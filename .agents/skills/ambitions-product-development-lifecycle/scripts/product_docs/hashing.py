"""Deterministic authority-contract hashing for lifecycle documents."""

from __future__ import annotations

from enum import Enum
import hashlib
import json
from typing import Any

from .models import EvidenceFile, InputBinding, LifecycleDocument


_INCLUDED_SCALARS = (
    "schema_version",
    "template_version",
    "template_hash",
    "skill_version",
    "skill_package_hash",
    "authoring_surface",
    "initiative_id",
    "document_id",
    "document_type",
    "authority_class",
    "entry_point",
    "repository_baseline_commit",
    "external_research_as_of",
)
_PATH_ARRAYS = (
    "canon_targets",
    "source_owner_paths",
    "test_owner_paths",
    "dependency_paths",
    "additional_freshness_paths",
    "freshness_paths",
)
_PRESERVED_ARRAYS = ("canon_delta_ids", "supersedes")


def _value(value: Any) -> Any:
    return value.value if isinstance(value, Enum) else value


def _input_record(binding: InputBinding) -> dict[str, object]:
    record: dict[str, object] = {
        "kind": binding.kind.value,
        "authority_id": binding.authority_id,
        "path": binding.path,
        "commit": binding.commit,
    }
    if binding.revision is not None:
        record["revision"] = binding.revision
    if binding.contract_hash is not None:
        record["contract_hash"] = binding.contract_hash
    return record


def _evidence_record(evidence: EvidenceFile) -> dict[str, str]:
    return {"path": evidence.path, "sha256": evidence.sha256, "role": evidence.role}


def _canonical_frontmatter(document: LifecycleDocument) -> str:
    metadata = document.metadata
    projection: dict[str, object] = {
        field: _value(getattr(metadata, field)) for field in _INCLUDED_SCALARS
    }
    projection.update(
        {field: sorted(set(getattr(metadata, field))) for field in _PATH_ARRAYS}
    )
    projection.update(
        {field: list(getattr(metadata, field)) for field in _PRESERVED_ARRAYS}
    )
    projection["inputs"] = sorted(
        (_input_record(binding) for binding in metadata.inputs),
        key=lambda record: (record["kind"], record["path"], record["authority_id"]),
    )
    projection["evidence_files"] = sorted(
        (_evidence_record(evidence) for evidence in metadata.evidence_files),
        key=lambda record: (record["path"], record.get("authority_id", "")),
    )
    return json.dumps(
        projection, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    )


def _normalized_body(document: LifecycleDocument) -> str:
    body = document.body_prefix + "".join(
        f"## {section.heading}{section.heading_ending}{section.body}"
        for section in document.sections
        if section.heading != "Review history"
    )
    body = body.replace("\r\n", "\n").replace("\r", "\n")
    lines = [line.rstrip(" \t") for line in body.split("\n")]
    while lines and not lines[0]:
        lines.pop(0)
    while lines and not lines[-1]:
        lines.pop()
    return "\n".join(lines)


def compute_contract_hash(document: LifecycleDocument) -> str:
    """Return the version-one contract hash for ``document``."""
    payload = (
        f"{_canonical_frontmatter(document)}\n---BODY---\n{_normalized_body(document)}"
    )
    return f"sha256:{hashlib.sha256(payload.encode('utf-8')).hexdigest()}"
