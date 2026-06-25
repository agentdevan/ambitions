"""Shared model helpers for Source Atlas Foundry."""

from __future__ import annotations

import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


NON_CLAIMS = [
    "not a private user-data backend",
    "not private life graph storage",
    "not an official legal, medical, financial, or admissions decision",
    "not runtime recommendation proof by itself",
    "not R2 release readiness",
    "not accessibility, privacy, or legal approval",
]

PRIVACY_BOUNDARY = (
    "public/reference/freshness only; no private life graph, goals, captures, "
    "calendar data, proof, receipts, personalization, behavior history, or private user context"
)

PRIVATE_CONTENT_PATTERNS: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b", re.I), "email_address"),
    (re.compile(r"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b"), "phone_number"),
    (re.compile(r"\bsk-[A-Za-z0-9_-]{12,}\b"), "api_key_or_secret"),
    (re.compile(r"\bmy\s+(goal|calendar|capture|receipt|schedule|life graph)\b", re.I), "first_person_private_context"),
    (re.compile(r"\bprivate life graph\b", re.I), "private_life_graph_reference"),
    (re.compile(r"\buser profile payload\b", re.I), "user_profile_payload"),
    (re.compile(r"\bpersonalization data\b", re.I), "personalization_data"),
    (re.compile(r"\bbehavior history\b", re.I), "behavior_history"),
]

PRIVATE_KEY_SEGMENTS = {
    "users",
    "user",
    "private",
    "captures",
    "capture",
    "life-graph",
    "life_graph",
    "receipts",
    "receipt",
    "personalization",
    "calendar",
}


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def canonical_json_bytes(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def stable_hash(value: Any) -> str:
    return hashlib.sha256(canonical_json_bytes(value)).hexdigest()


def stable_id(prefix: str, value: Any) -> str:
    return f"{prefix}.{stable_hash(value)[:16]}"


def file_sha256(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def read_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(value, handle, indent=2, sort_keys=True, ensure_ascii=False)
        handle.write("\n")


def relative_to_root(path: Path, root: Path) -> str:
    try:
        return str(path.resolve().relative_to(root.resolve()))
    except ValueError:
        return str(path)


def is_boundary_line(line: str) -> bool:
    lowered = line.lower()
    markers = [
        "no private",
        "not private",
        "must not receive",
        "never receive",
        "public/reference/freshness only",
        "not a private",
        "not private life graph",
    ]
    return any(marker in lowered for marker in markers)


def privacy_findings_for_text(text: str, label: str) -> list[str]:
    findings: list[str] = []
    for index, line in enumerate(text.splitlines(), start=1):
        if is_boundary_line(line):
            continue
        for pattern, name in PRIVATE_CONTENT_PATTERNS:
            if pattern.search(line):
                findings.append(f"{label}:{index}: {name}")
    return findings


def privacy_findings_for_value(value: Any, label: str) -> list[str]:
    findings: list[str] = []

    def walk(item: Any, path: str) -> None:
        if isinstance(item, str):
            findings.extend(privacy_findings_for_text(item, path))
        elif isinstance(item, list):
            for index, child in enumerate(item):
                walk(child, f"{path}[{index}]")
        elif isinstance(item, dict):
            for key, child in item.items():
                walk(child, f"{path}.{key}")

    walk(value, label)
    return findings


def object_key_findings(key: str) -> list[str]:
    normalized = key.lower().replace("\\", "/")
    segments = [segment for segment in normalized.split("/") if segment]
    return [f"object key contains private segment '{segment}'" for segment in segments if segment in PRIVATE_KEY_SEGMENTS]
