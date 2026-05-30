#!/usr/bin/env python3
from __future__ import annotations
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
def main():
    state_path = ROOT / ".codex/state/harness-state.json"
    state = json.loads(state_path.read_text()) if state_path.exists() else {}
    next_slice = state.get("next_eligible_slice", 7)
    print(json.dumps({"next_eligible_slice": next_slice, "command": f"python3 scripts/harness/ambitions_harness_slice_runner.py --slice {next_slice}", "claims_not_made": ["No release readiness claim"]}, indent=2))
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
