param(
  [string]$ExportManifestPath = "registries/ph-civ-export-manifest.yaml",
  [string]$ChoreographyPath = "registries/ph-choreography.yaml",
  [string]$ClaimBoundaryPath = "registries/ph-claim-boundaries.yaml",
  [string]$PrePublicationDocPath = "docs/ph-civ-pre-publication-release.md"
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
    return $null
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
$claimBoundaryText = Get-Text -Path (Assert-FileExists -Path $ClaimBoundaryPath -Context 'Claim boundary registry')
$prePublicationDocText = Get-Text -Path (Assert-FileExists -Path $PrePublicationDocPath -Context 'Pre-publication release doc')

foreach ($required in @(
  'target_repo: rbtkhn/ph-civ',
  'source_repo: rbtkhn/ph-workshop',
  'release_stage: pre_publication_scaffold',
  'public_population: paused',
  'approval_authority: route_public_export_status',
  'batch_id: pilot-001'
)) {
  if ($exportManifestText -notmatch [regex]::Escape($required)) {
    throw "Export manifest missing required marker: $required"
  }
}

$allowedBoundaries = New-Object System.Collections.Generic.HashSet[string]
foreach ($match in [regex]::Matches($claimBoundaryText, '(?m)^\s+- tag:\s*(\S+)\s*$')) {
  $allowedBoundaries.Add($match.Groups[1].Value.Trim()) | Out-Null
}
foreach ($requiredBoundary in @('orientation', 'interpretive', 'historical_claim', 'current_events', 'forecast_bearing', 'rights_sensitive', 'artifact_manifest')) {
  if (-not $allowedBoundaries.Contains($requiredBoundary)) {
    throw "Claim boundary taxonomy missing required tag: $requiredBoundary"
  }
}

$routeBlocks = @{}
foreach ($match in [regex]::Matches($choreographyText, "(?ms)^\s+- source_id:\s*(\S+)\s*\n(.*?)(?=^\s+- source_id:|\z)")) {
  $routeBlocks[$match.Groups[1].Value] = $match.Groups[0].Value
}
if ($routeBlocks.Count -eq 0) {
  throw "No choreography routes found in $ChoreographyPath"
}

$pilotRoutes = Get-YamlList -Text $exportManifestText -Field 'route_ids'
if ($pilotRoutes.Count -eq 0) {
  throw "Export manifest pilot-001 has no route_ids"
}

$approvedCount = 0
$exportedCount = 0
foreach ($sourceId in $pilotRoutes) {
  if (-not $routeBlocks.ContainsKey($sourceId)) {
    throw "Export manifest pilot-001 references unknown choreography route: $sourceId"
  }

  $block = $routeBlocks[$sourceId]
  $surface = Get-BlockField -Block $block -Field 'surface'
  $museumStatus = Get-BlockField -Block $block -Field 'museum_status'
  $publicExportStatus = Get-BlockField -Block $block -Field 'public_export_status'
  $claimBoundaries = Get-YamlList -Text $block -Field 'claim_boundaries'

  if ($publicExportStatus -eq 'approved') {
    $approvedCount += 1
  }
  if ($publicExportStatus -eq 'exported') {
    $exportedCount += 1
  }
  if ($exportManifestText -match 'release_stage:\s*pre_publication_scaffold' -and $publicExportStatus -eq 'exported') {
    throw "Route $sourceId is exported while export manifest remains pre_publication_scaffold"
  }
  if ($claimBoundaries.Count -eq 0) {
    throw "Route $sourceId is missing claim_boundaries"
  }

  foreach ($boundary in $claimBoundaries) {
    if (-not $allowedBoundaries.Contains($boundary)) {
      throw "Route $sourceId has unknown claim boundary: $boundary"
    }
  }

  foreach ($required in @('orientation', 'interpretive', 'historical_claim')) {
    if ($claimBoundaries -notcontains $required) {
      throw "Route $sourceId is missing required claim boundary: $required"
    }
  }

  if ($surface -eq 'ph-apo') {
    foreach ($required in @('current_events', 'forecast_bearing')) {
      if ($claimBoundaries -notcontains $required) {
        throw "Route $sourceId ph-apo route is missing stronger claim boundary: $required"
      }
    }
  }

  if ($museumStatus -and $museumStatus -ne 'none') {
    foreach ($required in @('rights_sensitive', 'artifact_manifest')) {
      if ($claimBoundaries -notcontains $required) {
        throw "Route $sourceId museum route is missing museum claim boundary: $required"
      }
    }
  }
}

foreach ($requiredText in @(
  'What This Is Not',
  'README.md',
  'llms.txt',
  'surface descriptions',
  'route data',
  'museum index',
  'no binary artifacts',
  'Unavailable route',
  'Uncurated museum exhibit',
  'Paused export',
  'Apocalypse caution'
)) {
  if ($prePublicationDocText -notmatch [regex]::Escape($requiredText)) {
    throw "Pre-publication doc missing required front-door or empty-state text: $requiredText"
  }
}

[pscustomobject]@{
  ExportManifestPath = $ExportManifestPath
  BatchId = 'pilot-001'
  RouteCount = $pilotRoutes.Count
  ApprovedRouteCount = $approvedCount
  ExportedRouteCount = $exportedCount
  Status = 'ph_civ_export_scaffold_valid'
} | Format-List | Out-Host
