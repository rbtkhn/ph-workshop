$ErrorActionPreference = 'Stop'

# Compatibility wrapper. The canonical local-skill validator is now
# validate-ph-skills.ps1; this command remains for older workflows that
# validate transcript skill routing directly.
& (Join-Path $PSScriptRoot 'validate-ph-skills.ps1')
