param(
  [Parameter(Mandatory = $true)][string]$Series,
  [Parameter(Mandatory = $true)][string[]]$ExpectedIds,
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

  $marker = "- source_id: $SourceId`n"
  $start = $SourceText.IndexOf($marker, [StringComparison]::Ordinal)
  if ($start -lt 0) {
    throw "Missing strategy-codex metadata block for $SourceId"
  }

  $next = $SourceText.IndexOf("`n- source_id:", $start + $marker.Length, [StringComparison]::Ordinal)
  if ($next -lt 0) {
    return $SourceText.Substring($start)
  }

  return $SourceText.Substring($start, $next - $start)
}

function Get-YamlScalar {
  param(
    [Parameter(Mandatory = $true)][string]$Block,
    [Parameter(Mandatory = $true)][string]$Key,
    [string]$Default = $null
  )

  $match = [regex]::Match($Block, "(?m)^\s*$([regex]::Escape($Key)):\s*(.*)$")
  if (-not $match.Success) {
    return $Default
  }

  $value = $match.Groups[1].Value.Trim()
  if ($value -eq '' -or $value -eq 'null') {
    return $Default
  }

  if (($value.StartsWith("'") -and $value.EndsWith("'")) -or ($value.StartsWith('"') -and $value.EndsWith('"'))) {
    $value = $value.Substring(1, $value.Length - 2)
  }

  return $value
}

function Get-FirstHeading {
  param([Parameter(Mandatory = $true)][string]$Text)
  $match = [regex]::Match($Text, '(?m)^#\s+(.+?)\s*$')
  if ($match.Success) {
    return $match.Groups[1].Value.Trim()
  }
  return $null
}

function Get-BodyFromMarker {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Marker
  )

  $markerMatch = [regex]::Match($Text, "(?m)^$([regex]::Escape($Marker))[ `t]*$")
  if (-not $markerMatch.Success) {
    throw "Marker '$Marker' not found"
  }

  $bodyStart = $Text.IndexOf("`n`n", $markerMatch.Index + $markerMatch.Length, [System.StringComparison]::Ordinal)
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
  'Core Strategic Thesis',
  'Neutral Lecture Summary',
  'Actors, Systems, And Stakes',
  'Claims, Forecasts, And Falsifiers',
  'Evidence Limits And Date Sensitivity',
  'Counter-Readings',
  'Open Issues For Review'
)

foreach ($chapterId in $ExpectedIds) {
  $ordinal = [int]($chapterId -replace '^[a-z]+-', '')
  $isLegacyGeo = ($Series -eq 'geo-strategy' -and $ordinal -le 12)
  $sourceBlock = Get-SourceBlock -SourceText $strategySourcesText -SourceId $chapterId
  $lecturePath = Get-YamlScalar -Block $sourceBlock -Key 'lecture_path'
  if (-not $lecturePath) {
    throw "Strategy metadata $chapterId is missing lecture_path"
  }

  $strategyLecturePath = Join-Path -Path $StrategyRoot -ChildPath ($lecturePath -replace '/', [IO.Path]::DirectorySeparatorChar)
  if (-not (Test-Path -LiteralPath $strategyLecturePath -PathType Leaf)) {
    throw "Strategy transfer lecture does not exist for ${chapterId}: $strategyLecturePath"
  }

  $strategyLectureText = Get-Text -Path $strategyLecturePath
  $expectedTitle = Get-FirstHeading -Text $strategyLectureText
  if (-not $expectedTitle) {
    $expectedTitle = Get-YamlScalar -Block $sourceBlock -Key 'title' -Default $chapterId
  }

  $expectedDate = Get-YamlScalar -Block $sourceBlock -Key 'publication_date' -Default 'unknown'
  $expectedUrl = Get-YamlScalar -Block $sourceBlock -Key 'canonical_url' -Default ''
  $expectedVideoId = Get-YamlScalar -Block $sourceBlock -Key 'video_id' -Default ''

  $block = Get-ManifestBlock -ManifestText $manifestText -ChapterId $chapterId
  foreach ($field in @('corpus_path', 'part_i_path', 'part_ii_path', 'ph_civ_path', 'orientation_payload_path')) {
    $target = Get-ManifestField -Block $block -Field $field -ChapterId $chapterId
    Assert-FileExists -Path $target -Context "Manifest row $chapterId $field" | Out-Null
  }

  $fieldChecks = @(
    @{ Field = 'series'; Expected = $Series },
    @{ Field = 'publication_date'; Expected = $expectedDate },
    @{ Field = 'transcript_fidelity'; Expected = 'exact_body_match' },
    @{ Field = 'part'; Expected = 'world-war' }
  )
  if (-not $isLegacyGeo) {
    $fieldChecks += @{ Field = 'title'; Expected = $expectedTitle }
  }
  if (-not $isLegacyGeo) {
    $fieldChecks += @{ Field = 'review_status'; Expected = 'source_reviewed' }
  }

  foreach ($fieldCheck in $fieldChecks) {
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
  if (-not $isLegacyGeo) {
    foreach ($metadataCheck in @(
      @{ Key = 'source_id'; Expected = $chapterId },
      @{ Key = 'title'; Expected = $expectedTitle },
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

    if ($expectedUrl) {
      $actualUrl = Get-FrontmatterValue -Text $transcriptText -Key 'source_url'
      if ($actualUrl -ne $expectedUrl) {
        throw "Transcript $chapterId source_url mismatch. Expected '$expectedUrl', found '$actualUrl'"
      }
    }

    if ($expectedVideoId) {
      $actualVideoId = Get-FrontmatterValue -Text $transcriptText -Key 'video_id'
      if ($actualVideoId -ne $expectedVideoId) {
        throw "Transcript $chapterId video_id mismatch. Expected '$expectedVideoId', found '$actualVideoId'"
      }
    }
  }

  $targetBody = Get-BodyFromMarker -Text $transcriptText -Marker '## Part I: Full transcript'
  $strategyBody = Get-BodyFromMarker -Text $strategyLectureText -Marker '## Full transcript'
  if ($strategyBody -cne $targetBody) {
    throw "Transcript body mismatch for $chapterId against strategy-codex transfer source"
  }

  if (-not $isLegacyGeo) {
    $corpusText = Get-Text -Path (Resolve-RepoPath -Path $corpusPath)
    if ((Get-FrontmatterValue -Text $corpusText -Key 'part') -ne 'world-war') {
      throw "Corpus entry $chapterId must set part: world-war"
    }

    $commentaryText = Get-Text -Path (Resolve-RepoPath -Path $commentaryPath)
    if ((Get-FrontmatterValue -Text $commentaryText -Key 'template_family') -ne 'world-war-strategic-commentary') {
      throw "Commentary $chapterId must use template_family: world-war-strategic-commentary"
    }
    foreach ($section in $requiredCommentarySections) {
      if ($commentaryText -notmatch "(?m)^##\s+$([regex]::Escape($section))\s*$") {
        throw "Commentary $chapterId is missing section '$section'"
      }
    }
  }

  $phCivText = Get-Text -Path (Resolve-RepoPath -Path $phCivPath)
  $payloadText = Get-Text -Path (Resolve-RepoPath -Path $payloadPath)
  if ((Get-FrontmatterValue -Text $phCivText -Key 'review_status') -ne 'in_review') {
    throw "PH-CIV $chapterId must set review_status: in_review"
  }
  if ((Get-FrontmatterValue -Text $phCivText -Key 'part') -ne 'world-war') {
    throw "PH-CIV $chapterId must set part: world-war"
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
  Series = $Series
  ManifestPath = $ManifestPath
  StrategyRoot = $StrategyRoot
  ChapterCount = $ExpectedIds.Count
  Status = 'world_war_series_valid'
} | Format-List | Out-Host
