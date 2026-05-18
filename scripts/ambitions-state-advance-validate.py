#!/usr/bin/env python3
"""Validate that Ambitions batch state mirrors agree after advancement."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACTIVE = ROOT / ".codex/state/active-batch.yml"
RUN_STATE = ROOT / ".codex/reports/current-run-state.md"
TRAIN_STATE = ROOT / ".codex/reports/current-batch-train-state.md"
QUEUE = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"


def active_value(key: str) -> str:
    for line in ACTIVE.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith(f"{key}:"):
            return stripped.split(":", 1)[1].strip().strip('"')
    return ""


def report_current(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    match = re.search(r"^Current batch:\s*(.+?)\s*$", text, re.M)
    if not match:
        return ""
    current = match.group(1).strip().rstrip(".")
    return re.sub(
        r"\s+/\s+(Accepted Yellow|Green|Yellow|Red|Complete|Completed|Partial|Blocked)$",
        "",
        current,
        flags=re.I,
    ).strip()


def report_next(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    match = re.search(r"^Next eligible batch:\s*(.+?)\s*$", text, re.M)
    return match.group(1).strip() if match else ""


def queue_exec_now() -> list[str]:
    data = json.loads(QUEUE.read_text(encoding="utf-8"))
    return [entry.get("id", "") for entry in data.get("batches", []) if entry.get("classification") == "executable_now"]


def queue_classification(batch_id: str) -> str:
    data = json.loads(QUEUE.read_text(encoding="utf-8"))
    for entry in data.get("batches", []):
        if entry.get("id", "") == batch_id:
            return str(entry.get("classification", ""))
    return ""


def main() -> int:
    failures: list[str] = []
    active_batch = active_value("batch")
    active_next = active_value("next_eligible_batch")
    active_batch_id = active_batch.split()[0] if active_batch else ""
    active_next_id = active_next.split()[0] if active_next else ""

    for label, path in [("run-state", RUN_STATE), ("train-state", TRAIN_STATE)]:
        current = report_current(path)
        next_batch = report_next(path)
        if current != active_batch:
            failures.append(f"{label} current {current!r} != active {active_batch!r}")
        if next_batch != active_next:
            failures.append(f"{label} next {next_batch!r} != active next {active_next!r}")

    exec_now = queue_exec_now()
    if len(exec_now) != 1:
        if not (len(exec_now) == 0 and queue_classification(active_next_id) == "conditional_trigger_only"):
            failures.append(f"queue has {len(exec_now)} executable_now batches: {exec_now}")
    elif exec_now[0] != active_next_id:
        failures.append(f"queue executable_now {exec_now[0]!r} != active next {active_next_id!r}")

    if not active_batch_id or not active_next_id:
        failures.append("active-batch.yml missing current or next batch id")

    if failures:
        print("RED: state advancement validation failed")
        for failure in failures:
            print(f"- {failure}")
        return 1

    terminal_note = " terminal-no-executable" if not exec_now else ""
    print(f"GREEN: state advancement coherent{terminal_note}; current={active_batch}; next={active_next}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
