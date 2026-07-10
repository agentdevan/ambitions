#!/usr/bin/env python3
"""Fail-closed structural validator for the Ambitions architecture scorecard."""

from __future__ import annotations

import argparse
import json
import re
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SCORECARD = ROOT / "docs/qa/architecture/architecture-10-scorecard.json"
DIMENSION_NAMES = {
    "overallArchitecture",
    "runtimeFoundations",
    "compileTimeModularity",
    "dependencyDiscipline",
    "proofTestIntegrity",
}
STATUS_VALUES = {"green", "yellow", "red"}


def validate_dimension(row: dict[str, object]) -> list[str]:
    """Return proof errors for one dimension; Green always fails closed."""
    errors: list[str] = []
    status = row.get("status")
    evidence = row.get("evidence")
    required_gates = row.get("requiredGates")
    gate_results = row.get("gateResults", {})

    if status not in STATUS_VALUES:
        errors.append("dimension status must be green, yellow, or red")
    if "workingScore" in row:
        if not isinstance(row.get("workingScore"), (int, float)) or isinstance(
            row.get("workingScore"), bool
        ):
            errors.append("dimension workingScore must be numeric")
        elif not 0 <= float(row["workingScore"]) <= 10:
            errors.append("dimension workingScore must be between 0 and 10")
    if not isinstance(evidence, list):
        errors.append("dimension evidence must be a list")
        evidence = []
    if not isinstance(required_gates, list) or not all(
        isinstance(gate, str) and gate for gate in required_gates
    ):
        errors.append("dimension requiredGates must be a list of names")
        required_gates = []
    if not isinstance(gate_results, dict):
        errors.append("dimension gateResults must be an object")
        gate_results = {}

    if status == "green":
        if not evidence:
            errors.append("green dimension has no evidence")
        for gate in required_gates:
            if gate_results.get(gate) != "pass":
                errors.append(f"missing gate {gate}")
        if "workingScore" in row and row.get("workingScore") != 10:
            errors.append("green dimension must have workingScore 10")
    return errors


def validate_scorecard(data: object, root: Path = ROOT) -> list[str]:
    if not isinstance(data, dict):
        return ["scorecard root must be an object"]

    errors: list[str] = []
    required_keys = {
        "schemaVersion",
        "baseline",
        "sourceCounts",
        "targetGraph",
        "validatorResults",
        "dimensions",
        "evidencePaths",
        "blockers",
        "forbiddenClaims",
    }
    for key in sorted(required_keys - data.keys()):
        errors.append(f"missing top-level key {key}")

    baseline = data.get("baseline")
    if not isinstance(baseline, dict):
        errors.append("baseline must be an object")
    else:
        commit = baseline.get("commit")
        if not isinstance(commit, str) or not re.fullmatch(r"[0-9a-f]{40}", commit):
            errors.append("baseline commit must be an exact 40-character SHA")
        if not isinstance(baseline.get("branch"), str) or not baseline.get("branch"):
            errors.append("baseline branch must be recorded")

    counts = data.get("sourceCounts")
    if not isinstance(counts, dict) or not counts:
        errors.append("sourceCounts must be a non-empty object")
    elif any(
        not isinstance(value, int) or isinstance(value, bool) or value < 0
        for value in counts.values()
    ):
        errors.append("sourceCounts values must be non-negative integers")

    target_graph = data.get("targetGraph")
    if not isinstance(target_graph, dict) or not target_graph.get("evidencePath"):
        errors.append("targetGraph must link its evidence path")

    validators = data.get("validatorResults")
    if not isinstance(validators, dict) or not validators:
        errors.append("validatorResults must be a non-empty object")
    else:
        for name, result in validators.items():
            if not isinstance(result, dict):
                errors.append(f"validator {name} must be an object")
                continue
            if result.get("status") not in {"pass", "fail", "not-run"}:
                errors.append(f"validator {name} has invalid status")
            if not isinstance(result.get("command"), str) or not result.get("command"):
                errors.append(f"validator {name} must record its command")

    dimensions = data.get("dimensions")
    if not isinstance(dimensions, dict):
        errors.append("dimensions must be an object")
    else:
        missing = DIMENSION_NAMES - dimensions.keys()
        extra = dimensions.keys() - DIMENSION_NAMES
        for name in sorted(missing):
            errors.append(f"missing dimension {name}")
        for name in sorted(extra):
            errors.append(f"unexpected dimension {name}")
        for name in sorted(DIMENSION_NAMES & dimensions.keys()):
            row = dimensions[name]
            if not isinstance(row, dict):
                errors.append(f"dimension {name} must be an object")
                continue
            if "workingScore" not in row:
                errors.append(f"dimension {name} is missing workingScore")
            errors.extend(f"{name}: {error}" for error in validate_dimension(row))

    evidence_paths = data.get("evidencePaths")
    if not isinstance(evidence_paths, list) or not evidence_paths:
        errors.append("evidencePaths must be a non-empty list")
    else:
        for evidence_path in evidence_paths:
            if not isinstance(evidence_path, str) or not evidence_path:
                errors.append("evidencePaths entries must be path strings")
            elif not (root / evidence_path).exists():
                errors.append(f"evidence path does not exist: {evidence_path}")

    if not isinstance(data.get("blockers"), list) or not data.get("blockers"):
        errors.append("blockers must be a non-empty list until all gates pass")
    if not isinstance(data.get("forbiddenClaims"), list) or not data.get("forbiddenClaims"):
        errors.append("forbiddenClaims must be a non-empty list")
    return errors


def run_self_tests() -> None:
    row = {"status": "green", "evidence": [], "requiredGates": ["runtime-restart"]}
    assert validate_dimension(row) == [
        "green dimension has no evidence",
        "missing gate runtime-restart",
    ]

    valid_green = {
        "status": "green",
        "workingScore": 10,
        "evidence": ["proof.json"],
        "requiredGates": ["runtime-restart"],
        "gateResults": {"runtime-restart": "pass"},
    }
    assert validate_dimension(valid_green) == []

    advisory = {
        "status": "yellow",
        "workingScore": 9.5,
        "evidence": [],
        "requiredGates": ["runtime-restart"],
        "gateResults": {"runtime-restart": "fail"},
    }
    assert validate_dimension(advisory) == []

    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "scorecard.json"
        path.write_text("{}", encoding="utf-8")
        assert validate_scorecard(json.loads(path.read_text(encoding="utf-8")), Path(directory))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--scorecard", type=Path, default=DEFAULT_SCORECARD)
    args = parser.parse_args()

    if args.self_test:
        run_self_tests()
        print("architecture 10 scorecard self-tests passed")
        return 0

    try:
        data = json.loads(args.scorecard.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        print(f"scorecard could not be read: {error}", file=sys.stderr)
        return 1

    errors = validate_scorecard(data)
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    statuses = ", ".join(
        f"{name}={row['status']}({row['workingScore']}/10)"
        for name, row in data["dimensions"].items()
    )
    print(f"architecture 10 scorecard structurally valid; advisory scores: {statuses}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
