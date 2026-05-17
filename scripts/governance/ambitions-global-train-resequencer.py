#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import subprocess

OUT = Path("docs/governance/generated/global_train_resequence.json")

LANES = [
    "governance_repair",
    "canon_propagation",
    "prompt_alignment",
    "frontend_authority",
    "implementation",
    "proof_closeout",
    "archive_cleanup"
]


def git_commit_iso() -> str:
    proc = subprocess.run(
        ["git", "show", "-s", "--format=%cI", "HEAD"],
        cwd=Path(__file__).resolve().parents[2],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    return proc.stdout.strip() or "unknown"


def main() -> int:
    data = {
        "generated_at": git_commit_iso(),
        "lanes": LANES,
        "rules": [
            "governance_red_before_feature_work",
            "canon_dependency_before_implementation",
            "smallest_safe_unit_first",
            "frontend_authority_before_visible_ui_changes"
        ]
    }

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
