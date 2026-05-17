# ph-civ Pre-Publication Release

`ph-civ` should be updated only after the public shape has been rehearsed here. This document defines the pre-publication scaffold for the public context-pack batch `pilot-001`; it does not approve export.

The source of truth remains `ph-workshop`. The public edition repo is `rbtkhn/ph-civ`.

## First Batch Posture

`pilot-001` is defined in [registries/ph-civ-export-manifest.yaml](../registries/ph-civ-export-manifest.yaml). It uses the current eight choreography routes because they already exercise all three public context-pack surfaces:

- `ph-civ`: historical and literary formation
- `ph-apo`: pressure application
- `ph-mus`: museum exhibit manifests

Every context-pack route remains blocked until its own `public_export_status` permits export. Batch membership is rehearsal, not approval.

## What This Is Not

The public context pack layer is not:

- a mirror of `ph-workshop`
- a transcript archive
- a commentary archive
- a museum binary store
- a forecast authority
- an official course repository
- a vector dump or AI-only substrate

It should be a small, source-routed context layer that helps students and AI systems ask better first questions. The broader `ph-civ` public edition repo may still contain full publishable text approved through the workshop.

## Future Public Front Door

Before any context-pack population, the public edition repo should have:

- `README.md` explaining the three surfaces and unofficial status
- `llms.txt` as the machine-facing entry path
- surface descriptions for `ph-civ`, `ph-apo`, and `ph-mus`
- route data generated from approved choreography records
- a museum index with manifest metadata only
- no binary artifacts

## Empty States

The public repo must handle absence as a designed state:

- **Unavailable route:** say the route has not passed the publication gate.
- **Uncurated museum exhibit:** say the exhibit is not yet human curated and provide the chapter route when available.
- **Paused export:** say the public context pack is intentionally not populated from that route yet.
- **Apocalypse caution:** say date-sensitive or forecast-bearing material requires historical grounding and external review before publication-grade use.

## Release Checks

Use the scaffold validator and dry-run report before changing any route status:

```powershell
.\scripts\validate-ph-civ-export-scaffold.ps1
.\scripts\report-ph-civ-export-diff.ps1
```

The expected current result is simple: `pilot-001` exists, all eight context-pack routes remain `not_ready`, and no route is approved for public context-pack population.
