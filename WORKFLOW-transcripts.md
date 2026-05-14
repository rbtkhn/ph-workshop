# Transcript Workflow

Predictive History transcript work is a lecture-fidelity workflow. It is separate from strategy-codex `/codex/YYYY/raw-input` ingestion and is intended for Predictive History channel videos and PH lecture-series transcripts.

## Operating Order

1. Run preflight checks against the local transcript stack.
2. Capture or refresh raw captions into the raw cache without overwriting by default.
3. Record manifest metadata: video ID, source tier, quality score, content hash, status, and capture time.
4. Sync generated verbatim Markdown with `--dry-run` first, then `--write`.
5. Repair curated lecture transcripts only in the intended scope.
6. Promote quotes only after timestamp/audio/video verification.

## Acquisition

Use the fetch command for single-video work:

```powershell
python scripts/fetch_youtube_channel_transcripts.py --video-id VIDEO_ID --dry-run
python scripts/fetch_youtube_channel_transcripts.py --video-id VIDEO_ID
```

The default source order is `youtube-transcript-api`, then `yt-dlp` WebVTT with manual captions preferred over auto captions. `whisper.cpp` is reserved for explicit, separately configured use and is not invoked by the default fetch script.

The command will not overwrite an existing raw transcript unless `--force` is supplied. Low-quality captures below `TRANSCRIPT_MIN_QUALITY` are rejected unless `--keep-low-quality` is explicit.

## Generated Verbatim Sync

Generated verbatim files are overwrite-prone:

```powershell
python scripts/work_jiang/sync_verbatim_transcripts.py --dry-run
python scripts/work_jiang/sync_verbatim_transcripts.py --write --only-glob "civ-*"
```

Use `--only-glob` to target a narrow series or video-ID pattern. Do not use generated sync as a substitute for curated lecture editing.

## Curated Repair

Use ASR normalization only on intended files:

```powershell
python scripts/work_jiang/normalize_lecture_transcript_asr.py path/to/file.md --dry-run
python scripts/work_jiang/normalize_lecture_transcript_asr.py path/to/file.md --write
```

Add recurring safe replacements to `scripts/work_jiang/asr_transcript_replacements.py` and extend tests when replacement behavior changes. Avoid blind global replacements.

## Quote Boundary

Raw or lightly cleaned ASR is not quote-grade. Anything promoted into `metadata/quotes.yaml`, chapters, or manuscript prose must be checked against the video/audio or a reliable timestamp segment. Preserve `[verify: MM:SS]`, `[unclear]`, or equivalent markers until verification is complete.
