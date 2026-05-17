param(
  [string]$RegistryPath = "registries/ph-choreography.yaml",
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

function Get-RouteField {
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

$resolvedRegistry = Resolve-RepoPath -Path $RegistryPath
if (-not (Test-Path -LiteralPath $resolvedRegistry -PathType Leaf)) {
  throw "Choreography registry path does not exist: $RegistryPath"
}

$registryText = Get-Text -Path $resolvedRegistry
$routes = [regex]::Matches($registryText, "(?ms)^\s+- source_id:\s*(\S+)\s*\n(.*?)(?=^\s+- source_id:|\z)")
if ($routes.Count -eq 0) {
  throw "No choreography routes found in $RegistryPath"
}

$allowedSurfaces = @('ph-civ', 'ph-apo')
$allowedMuseumStatuses = @('none', 'planned', 'curated_draft', 'human_curated', 'published')
$seenSourceIds = New-Object System.Collections.Generic.HashSet[string]
$routedMuseumPacks = New-Object System.Collections.Generic.HashSet[string]

foreach ($route in $routes) {
  $sourceId = $route.Groups[1].Value
  $block = $route.Groups[0].Value
  if (-not $seenSourceIds.Add($sourceId)) {
    throw "Duplicate choreography route for $sourceId"
  }

  $surface = Get-RouteField -Block $block -Field 'surface'
  $museumStatus = Get-RouteField -Block $block -Field 'museum_status'
  $cardPath = Get-RouteField -Block $block -Field 'card_path'
  $transcriptPath = Get-RouteField -Block $block -Field 'transcript_path'
  $commentaryPath = Get-RouteField -Block $block -Field 'commentary_path'
  $museumExhibitPath = Get-RouteField -Block $block -Field 'museum_exhibit_path'
  $museumPayloadPath = Get-RouteField -Block $block -Field 'museum_payload_path'
  $whatChangesHere = Get-RouteField -Block $block -Field 'what_changes_here'

  if ($surface -notin $allowedSurfaces) {
    throw "Route $sourceId has invalid surface '$surface'"
  }
  if ($museumStatus -notin $allowedMuseumStatuses) {
    throw "Route $sourceId has invalid museum_status '$museumStatus'"
  }
  if (-not $whatChangesHere) {
    throw "Route $sourceId must include what_changes_here"
  }

  foreach ($pathInfo in @(
    @{ Name = 'card_path'; Path = $cardPath },
    @{ Name = 'transcript_path'; Path = $transcriptPath },
    @{ Name = 'commentary_path'; Path = $commentaryPath }
  )) {
    if (-not $pathInfo.Path) {
      throw "Route $sourceId missing $($pathInfo.Name)"
    }
    Assert-FileExists -Path $pathInfo.Path -Context "Route $sourceId $($pathInfo.Name)" | Out-Null
  }

  if ($museumStatus -ne 'none') {
    if (-not $museumExhibitPath -or -not $museumPayloadPath) {
      throw "Route $sourceId with museum_status $museumStatus must include museum_exhibit_path and museum_payload_path"
    }
    if ($museumExhibitPath -notmatch '^corpus/media-packs/.+\.md$') {
      throw "Route $sourceId museum_exhibit_path must stay in corpus/media-packs and be Markdown"
    }
    $resolvedMuseumExhibit = Assert-FileExists -Path $museumExhibitPath -Context "Route $sourceId museum_exhibit_path"
    $resolvedMuseumPayload = Assert-FileExists -Path $museumPayloadPath -Context "Route $sourceId museum_payload_path"
    $routedMuseumPacks.Add($museumExhibitPath) | Out-Null

    $packText = Get-Text -Path $resolvedMuseumExhibit
    $payloadText = Get-Text -Path $resolvedMuseumPayload
    foreach ($textInfo in @(
      @{ Name = 'museum exhibit'; Text = $packText },
      @{ Name = 'museum payload'; Text = $payloadText }
    )) {
      if ($textInfo.Text -notmatch "(?m)^source_id:\s*$([regex]::Escape($sourceId))\s*$") {
        throw "Route $sourceId $($textInfo.Name) does not declare matching source_id"
      }
    }

    foreach ($pathField in @('civ_ph_path', 'transcript_path', 'commentary_path')) {
      if ($payloadText -notmatch "(?m)^\s+$([regex]::Escape($pathField)):\s*.+$") {
        throw "Route $sourceId museum payload is missing return path $pathField"
      }
    }
    if ($packText -notmatch "(?m)^##\s+Return Path\s*$") {
      throw "Route $sourceId museum exhibit is missing Return Path section"
    }

    if ($surface -eq 'ph-apo' -and $packText -notmatch '(?i)date-sensitive|current-events|current events|forecast|pressure') {
      throw "Route $sourceId ph-apo museum exhibit must include date-sensitive/current-events/pressure caution language"
    }
  }
}

$resolvedMediaCorpus = Resolve-RepoPath -Path $MediaCorpusPath
if (-not (Test-Path -LiteralPath $resolvedMediaCorpus -PathType Container)) {
  throw "Media corpus path does not exist: $MediaCorpusPath"
}

$mediaFiles = Get-ChildItem -LiteralPath $resolvedMediaCorpus -File -Filter '*.md' |
  Where-Object { $_.Name -notin @('README.md', 'index.md') }

foreach ($mediaFile in $mediaFiles) {
  $relative = $mediaFile.FullName.Substring((Get-Location).Path.Length + 1) -replace '\\', '/'
  if (-not $routedMuseumPacks.Contains($relative)) {
    throw "Museum exhibit lacks ph choreography route: $relative"
  }
}

[pscustomobject]@{
  RegistryPath = $RegistryPath
  RouteCount = $routes.Count
  RoutedMuseumPackCount = $routedMuseumPacks.Count
  Status = 'ph_choreography_valid'
} | Format-List | Out-Host
