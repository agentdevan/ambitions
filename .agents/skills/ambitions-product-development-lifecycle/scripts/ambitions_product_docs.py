#!/usr/bin/env python3
"""Ambitions product-development lifecycle entrypoint."""

from __future__ import annotations

import sys
from pathlib import Path


if not (3, 11) <= sys.version_info[:2] < (3, 15):
    print("PYTHON_VERSION_UNSUPPORTED requires Python 3.11-3.14", file=sys.stderr)
    raise SystemExit(3)

# Read-only CLI invocations must not materialize import caches in the repository.
sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))

from product_docs.cli import main  # noqa: E402 -- path and bytecode policy precede import


raise SystemExit(main())
