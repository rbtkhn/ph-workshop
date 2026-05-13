# PH-CIV

PH-CIV is a derived study corpus for Predictive History. It gives each calibrated chapter a compact civilizational placement, reading posture, and return path without replacing the source chapter, transcript, or commentary.

The first audience is Jiang students and serious listeners who want to know where a unit sits before reading it closely. PH-CIV should help readers notice the larger historical pressures in play while keeping source discipline, uncertainty, and representation-not-endorsement intact.

## Entry Contract

Each entry uses the source ID as its filename, such as `geo-07.md`, so later tools can resolve entries directly.

Required frontmatter:

```yaml
source_id:
title:
source_series:
publication_date:
source_chapter_path:
commentary_path:
derived_corpus: ph-civ
placement_weight: strong | medium | light
review_status: calibration_seed
```

Required sections:

- `Where This Sits`
- `Reading Posture`
- `Historical Pressure Points`
- `Limits of the Frame`
- `Return Path`

## Calibration

Placement weight controls rhetorical force.

- `strong` entries can carry a broad civilizational frame.
- `medium` entries should keep institutional and historical placement in view without overstating the unit.
- `light` entries should be narrow, useful, and explicit about limits.

PH-CIV entries should not become second commentaries. They should orient the reader, name the pressure points, and point back to the source chapter.

## Seed Set

Use [index.md](index.md) for the current calibrated entries.
