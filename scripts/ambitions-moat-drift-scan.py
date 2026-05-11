#!/usr/bin/env python3
"""Validate moat-facing source boundaries and vocabulary drift signals."""

from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]

SCAN_FILES = [
    ROOT / "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    ROOT / "docs/truth/PRODUCT_MOAT_TRUTH.md",
    ROOT / "docs/AmbitionsCanon/03_Signature_Object_Specs.md",
    ROOT / "docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md",
    ROOT / "docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md",
    ROOT / "docs/AmbitionsCanon/18_Trust_Receipts_And_Closure_Language.md",
    ROOT / "Native/Ambitions/Domain/AmbitionGraphModels.swift",
    ROOT / "Native/Ambitions/Domain/CaptureModels.swift",
    ROOT / "Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift",
    ROOT / "Native/AmbitionsTests/Domain/CaptureModelsTests.swift",
]

FORBIDDEN_PATTERNS = [
    r"\bbegin focus\b",
    r"\bstart focus\b",
    r"\bbest next move\b",
    r"\bnext best move\b",
    r"\bai recommends\b",
    r"\bcalendar clone\b",
    r"\bfull task list\b",
    r"\bproductivity dashboard\b",
    r"\bchatbot\b",
]

PLAN_Top_LEVEL_PATTERNS = [
    r"\bplan tab\b",
    r"\bplan as a top-level\b",
]

PROFILE_TOP_LEVEL_PATTERNS = [
    r"\bprofile tab\b",
    r"\bprofile screen\b",
]

CAPTURES_Top_LEVEL_PATTERNS = [
    r"\bcaptures tab\b",
    r"\bcaptures as a top-level\b",
]

DAYTIMELINE_PATTERNS = [
    r"\bdaytimelinerail\b",
    r"\breality rail\b",
    r"\bday rail\b",
    r"\bhero step panel\b",
]

NEGATIVE_SECTION_MARKERS = (
    "banned",
    "forbidden",
    "anti-pattern",
    "anti-metric",
    "anti-metrics",
    "antipattern",
    "hard red",
    "avoid",
    "negative",
    "not",
    "never",
    "compatibility",
    "archive",
    "historical",
    "seam",
    "allowed",
)

SECTION_HEADER_MARKERS = (
    "forbidden",
    "banned",
    "anti-pattern",
    "anti-metric",
    "anti-metrics",
    "antipattern",
    "hard red",
    "hard rule",
    "hard rules",
    "hard constraints",
    "compatibility",
    "compatibility seam",
    "compatibility table",
    "codex",
    "operating order",
    "must not",
    "may not",
    "should not",
    "does not",
    "non-goals",
    "non goal",
    "non-moat",
    "non moat",
    "may not show",
    "must not show",
    "may not become",
    "must not become",
    "fails if",
    "hard reds",
    "unapproved",
    "stop and repair if",
    "never",
    "must never",
)


def _is_negated_ban_line(line: str) -> bool:
    lower = line.lower()
    if not re.search(r"\b(no|without|not|never|cannot|can't|must not|may not|should not|does not)\b", lower):
        return False
    return any(re.search(pattern, lower) is not None for pattern in FORBIDDEN_PATTERNS)


def _is_heading(line: str) -> bool:
    return bool(re.match(r"^\s{0,3}#{1,6}\s+", line))


def _is_code_fence(line: str) -> bool:
    return line.strip().startswith("```")


def _is_section_break(line: str) -> bool:
    if _is_code_fence(line):
        return False
    if re.match(r"^\s{0,3}#{1,6}\s+", line):
        return True
    if re.match(r"^\s*(?:-\s+|\d+\.\s+)[^:]+:\s*$", line):
        return True
    stripped = line.strip().lower()
    if stripped.endswith(":"):
        if len(stripped) > 140:
            return False
        return any(token in stripped for token in SECTION_HEADER_MARKERS)
    if stripped.startswith("forbidden") or stripped.startswith("banned") or stripped.startswith("hard red") or stripped.startswith("hard reds") or stripped.startswith("unapproved") or stripped.startswith("fails if") or stripped.startswith("stop and repair if") or stripped.startswith("may not") or stripped.startswith("must not") or stripped.startswith("should not") or stripped.startswith("does not") or stripped.startswith("it does not") or stripped.startswith("must never") or stripped.startswith("never") or stripped.startswith("codex must stop and repair if"):
        if len(stripped) > 160 or stripped.startswith(("-", "*", "+", "|", ">")):
            return False
        return True
    return False


def _is_section_trigger(line: str) -> bool:
    lower = line.lower()
    return any(token in lower for token in SECTION_HEADER_MARKERS)


def _is_comparison_context(line: str) -> bool:
    lower = line.lower()
    return (
        " over " in lower
        and (
            "task list" in lower
            or "calendar clone" in lower
            or "chatbot" in lower
            or "score" in lower
            or "overdue" in lower
        )
    )


def _is_allowed_ban_context(line: str) -> bool:
    lower = line.lower()
    if "closure replaces overdue" in lower:
        return True
    if "passes only if" in lower and ("calendar clone" in lower or "task list" in lower or "chatbot" in lower or "productivity" in lower):
        return True
    return False


def _is_negative_context(line: str) -> bool:
    lower = line.lower()
    return any(token in lower for token in NEGATIVE_SECTION_MARKERS)


def _read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines()


def _matches(patterns: list[str], text: str) -> bool:
    lower = text.lower()
    return any(re.search(pattern, lower) is not None for pattern in patterns)


def main() -> int:
    errors: list[str] = []

    for path in SCAN_FILES:
        if not path.exists():
            continue
        in_negative_section = False
        in_code_block = False
        for index, line in enumerate(_read_lines(path), start=1):
            if _is_code_fence(line):
                in_code_block = not in_code_block
                continue
            if in_code_block:
                continue
            if _is_section_break(line):
                if _is_section_trigger(line):
                    in_negative_section = True
                elif _is_heading(line):
                    in_negative_section = False
                continue
            if _is_comparison_context(line):
                continue
            if _is_allowed_ban_context(line):
                continue
            if in_negative_section:
                continue
            if _is_heading(line):
                in_negative_section = _is_negative_context(line)
                continue
            if line.strip().startswith("|"):
                continue
            if _is_negated_ban_line(line):
                continue

            if _matches(FORBIDDEN_PATTERNS, line):
                errors.append(f"{path}: line {index}: forbidden user-facing phrase {line.strip()!r}")
            if _matches(PLAN_Top_LEVEL_PATTERNS, line):
                errors.append(f"{path}: line {index}: top-level Plan reference {line.strip()!r}")
            if _matches(PROFILE_TOP_LEVEL_PATTERNS, line):
                errors.append(f"{path}: line {index}: top-level Profile reference {line.strip()!r}")
            if _matches(CAPTURES_Top_LEVEL_PATTERNS, line):
                errors.append(f"{path}: line {index}: top-level Captures reference {line.strip()!r}")
            if _matches(DAYTIMELINE_PATTERNS, line):
                errors.append(f"{path}: line {index}: legacy object signature reference {line.strip()!r}")

    print("# Moat Drift Scan")
    if errors:
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1
    print("GREEN: no forbidden moat drift terms found in scanned source/docs")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
