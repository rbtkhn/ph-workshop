# Predictive History

A source-disciplined public study companion for Professor Jiang's Predictive History corpus.

This repository organizes source metadata, study annotations, reading paths, claims, concepts, predictions, and future book/site material so Jiang students can study the corpus with source discipline: what was said, where it was said, when it was said, what it implies, and how it can be compared or tested.

If you are using an LLM or coding agent, start with [llms.txt](llms.txt). That file points to the canonical reading path without repeating the whole repository map here.

## Status

This is an independent educational and research project. It is not an official archive, not a substitute for Professor Jiang's original videos or essays, and not endorsed by Professor Jiang unless explicitly stated later.

Representation is not endorsement. The repository documents and analyzes claims in the corpus; it does not automatically affirm every claim, prediction, interpretation, or framing.

License status is pending. Until a license is added, do not assume broad reuse rights for repository contents or source material.

## V1 Scope

The first version established the public contract before importing real corpus items. The first Geo-Strategy batch is now present as transcript-first chapter pairs plus corpus pointers for `geo-01` through `geo-12`; Civilization Volume II has a first sixty-chapter spine from `civ-01` through `civ-60`; Volume V Great Books is active through `gb-10`; and a limited Secret History literary subset supports the Homer-to-Tolstoy corridor.

Included now:

- contribution rules
- annotation template
- source and transcript status vocabulary
- correction workflow
- repo map
- export policy from the private working corpus
- the first public Geo-Strategy chapter files for `geo-01` through `geo-12`
- the Civilization Volume II scaffold and multi-layer commentary template
- the first Civilization spine from `civ-01` through `civ-60`, with `civ-02` through `civ-60` in review
- the `ph-civ` derived study corpus for calibrated and in-review chapter placement and re-entry
- the Great Books Volume V spine from `gb-01` through `gb-10`, with all ten units in review
- the limited Secret History literary subset for `sh-11`, `sh-16`, `sh-17`, and `sh-18`
- the first cross-volume corridors, Homer to Dante and Homer to Tolstoy, linking Civilization, Great Books, and selected Secret History study routes

Not included yet:

- generous excerpts
- full corpus exports beyond the active Geo-Strategy, Civilization, Great Books, and limited Secret History literary subset batches
- private operator notes
- internal working backlog
- final Civilization commentary analysis beyond `civ-01`

## Intended Audience

The first audience is Jiang students and serious listeners who already care about the corpus and want a clearer study map.

The repository should help readers:

- find the right starting point
- understand the major series
- distinguish source text, summary, annotation, prediction, and counter-reading
- see uncertainty and review status clearly
- contribute corrections without weakening source discipline

## Public Surfaces

- [llms.txt](llms.txt) - compact AI-facing entry point
- [docs/chapter-index.md](docs/chapter-index.md) - readable chapter catalog
- [docs/series-roadmap.md](docs/series-roadmap.md) - series-level planning and batch order
- [docs/repo-map.md](docs/repo-map.md) - intended folder structure
- [corpus/](corpus/) - public source items and annotations
- [corpus/ph-civ/](corpus/ph-civ/) - derived study placements for calibrated and in-review chapters
- [corpus/cross-volume/](corpus/cross-volume/) - guided corridors across routed volumes, beginning with Homer to Dante and the broader Homer to Tolstoy literary arc
- [corpus/great-books/](corpus/great-books/) - Great Books corpus pointers for `gb-01` through `gb-10`
- [corpus/secret-history/](corpus/secret-history/) - limited Secret History literary/imagination subset for the Homer-to-Tolstoy corridor
- [corpus/civilization/](corpus/civilization/) - Civilization corpus pointers for `civ-01` through `civ-60`
- [registries/](registries/) - current source index, cross-volume edge registry, and future cross-reference registries
- [book/](book/) - public chapter files and reader-facing material
- [book/volume-ii/](book/volume-ii/) - Civilization chapter scaffold and first sixty-chapter spine
- [book/volume-v/](book/volume-v/) - Great Books chapter scaffold and first ten-chapter spine
- [book/volume-vi/](book/volume-vi/) - limited Secret History literary/imagination subset
- [book/volume-ii/civ-01/](book/volume-ii/civ-01/) - calibrated Civilization pilot chapter pair
- [docs/annotation-block.md](docs/annotation-block.md) - required annotation format
- [docs/source-status.md](docs/source-status.md) - status ladder for source and transcript handling
- [docs/corrections-policy.md](docs/corrections-policy.md) - how corrections are reported and reviewed
- [docs/git-workflow.md](docs/git-workflow.md) - safe pull/push workflow for this checkout

## Machine Entry

- [llms.txt](llms.txt) is the model-facing index.
- [chapter-manifest.yaml](chapter-manifest.yaml) is the routing table for chapter-by-chapter loads.
- [registries/cross-volume-links.yaml](registries/cross-volume-links.yaml) is the typed edge registry for public cross-volume corridors.
- The default load is one chapter at a time.

## Contributing

If you want to help improve the repository, start with [CONTRIBUTING.md](CONTRIBUTING.md). It explains the source-discipline rules, rights expectations, and review process for new material or corrections.

## Source Discipline

Every public corpus item should preserve a stable source ID such as `geo-01`, `vi-16`, or `es-13`, along with the original source URL and publication date when known.

Video-derived claims should include timestamps where practical. Transcript text and longer excerpts require rights review before publication.

## Roadmap

See [docs/series-roadmap.md](docs/series-roadmap.md) for the series-level plan and current batch order.
