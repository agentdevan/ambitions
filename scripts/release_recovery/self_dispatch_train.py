#!/usr/bin/env python3
"""Controlled self-dispatch controller for Ambitions release recovery.

This script is intentionally deterministic. It runs the existing autopilot engine,
then dispatches the next train cycle only when all blocking gates pass, cycles
remain, and pending batch scripts still exist.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from typing import Iterable
from urllib import error, request

CONTROLLER_VERSION = "2026.06.16.1"
ROOT = Path(__file__).resolve().parents[2]
STATE_PATH = ROOT / "artifacts" / "release-recovery" / "autopilot-state.json"
BATCH_DIR = ROOT / "scripts" / "release_recovery"
BATCH_RE = re.compile(r"^batch_[0-9]{2}_[a-z0-9_]+$")


def discover_batches() -> list[str]:
    batches: list[str] = []
    for script in sorted(BATCH_DIR.glob("apply_batch_*.py")):
        batch = script.stem.removeprefix("apply_")
        if BATCH_RE.fullmatch(batch):
            batches.append(batch)
    return batches


def load_completed_batches() -> set[str]:
    if not STATE_PATH.exists():
        return set()
    try:
        state = json.loads(STATE_PATH.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return set()
    return set(state.get("completed_batches") or [])


def first_pending_batch(start_batch: str) -> str | None:
    batches = discover_batches()
    if not batches:
        return None
    completed = load_completed_batches()
    start_index = 0
    if start_batch != "auto":
        if not BATCH_RE.fullmatch(start_batch):
            raise ValueError(f"Invalid start batch: {start_batch}")
        if start_batch not in batches:
            raise ValueError(f"Unknown start batch: {start_batch}")
        start_index = batches.index(start_batch)
    for batch in batches[start_index:]:
        if batch not in completed:
            return batch
    return None


def run_autopilot(args: argparse.Namespace, start_batch: str) -> int:
    command = [
        sys.executable,
        str(ROOT / "scripts" / "release_recovery" / "autopilot.py"),
        "--start-batch",
        start_batch,
        "--max-batches",
        str(args.max_batches),
        "--gate-mode",
        args.gate_mode,
        "--skip-completed",
    ]
    if args.commit_changes:
        command.append("--commit")
    if args.run_xcode_build:
        command.append("--run-xcode-build")
    if args.run_swift_tests:
        command.append("--run-swift-tests")
    if args.run_launch_smoke:
        command.append("--run-launch-smoke")
    return subprocess.run(command, cwd=ROOT, check=False).returncode


def dispatch_next(args: argparse.Namespace, next_batch: str) -> None:
    repo = os.environ.get("GITHUB_REPOSITORY")
    token = os.environ.get("AMBITIONS_AUTOPILOT_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if not repo:
        raise RuntimeError("GITHUB_REPOSITORY is not set.")
    if not token:
        raise RuntimeError("No dispatch token is available.")

    payload = {
        "ref": args.ref,
        "inputs": {
            "start_batch": next_batch,
            "max_batches": str(args.max_batches),
            "gate_mode": args.gate_mode,
            "commit_changes": "true" if args.commit_changes else "false",
            "run_xcode_build": "true" if args.run_xcode_build else "false",
            "run_swift_tests": "true" if args.run_swift_tests else "false",
            "run_launch_smoke": "true" if args.run_launch_smoke else "false",
            "self_dispatch": "true",
            "cycles_remaining": str(args.cycles_remaining - 1),
        },
    }
    url = f"https://api.github.com/repos/{repo}/actions/workflows/{args.workflow_file}/dispatches"
    req = request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "X-GitHub-Api-Version": "2026-03-10",
        },
        method="POST",
    )
    try:
        with request.urlopen(req, timeout=30) as response:
            print(f"Dispatched next train cycle for {next_batch}: HTTP {response.status}")
    except error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"Dispatch failed: HTTP {exc.code}: {body}") from exc


def parse_bool(value: str) -> bool:
    return value.strip().lower() in {"1", "true", "yes", "on"}


def parse_args(argv: Iterable[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run and optionally self-dispatch Ambitions recovery train cycles.")
    parser.add_argument("--start-batch", default="auto")
    parser.add_argument("--max-batches", type=int, default=8)
    parser.add_argument("--gate-mode", choices=("staged", "strict"), default="staged")
    parser.add_argument("--commit-changes", type=parse_bool, default=True)
    parser.add_argument("--run-xcode-build", type=parse_bool, default=True)
    parser.add_argument("--run-swift-tests", type=parse_bool, default=False)
    parser.add_argument("--run-launch-smoke", type=parse_bool, default=False)
    parser.add_argument("--self-dispatch", type=parse_bool, default=True)
    parser.add_argument("--cycles-remaining", type=int, default=3)
    parser.add_argument("--workflow-file", default="ambitions-autopilot-train.yml")
    parser.add_argument("--ref", default="main")
    return parser.parse_args(list(argv))


def main(argv: Iterable[str] = sys.argv[1:]) -> int:
    args = parse_args(argv)
    if args.max_batches < 1:
        raise ValueError("max_batches must be at least 1.")
    if args.cycles_remaining < 0:
        raise ValueError("cycles_remaining must be non-negative.")

    start_batch = first_pending_batch(args.start_batch)
    if start_batch is None:
        print("No pending recovery batches found.")
        return 0

    print(f"Controller version: {CONTROLLER_VERSION}")
    print(f"Selected start batch: {start_batch}")
    exit_code = run_autopilot(args, start_batch)
    if exit_code != 0:
        print(f"Autopilot stopped with exit code {exit_code}; self-dispatch suppressed.", file=sys.stderr)
        return exit_code

    next_batch = first_pending_batch("auto")
    if next_batch is None:
        print("No pending recovery batches remain.")
        return 0
    if not args.self_dispatch:
        print(f"Pending batch remains but self-dispatch is disabled: {next_batch}")
        return 0
    if args.cycles_remaining <= 0:
        print(f"Pending batch remains but cycle budget is exhausted: {next_batch}")
        return 0

    dispatch_next(args, next_batch)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
