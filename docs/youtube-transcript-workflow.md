# YouTube Transcript Workflow

This repo treats Predictive History YouTube transcript work as a lecture-fidelity workflow. It is not the strategy-codex `/codex/YYYY/raw-input` daily current-events capture path.

Agents should use the repo-local `ph-youtube-transcript` skill when a task mentions `youtube transcript`, `ph transcript`, or `predictive history transcript`.

## Preflight

Before fetching, syncing, or editing transcript material, inspect the checkout for the active transcript stack: `WORKFLOW-transcripts.md`, `ASR-VERIFICATION-RUBRIC.md`, `ASR-AUDIT-LOG.md`, `research/external/youtube-channels/predictive-history/`, `scripts/fetch_youtube_channel_transcripts.py`, `scripts/youtube_transcripts/`, and `scripts/work_jiang/`.

If those surfaces are absent, operate in plan-only fallback. Do not improvise raw transcript caches, generated transcript files, manifests, or curated lecture edits.

## Transcript Layers

| Layer | Typical surface | Rule |
| --- | --- | --- |
| Raw cache | `research/external/youtube-channels/predictive-history/transcripts/*.txt` | Usually gitignored; do not overwrite unless explicitly refreshing. |
| Index/manifest | `index.json`, `transcript_manifest.json`, `CHANNEL-VIDEO-INDEX.md` | Record source tier, quality, hash, and status where tooling supports it. |
| Generated verbatim | `verbatim-transcripts/*.md` | Overwrite-prone generated layer; review dry runs before writing. |
| Curated lecture | `lectures/*.md`, especially `## Full transcript` | Repair carefully while preserving transcript fidelity. |
| Book and quote | `metadata/quotes.yaml`, chapters, manuscript prose | Quote-grade only after timestamp/audio/video verification. |

## Acquisition And Sync

Prefer existing repo tooling when present. The intended acquisition order is `youtube-transcript-api` timedtext, then `yt-dlp` WebVTT with manual captions preferred over auto captions, then `whisper.cpp` only when already configured and explicitly requested.

Respect `TRANSCRIPT_MIN_QUALITY` and `--keep-low-quality` conventions. Resume without overwriting existing raw transcript files unless `--force` or an equivalent refresh flag is explicit.

For generated verbatim sync, start with `scripts/work_jiang/sync_verbatim_transcripts.py --dry-run`, then use `--write` only after review. Use `--only-glob` for targeted series work.

## ASR And Quote Boundaries

Use targeted ASR corrections in `scripts/work_jiang/asr_transcript_replacements.py`, not blind global replacements. Record significant recurring issues in `ASR-AUDIT-LOG.md` and use `ASR-VERIFICATION-RUBRIC.md` for depth A/B/C decisions where those files exist.

Raw or lightly cleaned ASR is not quote-grade by default. Anything promoted into `metadata/quotes.yaml`, chapters, or polished manuscript prose must be checked against the video/audio or a reliable raw timestamp segment. Preserve markers such as `[verify: MM:SS]` or `[unclear]`; do not smooth a quote into words the lecturer did not say.
