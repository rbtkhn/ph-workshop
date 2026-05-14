from __future__ import annotations

import re
from collections.abc import Iterable


# Keep replacements conservative and recurring. Avoid context-sensitive guesses.
REPLACEMENTS: list[tuple[str, str]] = []


def apply_replacements(text: str, replacements: Iterable[tuple[str, str]] | None = None) -> str:
    output = text
    for pattern, replacement in replacements if replacements is not None else REPLACEMENTS:
        output = re.sub(pattern, replacement, output)
    return output
