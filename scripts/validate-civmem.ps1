param(
  [Parameter(Mandatory = $true)]
  [string]$DoctrinePath,

  [Parameter(Mandatory = $true)]
  [string]$PayloadPath,

  [Parameter(Mandatory = $true)]
  [string]$CommentaryPath
)

# Deprecated legacy validator. New civ-ph orientation payload work should use
# scripts/validate-orientation.ps1, which validates neutral *-orientation.yaml
# payloads against civ-ph entries and manifest routing.

$ErrorActionPreference = 'Stop'

function Get-Text {
  param([Parameter(Mandatory = $true)][string]$Path)
  return (Get-Content -LiteralPath $Path -Raw -Encoding utf8) -replace "`r`n", "`n"
}

function Parse-CivMemPayload {
  param([Parameter(Mandatory = $true)][string]$Text)

  $data = [ordered]@{}
  $currentKey = $null

  foreach ($line in ($Text -split "`n")) {
    if ($line -match '^\s*$' -or $line -match '^\s*#') {
      continue
    }

    if ($line -match '^([A-Za-z_]+):\s*(.*)$') {
      $currentKey = $matches[1]
      $value = $matches[2].Trim()

      if ($value -eq '') {
        $data[$currentKey] = @()
      } else {
        $data[$currentKey] = $value.Trim('"')
        $currentKey = $null
      }

      continue
    }

    if ($currentKey -and $line -match '^\s*-\s*(.*)$') {
      if (-not $data.Contains($currentKey)) {
        $data[$currentKey] = @()
      }

      $data[$currentKey] += $matches[1].Trim().Trim('"')
      continue
    }

    throw "Unrecognized payload line in ${PayloadPath}: $line"
  }

  return $data
}

function Get-SectionText {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Heading
  )

  $pattern = "(?ms)^##\s+$([regex]::Escape($Heading))\s*\n(.*?)(?=^##\s+|\z)"
  $match = [regex]::Match($Text, $pattern)
  if (-not $match.Success) {
    return $null
  }

  return $match.Groups[1].Value
}

$doctrineText = Get-Text -Path $DoctrinePath
if ($doctrineText -notmatch 'active_voice_profile:\s*house-default') {
  throw "Doctrine file $DoctrinePath must declare active_voice_profile: house-default"
}

$payloadText = Get-Text -Path $PayloadPath
$payload = Parse-CivMemPayload -Text $payloadText

foreach ($requiredKey in @('primary_object', 'historical_arc', 'dominant_slots', 'reader_orientation', 'fit_strength')) {
  if (-not $payload.Contains($requiredKey)) {
    throw "Payload file $PayloadPath is missing required key '$requiredKey'"
  }
}

$commentaryText = Get-Text -Path $CommentaryPath
if ($commentaryText -notmatch '(?m)^civ_mem_payload_path:\s*') {
  throw "Commentary file $CommentaryPath must declare civ_mem_payload_path in frontmatter"
}

if ($commentaryText -notmatch [regex]::Escape((Split-Path -Leaf $PayloadPath))) {
  throw "Commentary file $CommentaryPath must link to payload path $(Split-Path -Leaf $PayloadPath)"
}

$contextSection = Get-SectionText -Text $commentaryText -Heading 'CIV-MEM Context'
if (-not $contextSection) {
  throw "Commentary file $CommentaryPath is missing a CIV-MEM Context section"
}

if ($contextSection -notmatch 'Primary object|Historical arc|Dominant slots|Reader orientation|Fit strength') {
  throw "CIV-MEM Context in $CommentaryPath is missing one or more required labels"
}

if ($payload['primary_object'] -and $contextSection -notmatch [regex]::Escape($payload['primary_object'])) {
  throw "CIV-MEM Context in $CommentaryPath does not match primary_object from $PayloadPath"
}

if ($payload['historical_arc'] -and $contextSection -notmatch [regex]::Escape($payload['historical_arc'])) {
  throw "CIV-MEM Context in $CommentaryPath does not match historical_arc from $PayloadPath"
}

if ($payload['reader_orientation'] -and $contextSection -notmatch [regex]::Escape($payload['reader_orientation'])) {
  throw "CIV-MEM Context in $CommentaryPath does not match reader_orientation from $PayloadPath"
}

if ($payload['fit_strength'] -and $contextSection -notmatch [regex]::Escape($payload['fit_strength'])) {
  throw "CIV-MEM Context in $CommentaryPath does not match fit_strength from $PayloadPath"
}

foreach ($slot in @($payload['dominant_slots'])) {
  if ($slot -and $contextSection -notmatch [regex]::Escape($slot)) {
    throw "CIV-MEM Context in $CommentaryPath is missing dominant slot '$slot' from $PayloadPath"
  }
}

if ($payload.Contains('mismatch_limit_note')) {
  $note = $payload['mismatch_limit_note']
  if ($note -and $contextSection -notmatch [regex]::Escape($note)) {
    throw "CIV-MEM Context in $CommentaryPath does not include mismatch_limit_note from $PayloadPath"
  }
}

[pscustomobject]@{
  DoctrinePath = $DoctrinePath
  PayloadPath = $PayloadPath
  CommentaryPath = $CommentaryPath
  VoiceProfile = 'house-default'
  Status = 'civ-mem_context_match'
} | Format-List | Out-Host
