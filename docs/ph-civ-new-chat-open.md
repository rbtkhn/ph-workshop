# ph-civ New Chat Opening

Use this opening when starting a new chat that may prepare `ph-civ` population from `ph-workshop`.

`ph-civ` already exists as `rbtkhn/ph-civ`, the public Predictive History distribution repository and public surface. This workshop controls whether additional route-level material may be populated there.

## Opening Sequence

1. Open `ph-workshop` as the editorial source repository.
2. Read `AGENTS.md` and `llms.txt`.
3. If the operator says `coffee`, treat it as this opening workflow and use `ph-open`.
4. Run `scripts/ph-civ-open.ps1`.
5. If a local `ph-civ` checkout is available, run `scripts/ph-civ-open.ps1 -PhCivPath <path>`.
6. Summarize the gate state before proposing work.

The opening command reports source commit, manifest state, route counts, candidate routes, approved/exported routes, validator status, and a copy-ready prompt for the next chat.

## Status Meaning

- `not_ready`: not eligible for public population.
- `candidate`: review rehearsal only; not eligible for export or population.
- `approved`: eligible for guarded public population when the operator explicitly asks.
- `exported`: already populated or represented in the public target.

Route-level `public_export_status` in `registries/ph-choreography.yaml` is the authority. Batch membership in `registries/ph-civ-export-manifest.yaml` does not approve export.

## Boundary

`ph-workshop` remains the editorial authority. `ph-civ` remains the public consumption layer.

During opening, do not copy transcripts, commentary bodies, museum binaries, workshop-private material, or candidate routes into `ph-civ`. If no route is `approved` or `exported`, the correct next action is blocker review, not population.

## Recommended New-Chat Prompt

```text
Open rbtkhn/ph-workshop as the editorial source for rbtkhn/ph-civ. Start with AGENTS.md and llms.txt, then run scripts/ph-civ-open.ps1 and summarize the gate state before proposing work. If the operator says coffee, treat it as this PH opening workflow, not as a generic greeting.

Boundary: ph-workshop is the editorial authority and ph-civ is the public consumption layer. Candidate routes are review-only. Do not copy transcripts, commentary bodies, museum binaries, workshop-private material, or any route into ph-civ unless route-level public_export_status is approved or exported and the operator explicitly asks for population.
```
