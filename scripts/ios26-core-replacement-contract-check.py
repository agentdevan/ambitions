#!/usr/bin/env python3
"""Validate IOS26 core replacement contract installation shape.

This does not prove implementation.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml"
RUNBOOK = ROOT / "docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md"
BATCH_DIR = ROOT / "prompts/batches"
DOCS = [
    ROOT / "docs/codex/IOS26_CORE_REPLACEMENT_P0_CONTRACTS.md",
    ROOT / "docs/codex/IOS26_CORE_REPLACEMENT_JOURNEY_SPEC.md",
    ROOT / "docs/codex/IOS26_CORE_LIFE_OPERATIONS_ARCHITECTURE.md",
]
REQUIRED_ROOTS = [
    "build/reports/core-replacement-contracts/",
    "build/reports/time-operations/",
    "build/reports/reminder-operations/",
    "build/reports/project-step-operations/",
    "build/reports/life-knowledge-operations/",
    "build/reports/life-command-search/",
    "build/reports/private-life-runtime-integration/",
]
REQUIRED_SECTIONS = [
    "## Batch type",
    "## Objective",
    "## End-user job being replaced",
    "## Replacement P0 contract",
    "## Exact source areas to inspect",
    "## Exact changes allowed",
    "## Exact changes forbidden",
    "## Required implementation behavior",
    "## Required tests",
    "## Required proof artifacts",
    "## Accessibility requirements",
    "## Privacy/local-first requirements",
    "## Performance requirements",
    "## Green / Yellow / Red closeout rules",
    "## Rollback strategy",
    "## Final report format",
]
BANNED_TOP_LEVEL = [
    "Assistant tab",
    "Dashboard tab",
    "Calendar tab",
    "Plan tab",
    "Inbox tab",
    "Review tab",
    "Profile tab",
]


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def manifest_batches() -> list[str]:
    return re.findall(r"IOS26-T04[E-K]-B\d{2}", MANIFEST.read_text(encoding="utf-8"))


def skip_line(line: str) -> bool:
    lowered = line.lower()
    return any(word in lowered for word in ["forbidden", "avoid", "red condition", "exact changes forbidden"])


def main() -> int:
    issues: list[str] = []
    for doc in DOCS:
        if not doc.exists():
            issues.append(f"missing {rel(doc)}")
    manifest = MANIFEST.read_text(encoding="utf-8") if MANIFEST.exists() else ""
    runbook = RUNBOOK.read_text(encoding="utf-8") if RUNBOOK.exists() else ""
    for train in [f"TRAIN_04{s}" for s in "EFGHIJK"]:
        if train not in manifest:
            issues.append(f"manifest missing {train}")
    for root in REQUIRED_ROOTS:
        if root not in manifest:
            issues.append(f"manifest missing proof root {root}")
    batches = sorted(set(manifest_batches()))
    if len(batches) != 45:
        issues.append(f"expected 45 T04E-T04K batches, found {len(batches)}")
    for batch in batches:
        matches = sorted(BATCH_DIR.glob(f"{batch}-*.md"))
        if len(matches) != 1:
            issues.append(f"{batch}: expected exactly one batch prompt, found {len(matches)}")
            continue
        prompt = matches[0]
        text = prompt.read_text(encoding="utf-8")
        for section in REQUIRED_SECTIONS:
            if section not in text:
                issues.append(f"{rel(prompt)}: missing {section}")
        command = f"scripts/ambitions-codex-train.sh {batch} {rel(prompt)}"
        if command not in runbook:
            issues.append(f"runbook missing {batch}")
        for line in text.splitlines():
            if skip_line(line):
                continue
            for banned in BANNED_TOP_LEVEL:
                if banned in line:
                    issues.append(f"{rel(prompt)}: banned active top-level IA term `{banned}`")
    if issues:
        for issue in issues:
            print(f"RED: {issue}")
        return 1
    print("GREEN: IOS26 core replacement contract installation shape passed")
    print(f"batches={len(batches)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
