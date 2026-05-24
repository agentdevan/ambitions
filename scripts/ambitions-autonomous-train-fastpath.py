#!/usr/bin/env python3
"""Fast-path autonomous train wrapper for Ambitions.

Designed for the Install / Review / Advance Train / Push repeat loop.
It routes to the next batch, applies HBI/MRI guardrails, and delegates actual
execution to the existing Ambitions runner via make targets.

This script is an orchestration accelerator only. It does not prove build,
release, device, accessibility, privacy, or commercial readiness.
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
ROUTER = ROOT / "scripts/ambitions-next-batch-resolver.py"
HBI_GUARD = ROOT / "scripts/ambitions-historical-baseline-train-guard.py"
MRI_ROUTER = ROOT / "scripts/ambitions-mri-autonomous-router.py"
MRI_MATERIALIZER = ROOT / "scripts/ambitions-mri-materialize-prompts.py"
RED_ROUTER = ROOT / "scripts/ambitions-red-repair-router.py"
OWNED_DETECTOR = ROOT / "scripts/ambitions-owned-files-detector.py"
CLOSEOUT = ROOT / "scripts/ambitions-batch-closeout-accelerator.py"
XCODE_BENCHMARK = ROOT / "scripts/ambitions-xcode-benchmark.sh"


def run(cmd: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def route() -> dict[str, Any]:
    proc = run([sys.executable, str(ROUTER), "--json", "--prefer-hbi"], capture=True)
    if proc.returncode != 0:
        print(proc.stdout or "", end="")
        print(proc.stderr or "", end="", file=sys.stderr)
        raise SystemExit(proc.returncode)
    return json.loads(proc.stdout)


def print_route() -> int:
    print(json.dumps(route(), indent=2, sort_keys=True))
    return 0


def status() -> int:
    result = {
        "fastpath": "installed",
        "router_exists": ROUTER.exists(),
        "hbi_guard_exists": HBI_GUARD.exists(),
        "mri_router_exists": MRI_ROUTER.exists(),
        "owned_files_detector_exists": OWNED_DETECTOR.exists(),
        "closeout_accelerator_exists": CLOSEOUT.exists(),
        "red_repair_router_exists": RED_ROUTER.exists(),
        "xcode_benchmark_exists": XCODE_BENCHMARK.exists(),
        "next_route": route(),
        "claim_boundary": "status only; no implementation/readiness proof",
    }
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


def guard_preflight() -> int:
    if HBI_GUARD.exists():
        proc = run([sys.executable, str(HBI_GUARD)])
        if proc.returncode != 0:
            return proc.returncode
    # MRI helpers are advisory here; the conductor decides if an MRI conflict is Hard Red.
    if (ROOT / "Makefile.mri").exists():
        run(["make", "-f", "Makefile.mri", "help"])
    if MRI_ROUTER.exists():
        run([sys.executable, str(MRI_ROUTER), "--help"])
    if MRI_MATERIALIZER.exists():
        run([sys.executable, str(MRI_MATERIALIZER), "--help"])
    if XCODE_BENCHMARK.exists():
        proc = run([str(XCODE_BENCHMARK), "--status"])
        if proc.returncode != 0:
            return proc.returncode
    return 0


def classify_failure(text: str) -> int:
    if not RED_ROUTER.exists():
        print("red repair router missing; cannot classify failure", file=sys.stderr)
        return 1
    proc = subprocess.run(
        [sys.executable, str(RED_ROUTER), "--json"],
        cwd=ROOT,
        input=text,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    print(proc.stdout or "", end="")
    print(proc.stderr or "", end="", file=sys.stderr)
    return proc.returncode


def maybe_print_staging(batch_id: str) -> None:
    if OWNED_DETECTOR.exists():
        run([sys.executable, str(OWNED_DETECTOR), "--batch", batch_id, "--print-git-add"])


def maybe_create_closeout(batch_id: str, route_info: dict[str, Any], status_value: str) -> None:
    if CLOSEOUT.exists():
        run([
            sys.executable,
            str(CLOSEOUT),
            "--batch",
            batch_id,
            "--status",
            status_value,
            "--hbi",
            str(route_info.get("hbi_applicability", "unknown")),
            "--mri",
            str(route_info.get("mri_applicability", "unknown")),
        ])


def execute_once(*, dry_run: bool, push: bool) -> int:
    route_info = route()
    batch_id = route_info.get("next_batch_id")
    prompt = route_info.get("prompt")
    if not batch_id or not prompt:
        print(json.dumps(route_info, indent=2, sort_keys=True))
        return 1

    guard_code = guard_preflight()
    if guard_code != 0:
        print(f"HBI guard/preflight failed with exit code {guard_code}", file=sys.stderr)
        return guard_code

    target = "batch-push" if push else "batch"
    command = ["make", target, f"BATCH={batch_id}", f"PROMPT={prompt}"]
    print(" ".join(command))
    if dry_run:
        return 0

    proc = run(command, capture=True)
    if proc.stdout:
        print(proc.stdout, end="")
    if proc.stderr:
        print(proc.stderr, end="", file=sys.stderr)

    if proc.returncode == 0:
        maybe_create_closeout(batch_id, route_info, "Green or Accepted Yellow - verify runner report")
        maybe_print_staging(batch_id)
        return 0

    maybe_create_closeout(batch_id, route_info, "Red - generated after failed run")
    return classify_failure((proc.stdout or "") + "\n" + (proc.stderr or "")) or proc.returncode


def execute_until_complete(*, dry_run: bool, push: bool, max_batches: int) -> int:
    executed = 0
    while executed < max_batches:
        code = execute_once(dry_run=dry_run, push=push)
        if code != 0:
            return code
        executed += 1
        if dry_run:
            break
    print(f"fastpath loop completed {executed} iteration(s)")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Run the Ambitions autonomous train fastpath.")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--status", action="store_true")
    mode.add_argument("--next", action="store_true")
    mode.add_argument("--run-current", action="store_true")
    mode.add_argument("--once", action="store_true")
    mode.add_argument("--until-complete", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--no-push", action="store_true", help="Use make batch instead of make batch-push")
    parser.add_argument("--max-batches", type=int, default=999)
    args = parser.parse_args()

    if args.status:
        return status()
    if args.next:
        return print_route()
    push = not args.no_push
    if args.run_current or args.once:
        return execute_once(dry_run=args.dry_run, push=push)
    if args.until_complete:
        return execute_until_complete(dry_run=args.dry_run, push=push, max_batches=args.max_batches)
    return status()


if __name__ == "__main__":
    raise SystemExit(main())
