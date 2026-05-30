#!/usr/bin/env python3
from _ambitions_static_gate_common import run_gate
PATTERNS = {'plan_top_level': r'Today\s*/\s*Goals\s*/\s*Capture\s*/\s*Plan\s*/\s*You|\btop-level Plan\b|\bPlan top-level\b', 'new_top_level': r'\bnew top-level\b|\badditional tab\b'}
raise SystemExit(run_gate('ambitions-ia-gate', PATTERNS))
