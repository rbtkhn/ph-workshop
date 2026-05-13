# Mandatory Chapter Media Packs, Lightweight by Default

## Summary
Make media packs mandatory for future chapters, but keep them lightweight and chapter-local. The pack should be a study aid rather than a media archive: each chapter gets a small media index plus a thumbnail and external links, while full video/audio mirroring stays out of scope. Existing Geo chapters stay unchanged for now; the rule applies to future chapters only.

## Key Changes
- Add a chapter-local media pack contract for new chapters:
  - each chapter has a `media.md` or equivalent media index beside transcript and commentary
  - the pack includes a thumbnail, external source links, and brief accessibility notes
  - optional key frames or slide images can be added when they materially help the lecture
- Surface the media pack in chapter metadata and chapter-level docs:
  - add a media pack path/status field to the future chapter template
  - make the chapter media pack discoverable from the transcript/commentary pair
- Keep the policy lightweight and rights-safe:
  - no default full video/audio storage in the repo
  - no mandatory Git LFS workflow
  - external links preferred over mirrored binaries
- Keep existing Geo content untouched:
  - no retroactive media-pack backfill for Geo
  - no placeholder media files for old chapters

## Test Plan
- Verify the media-pack rule is explicit for future chapters and does not imply a repo-wide backfill.
- Confirm the chapter template requires a media pack path while keeping the pack itself lightweight.
- Check that the policy is consistent with the current rights/reuse language in `CONTRIBUTING.md` and `docs/export-from-strategy-codex.md`.
- Ensure the repo map and front-door docs can point to the media pack without turning the repo into a media archive.

## Assumptions
- “Mandatory” means every **new** chapter must have a media pack; existing Geo chapters are not backfilled.
- The minimum pack is chapter-local index + thumbnail + external links.
- Key frames and slides are optional enhancements, not baseline requirements.
