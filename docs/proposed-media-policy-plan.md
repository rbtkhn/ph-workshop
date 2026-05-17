# Human-Curated Predictive History Museum, Link-First By Default

## Summary
Make the Predictive History Museum a human-curated, agent-structured study layer with one exhibit per chapter across Predictive History: Civilization and Predictive History: Apocalypse. The internal schema can remain `media-pack`, but the public experience should be a chapter exhibit: civ-ph says where the lecture sits, the museum says which artifacts to encounter before reading, the transcript preserves what was said, and commentary interprets and bounds it.

The canonical storage and bidder contract is [predictive-history-museum.md](predictive-history-museum.md).

Artifacts are not only visual media. They can include objects, texts, maps, places, diagrams, music, speeches, documents, performances, architecture, flags, tools, propaganda, and pressure systems.

Use canonical artifact types in payloads: `artwork`, `artifact`, `object`, `text`, `manuscript`, `map`, `place`, `portrait`, `chart`, `diagram`, `music`, `speech`, `document`, `performance`, `architecture`, `institution`, `pressure_system`, and `symbolic_artifact`.

## Key Changes
- Add a chapter-local media payload plus public Predictive History Museum exhibit page:
  - each chapter should eventually have a `*-media.yaml` beside transcript and commentary
  - rendered packs live under `corpus/media-packs/`
  - packs aim for 5-15 high-value items, with 15 as the rich target
- Surface the Predictive History Museum exhibit in chapter metadata and chapter-level docs:
  - add `media_pack_path`, `media_payload_path`, and `media_pack_status`
  - make packs discoverable from manifest and corpus index
- Keep the policy lightweight and rights-safe:
  - every artifact must be stored in a local museum vault and shared document cloud workspace
  - no large binary artifact storage in GitHub
  - no mandatory Git LFS workflow
  - external links are required as provenance, but URL-only artifacts are insufficient
- Keep human responsibility focused:
  - humans search, select, and curate candidate artifacts
  - humans provide taste, cultural judgment, historical proportion, emotional calibration, and final curatorial responsibility
  - agents structure payloads, write museum-label captions, and run validation
  - rights handling uses conservative statuses, not human legal review

## Human Curator Checklist

- Choose artifacts for chapter-opening power, not availability alone.
- Check sacred, traumatic, political, or identity-bearing material before publication.
- Preserve historical proportion so one artifact does not dominate the lecture.
- Build exhibit pacing: entrance, context, primary artifacts, comparison, pressure, caution, return.
- Prefer stable link-first sources and mark uncertain rights status.
- Balance elite/state/imperial artifacts with non-obvious local, ordinary, sonic, textual, or ritual evidence.
- Calibrate emotional distance around violence, grief, humiliation, beauty, propaganda, and awe.
- Reject decorative items that do not help readers enter the chapter.
- Add local knowledge that an agent is unlikely to find by generic search.
- Own the exhibit's point of view, limits, and final responsibility.

## Test Plan
- Verify Predictive History Museum exhibits are link-first orientation aids, not proof bundles or media archives.
- Confirm each calibrated pack resolves from the manifest and contains required item metadata.
- Check that the policy is consistent with the current rights/reuse language in `CONTRIBUTING.md` and `docs/export-from-strategy-codex.md`.
- Ensure repo map, front-door docs, and validation runner point to the Predictive History Museum layer while preserving the internal media-pack path/schema.

## Assumptions
- The current rollout is calibration-only.
- Existing chapters are not all backfilled in one pass.
- The target end state is one exhibit per chapter across Predictive History: Civilization and Predictive History: Apocalypse.
- Calibration packs may remain `curated_draft` until a human search and curation pass approves the final selections.
