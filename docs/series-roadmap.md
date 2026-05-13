# Series Roadmap

This roadmap shows the current series-level shape of the repository. Use [chapter-index.md](chapter-index.md) for chapter inventory, [chapter-manifest.yaml](../chapter-manifest.yaml) for routing, and [llms.txt](../llms.txt) for the AI-facing entry path.

## Current State

| Series | Status | Notes |
| --- | --- | --- |
| Geo-Strategy | Complete through `geo-12` | First public batch; all twelve chapter pairs are present and fidelity-verified. |
| Civilization | First twenty-eight-chapter spine present | Volume II commentary template is present in `book/volume-ii/`; `civ-01` is the calibrated pilot, and `civ-02` through `civ-28` are in review after initial commentary analysis. |
| PH-CIV | Seed plus spine placements present | Calibrated placements exist for `civ-01`, `geo-05`, `geo-07`, and `geo-12`; `civ-02` through `civ-28` are in review. |
| Secret History | Pending | Planned future series; no public chapter batch yet. |
| Game Theory | Pending | Planned future series; no public chapter batch yet. |
| Great Books | Pending | Planned future series; no public chapter batch yet. |
| Interviews | Pending | Planned future series; no public chapter batch yet. |
| Essays | Pending | Planned future series; no public chapter batch yet. |

## Suggested Order

The repository has already proven the Geo-Strategy pipeline. A sensible next order is:

1. Civilization
2. Secret History
3. Game Theory
4. Great Books
5. Interviews
6. Essays

This order is only a planning guide. The actual publication sequence can change if a different series is better prepared or more useful for review.

## Planning Notes

- Keep the series roadmap high-level.
- Treat Civilization as the next active batch family, with a public first twenty-eight-chapter spine now in review from `civ-02` through `civ-28`.
- Treat PH-CIV as a derived study corpus, not a replacement for source transcripts, annotations, or commentary.
- Do not reserve placeholder chapter files or manifest rows for future Civilization chapters until the batch is actually created.
- Media policy draft for future chapters: [docs/proposed-media-policy-plan.md](proposed-media-policy-plan.md).
- Keep chapter routing in `chapter-manifest.yaml`.
- Keep the readable chapter inventory in `chapter-index.md`.
- Keep the public front door in `README.md`.
- Keep the machine front door in `llms.txt`.
