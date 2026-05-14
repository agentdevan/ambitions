#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_design_lock_repair_05_common import (
    BATCH_ID,
    RESIDUE_REPORT,
    build_active_residue_payload,
    write_json,
)


def main() -> int:
    payload = build_active_residue_payload()
    write_json(RESIDUE_REPORT, payload)
    print("PASS" if payload.get("status") == "green" else "FAIL")
    return 0 if payload.get("status") == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
