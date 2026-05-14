from __future__ import annotations

import re


def light_clean(text: str) -> str:
    """Apply conservative whitespace cleanup without changing wording."""
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip() + ("\n" if text.strip() else "")
