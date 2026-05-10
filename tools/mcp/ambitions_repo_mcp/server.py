#!/usr/bin/env python3
"""Read-only Ambitions repo MCP server.

This server intentionally uses only Python stdlib and exposes only read-only tools.
It implements newline-delimited JSON-RPC for MCP stdio transport.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable

JSON = dict[str, Any]
REPO_ROOT = Path(__file__).resolve().parents[3]

FORBIDDEN_CLAIM_PATTERNS = [
    r"\bproduction[- ]ready\b",
    r"\brelease[- ]ready\b",
    r"\bApp Store[- ]ready\b",
    r"\bTestFlight[- ]ready\b",
    r"\bdevice verified\b",
    r"\bphysical[- ]device proof\b",
    r"\baccessibility compliant\b",
    r"\baccessibility verified\b",
    r"\bprivacy compliant\b",
    r"\blegal compliant\b",
    r"\bguaranteed\b",
    r"\bbest possible\b",
    r"\bAI confidence\b",
    r"\bmodel confidence\b",
    r"\bproductivity score\b",
    r"\boverdue\b",
    r"\byou failed\b",
    r"\bfailed goal\b",
]

EFC_PROOF_FAMILIES = [
    "product_proof",
    "trust_proof",
    "privacy_proof",
    "accessibility_proof",
    "degraded_state_proof",
    "test_proof",
    "release_claim_boundary",
    "recovery_proof",
    "performance_proof",
    "continuation_proof",
]

CLOSEOUT_REQUIRED_HEADINGS = [
    "files changed",
    "validation",
    "efc",
    "non-claims",
    "next eligible",
    "rollback",
]


@dataclass(frozen=True)
class ToolDef:
    name: str
    description: str
    input_schema: JSON
    handler: Callable[[JSON], JSON]


def _safe_repo_path(path_value: str) -> Path:
    if not path_value or "\x00" in path_value:
        raise ValueError("path is empty or invalid")
    raw = Path(path_value)
    if raw.is_absolute():
        candidate = raw.resolve()
    else:
        candidate = (REPO_ROOT / raw).resolve()
    try:
        candidate.relative_to(REPO_ROOT)
    except ValueError as exc:
        raise ValueError(f"path escapes repo root: {path_value}") from exc
    return candidate


def _read_text(path_value: str, max_bytes: int = 500_000) -> str:
    path = _safe_repo_path(path_value)
    if not path.exists():
        raise FileNotFoundError(str(path.relative_to(REPO_ROOT)))
    if not path.is_file():
        raise ValueError(f"not a file: {path.relative_to(REPO_ROOT)}")
    if path.stat().st_size > max_bytes:
        raise ValueError(f"file too large for MCP read: {path.relative_to(REPO_ROOT)}")
    return path.read_text(encoding="utf-8", errors="replace")


def _exists(path_value: str) -> bool:
    try:
        return _safe_repo_path(path_value).exists()
    except ValueError:
        return False


def _extract_yaml_scalar(text: str, key: str) -> str | None:
    match = re.search(rf"^\s*{re.escape(key)}:\s*\"?([^\"\n]+)\"?\s*$", text, re.MULTILINE)
    if match:
        return match.group(1).strip()
    return None


def _extract_current_block(text: str) -> JSON:
    block_match = re.search(r"^current:\s*$([\s\S]*?)(?:^\S|\Z)", text, re.MULTILINE)
    block = block_match.group(1) if block_match else text
    return {
        "train": _extract_yaml_scalar(block, "train"),
        "batch": _extract_yaml_scalar(block, "batch"),
        "previous_batch": _extract_yaml_scalar(block, "previous_batch"),
        "previous_result": _extract_yaml_scalar(block, "previous_result"),
        "next_eligible_batch": _extract_yaml_scalar(block, "next_eligible_batch"),
    }


def _path_category(path: str) -> str:
    p = path.replace("\\", "/")
    if p.startswith("Native/Ambitions/Features/") or p.startswith("Native/Ambitions/App/"):
        return "user_facing_app"
    if p.startswith("Native/Ambitions/Domain/"):
        return "domain_intelligence_or_contract"
    if p.startswith("Native/Ambitions/Persistence/"):
        return "persistence"
    if p.startswith("Native/Ambitions/Services/"):
        return "services_side_effects"
    if p.startswith("Native/AmbitionsTests/") or p.startswith("Native/AmbitionsUITests/"):
        return "tests"
    if p.startswith("docs/AmbitionsCanon/"):
        return "product_design_canon"
    if p.startswith("docs/codex/") or p.startswith(".codex/"):
        return "codex_governance"
    if p.startswith("docs/canon/"):
        return "legacy_or_supporting_canon"
    if p.startswith("docs/status/") or p.startswith("docs/audits/") or p.startswith("docs/handoff/"):
        return "evidence_status_docs"
    if p.startswith("project.yml") or p.startswith("Package.swift"):
        return "build_configuration"
    if ".github/workflows" in p:
        return "hosted_ci"
    return "other"


def _required_proof_for_categories(categories: set[str]) -> list[str]:
    proof: set[str] = set()
    if categories & {"user_facing_app", "product_design_canon"}:
        proof.update([
            "product_proof",
            "trust_proof",
            "accessibility_proof",
            "degraded_state_proof",
            "test_proof",
            "release_claim_boundary",
        ])
    if categories & {"domain_intelligence_or_contract", "services_side_effects"}:
        proof.update([
            "trust_proof",
            "privacy_proof",
            "test_proof",
            "recovery_proof",
            "release_claim_boundary",
        ])
    if "persistence" in categories:
        proof.update([
            "privacy_proof",
            "degraded_state_proof",
            "test_proof",
            "recovery_proof",
            "performance_proof",
            "release_claim_boundary",
        ])
    if "build_configuration" in categories or "hosted_ci" in categories:
        proof.update([
            "test_proof",
            "release_claim_boundary",
            "continuation_proof",
        ])
    if categories & {"codex_governance", "evidence_status_docs", "legacy_or_supporting_canon"}:
        proof.update([
            "release_claim_boundary",
            "continuation_proof",
        ])
    return [p for p in EFC_PROOF_FAMILIES if p in proof]


def _hard_red_risks(paths: list[str], categories: set[str]) -> list[str]:
    risks: list[str] = []
    if "hosted_ci" in categories:
        risks.append("hosted CI workflow touched; requires explicit cost/billing/provider approval")
    if "build_configuration" in categories:
        risks.append("build configuration touched; signing/entitlement/release-claim boundaries required")
    if any("Entitlements" in p or p.endswith(".entitlements") for p in paths):
        risks.append("entitlement file touched; signing/platform approval required")
    if any("StoreKit" in p or "Paywall" in p for p in paths):
        risks.append("monetization surface touched; StoreKit/product/pricing/legal approval required")
    if categories & {"user_facing_app", "product_design_canon"}:
        risks.append("public accessibility or device-quality claim must be blocked without real-device evidence")
    return risks


def tool_get_active_batch(_: JSON) -> JSON:
    active_path = ".codex/state/active-batch.yml"
    text = _read_text(active_path)
    current = _extract_current_block(text)
    source_truth = re.findall(r"^\s*-\s+\"?([^\"\n]+)\"?\s*$", text, re.MULTILINE)
    return {
        "repo_root": str(REPO_ROOT),
        "active_batch_file": active_path,
        "current": current,
        "source_truth": source_truth,
        "efc_overlay_active": "EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md" in text,
    }


def tool_get_efc_overlay_status(_: JSON) -> JSON:
    files = [
        "docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md",
        "docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md",
        "docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md",
        "docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md",
    ]
    return {
        "active": all(_exists(path) for path in files),
        "files": {path: _exists(path) for path in files},
        "rule": "EFC applies to unfinished work as a proof overlay, not a parallel feature train.",
        "non_claims": [
            "no app behavior implementation",
            "no release readiness",
            "no device proof",
            "no public accessibility proof",
            "no legal/privacy compliance claim",
        ],
    }


def tool_get_source_truth_stack(_: JSON) -> JSON:
    stack = [
        "docs/truth/README.md",
        "docs/truth/PRODUCT_DESIGN_TRUTH.md",
        "docs/truth/IMPLEMENTATION_TRUTH.md",
        "docs/truth/RELEASE_TRUTH.md",
        "docs/truth/CODEX_PROCESS_TRUTH.md",
        "docs/truth/HISTORICAL_POLICY.md",
        "README.md",
        "docs/README.md",
        "AGENTS.md",
        ".codex/OPERATING_SYSTEM.md",
        ".codex/REPO_INVENTORY.md",
        ".codex/SESSION_BOOTSTRAP.md",
        ".codex/GLOBAL_BATCH_TRAIN.md",
        ".codex/BATCH_TRAIN_REGISTRY.md",
        ".codex/SKILL_GOVERNANCE.md",
        ".codex/TOOLING_AND_VALIDATION.md",
        "docs/AmbitionsCanon/README.md",
        "docs/status/current-implementation-map.md",
        "docs/status/release-evidence-packet.md",
        "docs/status/archive-and-stale-material-ledger.md",
        "docs/status/repo-control-plane-cleanup-final-report.md",
        "docs/status/repo-cleanup-index.md",
        "docs/native-build-and-release.md",
        ".codex/state/active-batch.yml",
        "docs/codex/BATCH_REGISTRY.md",
        "docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md",
        "docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md",
        "docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md",
        "target source files and tests",
    ]
    return {
        "stack": [{"path": path, "exists": _exists(path)} for path in stack],
        "precedence_note": "docs/truth/* wins conflicts. Live source plus IMPLEMENTATION_TRUTH and the current implementation map own implementation status; RELEASE_TRUTH plus current raw evidence own proof claims; CODEX_PROCESS_TRUTH, AGENTS.md, and active .codex OS files own Codex operation; HISTORICAL_POLICY owns archive/delete policy. AmbitionsCanon and docs/codex history are supporting where compatible.",
    }


def tool_check_efc_applicability(args: JSON) -> JSON:
    changed_files = args.get("changed_files") or []
    if not isinstance(changed_files, list):
        raise ValueError("changed_files must be a list of paths")
    paths = [str(item) for item in changed_files]
    categories = {_path_category(path) for path in paths}
    required = _required_proof_for_categories(categories)
    return {
        "efc_required": bool(required),
        "changed_files": paths,
        "categories": sorted(categories),
        "required_proof": required,
        "likely_owner": _likely_owner(categories),
        "hard_red_risks": _hard_red_risks(paths, categories),
        "closeout_required_note": "After EFC00, every applicable batch report must state EFC applicability: invoked / not applicable / accepted Yellow with owner.",
    }


def _likely_owner(categories: set[str]) -> str:
    if "user_facing_app" in categories or "product_design_canon" in categories:
        return "AFI/FCP/FVQ"
    if "domain_intelligence_or_contract" in categories:
        return "AOS/LDI/PK"
    if "persistence" in categories or "services_side_effects" in categories:
        return "PK/PFC"
    if "codex_governance" in categories or "evidence_status_docs" in categories:
        return "CQS/GOV/EFC"
    if "build_configuration" in categories or "hosted_ci" in categories:
        return "PFC/Release"
    return "batch owner must be determined from registry"


def tool_changed_file_impact(args: JSON) -> JSON:
    changed_files = args.get("changed_files") or []
    if not isinstance(changed_files, list):
        raise ValueError("changed_files must be a list of paths")
    impacts = []
    for raw in changed_files:
        path = str(raw)
        category = _path_category(path)
        impacts.append({
            "path": path,
            "category": category,
            "likely_owner": _likely_owner({category}),
            "efc_required_proof": _required_proof_for_categories({category}),
            "suggested_validation": _suggested_validation(category),
        })
    return {"impacts": impacts}


def _suggested_validation(category: str) -> list[str]:
    if category == "user_facing_app":
        return ["focused unit/UI tests", "visual proof", "accessibility proof", "EFC applicability"]
    if category == "domain_intelligence_or_contract":
        return ["focused domain tests", "fixture tests", "claim scan", "EFC trust/privacy proof"]
    if category == "persistence":
        return ["persistence tests", "migration/restore proof", "privacy proof"]
    if category == "services_side_effects":
        return ["service tests", "side-effect ledger proof", "privacy/degraded-state proof"]
    if category == "codex_governance":
        return ["doc QA", "claim scan", "active batch state check"]
    if category == "product_design_canon":
        return ["canon consistency scan", "visual/a11y applicability", "claim scan"]
    if category == "build_configuration":
        return ["xcodegen generate", "focused build", "release-claim boundary"]
    if category == "hosted_ci":
        return ["cost/billing approval", "workflow security review", "release-claim boundary"]
    return ["owner-specific validation", "claim scan"]


def tool_detect_forbidden_claims(args: JSON) -> JSON:
    paths = args.get("paths") or []
    if isinstance(paths, str):
        paths = [paths]
    if not isinstance(paths, list):
        raise ValueError("paths must be a list of repo-relative file paths")
    findings = []
    compiled = [(pattern, re.compile(pattern, re.IGNORECASE)) for pattern in FORBIDDEN_CLAIM_PATTERNS]
    for path in [str(p) for p in paths]:
        text = _read_text(path)
        for line_no, line in enumerate(text.splitlines(), start=1):
            for pattern, regex in compiled:
                if regex.search(line):
                    findings.append({
                        "path": path,
                        "line": line_no,
                        "pattern": pattern,
                        "text": line.strip()[:240],
                    })
    return {
        "finding_count": len(findings),
        "findings": findings,
        "note": "Findings are review triggers, not automatic failures. Some forbidden phrases may be valid inside no-claim boundaries or historical examples.",
    }


def tool_check_batch_closeout_shape(args: JSON) -> JSON:
    report_path = args.get("report_path")
    if not isinstance(report_path, str):
        raise ValueError("report_path is required")
    text = _read_text(report_path)
    lowered = text.lower()
    missing = [heading for heading in CLOSEOUT_REQUIRED_HEADINGS if heading not in lowered]
    efc_present = "efc" in lowered and ("invoked" in lowered or "not applicable" in lowered or "accepted yellow" in lowered)
    return {
        "report_path": report_path,
        "valid_shape": not missing and efc_present,
        "missing_headings_or_terms": missing + ([] if efc_present else ["EFC applicability status"]),
        "recommended_sections": [
            "Files Changed",
            "Validation Performed / Not Performed",
            "EFC Flagship Proof Overlay",
            "Non-Claims",
            "Next Eligible Batch",
            "Rollback Path",
        ],
    }


def tool_summarize_repo_posture(_: JSON) -> JSON:
    active = tool_get_active_batch({})
    efc = tool_get_efc_overlay_status({})
    return {
        "app": "native SwiftUI Ambitions app",
        "top_level_ia": "Today / Goals / Capture / Time / You",
        "local_first_posture": True,
        "hosted_ci_active": _exists(".github/workflows"),
        "efc_overlay_active": efc["active"],
        "current_batch": active["current"],
        "release_claims": {
            "app_store_ready": False,
            "testflight_ready": False,
            "physical_device_proven": False,
            "public_accessibility_conformance": False,
            "legal_privacy_signoff": False,
        },
        "standing_warning": "Do not claim release/device/accessibility/legal/privacy proof without matching evidence.",
    }


TOOLS: dict[str, ToolDef] = {}


def _register(tool: ToolDef) -> None:
    TOOLS[tool.name] = tool


def _tool_schema(properties: JSON | None = None, required: list[str] | None = None) -> JSON:
    return {
        "type": "object",
        "properties": properties or {},
        "required": required or [],
        "additionalProperties": False,
    }


_register(ToolDef(
    "get_active_batch",
    "Return the current active batch, next eligible batch, source-truth files, and EFC overlay status.",
    _tool_schema(),
    tool_get_active_batch,
))
_register(ToolDef(
    "get_efc_overlay_status",
    "Return whether the EFC proof overlay files exist and what they claim or do not claim.",
    _tool_schema(),
    tool_get_efc_overlay_status,
))
_register(ToolDef(
    "get_source_truth_stack",
    "Return the current Ambitions source-truth read order and existence checks.",
    _tool_schema(),
    tool_get_source_truth_stack,
))
_register(ToolDef(
    "check_efc_applicability",
    "Given changed files, identify whether EFC applies and which proof families are required.",
    _tool_schema({"changed_files": {"type": "array", "items": {"type": "string"}}}, ["changed_files"]),
    tool_check_efc_applicability,
))
_register(ToolDef(
    "changed_file_impact",
    "Given changed files, classify likely owner, validation, and EFC proof impact per file.",
    _tool_schema({"changed_files": {"type": "array", "items": {"type": "string"}}}, ["changed_files"]),
    tool_changed_file_impact,
))
_register(ToolDef(
    "detect_forbidden_claims",
    "Scan selected repo files for release/accessibility/privacy/AI/shame claim triggers.",
    _tool_schema({"paths": {"type": "array", "items": {"type": "string"}}}, ["paths"]),
    tool_detect_forbidden_claims,
))
_register(ToolDef(
    "check_batch_closeout_shape",
    "Validate that a batch closeout report includes required EFC-era sections.",
    _tool_schema({"report_path": {"type": "string"}}, ["report_path"]),
    tool_check_batch_closeout_shape,
))
_register(ToolDef(
    "summarize_repo_posture",
    "Return a concise current repo posture summary for Codex preflight.",
    _tool_schema(),
    tool_summarize_repo_posture,
))


def _mcp_tools_list() -> JSON:
    return {
        "tools": [
            {
                "name": tool.name,
                "description": tool.description,
                "inputSchema": tool.input_schema,
            }
            for tool in TOOLS.values()
        ]
    }


def _mcp_tool_call(params: JSON) -> JSON:
    name = params.get("name")
    args = params.get("arguments") or {}
    if not isinstance(name, str) or name not in TOOLS:
        raise ValueError(f"unknown tool: {name}")
    if not isinstance(args, dict):
        raise ValueError("tool arguments must be an object")
    result = TOOLS[name].handler(args)
    return {
        "content": [
            {
                "type": "text",
                "text": json.dumps(result, indent=2, sort_keys=True),
            }
        ],
        "isError": False,
    }


def _response(request_id: Any, result: JSON | None = None, error: JSON | None = None) -> JSON:
    payload: JSON = {"jsonrpc": "2.0", "id": request_id}
    if error is not None:
        payload["error"] = error
    else:
        payload["result"] = result or {}
    return payload


def _error(code: int, message: str, data: Any | None = None) -> JSON:
    payload: JSON = {"code": code, "message": message}
    if data is not None:
        payload["data"] = data
    return payload


def _handle(message: JSON) -> JSON | None:
    request_id = message.get("id")
    method = message.get("method")
    params = message.get("params") or {}

    # Notifications do not receive responses.
    is_notification = "id" not in message

    try:
        if method == "initialize":
            if is_notification:
                return None
            return _response(request_id, {
                "protocolVersion": "2025-03-26",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "ambitions_repo_mcp", "version": "0.1.0"},
            })
        if method == "notifications/initialized":
            return None
        if method == "ping":
            if is_notification:
                return None
            return _response(request_id, {})
        if method == "tools/list":
            if is_notification:
                return None
            return _response(request_id, _mcp_tools_list())
        if method == "tools/call":
            if is_notification:
                return None
            if not isinstance(params, dict):
                raise ValueError("params must be an object")
            return _response(request_id, _mcp_tool_call(params))
        if is_notification:
            return None
        return _response(request_id, error=_error(-32601, f"method not found: {method}"))
    except Exception as exc:  # deterministic tool error returned as JSON-RPC error
        if is_notification:
            return None
        return _response(request_id, error=_error(-32000, str(exc)))


def run_stdio() -> int:
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            message = json.loads(line)
            if isinstance(message, list):
                responses = [_handle(item) for item in message if isinstance(item, dict)]
                responses = [resp for resp in responses if resp is not None]
                if responses:
                    print(json.dumps(responses, separators=(",", ":")), flush=True)
                continue
            if not isinstance(message, dict):
                raise ValueError("JSON-RPC message must be an object")
            response = _handle(message)
            if response is not None:
                print(json.dumps(response, separators=(",", ":")), flush=True)
        except Exception as exc:
            error_response = _response(None, error=_error(-32700, f"parse or dispatch error: {exc}"))
            print(json.dumps(error_response, separators=(",", ":")), flush=True)
    return 0


def run_self_test() -> int:
    required = [
        ".codex/state/active-batch.yml",
        "docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md",
        "docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md",
    ]
    missing = [path for path in required if not _exists(path)]
    if missing:
        print(f"ambitions_repo_mcp self-test failed; missing: {', '.join(missing)}")
        return 1
    active = tool_get_active_batch({})
    if not active["current"].get("batch"):
        print("ambitions_repo_mcp self-test failed; active batch not parsed")
        return 1
    applicability = tool_check_efc_applicability({"changed_files": ["Native/Ambitions/Features/Today/TodayView.swift"]})
    if not applicability["efc_required"]:
        print("ambitions_repo_mcp self-test failed; EFC applicability did not trigger for user-facing file")
        return 1
    print("ambitions_repo_mcp self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Ambitions read-only repo MCP server")
    parser.add_argument("--self-test", action="store_true", help="Run local self-test and exit")
    args = parser.parse_args()
    if args.self_test:
        return run_self_test()
    return run_stdio()


if __name__ == "__main__":
    raise SystemExit(main())
