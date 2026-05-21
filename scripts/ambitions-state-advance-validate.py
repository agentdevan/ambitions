#!/usr/bin/env python3
"""Validate that global train advancement uses the single IOS26 authority."""
from __future__ import annotations

import json
import subprocess
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


def main() -> int:
    authority = json.loads(AUTHORITY.read_text(encoding="utf-8"))
    batch = resolver_batch()
    failures: list[str] = []

    if not authority.get("single_global_batch_train_authority"):
        failures.append("authority JSON no longer declares a single global batch train authority")
    if authority.get("historical_batch_policy", {}).get("classification") != "historical":
        failures.append("non-IOS26 policy is not historical")
    if not batch:
        failures.append("resolver returned no next IOS26 batch")
    elif not batch.startswith("IOS26-"):
        failures.append(f"resolver selected non-IOS26 historical batch {batch}")

    if failures:
        print("RED: state advancement validation failed")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"GREEN: state advancement authority coherent; next_ios26={batch}; non_ios26=historical")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
