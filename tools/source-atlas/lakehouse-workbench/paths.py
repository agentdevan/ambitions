"""Shared local paths for the Source Atlas Lakehouse Workbench."""

from __future__ import annotations

import os
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[3]
DEFAULT_RUNS_BASE_DIR = REPO_ROOT / "output" / "source-atlas" / "lakehouse-runs"


def runs_base_dir() -> Path:
    configured = os.getenv("AMBITIONS_SOURCE_ATLAS_RUNS_DIR") or os.getenv("RUNS_BASE_DIR")
    if configured:
        return Path(configured).expanduser().resolve()
    return DEFAULT_RUNS_BASE_DIR


RUNS_BASE_DIR = runs_base_dir()
