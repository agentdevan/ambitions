#!/usr/bin/env python3
"""Print the Speed Train validation lane for a batch.

This is advisory. The batch prompt remains source of truth, but Speed Train uses
this to make the next proof expectation visible before a child batch runs.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QUEUE = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
POLICY = ROOT / "docs/codex/SPEED_TRAIN_LANE_POLICY.json"
PROMPTS = ROOT / "prompts/batches"


def load_queue() -> dict[str, dict]:
    data = json.loads(QUEUE.read_text(encoding="utf-8"))
    return {entry.get("id", ""): entry for entry in data.get("batches", [])}


def prompt_text(batch_id: str) -> str:
    path = PROMPTS / f"{batch_id}.md"
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8", errors="ignore").lower()


def classify(batch_id: str) -> str:
    text = prompt_text(batch_id)
    if any(token in batch_id for token in ["RHC", "FCP27", "FCP28", "FCP29", "FCP30", "PFC37", "PFC38", "PFC39", "PFC40"]):
        if "device" in text or "release" in text or "app store" in text:
            return "terminal_release_or_device"
    if "swiftdata" in text or "persistence" in text or "schema" in text or "migration" in text:
        return "persistence_or_schema"
    if "view" in text or "swiftui" in text or "visual" in text or "screenshot" in text:
        return "ui_visual"
    if "service" in text or "executor" in text or "projector" in text or "handler" in text:
        return "service_seam"
    if "domain" in text or "model" in text or "ledger" in text or "policy" in text:
        return "domain_model"
    if batch_id.startswith(("SA", "AOS", "LDI", "PK")):
        return "service_seam"
    return "docs_control_plane"


def main(argv: list[str]) -> int:
    if not argv:
        print("usage: scripts/ambitions-speed-lane-policy.py BATCH_ID", file=sys.stderr)
        return 2
    batch_id = argv[0]
    queue = load_queue()
    if batch_id not in queue:
        print(f"RED: batch not found in queue: {batch_id}")
        return 1

    policy = json.loads(POLICY.read_text(encoding="utf-8"))
    lane = classify(batch_id)
    lane_policy = policy.get("lanes", {}).get(lane, {})

    print(f"Speed lane: {lane}")
    print(f"Batch: {batch_id} — {queue[batch_id].get('title', '')}")
    print(f"Queue class: {queue[batch_id].get('classification', '')}")
    benchmark = policy.get("benchmark_helper", {})
    if benchmark:
        print(f"Benchmark helper: {benchmark.get('status_command', '')}")
        print(f"Benchmark artifacts: {benchmark.get('artifact_root', '')}")
    print("Required checks:")
    for command in lane_policy.get("required", []):
        print(f"- {command}")
    print(f"Xcode required: {lane_policy.get('xcode_required', False)}")
    print(f"Full suite required: {lane_policy.get('full_suite_required', False)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
