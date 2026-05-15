---
name: civ-ph
description: Use for maintaining corpus/civ-ph placement entries, orientation payload alignment, limits sections, return paths, review status, and calibrated versus in-review distinctions without overclaiming.
---

# civ-ph

Use this skill for the public civ-ph orientation corpus under `corpus/civ-ph/`.

## Operating Rules

- Keep civ-ph orientation-first: where the unit sits, how to read it, pressure points, limits, and return path.
- Keep `corpus/civ-ph/` distinct from commentary, transcript, and source annotation surfaces.
- Preserve `placement_weight`, `review_status`, `source_id`, `source_chapter_path`, `commentary_path`, and `source_corpus_path` discipline.
- Align orientation payloads with public civ-ph entries when `orientation_payload_path` exists.
- Do not overclaim calibrated status. Calibrated, in-review, and draft states must remain visible and accurate.
- Always include limits language; weak or speculative frames should be narrower and less rhetorical.

## Validation

Run `scripts/validate-civ-ph.ps1`, `scripts/validate-orientation.ps1`, and `scripts/validate-all.ps1`. For health snapshots, run `scripts/audit-civ-ph.ps1`.
