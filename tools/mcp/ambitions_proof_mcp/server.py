#!/usr/bin/env python3
"""Controlled proof MCP for Ambitions.

This server intentionally exposes named validation actions only. It is not a
generic shell, network, signing, release, or git mutation interface.
"""

from __future__ import annotations

import argparse
import fcntl
import json
import os
import re
import shlex
import signal
import subprocess
import sys
import time
import uuid
from contextlib import contextmanager
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable, Iterator

JSON = dict[str, Any]
REPO_ROOT = Path(__file__).resolve().parents[3]
LOG_ROOT = REPO_ROOT / ".codex" / "logs"
PROOF_ROOT = LOG_ROOT / "proof"
MCP_LOG_ROOT = LOG_ROOT / "mcp"
XCODE_SUMMARY_ROOT = REPO_ROOT / ".codex" / "xcode-summaries"
XCODE_LOG_ROOT = REPO_ROOT / ".codex" / "xcode-logs"
XCODE_JOB_ROOT = REPO_ROOT / ".codex" / "xcode-jobs"


@dataclass(frozen=True)
class Validation:
    name: str
    description: str
    command: tuple[str, ...]
    requires: tuple[str, ...] = ()
    timeout_seconds: int = 120
    enabled_by_default: bool = True
    requires_explicit_args: bool = False
    xcode_wrapper_lane: str | None = None


VALIDATIONS: dict[str, Validation] = {
    "mcp01_self_test": Validation(
        "mcp01_self_test",
        "Run the Swift SDK-backed Ambitions Native Repo MCP self-test.",
        ("swift", "run", "--package-path", "tools/mcp/ambitions_native_mcp", "ambitions-native-mcp", "--toolset", "repo", "--self-test"),
        requires=("tools/mcp/ambitions_native_mcp/Package.swift",),
    ),
    "repo_claim_scan": Validation(
        "repo_claim_scan",
        "Run a conservative forbidden-claim scan through the read-only MCP self-test path.",
        ("python3", "tools/mcp/ambitions_proof_mcp/server.py", "--claim-scan"),
    ),
    "architecture_applicability_scan": Validation(
        "architecture_applicability_scan",
        "Run a current architecture/proof applicability smoke scan for a user-facing Swift path.",
        ("python3", "tools/mcp/ambitions_proof_mcp/server.py", "--architecture-scan"),
    ),
    "doc_link_scan_basic": Validation(
        "doc_link_scan_basic",
        "Run a local-only basic Markdown link target scan for docs.",
        ("python3", "tools/mcp/ambitions_proof_mcp/server.py", "--doc-link-scan-basic"),
    ),
    "git_status_summary": Validation(
        "git_status_summary",
        "Show porcelain git status. Read-only.",
        ("git", "status", "--short"),
    ),
    "xcodegen_check_dry_run": Validation(
        "xcodegen_check_dry_run",
        "Run xcodegen help as a non-mutating availability check.",
        ("xcodegen", "--version"),
        enabled_by_default=False,
    ),
    "build_local": Validation(
        "build_local",
        "Legacy fallback: run the existing local build script only when explicitly requested. Prefer xcode_validate_build.",
        ("./scripts/build-local.sh",),
        requires=("scripts/build-local.sh",),
        timeout_seconds=1800,
        enabled_by_default=False,
    ),
    "focused_tests": Validation(
        "focused_tests",
        "Deprecated fallback: raw focused xcodebuild tests with explicit arguments only. Prefer xcode_validate_focused_test.",
        ("xcodebuild", "test"),
        timeout_seconds=1800,
        enabled_by_default=False,
        requires_explicit_args=True,
    ),
    "xcode_validate_build": Validation(
        "xcode_validate_build",
        "Run Ambitions Xcode Build Lab build lane through the approved wrapper.",
        ("scripts/ambitions-xcode-validate.sh", "--lane", "build", "--json"),
        requires=("scripts/ambitions-xcode-validate.sh",),
        timeout_seconds=1800,
        enabled_by_default=False,
        requires_explicit_args=True,
        xcode_wrapper_lane="build",
    ),
    "xcode_validate_build_for_testing": Validation(
        "xcode_validate_build_for_testing",
        "Run Ambitions Xcode Build Lab build-for-testing lane through the approved wrapper.",
        ("scripts/ambitions-xcode-validate.sh", "--lane", "build-for-testing", "--json"),
        requires=("scripts/ambitions-xcode-validate.sh",),
        timeout_seconds=1800,
        enabled_by_default=False,
        requires_explicit_args=True,
        xcode_wrapper_lane="build-for-testing",
    ),
    "xcode_validate_focused_test": Validation(
        "xcode_validate_focused_test",
        "Run Ambitions Xcode Build Lab focused-test lane through the approved wrapper, with simulator-safe timeout.",
        ("scripts/ambitions-xcode-validate.sh", "--lane", "focused-test", "--json"),
        requires=("scripts/ambitions-xcode-validate.sh",),
        timeout_seconds=1800,
        enabled_by_default=False,
        requires_explicit_args=True,
        xcode_wrapper_lane="focused-test",
    ),
    "xcode_validate_test_plan": Validation(
        "xcode_validate_test_plan",
        "Run Ambitions Xcode Build Lab test-plan lane through the approved wrapper.",
        ("scripts/ambitions-xcode-validate.sh", "--lane", "test-plan", "--json"),
        requires=("scripts/ambitions-xcode-validate.sh",),
        timeout_seconds=1800,
        enabled_by_default=False,
        requires_explicit_args=True,
        xcode_wrapper_lane="test-plan",
    ),
}

FORBIDDEN_EXTRA_TOKENS = {
    "curl",
    "wget",
    "sudo",
    "security",
    "gh",
    "git push",
    "git merge",
    "git rebase",
    "git reset",
    "xcrun " + "altool",
    "notarytool",
    "fastlane",
    "archive",
    "-exportArchive",
    "-allowProvisioningUpdates",
    "codesign",
    "productbuild",
}

XCODE_ALLOWED_EXTRA_FLAGS = {"--batch", "--test", "--test-plan"}
BATCH_ID_RE = re.compile(r"^[A-Za-z0-9._-]{1,120}$")
XCODE_JOB_ID_RE = re.compile(r"^xcode-[0-9]{8}T[0-9]{6}Z-[a-f0-9]{8}$")
TIMEOUT_CATEGORIES = {"test_timeout", "mcp_timeout", "simulator_boot_failure", "missing_destination"}
TERMINAL_JOB_STATUSES = {"succeeded", "failed", "cancelled", "interrupted"}


@dataclass(frozen=True)
class ToolDef:
    name: str
    description: str
    input_schema: JSON
    handler: Callable[[JSON], JSON]


def _safe_repo_path(path_value: str) -> Path:
    if not path_value or "\x00" in path_value:
        raise ValueError("path is empty or invalid")
    candidate = (REPO_ROOT / path_value).resolve()
    try:
        candidate.relative_to(REPO_ROOT)
    except ValueError as exc:
        raise ValueError(f"path escapes repo root: {path_value}") from exc
    return candidate


def _timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def _command_available(name: str) -> bool:
    return any((Path(part) / name).exists() for part in os.environ.get("PATH", "").split(os.pathsep))


def _validation_status(validation: Validation) -> JSON:
    missing_paths = [path for path in validation.requires if not _safe_repo_path(path).exists()]
    command_name = validation.command[0]
    available = _command_available(command_name) or _safe_repo_path(command_name).exists()
    enabled = validation.enabled_by_default and available and not missing_paths
    return {
        "name": validation.name,
        "description": validation.description,
        "command": list(validation.command),
        "enabled": enabled,
        "enabled_by_default": validation.enabled_by_default,
        "requires_explicit_args": validation.requires_explicit_args,
        "missing_paths": missing_paths,
        "command_available": available,
        "timeout_seconds": validation.timeout_seconds,
        "xcode_wrapper_lane": validation.xcode_wrapper_lane,
    }


def _assert_command_allowed(command: list[str]) -> None:
    joined = " ".join(command)
    if any(token in joined for token in FORBIDDEN_EXTRA_TOKENS):
        raise ValueError(f"forbidden command token in validation command: {joined}")


def _parse_flag_values(args: list[str]) -> dict[str, str]:
    values: dict[str, str] = {}
    index = 0
    while index < len(args):
        flag = args[index]
        if flag not in XCODE_ALLOWED_EXTRA_FLAGS:
            raise ValueError(f"unsupported xcode wrapper argument: {flag}")
        if flag in values:
            raise ValueError(f"duplicate xcode wrapper argument: {flag}")
        if index + 1 >= len(args):
            raise ValueError(f"missing value for xcode wrapper argument: {flag}")
        value = args[index + 1]
        if value.startswith("--") or "\x00" in value:
            raise ValueError(f"invalid value for xcode wrapper argument: {flag}")
        values[flag] = value
        index += 2
    return values


def _validated_xcode_extra_args(validation: Validation, extra_args: list[str]) -> list[str]:
    values = _parse_flag_values(extra_args)
    batch_id = values.get("--batch")
    if not batch_id or not BATCH_ID_RE.match(batch_id):
        raise ValueError("xcode wrapper validations require --batch with a safe batch id")

    lane = validation.xcode_wrapper_lane
    if lane in {"build", "build-for-testing"}:
        allowed = {"--batch"}
    elif lane == "focused-test":
        allowed = {"--batch", "--test"}
    elif lane == "test-plan":
        allowed = {"--batch", "--test-plan"}
    else:
        raise ValueError(f"unsupported xcode wrapper lane: {lane}")

    unexpected = set(values) - allowed
    if unexpected:
        raise ValueError(f"unexpected argument(s) for {validation.name}: {', '.join(sorted(unexpected))}")

    return extra_args


def _batch_from_command(command: list[str]) -> str | None:
    if "--batch" not in command:
        return None
    index = command.index("--batch")
    if index + 1 >= len(command):
        return None
    return command[index + 1]


def _xctest_recovery_state(
    *,
    validation_name: str | None,
    classification: str | None,
    status: str | None,
    exit_code: int | None,
    log_tail: str | None = None,
) -> JSON:
    normalized_status = (status or "").lower()
    normalized_classification = (classification or "unknown").lower()
    tail = (log_tail or "").lower()
    proof_verified = normalized_status == "passed" and normalized_classification == "passed" and exit_code == 0
    timed_out = normalized_classification in TIMEOUT_CATEGORIES or "timed out" in tail or "timeout" in tail
    retry_validation = None
    if timed_out or normalized_classification in {"test_failure", "test_discovery_failure", "unknown"}:
        retry_validation = "xcode_validate_focused_test"
    return {
        "xctest_proof_verified": proof_verified,
        "proof_state": "verified" if proof_verified else "not_verified",
        "previous_attempt_classification": normalized_classification,
        "previous_attempt_timed_out": timed_out,
        "recommended_retry_validation": retry_validation,
        "recommended_route": "ambitionsProof.run_named_validation" if retry_validation else None,
        "preferred_xcode_path": "scripts/ambitions-xcode-validate.sh --lane focused-test --json" if retry_validation else None,
        "continuation_status": "CONTINUE" if proof_verified else "RETRY_XCODE_WRAPPER_PROOF",
        "note": "Timed-out focused XcodeBuildMCP attempts are not XCTest proof; recover through wrapper-native Ambitions Proof MCP validation." if timed_out else "Only a passing Xcode Build Lab summary verifies XCTest proof.",
    }


def _latest_xcode_summary_for_command(command: list[str]) -> JSON | None:
    batch_id = _batch_from_command(command)
    if not batch_id:
        return None
    try:
        return _latest_xcode_summary(batch_id)
    except Exception:
        return None


def _latest_xcode_summary(batch_id: str) -> JSON:
    if not BATCH_ID_RE.match(batch_id):
        raise ValueError("batch_id is invalid")
    root = XCODE_SUMMARY_ROOT / batch_id
    if not root.exists():
        return {"found": False, "batch": batch_id, "summary": None}
    summaries = sorted(root.rglob("*summary.json"), key=lambda path: path.stat().st_mtime, reverse=True)
    if not summaries:
        return {"found": False, "batch": batch_id, "summary": None}
    latest = summaries[0]
    data = json.loads(latest.read_text(encoding="utf-8"))
    return {
        "found": True,
        "batch": batch_id,
        "path": str(latest.relative_to(REPO_ROOT)),
        "modified_unix": int(latest.stat().st_mtime),
        "summary": data,
    }


def _latest_xcode_log(batch_id: str) -> JSON | None:
    if not BATCH_ID_RE.match(batch_id):
        raise ValueError("batch_id is invalid")
    root = XCODE_LOG_ROOT / batch_id
    if not root.exists():
        return None
    logs = sorted(root.rglob("*.log"), key=lambda path: path.stat().st_mtime, reverse=True)
    if not logs:
        return None
    latest = logs[0]
    text = latest.read_text(encoding="utf-8", errors="replace")
    return {
        "path": str(latest.relative_to(REPO_ROOT)),
        "modified_unix": int(latest.stat().st_mtime),
        "bytes": latest.stat().st_size,
        "tail": text[-4000:],
    }


def _run(validation: Validation, extra_args: list[str] | None = None) -> JSON:
    extra_args = extra_args or []
    if validation.requires_explicit_args and not extra_args:
        raise ValueError(f"{validation.name} requires explicit target/test arguments")
    status = _validation_status(validation)
    if status["missing_paths"]:
        raise FileNotFoundError(f"missing required paths: {', '.join(status['missing_paths'])}")
    if validation.xcode_wrapper_lane:
        extra_args = _validated_xcode_extra_args(validation, extra_args)
    command = list(validation.command) + extra_args
    _assert_command_allowed(command)
    PROOF_ROOT.mkdir(parents=True, exist_ok=True)
    log_path = PROOF_ROOT / f"{_timestamp()}-{validation.name}.log"
    try:
        proc = subprocess.run(
            command,
            cwd=REPO_ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=validation.timeout_seconds,
            check=False,
        )
        output = proc.stdout
        exit_code = proc.returncode
        classification = "passed" if exit_code == 0 else "unknown"
    except subprocess.TimeoutExpired as exc:
        raw_output = exc.output or ""
        if isinstance(raw_output, bytes):
            raw_output = raw_output.decode("utf-8", errors="replace")
        output = raw_output + f"\nMCP validation timed out after {validation.timeout_seconds} seconds.\n"
        exit_code = 124
        classification = "mcp_timeout"
    log_path.write_text(output, encoding="utf-8")
    passed = exit_code == 0
    recovery = _xctest_recovery_state(
        validation_name=validation.name,
        classification=classification,
        status="passed" if passed else "failed",
        exit_code=exit_code,
        log_tail=output[-4000:],
    )
    return {
        "validation": validation.name,
        "command": command,
        "exit_code": exit_code,
        "passed": passed,
        "failure_category": classification,
        "timeout_seconds": validation.timeout_seconds,
        "log_path": str(log_path.relative_to(REPO_ROOT)),
        "output_tail": output[-4000:],
        "xcode_summary": _latest_xcode_summary_for_command(command),
        "xctest_recovery": recovery,
        "non_claims": [
            "not release proof",
            "not device proof",
            "not public accessibility proof",
            "not legal/privacy signoff",
        ],
    }


def tool_list_available_validations(_: JSON) -> JSON:
    return {
        "validations": [_validation_status(item) for item in VALIDATIONS.values()],
        "hard_boundaries": [
            "no arbitrary shell",
            "no network commands",
            "no secrets commands",
            "no destructive commands",
            "no signing or App Store upload",
            "no git push/merge/rebase/reset",
            "wrapper-native Xcode validations use 1800-second timeout for simulator lanes",
            "timed-out focused XcodeBuildMCP attempts do not verify XCTest proof",
        ],
    }


def tool_run_named_validation(args: JSON) -> JSON:
    name = args.get("name")
    extra_args = args.get("args") or []
    if not isinstance(name, str) or name not in VALIDATIONS:
        raise ValueError("unknown validation name")
    if not isinstance(extra_args, list) or not all(isinstance(item, str) for item in extra_args):
        raise ValueError("args must be a list of strings")
    return _run(VALIDATIONS[name], extra_args)


def tool_collect_latest_logs(args: JSON) -> JSON:
    limit = int(args.get("limit", 10))
    roots = [PROOF_ROOT, MCP_LOG_ROOT, REPO_ROOT / "output" / "logs", XCODE_LOG_ROOT, XCODE_SUMMARY_ROOT, XCODE_JOB_ROOT]
    logs: list[Path] = []
    for root in roots:
        if root.exists():
            logs.extend(path for path in root.rglob("*") if path.is_file())
    logs.sort(key=lambda path: path.stat().st_mtime, reverse=True)
    return {
        "logs": [
            {
                "path": str(path.relative_to(REPO_ROOT)),
                "bytes": path.stat().st_size,
                "modified_unix": int(path.stat().st_mtime),
            }
            for path in logs[:limit]
        ]
    }


def tool_generate_proof_packet(args: JSON) -> JSON:
    title = str(args.get("title") or "Ambitions Local Proof Packet")
    validations = args.get("validations") or []
    if not isinstance(validations, list) or not all(isinstance(item, str) for item in validations):
        raise ValueError("validations must be a list of validation names")
    PROOF_ROOT.mkdir(parents=True, exist_ok=True)
    packet_path = PROOF_ROOT / f"{_timestamp()}-proof-packet.md"
    latest = tool_collect_latest_logs({"limit": 20})["logs"]
    packet = [
        f"# {title}",
        "",
        f"Generated: {_timestamp()}",
        "",
        "## Validation Names",
        "",
        *(f"- {item}" for item in validations),
        "",
        "## Latest Logs",
        "",
        *(f"- `{item['path']}` ({item['bytes']} bytes)" for item in latest),
        "",
        "## Non-Claims",
        "",
        "- This packet is local engineering evidence only.",
        "- It is not release readiness, App Store readiness, TestFlight readiness, physical-device proof, public accessibility proof, or legal/privacy signoff.",
    ]
    packet_path.write_text("\n".join(packet) + "\n", encoding="utf-8")
    return {"packet_path": str(packet_path.relative_to(REPO_ROOT)), "included_log_count": len(latest)}


def tool_check_validation_policy(args: JSON) -> JSON:
    name = args.get("name")
    if name is not None and name not in VALIDATIONS:
        return {"allowed": False, "reason": "unknown validation name"}
    return {
        "allowed": True,
        "allowed_names": sorted(VALIDATIONS),
        "preferred_xcode_validations": [
            "xcode_validate_build",
            "xcode_validate_build_for_testing",
            "xcode_validate_focused_test",
            "xcode_validate_test_plan",
        ],
        "deprecated_xcode_validations": ["build_local", "focused_tests"],
        "xctest_timeout_policy": "A focused XcodeBuildMCP timeout is not verified XCTest proof; retry via xcode_validate_focused_test through ambitionsProof.run_named_validation.",
        "forbidden": [
            "arbitrary command",
            "network command",
            "secrets command",
            "destructive command",
            "signing command",
            "App Store upload",
            "hosted CI creation",
            "git push/merge/rebase/reset",
        ],
    }


def tool_xcode_latest_summary(args: JSON) -> JSON:
    batch_id = args.get("batch_id")
    if not isinstance(batch_id, str):
        raise ValueError("batch_id is required")
    return _latest_xcode_summary(batch_id)


def tool_xcode_failure_classification(args: JSON) -> JSON:
    batch_id = args.get("batch_id")
    if not isinstance(batch_id, str):
        raise ValueError("batch_id is required")
    summary = _latest_xcode_summary(batch_id)
    classification = None
    status = None
    exit_code = None
    if summary.get("found") and isinstance(summary.get("summary"), dict):
        data = summary["summary"]
        classification = data.get("failure_category")
        status = data.get("status")
        exit_code = data.get("exit_code")
    latest_log = _latest_xcode_log(batch_id)
    tail = latest_log.get("tail") if isinstance(latest_log, dict) else None
    recovery = _xctest_recovery_state(
        validation_name="xcode_failure_classification",
        classification=classification,
        status=status,
        exit_code=exit_code,
        log_tail=tail,
    )
    return {
        "batch": batch_id,
        "summary": summary,
        "status": status,
        "exit_code": exit_code,
        "failure_category": classification,
        "latest_log": latest_log,
        "xctest_recovery": recovery,
        "non_claims": [
            "classification is local engineering evidence only",
            "not release proof",
            "not device proof",
            "not public accessibility proof",
        ],
    }


def tool_xctest_recovery_plan(args: JSON) -> JSON:
    batch_id = args.get("batch_id")
    test_id = args.get("test_id")
    previous_failure_category = args.get("previous_failure_category") or "test_timeout"
    previous_note = args.get("previous_note") or "focused XcodeBuildMCP attempt timed out"
    if not isinstance(batch_id, str) or not BATCH_ID_RE.match(batch_id):
        raise ValueError("batch_id is required and must be safe")
    if test_id is not None and not isinstance(test_id, str):
        raise ValueError("test_id must be a string when provided")
    args_list = ["--batch", batch_id]
    if test_id:
        args_list.extend(["--test", test_id])
    return {
        "batch": batch_id,
        "previous_attempt": {
            "source": "XcodeBuildMCP",
            "failure_category": previous_failure_category,
            "note": previous_note,
            "xctest_proof_verified": False,
        },
        "next_validation": {
            "tool": "ambitionsProof.run_named_validation",
            "name": "xcode_validate_focused_test",
            "args": args_list,
        },
        "acceptance_gate": "Only a passing xcode_latest_summary for this batch verifies XCTest proof.",
        "continuation_after_retry": "Call ambitionsProof.xcode_latest_summary, then ambitionsProof.xcode_failure_classification, then ambitionsRepo.repo_changed_file_impact and ambitionsRepo.repo_claim_scan for current routing/claim boundaries.",
    }


def _iso_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _job_dir(job_id: str) -> Path:
    if not isinstance(job_id, str) or not XCODE_JOB_ID_RE.fullmatch(job_id):
        raise ValueError("job_id is invalid")
    root = XCODE_JOB_ROOT.resolve()
    candidate = (root / job_id).resolve()
    if candidate.parent != root:
        raise ValueError("job_id escapes the Xcode job root")
    return candidate


@contextmanager
def _job_lock(job_dir: Path) -> Iterator[None]:
    job_dir.mkdir(parents=True, exist_ok=True)
    lock_path = job_dir / "job.lock"
    with lock_path.open("a+", encoding="utf-8") as lock_file:
        fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX)
        try:
            yield
        finally:
            fcntl.flock(lock_file.fileno(), fcntl.LOCK_UN)


def _atomic_write_json(path: Path, payload: JSON) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp_path = path.with_name(f".{path.name}.{os.getpid()}.{uuid.uuid4().hex}.tmp")
    try:
        with temp_path.open("w", encoding="utf-8") as stream:
            json.dump(payload, stream, indent=2, sort_keys=True)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temp_path, path)
        directory_fd = os.open(path.parent, os.O_RDONLY)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
    finally:
        temp_path.unlink(missing_ok=True)


def _read_json_object(path: Path) -> JSON:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"invalid persisted Xcode job record: {path}") from exc
    if not isinstance(payload, dict):
        raise RuntimeError(f"persisted Xcode job record is not an object: {path}")
    return payload


def _load_job_state(job_id: str) -> JSON:
    state_path = _job_dir(job_id) / "job.json"
    try:
        state = _read_json_object(state_path)
    except FileNotFoundError as exc:
        raise ValueError(f"unknown Xcode job: {job_id}") from exc
    if state.get("job_id") != job_id:
        raise RuntimeError(f"persisted Xcode job id mismatch: {job_id}")
    return state


def _git_output(*args: str) -> str:
    proc = subprocess.run(
        ["git", *args],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        timeout=10,
        check=False,
    )
    return proc.stdout.rstrip() if proc.returncode == 0 else ""


def _git_context() -> JSON:
    return {
        "branch": _git_output("branch", "--show-current") or "(detached)",
        "sha": _git_output("rev-parse", "HEAD"),
        "status": _git_output("status", "--short"),
    }


def _prepare_xcode_job_request(validation_name: str, extra_args: list[str]) -> tuple[Validation, list[str], str]:
    validation = VALIDATIONS.get(validation_name)
    if validation is None or validation.xcode_wrapper_lane is None:
        raise ValueError("resumable jobs accept allowlisted Xcode Build Lab validations only")
    if validation.requires_explicit_args and not extra_args:
        raise ValueError(f"{validation.name} requires explicit target/test arguments")
    status = _validation_status(validation)
    if status["missing_paths"]:
        raise FileNotFoundError(f"missing required paths: {', '.join(status['missing_paths'])}")
    validated_args = _validated_xcode_extra_args(validation, extra_args)
    command = list(validation.command) + validated_args
    _assert_command_allowed(command)
    batch_id = _batch_from_command(command)
    if batch_id is None:
        raise ValueError("Xcode Build Lab jobs require a batch id")
    return validation, command, batch_id


def _spawn_xcode_job_worker(job_id: str) -> int:
    job_dir = _job_dir(job_id)
    worker_log_path = job_dir / "worker.log"
    with worker_log_path.open("a", encoding="utf-8") as worker_log:
        proc = subprocess.Popen(
            [sys.executable, str(Path(__file__).resolve()), "--run-xcode-job", job_id],
            cwd=REPO_ROOT,
            stdin=subprocess.DEVNULL,
            stdout=worker_log,
            stderr=subprocess.STDOUT,
            start_new_session=True,
            close_fds=True,
        )
    return proc.pid


def _job_process_matches(pid: int, job_id: str) -> bool:
    if pid <= 0:
        return False
    try:
        os.kill(pid, 0)
    except (ProcessLookupError, PermissionError):
        return False
    proc = subprocess.run(
        ["ps", "-p", str(pid), "-o", "stat=", "-o", "command="],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        timeout=5,
        check=False,
    )
    if proc.returncode != 0 or not proc.stdout.strip():
        return False
    status, _, command_text = proc.stdout.strip().partition(" ")
    if "Z" in status or not command_text:
        return False
    try:
        command = shlex.split(command_text)
    except ValueError:
        return False
    try:
        flag_index = command.index("--run-xcode-job")
    except ValueError:
        return False
    return flag_index + 1 < len(command) and command[flag_index + 1] == job_id


def _owned_descendant_pids(root_pid: int) -> list[int]:
    proc = subprocess.run(
        ["ps", "-axo", "pid=,ppid="],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        timeout=5,
        check=False,
    )
    if proc.returncode != 0:
        return []
    children: dict[int, list[int]] = {}
    for line in proc.stdout.splitlines():
        parts = line.split()
        if len(parts) != 2:
            continue
        pid, parent_pid = map(int, parts)
        children.setdefault(parent_pid, []).append(pid)
    descendants: list[int] = []
    pending = list(children.get(root_pid, []))
    while pending:
        pid = pending.pop()
        descendants.append(pid)
        pending.extend(children.get(pid, []))
    return descendants


def _terminate_job_processes(worker_pgid: int, descendants: list[int]) -> None:
    for pid in reversed(descendants):
        try:
            os.kill(pid, signal.SIGTERM)
        except (ProcessLookupError, PermissionError):
            pass
    os.killpg(worker_pgid, signal.SIGTERM)
    deadline = time.monotonic() + 0.5
    while time.monotonic() < deadline:
        if not any(_pid_exists(pid) for pid in descendants):
            return
        time.sleep(0.02)
    for pid in reversed(descendants):
        try:
            os.kill(pid, signal.SIGKILL)
        except (ProcessLookupError, PermissionError):
            pass


def _pid_exists(pid: int) -> bool:
    try:
        os.kill(pid, 0)
        return True
    except (ProcessLookupError, PermissionError):
        return False


def _job_output_tail(job_id: str, limit: int = 4000) -> str:
    log_path = _job_dir(job_id) / "job.log"
    if not log_path.exists():
        return ""
    return log_path.read_text(encoding="utf-8", errors="replace")[-limit:]


def _terminal_result_for_lost_worker(state: JSON, status: str, failure_category: str) -> JSON:
    job_id = str(state["job_id"])
    batch_id = str(state.get("batch_id") or "")
    return {
        "job_id": job_id,
        "status": status,
        "validation": state.get("validation"),
        "batch_id": batch_id,
        "command": state.get("command") or [],
        "exit_code": None,
        "passed": False,
        "failure_category": failure_category,
        "source": {"start": state.get("source") or {}, "end": _git_context()},
        "finished_at": _iso_now(),
        "log_path": str(_job_dir(job_id) / "job.log"),
        "output_tail": _job_output_tail(job_id),
        "xcode_summary": _latest_xcode_summary(batch_id) if BATCH_ID_RE.fullmatch(batch_id) else None,
        "non_claims": [
            "not release proof",
            "not device proof",
            "not public accessibility proof",
            "not legal/privacy signoff",
        ],
    }


def _reconcile_job_state(job_id: str) -> JSON:
    job_dir = _job_dir(job_id)
    state = _load_job_state(job_id)
    result_path = job_dir / "result.json"
    if result_path.exists():
        result = _read_json_object(result_path)
        result_status = result.get("status")
        if result_status not in TERMINAL_JOB_STATUSES:
            raise RuntimeError(f"persisted Xcode job result is not terminal: {job_id}")
        if state.get("status") != result_status:
            with _job_lock(job_dir):
                state = _load_job_state(job_id)
                if state.get("status") != result_status:
                    state["status"] = result_status
                    state["finished_at"] = result.get("finished_at") or _iso_now()
                    state["command_pid"] = None
                    _atomic_write_json(job_dir / "job.json", state)
        return state
    if state.get("status") in TERMINAL_JOB_STATUSES:
        with _job_lock(job_dir):
            state = _load_job_state(job_id)
            if result_path.exists():
                result = _read_json_object(result_path)
                result_status = result.get("status")
                if result_status not in TERMINAL_JOB_STATUSES:
                    raise RuntimeError(f"persisted Xcode job result is not terminal: {job_id}")
                state["status"] = result_status
                state["finished_at"] = result.get("finished_at") or _iso_now()
                state["command_pid"] = None
                _atomic_write_json(job_dir / "job.json", state)
                return state
            result = _terminal_result_for_lost_worker(state, "interrupted", "terminal_result_missing")
            _atomic_write_json(result_path, result)
            state["status"] = "interrupted"
            state["finished_at"] = result["finished_at"]
            state["command_pid"] = None
            _atomic_write_json(job_dir / "job.json", state)
        return state

    worker_pid = int(state.get("worker_pid") or 0)
    if _job_process_matches(worker_pid, job_id):
        return state

    terminal_status = "cancelled" if state.get("status") == "cancelling" or state.get("cancel_requested_at") else "interrupted"
    failure_category = "cancelled" if terminal_status == "cancelled" else "worker_interrupted"
    with _job_lock(job_dir):
        state = _load_job_state(job_id)
        if state.get("status") in TERMINAL_JOB_STATUSES:
            return state
        if result_path.exists():
            result = _read_json_object(result_path)
            result_status = result.get("status")
            if result_status not in TERMINAL_JOB_STATUSES:
                raise RuntimeError(f"persisted Xcode job result is not terminal: {job_id}")
            state["status"] = result_status
            state["finished_at"] = result.get("finished_at") or _iso_now()
            state["command_pid"] = None
            _atomic_write_json(job_dir / "job.json", state)
            return state
        result = _terminal_result_for_lost_worker(state, terminal_status, failure_category)
        _atomic_write_json(result_path, result)
        state["status"] = terminal_status
        state["finished_at"] = result["finished_at"]
        state["command_pid"] = None
        _atomic_write_json(job_dir / "job.json", state)
    return state


def _public_job_status(state: JSON) -> JSON:
    job_id = str(state["job_id"])
    status = str(state.get("status") or "unknown")
    worker_pid = int(state.get("worker_pid") or 0)
    active = status not in TERMINAL_JOB_STATUSES and _job_process_matches(worker_pid, job_id)
    return {
        "job_id": job_id,
        "status": status,
        "terminal": status in TERMINAL_JOB_STATUSES,
        "active": active,
        "resumable": True,
        "validation": state.get("validation"),
        "batch_id": state.get("batch_id"),
        "source": state.get("source") or {},
        "created_at": state.get("created_at"),
        "started_at": state.get("started_at"),
        "finished_at": state.get("finished_at"),
        "cancel_requested_at": state.get("cancel_requested_at"),
        "worker_pid": worker_pid,
        "command_pid": state.get("command_pid"),
        "log_path": str(_job_dir(job_id) / "job.log"),
        "result_path": str(_job_dir(job_id) / "result.json"),
        "output_tail": _job_output_tail(job_id),
    }


def tool_xcode_job_submit(args: JSON) -> JSON:
    validation_name = args.get("validation")
    extra_args = args.get("args") or []
    if not isinstance(validation_name, str):
        raise ValueError("validation is required")
    if not isinstance(extra_args, list) or not all(isinstance(item, str) for item in extra_args):
        raise ValueError("args must be a list of strings")
    _, command, batch_id = _prepare_xcode_job_request(validation_name, extra_args)
    source = _git_context()
    XCODE_JOB_ROOT.mkdir(parents=True, exist_ok=True)

    while True:
        job_id = f"xcode-{_timestamp()}-{uuid.uuid4().hex[:8]}"
        job_dir = _job_dir(job_id)
        try:
            job_dir.mkdir(mode=0o700)
            break
        except FileExistsError:
            continue

    state: JSON = {
        "schema_version": 1,
        "job_id": job_id,
        "status": "queued",
        "validation": validation_name,
        "batch_id": batch_id,
        "args": extra_args,
        "command": command,
        "source": source,
        "created_at": _iso_now(),
        "started_at": None,
        "finished_at": None,
        "worker_pid": 0,
        "worker_pgid": 0,
        "command_pid": None,
        "log_path": str(job_dir / "job.log"),
        "result_path": str(job_dir / "result.json"),
        "cancel_requested_at": None,
    }
    with _job_lock(job_dir):
        _atomic_write_json(job_dir / "job.json", state)
        try:
            worker_pid = _spawn_xcode_job_worker(job_id)
        except Exception as exc:
            state["status"] = "failed"
            state["finished_at"] = _iso_now()
            result = _terminal_result_for_lost_worker(state, "failed", "worker_launch_failed")
            result["error"] = str(exc)
            _atomic_write_json(job_dir / "result.json", result)
            _atomic_write_json(job_dir / "job.json", state)
            return _public_job_status(state)
        state["worker_pid"] = worker_pid
        state["worker_pgid"] = worker_pid
        _atomic_write_json(job_dir / "job.json", state)
    return _public_job_status(state)


def tool_xcode_job_status(args: JSON) -> JSON:
    job_id = args.get("job_id")
    if not isinstance(job_id, str):
        raise ValueError("job_id is required")
    return _public_job_status(_reconcile_job_state(job_id))


def tool_xcode_job_result(args: JSON) -> JSON:
    status = tool_xcode_job_status(args)
    if not status["terminal"]:
        return {"ready": False, "job": status}
    result_path = _job_dir(str(status["job_id"])) / "result.json"
    result = _read_json_object(result_path) if result_path.exists() else None
    return {"ready": True, "job": status, "result": result}


def tool_xcode_job_cancel(args: JSON) -> JSON:
    job_id = args.get("job_id")
    if not isinstance(job_id, str):
        raise ValueError("job_id is required")
    state = _reconcile_job_state(job_id)
    if state.get("status") in TERMINAL_JOB_STATUSES:
        return {"cancellation_requested": False, "job": _public_job_status(state)}
    worker_pid = int(state.get("worker_pid") or 0)
    worker_pgid = int(state.get("worker_pgid") or 0)
    if worker_pgid <= 0 or not _job_process_matches(worker_pid, job_id):
        state = _reconcile_job_state(job_id)
        return {"cancellation_requested": False, "job": _public_job_status(state)}
    try:
        actual_pgid = os.getpgid(worker_pid)
    except ProcessLookupError:
        state = _reconcile_job_state(job_id)
        return {"cancellation_requested": False, "job": _public_job_status(state)}
    if actual_pgid != worker_pgid:
        raise RuntimeError(f"Xcode job process-group ownership changed: {job_id}")
    descendants = _owned_descendant_pids(worker_pid)

    job_dir = _job_dir(job_id)
    with _job_lock(job_dir):
        state = _load_job_state(job_id)
        if state.get("status") in TERMINAL_JOB_STATUSES:
            return {"cancellation_requested": False, "job": _public_job_status(state)}
        state["status"] = "cancelling"
        state["cancel_requested_at"] = state.get("cancel_requested_at") or _iso_now()
        _atomic_write_json(job_dir / "job.json", state)
    try:
        _terminate_job_processes(worker_pgid, descendants)
    except ProcessLookupError:
        state = _reconcile_job_state(job_id)
        return {"cancellation_requested": False, "job": _public_job_status(state)}
    return {"cancellation_requested": True, "job": _public_job_status(state)}


def _worker_failure_result(job_id: str, state: JSON, exc: Exception) -> JSON:
    job_dir = _job_dir(job_id)
    try:
        with (job_dir / "job.log").open("a", encoding="utf-8") as log:
            log.write(f"\nXcode job worker failed: {exc}\n")
    except OSError:
        pass
    return {
        "job_id": job_id,
        "status": "failed",
        "validation": state.get("validation"),
        "batch_id": state.get("batch_id"),
        "command": state.get("command") or [],
        "exit_code": None,
        "passed": False,
        "failure_category": "worker_failure",
        "error": str(exc),
        "source": {"start": state.get("source") or {}, "end": _git_context()},
        "finished_at": _iso_now(),
        "log_path": str(job_dir / "job.log"),
        "output_tail": _job_output_tail(job_id),
        "xcode_summary": None,
        "non_claims": [
            "not release proof",
            "not device proof",
            "not public accessibility proof",
            "not legal/privacy signoff",
        ],
    }


def _run_xcode_job(job_id: str) -> int:
    job_dir = _job_dir(job_id)
    state = _load_job_state(job_id)
    old_signal_handlers: dict[int, Any] = {}
    cancellation_signal = False

    def request_cancellation(_: int, __: Any) -> None:
        nonlocal cancellation_signal
        cancellation_signal = True

    try:
        validation_name = state.get("validation")
        extra_args = state.get("args") or []
        if not isinstance(validation_name, str) or not isinstance(extra_args, list) or not all(isinstance(item, str) for item in extra_args):
            raise ValueError("persisted Xcode job request is invalid")
        validation, command, batch_id = _prepare_xcode_job_request(validation_name, extra_args)
        source_start = state.get("source") if isinstance(state.get("source"), dict) else _git_context()

        for signum in (signal.SIGTERM, signal.SIGINT):
            try:
                old_signal_handlers[signum] = signal.getsignal(signum)
                signal.signal(signum, request_cancellation)
            except ValueError:
                old_signal_handlers.clear()
                break

        with _job_lock(job_dir):
            state = _load_job_state(job_id)
            state["status"] = "running"
            state["started_at"] = state.get("started_at") or _iso_now()
            state["worker_pid"] = os.getpid()
            state["worker_pgid"] = os.getpgrp()
            state["command"] = command
            _atomic_write_json(job_dir / "job.json", state)

        timed_out = False
        termination_sent = False
        termination_started_at: float | None = None
        deadline = time.monotonic() + validation.timeout_seconds
        with (job_dir / "job.log").open("a", encoding="utf-8") as log:
            proc = subprocess.Popen(
                command,
                cwd=REPO_ROOT,
                text=True,
                stdout=log,
                stderr=subprocess.STDOUT,
                close_fds=True,
            )
            with _job_lock(job_dir):
                state = _load_job_state(job_id)
                state["command_pid"] = proc.pid
                _atomic_write_json(job_dir / "job.json", state)

            while proc.poll() is None:
                if cancellation_signal and not termination_sent:
                    proc.terminate()
                    termination_sent = True
                    termination_started_at = time.monotonic()
                if time.monotonic() >= deadline and not termination_sent:
                    timed_out = True
                    proc.terminate()
                    termination_sent = True
                    termination_started_at = time.monotonic()
                if termination_started_at is not None and time.monotonic() - termination_started_at >= 30:
                    proc.kill()
                    termination_started_at = None
                try:
                    proc.wait(timeout=0.25)
                except subprocess.TimeoutExpired:
                    continue
            exit_code = proc.returncode

        with _job_lock(job_dir):
            state = _load_job_state(job_id)
        cancellation_requested = cancellation_signal or bool(state.get("cancel_requested_at")) or state.get("status") == "cancelling"
        source_end = _git_context()
        source_changed = bool(source_start.get("sha")) and source_start.get("sha") != source_end.get("sha")
        try:
            xcode_summary = _latest_xcode_summary(batch_id)
        except Exception:
            xcode_summary = None
        summary_payload = xcode_summary.get("summary") if isinstance(xcode_summary, dict) else None
        summary_category = summary_payload.get("failure_category") if isinstance(summary_payload, dict) else None

        if timed_out:
            final_status = "failed"
            failure_category = "mcp_timeout"
        elif cancellation_requested:
            final_status = "cancelled"
            failure_category = "cancelled"
        elif source_changed:
            final_status = "failed"
            failure_category = "source_changed_during_job"
        elif exit_code == 0:
            final_status = "succeeded"
            failure_category = "passed"
        else:
            final_status = "failed"
            failure_category = summary_category if isinstance(summary_category, str) else "unknown"
        passed = final_status == "succeeded"
        finished_at = _iso_now()
        output_tail = _job_output_tail(job_id)
        result: JSON = {
            "job_id": job_id,
            "status": final_status,
            "validation": validation_name,
            "batch_id": batch_id,
            "command": command,
            "exit_code": exit_code,
            "passed": passed,
            "failure_category": failure_category,
            "timeout_seconds": validation.timeout_seconds,
            "source": {"start": source_start, "end": source_end},
            "finished_at": finished_at,
            "log_path": str(job_dir / "job.log"),
            "output_tail": output_tail,
            "xcode_summary": xcode_summary,
            "xctest_recovery": _xctest_recovery_state(
                validation_name=validation_name,
                classification=failure_category,
                status="passed" if passed else "failed",
                exit_code=exit_code,
                log_tail=output_tail,
            ),
            "non_claims": [
                "not release proof",
                "not device proof",
                "not public accessibility proof",
                "not legal/privacy signoff",
            ],
        }
        with _job_lock(job_dir):
            state = _load_job_state(job_id)
            _atomic_write_json(job_dir / "result.json", result)
            state["status"] = final_status
            state["finished_at"] = finished_at
            state["command_pid"] = None
            _atomic_write_json(job_dir / "job.json", state)
        return 0 if passed else 1
    except Exception as exc:
        result = _worker_failure_result(job_id, state, exc)
        with _job_lock(job_dir):
            state = _load_job_state(job_id)
            _atomic_write_json(job_dir / "result.json", result)
            state["status"] = "failed"
            state["finished_at"] = result["finished_at"]
            state["command_pid"] = None
            _atomic_write_json(job_dir / "job.json", state)
        return 1
    finally:
        for signum, handler in old_signal_handlers.items():
            signal.signal(signum, handler)


TOOLS: dict[str, ToolDef] = {}


def _register(tool: ToolDef) -> None:
    TOOLS[tool.name] = tool


def _tool_schema(properties: JSON | None = None, required: list[str] | None = None) -> JSON:
    return {"type": "object", "properties": properties or {}, "required": required or [], "additionalProperties": False}


_register(ToolDef("list_available_validations", "List allowlisted local validations.", _tool_schema(), tool_list_available_validations))
_register(ToolDef("run_named_validation", "Run one allowlisted validation by name.", _tool_schema({"name": {"type": "string"}, "args": {"type": "array", "items": {"type": "string"}}}, ["name"]), tool_run_named_validation))
_register(ToolDef("collect_latest_logs", "Collect latest local proof and Xcode logs/summaries.", _tool_schema({"limit": {"type": "integer"}}), tool_collect_latest_logs))
_register(ToolDef("generate_proof_packet", "Generate a local proof packet from latest logs.", _tool_schema({"title": {"type": "string"}, "validations": {"type": "array", "items": {"type": "string"}}}), tool_generate_proof_packet))
_register(ToolDef("check_validation_policy", "Return validation policy and forbidden actions.", _tool_schema({"name": {"type": "string"}}), tool_check_validation_policy))
_register(ToolDef("xcode_latest_summary", "Return the latest Xcode Build Lab validate-summary.json for a batch.", _tool_schema({"batch_id": {"type": "string"}}, ["batch_id"]), tool_xcode_latest_summary))
_register(ToolDef("xcode_failure_classification", "Return latest Xcode Build Lab failure category, proof verification state, and log tail for a batch.", _tool_schema({"batch_id": {"type": "string"}}, ["batch_id"]), tool_xcode_failure_classification))
_register(ToolDef("xctest_recovery_plan", "Return the wrapper-native recovery plan after an unverified or timed-out focused XCTest attempt.", _tool_schema({"batch_id": {"type": "string"}, "test_id": {"type": "string"}, "previous_failure_category": {"type": "string"}, "previous_note": {"type": "string"}}, ["batch_id"]), tool_xctest_recovery_plan))
_register(ToolDef("xcode_job_submit", "Submit an allowlisted Xcode Build Lab validation as a durable background job.", _tool_schema({"validation": {"type": "string"}, "args": {"type": "array", "items": {"type": "string"}}}, ["validation"]), tool_xcode_job_submit))
_register(ToolDef("xcode_job_status", "Return durable status and the current log tail for an Xcode job.", _tool_schema({"job_id": {"type": "string"}}, ["job_id"]), tool_xcode_job_status))
_register(ToolDef("xcode_job_result", "Return the final result for a completed Xcode job, or a pending state.", _tool_schema({"job_id": {"type": "string"}}, ["job_id"]), tool_xcode_job_result))
_register(ToolDef("xcode_job_cancel", "Request cancellation of a running Xcode job and its owned process group.", _tool_schema({"job_id": {"type": "string"}}, ["job_id"]), tool_xcode_job_cancel))


def _mcp_tools_list() -> JSON:
    return {"tools": [{"name": tool.name, "description": tool.description, "inputSchema": tool.input_schema} for tool in TOOLS.values()]}


def _mcp_tool_call(params: JSON) -> JSON:
    name = params.get("name")
    args = params.get("arguments") or {}
    if not isinstance(name, str) or name not in TOOLS:
        raise ValueError(f"unknown tool: {name}")
    if not isinstance(args, dict):
        raise ValueError("tool arguments must be an object")
    result = TOOLS[name].handler(args)
    return {"content": [{"type": "text", "text": json.dumps(result, indent=2, sort_keys=True)}], "isError": False}


def _response(request_id: Any, result: JSON | None = None, error: JSON | None = None) -> JSON:
    payload: JSON = {"jsonrpc": "2.0", "id": request_id}
    if error is not None:
        payload["error"] = error
    else:
        payload["result"] = result or {}
    return payload


def _error(code: int, message: str) -> JSON:
    return {"code": code, "message": message}


def _handle(message: JSON) -> JSON | None:
    request_id = message.get("id")
    method = message.get("method")
    params = message.get("params") or {}
    is_notification = "id" not in message
    try:
        if method == "initialize":
            return None if is_notification else _response(request_id, {"protocolVersion": "2025-03-26", "capabilities": {"tools": {}}, "serverInfo": {"name": "ambitions_proof_mcp", "version": "0.4.0"}})
        if method == "notifications/initialized":
            return None
        if method == "tools/list":
            return None if is_notification else _response(request_id, _mcp_tools_list())
        if method == "tools/call":
            return None if is_notification else _response(request_id, _mcp_tool_call(params))
        return None if is_notification else _response(request_id, error=_error(-32601, f"method not found: {method}"))
    except Exception as exc:
        return None if is_notification else _response(request_id, error=_error(-32000, str(exc)))


def run_stdio() -> int:
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            response = _handle(json.loads(line))
            if response is not None:
                print(json.dumps(response, separators=(",", ":")), flush=True)
        except Exception as exc:
            print(json.dumps(_response(None, error=_error(-32700, str(exc)))), flush=True)
    return 0


def _claim_scan() -> int:
    risky = ["README.md", "docs/README.md", "AGENTS.md"]
    result = {"paths": risky, "note": "basic MCP02 claim-scan placeholder; use ambitionsRepo.repo_claim_scan for targeted scans"}
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


def _architecture_scan() -> int:
    result = {
        "changed_files": ["Native/Ambitions/Features/Today/TodayView.swift"],
        "owner": "legacy Features compatibility",
        "architecture_debt": True,
        "required_proof": ["architecture_owner_report", "focused_test_or_build", "visual_applicability", "accessibility_applicability", "release_claim_boundary"],
        "required_route": "Move touched implementation toward the Final Architecture Tree owner or close Yellow with explicit architecture debt and a named repair train.",
    }
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


def _doc_link_scan_basic() -> int:
    missing: list[str] = []
    for path in (REPO_ROOT / "docs").rglob("*.md"):
        text = path.read_text(encoding="utf-8", errors="replace")
        for target in [part.split(")", 1)[0] for part in text.split("](")[1:]]:
            if target.startswith(("http://", "https://", "#", "mailto:")):
                continue
            clean = target.split("#", 1)[0]
            if clean and not (path.parent / clean).resolve().exists():
                missing.append(f"{path.relative_to(REPO_ROOT)} -> {target}")
    print(json.dumps({"missing_count": len(missing), "missing": missing[:100]}, indent=2, sort_keys=True))
    return 1 if missing else 0


def run_self_test() -> int:
    names = set(VALIDATIONS)
    required_validations = {
        "mcp01_self_test",
        "repo_claim_scan",
        "architecture_applicability_scan",
        "doc_link_scan_basic",
        "git_status_summary",
        "xcodegen_check_dry_run",
        "build_local",
        "focused_tests",
        "xcode_validate_build",
        "xcode_validate_build_for_testing",
        "xcode_validate_focused_test",
        "xcode_validate_test_plan",
    }
    required_tools = {
        "run_named_validation",
        "xcode_latest_summary",
        "xcode_failure_classification",
        "xctest_recovery_plan",
        "xcode_job_submit",
        "xcode_job_status",
        "xcode_job_result",
        "xcode_job_cancel",
    }
    if not required_validations.issubset(names):
        missing = sorted(required_validations - names)
        print(f"ambitions_proof_mcp self-test failed; missing validation names: {', '.join(missing)}")
        return 1
    if not required_tools.issubset(TOOLS):
        missing = sorted(required_tools - set(TOOLS))
        print(f"ambitions_proof_mcp self-test failed; missing tools: {', '.join(missing)}")
        return 1
    focused = VALIDATIONS["xcode_validate_focused_test"]
    if focused.timeout_seconds < 1800 or focused.xcode_wrapper_lane != "focused-test":
        print("ambitions_proof_mcp self-test failed; focused-test wrapper timeout/lane not installed")
        return 1
    try:
        _validated_xcode_extra_args(focused, ["--batch", "MCP-SMOKE-01", "--test", "AmbitionsTests/Focused"])
    except Exception as exc:
        print(f"ambitions_proof_mcp self-test failed; focused-test args rejected: {exc}")
        return 1
    recovery = _xctest_recovery_state(
        validation_name="xcode_validate_focused_test",
        classification="test_timeout",
        status="failed",
        exit_code=25,
        log_tail="focused XcodeBuildMCP attempt timed out",
    )
    if recovery["xctest_proof_verified"] or recovery["recommended_retry_validation"] != "xcode_validate_focused_test":
        print("ambitions_proof_mcp self-test failed; timeout recovery did not route to wrapper focused test")
        return 1
    print("ambitions_proof_mcp self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Ambitions controlled proof MCP")
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--claim-scan", action="store_true")
    parser.add_argument("--architecture-scan", action="store_true")
    parser.add_argument("--doc-link-scan-basic", action="store_true")
    parser.add_argument("--run-xcode-job", metavar="JOB_ID")
    args = parser.parse_args()
    if args.self_test:
        return run_self_test()
    if args.claim_scan:
        return _claim_scan()
    if args.architecture_scan:
        return _architecture_scan()
    if args.doc_link_scan_basic:
        return _doc_link_scan_basic()
    if args.run_xcode_job:
        return _run_xcode_job(args.run_xcode_job)
    return run_stdio()


if __name__ == "__main__":
    raise SystemExit(main())
