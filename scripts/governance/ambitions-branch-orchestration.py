#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
from datetime import datetime, timezone

OUT = Path("docs/governance/generated/branch_orchestration_plan.json")


def main() -> int:
    plan = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "segments": [
            {"name": "governance", "branch_prefix": "governance/"},
            {"name": "canon", "branch_prefix": "canon/"},
            {"name": "frontend", "branch_prefix": "frontend/"},
            {"name": "platform", "branch_prefix": "platform/"},
            {"name": "prompts", "branch_prefix": "prompts/"},
        ],
        "rules": [
            "Do not mix governance and frontend implementation in the same autonomous PR when avoidable.",
            "Canon updates should precede propagation rewrites.",
            "Governance Reds block feature PRs.",
        ],
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(plan, indent=2) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
