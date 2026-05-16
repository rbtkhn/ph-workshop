param(
  [string]$RegistryPath = "registries/causation-lenses.yaml",
  [string]$CrossVolumeRegistryPath = "registries/cross-volume-links.yaml",
  [string]$ManifestPath = "chapter-manifest.yaml",
  [string]$CorridorPath = "corpus/cross-volume/tolstoy-question.md"
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

function Get-ManifestBlock {
  param(
    [Parameter(Mandatory = $true)][string]$ManifestText,
    [Parameter(Mandatory = $true)][string]$SourceId
  )

  $pattern = "(?ms)^\s*-\s+(?:id|chapter_id):\s*$([regex]::Escape($SourceId))\s*$.*?(?=^\s*-\s+(?:id|chapter_id):\s*|\z)"
  $match = [regex]::Match($ManifestText, $pattern)
  if (-not $match.Success) {
    return $null
  }
  return $match.Value
}

$requiredLensIds = @('civ-15', 'civ-16', 'civ-25', 'civ-48', 'civ-53', 'sh-16', 'civ-59', 'gt-21', 'gt-22')
$requiredFields = @('source_id', 'visible_actor', 'causation_question', 'caution')
$requiredSectionLabels = @('Visible actor', 'Underlying pressure', 'Tolstoy question', 'Limit')

$resolvedRegistryPath = Resolve-RepoPath -Path $RegistryPath
if (-not (Test-Path -LiteralPath $resolvedRegistryPath -PathType Leaf)) {
  throw "Causation lens registry does not exist: $RegistryPath"
}

$resolvedCrossVolumeRegistryPath = Resolve-RepoPath -Path $CrossVolumeRegistryPath
if (-not (Test-Path -LiteralPath $resolvedCrossVolumeRegistryPath -PathType Leaf)) {
  throw "Cross-volume registry does not exist: $CrossVolumeRegistryPath"
}

$resolvedManifestPath = Resolve-RepoPath -Path $ManifestPath
if (-not (Test-Path -LiteralPath $resolvedManifestPath -PathType Leaf)) {
  throw "Manifest path does not exist: $ManifestPath"
}

$resolvedCorridorPath = Resolve-RepoPath -Path $CorridorPath
if (-not (Test-Path -LiteralPath $resolvedCorridorPath -PathType Leaf)) {
  throw "Tolstoy question corridor file does not exist: $CorridorPath"
}

$registryText = Get-Text -Path $resolvedRegistryPath
$crossVolumeText = Get-Text -Path $resolvedCrossVolumeRegistryPath
$manifestText = Get-Text -Path $resolvedManifestPath
$corridorText = Get-Text -Path $resolvedCorridorPath

if ($registryText -notmatch "(?m)^version:\s*1\s*$") {
  throw "Causation lens registry must declare version: 1"
}
if ($registryText -notmatch "(?m)^lenses:\s*$") {
  throw "Causation lens registry must declare a lenses section"
}
if ($crossVolumeText -notmatch "(?m)^\s+-\s+corridor:\s*tolstoy-question\s*$") {
  throw "Cross-volume registry must define corridor tolstoy-question"
}
if ($crossVolumeText -notmatch "(?m)^\s+reader_path:\s*$([regex]::Escape($CorridorPath))\s*$") {
  throw "Cross-volume registry must route tolstoy-question to $CorridorPath"
}

foreach ($phrase in @('visible actors', 'deeper pressures', 'great-man history')) {
  if ($corridorText -notmatch [regex]::Escape($phrase)) {
    throw "Tolstoy question corridor should mention '$phrase'"
  }
}

$lensMatches = [regex]::Matches($registryText, "(?ms)^\s+-\s+source_id:\s*(\S+)\s*\n(.*?)(?=^\s+-\s+source_id:|\z)")
if ($lensMatches.Count -eq 0) {
  throw "Causation lens registry does not define any lenses"
}

$seen = @{}
foreach ($lensMatch in $lensMatches) {
  $block = $lensMatch.Value
  $sourceId = $lensMatch.Groups[1].Value.Trim().Trim('"')
  $seen[$sourceId] = $true

  foreach ($field in $requiredFields) {
    if ($field -eq 'source_id') {
      continue
    }
    if (-not (Get-BlockField -Block $block -Field $field)) {
      throw "Causation lens $sourceId is missing field '$field'"
    }
  }

  if ($block -notmatch "(?m)^\s+underlying_pressures:\s*$") {
    throw "Causation lens $sourceId is missing underlying_pressures"
  }
  $pressureCount = ([regex]::Matches($block, "(?m)^\s{6}-\s+")).Count
  if ($pressureCount -lt 2) {
    throw "Causation lens $sourceId should include at least two underlying pressures"
  }

  $manifestBlock = Get-ManifestBlock -ManifestText $manifestText -SourceId $sourceId
  if (-not $manifestBlock) {
    throw "Causation lens source $sourceId is missing from $ManifestPath"
  }

  $civPhPath = Get-BlockField -Block $manifestBlock -Field 'civ_ph_path'
  if (-not $civPhPath) {
    throw "Causation lens source $sourceId does not declare civ_ph_path"
  }

  $resolvedCivPhPath = Resolve-RepoPath -Path $civPhPath
  if (-not (Test-Path -LiteralPath $resolvedCivPhPath -PathType Leaf)) {
    throw "Causation lens source $sourceId points civ_ph_path to missing file: $civPhPath"
  }

  $civPhText = Get-Text -Path $resolvedCivPhPath
  if ($civPhText -notmatch "(?m)^## Agency And Necessity\s*$") {
    throw "civ-ph entry $civPhPath is missing '## Agency And Necessity'"
  }
  foreach ($label in $requiredSectionLabels) {
    if ($civPhText -notmatch "(?m)^-\s+\*\*$([regex]::Escape($label)):\*\*") {
      throw "civ-ph entry $civPhPath is missing Agency And Necessity label '$label'"
    }
  }
}

foreach ($sourceId in $requiredLensIds) {
  if (-not $seen.ContainsKey($sourceId)) {
    throw "Causation lens registry is missing required source_id $sourceId"
  }
}

[pscustomobject]@{
  RegistryPath = $RegistryPath
  CorridorPath = $CorridorPath
  LensCount = $lensMatches.Count
  RequiredLensCount = $requiredLensIds.Count
  Status = 'causation_lens_valid'
} | Format-List | Out-Host
