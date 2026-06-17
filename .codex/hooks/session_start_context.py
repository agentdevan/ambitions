#!/usr/bin/env python3
"""SessionStart hook helper for Codex.
Injects repo-aware context for local Ambitions control-plane work.
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
                "persistent_surfaces": "Today / Goals / Time / You",
                "global_composer": "Capture",
                "capture_model": "Capture is the global Atmosphere Composer/Open Field composer, not a tab or root destination",
                "motion_model": "Motion is Stage/Motion cross-surface behavior, not a tab or root destination",
                "trust_model": "Proof / Source / Privacy / History / Receipts are inspectable trust details",
                "account_model": "Ambitions Account is optional launch identity/entitlement infrastructure; offline core works with no account",
                "r2_model": "R2/Source Atlas is public/reference/freshness infrastructure, not a user-data backend",
                "ai_boundary": "Hosted AI services and cloud LLMs are not core architecture",
                "compatibility_names": "Plan/Profile/Captures/Pulse/Motion-tab/Capture-tab are historical or compatibility context unless explicitly scoped",
                "no_cost_policy": "No new dependency, hosted service, CI, entitlement, R2, account, or network side-effect work unless explicitly scoped and approved",
            },
            "expected_finalize_fields": [
                "STATUS: GREEN|YELLOW|RED",
                "Files changed",
                "Product law preserved",
                "Validation run",
                "Validation not run",
                "Proof artifacts",
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
