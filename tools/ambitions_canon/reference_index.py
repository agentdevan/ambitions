"""Closed provenance-bound impact reference index loading."""

from __future__ import annotations

import hashlib
import json
import os
import re
from pathlib import Path

from tools.ambitions_canon.model import (
    AuthorityClass,
    AuthorityReference,
    AuthorityReferenceKind,
    CanonError,
    CanonManifest,
    GapSeverity,
    ImpactReferenceIndex,
    SpecificationGapRecord,
    TaskPackReference,
)
from tools.ambitions_canon.supersession import _open_file_nofollow


REFERENCE_INDEX_PATH = Path("docs/canon/migration/impact-reference-index.json")
_TOP_FIELDS = frozenset(
    {
        "schema_version",
        "canon_revision",
        "indexed_requirement_ids",
        "authority_references",
        "task_packs",
        "specification_gaps",
    }
)
_AUTHORITY_REQUIRED = frozenset(
    {
        "schema_version",
        "reference_id",
        "authority_class",
        "reference_kind",
        "source",
        "revision",
        "requirement_ids",
        "approval_state",
    }
)
_AUTHORITY_ALLOWED = _AUTHORITY_REQUIRED | {
    "approved_by",
    "implementation_status",
}
_PACK_FIELDS = frozenset(
    {
        "schema_version",
        "pack_id",
        "source",
        "canon_revision",
        "canon_sha",
        "requirement_ids",
    }
)
_GAP_FIELDS = frozenset({"gap_id", "severity", "affected_ids", "message"})
_APPROVAL_STATES = frozenset({"unreviewed", "approved", "rejected", "stale"})
_SHA256 = re.compile(r"^[0-9a-f]{64}$")


def load_manifest_reference_index(
    manifest: CanonManifest,
    requirement_ids: tuple[str, ...],
    specification_ids: tuple[str, ...],
) -> ImpactReferenceIndex | None:
    if manifest.repository_root is None:
        return None
    path = manifest.repository_root / REFERENCE_INDEX_PATH
    try:
        source_bytes = _read_bytes(path)
    except CanonError as exc:
        if exc.code == "CANON_REFERENCE_INDEX_READ" and not os.path.lexists(path):
            raise CanonError(
                "CANON_REFERENCE_INDEX_MISSING",
                "repository-backed canon requires the fixed impact reference index",
                path,
            ) from exc
        raise
    return parse_reference_index_bytes(
        source_bytes,
        path,
        canon_revision=manifest.canon_revision,
        requirement_ids=requirement_ids,
        specification_ids=specification_ids,
    )


def parse_reference_index_bytes(
    source_bytes: bytes,
    source_path: Path,
    *,
    canon_revision: int,
    requirement_ids: tuple[str, ...],
    specification_ids: tuple[str, ...] = (),
) -> ImpactReferenceIndex:
    try:
        raw = json.loads(source_bytes.decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise _schema_error(source_path, "invalid UTF-8 reference index JSON") from exc
    if not isinstance(raw, dict) or set(raw) != _TOP_FIELDS:
        raise _schema_error(source_path, "reference index top-level fields are closed")
    schema_version = _integer(raw["schema_version"], source_path, "schema_version")
    revision = _integer(raw["canon_revision"], source_path, "canon_revision")
    if schema_version != 1:
        raise _schema_error(source_path, "reference index schema_version must be 1")
    indexed_ids = _string_list(
        raw["indexed_requirement_ids"],
        source_path,
        "indexed_requirement_ids",
        allow_empty=True,
    )
    expected_ids = tuple(sorted(requirement_ids))
    if revision != canon_revision or indexed_ids != expected_ids:
        raise CanonError(
            "CANON_REFERENCE_INDEX_STALE",
            "reference index revision or active requirement IDs are stale",
            source_path,
        )
    references = _parse_authority_references(raw["authority_references"], source_path)
    task_packs = _parse_task_packs(raw["task_packs"], source_path)
    gaps = _parse_gaps(raw["specification_gaps"], source_path)
    _validate_nested_records(
        references,
        task_packs,
        gaps,
        source_path,
        canon_revision=canon_revision,
        requirement_ids=expected_ids,
        specification_ids=tuple(sorted(specification_ids)),
    )
    return ImpactReferenceIndex(
        schema_version=1,
        complete=True,
        authority_references=references,
        task_packs=task_packs,
        specification_gaps=gaps,
        canon_revision=revision,
        indexed_requirement_ids=indexed_ids,
        source_path=source_path,
        source_bytes=source_bytes,
        source_sha=hashlib.sha256(source_bytes).hexdigest(),
    )


def validate_reference_index_provenance(
    index: ImpactReferenceIndex,
    *,
    canon_revision: int,
    requirement_ids: tuple[str, ...],
    specification_ids: tuple[str, ...] = (),
) -> None:
    if index.source_bytes is None or index.source_path is None:
        raise CanonError(
            "CANON_IMPACT_REFERENCE_INDEX_REQUIRED",
            "reference index lacks pinned source provenance",
        )
    parsed = parse_reference_index_bytes(
        index.source_bytes,
        index.source_path,
        canon_revision=canon_revision,
        requirement_ids=requirement_ids,
        specification_ids=specification_ids,
    )
    if parsed != index or parsed.source_sha != index.source_sha:
        raise CanonError(
            "CANON_IMPACT_REFERENCE_INDEX_REQUIRED",
            "reference index does not match its pinned source provenance",
            index.source_path,
        )


def _parse_authority_references(value: object, path: Path) -> tuple[AuthorityReference, ...]:
    rows = _object_list(value, path, "authority_references")
    parsed: list[AuthorityReference] = []
    for row in rows:
        if not _AUTHORITY_REQUIRED <= set(row) or not set(row) <= _AUTHORITY_ALLOWED:
            raise _schema_error(path, "authority reference fields are closed")
        try:
            authority_class = AuthorityClass(_string(row["authority_class"], path, "authority_class"))
            reference_kind = AuthorityReferenceKind(_string(row["reference_kind"], path, "reference_kind"))
        except ValueError as exc:
            raise _schema_error(path, "authority class or reference kind is invalid") from exc
        approval_state = _string(row["approval_state"], path, "approval_state")
        if approval_state not in _APPROVAL_STATES:
            raise _schema_error(path, "approval_state is invalid")
        if not _kind_matches(authority_class, reference_kind):
            raise _schema_error(path, "authority class does not match reference kind")
        parsed.append(
            AuthorityReference(
                schema_version=_integer(row["schema_version"], path, "schema_version"),
                reference_id=_string(row["reference_id"], path, "reference_id"),
                authority_class=authority_class,
                reference_kind=reference_kind,
                source=_string(row["source"], path, "source"),
                revision=_string(row["revision"], path, "revision"),
                requirement_ids=_string_list(row["requirement_ids"], path, "requirement_ids", allow_empty=False),
                approval_state=approval_state,
                approved_by=_optional_string(row.get("approved_by"), path, "approved_by"),
                implementation_status=_optional_string(row.get("implementation_status"), path, "implementation_status"),
            )
        )
    return _ordered_unique(parsed, "reference_id", path, "authority reference")


def _parse_task_packs(value: object, path: Path) -> tuple[TaskPackReference, ...]:
    rows = _object_list(value, path, "task_packs")
    parsed: list[TaskPackReference] = []
    for row in rows:
        if set(row) != _PACK_FIELDS:
            raise _schema_error(path, "task-pack reference fields are closed")
        sha = _string(row["canon_sha"], path, "canon_sha")
        if _SHA256.fullmatch(sha) is None:
            raise _schema_error(path, "task-pack canon_sha is invalid")
        parsed.append(
            TaskPackReference(
                schema_version=_integer(row["schema_version"], path, "schema_version"),
                pack_id=_string(row["pack_id"], path, "pack_id"),
                source=_string(row["source"], path, "source"),
                canon_revision=_integer(row["canon_revision"], path, "canon_revision"),
                canon_sha=sha,
                requirement_ids=_string_list(row["requirement_ids"], path, "requirement_ids", allow_empty=False),
            )
        )
    return _ordered_unique(parsed, "pack_id", path, "task-pack reference")


def _parse_gaps(value: object, path: Path) -> tuple[SpecificationGapRecord, ...]:
    rows = _object_list(value, path, "specification_gaps")
    parsed: list[SpecificationGapRecord] = []
    for row in rows:
        if set(row) != _GAP_FIELDS:
            raise _schema_error(path, "specification-gap fields are closed")
        try:
            severity = GapSeverity(_string(row["severity"], path, "severity"))
        except ValueError as exc:
            raise _schema_error(path, "specification-gap severity is invalid") from exc
        parsed.append(
            SpecificationGapRecord(
                gap_id=_string(row["gap_id"], path, "gap_id"),
                severity=severity,
                affected_ids=_string_list(row["affected_ids"], path, "affected_ids", allow_empty=False),
                message=_string(row["message"], path, "message"),
            )
        )
    return _ordered_unique(parsed, "gap_id", path, "specification gap")


def _validate_nested_records(
    references: tuple[AuthorityReference, ...],
    task_packs: tuple[TaskPackReference, ...],
    gaps: tuple[SpecificationGapRecord, ...],
    path: Path,
    *,
    canon_revision: int,
    requirement_ids: tuple[str, ...],
    specification_ids: tuple[str, ...],
) -> None:
    requirements = set(requirement_ids)
    active_ids = requirements | set(specification_ids)
    for reference in references:
        if reference.schema_version != 1:
            raise _schema_error(path, "authority reference schema_version must be 1")
        _require_known_ids(
            reference.requirement_ids,
            requirements,
            path,
            label="authority reference requirement_ids",
        )
    for task_pack in task_packs:
        if task_pack.schema_version != 1:
            raise _schema_error(path, "task-pack schema_version must be 1")
        if task_pack.canon_revision != canon_revision:
            raise CanonError(
                "CANON_REFERENCE_INDEX_STALE",
                "task-pack canon_revision does not match the active canon revision",
                path,
            )
        _require_known_ids(
            task_pack.requirement_ids,
            active_ids,
            path,
            label="task-pack canonical IDs",
        )
    for gap in gaps:
        _require_known_ids(
            gap.affected_ids,
            active_ids,
            path,
            label="specification-gap affected_ids",
        )

    record_ids = tuple(
        [item.reference_id for item in references]
        + [item.pack_id for item in task_packs]
        + [item.gap_id for item in gaps]
    )
    if len(record_ids) != len(set(record_ids)) or active_ids & set(record_ids):
        raise _schema_error(
            path,
            "reference-index record IDs must be unique and distinct from active canon IDs",
        )


def _require_known_ids(
    identifiers: tuple[str, ...],
    allowed: set[str],
    path: Path,
    *,
    label: str,
) -> None:
    unknown = tuple(sorted(set(identifiers) - allowed))
    if unknown:
        raise CanonError(
            "CANON_REFERENCE_INDEX_UNKNOWN_ID",
            f"{label} contains an unknown active ID: {unknown[0]}",
            path,
        )


def _read_bytes(path: Path) -> bytes:
    try:
        descriptor = _open_file_nofollow(path)
        try:
            chunks: list[bytes] = []
            while True:
                chunk = os.read(descriptor, 64 * 1024)
                if not chunk:
                    return b"".join(chunks)
                chunks.append(chunk)
        finally:
            os.close(descriptor)
    except OSError as exc:
        raise CanonError("CANON_REFERENCE_INDEX_READ", "unable to read impact reference index", path) from exc


def _object_list(value: object, path: Path, field: str) -> list[dict[str, object]]:
    if not isinstance(value, list) or not all(isinstance(item, dict) for item in value):
        raise _schema_error(path, f"{field} must be an object list")
    return value


def _string(value: object, path: Path, field: str) -> str:
    if not isinstance(value, str) or not value or value != value.strip():
        raise _schema_error(path, f"{field} must be a non-empty trimmed string")
    return value


def _optional_string(value: object, path: Path, field: str) -> str | None:
    return None if value is None else _string(value, path, field)


def _integer(value: object, path: Path, field: str) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        raise _schema_error(path, f"{field} must be a non-negative integer")
    return value


def _string_list(value: object, path: Path, field: str, *, allow_empty: bool) -> tuple[str, ...]:
    if not isinstance(value, list) or (not value and not allow_empty):
        raise _schema_error(path, f"{field} must be a string list")
    result = tuple(_string(item, path, field) for item in value)
    if result != tuple(sorted(set(result))):
        raise _schema_error(path, f"{field} must be sorted and unique")
    return result


def _ordered_unique(values, field: str, path: Path, label: str):
    ordered = tuple(sorted(values, key=lambda item: getattr(item, field)))
    identities = [getattr(item, field) for item in values]
    if tuple(values) != ordered or len(identities) != len(set(identities)):
        raise _schema_error(path, f"{label} records must be sorted and unique")
    return ordered


def _kind_matches(authority_class: AuthorityClass, kind: AuthorityReferenceKind) -> bool:
    if kind is AuthorityReferenceKind.FIGMA:
        return authority_class is AuthorityClass.FIGMA
    if kind is AuthorityReferenceKind.LINEAR:
        return authority_class is AuthorityClass.LINEAR
    return authority_class is AuthorityClass.SOURCE_AND_TESTS


def _schema_error(path: Path, message: str) -> CanonError:
    return CanonError("CANON_REFERENCE_INDEX_SCHEMA", message, path)
