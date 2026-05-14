# Repository Map

This repo is docs-first and site-ready. Markdown files should remain readable on GitHub and easy to convert into a static site later.

```text
.
|-- README.md
|-- llms.txt
|-- chapter-manifest.yaml
|-- CONTRIBUTING.md
|-- CHANGELOG.md
|-- .cursor/
|   `-- skills/
|       |-- ph-transcript/
|       |-- ph-chapter/
|       |-- ph-civ/
|       |-- ph-cross-volume/
|       |-- ph-audit/
|       `-- ph-youtube-transcript/
|-- .codex/
|   `-- skills/
|       |-- ph-transcript/
|       |-- ph-chapter/
|       |-- ph-civ/
|       |-- ph-cross-volume/
|       |-- ph-audit/
|       `-- ph-youtube-transcript/
|-- docs/
|   |-- annotation-block.md
|   |-- chapter-index.md
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
|   |   |-- geo-11.md
|   |   `-- geo-12.md
|   |-- civilization/
|   |   |-- civ-01.md
|   |   `-- civ-02..civ-60.md
|   |-- great-books/
|   |   |-- README.md
|   |   |-- index.md
|   |   `-- gb-01..gb-10.md
|   |-- cross-volume/
|   |   |-- README.md
|   |   |-- index.md
|   |   |-- homer-to-dante.md
|   |   `-- homer-to-tolstoy.md
|   `-- ph-civ/
|       |-- README.md
|       |-- index.md
|       |-- civ-01.md
|       |-- civ-02..civ-60.md
|       |-- gb-01..gb-10.md
|       |-- geo-05.md
|       |-- geo-07.md
|       `-- geo-12.md
|-- registries/
|   |-- README.md
|   `-- cross-volume-links.yaml
|-- reports/
|   |-- civilization-spine-health.md
|   |-- ph-civ-health.md
|   |-- high-risk-review-queue.md
|   `-- next-actions.md
|-- scripts/
|   |-- audit-civilization-spine.ps1
|   |-- audit-ph-civ.ps1
|   |-- audit-review-queue.ps1
|   |-- validate-all.ps1
|   |-- validate-civilization-spine.ps1
|   |-- validate-cross-volume-links.ps1
|   |-- validate-orientation.ps1
|   |-- validate-ph-civ.ps1
|   |-- validate-ph-skills.ps1
|   |-- validate-transcript-skill.ps1
|   `-- validate-transcript-fidelity.ps1
`-- book/
    |-- README.md
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
    |   |-- geo-11-transcript.md
    |   |-- geo-11-commentary.md
    |   |-- geo-12-transcript.md
    |   `-- geo-12-commentary.md
    |-- volume-ii/
    |   |-- README.md
    |   `-- civ-01..civ-60/
    |       |-- civ-XX-transcript.md
    |       `-- civ-XX-commentary.md
    `-- volume-v/
        |-- README.md
        `-- gb-01..gb-10/
            |-- gb-XX-transcript.md
            |-- gb-XX-commentary.md
            `-- gb-XX-orientation.yaml
```

## Future Corpus Shape

Future corpus material should be added in small reviewed batches. A likely structure:

```text
corpus/
|-- geo-strategy/
|-- civilization/
|-- ph-civ/
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

The exact registry format should be settled after the first manual Geo-Strategy batch.

## Local Skills

The repo-local Predictive History skill suite lives under both `.cursor/skills/` and `.codex/skills/` so future agents can load the same workflows in either surface.

- `ph-transcript`: transcript acquisition, ASR audit, generated verbatim sync, exact-body-match checks, and quote-grade boundaries.
- `ph-chapter`: one chapter pair plus manifest, source metadata, and review status wiring.
- `ph-civ`: PH-CIV placement entries, orientation payload alignment, limits, and return paths.
- `ph-cross-volume`: typed cross-volume corridors and edge registry work.
- `ph-audit`: health checks, audit reports, high-risk queue, and next-action summaries.
- `ph-youtube-transcript`: compatibility alias for `ph-transcript`.

See [youtube-transcript-workflow.md](youtube-transcript-workflow.md) for the public transcript workflow map.
