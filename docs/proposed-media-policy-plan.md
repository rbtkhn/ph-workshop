# Human-Curated Civilization Museum, Link-First By Default

## Summary
Make the Civilization Museum a human-curated, agent-structured study layer. The internal schema can remain `media-pack`, but the public experience should be a chapter exhibit: civ-ph says where the lecture sits, the museum says which artifacts to encounter before reading, the transcript preserves what was said, and commentary interprets and bounds it.

Artifacts are not only visual media. They can include objects, texts, maps, places, diagrams, music, speeches, documents, performances, architecture, flags, tools, propaganda, and pressure systems.

## Key Changes
- Add a chapter-local media payload plus public Civilization Museum exhibit page:
  - each calibrated chapter has a `*-media.yaml` beside transcript and commentary
  - rendered packs live under `corpus/media-packs/`
  - packs aim for 5-15 high-value items, with 15 as the rich target
- Surface the Civilization Museum exhibit in chapter metadata and chapter-level docs:
  - add `media_pack_path`, `media_payload_path`, and `media_pack_status`
  - make packs discoverable from manifest and corpus index
- Keep the policy lightweight and rights-safe:
  - no default full video/audio storage in the repo
  - no mandatory Git LFS workflow
  - external links preferred over mirrored binaries
- Keep human responsibility focused:
  - humans search, select, and curate candidate artifacts
  - humans provide taste, cultural judgment, historical proportion, emotional calibration, and final curatorial responsibility
  - agents structure payloads, write museum-label captions, and run validation
  - rights handling uses conservative statuses, not human legal review

## Test Plan
- Verify Civilization Museum exhibits are link-first orientation aids, not proof bundles or media archives.
- Confirm each calibrated pack resolves from the manifest and contains required item metadata.
- Check that the policy is consistent with the current rights/reuse language in `CONTRIBUTING.md` and `docs/export-from-strategy-codex.md`.
- Ensure repo map, front-door docs, and validation runner point to the Civilization Museum layer while preserving the internal media-pack path/schema.

## Assumptions
- The first rollout is calibration-only.
- Existing chapters are not all backfilled in one pass.
- The first calibration packs may remain `curated_draft` until a human search and curation pass approves the final selections.
