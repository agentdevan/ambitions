#!/usr/bin/env python3
"""Audit active canon for stale paths and active stale product vocabulary."""

from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
CANON_DIR = ROOT / "docs" / "canon"

REPO_PREFIXES = (
    ".agents/",
    "AGENTS.md",
    "Packages/AmbitionsDesignSystem/AppUI/",
    "Native/",
    "Packages/AmbitionsDesignSystem/Package.swift",
    "Packages/",
    "README.md",
    "Packages/AmbitionsDesignSystem/Sources/",
    "docs/",
    "project.yml",
    "scripts/",
    "tools/",
)

PLANNED_PATH_MARKERS = (
    "planned script",
    "planned path",
    "planned/internal",
    "future validation",
    "future script",
    "canonical owner",
    "architecture tree",
)

STALE_ACTIVE_TERMS = {
    "Reality Meridian": "Today = Reality Window",
    "Constellation Atlas": "Goals = Life Area Atlas",
    "LifeShape Field": "Time = native Life Calendar",
    "Atmosphere Composer": "Capture = global typed route graph + full-screen Stage composer",
    "Open Field": "Capture = global typed route graph + full-screen Stage composer",
    "User System Profile": "You = local settings, personalization, privacy, learning, Source, receipts, and account controls",
    "Motion Current": "Motion = Stage/Motion behavior",
    "Recommended next move": "Recommended step",
    "best next move": "Recommended step",
}

ALLOWED_STALE_CONTEXT_MARKERS = (
    "avoid", "forbidden", "legacy", "internal", "compatibility", "historical", "old",
    "not user-facing", "not appear", "must not", "may remain", "over ", "translation",
    "source/type", "source or architecture inventory", "internal / weak phrase",
)

STALE_CONTEXT_SECTION_MARKERS = (
    "avoid", "forbidden", "legacy", "internal", "compatibility", "historical", "translation", "anti-regression", "anti-regressions",
)


def _strip_fenced_blocks(text: str) -> str:
    return re.sub(r"```.*?```", "", text, flags=re.S)


def _inline_code_spans(line: str) -> list[str]:
    return [match.group(1).strip() for match in re.finditer(r"`([^`]+)`", line)]


def _is_repo_path_candidate(value: str, document_paths: dict[str, list[Path]]) -> bool:
    if not value or "://" in value or "*" in value or value.startswith("."):
        return False
    return value in document_paths or value.startswith(REPO_PREFIXES)


def _resolve_candidate(path: Path, value: str, document_paths: dict[str, list[Path]]) -> Path:
    clean = value.rstrip(".,;:")
    line_reference = re.fullmatch(r"(.+):(\d+)", clean)
    if line_reference:
        clean = line_reference.group(1)
    if clean in document_paths and len(document_paths[clean]) == 1:
        return document_paths[clean][0]
    if clean.startswith("../"):
        return (path.parent / clean).resolve()
    return ROOT / clean


def _planned_path_allowed(line: str) -> bool:
    return any(marker in line.lower() for marker in PLANNED_PATH_MARKERS)


def _stale_context_allowed(line: str) -> bool:
    return any(marker in line.lower() for marker in ALLOWED_STALE_CONTEXT_MARKERS)


def _is_heading(line: str) -> bool:
    return bool(re.match(r"^\s{0,3}#{1,6}\s+", line))


def _starts_context_section(line: str) -> bool:
    lower = line.strip().lower()
    if _is_heading(line):
        return any(marker in lower for marker in STALE_CONTEXT_SECTION_MARKERS)
    return lower.endswith(":") and len(lower) <= 140 and any(marker in lower for marker in STALE_CONTEXT_SECTION_MARKERS)


def main() -> int:
    missing_paths: list[str] = []
    stale_terms: list[str] = []
    documents = sorted(CANON_DIR.rglob("*.md"))
    document_paths: dict[str, list[Path]] = {}
    for document in documents:
        document_paths.setdefault(document.name, []).append(document)

    for path in documents:
        text = _strip_fenced_blocks(path.read_text(encoding="utf-8"))
        in_allowed_stale_section = False
        for line_number, line in enumerate(text.splitlines(), start=1):
            if _starts_context_section(line):
                in_allowed_stale_section = True
                continue
            if _is_heading(line):
                in_allowed_stale_section = False

            for value in _inline_code_spans(line):
                if not _is_repo_path_candidate(value, document_paths):
                    continue
                candidate = _resolve_candidate(path, value, document_paths)
                try:
                    candidate.relative_to(ROOT)
                except ValueError:
                    continue
                if candidate.exists() or _planned_path_allowed(line):
                    continue
                missing_paths.append(f"{path.relative_to(ROOT)}:{line_number}: missing `{value}`")

            if in_allowed_stale_section or _stale_context_allowed(line):
                continue
            for term, replacement in STALE_ACTIVE_TERMS.items():
                if re.search(rf"(?<!\w){re.escape(term)}(?!\w)", line, re.IGNORECASE):
                    stale_terms.append(f"{path.relative_to(ROOT)}:{line_number}: active stale term `{term}`; use {replacement}")

    print("# Ambitions Canon Path/Vocabulary Audit")
    if missing_paths or stale_terms:
        for item in missing_paths + stale_terms:
            print(f"RED: {item}", file=sys.stderr)
        return 1
    print("GREEN: active canon paths resolve and active stale terms are quarantined")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
