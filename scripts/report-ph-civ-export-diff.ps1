param(
  [string]$ExportManifestPath = "registries/ph-civ-export-manifest.yaml",
  [string]$ChoreographyPath = "registries/ph-choreography.yaml",
  [string]$ReportsDir = ""
)

$ErrorActionPreference = 'Stop'

function Get-Text {
  param([Parameter(Mandatory = $true)][string]$Path)
  return (Get-Content -LiteralPath $Path -Raw -Encoding utf8) -replace "`r`n", "`n"
}

function Resolve-RepoPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return Join-Path -Path (Get-Location) -ChildPath ($Path -replace '/', [IO.Path]::DirectorySeparatorChar)
}

function Assert-FileExists {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Context
  )

  $resolved = Resolve-RepoPath -Path $Path
  if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
    throw "$Context points to missing file: $Path"
  }
  return $resolved
}

function Get-BlockField {
  param(
    [Parameter(Mandatory = $true)][string]$Block,
    [Parameter(Mandatory = $true)][string]$Field
  )

  $match = [regex]::Match($Block, "(?m)^\s+$([regex]::Escape($Field)):\s*(.+?)\s*$")
  if (-not $match.Success) {
    return ''
  }
  return $match.Groups[1].Value.Trim().Trim('"')
}

function Get-YamlList {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Field
  )

  $lines = $Text -split "`n"
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^(?<indent>\s*)$([regex]::Escape($Field)):\s*$") {
      $baseIndent = $matches.indent.Length
      $items = New-Object System.Collections.Generic.List[string]
      for ($j = $i + 1; $j -lt $lines.Count; $j++) {
        $line = $lines[$j]
        if ($line.Trim().Length -eq 0) {
          continue
        }
        $indent = ([regex]::Match($line, '^\s*')).Value.Length
        if ($indent -le $baseIndent) {
          break
        }
        if ($line -match '^\s*-\s*(.+?)\s*$') {
          $items.Add($matches[1].Trim().Trim('"')) | Out-Null
        }
      }
      return $items.ToArray()
    }
  }
  return @()
}

$exportManifestText = Get-Text -Path (Assert-FileExists -Path $ExportManifestPath -Context 'Export manifest')
$choreographyText = Get-Text -Path (Assert-FileExists -Path $ChoreographyPath -Context 'Choreography registry')
$sourceCommit = (& git rev-parse --short HEAD).Trim()

$routeBlocks = @{}
foreach ($match in [regex]::Matches($choreographyText, "(?ms)^\s+- source_id:\s*(\S+)\s*\n(.*?)(?=^\s+- source_id:|\z)")) {
  $routeBlocks[$match.Groups[1].Value] = $match.Groups[0].Value
}

$pilotRoutes = Get-YamlList -Text $exportManifestText -Field 'route_ids'
$rows = New-Object System.Collections.Generic.List[object]
foreach ($sourceId in $pilotRoutes) {
  $block = $routeBlocks[$sourceId]
  if (-not $block) {
    $rows.Add([pscustomobject]@{
      source_id = $sourceId
      surface = 'missing'
      public_export_status = 'missing_route'
      museum_status = ''
      claim_boundaries = ''
      blocker = 'Missing choreography route'
    }) | Out-Null
    continue
  }

  $publicExportStatus = Get-BlockField -Block $block -Field 'public_export_status'
  $readinessNote = Get-BlockField -Block $block -Field 'readiness_note'
  $blocker = ''
  if ($publicExportStatus -ne 'approved' -and $publicExportStatus -ne 'exported') {
    $blocker = $readinessNote
  }

  $rows.Add([pscustomobject]@{
    source_id = $sourceId
    surface = Get-BlockField -Block $block -Field 'surface'
    public_export_status = $publicExportStatus
    museum_status = Get-BlockField -Block $block -Field 'museum_status'
    claim_boundaries = (Get-YamlList -Text $block -Field 'claim_boundaries') -join ','
    blocker = $blocker
  }) | Out-Null
}

$approvedRoutes = @($rows | Where-Object { $_.public_export_status -eq 'approved' -or $_.public_export_status -eq 'exported' })

$summary = [pscustomobject]@{
  BatchId = 'pilot-001'
  SourceCommit = $sourceCommit
  RouteCount = $rows.Count
  ApprovedForPopulation = $approvedRoutes.Count
  PublicPopulationStatus = $(if ($approvedRoutes.Count -eq 0) { 'paused_no_routes_approved' } else { 'routes_ready_for_review' })
}

$summary | Format-List | Out-Host
$rows | Format-Table -AutoSize | Out-Host

if ($ReportsDir) {
  $resolvedReportsDir = Resolve-RepoPath -Path $ReportsDir
  New-Item -ItemType Directory -Force -Path $resolvedReportsDir | Out-Null

  $jsonPath = Join-Path $resolvedReportsDir 'ph-civ-export-diff.json'
  [pscustomobject]@{
    summary = $summary
    routes = $rows
  } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $jsonPath -Encoding utf8

  $mdPath = Join-Path $resolvedReportsDir 'ph-civ-export-diff.md'
  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add("# ph-civ Export Diff") | Out-Null
  $lines.Add("") | Out-Null
  $lines.Add("- Batch: pilot-001") | Out-Null
  $lines.Add("- Source commit: $sourceCommit") | Out-Null
  $lines.Add("- Approved for population: $($approvedRoutes.Count)") | Out-Null
  $lines.Add("") | Out-Null
  $lines.Add("| source_id | surface | export status | museum status | blocker |") | Out-Null
  $lines.Add("| --- | --- | --- | --- | --- |") | Out-Null
  foreach ($row in $rows) {
    $lines.Add("| $($row.source_id) | $($row.surface) | $($row.public_export_status) | $($row.museum_status) | $($row.blocker) |") | Out-Null
  }
  $lines -join "`n" | Set-Content -LiteralPath $mdPath -Encoding utf8
}
