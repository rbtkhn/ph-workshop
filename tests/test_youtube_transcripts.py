import sys
import json
import shutil
import subprocess
import uuid
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from youtube_transcripts.manifest import content_hash, extract_video_id, quality_score, transcript_filename
from youtube_transcripts.vtt import vtt_to_text


def test_extract_video_id_from_common_urls():
    assert extract_video_id("https://www.youtube.com/watch?v=abc123_XYz") == "abc123_XYz"
    assert extract_video_id("https://youtu.be/abc123_XYz") == "abc123_XYz"
    assert extract_video_id("abc123_XYz") == "abc123_XYz"


def test_vtt_to_text_removes_timecodes_and_tags():
    vtt = """WEBVTT

00:00:01.000 --> 00:00:02.000
<c>Hello</c> world

00:00:02.000 --> 00:00:03.000
Hello world
"""
    assert vtt_to_text(vtt) == "Hello world\nHello world\n"


def test_manifest_helpers_are_stable():
    assert transcript_filename("abc-123") == "abc-123.txt"
    assert len(content_hash("hello")) == 64
    assert quality_score("one two three four five") > 0


def test_fetch_cli_imports_local_file_without_network():
    tmp_path = Path(".codex-test-temp") / f"test_fetch_cli_{uuid.uuid4().hex}"
    tmp_path.mkdir(parents=True)
    source = tmp_path / "caption.txt"
    source.write_text(" ".join(f"word{i}" for i in range(300)), encoding="utf-8")
    transcripts_dir = tmp_path / "transcripts"
    manifest = tmp_path / "transcript_manifest.json"

    result = subprocess.run(
        [
            sys.executable,
            "scripts/fetch_youtube_channel_transcripts.py",
            "--video-id",
            "abc123_XYz",
            "--from-file",
            str(source),
            "--transcripts-dir",
            str(transcripts_dir),
            "--manifest",
            str(manifest),
        ],
        cwd=Path(__file__).resolve().parents[1],
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0, result.stderr
    assert (transcripts_dir / "abc123_XYz.txt").exists()
    data = json.loads(manifest.read_text(encoding="utf-8"))
    assert data["transcripts"][0]["video_id"] == "abc123_XYz"
    assert data["transcripts"][0]["source_tier"] == "local_file"
    shutil.rmtree(tmp_path, ignore_errors=True)
