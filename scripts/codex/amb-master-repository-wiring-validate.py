#!/usr/bin/env python3
"""Validate amb-master repository wiring and quarantine boundaries."""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ARTIFACT = ROOT / "artifacts/ambitions-master-build"
PROJECT_ID = "ca716546-e3d4-4d5b-a399-03076ccba9ee"
AMB_1047_SHA = "8f5cfc1dae8c684571e17dabba765eb937ab2169"

REQUIRED_DISPATCH = {
    "scripts/codex/program-preflight.sh": [
        "amb-master|amb_master|AMB-MASTER|AMB_MASTER|master-build|MASTER-BUILD",
        "artifacts/ambitions-master-build",
        "scripts/codex/amb-master-readiness-validate.py",
        "scripts/codex/amb-master-canon-ia-validate.py",
    ],
    "scripts/codex/program-phase-gate.sh": [
        "amb-master|amb_master|AMB-MASTER|AMB_MASTER|master-build|MASTER-BUILD",
        "artifacts/ambitions-master-build/AMB_MASTER_PHASE_GATES.md",
        "scripts/codex/amb-master-readiness-validate.py --phase",
    ],
    "scripts/codex/program-proof-index.sh": [
        "amb-master|amb_master|AMB-MASTER|AMB_MASTER|master-build|MASTER-BUILD",
        "artifacts/ambitions-master-build",
    ],
    "scripts/codex/program-closeout-check.sh": [
        "amb-master|amb_master|AMB-MASTER|AMB_MASTER|master-build|MASTER-BUILD",
        "artifacts/ambitions-master-build",
    ],
    "scripts/codex/linear-closeout-validate.py": [
        "AMB_MASTER_CHILD_REQUIRED",
        PROJECT_ID,
        "AMB-1048",
    ],
}

REQUIRED_EXECUTABLES = [
    "scripts/codex/amb-master-readiness-validate.py",
    "scripts/codex/amb-master-canon-ia-validate.py",
    "scripts/codex/amb-master-repository-wiring-validate.py",
    ".agents/skills/ambitions-master-build/scripts/amb-master-preflight.sh",
    ".agents/skills/ambitions-master-build/scripts/amb-master-phase-gate.sh",
]

AMB_MASTER_ACTIVE_FILES = [
    "artifacts/ambitions-master-build/AMB_MASTER_GOAL.md",
    "artifacts/ambitions-master-build/AMB_MASTER-run-state.md",
    "artifacts/ambitions-master-build/AMB_MASTER_LINEAR_ISSUE_MAP.md",
    "artifacts/ambitions-master-build/AMB_MASTER_LINEAR_ISSUE_MAP.json",
    "artifacts/ambitions-master-build/AMB_MASTER_EXECUTION_QUEUE.md",
    "artifacts/ambitions-master-build/AMB_MASTER_EXECUTION_QUEUE.json",
    "artifacts/ambitions-master-build/AMB_MASTER_PHASE_GATES.md",
    "docs/codex/AMB_MASTER_GREEN_YELLOW_RED_REPORTING.md",
    "docs/codex/AMB_MASTER_VALIDATION_REGISTRY.md",
    "docs/codex/AMB_MASTER_PROOF_ARTIFACT_CONTRACT.md",
    ".agents/skills/ambitions-master-build/SKILL.md",
    ".agents/skills/ambitions-master-build/references/amb-master-closeout-template.md",
    ".agents/skills/ambitions-master-build/references/amb-master-reviewer-prompts.md",
]


def read(rel: str) -> str:
    path = ROOT / rel
    return path.read_text(encoding="utf-8", errors="ignore") if path.exists() else ""


def load_json(rel: str) -> dict:
    return json.loads(read(rel))


def git_output(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )


def check(condition: bool, failures: list[str], message: str) -> None:
    if not condition:
        failures.append(message)


def validate() -> list[str]:
    failures: list[str] = []

    registry = read("docs/codex-os/PROGRAM_REGISTRY.md")
    check("## AMB-MASTER - Personal Life OS Runtime + Native iPhone App Master Build" in registry, failures, "program registry missing AMB-MASTER entry")
    check(PROJECT_ID in registry, failures, "program registry missing amb-master Linear project id")
    check("do not create a duplicate master-build program or reuse PLOS labels" in registry, failures, "program registry missing duplicate/PLOS reuse quarantine rule")
    check("Next runnable gate: AMB-1113 / M02.T00" in registry, failures, "program registry next runnable gate is stale")

    for rel, snippets in REQUIRED_DISPATCH.items():
        text = read(rel)
        check(bool(text), failures, f"missing dispatch file: {rel}")
        for snippet in snippets:
            check(snippet in text, failures, f"{rel} missing dispatch snippet: {snippet}")

    readiness = read("scripts/codex/amb-master-readiness-validate.py")
    check("amb-master-repository-wiring-validate.py" in readiness, failures, "readiness validator does not require repository wiring validator")
    check("run_child_validator" in readiness, failures, "readiness validator does not execute child validators")

    for rel in REQUIRED_EXECUTABLES:
        path = ROOT / rel
        check(path.exists(), failures, f"missing executable path: {rel}")
        check(os.access(path, os.X_OK), failures, f"path is not executable: {rel}")

    for dirname in ("reports", "validation", "reviewer-output", "script-output"):
        check((ARTIFACT / dirname).is_dir(), failures, f"missing amb-master artifact directory: {dirname}")

    tracked_logs = git_output("ls-files", "artifacts/ambitions-master-build/script-output")
    check(tracked_logs.returncode == 0, failures, "git ls-files failed for script-output quarantine")
    check(not tracked_logs.stdout.strip(), failures, "script-output logs must remain untracked")
    ignored_sample = git_output("check-ignore", "artifacts/ambitions-master-build/script-output/amb-master-quarantine-sample.log")
    check(ignored_sample.returncode == 0, failures, "script-output .log quarantine is not covered by gitignore")

    issue_map = load_json("artifacts/ambitions-master-build/AMB_MASTER_LINEAR_ISSUE_MAP.json")
    queue = load_json("artifacts/ambitions-master-build/AMB_MASTER_EXECUTION_QUEUE.json")
    check(issue_map.get("project", {}).get("id") == PROJECT_ID, failures, "issue map project id mismatch")
    check(queue.get("project_id") == PROJECT_ID, failures, "queue project id mismatch")

    bindings = {entry.get("linear_id"): entry for entry in issue_map.get("bindings", [])}
    queue_entries = {entry.get("linear_id"): entry for entry in queue.get("queue", []) if str(entry.get("linear_id", "")).startswith("AMB-")}
    for issue in ("AMB-1126", "AMB-1046", "AMB-1047", "AMB-1048", "AMB-1049", "AMB-1050", "AMB-1051", "AMB-1052", "AMB-1053", "AMB-1127", "AMB-1128", "AMB-1113"):
        check(issue in bindings, failures, f"issue map missing binding: {issue}")
        check(issue in queue_entries, failures, f"queue missing binding: {issue}")
    check(AMB_1047_SHA in bindings.get("AMB-1047", {}).get("status", ""), failures, "issue map does not record AMB-1047 pushed SHA")
    check(AMB_1047_SHA in queue_entries.get("AMB-1047", {}).get("state", ""), failures, "queue does not record AMB-1047 pushed SHA")
    check(queue.get("next", {}).get("linear_id") == "AMB-1113", failures, "execution queue next issue must be AMB-1113 after AMB-1128 closeout")

    combined = "\n".join(read(rel) for rel in AMB_MASTER_ACTIVE_FILES)
    forbidden_patterns = [
        r"\bPLOS-M\d+\b",
        r"\bPLOS-\d+\b",
        r"PLOS_M",
        r"linear identifiers used:\s*PLOS",
        r"Linear issue:\s*M\d",
        r"Linear identifiers used:\s*M\d",
        r"Commit and push `AMB-1047`",
        r"AMB-1047` / `M00\.T01`: pending commit/push",
        r"local_green_pending_push",
    ]
    for pattern in forbidden_patterns:
        match = re.search(pattern, combined, re.IGNORECASE)
        check(match is None, failures, f"forbidden stale/quarantined control-plane text remains: {pattern}")

    quarantine_terms = [
        "private user data in R2/public Source Atlas",
        "required cloud LLM/core hosted backend",
        "release/TestFlight/App Store/accessibility/privacy/legal/device/performance claims without current proof",
        "script-output logs remain ignored and untracked",
    ]
    for term in quarantine_terms:
        check(term in combined or term in registry, failures, f"missing quarantine boundary term: {term}")

    return failures


def self_test() -> int:
    failures = validate()
    if failures:
        print("FAIL self-test current amb-master wiring/quarantine invalid")
        for failure in failures:
            print("FAIL " + failure)
        return 1
    print("PASS amb-master repository wiring validator self-test")
    return 0


def main() -> int:
    if "--self-test" in sys.argv[1:]:
        return self_test()
    failures = validate()
    for failure in failures:
        print("FAIL " + failure)
    if failures:
        return 1
    print("PASS amb-master repository wiring and quarantine boundaries are valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
