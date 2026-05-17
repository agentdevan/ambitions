#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
from datetime import datetime, timezone

GENERATED = Path("docs/governance/generated")
OUT = Path("docs/governance/GOVERNANCE_DASHBOARD.md")


def load_json(name: str, default):
    path = GENERATED / name
    if not path.exists():
        return default
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    summary = load_json("governance_reconciliation_summary.json", {})
    lineage = load_json("train_lineage_graph.json", {"records": {}})
    records = lineage.get("records", {})

    unresolved = [r for r in records.values() if r.get("state") in {"NEEDS_RECONCILIATION", "COMPLETION_CLAIM_UNPROVEN"}]
    orphan_prompts = [r for r in records.values() if r.get("prompt_files") and not r.get("commits")]
    proof_gaps = [r for r in records.values() if str(r.get("state", "")).startswith("COMPLETE") and not r.get("proof_files")]

    lines = [
        "# Ambitions Governance Dashboard",
        "",
        f"Generated: {datetime.now(timezone.utc).isoformat()}",
        "",
        "## Snapshot",
        "",
        f"- Trains detected: {summary.get('train_count', len(records))}",
        f"- Unresolved reconciliation states: {len(unresolved)}",
        f"- Orphan prompt candidates: {len(orphan_prompts)}",
        f"- Completion proof gaps: {len(proof_gaps)}",
        f"- Stale overlay findings: {summary.get('stale_overlay_count', 'unknown')}",
        "",
        "## Highest Priority Fixes",
        "",
    ]

    groups = [
        ("Unresolved reconciliation", unresolved[:20]),
        ("Orphan prompts", orphan_prompts[:20]),
        ("Completion proof gaps", proof_gaps[:20]),
    ]
    for label, items in groups:
        lines.append(f"### {label}")
        lines.append("")
        if not items:
            lines.append("- None detected")
        else:
            for item in items:
                lines.append(f"- `{item.get('train_id')}` — {item.get('state')} / {item.get('confidence')}")
        lines.append("")

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
