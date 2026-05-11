#!/usr/bin/env python3
"""Validate the queue-control-plane invariants used by remaining-train prompts."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]


REQUIRED_FILES = [
    "docs/truth/README.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    ".codex/state/active-batch.yml",
    ".codex/reports/current-batch-train-state.md",
    "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json",
    "docs/codex/AMB_REMAINING_BATCH_REFERENCE.json",
]


def load_batches(path: Path) -> list[dict]:
    data = json.loads(path.read_text())
    if isinstance(data, dict) and isinstance(data.get("batches"), list):
        return data["batches"]
    if isinstance(data, list):
        return data
    raise ValueError(f"{path} does not contain a batch list")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()

    errors: list[str] = []
    warnings: list[str] = []

    for rel in REQUIRED_FILES:
        if not (ROOT / rel).exists():
            errors.append(f"missing required control-plane file: {rel}")

    queue_path = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
    reference_path = ROOT / "docs/codex/AMB_REMAINING_BATCH_REFERENCE.json"
    if queue_path.exists() and reference_path.exists():
        queue = load_batches(queue_path)
        reference = load_batches(reference_path)
        queue_ids = [str(item.get("id", "")) for item in queue]
        reference_ids = [str(item.get("id", "")) for item in reference]
        if len(queue) != 146:
            warnings.append(f"canonical queue count is {len(queue)}, not the expected 146 hypothesis")
        if queue_ids != reference_ids:
            errors.append("remaining-batch reference order differs from canonical queue")
        pk17 = next((item for item in queue if item.get("id") == "PK17"), None)
        if not pk17:
            errors.append("PK17 missing from canonical queue")
        elif pk17.get("classification") != "executable_now":
            errors.append(f"PK17 classification is {pk17.get('classification')!r}, expected executable_now")

    active_text = (ROOT / ".codex/state/active-batch.yml").read_text() if (ROOT / ".codex/state/active-batch.yml").exists() else ""
    if "next_eligible_batch: \"PK17 Today Read Model Extraction\"" not in active_text:
        errors.append("active-batch mirror does not identify PK17 Today Read Model Extraction as next eligible")
    if "branch_creation_allowed: false" not in active_text:
        warnings.append("active-batch mirror does not explicitly forbid branch creation")

    print("# Ambitions Control Plane Check")
    for warning in warnings:
        print(f"YELLOW: {warning}")
    if errors:
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1
    print("GREEN: control-plane queue invariants passed")
    return 0 if not (args.strict and warnings) else 0


if __name__ == "__main__":
    raise SystemExit(main())
