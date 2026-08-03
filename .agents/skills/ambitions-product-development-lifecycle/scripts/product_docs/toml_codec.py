"""Constrained TOML codec for the version-one lifecycle frontmatter."""

from __future__ import annotations

import tomllib
from enum import Enum
from pathlib import Path, PurePosixPath
from typing import Any

from .errors import Diagnostic, ProductDocsError
from .models import (
    AuthorityClass,
    DocumentMetadata,
    DocumentStatus,
    EvidenceFile,
    InputBinding,
    InputKind,
    ReviewVerdict,
    DocumentType,
)


SCALAR_FIELDS = (
    "schema_version", "template_version", "template_hash", "skill_version", "skill_package_hash",
    "authoring_surface", "initiative_id", "document_id", "document_type", "authority_class", "entry_point",
    "status", "revision", "created_at", "updated_at", "repository_baseline_commit", "external_research_as_of",
    "contract_hash", "content_review_verdict", "content_review_revision", "content_review_hash",
    "content_blocking_findings", "consumer_review_verdict", "consumer_review_revision", "consumer_review_hash",
    "consumer_blocking_findings",
)
ARRAY_FIELDS = (
    "canon_targets", "canon_delta_ids", "source_owner_paths", "test_owner_paths", "dependency_paths",
    "additional_freshness_paths", "freshness_paths", "supersedes",
)
KNOWN_FIELDS = frozenset((*SCALAR_FIELDS, *ARRAY_FIELDS, "inputs", "evidence_files"))
INTEGER_FIELDS = frozenset((
    "schema_version", "revision", "content_review_revision", "content_blocking_findings",
    "consumer_review_revision", "consumer_blocking_findings",
))
INPUT_FIELDS = {
    InputKind.LIFECYCLE_DOCUMENT: frozenset(("kind", "authority_id", "path", "revision", "contract_hash", "commit")),
    InputKind.CANON: frozenset(("kind", "authority_id", "path", "commit")),
    InputKind.APPROVED_DESIGN: frozenset(("kind", "authority_id", "path", "revision", "contract_hash", "commit")),
    InputKind.REPOSITORY_EVIDENCE: frozenset(("kind", "authority_id", "path", "commit")),
}
EVIDENCE_FIELDS = frozenset(("path", "sha256", "role"))


def _error(code: str, message: str, *, path: str | None = None) -> ProductDocsError:
    return ProductDocsError(Diagnostic(code=code, message=message, path=path))


def _validate_repository_path(value: str, repository_root: Path, field: str) -> str:
    if not value:
        raise _error("noncanonical-path", f"{field} must be a nonempty normalized POSIX-relative path", path=value)
    if "\\" in value:
        raise _error("noncanonical-path", f"{field} must use POSIX path separators", path=value)
    candidate = PurePosixPath(value)
    if candidate.is_absolute():
        raise _error("absolute-path", f"{field} must be repository relative", path=value)
    if ".." in candidate.parts:
        raise _error("path-traversal", f"{field} must not traverse outside the repository", path=value)
    canonical = candidate.as_posix()
    if canonical == "." or value != canonical:
        raise _error("noncanonical-path", f"{field} must use normalized POSIX-relative spelling", path=value)
    try:
        (repository_root / Path(canonical)).resolve().relative_to(repository_root.resolve())
    except ValueError as error:
        raise _error("path-outside-repository", f"{field} must remain inside the repository", path=value) from error
    return canonical


def _string_array(data: dict[str, Any], field: str, repository_root: Path) -> tuple[str, ...]:
    value = data.get(field)
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise _error("invalid-frontmatter-type", f"{field} must be an array of strings")
    if field.endswith("_paths") or field == "canon_targets":
        return tuple(_validate_repository_path(item, repository_root, field) for item in value)
    return tuple(value)


def _required_string(record: dict[str, Any], field: str, record_kind: str) -> str:
    value = record.get(field)
    if not isinstance(value, str):
        raise _error("invalid-record-field", f"{record_kind}.{field} must be a string")
    return value


def _parse_input(record: Any, repository_root: Path) -> InputBinding:
    if not isinstance(record, dict):
        raise _error("invalid-input-record", "inputs entries must be TOML tables")
    kind_text = _required_string(record, "kind", "inputs")
    try:
        kind = InputKind(kind_text)
    except ValueError as error:
        raise _error("unknown-input-kind", f"Unknown input kind: {kind_text}") from error
    unexpected = set(record).difference(INPUT_FIELDS[kind])
    if unexpected:
        raise _error("unknown-input-field", f"Unknown fields for {kind.value}: {', '.join(sorted(unexpected))}")
    authority_id = _required_string(record, "authority_id", "inputs")
    path = _validate_repository_path(_required_string(record, "path", "inputs"), repository_root, "inputs.path")
    commit = _required_string(record, "commit", "inputs")
    revision = record.get("revision")
    contract_hash = record.get("contract_hash")
    if kind in (InputKind.LIFECYCLE_DOCUMENT, InputKind.APPROVED_DESIGN):
        if type(revision) is not int or not isinstance(contract_hash, str):
            raise _error("invalid-input-record", f"{kind.value} requires integer revision and string contract_hash")
    elif revision is not None or contract_hash is not None:
        raise _error("unknown-input-field", f"{kind.value} does not permit revision or contract_hash")
    return InputBinding(
        kind=kind,
        authority_id=authority_id,
        path=path,
        commit=commit,
        revision=revision,
        contract_hash=contract_hash,
    )


def parse_frontmatter(text: str, repository_root: Path) -> DocumentMetadata:
    try:
        data = tomllib.loads(text)
    except tomllib.TOMLDecodeError as error:
        raise _error("toml-parse-error", f"Invalid TOML frontmatter: {error}") from error
    unknown = set(data).difference(KNOWN_FIELDS)
    if unknown:
        raise _error("unknown-frontmatter-field", f"Unknown frontmatter fields: {', '.join(sorted(unknown))}")
    missing = set((*SCALAR_FIELDS, *ARRAY_FIELDS)).difference(data)
    if missing:
        raise _error("missing-frontmatter-field", f"Missing frontmatter fields: {', '.join(sorted(missing))}")
    for field in INTEGER_FIELDS:
        if type(data[field]) is not int:
            raise _error("invalid-frontmatter-type", f"{field} must be an integer")
    for field in set(SCALAR_FIELDS).difference(INTEGER_FIELDS | {"document_type", "authority_class", "status", "content_review_verdict", "consumer_review_verdict"}):
        if not isinstance(data[field], str):
            raise _error("invalid-frontmatter-type", f"{field} must be a string")
    try:
        document_type = DocumentType(data["document_type"])
        authority_class = AuthorityClass(data["authority_class"])
        status = DocumentStatus(data["status"])
        content_verdict = ReviewVerdict(data["content_review_verdict"])
        consumer_verdict = ReviewVerdict(data["consumer_review_verdict"])
    except ValueError as error:
        raise _error("invalid-enum-value", str(error)) from error
    input_records = data.get("inputs", [])
    evidence_records = data.get("evidence_files", [])
    if not isinstance(input_records, list) or not isinstance(evidence_records, list):
        raise _error("invalid-frontmatter-type", "inputs and evidence_files must be TOML table arrays")
    inputs = tuple(_parse_input(record, repository_root) for record in input_records)
    evidence_files = []
    for record in evidence_records:
        if not isinstance(record, dict) or set(record) != EVIDENCE_FIELDS:
            raise _error("invalid-evidence-record", "evidence_files entries require only path, sha256, and role")
        evidence_files.append(EvidenceFile(
            path=_validate_repository_path(_required_string(record, "path", "evidence_files"), repository_root, "evidence_files.path"),
            sha256=_required_string(record, "sha256", "evidence_files"),
            role=_required_string(record, "role", "evidence_files"),
        ))
    return DocumentMetadata(
        **{field: data[field] for field in SCALAR_FIELDS if field not in {"document_type", "authority_class", "status", "content_review_verdict", "consumer_review_verdict"}},
        document_type=document_type,
        authority_class=authority_class,
        status=status,
        content_review_verdict=content_verdict,
        consumer_review_verdict=consumer_verdict,
        **{field: _string_array(data, field, repository_root) for field in ARRAY_FIELDS},
        inputs=inputs,
        evidence_files=tuple(evidence_files),
    )


def _toml_string(value: str) -> str:
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"').replace("\t", "\\t").replace("\r", "\\r").replace("\n", "\\n") + '"'


def render_frontmatter(metadata: DocumentMetadata) -> str:
    values: dict[str, Any] = {field: getattr(metadata, field) for field in SCALAR_FIELDS}
    lines = []
    for field in SCALAR_FIELDS:
        if field in {"authoring_surface", "status", "content_review_verdict"}:
            lines.append("")
        value = values[field]
        if isinstance(value, Enum):
            value = value.value
        if field in INTEGER_FIELDS:
            if type(value) is not int:
                raise _error("invalid-frontmatter-type", f"{field} must be an integer")
            lines.append(f"{field} = {value}")
        else:
            lines.append(f"{field} = {_toml_string(value)}")
    for field in ARRAY_FIELDS:
        if field == ARRAY_FIELDS[0]:
            lines.append("")
        lines.append(f"{field} = [" + ", ".join(_toml_string(value) for value in getattr(metadata, field)) + "]")
    for binding in metadata.inputs:
        lines.extend(("", "[[inputs]]", f"kind = {_toml_string(binding.kind.value)}", f"authority_id = {_toml_string(binding.authority_id)}", f"path = {_toml_string(binding.path)}"))
        if binding.revision is not None:
            if type(binding.revision) is not int:
                raise _error("invalid-input-record", "inputs.revision must be an integer")
            lines.append(f"revision = {binding.revision}")
        if binding.contract_hash is not None:
            lines.append(f"contract_hash = {_toml_string(binding.contract_hash)}")
        lines.append(f"commit = {_toml_string(binding.commit)}")
    for evidence in metadata.evidence_files:
        lines.extend(("", "[[evidence_files]]", f"path = {_toml_string(evidence.path)}", f"sha256 = {_toml_string(evidence.sha256)}", f"role = {_toml_string(evidence.role)}"))
    return "\n".join(lines)
