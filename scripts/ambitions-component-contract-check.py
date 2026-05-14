#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

from ambitions_design_system_15_common import cli


if __name__ == "__main__":
    raise SystemExit(cli("component_contract_check"))
