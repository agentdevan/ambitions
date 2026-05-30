#!/usr/bin/env python3
from _ambitions_static_gate_common import run_gate
PATTERNS = {'release_ready': r'\brelease ready\b|\bproduction ready\b|\bship ready\b', 'testflight': r'\bTestFlight ready\b|\bApp Store ready\b', 'unproven_build': r'\bbuild passed\b|\btests passed\b|\bCI green\b', 'privacy_legal': r'\bprivacy approved\b|\blegal approved\b'}
raise SystemExit(run_gate('ambitions-claim-discipline-gate', PATTERNS))
