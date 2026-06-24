#!/usr/bin/env python3
"""Validate product vocabulary for moat-facing terms and explicit ban words."""

from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]

SCAN_FILES = [
    ROOT / "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    ROOT / "docs/truth/PRODUCT_MOAT_TRUTH.md",
    ROOT / "docs/truth/PRODUCT_EXPERIENCE_CANON.md",
    ROOT / "docs/truth/CODEX_PROCESS_TRUTH.md",
    ROOT / "AGENTS.md",
]

NEGATIVE_SECTION_MARKERS = (
    "forbidden",
    "banned",
    "anti-pattern",
    "anti-metric",
    "anti-metrics",
    "antipattern",
    "hard red",
    "regression",
    "compatibility",
    "archive",
    "historical",
    "seam",
    "legacy",
    "operating order",
)

SECTION_HEADER_MARKERS = (
    "avoid",
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
    "regression",
    "compatibility",
    "compatibility seam",
    "compatibility table",
    "codex",
    "operating order",
    "legacy",
    "historical",
    "seam",
    "allowed",
    "must not",
    "may not",
    "should not",
    "does not",
    "no ",
    "non-goals",
    "non goal",
    "non-goal",
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
    "is not",
)


def _is_negated_ban_line(line: str) -> bool:
    lower = line.lower()
    if not re.search(r"\b(no|without|not|never|cannot|can't|must not|may not|should not|does not)\b", lower):
        return False
    return any(re.search(rf"\b{re.escape(term.lower())}\b", lower) is not None for term in BANNED)

BANNED = [
    "AI recommends",
    "best next move",
    "next best move",
    "overdue",
    "Begin Focus",
    "Start Focus",
    "calendar clone",
    "task list",
    "streak broken",
    "habit score",
    "life score",
    "productivity score",
    "AI assistant",
    "chatbot",
]

REQUIRED_TERMS = [
    "Ambition",
    "Commitment",
    "Constraint",
    "Recovery",
    "Recommendation Accountability",
    "Proof",
    "Reflection",
    "Private Life Runtime",
    "Reality Meridian",
    "Start Here",
]


def _is_code_fence(line: str) -> bool:
    return line.strip().startswith("```")


def _is_heading(line: str) -> bool:
    return bool(re.match(r"^\s{0,3}#{1,6}\s+", line))


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
    if stripped.startswith("forbidden") or stripped.startswith("banned") or stripped.startswith("hard red") or stripped.startswith("hard reds") or stripped.startswith("regression") or stripped.startswith("unapproved") or stripped.startswith("fails if") or stripped.startswith("stop and repair if") or stripped.startswith("may not") or stripped.startswith("must not") or stripped.startswith("should not") or stripped.startswith("does not") or stripped.startswith("it does not") or stripped.startswith("must never") or stripped.startswith("never") or stripped.startswith("codex must stop and repair if"):
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
            or "productivity" in lower
        )
    )


def _is_allowed_ban_context(line: str) -> bool:
    lower = line.lower()
    if "closure replaces overdue" in lower:
        return True
    if "passes only if" in lower and ("calendar clone" in lower or "task list" in lower or "chatbot" in lower or "productivity" in lower):
        return True
    return False


def main() -> int:
    errors: list[str] = []
    seen_required = {term: False for term in REQUIRED_TERMS}

    for path in SCAN_FILES:
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        lower = text.lower()
        for term in REQUIRED_TERMS:
            if term.lower() in lower:
                seen_required[term] = True

        in_negative_section = False
        in_code_block = False
        for i, line in enumerate(text.splitlines(), start=1):
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
            if _is_negated_ban_line(line):
                continue
            if line.strip().startswith("|"):
                continue
            for term in BANNED:
                if re.search(rf"\b{re.escape(term.lower())}\b", line.lower()) is not None:
                    errors.append(f"{path}: line {i}: banned active copy term {term!r} in line {line.strip()!r}")

    missing = [term for term, present in seen_required.items() if not present]
    for term in missing:
        errors.append(f"missing required moat term in canonical docs: {term}")

    print("# Vocabulary Drift Scan")
    if errors:
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1
    print("GREEN: canonical and active vocabulary terms are present and explicit ban terms are absent")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
