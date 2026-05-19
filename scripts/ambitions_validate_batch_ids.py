#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
TARGET_DIR = ROOT / "prompts" / "moat-install"
MAIN_PROMPT = ROOT / "prompts" / "AMB-MOAT-OS-FINAL-INSTALLER-POST24.md"


def batch_from_path(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    import re

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


def main() -> int:
    seen = {}
    issues = []

    files = []
    if MAIN_PROMPT.exists():
        files.append(MAIN_PROMPT)
    files.extend(sorted(TARGET_DIR.glob("*.md")))

    for path in files:
        if not path.name.endswith(".md"):
            continue
        text = path.read_text(encoding="utf-8")
        batch_id = batch_from_path(path)
        if not batch_id:
            issues.append(f"{path}: missing Batch ID")
            continue
        expected = path.stem
        if batch_id != expected:
            issues.append(f"{path}: filename/batch mismatch expected {expected} got {batch_id}")
        seen[batch_id] = seen.get(batch_id, 0) + 1
        if not batch_id.startswith("AMB-"):
            issues.append(f"{path}: batch ID missing AMB- prefix: {batch_id}")

    duplicates = [b for b, c in seen.items() if c > 1]
    if duplicates:
        issues.append(f"duplicate batch IDs: {', '.join(duplicates)}")

    if issues:
        print("RED")
        print("\n".join(issues))
        return 1

    print("GREEN")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
