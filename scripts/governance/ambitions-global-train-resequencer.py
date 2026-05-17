#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
from datetime import datetime, timezone

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


def main() -> int:
    data = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
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
