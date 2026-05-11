#!/usr/bin/env python3
"""SessionStart hook helper for Codex.
Injects repo-aware context for local AMBITIONOS control-plane work.
"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path


def _git_root() -> str:
    try:
        out = subprocess.check_output(["git", "rev-parse", "--show-toplevel"], stderr=subprocess.DEVNULL, text=True)
        return out.strip()
    except Exception:
        return str(Path.cwd())


def _read_stdin() -> dict:
    try:
        return json.load(open(0))
    except Exception:
        return {}


def main() -> None:
    event = _read_stdin()
    git_root = _git_root()

    output = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "developerContext": {
                "runner_required": True,
                "runner_bypass_phrase": "bypass the Ambitions runner",
                "runner_boundary": "Ambitions implementation/release/OS-control prompts should route through scripts/ambitions-codex-train.sh unless explicitly bypassed",
                "git_root": git_root,
                "top_level_ia": "Today / Goals / Capture / Time / You",
                "plan_wording": "Plan is compatibility/contextual only unless explicitly scoped",
                "no_cost_policy": "No new cloud API, no hosted CI, no dependency installs, no package/network side-effect tools",
            },
            "expected_finalize_fields": [
                "STATUS: GREEN|YELLOW|RED",
                "Files changed",
                "Validation run",
                "No-cost proof",
                "Rollback",
            ],
        },
        "message": "Session context seeded for Ambitions Codex OS hardening.",
        "continue": True,
    }

    if isinstance(event, dict):
        output["sessionInput"] = event

    print(json.dumps(output))


if __name__ == "__main__":
    main()
