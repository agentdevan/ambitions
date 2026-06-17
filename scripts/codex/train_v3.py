#!/usr/bin/env python3
"""Ambitions Codex Train V3.

Manifest-driven GitHub Actions runner for new Ambitions Codex trains.
Design goals: typed batches, no prompt mutation, no release-recovery coupling,
no build/reports output, and no universal source gates.
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


def log(message: str) -> None:
    print(message, flush=True)


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def run(
    command: list[str],
    log_path: Path | None = None,
    env: dict[str, str] | None = None,
    input_text: str | None = None,
) -> subprocess.CompletedProcess[str]:
    merged = os.environ.copy()
    if env:
        merged.update(env)
    process = subprocess.run(
        command,
        cwd=ROOT,
        env=merged,
        input=input_text,
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
    for key in ("id", "batches"):
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


def print_gate(result: GateResult) -> None:
    marker = "OK" if result.status == "green" else ("WARN" if result.status == "yellow" else "FAIL")
    blocking = "blocking" if result.blocking else "advisory"
    log(f"[{marker}] {result.name} ({blocking}) — {result.summary}")
    if result.log_path:
        log(f"      log: {result.log_path}")


def record_gate(results: list[GateResult], result: GateResult) -> None:
    results.append(result)
    print_gate(result)


def tail_summary(text: str, limit: int = 1000) -> str:
    tail = "\n".join(text.splitlines()[-12:]).strip()
    return tail[:limit]


def gate(name: str, command: list[str], ctx: BatchContext, blocking: bool = True) -> GateResult:
    log_path = ctx.run_dir / "gates" / f"{name}.log"
    result = run(command, log_path)
    status: Status = "green" if result.returncode == 0 else "red"
    summary = f"exit={result.returncode}"
    if result.returncode != 0:
        tail = tail_summary(result.stdout)
        if tail:
            summary += f"; tail={tail}"
    return GateResult(name, status, blocking, command, rel(log_path), summary)


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
    missing_files = [path for path in truth_files if not (ROOT / path).exists()]
    if missing_files:
        return GateResult("truth_readback", "red", True, None, None, f"missing truth files: {missing_files}")

    product_path = ROOT / "docs/truth/PRODUCT_DESIGN_TRUTH.md"
    if not product_path.exists():
        return GateResult("truth_readback", "red", True, None, None, "missing PRODUCT_DESIGN_TRUTH.md")

    product_truth = product_path.read_text(encoding="utf-8", errors="ignore")
    lower = product_truth.lower()
    requirements: list[tuple[str, list[str]]] = [
        ("four-surface law", ["today / goals / time / you"]),
        ("capture global law", ["capture", "global"]),
        ("motion behavior law", ["motion", "cross-surface"]),
        ("r2 boundary", ["r2", "not a user-data backend"]),
        ("hosted ai/cloud llm boundary", ["hosted ai", "cloud llm"]),
        ("canon sentinel", ["this is the canon."]),
    ]
    missing = [label for label, tokens in requirements if not all(token in lower for token in tokens)]
    if missing:
        return GateResult("truth_readback", "red", True, None, None, f"missing/weak product truth requirements: {missing}")
    return GateResult("truth_readback", "green", True, None, None, "truth files and product law present")


def changed_files_since(start_sha: str) -> list[str]:
    tracked = run(["git", "diff", "--name-only", start_sha]).stdout.splitlines()
    untracked = run(["git", "ls-files", "--others", "--exclude-standard"]).stdout.splitlines()
    return sorted(set(item for item in tracked + untracked if item.strip()))


def path_allowed(path: str, allowed: list[str]) -> bool:
    normalized = path.replace("\\", "/")
    for prefix in allowed:
        clean = prefix.replace("\\", "/")
        if clean.endswith("/"):
            if normalized.startswith(clean):
                return True
        elif normalized == clean:
            return True
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
    report.parent.mkdir(parents=True, exist_ok=True)
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
    results: list[GateResult] = []
    record_gate(results, gate_prompt_lint(ctx))
    record_gate(results, gate_truth_readback(ctx, truth_files))
    return results


def run_post_gates(ctx: BatchContext) -> list[GateResult]:
    results: list[GateResult] = []
    for result in [
        gate("diff_check", ["git", "diff", "--check"], ctx, True),
        gate_allowed_paths(ctx),
    ]:
        record_gate(results, result)
    if ctx.batch["type"] == "audit":
        record_gate(results, gate_no_source_diff_for_audit(ctx))
    for result in [
        gate("authority_drift", ["python3", "scripts/ambitions_validate_authority_drift.py"], ctx, True),
        gate("local_first_boundary", ["python3", "scripts/ambitions-local-first-boundary-scan.py"], ctx, True),
    ]:
        record_gate(results, result)
    if ctx.batch["type"] in {"source", "visual", "schema", "validation"}:
        record_gate(results, gate("root_ia_validator", ["python3", "scripts/codex/amb-master-canon-ia-validate.py"], ctx, True))
    if ctx.run_xcode_build and bool(ctx.batch.get("build")):
        for result in [
            gate("xcodegen", ["xcodegen", "generate"], ctx, True),
            gate("resolve_packages", ["xcodebuild", "-project", "Ambitions.xcodeproj", "-scheme", "Ambitions", "-resolvePackageDependencies"], ctx, True),
            gate("xcodebuild", ["xcodebuild", "-project", "Ambitions.xcodeproj", "-scheme", "Ambitions", "-destination", "generic/platform=iOS Simulator", "CODE_SIGNING_ALLOWED=NO", "build"], ctx, True),
        ]:
            record_gate(results, result)
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

Rules:
- Manifest batch type controls gates.
- Do not mutate prompt files.
- Write ephemeral logs under artifacts/codex-train-v3 only.
- Do not write generated reports under build/reports.
- Preserve product law: Today / Goals / Time / You; Capture global composer; Motion behavior layer.

---

"""
    rendered.parent.mkdir(parents=True, exist_ok=True)
    rendered.write_text(preface + body, encoding="utf-8")
    return rendered


def run_codex(ctx: BatchContext) -> GateResult:
    if ctx.mode == "dry-run":
        return GateResult("codex", "green", True, None, None, "dry-run skipped codex")
    if shutil.which("codex") is None:
        return GateResult("codex", "red", True, None, None, "codex CLI unavailable")
    rendered = render_prompt(ctx)
    out = ctx.run_dir / "codex-output.log"
    last = ctx.run_dir / "codex-last-message.md"
    command = [
        "codex",
        "exec",
        "-c",
        f"service_tier=\"{os.environ.get('CODEX_SERVICE_TIER', 'fast')}\"",
        "--model",
        os.environ.get("PATCH_MODEL", "gpt-5.3-codex-spark"),
        "--sandbox",
        "danger-full-access",
        "--json",
        "--output-last-message",
        str(last),
    ]
    result = run(command, out, input_text=rendered.read_text(encoding="utf-8"))
    status: Status = "green" if result.returncode == 0 else "red"
    summary = f"exit={result.returncode}"
    if result.returncode != 0:
        tail = tail_summary(result.stdout)
        if tail:
            summary += f"; tail={tail}"
    return GateResult("codex", status, True, command, rel(out), summary)


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
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text("\n".join(lines) + "\n", encoding="utf-8")


def commit_batch(ctx: BatchContext) -> str | None:
    if ctx.mode == "dry-run" or ctx.commit_strategy == "none" or not ctx.batch.get("commit", True):
        return None
    files = changed_files_since(ctx.start_sha)
    add_files = [path for path in files if not path.startswith("artifacts/codex-train-v3/") and not path.startswith(".codex/runs/")]
    if not add_files:
        return None
    subprocess.run(["git", "config", "user.name", "ambitions-codex-train-v3"], cwd=ROOT, check=True)
    subprocess.run(["git", "config", "user.email", "actions@users.noreply.github.com"], cwd=ROOT, check=True)
    subprocess.run(["git", "add", *add_files], cwd=ROOT, check=True)
    if subprocess.run(["git", "diff", "--cached", "--quiet"], cwd=ROOT, check=False).returncode == 0:
        return None
    message = f"{ctx.batch['id']}: {ctx.batch.get('title', 'Codex Train V3 batch')}"
    subprocess.run(["git", "commit", "-m", message], cwd=ROOT, check=True)
    subprocess.run(["git", "push", "origin", "HEAD:main"], cwd=ROOT, check=True)
    return current_sha()


def batch_status(results: list[GateResult]) -> Status:
    if any(result.blocking and result.status == "red" for result in results):
        return "red"
    if any(result.status == "yellow" for result in results):
        return "yellow"
    return "green"


def run_batch(train_id: str, batch: dict, args: argparse.Namespace, truth_files: list[str]) -> Status:
    git(["pull", "--ff-only", "origin", "main"])
    ensure_clean_worktree()
    start_sha = current_sha()
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    run_dir = RUN_ROOT / train_id / batch["id"] / run_id
    run_dir.mkdir(parents=True, exist_ok=True)

    ctx = BatchContext(train_id, batch, run_dir, start_sha, args.mode, args.run_xcode_build, args.run_tests, args.commit_strategy)

    results: list[GateResult] = []
    log(f"-- pre gates for {batch['id']} --")
    results.extend(run_pre_gates(ctx, truth_files))
    if batch_status(results) == "red":
        write_batch_report(ctx, results, "red", None)
        return "red"

    log(f"-- codex for {batch['id']} --")
    codex_result = run_codex(ctx)
    record_gate(results, codex_result)
    if batch_status(results) == "red":
        write_batch_report(ctx, results, "red", None)
        return "red"

    log(f"-- post gates for {batch['id']} --")
    results.extend(run_post_gates(ctx))
    status = batch_status(results)
    commit_sha = None
    if status == "green":
        commit_sha = commit_batch(ctx)
        if commit_sha:
            log(f"committed {batch['id']}: {commit_sha}")
        else:
            log(f"no commit created for {batch['id']}")
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

    log(f"Train: {manifest['id']}")
    log(f"Mode: {args.mode}")
    log(f"Selected batches: {', '.join(batch['id'] for batch in batches)}")

    final_status: Status = "green"
    for batch in batches:
        log(f"== {batch['id']} {batch.get('title', '')} ==")
        status = run_batch(manifest["id"], batch, args, manifest.get("truth_files", []))
        log(f"{batch['id']}: {status}")
        if status == "red":
            final_status = "red"
            if manifest.get("fail_fast", True):
                break
        elif status == "yellow" and final_status != "red":
            final_status = "yellow"

    log(f"Final status: {final_status}")
    return 0 if final_status != "red" else 1


if __name__ == "__main__":
    raise SystemExit(main())
