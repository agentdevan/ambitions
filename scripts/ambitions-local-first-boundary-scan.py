#!/usr/bin/env python3
"""Guard active docs against account, R2, and local-first boundary drift."""
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

SCAN_FILES = [
    ROOT / "docs" / "canon" / "CONSTITUTION.md",
    ROOT / "docs" / "canon" / "specifications" / "systems" / "private-life-runtime.md",
    ROOT / "docs" / "canon" / "specifications" / "systems" / "privacy-and-data-classification.md",
    ROOT / "docs" / "canon" / "specifications" / "systems" / "source-atlas.md",
    ROOT / "docs" / "canon" / "generated" / "CODEX_START_HERE.md",
    ROOT / "AGENTS.md",
    ROOT / "README.md",
    ROOT / "docs" / "README.md",
]

REQUIRED_CONSTITUTION_PHRASES = [
    "fully useful for core value without account sign-in and without network access",
    "MUST NOT own, store, synchronize, profile, or infer from the private life graph",
    "MUST NOT receive, store, infer from, personalize from, or transmit",
    "MUST NOT become a generic AI destination, a hosted-intelligence or cloud-profiling path",
]

REQUIRED_CONTEXT_PHRASES = [
    "offline core",
    "R2",
    "private life graph",
]


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore") if path.exists() else ""


def main() -> int:
    errors: list[str] = []

    constitution = ROOT / "docs" / "canon" / "CONSTITUTION.md"
    text = read(constitution)
    if not text:
        errors.append("missing canonical constitution")
    else:
        for phrase in REQUIRED_CONSTITUTION_PHRASES:
            if phrase not in text:
                errors.append(f"CONSTITUTION.md missing: {phrase}")

    for path in SCAN_FILES:
        if not path.exists():
            continue
        rel = path.relative_to(ROOT)
        doc = read(path)
        lower = doc.lower()

        if "ambitions account" in lower:
            for phrase in ("offline", "private life graph"):
                if phrase not in lower:
                    errors.append(f"{rel}: Ambitions Account mentioned without {phrase!r} boundary")

        if "r2" in lower:
            if not any(marker in lower for marker in (
                "not a user-data backend",
                "must never",
                "must not receive",
                "must not own",
                "public-only",
                "public reference is not private intelligence",
                "never become command or private-graph authority",
            )):
                errors.append(f"{rel}: R2 mentioned without user-data boundary")

        if "hosted ai" in lower or "cloud llm" in lower:
            if "excluded" not in lower and "not core" not in lower and "hard red" not in lower:
                errors.append(f"{rel}: hosted AI/cloud LLM mentioned without exclusion boundary")

    print("# Local-First Boundary Scan")
    if errors:
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1

    print("GREEN: local-first/account/R2/hosted-AI boundary checks passed in active authority files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
