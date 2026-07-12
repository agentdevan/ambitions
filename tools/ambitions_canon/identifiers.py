"""One authoritative grammar for stable globally unique canon identities."""

from __future__ import annotations

import re


CANONICAL_ID_GRAMMAR = r"[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+"
CANONICAL_ID_PATTERN = re.compile(rf"^{CANONICAL_ID_GRAMMAR}$")


def is_canonical_id(value: object) -> bool:
    return isinstance(value, str) and CANONICAL_ID_PATTERN.fullmatch(value) is not None
