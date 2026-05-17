param(
  [string]$RegistryPath = "registries/ph-choreography.yaml",
  [string]$ClaimBoundaryPath = "registries/ph-claim-boundaries.yaml"
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

function Assert-TextMatches {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Pattern,
    [Parameter(Mandatory = $true)][string]$Context
  )

  if ($Text -notmatch $Pattern) {
    throw $Context
  }
}

function Get-YamlList {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Field
  )

  $lines = $Text -split "`n"
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^(?<indent>\s*)$([regex]::Escape($Field)):\s*$") {
      $baseIndent = $matches.indent.Length
      $items = New-Object System.Collections.Generic.List[string]
      for ($j = $i + 1; $j -lt $lines.Count; $j++) {
        $line = $lines[$j]
        if ($line.Trim().Length -eq 0) {
          continue
        }
        $indent = ([regex]::Match($line, '^\s*')).Value.Length
        if ($indent -le $baseIndent) {
          break
        }
        if ($line -match '^\s*-\s*(.+?)\s*$') {
          $items.Add($matches[1].Trim().Trim('"')) | Out-Null
        }
      }
      return $items.ToArray()
    }
  }
  return @()
}

$resolvedRegistry = Resolve-RepoPath -Path $RegistryPath
if (-not (Test-Path -LiteralPath $resolvedRegistry -PathType Leaf)) {
  throw "Publication gate registry path does not exist: $RegistryPath"
}

$registryText = Get-Text -Path $resolvedRegistry
$claimBoundaryText = Get-Text -Path (Assert-FileExists -Path $ClaimBoundaryPath -Context 'Claim boundary registry')
$allowedBoundaries = New-Object System.Collections.Generic.HashSet[string]
foreach ($match in [regex]::Matches($claimBoundaryText, '(?m)^\s+- tag:\s*(\S+)\s*$')) {
  $allowedBoundaries.Add($match.Groups[1].Value.Trim()) | Out-Null
}

$routes = [regex]::Matches($registryText, "(?ms)^\s+- source_id:\s*(\S+)\s*\n(.*?)(?=^\s+- source_id:|\z)")
if ($routes.Count -eq 0) {
  throw "No choreography routes found in $RegistryPath"
}

$allowedExportStatuses = @('not_ready', 'candidate', 'approved', 'exported')
$allowedMuseumStatuses = @('none', 'planned', 'curated_draft', 'human_curated', 'published')
$strictStatuses = @('approved', 'exported')
$warningCount = 0

foreach ($route in $routes) {
  $sourceId = $route.Groups[1].Value
  $block = $route.Groups[0].Value

  $surface = Get-RouteField -Block $block -Field 'surface'
  $museumStatus = Get-RouteField -Block $block -Field 'museum_status'
  $publicExportStatus = Get-RouteField -Block $block -Field 'public_export_status'
  $readinessNote = Get-RouteField -Block $block -Field 'readiness_note'
  $cardPath = Get-RouteField -Block $block -Field 'card_path'
  $transcriptPath = Get-RouteField -Block $block -Field 'transcript_path'
  $commentaryPath = Get-RouteField -Block $block -Field 'commentary_path'
  $museumExhibitPath = Get-RouteField -Block $block -Field 'museum_exhibit_path'
  $museumPayloadPath = Get-RouteField -Block $block -Field 'museum_payload_path'
  $claimBoundaries = Get-YamlList -Text $block -Field 'claim_boundaries'

  if (-not $publicExportStatus) {
    throw "Route $sourceId is missing public_export_status"
  }
  if ($publicExportStatus -notin $allowedExportStatuses) {
    throw "Route $sourceId has invalid public_export_status '$publicExportStatus'"
  }
  if ($museumStatus -and $museumStatus -notin $allowedMuseumStatuses) {
    throw "Route $sourceId has invalid museum_status '$museumStatus'"
  }
  if ($publicExportStatus -eq 'not_ready' -and -not $readinessNote) {
    Write-Warning "Route $sourceId is not_ready but has no readiness_note"
    $warningCount += 1
  }

  $needsApoCaution = $surface -eq 'ph-apo' -and $publicExportStatus -in @('candidate', 'approved', 'exported')
  $needsStrictGate = $publicExportStatus -in $strictStatuses

  if ($publicExportStatus -in @('candidate', 'approved', 'exported')) {
    if ($claimBoundaries.Count -eq 0) {
      throw "Route $sourceId with public_export_status $publicExportStatus must include claim_boundaries"
    }
    foreach ($boundary in $claimBoundaries) {
      if (-not $allowedBoundaries.Contains($boundary)) {
        throw "Route $sourceId has unknown claim boundary: $boundary"
      }
    }
  }

  if (-not $needsApoCaution -and -not $needsStrictGate) {
    continue
  }

  $cardText = ''
  $commentaryText = ''
  $museumExhibitText = ''
  $museumPayloadText = ''

  if ($cardPath) {
    $cardText = Get-Text -Path (Assert-FileExists -Path $cardPath -Context "Route $sourceId card_path")
  } elseif ($needsStrictGate) {
    throw "Route $sourceId with public_export_status $publicExportStatus must include card_path"
  }

  if ($transcriptPath) {
    Assert-FileExists -Path $transcriptPath -Context "Route $sourceId transcript_path" | Out-Null
  } elseif ($needsStrictGate) {
    throw "Route $sourceId with public_export_status $publicExportStatus must include transcript_path"
  }

  if ($commentaryPath) {
    $commentaryText = Get-Text -Path (Assert-FileExists -Path $commentaryPath -Context "Route $sourceId commentary_path")
  } elseif ($needsStrictGate) {
    throw "Route $sourceId with public_export_status $publicExportStatus must include commentary_path"
  }

  if ($needsApoCaution) {
    $cautionText = "$cardText`n$commentaryText"
    if ($museumExhibitPath) {
      $museumExhibitText = Get-Text -Path (Assert-FileExists -Path $museumExhibitPath -Context "Route $sourceId museum_exhibit_path")
      $cautionText = "$cautionText`n$museumExhibitText"
    }
    Assert-TextMatches -Text $cautionText -Pattern '(?i)date-sensitive|current-events|current events|forecast|external review|publication-grade' -Context "Route $sourceId ph-apo $publicExportStatus route must keep caution language visible"
  }

  if (-not $needsStrictGate) {
    continue
  }

  Assert-TextMatches -Text $cardText -Pattern '(?m)^##\s+Limits of the Frame\s*$' -Context "Route $sourceId approved/exported card is missing Limits of the Frame section"
  Assert-TextMatches -Text $cardText -Pattern '(?m)^##\s+Return Path\s*$' -Context "Route $sourceId approved/exported card is missing Return Path section"

  if (-not $museumStatus) {
    throw "Route $sourceId with public_export_status $publicExportStatus must include museum_status"
  }

  if ($museumStatus -ne 'none') {
    if (-not $museumExhibitPath -or -not $museumPayloadPath) {
      throw "Route $sourceId with public_export_status $publicExportStatus and museum_status $museumStatus must include museum_exhibit_path and museum_payload_path"
    }

    if (-not $museumExhibitText) {
      $museumExhibitText = Get-Text -Path (Assert-FileExists -Path $museumExhibitPath -Context "Route $sourceId museum_exhibit_path")
    }
    $museumPayloadText = Get-Text -Path (Assert-FileExists -Path $museumPayloadPath -Context "Route $sourceId museum_payload_path")

    Assert-TextMatches -Text $museumExhibitText -Pattern '(?m)^rights_mode:\s*.+' -Context "Route $sourceId museum exhibit is missing rights_mode"
    Assert-TextMatches -Text $museumExhibitText -Pattern '(?m)^##\s+Return Path\s*$' -Context "Route $sourceId museum exhibit is missing Return Path section"
    Assert-TextMatches -Text $museumPayloadText -Pattern '(?m)^rights_mode:\s*.+' -Context "Route $sourceId museum payload is missing rights_mode"
    Assert-TextMatches -Text $museumPayloadText -Pattern '(?m)^\s+rights_status:\s*.+' -Context "Route $sourceId museum payload is missing item rights_status"
    Assert-TextMatches -Text $museumPayloadText -Pattern '(?m)^\s+rights_note:\s*.+' -Context "Route $sourceId museum payload is missing item rights_note"

    foreach ($pathField in @('civ_ph_path', 'transcript_path', 'commentary_path')) {
      Assert-TextMatches -Text $museumPayloadText -Pattern "(?m)^\s+$([regex]::Escape($pathField)):\s*.+" -Context "Route $sourceId museum payload is missing return path $pathField"
    }
  }
}

$validateAllPath = Resolve-RepoPath -Path "scripts/validate-all.ps1"
if (-not (Test-Path -LiteralPath $validateAllPath -PathType Leaf)) {
  throw "Publication gate validator coverage cannot be confirmed because scripts/validate-all.ps1 is missing"
}
$validateAllText = Get-Text -Path $validateAllPath
if ($validateAllText -notmatch [regex]::Escape('validate-ph-publication-gate.ps1')) {
  throw "scripts/validate-all.ps1 must invoke scripts/validate-ph-publication-gate.ps1"
}

[pscustomobject]@{
  RegistryPath = $RegistryPath
  RouteCount = $routes.Count
  WarningCount = $warningCount
  Status = 'ph_publication_gate_valid'
} | Format-List | Out-Host
