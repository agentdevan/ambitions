#!/usr/bin/env python3
"""Check Ambitions train mirrors against the single global sequence authority."""
from __future__ import annotations

import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACTIVE_BATCH = ROOT / ".codex/state/active-batch.yml"
AUTHORITY = ROOT / "docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json"
RESOLVER = ROOT / "scripts/ambitions-next-batch-resolver.py"


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise SystemExit(f"RED: missing required state file: {path.relative_to(ROOT)}")


def active_value(text: str, key: str) -> str | None:
    match = re.search(rf"^\s*{re.escape(key)}:\s*\"?([^\"\n]+)\"?\s*$", text, re.MULTILINE)
    return match.group(1).strip() if match else None


def resolver_batch() -> str:
    return subprocess.check_output(
        ["python3", str(RESOLVER), "--field", "batch_id"],
        cwd=ROOT,
        text=True,
    ).strip()


def main() -> int:
    authority = json.loads(read(AUTHORITY))
    active = read(ACTIVE_BATCH)
    current = active_value(active, "batch") or ""
    next_from_state = active_value(active, "next_eligible_batch") or ""
    selected = resolver_batch()
    failures: list[str] = []

    if authority.get("historical_batch_policy", {}).get("classification") != "historical":
        failures.append("authority JSON does not classify non-IOS26 batches as historical")
    if not selected:
        failures.append("resolver did not select an IOS26 batch")
    elif not selected.startswith("IOS26-"):
        failures.append(f"resolver selected non-IOS26 historical batch {selected}")

    if failures:
        print("RED: stale state authority check failed")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(
        "GREEN: state mirrors are historical for non-IOS26 selection; "
        f"current_mirror={current or 'none'}; next_mirror={next_from_state or 'none'}; "
        f"authoritative_next={selected}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
