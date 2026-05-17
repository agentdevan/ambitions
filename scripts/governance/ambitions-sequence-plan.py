#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys

# Canonical compatibility wrapper.
# The actual implementation lives in:
# scripts/governance/ambitions-global-train-resequencer.py

cmd = ["python3", "scripts/governance/ambitions-global-train-resequencer.py"]
raise SystemExit(subprocess.run(cmd).returncode)
