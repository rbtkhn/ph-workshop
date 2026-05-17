param(
  [string]$PhCivPath
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$ManifestPath = Join-Path $RepoRoot 'registries/ph-civ-export-manifest.yaml'
$ChoreographyPath = Join-Path $RepoRoot 'registries/ph-choreography.yaml'
$CheckFailures = New-Object System.Collections.Generic.List[string]

function Get-Scalar {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Key
  )

  $match = [regex]::Match($Text, "(?m)^\s*(?:-\s+)?$([regex]::Escape($Key)):\s*(.+?)\s*$")
  if (-not $match.Success) {
    return ''
  }
  return ($match.Groups[1].Value.Trim() -replace '^"|"$', '')
}

function Get-Routes {
  param([Parameter(Mandatory = $true)][string]$Path)

  $routes = New-Object System.Collections.Generic.List[object]
  $current = $null

  foreach ($line in Get-Content -LiteralPath $Path -Encoding utf8) {
    if ($line -match '^\s*-\s+source_id:\s*(\S+)\s*$') {
      if ($null -ne $current) {
        $routes.Add([pscustomobject]$current) | Out-Null
      }
      $current = [ordered]@{
        source_id = $Matches[1]
        surface = ''
        museum_status = ''
        public_export_status = ''
        readiness_note = ''
      }
      continue
    }

    if ($null -eq $current) {
      continue
    }

    if ($line -match '^\s+(surface|museum_status|public_export_status|readiness_note):\s*(.*)\s*$') {
      $current[$Matches[1]] = ($Matches[2].Trim() -replace '^"|"$', '')
    }
  }

  if ($null -ne $current) {
    $routes.Add([pscustomobject]$current) | Out-Null
  }

  return $routes
}

function Invoke-OpeningCheck {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$ScriptPath
  )

  Write-Host ""
  Write-Host "== $Name =="
  try {
    & $ScriptPath | Out-Host
    Write-Host "check_status: pass"
  } catch {
    $CheckFailures.Add($Name) | Out-Null
    Write-Host "check_status: fail"
    Write-Host "error: $($_.Exception.Message)"
  }
}

function Test-PhCivTarget {
  param([Parameter(Mandatory = $true)][string]$Path)

  Write-Host ""
  Write-Host "== ph-civ target check =="
  if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    $CheckFailures.Add('ph-civ target path') | Out-Null
    Write-Host "target_status: missing"
    Write-Host "target_path: $Path"
    return
  }

  $resolved = Resolve-Path -LiteralPath $Path
  Write-Host "target_path: $resolved"

  try {
    $inside = git -C $resolved rev-parse --is-inside-work-tree 2>&1
    if ($LASTEXITCODE -ne 0 -or $inside.Trim() -ne 'true') {
      throw "not a git worktree"
    }

    $origin = git -C $resolved remote get-url origin 2>&1
    if ($LASTEXITCODE -ne 0) {
      throw "origin remote unavailable"
    }

    Write-Host "target_origin: $origin"
    if ($origin -notmatch 'github\.com[:/]rbtkhn/ph-civ(\.git)?$') {
      $CheckFailures.Add('ph-civ target origin') | Out-Null
      Write-Host "target_origin_status: unexpected"
    } else {
      Write-Host "target_origin_status: ok"
    }

    Write-Host "target_worktree_status:"
    git -C $resolved status --short --branch | ForEach-Object { Write-Host "  $_" }
  } catch {
    $CheckFailures.Add('ph-civ target git') | Out-Null
    Write-Host "target_status: invalid"
    Write-Host "error: $($_.Exception.Message)"
  }
}

$manifestText = Get-Content -LiteralPath $ManifestPath -Raw -Encoding utf8
$routes = @(Get-Routes -Path $ChoreographyPath)

$targetRepo = Get-Scalar -Text $manifestText -Key 'target_repo'
$sourceRepo = Get-Scalar -Text $manifestText -Key 'source_repo'
$releaseStage = Get-Scalar -Text $manifestText -Key 'release_stage'
$publicPopulation = Get-Scalar -Text $manifestText -Key 'public_population'
$approvalAuthority = Get-Scalar -Text $manifestText -Key 'approval_authority'
$batchId = Get-Scalar -Text $manifestText -Key 'batch_id'
$sourceCommit = (git -C $RepoRoot rev-parse --short HEAD).Trim()
$repoStatus = @(git -C $RepoRoot status --short --branch)

$approvedRoutes = @($routes | Where-Object { $_.public_export_status -in @('approved', 'exported') })
$candidateRoutes = @($routes | Where-Object { $_.public_export_status -eq 'candidate' })
$statusCounts = $routes | Group-Object public_export_status | Sort-Object Name

Write-Host "PH-CIV Population Opening Brief"
Write-Host "================================"
Write-Host "source_repo: $sourceRepo"
Write-Host "target_repo: $targetRepo"
Write-Host "source_commit: $sourceCommit"
Write-Host "batch_id: $batchId"
Write-Host "release_stage: $releaseStage"
Write-Host "public_population: $publicPopulation"
Write-Host "approval_authority: $approvalAuthority"
Write-Host ""
Write-Host "worktree_status:"
$repoStatus | ForEach-Object { Write-Host "  $_" }
Write-Host ""
Write-Host "route_status_counts:"
foreach ($count in $statusCounts) {
  Write-Host "  $($count.Name): $($count.Count)"
}
Write-Host ""
Write-Host "ApprovedForPopulation = $($approvedRoutes.Count)"
Write-Host "CandidateRouteCount = $($candidateRoutes.Count)"

if ($candidateRoutes.Count -gt 0) {
  Write-Host ""
  Write-Host "candidate_routes:"
  foreach ($route in $candidateRoutes) {
    Write-Host "  - $($route.source_id) [$($route.surface)] $($route.readiness_note)"
  }
}

if ($approvedRoutes.Count -gt 0) {
  Write-Host ""
  Write-Host "approved_or_exported_routes:"
  foreach ($route in $approvedRoutes) {
    Write-Host "  - $($route.source_id) [$($route.public_export_status)]"
  }
  Write-Host ""
  Write-Host "readiness_token: population_ready_approved_routes_present"
} else {
  Write-Host ""
  Write-Host "readiness_token: population_blocked_no_approved_routes"
  if ($candidateRoutes.Count -gt 0) {
    Write-Host "review_token: candidate_review_ready"
  }
}

Invoke-OpeningCheck -Name 'ph-civ export scaffold' -ScriptPath (Join-Path $PSScriptRoot 'validate-ph-civ-export-scaffold.ps1')
Invoke-OpeningCheck -Name 'ph-civ publication gate' -ScriptPath (Join-Path $PSScriptRoot 'validate-ph-publication-gate.ps1')
Invoke-OpeningCheck -Name 'ph-civ export diff' -ScriptPath (Join-Path $PSScriptRoot 'report-ph-civ-export-diff.ps1')

if ($PhCivPath) {
  Test-PhCivTarget -Path $PhCivPath
}

$candidateIds = if ($candidateRoutes.Count -gt 0) {
  ($candidateRoutes | ForEach-Object { $_.source_id }) -join ', '
} else {
  'none'
}
$approvedIds = if ($approvedRoutes.Count -gt 0) {
  ($approvedRoutes | ForEach-Object { $_.source_id }) -join ', '
} else {
  'none'
}
$populationInstruction = if ($approvedRoutes.Count -gt 0) {
  "Approved/exported routes are present: $approvedIds. Prepare only a guarded population plan before writing to ph-civ."
} else {
  "No routes are approved/exported. Review blockers only; do not populate ph-civ."
}

Write-Host ""
Write-Host "== copy-ready next-chat prompt =="
@"
Open rbtkhn/ph-workshop as the editorial source for rbtkhn/ph-civ. Start with llms.txt, then run scripts/ph-civ-open.ps1 and summarize the gate state before proposing work.

Current opening state from this checkout:
- source_commit: $sourceCommit
- batch_id: $batchId
- public_population: $publicPopulation
- ApprovedForPopulation: $($approvedRoutes.Count)
- candidate_routes: $candidateIds
- approved_or_exported_routes: $approvedIds

Boundary: ph-workshop is the editorial authority and ph-civ is the public consumption layer. Candidate routes are review-only. Do not copy transcripts, commentary bodies, museum binaries, workshop-private material, or any route into ph-civ unless route-level public_export_status is approved or exported and the operator explicitly asks for population.

Next action: $populationInstruction
"@ | Write-Host

if ($CheckFailures.Count -gt 0) {
  Write-Host ""
  Write-Host "opening_check_status: failed"
  Write-Host "failed_checks: $($CheckFailures -join ', ')"
  exit 1
}

Write-Host ""
Write-Host "opening_check_status: pass"
