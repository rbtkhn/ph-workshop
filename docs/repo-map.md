# Repository Map

This repo is docs-first and site-ready. Markdown files should remain readable on GitHub and easy to convert into a static site later.

## Surface Vocabulary

- **Source item**: the underlying Jiang video, essay, interview, or other source.
- **Source transcript**: the source-text or transcript record when available.
- **Commentary**: the main study surface for thesis, claims, concepts, predictions, counter-readings, routes, limits, and correction paths.
- **civ-ph placement card**: the compact civilizational orientation and re-entry page.

Use **Part One** and **Part Two** only for the whole corpus architecture: Civilization and Apocalypse.

```text
.
|-- README.md
|-- AGENTS.md
|-- llms.txt
|-- chapter-manifest.yaml
|-- CONTRIBUTING.md
|-- CHANGELOG.md
|-- .cursor/
|   `-- skills/
|       |-- coffee/
|       |-- ph-open/
|       |-- ph-transcript/
|       |-- ph-chapter/
|       |-- civ-ph/
|       |-- ph-cross-volume/
|       |-- ph-audit/
|       `-- ph-youtube-transcript/
|-- .codex/
|   `-- skills/
|       |-- coffee/
|       |-- ph-open/
|       |-- ph-transcript/
|       |-- ph-chapter/
|       |-- civ-ph/
|       |-- ph-cross-volume/
|       |-- ph-audit/
|       `-- ph-youtube-transcript/
|-- docs/
|   |-- annotation-block.md
|   |-- audience-profile.md
|   |-- chapter-index.md
|   |-- predictive-history-after-tolstoy.md
|   |-- predictive-history-museum.md
|   |-- ph-civ-new-chat-open.md
|   |-- series-roadmap.md
|   |-- corrections-policy.md
|   |-- export-from-strategy-codex.md
|   |-- repo-map.md
|   |-- youtube-transcript-workflow.md
|   `-- source-status.md
|-- corpus/
|   |-- README.md
|   |-- geo-strategy/
|   |   |-- geo-01.md
|   |   |-- geo-02.md
|   |   |-- geo-03.md
|   |   |-- geo-04.md
|   |   |-- geo-05.md
|   |   |-- geo-06.md
|   |   |-- geo-07.md
|   |   |-- geo-08.md
|   |   |-- geo-09.md
|   |   |-- geo-10.md
|   |   |-- index.md
|   |   |-- geo-01.md
|   |   `-- geo-02..geo-20.md
|   |-- game-theory/
|   |   |-- README.md
|   |   |-- index.md
|   |   `-- gt-01..gt-22.md
|   |-- civilization/
|   |   |-- civ-01.md
|   |   `-- civ-02..civ-60.md
|   |-- great-books/
|   |   |-- README.md
|   |   |-- index.md
|   |   `-- gb-01..gb-10.md
|   |-- secret-history/
|   |   |-- README.md
|   |   |-- index.md
|   |   `-- sh-01..sh-28.md
|   |-- world-war/
|   |   |-- README.md
|   |   |-- index.md
|   |   `-- pressure-corridor files
|   |-- media-packs/
|   |   |-- README.md
|   |   |-- index.md
|   |   `-- Predictive History Museum exhibit pages using the internal media-pack schema; target one exhibit per chapter
|   |-- cross-volume/
|   |   |-- README.md
|   |   |-- index.md
|   |   |-- homer-to-dante.md
|   |   |-- homer-to-tolstoy.md
|   |   `-- tolstoy-question.md
|   `-- civ-ph/
|       |-- README.md
|       |-- index.md
|       |-- civ-01.md
|       |-- civ-02..civ-60.md
|       |-- geo-01..geo-20.md
|       |-- gt-01..gt-22.md
|       |-- gb-01..gb-10.md
|       `-- sh-01..sh-28.md
|-- registries/
|   |-- README.md
|   |-- actors.yaml
|   |-- causation-lenses.yaml
|   |-- theaters.yaml
|   |-- forecasts.yaml
|   `-- cross-volume-links.yaml
|-- reports/
|   |-- civilization-spine-health.md
|   |-- civ-ph-health.md
|   |-- high-risk-review-queue.md
|   |-- improvement-loops.md
|   |-- review-sprint.md
|   `-- next-actions.md
|-- scripts/
|   |-- audit-civilization-spine.ps1
|   |-- audit-civ-ph.ps1
|   |-- audit-improvement-loops.ps1
|   |-- audit-review-queue.ps1
|   |-- audit-review-sprint.ps1
|   |-- validate-all.ps1
|   |-- validate-causation-lens.ps1
|   |-- validate-civilization-spine.ps1
|   |-- validate-cross-volume-links.ps1
|   |-- validate-geo-strategy-spine.ps1
|   |-- validate-game-theory-spine.ps1
|   |-- validate-secret-history-spine.ps1
|   |-- validate-world-war-part.ps1
|   |-- validate-media-packs.ps1
|   |-- validate-orientation.ps1
|   |-- validate-civ-ph.ps1
|   |-- validate-ph-skills.ps1
|   |-- ph-civ-open.ps1
|   |-- validate-transcript-skill.ps1
|   `-- validate-transcript-fidelity.ps1
`-- book/
    |-- README.md
    |-- parts/
    |   |-- civilization-to-apocalypse.md
    |   |-- civilization/
    |   `-- world-war/
    |-- volume-i/
    |   |-- geo-01-transcript.md
    |   |-- geo-01-commentary.md
    |   |-- geo-02-transcript.md
    |   |-- geo-02-commentary.md
    |   |-- geo-03-transcript.md
    |   |-- geo-03-commentary.md
    |   |-- geo-04-transcript.md
    |   |-- geo-04-commentary.md
    |   |-- geo-05-transcript.md
    |   |-- geo-05-commentary.md
    |   |-- geo-06-transcript.md
    |   |-- geo-06-commentary.md
    |   |-- geo-07-transcript.md
    |   |-- geo-07-commentary.md
    |   |-- geo-08-transcript.md
    |   |-- geo-08-commentary.md
    |   |-- geo-09-transcript.md
    |   |-- geo-09-commentary.md
    |   |-- geo-10-transcript.md
    |   |-- geo-10-commentary.md
    |   `-- geo-01..geo-20 source transcripts, commentaries, and orientation files
    |-- volume-ii/
    |   |-- README.md
    |   `-- civ-01..civ-60/
    |       |-- civ-XX-transcript.md
    |       `-- civ-XX-commentary.md
    |-- volume-v/
    |   |-- README.md
    |   `-- gb-01..gb-10/
    |       |-- gb-XX-transcript.md
    |       |-- gb-XX-commentary.md
    |       `-- gb-XX-orientation.yaml
    `-- volume-vi/
        |-- README.md
        `-- sh-01..sh-28/
            |-- sh-XX-transcript.md
            |-- sh-XX-commentary.md
            `-- sh-XX-orientation.yaml
```

## Future Corpus Shape

Future corpus material should be added in small reviewed batches. A likely structure:

```text
corpus/
|-- geo-strategy/
|-- civilization/
|-- civ-ph/
|-- cross-volume/
|-- secret-history/
|-- game-theory/
|-- great-books/
|-- interviews/
`-- essays/
```

## Future Registry Shape

```text
registries/
|-- sources.md
|-- cross-volume-links.yaml
|-- concepts.md
|-- claims.md
|-- predictions.md
`-- counter-readings.md
```

The strategic registries are intentionally minimal in this pass. They provide starting anchors for actors, theaters, and forecast-bearing claims without replacing chapter-level review.

## Local Skills

The repo-local Predictive History skill suite lives under both `.cursor/skills/` and `.codex/skills/` so future agents can load the same workflows in either surface.

- `ph-transcript`: transcript acquisition, ASR audit, generated verbatim sync, exact-body-match checks, and quote-grade boundaries.
- `coffee`: compatibility opener that routes `coffee` to `ph-open` instead of a generic greeting.
- `ph-open`: fresh-chat bootstrap for `ph-civ` population readiness, candidate routes, gate status, and no-export boundaries.
- `ph-chapter`: one source transcript and commentary unit plus manifest, source metadata, and review status wiring.
- `civ-ph`: civ-ph placement entries, orientation payload alignment, limits, and return paths.
- `ph-cross-volume`: typed cross-volume corridors and edge registry work.
- `ph-audit`: health checks, audit reports, high-risk queue, and next-action summaries.
- `ph-youtube-transcript`: compatibility alias for `ph-transcript`.

See [youtube-transcript-workflow.md](youtube-transcript-workflow.md) for the public transcript workflow map.
See [recursive-improvement-loops.md](recursive-improvement-loops.md) for the internal quality loop protocol.
    |-- volume-iii/
    |   |-- README.md
    |   `-- gt-01..gt-22/
    |       |-- gt-XX-transcript.md
    |       |-- gt-XX-commentary.md
    |       `-- gt-XX-orientation.yaml
    |-- volume-v/
