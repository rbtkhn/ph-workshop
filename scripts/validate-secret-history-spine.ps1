param(
  [string]$ManifestPath = "chapter-manifest.yaml",
  [string]$StrategyRoot = "..\strategy-codex\codex\predictive-history",
  [string[]]$ExpectedIds = @(
    'sh-01', 'sh-02', 'sh-03', 'sh-04', 'sh-05',
    'sh-06', 'sh-07', 'sh-08', 'sh-09', 'sh-10',
    'sh-11', 'sh-12', 'sh-13', 'sh-14', 'sh-15',
    'sh-16', 'sh-17', 'sh-18', 'sh-19', 'sh-20',
    'sh-21', 'sh-22', 'sh-23', 'sh-24', 'sh-25',
    'sh-26', 'sh-27', 'sh-28'
  )
)

$ErrorActionPreference = 'Stop'

& .\scripts\validate-world-war-series.ps1 `
  -Series 'secret-history' `
  -ExpectedIds $ExpectedIds `
  -ManifestPath $ManifestPath `
  -StrategyRoot $StrategyRoot
