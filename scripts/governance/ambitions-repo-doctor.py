#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GENERATED = ROOT / "docs" / "governance" / "generated"
BUILD = ROOT / "build" / "codex-os"
SUMMARY_MD = GENERATED / "repo_doctor_summary.md"
SUMMARY_JSON = GENERATED / "repo_doctor_summary.json"

COMMANDS: list[tuple[str, list[str]]] = [
    ("governance_reconcile", ["python3", "scripts/governance/ambitions-governance-reconcile.py", "--write"]),
    ("canon_impact_map", ["python3", "scripts/governance/ambitions-canon-impact-map.py"]),
    ("canon_propagation_engine", ["python3", "scripts/governance/ambitions-canon-propagation-engine.py"]),
    ("mature_spec_synthesis", ["python3", "scripts/governance/ambitions-spec-synthesis.py"]),
    ("prompt_rewrite_planner", ["python3", "scripts/governance/ambitions-prompt-rewrite-planner.py"]),
    ("supersession_rewriter", ["python3", "scripts/governance/ambitions-supersession-rewriter.py"]),
    ("implementation_expectation_map", ["python3", "scripts/governance/ambitions-implementation-expectation-map.py"]),
    ("global_train_resequencer", ["python3", "scripts/governance/ambitions-global-train-resequencer.py"]),
    ("cleanup_action_plan", ["python3", "scripts/governance/ambitions-cleanup-action-plan.py"]),
    ("architecture_debt_score", ["python3", "scripts/governance/ambitions-architecture-debt-score.py"]),
    ("lineage_confidence_score", ["python3", "scripts/governance/ambitions-lineage-confidence-score.py"]),
    ("governance_dashboard", ["python3", "scripts/governance/ambitions-governance-dashboard.py"]),
    ("governance_trend_report", ["python3", "scripts/governance/ambitions-governance-trend-report.py"]),
    ("authority_diff_report", ["python3", "scripts/governance/ambitions-authority-diff-report.py"]),
    ("historical_registry_extract", ["python3", "scripts/governance/ambitions-historical-registry-extract.py"]),
    ("batch_closeout_validate", ["python3", "scripts/governance/ambitions-batch-closeout-validate.py"]),
    ("governance_validate", ["python3", "scripts/governance/ambitions-governance-validate.py"]),
    ("generated_freshness_check", ["python3", "scripts/governance/ambitions-generated-freshness-check.py"]),
]

BRIDGE_COMMANDS: list[tuple[str, list[str]]] = [
    ("codex_os_next_action", ["python3", "scripts/codex-os/ambitions-codex-os-next-action.py"]),
    ("codex_os_batch_selector", ["python3", "scripts/codex-os/ambitions-codex-os-batch-selector.py"]),
    ("codex_os_repair_router", ["python3", "scripts/codex-os/ambitions-codex-os-repair-router.py"]),
    ("codex_os_performance_check", ["python3", "scripts/codex-os/ambitions-codex-os-performance-check.py"]),
    ("codex_os_sync_governance", ["python3", "scripts/codex-os/ambitions-codex-os-sync-governance.py"]),
]

CONTEXT_COMMAND: tuple[str, list[str]] = (
    "codex_os_context_pack",
    ["python3", "scripts/codex-os/ambitions-codex-os-context-pack.py"],
)

FRESHNESS_COMMAND: tuple[str, list[str]] = (
    "generated_freshness_check",
    ["python3", "scripts/governance/ambitions-generated-freshness-check.py"],
)


def run_command(cmd: list[str], env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    command_env = os.environ.copy()
    if env:
        command_env.update(env)
    return subprocess.run(cmd, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=command_env)


def git_commit_iso() -> str:
    proc = subprocess.run(
        ["git", "show", "-s", "--format=%cI", "HEAD"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    text = proc.stdout.strip()
    return text or "unknown"


def short_stdout(output: str, limit: int = 280) -> str:
    text = output.strip()
    if len(text) <= limit:
        return text
    return text[:limit].rstrip() + " …"


def read_json(path: Path) -> dict[str, object]:
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def accepted_yellow_advisories() -> list[dict[str, object]]:
    advisories: list[dict[str, object]] = []
    governance = read_json(GENERATED / "accepted_yellow_governance_debt.json")
    if governance.get("status") == "ACCEPTED_YELLOW":
        advisories.append({"source": "governance_reconciliation", **governance})

    return advisories


def overall_status_for(args: argparse.Namespace, failures: list[dict[str, object]]) -> str:
    if failures:
        return "RED" if args.strict else "YELLOW"
    return "YELLOW" if accepted_yellow_advisories() else "GREEN"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--strict", action="store_true", help="Exit non-zero if any governance command fails")
    args = parser.parse_args()

    GENERATED.mkdir(parents=True, exist_ok=True)
    BUILD.mkdir(parents=True, exist_ok=True)

    core_results: list[dict[str, object]] = []
    bridge_results: list[dict[str, object]] = []
    failures: list[dict[str, object]] = []

    for name, cmd in COMMANDS:
        print(f"RUNNING: {' '.join(cmd)}")
        bridge_env = {"CODEX_OS_SKIP_REPO_DOCTOR": "1"} if name == "codex_os_sync_governance" else None
        proc = run_command(cmd, env=bridge_env)
        entry = {
            "name": name,
            "command": " ".join(cmd),
            "returncode": proc.returncode,
            "stdout": short_stdout(proc.stdout),
            "stderr": short_stdout(proc.stderr),
        }
        core_results.append(entry)
        if proc.returncode != 0:
            failures.append(entry)
            print(f"FAILED: {' '.join(cmd)}")

    provisional_summary = {
        "generated_at": git_commit_iso(),
        "strict_mode": args.strict,
        "overall_status": overall_status_for(args, failures),
        "command_results": core_results,
        "failures": failures,
        "failure_count": len(failures),
        "success_count": len(core_results) - len(failures),
        "command_names": [name for name, _cmd in COMMANDS],
        "generated_outputs": [
            "docs/governance/GOVERNANCE_DASHBOARD.md",
            "docs/governance/generated/repo_doctor_summary.md",
            "docs/governance/generated/repo_doctor_summary.json",
            "build/codex-os/active-authority-map.json",
            "build/codex-os/ambitions-context-pack.md",
            "build/codex-os/next-action.json",
            "build/codex-os/next-action.md",
            "build/codex-os/batch-selection.json",
            "build/codex-os/batch-selection.md",
            "build/codex-os/repair-plan.json",
            "build/codex-os/repair-plan.md",
            "build/codex-os/performance-check.json",
            "build/codex-os/performance-check.md",
            "build/codex-os/sync-report.json",
            "build/codex-os/sync-report.md",
        ],
        "repo_root": str(ROOT),
        "command_status": {
            "normal_mode_collect_all": True,
            "strict_mode_exit_nonzero_on_failure": args.strict and bool(failures),
        },
    }

    SUMMARY_JSON.write_text(json.dumps(provisional_summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    for name, cmd in BRIDGE_COMMANDS:
        print(f"RUNNING: {' '.join(cmd)}")
        proc = run_command(cmd)
        entry = {
            "name": name,
            "command": " ".join(cmd),
            "returncode": proc.returncode,
            "stdout": short_stdout(proc.stdout),
            "stderr": short_stdout(proc.stderr),
        }
        bridge_results.append(entry)
        if proc.returncode != 0:
            failures.append(entry)
            print(f"FAILED: {' '.join(cmd)}")

    overall_status = overall_status_for(args, failures)

    summary = dict(provisional_summary)
    summary.update(
        {
            "generated_at": git_commit_iso(),
            "overall_status": overall_status,
            "command_results": core_results + bridge_results,
            "failures": failures,
            "accepted_yellow_advisories": accepted_yellow_advisories(),
            "failure_count": len(failures),
            "success_count": len(core_results) + len(bridge_results) - len(failures),
            "command_status": {
                "normal_mode_collect_all": True,
                "strict_mode_exit_nonzero_on_failure": args.strict and bool(failures),
                "codex_os_context_refreshed": any(item["name"] == "codex_os_context_pack" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_next_action_refreshed": any(item["name"] == "codex_os_next_action" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_batch_selection_refreshed": any(item["name"] == "codex_os_batch_selector" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_repair_router_refreshed": any(item["name"] == "codex_os_repair_router" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_performance_refreshed": any(item["name"] == "codex_os_performance_check" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_sync_refreshed": any(item["name"] == "codex_os_sync_governance" and item["returncode"] == 0 for item in bridge_results),
            },
            "bridge_results": bridge_results,
        }
    )

    SUMMARY_JSON.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    print(f"RUNNING: {' '.join(CONTEXT_COMMAND[1])}")
    proc = run_command(CONTEXT_COMMAND[1])
    context_entry = {
        "name": CONTEXT_COMMAND[0],
        "command": " ".join(CONTEXT_COMMAND[1]),
        "returncode": proc.returncode,
        "stdout": short_stdout(proc.stdout),
        "stderr": short_stdout(proc.stderr),
    }
    bridge_results.append(context_entry)
    if proc.returncode != 0:
        failures.append(context_entry)
        print(f"FAILED: {' '.join(CONTEXT_COMMAND[1])}")

    overall_status = overall_status_for(args, failures)

    summary.update(
        {
            "generated_at": git_commit_iso(),
            "overall_status": overall_status,
            "command_results": core_results + bridge_results,
            "failures": failures,
            "accepted_yellow_advisories": accepted_yellow_advisories(),
            "failure_count": len(failures),
            "success_count": len(core_results) + len(bridge_results) - len(failures),
            "command_status": {
                "normal_mode_collect_all": True,
                "strict_mode_exit_nonzero_on_failure": args.strict and bool(failures),
                "codex_os_context_refreshed": any(item["name"] == "codex_os_context_pack" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_next_action_refreshed": any(item["name"] == "codex_os_next_action" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_batch_selection_refreshed": any(item["name"] == "codex_os_batch_selector" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_repair_router_refreshed": any(item["name"] == "codex_os_repair_router" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_performance_refreshed": any(item["name"] == "codex_os_performance_check" and item["returncode"] == 0 for item in bridge_results),
            },
            "bridge_results": bridge_results,
        }
    )

    SUMMARY_JSON.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    print(f"RUNNING: {' '.join(FRESHNESS_COMMAND[1])}")
    proc = run_command(FRESHNESS_COMMAND[1], env={"CODEX_OS_SKIP_REPO_DOCTOR": "1"})
    freshness_entry = {
        "name": FRESHNESS_COMMAND[0],
        "command": " ".join(FRESHNESS_COMMAND[1]),
        "returncode": proc.returncode,
        "stdout": short_stdout(proc.stdout),
        "stderr": short_stdout(proc.stderr),
    }
    bridge_results.append(freshness_entry)
    if proc.returncode != 0:
        failures.append(freshness_entry)
        print(f"FAILED: {' '.join(FRESHNESS_COMMAND[1])}")

    overall_status = overall_status_for(args, failures)

    summary.update(
        {
            "generated_at": git_commit_iso(),
            "overall_status": overall_status,
            "command_results": core_results + bridge_results,
            "failures": failures,
            "accepted_yellow_advisories": accepted_yellow_advisories(),
            "failure_count": len(failures),
            "success_count": len(core_results) + len(bridge_results) - len(failures),
            "command_status": {
                "normal_mode_collect_all": True,
                "strict_mode_exit_nonzero_on_failure": args.strict and bool(failures),
                "codex_os_context_refreshed": any(item["name"] == "codex_os_context_pack" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_next_action_refreshed": any(item["name"] == "codex_os_next_action" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_batch_selection_refreshed": any(item["name"] == "codex_os_batch_selector" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_repair_router_refreshed": any(item["name"] == "codex_os_repair_router" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_performance_refreshed": any(item["name"] == "codex_os_performance_check" and item["returncode"] == 0 for item in bridge_results),
                "codex_os_sync_refreshed": any(item["name"] == "codex_os_sync_governance" and item["returncode"] == 0 for item in bridge_results),
                "generated_freshness_refreshed": any(item["name"] == "generated_freshness_check" and item["returncode"] == 0 for item in bridge_results),
            },
            "bridge_results": bridge_results,
        }
    )

    SUMMARY_JSON.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    md_lines = [
        "# Repo Doctor Summary",
        "",
        f"Generated: {summary['generated_at']}",
        f"Overall status: {overall_status}",
        f"Strict mode requested: {args.strict}",
        f"Failures: {len(failures)}",
        "",
        "## Command Results",
        "",
        "| Name | Status | Command |",
        "|---|---|---|",
    ]
    for item in core_results + bridge_results:
        status = "GREEN" if item["returncode"] == 0 else "RED"
        md_lines.append(f"| {item['name']} | {status} | `{item['command']}` |")

    md_lines += [
        "",
        "## Failure Details",
        "",
    ]
    if failures:
        for item in failures:
            md_lines.append(f"- `{item['command']}` => {item['returncode']}")
            stdout = str(item["stdout"])
            stderr = str(item["stderr"])
            if stdout:
                md_lines.append(f"  - stdout: {stdout}")
            if stderr:
                md_lines.append(f"  - stderr: {stderr}")
    else:
        md_lines.append("- None")

    accepted_yellows = accepted_yellow_advisories()
    md_lines += [
        "",
        "## Accepted Yellow Advisories",
        "",
    ]
    if accepted_yellows:
        for item in accepted_yellows:
            owner = item.get("owner", "unknown")
            reason = item.get("reason", "accepted Yellow evidence recorded")
            source = item.get("source", "unknown")
            md_lines.append(f"- `{source}` — owner: {owner}; reason: {reason}")
    else:
        md_lines.append("- None")

    md_lines += [
        "",
        "## Codex OS Bridge",
        "",
        f"- Context pack refreshed: {summary['command_status']['codex_os_context_refreshed']}",
        f"- Next action refreshed: {summary['command_status']['codex_os_next_action_refreshed']}",
        f"- Batch selector refreshed: {summary['command_status']['codex_os_batch_selection_refreshed']}",
        f"- Repair router refreshed: {summary['command_status']['codex_os_repair_router_refreshed']}",
        f"- Performance check refreshed: {summary['command_status']['codex_os_performance_refreshed']}",
        f"- Sync report refreshed: {summary['command_status']['codex_os_sync_refreshed']}",
        f"- Generated freshness refreshed: {summary['command_status']['generated_freshness_refreshed']}",
        "",
        "## Result",
        "",
    ]
    if failures:
        md_lines.append("Governance Red remains or governance advisories remain unresolved.")
    elif accepted_yellows:
        md_lines.append("Repo doctor strict path passed with explicit accepted Yellow advisories.")
    else:
        md_lines.append("Repo doctor passed.")

    SUMMARY_MD.write_text("\n".join(md_lines).rstrip() + "\n", encoding="utf-8")

    print(f"Ambitions repo doctor completed with {len(failures)} failure(s).")
    print(f"Summary: {SUMMARY_MD}")
    return 1 if args.strict and failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
