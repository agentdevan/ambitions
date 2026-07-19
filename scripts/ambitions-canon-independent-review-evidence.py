#!/usr/bin/env python3
"""Verify exact-head independent GitHub Codex review evidence."""

from pathlib import Path
import sys


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
if str(REPOSITORY_ROOT) not in sys.path:
    sys.path.insert(0, str(REPOSITORY_ROOT))

from tools.ambitions_canon.independent_review import main


if __name__ == "__main__":
    sys.exit(main())
