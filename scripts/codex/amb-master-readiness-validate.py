#!/usr/bin/env python3
"""Validate Ambitions Master Build Goal Mode control-plane artifacts."""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ARTIFACT = ROOT / "artifacts/ambitions-master-build"
PROJECT_ID = "ca716546-e3d4-4d5b-a399-03076ccba9ee"
REQUIRED_FILES = [
    ARTIFACT / "AMB_MASTER_GOAL.md",
    ARTIFACT / "AMB_MASTER-run-state.md",
    ARTIFACT / "AMB_MASTER_LINEAR_ISSUE_MAP.md",
    ARTIFACT / "AMB_MASTER_LINEAR_ISSUE_MAP.json",
    ARTIFACT / "AMB_MASTER_EXECUTION_QUEUE.md",
    ARTIFACT / "AMB_MASTER_EXECUTION_QUEUE.json",
    ARTIFACT / "AMB_MASTER_PHASE_GATES.md",
    ROOT / "docs/codex/AMB_MASTER_GREEN_YELLOW_RED_REPORTING.md",
    ROOT / "docs/codex/AMB_MASTER_VALIDATION_REGISTRY.md",
    ROOT / "docs/codex/AMB_MASTER_PROOF_ARTIFACT_CONTRACT.md",
    ROOT / ".agents/skills/ambitions-master-build/SKILL.md",
    ROOT / ".agents/skills/ambitions-master-build/references/amb-master-closeout-template.md",
    ROOT / ".agents/skills/ambitions-master-build/references/amb-master-reviewer-prompts.md",
]
REQUIRED_ISSUES = {"AMB-1126", "AMB-1046", "AMB-1047", "AMB-1048"}
REQUIRED_PHASES = [f"M{i:02d}" for i in range(12)]


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def validate(phase: str | None = None) -> list[str]:
    failures: list[str] = []
    for path in REQUIRED_FILES:
        if not path.exists():
            failures.append(f"missing required file: {path.relative_to(ROOT)}")

    if failures:
        return failures

    issue_map = load_json(ARTIFACT / "AMB_MASTER_LINEAR_ISSUE_MAP.json")
    queue = load_json(ARTIFACT / "AMB_MASTER_EXECUTION_QUEUE.json")
    if issue_map.get("project", {}).get("id") != PROJECT_ID:
        failures.append("issue map project id mismatch")
    if queue.get("project_id") != PROJECT_ID:
        failures.append("execution queue project id mismatch")

    bound_issues = {entry.get("linear_id") for entry in issue_map.get("bindings", [])}
    missing_issues = sorted(REQUIRED_ISSUES.difference(bound_issues))
    if missing_issues:
        failures.append(f"issue map missing required AMB bindings: {missing_issues}")

    queue_issues = {entry.get("linear_id") for entry in queue.get("queue", []) if str(entry.get("linear_id", "")).startswith("AMB-")}
    missing_queue = sorted(REQUIRED_ISSUES.difference(queue_issues))
    if missing_queue:
        failures.append(f"queue missing required AMB bindings: {missing_queue}")

    phase_text = (ARTIFACT / "AMB_MASTER_PHASE_GATES.md").read_text(encoding="utf-8")
    for required_phase in REQUIRED_PHASES:
        if not re.search(rf"^## {required_phase}\b", phase_text, re.MULTILINE):
            failures.append(f"phase gates missing {required_phase}")
    if phase and not re.search(rf"^## {re.escape(phase)}\b", phase_text, re.MULTILINE):
        failures.append(f"phase gate not declared: {phase}")

    combined = "\n".join(path.read_text(encoding="utf-8", errors="ignore") for path in REQUIRED_FILES)
    if "PLOS-" in combined or "PLOS_M" in combined:
        failures.append("amb-master artifacts must not use legacy PLOS labels")
    if re.search(r"Linear issue:\s*M\d", combined):
        failures.append("train label appears in Linear issue field")
    if "AMB_MASTER" not in combined:
        failures.append("amb-master artifact marker missing")
    return failures


def self_test() -> int:
    failures = validate("M00")
    if failures:
        print("FAIL self-test current artifacts invalid")
        for failure in failures:
            print("FAIL " + failure)
        return 1
    print("PASS amb-master readiness validator self-test")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--phase")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        return self_test()
    failures = validate(args.phase)
    for failure in failures:
        print("FAIL " + failure)
    if failures:
        return 1
    print("PASS amb-master readiness artifacts are present and AMB-bound")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
