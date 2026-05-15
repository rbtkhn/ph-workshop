param(
  [string]$ManifestPath = "chapter-manifest.yaml"
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

function Get-ManifestBlock {
  param(
    [Parameter(Mandatory = $true)][string]$ManifestText,
    [Parameter(Mandatory = $true)][string]$ChapterId
  )

  $chapterPattern = "(?ms)^\s+- chapter_id:\s*$([regex]::Escape($ChapterId))\s*\n(.*?)(?=^\s+- chapter_id:|\z)"
  $chapterMatch = [regex]::Match($ManifestText, $chapterPattern)
  if (-not $chapterMatch.Success) {
    throw "Missing manifest row: $ChapterId"
  }

  return $chapterMatch.Groups[0].Value
}

function Get-ManifestField {
  param(
    [Parameter(Mandatory = $true)][string]$Block,
    [Parameter(Mandatory = $true)][string]$Field,
    [Parameter(Mandatory = $true)][string]$ChapterId
  )

  $fieldMatch = [regex]::Match($Block, "(?m)^\s+$([regex]::Escape($Field)):\s*(.+?)\s*$")
  if (-not $fieldMatch.Success) {
    throw "Manifest row $ChapterId is missing $Field"
  }

  return $fieldMatch.Groups[1].Value.Trim('"')
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
}

$requiredFiles = @(
  'book/parts/civilization/README.md',
  'book/parts/civilization/index.md',
  'book/parts/world-war/README.md',
  'book/parts/world-war/index.md',
  'corpus/world-war/README.md',
  'corpus/world-war/index.md',
  'registries/actors.yaml',
  'registries/theaters.yaml',
  'registries/forecasts.yaml'
)

foreach ($file in $requiredFiles) {
  Assert-FileExists -Path $file -Context 'World War part surface'
}

foreach ($corridor in @(
  'us-iran',
  'russia-ukraine',
  'china-pacific',
  'dollar-finance',
  'state-decay',
  'escalation',
  'eschatology',
  'media-technology'
)) {
  Assert-FileExists -Path "corpus/world-war/$corridor.md" -Context "World War corridor $corridor"
}

$resolvedManifestPath = Resolve-RepoPath -Path $ManifestPath
if (-not (Test-Path -LiteralPath $resolvedManifestPath -PathType Leaf)) {
  throw "Manifest path does not exist: $ManifestPath"
}

$manifestText = Get-Text -Path $resolvedManifestPath
$expectedIds = @()
$expectedIds += 1..20 | ForEach-Object { 'geo-{0:D2}' -f $_ }
$expectedIds += 1..22 | ForEach-Object { 'gt-{0:D2}' -f $_ }
$expectedIds += 1..28 | ForEach-Object { 'sh-{0:D2}' -f $_ }

foreach ($chapterId in $expectedIds) {
  $block = Get-ManifestBlock -ManifestText $manifestText -ChapterId $chapterId
  if ((Get-ManifestField -Block $block -Field 'part' -ChapterId $chapterId) -ne 'world-war') {
    throw "Manifest row $chapterId must set part: world-war"
  }

  foreach ($field in @('corpus_path', 'part_i_path', 'part_ii_path', 'civ_ph_path', 'orientation_payload_path')) {
    $target = Get-ManifestField -Block $block -Field $field -ChapterId $chapterId
    Assert-FileExists -Path $target -Context "Manifest row $chapterId $field"
  }

  $phCivPath = Get-ManifestField -Block $block -Field 'civ_ph_path' -ChapterId $chapterId
  $phCivText = Get-Text -Path (Resolve-RepoPath -Path $phCivPath)
  if ($phCivText -notmatch '(?m)^part:\s*world-war\s*$') {
    throw "civ-ph entry $chapterId must set part: world-war"
  }
}

foreach ($dualId in @('sh-11', 'sh-16', 'sh-17', 'sh-18')) {
  $block = Get-ManifestBlock -ManifestText $manifestText -ChapterId $dualId
  if ((Get-ManifestField -Block $block -Field 'part_role' -ChapterId $dualId) -ne 'dual_civilization_support') {
    throw "Manifest row $dualId must preserve dual_civilization_support role"
  }
}

[pscustomobject]@{
  ManifestPath = $ManifestPath
  WorldWarUnits = $expectedIds.Count
  Status = 'world_war_part_valid'
} | Format-List | Out-Host
