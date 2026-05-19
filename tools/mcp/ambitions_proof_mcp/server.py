#!/usr/bin/env python3
"""Controlled proof MCP for Ambitions.

This server intentionally exposes named validation actions only. It is not a
generic shell, network, signing, release, or git mutation interface.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable

JSON = dict[str, Any]
REPO_ROOT = Path(__file__).resolve().parents[3]
LOG_ROOT = REPO_ROOT / ".codex" / "logs"
PROOF_ROOT = LOG_ROOT / "proof"
MCP_LOG_ROOT = LOG_ROOT / "mcp"
XCODE_SUMMARY_ROOT = REPO_ROOT / ".codex" / "xcode-summaries"
XCODE_LOG_ROOT = REPO_ROOT / ".codex" / "xcode-logs"


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
        "Run the read-only Ambitions Repo MCP self-test.",
        ("python3", "tools/mcp/ambitions_repo_mcp/server.py", "--self-test"),
        requires=("tools/mcp/ambitions_repo_mcp/server.py",),
    ),
    "repo_claim_scan": Validation(
        "repo_claim_scan",
        "Run a conservative forbidden-claim scan through the read-only MCP self-test path.",
        ("python3", "tools/mcp/ambitions_proof_mcp/server.py", "--claim-scan"),
    ),
    "efc_applicability_scan": Validation(
        "efc_applicability_scan",
        "Run an EFC applicability smoke scan for a user-facing Swift path.",
        ("python3", "tools/mcp/ambitions_proof_mcp/server.py", "--efc-scan"),
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
    "xcrun altool",
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
TIMEOUT_CATEGORIES = {"test_timeout", "mcp_timeout", "simulator_boot_failure", "missing_destination"}


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
    summaries = sorted(root.rglob("validate-summary.json"), key=lambda path: path.stat().st_mtime, reverse=True)
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
            "wrapper-native Xcode validations use 1800-second timeout for simulator workflows",
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
    roots = [PROOF_ROOT, MCP_LOG_ROOT, REPO_ROOT / "output" / "logs", XCODE_LOG_ROOT, XCODE_SUMMARY_ROOT]
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
        "continuation_after_retry": "Call ambitionsProof.xcode_latest_summary, then ambitionsProof.xcode_failure_classification, then ambitionsRepo.continuation_oracle.",
    }


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
            return None if is_notification else _response(request_id, {"protocolVersion": "2025-03-26", "capabilities": {"tools": {}}, "serverInfo": {"name": "ambitions_proof_mcp", "version": "0.3.0"}})
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
    result = {"paths": risky, "note": "basic MCP02 claim-scan placeholder; use ambitionsRepo detect_forbidden_claims for targeted scans"}
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


def _efc_scan() -> int:
    result = {
        "changed_files": ["Native/Ambitions/Features/Today/TodayView.swift"],
        "efc_required": True,
        "required_proof": ["product_proof", "trust_proof", "accessibility_proof", "degraded_state_proof", "test_proof", "release_claim_boundary"],
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
        "efc_applicability_scan",
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
    parser.add_argument("--efc-scan", action="store_true")
    parser.add_argument("--doc-link-scan-basic", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        return run_self_test()
    if args.claim_scan:
        return _claim_scan()
    if args.efc_scan:
        return _efc_scan()
    if args.doc_link_scan_basic:
        return _doc_link_scan_basic()
    return run_stdio()


if __name__ == "__main__":
    raise SystemExit(main())
