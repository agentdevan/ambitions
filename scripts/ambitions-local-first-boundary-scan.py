#!/usr/bin/env python3
"""Guard against accidental architecture drift away from local-first and on-device assumptions."""

from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]

SCAN_FILES = [
    ROOT / "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    ROOT / "docs/truth/PRODUCT_MOAT_TRUTH.md",
    ROOT / "docs/AmbitionsCanon/03_Signature_Object_Specs.md",
    ROOT / "docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md",
    ROOT / "docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md",
    ROOT / "docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md",
    ROOT / "Native/Ambitions/Domain/AmbitionGraphModels.swift",
    ROOT / "Native/Ambitions/Domain/CaptureModels.swift",
    ROOT / "Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift",
    ROOT / "Native/AmbitionsTests/Domain/CaptureModelsTests.swift",
]

FORBIDDEN_PHRASES = [
    r"cloud\s+llm",
    r"custom\s+hosted\s+backend",
    r"personal\s+data\s+backend",
    r"account\s+required",
    r"user\s+auth",
    r"server-side\s+recommend",
    r"external\s+ai",
    r"openai",
    r"gpt-",
    r"chatgpt",
]

BANNED_CLAIM_PHRASES = [
    r"release\s+ready",
    r"testflight\s+ready",
    r"app\s+store\s+ready",
    r"privacy\s+approval",
    r"accessibility\s+approved",
]

NEGATIVE_SECTION_MARKERS = (
    "forbidden",
    "banned",
    "anti-pattern",
    "antipattern",
    "hard red",
    "hard rule",
    "hard rules",
    "hard constraints",
    "compatibility",
    "compatibility seam",
    "legacy",
    "historical",
    "archive",
    "codex",
    "operating order",
    "external/cloud",
    "quality bar",
    "no external",
    "external/cloud llm",
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
    "fails if",
    "hard reds",
    "unapproved",
    "stop and repair if",
    "never",
    "must never",
)


def _is_heading(line: str) -> bool:
    return bool(re.match(r"^\s{0,3}#{1,6}\s+", line))


def _is_code_fence(line: str) -> bool:
    return line.strip().startswith("```")


def _is_section_break(line: str) -> bool:
    if line.strip().startswith("```"):
        return False
    if _is_heading(line):
        return True
    if re.match(r"^\s*(?:-\s+|\d+\.\s+)[^:]+:\s*$", line):
        return True
    stripped = line.strip().lower()
    if stripped.endswith(":"):
        if len(stripped) > 140:
            return False
        return any(token in stripped for token in NEGATIVE_SECTION_MARKERS)
    if stripped.startswith("forbidden") or stripped.startswith("banned") or stripped.startswith("hard red") or stripped.startswith("hard reds") or stripped.startswith("unapproved") or stripped.startswith("fails if") or stripped.startswith("stop and repair if") or stripped.startswith("may not") or stripped.startswith("must not") or stripped.startswith("should not") or stripped.startswith("does not") or stripped.startswith("it does not") or stripped.startswith("must never") or stripped.startswith("never") or stripped.startswith("codex must stop and repair if"):
        if len(stripped) > 160 or stripped.startswith(("-", "*", "+", "|", ">")):
            return False
        return True
    return False


def _is_section_trigger(line: str) -> bool:
    lower = line.lower()
    return any(token in lower for token in NEGATIVE_SECTION_MARKERS)


def _line_hits(patterns: list[str], line: str) -> bool:
    lower = line.lower()
    return any(re.search(pattern, lower) is not None for pattern in patterns)


def main() -> int:
    errors: list[str] = []

    for path in SCAN_FILES:
        if not path.exists():
            continue
        in_negative_section = False
        in_code_block = False
        for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
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
            if in_negative_section:
                continue

            stripped = line.strip()
            lower = stripped.lower()
            if not stripped:
                continue
            if lower.startswith("|") or lower.startswith("//"):
                continue
            if "xctassert" in lower or "let combined" in lower or "release candidate" in lower or "expected phrase" in lower or "check." in lower:
                continue
            if re.search(r"apple\\s*/\\s*openai\\s*/\\s*meta", lower):
                continue

            if _line_hits(FORBIDDEN_PHRASES, line):
                errors.append(f"{path}: line {i}: forbidden external-boundary phrase {line.strip()!r}")
            if _line_hits(BANNED_CLAIM_PHRASES, line):
                errors.append(f"{path}: line {i}: unverified claim phrase {line.strip()!r}")

    print("# Local-First Boundary Scan")
    if errors:
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1
    print("GREEN: local-first and claim-boundary checks passed in scanned files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
