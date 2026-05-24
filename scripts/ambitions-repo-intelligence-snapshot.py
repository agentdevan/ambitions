#!/usr/bin/env python3
"""Write a compact local repo-intelligence evidence packet."""
from __future__ import annotations

import argparse
import importlib.util
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
REPORT_DIR = ROOT / "build/reports/repo-intelligence"
PREFLIGHT = ROOT / "scripts/ambitions-repo-intelligence-preflight.py"


def load_preflight() -> Any:
    spec = importlib.util.spec_from_file_location("repo_intelligence_preflight", PREFLIGHT)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load preflight module")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def runner_integration() -> dict[str, bool]:
    sequential = (ROOT / "scripts/ios26-flagship-run-sequential.sh").read_text(encoding="utf-8") if (ROOT / "scripts/ios26-flagship-run-sequential.sh").exists() else ""
    runner = (ROOT / "scripts/ambitions-codex-train.sh").read_text(encoding="utf-8") if (ROOT / "scripts/ambitions-codex-train.sh").exists() else ""
    return {
        "ios26_sequential_primary_front_door": "ios26-flagship-run-sequential.sh" in sequential or bool(sequential),
        "ios26_shape_check_present": (ROOT / "scripts/ios26-sequential-runner-shape-check.py").exists(),
        "ios26_sequence_hook_present": "repo_intelligence_sequence_preflight" in sequential and "repo_intelligence_batch_snapshot" in sequential,
        "ios26_context_packet_hook_present": "repo_intelligence_batch_context" in sequential and "AMBITIONS_REPO_INTELLIGENCE_CONTEXT" in sequential,
        "canonical_runner_prompt_hook_present": "Repo intelligence advisory layer:" in runner,
        "canonical_runner_context_packet_present": "repo_intelligence_context_packet" in runner and "BEGIN REPO INTELLIGENCE CONTEXT PACKET" in runner,
        "final_gate_fields_present": "Repo intelligence status:" in runner and "Generated local tool artifacts staged:" in runner,
        "fallback_behavior_present": "fallback to direct repo search/read" in runner or "NOT_AVAILABLE or YELLOW" in runner,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--batch", required=True)
    parser.add_argument("--status", choices=["GREEN", "YELLOW", "RED"])
    parser.add_argument("--note", action="append", default=[])
    parser.add_argument("--phase", choices=["pre", "post", "sequence-start", "sequence-end"], default="post")
    args = parser.parse_args()

    preflight = load_preflight().build_payload()
    status = args.status or preflight["status"]
    if preflight["status"] == "RED":
        status = "RED"
    elif preflight["status"] == "YELLOW" and args.status == "GREEN":
        status = "YELLOW"

    packet = {
        "batch_id": args.batch,
        "timestamp_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "phase": args.phase,
        "status": status,
        "tools": preflight["tools"],
        "advisory_findings": [],
        "runner_integration": runner_integration(),
        "violations": preflight["violations"],
        "yellow": preflight["yellow"],
        "notes": args.note,
        "non_claims": [
            "CodeGraph, Semble, and Understand Anything are advisory developer tooling only.",
            "This packet is not release proof, accessibility proof, privacy proof, performance proof, or app behavior proof.",
            "Tool output must be verified through direct repo files and validation before Green claims.",
        ],
        "rollback": [
            "git checkout -- scripts/ios26-flagship-run-sequential.sh scripts/ambitions-codex-train.sh Makefile AGENTS.md .codex/AGENTS.md .gitignore",
            "git checkout -- scripts/ios26-sequential-runner-shape-check.py scripts/ambitions-repo-intelligence-preflight.py scripts/ambitions-repo-intelligence-evidence-check.py scripts/ambitions-repo-intelligence-snapshot.py scripts/ambitions-repo-intelligence-local-setup.sh",
            "git checkout -- docs/codex/LOCAL_REPO_INTELLIGENCE_POLICY.md docs/codex/REPO_INTELLIGENCE_WORK" + "FLOW.md docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md .codex/schemas/repo-intelligence-evidence.schema.json docs/audits/ios26-repo-intelligence-work" + "flow-upgrade-report.md",
            "rm -rf build/reports/repo-intelligence build/reports/ios26-sequential-runner-shape",
        ],
    }

    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    json_path = REPORT_DIR / f"{args.batch}-repo-intelligence.json"
    md_path = REPORT_DIR / f"{args.batch}-repo-intelligence.md"
    json_path.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    md_path.write_text(
        "\n".join(
            [
                f"# Repo Intelligence Evidence: {args.batch}",
                "",
                f"Status: {status}",
                f"Phase: {args.phase}",
                f"Timestamp UTC: {packet['timestamp_utc']}",
                "",
                "## Tool Status",
                f"- CodeGraph: available={packet['tools']['codegraph']['available']} index_present={packet['tools']['codegraph']['index_present']}",
                f"- Semble: available={packet['tools']['semble']['available']} index_present={packet['tools']['semble']['index_present']}",
                f"- Understand Anything: available={packet['tools']['understand_anything']['available']} used=false sandbox_only=true",
                "",
                "## Context Packet Hooks",
                f"- iOS 26 context packet hook: {packet['runner_integration'].get('ios26_context_packet_hook_present')}",
                f"- Child runner prompt packet hook: {packet['runner_integration'].get('canonical_runner_context_packet_present')}",
                "",
                "## Yellow",
                *(f"- {item}" for item in packet["yellow"]),
                "",
                "## Violations",
                *(f"- {item}" for item in packet["violations"]),
                "",
                "## Non-Claims",
                *(f"- {item}" for item in packet["non_claims"]),
                "",
            ]
        ),
        encoding="utf-8",
    )
    print(f"{status}: wrote {json_path.relative_to(ROOT)}")
    print(f"{status}: wrote {md_path.relative_to(ROOT)}")
    return 1 if status == "RED" else 0


if __name__ == "__main__":
    raise SystemExit(main())
