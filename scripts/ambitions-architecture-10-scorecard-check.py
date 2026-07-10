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
MANDATORY_GATES = {
    "overallArchitecture": (
        "target-graph-acyclic",
        "one-mutation-authority",
        "stage-presentation-only",
        "zero-noncanonical-production-owners",
        "behavior-backed-architecture-proof",
    ),
    "runtimeFoundations": (
        "all-mutations-enumerated",
        "runtime-restart",
        "duplicate-idempotency",
        "rollback",
        "corruption-recovery",
        "outbox-faults",
    ),
    "compileTimeModularity": (
        "compiler-enforced-targets",
        "acyclic-target-graph",
        "incremental-feature-rebuild",
    ),
    "dependencyDiscipline": (
        "no-feature-service-locator",
        "no-optional-live-dependencies",
        "no-default-live-runtime",
        "no-internal-notification-routing",
        "app-only-composition",
    ),
    "proofTestIntegrity": (
        "executable-behavior-assertions",
        "lexical-tests-governance-only",
        "real-store-restart-replay",
        "zero-skips",
        "zero-retries",
        "zero-expected-failures",
    ),
}
DIMENSION_NAMES = set(MANDATORY_GATES)
STATUS_VALUES = {"green", "yellow", "red"}


def _evidence_file(path_value: object, root: Path) -> tuple[Path | None, str | None]:
    if not isinstance(path_value, str) or not path_value:
        return None, "evidence path must be a non-empty string"
    relative = Path(path_value)
    if relative.is_absolute() or ".." in relative.parts:
        return None, f"evidence path must be repo-relative: {path_value}"
    path = root / relative
    if not path.is_file():
        return None, f"evidence path does not exist: {path_value}"
    return path, None


def validate_dimension(
    row: dict[str, object],
    *,
    dimension_name: str | None = None,
    root: Path = ROOT,
    scored_commit: str | None = None,
) -> list[str]:
    """Return proof errors for one dimension; Green always fails closed."""
    errors: list[str] = []
    status = row.get("status")
    evidence = row.get("evidence")
    required_gates = row.get("requiredGates")
    gate_results = row.get("gateResults", {})
    expected_gates = MANDATORY_GATES.get(dimension_name) if dimension_name else None

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
    else:
        for evidence_path in evidence:
            _, path_error = _evidence_file(evidence_path, root)
            if path_error:
                errors.append(path_error)
    if not isinstance(required_gates, list) or not all(
        isinstance(gate, str) and gate for gate in required_gates
    ):
        errors.append("dimension requiredGates must be a list of names")
        required_gates = []
    if not isinstance(gate_results, dict):
        errors.append("dimension gateResults must be an object")
        gate_results = {}
    elif any(result not in {"pass", "fail", "not-run"} for result in gate_results.values()):
        errors.append("dimension gateResults values must be pass, fail, or not-run")

    if expected_gates is not None:
        expected_set = set(expected_gates)
        if len(required_gates) != len(expected_gates) or set(required_gates) != expected_set:
            errors.append(f"requiredGates do not match validator contract for {dimension_name}")
        if set(gate_results) != expected_set:
            errors.append(f"gateResults do not match validator contract for {dimension_name}")

    if status == "green":
        if not evidence:
            errors.append("green dimension has no evidence")
        for gate in required_gates:
            if gate_results.get(gate) != "pass":
                errors.append(f"missing gate {gate}")
        if "workingScore" in row and row.get("workingScore") != 10:
            errors.append("green dimension must have workingScore 10")
        if expected_gates is not None:
            gate_evidence = row.get("gateEvidence")
            if not isinstance(gate_evidence, dict) or set(gate_evidence) != set(expected_gates):
                errors.append(f"green gateEvidence does not match validator contract for {dimension_name}")
                gate_evidence = {}
            for gate in expected_gates:
                proof_value = gate_evidence.get(gate)
                if proof_value not in evidence:
                    errors.append(f"gate evidence {gate} is not linked in dimension evidence")
                proof_path, path_error = _evidence_file(proof_value, root)
                if path_error:
                    errors.append(f"gate {gate}: {path_error}")
                    continue
                try:
                    proof = json.loads(proof_path.read_text(encoding="utf-8"))
                except (OSError, json.JSONDecodeError) as error:
                    errors.append(f"gate {gate}: malformed machine evidence: {error}")
                    continue
                if not isinstance(proof, dict):
                    errors.append(f"gate {gate}: machine evidence must be an object")
                    continue
                if proof.get("gate") != gate:
                    errors.append(f"gate {gate}: machine evidence gate mismatch")
                if proof.get("status") != "pass":
                    errors.append(f"gate {gate}: machine evidence is not pass")
                if proof.get("commit") != scored_commit:
                    errors.append(f"gate {gate}: machine evidence commit mismatch")
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
            scored_commit = baseline.get("commit") if isinstance(baseline, dict) else None
            errors.extend(
                f"{name}: {error}"
                for error in validate_dimension(
                    row,
                    dimension_name=name,
                    root=root,
                    scored_commit=scored_commit if isinstance(scored_commit, str) else None,
                )
            )

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

    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        path = root / "scorecard.json"
        path.write_text("{}", encoding="utf-8")
        assert validate_scorecard(json.loads(path.read_text(encoding="utf-8")), root)

        dimension_name = "overallArchitecture"
        gates = MANDATORY_GATES[dimension_name]
        (root / "context.json").write_text("{}", encoding="utf-8")
        advisory = {
            "status": "red",
            "workingScore": 4,
            "evidence": ["context.json"],
            "requiredGates": list(gates),
            "gateResults": dict.fromkeys(gates, "fail"),
        }
        assert validate_dimension(
            advisory,
            dimension_name=dimension_name,
            root=root,
            scored_commit="a" * 40,
        ) == []

        empty_gates = {**advisory, "requiredGates": [], "gateResults": {}}
        empty_errors = validate_dimension(
            empty_gates, dimension_name=dimension_name, root=root, scored_commit="a" * 40
        )
        assert any("requiredGates do not match" in error for error in empty_errors)
        assert any("gateResults do not match" in error for error in empty_errors)

        reduced_gates = {
            **advisory,
            "requiredGates": list(gates[:-1]),
            "gateResults": dict.fromkeys(gates[:-1], "fail"),
        }
        reduced_errors = validate_dimension(
            reduced_gates, dimension_name=dimension_name, root=root, scored_commit="a" * 40
        )
        assert any("requiredGates do not match" in error for error in reduced_errors)

        nonexistent = {**advisory, "evidence": ["does-not-exist.json"]}
        assert "evidence path does not exist: does-not-exist.json" in validate_dimension(
            nonexistent, dimension_name=dimension_name, root=root, scored_commit="a" * 40
        )

        green = {
            **advisory,
            "status": "green",
            "workingScore": 10,
            "gateResults": dict.fromkeys(gates, "pass"),
        }
        missing_proof_errors = validate_dimension(
            green, dimension_name=dimension_name, root=root, scored_commit="a" * 40
        )
        assert any("green gateEvidence does not match" in error for error in missing_proof_errors)

        gate_evidence: dict[str, str] = {}
        for gate in gates:
            proof_path = f"{gate}.json"
            (root / proof_path).write_text(
                json.dumps({"gate": gate, "status": "pass", "commit": "a" * 40}),
                encoding="utf-8",
            )
            gate_evidence[gate] = proof_path
        valid_green = {
            **green,
            "evidence": ["context.json", *gate_evidence.values()],
            "gateEvidence": gate_evidence,
        }
        assert validate_dimension(
            valid_green, dimension_name=dimension_name, root=root, scored_commit="a" * 40
        ) == []

        mismatch_gate = gates[0]
        (root / gate_evidence[mismatch_gate]).write_text(
            json.dumps({"gate": mismatch_gate, "status": "pass", "commit": "b" * 40}),
            encoding="utf-8",
        )
        mismatch_errors = validate_dimension(
            valid_green, dimension_name=dimension_name, root=root, scored_commit="a" * 40
        )
        assert f"gate {mismatch_gate}: machine evidence commit mismatch" in mismatch_errors

        (root / gate_evidence[mismatch_gate]).write_text("not-json", encoding="utf-8")
        malformed_errors = validate_dimension(
            valid_green, dimension_name=dimension_name, root=root, scored_commit="a" * 40
        )
        assert any("malformed machine evidence" in error for error in malformed_errors)


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
