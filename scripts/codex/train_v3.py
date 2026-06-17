#!/usr/bin/env python3
"""Ambitions Codex Train V3.

A small manifest-driven GitHub Actions runner for Ambitions trains.
It replaces recovery-era autopilot semantics for new Codex work.
"""
from __future__ import annotations

import argparse
import json
import os
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
import shutil
import subprocess
import sys
from typing import Iterable, Literal

ROOT = Path(__file__).resolve().parents[2]
RUN_ROOT = ROOT / "artifacts" / "codex-train-v3" / "runs"

Status = Literal["green", "yellow", "red"]


@dataclass
class GateResult:
    name: str
    status: Status
    blocking: bool
    command: list[str] | None
    log_path: str | None
    summary: str


@dataclass
class BatchContext:
    train_id: str
    batch: dict
    run_dir: Path
    start_sha: str
    mode: str
    run_xcode_build: bool
    run_tests: str
    commit_strategy: str


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def run(command: list[str], log_path: Path | None = None, env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    merged = os.environ.copy()
    if env:
        merged.update(env)
    process = subprocess.run(
        command,
        cwd=ROOT,
        env=merged,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if log_path is not None:
        log_path.parent.mkdir(parents=True, exist_ok=True)
        log_path.write_text("$ " + " ".join(command) + "\n\n" + process.stdout, encoding="utf-8")
    return process


def git(args: list[str], check: bool = True) -> str:
    process = run(["git", *args])
    if check and process.returncode != 0:
        raise RuntimeError(process.stdout)
    return process.stdout.strip()


def current_sha() -> str:
    return git(["rev-parse", "HEAD"])


def ensure_clean_worktree() -> None:
    status = git(["status", "--porcelain"])
    if status:
        raise RuntimeError("Dirty worktree before batch:\n" + status)


def load_manifest(path: Path) -> dict:
    if not path.exists():
        raise RuntimeError(f"Train manifest missing: {path}")
    data = json.loads(path.read_text(encoding="utf-8"))
    required = ["id", "batches"]
    for key in required:
        if key not in data:
            raise RuntimeError(f"Train manifest missing key: {key}")
    if not isinstance(data["batches"], list) or not data["batches"]:
        raise RuntimeError("Train manifest has no batches")
    return data


def selected_batches(batches: list[dict], start_batch: str, end_batch: str, max_batches: int) -> list[dict]:
    selected: list[dict] = []
    started = start_batch == "auto"
    for batch in batches:
        bid = batch["id"]
        if bid == start_batch:
            started = True
        if started:
            selected.append(batch)
        if end_batch != "auto" and bid == end_batch:
            break
        if len(selected) >= max_batches:
            break
    if not selected:
        raise RuntimeError(f"No batches selected. start_batch={start_batch} end_batch={end_batch}")
    return selected


def gate(name: str, command: list[str], ctx: BatchContext, blocking: bool = True) -> GateResult:
    log_path = ctx.run_dir / "gates" / f"{name}.log"
    result = run(command, log_path)
    status: Status = "green" if result.returncode == 0 else "red"
    return GateResult(name, status, blocking, command, rel(log_path), f"exit={result.returncode}")


def gate_prompt_lint(ctx: BatchContext) -> GateResult:
    prompt = ROOT / ctx.batch["prompt"]
    if not prompt.exists():
        return GateResult("prompt_lint", "red", True, None, None, f"missing prompt: {ctx.batch['prompt']}")
    text = prompt.read_text(encoding="utf-8", errors="ignore")
    required = [
        "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
        "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
        "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
    ]
    missing = [item for item in required if item not in text]
    if missing:
        return GateResult("prompt_lint", "red", True, None, None, f"missing metadata: {missing}")
    return GateResult("prompt_lint", "green", True, None, None, "prompt metadata ok")


def gate_truth_readback(ctx: BatchContext, truth_files: list[str]) -> GateResult:
    missing = [path for path in truth_files if not (ROOT / path).exists()]
    if missing:
        return GateResult("truth_readback", "red", True, None, None, f"missing truth files: {missing}")
    product_truth = (ROOT / "docs/truth/PRODUCT_DESIGN_TRUTH.md").read_text(encoding="utf-8", errors="ignore")
    required = [
        "Today / Goals / Time / You",
        "Capture is the global composer",
        "Motion is cross-surface behavior",
        "R2 is not a user-data backend",
        "Hosted AI services and cloud LLMs are not core architecture",
        "This is the canon.",
    ]
    missing_phrases = [phrase for phrase in required if phrase not in product_truth]
    if missing_phrases:
        return GateResult("truth_readback", "red", True, None, None, f"missing product truth phrases: {missing_phrases}")
    return GateResult("truth_readback", "green", True, None, None, "truth files present")


def changed_files_since(start_sha: str) -> list[str]:
    tracked = run(["git", "diff", "--name-only", start_sha]).stdout.splitlines()
    untracked = run(["git", "ls-files", "--others", "--exclude-standard"]).stdout.splitlines()
    return sorted(set([item for item in tracked + untracked if item.strip()]))


def path_allowed(path: str, allowed: list[str]) -> bool:
    normalized = path.replace("\\", "/")
    for prefix in allowed:
        clean = prefix.replace("\\", "/")
        if clean.endswith("/"):
            if normalized.startswith(clean):
                return True
        elif normalized == clean:
            return True
    # Runner-local artifacts are always allowed and uploaded only unless explicitly staged.
    if normalized.startswith("artifacts/codex-train-v3/"):
        return True
    if normalized.startswith(".codex/runs/"):
        return True
    return False


def gate_allowed_paths(ctx: BatchContext) -> GateResult:
    files = changed_files_since(ctx.start_sha)
    allowed = list(ctx.batch.get("allowed_paths") or [])
    offenders = [path for path in files if not path_allowed(path, allowed)]
    report = ctx.run_dir / "changed-files.json"
    report.write_text(json.dumps({"changed_files": files, "offenders": offenders}, indent=2) + "\n", encoding="utf-8")
    if offenders:
        return GateResult("allowed_paths", "red", True, None, rel(report), f"off-path changes: {offenders}")
    return GateResult("allowed_paths", "green", True, None, rel(report), f"changed files ok: {len(files)}")


def gate_no_source_diff_for_audit(ctx: BatchContext) -> GateResult:
    files = changed_files_since(ctx.start_sha)
    source_prefixes = ("Native/", "Sources/", "AppUI/", "project.yml", "Package.swift")
    offenders = [path for path in files if path.startswith(source_prefixes)]
    if offenders:
        return GateResult("audit_no_source_diff", "red", True, None, None, f"audit batch changed source paths: {offenders}")
    return GateResult("audit_no_source_diff", "green", True, None, None, "no source diff in audit batch")


def run_pre_gates(ctx: BatchContext, truth_files: list[str]) -> list[GateResult]:
    results = [gate_prompt_lint(ctx), gate_truth_readback(ctx, truth_files)]
    if ctx.batch["type"] != "audit":
        # Source-owning gates should not run on audit batches.
        pass
    return results


def run_post_gates(ctx: BatchContext) -> list[GateResult]:
    results: list[GateResult] = []
    results.append(gate("diff_check", ["git", "diff", "--check"], ctx, True))
    results.append(gate_allowed_paths(ctx))
    if ctx.batch["type"] == "audit":
        results.append(gate_no_source_diff_for_audit(ctx))
    results.append(gate("authority_drift", ["python3", "scripts/ambitions_validate_authority_drift.py"], ctx, True))
    results.append(gate("local_first_boundary", ["python3", "scripts/ambitions-local-first-boundary-scan.py"], ctx, True))
    if ctx.batch["type"] in {"source", "visual", "schema", "validation"}:
        results.append(gate("root_ia_validator", ["python3", "scripts/codex/amb-master-canon-ia-validate.py"], ctx, True))
    if ctx.run_xcode_build and bool(ctx.batch.get("build")):
        results.append(gate("xcodegen", ["xcodegen", "generate"], ctx, True))
        results.append(gate("resolve_packages", ["xcodebuild", "-project", "Ambitions.xcodeproj", "-scheme", "Ambitions", "-resolvePackageDependencies"], ctx, True))
        results.append(gate("xcodebuild", ["xcodebuild", "-project", "Ambitions.xcodeproj", "-scheme", "Ambitions", "-destination", "generic/platform=iOS Simulator", "CODE_SIGNING_ALLOWED=NO", "build"], ctx, True))
    return results


def render_prompt(ctx: BatchContext) -> Path:
    prompt_path = ROOT / ctx.batch["prompt"]
    body = prompt_path.read_text(encoding="utf-8", errors="ignore")
    rendered = ctx.run_dir / "rendered-prompt.md"
    allowed = "\n".join(f"- {item}" for item in ctx.batch.get("allowed_paths", []))
    preface = f"""# Train V3 Execution Context

Train: {ctx.train_id}
Batch: {ctx.batch['id']}
Type: {ctx.batch['type']}
Title: {ctx.batch.get('title', '')}
Mode: {ctx.mode}

Manifest allowed paths:
{allowed}

Manifest rules:
- Batch type in manifest is authoritative.
- Do not mutate prompt files.
- Write ephemeral logs under artifacts/codex-train-v3 only.
- Do not write generated reports under build/reports.
- Commit only intentional Green batch outputs.
- Preserve product law: Today / Goals / Time / You; Capture global composer; Motion behavior layer.

---

"""
    rendered.write_text(preface + body, encoding="utf-8")
    return rendered


def run_codex(ctx: BatchContext) -> GateResult:
    if ctx.mode == "dry-run":
        return GateResult("codex", "green", True, None, None, "dry-run skipped codex")
    if shutil.which("codex") is None:
        return GateResult("codex", "red", True, None, None, "codex CLI unavailable")
    rendered = render_prompt(ctx)
    out = ctx.run_dir / "codex-output.log"
    command = ["codex", "exec", "--sandbox", "danger-full-access", "--model", os.environ.get("PATCH_MODEL", "gpt-5.3-codex-spark"), str(rendered)]
    result = run(command, out)
    status: Status = "green" if result.returncode == 0 else "red"
    return GateResult("codex", status, True, command, rel(out), f"exit={result.returncode}")


def write_batch_report(ctx: BatchContext, results: list[GateResult], status: Status, commit_sha: str | None) -> None:
    report = ctx.run_dir / "batch-report.md"
    lines = [
        f"# {ctx.batch['id']} — {ctx.batch.get('title', '')}",
        "",
        f"Status: {status.upper()}",
        f"Train: `{ctx.train_id}`",
        f"Type: `{ctx.batch['type']}`",
        f"Start SHA: `{ctx.start_sha}`",
        f"Commit SHA: `{commit_sha or 'none'}`",
        f"Run dir: `{rel(ctx.run_dir)}`",
        "",
        "## Gates",
        "",
        "| Gate | Status | Blocking | Summary | Log |",
        "|---|---|---:|---|---|",
    ]
    for result in results:
        lines.append(f"| {result.name} | {result.status} | {str(result.blocking).lower()} | {result.summary} | `{result.log_path or ''}` |")
    lines.extend(["", "## Changed files", ""])
    for path in changed_files_since(ctx.start_sha):
        lines.append(f"- `{path}`")
    report.write_text("\n".join(lines) + "\n", encoding="utf-8")

    train_artifact_dir = ROOT / "artifacts" / ctx.train_id
    train_artifact_dir.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(report, train_artifact_dir / f"{ctx.batch['id']}-report.md")


def commit_batch(ctx: BatchContext) -> str | None:
    if ctx.mode == "dry-run" or ctx.commit_strategy == "none" or not ctx.batch.get("commit", True):
        return None
    files = changed_files_since(ctx.start_sha)
    if not files:
        return None
    subprocess.run(["git", "config", "user.name", "ambitions-codex-train-v3"], cwd=ROOT, check=True)
    subprocess.run(["git", "config", "user.email", "actions@users.noreply.github.com"], cwd=ROOT, check=True)
    add_files = [path for path in files if not path.startswith("artifacts/codex-train-v3/") and not path.startswith(".codex/runs/")]
    if not add_files:
        return None
    subprocess.run(["git", "add", *add_files], cwd=ROOT, check=True)
    if subprocess.run(["git", "diff", "--cached", "--quiet"], cwd=ROOT, check=False).returncode == 0:
        return None
    message = f"{ctx.batch['id']}: {ctx.batch.get('title', 'Codex Train V3 batch')}"
    subprocess.run(["git", "commit", "-m", message], cwd=ROOT, check=True)
    subprocess.run(["git", "push", "origin", "HEAD:main"], cwd=ROOT, check=True)
    return current_sha()


def batch_status(results: list[GateResult]) -> Status:
    blocking_red = any(result.blocking and result.status == "red" for result in results)
    if blocking_red:
        return "red"
    any_yellow = any(result.status == "yellow" for result in results)
    return "yellow" if any_yellow else "green"


def run_batch(train_id: str, batch: dict, args: argparse.Namespace, truth_files: list[str]) -> Status:
    git(["pull", "--ff-only", "origin", "main"])
    ensure_clean_worktree()
    start_sha = current_sha()
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    run_dir = RUN_ROOT / train_id / batch["id"] / run_id
    run_dir.mkdir(parents=True, exist_ok=True)

    ctx = BatchContext(
        train_id=train_id,
        batch=batch,
        run_dir=run_dir,
        start_sha=start_sha,
        mode=args.mode,
        run_xcode_build=args.run_xcode_build,
        run_tests=args.run_tests,
        commit_strategy=args.commit_strategy,
    )

    results: list[GateResult] = []
    results.extend(run_pre_gates(ctx, truth_files))
    pre_status = batch_status(results)
    if pre_status == "red":
        write_batch_report(ctx, results, "red", None)
        return "red"

    results.append(run_codex(ctx))
    if batch_status(results) == "red":
        write_batch_report(ctx, results, "red", None)
        return "red"

    results.extend(run_post_gates(ctx))
    status = batch_status(results)
    commit_sha = None
    if status == "green":
        commit_sha = commit_batch(ctx)
    write_batch_report(ctx, results, status, commit_sha)
    return status


def parse_args(argv: Iterable[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run an Ambitions Codex Train V3 manifest.")
    parser.add_argument("--train", default="object-stage-mega-train")
    parser.add_argument("--manifest", default="")
    parser.add_argument("--start-batch", default="auto")
    parser.add_argument("--end-batch", default="auto")
    parser.add_argument("--max-batches", type=int, default=99)
    parser.add_argument("--mode", choices=("dry-run", "execute"), default="execute")
    parser.add_argument("--commit-strategy", choices=("none", "batch"), default="batch")
    parser.add_argument("--run-xcode-build", action="store_true")
    parser.add_argument("--run-tests", choices=("none", "focused", "full"), default="none")
    return parser.parse_args(list(argv))


def main(argv: Iterable[str] = sys.argv[1:]) -> int:
    args = parse_args(argv)
    manifest_path = Path(args.manifest) if args.manifest else ROOT / "trains" / args.train / "train.json"
    if not manifest_path.is_absolute():
        manifest_path = ROOT / manifest_path
    manifest = load_manifest(manifest_path)
    batches = selected_batches(manifest["batches"], args.start_batch, args.end_batch, args.max_batches)

    print(f"Train: {manifest['id']}")
    print(f"Mode: {args.mode}")
    print(f"Selected batches: {', '.join(batch['id'] for batch in batches)}")

    final_status: Status = "green"
    for batch in batches:
        print(f"== {batch['id']} {batch.get('title', '')} ==")
        status = run_batch(manifest["id"], batch, args, manifest.get("truth_files", []))
        print(f"{batch['id']}: {status}")
        if status == "red":
            final_status = "red"
            if manifest.get("fail_fast", True):
                break
        elif status == "yellow" and final_status != "red":
            final_status = "yellow"

    print(f"Final status: {final_status}")
    return 0 if final_status != "red" else 1


if __name__ == "__main__":
    raise SystemExit(main())
