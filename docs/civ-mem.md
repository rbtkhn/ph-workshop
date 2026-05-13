---
active_voice_profile: house-default
payload_home: chapter-local YAML sidecar
render_surface: commentary only
calibration_units:
  - civ-01
  - geo-12
low_fit_rule: always present, shorter, and honest
---

# CIV-MEM Doctrine

CIV-MEM is a historical-civilizational contextualization layer for lecture and chapter reading.
It is an overlay, not a second corpus.

## Contract

- **Payload** lives in a chapter-local YAML sidecar.
- **Rendering** lives in the chapter commentary surface as `## CIV-MEM Context`.
- **Voice** is rendering-only and is currently fixed to `house-default`.

## Payload Fields

Each CIV-MEM payload should carry:

- `primary_object`
- `historical_arc`
- `dominant_slots`
- `reader_orientation`
- `fit_strength`
- optional `mismatch_limit_note`

## Rendering Rules

- Render a substantial but compact `## CIV-MEM Context` block near the top of the commentary.
- Keep the rendered block derived from the payload, not independently authored.
- Keep `At a glance` and `CIV-MEM Context` distinct: the first is topic/argument, the second is civilizational placement and reading posture.

## Voice

`house-default` is the only active CIV-MEM voice profile.

- base tone: historical cartographer
- secondary tone: civilizational guide
- occasional intensifier: prophetic-historical
- open with placement, not drama
- prefer "where this sits" over "what this proves"
- keep weak-fit cases short, honest, and useful

## Calibration Set

The first calibration set is:

- `civ-01` as the strong-fit Civilization pilot
- `geo-12` as the first contrast unit

