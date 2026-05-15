# civ-ph

civ-ph is a derived study corpus for Predictive History. It gives each routed chapter a compact civilizational placement, reading posture, and return path without replacing the source chapter, transcript, or commentary.

The first audience is Jiang students and serious listeners who want to know where a unit sits before reading it closely. civ-ph should help readers notice the larger historical pressures in play while keeping source discipline, uncertainty, and representation-not-endorsement intact.

## Entry Contract

Each entry uses the source ID as its filename, such as `geo-07.md`, so later tools can resolve entries directly.

Required frontmatter:

```yaml
source_id:
title:
source_series:
publication_date:
source_corpus_path:
source_chapter_path:
commentary_path:
derived_corpus: civ-ph
placement_weight: strong | medium | light
review_status: calibration_seed | in_review | draft_pending_analysis
```

Required sections:

- `Where This Sits`
- `Reading Posture`
- `Historical Pressure Points`
- `Limits of the Frame`
- `Return Path`

## What civ-ph Is / Is Not

civ-ph is:

- a derived placement corpus
- a reading posture and return-path aid
- a way to compare chapters by historical pressure, placement weight, and review status

civ-ph is not:

- a transcript or source substitute
- an endorsement of every represented claim
- a second commentary page
- a prediction registry

## Calibration

Placement weight controls rhetorical force.

- `strong` entries can carry a broad civilizational frame.
- `medium` entries should keep institutional and historical placement in view without overstating the unit.
- `light` entries should be narrow, useful, and explicit about limits.

Review status controls confidence.

- `calibration_seed` entries have been checked as part of the seed set.
- `in_review` entries have initial commentary analysis but still need final review.
- `draft_pending_analysis` entries are public routing aids, but their commentary analysis is not complete.

civ-ph entries should not become second commentaries. They should orient the reader, name the pressure points, and point back to the source chapter.

## Operating Pipeline

civ-ph work follows a compact pipeline:

```text
map -> orient -> constrain -> validate -> route
```

- `map`: identify eligible chapters and assign placement weight.
- `orient`: produce the reader-facing placement entry.
- `constrain`: keep rhetoric, uncertainty, and source discipline in bounds.
- `validate`: check schema, paths, public terminology, and routing.
- `route`: expose entries through the index, manifest, and future tools.

## Tool Readiness

civ-ph filenames intentionally match source IDs. This keeps the corpus ready for future commands such as `civ-ph orient geo-07`, `civ-ph index`, and `civ-ph validate` without changing the file layout.

## Current Entries

Use [index.md](index.md) for the current calibrated and draft entries.
