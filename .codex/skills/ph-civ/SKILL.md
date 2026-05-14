---
name: ph-civ
description: Use for maintaining corpus/ph-civ placement entries, orientation payload alignment, limits sections, return paths, review status, and calibrated versus in-review distinctions without overclaiming.
---

# PH-CIV

Use this skill for the public PH-CIV orientation corpus under `corpus/ph-civ/`.

## Operating Rules

- Keep PH-CIV orientation-first: where the unit sits, how to read it, pressure points, limits, and return path.
- Keep `corpus/ph-civ/` distinct from commentary, transcript, and source annotation surfaces.
- Preserve `placement_weight`, `review_status`, `source_id`, `source_chapter_path`, `commentary_path`, and `source_corpus_path` discipline.
- Align orientation payloads with public PH-CIV entries when `orientation_payload_path` exists.
- Do not overclaim calibrated status. Calibrated, in-review, and draft states must remain visible and accurate.
- Always include limits language; weak or speculative frames should be narrower and less rhetorical.

## Validation

Run `scripts/validate-ph-civ.ps1`, `scripts/validate-orientation.ps1`, and `scripts/validate-all.ps1`. For health snapshots, run `scripts/audit-ph-civ.ps1`.
