param(
  [string]$RegistryPath = "registries/cross-volume-links.yaml",
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

$allowedRelationTypes = @('scale_shift', 'inheritance', 'revision', 'transmutation', 'return')
$allowedStrengths = @('strong', 'medium', 'light')
$requiredEdgeFields = @('from', 'to', 'relation_type', 'corridor', 'theme', 'claim', 'strength', 'guardrail')

$resolvedRegistryPath = Resolve-RepoPath -Path $RegistryPath
if (-not (Test-Path -LiteralPath $resolvedRegistryPath -PathType Leaf)) {
  throw "Cross-volume registry does not exist: $RegistryPath"
}

$resolvedManifestPath = Resolve-RepoPath -Path $ManifestPath
if (-not (Test-Path -LiteralPath $resolvedManifestPath -PathType Leaf)) {
  throw "Manifest path does not exist: $ManifestPath"
}

$registryText = Get-Text -Path $resolvedRegistryPath
$manifestText = Get-Text -Path $resolvedManifestPath

$corridorsSectionMatch = [regex]::Match($registryText, "(?ms)^corridors:\s*\n(.*?)(?=^edges:\s*$)")
if (-not $corridorsSectionMatch.Success) {
  throw "Registry $RegistryPath is missing a corridors section"
}

$corridorBlocks = [regex]::Matches($corridorsSectionMatch.Groups[1].Value, "(?ms)^\s+-\s+corridor:\s*(\S+)\s*\n(.*?)(?=^\s+-\s+corridor:|\z)")
if ($corridorBlocks.Count -eq 0) {
  throw "Registry $RegistryPath does not define any corridors"
}

$corridorPaths = @{}
foreach ($blockMatch in $corridorBlocks) {
  $corridor = $blockMatch.Groups[1].Value.Trim().Trim('"')
  $block = $blockMatch.Value
  $readerPath = Get-BlockField -Block $block -Field 'reader_path'
  if (-not $readerPath) {
    throw "Corridor $corridor is missing reader_path"
  }
  $resolvedReaderPath = Resolve-RepoPath -Path $readerPath
  if (-not (Test-Path -LiteralPath $resolvedReaderPath -PathType Leaf)) {
    throw "Corridor $corridor points to missing reader file: $readerPath"
  }
  $corridorPaths[$corridor] = $readerPath
}

$edgeMatches = [regex]::Matches($registryText, "(?ms)^\s+-\s+from:\s*(\S+)\s*\n(.*?)(?=^\s+-\s+from:|\z)")
if ($edgeMatches.Count -eq 0) {
  throw "Registry $RegistryPath does not define any edges"
}

foreach ($edgeMatch in $edgeMatches) {
  $edgeBlock = $edgeMatch.Value
  $from = $edgeMatch.Groups[1].Value.Trim().Trim('"')

  foreach ($field in $requiredEdgeFields) {
    if ($field -eq 'from') {
      continue
    }
    if (-not (Get-BlockField -Block $edgeBlock -Field $field)) {
      throw "Cross-volume edge from $from is missing field '$field'"
    }
  }

  $to = Get-BlockField -Block $edgeBlock -Field 'to'
  $relationType = Get-BlockField -Block $edgeBlock -Field 'relation_type'
  $corridor = Get-BlockField -Block $edgeBlock -Field 'corridor'
  $strength = Get-BlockField -Block $edgeBlock -Field 'strength'

  if ($relationType -notin $allowedRelationTypes) {
    throw "Cross-volume edge $from -> $to has invalid relation_type '$relationType'"
  }
  if ($strength -notin $allowedStrengths) {
    throw "Cross-volume edge $from -> $to has invalid strength '$strength'"
  }
  if (-not $corridorPaths.ContainsKey($corridor)) {
    throw "Cross-volume edge $from -> $to references unknown corridor '$corridor'"
  }

  foreach ($endpoint in @($from, $to)) {
    $manifestBlock = Get-ManifestBlock -ManifestText $manifestText -SourceId $endpoint
    if (-not $manifestBlock) {
      throw "Cross-volume endpoint $endpoint is missing from $ManifestPath"
    }

    $phCivPath = Get-BlockField -Block $manifestBlock -Field 'civ_ph_path'
    if (-not $phCivPath) {
      throw "Cross-volume endpoint $endpoint does not declare civ_ph_path in $ManifestPath"
    }

    $resolvedPhCivPath = Resolve-RepoPath -Path $phCivPath
    if (-not (Test-Path -LiteralPath $resolvedPhCivPath -PathType Leaf)) {
      throw "Cross-volume endpoint $endpoint points civ_ph_path to missing file: $phCivPath"
    }
  }
}

[pscustomobject]@{
  RegistryPath = $RegistryPath
  ManifestPath = $ManifestPath
  CorridorCount = $corridorBlocks.Count
  EdgeCount = $edgeMatches.Count
  Status = 'cross_volume_links_valid'
} | Format-List | Out-Host
