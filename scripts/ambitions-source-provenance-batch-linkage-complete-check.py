#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_design_lock_repair_05_common import (
    BATCH_ID,
    PROVENANCE_MD,
    PROVENANCE_REPORT,
    PROVENANCE_YAML,
    build_provenance_payload,
    write_json,
    write_json_like_yaml,
    write_text,
)


def render_md(payload: dict) -> str:
    lines = [
        "# Visual Source Provenance And Batch Linkage",
        "",
        f"Status: {payload.get('status', 'unknown').upper()}",
        "",
        f"Batch: `{BATCH_ID}`",
        "",
        "## Summary",
        "",
        f"- Inventory count: {payload.get('inventory_count', 0)}",
        f"- Provenance row count: {payload.get('provenance_row_count', 0)}",
        f"- Linked count: {payload.get('linked_count', 0)}",
        f"- Planned batch count: {payload.get('planned_batch_count', 0)}",
        f"- Not-found batch count: {payload.get('not_found_count', 0)}",
        f"- Needs-direction count: {payload.get('needs_direction_count', 0)}",
        "",
        "## Boundary",
        "",
        "- This is provenance and batch linkage, not implementation proof.",
        "- Null or not-found fields are explicit when the repo does not provide direct evidence.",
    ]
    return "\n".join(lines) + "\n"


def main() -> int:
    payload = build_provenance_payload()
    payload["status"] = "green" if payload.get("provenance_row_count") == payload.get("inventory_count") else "yellow"
    write_json_like_yaml(PROVENANCE_YAML, payload)
    write_text(PROVENANCE_MD, render_md(payload))
    write_json(PROVENANCE_REPORT, payload)
    print("PASS" if payload["status"] == "green" else "FAIL")
    return 0 if payload["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
