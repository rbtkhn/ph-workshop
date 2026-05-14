param(
  [string]$ManifestPath = "chapter-manifest.yaml",
  [string]$CorpusPath = "corpus/ph-civ"
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
  if (-not $match.Success) {
    return $null
  }
  return $match.Groups[1].Value
}

function Get-FrontmatterValue {
  param(
    [Parameter(Mandatory = $true)][string]$Frontmatter,
    [Parameter(Mandatory = $true)][string]$Key
  )
  $match = [regex]::Match($Frontmatter, "(?m)^$([regex]::Escape($Key)):\s*(.*)$")
  if (-not $match.Success) {
    return $null
  }
  return $match.Groups[1].Value.Trim().Trim('"')
}

function Get-PublicSurfaceFiles {
  param([Parameter(Mandatory = $true)][string]$CorpusPath)

  $paths = @(
    'README.md',
    'llms.txt',
    'CHANGELOG.md',
    'chapter-manifest.yaml',
    'corpus/README.md',
    'book/README.md',
    'book/volume-ii/README.md',
    'docs/chapter-index.md',
    'docs/repo-map.md',
    'docs/series-roadmap.md'
  )

  $files = New-Object System.Collections.Generic.List[string]

  foreach ($path in $paths) {
    $resolvedPath = Resolve-RepoPath -Path $path
    if (Test-Path -LiteralPath $resolvedPath -PathType Leaf) {
      $files.Add($resolvedPath)
    }
  }

  $resolvedCorpusPath = Resolve-RepoPath -Path $CorpusPath
  if (Test-Path -LiteralPath $resolvedCorpusPath -PathType Container) {
    foreach ($file in (Get-ChildItem -LiteralPath $resolvedCorpusPath -Filter '*.md' -File)) {
      $files.Add($file.FullName)
    }
  }

  $greatBooksCorpusPath = Resolve-RepoPath -Path 'corpus/great-books'
  if (Test-Path -LiteralPath $greatBooksCorpusPath -PathType Container) {
    foreach ($file in (Get-ChildItem -LiteralPath $greatBooksCorpusPath -Filter '*.md' -File)) {
      $files.Add($file.FullName)
    }
  }

  $bookRoot = Resolve-RepoPath -Path 'book'
  if (Test-Path -LiteralPath $bookRoot -PathType Container) {
    foreach ($file in (Get-ChildItem -LiteralPath $bookRoot -Filter '*.md' -File -Recurse)) {
      $files.Add($file.FullName)
    }
  }

  return $files | Select-Object -Unique
}

$resolvedCorpusPath = Resolve-RepoPath -Path $CorpusPath
if (-not (Test-Path -LiteralPath $resolvedCorpusPath -PathType Container)) {
  throw "PH-CIV corpus path does not exist: $CorpusPath"
}

$forbiddenPattern = '(?i)civ[-_ ]?mem'
$publicSurfaceFiles = Get-PublicSurfaceFiles -CorpusPath $CorpusPath
foreach ($file in $publicSurfaceFiles) {
  $text = Get-Text -Path $file
  if ($text -match $forbiddenPattern) {
    throw "Public surface file $file contains internal scaffold terminology"
  }
}

$publicFiles = Get-ChildItem -LiteralPath $resolvedCorpusPath -Filter '*.md' -File
$entryFiles = $publicFiles | Where-Object { $_.Name -notin @('README.md', 'index.md') }
if (-not $entryFiles) {
  throw "No PH-CIV entry files found in $CorpusPath"
}

$requiredFields = @(
  'source_id',
  'title',
  'source_series',
  'publication_date',
  'source_corpus_path',
  'source_chapter_path',
  'commentary_path',
  'derived_corpus',
  'placement_weight',
  'review_status'
)

$requiredSections = @(
  'Where This Sits',
  'Reading Posture',
  'Historical Pressure Points',
  'Limits of the Frame',
  'Return Path'
)

foreach ($file in $entryFiles) {
  $text = Get-Text -Path $file.FullName
  $frontmatter = Get-Frontmatter -Text $text
  if (-not $frontmatter) {
    throw "PH-CIV entry $($file.FullName) is missing frontmatter"
  }

  foreach ($field in $requiredFields) {
    if (-not (Get-FrontmatterValue -Frontmatter $frontmatter -Key $field)) {
      throw "PH-CIV entry $($file.FullName) is missing frontmatter field '$field'"
    }
  }

  if ((Get-FrontmatterValue -Frontmatter $frontmatter -Key 'derived_corpus') -ne 'ph-civ') {
    throw "PH-CIV entry $($file.FullName) must set derived_corpus: ph-civ"
  }

  $reviewStatus = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'review_status'
  if ($reviewStatus -notin @('calibration_seed', 'in_review', 'draft_pending_analysis')) {
    throw "PH-CIV entry $($file.FullName) has invalid review_status '$reviewStatus'"
  }

  $sourceId = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'source_id'
  if ($file.Name -ne "$sourceId.md") {
    throw "PH-CIV entry filename $($file.Name) must match source_id '$sourceId'"
  }

  $placementWeight = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'placement_weight'
  if ($placementWeight -notin @('strong', 'medium', 'light')) {
    throw "PH-CIV entry $($file.FullName) has invalid placement_weight '$placementWeight'"
  }

  foreach ($section in $requiredSections) {
    if ($text -notmatch "(?m)^##\s+$([regex]::Escape($section))\s*$") {
      throw "PH-CIV entry $($file.FullName) is missing section '$section'"
    }
  }

  foreach ($pathField in @('source_corpus_path', 'source_chapter_path', 'commentary_path')) {
    $target = Get-FrontmatterValue -Frontmatter $frontmatter -Key $pathField
    $resolvedTarget = Resolve-RepoPath -Path $target
    if (-not (Test-Path -LiteralPath $resolvedTarget -PathType Leaf)) {
      throw "PH-CIV entry $($file.FullName) points $pathField to missing file: $target"
    }
  }
}

$resolvedManifestPath = Resolve-RepoPath -Path $ManifestPath
if (-not (Test-Path -LiteralPath $resolvedManifestPath -PathType Leaf)) {
  throw "Manifest path does not exist: $ManifestPath"
}

$manifestText = Get-Text -Path $resolvedManifestPath
$manifestMatches = [regex]::Matches($manifestText, '(?m)^\s+ph_civ_path:\s*(\S+)\s*$')
if ($manifestMatches.Count -eq 0) {
  throw "Manifest $ManifestPath does not declare any ph_civ_path values"
}

foreach ($match in $manifestMatches) {
  $target = $match.Groups[1].Value.Trim('"')
  $resolvedTarget = Resolve-RepoPath -Path $target
  if (-not (Test-Path -LiteralPath $resolvedTarget -PathType Leaf)) {
    throw "Manifest ph_civ_path points to missing file: $target"
  }
}

foreach ($file in $entryFiles) {
  $relativePath = ($file.FullName.Substring((Get-Location).Path.Length + 1) -replace '\\', '/')
  if ($manifestText -notmatch [regex]::Escape($relativePath)) {
    throw "PH-CIV entry $relativePath is not referenced by ph_civ_path in $ManifestPath"
  }
}

[pscustomobject]@{
  CorpusPath = $CorpusPath
  ManifestPath = $ManifestPath
  EntryCount = $entryFiles.Count
  ManifestLinks = $manifestMatches.Count
  Status = 'ph_civ_valid'
} | Format-List | Out-Host
