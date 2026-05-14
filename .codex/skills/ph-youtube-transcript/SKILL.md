---
name: ph-youtube-transcript
description: Use for Predictive History YouTube transcript work, including PH channel caption capture, ASR audit, verbatim transcript sync, curated lecture transcript repair, and quote-grade verification boundaries. Activate on "youtube transcript", "ph transcript", or "predictive history transcript"; do not use for strategy-codex raw-input ingestion.
---

# PH YouTube Transcript

Use this skill for Predictive History channel videos and PH lecture-series transcript work. This is a PH lecture-fidelity workflow, not the strategy-codex `/codex/YYYY/raw-input` daily current-events capture path.

## Required Preflight

Before fetching, syncing, or editing transcript material, inspect the checkout for the active transcript stack:

- `WORKFLOW-transcripts.md`
- `ASR-VERIFICATION-RUBRIC.md`
- `ASR-AUDIT-LOG.md`
- `research/external/youtube-channels/predictive-history/README.md`
- `research/external/youtube-channels/predictive-history/transcripts/README.md`
- `scripts/fetch_youtube_channel_transcripts.py`
- `scripts/youtube_transcripts/`
- `scripts/work_jiang/sync_verbatim_transcripts.py`
- `scripts/work_jiang/normalize_lecture_transcript_asr.py`
- `scripts/work_jiang/asr_transcript_replacements.py`
- `scripts/work_jiang/asr_light_clean.py`
- relevant transcript, ASR, and `youtube_transcripts` tests

If the stack is present, operate through those repo tools. If it is absent, enter plan-only fallback: explain the missing pieces and propose the next safe step. Do not improvise new transcript artifacts, caches, or manifests.

## Source Layers

- Raw cache: `research/external/youtube-channels/predictive-history/transcripts/*.txt`, usually gitignored.
- Lightweight index/manifest: `index.json`, `transcript_manifest.json`, and `CHANNEL-VIDEO-INDEX.md` where present.
- Verbatim generated layer: `verbatim-transcripts/*.md`, generated or synced from raw captions where applicable.
- Curated lecture layer: `lectures/*.md`, especially `## Full transcript`.
- Book and quote layer: `metadata/quotes.yaml`, chapters, and manuscript files. This layer requires stronger verification than ordinary transcript capture.

Keep generated/cache files separate from curated lecture edits.

## Acquisition

Prefer the repo's existing `scripts/fetch_youtube_channel_transcripts.py` and `scripts/youtube_transcripts/` library. Inspect `--help` before running commands in a new checkout.

Default source order:

1. `youtube-transcript-api` timedtext when available.
2. `yt-dlp` WebVTT fallback, preferring manual captions over auto captions.
3. `whisper.cpp` only when already configured and explicitly requested.

Record source tier, quality score, content hash, and status in the manifest where existing tooling supports those fields. Respect `TRANSCRIPT_MIN_QUALITY`; do not silently accept low-quality transcripts. Use `--keep-low-quality` only when the user or repo workflow explicitly calls for retaining suspect material.

For single-video work, fetch or refresh by URL or video ID using the existing script interface. For batch work, refresh the PH channel index, fetch missing transcripts, and resume without overwriting existing raw transcript files. Use `--force` or an equivalent refresh flag only when explicit.

## ASR Cleanup And Audit

- Run `scripts/work_jiang/normalize_lecture_transcript_asr.py` only on the intended scope.
- Put recurring safe ASR corrections in `scripts/work_jiang/asr_transcript_replacements.py`.
- Extend tests when adding normalization behavior.
- Avoid blind global replacements for context-sensitive terms.
- Record significant recurring ASR issues in `ASR-AUDIT-LOG.md`.
- Use `ASR-VERIFICATION-RUBRIC.md` for depth A/B/C decisions.
- Do not claim full proofreading unless a full depth-C pass was actually completed.

Do not infer missing dates from titles. Do not upgrade auto captions into human/manual captions. Do not erase uncertainty or collapse ASR noise into confident proper nouns without verification.

## Verbatim Sync

Use generated sync carefully:

- Start with `scripts/work_jiang/sync_verbatim_transcripts.py --dry-run`.
- Use `scripts/work_jiang/sync_verbatim_transcripts.py --write` only after reviewing the dry run.
- Use `--only-glob` for targeted series work.
- Inspect `--help` before using any force or refresh flags.

Files under `verbatim-transcripts/*.md` are generated and overwrite-prone. Curated `lectures/*.md` edits are a separate layer.

## Quote-Grade Boundary

Raw or lightly cleaned ASR is not quote-grade by default.

Anything promoted into `metadata/quotes.yaml`, chapters, or polished manuscript prose must be checked against the video/audio or a reliable raw timestamp segment. Preserve uncertainty markers such as `[verify: MM:SS]`, `[unclear]`, or the local equivalent. Do not smooth a quote into words the lecturer did not say.

When the curated layer calls for transcript fidelity, preserve the lecturer's meaning and cadence while marking uncertainty honestly.

## Validation

After changing this protocol or transcript tooling, run the relevant repo checks:

- `.\scripts\validate-transcript-skill.ps1`
- `.\scripts\validate-all.ps1`
- `python -m pytest tests/test_normalize_lecture_transcript_asr.py -q` when that test exists
- any tests covering `scripts/youtube_transcripts/` when present
