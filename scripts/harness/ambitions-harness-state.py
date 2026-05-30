#!/usr/bin/env python3
from __future__ import annotations
import json, subprocess
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
def main():
    state_path = ROOT / ".codex/state/harness-state.json"
    state = json.loads(state_path.read_text()) if state_path.exists() else {}
    state["branch"] = subprocess.check_output(["git", "branch", "--show-current"], cwd=ROOT, text=True).strip()
    state["sha"] = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    state["dirty"] = bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT, text=True).strip())
    state["resume_command"] = "python3 scripts/harness/ambitions_harness_slice_runner.py --slice <next>"
    state["rollback_command"] = "git revert <sha>"
    print(json.dumps(state, indent=2))
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
