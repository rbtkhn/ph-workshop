from __future__ import annotations

import argparse
import os
from pathlib import Path

from youtube_transcripts.acquire import fetch_caption_text
from youtube_transcripts.manifest import (
    content_hash,
    extract_video_id,
    load_manifest,
    quality_score,
    transcript_filename,
    upsert_transcript_record,
    write_manifest,
)


DEFAULT_CACHE_ROOT = Path("research/external/youtube-channels/predictive-history")
DEFAULT_TRANSCRIPTS_DIR = DEFAULT_CACHE_ROOT / "transcripts"
DEFAULT_MANIFEST = DEFAULT_CACHE_ROOT / "transcript_manifest.json"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Fetch Predictive History YouTube captions into the raw transcript cache.")
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--video-id", help="YouTube video ID")
    source.add_argument("--video-url", help="YouTube video URL")
    parser.add_argument("--from-file", help="Import transcript text from a local file instead of fetching from YouTube")
    parser.add_argument("--transcripts-dir", default=str(DEFAULT_TRANSCRIPTS_DIR))
    parser.add_argument("--manifest", default=str(DEFAULT_MANIFEST))
    parser.add_argument("--dry-run", action="store_true", help="Show what would happen without writing files")
    parser.add_argument("--force", action="store_true", help="Overwrite an existing raw transcript file")
    parser.add_argument("--keep-low-quality", action="store_true", help="Keep transcript text below TRANSCRIPT_MIN_QUALITY")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    video_source = args.video_id or args.video_url
    video_id = extract_video_id(video_source)
    transcripts_dir = Path(args.transcripts_dir)
    manifest_path = Path(args.manifest)
    target = transcripts_dir / transcript_filename(video_id)
    min_quality = float(os.environ.get("TRANSCRIPT_MIN_QUALITY", "0.35"))

    if target.exists() and not args.force:
        print(f"SKIP existing raw transcript: {target}")
        print("Use --force only when an explicit refresh is intended.")
        return 0

    if args.from_file:
        text = Path(args.from_file).read_text(encoding="utf-8")
        source_tier = "local_file"
    elif args.dry_run:
        print(f"DRY RUN would fetch captions for {video_id} into {target}")
        print("Source order: youtube-transcript-api -> yt-dlp manual WebVTT -> yt-dlp auto WebVTT")
        return 0
    else:
        text, source_tier = fetch_caption_text(video_id, video_source)

    score = quality_score(text)
    status = "captured"
    if score < min_quality:
        status = "low_quality"
        if not args.keep_low_quality:
            raise SystemExit(
                f"Transcript quality score {score} is below TRANSCRIPT_MIN_QUALITY={min_quality}; "
                "rerun with --keep-low-quality only if retaining suspect material is intentional."
            )

    if args.dry_run:
        print(f"DRY RUN would write {target}")
        print(f"source_tier={source_tier} quality_score={score} status={status}")
        return 0

    transcripts_dir.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding="utf-8")

    manifest = load_manifest(manifest_path)
    relative_path = os.path.relpath(target, Path.cwd())
    upsert_transcript_record(
        manifest,
        video_id=video_id,
        relative_path=relative_path,
        source_tier=source_tier,
        quality=score,
        status=status,
        text_hash=content_hash(text),
    )
    write_manifest(manifest_path, manifest)
    print(f"WROTE {target}")
    print(f"UPDATED {manifest_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
