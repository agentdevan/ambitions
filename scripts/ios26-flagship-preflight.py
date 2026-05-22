#!/usr/bin/env python3
"""Preflight validator for the installed IOS26 flagship train."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml"
RUNBOOK = ROOT / "docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md"
BATCH_DIR = ROOT / "prompts/batches"
TRAIN_DIR = ROOT / "prompts/trains/ios26-flagship"
HEADER_LINES = [
    "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
    "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
    "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
]
REQUIRED_SECTIONS = [
    "## Batch type",
    "## Objective",
    "## Why this exists",
    "## Dependencies",
    "## Truth files to read",
    "## Exact source areas to inspect",
    "## Exact changes allowed",
    "## Exact changes forbidden",
    "## Implementation steps",
    "## Tests to add/update",
    "## Commands to run",
    "## Required proof artifacts",
    "## Accessibility requirements",
    "## Privacy/local-first requirements",
    "## iOS 26 API verification requirements",
    "## Green / Yellow / Red closeout rules",
    "## Rollback strategy",
    "## Final report format",
]
FORBIDDEN_CLAIMS = [
    "release-ready",
    "App Store-ready",
    "TestFlight-ready",
    "device-verified",
    "fully accessible",
    "performance validated",
    "privacy approved",
    "legally approved",
]


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def run_git_status() -> list[str]:
    result = subprocess.run(
        ["git", "status", "--short"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        return [f"git status failed: {result.stderr.strip()}"]
    return result.stdout.splitlines()


def parse_manifest_batches() -> list[str]:
    text = MANIFEST.read_text(encoding="utf-8")
    return re.findall(r"^\s+- (IOS26-T\d{2}A?-B\d{2})\s*$", text, flags=re.MULTILINE)


def expected_prompt_path(batch_id: str) -> Path | None:
    matches = sorted(BATCH_DIR.glob(f"{batch_id}-*.md"))
    if len(matches) == 1:
        return matches[0]
    return None


def check_batch_prompt(path: Path) -> list[str]:
    issues: list[str] = []
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if lines[:3] != HEADER_LINES:
        issues.append(f"{rel(path)}: runner header is missing or not first")
    for section in REQUIRED_SECTIONS:
        if section not in text:
            issues.append(f"{rel(path)}: missing {section}")
    for claim in FORBIDDEN_CLAIMS:
        if claim in text and "Forbidden" not in text:
            issues.append(f"{rel(path)}: possible unsupported claim `{claim}`")
    if "Status: Green / Yellow / Red" not in text:
        issues.append(f"{rel(path)}: missing final report status line")
    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--batch", help="Optional batch id to validate in isolation.")
    parser.add_argument("--strict-dirty", action="store_true", help="Fail if tracked or untracked worktree changes exist.")
    args = parser.parse_args()

    issues: list[str] = []
    for path in [MANIFEST, RUNBOOK, BATCH_DIR, TRAIN_DIR]:
        if not path.exists():
            issues.append(f"missing required path: {rel(path)}")

    if issues:
        for issue in issues:
            print(f"RED: {issue}")
        return 1

    manifest_batches = parse_manifest_batches()
    if len(manifest_batches) != 57:
        issues.append(f"expected 57 manifest batches, found {len(manifest_batches)}")
    if len(set(manifest_batches)) != len(manifest_batches):
        issues.append("manifest contains duplicate IOS26 batch ids")

    selected = [args.batch] if args.batch else manifest_batches
    for batch_id in selected:
        if batch_id not in manifest_batches:
            issues.append(f"{batch_id}: not listed in manifest")
            continue
        prompt = expected_prompt_path(batch_id)
        if prompt is None:
            issues.append(f"{batch_id}: expected exactly one prompt file")
            continue
        issues.extend(check_batch_prompt(prompt))
        runbook_command = f"scripts/ambitions-codex-train.sh {batch_id} {rel(prompt)}"
        if runbook_command not in RUNBOOK.read_text(encoding="utf-8"):
            issues.append(f"{batch_id}: runbook missing exact command")

    train_prompts = sorted(TRAIN_DIR.glob("TRAIN_*.md"))
    if len(train_prompts) != 18:
        issues.append(f"expected 18 train prompt files, found {len(train_prompts)}")

    if args.strict_dirty:
        dirty = run_git_status()
        if dirty:
            issues.append("worktree is dirty under --strict-dirty")
            issues.extend(f"dirty: {line}" for line in dirty[:30])

    if issues:
        for issue in issues:
            print(f"RED: {issue}")
        return 1

    print("GREEN: IOS26 flagship train preflight passed")
    print(f"batches={len(manifest_batches)}")
    print(f"train_prompts={len(train_prompts)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
