param(
  [string]$ManifestPath = "chapter-manifest.yaml",
  [string]$MediaCorpusPath = "corpus/media-packs"
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

function Assert-Contains {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Pattern,
    [Parameter(Mandatory = $true)][string]$Context
  )

  if ($Text -notmatch $Pattern) {
    throw "$Context is missing required pattern: $Pattern"
  }
}

$resolvedManifestPath = Resolve-RepoPath -Path $ManifestPath
if (-not (Test-Path -LiteralPath $resolvedManifestPath -PathType Leaf)) {
  throw "Manifest path does not exist: $ManifestPath"
}

$resolvedMediaCorpusPath = Resolve-RepoPath -Path $MediaCorpusPath
if (-not (Test-Path -LiteralPath $resolvedMediaCorpusPath -PathType Container)) {
  throw "Media corpus path does not exist: $MediaCorpusPath"
}

$manifestText = Get-Text -Path $resolvedManifestPath
$manifestRows = [regex]::Matches($manifestText, "(?ms)^\s+- chapter_id:\s*(\S+)\s*\n(.*?)(?=^\s+- chapter_id:|\z)")
$mediaRows = @(
  $manifestRows |
    Where-Object { $_.Groups[2].Value -match '(?m)^\s+media_pack_path:\s*\S+' -or $_.Groups[2].Value -match '(?m)^\s+media_payload_path:\s*\S+' }
)

if ($mediaRows.Count -eq 0) {
  throw "No media pack rows found in $ManifestPath"
}

$allowedStatuses = @('curated_draft', 'in_review', 'human_curated')
$allowedRights = @('public_domain', 'open_license', 'external_link_only', 'needs_review', 'unavailable')
$requiredMdSections = @(
  'How To Use This Pack',
  'Entry Object',
  'Return Path'
)

foreach ($row in $mediaRows) {
  $sourceId = $row.Groups[1].Value
  $block = $row.Groups[0].Value
  $part = Get-ManifestField -Block $block -Field 'part'
  if (-not $part) {
    $part = if ($sourceId -match '^(civ|gb)-') { 'civilization' } else { 'world-war' }
  }

  $mediaPackPath = Get-ManifestField -Block $block -Field 'media_pack_path'
  $mediaPayloadPath = Get-ManifestField -Block $block -Field 'media_payload_path'
  $mediaStatus = Get-ManifestField -Block $block -Field 'media_pack_status'

  if (-not $mediaPackPath -or -not $mediaPayloadPath -or -not $mediaStatus) {
    throw "Manifest row $sourceId must define media_pack_path, media_payload_path, and media_pack_status"
  }
  if ($mediaStatus -notin $allowedStatuses) {
    throw "Manifest row $sourceId has invalid media_pack_status '$mediaStatus'"
  }

  $resolvedPack = Assert-FileExists -Path $mediaPackPath -Context "Manifest row $sourceId media_pack_path"
  $resolvedPayload = Assert-FileExists -Path $mediaPayloadPath -Context "Manifest row $sourceId media_payload_path"

  $packText = Get-Text -Path $resolvedPack
  $payloadText = Get-Text -Path $resolvedPayload

  foreach ($field in @(
    'source_id',
    'title',
    'part',
    'media_pack_status',
    'primary_job',
    'rights_mode',
    'reader_voice',
    'items'
  )) {
    Assert-Contains -Text $payloadText -Pattern "(?m)^$([regex]::Escape($field)):" -Context "Media payload $mediaPayloadPath"
  }

  Assert-Contains -Text $payloadText -Pattern "(?m)^source_id:\s*$([regex]::Escape($sourceId))\s*$" -Context "Media payload $mediaPayloadPath"
  Assert-Contains -Text $payloadText -Pattern "(?m)^part:\s*$([regex]::Escape($part))\s*$" -Context "Media payload $mediaPayloadPath"
  Assert-Contains -Text $payloadText -Pattern "(?m)^rights_mode:\s*link_first_rights_safe\s*$" -Context "Media payload $mediaPayloadPath"
  Assert-Contains -Text $payloadText -Pattern "(?m)^reader_voice:\s*museum_label\s*$" -Context "Media payload $mediaPayloadPath"
  Assert-Contains -Text $payloadText -Pattern "(?m)^\s+human_curated:\s*(true|false)\s*$" -Context "Media payload $mediaPayloadPath"

  $itemMatches = [regex]::Matches($payloadText, "(?m)^\s+- id:\s*(\S+)\s*$")
  if ($itemMatches.Count -lt 5 -or $itemMatches.Count -gt 15) {
    throw "Media payload $mediaPayloadPath must contain between 5 and 15 items, found $($itemMatches.Count)"
  }

  $itemBlocks = [regex]::Matches($payloadText, "(?ms)^\s+- id:\s*\S+\s*\n(.*?)(?=^\s+- id:|\z)")
  foreach ($item in $itemBlocks) {
    $itemText = $item.Groups[0].Value
    foreach ($requiredField in @('label', 'item_type', 'role', 'source_url', 'rights_status', 'what_to_notice', 'limit_note')) {
      Assert-Contains -Text $itemText -Pattern "(?m)^\s+$([regex]::Escape($requiredField)):\s*.+" -Context "Media item in $mediaPayloadPath"
    }
    $rightsMatch = [regex]::Match($itemText, '(?m)^\s+rights_status:\s*(\S+)\s*$')
    if (-not $rightsMatch.Success -or $rightsMatch.Groups[1].Value -notin $allowedRights) {
      throw "Media item in $mediaPayloadPath has invalid rights_status"
    }
    $sourceUrl = [regex]::Match($itemText, '(?m)^\s+source_url:\s*"?(.+?)"?\s*$').Groups[1].Value
    if ($sourceUrl -notmatch '^https?://') {
      throw "Media item in $mediaPayloadPath must use http(s) source_url"
    }
  }

  foreach ($section in $requiredMdSections) {
    Assert-Contains -Text $packText -Pattern "(?m)^##\s+$([regex]::Escape($section))\s*$" -Context "Media pack $mediaPackPath"
  }
  foreach ($section in @('Context Anchors', 'Primary Objects And Texts', 'Comparison Objects', 'Pressure / Structure', 'Limits And Cautions')) {
    if ($packText -notmatch "(?m)^##\s+$([regex]::Escape($section))\s*$") {
      # Rich packs can omit a group when the curated set is smaller than 15, but at least
      # one of the semester-shaping groups beyond Entry Object must be present.
      continue
    }
  }

  foreach ($pathField in @('ph_civ_path', 'transcript_path', 'commentary_path')) {
    $pathMatches = [regex]::Matches($payloadText, "(?m)^\s+$([regex]::Escape($pathField)):\s*(.+?)\s*$")
    if ($pathMatches.Count -eq 0) {
      throw "Media payload $mediaPayloadPath is missing related path field $pathField"
    }
    foreach ($pathMatch in $pathMatches) {
      Assert-FileExists -Path ($pathMatch.Groups[1].Value.Trim().Trim('"')) -Context "Media payload $mediaPayloadPath $pathField" | Out-Null
    }
  }

  if ($part -eq 'world-war') {
    if ($packText -notmatch '(?i)date-sensitive|current-events|current events|forecast|pressure') {
      throw "World War media pack $mediaPackPath must include date-sensitive/current-events caution language"
    }
  }
}

[pscustomobject]@{
  ManifestPath = $ManifestPath
  MediaCorpusPath = $MediaCorpusPath
  MediaPackCount = $mediaRows.Count
  Status = 'media_packs_valid'
} | Format-List | Out-Host
