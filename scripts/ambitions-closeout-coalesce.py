#!/usr/bin/env python3
"""Plan or stage a single coalesced closeout commit for a batch.

The intended post-PK pattern is one commit containing implementation, focused
proof/report, and state advancement. This helper lists the exact candidate files
and can stage them with --stage after Codex has verified the scope.
"""
from __future__ import annotations

import argparse
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STATE_FILES = [
    ".codex/state/active-batch.yml",
    ".codex/reports/current-run-state.md",
    ".codex/reports/current-batch-train-state.md",
    ".codex/state/global-train-attempt-ledger.md",
    "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json",
    "docs/codex/BATCH_REGISTRY.md",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Plan/stage a coalesced batch closeout commit.")
    parser.add_argument("--batch", required=True, help="Batch id, e.g. SA07")
    parser.add_argument("--stage", action="store_true", help="Stage the planned files.")
    parser.add_argument("--include-untracked", action="store_true", default=True)
    return parser.parse_args()


def git_lines(*args: str) -> list[str]:
    proc = subprocess.run(["git", *args], cwd=ROOT, text=True, capture_output=True, check=False)
    return [line.strip() for line in proc.stdout.splitlines() if line.strip()]


def changed_files() -> list[str]:
    files = set(git_lines("diff", "--name-only", "HEAD"))
    files.update(git_lines("ls-files", "--others", "--exclude-standard"))
    return sorted(path for path in files if not path.startswith(".codex/runs/"))


def classify(path: str, batch: str) -> str:
    lower = path.lower()
    if path in STATE_FILES:
        return "state"
    if f"{batch.lower()}" in lower and (lower.startswith("docs/audits/") or lower.startswith("prompts/batches/")):
        return "batch_report_or_prompt"
    if lower.startswith("native/ambitionstests/") or lower.startswith("tests/"):
        return "focused_test"
    if lower.startswith("native/ambitions/") or lower.startswith("sources/"):
        return "implementation"
    if lower.startswith("docs/"):
        return "docs"
    if lower.startswith("scripts/") or lower.startswith("tools/") or lower == "makefile":
        return "tooling"
    return "other"


def main() -> int:
    args = parse_args()
    files = changed_files()
    if not files:
        print("No changed files outside .codex/runs.")
        return 0

    print(f"Coalesced closeout candidate for {args.batch}:")
    for path in files:
        print(f"- {classify(path, args.batch):24} {path}")

    missing_state = [path for path in STATE_FILES if Path(ROOT / path).exists() and path not in files]
    if missing_state:
        print("State files not changed in this closeout candidate:")
        for path in missing_state:
            print(f"- {path}")

    if args.stage:
        subprocess.run(["git", "add", "--", *files], cwd=ROOT, check=True)
        print(f"STAGED {len(files)} files")
    else:
        print("Dry run only. Re-run with --stage after scope review.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
