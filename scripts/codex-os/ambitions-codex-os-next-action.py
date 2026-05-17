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
    batch_selection_candidates,
    ensure_dir,
    generated_freshness_state,
    git_head_commit_iso,
    load_json_from_generated,
    repo_doctor_summary_snapshot,
    write_json,
    write_text,
)


def command_record(decision: str, reason: str, command: str, blockers: list[str] | None = None, blocked_reason: str = "") -> dict[str, object]:
    return {
        "generated_at": git_head_commit_iso(),
        "decision": decision,
        "reason": reason,
        "command": command,
        "blockers": blockers or [],
        "blocked_reason": blocked_reason,
    }


def main() -> int:
    ensure_dir(BUILD_ROOT)

    repo_doctor = repo_doctor_summary_snapshot()
    gov_summary = load_json_from_generated("governance_reconciliation_summary.json", {})
    canon_impact = load_json_from_generated("canon_impact_map.json", {})
    resequence = load_json_from_generated("global_train_resequence.json", {})
    implementation_expectation = load_json_from_generated("implementation_expectation_map.json", {})
    freshness = generated_freshness_state()
    debt = architecture_debt_snapshot()

    failures = list(repo_doctor.get("failures", [])) if isinstance(repo_doctor, dict) else []
    overall_status = str(repo_doctor.get("overall_status", "missing")).upper()
    unresolved = int(gov_summary.get("needs_reconciliation_count", 0) or 0) if isinstance(gov_summary, dict) else 0
    stale = int(gov_summary.get("stale_overlay_count", 0) or 0) if isinstance(gov_summary, dict) else 0
    changed_canon_files = canon_impact.get("changed_canon_files", []) if isinstance(canon_impact, dict) else []
    retired_canon = canon_impact.get("retired_canon_signals", []) if isinstance(canon_impact, dict) else []
    resequence_lanes = resequence.get("lanes", []) if isinstance(resequence, dict) else []
    expectation_count = len(implementation_expectation.get("expectations", {})) if isinstance(implementation_expectation, dict) else 0

    decision = "idle"
    reason = "No blocking governance condition was detected."
    command = "python3 scripts/codex-os/ambitions-codex-os-batch-selector.py"
    blockers: list[str] = []
    blocked_reason = ""

    if freshness.get("missing_count", 0):
        decision = "run_repo_doctor"
        reason = "Generated outputs are missing."
        command = "python3 scripts/governance/ambitions-repo-doctor.py"
        blockers = list(freshness.get("missing", []))
    elif overall_status in {"RED", "missing"} or failures or unresolved > 0 or stale > 0:
        decision = "repair_governance"
        reason = "Repo doctor or governance reconciliation still reports unresolved work."
        command = "python3 scripts/codex-os/ambitions-codex-os-repair-router.py"
        blockers = [f"repo_doctor:{overall_status}", f"unresolved:{unresolved}", f"stale:{stale}"]
        blocked_reason = "Governance Red or unresolved reconciliation remains."
    elif changed_canon_files or retired_canon:
        decision = "run_canon_installer"
        reason = "Canon inputs changed and propagation outputs need refresh."
        command = "python3 scripts/governance/ambitions-canon-installer.py"
        blockers = [*changed_canon_files[:8], *(f"retired:{item.get('path', '')}" for item in retired_canon[:8] if isinstance(item, dict))]
        blocked_reason = "Canon propagation is stale."
    elif freshness.get("missing_count", 0) == 0 and not resequence_lanes:
        decision = "run_resequencer"
        reason = "Global train resequence output is missing or incomplete."
        command = "python3 scripts/governance/ambitions-global-train-resequencer.py"
        blocked_reason = "Global sequencing state is not yet generated."
    elif expectation_count == 0:
        decision = "repair_expectations_proof"
        reason = "Implementation expectation map is missing or empty."
        command = "python3 scripts/codex-os/ambitions-codex-os-repair-router.py"
        blockers = [f"expectations:{expectation_count}"]
        blocked_reason = "Implementation expectation map is not populated."
    else:
        selection = batch_selection_candidates()
        selected_batch = str(selection.get("selected_batch", ""))
        if selected_batch:
            decision = "select_next_batch"
            reason = f"No blockers remain; select the safest executable batch ({selected_batch})."
            command = "python3 scripts/codex-os/ambitions-codex-os-batch-selector.py"
        else:
            decision = "idle"
            reason = "No executable batch is currently available."
            command = "python3 scripts/codex-os/ambitions-codex-os-sync-governance.py"

    record = command_record(decision, reason, command, blockers, blocked_reason)
    record["repo_doctor_overall_status"] = overall_status
    record["governance_unresolved"] = unresolved
    record["governance_stale_overlays"] = stale
    record["changed_canon_files"] = changed_canon_files
    record["retired_canon_signals"] = retired_canon
    record["implementation_expectation_count"] = expectation_count
    record["architecture_debt_score"] = debt.get("score", 0)
    record["generated_outputs_missing"] = freshness.get("missing", [])

    write_json("build/codex-os/next-action.json", record)

    lines = [
        "# Codex OS Next Action",
        "",
        f"Generated: {record['generated_at']}",
        "",
        f"Decision: {decision}",
        f"Reason: {reason}",
        "",
        "## Blockers",
        "",
    ]
    if blockers:
        lines.extend(f"- {item}" for item in blockers)
    else:
        lines.append("- None")
    lines += [
        "",
        "## Blocked Reason",
        "",
        blocked_reason or "None",
        "",
        "## Exact Command",
        "",
        "```bash",
        command,
        "```",
        "",
        "## Evidence",
        "",
        f"- repo doctor status: {overall_status}",
        f"- governance unresolved: {unresolved}",
        f"- stale overlays: {stale}",
        f"- architecture debt score: {debt.get('score', 0)}",
        f"- implementation expectations: {expectation_count}",
    ]
    write_text("build/codex-os/next-action.md", "\n".join(lines).rstrip() + "\n")
    print(command)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
