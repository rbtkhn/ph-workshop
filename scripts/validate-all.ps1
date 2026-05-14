param(
  [string]$StrategyRoot = "..\strategy-codex\codex\predictive-history",
  [string]$ReportsDir = "reports",
  [switch]$FailOnWarnings,
  [switch]$SkipStrategyChecks
)

$ErrorActionPreference = 'Stop'

function Invoke-Step {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][scriptblock]$Script
  )

  Write-Host "==> $Name"
  & $Script
}

function Get-Text {
  param([Parameter(Mandatory = $true)][string]$Path)
  return (Get-Content -LiteralPath $Path -Raw -Encoding utf8) -replace "`r`n", "`n"
}

function Resolve-RepoPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return Join-Path -Path (Get-Location) -ChildPath ($Path -replace '/', [IO.Path]::DirectorySeparatorChar)
}

function Add-Warning {
  param(
    [System.Collections.Generic.List[string]]$Warnings,
    [Parameter(Mandatory = $true)][string]$Message
  )
  $Warnings.Add($Message) | Out-Null
}

$warnings = New-Object System.Collections.Generic.List[string]

if (-not $SkipStrategyChecks) {
  Invoke-Step -Name 'Validate Civilization spine' -Script {
    & .\scripts\validate-civilization-spine.ps1 -StrategyRoot $StrategyRoot
  }
  Invoke-Step -Name 'Validate Great Books spine' -Script {
    & .\scripts\validate-great-books-spine.ps1 -StrategyRoot $StrategyRoot
  }
} else {
  Add-Warning -Warnings $warnings -Message 'Skipped strategy-codex spine validation'
}

Invoke-Step -Name 'Validate PH-CIV' -Script {
  & .\scripts\validate-ph-civ.ps1
}

Invoke-Step -Name 'Validate orientation payloads' -Script {
  & .\scripts\validate-orientation.ps1
}

Invoke-Step -Name 'Generate Civilization spine health report' -Script {
  & .\scripts\audit-civilization-spine.ps1 -ReportsDir $ReportsDir
}

Invoke-Step -Name 'Generate PH-CIV health report' -Script {
  & .\scripts\audit-ph-civ.ps1 -ReportsDir $ReportsDir
}

Invoke-Step -Name 'Generate high-risk review queue' -Script {
  & .\scripts\audit-review-queue.ps1 -ReportsDir $ReportsDir
}

Invoke-Step -Name 'Scan public surfaces for internal terminology' -Script {
  $publicPaths = @(
    'README.md',
    'llms.txt',
    'CHANGELOG.md',
    'chapter-manifest.yaml',
    'corpus/README.md',
    'corpus/ph-civ',
    'corpus/great-books',
    'book/README.md',
    'book/volume-ii/README.md',
    'book/volume-v/README.md',
    'docs/chapter-index.md',
    'docs/repo-map.md',
    'docs/series-roadmap.md',
    'docs/source-status.md',
    'docs/export-from-strategy-codex.md'
  )

  foreach ($path in $publicPaths) {
    $resolved = Resolve-RepoPath -Path $path
    if (-not (Test-Path -LiteralPath $resolved)) {
      continue
    }

    $files = if (Test-Path -LiteralPath $resolved -PathType Container) {
      Get-ChildItem -LiteralPath $resolved -File -Recurse -Include '*.md', '*.yaml'
    } else {
      Get-Item -LiteralPath $resolved
    }

    foreach ($file in $files) {
      $relative = $file.FullName.Substring((Get-Location).Path.Length + 1)
      if ($relative -in @('docs\civ-mem.md', 'docs\internal-audit-substrate.md')) {
        continue
      }
      if ($file.Name -like '*civmem.yaml') {
        continue
      }
      $text = Get-Text -Path $file.FullName
      if ($text -match '(?i)civ[-_ ]?mem') {
        throw "Public surface file $($file.FullName) contains internal scaffold terminology"
      }
    }
  }
}

Invoke-Step -Name 'Scan stale placeholders' -Script {
  $scanRoots = @('book/volume-ii', 'book/volume-v', 'corpus/civilization', 'corpus/great-books', 'corpus/ph-civ', 'README.md', 'llms.txt', 'docs')
  $allowed = @(
    'book\volume-ii\civ-XX-commentary.md',
    'corpus\ph-civ\README.md',
    'docs\internal-audit-substrate.md',
    'docs\proposed-media-policy-plan.md',
    'docs\series-roadmap.md',
    'docs\repo-map.md'
  )

  foreach ($root in $scanRoots) {
    $resolved = Resolve-RepoPath -Path $root
    if (-not (Test-Path -LiteralPath $resolved)) {
      continue
    }

    $files = if (Test-Path -LiteralPath $resolved -PathType Container) {
      Get-ChildItem -LiteralPath $resolved -File -Recurse -Include '*.md', '*.yaml', '*.ps1'
    } else {
      Get-Item -LiteralPath $resolved
    }

    foreach ($file in $files) {
      $relative = $file.FullName.Substring((Get-Location).Path.Length + 1)
      if ($relative -in $allowed -or $file.Name -like '*-transcript.md') {
        continue
      }

      $text = Get-Text -Path $file.FullName
      if ($text -match '(?i)\b(TBD|TODO|draft_pending_analysis|placeholder)\b') {
        Add-Warning -Warnings $warnings -Message "Stale placeholder-like language in $relative"
      }
    }
  }
}

Invoke-Step -Name 'Check whitespace' -Script {
  & git diff --check
  if ($LASTEXITCODE -ne 0) {
    throw 'git diff --check failed'
  }
}

$reportWarnings = 0
foreach ($jsonName in @('civilization-spine-health.json', 'ph-civ-health.json')) {
  $path = Resolve-RepoPath -Path (Join-Path $ReportsDir $jsonName)
  if (Test-Path -LiteralPath $path -PathType Leaf) {
    $json = Get-Content -LiteralPath $path -Raw -Encoding utf8 | ConvertFrom-Json
    if ($json.warning_count -ne $null) {
      $reportWarnings += [int]$json.warning_count
    }
  }
}

$queuePath = Resolve-RepoPath -Path (Join-Path $ReportsDir 'high-risk-review-queue.json')
if (Test-Path -LiteralPath $queuePath -PathType Leaf) {
  $queueJson = Get-Content -LiteralPath $queuePath -Raw -Encoding utf8 | ConvertFrom-Json
  if ($queueJson.queue_count -ne $null) {
    $reportWarnings += [int]$queueJson.queue_count
  }
}

$warningCount = $warnings.Count + $reportWarnings
if ($FailOnWarnings -and $warningCount -gt 0) {
  throw "validate-all completed with $warningCount warnings and -FailOnWarnings was set"
}

$status = 'valid_with_warnings'
if ([int]$warningCount -eq 0) {
  $status = 'valid'
}

[pscustomobject]@{
  ReportsDir = $ReportsDir
  WarningCount = $warningCount
  FailOnWarnings = [bool]$FailOnWarnings
  Status = $status
} | Format-List | Out-Host
