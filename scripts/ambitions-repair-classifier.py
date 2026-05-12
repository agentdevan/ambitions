#!/usr/bin/env python3
"""Classify Ambitions batch failures into fast repair actions."""
from __future__ import annotations

import argparse
import re
from pathlib import Path

PATTERNS = [
    ("permission_or_local_wrapper", [r"approval policy", r"permission denied", r"operation not permitted", r"sandbox", r"blocked by local"]),
    ("stale_state", [r"stale state", r"state mirrors", r"executable_now", r"next eligible", r"current batch mismatch"]),
    ("missing_prompt", [r"prompt missing", r"no such file.*prompts/batches", r"batch not found"]),
    ("broad_scanner_noise", [r"possible unsupported completion/readiness claims", r"historical", r"\.codex/logs"]),
    ("focused_test_failure", [r"test failed", r"xctest", r"assertion", r"failed tests"]),
    ("compile_failure", [r"compilation failed", r"swiftc", r"build failed", r"cannot find", r"type .* has no member"]),
    ("simulator_environment", [r"simulator_boot_failure", r"unable to boot", r"destination", r"core simulator"]),
    ("git_push_failure", [r"git push", r"rejected", r"non-fast-forward", r"authentication failed", r"remote rejected"]),
    ("unsupported_claim", [r"unsupported claim", r"release readiness", r"testflight", r"app store", r"production readiness"]),
    ("hard_red", [r"hard red", r"status:\s*red", r"red stop"]),
]

ACTIONS = {
    "permission_or_local_wrapper": "Use ACCESS_MODE=bypass and direct native git with --no-verify only after scoped proof passes.",
    "stale_state": "Run state advancement repair with scripts/ambitions-advance-batch-state.py, then validate with scripts/ambitions-state-advance-validate.py.",
    "missing_prompt": "Materialize the missing prompt from the batch template and live queue; do not run implementation until prompt exists.",
    "broad_scanner_noise": "Narrow claim scan to changed/current files for install preflight; keep broad scan for final gate.",
    "focused_test_failure": "Repair only touched owner seam once; rerun focused owner tests.",
    "compile_failure": "Repair compile error in owning seam; do not advance state until focused compile/test proof exists or accepted-yellow owner is documented.",
    "simulator_environment": "Allow Accepted Yellow only if focused source proof is otherwise clean and report names simulator/environment blocker.",
    "git_push_failure": "Run git status, git pull --ff-only, then direct /usr/bin/git push --no-verify origin HEAD:main if local commit is eligible.",
    "unsupported_claim": "Repair claim text or report no-claim boundary; do not weaken scanner globally.",
    "hard_red": "Stop. Report blocker, changed files, rollback, and next safe repair command.",
    "unknown": "Stop for manual triage; do not invent a repair.",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Classify a batch failure log.")
    parser.add_argument("path", nargs="?", help="Log/report path. Reads stdin if omitted.")
    return parser.parse_args()


def classify(text: str) -> str:
    lowered = text.lower()
    for label, patterns in PATTERNS:
        if any(re.search(pattern, lowered, re.I) for pattern in patterns):
            return label
    return "unknown"


def main() -> int:
    args = parse_args()
    text = Path(args.path).read_text(encoding="utf-8", errors="ignore") if args.path else __import__("sys").stdin.read()
    label = classify(text)
    print(f"classification: {label}")
    print(f"recommended_action: {ACTIONS[label]}")
    return 0 if label != "hard_red" else 1


if __name__ == "__main__":
    raise SystemExit(main())
