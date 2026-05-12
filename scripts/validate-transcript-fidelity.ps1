param(
  [Parameter(Mandatory = $true)]
  [string]$SourcePath,

  [Parameter(Mandatory = $true)]
  [string]$TargetPath,

  [string]$SourceMarker = '## Full transcript',

  [string]$TargetMarker = '## Part I: Full transcript'
)

$ErrorActionPreference = 'Stop'

function Get-BodyFromMarker {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$Marker
  )

  $text = Get-Content -LiteralPath $Path -Raw -Encoding utf8
  $normalized = $text -replace "`r`n", "`n"
  $markerIndex = $normalized.IndexOf($Marker, [System.StringComparison]::Ordinal)

  if ($markerIndex -lt 0) {
    throw "Marker '$Marker' not found in $Path"
  }

  $afterMarker = $markerIndex + $Marker.Length
  $bodyStart = $normalized.IndexOf("`n`n", $afterMarker, [System.StringComparison]::Ordinal)

  if ($bodyStart -lt 0) {
    throw "Could not find transcript body separator after '$Marker' in $Path"
  }

  $body = $normalized.Substring($bodyStart + 2)
  return ($body -replace "(?m)[ `t]+$", '').Trim()
}

function Normalize-Body {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Text
  )

  return (($Text -replace "`r`n", "`n" -replace "`r", "`n") -replace "(?m)[ `t]+$", '').Trim()
}

$sourceBody = Get-BodyFromMarker -Path $SourcePath -Marker $SourceMarker
$targetBody = Get-BodyFromMarker -Path $TargetPath -Marker $TargetMarker

$sourceExact = $sourceBody -ceq $targetBody
$sourceNormalized = Normalize-Body -Text $sourceBody
$targetNormalized = Normalize-Body -Text $targetBody
$normalizedExact = $sourceNormalized -ceq $targetNormalized

$status = if ($sourceExact) { 'exact_body_match' } elseif ($normalizedExact) { 'normalized_exact_match' } else { 'needs_fidelity_review' }

[pscustomobject]@{
  SourcePath = $SourcePath
  TargetPath = $TargetPath
  Status = $status
  ExactBodyMatch = $sourceExact
  NormalizedExactMatch = $normalizedExact
} | Format-List | Out-Host

if (-not $normalizedExact) {
  throw "Transcript fidelity check failed: '$SourcePath' does not match '$TargetPath'."
}
