#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
PROMPT_FILES = [
    ROOT / "prompts" / "AMB-MOAT-OS-FINAL-INSTALLER-POST24.md",
]
PROMPT_FILES += sorted((ROOT / "prompts" / "moat-install").glob("*.md"))

REQUIRED_HEADER = [
    "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
    "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
    "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
]
REQUIRED_SECTIONS = [
    "Batch ID",
    "Runner command",
    "Objective",
    "Active source truth to inspect",
    "Allowed scope",
    "Forbidden scope",
    "Validation expectations",
    "Hard Red stop conditions",
    "Rollback expectations",
]
DOWNSTREAM_REQUIRED_SECTIONS = [
    "Implementation requirements",
    "Visual proof expectations",
    "Accessibility expectations",
    "Privacy / trust expectations",
    "Continuity expectations",
    "Expected final report format",
]

def parse_batch_id(text: str) -> str:
    lines = text.splitlines()
    for i, line in enumerate(lines):
        m = re.match(r"^\s*#+\s*Batch ID\s*:\s*(.+)$", line)
        if m:
            return m.group(1).strip()
        m = re.match(r"^\s*#+\s*Batch ID\s*$", line)
        if m:
            next_line = next((x for x in lines[i + 1 :] if x.strip()), "")
            return next_line.strip()
    return ""


def validate_file(path: Path):
    issues: list[str] = []
    text = path.read_text(encoding="utf-8")
    lines = [line.strip("\n") for line in text.splitlines()]

    for i, line in enumerate(REQUIRED_HEADER):
        if len(lines) <= i or lines[i].strip() != line:
            issues.append(f"{path}: missing or misplaced header line '{line}'")

    if "BYPASSES_RUNNER" in text and path.name != "AMB-MOAT-OS-FINAL-INSTALLER-POST24.md":
        issues.append(f"{path}: contains uppercase BYPASSES_RUNNER")

    if re.search(r"direct\s+codex\s+execution", text, re.IGNORECASE) and path.name != "AMB-MOAT-OS-FINAL-INSTALLER-POST24.md":
        issues.append(f"{path}: contains direct Codex execution instructions")

    for section in REQUIRED_SECTIONS:
        if not any(line.startswith("## "+section) or re.match(rf"^{re.escape(section)}\b", line) for line in lines):
            issues.append(f"{path}: missing required section '{section}'")

    if path.parent.name == "moat-install":
        for section in DOWNSTREAM_REQUIRED_SECTIONS:
            if not any(line.startswith("## "+section) or re.match(rf"^{re.escape(section)}\b", line) for line in lines):
                issues.append(f"{path}: missing downstream required section '{section}'")

    batch_id = parse_batch_id(text)
    if not batch_id:
        issues.append(f"{path}: missing Batch ID")

    return batch_id, issues


def main() -> int:
    all_issues: list[str] = []
    seen: dict[str, int] = {}

    for path in PROMPT_FILES:
        if not path.exists():
            all_issues.append(f"missing file: {path}")
            continue
        batch_id, issues = validate_file(path)
        for issue in issues:
            all_issues.append(issue)
        if batch_id:
            seen[batch_id] = seen.get(batch_id, 0) + 1

    dups = [batch_id for batch_id, count in seen.items() if count > 1]
    if dups:
        all_issues.append(f"duplicate Batch IDs: {', '.join(dups)}")

    if all_issues:
        print("RED")
        for issue in all_issues:
            print(issue)
        return 1

    print("GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
