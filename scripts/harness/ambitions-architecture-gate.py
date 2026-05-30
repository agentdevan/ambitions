#!/usr/bin/env python3
from _ambitions_static_gate_common import run_gate
PATTERNS = {'rejected_architecture': r'\bVIPER\b|\bCombine-first MVVM\b|\bHummingbird\b', 'unscoped_refactor': r'\bbroad refactor\b|\bfull rewrite\b'}
raise SystemExit(run_gate('ambitions-architecture-gate', PATTERNS))
