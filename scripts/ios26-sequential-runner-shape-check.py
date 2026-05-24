#!/usr/bin/env python3
"""Validate the iOS 26 sequential runner shape without external packages."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "scripts/ios26-flagship-run-sequential.sh"
MANIFEST = ROOT / "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml"
REPORT = ROOT / "build/reports/ios26-sequential-runner-shape/shape-check.json"

REQUIRED_DEPENDENCIES = [
    "scripts/ambitions-codex-train.sh",
    "scripts/ios26-flagship-preflight.py",
    "scripts/ios26-flagship-proof-packet-check.py",
    "scripts/ambitions-repo-intelligence-context.py",
    "scripts/ambitions-repo-intelligence-packet-check.py",
    "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml",
]


def manifest_batches() -> list[str]:
    batches: list[str] = []
    for line in MANIFEST.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        match = re.match(r"-\s+(IOS26-[A-Za-z0-9._-]+)\s*$", stripped)
        if match:
            batches.append(match.group(1))
    return batches


def runner_batches(text: str) -> list[dict[str, str]]:
    calls: list[dict[str, str]] = []
    for line in text.splitlines():
        match = re.match(r"^run_batch\s+(IOS26-[A-Za-z0-9._-]+)\s+(prompts/batches/\S+)\s*$", line)
        if match:
            calls.append({"batch_id": match.group(1), "prompt": match.group(2)})
    return calls


def extract_run_batch(text: str) -> str:
    match = re.search(r"run_batch\(\)\s*\{(?P<body>.*?)\n\}", text, flags=re.S)
    return match.group("body") if match else ""


def check_order(body: str, report: list[str]) -> None:
    expected = [
        ("logs RUNNING", 'echo "RUNNING $batch_id $prompt"'),
        ("iOS 26 preflight", 'python3 scripts/ios26-flagship-preflight.py --batch "$batch_id"'),
        ("canonical runner", 'scripts/ambitions-codex-train.sh "$batch_id" "$prompt"'),
        ("proof-packet", 'python3 scripts/ios26-flagship-proof-packet-check.py --batch "$batch_id"'),
    ]
    positions: list[int] = []
    for label, needle in expected:
        index = body.find(needle)
        if index < 0:
            report.append(f"run_batch missing {label}: {needle}")
        positions.append(index)
    if all(index >= 0 for index in positions) and positions != sorted(positions):
        report.append("run_batch preflight -> runner -> proof-packet order changed")


def check_failure_behavior(body: str, report: list[str]) -> None:
    required_fragments = [
        'if [[ "$preflight_status" -ne 0 ]]',
        'echo "NEXT_FAILED_BATCH=$batch_id"',
        'exit "$preflight_status"',
        'if [[ "$runner_status" -ne 0 ]]',
        'exit "$runner_status"',
        'if [[ "$proof_status" -ne 0 ]]',
        'exit "$proof_status"',
    ]
    for fragment in required_fragments:
        if fragment not in body:
            report.append(f"run_batch hard-stop behavior missing: {fragment}")


def check_repo_intelligence_context(text: str, body: str, report: list[str]) -> None:
    required_fragments = [
        'REPO_INTELLIGENCE_CONTEXT="scripts/ambitions-repo-intelligence-context.py"',
        'REPO_INTELLIGENCE_PACKET_CHECK="scripts/ambitions-repo-intelligence-packet-check.py"',
        "repo_intelligence_batch_context()",
        'python3 "$REPO_INTELLIGENCE_CONTEXT" --batch "$batch_id" --prompt "$prompt" --print-path',
        'python3 "$REPO_INTELLIGENCE_PACKET_CHECK" "$packet_json"',
        'AMBITIONS_REPO_INTELLIGENCE_CONTEXT="$context_path"',
        'repo_intelligence_batch_context "$batch_id" "$prompt"',
    ]
    for fragment in required_fragments:
        haystack = body if fragment == 'repo_intelligence_batch_context "$batch_id" "$prompt"' else text
        if fragment not in haystack:
            report.append(f"repo-intelligence context integration missing: {fragment}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true", help=f"write {REPORT.relative_to(ROOT)}")
    args = parser.parse_args()

    errors: list[str] = []
    warnings: list[str] = []

    if not RUNNER.exists():
        errors.append(f"missing runner: {RUNNER.relative_to(ROOT)}")
        text = ""
    else:
        text = RUNNER.read_text(encoding="utf-8")

    if not MANIFEST.exists():
        errors.append(f"missing manifest: {MANIFEST.relative_to(ROOT)}")
        manifest_ids: list[str] = []
    else:
        manifest_ids = manifest_batches()

    if "set -Eeuo pipefail" not in text:
        errors.append("runner does not use set -Eeuo pipefail")
    for dependency in REQUIRED_DEPENDENCIES:
        if dependency not in text:
            errors.append(f"runner dependency check missing {dependency}")

    body = extract_run_batch(text)
    if not body:
        errors.append("run_batch() function not found")
    else:
        check_order(body, errors)
        check_failure_behavior(body, errors)
        check_repo_intelligence_context(text, body, errors)

    calls = runner_batches(text)
    runner_ids = [call["batch_id"] for call in calls]
    duplicates = sorted({batch_id for batch_id in runner_ids if runner_ids.count(batch_id) > 1})
    if duplicates:
        errors.append(f"duplicate runner batch IDs: {', '.join(duplicates)}")
    if runner_ids != manifest_ids:
        missing = [batch_id for batch_id in manifest_ids if batch_id not in runner_ids]
        extra = [batch_id for batch_id in runner_ids if batch_id not in manifest_ids]
        order_mismatch = not missing and not extra
        if missing:
            errors.append(f"runner missing manifest batch IDs: {', '.join(missing)}")
        if extra:
            errors.append(f"runner has non-manifest iOS 26 batch IDs: {', '.join(extra)}")
        if order_mismatch:
            errors.append("runner batch order differs from manifest batch order")

    status = "GREEN" if not errors else "RED"
    payload = {
        "status": status,
        "runner": str(RUNNER.relative_to(ROOT)),
        "manifest": str(MANIFEST.relative_to(ROOT)),
        "manifest_batch_count": len(manifest_ids),
        "runner_batch_count": len(runner_ids),
        "errors": errors,
        "warnings": warnings,
    }

    print(f"{status}: IOS26 sequential runner shape check")
    print(f"manifest batches: {len(manifest_ids)}")
    print(f"runner batches: {len(runner_ids)}")
    for error in errors:
        print(f"RED: {error}")
    for warning in warnings:
        print(f"YELLOW: {warning}")

    if args.json:
        REPORT.parent.mkdir(parents=True, exist_ok=True)
        REPORT.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(f"wrote {REPORT.relative_to(ROOT)}")

    return 0 if status == "GREEN" else 1


if __name__ == "__main__":
    raise SystemExit(main())
