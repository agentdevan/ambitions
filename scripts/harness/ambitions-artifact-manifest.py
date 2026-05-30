#!/usr/bin/env python3
"""Emit a harness artifact manifest JSON for docs-only proof lanes."""

from __future__ import annotations

import argparse
import json
import os
import platform
import subprocess
import sys
from datetime import datetime, timezone
from typing import Any


def run(cmd: list[str]) -> str:
    try:
        out = subprocess.check_output(cmd, stderr=subprocess.DEVNULL, text=True)
        return out.strip()
    except Exception:
        return ""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Emit a harness artifact manifest JSON")
    parser.add_argument("--batch-id", required=True)
    parser.add_argument("--status", required=True, choices=["Green", "Yellow", "Red"])
    parser.add_argument("--mode", default="manual")
    parser.add_argument("--command", action="append", default=[])
    parser.add_argument("--artifact", action="append", default=[])
    parser.add_argument("--claim-made", action="append", default=[])
    parser.add_argument("--claim-not-made", action="append", default=[])
    parser.add_argument("--risk", action="append", default=[])
    parser.add_argument("--next-step")
    parser.add_argument("--output", default="-")
    return parser.parse_args()


def manifest(args: argparse.Namespace) -> dict[str, Any]:
    now = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    branch = run(["git", "branch", "--show-current"]) or "unknown"
    sha = run(["git", "rev-parse", "HEAD"]) or "unknown"
    status_short = run(["git", "status", "--short"])

    return {
        "schema_version": "1.0",
        "batch_id": args.batch_id,
        "mode": args.mode,
        "status": args.status,
        "started_at_utc": None,
        "finished_at_utc": now,
        "git": {
            "branch": branch,
            "commit_sha": sha,
            "status_short": status_short,
            "dirty": bool(status_short),
        },
        "environment": {
            "machine": platform.machine(),
            "platform": platform.system(),
            "release": platform.release(),
            "python_version": platform.python_version(),
        },
        "commands": [{"command": c, "exit_code": None, "output": None} for c in args.command],
        "artifacts": [{"path": a, "exists": os.path.exists(a)} for a in args.artifact],
        "risks": args.risk,
        "claims_made": args.claim_made,
        "claims_not_made": args.claim_not_made,
        "next_recommended_step": args.next_step,
    }


def main() -> int:
    args = parse_args()
    payload = manifest(args)
    text = json.dumps(payload, indent=2) + "\n"

    if args.output == "-":
        sys.stdout.write(text)
    else:
        with open(args.output, "w", encoding="utf-8") as fh:
            fh.write(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
