#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
from pathlib import Path

GENERATED = Path("docs/governance/generated")
BUILD = Path("build/codex-os")
OUT = Path("docs/governance/GOVERNANCE_DASHBOARD.md")


def load_json(name: str, default):
    path = GENERATED / name
    if not path.exists():
        return default
    return json.loads(path.read_text(encoding="utf-8"))


def load_build_json(name: str, default):
    path = BUILD / name
    if not path.exists():
        return default
    return json.loads(path.read_text(encoding="utf-8"))


def git_commit_iso() -> str:
    proc = subprocess.run(
        ["git", "show", "-s", "--format=%cI", "HEAD"],
        cwd=Path(__file__).resolve().parents[2],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    text = proc.stdout.strip()
    return text or "unknown"


def main() -> int:
    summary = load_json("governance_reconciliation_summary.json", {})
    lineage = load_json("train_lineage_graph.json", {"records": {}})
    records = lineage.get("records", {})
    next_action = load_build_json("next-action.json", {})
    batch_selection = load_build_json("batch-selection.json", {})
    performance = load_build_json("performance-check.json", {})

    unresolved = [r for r in records.values() if r.get("state") in {"NEEDS_RECONCILIATION", "COMPLETION_CLAIM_UNPROVEN"}]
    orphan_prompts = [r for r in records.values() if r.get("prompt_files") and not r.get("commits")]
    proof_gaps = [r for r in records.values() if str(r.get("state", "")).startswith("COMPLETE") and not r.get("proof_files")]

    lines = [
        "# Ambitions Governance Dashboard",
        "",
        f"Generated: {git_commit_iso()}",
        "",
        "## Snapshot",
        "",
        f"- Trains detected: {summary.get('train_count', len(records))}",
        f"- Unresolved reconciliation states: {len(unresolved)}",
        f"- Orphan prompt candidates: {len(orphan_prompts)}",
        f"- Completion proof gaps: {len(proof_gaps)}",
        f"- Stale overlay findings: {summary.get('stale_overlay_count', 'unknown')}",
        "",
        "## Codex OS Bridge",
        "",
        f"- Next action: {next_action.get('decision', 'missing')}",
        f"- Next command: {next_action.get('command', 'missing')}",
        f"- Selected batch: {batch_selection.get('selected_batch') or 'none'}",
        f"- Performance missing outputs: {performance.get('missing_output_count', 'unknown')}",
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
