from __future__ import annotations

import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


YOUTUBE_ID_RE = re.compile(r"^[A-Za-z0-9_-]{6,}$")


def extract_video_id(value: str) -> str:
    """Extract a YouTube video ID from a URL or return the supplied ID."""
    value = value.strip()
    if not value:
        raise ValueError("Video ID or URL is required")
    if YOUTUBE_ID_RE.match(value) and "://" not in value:
        return value

    patterns = [
        r"[?&]v=([A-Za-z0-9_-]+)",
        r"youtu\.be/([A-Za-z0-9_-]+)",
        r"/shorts/([A-Za-z0-9_-]+)",
        r"/embed/([A-Za-z0-9_-]+)",
    ]
    for pattern in patterns:
        match = re.search(pattern, value)
        if match:
            return match.group(1)
    raise ValueError(f"Could not extract YouTube video ID from {value!r}")


def transcript_filename(video_id: str) -> str:
    safe = re.sub(r"[^A-Za-z0-9_-]", "_", video_id)
    return f"{safe}.txt"


def content_hash(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def quality_score(text: str) -> float:
    words = re.findall(r"\b[\w'-]+\b", text)
    if not words:
        return 0.0
    unique_ratio = len(set(w.lower() for w in words)) / len(words)
    length_score = min(len(words) / 250.0, 1.0)
    noise_penalty = min(text.count("[Music]") / 20.0, 0.25)
    return round(max(0.0, min(1.0, (0.65 * length_score) + (0.35 * unique_ratio) - noise_penalty)), 3)


def load_manifest(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {"schema_version": 1, "transcripts": []}
    data = json.loads(path.read_text(encoding="utf-8"))
    data.setdefault("schema_version", 1)
    data.setdefault("transcripts", [])
    return data


def write_manifest(path: Path, manifest: dict[str, Any]) -> None:
    records = sorted(manifest.get("transcripts", []), key=lambda item: item.get("video_id", ""))
    output = {
        "schema_version": manifest.get("schema_version", 1),
        "transcripts": records,
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(output, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def upsert_transcript_record(
    manifest: dict[str, Any],
    *,
    video_id: str,
    relative_path: str,
    source_tier: str,
    quality: float,
    status: str,
    text_hash: str,
) -> dict[str, Any]:
    records = [item for item in manifest.get("transcripts", []) if item.get("video_id") != video_id]
    records.append(
        {
            "video_id": video_id,
            "path": relative_path.replace("\\", "/"),
            "source_tier": source_tier,
            "quality_score": quality,
            "status": status,
            "content_hash": text_hash,
            "captured_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
        }
    )
    manifest["transcripts"] = records
    manifest.setdefault("schema_version", 1)
    return manifest
