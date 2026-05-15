param(
  [string]$ManifestPath = "chapter-manifest.yaml",
  [string]$ReportsDir = "reports"
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
    [Parameter(Mandatory = $true)][string]$SourceId
  )

  $match = [regex]::Match($ManifestText, "(?ms)^\s+- chapter_id:\s*$([regex]::Escape($SourceId))\s*\n(.*?)(?=^\s+- chapter_id:|\z)")
  if (-not $match.Success) {
    throw "Missing manifest row for $SourceId"
  }
  return $match.Groups[0].Value
}

function Get-ManifestField {
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

function Get-FrontmatterValue {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Key
  )

  $frontmatter = [regex]::Match($Text, "(?ms)\A---\n(.*?)\n---\n")
  if (-not $frontmatter.Success) {
    return $null
  }

  $match = [regex]::Match($frontmatter.Groups[1].Value, "(?m)^$([regex]::Escape($Key)):\s*(.*)$")
  if (-not $match.Success) {
    return $null
  }

  return $match.Groups[1].Value.Trim().Trim('"')
}

function Test-PathField {
  param(
    [Parameter(Mandatory = $true)][string]$SourceId,
    [Parameter(Mandatory = $true)][string]$FieldName,
    [AllowNull()][string]$RelativePath,
    [Parameter(Mandatory = $true)]$Warnings
  )

  if (-not $RelativePath) {
    $Warnings.Add("Missing manifest field $FieldName") | Out-Null
    return $false
  }

  $resolved = Resolve-RepoPath -Path $RelativePath
  if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
    throw "Manifest row $SourceId points $FieldName to missing file: $RelativePath"
  }

  return $true
}

function Get-LayerStatus {
  param([Parameter(Mandatory = $true)][string]$Text)

  $missing = New-Object System.Collections.Generic.List[string]
  foreach ($layer in 0..6) {
    if ($Text -notmatch "(?m)^##\s+Layer $layer\b") {
      $missing.Add("Layer $layer") | Out-Null
    }
  }
  return @($missing)
}

$resolvedManifestPath = Resolve-RepoPath -Path $ManifestPath
if (-not (Test-Path -LiteralPath $resolvedManifestPath -PathType Leaf)) {
  throw "Manifest path does not exist: $ManifestPath"
}

$resolvedReportsDir = Resolve-RepoPath -Path $ReportsDir
if (-not (Test-Path -LiteralPath $resolvedReportsDir -PathType Container)) {
  New-Item -ItemType Directory -Path $resolvedReportsDir | Out-Null
}

$manifestText = Get-Text -Path $resolvedManifestPath
$calibratedOrientationIds = @('civ-01')
$items = New-Object System.Collections.Generic.List[object]
$warningCount = 0

foreach ($sourceId in (1..60 | ForEach-Object { "civ-{0:D2}" -f $_ })) {
  $block = Get-ManifestBlock -ManifestText $manifestText -SourceId $sourceId
  $warnings = New-Object System.Collections.Generic.List[string]

  $corpusPath = Get-ManifestField -Block $block -Field 'corpus_path'
  $partIPath = Get-ManifestField -Block $block -Field 'part_i_path'
  $partIIPath = Get-ManifestField -Block $block -Field 'part_ii_path'
  $phCivPath = Get-ManifestField -Block $block -Field 'civ_ph_path'
  $orientationPayloadPath = Get-ManifestField -Block $block -Field 'orientation_payload_path'
  $transcriptFidelity = Get-ManifestField -Block $block -Field 'transcript_fidelity'

  Test-PathField -SourceId $sourceId -FieldName 'corpus_path' -RelativePath $corpusPath -Warnings $warnings | Out-Null
  Test-PathField -SourceId $sourceId -FieldName 'part_i_path' -RelativePath $partIPath -Warnings $warnings | Out-Null
  Test-PathField -SourceId $sourceId -FieldName 'part_ii_path' -RelativePath $partIIPath -Warnings $warnings | Out-Null
  Test-PathField -SourceId $sourceId -FieldName 'civ_ph_path' -RelativePath $phCivPath -Warnings $warnings | Out-Null

  if ($sourceId -in $calibratedOrientationIds) {
    Test-PathField -SourceId $sourceId -FieldName 'orientation_payload_path' -RelativePath $orientationPayloadPath -Warnings $warnings | Out-Null
  }

  if ($transcriptFidelity -ne 'exact_body_match') {
    $warnings.Add("transcript_fidelity is '$transcriptFidelity'") | Out-Null
  }

  $transcriptText = Get-Text -Path (Resolve-RepoPath -Path $partIPath)
  $commentaryText = Get-Text -Path (Resolve-RepoPath -Path $partIIPath)
  $phCivText = Get-Text -Path (Resolve-RepoPath -Path $phCivPath)

  $transcriptReviewStatus = Get-FrontmatterValue -Text $transcriptText -Key 'review_status'
  $commentaryStatus = Get-FrontmatterValue -Text $commentaryText -Key 'commentary_status'
  $sourceReviewedAt = Get-FrontmatterValue -Text $commentaryText -Key 'source_reviewed_at'
  $phCivReviewStatus = Get-FrontmatterValue -Text $phCivText -Key 'review_status'
  $representation = Get-FrontmatterValue -Text $commentaryText -Key 'representation_not_endorsement'

  if ($transcriptReviewStatus -ne 'source_reviewed') {
    $warnings.Add("transcript review_status is '$transcriptReviewStatus'") | Out-Null
  }
  if ($sourceId -ne 'civ-01' -and $commentaryStatus -ne 'in-review') {
    $warnings.Add("commentary_status is '$commentaryStatus'") | Out-Null
  }
  if (-not $sourceReviewedAt) {
    $warnings.Add("missing source_reviewed_at") | Out-Null
  }
  if (-not $phCivReviewStatus) {
    $warnings.Add("missing civ-ph review_status") | Out-Null
  }
  if ($representation -ne 'true') {
    $warnings.Add("commentary representation_not_endorsement is '$representation'") | Out-Null
  }

  $missingLayers = @(Get-LayerStatus -Text $commentaryText)
  foreach ($layer in $missingLayers) {
    $warnings.Add("missing commentary $layer") | Out-Null
  }

  $warningCount += $warnings.Count

  $items.Add([pscustomobject][ordered]@{
    source_id = $sourceId
    title = Get-ManifestField -Block $block -Field 'title'
    corpus_path = $corpusPath
    part_i_path = $partIPath
    part_ii_path = $partIIPath
    civ_ph_path = $phCivPath
    orientation_payload_path = $orientationPayloadPath
    transcript_fidelity = $transcriptFidelity
    transcript_review_status = $transcriptReviewStatus
    commentary_status = $commentaryStatus
    civ_ph_review_status = $phCivReviewStatus
    source_reviewed_at = $sourceReviewedAt
    warnings = @($warnings.ToArray())
  }) | Out-Null
}

$reportStatus = 'warnings'
if ([int]$warningCount -eq 0) {
  $reportStatus = 'clean'
}

$summary = [pscustomobject][ordered]@{
  generated_at = 'deterministic-local'
  manifest_path = $ManifestPath
  chapter_count = $items.Count
  warning_count = $warningCount
  status = $reportStatus
  chapters = @($items.ToArray())
}

$jsonPath = Join-Path -Path $resolvedReportsDir -ChildPath 'civilization-spine-health.json'
$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonPath -Encoding utf8

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Civilization Spine Health') | Out-Null
$md.Add('') | Out-Null
$md.Add('Internal audit snapshot for `civ-01` through `civ-60`.') | Out-Null
$md.Add('') | Out-Null
$md.Add("Status: $($summary.status)") | Out-Null
$md.Add("Chapter count: $($summary.chapter_count)") | Out-Null
$md.Add("Warning count: $($summary.warning_count)") | Out-Null
$md.Add('') | Out-Null
$md.Add('| source_id | transcript | commentary | civ-ph | orientation | warnings |') | Out-Null
$md.Add('| --- | --- | --- | --- | --- | --- |') | Out-Null
foreach ($item in $items) {
  $orientation = if ($item.orientation_payload_path) { 'routed' } else { '-' }
  $warningText = if ($item.warnings.Count -gt 0) { ($item.warnings -join '; ') } else { 'none' }
  $sourceId = $item.source_id
  $md.Add("| ``$sourceId`` | $($item.transcript_fidelity) | $($item.commentary_status) | $($item.civ_ph_review_status) | $orientation | $warningText |") | Out-Null
}

$mdPath = Join-Path -Path $resolvedReportsDir -ChildPath 'civilization-spine-health.md'
$md | Set-Content -LiteralPath $mdPath -Encoding utf8

[pscustomobject]@{
  Report = 'civilization-spine-health'
  ChapterCount = $items.Count
  WarningCount = $warningCount
  Status = $summary.status
} | Format-List | Out-Host
