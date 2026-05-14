#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_design_lock_repair_05_common import (
    AUTHORITY_STATUS_MD,
    CONFLICT_REPORT,
    BATCH_ID,
    build_dashboard_conflict_payload,
    write_json,
    write_text,
)


def render_md(payload: dict) -> str:
    lines = [
        "# Final Form Lock Repair 05 Authority Status",
        "",
        f"Status: {payload.get('status', 'unknown').upper()}",
        "",
        f"Batch: `{BATCH_ID}`",
        "",
        "## Canonical Authority",
        "",
        f"- {payload.get('canonical_authority', 'unknown')}",
        "",
        "## Supporting Reports",
        "",
    ]
    for report in payload.get("reports", []):
        lines.append(
            f"- `{report['path']}` -> `{report['role']}` with active scope `{report['active_scope']}` and status `{report['status']}`"
        )
    lines.extend(
        [
            "",
            "## Resolution",
            "",
            "- The new lock packet is the canonical decision surface.",
            "- Historical dashboards remain supporting inputs only.",
        ]
    )
    return "\n".join(lines) + "\n"


def main() -> int:
    payload = build_dashboard_conflict_payload()
    write_json(CONFLICT_REPORT, payload)
    write_text(AUTHORITY_STATUS_MD, render_md(payload))
    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
