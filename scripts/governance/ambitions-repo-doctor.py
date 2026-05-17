#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys

COMMANDS = [
    ["python3", "scripts/governance/ambitions-governance-reconcile.py", "--write"],
    ["python3", "scripts/governance/ambitions-governance-validate.py"],
    ["python3", "scripts/governance/ambitions-no-orphan-file-gate.py"],
    ["python3", "scripts/governance/ambitions-auto-archive-candidates.py"],
    ["python3", "scripts/governance/ambitions-historical-registry-extract.py"],
]


def main() -> int:
    for cmd in COMMANDS:
        print(f"RUNNING: {' '.join(cmd)}")
        proc = subprocess.run(cmd)
        if proc.returncode != 0:
            print(f"FAILED: {' '.join(cmd)}")
            return proc.returncode

    print("Ambitions repo doctor completed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
