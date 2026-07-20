#!/usr/bin/env python3
"""Ambitions product-canon compiler entrypoint."""

from __future__ import annotations

import sys
from pathlib import Path


if not (3, 11) <= sys.version_info[:2] < (3, 15):
    print("PYTHON_VERSION_UNSUPPORTED requires Python 3.11-3.14", file=sys.stderr)
    raise SystemExit(2)

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.ambitions_canon.cli import main


raise SystemExit(main())
