"""Shared model helpers for Source Atlas Foundry."""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .boundary import (
    BoundaryIssue,
    ALLOWED_DATA_CLASSES,
    FORBIDDEN_DATA_CLASSES,
    boundary_issue_strings,
    boundary_issues_for_value,
    is_boundary_line,
    object_key_issues,
)


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


def privacy_findings_for_text(text: str, label: str) -> list[str]:
    return [
        issue.format()
        for issue in boundary_issues_for_value(text, label)
        if not is_boundary_line(issue.detail)
    ]


def privacy_findings_for_value(value: Any, label: str) -> list[str]:
    return boundary_issue_strings(boundary_issues_for_value(value, label))


def object_key_findings(key: str) -> list[str]:
    return [issue.format() for issue in object_key_issues(key)]
