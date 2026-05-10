#!/usr/bin/env python3
"""Run the read-only Ambitions control-plane checks as one gate.

This script intentionally performs no repo mutation. It is designed to be run
before advancing to the next batch, before accepting a final report, and after
queue/control-plane edits.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

BASE_CHECKS = [
    [sys.executable, "-m", "json.tool", "docs/codex/AMB_REMAINING_BATCH_REFERENCE.json"],
    [sys.executable, "-m", "json.tool", "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"],
    [sys.executable, "scripts/ambitions-queue-snapshot.py", "--strict"],
    [sys.executable, "scripts/ambitions-source-atlas-title-check.py", "--strict"],
]


def run_command(command: list[str]) -> dict[str, object]:
    result = subprocess.run(
        command,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    return {
        "command": " ".join(command),
        "exit_code": result.returncode,
        "stdout": result.stdout.strip(),
        "stderr": result.stderr.strip(),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Run Ambitions control-plane checks")
    parser.add_argument(
        "--final-report",
        action="append",
        default=[],
        help="Optional final report path to validate with ambitions-final-report-gate.py. May be passed more than once.",
    )
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON")
    args = parser.parse_args()

    checks = list(BASE_CHECKS)
    for report in args.final_report:
        checks.append([sys.executable, "scripts/ambitions-final-report-gate.py", report, "--strict"])

    results = [run_command(command) for command in checks]
    failures = [result for result in results if result["exit_code"] != 0]
    status = "RED" if failures else "GREEN"
    payload = {
        "status": status,
        "checks": results,
        "failure_count": len(failures),
        "non_claims": [
            "This gate does not prove app build success.",
            "This gate does not prove UI visual quality.",
            "This gate does not prove accessibility conformance.",
            "This gate does not prove release/TestFlight/App Store readiness.",
            "This gate does not prove physical-device behavior.",
        ],
    }

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(f"STATUS: {status}")
        for result in results:
            print()
            print(f"$ {result['command']}")
            print(f"exit_code: {result['exit_code']}")
            if result["stdout"]:
                print("stdout:")
                print(result["stdout"])
            if result["stderr"]:
                print("stderr:")
                print(result["stderr"])
        print("\nNon-claims:")
        for item in payload["non_claims"]:
            print(f"- {item}")

    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
