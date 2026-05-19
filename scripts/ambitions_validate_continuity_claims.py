#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "docs" / "continuity" / "AMB_APPLE_CONTINUITY_CONFLICT_RESTORE_SPEC.md"
REQUIRED = [
    "local_only",
    "unavailable",
    "enabled",
    "sync_pending",
    "partial_restore",
    "restore_checkpoint",
    "conflict_detected",
    "conflict_receipt",
    "migration_required",
    "migration_complete",
    "source_freshness_degraded_after_restore",
    "new_device_restore",
]


def main() -> int:
    if not PATH.exists():
        print("RED")
        print(f"missing file: {PATH}")
        return 1

    text = PATH.read_text(encoding="utf-8").lower()
    missing = [item for item in REQUIRED if item not in text]
    if missing:
        print("RED")
        print(f"missing continuity states: {', '.join(missing)}")
        return 1

    print("GREEN")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
