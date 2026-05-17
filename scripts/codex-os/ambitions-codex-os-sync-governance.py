#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

from ambitions_codex_os_common import (  # noqa: E402
    BUILD_ROOT,
    ensure_dir,
    generated_freshness_state,
    git_head_commit_iso,
    read_text,
    repo_doctor_summary_snapshot,
    write_json,
    write_text,
)


COMMANDS = [
    ("repo_doctor", ["python3", "scripts/governance/ambitions-repo-doctor.py"]),
    ("next_action", ["python3", "scripts/codex-os/ambitions-codex-os-next-action.py"]),
    ("batch_selector", ["python3", "scripts/codex-os/ambitions-codex-os-batch-selector.py"]),
    ("repair_router", ["python3", "scripts/codex-os/ambitions-codex-os-repair-router.py"]),
    ("performance_check", ["python3", "scripts/codex-os/ambitions-codex-os-performance-check.py"]),
    ("context_pack", ["python3", "scripts/codex-os/ambitions-codex-os-context-pack.py"]),
]


def run(cmd: list[str]) -> dict[str, object]:
    proc = subprocess.run(cmd, cwd=Path(__file__).resolve().parents[2], text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return {
        "command": " ".join(cmd),
        "returncode": proc.returncode,
        "stdout": proc.stdout.strip(),
        "stderr": proc.stderr.strip(),
    }


def main() -> int:
    ensure_dir(BUILD_ROOT)

    repo_doctor = repo_doctor_summary_snapshot()
    repo_doctor_missing = repo_doctor.get("overall_status") == "missing" or not Path("docs/governance/generated/repo_doctor_summary.md").exists()
    repo_doctor_result = {
        "command": "python3 scripts/governance/ambitions-repo-doctor.py",
        "returncode": 0 if not repo_doctor_missing else 2,
        "stdout": "repo doctor summary already present" if not repo_doctor_missing else "repo doctor summary missing; verification only",
        "stderr": "",
    }

    results = [repo_doctor_result]
    for _name, cmd in COMMANDS[1:]:
        results.append(run(cmd))

    repo_doctor = repo_doctor_summary_snapshot()
    next_action = load_build_json("next-action.json")
    batch_selection = load_build_json("batch-selection.json")
    repair_plan = load_build_json("repair-plan.json")
    perf = load_build_json("performance-check.json")
    freshness = generated_freshness_state()

    data = {
        "generated_at": git_head_commit_iso(),
        "results": results,
        "repo_doctor_status": repo_doctor.get("overall_status", "missing"),
        "repo_doctor_missing": repo_doctor_missing,
        "next_action": next_action,
        "batch_selection": batch_selection,
        "repair_plan_categories": list((repair_plan.get("categories", {}) or {}).keys()) if isinstance(repair_plan, dict) else [],
        "performance_check": perf,
        "generated_output_freshness": freshness,
    }
    write_json("build/codex-os/sync-report.json", data)

    lines = [
        "# Codex OS Sync Report",
        "",
        f"Generated: {data['generated_at']}",
        "",
        f"- Repo doctor status: {data['repo_doctor_status']}",
        f"- Repo doctor missing: {data['repo_doctor_missing']}",
        f"- Next action decision: {next_action.get('decision', 'missing')}",
        f"- Selected batch: {batch_selection.get('selected_batch', 'none')}",
        f"- Performance missing outputs: {perf.get('missing_output_count', 0)}",
        f"- Freshness missing outputs: {freshness.get('missing_count', 0)}",
        "",
        "## Commands",
        "",
    ]
    for item in results:
        lines.append(f"- `{item['command']}` => {item['returncode']}")
    lines += [
        "",
        "## Next Action",
        "",
        str(next_action.get("reason", "No next action recorded.")),
        "",
        "```bash",
        str(next_action.get("command", "")),
        "```",
    ]
    write_text("build/codex-os/sync-report.md", "\n".join(lines).rstrip() + "\n")
    print(json.dumps(data, indent=2, sort_keys=True))
    return 0


def load_build_json(name: str) -> dict[str, object]:
    path = BUILD_ROOT / name
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


if __name__ == "__main__":
    raise SystemExit(main())
