#!/usr/bin/env python3
"""Validate that the Historical Baseline train is installed in repo governance.

This guard verifies installation/discoverability only. It does not prove implementation,
build success, UI quality, privacy approval, release readiness, or device readiness.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_BATCHES = [
    "HBI-00",
    "HBI-01",
    "HBI-02",
    "HBI-03",
    "HBI-04",
    "HBI-05",
    "HBI-06",
    "HBI-07",
    "HBI-08",
    "SCI-01",
    "SCI-02",
    "SCI-03",
    "IRQ-01",
    "IRQ-02",
    "HBI-09",
    "HBI-10",
    "PRI-01",
    "RHE-01",
    "PPL-01",
    "PPL-02",
    "LSF-01",
    "MGP-01",
    "RRE-01",
]

REQUIRED_FILES = [
    "docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md",
    "docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json",
    "docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md",
]

REQUIRED_PROMPT_MARKERS = [
    "AMBITIONS_RUNNER_REQUIRED: true",
    "RUN_WITH: scripts/ambitions-codex-train.sh",
    "DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner",
    "## Batch ID",
    "## Runner command",
]


def fail(message: str) -> None:
    print(f"Historical Baseline train guard: FAIL - {message}", file=sys.stderr)
    raise SystemExit(1)


def require_file(path: str) -> Path:
    file_path = ROOT / path
    if not file_path.is_file():
        fail(f"missing required file: {path}")
    return file_path


def main() -> int:
    for path in REQUIRED_FILES:
        require_file(path)

    manifest_path = require_file("docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json")
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"manifest is not valid JSON: {exc}")

    manifest_batches = {entry.get("id"): entry for entry in manifest.get("batches", [])}
    missing_manifest_batches = [batch for batch in REQUIRED_BATCHES if batch not in manifest_batches]
    if missing_manifest_batches:
        fail(f"manifest missing batches: {', '.join(missing_manifest_batches)}")

    for batch in REQUIRED_BATCHES:
        prompt_path = Path("prompts/batches") / f"{batch}.md"
        file_path = require_file(str(prompt_path))
        text = file_path.read_text(encoding="utf-8")
        for marker in REQUIRED_PROMPT_MARKERS:
            if marker not in text:
                fail(f"{prompt_path} missing marker: {marker}")
        if batch not in text:
            fail(f"{prompt_path} does not mention its batch id")

    overlay_text = require_file("docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md").read_text(
        encoding="utf-8"
    )
    train_text = require_file(
        "docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md"
    ).read_text(encoding="utf-8")

    for batch in REQUIRED_BATCHES:
        if batch not in overlay_text and batch not in train_text:
            fail(f"batch not represented in overlay/train docs: {batch}")

    print("Historical Baseline train guard: PASS")
    print(f"Verified {len(REQUIRED_BATCHES)} runner-compatible batch prompts.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
