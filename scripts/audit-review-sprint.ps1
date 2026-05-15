param(
  [int]$Count = 5,
  [string]$ReportsDir = "reports"
)

$ErrorActionPreference = 'Stop'

function Resolve-RepoPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return Join-Path -Path (Get-Location) -ChildPath ($Path -replace '/', [IO.Path]::DirectorySeparatorChar)
}

function Read-RequiredJson {
  param([Parameter(Mandatory = $true)][string]$Path)
  $resolved = Resolve-RepoPath -Path $Path
  if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
    throw "Required report is missing: $Path"
  }
  return Get-Content -LiteralPath $resolved -Raw -Encoding utf8 | ConvertFrom-Json
}

function Get-PriorityRank {
  param([Parameter(Mandatory = $true)][string]$Priority)
  switch ($Priority) {
    'high' { return 0 }
    'medium' { return 1 }
    'watch' { return 2 }
    default { return 3 }
  }
}

if ($Count -lt 1) {
  throw 'Count must be at least 1'
}

$resolvedReportsDir = Resolve-RepoPath -Path $ReportsDir
if (-not (Test-Path -LiteralPath $resolvedReportsDir -PathType Container)) {
  New-Item -ItemType Directory -Path $resolvedReportsDir | Out-Null
}

$queue = Read-RequiredJson -Path (Join-Path $ReportsDir 'high-risk-review-queue.json')
$nextActions = Read-RequiredJson -Path (Join-Path $ReportsDir 'next-actions.json')
$loops = Read-RequiredJson -Path (Join-Path $ReportsDir 'improvement-loops.json')

$orderedItems = @($queue.items | Sort-Object @{ Expression = { Get-PriorityRank -Priority $_.priority } }, source_id)
$selected = @($orderedItems | Select-Object -First $Count)

$sprintItems = foreach ($item in $selected) {
  [pscustomobject][ordered]@{
    source_id = $item.source_id
    title = $item.title
    priority = $item.priority
    flags = @($item.flags)
    recommended_next_action = $item.recommended_next_action
    commentary_path = $item.commentary_path
    civ_ph_path = $item.civ_ph_path
    target_loop = 'Interpretive Constraint Loop'
    allowed_action = 'Deepen limits, clarify counter-readings, and add uncertainty or source-status notes in commentary or civ-ph.'
    validation_return_path = 'Regenerate the review queue, regenerate the improvement loop report, then run validate-all.'
  }
}

$summary = [pscustomobject][ordered]@{
  generated_at = 'deterministic-local'
  cadence = 'weekly'
  sprint_model = 'validate -> audit -> select sprint -> deepen selected items -> revalidate'
  requested_count = $Count
  selected_count = $sprintItems.Count
  queue_count = $queue.queue_count
  improvement_loop_status = $loops.status
  next_actions = @($nextActions.next_actions)
  items = @($sprintItems)
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $resolvedReportsDir 'review-sprint.json') -Encoding utf8

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Weekly Review Sprint') | Out-Null
$md.Add('') | Out-Null
$md.Add('Internal maintainer sprint selected from the high-risk review queue.') | Out-Null
$md.Add('') | Out-Null
$md.Add('Sprint model: `validate -> audit -> select sprint -> deepen selected items -> revalidate`') | Out-Null
$md.Add("Selected items: $($sprintItems.Count)") | Out-Null
$md.Add("Queue count: $($queue.queue_count)") | Out-Null
$md.Add("Improvement loop status: $($loops.status)") | Out-Null
$md.Add('') | Out-Null
$md.Add('## Sprint Items') | Out-Null
$md.Add('') | Out-Null
$md.Add('| source_id | priority | flags | next action |') | Out-Null
$md.Add('| --- | --- | --- | --- |') | Out-Null
foreach ($item in $sprintItems) {
  $sourceId = $item.source_id
  $flags = $item.flags -join ', '
  $md.Add("| ``$sourceId`` | $($item.priority) | $flags | $($item.recommended_next_action) |") | Out-Null
}
$md.Add('') | Out-Null
$md.Add('## Allowed Action') | Out-Null
$md.Add('') | Out-Null
$md.Add('For each selected item, deepen limits, clarify counter-readings, and add uncertainty or source-status notes in commentary or civ-ph. Do not edit transcript bodies as part of sprint work.') | Out-Null
$md.Add('') | Out-Null
$md.Add('## Validation Return Path') | Out-Null
$md.Add('') | Out-Null
$md.Add('After sprint work, rerun `.\scripts\audit-review-queue.ps1`, `.\scripts\audit-improvement-loops.ps1`, `.\scripts\audit-review-sprint.ps1`, and `.\scripts\validate-all.ps1`.') | Out-Null
$md | Set-Content -LiteralPath (Join-Path $resolvedReportsDir 'review-sprint.md') -Encoding utf8

[pscustomobject]@{
  Report = 'review-sprint'
  SelectedCount = $sprintItems.Count
  QueueCount = $queue.queue_count
  Status = 'selected'
} | Format-List | Out-Host
