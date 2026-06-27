"""Source Atlas public/reference boundary primitives.

These helpers intentionally live in Foundry, not app runtime. They classify
candidate public/reference artifacts before any pack or R2 plan can be trusted.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any, Iterable


class SourceAtlasDataClass(str, Enum):
    OFFICIAL_PUBLIC_SOURCE = "official_public_source"
    PUBLIC_REFERENCE_CLAIM = "public_reference_claim"
    PUBLIC_REQUIREMENT = "public_requirement"
    PUBLIC_PROVENANCE = "public_provenance"
    PUBLIC_ONTOLOGY = "public_ontology"
    PUBLIC_ATOM_EDGE_LATTICE = "public_atom_edge_lattice"
    PUBLIC_RECIPE = "public_recipe"
    PUBLIC_FRESHNESS = "public_freshness"
    PUBLIC_R2_OBJECT_KEY = "public_r2_object_key"
    SYNTHETIC_FIXTURE = "synthetic_fixture"


ALLOWED_DATA_CLASSES = {item.value for item in SourceAtlasDataClass}

FORBIDDEN_DATA_CLASSES = {
    "goal_text",
    "capture_text",
    "schedule_or_capacity",
    "calendar_data",
    "life_capital",
    "proof_payload",
    "receipt_payload",
    "account_secret",
    "user_identifier",
    "private_life_graph",
    "personalization",
    "behavior_history",
    "inferred_priority",
    "private_user_context",
}

BOUNDARY_CONTEXT_KEYS = {
    "privacyBoundary",
    "nonClaims",
    "secretBoundary",
    "runtimeBoundary",
    "dataClassification",
    "boundary",
    "localPersonalizationRequired",
    "localRuntimeJoinRequired",
    "sourceAtlasInvisibleByDefault",
    "mustJoinWithPrivateRuntimeLocally",
    "mustNotUploadPrivateContext",
    "doesNotStoreFinalUserPath",
    "doesNotCreateFinalSchedule",
    "forbidden_artifact_classes",
    "forbiddenArtifactClasses",
    "forbiddenPrivateClasses",
    "allowed_artifact_classes",
    "allowedArtifactClasses",
    "terms",
    "termsGate",
    "privacyGate",
}

FORBIDDEN_KEY_PATTERNS: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"(^|[_-])user(id|_id|-id)?($|[_-])", re.I), "user_identifier"),
    (re.compile(r"account(secret|token|key|credential|session)", re.I), "account_secret"),
    (re.compile(r"(api|access|secret|session|refresh)[_-]?(key|token|secret)", re.I), "account_secret"),
    (re.compile(r"goal([_-]?(text|title|description|intent|phrase|id))?$", re.I), "goal_text"),
    (re.compile(r"capture([_-]?(text|body|transcript|note))?$", re.I), "capture_text"),
    (re.compile(r"(calendar|schedule|capacity|availability|protectedTime|fixedPoint)", re.I), "schedule_or_capacity"),
    (re.compile(r"(life[_-]?capital|lifeCapital|capabilityLedger|resourceGraph|relationshipGraph)", re.I), "life_capital"),
    (re.compile(r"(proof[_-]?(payload|body)|proofPayload|proofBody|evidenceLedger|receipt[_-]?(payload|body)|receiptPayload|receiptBody|closureHistory)", re.I), "proof_or_receipt_payload"),
    (re.compile(r"(private[_-]?life[_-]?graph|privateLifeGraph|life[_-]?graph|lifeGraph|personalization|behaviorHistory|inferred[_-]?priorit)", re.I), "private_life_graph"),
]

FORBIDDEN_TEXT_PATTERNS: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b", re.I), "email_address"),
    (re.compile(r"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b"), "phone_number"),
    (re.compile(r"\b(?:sk|pk|rk|ak)-[A-Za-z0-9_-]{12,}\b"), "api_key_or_secret"),
    (re.compile(r"\bmy\s+(goal|goals|calendar|capture|captures|receipt|receipts|schedule|capacity|life graph|proof)\b", re.I), "first_person_private_context"),
    (re.compile(r"\bI\s+(need|want|plan|captured|scheduled|proved|finished)\b", re.I), "first_person_private_context"),
    (re.compile(r"\b(private life graph|personalization data|behavior history|inferred priorit(?:y|ies)|private user context)\b", re.I), "private_graph_language"),
    (re.compile(r"\bLife Capital\b.*\b(user|my|personal|private)\b", re.I), "life_capital_private_context"),
]

FORBIDDEN_OBJECT_KEY_SEGMENTS = {
    "account",
    "accounts",
    "calendar",
    "calendars",
    "capture",
    "captures",
    "closure",
    "closures",
    "goal",
    "goals",
    "life-capital",
    "life_capital",
    "life-graph",
    "life_graph",
    "personalization",
    "private",
    "proof",
    "proofs",
    "receipt",
    "receipts",
    "schedule",
    "schedules",
    "user",
    "users",
}

ALLOWED_R2_KEY_PREFIXES = {
    "source-atlas",
    "source_atlas",
    "public-reference",
    "public_reference",
}


@dataclass(frozen=True)
class BoundaryIssue:
    label: str
    path: str
    code: str
    detail: str

    def format(self) -> str:
        return f"{self.label}:{self.path}: {self.code}: {self.detail}"


def boundary_issue_strings(issues: Iterable[BoundaryIssue]) -> list[str]:
    return [issue.format() for issue in issues]


def is_boundary_context_path(path: str) -> bool:
    segment = path.split(".")[-1]
    segment = segment.split("[", 1)[0]
    return segment in BOUNDARY_CONTEXT_KEYS


def is_boundary_line(line: str) -> bool:
    lowered = line.lower()
    markers = [
        "no private",
        "not private",
        "must not receive",
        "never receive",
        "public/reference/freshness only",
        "public/reference artifact",
        "not a private",
        "not private life graph",
        "forbidden private",
        "must not upload private",
    ]
    return any(marker in lowered for marker in markers)


def _data_class_for_value(value: Any, path: str) -> str | None:
    if isinstance(value, dict):
        for key in ("dataClass", "dataClassification", "classification"):
            raw = value.get(key)
            if isinstance(raw, str):
                return raw
    if path.endswith(".classification") and isinstance(value, str):
        return value
    return None


def boundary_issues_for_value(value: Any, label: str) -> list[BoundaryIssue]:
    issues: list[BoundaryIssue] = []

    def walk(item: Any, path: str) -> None:
        data_class = _data_class_for_value(item, path)
        if data_class and data_class not in ALLOWED_DATA_CLASSES:
            issues.append(BoundaryIssue(label, path, "unsupported_data_class", data_class))
        if isinstance(item, str):
            if is_boundary_context_path(path):
                return
            for index, line in enumerate(item.splitlines() or [item], start=1):
                if is_boundary_line(line):
                    continue
                for pattern, code in FORBIDDEN_TEXT_PATTERNS:
                    if pattern.search(line):
                        issues.append(BoundaryIssue(label, f"{path}:{index}", code, line.strip()[:160]))
        elif isinstance(item, list):
            for index, child in enumerate(item):
                walk(child, f"{path}[{index}]")
        elif isinstance(item, dict):
            if item.get("kind") == "ambitions.sourceAtlas.userMiniPack":
                issues.append(BoundaryIssue(label, path, "user_mini_pack_forbidden_in_foundry", "user mini-packs are local-only"))
            for key, child in item.items():
                key_path = f"{path}.{key}"
                if not is_boundary_context_path(key_path):
                    for pattern, code in FORBIDDEN_KEY_PATTERNS:
                        if pattern.search(key):
                            issues.append(BoundaryIssue(label, key_path, code, f"forbidden key '{key}'"))
                if key in {"privacyClass", "sourceKind", "kind"} and isinstance(child, str):
                    normalized = child.lower()
                    if normalized in {"privatelife", "private_life", "private", "sensitiveprivate", "sensitive_private"}:
                        issues.append(BoundaryIssue(label, key_path, "private_privacy_class_forbidden", child))
                    if normalized in {"userprovided", "user_provided"}:
                        issues.append(BoundaryIssue(label, key_path, "user_provided_source_forbidden", child))
                    if normalized in {"user_mini_pack", "ambitions.sourceatlas.userminipack"}:
                        issues.append(BoundaryIssue(label, key_path, "user_mini_pack_forbidden_in_foundry", child))
                walk(child, key_path)

    walk(value, "$")
    return issues


def boundary_issues_for_json_file(path: Path, label: str | None = None) -> list[BoundaryIssue]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        return [BoundaryIssue(label or str(path), "$", "invalid_json", str(exc))]
    return boundary_issues_for_value(value, label or str(path))


def object_key_issues(key: str, label: str = "objectKey") -> list[BoundaryIssue]:
    normalized = key.lower().replace("\\", "/").strip("/")
    segments = [segment for segment in normalized.split("/") if segment]
    issues: list[BoundaryIssue] = []
    if segments and segments[0] not in ALLOWED_R2_KEY_PREFIXES:
        issues.append(BoundaryIssue(label, "$", "unsupported_r2_prefix", segments[0]))
    for segment in segments:
        if segment in FORBIDDEN_OBJECT_KEY_SEGMENTS:
            issues.append(BoundaryIssue(label, "$", "private_r2_object_key_segment", segment))
        if re.search(r"\b[a-f0-9]{24,}\b", segment):
            issues.append(BoundaryIssue(label, "$", "possible_user_identifier_in_object_key", segment))
        if re.search(r"\buser[-_]?[a-z0-9]{4,}\b", segment, re.I):
            issues.append(BoundaryIssue(label, "$", "possible_user_identifier_in_object_key", segment))
    return issues


def request_shape_issues(request: dict[str, Any], label: str = "request") -> list[BoundaryIssue]:
    issues = boundary_issues_for_value(request, label)
    headers = request.get("headers") if isinstance(request, dict) else None
    if isinstance(headers, dict):
        for key in headers:
            if key.lower() in {"authorization", "cookie", "x-user-id", "x-account-id"}:
                issues.append(BoundaryIssue(label, f"$.headers.{key}", "forbidden_request_header", key))
    query = request.get("query") if isinstance(request, dict) else None
    if isinstance(query, dict):
        for key in query:
            if re.search(r"(user|account|goal|capture|schedule|capacity|calendar|life[_-]?capital|proof|receipt|priority)", key, re.I):
                issues.append(BoundaryIssue(label, f"$.query.{key}", "forbidden_request_query_field", key))
    return issues
