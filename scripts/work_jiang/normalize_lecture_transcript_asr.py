from __future__ import annotations

import argparse
import difflib
from pathlib import Path

from asr_light_clean import light_clean
from asr_transcript_replacements import apply_replacements


def normalize_text(text: str) -> str:
    return light_clean(apply_replacements(text))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Conservatively normalize ASR artifacts in intended lecture transcript files.")
    parser.add_argument("paths", nargs="+", help="Files to inspect")
    parser.add_argument("--dry-run", action="store_true", help="Print diffs without writing")
    parser.add_argument("--write", action="store_true", help="Write normalized text")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.write == args.dry_run:
        raise SystemExit("Choose exactly one of --dry-run or --write")

    changed = 0
    for raw_path in args.paths:
        path = Path(raw_path)
        original = path.read_text(encoding="utf-8")
        normalized = normalize_text(original)
        if normalized == original:
            print(f"UNCHANGED {path}")
            continue
        changed += 1
        if args.dry_run:
            diff = difflib.unified_diff(
                original.splitlines(keepends=True),
                normalized.splitlines(keepends=True),
                fromfile=str(path),
                tofile=f"{path} normalized",
            )
            print("".join(diff), end="")
        else:
            path.write_text(normalized, encoding="utf-8")
            print(f"WROTE {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
