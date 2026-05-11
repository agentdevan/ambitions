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


def load_payload(path: Path) -> object:
    return json.loads(path.read_text())


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
        queue_payload = load_payload(queue_path)
        reference_payload = load_payload(reference_path)
        queue = load_batches(queue_path)
        reference = load_batches(reference_path)
        queue_ids = [str(item.get("id", "")) for item in queue]
        reference_ids = [str(item.get("id", "")) for item in reference]
        if len(queue) != 146:
            warnings.append(f"canonical queue count is {len(queue)}, not the expected 146 hypothesis")
        if queue_ids != reference_ids:
            errors.append("remaining-batch reference order differs from canonical queue")

        executable_now = [item for item in queue if item.get("classification") == "executable_now"]
        if len(executable_now) != 1:
            errors.append(f"canonical queue has {len(executable_now)} executable_now records, expected 1")
        next_batch = str(queue_payload.get("next_eligible_batch", "")) if isinstance(queue_payload, dict) else ""
        next_title = str(queue_payload.get("next_eligible_title", "")) if isinstance(queue_payload, dict) else ""
        if executable_now and executable_now[0].get("id") != next_batch:
            errors.append(
                f"next_eligible_batch {next_batch!r} does not match executable_now {executable_now[0].get('id')!r}"
            )
        if isinstance(reference_payload, dict):
            metadata = reference_payload.get("metadata", {})
            if isinstance(metadata, dict):
                if metadata.get("next_eligible_batch") != next_batch:
                    errors.append("remaining-batch reference next eligible differs from canonical queue")

    active_text = (ROOT / ".codex/state/active-batch.yml").read_text() if (ROOT / ".codex/state/active-batch.yml").exists() else ""
    expected_active = f'next_eligible_batch: "{next_batch} {next_title}"' if next_batch and next_title else ""
    if expected_active and expected_active not in active_text:
        errors.append(f"active-batch mirror does not identify {next_batch} {next_title} as next eligible")
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
