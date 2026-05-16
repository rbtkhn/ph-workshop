# Annotation Block Template

Use this template for future public corpus items. V1 includes the template only; real items come later through manual pilot review.

## Surface Vocabulary

- **Source item**: the underlying Jiang video, essay, interview, or other source.
- **Source transcript**: the source-text or transcript record for the source item when available.
- **Commentary**: the main study surface for thesis, claims, concepts, predictions, counter-readings, routes, limits, and correction paths.
- **civ-ph placement card**: the compact civilizational orientation and re-entry page.

Use **Part One** and **Part Two** only for the whole corpus architecture, not for individual source surfaces.

```yaml
---
source_id: geo-01
public_slug: geo-01-example-title
title: ""
series: geo-strategy
episode: 1
source_type: video
canonical_url: ""
publication_date: YYYY-MM-DD
source_status: linked_only
transcript_status: not_imported
annotation_status: not_started
review_status: unreviewed
source_reviewed_at: null
exported_from_strategy_codex_at: null
rights_review: required_before_long_excerpt
representation_not_endorsement: true
transcript_fidelity: exact_body_match
---
```

## Required Sections

```md
# [source_id] Title

## Source

- Original source:
- Publication date:
- Series / episode:
- Public source ID:
- Transcript status:
- Transcript fidelity:
- Annotation status:
- Review status:

## Study Summary

Short plain-language summary of what the item is about.

## Core Thesis

One to three bullets describing the central claim or teaching movement.

## Key Claims

- Claim:
  - Source anchor:
  - Timestamp:
  - Status:

## Concepts

- Concept:
  - Working definition:
  - Related sources:

## Predictions / Falsifiers

Use only when the item contains forecast-like claims.

- Prediction:
  - Source anchor:
  - Time horizon:
  - Falsifier or resolution condition:
  - Status:

## Counter-Reading Pointer

Optional. Link to a separate counter-reading or disagreement note when useful.

## Notes

Clearly label open uncertainties, transcript limitations, or interpretation risks.
```

## Commentary Standard

Commentaries are the primary link-worthy study pages. A mature commentary should include:

- quick thesis
- source transcript status
- review status and rights limits
- core claims
- key concepts
- predictions / falsifiers
- counter-readings
- `civ-ph` placement link
- related routes
- correction path

## Style

- Prefer compact, student-useful annotations.
- Quote only when needed and with timestamps or source anchors.
- Keep summary and interpretation separate.
- Use clear uncertainty labels rather than hiding weak confidence.
