from __future__ import annotations

import argparse
from fnmatch import fnmatch
from pathlib import Path


DEFAULT_RAW_DIR = Path("research/external/youtube-channels/predictive-history/transcripts")
DEFAULT_OUT_DIR = Path("verbatim-transcripts")


def render_verbatim(video_id: str, text: str) -> str:
    return (
        "---\n"
        f"video_id: {video_id}\n"
        "source: raw_youtube_caption_cache\n"
        "transcript_status: generated_verbatim_pending_review\n"
        "quote_grade: false\n"
        "---\n\n"
        f"# Verbatim Transcript: {video_id}\n\n"
        "## Full transcript\n\n"
        f"{text.strip()}\n"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Sync raw Predictive History caption cache into generated verbatim Markdown.")
    parser.add_argument("--raw-dir", default=str(DEFAULT_RAW_DIR))
    parser.add_argument("--out-dir", default=str(DEFAULT_OUT_DIR))
    parser.add_argument("--only-glob", help="Only sync raw transcript IDs matching this glob")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--force", action="store_true", help="Overwrite existing generated verbatim files")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.write == args.dry_run:
        raise SystemExit("Choose exactly one of --dry-run or --write")

    raw_dir = Path(args.raw_dir)
    out_dir = Path(args.out_dir)
    if not raw_dir.exists():
        print(f"No raw transcript directory found: {raw_dir}")
        return 0

    synced = 0
    for raw_file in sorted(raw_dir.glob("*.txt")):
        video_id = raw_file.stem
        if args.only_glob and not fnmatch(video_id, args.only_glob):
            continue
        target = out_dir / f"{video_id}.md"
        if target.exists() and not args.force:
            print(f"SKIP existing generated file: {target}")
            continue
        rendered = render_verbatim(video_id, raw_file.read_text(encoding="utf-8"))
        if args.dry_run:
            print(f"DRY RUN would sync {raw_file} -> {target}")
        else:
            out_dir.mkdir(parents=True, exist_ok=True)
            target.write_text(rendered, encoding="utf-8")
            print(f"WROTE {target}")
        synced += 1
    print(f"Sync candidates: {synced}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
