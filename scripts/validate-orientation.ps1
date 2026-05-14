param(
  [string]$ManifestPath = "chapter-manifest.yaml",
  [string]$CorpusPath = "corpus/ph-civ",
  [string[]]$CalibrationIds = @()
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

function Parse-OrientationPayload {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$PayloadPath
  )

  $data = [ordered]@{}
  $currentKey = $null
  $blockKey = $null
  $blockLines = New-Object System.Collections.Generic.List[string]

  $flushBlockScalar = {
    if ($blockKey) {
      $data[$blockKey] = (($blockLines | ForEach-Object { $_ }) -join "`n").Trim()
      $blockKey = $null
      $blockLines.Clear()
    }
  }

  foreach ($line in ($Text -split "`n")) {
    if ($blockKey -and $line -match '^\s+(.*)$') {
      $blockLines.Add($matches[1]) | Out-Null
      continue
    }

    . $flushBlockScalar

    if ($line -match '^\s*$' -or $line -match '^\s*#') {
      continue
    }

    if ($line -match '^([A-Za-z_]+):\s*(.*)$') {
      $currentKey = $matches[1]
      $value = $matches[2].Trim()

      if ($value -eq '|') {
        $blockKey = $currentKey
        $currentKey = $null
        continue
      }

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

    throw "Unrecognized orientation payload line in ${PayloadPath}: $line"
  }

  . $flushBlockScalar

  return $data
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

  return $match.Groups[1].Value.Trim()
}

function Get-ManifestBlock {
  param(
    [Parameter(Mandatory = $true)][string]$ManifestText,
    [Parameter(Mandatory = $true)][string]$SourceId
  )

  $pattern = "(?ms)^\s+- chapter_id:\s*$([regex]::Escape($SourceId))\s*\n(.*?)(?=^\s+- chapter_id:|\z)"
  $match = [regex]::Match($ManifestText, $pattern)
  if (-not $match.Success) {
    throw "Missing manifest row for calibrated orientation unit: $SourceId"
  }
  return $match.Groups[0].Value
}

function Get-ManifestField {
  param(
    [Parameter(Mandatory = $true)][string]$Block,
    [Parameter(Mandatory = $true)][string]$Field,
    [Parameter(Mandatory = $true)][string]$SourceId
  )

  $match = [regex]::Match($Block, "(?m)^\s+$([regex]::Escape($Field)):\s*(\S+)\s*$")
  if (-not $match.Success) {
    throw "Manifest row $SourceId is missing $Field"
  }

  return $match.Groups[1].Value.Trim('"')
}

function Assert-ContainsText {
  param(
    [Parameter(Mandatory = $true)][string]$Haystack,
    [Parameter(Mandatory = $true)][string]$Needle,
    [Parameter(Mandatory = $true)][string]$Context
  )

  if ($Haystack -notmatch [regex]::Escape($Needle)) {
    throw "$Context does not contain expected orientation payload text: $Needle"
  }
}

$resolvedManifestPath = Resolve-RepoPath -Path $ManifestPath
if (-not (Test-Path -LiteralPath $resolvedManifestPath -PathType Leaf)) {
  throw "Manifest path does not exist: $ManifestPath"
}

$resolvedCorpusPath = Resolve-RepoPath -Path $CorpusPath
if (-not (Test-Path -LiteralPath $resolvedCorpusPath -PathType Container)) {
  throw "PH-CIV corpus path does not exist: $CorpusPath"
}

$requiredPayloadFields = @(
  'source_id',
  'placement_weight',
  'where_this_sits',
  'reading_posture',
  'historical_pressure_points',
  'limits_of_the_frame',
  'return_path'
)

$requiredSections = @(
  'Where This Sits',
  'Reading Posture',
  'Historical Pressure Points',
  'Limits of the Frame',
  'Return Path'
)

$manifestText = Get-Text -Path $resolvedManifestPath
if ($CalibrationIds.Count -eq 0) {
  $CalibrationIds = @(
    [regex]::Matches($manifestText, "(?ms)^\s+- chapter_id:\s*(\S+)\s*\n(.*?)(?=^\s+- chapter_id:|\z)") |
      Where-Object { $_.Groups[2].Value -match '(?m)^\s+orientation_payload_path:\s*\S+' -and $_.Groups[2].Value -match '(?m)^\s+ph_civ_path:\s*\S+' } |
      ForEach-Object { $_.Groups[1].Value }
  )
}
$validated = 0

foreach ($sourceId in $CalibrationIds) {
  $block = Get-ManifestBlock -ManifestText $manifestText -SourceId $sourceId
  $payloadPath = Get-ManifestField -Block $block -Field 'orientation_payload_path' -SourceId $sourceId
  $phCivPath = Get-ManifestField -Block $block -Field 'ph_civ_path' -SourceId $sourceId

  if ($payloadPath -match '(?i)civ[-_ ]?mem') {
    throw "Manifest row $sourceId must use a neutral orientation payload path, found: $payloadPath"
  }

  $resolvedPayloadPath = Resolve-RepoPath -Path $payloadPath
  if (-not (Test-Path -LiteralPath $resolvedPayloadPath -PathType Leaf)) {
    throw "Manifest row $sourceId points orientation_payload_path to missing file: $payloadPath"
  }

  $payload = Parse-OrientationPayload -Text (Get-Text -Path $resolvedPayloadPath) -PayloadPath $payloadPath
  foreach ($field in $requiredPayloadFields) {
    if (-not $payload.Contains($field)) {
      throw "Orientation payload $payloadPath is missing required field '$field'"
    }
  }

  if ($payload['source_id'] -ne $sourceId) {
    throw "Orientation payload $payloadPath has source_id '$($payload['source_id'])', expected '$sourceId'"
  }

  if ($payload['placement_weight'] -notin @('strong', 'medium', 'light')) {
    throw "Orientation payload $payloadPath has invalid placement_weight '$($payload['placement_weight'])'"
  }

  $resolvedPhCivPath = Resolve-RepoPath -Path $phCivPath
  if (-not (Test-Path -LiteralPath $resolvedPhCivPath -PathType Leaf)) {
    throw "Manifest row $sourceId points ph_civ_path to missing file: $phCivPath"
  }

  $phCivText = Get-Text -Path $resolvedPhCivPath
  $frontmatter = Get-Frontmatter -Text $phCivText
  if (-not $frontmatter) {
    throw "PH-CIV entry $phCivPath is missing frontmatter"
  }

  if ((Get-FrontmatterValue -Frontmatter $frontmatter -Key 'source_id') -ne $sourceId) {
    throw "PH-CIV entry $phCivPath has mismatched source_id"
  }

  $phCivWeight = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'placement_weight'
  if ($phCivWeight -ne $payload['placement_weight']) {
    throw "PH-CIV entry $phCivPath placement_weight '$phCivWeight' does not match orientation payload '$($payload['placement_weight'])'"
  }

  foreach ($section in $requiredSections) {
    if (-not (Get-SectionText -Text $phCivText -Heading $section)) {
      throw "PH-CIV entry $phCivPath is missing required section '$section'"
    }
  }

  Assert-ContainsText -Haystack (Get-SectionText -Text $phCivText -Heading 'Where This Sits') -Needle $payload['where_this_sits'] -Context "$phCivPath Where This Sits"
  Assert-ContainsText -Haystack (Get-SectionText -Text $phCivText -Heading 'Reading Posture') -Needle $payload['reading_posture'] -Context "$phCivPath Reading Posture"
  Assert-ContainsText -Haystack (Get-SectionText -Text $phCivText -Heading 'Limits of the Frame') -Needle $payload['limits_of_the_frame'] -Context "$phCivPath Limits of the Frame"
  Assert-ContainsText -Haystack (Get-SectionText -Text $phCivText -Heading 'Return Path') -Needle $payload['return_path'] -Context "$phCivPath Return Path"

  $pressureSection = Get-SectionText -Text $phCivText -Heading 'Historical Pressure Points'
  foreach ($pressurePoint in @($payload['historical_pressure_points'])) {
    Assert-ContainsText -Haystack $pressureSection -Needle $pressurePoint -Context "$phCivPath Historical Pressure Points"
  }

  $validated += 1
}

[pscustomobject]@{
  ManifestPath = $ManifestPath
  CorpusPath = $CorpusPath
  CalibratedUnits = ($CalibrationIds -join ', ')
  PayloadCount = $validated
  Status = 'orientation_payloads_valid'
} | Format-List | Out-Host
