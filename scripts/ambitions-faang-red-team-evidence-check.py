#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_design_lock_repair_05_common import (
    BATCH_ID,
    RED_TEAM_MD,
    RED_TEAM_REPORT,
    build_red_team_payload,
    render_red_team_md,
    write_json,
    write_text,
)


def main() -> int:
    payload = build_red_team_payload()
    write_json(RED_TEAM_REPORT, payload)
    write_text(RED_TEAM_MD, render_red_team_md(payload))
    print("PASS" if payload.get("status") == "green" else "FAIL")
    return 0 if payload.get("status") == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
