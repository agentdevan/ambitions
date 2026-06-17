#!/usr/bin/env python3
"""Guard active docs against account, R2, and local-first boundary drift."""
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

SCAN_FILES = [
    ROOT / "docs" / "truth" / "PRODUCT_DESIGN_TRUTH.md",
    ROOT / "docs" / "truth" / "PRODUCT_MOAT_TRUTH.md",
    ROOT / "docs" / "truth" / "IMPLEMENTATION_TRUTH.md",
    ROOT / "docs" / "truth" / "CODEX_PROCESS_TRUTH.md",
    ROOT / "docs" / "codex" / "LOCAL_DATA_CLOUD_BOUNDARY_LAW.md",
    ROOT / "AGENTS.md",
    ROOT / ".codex" / "os" / "AMBITIONS_OPERATING_CONTEXT.md",
]

REQUIRED_PRODUCT_TRUTH_PHRASES = [
    "Ambitions supports custom Ambitions Accounts at launch",
    "The app must remain fully usable without an account",
    "R2 is not a user-data backend",
    "Hosted AI services and cloud LLMs are not core architecture",
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

    product_truth = ROOT / "docs" / "truth" / "PRODUCT_DESIGN_TRUTH.md"
    text = read(product_truth)
    if not text:
        errors.append("missing PRODUCT_DESIGN_TRUTH.md")
    else:
        for phrase in REQUIRED_PRODUCT_TRUTH_PHRASES:
            if phrase not in text:
                errors.append(f"PRODUCT_DESIGN_TRUTH.md missing: {phrase}")

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
            if "not a user-data backend" not in lower and "must never" not in lower:
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
