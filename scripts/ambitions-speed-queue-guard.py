#!/usr/bin/env python3
"""Guard Speed Train selection against historical non-IOS26 batches."""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUTHORITY = ROOT / "docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json"
RESOLVER = ROOT / "scripts/ambitions-next-batch-resolver.py"


def resolver_batch() -> str:
    return subprocess.check_output(
        ["python3", str(RESOLVER), "--field", "batch_id"],
        cwd=ROOT,
        text=True,
    ).strip()


def main(argv: list[str]) -> int:
    expected_batch = argv[0] if argv else None
    authority = json.loads(AUTHORITY.read_text(encoding="utf-8"))
    batch = resolver_batch()
    failures: list[str] = []

    if not batch:
        failures.append("resolver returned no runnable IOS26 batch")
    if batch and not batch.startswith("IOS26-"):
        failures.append(f"resolver selected non-IOS26 historical batch {batch}")
    if expected_batch and batch != expected_batch:
        failures.append(f"requested {expected_batch}, but resolver selected {batch}")
    if authority.get("historical_batch_policy", {}).get("classification") != "historical":
        failures.append("authority JSON no longer classifies non-IOS26 batches as historical")

    if failures:
        print("RED: speed queue guard failed")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"GREEN: speed queue guard passed; next_ios26={batch}; non_ios26=historical")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
