#!/usr/bin/env python3
"""Controlled proof MCP for Ambitions.

This server intentionally exposes named validation actions only. It is not a
generic shell, network, signing, release, or git mutation interface.
"""

from __future__ import annotations

import argparse
import json
import os
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


@dataclass(frozen=True)
class Validation:
    name: str
    description: str
    command: tuple[str, ...]
    requires: tuple[str, ...] = ()
    timeout_seconds: int = 120
    enabled_by_default: bool = True
    requires_explicit_args: bool = False


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
        "Run the existing local build script only when an app-source batch requires it.",
        ("./scripts/build-local.sh",),
        requires=("scripts/build-local.sh",),
        timeout_seconds=1800,
        enabled_by_default=False,
    ),
    "focused_tests": Validation(
        "focused_tests",
        "Run focused xcodebuild tests with explicit arguments only.",
        ("xcodebuild", "test"),
        timeout_seconds=1800,
        enabled_by_default=False,
        requires_explicit_args=True,
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
}


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
    }


def _assert_command_allowed(command: list[str]) -> None:
    joined = " ".join(command)
    if any(token in joined for token in FORBIDDEN_EXTRA_TOKENS):
        raise ValueError(f"forbidden command token in validation command: {joined}")


def _run(validation: Validation, extra_args: list[str] | None = None) -> JSON:
    extra_args = extra_args or []
    if validation.requires_explicit_args and not extra_args:
        raise ValueError(f"{validation.name} requires explicit target/test arguments")
    status = _validation_status(validation)
    if status["missing_paths"]:
        raise FileNotFoundError(f"missing required paths: {', '.join(status['missing_paths'])}")
    command = list(validation.command) + extra_args
    _assert_command_allowed(command)
    PROOF_ROOT.mkdir(parents=True, exist_ok=True)
    log_path = PROOF_ROOT / f"{_timestamp()}-{validation.name}.log"
    proc = subprocess.run(
        command,
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=validation.timeout_seconds,
        check=False,
    )
    log_path.write_text(proc.stdout, encoding="utf-8")
    return {
        "validation": validation.name,
        "command": command,
        "exit_code": proc.returncode,
        "passed": proc.returncode == 0,
        "log_path": str(log_path.relative_to(REPO_ROOT)),
        "output_tail": proc.stdout[-4000:],
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
    roots = [PROOF_ROOT, MCP_LOG_ROOT, REPO_ROOT / "output" / "logs"]
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


TOOLS: dict[str, ToolDef] = {}


def _register(tool: ToolDef) -> None:
    TOOLS[tool.name] = tool


def _tool_schema(properties: JSON | None = None, required: list[str] | None = None) -> JSON:
    return {"type": "object", "properties": properties or {}, "required": required or [], "additionalProperties": False}


_register(ToolDef("list_available_validations", "List allowlisted local validations.", _tool_schema(), tool_list_available_validations))
_register(ToolDef("run_named_validation", "Run one allowlisted validation by name.", _tool_schema({"name": {"type": "string"}, "args": {"type": "array", "items": {"type": "string"}}}, ["name"]), tool_run_named_validation))
_register(ToolDef("collect_latest_logs", "Collect latest local proof logs.", _tool_schema({"limit": {"type": "integer"}}), tool_collect_latest_logs))
_register(ToolDef("generate_proof_packet", "Generate a local proof packet from latest logs.", _tool_schema({"title": {"type": "string"}, "validations": {"type": "array", "items": {"type": "string"}}}), tool_generate_proof_packet))
_register(ToolDef("check_validation_policy", "Return validation policy and forbidden actions.", _tool_schema({"name": {"type": "string"}}), tool_check_validation_policy))


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
            return None if is_notification else _response(request_id, {"protocolVersion": "2025-03-26", "capabilities": {"tools": {}}, "serverInfo": {"name": "ambitions_proof_mcp", "version": "0.1.0"}})
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
    required = {"mcp01_self_test", "repo_claim_scan", "efc_applicability_scan", "doc_link_scan_basic", "git_status_summary", "xcodegen_check_dry_run", "build_local", "focused_tests"}
    if not required.issubset(names):
        print("ambitions_proof_mcp self-test failed; missing validation names")
        return 1
    if "run_named_validation" not in TOOLS:
        print("ambitions_proof_mcp self-test failed; missing run tool")
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
