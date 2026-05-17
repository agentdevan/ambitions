#!/usr/bin/env python3
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

from ambitions_codex_os_common import (  # noqa: E402
    BUILD_ROOT,
    architecture_debt_snapshot,
    ensure_dir,
    git_head_commit_iso,
    load_json_from_generated,
    load_text_from_generated,
    repo_doctor_summary_snapshot,
    write_json,
    write_text,
)


def main() -> int:
    ensure_dir(BUILD_ROOT)

    repo_doctor = repo_doctor_summary_snapshot()
    gov_summary = load_json_from_generated("governance_reconciliation_summary.json", {})
    canon_impact = load_json_from_generated("canon_impact_map.json", {})
    cleanup_plan_text = load_text_from_generated("cleanup_action_plan.md", "")
    debt = architecture_debt_snapshot()

    unresolved = int(gov_summary.get("needs_reconciliation_count", 0) or 0) if isinstance(gov_summary, dict) else 0
    stale = int(gov_summary.get("stale_overlay_count", 0) or 0) if isinstance(gov_summary, dict) else 0
    failures = list(repo_doctor.get("failures", [])) if isinstance(repo_doctor, dict) else []
    changed_canon = canon_impact.get("changed_canon_files", []) if isinstance(canon_impact, dict) else []
    retired_canon = canon_impact.get("retired_canon_signals", []) if isinstance(canon_impact, dict) else []

    categories: dict[str, dict[str, object]] = {}
    commands: dict[str, str] = {}

    if failures or unresolved or stale:
        categories["governance repair"] = {
            "signals": [f"repo_doctor_failures:{len(failures)}", f"unresolved:{unresolved}", f"stale:{stale}"],
            "reason": "Governance outputs are not fully reconciled.",
        }
        commands["governance repair"] = "python3 scripts/governance/ambitions-repo-doctor.py --strict"

    if changed_canon or retired_canon:
        categories["canon propagation repair"] = {
            "signals": [*changed_canon[:10], *(f"retired:{item.get('path', '')}" for item in retired_canon[:10] if isinstance(item, dict))],
            "reason": "Canon inputs changed and propagation outputs require refresh.",
        }
        commands["canon propagation repair"] = "python3 scripts/governance/ambitions-canon-installer.py"

    if failures and any("prompt" in str(item).lower() for item in failures):
        categories["prompt rewrite repair"] = {
            "signals": ["repo_doctor reports prompt-related failures"],
            "reason": "Prompt lineage or rewrite outputs need repair.",
        }
        commands["prompt rewrite repair"] = "python3 scripts/governance/ambitions-canon-installer.py"

    if any("frontend" in str(item).lower() or "encyclopedia" in str(item).lower() for item in changed_canon):
        categories["frontend authority repair"] = {
            "signals": ["frontend-related changes or checks were detected"],
            "reason": "Frontend authority outputs should be refreshed.",
        }
        commands["frontend authority repair"] = "python3 scripts/ambitions-frontend-authority-preflight.py"

    if any("encyclopedia" in str(item).lower() for item in changed_canon):
        categories["encyclopedia repair"] = {
            "signals": ["encyclopedia-related canon or authority changes"],
            "reason": "Encyclopedia / frontend OS binding outputs need validation.",
        }
        commands["encyclopedia repair"] = "python3 scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py"

    if unresolved or stale or debt.get("score", 0) < 90:
        categories["global train sequencing repair"] = {
            "signals": [f"debt_score:{debt.get('score', 0)}", f"cleanup_present:{bool(cleanup_plan_text.strip())}"],
            "reason": "Train sequencing should be refreshed when governance debt stays elevated.",
        }
        commands["global train sequencing repair"] = "python3 scripts/governance/ambitions-global-train-resequencer.py"

    if any(
        "validate" in str(item.get("command", "")).lower() or "proof" in str(item.get("command", "")).lower()
        for item in failures
        if isinstance(item, dict)
    ):
        categories["proof/closeout repair"] = {
            "signals": ["repo doctor failures include proof or validation work"],
            "reason": "Closeout proof or lineage may be incomplete.",
        }
        commands["proof/closeout repair"] = "python3 scripts/governance/ambitions-governance-validate.py"

    if cleanup_plan_text.strip():
        categories["archive/shrink repair"] = {
            "signals": ["cleanup plan output exists"],
            "reason": "Archive and shrink recommendations are present.",
        }
        commands["archive/shrink repair"] = "python3 scripts/governance/ambitions-cleanup-action-plan.py"

    if not categories:
        categories["implementation safety repair"] = {
            "signals": [f"architecture_debt_score:{debt.get('score', 0)}"],
            "reason": "No specific repair class dominates, but implementation safety should still be checked.",
        }
        commands["implementation safety repair"] = "python3 scripts/governance/ambitions-generated-freshness-check.py"

    data = {
        "generated_at": git_head_commit_iso(),
        "categories": categories,
        "commands": commands,
        "repo_doctor_overall_status": repo_doctor.get("overall_status", "missing") if isinstance(repo_doctor, dict) else "missing",
        "governance_unresolved": unresolved,
        "governance_stale_overlays": stale,
        "architecture_debt_score": debt.get("score", 0),
    }
    write_json("build/codex-os/repair-plan.json", data)

    lines = [
        "# Codex OS Repair Plan",
        "",
        f"Generated: {data['generated_at']}",
        "",
    ]
    for category, payload in categories.items():
        lines += [f"## {category}", "", str(payload.get("reason", "")), "", "### Signals", ""]
        lines.extend(f"- {item}" for item in payload.get("signals", []))
        lines += ["", "### Command", "", "```bash", commands.get(category, ""), "```", ""]
    write_text("build/codex-os/repair-plan.md", "\n".join(lines).rstrip() + "\n")
    print(json.dumps(data, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
