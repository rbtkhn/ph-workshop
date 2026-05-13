param(
  [string]$ManifestPath = "chapter-manifest.yaml",
  [string]$StrategyRoot = "..\strategy-codex\codex\predictive-history"
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

function Get-SourceBlock {
  param(
    [Parameter(Mandatory = $true)][string]$SourceText,
    [Parameter(Mandatory = $true)][string]$SourceId
  )

  $match = [regex]::Match($SourceText, "(?ms)^- source_id: $([regex]::Escape($SourceId))\n(.*?)(?=^- source_id: |\z)")
  if (-not $match.Success) {
    throw "Missing strategy-codex metadata block for $SourceId"
  }

  return "- source_id: $SourceId`n$($match.Groups[1].Value)"
}

function Get-YamlScalar {
  param(
    [Parameter(Mandatory = $true)][string]$Block,
    [Parameter(Mandatory = $true)][string]$Key
  )

  $match = [regex]::Match($Block, "(?m)^\s*$([regex]::Escape($Key)):\s*(.*)$")
  if (-not $match.Success) {
    throw "Missing strategy-codex key '$Key'"
  }

  $value = $match.Groups[1].Value.Trim()
  if ($value -eq 'null') {
    return $null
  }

  if (($value.StartsWith("'") -and $value.EndsWith("'")) -or ($value.StartsWith('"') -and $value.EndsWith('"'))) {
    $value = $value.Substring(1, $value.Length - 2)
    $value = $value -replace "''", "'"
  }

  return $value
}

function Get-BodyFromMarker {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Marker
  )

  $markerIndex = $Text.IndexOf($Marker, [System.StringComparison]::Ordinal)
  if ($markerIndex -lt 0) {
    throw "Marker '$Marker' not found"
  }

  $afterMarker = $markerIndex + $Marker.Length
  $bodyStart = $Text.IndexOf("`n`n", $afterMarker, [System.StringComparison]::Ordinal)
  if ($bodyStart -lt 0) {
    throw "Could not find body separator after '$Marker'"
  }

  return (($Text.Substring($bodyStart + 2) -replace "(?m)[ `t]+$", '').Trim())
}

function Get-FrontmatterValue {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Key
  )

  $frontmatter = [regex]::Match($Text, "(?ms)\A---\n(.*?)\n---\n")
  if (-not $frontmatter.Success) {
    throw "Missing frontmatter while reading key '$Key'"
  }

  $match = [regex]::Match($frontmatter.Groups[1].Value, "(?m)^$([regex]::Escape($Key)):\s*(.*)$")
  if (-not $match.Success) {
    throw "Missing frontmatter key '$Key'"
  }

  return $match.Groups[1].Value.Trim().Trim('"')
}

$resolvedManifestPath = Resolve-RepoPath -Path $ManifestPath
if (-not (Test-Path -LiteralPath $resolvedManifestPath -PathType Leaf)) {
  throw "Manifest path does not exist: $ManifestPath"
}

$manifestText = Get-Text -Path $resolvedManifestPath
$expectedIds = 1..25 | ForEach-Object { "civ-{0:D2}" -f $_ }
$strategySourcesPath = Join-Path -Path $StrategyRoot -ChildPath 'metadata\sources.yaml'
if (-not (Test-Path -LiteralPath $strategySourcesPath -PathType Leaf)) {
  throw "Strategy metadata path does not exist: $strategySourcesPath"
}

$strategySourcesText = Get-Text -Path $strategySourcesPath

foreach ($chapterId in $expectedIds) {
  $sourceBlock = Get-SourceBlock -SourceText $strategySourcesText -SourceId $chapterId
  $expectedTitle = Get-YamlScalar -Block $sourceBlock -Key 'title'
  $expectedUrl = Get-YamlScalar -Block $sourceBlock -Key 'canonical_url'
  $expectedDate = Get-YamlScalar -Block $sourceBlock -Key 'publication_date'
  $lecturePath = Get-YamlScalar -Block $sourceBlock -Key 'lecture_path'
  $strategyLecturePath = Join-Path -Path $StrategyRoot -ChildPath ($lecturePath -replace '/', [IO.Path]::DirectorySeparatorChar)
  if (-not (Test-Path -LiteralPath $strategyLecturePath -PathType Leaf)) {
    throw "Strategy lecture path does not exist for ${chapterId}: $strategyLecturePath"
  }

  $chapterPattern = "(?ms)^\s+- chapter_id:\s*$([regex]::Escape($chapterId))\s*\n(.*?)(?=^\s+- chapter_id:|\z)"
  $chapterMatch = [regex]::Match($manifestText, $chapterPattern)
  if (-not $chapterMatch.Success) {
    throw "Missing Civilization spine manifest row: $chapterId"
  }

  $block = $chapterMatch.Groups[0].Value
  foreach ($field in @('corpus_path', 'part_i_path', 'part_ii_path', 'ph_civ_path')) {
    $fieldMatch = [regex]::Match($block, "(?m)^\s+${field}:\s*(\S+)\s*$")
    if (-not $fieldMatch.Success) {
      throw "Manifest row $chapterId is missing $field"
    }

    $target = $fieldMatch.Groups[1].Value.Trim('"')
    $resolvedTarget = Resolve-RepoPath -Path $target
    if (-not (Test-Path -LiteralPath $resolvedTarget -PathType Leaf)) {
      throw "Manifest row $chapterId points $field to missing file: $target"
    }
  }

  $transcriptPath = Resolve-RepoPath -Path "book/volume-ii/$chapterId/$chapterId-transcript.md"
  $transcriptText = Get-Text -Path $transcriptPath
  if ($transcriptText -notmatch "(?ms)^## Part I: Full transcript\s*\n\n\S") {
    throw "Transcript $chapterId is missing non-empty Part I body"
  }

  $sourceId = Get-FrontmatterValue -Text $transcriptText -Key 'source_id'
  if ($sourceId -ne $chapterId) {
    throw "Transcript $chapterId has mismatched source_id '$sourceId'"
  }

  foreach ($metadataCheck in @(
    @{ Key = 'title'; Expected = $expectedTitle },
    @{ Key = 'canonical_url'; Expected = $expectedUrl },
    @{ Key = 'publication_date'; Expected = $expectedDate }
  )) {
    $actualValue = Get-FrontmatterValue -Text $transcriptText -Key $metadataCheck.Key
    if ($actualValue -ne $metadataCheck.Expected) {
      throw "Transcript $chapterId metadata '$($metadataCheck.Key)' mismatch. Expected '$($metadataCheck.Expected)', found '$actualValue'"
    }
  }

  $representation = Get-FrontmatterValue -Text $transcriptText -Key 'representation_not_endorsement'
  if ($representation -ne 'true') {
    throw "Transcript $chapterId must preserve representation_not_endorsement: true"
  }

  $strategyLectureText = Get-Text -Path $strategyLecturePath
  $strategyBody = Get-BodyFromMarker -Text $strategyLectureText -Marker '## Full transcript'
  $targetBody = Get-BodyFromMarker -Text $transcriptText -Marker '## Part I: Full transcript'
  if ($strategyBody -cne $targetBody) {
    throw "Transcript body mismatch for $chapterId against strategy-codex transfer source"
  }
}

[pscustomobject]@{
  ManifestPath = $ManifestPath
  StrategyRoot = $StrategyRoot
  ChapterCount = $expectedIds.Count
  Status = 'civilization_spine_valid'
} | Format-List | Out-Host
