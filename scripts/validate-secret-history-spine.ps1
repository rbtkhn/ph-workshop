param(
  [string]$ManifestPath = "chapter-manifest.yaml",
  [string]$StrategyRoot = "..\strategy-codex\codex\predictive-history",
  [string[]]$ExpectedIds = @('sh-11', 'sh-16', 'sh-17', 'sh-18')
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

function Get-ManifestBlock {
  param(
    [Parameter(Mandatory = $true)][string]$ManifestText,
    [Parameter(Mandatory = $true)][string]$ChapterId
  )

  $chapterPattern = "(?ms)^\s+- chapter_id:\s*$([regex]::Escape($ChapterId))\s*\n(.*?)(?=^\s+- chapter_id:|\z)"
  $chapterMatch = [regex]::Match($ManifestText, $chapterPattern)
  if (-not $chapterMatch.Success) {
    throw "Missing Secret History manifest row: $ChapterId"
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

  return $resolved
}

$resolvedManifestPath = Resolve-RepoPath -Path $ManifestPath
if (-not (Test-Path -LiteralPath $resolvedManifestPath -PathType Leaf)) {
  throw "Manifest path does not exist: $ManifestPath"
}

$strategySourcesPath = Join-Path -Path $StrategyRoot -ChildPath 'metadata\sources.yaml'
if (-not (Test-Path -LiteralPath $strategySourcesPath -PathType Leaf)) {
  throw "Strategy metadata path does not exist: $strategySourcesPath"
}

$manifestText = Get-Text -Path $resolvedManifestPath
$strategySourcesText = Get-Text -Path $strategySourcesPath
$requiredCommentarySections = @(
  'Core Thesis & Literary Role',
  'Neutral Lecture Summary',
  'Key Terms, Texts, and Interpretive Claims',
  'Passage / Argument Anchors',
  'Counter-Readings & Limits',
  'Cross-Series Links',
  'Open Issues & Future Review'
)

foreach ($chapterId in $ExpectedIds) {
  $sourceBlock = Get-SourceBlock -SourceText $strategySourcesText -SourceId $chapterId
  $expectedTitle = Get-YamlScalar -Block $sourceBlock -Key 'title'
  $expectedUrl = Get-YamlScalar -Block $sourceBlock -Key 'canonical_url'
  $expectedDate = Get-YamlScalar -Block $sourceBlock -Key 'publication_date'
  $expectedVideoId = Get-YamlScalar -Block $sourceBlock -Key 'video_id'
  $lecturePath = Get-YamlScalar -Block $sourceBlock -Key 'lecture_path'
  $strategyLecturePath = Join-Path -Path $StrategyRoot -ChildPath ($lecturePath -replace '/', [IO.Path]::DirectorySeparatorChar)

  if (-not (Test-Path -LiteralPath $strategyLecturePath -PathType Leaf)) {
    throw "Strategy transfer lecture does not exist for ${chapterId}: $strategyLecturePath"
  }

  $block = Get-ManifestBlock -ManifestText $manifestText -ChapterId $chapterId
  foreach ($field in @('corpus_path', 'part_i_path', 'part_ii_path', 'ph_civ_path', 'orientation_payload_path')) {
    $target = Get-ManifestField -Block $block -Field $field -ChapterId $chapterId
    Assert-FileExists -Path $target -Context "Manifest row $chapterId $field" | Out-Null
  }

  foreach ($fieldCheck in @(
    @{ Field = 'series'; Expected = 'secret-history' },
    @{ Field = 'title'; Expected = $expectedTitle },
    @{ Field = 'source_url'; Expected = $expectedUrl },
    @{ Field = 'publication_date'; Expected = $expectedDate },
    @{ Field = 'transcript_fidelity'; Expected = 'exact_body_match' },
    @{ Field = 'review_status'; Expected = 'source_reviewed' },
    @{ Field = 'subset_status'; Expected = 'literary_subset' }
  )) {
    $actual = Get-ManifestField -Block $block -Field $fieldCheck.Field -ChapterId $chapterId
    if ($actual -ne $fieldCheck.Expected) {
      throw "Manifest row $chapterId field '$($fieldCheck.Field)' mismatch. Expected '$($fieldCheck.Expected)', found '$actual'"
    }
  }

  $corpusPath = Get-ManifestField -Block $block -Field 'corpus_path' -ChapterId $chapterId
  $transcriptPath = Get-ManifestField -Block $block -Field 'part_i_path' -ChapterId $chapterId
  $commentaryPath = Get-ManifestField -Block $block -Field 'part_ii_path' -ChapterId $chapterId
  $phCivPath = Get-ManifestField -Block $block -Field 'ph_civ_path' -ChapterId $chapterId
  $payloadPath = Get-ManifestField -Block $block -Field 'orientation_payload_path' -ChapterId $chapterId

  $transcriptText = Get-Text -Path (Resolve-RepoPath -Path $transcriptPath)
  foreach ($metadataCheck in @(
    @{ Key = 'source_id'; Expected = $chapterId },
    @{ Key = 'source_series'; Expected = 'secret-history' },
    @{ Key = 'title'; Expected = $expectedTitle },
    @{ Key = 'source_url'; Expected = $expectedUrl },
    @{ Key = 'video_id'; Expected = $expectedVideoId },
    @{ Key = 'publication_date'; Expected = $expectedDate },
    @{ Key = 'transcript_fidelity'; Expected = 'exact_body_match' },
    @{ Key = 'transcript_source'; Expected = 'strategy_codex_transfer' },
    @{ Key = 'representation_not_endorsement'; Expected = 'true' }
  )) {
    $actualValue = Get-FrontmatterValue -Text $transcriptText -Key $metadataCheck.Key
    if ($actualValue -ne $metadataCheck.Expected) {
      throw "Transcript $chapterId metadata '$($metadataCheck.Key)' mismatch. Expected '$($metadataCheck.Expected)', found '$actualValue'"
    }
  }

  $targetBody = Get-BodyFromMarker -Text $transcriptText -Marker '## Part I: Full transcript'
  $strategyLectureText = Get-Text -Path $strategyLecturePath
  $strategyBody = Get-BodyFromMarker -Text $strategyLectureText -Marker '## Full transcript'
  if ($strategyBody -cne $targetBody) {
    throw "Transcript body mismatch for $chapterId against strategy-codex transfer source"
  }

  $corpusText = Get-Text -Path (Resolve-RepoPath -Path $corpusPath)
  if ((Get-FrontmatterValue -Text $corpusText -Key 'subset_status') -ne 'literary_subset') {
    throw "Corpus entry $chapterId must mark subset_status: literary_subset"
  }
  if ($corpusText -notmatch 'limited Secret History literary/imagination subset') {
    throw "Corpus entry $chapterId must state the limited subset boundary"
  }

  $commentaryText = Get-Text -Path (Resolve-RepoPath -Path $commentaryPath)
  if ((Get-FrontmatterValue -Text $commentaryText -Key 'template_family') -ne 'secret-history-literary-commentary') {
    throw "Commentary $chapterId must use template_family: secret-history-literary-commentary"
  }
  foreach ($section in $requiredCommentarySections) {
    if ($commentaryText -notmatch "(?m)^##\s+$([regex]::Escape($section))\s*$") {
      throw "Commentary $chapterId is missing section '$section'"
    }
  }

  $phCivText = Get-Text -Path (Resolve-RepoPath -Path $phCivPath)
  $payloadText = Get-Text -Path (Resolve-RepoPath -Path $payloadPath)
  if ((Get-FrontmatterValue -Text $phCivText -Key 'source_series') -ne 'secret-history') {
    throw "PH-CIV $chapterId must set source_series: secret-history"
  }
  if ((Get-FrontmatterValue -Text $phCivText -Key 'review_status') -ne 'in_review') {
    throw "PH-CIV $chapterId must set review_status: in_review"
  }
  $phCivWeight = Get-FrontmatterValue -Text $phCivText -Key 'placement_weight'
  $payloadWeightMatch = [regex]::Match($payloadText, '(?m)^placement_weight:\s*(\S+)\s*$')
  if (-not $payloadWeightMatch.Success) {
    throw "Orientation payload $chapterId is missing placement_weight"
  }
  if ($payloadWeightMatch.Groups[1].Value -ne $phCivWeight) {
    throw "PH-CIV $chapterId placement_weight does not match orientation payload"
  }
  if ($chapterId -eq 'sh-16' -and $phCivText -notmatch 'not a dedicated Tolstoy lecture') {
    throw "PH-CIV sh-16 must caveat that it is not a dedicated Tolstoy lecture"
  }
}

[pscustomobject]@{
  ManifestPath = $ManifestPath
  StrategyRoot = $StrategyRoot
  ChapterCount = $ExpectedIds.Count
  Status = 'secret_history_spine_valid'
} | Format-List | Out-Host
