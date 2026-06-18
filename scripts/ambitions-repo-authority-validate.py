#!/usr/bin/env python3
"""Validate the active repo authority map."""

from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_PATHS = [
    ROOT / "README.md",
    ROOT / "AGENTS.md",
    ROOT / "docs" / "README.md",
    ROOT / "docs" / "truth" / "README.md",
    ROOT / "docs" / "truth" / "PRODUCT_DESIGN_TRUTH.md",
    ROOT / "docs" / "truth" / "PRODUCT_MOAT_TRUTH.md",
    ROOT / "docs" / "truth" / "IMPLEMENTATION_TRUTH.md",
    ROOT / "docs" / "truth" / "RELEASE_TRUTH.md",
    ROOT / "docs" / "truth" / "CODEX_PROCESS_TRUTH.md",
    ROOT / "docs" / "truth" / "HISTORICAL_POLICY.md",
    ROOT / "docs" / "validation",
    ROOT / "docs" / "audits",
    ROOT / "docs" / "architecture",
    ROOT / "docs" / "codex",
    ROOT / "project.yml",
    ROOT / "Package.swift",
]

SCAN_FILES = [
    ROOT / "README.md",
    ROOT / "AGENTS.md",
    ROOT / "docs" / "README.md",
    ROOT / "docs" / "truth" / "README.md",
    ROOT / "docs" / "truth" / "PRODUCT_DESIGN_TRUTH.md",
    ROOT / "docs" / "truth" / "PRODUCT_MOAT_TRUTH.md",
    ROOT / "docs" / "truth" / "IMPLEMENTATION_TRUTH.md",
    ROOT / "docs" / "truth" / "RELEASE_TRUTH.md",
    ROOT / "docs" / "truth" / "CODEX_PROCESS_TRUTH.md",
    ROOT / ".env.example",
    ROOT / "skills-lock.json",
]

BAD_PHRASES = [
    "Ambitions 2.0",
    "Ambitions_2_0",
    "Ambitions 3.0",
    "Ambitions_3_0",
    "Ambitions 4.0",
    "Ambitions_4_0",
    "EXPO_PUBLIC_SUPABASE",
]

REQUIRED_PORTAL_MARKERS = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
    "docs/validation",
    "docs/audits",
]

OBSOLETE_PORTAL_MARKERS = [
    "frontend/README.md",
    "frontend/installed-canon.md",
    "frontend/intended-canon.md",
    "frontend/visual-encyclopedia",
    "backend/README.md",
    "codex-os/README.md",
    "product-canon/README.md",
    "validation/README.md",
    "history/README.md",
    "docs/canon/README.md",
]


def scan_text(path: Path, text: str, errors: list[str]) -> None:
    lower = text.lower()
    for phrase in BAD_PHRASES:
        if phrase.lower() in lower:
            errors.append(f"{path}: banned active phrase {phrase!r}")


def main() -> int:
    errors: list[str] = []

    for path in REQUIRED_PATHS:
        if not path.exists():
            errors.append(f"missing required path: {path.relative_to(ROOT)}")

    for path in SCAN_FILES:
        if path.exists():
            scan_text(path, path.read_text(encoding="utf-8"), errors)

    docs = (ROOT / "README.md").read_text(encoding="utf-8") if (ROOT / "README.md").exists() else ""
    for marker in REQUIRED_PORTAL_MARKERS:
        if marker not in docs:
            errors.append(f"README.md missing portal marker {marker!r}")

    docs_readme = (ROOT / "docs" / "README.md").read_text(encoding="utf-8") if (ROOT / "docs" / "README.md").exists() else ""
    combined_front_doors = docs + "\n" + docs_readme
    for marker in OBSOLETE_PORTAL_MARKERS:
        if marker in combined_front_doors:
            errors.append(f"front-door docs still reference obsolete authority portal {marker!r}")

    if (ROOT / "skills-lock.json").exists():
        text = (ROOT / "skills-lock.json").read_text(encoding="utf-8")
        if re.search(r'"supabase"|supabase-postgres-best-practices', text, flags=re.IGNORECASE):
            errors.append("skills-lock.json still contains stale provider skill residue")

    if (ROOT / ".env.example").exists():
        text = (ROOT / ".env.example").read_text(encoding="utf-8")
        if re.search(r"supabase|expo_public_supabase", text, flags=re.IGNORECASE):
            errors.append(".env.example still contains stale hosted-backend placeholders")

    print("# Repo Authority Validate")
    if errors:
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1

    print("GREEN: active truth authority paths exist and front-door scans passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
