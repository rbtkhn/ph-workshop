Write-Warning "validate-ph-civ.ps1 is deprecated; use validate-civ-ph.ps1."
& (Join-Path $PSScriptRoot 'validate-civ-ph.ps1') @args
