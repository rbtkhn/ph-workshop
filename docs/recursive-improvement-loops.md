# Recursive Improvement Loops

This internal doctrine makes the repo's quality-improvement loops explicit for maintainers and future agents.

The governing pattern is:

```text
validate -> audit -> queue -> deepen -> revalidate
```

These loops improve corpus quality without changing transcript fidelity or turning review warnings into hidden edits. They are maintainer infrastructure, not reader-facing doctrine and not a public `civ-ph` package feature.

## Loop Rules

- Validation finds broken structure, invalid schema, public terminology leakage, and fidelity failures.
- Audit reports summarize current health without rewriting source content.
- Queues identify the next human or agent review target.
- Deepening work happens only in the appropriate interpretive surface: commentary, civ-ph, orientation payloads, media packs, or routing docs.
- Revalidation closes the loop before changes are trusted.
- Transcript bodies remain fidelity-bearing and are not rewritten by guardrails.

## Structural Integrity Loop

- **Purpose:** keep routed chapter surfaces resolvable and schema-consistent.
- **Signal source:** spine validators, `chapter-manifest.yaml`, routed chapter files, and path checks.
- **Queue/report artifact:** `reports/civilization-spine-health.*`.
- **Allowed action:** repair manifest paths, missing routed files, invalid metadata, and validator failures.
- **Validation return path:** run the relevant spine validator, then `.\scripts\validate-all.ps1`.
- **Failure boundary:** broken paths, missing required files, invalid schema, or validator failure is a hard failure.

## Source Fidelity Loop

- **Purpose:** preserve exact transcript bodies and quote-grade boundaries.
- **Signal source:** transcript fidelity metadata, transfer-authority comparisons, transcript substrate checks, and ASR workflow docs.
- **Queue/report artifact:** spine health reports, transcript validators, and transcript audit notes where present.
- **Allowed action:** correct routing or metadata; repair curated transcripts only through explicit transcript-fidelity workflow.
- **Validation return path:** run transcript and spine validators against the transfer authority.
- **Failure boundary:** do not alter transcript bodies as a side effect of commentary, civ-ph, media-pack, or guardrail review.

## Interpretive Constraint Loop

- **Purpose:** keep high-risk interpretation bounded, source-statused, and reviewable.
- **Signal source:** high-risk heuristic flags, known-risk seeds, limits sections, and date-sensitive/current-event language.
- **Queue/report artifact:** `reports/high-risk-review-queue.*` and `reports/next-actions.*`.
- **Allowed action:** deepen limits, clarify counter-readings, mark uncertainty, and add external-review notes in commentary or civ-ph.
- **Validation return path:** regenerate the review queue and run `.\scripts\validate-all.ps1`.
- **Failure boundary:** review-depth warnings stay warnings; unsupported confidence, missing limits, or public terminology leakage must be corrected.

## Orientation Coherence Loop

- **Purpose:** keep civ-ph entries aligned with routed chapters, orientation payloads, placement weights, limits, and return paths.
- **Signal source:** civ-ph validator, orientation validator, manifest `civ_ph_path`, and entry frontmatter.
- **Queue/report artifact:** `reports/civ-ph-health.*`.
- **Allowed action:** update orientation payloads, civ-ph limits, placement weights, review status, and return paths.
- **Validation return path:** run `.\scripts\validate-civ-ph.ps1`, `.\scripts\validate-orientation.ps1`, then `.\scripts\validate-all.ps1`.
- **Failure boundary:** civ-ph must remain orientation, not transcript, source substitute, endorsement, or second commentary.

## Cross-Surface Routing Loop

- **Purpose:** keep cross-volume corridors, media packs, reports, registries, and export surfaces mutually navigable.
- **Signal source:** cross-volume validators, media-pack validators, report generation, and export-readiness checks.
- **Queue/report artifact:** cross-volume registry, media-pack corpus, improvement-loop report, and future export reports.
- **Allowed action:** repair typed edges, return paths, media-pack routing, report wiring, and source-safe export metadata.
- **Validation return path:** run cross-volume, media-pack, civ-ph, and full validation.
- **Failure boundary:** corridors and media packs orient study; they do not prove causal claims or override chapter-level source status.

## Maintainer Use

Use this doctrine when a repo change asks for review, hardening, expansion, or export readiness.

1. Run validation.
2. Read the generated reports.
3. Select the highest-priority queue item.
4. Deepen only the intended surface.
5. Re-run validation and regenerate reports.

The loop is complete only when the repo can explain both what changed and why the next maintainer should trust it.

## Weekly Review Sprint

Use the weekly review sprint when the repo has known interpretive-risk warnings and maintainers need a small, bounded next pass.

The sprint rhythm is:

```text
validate -> audit -> select sprint -> deepen selected items -> revalidate
```

`.\scripts\audit-review-sprint.ps1` selects the next five review targets from the high-risk review queue by default. Sprint work may deepen limits, clarify counter-readings, and add uncertainty or source-status notes in commentary or civ-ph. Sprint work must not edit transcript bodies.

The sprint is complete only after the review queue, improvement-loop report, sprint report, and full validation have been regenerated.
