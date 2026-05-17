# Series Roadmap

This roadmap shows the current series-level shape of the repository. Use [chapter-index.md](chapter-index.md) for chapter inventory, [chapter-manifest.yaml](../chapter-manifest.yaml) for routing, and [llms.txt](../llms.txt) for the AI-facing entry path.

## Current State

| Series | Status | Notes |
| --- | --- | --- |
| Geo-Strategy | Complete through `geo-20` | Apocalypse application spine; all twenty source transcripts and commentaries are routed with civ-ph placement cards and orientation payloads. |
| Civilization | First sixty-chapter spine present | Volume II commentary template is present in `book/volume-ii/`; `civ-01` is the calibrated pilot, and `civ-02` through `civ-60` are in review after initial commentary analysis. |
| civ-ph | Cross-part orientation corpus present | civ-ph now routes Civilization and Apocalypse units with the same public placement-card shape while shifting emphasis from historical law to applied pressure in Part Two. |
| Cross-Volume Corridors | First literary and causation corridors present | `corpus/cross-volume/homer-to-dante.md` links routed Civilization and Great Books chapters; `corpus/cross-volume/homer-to-tolstoy.md` extends the literary author arc through Shakespeare, Dostoevsky, and a routed Tolstoy endpoint via `sh-16`; `corpus/cross-volume/tolstoy-question.md` asks how visible actors relate to deeper pressure systems. |
| Secret History | Complete through `sh-28` | Apocalypse spine by default; `sh-11`, `sh-16`, `sh-17`, and `sh-18` remain dual-role Civilization support nodes. |
| Game Theory | Complete through `gt-22` | Central Apocalypse application spine with exact transcripts, strategic commentary, civ-ph cards, and orientation payloads. |
| Great Books | First ten-chapter spine present | Volume V lives in `book/volume-v/`; `gb-01` through `gb-09` are in review after initial transfer-backed commentary analysis, and `gb-10` is in review after direct public-channel import. |
| Predictive History Museum | Calibration set present | Human-curated, agent-structured chapter exhibits live under `corpus/media-packs/`; the target end state is one exhibit per chapter across Predictive History: Civilization and Predictive History: Apocalypse. |
| ph public surfaces | Pre-publication scaffold present | `registries/ph-choreography.yaml` routes the first `ph-civ`, `ph-apo`, and `ph-mus` calibration batch, while [the publication gate](ph-civ-publication-gate.md) and [export manifest](../registries/ph-civ-export-manifest.yaml) keep `ph-civ` from being populated before routes are approved. |
| Interviews | Pending | Planned future series; no public chapter batch yet. |
| Essays | Pending | Planned future series; no public chapter batch yet. |

## Suggested Order

The repository now has both course semesters materialized at an in-review level. A sensible next order is:

1. Deepen Apocalypse high-risk review packets.
2. Add external-source bibliography for forecast-bearing claims.
3. Harden civ-ph cards that carry date-sensitive claims.
4. Define and pass the publication gate before populating `ph-civ`.
5. Interviews
6. Essays

This order is only a planning guide. The actual publication sequence can change if a different series is better prepared or more useful for review.

## Planning Notes

- Keep the series roadmap high-level.
- Treat Civilization as a completed first spine, with `civ-02` through `civ-60` in review.
- Use [book/parts/civilization-to-apocalypse.md](../book/parts/civilization-to-apocalypse.md) as the transition from law discovery into pressure reading.
- Treat Great Books as the active Volume V literary spine, with `gb-01` through `gb-10` in review.
- Treat civ-ph as a derived study corpus, not a replacement for source transcripts, annotations, or commentaries.
- Treat cross-volume corridors as guided study routes, not causal proofs or replacements for chapter-level commentary.
- Treat the Tolstoy question as a causation lens: it should prevent overpersonalized history without turning the corpus into deterministic theory.
- Treat Secret History as Apocalypse by default, with named dual-role support nodes for the Civilization literary spine.
- Do not reserve placeholder chapter files or manifest rows for future Civilization chapters until the batch is actually created.
- Predictive History Museum policy draft for future chapter exhibits: [docs/proposed-media-policy-plan.md](proposed-media-policy-plan.md).
- Keep chapter routing in `chapter-manifest.yaml`.
- Keep the readable chapter inventory in `chapter-index.md`.
- Keep the public front door in `README.md`.
- Keep the machine front door in `llms.txt`.
- Keep `ph-civ` population paused until `pilot-001` passes the export scaffold and publication gate.
