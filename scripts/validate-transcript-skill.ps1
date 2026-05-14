$ErrorActionPreference = 'Stop'

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$Warnings = New-Object System.Collections.Generic.List[string]
$Failures = New-Object System.Collections.Generic.List[string]

function Resolve-RepoPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return Join-Path -Path $RepoRoot -ChildPath ($Path -replace '/', [IO.Path]::DirectorySeparatorChar)
}

function Get-Text {
  param([Parameter(Mandatory = $true)][string]$Path)
  return (Get-Content -LiteralPath $Path -Raw -Encoding utf8) -replace "`r`n", "`n"
}

function Add-Failure {
  param([Parameter(Mandatory = $true)][string]$Message)
  $Failures.Add($Message) | Out-Null
}

function Add-TranscriptWarning {
  param([Parameter(Mandatory = $true)][string]$Message)
  $Warnings.Add($Message) | Out-Null
  Write-Warning $Message
}

function Assert-File {
  param([Parameter(Mandatory = $true)][string]$Path)
  $resolved = Resolve-RepoPath -Path $Path
  if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
    Add-Failure "Missing required file: $Path"
  }
  return $resolved
}

function Assert-Text {
  param(
    [Parameter(Mandatory = $true)][string]$Label,
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Needle
  )

  if ($Text -notlike "*$Needle*") {
    Add-Failure "$Label is missing required text: $Needle"
  }
}

$cursorSkill = Assert-File '.cursor/skills/ph-youtube-transcript/SKILL.md'
$codexSkill = Assert-File '.codex/skills/ph-youtube-transcript/SKILL.md'
$cursorAgent = Assert-File '.cursor/skills/ph-youtube-transcript/agents/openai.yaml'
$codexAgent = Assert-File '.codex/skills/ph-youtube-transcript/agents/openai.yaml'
$workflowDoc = Assert-File 'docs/youtube-transcript-workflow.md'
$llmsPath = Assert-File 'llms.txt'
$repoMapPath = Assert-File 'docs/repo-map.md'

if ($Failures.Count -eq 0) {
  $cursorSkillText = Get-Text -Path $cursorSkill
  $codexSkillText = Get-Text -Path $codexSkill
  $cursorAgentText = Get-Text -Path $cursorAgent
  $codexAgentText = Get-Text -Path $codexAgent
  $workflowDocText = Get-Text -Path $workflowDoc
  $llmsText = Get-Text -Path $llmsPath
  $repoMapText = Get-Text -Path $repoMapPath

  if ($cursorSkillText -ne $codexSkillText) {
    Add-Failure 'Cursor and Codex transcript skill files must remain identical'
  }

  if ($cursorAgentText -ne $codexAgentText) {
    Add-Failure 'Cursor and Codex openai.yaml files must remain identical'
  }

  $requiredSkillText = @(
    'name: ph-youtube-transcript',
    'youtube transcript',
    'ph transcript',
    'predictive history transcript',
    'Predictive History channel',
    '/codex/YYYY/raw-input',
    'daily current-events',
    'plan-only fallback',
    'WORKFLOW-transcripts.md',
    'ASR-VERIFICATION-RUBRIC.md',
    'ASR-AUDIT-LOG.md',
    'research/external/youtube-channels/predictive-history/transcripts/*.txt',
    'index.json',
    'transcript_manifest.json',
    'CHANNEL-VIDEO-INDEX.md',
    'verbatim-transcripts/*.md',
    'lectures/*.md',
    '## Full transcript',
    'metadata/quotes.yaml',
    'scripts/fetch_youtube_channel_transcripts.py',
    'scripts/youtube_transcripts/',
    'youtube-transcript-api',
    'yt-dlp',
    'whisper.cpp',
    'manual captions',
    'auto captions',
    'TRANSCRIPT_MIN_QUALITY',
    '--keep-low-quality',
    '--force',
    'scripts/work_jiang/normalize_lecture_transcript_asr.py',
    'scripts/work_jiang/asr_transcript_replacements.py',
    'scripts/work_jiang/asr_light_clean.py',
    'scripts/work_jiang/sync_verbatim_transcripts.py --dry-run',
    'scripts/work_jiang/sync_verbatim_transcripts.py --write',
    '--only-glob',
    '[verify: MM:SS]',
    '[unclear]',
    'not quote-grade'
  )

  foreach ($needle in $requiredSkillText) {
    Assert-Text -Label 'ph-youtube-transcript skill' -Text $cursorSkillText -Needle $needle
  }

  $requiredDocText = @(
    'ph-youtube-transcript',
    '/codex/YYYY/raw-input',
    'plan-only fallback',
    'Transcript Layers',
    'research/external/youtube-channels/predictive-history/transcripts/*.txt',
    'transcript_manifest.json',
    'verbatim-transcripts/*.md',
    'lectures/*.md',
    'metadata/quotes.yaml',
    'youtube-transcript-api',
    'yt-dlp',
    'whisper.cpp',
    'TRANSCRIPT_MIN_QUALITY',
    '--keep-low-quality',
    '--force',
    'sync_verbatim_transcripts.py --dry-run',
    '--only-glob',
    'not quote-grade',
    '[verify: MM:SS]'
  )

  foreach ($needle in $requiredDocText) {
    Assert-Text -Label 'docs/youtube-transcript-workflow.md' -Text $workflowDocText -Needle $needle
  }

  $requiredAgentText = @(
    'display_name: "PH YouTube Transcript"',
    'short_description: "Predictive History transcript workflow"',
    'default_prompt: "Use $ph-youtube-transcript',
    'allow_implicit_invocation: true'
  )

  foreach ($needle in $requiredAgentText) {
    Assert-Text -Label 'agents/openai.yaml' -Text $cursorAgentText -Needle $needle
  }

  foreach ($needle in @('docs/youtube-transcript-workflow.md', 'ph-youtube-transcript', 'youtube transcript', 'ph transcript', 'predictive history transcript', 'plan-only fallback')) {
    Assert-Text -Label 'llms.txt' -Text $llmsText -Needle $needle
  }

  foreach ($needle in @('.cursor/', '.codex/', 'ph-youtube-transcript', 'youtube-transcript-workflow.md', 'validate-transcript-skill.ps1')) {
    Assert-Text -Label 'docs/repo-map.md' -Text $repoMapText -Needle $needle
  }
}

$futureTranscriptStack = @(
  'WORKFLOW-transcripts.md',
  'ASR-VERIFICATION-RUBRIC.md',
  'ASR-AUDIT-LOG.md',
  'research/external/youtube-channels/predictive-history/README.md',
  'research/external/youtube-channels/predictive-history/transcripts/README.md',
  'scripts/fetch_youtube_channel_transcripts.py',
  'scripts/youtube_transcripts',
  'scripts/work_jiang/sync_verbatim_transcripts.py',
  'scripts/work_jiang/normalize_lecture_transcript_asr.py',
  'scripts/work_jiang/asr_transcript_replacements.py',
  'scripts/work_jiang/asr_light_clean.py'
)

foreach ($path in $futureTranscriptStack) {
  $resolved = Resolve-RepoPath -Path $path
  if (-not (Test-Path -LiteralPath $resolved)) {
    Add-TranscriptWarning "Future transcript stack surface is absent in this checkout: $path"
  }
}

if ($Failures.Count -gt 0) {
  foreach ($failure in $Failures) {
    Write-Error $failure
  }
  throw "Transcript skill validation failed with $($Failures.Count) failure(s)"
}

$status = 'valid'
if ($Warnings.Count -gt 0) {
  $status = 'valid_with_warnings'
}

[pscustomobject]@{
  Status = $status
  WarningCount = $Warnings.Count
} | Format-List | Out-Host
