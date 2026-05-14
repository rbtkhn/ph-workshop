param(
  [string]$ManifestPath = "chapter-manifest.yaml",
  [string]$StrategyRoot = "..\strategy-codex\codex\predictive-history",
  [string[]]$ExpectedIds = @(
    'geo-01', 'geo-02', 'geo-03', 'geo-04', 'geo-05',
    'geo-06', 'geo-07', 'geo-08', 'geo-09', 'geo-10',
    'geo-11', 'geo-12', 'geo-13', 'geo-14', 'geo-15',
    'geo-16', 'geo-17', 'geo-18', 'geo-19', 'geo-20'
  )
)

$ErrorActionPreference = 'Stop'

& .\scripts\validate-world-war-series.ps1 `
  -Series 'geo-strategy' `
  -ExpectedIds $ExpectedIds `
  -ManifestPath $ManifestPath `
  -StrategyRoot $StrategyRoot
