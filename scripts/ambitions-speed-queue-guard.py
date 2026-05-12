#!/usr/bin/env python3
"""Guard Speed Train batch selection against stale or unsafe queue state."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QUEUE = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
ACTIVE = ROOT / ".codex/state/active-batch.yml"


def read_active_next() -> str | None:
    for line in ACTIVE.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("next_eligible_batch:"):
            return stripped.split(":", 1)[1].strip().strip('"')
    return None


def main(argv: list[str]) -> int:
    expected_batch = argv[0] if argv else None
    data = json.loads(QUEUE.read_text(encoding="utf-8"))
    executable_now = [entry for entry in data.get("batches", []) if entry.get("classification") == "executable_now"]

    failures: list[str] = []
    if len(executable_now) != 1:
        failures.append(f"expected exactly one executable_now batch, found {len(executable_now)}")

    queue_batch = executable_now[0].get("id") if executable_now else None
    active_next = read_active_next()
    active_next_id = active_next.split()[0] if active_next else None

    if expected_batch and queue_batch != expected_batch:
        failures.append(f"requested {expected_batch}, but queue executable_now is {queue_batch}")
    if queue_batch and active_next_id != queue_batch:
        failures.append(f"active next batch {active_next_id} does not match queue executable_now {queue_batch}")

    if failures:
        print("RED: speed queue guard failed")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"GREEN: speed queue guard passed; executable_now={queue_batch}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
