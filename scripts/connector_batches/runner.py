#!/usr/bin/env python3
"""Run deterministic connector-authored source batches.

This runner intentionally does not invoke any code-generation agent. It applies
repo-owned patch/script batches, validates path boundaries, optionally builds on
the self-hosted Mac runner, and commits/pushes only after gates pass.
"""
from __future__ import annotations

import argparse
import json
import os
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
import subprocess
import sys
from typing import Iterable, Literal

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_DIR = ROOT / "scripts" / "connector_batches" / "manifests"
ARTIFACT_ROOT = ROOT / "artifacts" / "connector-batches"
STATE_PATH = ARTIFACT_ROOT / "state.json"
LATEST_PATH = ARTIFACT_ROOT / "latest.md"

Status = Literal["green", "yellow", "red"]


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
    title: str
    status: Status
    commit_sha: str | None
    started_at: str
    finished_at: str
    changed_files: list[str]
    results: list[CommandResult]


def now_utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def normalize(path: str) -> str:
    return path.replace("\\", "/")


def run_command(
    name: str,
    command: list[str],
    log_path: Path,
    *,
    blocking: bool = True,
    env: dict[str, str] | None = None,
) -> CommandResult:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)
    process = subprocess.run(
        command,
        cwd=ROOT,
        env=merged_env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    log_path.write_text("$ " + " ".join(command) + "\n\n" + process.stdout, encoding="utf-8")
    print(f"[{name}] exit={process.returncode} blocking={blocking} log={rel(log_path)}")
    if process.returncode != 0:
        print(process.stdout[-4000:], file=sys.stderr)
    return CommandResult(name=name, command=command, returncode=process.returncode, log_path=rel(log_path), blocking=blocking)


def git(args: list[str], *, check: bool = True) -> str:
    process = subprocess.run(["git", *args], cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False)
    if check and process.returncode != 0:
        raise RuntimeError(process.stdout)
    return process.stdout.strip()


def current_sha() -> str:
    return git(["rev-parse", "HEAD"])


def ensure_clean_worktree() -> None:
    status = git(["status", "--porcelain"])
    if status:
        raise RuntimeError("Dirty worktree before connector batch:\n" + status)


def changed_files_since(start_sha: str) -> list[str]:
    tracked = git(["diff", "--name-only", start_sha], check=False).splitlines()
    untracked = git(["ls-files", "--others", "--exclude-standard"], check=False).splitlines()
    return sorted({normalize(path.strip()) for path in tracked + untracked if path.strip()})


def source_or_test_changed(files: Iterable[str]) -> bool:
    prefixes = (
        "Native/Ambitions/",
        "Native/AmbitionsTests/",
        "Native/AmbitionsUITests/",
        "Sources/",
        "AppUI/",
    )
    return any(normalize(path).startswith(prefixes) for path in files)


def path_allowed(path: str, allowed_paths: Iterable[str]) -> bool:
    normalized = normalize(path)
    for raw_prefix in allowed_paths:
        prefix = normalize(str(raw_prefix))
        if prefix.endswith("/") and normalized.startswith(prefix):
            return True
        if normalized == prefix:
            return True
    if normalized.startswith("artifacts/connector-batches/"):
        return True
    return False


def load_json(path: Path) -> dict:
    if not path.exists():
        raise RuntimeError(f"Missing JSON file: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def load_state() -> dict:
    if not STATE_PATH.exists():
        return {"version": 1, "completed_batches": [], "runs": []}
    return json.loads(STATE_PATH.read_text(encoding="utf-8"))


def save_state(state: dict) -> None:
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def manifest_path_for(batch_id: str) -> Path:
    return MANIFEST_DIR / f"{batch_id}.json"


def discover_batch_ids() -> list[str]:
    if not MANIFEST_DIR.exists():
        return []
    return sorted(path.stem for path in MANIFEST_DIR.glob("*.json"))


def select_batches(start_batch: str, max_batches: int, skip_completed: bool, completed: set[str]) -> list[str]:
    batch_ids = discover_batch_ids()
    if not batch_ids:
        raise RuntimeError(f"No connector batch manifests found under {rel(MANIFEST_DIR)}")
    if start_batch == "auto":
        selected = [batch for batch in batch_ids if not skip_completed or batch not in completed]
        return selected[:max_batches]
    if start_batch not in batch_ids:
        raise RuntimeError(f"Unknown connector batch `{start_batch}`. Available: {', '.join(batch_ids)}")
    selected: list[str] = []
    for batch in batch_ids[batch_ids.index(start_batch):]:
        if skip_completed and batch in completed:
            print(f"Skipping completed connector batch: {batch}")
            continue
        selected.append(batch)
        if len(selected) >= max_batches:
            break
    return selected


def apply_patch(manifest: dict, run_dir: Path) -> CommandResult:
    patch_path = ROOT / str(manifest["patch"])
    if not patch_path.exists():
        raise RuntimeError(f"Patch file missing: {rel(patch_path)}")
    return run_command("apply_patch", ["git", "apply", "--whitespace=fix", rel(patch_path)], run_dir / "apply-patch.log", blocking=True)


def apply_script(manifest: dict, run_dir: Path) -> CommandResult:
    script_path = ROOT / str(manifest["script"])
    if not script_path.exists():
        raise RuntimeError(f"Apply script missing: {rel(script_path)}")
    return run_command("apply_script", ["python3", rel(script_path)], run_dir / "apply-script.log", blocking=True)


def apply_batch(manifest: dict, run_dir: Path) -> CommandResult:
    mode = str(manifest.get("mode", "patch"))
    if mode == "patch":
        return apply_patch(manifest, run_dir)
    if mode == "script":
        return apply_script(manifest, run_dir)
    raise RuntimeError(f"Unsupported connector batch mode `{mode}`")


def run_standard_gates(args: argparse.Namespace, run_dir: Path) -> list[CommandResult]:
    results = [
        run_command("diff_check", ["git", "diff", "--check"], run_dir / "diff-check.log", blocking=True),
        run_command("authority_drift", ["python3", "scripts/ambitions_validate_authority_drift.py"], run_dir / "authority-drift.log", blocking=True),
        run_command("local_first_boundary", ["python3", "scripts/ambitions-local-first-boundary-scan.py"], run_dir / "local-first-boundary.log", blocking=True),
        run_command("root_ia_validator", ["python3", "scripts/codex/amb-master-canon-ia-validate.py"], run_dir / "root-ia-validator.log", blocking=True),
    ]
    if args.run_xcode_build:
        results.extend(run_xcode_build(run_dir))
    if args.run_swift_tests:
        results.append(run_command("swift_test", ["swift", "test"], run_dir / "swift-test.log", blocking=True))
    return results


def run_xcode_build(run_dir: Path) -> list[CommandResult]:
    results: list[CommandResult] = []
    if (ROOT / "project.yml").exists():
        results.append(run_command("xcodegen", ["xcodegen", "generate"], run_dir / "xcodegen.log", blocking=True))
        if not results[-1].passed:
            return results
    results.append(
        run_command(
            "resolve_packages",
            ["xcodebuild", "-project", "Ambitions.xcodeproj", "-scheme", "Ambitions", "-resolvePackageDependencies"],
            run_dir / "resolve-packages.log",
            blocking=True,
        )
    )
    if not results[-1].passed:
        return results
    results.append(
        run_command(
            "xcodebuild",
            [
                "xcodebuild",
                "-project",
                "Ambitions.xcodeproj",
                "-scheme",
                "Ambitions",
                "-destination",
                "generic/platform=iOS Simulator",
                "CODE_SIGNING_ALLOWED=NO",
                "build",
            ],
            run_dir / "xcodebuild.log",
            blocking=True,
        )
    )
    return results


def write_diff_artifacts(run_dir: Path, start_sha: str) -> None:
    run_dir.mkdir(parents=True, exist_ok=True)
    (run_dir / "changed-files.json").write_text(json.dumps(changed_files_since(start_sha), indent=2) + "\n", encoding="utf-8")
    with (run_dir / "batch.patch").open("w", encoding="utf-8") as handle:
        subprocess.run(["git", "diff", start_sha], cwd=ROOT, text=True, stdout=handle, check=False)
    with (run_dir / "batch-diff-stat.log").open("w", encoding="utf-8") as handle:
        subprocess.run(["git", "diff", "--stat", start_sha], cwd=ROOT, text=True, stdout=handle, check=False)


def gate_allowed_paths(manifest: dict, files: list[str], run_dir: Path) -> CommandResult:
    allowed = list(manifest.get("allowed_paths") or [])
    offenders = [path for path in files if not path_allowed(path, allowed)]
    report = run_dir / "allowed-paths.json"
    report.write_text(json.dumps({"allowed_paths": allowed, "changed_files": files, "offenders": offenders}, indent=2) + "\n", encoding="utf-8")
    status = 0 if not offenders else 1
    return CommandResult(
        name="allowed_paths",
        command=["connector-internal", "allowed-paths"],
        returncode=status,
        log_path=rel(report),
        blocking=True,
    )


def gate_source_required(manifest: dict, files: list[str], run_dir: Path) -> CommandResult:
    required = bool(manifest.get("source_required", True))
    passed = True if not required else source_or_test_changed(files)
    report = run_dir / "source-required.json"
    report.write_text(
        json.dumps({"source_required": required, "passed": passed, "changed_files": files}, indent=2) + "\n",
        encoding="utf-8",
    )
    return CommandResult(
        name="source_required",
        command=["connector-internal", "source-required"],
        returncode=0 if passed else 1,
        log_path=rel(report),
        blocking=True,
    )


def write_latest(result: BatchResult, run_dir: Path) -> None:
    lines = [
        "# Ambitions Connector Batch Latest",
        "",
        f"Batch: `{result.batch}`",
        f"Title: `{result.title}`",
        f"Status: `{result.status}`",
        f"Commit: `{result.commit_sha or 'none'}`",
        f"Started: `{result.started_at}`",
        f"Finished: `{result.finished_at}`",
        "",
        "## Changed files",
        "",
    ]
    if result.changed_files:
        lines.extend(f"- `{path}`" for path in result.changed_files)
    else:
        lines.append("- none")
    lines.extend(["", "## Gates", "", "| Gate | Blocking | Exit | Log |", "|---|---:|---:|---|"])
    for item in result.results:
        lines.append(f"| {item.name} | {str(item.blocking).lower()} | {item.returncode} | `{item.log_path}` |")
    lines.append("")
    lines.append(f"Patch: `{rel(run_dir / 'batch.patch')}`")
    LATEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    LATEST_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")


def commit_green_batch(batch_id: str, changed_files: list[str]) -> str | None:
    if not changed_files:
        print("No changed files to commit.")
        return None
    subprocess.run(["git", "config", "user.name", "ambitions-connector-batch"], cwd=ROOT, check=True)
    subprocess.run(["git", "config", "user.email", "actions@users.noreply.github.com"], cwd=ROOT, check=True)
    add_paths = sorted(set(changed_files + [rel(STATE_PATH), rel(LATEST_PATH)]))
    subprocess.run(["git", "add", *add_paths], cwd=ROOT, check=True)
    if subprocess.run(["git", "diff", "--cached", "--quiet"], cwd=ROOT, check=False).returncode == 0:
        print("No staged diff to commit.")
        return None
    subprocess.run(["git", "commit", "-m", f"{batch_id}: apply connector batch"], cwd=ROOT, check=True)
    first_push = subprocess.run(["git", "push", "origin", "HEAD:main"], cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False)
    if first_push.returncode == 0:
        print(first_push.stdout)
        return current_sha()
    print(first_push.stdout, file=sys.stderr)
    subprocess.run(["git", "fetch", "origin", "main"], cwd=ROOT, check=True)
    rebase = subprocess.run(["git", "rebase", "origin/main"], cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False)
    if rebase.returncode != 0:
        print(rebase.stdout, file=sys.stderr)
        subprocess.run(["git", "rebase", "--abort"], cwd=ROOT, check=False)
        raise RuntimeError("Could not rebase connector batch before push")
    subprocess.run(["git", "push", "origin", "HEAD:main"], cwd=ROOT, check=True)
    return current_sha()


def run_one_batch(batch_id: str, args: argparse.Namespace, state: dict) -> BatchResult:
    manifest = load_json(manifest_path_for(batch_id))
    title = str(manifest.get("title", batch_id))
    started = now_utc()
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    run_dir = ARTIFACT_ROOT / "runs" / f"{stamp}-{batch_id}"
    run_dir.mkdir(parents=True, exist_ok=True)
    start_sha = current_sha()
    results: list[CommandResult] = []
    status: Status = "red"
    commit_sha: str | None = None

    try:
        results.append(apply_batch(manifest, run_dir))
        files = changed_files_since(start_sha)
        write_diff_artifacts(run_dir, start_sha)
        results.append(gate_allowed_paths(manifest, files, run_dir))
        results.append(gate_source_required(manifest, files, run_dir))
        results.extend(run_standard_gates(args, run_dir))
        blocking_failures = [item for item in results if item.blocking and not item.passed]
        if blocking_failures:
            raise RuntimeError("Blocking connector gates failed: " + ", ".join(item.name for item in blocking_failures))
        status = "green"
        completed = set(state.get("completed_batches", []))
        completed.add(batch_id)
        state["completed_batches"] = sorted(completed)
        state["last_green_batch"] = batch_id
        state["updated_at"] = now_utc()
        save_state(state)
        files = changed_files_since(start_sha)
        if args.commit:
            commit_sha = commit_green_batch(batch_id, files)
    finally:
        finished = now_utc()
        final_files = changed_files_since(start_sha)
        result = BatchResult(
            batch=batch_id,
            title=title,
            status=status,
            commit_sha=commit_sha,
            started_at=started,
            finished_at=finished,
            changed_files=final_files,
            results=results,
        )
        write_latest(result, run_dir)
        state.setdefault("runs", []).append(asdict(result))
        save_state(state)
    return result


def parse_args(argv: Iterable[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run deterministic connector-authored source batches.")
    parser.add_argument("--batch", default="auto")
    parser.add_argument("--max-batches", type=int, default=1)
    parser.add_argument("--commit", action="store_true")
    parser.add_argument("--skip-completed", action="store_true")
    parser.add_argument("--run-xcode-build", action="store_true")
    parser.add_argument("--run-swift-tests", action="store_true")
    return parser.parse_args(list(argv))


def main(argv: Iterable[str] = sys.argv[1:]) -> int:
    args = parse_args(argv)
    git(["pull", "--ff-only", "origin", "main"])
    ensure_clean_worktree()
    state = load_state()
    completed = set(state.get("completed_batches", []))
    selected = select_batches(args.batch, args.max_batches, args.skip_completed, completed)
    if not selected:
        print("No connector batches selected.")
        return 0
    print("Connector batches selected: " + ", ".join(selected))
    final_status: Status = "green"
    for batch_id in selected:
        try:
            result = run_one_batch(batch_id, args, state)
        except Exception as exc:
            state["status"] = "red"
            state["failed_batch"] = batch_id
            state["failure"] = str(exc)
            save_state(state)
            print(f"Connector batch stopped on {batch_id}: {exc}", file=sys.stderr)
            return 1
        if result.status != "green":
            final_status = result.status
            break
    state["status"] = final_status
    state["failed_batch"] = None if final_status == "green" else selected[-1]
    state["failure"] = None if final_status == "green" else "non-green connector batch"
    save_state(state)
    print(f"Connector batch runner finished: {final_status}")
    return 0 if final_status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
