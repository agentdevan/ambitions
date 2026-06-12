#!/usr/bin/env python3
"""Validate PLOS Goal Mode readiness artifacts without network or Linear writes."""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
PLOS_DIR = ROOT / "artifacts" / "plos-runtime"
MAP_PATH = PLOS_DIR / "PLOS_LINEAR_ISSUE_MAP.json"
QUEUE_PATH = PLOS_DIR / "PLOS_EXECUTION_QUEUE.json"
PHASE_GATES_PATH = PLOS_DIR / "PLOS_PHASE_GATES.md"
AMB_RE = re.compile(r"^AMB-[0-9]+$")
PHASE_ORDER = [f"M{i:02d}" for i in range(27)]

REQUIRED_FILES = [
    PLOS_DIR / "PLOS_GOAL.md",
    PLOS_DIR / "PLOS-run-state.md",
    PLOS_DIR / "PLOS_PHASE_GATES.md",
    PLOS_DIR / "PLOS_RISK_REGISTER.md",
    PLOS_DIR / "PLOS_LINEAR_ISSUE_MAP.md",
    PLOS_DIR / "PLOS_LINEAR_ISSUE_MAP.json",
    PLOS_DIR / "PLOS_EXECUTION_QUEUE.md",
    PLOS_DIR / "PLOS_EXECUTION_QUEUE.json",
    PLOS_DIR / "PLOS_AUTONOMOUS_READINESS_AUDIT.md",
    ROOT / ".agents" / "skills" / "plos-runtime-master-build" / "SKILL.md",
    ROOT / ".agents" / "skills" / "plos-runtime-master-build" / "references" / "plos-reviewer-prompts.md",
    ROOT / ".agents" / "skills" / "plos-runtime-master-build" / "references" / "plos-closeout-template.md",
]


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def phase_entries(payload: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {entry.get("phase", ""): entry for entry in payload.get("phase_issues", [])}


def queue_entries(payload: dict[str, Any]) -> list[dict[str, Any]]:
    return payload.get("queue", [])


def validate_payload(issue_map: dict[str, Any], queue: dict[str, Any], phase: str | None = None) -> list[str]:
    failures: list[str] = []
    entries = phase_entries(issue_map)
    queue_items = queue_entries(queue)
    queue_by_phase = {item.get("phase", ""): item for item in queue_items}

    for expected in PHASE_ORDER:
        if expected not in entries:
            failures.append(f"missing PLOS phase map entry: {expected}")
        if expected not in queue_by_phase:
            failures.append(f"missing PLOS execution queue entry: {expected}")

    extra_phases = sorted(set(entries).difference(PHASE_ORDER))
    if extra_phases:
        failures.append(f"unexpected PLOS phase map entries: {', '.join(extra_phases)}")

    if [item.get("phase") for item in queue_items] != PHASE_ORDER:
        failures.append("PLOS execution queue is not in strict M00..M26 order")

    seen_ids: set[str] = set()
    for expected in PHASE_ORDER:
        entry = entries.get(expected)
        if not entry:
            continue
        linear_id = entry.get("linear_id", "")
        label = entry.get("label", "")
        title = entry.get("title", "")
        if not AMB_RE.match(linear_id):
            failures.append(f"{expected} uses non-AMB Linear identifier: {linear_id}")
        if linear_id in seen_ids:
            failures.append(f"duplicate Linear issue id in phase map: {linear_id}")
        seen_ids.add(linear_id)
        if label != f"PLOS-{expected}":
            failures.append(f"{expected} label mismatch: {label}")
        if f"PLOS-{expected}" not in title:
            failures.append(f"{expected} title does not carry its PLOS label")

        queue_item = queue_by_phase.get(expected, {})
        if queue_item.get("linear_id") != linear_id:
            failures.append(f"{expected} queue Linear id does not match issue map")
        if queue_item.get("label") != f"PLOS-{expected}":
            failures.append(f"{expected} queue label mismatch")
        if queue_item.get("linear_lookup_identifier") != linear_id:
            failures.append(f"{expected} queue must use AMB id as linear_lookup_identifier")

    for child in issue_map.get("known_child_issue_bindings", []):
        linear_id = child.get("linear_id", "")
        if not AMB_RE.match(linear_id):
            failures.append(f"known child issue uses non-AMB Linear identifier: {linear_id}")
        parent = child.get("parent_linear_id", "")
        if parent and not AMB_RE.match(parent):
            failures.append(f"known child issue has non-AMB parent identifier: {parent}")

    identifier_policy = issue_map.get("identifier_policy", {})
    if identifier_policy.get("linear_fetch_update_identifier") != "AMB issue identifier only":
        failures.append("identifier policy must require AMB issue identifiers for Linear reads and writes")
    forbidden = " ".join(identifier_policy.get("forbidden_for_linear_reads_or_writes", []))
    if "PLOS-M##" not in forbidden or "PLOS-###" not in forbidden:
        failures.append("identifier policy must forbid PLOS labels for Linear reads and writes")

    if phase:
        if phase not in PHASE_ORDER:
            failures.append(f"invalid PLOS phase: {phase}")
        if phase in PHASE_ORDER and phase not in entries:
            failures.append(f"phase not mapped to Linear issue: {phase}")

    return failures


def validate_files(phase: str | None = None) -> list[str]:
    failures: list[str] = []
    for path in REQUIRED_FILES:
        if not path.exists():
            failures.append(f"missing required PLOS readiness file: {path.relative_to(ROOT)}")

    if not MAP_PATH.exists() or not QUEUE_PATH.exists():
        return failures

    try:
        issue_map = load_json(MAP_PATH)
    except Exception as exc:  # pragma: no cover - failure path
        failures.append(f"cannot parse {MAP_PATH.relative_to(ROOT)}: {exc}")
        return failures
    try:
        queue = load_json(QUEUE_PATH)
    except Exception as exc:  # pragma: no cover - failure path
        failures.append(f"cannot parse {QUEUE_PATH.relative_to(ROOT)}: {exc}")
        return failures

    failures.extend(validate_payload(issue_map, queue, phase=phase))

    if PHASE_GATES_PATH.exists():
        gates = PHASE_GATES_PATH.read_text(encoding="utf-8", errors="ignore")
        phases = [phase] if phase else PHASE_ORDER
        for item in phases:
            if f"## {item}" not in gates:
                failures.append(f"missing phase gate heading in PLOS_PHASE_GATES.md: {item}")

    return failures


def self_test() -> int:
    valid_map = {
        "phase_issues": [
            {
                "phase": phase,
                "label": f"PLOS-{phase}",
                "linear_id": f"AMB-{600 + index}",
                "title": f"PLOS-{phase} - Test phase",
            }
            for index, phase in enumerate(PHASE_ORDER)
        ],
        "identifier_policy": {
            "linear_fetch_update_identifier": "AMB issue identifier only",
            "forbidden_for_linear_reads_or_writes": ["PLOS-M##", "PLOS-###"],
        },
        "known_child_issue_bindings": [],
    }
    valid_queue = {
        "queue": [
            {
                "phase": phase,
                "label": f"PLOS-{phase}",
                "linear_id": f"AMB-{600 + index}",
                "linear_lookup_identifier": f"AMB-{600 + index}",
            }
            for index, phase in enumerate(PHASE_ORDER)
        ]
    }
    failures = validate_payload(valid_map, valid_queue)
    if failures:
        print("FAIL self-test valid payload rejected")
        for failure in failures:
            print("FAIL " + failure)
        return 1

    broken = json.loads(json.dumps(valid_map))
    broken["phase_issues"][0]["linear_id"] = "PLOS-M00"
    failures = validate_payload(broken, valid_queue)
    if not any("non-AMB Linear identifier" in failure for failure in failures):
        print("FAIL self-test did not reject synthetic PLOS Linear identifier")
        return 1

    broken_queue = json.loads(json.dumps(valid_queue))
    broken_queue["queue"][1]["linear_lookup_identifier"] = "PLOS-M01"
    failures = validate_payload(valid_map, broken_queue)
    if not any("linear_lookup_identifier" in failure for failure in failures):
        print("FAIL self-test did not reject PLOS lookup identifier")
        return 1

    print("PASS plos readiness validator self-test")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--phase", help="Validate a specific PLOS phase gate such as M00 or M01.")
    parser.add_argument("--self-test", action="store_true", help="Run in-memory validator self-tests.")
    args = parser.parse_args()

    if args.self_test:
        return self_test()

    failures = validate_files(phase=args.phase)
    for failure in failures:
        print("FAIL " + failure)
    if failures:
        return 1
    if args.phase:
        print(f"PASS PLOS readiness phase gate is declared and AMB-bound: {args.phase}")
    else:
        print("PASS PLOS autonomous readiness artifacts are AMB-bound and internally consistent")
    return 0


if __name__ == "__main__":
    sys.exit(main())
