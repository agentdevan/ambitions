#!/usr/bin/env python3
"""Verify the installed Ambitions Harness Slice 1 support files.

Approved boundary:
- docs/scripts/prompts only
- no app source changes
- no docs/truth changes
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

REQUIRED_FILES = [
    "docs/codex/HARNESS_README.md",
    "docs/codex/HARNESS_PLAN.md",
    "docs/codex/HARNESS_ARTIFACT_SCHEMA.md",
    "docs/codex/HARNESS_LINEAR.md",
    "docs/codex/HARNESS_RUNS.md",
    "scripts/harness/install-harness-slice1.py",
    "scripts/harness/check-slice1.py",
    "scripts/ambitions-slice1-status.py",
    "prompts/batches/HARNESS-T00-B01-baseline-audit.md",
    "prompts/batches/HARNESS-T01-B01-docs.md",
]

FUTURE_SLICE_FILES = [
    "scripts/harness/ambitions-artifact-manifest.py",
    "scripts/harness/ambitions-proof-baseline.sh",
    "scripts/harness/ambitions-static-gates.py",
    "prompts/batches/HARNESS-T02-B01-artifacts.md",
    "prompts/batches/HARNESS-T03-B01-static-gates.md",
    "prompts/batches/HARNESS-T04-B01-first-run.md",
]


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify Harness Slice 1 installation.")
    parser.add_argument("--root", default=".")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    missing = [path for path in REQUIRED_FILES if not (root / path).exists()]
    present = [path for path in REQUIRED_FILES if (root / path).exists()]
    future_missing = [path for path in FUTURE_SLICE_FILES if not (root / path).exists()]

    result = {
        "schema_version": "1.0",
        "status": "Green" if not missing else "Yellow",
        "present": present,
        "missing": missing,
        "future_slice_remaining": future_missing,
        "notes": [
            "Slice 1 was installed with flattened docs/codex/HARNESS_*.md paths because nested harness docs were blocked by the connector.",
            "Remaining future files should be installed by Codex/manual runner if connector filters continue to block direct creation.",
        ],
        "non_claims": [
            "No app source change claim.",
            "No docs/truth change claim.",
            "No distribution readiness claim.",
            "No device validation claim.",
            "No accessibility conformance claim.",
            "No performance validation claim.",
        ],
    }

    if args.json:
        print(json.dumps(result, indent=2, sort_keys=True))
    else:
        print(f"Harness Slice 1 install status: {result['status']}")
        print(f"Present required: {len(present)}")
        print(f"Missing required: {len(missing)}")
        print(f"Future remaining: {len(future_missing)}")
        for path in missing:
            print(f"MISSING {path}")

    return 0 if not missing else 1


if __name__ == "__main__":
    raise SystemExit(main())
