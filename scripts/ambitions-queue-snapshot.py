#!/usr/bin/env python3
"""Print a deterministic snapshot of Ambitions remaining-queue files."""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_QUEUE = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
DEFAULT_REFERENCE = ROOT / "docs/codex/AMB_REMAINING_BATCH_REFERENCE.json"
DEFAULT_BLUEPRINT = ROOT / "docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json"


def load_batches(path: Path) -> list[dict]:
    data = json.loads(path.read_text())
    if isinstance(data, dict) and isinstance(data.get("batches"), list):
        return data["batches"]
    if isinstance(data, list):
        return data
    raise ValueError(f"{path} does not contain a batch list")


def train_for(record: dict) -> str:
    batch_id = str(record.get("id", ""))
    if batch_id.startswith("SA"):
        return "SA"
    if batch_id.startswith("LDI"):
        return "LDI"
    if batch_id.startswith("AOS"):
        return "AOS"
    if batch_id.startswith("FCP"):
        return "FCP"
    if batch_id.startswith("PFC"):
        return "PFC"
    if batch_id.startswith("EFC"):
        return "EFC"
    if batch_id.startswith("RHC"):
        return "RHC"
    if batch_id.startswith("CS"):
        return "CS"
    if batch_id.startswith("PX"):
        return "PX"
    if batch_id.startswith("PK"):
        return "PK"
    if batch_id.startswith("DPTG"):
        return "DPTG"
    return "Other"


def duplicate_ids(records: list[dict]) -> list[str]:
    counts = Counter(str(item.get("id", "")) for item in records)
    return sorted(batch_id for batch_id, count in counts.items() if count > 1)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--queue", default=str(DEFAULT_QUEUE))
    parser.add_argument("--reference", default=str(DEFAULT_REFERENCE))
    parser.add_argument("--blueprint", default=str(DEFAULT_BLUEPRINT))
    parser.add_argument("--limit", type=int, default=0)
    args = parser.parse_args()

    queue_path = Path(args.queue)
    reference_path = Path(args.reference)
    blueprint_path = Path(args.blueprint)

    queue = load_batches(queue_path)
    reference = load_batches(reference_path) if reference_path.exists() else []
    blueprint = load_batches(blueprint_path) if blueprint_path.exists() else []

    ids = [str(item.get("id", "")) for item in queue]
    ref_ids = [str(item.get("id", "")) for item in reference]
    blueprint_ids = [str(item.get("id", "")) for item in blueprint]

    print("# Ambitions Queue Snapshot")
    print(f"queue_path: {queue_path}")
    print(f"queue_count: {len(queue)}")
    print(f"reference_count: {len(reference) if reference else 'missing'}")
    print(f"blueprint_count: {len(blueprint) if blueprint else 'missing'}")
    print(f"first_batch: {ids[0] if ids else 'none'}")
    print(f"last_batch: {ids[-1] if ids else 'none'}")
    print(f"duplicates: {', '.join(duplicate_ids(queue)) or 'none'}")
    print("classifications:")
    for name, count in sorted(Counter(str(item.get("classification", "unknown")) for item in queue).items()):
        print(f"- {name}: {count}")
    print("trains:")
    for name, count in sorted(Counter(train_for(item) for item in queue).items()):
        print(f"- {name}: {count}")

    if args.limit:
        print("records:")
        for index, record in enumerate(queue[: args.limit], start=1):
            print(f"- {index}: {record.get('id')} — {record.get('title')} [{record.get('classification')}]")

    errors: list[str] = []
    if duplicate_ids(queue):
        errors.append("canonical queue has duplicate IDs")
    if reference and ids != ref_ids:
        errors.append("reference IDs do not match canonical queue order")
    if blueprint and ids != blueprint_ids:
        errors.append("blueprint IDs do not match canonical queue order")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
