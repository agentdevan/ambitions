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
STATE = ROOT / "docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml"
BATCH_DIR = ROOT / "prompts/batches"
TRAIN_DIR = ROOT / "prompts/trains/ios26-flagship"
REPLACEMENT_DOCS = [
    ROOT / "docs/codex/IOS26_CORE_REPLACEMENT_P0_CONTRACTS.md",
    ROOT / "docs/codex/IOS26_CORE_REPLACEMENT_JOURNEY_SPEC.md",
    ROOT / "docs/codex/IOS26_CORE_LIFE_OPERATIONS_ARCHITECTURE.md",
]
HEADER_LINES = [
    "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
    "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
    "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
]
REQUIRED_REPLACEMENT_SECTIONS = [
    "## Batch type",
    "## Objective",
    "## End-user job being replaced",
    "## Replacement P0 contract",
    "## Why this exists",
    "## Dependencies",
    "## Truth files to read",
    "## Exact source areas to inspect",
    "## Exact changes allowed",
    "## Exact changes forbidden",
    "## Required implementation behavior",
    "## Required tests",
    "## Commands to run",
    "## Required proof artifacts",
    "## Accessibility requirements",
    "## Privacy/local-first requirements",
    "## Performance requirements",
    "## iOS 26 API verification requirements",
    "## Green / Yellow / Red closeout rules",
    "## Rollback strategy",
    "## Final report format",
]
REQUIRED_LEGACY_SECTIONS = [
    "## Batch type",
    "## Objective",
    "## Why this exists",
    "## Dependencies",
    "## Truth files to read",
    "## Exact source areas to inspect",
    "## Exact changes allowed",
    "## Exact changes forbidden",
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
BATCH_RE = re.compile(r"IOS26-T\d{2}[A-Z]?-B\d{2}")
TRAIN_RE = re.compile(r"TRAIN_\d{2}[A-Z]?")


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def run_git_status() -> list[str]:
    result = subprocess.run(["git", "status", "--short"], cwd=ROOT, text=True, capture_output=True, check=False)
    if result.returncode != 0:
        return [f"git status failed: {result.stderr.strip()}"]
    return result.stdout.splitlines()


def parse_manifest() -> tuple[list[dict[str, object]], list[str], dict[str, list[str]]]:
    trains: list[dict[str, object]] = []
    proof_roots: list[str] = []
    dependencies: dict[str, list[str]] = {}
    section = None
    current: dict[str, object] | None = None
    in_batches = False
    for raw in MANIFEST.read_text(encoding="utf-8").splitlines():
        line = raw.rstrip()
        stripped = line.strip()
        if stripped == "dependencies:":
            section = "dependencies"
            continue
        if stripped == "proof_artifact_roots:":
            section = "proof_roots"
            continue
        if stripped == "trains:":
            section = "trains"
            continue
        if section == "dependencies" and line.startswith("  TRAIN_"):
            key, value = stripped.split(":", 1)
            dependencies[key] = TRAIN_RE.findall(value)
        elif section == "proof_roots" and line.startswith("  - "):
            proof_roots.append(stripped.removeprefix("- "))
        elif section == "trains":
            if line.startswith("  - id: "):
                current = {"id": stripped.removeprefix("- id: "), "title": "", "status": "", "batches": []}
                trains.append(current)
                in_batches = False
            elif current is not None and line.startswith("    title: "):
                current["title"] = stripped.removeprefix("title: ")
            elif current is not None and line.startswith("    status: "):
                current["status"] = stripped.removeprefix("status: ")
            elif current is not None and stripped == "batches:":
                in_batches = True
            elif current is not None and in_batches and line.startswith("      - "):
                current["batches"].append(stripped.removeprefix("- "))  # type: ignore[index]
    return trains, proof_roots, dependencies


def prompt_matches(batch_id: str) -> list[Path]:
    return sorted(BATCH_DIR.glob(f"{batch_id}-*.md"))


def in_allowed_claim_context(heading: str) -> bool:
    h = heading.lower()
    return any(token in h for token in ["forbidden", "red", "avoid", "claim"])


def check_claims(path: Path) -> list[str]:
    issues: list[str] = []
    heading = ""
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("##"):
            heading = line
        if in_allowed_claim_context(heading):
            continue
        for claim in FORBIDDEN_CLAIMS:
            if claim in line:
                issues.append(f"{rel(path)}: possible unsupported claim `{claim}` outside claim/forbidden/red section")
    return issues


def check_batch_prompt(path: Path, replacement_required: bool) -> list[str]:
    issues: list[str] = []
    text = path.read_text(encoding="utf-8")
    if text.splitlines()[:3] != HEADER_LINES:
        issues.append(f"{rel(path)}: runner header is missing or not first")
    sections = REQUIRED_REPLACEMENT_SECTIONS if replacement_required else []
    for section in sections:
        if section not in text:
            issues.append(f"{rel(path)}: missing {section}")
    if replacement_required and "Status: Green / Yellow / Red" not in text:
        issues.append(f"{rel(path)}: missing final report status line")
    issues.extend(check_claims(path))
    return issues


def train_prompt_for(train_id: str) -> list[Path]:
    return sorted(TRAIN_DIR.glob(f"{train_id}_*.md"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--batch", help="Optional batch id to validate in isolation.")
    parser.add_argument("--strict-dirty", action="store_true", help="Fail if tracked or untracked worktree changes exist.")
    parser.add_argument("--print-counts", action="store_true", help="Print manifest counts.")
    parser.add_argument("--state-check", action="store_true", help="Validate execution-state reconciliation file shape.")
    parser.add_argument("--replacement-contracts", action="store_true", help="Validate replacement contract installation shape.")
    args = parser.parse_args()

    issues: list[str] = []
    warnings: list[str] = []
    for path in [MANIFEST, RUNBOOK, BATCH_DIR, TRAIN_DIR]:
        if not path.exists():
            issues.append(f"missing required path: {rel(path)}")
    if issues:
        for issue in issues:
            print(f"RED: {issue}")
        return 1

    trains, proof_roots, dependencies = parse_manifest()
    manifest_batches = [batch for train in trains for batch in train["batches"]]  # type: ignore[index]
    if len(set(manifest_batches)) != len(manifest_batches):
        issues.append("manifest contains duplicate IOS26 batch ids")
    for batch in manifest_batches:
        if not BATCH_RE.fullmatch(batch):
            issues.append(f"invalid manifest batch id: {batch}")
    runbook_text = RUNBOOK.read_text(encoding="utf-8")

    selected = [args.batch] if args.batch else manifest_batches
    for batch_id in selected:
        if batch_id not in manifest_batches:
            issues.append(f"{batch_id}: not listed in manifest")
            continue
        matches = prompt_matches(batch_id)
        replacement_required = bool(re.search(r"IOS26-T04[E-K]-", batch_id))
        if len(matches) != 1 and replacement_required:
            issues.append(f"{batch_id}: expected exactly one prompt file, found {len(matches)}")
            continue
        if len(matches) == 0:
            issues.append(f"{batch_id}: expected prompt file, found 0")
            continue
        if len(matches) != 1:
            warnings.append(f"{batch_id}: legacy duplicate prompt files found; using runbook-referenced prompt")
        command_prefix = f"scripts/ambitions-codex-train.sh {batch_id} "
        command_line = next((line for line in runbook_text.splitlines() if line.startswith(command_prefix)), "")
        if not command_line:
            issues.append(f"{batch_id}: runbook missing exact command")
            continue
        prompt_path = ROOT / command_line.removeprefix(command_prefix)
        if prompt_path not in matches:
            issues.append(f"{batch_id}: runbook prompt does not match prompt files")
            continue
        issues.extend(check_batch_prompt(prompt_path, replacement_required=replacement_required))

    for train in trains:
        train_id = str(train["id"])
        matches = train_prompt_for(train_id)
        if len(matches) != 1:
            issues.append(f"{train_id}: expected exactly one train prompt, found {len(matches)}")
        elif matches[0].read_text(encoding="utf-8").splitlines()[:3] != HEADER_LINES:
            issues.append(f"{rel(matches[0])}: train prompt runner header is missing or not first")

    for train in ["TRAIN_04E", "TRAIN_04F", "TRAIN_04G", "TRAIN_04H", "TRAIN_04I", "TRAIN_04J", "TRAIN_04K"]:
        if train not in dependencies:
            issues.append(f"{train}: missing dependency entry")

    if args.state_check:
        if not STATE.exists():
            issues.append(f"missing {rel(STATE)}")
        else:
            state = STATE.read_text(encoding="utf-8")
            for token in ["user_reported_state_is_operational_context_not_proof: true", "manifest_status_is_install_state_not_execution_proof: true", "closeout_artifacts_required_for_green_completion_claims: true", "active_batch: IOS26-T04D-B06"]:
                if token not in state:
                    issues.append(f"{rel(STATE)}: missing `{token}`")

    if args.replacement_contracts:
        for doc in REPLACEMENT_DOCS:
            if not doc.exists():
                issues.append(f"missing {rel(doc)}")
        for root in ["build/reports/core-replacement-contracts/", "build/reports/time-operations/", "build/reports/reminder-operations/", "build/reports/project-step-operations/", "build/reports/life-knowledge-operations/", "build/reports/life-command-search/", "build/reports/private-life-runtime-integration/"]:
            if root not in proof_roots:
                issues.append(f"manifest missing proof root {root}")
        existing = [str(t["id"]) for t in trains]
        for train in [f"TRAIN_04{s}" for s in "EFGHIJK"]:
            if train not in existing:
                issues.append(f"manifest missing {train}")

    if args.strict_dirty:
        dirty = run_git_status()
        if dirty:
            issues.append("worktree is dirty under --strict-dirty")
            issues.extend(f"dirty: {line}" for line in dirty[:30])

    if args.print_counts:
        print(f"trains={len(trains)}")
        print(f"batches={len(manifest_batches)}")
        print(f"proof_roots={len(proof_roots)}")
        print(f"train_prompts={len(list(TRAIN_DIR.glob('TRAIN_*.md')))}")

    for warning in warnings:
        print(f"YELLOW: {warning}")
    if issues:
        for issue in issues:
            print(f"RED: {issue}")
        print(f"SUMMARY: Green=0 Yellow={len(warnings)} Red={len(issues)}")
        return 1

    print("GREEN: IOS26 flagship train preflight passed")
    print(f"SUMMARY: Green=1 Yellow={len(warnings)} Red=0")
    if not args.print_counts:
        print(f"batches={len(manifest_batches)}")
        print(f"train_prompts={len(list(TRAIN_DIR.glob('TRAIN_*.md')))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
