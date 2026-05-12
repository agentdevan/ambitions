#!/usr/bin/env python3
"""Local-only eval dataset validator and dry-run runner."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DATASETS = [
    Path("tools/openai/evals/datasets/batch_quality.jsonl"),
    Path("tools/openai/evals/datasets/claim_safety.jsonl"),
    Path("tools/openai/evals/datasets/visual_canon.jsonl"),
]
VERDICTS = {"pass", "fail"}


def validate_row(row: dict, index: int) -> str | None:
    if not isinstance(row, dict):
        return f"row {index} is not JSON object"
    if not isinstance(row.get("id"), str) or not row["id"]:
        return f"row {index} missing id"
    if not isinstance(row.get("input"), str):
        return f"row {index} missing input"
    expected = row.get("expected")
    if not isinstance(expected, dict):
        return f"row {index} missing expected object"
    verdict = expected.get("verdict")
    if verdict not in VERDICTS:
        return f"row {index} expected.verdict must be pass|fail"
    if not isinstance(expected.get("reason"), str):
        return f"row {index} expected.reason missing"
    return None


def validate_dataset(path: Path) -> tuple[int, int]:
    total = 0
    errors = 0
    for idx, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if not line.strip():
            continue
        total += 1
        try:
            row = json.loads(line)
        except json.JSONDecodeError as exc:
            print(f"{path}:{idx}: invalid JSON ({exc})")
            errors += 1
            continue
        err = validate_row(row, idx)
        if err:
            print(f"{path}:{idx}: {err}")
            errors += 1
    return total, errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Run local eval dataset validation (dry-run by design)")
    parser.add_argument("datasets", nargs="*", default=[str(p) for p in DEFAULT_DATASETS])
    parser.add_argument("--dry-run", action="store_true", help="Skip execution and print expected run plan")
    args = parser.parse_args()

    paths = [Path(p) for p in args.datasets]
    total_rows = 0
    total_errors = 0
    for path in paths:
        if not path.exists():
            print(f"Missing dataset: {path}")
            total_errors += 1
            continue
        rows, errors = validate_dataset(path)
        total_rows += rows
        total_errors += errors
        print(f"Validated {rows} rows from {path} ({errors} errors)")

    if total_errors:
        return 1

    print(f"TOTAL_ROWS={total_rows}")
    if args.dry_run:
        for path in paths:
            print(f"DRY RUN: would execute OpenAI Evals workflow for {path}")
        return 0

    print("DRY RUN mode not enabled; local scaffold remains shape-only without live calls")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
