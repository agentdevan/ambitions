#!/usr/bin/env python3
import sys

if sys.version_info < (3, 12) or sys.version_info >= (3, 15):
    print(
        "PYTHON_VERSION_UNSUPPORTED requires Python 3.12-3.14",
        file=sys.stderr,
    )
    raise SystemExit(2)

from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.ambitions_canon.cli import main

raise SystemExit(main())
