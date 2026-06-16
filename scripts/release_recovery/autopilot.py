#!/usr/bin/env python3
"""Ambitions release recovery autopilot.

Runs inside the self-hosted GitHub Actions runner. It discovers deterministic
recovery batch scripts, applies them in order, runs staged gates, commits after
blocking validation passes, and stops on the first real Red gate.

This is not an open-ended AI loop. It is a deterministic, repo-native repair
cycle that creates proof artifacts for human/model review.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from typing import Iterable

ROOT = Path(__file__).resolve().parents[2]
BATCH_DIR = ROOT / "scripts" / "release_recovery"
ARTIFACT_ROOT = ROOT / "artifacts" / "release-recovery"
STATE_PATH = ARTIFACT_ROOT / "autopilot-state.json"
LATEST_PATH = ARTIFACT_ROOT / "autopilot-latest.md"


@dataclass(frozen=True)
class CommandResult:
    name: str
    command: list[str]
    returncode: int
    log_path: str
    blocking: bool

    @property
    def passed(self) -> bool:
        return self.returncode == 0


@dataclass(frozen=True)
class BatchResult:
    batch: str
    status: str
    commit_sha: str | None
    started_at: str
    finished_at: str
    results: list[CommandResult]


def run_command(
    name: str,
    command: list[str],
    log_path: Path,
    blocking: bool = True,
    env: dict[str, str] | None = None,
) -> CommandResult:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)

    with log_path.open("w", encoding="utf-8") as log:
        log.write(f"$ {' '.join(command)}\n\n")
        log.flush()
        process = subprocess.run(
            command,
            cwd=ROOT,
            env=merged_env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )
        log.write(process.stdout)

    print(f"[{name}] exit={process.returncode} blocking={blocking} log={log_path.relative_to(ROOT)}")
    if process.returncode != 0 and blocking:
        print(process.stdout[-4000:], file=sys.stderr)
    return CommandResult(
        name=name,
        command=command,
        returncode=process.returncode,
        log_path=log_path.relative_to(ROOT).as_posix(),
        blocking=blocking,
    )


def discover_batches() -> list[str]:
    batches: list[str] = []
    for script in sorted(BATCH_DIR.glob("apply_batch_*.py")):
        stem = script.stem
        if stem.startswith("apply_"):
            batches.append(stem.removeprefix("apply_"))
    return batches


def load_state() -> dict:
    if not STATE_PATH.exists():
        return {
            "version": 1,
            "last_green_batch": None,
            "completed_batches": [],
            "runs": [],
        }
    return json.loads(STATE_PATH.read_text(encoding="utf-8"))


def save_state(state: dict) -> None:
    ARTIFACT_ROOT.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def batch_script(batch: str) -> Path:
    return BATCH_DIR / f"apply_{batch}.py"


def select_batches(all_batches: list[str], start_batch: str, max_batches: int, skip_completed: set[str]) -> list[str]:
    if start_batch not in all_batches:
        raise RuntimeError(f"Unknown start batch `{start_batch}`. Available: {', '.join(all_batches)}")
    start_index = all_batches.index(start_batch)
    selected: list[str] = []
    for batch in all_batches[start_index:]:
        if batch in skip_completed:
            print(f"Skipping completed batch: {batch}")
            continue
        selected.append(batch)
        if len(selected) >= max_batches:
            break
    return selected


def git_diff_exists() -> bool:
    return subprocess.run(["git", "diff", "--quiet"], cwd=ROOT, check=False).returncode != 0


def current_sha() -> str:
    result = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True, stdout=subprocess.PIPE, check=True)
    return result.stdout.strip()


def commit_changes(batch: str) -> str | None:
    if not git_diff_exists():
        print("No diff to commit.")
        return None

    subprocess.run(["git", "config", "user.name", "ambitions-recovery-runner"], cwd=ROOT, check=True)
    subprocess.run(["git", "config", "user.email", "actions@users.noreply.github.com"], cwd=ROOT, check=True)
    subprocess.run(["git", "add", "Native", "Sources", "scripts", ".github"], cwd=ROOT, check=True)
    if STATE_PATH.exists():
        subprocess.run(["git", "add", STATE_PATH.as_posix()], cwd=ROOT, check=True)
    if LATEST_PATH.exists():
        subprocess.run(["git", "add", LATEST_PATH.as_posix()], cwd=ROOT, check=True)

    if subprocess.run(["git", "diff", "--cached", "--quiet"], cwd=ROOT, check=False).returncode == 0:
        print("No staged diff to commit.")
        return None

    subprocess.run(["git", "commit", "-m", f"Apply Ambitions release recovery {batch}"], cwd=ROOT, check=True)
    subprocess.run(["git", "push", "origin", "HEAD:main"], cwd=ROOT, check=True)
    return current_sha()


def write_latest_summary(batch_result: BatchResult, run_dir: Path) -> None:
    lines = [
        "# Ambitions Release Recovery Autopilot Latest",
        "",
        f"Batch: `{batch_result.batch}`",
        f"Status: `{batch_result.status}`",
        f"Started: `{batch_result.started_at}`",
        f"Finished: `{batch_result.finished_at}`",
        f"Commit: `{batch_result.commit_sha or 'none'}`",
        "",
        "## Gates",
        "",
        "| Gate | Blocking | Exit | Log |",
        "|---|---:|---:|---|",
    ]
    for result in batch_result.results:
        lines.append(f"| {result.name} | {str(result.blocking).lower()} | {result.returncode} | `{result.log_path}` |")
    lines.extend([
        "",
        f"Patch artifact: `{(run_dir / 'batch.patch').relative_to(ROOT).as_posix()}`",
        "",
    ])
    ARTIFACT_ROOT.mkdir(parents=True, exist_ok=True)
    LATEST_PATH.write_text("\n".join(lines), encoding="utf-8")


def capture_diff_artifacts(run_dir: Path) -> None:
    run_dir.mkdir(parents=True, exist_ok=True)
    with (run_dir / "batch.patch").open("w", encoding="utf-8") as patch:
        subprocess.run(["git", "diff", "--", "Native", "Sources", "scripts", ".github"], cwd=ROOT, text=True, stdout=patch, check=False)
    with (run_dir / "batch-diff-stat.log").open("w", encoding="utf-8") as stat:
        subprocess.run(["git", "diff", "--stat"], cwd=ROOT, text=True, stdout=stat, check=False)


def find_built_app(derived_data: Path) -> Path | None:
    candidates = sorted(derived_data.rglob("Ambitions.app"), key=lambda p: len(p.as_posix()))
    return candidates[0] if candidates else None


def run_launch_smoke(run_dir: Path, destination_name: str, derived_data: Path) -> CommandResult:
    script = run_dir / "launch-smoke.sh"
    script.write_text(
        f"""#!/usr/bin/env bash
set -euo pipefail
DEVICE_NAME={destination_name!r}
xcrun simctl boot "$DEVICE_NAME" || true
xcrun simctl bootstatus "$DEVICE_NAME" -b
APP_PATH=$(find {derived_data.as_posix()!r} -name Ambitions.app -type d | head -n 1)
if [[ -z "$APP_PATH" ]]; then
  echo "Ambitions.app not found in derived data" >&2
  exit 2
fi
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$APP_PATH/Info.plist")
xcrun simctl install "$DEVICE_NAME" "$APP_PATH"
xcrun simctl launch "$DEVICE_NAME" "$BUNDLE_ID"
sleep 4
mkdir -p {str((run_dir / 'screenshots').as_posix())!r}
xcrun simctl io "$DEVICE_NAME" screenshot {str((run_dir / 'screenshots' / 'launch.png').as_posix())!r}
""",
        encoding="utf-8",
    )
    script.chmod(0o755)
    return run_command("launch_smoke", ["bash", script.as_posix()], run_dir / "launch-smoke.log", blocking=True)


def run_gates(
    batch: str,
    run_dir: Path,
    gate_mode: str,
    run_swift_tests: bool,
    run_xcode_build: bool,
    run_launch_smoke_gate: bool,
    xcode_scheme: str,
    xcode_destination: str,
    simulator_name: str,
) -> list[CommandResult]:
    results: list[CommandResult] = []
    strict = gate_mode == "strict"
    derived_data = run_dir / "DerivedData"

    results.append(run_command("release_red_guard", ["python3", "scripts/ambitions-release-red-guard.py"], run_dir / "release-red-guard.log", blocking=True))
    results.append(run_command("empty_action_lint", ["python3", "scripts/ambitions-empty-action-lint.py"], run_dir / "empty-action-lint.log", blocking=True))
    results.append(run_command("copy_contract_lint", ["python3", "scripts/ambitions-copy-contract-lint.py"], run_dir / "copy-contract-lint.log", blocking=strict))
    results.append(run_command("first_viewport_card_lint", ["python3", "scripts/ambitions-first-viewport-card-lint.py"], run_dir / "first-viewport-card-lint.log", blocking=strict))

    if run_swift_tests:
        results.append(run_command("swift_test", ["swift", "test"], run_dir / "swift-test.log", blocking=True))

    if run_xcode_build:
        results.append(run_command(
            "xcodebuild",
            [
                "xcodebuild",
                "-scheme", xcode_scheme,
                "-destination", xcode_destination,
                "-derivedDataPath", derived_data.as_posix(),
                "build",
            ],
            run_dir / "xcodebuild.log",
            blocking=True,
        ))

    if run_launch_smoke_gate:
        results.append(run_launch_smoke(run_dir, simulator_name, derived_data))

    failed_blocking = [result for result in results if result.blocking and not result.passed]
    if failed_blocking:
        names = ", ".join(result.name for result in failed_blocking)
        raise RuntimeError(f"Blocking gates failed for {batch}: {names}")

    return results


def run_batch(
    batch: str,
    args: argparse.Namespace,
    state: dict,
) -> BatchResult:
    started = datetime.now(timezone.utc).isoformat()
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    run_dir = ARTIFACT_ROOT / "runs" / f"{timestamp}-{batch}"
    run_dir.mkdir(parents=True, exist_ok=True)

    script = batch_script(batch)
    if not script.exists():
        raise RuntimeError(f"Batch script missing: {script.relative_to(ROOT)}")

    results: list[CommandResult] = []
    commit_sha: str | None = None
    status = "red"

    try:
        results.append(run_command("apply_batch", ["python3", script.relative_to(ROOT).as_posix()], run_dir / "apply-batch.log", blocking=True))
        capture_diff_artifacts(run_dir)
        results.extend(run_gates(
            batch=batch,
            run_dir=run_dir,
            gate_mode=args.gate_mode,
            run_swift_tests=args.run_swift_tests,
            run_xcode_build=args.run_xcode_build,
            run_launch_smoke_gate=args.run_launch_smoke,
            xcode_scheme=args.xcode_scheme,
            xcode_destination=args.xcode_destination,
            simulator_name=args.simulator_name,
        ))
        status = "green"
    finally:
        finished = datetime.now(timezone.utc).isoformat()
        batch_result = BatchResult(
            batch=batch,
            status=status,
            commit_sha=None,
            started_at=started,
            finished_at=finished,
            results=results,
        )
        write_latest_summary(batch_result, run_dir)

    if status == "green":
        completed = set(state.get("completed_batches", []))
        completed.add(batch)
        state["completed_batches"] = sorted(completed)
        state["last_green_batch"] = batch
        state.setdefault("runs", []).append(asdict(batch_result))
        save_state(state)
        write_latest_summary(batch_result, run_dir)
        if args.commit:
            commit_sha = commit_changes(batch)

    finished = datetime.now(timezone.utc).isoformat()
    final_result = BatchResult(
        batch=batch,
        status=status,
        commit_sha=commit_sha,
        started_at=started,
        finished_at=finished,
        results=results,
    )
    write_latest_summary(final_result, run_dir)
    return final_result


def parse_args(argv: Iterable[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run Ambitions release recovery batches with gated validation.")
    parser.add_argument("--start-batch", default="batch_01_guard_cleanup")
    parser.add_argument("--max-batches", type=int, default=8)
    parser.add_argument("--gate-mode", choices=("staged", "strict"), default="staged")
    parser.add_argument("--commit", action="store_true")
    parser.add_argument("--skip-completed", action="store_true")
    parser.add_argument("--run-swift-tests", action="store_true")
    parser.add_argument("--run-xcode-build", action="store_true")
    parser.add_argument("--run-launch-smoke", action="store_true")
    parser.add_argument("--xcode-scheme", default="Ambitions")
    parser.add_argument("--xcode-destination", default="platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5")
    parser.add_argument("--simulator-name", default="iPhone 17 Pro")
    return parser.parse_args(list(argv))


def main(argv: Iterable[str] = sys.argv[1:]) -> int:
    args = parse_args(argv)
    ARTIFACT_ROOT.mkdir(parents=True, exist_ok=True)
    state = load_state()
    all_batches = discover_batches()
    if not all_batches:
        raise RuntimeError("No recovery batches found.")

    completed = set(state.get("completed_batches", [])) if args.skip_completed else set()
    selected = select_batches(all_batches, args.start_batch, args.max_batches, completed)
    if not selected:
        print("No batches selected.")
        return 0

    print(f"Autopilot selected batches: {', '.join(selected)}")
    print(f"Gate mode: {args.gate_mode}; commit={args.commit}; swift={args.run_swift_tests}; xcode={args.run_xcode_build}; launch={args.run_launch_smoke}")

    for batch in selected:
        try:
            result = run_batch(batch, args, state)
        except Exception as exc:
            state["status"] = "red"
            state["failed_batch"] = batch
            state["failure"] = str(exc)
            save_state(state)
            print(f"Autopilot stopped on {batch}: {exc}", file=sys.stderr)
            return 1
        if result.status != "green":
            print(f"Autopilot stopped on {batch}: {result.status}", file=sys.stderr)
            return 1

    state["status"] = "green"
    state["failed_batch"] = None
    state["failure"] = None
    save_state(state)
    print("Autopilot finished selected batches.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
