#!/usr/bin/env python3
"""Compatibility wrapper for the authoritative Ambitions next-batch resolver."""
from __future__ import annotations

import runpy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
runpy.run_path(str(ROOT / "scripts/ambitions-next-batch-resolver.py"), run_name="__main__")
