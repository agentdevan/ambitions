#!/usr/bin/env python3
"""Harness Slice 1 bootstrap coordinator.

This script is intentionally small. It does not generate source files from an embedded
payload. Slice 1 files should exist as normal repo files under:

- docs/codex/harness/
- scripts/harness/
- prompts/batches/HARNESS-*.md

Approved boundary:
- docs/scripts/prompts only
- no app source changes
- no docs/truth changes
- no release claims
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

REQUIRED_FILES = [
    "docs/codex/harness/README.md",
    "docs/codex/harness/HARNESS_10_10_PLAN.md",
    "docs/codex/harness/HARNESS_ARTIFACT_SCHEMA.md",
    "docs/codex/harness/HARNESS_LINEAR_PROTOCOL.md",
    "docs/codex/harness/HARNESS_MANUAL_RUNNER_PROTOCOL.md",
    "docs/codex/harness/HARNESS_SCORECARD.md",
    "scripts/harness/ambitions-artifact-manifest.py",
    "scripts/harness/ambitions-proof-baseline.sh",
    "scripts/harness/ambitions-xcresult-summary.py",
    "scripts/harness/ambitions-product-language-gate.py",
    "scripts/harness/ambitions-ia-gate.py",
    "scripts/harness/ambitions-local-only-gate.py",
    "scripts/harness/ambitions-architecture-gate.py",
    "scripts/harness/ambitions-claim-discipline-gate.py",
    "prompts/batches/HARNESS-T00-B01-baseline-audit.md",
    "prompts/batches/HARNESS-T01-B01-harness-doc-portal.md",
    "prompts/batches/HARNESS-T02-B01-artifact-manifest-schema.md",
    "prompts/batches/HARNESS-T02-B02-proof-wrapper-scripts.md",
    "prompts/batches/HARNESS-T03-B01-static-gates.md",
    "prompts/batches/HARNESS-T04-B01-first-proof-wrapper-run.md",
    "prompts/batches/HARNESS-T04-B02-app-driving-proof-decision.md",
]


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify Harness Slice 1 file installation.")
    parser.add_argument("--root", default=".", help="Repo root. Default: current directory.")
    parser.add_argument("--json", action="store_true", help="Print JSON only.")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    missing = [path for path in REQUIRED_FILES if not (root / path).exists()]
    present = [path for path in REQUIRED_FILES if (root / path).exists()]

    result = {
        "schema_version": "1.0",
        "status": "Green" if not missing else "Yellow",
        "present": present,
        "missing": missing,
        "claims_not_made": [
            "No app source change claim.",
            "No docs/truth change claim.",
            "No release readiness claim.",
            "No TestFlight readiness claim.",
            "No App Store readiness claim.",
            "No device validation claim.",
            "No accessibility conformance claim.",
            "No performance validation claim.",
        ],
    }

    if args.json:
        print(json.dumps(result, indent=2, sort_keys=True))
    else:
        print(f"Harness Slice 1 install status: {result['status']}")
        print(f"Present: {len(present)}")
        print(f"Missing: {len(missing)}")
        for path in missing:
            print(f"MISSING {path}")

    return 0 if not missing else 1


if __name__ == "__main__":
    raise SystemExit(main())
