#!/usr/bin/env python3
"""Deterministic batch lane classifier for throughput orchestration.

Reads the canonical queue JSON and classifies queued batches into throughput lanes.
No state mutation and no network operations are performed.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Dict, Iterable, List

POLICY_LANE_MAP = {
    "historical_complete_do_not_run": "defer_with_ledger",
    "absorbed_as_overlay": "parallel_readonly_prep",
    "conditional_trigger_only": "defer_with_ledger",
    "deleted_obsolete": "blocked_hard_red",
    "evidence_preserved_minimal": "defer_with_ledger",
    "executable_now": "critical_serial_write",
    "executable_later": "parallel_readonly_prep",
    "unknown_requires_repair": "repair_or_finalize_required",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Classify queue entries into deterministic throughput lanes."
    )
    parser.add_argument(
        "--queue",
        help="Path to docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json",
        default="docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json",
    )
    parser.add_argument("--batch", help="Classify a single batch id", default=None)
    parser.add_argument("--limit", type=int, default=20, help="Limit entries")
    return parser.parse_args()


def load_batches(path: Path) -> List[Dict[str, str]]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return list(data.get("batches", []))


def classify_batch(batch: Dict[str, str]) -> str:
    base = batch.get("classification", "unknown")
    if "PK" in batch.get("id", "") and batch.get("id", "").startswith("PK"):
        if base == "historical_complete_do_not_run":
            return "defer_with_ledger"
    return POLICY_LANE_MAP.get(base, "parallel_readonly_prep")


def lane_for_batch(batch: Dict[str, str]) -> str:
    return classify_batch(batch)


def print_table(rows: Iterable[Dict[str, str]]) -> None:
    print("| Batch | Title | Queue Class | Lane | Rationale |")
    print("| --- | --- | --- | --- | --- |")
    for row in rows:
        print(
            f"| {row['batch']} | {row['title']} | {row['queue_class']} | {row['lane']} | {row['rationale']} |"
        )


def row_for_batch(batch: Dict[str, str]) -> Dict[str, str]:
    queue_class = batch.get("classification", "unknown")
    lane = lane_for_batch(batch)

    if queue_class == "historical_complete_do_not_run":
        rationale = "Queued as historical evidence only; do not rerun from this lane"
    elif queue_class == "executable_now":
        rationale = "Queue explicitly marks executable now; canonical write lane candidate"
    elif queue_class == "executable_later":
        rationale = "Future queue item; prep and dependency checks may be run"
    elif queue_class == "unknown_requires_repair":
        rationale = "Requires repair/finalization resolution before write execution"
    elif queue_class == "blocked_hard_red":
        rationale = "Hard-block status in queue metadata"
    else:
        rationale = f"Classification '{queue_class}' defaults to read-only prep"

    return {
        "batch": batch.get("id", "(unknown)"),
        "title": batch.get("title", "(untitled)"),
        "queue_class": queue_class,
        "lane": lane,
        "rationale": rationale,
    }


def format_list(rows: Iterable[Dict[str, str]]) -> None:
    for row in rows:
        print(
            f"- {row['batch']} | {row['title']} | {row['queue_class']} | {row['lane']}"
            f" | {row['rationale']}"
        )


def main() -> int:
    args = parse_args()
    path = Path(args.queue)
    if not path.exists():
        print(f"ERROR: queue file missing: {path}", file=sys.stderr)
        return 2

    batches = load_batches(path)
    if args.batch:
        target = args.batch.upper()
        selected = [b for b in batches if b.get("id") == target]
        if not selected:
            print(f"ERROR: batch not found: {target}", file=sys.stderr)
            return 2
        rows = [row_for_batch(selected[0])]
    else:
        rows = [row_for_batch(b) for b in batches[: args.limit]]

    if not rows:
        print("No queue entries matched the request.")
        return 0

    print("# Throughput Batch Classification")
    print("")
    print_table(rows)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
