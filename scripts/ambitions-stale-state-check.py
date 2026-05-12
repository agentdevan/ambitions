#!/usr/bin/env python3
"""Check Ambitions batch state mirrors for obvious stale-run drift.

This script intentionally uses only the Python standard library and conservative
text parsing so it can run in local Codex/runner contexts without extra deps.
It is not a replacement for the queue snapshot; it catches the specific class of
failure where commits advance but compact mirrors still point at old batches.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

ACTIVE_BATCH = ROOT / ".codex/state/active-batch.yml"
CURRENT_RUN = ROOT / ".codex/reports/current-run-state.md"
CURRENT_TRAIN = ROOT / ".codex/reports/current-batch-train-state.md"
QUEUE_JSON = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise SystemExit(f"RED: missing required state file: {path.relative_to(ROOT)}")


def active_value(text: str, key: str) -> str | None:
    match = re.search(rf"^\s*{re.escape(key)}:\s*\"?([^\"\n]+)\"?\s*$", text, re.MULTILINE)
    return match.group(1).strip() if match else None


def current_batch(text: str) -> str | None:
    match = re.search(r"^Current batch:\s*(.+?)\s*/\s*(Green|Accepted Yellow|Yellow|Red|GREEN|YELLOW|RED)\.?\s*$", text, re.MULTILINE)
    return match.group(1).strip() if match else None


def next_batch(text: str) -> str | None:
    patterns = [
        r"^Next eligible batch:\s*(.+?)\.?\s*$",
        r"^Next recommended implementation pass:\s*(.+?)\.?\s*$",
        r"^Next eligible non-UI platform batch:\s*(.+?)\.?\s*$",
    ]
    for pattern in patterns:
        match = re.search(pattern, text, re.MULTILINE)
        if match:
            return match.group(1).strip()
    return None


def queue_classifications() -> dict[str, str]:
    data = json.loads(read(QUEUE_JSON))
    return {entry["id"]: entry["classification"] for entry in data.get("batches", [])}


def main() -> int:
    active = read(ACTIVE_BATCH)
    run = read(CURRENT_RUN)
    train = read(CURRENT_TRAIN)
    classifications = queue_classifications()

    expected_current = active_value(active, "batch")
    expected_next = active_value(active, "next_eligible_batch")
    run_current = current_batch(run)
    train_current = current_batch(train)
    run_next = next_batch(run)
    train_next = next_batch(train)

    failures: list[str] = []

    if not expected_current:
        failures.append("active-batch.yml missing current.batch")
    if not expected_next:
        failures.append("active-batch.yml missing current.next_eligible_batch")

    for label, value in [("current-run-state current", run_current), ("current-batch-train-state current", train_current)]:
        if expected_current and value != expected_current:
            failures.append(f"{label} is {value!r}; expected {expected_current!r}")

    for label, value in [("current-run-state next", run_next), ("current-batch-train-state next", train_next)]:
        if expected_next and value != expected_next:
            failures.append(f"{label} is {value!r}; expected {expected_next!r}")

    next_id = expected_next.split()[0] if expected_next else None
    current_id = expected_current.split()[0] if expected_current else None

    if next_id and classifications.get(next_id) != "executable_now":
        failures.append(f"queue marks {next_id} as {classifications.get(next_id)!r}; expected 'executable_now'")

    if current_id and classifications.get(current_id) != "historical_complete_do_not_run":
        failures.append(f"queue marks {current_id} as {classifications.get(current_id)!r}; expected 'historical_complete_do_not_run'")

    if failures:
        print("RED: stale state mirrors detected")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"GREEN: state mirrors agree: current={expected_current}; next={expected_next}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
