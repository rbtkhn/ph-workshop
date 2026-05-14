param(
  [string]$ManifestPath = "chapter-manifest.yaml",
  [string]$StrategyRoot = "..\strategy-codex\codex\predictive-history",
  [string[]]$ExpectedIds = @(
    'gt-01', 'gt-02', 'gt-03', 'gt-04', 'gt-05',
    'gt-06', 'gt-07', 'gt-08', 'gt-09', 'gt-10',
    'gt-11', 'gt-12', 'gt-13', 'gt-14', 'gt-15',
    'gt-16', 'gt-17', 'gt-18', 'gt-19', 'gt-20',
    'gt-21', 'gt-22'
  )
)

$ErrorActionPreference = 'Stop'

& .\scripts\validate-world-war-series.ps1 `
  -Series 'game-theory' `
  -ExpectedIds $ExpectedIds `
  -ManifestPath $ManifestPath `
  -StrategyRoot $StrategyRoot
