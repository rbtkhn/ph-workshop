from __future__ import annotations

import subprocess
import shutil
import sys
import tempfile
from pathlib import Path

from .vtt import vtt_to_text


def fetch_with_youtube_transcript_api(video_id: str) -> str:
    try:
        from youtube_transcript_api import YouTubeTranscriptApi  # type: ignore
    except ImportError as exc:
        raise RuntimeError("youtube-transcript-api is not installed") from exc

    api = YouTubeTranscriptApi()
    try:
        fetched = api.fetch(video_id)
        snippets = fetched.to_raw_data()
    except AttributeError:
        snippets = YouTubeTranscriptApi.get_transcript(video_id)
    return "\n".join(str(item.get("text", "")).strip() for item in snippets if item.get("text")).strip() + "\n"


def fetch_with_ytdlp(video_or_url: str, *, auto_captions: bool = False) -> str:
    with tempfile.TemporaryDirectory() as tmp:
        output_template = str(Path(tmp) / "%(id)s.%(ext)s")
        ytdlp_command = ["yt-dlp"] if shutil.which("yt-dlp") else [sys.executable, "-m", "yt_dlp"]
        command = [
            *ytdlp_command,
            "--skip-download",
            "--sub-langs",
            "en.*",
            "--sub-format",
            "vtt",
            "--output",
            output_template,
        ]
        command.append("--write-auto-subs" if auto_captions else "--write-subs")
        command.append(video_or_url)
        result = subprocess.run(command, capture_output=True, text=True, check=False)
        if result.returncode != 0:
            raise RuntimeError(result.stderr.strip() or "yt-dlp caption fetch failed")
        vtt_files = sorted(Path(tmp).glob("*.vtt"))
        if not vtt_files:
            raise RuntimeError("yt-dlp completed but did not produce a WebVTT caption file")
        return vtt_to_text(vtt_files[0].read_text(encoding="utf-8", errors="replace"))


def fetch_caption_text(video_id: str, video_or_url: str) -> tuple[str, str]:
    try:
        return fetch_with_youtube_transcript_api(video_id), "youtube_transcript_api"
    except Exception:
        pass

    try:
        return fetch_with_ytdlp(video_or_url, auto_captions=False), "yt_dlp_manual_vtt"
    except Exception:
        return fetch_with_ytdlp(video_or_url, auto_captions=True), "yt_dlp_auto_vtt"
