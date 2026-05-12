#!/usr/bin/env python3
"""OpenAI build suite local dry-run runner."""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.openai.repo_brain import build_repo_manifest  # noqa: E402
from tools.openai.evals import run_evals  # noqa: E402


def main() -> int:
    root = ROOT
    print("OpenAI Build Suite dry-run start")

    manifest = build_repo_manifest.build_manifest(root)
    print(f"manifest_count={manifest['count']}")

    # Keep this dry-run local-only and schema-only.
    original_argv = list(sys.argv)
    try:
        sys.argv = [sys.argv[0], "--dry-run"]
        eval_result = run_evals.main()
        if eval_result:
            return int(eval_result)
    finally:
        sys.argv = original_argv

    print("DRY RUN: launch packet + visual critique + batch report checks are available through dedicated scripts")
    print("DRY RUN: queue consistency check can run: python3 scripts/ambitions-prompt-queue-consistency.py PK28")
    print("GREEN: openai-build-suite-dry-run completed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
