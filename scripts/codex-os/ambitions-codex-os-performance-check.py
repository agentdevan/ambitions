#!/usr/bin/env python3
from __future__ import annotations

import json
import hashlib
from datetime import datetime, timezone
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

from ambitions_codex_os_common import (  # noqa: E402
    BUILD_ROOT,
    GENERATED_ROOT,
    architecture_debt_snapshot,
    ensure_dir,
    generated_freshness_state,
    git_head_commit_iso,
    load_json_from_generated,
    repo_doctor_summary_snapshot,
    write_json,
    write_text,
)


def main() -> int:
    ensure_dir(BUILD_ROOT)

    required = [
        "docs/governance/GOVERNANCE_DASHBOARD.md",
        "docs/governance/generated/repo_doctor_summary.md",
        "build/codex-os/ambitions-context-pack.md",
        "build/codex-os/next-action.md",
        "build/codex-os/sync-report.md",
        "build/codex-os/active-authority-map.json",
    ]

    freshness = generated_freshness_state(required)
    gov_summary = load_json_from_generated("governance_reconciliation_summary.json", {})
    stale_count = int(gov_summary.get("stale_overlay_count", 0) or 0) if isinstance(gov_summary, dict) else 0
    unresolved_count = int(gov_summary.get("needs_reconciliation_count", 0) or 0) if isinstance(gov_summary, dict) else 0
    orphan_count = 0
    orphan_report = GENERATED_ROOT / "orphan_prompt_audit.md"
    if orphan_report.exists():
        orphan_count = max(0, sum(1 for line in orphan_report.read_text(encoding="utf-8", errors="replace").splitlines() if line.startswith("| ")) - 2)
    arch = architecture_debt_snapshot()
    repo_doctor = repo_doctor_summary_snapshot()
    next_action_path = BUILD_ROOT / "next-action.json"
    next_action = {}
    if next_action_path.exists():
        next_action = json.loads(next_action_path.read_text(encoding="utf-8"))

    data = {
        "generated_at": git_head_commit_iso(),
        "required_output_count": len(required),
        "present_output_count": freshness["present_count"],
        "missing_output_count": freshness["missing_count"],
        "missing_outputs": freshness["missing"],
        "unresolved_governance_count": unresolved_count,
        "stale_overlay_count": stale_count,
        "orphan_prompt_count": orphan_count,
        "architecture_debt_score": arch.get("score", 0),
        "context_pack_freshness": file_status("build/codex-os/ambitions-context-pack.md"),
        "next_action_freshness": file_status("build/codex-os/next-action.md"),
        "repo_doctor_command_status": repo_doctor.get("overall_status", "missing"),
        "next_action_decision": next_action.get("decision", "missing"),
    }
    write_json("build/codex-os/performance-check.json", data)

    lines = [
        "# Codex OS Performance Check",
        "",
        f"Generated: {data['generated_at']}",
        "",
        f"- Generated outputs present: {data['present_output_count']}/{data['required_output_count']}",
        f"- Missing generated outputs: {data['missing_output_count']}",
        f"- Unresolved governance count: {unresolved_count}",
        f"- Stale overlay count: {stale_count}",
        f"- Orphan prompt count: {orphan_count}",
        f"- Architecture debt score: {arch.get('score', 0)}",
        f"- Repo doctor command status: {data['repo_doctor_command_status']}",
        f"- Context pack freshness: {data['context_pack_freshness'].get('exists', False)}",
        f"- Next-action freshness: {data['next_action_freshness'].get('exists', False)}",
        f"- Next-action decision: {data['next_action_decision']}",
    ]
    write_text("build/codex-os/performance-check.md", "\n".join(lines) + "\n")
    print(json.dumps(data, indent=2, sort_keys=True))
    return 0


def file_status(path: str) -> dict[str, object]:
    candidate = Path(path)
    exists = candidate.exists()
    return {
        "path": path,
        "exists": exists,
        "sha256": hashlib.sha256(candidate.read_bytes()).hexdigest() if exists else "",
    }


if __name__ == "__main__":
    raise SystemExit(main())
