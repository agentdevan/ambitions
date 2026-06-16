#!/usr/bin/env python3
"""Compatibility launcher for the resilient release recovery autopilot."""

from __future__ import annotations

from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
TARGET = ROOT / "scripts" / "release_recovery" / "autopilot_v2.py"

if __name__ == "__main__":
    raise SystemExit(
        subprocess.run([sys.executable, TARGET.as_posix(), *sys.argv[1:]], cwd=ROOT, check=False).returncode
    )
