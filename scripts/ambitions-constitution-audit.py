#!/usr/bin/env python3
"""Compatibility entry point for the canonical constitution audit."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CANON_AUDIT = ROOT / "scripts" / "ambitions-canon.py"


def main() -> int:
    """Preserve the established CI command while delegating to active canon."""
    completed = subprocess.run([sys.executable, str(CANON_AUDIT), "audit"], cwd=ROOT, check=False)
    return completed.returncode


if __name__ == "__main__":
    raise SystemExit(main())
