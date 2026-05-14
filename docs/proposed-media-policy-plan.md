# Human-Curated Chapter Media Packs, Link-First By Default

## Summary
Make media packs a human-curated, agent-structured study layer. The pack should orient students before transcript and commentary: PH-CIV says where the lecture sits, the media pack says what to see before reading, the transcript preserves what was said, and commentary interprets and bounds it.

## Key Changes
- Add a chapter-local media payload plus public media-pack corpus page:
  - each calibrated chapter has a `*-media.yaml` beside transcript and commentary
  - rendered packs live under `corpus/media-packs/`
  - packs aim for 5-15 high-value items, with 15 as the rich target
- Surface the media pack in chapter metadata and chapter-level docs:
  - add `media_pack_path`, `media_payload_path`, and `media_pack_status`
  - make packs discoverable from manifest and corpus index
- Keep the policy lightweight and rights-safe:
  - no default full video/audio storage in the repo
  - no mandatory Git LFS workflow
  - external links preferred over mirrored binaries
- Keep human responsibility focused:
  - humans search and curate candidate media
  - agents structure payloads, write museum-label captions, and run validation
  - rights handling uses conservative statuses, not human legal review

## Test Plan
- Verify media packs are link-first orientation aids, not proof bundles or media archives.
- Confirm each calibrated pack resolves from the manifest and contains required item metadata.
- Check that the policy is consistent with the current rights/reuse language in `CONTRIBUTING.md` and `docs/export-from-strategy-codex.md`.
- Ensure repo map, front-door docs, and validation runner point to the media-pack layer.

## Assumptions
- The first rollout is calibration-only.
- Existing chapters are not all backfilled in one pass.
- The first calibration packs may remain `curated_draft` until a human search and curation pass approves the final selections.
