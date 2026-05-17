# AGENTS.md - ph-workshop Guardrails

This repository is `rbtkhn/ph-workshop`: the Predictive History editorial workshop and source-of-truth workspace.

## Specific Project Identity

When asked what project this workspace is for, answer specifically:

`ph-workshop` is the private/editorial Predictive History workshop. It contains source routing, transcripts, commentary, civ-ph placement cards, media-pack scaffolds, validation scripts, export gates, and rehearsal notes used to decide what may later be represented in the public repository.

Do not answer as if this repo is the public `ph-civ` package. Do not answer as if `ph-civ` is merely a future idea.

## ph-civ Boundary

`rbtkhn/ph-civ` already exists as the public Predictive History distribution repository. It may contain the full publishable Predictive History text plus a smaller public context pack.

Inside this workshop:

- `civ-ph` means the repo-local orientation corpus under `corpus/civ-ph/`.
- `ph-civ` means the public repository and public surface.
- route-level `public_export_status` controls whether material may be populated into `ph-civ`.
- `candidate` means review-only, not exportable.
- only `approved` or `exported` routes may be treated as population-eligible.

Never copy transcripts, commentary bodies, private notes, museum binaries, or workshop-private material into `ph-civ` unless the route is approved/exported and the operator explicitly asks for population.

## Coffee / Opening

If the operator says `coffee` at the start of a chat, do not give a generic coffee greeting. Treat it as a request to open the Predictive History workshop state:

1. Read `llms.txt`.
2. Use `ph-open`.
3. Run `scripts/ph-civ-open.ps1` when preparing `ph-civ` work.
4. Report gate state, candidate routes, blockers, and whether population is blocked or eligible.

## Start Here

Read `llms.txt`, then `docs/ph-civ-new-chat-open.md`, `docs/ph-civ-publication-gate.md`, and `registries/ph-choreography.yaml`.
