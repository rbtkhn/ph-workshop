param(
  [string]$ManifestPath = "chapter-manifest.yaml",
  [string]$CorpusPath = "corpus/civ-ph",
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

function Get-Frontmatter {
  param([Parameter(Mandatory = $true)][string]$Text)
  $match = [regex]::Match($Text, "(?ms)\A---\n(.*?)\n---\n")
  if (-not $match.Success) { return $null }
  return $match.Groups[1].Value
}

function Get-FrontmatterValue {
  param(
    [AllowNull()][string]$Frontmatter,
    [Parameter(Mandatory = $true)][string]$Key
  )
  if (-not $Frontmatter) { return $null }
  $match = [regex]::Match($Frontmatter, "(?m)^$([regex]::Escape($Key)):\s*(.*)$")
  if (-not $match.Success) { return $null }
  return $match.Groups[1].Value.Trim().Trim('"')
}

function Get-SectionText {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Heading
  )
  $match = [regex]::Match($Text, "(?ms)^##\s+$([regex]::Escape($Heading))\s*\n(.*?)(?=^##\s+|\z)")
  if (-not $match.Success) { return $null }
  return $match.Groups[1].Value.Trim()
}

$resolvedCorpusPath = Resolve-RepoPath -Path $CorpusPath
if (-not (Test-Path -LiteralPath $resolvedCorpusPath -PathType Container)) {
  throw "civ-ph corpus path does not exist: $CorpusPath"
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
$requiredFields = @('source_id', 'title', 'source_series', 'publication_date', 'source_corpus_path', 'source_chapter_path', 'commentary_path', 'derived_corpus', 'placement_weight', 'review_status')
$requiredSections = @('Where This Sits', 'Reading Posture', 'Historical Pressure Points', 'Limits of the Frame', 'Return Path')
$items = New-Object System.Collections.Generic.List[object]
$warningCount = 0
$hardFailures = New-Object System.Collections.Generic.List[string]

$entryFiles = Get-ChildItem -LiteralPath $resolvedCorpusPath -Filter '*.md' -File |
  Where-Object { $_.Name -notin @('README.md', 'index.md') } |
  Sort-Object Name

foreach ($file in $entryFiles) {
  $warnings = New-Object System.Collections.Generic.List[string]
  $text = Get-Text -Path $file.FullName
  $frontmatter = Get-Frontmatter -Text $text
  $sourceId = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'source_id'

  if (-not $frontmatter) {
    $hardFailures.Add("$($file.Name) missing frontmatter") | Out-Null
    continue
  }

  foreach ($field in $requiredFields) {
    if (-not (Get-FrontmatterValue -Frontmatter $frontmatter -Key $field)) {
      $warnings.Add("missing frontmatter field $field") | Out-Null
    }
  }

  $derivedCorpus = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'derived_corpus'
  $placementWeight = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'placement_weight'
  $reviewStatus = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'review_status'

  if ($file.Name -ne "$sourceId.md") {
    $warnings.Add("filename does not match source_id") | Out-Null
  }
  if ($derivedCorpus -ne 'civ-ph') {
    $warnings.Add("derived_corpus is '$derivedCorpus'") | Out-Null
  }
  if ($placementWeight -notin @('strong', 'medium', 'light')) {
    $warnings.Add("invalid placement_weight '$placementWeight'") | Out-Null
  }
  if ($reviewStatus -notin @('calibration_seed', 'in_review', 'draft_pending_analysis')) {
    $warnings.Add("invalid review_status '$reviewStatus'") | Out-Null
  }

  foreach ($section in $requiredSections) {
    if (-not (Get-SectionText -Text $text -Heading $section)) {
      $warnings.Add("missing section $section") | Out-Null
    }
  }

  $limits = Get-SectionText -Text $text -Heading 'Limits of the Frame'
  $returnPath = Get-SectionText -Text $text -Heading 'Return Path'
  if ($limits -and $limits.Length -lt 80) {
    $warnings.Add("limits section is short") | Out-Null
  }
  if ($returnPath -and $returnPath.Length -lt 80) {
    $warnings.Add("return path section is short") | Out-Null
  }

  $relativePath = ($file.FullName.Substring((Get-Location).Path.Length + 1) -replace '\\', '/')
  if ($manifestText -notmatch [regex]::Escape($relativePath)) {
    $warnings.Add("not referenced by civ_ph_path in manifest") | Out-Null
  }

  foreach ($pathField in @('source_corpus_path', 'source_chapter_path', 'commentary_path')) {
    $target = Get-FrontmatterValue -Frontmatter $frontmatter -Key $pathField
    if ($target) {
      $resolvedTarget = Resolve-RepoPath -Path $target
      if (-not (Test-Path -LiteralPath $resolvedTarget -PathType Leaf)) {
        $hardFailures.Add("$sourceId points $pathField to missing file: $target") | Out-Null
      }
    }
  }

  if ($text -match '(?i)civ[-_ ]?mem') {
    $hardFailures.Add("$sourceId contains internal scaffold terminology") | Out-Null
  }

  $warningCount += $warnings.Count
  $items.Add([pscustomobject][ordered]@{
    source_id = $sourceId
    placement_weight = $placementWeight
    review_status = $reviewStatus
    file = $relativePath
    limits_length = if ($limits) { $limits.Length } else { 0 }
    return_path_length = if ($returnPath) { $returnPath.Length } else { 0 }
    warnings = @($warnings.ToArray())
  }) | Out-Null
}

if ($hardFailures.Count -gt 0) {
  throw "civ-ph audit hard failures: $($hardFailures -join '; ')"
}

$byWeight = @{}
foreach ($weight in @('strong', 'medium', 'light')) {
  $byWeight[$weight] = @($items | Where-Object { $_.placement_weight -eq $weight }).Count
}

$reportStatus = 'warnings'
if ([int]$warningCount -eq 0) {
  $reportStatus = 'clean'
}

$summary = [pscustomobject][ordered]@{
  generated_at = 'deterministic-local'
  corpus_path = $CorpusPath
  entry_count = $items.Count
  warning_count = $warningCount
  placement_weight_counts = [pscustomobject][ordered]@{
    strong = $byWeight['strong']
    medium = $byWeight['medium']
    light = $byWeight['light']
  }
  status = $reportStatus
  entries = @($items.ToArray())
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $resolvedReportsDir 'civ-ph-health.json') -Encoding utf8

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# civ-ph Health') | Out-Null
$md.Add('') | Out-Null
$md.Add('Internal audit snapshot for civ-ph orientation entries.') | Out-Null
$md.Add('') | Out-Null
$md.Add("Status: $($summary.status)") | Out-Null
$md.Add("Entry count: $($summary.entry_count)") | Out-Null
$md.Add("Warning count: $($summary.warning_count)") | Out-Null
$md.Add("Placement weights: strong=$($byWeight['strong']), medium=$($byWeight['medium']), light=$($byWeight['light'])") | Out-Null
$md.Add('') | Out-Null
$md.Add('| source_id | weight | review_status | warnings |') | Out-Null
$md.Add('| --- | --- | --- | --- |') | Out-Null
foreach ($item in $items) {
  $warningText = if ($item.warnings.Count -gt 0) { ($item.warnings -join '; ') } else { 'none' }
  $sourceId = $item.source_id
  $md.Add("| ``$sourceId`` | $($item.placement_weight) | $($item.review_status) | $warningText |") | Out-Null
}
$md | Set-Content -LiteralPath (Join-Path $resolvedReportsDir 'civ-ph-health.md') -Encoding utf8

[pscustomobject]@{
  Report = 'civ-ph-health'
  EntryCount = $items.Count
  WarningCount = $warningCount
  Status = $summary.status
} | Format-List | Out-Host
