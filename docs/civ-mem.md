---
active_voice_profile: house-default
payload_home: chapter-local neutral orientation YAML sidecar
render_surface: ph-civ derived corpus
calibration_units:
  - civ-01
  - geo-05
  - geo-07
  - geo-12
low_fit_rule: always present, shorter, and honest
---

# CIV-MEM Doctrine

CIV-MEM is a historical-civilizational contextualization layer for lecture and chapter reading.
It is an internal derivation scaffold, not the public reader-facing corpus.

## Contract

- **Active payload authority** lives in a chapter-local neutral YAML sidecar named `*-orientation.yaml`.
- **Public rendering authority** lives in the PH-CIV derived corpus under `corpus/ph-civ/`.
- **Voice authority** lives in this doctrine file; rendering is currently fixed to `house-default`.

The current repository does not yet have a separate evidence/media pack object beyond the chapter-local source files, corpus pointer, and commentary pair. The neutral orientation sidecar is therefore the lightest existing pack-owned authority surface for the internal payload. It must remain structured and reusable; do not replace it with manually duplicated freeform prose.

## Active Payload Fields

Each active orientation payload should carry PH-CIV-section-shaped fields:

- `source_id`
- `placement_weight`
- `where_this_sits`
- `reading_posture`
- `historical_pressure_points`
- `limits_of_the_frame`
- `return_path`

## Derived Rendering Rules

- Render public placements in `corpus/ph-civ/`, not as a named top-of-chapter block.
- Keep the derived entry anchored in the neutral orientation payload, not independently authored.
- Keep source commentary and PH-CIV distinct: commentary is topic, claim, and evidence work; PH-CIV is civilizational placement and reading posture.
- Route calibrated payloads from `chapter-manifest.yaml` using `orientation_payload_path`.

## Voice

`house-default` is the only active CIV-MEM voice profile.

- base tone: historical cartographer
- secondary tone: civilizational guide
- occasional intensifier: prophetic-historical
- open with placement, not drama
- prefer "where this sits" over "what this proves"
- keep weak-fit cases short, honest, and useful

## Calibration Set

The first calibration set is deliberately mixed across fit and genre conditions:

- `civ-01` as the strong-fit Civilization pilot
- `geo-07` as a mediated uncertainty / current-event reasoning unit
- `geo-05` as a lower-fit electoral forecast unit
- `geo-12` as the medium-fit bridge into psychohistory and future modeling

The repository has not yet imported Interviews or Great Books as chapter pairs. When those series arrive, add one true interview-style unit and one true literary unit before broad CIV-MEM rollout.

## Legacy Payloads

Earlier calibration used `*-civmem.yaml` sidecars. Those files are deprecated historical scaffold material and should remain available temporarily for maintainers, but they are no longer the active routed payloads. New tooling should prefer `*-orientation.yaml` and `scripts/validate-orientation.ps1`.

## Cooler Rerender Check

The schema must survive voice modulation without payload redesign. A cooler rerender of an existing payload may reduce rhetoric and shorten the frame, but it should still preserve `source_id`, `placement_weight`, section intent, limits, and return path. This is a calibration check, not a second active voice profile.
