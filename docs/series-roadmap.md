# Series Roadmap

This roadmap shows the current series-level shape of the repository. Use [chapter-index.md](chapter-index.md) for chapter inventory, [chapter-manifest.yaml](../chapter-manifest.yaml) for routing, and [llms.txt](../llms.txt) for the AI-facing entry path.

## Current State

| Series | Status | Notes |
| --- | --- | --- |
| Geo-Strategy | Complete through `geo-12` | First public batch; all twelve chapter pairs are present and fidelity-verified. |
| Civilization | First sixty-chapter spine present | Volume II commentary template is present in `book/volume-ii/`; `civ-01` is the calibrated pilot, and `civ-02` through `civ-60` are in review after initial commentary analysis. |
| PH-CIV | Seed plus spine placements present | Calibrated placements exist for `civ-01`, `geo-05`, `geo-07`, and `geo-12`; `civ-02` through `civ-60` are in review. |
| Cross-Volume Corridors | First corridor present | `corpus/cross-volume/homer-to-dante.md` links routed Civilization and Great Books chapters through typed edges in `registries/cross-volume-links.yaml`. |
| Secret History | Pending | Planned future series; no public chapter batch yet. |
| Game Theory | Pending | Planned future series; no public chapter batch yet. |
| Great Books | First nine-chapter spine present | Volume V lives in `book/volume-v/`; `gb-01` through `gb-09` are in review after initial transfer-backed commentary analysis. |
| Interviews | Pending | Planned future series; no public chapter batch yet. |
| Essays | Pending | Planned future series; no public chapter batch yet. |

## Suggested Order

The repository has already proven the Geo-Strategy pipeline. A sensible next order is:

1. Civilization
2. Great Books
3. Secret History
4. Game Theory
5. Interviews
6. Essays

This order is only a planning guide. The actual publication sequence can change if a different series is better prepared or more useful for review.

## Planning Notes

- Keep the series roadmap high-level.
- Treat Civilization as a completed first spine, with `civ-02` through `civ-60` in review.
- Treat Great Books as the active Volume V literary spine, with `gb-01` through `gb-09` in review.
- Treat PH-CIV as a derived study corpus, not a replacement for source transcripts, annotations, or commentary.
- Treat cross-volume corridors as guided study routes, not causal proofs or replacements for chapter-level commentary.
- Do not reserve placeholder chapter files or manifest rows for future Civilization chapters until the batch is actually created.
- Media policy draft for future chapters: [docs/proposed-media-policy-plan.md](proposed-media-policy-plan.md).
- Keep chapter routing in `chapter-manifest.yaml`.
- Keep the readable chapter inventory in `chapter-index.md`.
- Keep the public front door in `README.md`.
- Keep the machine front door in `llms.txt`.
