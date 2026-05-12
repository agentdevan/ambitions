#!/usr/bin/env python3
"""Route post-PK batches to the fastest safe validation lane.

This is advisory tooling for Codex Desktop/operator loops. It does not mutate
state and does not claim batch completion.
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
QUEUE = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
ACTIVE = ROOT / ".codex/state/active-batch.yml"
PROMPTS = ROOT / "prompts/batches"

LANES: dict[str, dict[str, Any]] = {
    "state_only": {
        "checks": ["git diff --check", "python3 scripts/ambitions-state-advance-validate.py"],
        "xcode": False,
        "heavy": False,
    },
    "docs_only": {
        "checks": ["git diff --check", "make prompt-audit", "python3 scripts/ambitions-unsupported-claim-scan.py <changed-files>"],
        "xcode": False,
        "heavy": False,
    },
    "prompt_only": {
        "checks": ["git diff --check", "make prompt-audit", "python3 scripts/ambitions-prompt-queue-consistency.py <batch>"],
        "xcode": False,
        "heavy": False,
    },
    "model_only": {
        "checks": ["git diff --check", "focused model tests if source touched"],
        "xcode": "focused-test",
        "heavy": False,
    },
    "service_only": {
        "checks": ["git diff --check", "focused owner service tests if available"],
        "xcode": "focused-test",
        "heavy": False,
    },
    "source_atlas": {
        "checks": ["git diff --check", "Source Atlas focused model/importer/query tests for touched owner"],
        "xcode": "focused-test when Swift source touched",
        "heavy": False,
    },
    "ui_preview": {
        "checks": ["git diff --check", "focused view-model/UI tests", "visual proof only if visual completion is claimed"],
        "xcode": "focused-test/preview only",
        "heavy": False,
    },
    "repo_hygiene": {
        "checks": ["git diff --check", "path allowlist check", "no generated/runtime artifacts unless scoped"],
        "xcode": False,
        "heavy": False,
    },
    "release_terminal": {
        "checks": ["terminal batch-defined full proof gate"],
        "xcode": True,
        "heavy": True,
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Classify the next post-PK batch into a speed lane.")
    parser.add_argument("--batch", help="Batch id to classify. Defaults to queue executable_now.")
    parser.add_argument("--json", action="store_true", help="Emit JSON.")
    parser.add_argument("--next", action="store_true", help="Print only the next batch id and lane.")
    return parser.parse_args()


def load_queue() -> list[dict[str, Any]]:
    return list(json.loads(QUEUE.read_text(encoding="utf-8")).get("batches", []))


def active_next() -> str:
    for line in ACTIVE.read_text(encoding="utf-8").splitlines():
        if line.strip().startswith("next_eligible_batch:"):
            return line.split(":", 1)[1].strip().strip('"')
    return ""


def prompt_text(batch_id: str) -> str:
    path = PROMPTS / f"{batch_id}.md"
    if path.exists():
        return path.read_text(encoding="utf-8", errors="ignore").lower()
    return ""


def queue_entry(batch_id: str, queue: list[dict[str, Any]]) -> dict[str, Any]:
    for entry in queue:
        if entry.get("id") == batch_id:
            return entry
    raise SystemExit(f"ERROR: batch not found in queue: {batch_id}")


def next_executable(queue: list[dict[str, Any]]) -> str:
    matches = [entry.get("id", "") for entry in queue if entry.get("classification") == "executable_now"]
    if len(matches) != 1:
        raise SystemExit(f"ERROR: expected exactly one executable_now batch, found {len(matches)}: {matches}")
    return matches[0]


def classify(batch_id: str, title: str, text: str) -> str:
    combined = f"{batch_id} {title} {text}".lower()
    if batch_id.startswith("RHC") or "repo hygiene" in combined or "cleanup" in combined:
        return "repo_hygiene"
    if any(token in combined for token in ["release", "testflight", "app store", "device proof", "signed archive", "privacy legal"]):
        return "release_terminal"
    if batch_id.startswith("SA") or "source atlas" in combined or "source" in title.lower():
        return "source_atlas"
    if any(token in combined for token in ["swiftui", "visual", "screenshot", "preview", "surface", "canon"]):
        return "ui_preview"
    if any(token in combined for token in ["prompt", "queue status", "classification"]):
        return "prompt_only"
    if any(token in combined for token in ["state-only", "advance train", "state repair"]):
        return "state_only"
    if any(token in combined for token in ["service", "executor", "projector", "handler", "runtime", "importer", "query"]):
        return "service_only"
    if any(token in combined for token in ["model", "schema", "ledger", "policy", "contract", "graph"]):
        return "model_only"
    return "docs_only"


def result_for(batch_id: str) -> dict[str, Any]:
    queue = load_queue()
    entry = queue_entry(batch_id, queue)
    text = prompt_text(batch_id)
    lane = classify(batch_id, entry.get("title", ""), text)
    policy = LANES[lane]
    return {
        "batch": batch_id,
        "title": entry.get("title", ""),
        "queue_classification": entry.get("classification", ""),
        "lane": lane,
        "checks": policy["checks"],
        "xcode": policy["xcode"],
        "heavy": policy["heavy"],
        "prompt": f"prompts/batches/{batch_id}.md",
    }


def main() -> int:
    args = parse_args()
    queue = load_queue()
    batch = args.batch or next_executable(queue)
    active = active_next().split()[0] if active_next() else ""
    if active and batch != active:
        raise SystemExit(f"ERROR: requested {batch}, but active next batch is {active}")
    result = result_for(batch)
    if args.json:
        print(json.dumps(result, indent=2))
    elif args.next:
        print(f"{result['batch']} {result['lane']}")
    else:
        print(f"Batch: {result['batch']} — {result['title']}")
        print(f"Lane: {result['lane']}")
        print(f"Queue: {result['queue_classification']}")
        print("Checks:")
        for check in result["checks"]:
            print(f"- {check}")
        print(f"Xcode: {result['xcode']}")
        print(f"Heavy: {result['heavy']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
