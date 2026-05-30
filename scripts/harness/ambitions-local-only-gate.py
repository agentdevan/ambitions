#!/usr/bin/env python3
from _ambitions_static_gate_common import run_gate
PATTERNS = {'required_cloud_ai': r'\brequired cloud\b|\bserver-side planning\b|\bhosted inference\b|\bcloud LLM\b', 'analytics': r'\banalytics SDK\b|\btracking SDK\b|\bremote config\b'}
raise SystemExit(run_gate('ambitions-local-only-gate', PATTERNS))
