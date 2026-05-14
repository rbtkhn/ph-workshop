$ErrorActionPreference = 'Stop'

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')

function Resolve-RepoPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return Join-Path -Path $RepoRoot -ChildPath ($Path -replace '/', [IO.Path]::DirectorySeparatorChar)
}

function Assert-Path {
  param([Parameter(Mandatory = $true)][string]$Path)
  $resolved = Resolve-RepoPath -Path $Path
  if (-not (Test-Path -LiteralPath $resolved)) {
    throw "Missing transcript substrate path: $Path"
  }
}

function Assert-Text {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Needle
  )
  $resolved = Resolve-RepoPath -Path $Path
  $text = Get-Content -LiteralPath $resolved -Raw -Encoding utf8
  if ($text -notlike "*$Needle*") {
    throw "$Path is missing required text: $Needle"
  }
}

$requiredPaths = @(
  '.gitignore',
  'WORKFLOW-transcripts.md',
  'ASR-VERIFICATION-RUBRIC.md',
  'ASR-AUDIT-LOG.md',
  'research/external/youtube-channels/predictive-history/README.md',
  'research/external/youtube-channels/predictive-history/CHANNEL-VIDEO-INDEX.md',
  'research/external/youtube-channels/predictive-history/index.json',
  'research/external/youtube-channels/predictive-history/transcript_manifest.json',
  'research/external/youtube-channels/predictive-history/transcripts/README.md',
  'scripts/fetch_youtube_channel_transcripts.py',
  'scripts/youtube_transcripts/__init__.py',
  'scripts/youtube_transcripts/acquire.py',
  'scripts/youtube_transcripts/manifest.py',
  'scripts/youtube_transcripts/vtt.py',
  'scripts/work_jiang/asr_light_clean.py',
  'scripts/work_jiang/asr_transcript_replacements.py',
  'scripts/work_jiang/normalize_lecture_transcript_asr.py',
  'scripts/work_jiang/sync_verbatim_transcripts.py',
  'tests/test_normalize_lecture_transcript_asr.py',
  'tests/test_youtube_transcripts.py'
)

foreach ($path in $requiredPaths) {
  Assert-Path -Path $path
}

foreach ($needle in @(
  'research/external/youtube-channels/predictive-history/transcripts/*.txt',
  'research/external/youtube-channels/predictive-history/transcripts/*.vtt',
  'research/external/youtube-channels/predictive-history/transcripts/*.srt'
)) {
  Assert-Text -Path '.gitignore' -Needle $needle
}

Assert-Text -Path 'WORKFLOW-transcripts.md' -Needle 'not quote-grade'
Assert-Text -Path 'ASR-VERIFICATION-RUBRIC.md' -Needle 'Depth C: Quote-Grade Review'
Assert-Text -Path 'scripts/fetch_youtube_channel_transcripts.py' -Needle 'TRANSCRIPT_MIN_QUALITY'
Assert-Text -Path 'scripts/work_jiang/sync_verbatim_transcripts.py' -Needle '--dry-run'
Assert-Text -Path 'scripts/work_jiang/normalize_lecture_transcript_asr.py' -Needle 'Choose exactly one of --dry-run or --write'

$verbatimDir = Resolve-RepoPath -Path 'verbatim-transcripts'
if (Test-Path -LiteralPath $verbatimDir -PathType Container) {
  $verbatimFiles = Get-ChildItem -LiteralPath $verbatimDir -File -Filter '*.md'
  foreach ($file in $verbatimFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
    foreach ($needle in @(
      'source: raw_youtube_caption_cache',
      'transcript_status: generated_verbatim_pending_review',
      'quote_grade: false',
      '## Full transcript'
    )) {
      if ($text -notlike "*$needle*") {
        throw "Generated verbatim file $($file.FullName) is missing required text: $needle"
      }
    }
  }
}

& python -m py_compile `
  scripts\fetch_youtube_channel_transcripts.py `
  scripts\youtube_transcripts\__init__.py `
  scripts\youtube_transcripts\manifest.py `
  scripts\youtube_transcripts\vtt.py `
  scripts\youtube_transcripts\acquire.py `
  scripts\work_jiang\asr_light_clean.py `
  scripts\work_jiang\asr_transcript_replacements.py `
  scripts\work_jiang\normalize_lecture_transcript_asr.py `
  scripts\work_jiang\sync_verbatim_transcripts.py

if ($LASTEXITCODE -ne 0) {
  throw 'Python transcript substrate compile check failed'
}

& python -m pytest tests\test_normalize_lecture_transcript_asr.py tests\test_youtube_transcripts.py -q
if ($LASTEXITCODE -ne 0) {
  throw 'Transcript substrate tests failed'
}

[pscustomobject]@{
  Status = 'transcript_substrate_valid'
  RequiredPathCount = $requiredPaths.Count
} | Format-List | Out-Host
