#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def discover_prompt_files() -> list[Path]:
    prompt_root = ROOT / "prompts"
    candidates = [
        prompt_root / "AMB-MOAT-OS-FINAL-INSTALLER-POST24.md",
        *sorted((prompt_root / "ambitions").glob("AMB-CODEX-OS-NO-COST-HARDENING-*.md")),
        *sorted((prompt_root / "batches").glob("AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md")),
        *sorted((prompt_root / "batches").glob("AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T*.md")),
    ]
    return sorted({path for path in candidates if path.exists()})


PROMPT_FILES = discover_prompt_files()


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

    for path in PROMPT_FILES:
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
