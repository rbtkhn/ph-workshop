# Series Roadmap

This roadmap shows the current series-level shape of the repository. Use [chapter-index.md](chapter-index.md) for chapter inventory, [chapter-manifest.yaml](../chapter-manifest.yaml) for routing, and [llms.txt](../llms.txt) for the AI-facing entry path.

## Current State

| Series | Status | Notes |
| --- | --- | --- |
| Geo-Strategy | Complete through `geo-20` | World War application spine; all twenty chapter pairs are routed with PH-CIV entries and orientation payloads. |
| Civilization | First sixty-chapter spine present | Volume II commentary template is present in `book/volume-ii/`; `civ-01` is the calibrated pilot, and `civ-02` through `civ-60` are in review after initial commentary analysis. |
| PH-CIV | Cross-part orientation corpus present | PH-CIV now routes Civilization and World War units with the same public card shape while shifting emphasis from historical law to applied pressure in Part Two. |
| Cross-Volume Corridors | First literary corridors present | `corpus/cross-volume/homer-to-dante.md` links routed Civilization and Great Books chapters; `corpus/cross-volume/homer-to-tolstoy.md` extends the literary author arc through Shakespeare, Dostoevsky, and a routed Tolstoy endpoint via `sh-16`. |
| Secret History | Complete through `sh-28` | World War spine by default; `sh-11`, `sh-16`, `sh-17`, and `sh-18` remain dual-role Civilization support nodes. |
| Game Theory | Complete through `gt-22` | Central World War application spine with exact transcripts, strategic commentary, PH-CIV cards, and orientation payloads. |
| Great Books | First ten-chapter spine present | Volume V lives in `book/volume-v/`; `gb-01` through `gb-09` are in review after initial transfer-backed commentary analysis, and `gb-10` is in review after direct public-channel import. |
| Interviews | Pending | Planned future series; no public chapter batch yet. |
| Essays | Pending | Planned future series; no public chapter batch yet. |

## Suggested Order

The repository now has both course semesters materialized at an in-review level. A sensible next order is:

1. Deepen World War high-risk review packets.
2. Add external-source bibliography for forecast-bearing claims.
3. Harden PH-CIV cards that carry date-sensitive claims.
4. Prepare export packaging once source and rights boundaries are settled.
5. Interviews
6. Essays

This order is only a planning guide. The actual publication sequence can change if a different series is better prepared or more useful for review.

## Planning Notes

- Keep the series roadmap high-level.
- Treat Civilization as a completed first spine, with `civ-02` through `civ-60` in review.
- Treat Great Books as the active Volume V literary spine, with `gb-01` through `gb-10` in review.
- Treat PH-CIV as a derived study corpus, not a replacement for source transcripts, annotations, or commentary.
- Treat cross-volume corridors as guided study routes, not causal proofs or replacements for chapter-level commentary.
- Treat Secret History as World War by default, with named dual-role support nodes for the Civilization literary spine.
- Do not reserve placeholder chapter files or manifest rows for future Civilization chapters until the batch is actually created.
- Media policy draft for future chapters: [docs/proposed-media-policy-plan.md](proposed-media-policy-plan.md).
- Keep chapter routing in `chapter-manifest.yaml`.
- Keep the readable chapter inventory in `chapter-index.md`.
- Keep the public front door in `README.md`.
- Keep the machine front door in `llms.txt`.
