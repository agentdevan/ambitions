#!/usr/bin/env python3
"""Lint bounded LifeContext fixtures for stale/off-domain scenario vocabulary."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

SCAN_TARGETS = [
    "Native/Ambitions/Domain/LifeContextModels.swift",
    "Native/Ambitions/Runtime/PrivateLifeRuntimeKernelContracts.swift",
    "Native/AmbitionsTests/Domain/LifeContextModelsTests.swift",
    "Native/AmbitionsTests/Runtime/LifeContextRuntimeEffectProofTests.swift",
    "Native/AmbitionsTests/Persistence/LifeContextRepositoryTests.swift",
]

BANNED_PATTERNS = [
    r"\bvarsity\b",
    r"\bfootball\b",
    r"\bbasketball\b",
    r"\bWNBA\b",
    r"\bNBA\b",
    r"\bathlete\b",
    r"\bmountain biking\b",
    r"\bmtb\b",
    r"\btrail\b",
    r"\bbike\b",
    r"\bleague pathway\b",
    r"\bindoor conditioning\b",
    r"\blocal ride\b",
    r"\bparent-ride\b",
    r"\btraining block\b",
]


def scoped_text(path: Path, text: str) -> str:
    if path.name == "LifeContextModels.swift":
        marker = "enum LifeContextFixtureProfiles"
        if marker not in text:
            return text
        return text[text.index(marker):]
    return text


def line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def main() -> int:
    failures: list[str] = []
    compiled = [(pattern, re.compile(pattern, re.IGNORECASE)) for pattern in BANNED_PATTERNS]

    for relative_path in SCAN_TARGETS:
        path = ROOT / relative_path
        text = path.read_text(encoding="utf-8")
        body = scoped_text(path, text)
        base_offset = text.index(body)
        for label, pattern in compiled:
            for match in pattern.finditer(body):
                line = line_number(text, base_offset + match.start())
                failures.append(f"{relative_path}:{line}: stale fixture term {label!r} -> {match.group(0)!r}")

    if failures:
        print("RED: stale/off-domain fixture vocabulary remains")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("GREEN: bounded domain fixtures use neutral Ambitions-native scenario vocabulary")
    return 0


if __name__ == "__main__":
    sys.exit(main())
