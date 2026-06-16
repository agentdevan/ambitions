#!/usr/bin/env python3
"""Ambitions release recovery autopilot v2.

Deterministic repair-cycle runner for the self-hosted Xcode machine.

Core behavior:
- Discover batch scripts named `apply_batch_*.py`.
- Apply batches in lexical order.
- Run blocking critical gates.
- Run advisory design/copy/card gates in staged mode.
- Generate/resolve the Xcode project before build gates.
- Commit only after blocking gates pass.
- Stop on first Red gate and leave artifacts for review.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from dataclasses import asdict, dataclass
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


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def run_command(name: str, command: list[str], log_path: Path, *, blocking: bool = True, env: dict[str, str] | None = None) -> CommandResult:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)
    with log_path.open("w", encoding="utf-8") as log:
        log.write("$ " + " ".join(command) + "\n\n")
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
    print(f"[{name}] exit={process.returncode} blocking={blocking} log={rel(log_path)}")
    if process.returncode != 0:
        print(process.stdout[-4000:], file=sys.stderr)
    return CommandResult(name=name, command=command, returncode=process.returncode, log_path=rel(log_path), blocking=blocking)


def discover_batches() -> list[str]:
    batches: list[str] = []
    for script in sorted(BATCH_DIR.glob("apply_batch_*.py")):
        batches.append(script.stem.removeprefix("apply_"))
    return batches


def load_state() -> dict:
    if not STATE_PATH.exists():
        return {"version": 2, "completed_batches": [], "last_green_batch": None, "runs": []}
    return json.loads(STATE_PATH.read_text(encoding="utf-8"))


def save_state(state: dict) -> None:
    ARTIFACT_ROOT.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def current_sha() -> str:
    return subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()


def git_diff_exists() -> bool:
    return subprocess.run(["git", "diff", "--quiet"], cwd=ROOT, check=False).returncode != 0


def capture_diff_artifacts(run_dir: Path) -> None:
    run_dir.mkdir(parents=True, exist_ok=True)
    with (run_dir / "batch.patch").open("w", encoding="utf-8") as patch:
        subprocess.run(["git", "diff", "--", "Native", "Sources", "scripts", ".github"], cwd=ROOT, text=True, stdout=patch, check=False)
    with (run_dir / "batch-diff-stat.log").open("w", encoding="utf-8") as stat:
        subprocess.run(["git", "diff", "--stat"], cwd=ROOT, text=True, stdout=stat, check=False)


def ensure_xcode_project(run_dir: Path) -> CommandResult | None:
    if not (ROOT / "project.yml").exists():
        return None
    script = run_dir / "generate-xcode-project.sh"
    script.write_text(
        """#!/usr/bin/env bash
set -euo pipefail
if ! command -v xcodegen >/dev/null 2>&1; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "project.yml exists but xcodegen and brew are unavailable" >&2
    exit 2
  fi
  brew install xcodegen
fi
xcodegen generate
""",
        encoding="utf-8",
    )
    script.chmod(0o755)
    return run_command("xcodegen", ["bash", rel(script)], run_dir / "xcodegen.log", blocking=True)


def xcode_container() -> tuple[str, Path]:
    workspaces = sorted(ROOT.glob("*.xcworkspace"))
    projects = sorted(ROOT.glob("*.xcodeproj"))
    if workspaces:
        return "workspace", workspaces[0]
    if projects:
        return "project", projects[0]
    raise RuntimeError("No .xcworkspace or .xcodeproj found after optional XcodeGen generation.")


def container_args(kind: str, path: Path) -> list[str]:
    if kind == "workspace":
        return ["-workspace", path.name]
    return ["-project", path.name]


def list_schemes(kind: str, path: Path, run_dir: Path) -> list[str]:
    command = ["xcodebuild", *container_args(kind, path), "-list", "-json"]
    result = run_command("xcode_list", command, run_dir / "xcode-list.json", blocking=True)
    if result.returncode != 0:
        raise RuntimeError("Unable to list Xcode schemes.")
    text = (run_dir / "xcode-list.json").read_text(encoding="utf-8")
    match = re.search(r"\{.*\}", text, re.DOTALL)
    if not match:
        raise RuntimeError("xcodebuild -list did not produce JSON.")
    data = json.loads(match.group(0))
    section = data.get("workspace") or data.get("project") or {}
    return list(section.get("schemes") or [])


def resolve_scheme(requested: str, schemes: list[str]) -> str:
    if requested != "auto":
        if requested in schemes:
            return requested
        raise RuntimeError(f"Requested Xcode scheme `{requested}` not found. Available: {', '.join(schemes)}")
    preferred = ["Ambitions", "AmbitionsApp", "Native", "Ambitions-iOS"]
    for scheme in preferred:
        if scheme in schemes:
            return scheme
    for scheme in schemes:
        lowered = scheme.lower()
        if "test" not in lowered and "uitest" not in lowered:
            return scheme
    if schemes:
        return schemes[0]
    raise RuntimeError("No Xcode schemes found.")


def run_xcode_build_gate(run_dir: Path, requested_scheme: str, destination: str) -> list[CommandResult]:
    results: list[CommandResult] = []
    xcodegen_result = ensure_xcode_project(run_dir)
    if xcodegen_result:
        results.append(xcodegen_result)
        if not xcodegen_result.passed:
            return results

    kind, path = xcode_container()
    schemes = list_schemes(kind, path, run_dir)
    scheme = resolve_scheme(requested_scheme, schemes)
    (run_dir / "xcode-selected-scheme.txt").write_text(f"{scheme}\n", encoding="utf-8")

    derived_data = run_dir / "DerivedData"
    build_command = [
        "xcodebuild",
        *container_args(kind, path),
        "-scheme", scheme,
        "-destination", destination,
        "-derivedDataPath", derived_data.as_posix(),
        "-skipPackagePluginValidation",
        "-skipMacroValidation",
        "build",
    ]
    results.append(run_command("xcodebuild", build_command, run_dir / "xcodebuild.log", blocking=True))
    return results


def run_launch_smoke_gate(run_dir: Path, simulator_name: str) -> CommandResult:
    script = run_dir / "launch-smoke.sh"
    script.write_text(
        f"""#!/usr/bin/env bash
set -euo pipefail
DEVICE_NAME={simulator_name!r}
xcrun simctl boot "$DEVICE_NAME" || true
xcrun simctl bootstatus "$DEVICE_NAME" -b
APP_PATH=$(find {str((run_dir / 'DerivedData').as_posix())!r} -name Ambitions.app -type d | head -n 1)
if [[ -z "$APP_PATH" ]]; then
  APP_PATH=$(find {str((run_dir / 'DerivedData').as_posix())!r} -name "*.app" -type d ! -name "*Tests.app" ! -name "*UITests.app" | head -n 1)
fi
if [[ -z "$APP_PATH" ]]; then
  echo "No built app found" >&2
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
    return run_command("launch_smoke", ["bash", rel(script)], run_dir / "launch-smoke.log", blocking=True)


def run_gates(args: argparse.Namespace, run_dir: Path) -> list[CommandResult]:
    strict = args.gate_mode == "strict"
    results = [
        run_command("release_red_guard", ["python3", "scripts/ambitions-release-red-guard.py"], run_dir / "release-red-guard.log", blocking=True),
        run_command("empty_action_lint", ["python3", "scripts/ambitions-empty-action-lint.py"], run_dir / "empty-action-lint.log", blocking=True),
        run_command("copy_contract_lint", ["python3", "scripts/ambitions-copy-contract-lint.py"], run_dir / "copy-contract-lint.log", blocking=strict),
        run_command("first_viewport_card_lint", ["python3", "scripts/ambitions-first-viewport-card-lint.py"], run_dir / "first-viewport-card-lint.log", blocking=strict),
    ]
    if args.run_swift_tests:
        results.append(run_command("swift_test", ["swift", "test"], run_dir / "swift-test.log", blocking=True))
    if args.run_xcode_build:
        results.extend(run_xcode_build_gate(run_dir, args.xcode_scheme, args.xcode_destination))
    if args.run_launch_smoke:
        results.append(run_launch_smoke_gate(run_dir, args.simulator_name))
    return results


def write_latest(batch: str, status: str, commit_sha: str | None, started: str, finished: str, results: list[CommandResult], run_dir: Path) -> None:
    lines = [
        "# Ambitions Release Recovery Autopilot Latest",
        "",
        f"Batch: `{batch}`",
        f"Status: `{status}`",
        f"Started: `{started}`",
        f"Finished: `{finished}`",
        f"Commit: `{commit_sha or 'none'}`",
        "",
        "| Gate | Blocking | Exit | Log |",
        "|---|---:|---:|---|",
    ]
    for result in results:
        lines.append(f"| {result.name} | {str(result.blocking).lower()} | {result.returncode} | `{result.log_path}` |")
    lines.append("")
    lines.append(f"Patch: `{rel(run_dir / 'batch.patch')}`")
    LATEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    LATEST_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")


def commit_green_batch(batch: str) -> str | None:
    if not git_diff_exists():
        print("No diff to commit.")
        return None
    subprocess.run(["git", "config", "user.name", "ambitions-recovery-runner"], cwd=ROOT, check=True)
    subprocess.run(["git", "config", "user.email", "actions@users.noreply.github.com"], cwd=ROOT, check=True)
    add_paths = ["Native", "Sources", "scripts", ".github", STATE_PATH.as_posix(), LATEST_PATH.as_posix()]
    subprocess.run(["git", "add", *add_paths], cwd=ROOT, check=True)
    if subprocess.run(["git", "diff", "--cached", "--quiet"], cwd=ROOT, check=False).returncode == 0:
        print("No staged diff to commit.")
        return None
    subprocess.run(["git", "commit", "-m", f"Apply Ambitions release recovery {batch}"], cwd=ROOT, check=True)
    subprocess.run(["git", "push", "origin", "HEAD:main"], cwd=ROOT, check=True)
    return current_sha()


def select_batches(all_batches: list[str], start_batch: str, max_batches: int, skip_completed: bool, completed: set[str]) -> list[str]:
    if start_batch not in all_batches:
        raise RuntimeError(f"Unknown start batch `{start_batch}`. Available: {', '.join(all_batches)}")
    selected: list[str] = []
    for batch in all_batches[all_batches.index(start_batch):]:
        if skip_completed and batch in completed:
            print(f"Skipping completed batch: {batch}")
            continue
        selected.append(batch)
        if len(selected) >= max_batches:
            break
    return selected


def run_batch(batch: str, args: argparse.Namespace, state: dict) -> BatchResult:
    started = datetime.now(timezone.utc).isoformat()
    run_stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    run_dir = ARTIFACT_ROOT / "runs" / f"{run_stamp}-{batch}"
    run_dir.mkdir(parents=True, exist_ok=True)

    script = BATCH_DIR / f"apply_{batch}.py"
    results: list[CommandResult] = []
    status = "red"
    commit_sha: str | None = None

    try:
        results.append(run_command("apply_batch", ["python3", rel(script)], run_dir / "apply-batch.log", blocking=True))
        capture_diff_artifacts(run_dir)
        results.extend(run_gates(args, run_dir))
        blocking_failures = [result for result in results if result.blocking and not result.passed]
        if blocking_failures:
            raise RuntimeError("Blocking gates failed: " + ", ".join(result.name for result in blocking_failures))
        status = "green"
        completed = set(state.get("completed_batches", []))
        completed.add(batch)
        state["completed_batches"] = sorted(completed)
        state["last_green_batch"] = batch
        save_state(state)
        if args.commit:
            commit_sha = commit_green_batch(batch)
    finally:
        finished = datetime.now(timezone.utc).isoformat()
        write_latest(batch, status, commit_sha, started, finished, results, run_dir)
    result = BatchResult(batch=batch, status=status, commit_sha=commit_sha, started_at=started, finished_at=datetime.now(timezone.utc).isoformat(), results=results)
    state.setdefault("runs", []).append(asdict(result))
    return result


def parse_args(argv: Iterable[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run Ambitions release recovery batches.")
    parser.add_argument("--start-batch", default="batch_01_guard_cleanup")
    parser.add_argument("--max-batches", type=int, default=8)
    parser.add_argument("--gate-mode", choices=("staged", "strict"), default="staged")
    parser.add_argument("--commit", action="store_true")
    parser.add_argument("--skip-completed", action="store_true")
    parser.add_argument("--run-swift-tests", action="store_true")
    parser.add_argument("--run-xcode-build", action="store_true")
    parser.add_argument("--run-launch-smoke", action="store_true")
    parser.add_argument("--xcode-scheme", default="auto")
    parser.add_argument("--xcode-destination", default="platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5")
    parser.add_argument("--simulator-name", default="iPhone 17 Pro")
    return parser.parse_args(list(argv))


def main(argv: Iterable[str] = sys.argv[1:]) -> int:
    args = parse_args(argv)
    state = load_state()
    all_batches = discover_batches()
    completed = set(state.get("completed_batches", []))
    selected = select_batches(all_batches, args.start_batch, args.max_batches, args.skip_completed, completed)
    if not selected:
        print("No batches selected.")
        return 0
    print("Autopilot v2 selected batches: " + ", ".join(selected))
    print(f"gate_mode={args.gate_mode} commit={args.commit} xcode={args.run_xcode_build} scheme={args.xcode_scheme}")

    for batch in selected:
        try:
            result = run_batch(batch, args, state)
        except Exception as exc:
            state["status"] = "red"
            state["failed_batch"] = batch
            state["failure"] = str(exc)
            save_state(state)
            print(f"Autopilot v2 stopped on {batch}: {exc}", file=sys.stderr)
            return 1
        if result.status != "green":
            print(f"Autopilot v2 stopped on {batch}: {result.status}", file=sys.stderr)
            return 1
    state["status"] = "green"
    state["failed_batch"] = None
    state["failure"] = None
    save_state(state)
    print("Autopilot v2 finished selected batches.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
