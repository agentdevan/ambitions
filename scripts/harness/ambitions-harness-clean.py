#!/usr/bin/env python3
from __future__ import annotations
import shutil, subprocess
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
def main():
    branch = subprocess.check_output(["git", "branch", "--show-current"], cwd=ROOT, text=True).strip()
    if branch != "main":
        raise SystemExit(f"Expected main, got {branch}")
    shutil.rmtree(ROOT / "build" / "reports" / "harness", ignore_errors=True)
    print("Removed generated build/reports/harness runtime output if present.")
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
