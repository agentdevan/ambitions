#!/usr/bin/env python3
"""Validate the repo authority portal cleanup."""

from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_PATHS = [
    ROOT / "README.md",
    ROOT / "frontend" / "README.md",
    ROOT / "frontend" / "installed-canon.md",
    ROOT / "frontend" / "intended-canon.md",
    ROOT / "frontend" / "visual-encyclopedia" / "README.md",
    ROOT / "frontend" / "visual-encyclopedia" / "AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md",
    ROOT / "backend" / "README.md",
    ROOT / "codex-os" / "README.md",
    ROOT / "product-canon" / "README.md",
    ROOT / "validation" / "README.md",
    ROOT / "history" / "README.md",
    ROOT / "docs" / "canon" / "README.md",
    ROOT / "docs" / "status" / "repo-authority-cleanup-baseline.md",
    ROOT / "docs" / "status" / "repo-authority-cleanup-active-path-allowlist.md",
    ROOT / "docs" / "status" / "repo-authority-cleanup-final-report.md",
]

SCAN_FILES = [
    ROOT / "README.md",
    ROOT / "docs" / "README.md",
    ROOT / "docs" / "AGENTS.md",
    ROOT / "frontend" / "README.md",
    ROOT / "frontend" / "installed-canon.md",
    ROOT / "frontend" / "intended-canon.md",
    ROOT / "frontend" / "visual-encyclopedia" / "README.md",
    ROOT / "backend" / "README.md",
    ROOT / "codex-os" / "README.md",
    ROOT / "product-canon" / "README.md",
    ROOT / "validation" / "README.md",
    ROOT / "history" / "README.md",
    ROOT / "docs" / "status" / "repo-authority-cleanup-final-report.md",
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
    "frontend/README.md",
    "backend/README.md",
    "codex-os/README.md",
    "product-canon/README.md",
    "validation/README.md",
    "history/README.md",
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

    frontend_doc = (ROOT / "frontend" / "README.md").read_text(encoding="utf-8") if (ROOT / "frontend" / "README.md").exists() else ""
    if "compatibility-only and not a top-level destination" not in frontend_doc:
        errors.append("frontend/README.md must explicitly demote Plan to compatibility-only")

    canon_doc = (ROOT / "docs" / "canon" / "README.md").read_text(encoding="utf-8") if (ROOT / "docs" / "canon" / "README.md").exists() else ""
    required_canon_markers = [
        "Status: Legacy canon index",
        "must not present Ambitions 2.0, 3.0, or 4.0 as active truth",
        "must not present `Plan` as a top-level destination",
    ]
    for marker in required_canon_markers:
        if marker not in canon_doc:
            errors.append(f"docs/canon/README.md missing legacy marker {marker!r}")
    if "(../frontend/README.md)" in canon_doc:
        errors.append("docs/canon/README.md contains stale relative link to docs/frontend")
    if "../../frontend/README.md" not in canon_doc:
        errors.append("docs/canon/README.md missing root frontend portal link")

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

    print("GREEN: portal paths exist and active-language scans passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
