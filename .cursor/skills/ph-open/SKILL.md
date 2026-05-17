---
name: ph-open
description: Use at the start of a new Predictive History workshop chat to orient ph-civ population readiness, gate status, candidate routes, blockers, and no-export boundaries.
---

# PH Open

Use this skill as the fresh-chat bootstrap for `ph-workshop`, especially when the operator is preparing `ph-civ` population work.

## Operating Rules

- Start from `llms.txt`, then use `docs/ph-civ-publication-gate.md`, `docs/ph-civ-pre-publication-release.md`, `registries/ph-civ-export-manifest.yaml`, and `registries/ph-choreography.yaml` as the gate sources.
- If the operator says `coffee`, treat it as this opening workflow, not as a generic coffee greeting.
- State that `ph-civ` already exists as the public repository and public surface; this workshop only gates additional route-level population into it.
- Run `scripts/ph-civ-open.ps1` before proposing any `ph-civ` population work.
- Treat `candidate` routes as review-only. Candidate status does not permit export or population.
- Treat only `approved` and `exported` route statuses as population-eligible.
- Do not copy transcripts, commentary bodies, museum binaries, or workshop-private material into `ph-civ` during opening.
- Keep `ph-workshop` as the editorial authority and `ph-civ` as the public consumption layer.

## Optional Target Check

When a local `ph-civ` checkout is available, run `scripts/ph-civ-open.ps1 -PhCivPath <path>` to verify the target repo path, origin, and worktree status. This check is read-only and does not imply export permission.

## Validation

Run `scripts/validate-ph-skills.ps1`, `scripts/validate-ph-civ-export-scaffold.ps1`, `scripts/validate-ph-publication-gate.ps1`, `scripts/report-ph-civ-export-diff.ps1`, and `scripts/ph-civ-open.ps1`.
