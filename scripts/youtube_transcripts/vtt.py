from __future__ import annotations

import re


TIMECODE_RE = re.compile(r"^\d{2}:\d{2}:\d{2}\.\d{3}\s+-->\s+\d{2}:\d{2}:\d{2}\.\d{3}")
TAG_RE = re.compile(r"<[^>]+>")


def vtt_to_text(vtt: str) -> str:
    lines: list[str] = []
    seen_consecutive: set[str] = set()
    for raw_line in vtt.splitlines():
        line = raw_line.strip()
        if not line or line == "WEBVTT" or line.startswith("Kind:") or line.startswith("Language:"):
            seen_consecutive.clear()
            continue
        if TIMECODE_RE.match(line) or line.isdigit():
            seen_consecutive.clear()
            continue
        line = TAG_RE.sub("", line).replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">")
        if line and line not in seen_consecutive:
            lines.append(line)
            seen_consecutive.add(line)
    return "\n".join(lines).strip() + ("\n" if lines else "")
