#!/usr/bin/env python3
"""Route runnable global-train work after the IOS26 authority reset.

Non-IOS26 post-PK batches are historical evidence and are no longer selectable
by Codex global train runners.
"""
from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
AUTHORITY = ROOT / "docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json"
RESOLVER = ROOT / "scripts/ambitions-next-batch-resolver.py"

IOS26_LANE: dict[str, Any] = {
    "lane": "ios26_flagship_train",
    "checks": [
        "git diff --check",
        "python3 scripts/ios26-flagship-preflight.py",
        "batch-defined IOS26 proof commands",
    ],
    "xcode": "batch-defined",
    "heavy": "batch-defined",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Classify the next runnable global batch.")
    parser.add_argument("--batch", help="Batch id to classify. Defaults to the single authority resolver.")
    parser.add_argument("--json", action="store_true", help="Emit JSON.")
    parser.add_argument("--next", action="store_true", help="Print only the next batch id and lane.")
    return parser.parse_args()


def resolver_batch() -> str:
    return subprocess.check_output(
        ["python3", str(RESOLVER), "--field", "batch_id"],
        cwd=ROOT,
        text=True,
    ).strip()


def result_for(batch_id: str) -> dict[str, Any]:
    authority = json.loads(AUTHORITY.read_text(encoding="utf-8"))
    if not batch_id.startswith("IOS26-"):
        return {
            "batch": batch_id,
            "title": "",
            "classification": "historical",
            "lane": "historical_non_runnable",
            "checks": [],
            "xcode": False,
            "heavy": False,
            "prompt": None,
            "authority": "docs/codex/GLOBAL_BATCH_SEQUENCE.md",
            "reason": authority.get("historical_batch_policy", {}).get("meaning", "non-IOS26 batch is historical"),
        }
    return {
        "batch": batch_id,
        "title": "IOS26 flagship train batch",
        "classification": "ios26_runnable",
        "prompt": subprocess.check_output(
            ["python3", str(RESOLVER), "--field", "prompt_path"],
            cwd=ROOT,
            text=True,
        ).strip(),
        "authority": "docs/codex/GLOBAL_BATCH_SEQUENCE.md",
        **IOS26_LANE,
    }


def main() -> int:
    args = parse_args()
    batch = args.batch or resolver_batch()
    result = result_for(batch)
    if args.json:
        print(json.dumps(result, indent=2))
    elif args.next:
        print(f"{result['batch']} {result['lane']}")
    else:
        print(f"Batch: {result['batch']}")
        print(f"Lane: {result['lane']}")
        print(f"Classification: {result['classification']}")
        print(f"Authority: {result['authority']}")
        if result.get("reason"):
            print(f"Reason: {result['reason']}")
        if result.get("checks"):
            print("Checks:")
            for check in result["checks"]:
                print(f"- {check}")
    return 1 if result["classification"] == "historical" else 0


if __name__ == "__main__":
    raise SystemExit(main())
