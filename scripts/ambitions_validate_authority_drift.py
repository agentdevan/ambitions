#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
TARGET_FILES = [
    ROOT / "docs" / "authority" / "AMB_ACTIVE_SOURCE_TRUTH.md",
    ROOT / "docs" / "authority" / "AMB_MOAT_OS_AUTHORITY_MODEL.md",
    ROOT / "docs" / "authority" / "AMB_OBSOLETE_AUTHORITY_REGISTER.md",
    ROOT / "docs" / "authority" / "AMB_ROOT_IA_CANON.md",
    ROOT / "docs" / "authority" / "AMB_POST24_TRUTH_AUDIT.md",
]


def has_forbidden_ia(text: str) -> bool:
    lowered = text.lower()
    if "today / goals / capture / time / you" in lowered:
        return False
    for line in lowered.splitlines():
        m = re.search(r"top-?level.*(?:plan|habits|insights|profile)", line)
        if not m:
            continue
        if "not promoted" in line or "legacy" in line or "historical" in line or "compatibility" in line:
            continue
        return True
    return False


def main() -> int:
    issues = []
    for path in TARGET_FILES:
        if not path.exists():
            issues.append(f"missing file: {path}")
            continue
        text = path.read_text(encoding="utf-8")

        if has_forbidden_ia(text):
            issues.append(f"{path}: top-level authority drift detected")

        if re.search(r"frontend.*owns.*start\s*here", text, re.IGNORECASE):
            issues.append(f"{path}: forbidden Start Here truth ownership to frontend")
        if re.search(r"ui\s+owns.*decision truth", text, re.IGNORECASE):
            issues.append(f"{path}: forbidden UI decision truth ownership")

    if not any(path.exists() for path in TARGET_FILES):
        issues.append("no authority files found")

    if issues:
        print("RED")
        print("\n".join(issues))
        return 1

    print("GREEN")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
