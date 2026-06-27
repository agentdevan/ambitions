#!/usr/bin/env python3
"""Run Source Atlas M09 validation and evidence commands."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from foundry.m09_validation import (
    generate_evidence_pack,
    route_known_issues,
    validate_command_matrix,
    validate_golden_benchmark_matrix,
    validate_source_state_repair_fixtures,
)
from foundry.model import write_json


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_MATRIX = REPO_ROOT / "docs" / "qa" / "source-atlas" / "2026-06-26-m09-validation-command-matrix.json"
DEFAULT_GOLDEN = REPO_ROOT / "tools" / "source-atlas" / "fixtures" / "m09" / "golden-benchmark-matrix.json"
DEFAULT_REPAIR = REPO_ROOT / "tools" / "source-atlas" / "fixtures" / "m09" / "source-state-repair-fixtures.json"
DEFAULT_OUTPUT = REPO_ROOT / "output" / "source-atlas" / "m09"
DEFAULT_LEDGER = "docs/qa/source-atlas/2026-06-26-m09-validation-repair-closeout-ledger.md"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Source Atlas M09 validation and repair evidence")
    sub = parser.add_subparsers(dest="command", required=True)

    matrix = sub.add_parser("validation-matrix")
    matrix.add_argument("--matrix", default=str(DEFAULT_MATRIX))
    matrix.add_argument("--output", default=str(DEFAULT_OUTPUT / "validation-command-matrix-result.json"))

    golden = sub.add_parser("golden-benchmarks")
    golden.add_argument("--matrix", default=str(DEFAULT_GOLDEN))
    golden.add_argument("--output", default=str(DEFAULT_OUTPUT / "golden-benchmark-result.json"))

    repair = sub.add_parser("source-state-repair")
    repair.add_argument("--fixtures", default=str(DEFAULT_REPAIR))
    repair.add_argument("--output", default=str(DEFAULT_OUTPUT / "source-state-repair-result.json"))

    router = sub.add_parser("known-issue-router")
    router.add_argument("--command-result", default=str(DEFAULT_OUTPUT / "validation-command-matrix-result.json"))
    router.add_argument("--golden-result", default=str(DEFAULT_OUTPUT / "golden-benchmark-result.json"))
    router.add_argument("--repair-result", default=str(DEFAULT_OUTPUT / "source-state-repair-result.json"))
    router.add_argument("--output", default=str(DEFAULT_OUTPUT / "known-issue-router-result.json"))

    evidence = sub.add_parser("evidence-pack")
    evidence.add_argument("--output-root", default=str(DEFAULT_OUTPUT))
    evidence.add_argument("--command-result", default=str(DEFAULT_OUTPUT / "validation-command-matrix-result.json"))
    evidence.add_argument("--golden-result", default=str(DEFAULT_OUTPUT / "golden-benchmark-result.json"))
    evidence.add_argument("--repair-result", default=str(DEFAULT_OUTPUT / "source-state-repair-result.json"))
    evidence.add_argument("--known-issue-result", default=str(DEFAULT_OUTPUT / "known-issue-router-result.json"))
    evidence.add_argument("--ledger-path", default=DEFAULT_LEDGER)

    all_parser = sub.add_parser("run-all")
    all_parser.add_argument("--output-root", default=str(DEFAULT_OUTPUT))

    args = parser.parse_args(argv)
    if args.command == "validation-matrix":
        result = validate_command_matrix(Path(args.matrix), REPO_ROOT, Path(args.output))
        return _finish(result)
    if args.command == "golden-benchmarks":
        result = validate_golden_benchmark_matrix(Path(args.matrix), Path(args.output))
        return _finish(result)
    if args.command == "source-state-repair":
        result = validate_source_state_repair_fixtures(Path(args.fixtures), Path(args.output))
        return _finish(result)
    if args.command == "known-issue-router":
        result = route_known_issues(
            Path(args.command_result),
            Path(args.golden_result),
            Path(args.repair_result),
            Path(args.output),
        )
        return 0
    if args.command == "evidence-pack":
        result = generate_evidence_pack(
            Path(args.output_root),
            Path(args.command_result),
            Path(args.golden_result),
            Path(args.repair_result),
            Path(args.known_issue_result),
            args.ledger_path,
        )
        return 0 if result["status"] == "Green" else 1
    if args.command == "run-all":
        output_root = Path(args.output_root)
        output_root.mkdir(parents=True, exist_ok=True)
        command_result_path = output_root / "validation-command-matrix-result.json"
        golden_result_path = output_root / "golden-benchmark-result.json"
        repair_result_path = output_root / "source-state-repair-result.json"
        known_result_path = output_root / "known-issue-router-result.json"
        command_result = validate_command_matrix(DEFAULT_MATRIX, REPO_ROOT, command_result_path)
        golden_result = validate_golden_benchmark_matrix(DEFAULT_GOLDEN, golden_result_path)
        repair_result = validate_source_state_repair_fixtures(DEFAULT_REPAIR, repair_result_path)
        route_known_issues(command_result_path, golden_result_path, repair_result_path, known_result_path)
        pack = generate_evidence_pack(
            output_root,
            command_result_path,
            golden_result_path,
            repair_result_path,
            known_result_path,
            DEFAULT_LEDGER,
        )
        summary = {
            "valid": command_result["valid"] and golden_result["valid"] and repair_result["valid"] and pack["status"] == "Green",
            "evidencePack": str(output_root / "m09-release-evidence-pack.json"),
        }
        write_json(output_root / "m09-run-all-summary.json", summary)
        return 0 if summary["valid"] else 1
    raise AssertionError(f"unhandled command: {args.command}")


def _finish(result: dict) -> int:
    print(f"{result['kind']}: {'PASS' if result.get('valid') else 'FAIL'}")
    for issue in result.get("issues", []):
        print(f"- {issue}")
    return 0 if result.get("valid") else 1


if __name__ == "__main__":
    raise SystemExit(main())
