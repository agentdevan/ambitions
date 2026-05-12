#!/usr/bin/env python3
"""Validate prompt labels against live queue/state for a target batch."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACTIVE_BATCH = ROOT / ".codex/state/active-batch.yml"
RUN_STATE = ROOT / ".codex/reports/current-run-state.md"
TRAIN_STATE = ROOT / ".codex/reports/current-batch-train-state.md"
QUEUE_JSON = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
PROMPT_PATTERN = re.compile(r"^Classification:\s*(\w+)\s*$", re.I | re.M)


def read_state() -> dict[str, str]:
    data = {}
    for line in ACTIVE_BATCH.read_text(encoding="utf-8").splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        data[key.strip()] = value.strip().strip('"')
    return data


def extract_current_batch(path: Path) -> str:
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


def extract_next_batch(path: Path) -> str:
    for pat in [
        r"^Next eligible batch:\s*(.+?)\s*$",
        r"^Next recommended implementation pass:\s*(.+?)\s*$",
        r"^Next eligible non-UI platform batch:\s*(.+?)\s*$",
    ]:
        m = re.search(pat, path.read_text(encoding="utf-8"), re.M)
        if m:
            return m.group(1).split(".")[0].strip()
    return ""


def queue_map() -> dict[str, str]:
    data = json.loads(QUEUE_JSON.read_text(encoding="utf-8"))
    return {entry["id"]: entry.get("classification", "") for entry in data.get("batches", [])}


def prompt_classification(batch_id: str) -> str:
    prompt = ROOT / f"prompts/batches/{batch_id}.md"
    if not prompt.exists():
        return ""
    text = prompt.read_text(encoding="utf-8", errors="ignore")
    match = PROMPT_PATTERN.search(text)
    return match.group(1).strip().lower() if match else ""


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: python3 scripts/ambitions-prompt-queue-consistency.py <BATCH_ID>")
        return 2

    target = sys.argv[1].strip()
    prompt = ROOT / f"prompts/batches/{target}.md"
    if not prompt.exists():
        print(f"FAIL: prompt missing: {prompt}")
        return 1

    state = read_state()
    current_next = state.get("next_eligible_batch", "").strip()
    queue = queue_map()

    exec_now = [batch for batch, cls in queue.items() if cls == "executable_now"]
    if len(exec_now) != 1:
        print(f"FAIL: expected 1 executable_now in queue; found {len(exec_now)}")
        return 1

    live_executable = exec_now[0]
    if current_next and current_next.split()[0] != live_executable:
        print(f"FAIL: active next batch mismatch. current={current_next}, executable_now={live_executable}")
        return 1

    if target not in queue:
        print(f"FAIL: target batch {target} not in queue")
        return 1

    # Pass on missing prompt classification labels
    label = prompt_classification(target)
    if label and label not in {"executable_now", "executable_later"}:
        print(f"FAIL: unsupported prompt classification '{label}' in {prompt}")
        return 1

    expected = queue.get(target, "")
    if label and expected != label:
        print(f"FAIL: prompt label {label} does not match queue classification {expected} for {target}")
        return 1

    run_current = extract_current_batch(RUN_STATE)
    train_current = extract_current_batch(TRAIN_STATE)
    if run_current and run_current != state.get("batch"):
        print(f"FAIL: run-state current mismatch: {run_current} vs {state.get('batch')}")
        return 1
    if train_current and train_current != state.get("batch"):
        print(f"FAIL: train-state current mismatch: {train_current} vs {state.get('batch')}")
        return 1

    run_next = extract_next_batch(RUN_STATE)
    train_next = extract_next_batch(TRAIN_STATE)
    if run_next and run_next != current_next:
        print(f"FAIL: run-state next mismatch: {run_next} vs {current_next}")
        return 1
    if train_next and train_next != current_next:
        print(f"FAIL: train-state next mismatch: {train_next} vs {current_next}")
        return 1

    print(f"PASS: {target} is queue-consistent with executable_now={live_executable}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
