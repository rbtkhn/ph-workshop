param(
  [string]$ReportsDir = "reports"
)

$ErrorActionPreference = 'Stop'

function Resolve-RepoPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return Join-Path -Path (Get-Location) -ChildPath ($Path -replace '/', [IO.Path]::DirectorySeparatorChar)
}

function Read-JsonIfPresent {
  param([Parameter(Mandatory = $true)][string]$Path)
  $resolved = Resolve-RepoPath -Path $Path
  if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
    return $null
  }
  return Get-Content -LiteralPath $resolved -Raw -Encoding utf8 | ConvertFrom-Json
}

function Test-RepoPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return Test-Path -LiteralPath (Resolve-RepoPath -Path $Path)
}

function New-Loop {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Purpose,
    [Parameter(Mandatory = $true)][string]$SignalSource,
    [Parameter(Mandatory = $true)][string]$Artifact,
    [Parameter(Mandatory = $true)][int]$WarningCount,
    [Parameter(Mandatory = $true)][string]$NextAction,
    [Parameter(Mandatory = $true)][string]$FailureBoundary
  )

  $status = if ($WarningCount -gt 0) { 'warnings' } else { 'clean' }
  return [pscustomobject][ordered]@{
    name = $Name
    purpose = $Purpose
    signal_source = $SignalSource
    artifact = $Artifact
    warning_count = $WarningCount
    status = $status
    next_action = $NextAction
    failure_boundary = $FailureBoundary
  }
}

$resolvedReportsDir = Resolve-RepoPath -Path $ReportsDir
if (-not (Test-Path -LiteralPath $resolvedReportsDir -PathType Container)) {
  New-Item -ItemType Directory -Path $resolvedReportsDir | Out-Null
}

$spine = Read-JsonIfPresent -Path (Join-Path $ReportsDir 'civilization-spine-health.json')
$civPh = Read-JsonIfPresent -Path (Join-Path $ReportsDir 'civ-ph-health.json')
$queue = Read-JsonIfPresent -Path (Join-Path $ReportsDir 'high-risk-review-queue.json')
$nextActions = Read-JsonIfPresent -Path (Join-Path $ReportsDir 'next-actions.json')

$missingReportWarnings = 0
foreach ($report in @($spine, $civPh, $queue, $nextActions)) {
  if ($null -eq $report) {
    $missingReportWarnings += 1
  }
}

$spineWarnings = if ($spine -and $spine.warning_count -ne $null) { [int]$spine.warning_count } else { 1 }
$civPhWarnings = if ($civPh -and $civPh.warning_count -ne $null) { [int]$civPh.warning_count } else { 1 }
$queueWarnings = if ($queue -and $queue.queue_count -ne $null) { [int]$queue.queue_count } else { 1 }

$nonExactTranscriptCount = 0
if ($spine -and $spine.chapters) {
  $nonExactTranscriptCount = @($spine.chapters | Where-Object { $_.transcript_fidelity -ne 'exact_body_match' }).Count
}

$crossSurfaceMissing = 0
foreach ($path in @(
  'registries/cross-volume-links.yaml',
  'corpus/cross-volume/index.md',
  'corpus/media-packs/index.md',
  'corpus/civ-ph/index.md',
  'reports/civ-ph-health.json',
  'reports/high-risk-review-queue.json'
)) {
  if (-not (Test-RepoPath -Path $path)) {
    $crossSurfaceMissing += 1
  }
}

$loops = @(
  New-Loop `
    -Name 'Structural Integrity Loop' `
    -Purpose 'Keep routed chapter surfaces resolvable and schema-consistent.' `
    -SignalSource 'Spine validators, chapter-manifest.yaml, routed chapter files, and path checks.' `
    -Artifact 'reports/civilization-spine-health.*' `
    -WarningCount $spineWarnings `
    -NextAction 'Repair manifest paths, missing routed files, invalid metadata, or validator failures.' `
    -FailureBoundary 'Broken paths, missing required files, invalid schema, or validator failures are hard failures.'
  New-Loop `
    -Name 'Source Fidelity Loop' `
    -Purpose 'Preserve exact transcript bodies and quote-grade boundaries.' `
    -SignalSource 'Transcript fidelity metadata, transfer-authority comparisons, and transcript substrate checks.' `
    -Artifact 'spine health reports and transcript validators' `
    -WarningCount $nonExactTranscriptCount `
    -NextAction 'Use explicit transcript-fidelity workflow before repairing curated transcript bodies.' `
    -FailureBoundary 'Guardrail review must not mutate transcript bodies.'
  New-Loop `
    -Name 'Interpretive Constraint Loop' `
    -Purpose 'Keep high-risk interpretation bounded, source-statused, and reviewable.' `
    -SignalSource 'Known-risk seeds, heuristic flags, limits sections, and date-sensitive language.' `
    -Artifact 'reports/high-risk-review-queue.* and reports/next-actions.*' `
    -WarningCount $queueWarnings `
    -NextAction 'Work the highest-priority guardrail queue, then regenerate reports.' `
    -FailureBoundary 'Review-depth gaps remain warnings; public terminology leakage and unsupported confidence must be corrected.'
  New-Loop `
    -Name 'Orientation Coherence Loop' `
    -Purpose 'Keep civ-ph entries aligned with chapters, payloads, placement weights, limits, and return paths.' `
    -SignalSource 'civ-ph validator, orientation validator, manifest civ_ph_path, and entry frontmatter.' `
    -Artifact 'reports/civ-ph-health.*' `
    -WarningCount $civPhWarnings `
    -NextAction 'Update civ-ph or orientation payloads only where alignment fails.' `
    -FailureBoundary 'civ-ph remains orientation, not transcript, source substitute, endorsement, or second commentary.'
  New-Loop `
    -Name 'Cross-Surface Routing Loop' `
    -Purpose 'Keep corridors, media packs, reports, registries, and export surfaces mutually navigable.' `
    -SignalSource 'Cross-volume validators, media-pack validators, report generation, and export-readiness checks.' `
    -Artifact 'cross-volume registry, media-pack corpus, and improvement-loop report' `
    -WarningCount ($crossSurfaceMissing + $missingReportWarnings) `
    -NextAction 'Repair missing routing/report surfaces, then run cross-volume and media-pack validation.' `
    -FailureBoundary 'Corridors and media packs orient study; they do not prove causal claims or override chapter source status.'
)

$overallWarnings = 0
foreach ($loop in $loops) {
  $overallWarnings += [int]$loop.warning_count
}

$summary = [pscustomobject][ordered]@{
  generated_at = 'deterministic-local'
  loop_model = 'validate -> audit -> queue -> deepen -> revalidate'
  status = if ($overallWarnings -gt 0) { 'warnings' } else { 'clean' }
  warning_count = $overallWarnings
  loops = $loops
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $resolvedReportsDir 'improvement-loops.json') -Encoding utf8

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Improvement Loops') | Out-Null
$md.Add('') | Out-Null
$md.Add('Internal maintainer snapshot for Predictive History recursive quality loops.') | Out-Null
$md.Add('') | Out-Null
$md.Add('Loop model: `validate -> audit -> queue -> deepen -> revalidate`') | Out-Null
$md.Add("Status: $($summary.status)") | Out-Null
$md.Add("Warning count: $($summary.warning_count)") | Out-Null
$md.Add('') | Out-Null
$md.Add('| loop | status | warnings | next action |') | Out-Null
$md.Add('| --- | --- | --- | --- |') | Out-Null
foreach ($loop in $loops) {
  $md.Add("| $($loop.name) | $($loop.status) | $($loop.warning_count) | $($loop.next_action) |") | Out-Null
}
$md.Add('') | Out-Null
$md.Add('## Failure Boundaries') | Out-Null
$md.Add('') | Out-Null
foreach ($loop in $loops) {
  $md.Add("- **$($loop.name):** $($loop.failure_boundary)") | Out-Null
}
$md | Set-Content -LiteralPath (Join-Path $resolvedReportsDir 'improvement-loops.md') -Encoding utf8

[pscustomobject]@{
  Report = 'improvement-loops'
  LoopCount = $loops.Count
  WarningCount = $overallWarnings
  Status = $summary.status
} | Format-List | Out-Host
