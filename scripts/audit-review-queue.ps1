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
  if (-not $match.Success) { return $null }
  return $match.Groups[0].Value
}

function Get-ManifestField {
  param(
    [AllowNull()][string]$Block,
    [Parameter(Mandatory = $true)][string]$Field
  )
  if (-not $Block) { return $null }
  $match = [regex]::Match($Block, "(?m)^\s+$([regex]::Escape($Field)):\s*(.+?)\s*$")
  if (-not $match.Success) { return $null }
  return $match.Groups[1].Value.Trim().Trim('"')
}

function Add-FlagIfMatch {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Pattern,
    [Parameter(Mandatory = $true)][string]$Flag,
    [Parameter(Mandatory = $true)]$Flags
  )
  if ($Text -match $Pattern -and -not $Flags.Contains($Flag)) {
    $Flags.Add($Flag) | Out-Null
  }
}

$resolvedManifestPath = Resolve-RepoPath -Path $ManifestPath
if (-not (Test-Path -LiteralPath $resolvedManifestPath -PathType Leaf)) {
  throw "Manifest path does not exist: $ManifestPath"
}

$resolvedReportsDir = Resolve-RepoPath -Path $ReportsDir
if (-not (Test-Path -LiteralPath $resolvedReportsDir -PathType Container)) {
  New-Item -ItemType Directory -Path $resolvedReportsDir | Out-Null
}

$seedRisk = @('civ-24', 'civ-25', 'civ-31', 'civ-32', 'civ-43', 'civ-44', 'civ-52', 'civ-53', 'civ-54', 'civ-58', 'civ-59', 'civ-60')
$manifestText = Get-Text -Path $resolvedManifestPath
$items = New-Object System.Collections.Generic.List[object]

foreach ($sourceId in (1..60 | ForEach-Object { "civ-{0:D2}" -f $_ })) {
  $block = Get-ManifestBlock -ManifestText $manifestText -SourceId $sourceId
  if (-not $block) {
    throw "Missing manifest row for $sourceId"
  }

  $partIIPath = Get-ManifestField -Block $block -Field 'part_ii_path'
  $phCivPath = Get-ManifestField -Block $block -Field 'ph_civ_path'
  $partIPath = Get-ManifestField -Block $block -Field 'part_i_path'
  foreach ($path in @($partIIPath, $phCivPath, $partIPath)) {
    if (-not $path) { throw "Missing path in manifest row $sourceId" }
    if (-not (Test-Path -LiteralPath (Resolve-RepoPath -Path $path) -PathType Leaf)) {
      throw "Missing routed file for ${sourceId}: $path"
    }
  }

  $reviewText = Get-Text -Path (Resolve-RepoPath -Path $phCivPath)
  $flags = New-Object System.Collections.Generic.List[string]
  if ($sourceId -in $seedRisk) {
    $flags.Add('seeded-known-risk') | Out-Null
  }

  Add-FlagIfMatch -Text $reviewText -Pattern '(?i)\b(Ukraine|Russia|Iran|Israel|Trump|Putin|China|NATO|current-events|live-current|forecast|prediction|war)\b' -Flag 'live-current-or-war-prediction' -Flags $flags
  Add-FlagIfMatch -Text $reviewText -Pattern '(?i)\b(race|racial|eugenics|antisemit|anti-semit|Holocaust|Nazi|Hitler)\b' -Flag 'race-eugenics-nazism-antisemitism' -Flags $flags
  Add-FlagIfMatch -Text $reviewText -Pattern '(?i)\b(violence|terror|purge|genocide|massacre|brutality|conquest)\b' -Flag 'violence-or-state-terror' -Flags $flags
  Add-FlagIfMatch -Text $reviewText -Pattern '(?i)\b(Christian|Islam|Jewish|Jesus|Paul|Muhammad|Bible|Quran|religious formation|Gnostic|Zoroastrian)\b' -Flag 'religious-formation' -Flags $flags
  Add-FlagIfMatch -Text $reviewText -Pattern '(?i)\b(central bank|Bretton Woods|dollar|Bitcoin|conspiracy|Quigley|finance)\b' -Flag 'finance-conspiracy-adjacent' -Flags $flags
  Add-FlagIfMatch -Text $reviewText -Pattern '(?i)\b(analogy|comparison|modern political|date-sensitive)\b' -Flag 'political-analogy-or-date-sensitive' -Flags $flags
  Add-FlagIfMatch -Text $reviewText -Pattern '(?i)\b(ASR|proper nouns|transcript cutoff|cutoff)\b' -Flag 'transcript-or-asr-risk' -Flags $flags

  if ($flags.Count -gt 0) {
    $priority = if ($sourceId -in $seedRisk) { 'high' } elseif ($flags.Count -ge 3) { 'medium' } else { 'watch' }
    $nextAction = switch ($priority) {
      'high' { 'manual guardrail and external-review triage' }
      'medium' { 'review limits language and source-layer separation' }
      default { 'monitor during next commentary pass' }
    }

    $items.Add([pscustomobject][ordered]@{
      source_id = $sourceId
      title = Get-ManifestField -Block $block -Field 'title'
      priority = $priority
      flags = @($flags.ToArray())
      recommended_next_action = $nextAction
      commentary_path = $partIIPath
      ph_civ_path = $phCivPath
    }) | Out-Null
  }
}

$orderedItems = @($items | Sort-Object @{ Expression = { if ($_.priority -eq 'high') { 0 } elseif ($_.priority -eq 'medium') { 1 } else { 2 } } }, source_id)
$nextActions = @(
  [pscustomobject][ordered]@{ action = 'Run high-priority manual guardrail review'; target = 'seeded known-risk chapters'; count = @($orderedItems | Where-Object { $_.priority -eq 'high' }).Count },
  [pscustomobject][ordered]@{ action = 'Review medium-risk limits and return paths'; target = 'heuristic medium-risk chapters'; count = @($orderedItems | Where-Object { $_.priority -eq 'medium' }).Count },
  [pscustomobject][ordered]@{ action = 'Preserve transcript fidelity during all review work'; target = 'all chapters'; count = 60 }
)

$queueSummary = [pscustomobject][ordered]@{
  generated_at = 'deterministic-local'
  queue_count = $orderedItems.Count
  seeded_known_risk = $seedRisk
  items = @($orderedItems)
}
$queueSummary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $resolvedReportsDir 'high-risk-review-queue.json') -Encoding utf8

$queueMd = New-Object System.Collections.Generic.List[string]
$queueMd.Add('# High-Risk Review Queue') | Out-Null
$queueMd.Add('') | Out-Null
$queueMd.Add('Internal seeded plus heuristic queue for Civilization review work.') | Out-Null
$queueMd.Add('') | Out-Null
$queueMd.Add("Queue count: $($orderedItems.Count)") | Out-Null
$queueMd.Add('') | Out-Null
$queueMd.Add('| source_id | priority | flags | next action |') | Out-Null
$queueMd.Add('| --- | --- | --- | --- |') | Out-Null
foreach ($item in $orderedItems) {
  $sourceId = $item.source_id
  $flags = $item.flags -join ', '
  $queueMd.Add("| ``$sourceId`` | $($item.priority) | $flags | $($item.recommended_next_action) |") | Out-Null
}
$queueMd | Set-Content -LiteralPath (Join-Path $resolvedReportsDir 'high-risk-review-queue.md') -Encoding utf8

$nextSummary = [pscustomobject][ordered]@{
  generated_at = 'deterministic-local'
  next_actions = $nextActions
}
$nextSummary | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $resolvedReportsDir 'next-actions.json') -Encoding utf8

$nextMd = New-Object System.Collections.Generic.List[string]
$nextMd.Add('# Next Actions') | Out-Null
$nextMd.Add('') | Out-Null
$nextMd.Add('Internal maintainer queue generated from the audit substrate.') | Out-Null
$nextMd.Add('') | Out-Null
$nextMd.Add('| action | target | count |') | Out-Null
$nextMd.Add('| --- | --- | --- |') | Out-Null
foreach ($action in $nextActions) {
  $nextMd.Add("| $($action.action) | $($action.target) | $($action.count) |") | Out-Null
}
$nextMd | Set-Content -LiteralPath (Join-Path $resolvedReportsDir 'next-actions.md') -Encoding utf8

[pscustomobject]@{
  Report = 'high-risk-review-queue'
  QueueCount = $orderedItems.Count
  HighPriorityCount = @($orderedItems | Where-Object { $_.priority -eq 'high' }).Count
  Status = 'warnings'
} | Format-List | Out-Host
