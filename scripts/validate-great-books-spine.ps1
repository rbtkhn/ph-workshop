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

function Get-ManifestBlock {
  param(
    [Parameter(Mandatory = $true)][string]$ManifestText,
    [Parameter(Mandatory = $true)][string]$ChapterId
  )

  $chapterPattern = "(?ms)^\s+- chapter_id:\s*$([regex]::Escape($ChapterId))\s*\n(.*?)(?=^\s+- chapter_id:|\z)"
  $chapterMatch = [regex]::Match($ManifestText, $chapterPattern)
  if (-not $chapterMatch.Success) {
    throw "Missing Great Books manifest row: $ChapterId"
  }

  return $chapterMatch.Groups[0].Value
}

function Get-ManifestField {
  param(
    [Parameter(Mandatory = $true)][string]$Block,
    [Parameter(Mandatory = $true)][string]$Field,
    [Parameter(Mandatory = $true)][string]$ChapterId
  )

  $fieldMatch = [regex]::Match($Block, "(?m)^\s+$([regex]::Escape($Field)):\s*(\S+)\s*$")
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
$expectedIds = 1..10 | ForEach-Object { "gb-{0:D2}" -f $_ }
$directYouTubeSources = @{
  'gb-10' = @{
    Title = "Great Books #10: Dante's Hierarchy of Hell"
    Url = 'https://www.youtube.com/watch?v=wGpdMYa2bME'
    Date = '2026-04-29'
    VideoId = 'wGpdMYa2bME'
    BookChapterId = 'gb-ch10'
    TranscriptFidelity = 'needs_fidelity_review'
  }
}
$requiredCommentarySections = @(
  'Core Thesis & Reading Problem',
  'Neutral Lecture Summary',
  'Key Terms, Texts, and Interpretive Claims',
  'Passage / Argument Anchors',
  'Counter-Readings & Limits',
  'Cross-Series Links',
  'Open Issues & Future Review'
)

foreach ($chapterId in $expectedIds) {
  $isDirectYouTubeSource = $directYouTubeSources.ContainsKey($chapterId)
  if ($isDirectYouTubeSource) {
    $directSource = $directYouTubeSources[$chapterId]
    $expectedTitle = $directSource.Title
    $expectedUrl = $directSource.Url
    $expectedDate = $directSource.Date
    $expectedTranscriptFidelity = $directSource.TranscriptFidelity
    $expectedBookChapterId = $directSource.BookChapterId
  } else {
    $sourceBlock = Get-SourceBlock -SourceText $strategySourcesText -SourceId $chapterId
    $expectedTitle = Get-YamlScalar -Block $sourceBlock -Key 'title'
    $expectedUrl = Get-YamlScalar -Block $sourceBlock -Key 'canonical_url'
    $expectedDate = Get-YamlScalar -Block $sourceBlock -Key 'publication_date'
    $expectedTranscriptFidelity = 'exact_body_match'
    $expectedBookChapterId = "gb-ch$($chapterId.Substring(3))"
    $lecturePath = Get-YamlScalar -Block $sourceBlock -Key 'lecture_path'
    $analysisPath = Get-YamlScalar -Block $sourceBlock -Key 'analysis_path'
    $strategyLecturePath = Join-Path -Path $StrategyRoot -ChildPath ($lecturePath -replace '/', [IO.Path]::DirectorySeparatorChar)
    $strategyAnalysisPath = Join-Path -Path $StrategyRoot -ChildPath ($analysisPath -replace '/', [IO.Path]::DirectorySeparatorChar)
    $evidencePackPath = Join-Path -Path $StrategyRoot -ChildPath ("evidence-packs\$expectedBookChapterId.md")

    foreach ($strategyFile in @($strategyLecturePath, $strategyAnalysisPath, $evidencePackPath)) {
      if (-not (Test-Path -LiteralPath $strategyFile -PathType Leaf)) {
        throw "Strategy transfer file does not exist for ${chapterId}: $strategyFile"
      }
    }
  }

  $block = Get-ManifestBlock -ManifestText $manifestText -ChapterId $chapterId
  foreach ($field in @('corpus_path', 'part_i_path', 'part_ii_path', 'ph_civ_path', 'orientation_payload_path')) {
    $target = Get-ManifestField -Block $block -Field $field -ChapterId $chapterId
    Assert-FileExists -Path $target -Context "Manifest row $chapterId $field" | Out-Null
  }

  $corpusPath = Get-ManifestField -Block $block -Field 'corpus_path' -ChapterId $chapterId
  $transcriptPath = Get-ManifestField -Block $block -Field 'part_i_path' -ChapterId $chapterId
  $commentaryPath = Get-ManifestField -Block $block -Field 'part_ii_path' -ChapterId $chapterId
  $phCivPath = Get-ManifestField -Block $block -Field 'ph_civ_path' -ChapterId $chapterId
  $payloadPath = Get-ManifestField -Block $block -Field 'orientation_payload_path' -ChapterId $chapterId

  $transcriptText = Get-Text -Path (Resolve-RepoPath -Path $transcriptPath)
  foreach ($metadataCheck in @(
    @{ Key = 'source_id'; Expected = $chapterId },
    @{ Key = 'series'; Expected = 'great-books' },
    @{ Key = 'title'; Expected = $expectedTitle },
    @{ Key = 'canonical_url'; Expected = $expectedUrl },
    @{ Key = 'publication_date'; Expected = $expectedDate },
    @{ Key = 'transcript_fidelity'; Expected = $expectedTranscriptFidelity },
    @{ Key = 'representation_not_endorsement'; Expected = 'true' }
  )) {
    $actualValue = Get-FrontmatterValue -Text $transcriptText -Key $metadataCheck.Key
    if ($actualValue -ne $metadataCheck.Expected) {
      throw "Transcript $chapterId metadata '$($metadataCheck.Key)' mismatch. Expected '$($metadataCheck.Expected)', found '$actualValue'"
    }
  }

  $targetBody = Get-BodyFromMarker -Text $transcriptText -Marker '## Part I: Full transcript'
  if ($isDirectYouTubeSource) {
    if ([string]::IsNullOrWhiteSpace($targetBody)) {
      throw "Transcript body for $chapterId is empty"
    }
    if ((Get-FrontmatterValue -Text $transcriptText -Key 'transcript_source') -ne 'youtube_auto_captions') {
      throw "Transcript $chapterId must identify transcript_source: youtube_auto_captions"
    }
  } else {
    $strategyLectureText = Get-Text -Path $strategyLecturePath
    $strategyBody = Get-BodyFromMarker -Text $strategyLectureText -Marker '## Full transcript'
    if ($strategyBody -cne $targetBody) {
      throw "Transcript body mismatch for $chapterId against strategy-codex transfer source"
    }
  }

  $corpusText = Get-Text -Path (Resolve-RepoPath -Path $corpusPath)
  if ((Get-FrontmatterValue -Text $corpusText -Key 'book_chapter_id') -ne $expectedBookChapterId) {
    throw "Corpus entry $chapterId must preserve transfer book_chapter_id metadata"
  }

  $commentaryText = Get-Text -Path (Resolve-RepoPath -Path $commentaryPath)
  if ((Get-FrontmatterValue -Text $commentaryText -Key 'template_family') -ne 'great-books-commentary') {
    throw "Commentary $chapterId must use template_family: great-books-commentary"
  }

  foreach ($section in $requiredCommentarySections) {
    if ($commentaryText -notmatch "(?m)^##\s+$([regex]::Escape($section))\s*$") {
      throw "Commentary $chapterId is missing section '$section'"
    }
  }

  $phCivText = Get-Text -Path (Resolve-RepoPath -Path $phCivPath)
  $payloadText = Get-Text -Path (Resolve-RepoPath -Path $payloadPath)
  $phCivWeight = Get-FrontmatterValue -Text $phCivText -Key 'placement_weight'
  $payloadWeightMatch = [regex]::Match($payloadText, '(?m)^placement_weight:\s*(\S+)\s*$')
  if (-not $payloadWeightMatch.Success) {
    throw "Orientation payload $chapterId is missing placement_weight"
  }

  if ($payloadWeightMatch.Groups[1].Value -ne $phCivWeight) {
    throw "PH-CIV $chapterId placement_weight does not match orientation payload"
  }

  if ((Get-FrontmatterValue -Text $phCivText -Key 'source_series') -ne 'great-books') {
    throw "PH-CIV $chapterId must set source_series: great-books"
  }
}

[pscustomobject]@{
  ManifestPath = $ManifestPath
  StrategyRoot = $StrategyRoot
  ChapterCount = $expectedIds.Count
  Status = 'great_books_spine_valid'
} | Format-List | Out-Host
