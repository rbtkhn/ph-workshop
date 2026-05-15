---
name: ph-chapter
description: Use for creating or updating exactly one Predictive History chapter pair: *-transcript.md plus *-commentary.md, wired through chapter-manifest.yaml, source metadata, review status, and transcript fidelity validation.
---

# PH Chapter

Use this skill when creating or updating one Predictive History chapter pair. Keep the scope to one unit unless the user explicitly requests a batch.

## Operating Rules

- Route the unit through `chapter-manifest.yaml` before treating it as canonical.
- Create or update the transcript file and commentary file as a pair: `*-transcript.md` plus `*-commentary.md`.
- Preserve transcript fidelity. Do not rewrite Part I transcript bodies to satisfy commentary guardrails.
- Use source metadata from the repo's canonical source surfaces and keep review status explicit.
- Mark draft, in-review, source-reviewed, and calibrated states honestly. Do not claim final scholarly review without evidence.
- Keep generated/cache transcript material separate from curated chapter text.

## Chapter Surfaces

Check the relevant volume folder under `book/`, the matching corpus entry, `chapter-manifest.yaml`, `docs/chapter-index.md`, and `docs/series-roadmap.md`. If the chapter has civ-ph or orientation payload routing, preserve those links rather than inventing a second route.

## Validation

Run the relevant spine validator for the chapter family, then run `scripts/validate-all.ps1`. For transcript imports or transfers, run `scripts/validate-transcript-fidelity.ps1` or the family validator that performs exact-body checks.
