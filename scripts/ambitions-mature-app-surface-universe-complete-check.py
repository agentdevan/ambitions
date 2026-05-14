#!/usr/bin/env python3
from __future__ import annotations

import json

from ambitions_visual_design_lock_repair_05_common import (
    BATCH_ID,
    UNIVERSE_MD,
    UNIVERSE_REPORT,
    UNIVERSE_YAML,
    build_universe_payload,
    load_inventory,
    load_priority_ids,
    render_lock_packet_md,
    write_json,
    write_json_like_yaml,
    write_text,
)


def render_md(payload: dict) -> str:
    tier_counts = payload.get("surface_tier_counts", {})
    lines = [
        "# Mature App Store Surface Universe",
        "",
        f"Status: {payload.get('status', 'unknown').upper()}",
        "",
        f"Batch: `{BATCH_ID}`",
        "",
        "## Summary",
        "",
        f"- Surface count: {payload.get('surface_count', 0)}",
        f"- Recipe inventory count: {payload.get('recipe_inventory_count', 0)}",
        f"- Non-surface recipe reference count: {payload.get('non_surface_recipe_reference_count', 0)}",
        f"- Missing recipe surface count: {payload.get('missing_recipe_surface_count', 0)}",
        f"- P0 surfaces: {tier_counts.get('P0', 0)}",
        f"- P1 surfaces: {tier_counts.get('P1', 0)}",
        f"- P2 surfaces: {tier_counts.get('P2', 0)}",
        f"- Candidate surfaces: {tier_counts.get('candidate', 0)}",
        f"- Linked surfaces: {payload.get('linked_surface_count', 0)}",
        f"- Intended-only surfaces: {payload.get('intended_only_surface_count', 0)}",
        "",
        "## Scope",
        "",
        "- The universe is derived from the full 159-entry recipe inventory.",
        "- Implementation proof remains explicitly out of scope.",
        "- No extra non-surface entries were needed in this batch.",
    ]
    return "\n".join(lines) + "\n"


def main() -> int:
    payload = build_universe_payload()
    payload["status"] = "green" if payload.get("surface_count") == 159 and payload.get("recipe_inventory_count") == 159 else "yellow"
    write_json_like_yaml(UNIVERSE_YAML, payload)
    write_text(UNIVERSE_MD, render_md(payload))
    write_json(UNIVERSE_REPORT, payload)
    print("PASS" if payload["status"] == "green" else "FAIL")
    return 0 if payload["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
