$ErrorActionPreference = 'Stop'

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$Failures = New-Object System.Collections.Generic.List[string]

function Resolve-RepoPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return Join-Path -Path $RepoRoot -ChildPath ($Path -replace '/', [IO.Path]::DirectorySeparatorChar)
}

function Add-Failure {
  param([Parameter(Mandatory = $true)][string]$Message)
  $Failures.Add($Message) | Out-Null
}

function Get-Text {
  param([Parameter(Mandatory = $true)][string]$Path)
  return (Get-Content -LiteralPath $Path -Raw -Encoding utf8) -replace "`r`n", "`n"
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
  if (-not $Text.Contains($Needle)) {
    Add-Failure "$Label is missing required text: $Needle"
  }
}

$canonicalSkills = @(
  'ph-open',
  'ph-transcript',
  'ph-chapter',
  'civ-ph',
  'ph-cross-volume',
  'ph-audit'
)

$allSkills = $canonicalSkills + @('ph-youtube-transcript')
$surfaces = @('.cursor', '.codex')

foreach ($skill in $allSkills) {
  $cursorSkill = Assert-File ".cursor/skills/$skill/SKILL.md"
  $codexSkill = Assert-File ".codex/skills/$skill/SKILL.md"
  $cursorAgent = Assert-File ".cursor/skills/$skill/agents/openai.yaml"
  $codexAgent = Assert-File ".codex/skills/$skill/agents/openai.yaml"

  if ($Failures.Count -eq 0) {
    $cursorSkillText = Get-Text -Path $cursorSkill
    $codexSkillText = Get-Text -Path $codexSkill
    $cursorAgentText = Get-Text -Path $cursorAgent
    $codexAgentText = Get-Text -Path $codexAgent

    if ($cursorSkillText -ne $codexSkillText) {
      Add-Failure "$skill SKILL.md differs between .cursor and .codex"
    }
    if ($cursorAgentText -ne $codexAgentText) {
      Add-Failure "$skill agents/openai.yaml differs between .cursor and .codex"
    }
    Assert-Text -Label "$skill SKILL.md" -Text $cursorSkillText -Needle "name: $skill"
    Assert-Text -Label "$skill agents/openai.yaml" -Text $cursorAgentText -Needle 'allow_implicit_invocation: true'
    Assert-Text -Label "$skill agents/openai.yaml" -Text $cursorAgentText -Needle "Use `$$skill"
  }
}

if ($Failures.Count -eq 0) {
  $skillText = @{}
  foreach ($skill in $allSkills) {
    $skillText[$skill] = Get-Text -Path (Resolve-RepoPath ".cursor/skills/$skill/SKILL.md")
  }

  foreach ($needle in @(
    'scripts/ph-civ-open.ps1',
    'candidate',
    'approved',
    'exported',
    'Do not copy transcripts',
    'ph-workshop'
  )) {
    Assert-Text -Label 'ph-open' -Text $skillText['ph-open'] -Needle $needle
  }

  foreach ($needle in @(
    'quote-grade',
    'exact-body-match',
    'ASR-AUDIT-LOG.md',
    'verbatim-transcripts/*.md',
    'metadata/quotes.yaml',
    'scripts/validate-transcript-fidelity.ps1',
    'validate-transcript-substrate.ps1'
  )) {
    Assert-Text -Label 'ph-transcript' -Text $skillText['ph-transcript'] -Needle $needle
  }

  foreach ($needle in @(
    'chapter-manifest.yaml',
    '*-transcript.md',
    '*-commentary.md',
    'Preserve transcript fidelity',
    'review status'
  )) {
    Assert-Text -Label 'ph-chapter' -Text $skillText['ph-chapter'] -Needle $needle
  }

  foreach ($needle in @(
    'corpus/civ-ph/',
    'placement_weight',
    'orientation_payload_path',
    'Do not overclaim calibrated status',
    'limits language'
  )) {
    Assert-Text -Label 'civ-ph' -Text $skillText['civ-ph'] -Needle $needle
  }

  foreach ($needle in @(
    'corpus/cross-volume/',
    'registries/cross-volume-links.yaml',
    'chapter-manifest.yaml',
    'scale_shift',
    'not causal proof'
  )) {
    Assert-Text -Label 'ph-cross-volume' -Text $skillText['ph-cross-volume'] -Needle $needle
  }

  foreach ($needle in @(
    'scripts/validate-all.ps1',
    'transcript fidelity',
    'civ-ph health',
    'high-risk review queue',
    'avoid content rewrites'
  )) {
    Assert-Text -Label 'ph-audit' -Text $skillText['ph-audit'] -Needle $needle
  }

  foreach ($needle in @(
    'compatibility alias',
    'canonical transcript skill is `ph-transcript`',
    'Do not duplicate or extend transcript policy'
  )) {
    Assert-Text -Label 'ph-youtube-transcript alias' -Text $skillText['ph-youtube-transcript'] -Needle $needle
  }

  if ($skillText['ph-youtube-transcript'].Length -gt 1200) {
    Add-Failure 'ph-youtube-transcript must remain a short alias, not a duplicate full skill'
  }

  $llmsText = Get-Text -Path (Assert-File 'llms.txt')
  $repoMapText = Get-Text -Path (Assert-File 'docs/repo-map.md')
  foreach ($skill in $canonicalSkills) {
    Assert-Text -Label 'llms.txt' -Text $llmsText -Needle $skill
    Assert-Text -Label 'docs/repo-map.md' -Text $repoMapText -Needle $skill
  }
  Assert-Text -Label 'llms.txt' -Text $llmsText -Needle 'ph-youtube-transcript'
  Assert-Text -Label 'docs/repo-map.md' -Text $repoMapText -Needle 'ph-youtube-transcript'
}

if ($Failures.Count -gt 0) {
  foreach ($failure in $Failures) {
    Write-Error $failure
  }
  throw "PH skill validation failed with $($Failures.Count) failure(s)"
}

[pscustomobject]@{
  Status = 'ph_skills_valid'
  CanonicalSkillCount = $canonicalSkills.Count
  AliasSkill = 'ph-youtube-transcript'
} | Format-List | Out-Host
