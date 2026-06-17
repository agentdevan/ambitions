#!/usr/bin/env python3
"""Ambitions Codex Train V3.

Manifest-driven GitHub Actions runner for new Ambitions Codex trains.
Design goals: typed batches, no prompt mutation, no release-recovery coupling,
no build/reports output, no universal source gates, and strict completion
invariants for source/schema/visual batches.
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

IGNORED_CHANGE_PREFIXES = (
    ".codex/runs/",
    "artifacts/codex-train-v3/",
)


@dataclass
class GateResult:
    name: str
    status: Status
    blocking: bool
    command: list[str] | None
    log_path: str | None
    summary: str


@dataclass
class CompletionSummary:
    status: Status
    scope_verdict: Status
    reason: str
    changed_files_by_kind: dict[str, list[str]]
    source_delta_count: int
    test_delta_count: int
    schema_delta_count: int
    artifact_delta_count: int
    validation_evidence: list[str]


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
    replay_of: str | None = None


def log(message: str) -> None:
    print(message, flush=True)


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def now_utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def normalize_path(path: str) -> str:
    return path.replace("\\", "/")


def run(
    command: list[str],
    log_path: Path | None = None,
    env: dict[str, str] | None = None,
    input_text: str | None = None,
    timeout_seconds: int | None = None,
) -> subprocess.CompletedProcess[str]:
    merged = os.environ.copy()
    if env:
        merged.update(env)
    try:
        process = subprocess.run(
            command,
            cwd=ROOT,
            env=merged,
            input=input_text,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
            timeout=timeout_seconds,
        )
    except subprocess.TimeoutExpired as exc:
        stdout = exc.stdout or ""
        if isinstance(stdout, bytes):
            stdout = stdout.decode("utf-8", errors="replace")
        stdout += f"\nTIMEOUT after {timeout_seconds}s\n"
        process = subprocess.CompletedProcess(command, 124, stdout=stdout)
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


def state_path(train_id: str) -> Path:
    return ROOT / "artifacts" / train_id / "train-state.json"


def load_state(train_id: str) -> dict:
    path = state_path(train_id)
    if not path.exists():
        return {"version": 2, "completed_batches": []}
    state = json.loads(path.read_text(encoding="utf-8"))
    state.setdefault("version", 2)
    state.setdefault("completed_batches", [])
    return state


def completed_batch_ids(train_id: str) -> set[str]:
    state = load_state(train_id)
    completed = state.get("completed_batches") or []
    status_by_id: dict[str, str] = {}
    for item in completed:
        if isinstance(item, dict):
            batch_id = item.get("id")
            if not batch_id:
                continue
            status_by_id[str(batch_id)] = str(item.get("status", "green"))
        else:
            status_by_id[str(item)] = "green"
    return {batch_id for batch_id, status in status_by_id.items() if status != "invalidated"}


def mark_batch_invalidated(ctx: BatchContext, reason: str, summary: CompletionSummary | None = None) -> None:
    path = state_path(ctx.train_id)
    path.parent.mkdir(parents=True, exist_ok=True)
    state = load_state(ctx.train_id)
    completed = state.setdefault("completed_batches", [])
    completed.append(
        {
            "id": ctx.batch["id"],
            "title": ctx.batch.get("title", ""),
            "type": ctx.batch.get("type", ""),
            "status": "invalidated",
            "invalidated_at": now_utc(),
            "start_sha": ctx.start_sha,
            "end_sha": current_sha(),
            "reason": reason,
            "source_delta_count": summary.source_delta_count if summary else 0,
            "test_delta_count": summary.test_delta_count if summary else 0,
            "schema_delta_count": summary.schema_delta_count if summary else 0,
            "artifact_delta_count": summary.artifact_delta_count if summary else 0,
            "changed_files_by_kind": summary.changed_files_by_kind if summary else {},
        }
    )
    state["completed_batches"] = completed
    state["updated_at"] = now_utc()
    path.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def mark_batch_completed(ctx: BatchContext, status: Status, summary: CompletionSummary) -> None:
    if ctx.mode != "execute" or status != "green":
        return
    path = state_path(ctx.train_id)
    path.parent.mkdir(parents=True, exist_ok=True)
    state = load_state(ctx.train_id)
    completed = state.setdefault("completed_batches", [])
    completed = [
        item
        for item in completed
        if not (
            isinstance(item, dict)
            and item.get("id") == ctx.batch["id"]
            and item.get("status", "green") != "invalidated"
        )
        and item != ctx.batch["id"]
    ]
    completed.append(
        {
            "id": ctx.batch["id"],
            "title": ctx.batch.get("title", ""),
            "type": ctx.batch.get("type", ""),
            "status": status,
            "completed_at": now_utc(),
            "start_sha": ctx.start_sha,
            "end_sha": current_sha(),
            "commit_sha": "recorded-by-git-history",
            "source_delta_count": summary.source_delta_count,
            "test_delta_count": summary.test_delta_count,
            "schema_delta_count": summary.schema_delta_count,
            "artifact_delta_count": summary.artifact_delta_count,
            "changed_files_by_kind": summary.changed_files_by_kind,
            "scope_verdict": summary.scope_verdict,
            "validation_evidence": summary.validation_evidence,
            "replay_of": ctx.replay_of,
        }
    )
    state["completed_batches"] = completed
    state["last_completed_batch"] = ctx.batch["id"]
    state["updated_at"] = now_utc()
    state["version"] = max(int(state.get("version", 1) or 1), 2)
    path.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8")


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
    return sorted(set(normalize_path(item) for item in tracked + untracked if item.strip()))


def durable_changed_files_since(start_sha: str) -> list[str]:
    return [
        path
        for path in changed_files_since(start_sha)
        if not any(path.startswith(prefix) for prefix in IGNORED_CHANGE_PREFIXES)
    ]


def path_allowed(path: str, allowed: list[str]) -> bool:
    normalized = normalize_path(path)
    for prefix in allowed:
        clean = normalize_path(prefix)
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


def classify_changed_files(files: Iterable[str], train_id: str) -> dict[str, list[str]]:
    kinds: dict[str, list[str]] = {
        "app_source": [],
        "tests": [],
        "persistence_schema": [],
        "scripts": [],
        "truth_docs": [],
        "schema_decision": [],
        "train_artifacts": [],
        "runner_artifacts": [],
        "other": [],
    }
    for raw in files:
        path = normalize_path(raw)
        if path.startswith(IGNORED_CHANGE_PREFIXES):
            kinds["runner_artifacts"].append(path)
        elif path.startswith("Native/AmbitionsTests/") or path.startswith("Native/AmbitionsUITests/"):
            kinds["tests"].append(path)
        elif path.startswith("Native/Ambitions/Persistence/") or path.startswith("Native/Ambitions/Domain/"):
            kinds["persistence_schema"].append(path)
        elif path.startswith("Native/Ambitions/") or path.startswith("Sources/") or path.startswith("AppUI/"):
            kinds["app_source"].append(path)
        elif path.startswith("scripts/"):
            kinds["scripts"].append(path)
        elif path.startswith("docs/truth/") or path == "AGENTS.md":
            kinds["truth_docs"].append(path)
        elif path.startswith(f"artifacts/{train_id}/") and path.endswith("-schema-decision.md"):
            kinds["schema_decision"].append(path)
        elif path.startswith(f"artifacts/{train_id}/"):
            kinds["train_artifacts"].append(path)
        else:
            kinds["other"].append(path)
    return kinds


def schema_decision_valid(ctx: BatchContext, changed: dict[str, list[str]]) -> tuple[bool, str]:
    candidates = changed.get("schema_decision", [])
    if not candidates:
        return False, "missing schema decision artifact"
    expected = f"artifacts/{ctx.train_id}/{ctx.batch['id']}-schema-decision.md"
    if expected not in candidates:
        return False, f"schema decision artifact must be {expected}"
    path = ROOT / expected
    if not path.exists():
        return False, f"schema decision artifact missing on disk: {expected}"
    text = path.read_text(encoding="utf-8", errors="ignore")
    lower = text.lower()
    required = {
        "inspected SwiftData/domain/persistence files": ["inspected", "swiftdata", "persistence"],
        "model inventory": ["model inventory"],
        "schema changed yes/no": ["schema changed", "no"],
        "migration/defaults impact": ["migration", "default"],
        "tests run or not-run reason": ["test"],
        "local-first/privacy boundary": ["local-first", "privacy"],
        "rollback": ["rollback"],
    }
    missing = [label for label, tokens in required.items() if not all(token in lower for token in tokens)]
    if missing:
        return False, f"schema decision missing sections: {', '.join(missing)}"
    return True, "valid no-change schema decision artifact"


def completion_summary_for(ctx: BatchContext) -> CompletionSummary:
    files = changed_files_since(ctx.start_sha)
    durable_files = durable_changed_files_since(ctx.start_sha)
    changed = classify_changed_files(files, ctx.train_id)
    durable_changed = classify_changed_files(durable_files, ctx.train_id)

    source_delta_count = len(durable_changed["app_source"])
    test_delta_count = len(durable_changed["tests"])
    schema_delta_count = len(durable_changed["persistence_schema"])
    artifact_delta_count = len(durable_changed["train_artifacts"]) + len(durable_changed["schema_decision"])

    validation_evidence = [
        path
        for path in files
        if path.startswith("artifacts/codex-train-v3/")
        or path.startswith(f"artifacts/{ctx.train_id}/")
        or path.startswith(".codex/")
    ]

    batch_type = str(ctx.batch.get("type", "source")).lower()
    reason = "completion invariant satisfied"
    status: Status = "green"

    if ctx.mode == "dry-run":
        return CompletionSummary(
            status="green",
            scope_verdict="green",
            reason="dry-run completion invariant skipped",
            changed_files_by_kind=changed,
            source_delta_count=source_delta_count,
            test_delta_count=test_delta_count,
            schema_delta_count=schema_delta_count,
            artifact_delta_count=artifact_delta_count,
            validation_evidence=validation_evidence,
        )

    if batch_type == "audit":
        source_like = durable_changed["app_source"] + durable_changed["tests"] + durable_changed["persistence_schema"]
        if source_like:
            status = "red"
            reason = f"audit batch changed source/test/schema paths: {source_like}"
    elif batch_type == "source":
        if source_delta_count + test_delta_count == 0:
            status = "red"
            reason = "source batch produced no app source or test delta; artifact-only completion is invalid"
    elif batch_type == "schema":
        if schema_delta_count + test_delta_count > 0:
            reason = "schema batch changed persistence/domain or tests"
        else:
            valid, detail = schema_decision_valid(ctx, durable_changed)
            if valid:
                reason = detail
            else:
                status = "red"
                reason = f"schema batch produced no schema/test delta and no valid no-change decision: {detail}"
    elif batch_type == "visual":
        if source_delta_count + test_delta_count == 0:
            status = "red"
            reason = "visual batch produced no app/UI source or test delta; artifact-only completion is invalid"
    elif batch_type == "validation":
        if not validation_evidence and not durable_changed["tests"] and not durable_changed["scripts"]:
            status = "red"
            reason = "validation batch produced no validation evidence, tests, scripts, or artifacts"
    else:
        if not durable_files:
            status = "red"
            reason = f"unknown batch type {batch_type!r} produced no durable diff"

    return CompletionSummary(
        status=status,
        scope_verdict=status,
        reason=reason,
        changed_files_by_kind=changed,
        source_delta_count=source_delta_count,
        test_delta_count=test_delta_count,
        schema_delta_count=schema_delta_count,
        artifact_delta_count=artifact_delta_count,
        validation_evidence=validation_evidence,
    )


def write_completion_invariant_report(ctx: BatchContext, summary: CompletionSummary) -> Path:
    report = ctx.run_dir / "completion-invariant.json"
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(
        json.dumps(
            {
                "batch_id": ctx.batch["id"],
                "type": ctx.batch.get("type"),
                "status": summary.status,
                "scope_verdict": summary.scope_verdict,
                "reason": summary.reason,
                "source_delta_count": summary.source_delta_count,
                "test_delta_count": summary.test_delta_count,
                "schema_delta_count": summary.schema_delta_count,
                "artifact_delta_count": summary.artifact_delta_count,
                "changed_files_by_kind": summary.changed_files_by_kind,
                "validation_evidence": summary.validation_evidence,
            },
            indent=2,
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )
    return report


def gate_completion_invariant(ctx: BatchContext) -> GateResult:
    summary = completion_summary_for(ctx)
    report = write_completion_invariant_report(ctx, summary)
    return GateResult(
        "completion_invariant",
        summary.status,
        True,
        None,
        rel(report),
        (
            f"{summary.reason}; app_source={summary.source_delta_count}; "
            f"tests={summary.test_delta_count}; schema={summary.schema_delta_count}; "
            f"artifacts={summary.artifact_delta_count}"
        ),
    )


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
    files = durable_changed_files_since(ctx.start_sha)
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
    for result in [gate("diff_check", ["git", "diff", "--check"], ctx, True), gate_allowed_paths(ctx)]:
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
    record_gate(results, gate_completion_invariant(ctx))
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
Replay of: {ctx.replay_of or 'none'}

Manifest allowed paths:
{allowed}

Rules:
- Manifest batch type controls gates.
- Do not mutate prompt files.
- Write ephemeral logs under artifacts/codex-train-v3 only.
- Do not write generated reports under build/reports.
- Preserve product law: Today / Goals / Time / You; Capture global composer; Motion behavior layer.
- Source/schema/visual batches cannot finish Green with artifact-only changes.
- Schema batches that decide no source change is required must write artifacts/{ctx.train_id}/{ctx.batch['id']}-schema-decision.md with inspected files, model inventory, schema changed yes/no, migration/defaults impact, tests, local-first/privacy boundary, and rollback.
- Final answer must name every durable changed file and explain why the batch is complete against scope.

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
    timeout_minutes = int(ctx.batch.get("codex_timeout_minutes") or os.environ.get("CODEX_TRAIN_V3_TIMEOUT_MINUTES", "35"))
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
    result = run(command, out, input_text=rendered.read_text(encoding="utf-8"), timeout_seconds=timeout_minutes * 60)
    status: Status = "green" if result.returncode == 0 else "red"
    summary = f"exit={result.returncode}; timeout={timeout_minutes}m"
    if result.returncode != 0:
        tail = tail_summary(result.stdout)
        if tail:
            summary += f"; tail={tail}"
    return GateResult("codex", status, True, command, rel(out), summary)


def write_batch_report(
    ctx: BatchContext,
    results: list[GateResult],
    status: Status,
    commit_sha: str | None,
    completion: CompletionSummary | None = None,
) -> None:
    report = ctx.run_dir / "batch-report.md"
    lines = [
        f"# {ctx.batch['id']} — {ctx.batch.get('title', '')}",
        "",
        f"Status: {status.upper()}",
        f"Train: `{ctx.train_id}`",
        f"Type: `{ctx.batch['type']}`",
        f"Start SHA: `{ctx.start_sha}`",
        f"Commit SHA: `{commit_sha or 'recorded-by-git-history' if status == 'green' else 'none'}`",
        f"Run dir: `{rel(ctx.run_dir)}`",
        f"Replay of: `{ctx.replay_of or 'none'}`",
        "",
        "## Gates",
        "",
        "| Gate | Status | Blocking | Summary | Log |",
        "|---|---|---:|---|---|",
    ]
    for result in results:
        lines.append(f"| {result.name} | {result.status} | {str(result.blocking).lower()} | {result.summary} | `{result.log_path or ''}` |")
    if completion is not None:
        lines.extend(
            [
                "",
                "## Completion invariant",
                "",
                f"- Verdict: `{completion.scope_verdict}`",
                f"- Reason: {completion.reason}",
                f"- App/UI source delta count: `{completion.source_delta_count}`",
                f"- Test delta count: `{completion.test_delta_count}`",
                f"- Schema/domain delta count: `{completion.schema_delta_count}`",
                f"- Durable artifact delta count: `{completion.artifact_delta_count}`",
                "",
                "### Changed files by kind",
                "",
            ]
        )
        for kind, paths in completion.changed_files_by_kind.items():
            lines.append(f"- `{kind}`: {len(paths)}")
            for path in paths:
                lines.append(f"  - `{path}`")
    lines.extend(["", "## Changed files", ""])
    for path in changed_files_since(ctx.start_sha):
        lines.append(f"- `{path}`")
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text("\n".join(lines) + "\n", encoding="utf-8")
    durable = ROOT / "artifacts" / ctx.train_id / f"{ctx.batch['id']}-report.md"
    durable.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(report, durable)


def write_invalid_green_report(ctx: BatchContext, completion: CompletionSummary, results: list[GateResult]) -> None:
    path = ROOT / "artifacts" / ctx.train_id / f"{ctx.batch['id']}-invalid-green.md"
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        f"# {ctx.batch['id']} invalid Green guard",
        "",
        f"Status: RED",
        f"Detected at: {now_utc()}",
        f"Start SHA: `{ctx.start_sha}`",
        f"Current SHA: `{current_sha()}`",
        f"Reason: {completion.reason}",
        "",
        "## Delta counts",
        "",
        f"- app_source: {completion.source_delta_count}",
        f"- tests: {completion.test_delta_count}",
        f"- schema: {completion.schema_delta_count}",
        f"- artifacts: {completion.artifact_delta_count}",
        "",
        "## Gate statuses",
        "",
    ]
    for result in results:
        lines.append(f"- {result.name}: {result.status} — {result.summary}")
    lines.extend(
        [
            "",
            "## Replay command",
            "",
            "```bash",
            f"python3 scripts/codex/train_v3.py --train {ctx.train_id} --start-batch {ctx.batch['id']} --end-batch {ctx.batch['id']} --mode execute --commit-strategy batch --run-xcode-build --run-tests {ctx.run_tests} --rerun-completed",
            "```",
        ]
    )
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


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


def latest_completion_summary(ctx: BatchContext) -> CompletionSummary:
    report = ctx.run_dir / "completion-invariant.json"
    if report.exists():
        data = json.loads(report.read_text(encoding="utf-8"))
        return CompletionSummary(
            status=data.get("status", "red"),
            scope_verdict=data.get("scope_verdict", "red"),
            reason=data.get("reason", "completion invariant report loaded"),
            changed_files_by_kind=data.get("changed_files_by_kind", {}),
            source_delta_count=int(data.get("source_delta_count", 0)),
            test_delta_count=int(data.get("test_delta_count", 0)),
            schema_delta_count=int(data.get("schema_delta_count", 0)),
            artifact_delta_count=int(data.get("artifact_delta_count", 0)),
            validation_evidence=list(data.get("validation_evidence", [])),
        )
    return completion_summary_for(ctx)


def run_batch(train_id: str, batch: dict, args: argparse.Namespace, truth_files: list[str]) -> Status:
    git(["pull", "--ff-only", "origin", "main"])
    ensure_clean_worktree()
    start_sha = current_sha()
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    run_dir = RUN_ROOT / train_id / batch["id"] / run_id
    run_dir.mkdir(parents=True, exist_ok=True)
    replay_of = start_sha if args.rerun_completed and batch["id"] in completed_batch_ids(train_id) else None
    ctx = BatchContext(train_id, batch, run_dir, start_sha, args.mode, args.run_xcode_build, args.run_tests, args.commit_strategy, replay_of)

    results: list[GateResult] = []
    log(f"-- pre gates for {batch['id']} --")
    results.extend(run_pre_gates(ctx, truth_files))
    if batch_status(results) == "red":
        write_batch_report(ctx, results, "red", None)
        return "red"

    log(f"-- codex for {batch['id']} --")
    record_gate(results, run_codex(ctx))
    if batch_status(results) == "red":
        write_batch_report(ctx, results, "red", None)
        return "red"

    log(f"-- post gates for {batch['id']} --")
    results.extend(run_post_gates(ctx))
    status = batch_status(results)
    completion = latest_completion_summary(ctx)
    commit_sha = None

    if status == "green":
        mark_batch_completed(ctx, status, completion)
        write_batch_report(ctx, results, status, None, completion)
        commit_sha = commit_batch(ctx)
        if commit_sha:
            log(f"committed {batch['id']}: {commit_sha}")
        else:
            log(f"no commit created for {batch['id']}")
    else:
        if completion.status == "red":
            write_invalid_green_report(ctx, completion, results)
            if args.invalidate_failed_completion:
                mark_batch_invalidated(ctx, completion.reason, completion)
        write_batch_report(ctx, results, status, None, completion)
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
    parser.add_argument("--rerun-completed", action="store_true")
    parser.add_argument("--invalidate-failed-completion", action="store_true", default=True)
    parser.add_argument("--no-invalidate-failed-completion", dest="invalidate_failed_completion", action="store_false")
    return parser.parse_args(list(argv))


def main(argv: Iterable[str] = sys.argv[1:]) -> int:
    args = parse_args(argv)
    manifest_path = Path(args.manifest) if args.manifest else ROOT / "trains" / args.train / "train.json"
    if not manifest_path.is_absolute():
        manifest_path = ROOT / manifest_path
    manifest = load_manifest(manifest_path)
    batches = selected_batches(manifest["batches"], args.start_batch, args.end_batch, args.max_batches)
    completed = completed_batch_ids(manifest["id"])
    if not args.rerun_completed:
        skipped = [batch["id"] for batch in batches if batch["id"] in completed]
        batches = [batch for batch in batches if batch["id"] not in completed]
        for batch_id in skipped:
            log(f"skipping completed batch: {batch_id}")

    log(f"Train: {manifest['id']}")
    log(f"Mode: {args.mode}")
    log(f"Selected batches: {', '.join(batch['id'] for batch in batches) if batches else 'none'}")
    if not batches:
        log("Final status: green")
        return 0

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
