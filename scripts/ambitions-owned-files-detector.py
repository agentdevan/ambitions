#!/usr/bin/env python3
"""Classify changed files for safe Ambitions batch staging.

Speed helper only. It does not mutate the worktree unless --print-git-add is copied
or evaluated by an operator/runner.
"""
from __future__ import annotations

import argparse
import json
import shlex
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
FORBIDDEN_PREFIXES = (
    ".codex/runs/",
    ".codex/DerivedData/",
    ".codex/xcode-results/",
    ".codex/xcode-logs/",
    ".codex/xcode-summaries/",
)
FORBIDDEN_EXACT = {
    "Package.resolved",
    "project.yml",
    "Ambitions.xcodeproj/project.pbxproj",
}
SUPPORT_PREFIXES = (
    "docs/audits/",
    "build/reports/",
    "scripts/",
    "docs/codex/",
    "prompts/batches/",
    ".codex/state/",
    ".codex/reports/",
)


def run(cmd: list[str]) -> tuple[int, str, str]:
    proc = subprocess.run(cmd, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return proc.returncode, proc.stdout, proc.stderr


def changed_files() -> list[str]:
    code, stdout, stderr = run(["git", "status", "--porcelain"])
    if code != 0:
        raise RuntimeError(stderr or "git status failed")
    files: list[str] = []
    for line in stdout.splitlines():
        if not line:
            continue
        path = line[3:].strip()
        if " -> " in path:
            path = path.split(" -> ", 1)[1]
        files.append(path)
    return files


def batch_tokens(batch_id: str) -> set[str]:
    base = batch_id.lower()
    return {base, base.replace("-", "_"), base.replace("-", ""), base.split("-", 1)[0]}


def classify(path: str, batch_id: str) -> str:
    if path in FORBIDDEN_EXACT or path.startswith(FORBIDDEN_PREFIXES):
        return "forbidden"
    tokens = batch_tokens(batch_id)
    lower = path.lower()
    if any(token and token in lower for token in tokens):
        return "owned_by_current_batch"
    if lower.startswith("docs/audits/"):
        return "report_or_proof"
    if lower.startswith(SUPPORT_PREFIXES):
        return "allowed_support_file"
    return "external_dirty_file"


def build_result(batch_id: str) -> dict[str, Any]:
    files = changed_files()
    buckets: dict[str, list[str]] = {
        "owned_by_current_batch": [],
        "report_or_proof": [],
        "allowed_support_file": [],
        "external_dirty_file": [],
        "forbidden": [],
    }
    for path in files:
        buckets[classify(path, batch_id)].append(path)
    safe = buckets["owned_by_current_batch"] + buckets["report_or_proof"]
    # Support files are not staged automatically unless explicitly requested; they may be shared governance.
    return {
        "batch_id": batch_id,
        "changed_count": len(files),
        "safe_to_stage_default": sorted(safe),
        "requires_operator_review": sorted(buckets["allowed_support_file"] + buckets["external_dirty_file"] + buckets["forbidden"]),
        "buckets": {key: sorted(value) for key, value in buckets.items()},
        "claim_boundary": "classification only; does not prove ownership or validation",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Classify changed files for current batch staging.")
    parser.add_argument("--batch", required=True, help="Current batch ID")
    parser.add_argument("--json", action="store_true", help="Print JSON classification")
    parser.add_argument("--print-git-add", action="store_true", help="Print git add command for default-safe files")
    args = parser.parse_args()

    result = build_result(args.batch)
    if args.print_git_add:
        safe = result["safe_to_stage_default"]
        if not safe:
            print("# no default-safe files to stage")
        else:
            print("git add " + " ".join(shlex.quote(path) for path in safe))
    else:
        print(json.dumps(result, indent=2, sort_keys=True))
    return 1 if result["buckets"]["forbidden"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
