"""Lossless, offline provenance registration for canon migration sources."""

from __future__ import annotations

import ctypes
import errno
import hashlib
import json
import os
import re
import stat
import subprocess
import sys
from collections.abc import Callable, Mapping, Sequence
from contextlib import contextmanager
from dataclasses import dataclass, field, replace
from pathlib import Path
from typing import Never

from tools.ambitions_canon.build import (
    _normalized_absolute,
    _open_directory_absolute_nofollow,
    _open_parent_nofollow,
    _read_descriptor,
    _rename_noreplace,
)
from tools.ambitions_canon.model import (
    AtomicClaim,
    CanonError,
    ClaimDisposition,
    ClaimTargetClass,
    Finding,
    GapSeverity,
    Modality,
)
from tools.ambitions_canon.render import stable_json


SOURCE_KINDS = frozenset({"repo", "linear", "figma", "source", "test", "proof"})
TRACKED_SOURCE_KINDS = frozenset({"repo", "source", "test", "proof"})
RAW_SOURCE_KINDS = frozenset({"linear", "figma"})
DIRECTORY_FLAGS = (
    os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0)
)
DARWIN_RENAME_SWAP = 0x00000002
LINUX_RENAME_EXCHANGE = 0x00000002
METADATA_FIELDS = frozenset(
    {
        "source_id",
        "kind",
        "title",
        "locator",
        "updated_at",
        "owner",
        "authority_claim",
    }
)
RECORD_FIELDS = METADATA_FIELDS | frozenset(
    {
        "raw_path",
        "raw_sha256",
        "raw_byte_length",
        "repo_path",
        "content_sha256",
        "repository_revision",
    }
)
RAW_FIELDS = frozenset({"raw_path", "raw_sha256", "raw_byte_length"})
REPO_FIELDS = frozenset({"repo_path", "content_sha256", "repository_revision"})
CLAIM_FIELDS = frozenset(
    {
        "claim_id",
        "source_id",
        "source_location",
        "original_text",
        "concept",
        "subject",
        "predicate",
        "value",
        "modality",
        "scope",
        "conditions",
        "exceptions",
        "authority_claim",
        "owner_approval",
        "disposition",
        "target_id",
        "target_class",
        "rationale",
    }
)
DECISION_CLAIM_FIELDS = frozenset({"owner_evidence_text", "owner_evidence_rationale"})
CLAIM_BATCH_FIELDS = frozenset(
    {"schema_version", "batch_id", "claims", "source_section_dispositions"}
)
SECTION_DISPOSITION_FIELDS = frozenset(
    {"source_id", "source_location", "disposition", "rationale"}
)
TARGET_REQUIRED_DISPOSITIONS = frozenset(
    {ClaimDisposition.KEEP, ClaimDisposition.REWRITE, ClaimDisposition.COMPOSE}
)
TARGET_CLASSES = frozenset(
    {
        ClaimTargetClass.CONSTITUTION,
        ClaimTargetClass.SPECIFICATION,
        ClaimTargetClass.STANDARD,
    }
)
CLAIM_ID_PATTERN = re.compile(r"^[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+$")
TARGET_ID_PATTERN = re.compile(r"^[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+$")
CONCEPT_PATTERN = re.compile(r"^[a-z0-9]+(?:[._-][a-z0-9]+)*$")
LINE_LOCATION_PATTERN = re.compile(r"^line:([1-9][0-9]*)$")
DECISION_LOCATION_PATTERN = re.compile(r"^decision:([1-9][0-9]*)$")
DECISION_EVIDENCE_PATTERN = re.compile(
    r"^linear-(?:comment|ledger):[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-"
    r"[0-9a-f]{4}-[0-9a-f]{12}:decision:([1-9][0-9]*)$"
)
UUID_PATTERN = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
)
MARKDOWN_HEADING_PATTERN = re.compile(r"^#{1,6}[ \t]+\S")
TRACKED_CLAIM_FIELDS = frozenset(
    {
        "authority_claim",
        "claim_id",
        "concept",
        "decision_mapping_status",
        "disposition",
        "owner_approval_sha256",
        "owner_evidence_rationale_sha256",
        "owner_evidence_text_sha256",
        "rationale_sha256",
        "source_id",
        "source_location",
        "target_class",
        "target_id",
    }
)
TRACKED_COVERAGE_FIELDS = frozenset(
    {
        "claim_ids",
        "disposition",
        "rationale_sha256",
        "source_id",
        "source_location",
    }
)
TRACKED_DISPOSITION_FIELDS = frozenset(
    {
        "catalog_sha256",
        "claims",
        "coverage",
        "decision_evidence_sha256",
        "decision_mapping_counts",
        "linear_decision_count",
        "schema_version",
        "section_count",
        "semantic_groups",
        "source_count",
        "uncovered",
    }
)


@dataclass(frozen=True, slots=True)
class TrackedCanonEvidenceSnapshot:
    """Closed tracked migration evidence usable without raw source snapshots."""

    source_catalog_bytes: bytes
    claim_dispositions_bytes: bytes
    conflict_baseline_bytes: bytes
    source_count: int
    claim_count: int
    section_count: int
    linear_decision_count: int
    decision_evidence_fingerprint_sha256: str | None


@dataclass(frozen=True, slots=True)
class SourceRecord:
    """One closed, immutable source-provenance record."""

    source_id: str
    kind: str
    title: str
    locator: str
    updated_at: str
    owner: str
    authority_claim: str
    raw_path: str | None = None
    raw_sha256: str | None = None
    raw_byte_length: int | None = None
    repo_path: str | None = None
    content_sha256: str | None = None
    repository_revision: str | None = None
    bound_repository_root: Path | None = field(
        default=None,
        compare=False,
        repr=False,
    )

    @classmethod
    def from_dict(cls, value: object, path: Path | None = None) -> "SourceRecord":
        if not isinstance(value, dict) or set(value) - RECORD_FIELDS:
            raise CanonError(
                "MIGRATION_CATALOG_INVALID",
                "source record must be an object with only supported fields",
                path,
            )
        metadata = {field: value.get(field) for field in METADATA_FIELDS}
        _validate_metadata(metadata, path, code="MIGRATION_CATALOG_INVALID")
        kind = str(metadata["kind"])
        if kind in TRACKED_SOURCE_KINDS:
            if (
                any(field in value for field in RAW_FIELDS)
                or set(value) != METADATA_FIELDS | REPO_FIELDS
            ):
                raise CanonError(
                    "MIGRATION_CATALOG_INVALID",
                    "repo source must contain exactly the repo provenance fields",
                    path,
                )
            repo_path = _required_string(value, "repo_path", path)
            content_sha256 = _required_sha(value, "content_sha256", path)
            repository_revision = _required_git_revision(
                value, "repository_revision", path
            )
            return cls(
                **metadata,
                repo_path=repo_path,
                content_sha256=content_sha256,
                repository_revision=repository_revision,
            )
        if (
            any(field in value for field in REPO_FIELDS)
            or set(value) != METADATA_FIELDS | RAW_FIELDS
        ):
            raise CanonError(
                "MIGRATION_CATALOG_INVALID",
                "non-repo source must contain exactly the raw provenance fields",
                path,
            )
        raw_path = _required_string(value, "raw_path", path)
        raw_sha256 = _required_sha(value, "raw_sha256", path)
        raw_byte_length = value.get("raw_byte_length")
        if (
            not isinstance(raw_byte_length, int)
            or isinstance(raw_byte_length, bool)
            or raw_byte_length < 0
        ):
            raise CanonError(
                "MIGRATION_CATALOG_INVALID",
                "raw_byte_length must be a non-negative integer",
                path,
            )
        return cls(
            **metadata,
            raw_path=raw_path,
            raw_sha256=raw_sha256,
            raw_byte_length=raw_byte_length,
        )

    def to_dict(self) -> dict[str, object]:
        result: dict[str, object] = {
            "source_id": self.source_id,
            "kind": self.kind,
            "title": self.title,
            "locator": self.locator,
            "updated_at": self.updated_at,
            "owner": self.owner,
            "authority_claim": self.authority_claim,
        }
        if self.kind in TRACKED_SOURCE_KINDS:
            result.update(
                {
                    "repo_path": self.repo_path,
                    "content_sha256": self.content_sha256,
                    "repository_revision": self.repository_revision,
                }
            )
        else:
            result.update(
                {
                    "raw_path": self.raw_path,
                    "raw_sha256": self.raw_sha256,
                    "raw_byte_length": self.raw_byte_length,
                }
            )
        return result


@dataclass(frozen=True, slots=True)
class _RepoSnapshot:
    pathspecs: tuple[str, ...]
    index_entries: bytes
    content_sha256: tuple[tuple[str, str], ...]


@dataclass(frozen=True, slots=True)
class _IndexEntry:
    path: str
    mode: str
    object_id: str


@dataclass(frozen=True, slots=True)
class _CatalogAncestryLink:
    parent_descriptor: int
    name: str
    identity: tuple[int, int]


@dataclass(frozen=True, slots=True)
class _CatalogTransactionArtifact:
    name: str
    preimage_sha256: str
    content_sha256: str
    identity: tuple[int, int]
    owner_catalog_name: str
    owner_catalog_identity: tuple[int, int] | None


@dataclass(frozen=True, slots=True)
class _CatalogTransactionCandidate:
    owner_catalog_name: str
    preimage_sha256: str
    content_sha256: str


@dataclass(frozen=True, slots=True)
class _CreatedCatalogDirectory:
    parent_descriptor: int
    descriptor: int
    original_name: str
    identity: tuple[int, int]


@dataclass(slots=True)
class _CatalogParentTransaction:
    created_directories: list[_CreatedCatalogDirectory]
    committed: bool = False


def register_source(
    catalog_path: Path,
    raw_path: Path,
    metadata: Mapping[str, object],
) -> SourceRecord:
    """Register exact ignored UTF-8 bytes without copying their content."""

    catalog_path = Path(catalog_path)
    raw_path = Path(raw_path)
    normalized_metadata = _validate_metadata(metadata, catalog_path)
    root = _repository_root(catalog_path.parent)
    if normalized_metadata["kind"] not in RAW_SOURCE_KINDS:
        raise CanonError(
            "MIGRATION_METADATA_INVALID",
            "only Linear and Figma use ignored raw registration; tracked kinds use repo registration",
            catalog_path,
        )
    relative_raw = _validate_raw_path(root, raw_path)
    raw = _read_regular_nofollow(raw_path, "MIGRATION_RAW_PATH_UNSAFE")
    try:
        raw.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise CanonError(
            "MIGRATION_RAW_UTF8_INVALID",
            "migration raw source must be exact UTF-8 bytes",
            relative_raw,
        ) from exc
    record = SourceRecord(
        **normalized_metadata,
        raw_path=relative_raw.as_posix(),
        raw_sha256=hashlib.sha256(raw).hexdigest(),
        raw_byte_length=len(raw),
        bound_repository_root=root,
    )
    _append_records(
        catalog_path,
        (record,),
        precondition=lambda: _require_raw_snapshot(record, root),
    )
    return record


def register_repo_sources(
    catalog_path: Path,
    repo_root: Path,
    pathspecs: Sequence[str],
) -> tuple[SourceRecord, ...]:
    """Register clean tracked repo files directly, without copying content."""

    catalog_path = Path(catalog_path)
    repo_root = Path(repo_root)
    actual_root = _repository_root(repo_root)
    if Path(os.path.realpath(repo_root)) != Path(os.path.realpath(actual_root)):
        raise CanonError(
            "MIGRATION_REPO_INVALID",
            "repo_root must be the Git worktree root",
            repo_root,
        )
    if not pathspecs or any(
        not isinstance(item, str) or not item.strip() for item in pathspecs
    ):
        raise CanonError(
            "MIGRATION_REPO_INVALID",
            "at least one nonblank pathspec is required",
            repo_root,
        )
    normalized_pathspecs = tuple(pathspecs)
    _require_clean_pathspec_state(actual_root, normalized_pathspecs)
    output = _git(actual_root, "ls-files", "-z", "--", *pathspecs)
    paths = tuple(
        sorted({item.decode("utf-8", "strict") for item in output.split(b"\0") if item})
    )
    if not paths:
        raise CanonError(
            "MIGRATION_REPO_NO_MATCH",
            "repo pathspecs did not match any tracked source",
            actual_root,
        )
    index_entries_raw = _git(
        actual_root,
        "ls-files",
        "--stage",
        "-z",
        "--",
        *normalized_pathspecs,
    )
    index_entries = _parse_index_entries(index_entries_raw, actual_root)
    if tuple(sorted(index_entries)) != paths:
        raise CanonError(
            "MIGRATION_REPO_DIRTY",
            "tracked path enumeration differs from stage-zero index entries",
            actual_root,
        )
    records: list[SourceRecord] = []
    for path_text in paths:
        relative = Path(path_text)
        _validate_repo_relative_path(relative, actual_root)
        if _repo_path_dirty(actual_root, path_text):
            raise CanonError(
                "MIGRATION_REPO_DIRTY",
                f"tracked repo source is dirty: {path_text}",
                relative,
            )
        absolute = actual_root / relative
        content = _read_regular_nofollow(absolute, "MIGRATION_REPO_PATH_UNSAFE")
        _require_worktree_matches_index(
            actual_root,
            index_entries[path_text],
            content,
            code="MIGRATION_REPO_DIRTY",
        )
        revision = (
            _git(
                actual_root,
                "log",
                "-1",
                "--format=%H",
                "--",
                path_text,
            )
            .decode("ascii")
            .strip()
        )
        updated_at = (
            _git(
                actual_root,
                "log",
                "-1",
                "--format=%cI",
                "--",
                path_text,
            )
            .decode("utf-8")
            .strip()
        )
        owner = (
            _git(
                actual_root,
                "log",
                "-1",
                "--format=%an",
                "--",
                path_text,
            )
            .decode("utf-8")
            .strip()
        )
        if not revision or not updated_at or not owner:
            raise CanonError(
                "MIGRATION_REPO_PROVENANCE",
                f"tracked repo source lacks commit provenance: {path_text}",
                relative,
            )
        source_id = (
            "REPO-" + hashlib.sha256(path_text.encode("utf-8")).hexdigest()[:24].upper()
        )
        records.append(
            SourceRecord(
                source_id=source_id,
                kind="repo",
                title=path_text,
                locator=f"repo:{path_text}",
                updated_at=updated_at,
                owner=owner,
                authority_claim=(
                    "current tracked repo authority provenance under the active "
                    "authority hierarchy; not a standalone product or implementation proof"
                ),
                repo_path=path_text,
                content_sha256=hashlib.sha256(content).hexdigest(),
                repository_revision=revision,
                bound_repository_root=actual_root,
            )
        )
    snapshot = _RepoSnapshot(
        pathspecs=normalized_pathspecs,
        index_entries=index_entries_raw,
        content_sha256=tuple(
            (record.repo_path, record.content_sha256)
            for record in records
            if record.repo_path is not None and record.content_sha256 is not None
        ),
    )
    _append_records(
        catalog_path,
        tuple(records),
        precondition=lambda: _require_repo_snapshot(actual_root, snapshot),
    )
    return tuple(records)


def load_source_catalog(catalog_path: Path) -> tuple[SourceRecord, ...]:
    """Load and validate one closed source catalog without following links."""

    path = Path(catalog_path)
    raw = _read_catalog_bytes(path, allow_missing=False)
    assert raw is not None
    records = _parse_catalog_bytes(raw, path)
    root = _repository_root(path.parent)
    return tuple(replace(record, bound_repository_root=root) for record in records)


def _parse_catalog_bytes(raw: bytes, path: Path) -> tuple[SourceRecord, ...]:
    try:
        payload = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise CanonError(
            "MIGRATION_CATALOG_INVALID",
            "source catalog must be valid UTF-8 JSON",
            path,
        ) from exc
    _validate_json_utf8_strings(payload, path)
    if not isinstance(payload, dict) or set(payload) != {"schema_version", "sources"}:
        raise CanonError(
            "MIGRATION_CATALOG_INVALID",
            "source catalog root must contain exactly schema_version and sources",
            path,
        )
    if payload["schema_version"] != 1 or isinstance(payload["schema_version"], bool):
        raise CanonError(
            "MIGRATION_CATALOG_INVALID",
            "source catalog schema_version must equal 1",
            path,
        )
    sources = payload["sources"]
    if not isinstance(sources, list):
        raise CanonError(
            "MIGRATION_CATALOG_INVALID",
            "source catalog sources must be an array",
            path,
        )
    records = tuple(SourceRecord.from_dict(item, path) for item in sources)
    _validate_unique_records(records, path)
    if tuple(sorted(records, key=lambda item: item.source_id)) != records:
        raise CanonError(
            "MIGRATION_CATALOG_INVALID",
            "source catalog records must be sorted by source_id",
            path,
        )
    return records


def _read_catalog_bytes(path: Path, *, allow_missing: bool) -> bytes | None:
    try:
        with _open_parent_nofollow(path) as (parent_descriptor, name, _absolute):
            raw, _identity = _read_catalog_at(
                parent_descriptor,
                name,
                path,
                allow_missing=allow_missing,
            )
            return raw
    except CanonError as exc:
        if exc.code == "MIGRATION_CATALOG_MISSING":
            raise
        if _catalog_ancestry_missing(path):
            if allow_missing:
                return None
            raise CanonError(
                "MIGRATION_CATALOG_MISSING",
                "source catalog does not exist",
                path,
            ) from exc
        raise CanonError(
            "MIGRATION_CATALOG_PATH_UNSAFE",
            "catalog path must have no symlink ancestry",
            path,
        ) from exc
    except OSError as exc:
        raise CanonError(
            "MIGRATION_CATALOG_PATH_UNSAFE",
            "catalog path must be a regular file with no symlink ancestry",
            path,
        ) from exc


def _read_catalog_at(
    parent_descriptor: int,
    name: str,
    path: Path,
    *,
    allow_missing: bool,
) -> tuple[bytes | None, tuple[int, int] | None]:
    try:
        descriptor = os.open(
            name,
            os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0),
            dir_fd=parent_descriptor,
        )
    except FileNotFoundError as exc:
        if allow_missing:
            return None, None
        raise CanonError(
            "MIGRATION_CATALOG_MISSING",
            "source catalog does not exist",
            path,
        ) from exc
    except OSError as exc:
        raise CanonError(
            "MIGRATION_CATALOG_PATH_UNSAFE",
            "catalog must be a regular file and not a symlink",
            path,
        ) from exc
    try:
        info = os.fstat(descriptor)
        if not stat.S_ISREG(info.st_mode):
            raise CanonError(
                "MIGRATION_CATALOG_PATH_UNSAFE",
                "catalog must be a regular file",
                path,
            )
        return _read_descriptor(descriptor), (info.st_dev, info.st_ino)
    finally:
        os.close(descriptor)


def _catalog_ancestry_missing(path: Path) -> bool:
    absolute = _normalized_absolute(path)
    current = Path(absolute.anchor)
    for component in absolute.parts[1:-1]:
        current /= component
        try:
            info = current.lstat()
        except FileNotFoundError:
            return True
        if stat.S_ISLNK(info.st_mode) or not stat.S_ISDIR(info.st_mode):
            return False
    return False


def _valid_source_record(record: object) -> bool:
    if not isinstance(record, SourceRecord):
        return False
    try:
        _validate_metadata(
            {
                "source_id": record.source_id,
                "kind": record.kind,
                "title": record.title,
                "locator": record.locator,
                "updated_at": record.updated_at,
                "owner": record.owner,
                "authority_claim": record.authority_claim,
            },
            code="MIGRATION_SOURCE_INVALID",
        )
    except CanonError:
        return False
    if (
        not isinstance(record.bound_repository_root, Path)
        or not record.bound_repository_root.is_absolute()
    ):
        return False
    if record.kind in TRACKED_SOURCE_KINDS:
        return (
            _canonical_relative_source_path(record.repo_path)
            and _valid_sha256(record.content_sha256)
            and _valid_git_object_id(record.repository_revision)
            and record.raw_path is None
            and record.raw_sha256 is None
            and record.raw_byte_length is None
        )
    if record.kind in RAW_SOURCE_KINDS:
        return (
            _canonical_relative_source_path(record.raw_path)
            and record.raw_path is not None
            and record.raw_path.startswith(".codex/canon-migration/")
            and _valid_sha256(record.raw_sha256)
            and isinstance(record.raw_byte_length, int)
            and not isinstance(record.raw_byte_length, bool)
            and record.raw_byte_length >= 0
            and record.repo_path is None
            and record.content_sha256 is None
            and record.repository_revision is None
        )
    return False


def _canonical_relative_source_path(value: object) -> bool:
    if not isinstance(value, str) or not value:
        return False
    path = Path(value)
    return (
        not path.is_absolute()
        and path.as_posix() == value
        and all(part not in ("", ".", "..") for part in path.parts)
    )


def _valid_sha256(value: object) -> bool:
    return (
        isinstance(value, str)
        and len(value) == 64
        and all(character in "0123456789abcdef" for character in value)
    )


def _valid_git_object_id(value: object) -> bool:
    return (
        isinstance(value, str)
        and len(value) in (40, 64)
        and all(character in "0123456789abcdef" for character in value)
    )


def verify_source(record: object, raw_path: Path) -> tuple[Finding, ...]:
    """Verify one source only at its registered, kind-specific repository path."""

    supplied = Path(raw_path)
    if not _valid_source_record(record):
        return (
            _finding(
                "MIGRATION_SOURCE_INVALID",
                "source record kind and provenance shape are invalid",
                supplied,
            ),
        )
    assert isinstance(record, SourceRecord)
    root = record.bound_repository_root
    if root is None:
        return (
            _finding(
                "MIGRATION_SOURCE_PATH_MISMATCH",
                "source record is not bound to its canonical repository root",
                supplied,
            ),
        )
    registered_path = (
        record.repo_path if record.kind in TRACKED_SOURCE_KINDS else record.raw_path
    )
    if registered_path is None:
        return (
            _finding(
                "MIGRATION_SOURCE_INVALID",
                "source record does not contain provenance for its kind",
                supplied,
            ),
        )
    expected = _normalized_absolute(root / registered_path)
    actual = _normalized_absolute(supplied)
    if actual != expected:
        return (
            _finding(
                "MIGRATION_SOURCE_PATH_MISMATCH",
                "source must be verified only at its exact registered path",
                supplied,
            ),
        )
    if record.kind in TRACKED_SOURCE_KINDS:
        tracked = _git_result(
            root,
            "ls-files",
            "--error-unmatch",
            "--",
            registered_path,
        )
        if tracked.returncode != 0:
            return (
                _finding(
                    "MIGRATION_REPO_NOT_TRACKED",
                    "registered repo source is missing from the Git index",
                    Path(registered_path),
                ),
            )
        try:
            _require_clean_pathspec_state(root, (registered_path,))
        except CanonError:
            return (
                _finding(
                    "MIGRATION_REPO_DIRTY",
                    "registered repo source has staged or worktree changes",
                    Path(registered_path),
                ),
            )
        try:
            content = _read_regular_nofollow(
                expected,
                "MIGRATION_REPO_PATH_UNSAFE",
            )
        except CanonError as error:
            return (_finding(error.code, error.message, error.path or expected),)
        if hashlib.sha256(content).hexdigest() != record.content_sha256:
            return (
                _finding(
                    "MIGRATION_REPO_CHECKSUM_MISMATCH",
                    "registered repo source content changed",
                    Path(registered_path),
                ),
            )
        return ()
    try:
        relative = _validate_raw_path(root, expected)
        if relative.as_posix() != record.raw_path:
            raise CanonError(
                "MIGRATION_RAW_PATH_UNSAFE",
                "registered raw path is not canonical",
                expected,
            )
        raw = _read_regular_nofollow(expected, "MIGRATION_RAW_PATH_UNSAFE")
        raw.decode("utf-8")
    except (CanonError, UnicodeDecodeError):
        return (
            _finding(
                "MIGRATION_RAW_UNREADABLE",
                "registered raw source is missing, unsafe, or not UTF-8",
                supplied,
            ),
        )
    if len(raw) != record.raw_byte_length:
        return (
            _finding(
                "MIGRATION_RAW_CHECKSUM_MISMATCH",
                "registered raw source byte length or checksum changed",
                supplied,
            ),
        )
    if hashlib.sha256(raw).hexdigest() != record.raw_sha256:
        return (
            _finding(
                "MIGRATION_RAW_CHECKSUM_MISMATCH",
                "registered raw source byte length or checksum changed",
                supplied,
            ),
        )
    return ()


def verify_catalog(
    catalog_path: Path, repo_root: Path | None = None
) -> tuple[Finding, ...]:
    """Verify every catalog source offline against local exact bytes or Git."""

    catalog_path = Path(catalog_path)
    try:
        records = load_source_catalog(catalog_path)
        root = _repository_root(repo_root or catalog_path.parent)
    except CanonError as error:
        return (_finding(error.code, error.message, error.path or catalog_path),)
    findings: list[Finding] = []
    for record in records:
        registered_path = (
            record.repo_path if record.kind in TRACKED_SOURCE_KINDS else record.raw_path
        )
        if registered_path is None:
            findings.append(
                _finding(
                    "MIGRATION_SOURCE_INVALID",
                    "source record does not contain provenance for its kind",
                    catalog_path,
                )
            )
            continue
        findings.extend(verify_source(record, root / registered_path))
    return tuple(
        sorted(
            findings, key=lambda item: (item.code, str(item.path or ""), item.message)
        )
    )


def _validate_metadata(
    metadata: Mapping[str, object],
    path: Path | None = None,
    *,
    code: str = "MIGRATION_METADATA_INVALID",
) -> dict[str, str]:
    if not isinstance(metadata, Mapping) or set(metadata) != METADATA_FIELDS:
        raise CanonError(
            code, "source metadata must contain exactly the required fields", path
        )
    normalized: dict[str, str] = {}
    for field_name in sorted(METADATA_FIELDS):
        value = metadata[field_name]
        if not isinstance(value, str) or not value.strip() or value != value.strip():
            raise CanonError(
                code,
                f"{field_name} must be a nonblank trimmed string",
                path,
            )
        _require_utf8_string(value, path, code)
        normalized[field_name] = value
    if normalized["kind"] not in SOURCE_KINDS:
        raise CanonError(
            code, f"kind must be one of: {', '.join(sorted(SOURCE_KINDS))}", path
        )
    return normalized


def _required_string(value: Mapping[str, object], field: str, path: Path | None) -> str:
    item = value.get(field)
    if not isinstance(item, str) or not item or item != item.strip():
        raise CanonError(
            "MIGRATION_CATALOG_INVALID",
            f"{field} must be a nonblank trimmed string",
            path,
        )
    _require_utf8_string(item, path, "MIGRATION_CATALOG_INVALID")
    return item


def _require_utf8_string(value: str, path: Path | None, code: str) -> None:
    try:
        value.encode("utf-8", errors="strict")
    except UnicodeEncodeError as exc:
        raise CanonError(code, "all source strings must be strict UTF-8", path) from exc


def _validate_json_utf8_strings(value: object, path: Path) -> None:
    if isinstance(value, str):
        _require_utf8_string(value, path, "MIGRATION_CATALOG_INVALID")
        return
    if isinstance(value, list):
        for item in value:
            _validate_json_utf8_strings(item, path)
        return
    if isinstance(value, dict):
        for key, item in value.items():
            if isinstance(key, str):
                _require_utf8_string(key, path, "MIGRATION_CATALOG_INVALID")
            _validate_json_utf8_strings(item, path)


def _required_sha(value: Mapping[str, object], field: str, path: Path | None) -> str:
    item = _required_string(value, field, path)
    if len(item) != 64 or any(
        character not in "0123456789abcdef" for character in item
    ):
        raise CanonError(
            "MIGRATION_CATALOG_INVALID", f"{field} must be a lowercase SHA-256", path
        )
    return item


def _required_git_revision(
    value: Mapping[str, object], field: str, path: Path | None
) -> str:
    item = _required_string(value, field, path)
    if len(item) not in (40, 64) or any(
        character not in "0123456789abcdef" for character in item
    ):
        raise CanonError(
            "MIGRATION_CATALOG_INVALID",
            f"{field} must be a lowercase Git object ID",
            path,
        )
    return item


def _validate_raw_path(root: Path, raw_path: Path) -> Path:
    absolute = Path(os.path.realpath(Path(os.path.abspath(raw_path))))
    canonical_root = Path(os.path.realpath(root))
    migration_root = canonical_root / ".codex/canon-migration"
    try:
        relative_to_migration = absolute.relative_to(migration_root)
        relative = absolute.relative_to(canonical_root)
    except ValueError as exc:
        raise CanonError(
            "MIGRATION_RAW_PATH_UNSAFE",
            "raw source must be below ignored .codex/canon-migration",
            raw_path,
        ) from exc
    if not relative_to_migration.parts or any(
        part in ("", ".", "..") for part in relative.parts
    ):
        raise CanonError(
            "MIGRATION_RAW_PATH_UNSAFE", "raw source path is not canonical", raw_path
        )
    ignored = _git_result(root, "check-ignore", "--quiet", "--", relative.as_posix())
    if ignored.returncode != 0:
        raise CanonError(
            "MIGRATION_RAW_PATH_UNSAFE",
            "raw source path must be ignored by Git",
            relative,
        )
    return relative


def _validate_repo_relative_path(relative: Path, root: Path) -> None:
    if (
        relative.is_absolute()
        or not relative.parts
        or any(part in ("", ".", "..") for part in relative.parts)
    ):
        raise CanonError(
            "MIGRATION_REPO_PATH_UNSAFE", "tracked repo path is not canonical", relative
        )
    absolute = Path(os.path.abspath(root / relative))
    try:
        absolute.relative_to(root)
    except ValueError as exc:
        raise CanonError(
            "MIGRATION_REPO_PATH_UNSAFE",
            "tracked repo path escapes repository",
            relative,
        ) from exc


def _read_regular_nofollow(path: Path, code: str) -> bytes:
    try:
        with _open_parent_nofollow(path) as (parent_descriptor, name, _absolute):
            descriptor = os.open(
                name,
                os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0),
                dir_fd=parent_descriptor,
            )
            try:
                if not stat.S_ISREG(os.fstat(descriptor).st_mode):
                    raise OSError("source is not a regular file")
                return _read_descriptor(descriptor)
            finally:
                os.close(descriptor)
    except (OSError, CanonError) as exc:
        raise CanonError(
            code, "path must be a regular file with no symlink ancestry", path
        ) from exc


def _append_records(
    catalog_path: Path,
    new_records: tuple[SourceRecord, ...],
    *,
    precondition: Callable[[], None] | None = None,
) -> None:
    if precondition is not None:
        precondition()
    root = _repository_root(catalog_path.parent)
    lock_name = f".{catalog_path.name}.lock"
    with _open_or_create_catalog_parent(root, catalog_path) as (
        parent_descriptor,
        name,
        absolute,
        ancestry,
        parent_transaction,
    ):
        try:
            lock_descriptor = os.open(
                lock_name,
                os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, "O_CLOEXEC", 0),
                0o600,
                dir_fd=parent_descriptor,
            )
        except OSError as exc:
            raise CanonError(
                "MIGRATION_CATALOG_BUSY",
                "source catalog update is already in progress",
                absolute,
            ) from exc
        os.close(lock_descriptor)
        recovery_name = f".{name}.recovery-prior"
        transaction_name: str | None = None
        retained_transaction_names: set[str] = set()
        cleanup_transaction = False
        try:
            initial_transactions = _inspect_catalog_transaction_state(
                parent_descriptor,
                name,
                recovery_name,
                absolute,
            )
            existing_bytes, existing_identity = _read_catalog_at(
                parent_descriptor,
                name,
                catalog_path,
                allow_missing=True,
            )
            existing = (
                _parse_catalog_bytes(existing_bytes, catalog_path)
                if existing_bytes is not None
                else ()
            )
            combined = existing + new_records
            _validate_unique_records(combined, catalog_path)
            ordered = tuple(sorted(combined, key=lambda item: item.source_id))
            content = stable_json(
                {"schema_version": 1, "sources": [item.to_dict() for item in ordered]}
            )
            transaction_name = _catalog_transaction_name(
                parent_descriptor,
                name,
                existing_bytes,
                content,
            )
            cleanup_transaction, staging_identity = _prepare_catalog_staging(
                parent_descriptor,
                transaction_name,
                content,
                absolute,
            )
            if precondition is not None:
                precondition()
            _require_catalog_transaction_state(
                parent_descriptor,
                name,
                recovery_name,
                absolute,
                initial_transactions,
                transaction_name,
                content,
                staging_identity,
            )
            cleanup_transaction = _install_catalog_cas(
                parent_descriptor,
                name,
                transaction_name,
                absolute,
                existing_bytes,
                existing_identity,
                content,
                staging_identity,
                ancestry,
                recovery_name,
                retained_transaction_names,
            )
            parent_transaction.committed = True
        except CanonError as exc:
            if (
                exc.code == "MIGRATION_CATALOG_RECOVERY_REQUIRED"
                and exc.path is not None
                and Path(exc.path).parent == absolute.parent
            ):
                retained_transaction_names.add(Path(exc.path).name)
            raise
        except OSError as exc:
            raise CanonError(
                "MIGRATION_CATALOG_WRITE",
                "unable to atomically update source catalog",
                absolute,
            ) from exc
        finally:
            cleanup_names = [lock_name]
            if (
                transaction_name is not None
                and cleanup_transaction
                and transaction_name not in retained_transaction_names
            ):
                cleanup_names.insert(0, transaction_name)
            for cleanup in cleanup_names:
                try:
                    os.unlink(cleanup, dir_fd=parent_descriptor)
                except FileNotFoundError:
                    pass


def _catalog_transaction_name(
    parent_descriptor: int,
    name: str,
    preimage: bytes | None,
    content: bytes,
) -> str:
    preimage_sha = hashlib.sha256(preimage or b"").hexdigest()
    content_sha = hashlib.sha256(content).hexdigest()
    catalog_sha = hashlib.sha256(os.fsencode(name)).hexdigest()
    transaction_name = f".canon-txn-{catalog_sha}-{preimage_sha}-{content_sha}"
    try:
        name_max = os.fpathconf(parent_descriptor, "PC_NAME_MAX")
    except (OSError, ValueError):
        name_max = 255
    if len(os.fsencode(transaction_name)) <= name_max:
        return transaction_name
    raise CanonError(
        "MIGRATION_CATALOG_WRITE",
        "filesystem name limit cannot represent deterministic catalog transaction",
    )


def _inspect_catalog_transaction_state(
    parent_descriptor: int,
    catalog_name: str,
    recovery_name: str,
    absolute: Path,
) -> tuple[_CatalogTransactionArtifact, ...]:
    try:
        names = sorted(os.listdir(parent_descriptor))
    except OSError as exc:
        raise CanonError(
            "MIGRATION_CATALOG_PATH_UNSAFE",
            "unable to inspect deterministic catalog transaction state",
            absolute,
        ) from exc
    artifacts: list[_CatalogTransactionArtifact] = []
    for candidate in names:
        if candidate.startswith(recovery_name):
            _raise_existing_recovery_artifact(
                parent_descriptor,
                candidate,
                absolute,
            )
        try:
            ownership = _catalog_transaction_candidate(
                candidate,
                catalog_name,
                absolute,
            )
        except CanonError:
            _raise_existing_recovery_artifact(
                parent_descriptor,
                candidate,
                absolute,
            )
        if ownership is None:
            continue
        artifact_path = absolute.with_name(candidate)
        try:
            artifact_bytes, identity = _read_catalog_transaction_at(
                parent_descriptor,
                candidate,
                artifact_path,
            )
        except CanonError as exc:
            try:
                os.stat(
                    candidate,
                    dir_fd=parent_descriptor,
                    follow_symlinks=False,
                )
            except FileNotFoundError as missing:
                raise CanonError(
                    "MIGRATION_CATALOG_CHANGED",
                    "deterministic catalog transaction changed during inspection",
                    absolute,
                ) from missing
            except OSError as unsafe:
                raise CanonError(
                    "MIGRATION_CATALOG_CHANGED",
                    "deterministic catalog transaction became unsafe during inspection",
                    absolute,
                ) from unsafe
            raise CanonError(
                "MIGRATION_CATALOG_RECOVERY_REQUIRED",
                f"unsafe deterministic recovery artifact must be resolved first: {candidate}",
                artifact_path,
            ) from exc
        assert artifact_bytes is not None
        assert identity is not None
        artifact_sha = hashlib.sha256(artifact_bytes).hexdigest()
        if artifact_sha != ownership.content_sha256:
            raise CanonError(
                "MIGRATION_CATALOG_RECOVERY_REQUIRED",
                f"prior catalog retained at deterministic recovery artifact: {candidate}",
                artifact_path,
            )
        owner_identity = None
        if ownership.owner_catalog_name != catalog_name:
            sibling_path = absolute.with_name(ownership.owner_catalog_name)
            try:
                sibling_bytes, owner_identity = _read_catalog_transaction_at(
                    parent_descriptor,
                    ownership.owner_catalog_name,
                    sibling_path,
                )
                _parse_catalog_bytes(sibling_bytes, sibling_path)
                _parse_catalog_bytes(artifact_bytes, artifact_path)
            except CanonError:
                _raise_existing_recovery_artifact(
                    parent_descriptor,
                    candidate,
                    absolute,
                )
            if hashlib.sha256(sibling_bytes).hexdigest() != ownership.preimage_sha256:
                _raise_existing_recovery_artifact(
                    parent_descriptor,
                    candidate,
                    absolute,
                )
        artifacts.append(
            _CatalogTransactionArtifact(
                name=candidate,
                preimage_sha256=ownership.preimage_sha256,
                content_sha256=ownership.content_sha256,
                identity=identity,
                owner_catalog_name=ownership.owner_catalog_name,
                owner_catalog_identity=owner_identity,
            )
        )
    return tuple(artifacts)


def _catalog_transaction_candidate(
    candidate: str,
    catalog_name: str,
    absolute: Path,
) -> _CatalogTransactionCandidate | None:
    catalog_sha = hashlib.sha256(os.fsencode(catalog_name)).hexdigest()
    hashed_base = f".canon-txn-{catalog_sha}"
    legacy_base = f".{catalog_name}.txn"
    if candidate.startswith(hashed_base):
        prefix = f"{hashed_base}-"
        if not candidate.startswith(prefix):
            _raise_malformed_transaction(candidate, absolute)
        hashes = _transaction_hash_pair(candidate[len(prefix) :])
        if hashes is None:
            _raise_malformed_transaction(candidate, absolute)
        return _CatalogTransactionCandidate(catalog_name, hashes[0], hashes[1])
    if not candidate.startswith(legacy_base):
        return None
    parsed = _legacy_transaction_parts(candidate)
    if parsed is None:
        _raise_malformed_transaction(candidate, absolute)
    owner_name, preimage_sha, content_sha = parsed
    if owner_name != catalog_name and not owner_name.startswith(f"{catalog_name}.txn"):
        _raise_malformed_transaction(candidate, absolute)
    return _CatalogTransactionCandidate(owner_name, preimage_sha, content_sha)


def _legacy_transaction_parts(candidate: str) -> tuple[str, str, str] | None:
    if not candidate.startswith("."):
        return None
    owner_name, marker, suffix = candidate[1:].rpartition(".txn-")
    if not marker or not owner_name:
        return None
    hashes = _transaction_hash_pair(suffix)
    if hashes is None:
        return None
    return owner_name, hashes[0], hashes[1]


def _transaction_hash_pair(value: str) -> tuple[str, str] | None:
    parts = value.split("-")
    if len(parts) != 2 or any(
        len(item) != 64
        or any(character not in "0123456789abcdef" for character in item)
        for item in parts
    ):
        return None
    return parts[0], parts[1]


def _raise_malformed_transaction(candidate: str, absolute: Path) -> Never:
    artifact_path = absolute.with_name(candidate)
    raise CanonError(
        "MIGRATION_CATALOG_RECOVERY_REQUIRED",
        f"malformed deterministic recovery artifact must be resolved first: {candidate}",
        artifact_path,
    )


def _catalog_transaction_hashes(
    candidate: str,
    catalog_name: str,
    absolute: Path,
) -> tuple[str, str] | None:
    ownership = _catalog_transaction_candidate(candidate, catalog_name, absolute)
    if ownership is None or ownership.owner_catalog_name != catalog_name:
        return None
    return ownership.preimage_sha256, ownership.content_sha256


def _read_catalog_transaction_at(
    parent_descriptor: int,
    candidate: str,
    artifact_path: Path,
) -> tuple[bytes, tuple[int, int]]:
    try:
        before = os.stat(
            candidate,
            dir_fd=parent_descriptor,
            follow_symlinks=False,
        )
    except OSError as exc:
        raise CanonError(
            "MIGRATION_CATALOG_PATH_UNSAFE",
            "deterministic catalog transaction is not safely inspectable",
            artifact_path,
        ) from exc
    if not stat.S_ISREG(before.st_mode):
        raise CanonError(
            "MIGRATION_CATALOG_PATH_UNSAFE",
            "deterministic catalog transaction must be a regular file",
            artifact_path,
        )
    expected_identity = (before.st_dev, before.st_ino)
    try:
        descriptor = os.open(
            candidate,
            os.O_RDONLY
            | os.O_NOFOLLOW
            | getattr(os, "O_NONBLOCK", 0)
            | getattr(os, "O_CLOEXEC", 0),
            dir_fd=parent_descriptor,
        )
    except OSError as exc:
        raise CanonError(
            "MIGRATION_CATALOG_PATH_UNSAFE",
            "deterministic catalog transaction changed before inspection",
            artifact_path,
        ) from exc
    try:
        opened = os.fstat(descriptor)
        opened_identity = (opened.st_dev, opened.st_ino)
        if not stat.S_ISREG(opened.st_mode) or opened_identity != expected_identity:
            raise CanonError(
                "MIGRATION_CATALOG_PATH_UNSAFE",
                "deterministic catalog transaction changed during inspection",
                artifact_path,
            )
        content = _read_descriptor(descriptor)
        after = os.fstat(descriptor)
        if (
            not stat.S_ISREG(after.st_mode)
            or (after.st_dev, after.st_ino) != expected_identity
        ):
            raise CanonError(
                "MIGRATION_CATALOG_PATH_UNSAFE",
                "deterministic catalog transaction changed during inspection",
                artifact_path,
            )
        return content, expected_identity
    finally:
        os.close(descriptor)


def _raise_existing_recovery_artifact(
    parent_descriptor: int,
    candidate: str,
    absolute: Path,
) -> Never:
    try:
        os.stat(
            candidate,
            dir_fd=parent_descriptor,
            follow_symlinks=False,
        )
    except FileNotFoundError as exc:
        raise CanonError(
            "MIGRATION_CATALOG_CHANGED",
            "deterministic recovery state changed during inspection",
            absolute,
        ) from exc
    except OSError as exc:
        raise CanonError(
            "MIGRATION_CATALOG_CHANGED",
            "deterministic recovery state became unsafe during inspection",
            absolute,
        ) from exc
    artifact_path = absolute.with_name(candidate)
    raise CanonError(
        "MIGRATION_CATALOG_RECOVERY_REQUIRED",
        f"prior recovery artifact must be resolved first: {candidate}",
        artifact_path,
    )


def _require_catalog_transaction_state(
    parent_descriptor: int,
    catalog_name: str,
    recovery_name: str,
    absolute: Path,
    initial: tuple[_CatalogTransactionArtifact, ...],
    transaction_name: str,
    content: bytes,
    staging_identity: tuple[int, int],
) -> None:
    current = _inspect_catalog_transaction_state(
        parent_descriptor,
        catalog_name,
        recovery_name,
        absolute,
    )
    expected = {artifact.name: artifact for artifact in initial}
    hashes = _catalog_transaction_hashes(
        transaction_name,
        catalog_name,
        absolute,
    )
    assert hashes is not None
    expected[transaction_name] = _CatalogTransactionArtifact(
        name=transaction_name,
        preimage_sha256=hashes[0],
        content_sha256=hashlib.sha256(content).hexdigest(),
        identity=staging_identity,
        owner_catalog_name=catalog_name,
        owner_catalog_identity=None,
    )
    if {artifact.name: artifact for artifact in current} != expected:
        raise CanonError(
            "MIGRATION_CATALOG_CHANGED",
            "deterministic catalog transaction state changed before atomic update",
            absolute,
        )


def _prepare_catalog_staging(
    parent_descriptor: int,
    transaction_name: str,
    content: bytes,
    absolute: Path,
) -> tuple[bool, tuple[int, int]]:
    try:
        descriptor = os.open(
            transaction_name,
            os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, "O_CLOEXEC", 0),
            0o600,
            dir_fd=parent_descriptor,
        )
    except FileExistsError:
        existing_bytes, existing_identity = _read_catalog_at(
            parent_descriptor,
            transaction_name,
            absolute,
            allow_missing=False,
        )
        if existing_bytes != content or existing_identity is None:
            raise CanonError(
                "MIGRATION_CATALOG_BUSY",
                "deterministic catalog transaction name contains different bytes",
                absolute,
            )
        return False, existing_identity
    try:
        view = memoryview(content)
        while view:
            written = os.write(descriptor, view)
            if written == 0:
                raise OSError("short catalog write")
            view = view[written:]
        os.fsync(descriptor)
        info = os.fstat(descriptor)
        identity = (info.st_dev, info.st_ino)
    except BaseException:
        os.close(descriptor)
        try:
            os.unlink(transaction_name, dir_fd=parent_descriptor)
            os.fsync(parent_descriptor)
        except OSError:
            pass
        raise
    os.close(descriptor)
    os.fsync(parent_descriptor)
    return True, identity


def _install_catalog_cas(
    parent_descriptor: int,
    name: str,
    transaction_name: str,
    absolute: Path,
    expected_bytes: bytes | None,
    expected_identity: tuple[int, int] | None,
    expected_content: bytes,
    expected_staging_identity: tuple[int, int],
    ancestry: tuple[_CatalogAncestryLink, ...],
    recovery_name: str,
    retained_transaction_names: set[str],
) -> bool:
    """Atomically install only over the exact descriptor-pinned preimage."""

    try:
        current_bytes, current_identity = _read_catalog_at(
            parent_descriptor,
            name,
            absolute,
            allow_missing=True,
        )
    except CanonError as exc:
        raise CanonError(
            "MIGRATION_CATALOG_CHANGED",
            "source catalog became unsafe during atomic update",
            absolute,
        ) from exc
    if current_identity != expected_identity or current_bytes != expected_bytes:
        raise CanonError(
            "MIGRATION_CATALOG_CHANGED",
            "source catalog changed during atomic update",
            absolute,
        )
    _require_visible_ancestry(ancestry, absolute)
    staging_bytes, staging_identity = _read_catalog_at(
        parent_descriptor,
        transaction_name,
        absolute,
        allow_missing=False,
    )
    if (
        staging_identity != expected_staging_identity
        or staging_bytes != expected_content
    ):
        raise CanonError(
            "MIGRATION_CATALOG_CHANGED",
            "deterministic catalog transaction changed before atomic update",
            absolute,
        )
    if expected_identity is None:
        try:
            _rename_noreplace(
                transaction_name,
                name,
                source_directory=parent_descriptor,
                destination_directory=parent_descriptor,
            )
        except OSError as exc:
            raise CanonError(
                "MIGRATION_CATALOG_CHANGED",
                "a catalog appeared during first-install compare-and-swap",
                absolute,
            ) from exc
        except CanonError as exc:
            raise CanonError(
                "MIGRATION_CATALOG_WRITE",
                "atomic no-replace catalog installation is unavailable",
                absolute,
            ) from exc
        os.fsync(parent_descriptor)
        try:
            _require_visible_ancestry(ancestry, absolute)
        except CanonError:
            os.unlink(name, dir_fd=parent_descriptor)
            os.fsync(parent_descriptor)
            raise
        return True

    try:
        _rename_exchange(
            transaction_name,
            name,
            source_directory=parent_descriptor,
            destination_directory=parent_descriptor,
        )
    except OSError as exc:
        raise CanonError(
            "MIGRATION_CATALOG_CHANGED",
            "source catalog changed before atomic exchange",
            absolute,
        ) from exc
    os.fsync(parent_descriptor)
    try:
        displaced_bytes, displaced_identity = _read_catalog_at(
            parent_descriptor,
            transaction_name,
            absolute,
            allow_missing=False,
        )
        matches = (
            displaced_identity == expected_identity
            and displaced_bytes == expected_bytes
        )
    except CanonError:
        matches = False
    if not matches:
        _rollback_catalog_exchange(
            parent_descriptor,
            name,
            transaction_name,
            recovery_name,
            retained_transaction_names,
            absolute,
            reason="catalog preimage changed",
        )
        raise CanonError(
            "MIGRATION_CATALOG_CHANGED",
            "source catalog changed during atomic exchange; concurrent bytes restored",
            absolute,
        )
    try:
        _require_visible_ancestry(ancestry, absolute)
    except CanonError:
        _rollback_catalog_exchange(
            parent_descriptor,
            name,
            transaction_name,
            recovery_name,
            retained_transaction_names,
            absolute,
            reason="visible catalog ancestry changed",
        )
        raise
    os.unlink(transaction_name, dir_fd=parent_descriptor)
    os.fsync(parent_descriptor)
    return True


def _rollback_catalog_exchange(
    parent_descriptor: int,
    name: str,
    transaction_name: str,
    recovery_name: str,
    retained_transaction_names: set[str],
    absolute: Path,
    *,
    reason: str,
) -> None:
    try:
        _rename_exchange(
            transaction_name,
            name,
            source_directory=parent_descriptor,
            destination_directory=parent_descriptor,
        )
        os.fsync(parent_descriptor)
        return
    except (OSError, CanonError) as rollback_error:
        locator = _retain_recovery_preimage(
            parent_descriptor,
            transaction_name,
            recovery_name,
            retained_transaction_names,
            absolute,
        )
        raise CanonError(
            "MIGRATION_CATALOG_RECOVERY_REQUIRED",
            f"{reason}; retained exact prior catalog at {locator}",
            absolute,
        ) from rollback_error


def _retain_recovery_preimage(
    parent_descriptor: int,
    transaction_name: str,
    recovery_name: str,
    retained_transaction_names: set[str],
    absolute: Path,
) -> str:
    try:
        prior_bytes, _prior_identity = _read_catalog_at(
            parent_descriptor,
            transaction_name,
            absolute,
            allow_missing=False,
        )
    except CanonError:
        retained_transaction_names.add(transaction_name)
        return transaction_name
    assert prior_bytes is not None
    prior_sha = hashlib.sha256(prior_bytes).hexdigest()
    candidate = recovery_name
    fallback = f"{recovery_name}-{prior_sha}"
    for _attempt in range(64):
        try:
            _rename_noreplace(
                transaction_name,
                candidate,
                source_directory=parent_descriptor,
                destination_directory=parent_descriptor,
            )
            os.fsync(parent_descriptor)
            return candidate
        except OSError as exc:
            if exc.errno not in (errno.EEXIST, errno.ENOTEMPTY):
                retained_transaction_names.add(transaction_name)
                return transaction_name
        except CanonError:
            retained_transaction_names.add(transaction_name)
            return transaction_name
        try:
            existing_bytes, _existing_identity = _read_catalog_at(
                parent_descriptor,
                candidate,
                absolute,
                allow_missing=False,
            )
        except CanonError:
            existing_bytes = b"unsafe recovery collision entry"
        if existing_bytes == prior_bytes:
            os.unlink(transaction_name, dir_fd=parent_descriptor)
            os.fsync(parent_descriptor)
            return candidate
        existing_sha = hashlib.sha256(existing_bytes or b"").hexdigest()
        candidate = (
            fallback
            if candidate == recovery_name
            else f"{candidate}-collision-{existing_sha}"
        )
    retained_transaction_names.add(transaction_name)
    return transaction_name


def _rename_exchange(
    source: str,
    destination: str,
    *,
    source_directory: int,
    destination_directory: int,
) -> None:
    source_bytes = os.fsencode(source)
    destination_bytes = os.fsencode(destination)
    libc = ctypes.CDLL(None, use_errno=True)
    if sys.platform == "darwin":
        try:
            rename = libc.renameatx_np
        except AttributeError as exc:
            raise CanonError(
                "MIGRATION_CATALOG_WRITE",
                "atomic catalog exchange is unavailable on this platform",
            ) from exc
        rename.argtypes = (
            ctypes.c_int,
            ctypes.c_char_p,
            ctypes.c_int,
            ctypes.c_char_p,
            ctypes.c_uint,
        )
        rename.restype = ctypes.c_int
        result = rename(
            source_directory,
            source_bytes,
            destination_directory,
            destination_bytes,
            DARWIN_RENAME_SWAP,
        )
    elif sys.platform.startswith("linux"):
        try:
            rename = libc.renameat2
        except AttributeError as exc:
            raise CanonError(
                "MIGRATION_CATALOG_WRITE",
                "atomic catalog exchange is unavailable on this platform",
            ) from exc
        rename.argtypes = (
            ctypes.c_int,
            ctypes.c_char_p,
            ctypes.c_int,
            ctypes.c_char_p,
            ctypes.c_uint,
        )
        rename.restype = ctypes.c_int
        result = rename(
            source_directory,
            source_bytes,
            destination_directory,
            destination_bytes,
            LINUX_RENAME_EXCHANGE,
        )
    else:
        raise CanonError(
            "MIGRATION_CATALOG_WRITE",
            "atomic catalog exchange is unavailable on this platform",
        )
    if result != 0:
        error = ctypes.get_errno()
        raise OSError(error, os.strerror(error), destination)


def _validate_unique_records(records: Sequence[SourceRecord], path: Path) -> None:
    for attribute, code in (
        ("source_id", "MIGRATION_SOURCE_ID_DUPLICATE"),
        ("locator", "MIGRATION_LOCATOR_DUPLICATE"),
    ):
        values = [getattr(item, attribute) for item in records]
        if len(values) != len(set(values)):
            raise CanonError(code, f"duplicate source {attribute}", path)
    paths = [
        item.repo_path if item.kind in TRACKED_SOURCE_KINDS else item.raw_path
        for item in records
    ]
    if len(paths) != len(set(paths)):
        raise CanonError("MIGRATION_PATH_DUPLICATE", "duplicate source path", path)


@contextmanager
def _open_or_create_catalog_parent(root: Path, catalog_path: Path):
    root_absolute = _normalized_absolute(root)
    catalog_absolute = _normalized_absolute(catalog_path)
    try:
        relative = catalog_absolute.relative_to(root_absolute)
    except ValueError as exc:
        raise CanonError(
            "MIGRATION_CATALOG_PATH_UNSAFE",
            "catalog must be inside the repository",
            catalog_path,
        ) from exc
    if (
        len(relative.parts) < 2
        or relative.is_absolute()
        or any(part in ("", ".", "..") for part in relative.parts)
    ):
        raise CanonError(
            "MIGRATION_CATALOG_PATH_UNSAFE",
            "catalog path must be a canonical repository-relative file path",
            catalog_path,
        )
    descriptors: list[int] = []
    transaction = _CatalogParentTransaction(created_directories=[])
    with _open_parent_nofollow(root_absolute) as (
        root_parent_descriptor,
        root_name,
        _root_path,
    ):
        try:
            try:
                current = os.open(
                    root_name,
                    DIRECTORY_FLAGS,
                    dir_fd=root_parent_descriptor,
                )
            except OSError as exc:
                raise CanonError(
                    "MIGRATION_CATALOG_PATH_UNSAFE",
                    "approved repository root must be a real directory",
                    root_absolute,
                ) from exc
            descriptors.append(current)
            root_info = os.fstat(current)
            ancestry = [
                _CatalogAncestryLink(
                    parent_descriptor=root_parent_descriptor,
                    name=root_name,
                    identity=(root_info.st_dev, root_info.st_ino),
                )
            ]
            for component in relative.parts[:-1]:
                created = False
                try:
                    child = os.open(component, DIRECTORY_FLAGS, dir_fd=current)
                except FileNotFoundError:
                    try:
                        os.mkdir(component, mode=0o755, dir_fd=current)
                        os.fsync(current)
                        child = os.open(component, DIRECTORY_FLAGS, dir_fd=current)
                        created = True
                    except OSError as exc:
                        raise CanonError(
                            "MIGRATION_CATALOG_PATH_UNSAFE",
                            "catalog parent creation encountered an unsafe ancestor",
                            catalog_path,
                        ) from exc
                except OSError as exc:
                    raise CanonError(
                        "MIGRATION_CATALOG_PATH_UNSAFE",
                        "catalog ancestry must contain only real directories",
                        catalog_path,
                    ) from exc
                descriptors.append(child)
                child_info = os.fstat(child)
                child_identity = (child_info.st_dev, child_info.st_ino)
                ancestry.append(
                    _CatalogAncestryLink(
                        parent_descriptor=current,
                        name=component,
                        identity=child_identity,
                    )
                )
                if created:
                    transaction.created_directories.append(
                        _CreatedCatalogDirectory(
                            parent_descriptor=current,
                            descriptor=child,
                            original_name=component,
                            identity=child_identity,
                        )
                    )
                current = child
            yield (
                current,
                relative.parts[-1],
                catalog_absolute,
                tuple(ancestry),
                transaction,
            )
        finally:
            active_error = sys.exc_info()[1]
            cleanup_error = None
            if not transaction.committed:
                cleanup_error = _cleanup_created_catalog_directories(
                    transaction.created_directories,
                    catalog_absolute,
                )
            for descriptor in reversed(descriptors):
                try:
                    os.close(descriptor)
                except OSError:
                    pass
            if cleanup_error is not None:
                if (
                    isinstance(active_error, CanonError)
                    and active_error.code == "MIGRATION_CATALOG_RECOVERY_REQUIRED"
                ):
                    raise active_error
                raise cleanup_error


def _require_visible_ancestry(
    ancestry: tuple[_CatalogAncestryLink, ...],
    catalog_path: Path,
) -> None:
    for link in ancestry:
        try:
            info = os.stat(
                link.name,
                dir_fd=link.parent_descriptor,
                follow_symlinks=False,
            )
        except OSError as exc:
            raise CanonError(
                "MIGRATION_CATALOG_PATH_CHANGED",
                "visible catalog ancestry disappeared during update",
                catalog_path,
            ) from exc
        if (
            not stat.S_ISDIR(info.st_mode)
            or (info.st_dev, info.st_ino) != link.identity
        ):
            raise CanonError(
                "MIGRATION_CATALOG_PATH_CHANGED",
                "visible catalog ancestry was replaced during update",
                catalog_path,
            )


def _cleanup_created_catalog_directories(
    created: list[_CreatedCatalogDirectory],
    catalog_path: Path,
) -> CanonError | None:
    retained: list[str] = []
    for directory in reversed(created):
        try:
            if os.listdir(directory.descriptor):
                retained.append(directory.original_name)
                continue
        except OSError:
            retained.append(directory.original_name)
            continue
        visible_names: list[str] = []
        try:
            for candidate in sorted(os.listdir(directory.parent_descriptor)):
                try:
                    info = os.stat(
                        candidate,
                        dir_fd=directory.parent_descriptor,
                        follow_symlinks=False,
                    )
                except OSError:
                    continue
                if (
                    stat.S_ISDIR(info.st_mode)
                    and (info.st_dev, info.st_ino) == directory.identity
                ):
                    visible_names.append(candidate)
        except OSError:
            retained.append(directory.original_name)
            continue
        if not visible_names:
            continue
        if len(visible_names) != 1:
            retained.append(directory.original_name)
            continue
        try:
            os.rmdir(visible_names[0], dir_fd=directory.parent_descriptor)
            os.fsync(directory.parent_descriptor)
        except OSError:
            retained.append(directory.original_name)
    if not retained:
        return None
    return CanonError(
        "MIGRATION_CATALOG_RECOVERY_REQUIRED",
        "created catalog ancestry retained for manual recovery: "
        + ", ".join(sorted(set(retained))),
        catalog_path,
    )


def _repository_root(path: Path) -> Path:
    candidate = Path(os.path.abspath(path))
    while not candidate.exists() and candidate != candidate.parent:
        candidate = candidate.parent
    result = _git_result(candidate, "rev-parse", "--show-toplevel")
    if result.returncode != 0:
        raise CanonError(
            "MIGRATION_REPO_INVALID", "path is not inside a Git worktree", Path(path)
        )
    try:
        return Path(result.stdout.decode("utf-8").strip())
    except UnicodeDecodeError as exc:
        raise CanonError(
            "MIGRATION_REPO_INVALID", "Git worktree path is not UTF-8", Path(path)
        ) from exc


def _repo_path_dirty(root: Path, path: str) -> bool:
    result = _git_result(
        root, "status", "--porcelain=v1", "-z", "--untracked-files=all", "--", path
    )
    if result.returncode != 0:
        raise CanonError(
            "MIGRATION_REPO_INVALID",
            "unable to inspect tracked source state",
            Path(path),
        )
    return bool(result.stdout)


def _require_clean_pathspec_state(root: Path, pathspecs: Sequence[str]) -> None:
    result = _git_result(
        root,
        "status",
        "--porcelain=v2",
        "-z",
        "--untracked-files=all",
        "--",
        *pathspecs,
    )
    if result.returncode != 0:
        raise CanonError(
            "MIGRATION_REPO_INVALID",
            "unable to inspect requested repo pathspec state",
            root,
        )
    if result.stdout:
        raise CanonError(
            "MIGRATION_REPO_DIRTY",
            "requested repo pathspec contains staged, worktree, or untracked changes",
            root,
        )
    flags = _git(root, "ls-files", "-v", "-z", "--", *pathspecs)
    for entry in (item for item in flags.split(b"\0") if item):
        if len(entry) < 3 or entry[1:2] != b" ":
            raise CanonError(
                "MIGRATION_REPO_INVALID",
                "unable to parse Git index flags",
                root,
            )
        tag = chr(entry[0])
        if tag == "S" or tag.islower():
            raise CanonError(
                "MIGRATION_REPO_DIRTY",
                "requested repo pathspec contains assume-unchanged or skip-worktree entries",
                root,
            )
    cached = _git_result(
        root,
        "diff",
        "--cached",
        "--quiet",
        "--",
        *pathspecs,
    )
    if cached.returncode == 1:
        raise CanonError(
            "MIGRATION_REPO_DIRTY",
            "requested repo pathspec index differs from HEAD",
            root,
        )
    if cached.returncode != 0:
        raise CanonError(
            "MIGRATION_REPO_INVALID",
            "unable to compare requested repo index to HEAD",
            root,
        )


def _parse_index_entries(raw: bytes, root: Path) -> dict[str, _IndexEntry]:
    entries: dict[str, _IndexEntry] = {}
    try:
        for item in (value for value in raw.split(b"\0") if value):
            header, encoded_path = item.split(b"\t", 1)
            mode, object_id, stage = header.decode("ascii").split(" ")
            path = encoded_path.decode("utf-8", errors="strict")
            if stage != "0" or path in entries:
                raise ValueError("non-stage-zero or duplicate index entry")
            if mode not in {"100644", "100755"} or not _valid_git_object_id(object_id):
                raise ValueError("unsupported index mode or object ID")
            entries[path] = _IndexEntry(
                path=path,
                mode=mode,
                object_id=object_id,
            )
    except (UnicodeError, ValueError) as exc:
        raise CanonError(
            "MIGRATION_REPO_DIRTY",
            "requested repo sources must be unique stage-zero regular-file index entries",
            root,
        ) from exc
    return entries


def _require_worktree_matches_index(
    root: Path,
    entry: _IndexEntry,
    content: bytes,
    *,
    code: str,
) -> None:
    index_content = _git(root, "cat-file", "blob", entry.object_id)
    try:
        with _open_parent_nofollow(root / entry.path) as (
            parent_descriptor,
            name,
            _absolute,
        ):
            descriptor = os.open(
                name,
                os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0),
                dir_fd=parent_descriptor,
            )
            try:
                info = os.fstat(descriptor)
            finally:
                os.close(descriptor)
    except (OSError, CanonError) as exc:
        raise CanonError(
            code,
            f"tracked repo source is missing or unsafe: {entry.path}",
            Path(entry.path),
        ) from exc
    executable = bool(info.st_mode & 0o111)
    expected_executable = entry.mode == "100755"
    if (
        not stat.S_ISREG(info.st_mode)
        or executable != expected_executable
        or content != index_content
    ):
        raise CanonError(
            code,
            f"worktree source differs from its exact index blob or mode: {entry.path}",
            Path(entry.path),
        )


def _require_repo_snapshot(root: Path, expected: _RepoSnapshot) -> None:
    try:
        _require_clean_pathspec_state(root, expected.pathspecs)
        index_entries = _git(
            root,
            "ls-files",
            "--stage",
            "-z",
            "--",
            *expected.pathspecs,
        )
        if index_entries != expected.index_entries:
            raise CanonError(
                "MIGRATION_REPO_CHANGED",
                "tracked repo index changed during registration",
                root,
            )
        parsed_entries = _parse_index_entries(index_entries, root)
        for path_text, expected_sha in expected.content_sha256:
            content = _read_regular_nofollow(
                root / path_text,
                "MIGRATION_REPO_PATH_UNSAFE",
            )
            entry = parsed_entries.get(path_text)
            if entry is None:
                raise CanonError(
                    "MIGRATION_REPO_CHANGED",
                    f"tracked repo source left the index: {path_text}",
                    Path(path_text),
                )
            _require_worktree_matches_index(
                root,
                entry,
                content,
                code="MIGRATION_REPO_CHANGED",
            )
            if hashlib.sha256(content).hexdigest() != expected_sha:
                raise CanonError(
                    "MIGRATION_REPO_CHANGED",
                    f"tracked repo source changed during registration: {path_text}",
                    Path(path_text),
                )
    except CanonError as exc:
        if exc.code == "MIGRATION_REPO_CHANGED":
            raise
        raise CanonError(
            "MIGRATION_REPO_CHANGED",
            "requested repo source snapshot changed during registration",
            exc.path or root,
        ) from exc


def _require_raw_snapshot(record: SourceRecord, root: Path) -> None:
    assert record.raw_path is not None
    findings = verify_source(record, root / record.raw_path)
    if findings:
        first = findings[0]
        raise CanonError(
            "MIGRATION_RAW_CHANGED",
            "raw source changed during registration",
            first.path,
        )


def _git(root: Path, *arguments: str) -> bytes:
    result = _git_result(root, *arguments)
    if result.returncode != 0:
        raise CanonError("MIGRATION_GIT_FAILED", "Git provenance command failed", root)
    return result.stdout


def _git_result(root: Path, *arguments: str) -> subprocess.CompletedProcess[bytes]:
    try:
        return subprocess.run(
            ("git", *arguments),
            cwd=root,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except OSError as exc:
        raise CanonError("MIGRATION_GIT_FAILED", "unable to execute Git", root) from exc


def _finding(code: str, message: str, path: Path) -> Finding:
    return Finding(
        code=code, severity=GapSeverity.P0_BLOCKER, message=message, path=path
    )


@dataclass(frozen=True, slots=True)
class SourceSectionDisposition:
    source_id: str
    source_location: str
    rationale: str


@dataclass(frozen=True, slots=True)
class ClaimBatch:
    batch_id: str
    claims: tuple[AtomicClaim, ...]
    source_section_dispositions: tuple[SourceSectionDisposition, ...]

    def __post_init__(self) -> None:
        object.__setattr__(self, "claims", tuple(self.claims))
        object.__setattr__(
            self,
            "source_section_dispositions",
            tuple(self.source_section_dispositions),
        )


@dataclass(frozen=True, slots=True)
class DecisionEvidenceEntry:
    decision_number: int
    evidence_kind: str
    entity_id: str
    evidence_locator: str
    author: str
    owner_evidence_text: str
    owner_evidence_rationale: str
    v3_clause: str
    mapping_status: str
    mapping_reviewed_by: str | None
    mapping_rationale: str


@dataclass(frozen=True, slots=True)
class DecisionEvidenceSnapshot:
    linear_v3_document_id: str
    owner: str
    evidence_entries: tuple[DecisionEvidenceEntry, ...]

    def __post_init__(self) -> None:
        object.__setattr__(self, "evidence_entries", tuple(self.evidence_entries))


@dataclass(frozen=True, slots=True)
class ClaimImportResult:
    source_count: int
    section_count: int
    linear_decision_count: int
    claim_count: int
    output_path: Path


@dataclass(frozen=True, slots=True)
class ClaimCoverageReport:
    complete: bool
    claims: tuple[dict[str, object], ...]
    uncovered: tuple[dict[str, str], ...]
    source_count: int
    section_count: int
    linear_decision_count: int

    def __post_init__(self) -> None:
        object.__setattr__(self, "claims", tuple(dict(item) for item in self.claims))
        object.__setattr__(
            self,
            "uncovered",
            tuple(dict(item) for item in self.uncovered),
        )

    def to_dict(self) -> dict[str, object]:
        return {
            "claims": list(self.claims),
            "complete": self.complete,
            "linear_decision_count": self.linear_decision_count,
            "schema_version": 1,
            "section_count": self.section_count,
            "source_count": self.source_count,
            "uncovered": list(self.uncovered),
        }


@dataclass(frozen=True, slots=True)
class _SourceInventory:
    record: SourceRecord
    source_path: Path
    raw: bytes
    identity: tuple[int, int, int, int, int]
    byte_length: int
    content_sha256: str
    text: str
    lines: tuple[str, ...]
    sections: tuple[str, ...]
    heading_lines: tuple[int, ...]


def parse_claim_batch(raw: bytes, path: Path) -> ClaimBatch:
    """Parse one closed, ignored atomic-claim interchange batch."""

    try:
        payload = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise CanonError(
            "CLAIM_BATCH_INVALID",
            "claim batch must be valid UTF-8 JSON",
            path,
        ) from exc
    _validate_json_utf8_strings(payload, path)
    if not isinstance(payload, dict) or set(payload) != CLAIM_BATCH_FIELDS:
        raise CanonError(
            "CLAIM_BATCH_INVALID",
            "claim batch must contain exactly the supported top-level fields",
            path,
        )
    if payload["schema_version"] != 1 or isinstance(payload["schema_version"], bool):
        raise CanonError(
            "CLAIM_BATCH_INVALID",
            "claim batch schema_version must equal 1",
            path,
        )
    batch_id = _claim_string(payload, "batch_id", path)
    raw_claims = payload["claims"]
    raw_dispositions = payload["source_section_dispositions"]
    if not isinstance(raw_claims, list) or not isinstance(raw_dispositions, list):
        raise CanonError(
            "CLAIM_BATCH_INVALID",
            "claims and source_section_dispositions must be arrays",
            path,
        )
    claims = tuple(_atomic_claim_from_dict(item, path) for item in raw_claims)
    dispositions = tuple(
        _section_disposition_from_dict(item, path) for item in raw_dispositions
    )
    _require_unique(
        (item.claim_id for item in claims),
        "CLAIM_ID_DUPLICATE",
        "claim_id",
        path,
    )
    _require_unique(
        (f"{item.source_id}\0{item.source_location}" for item in dispositions),
        "CLAIM_SECTION_DISPOSITION_DUPLICATE",
        "source section disposition",
        path,
    )
    return ClaimBatch(batch_id, claims, dispositions)


def parse_decision_evidence_snapshot(
    raw: bytes,
    path: Path,
) -> DecisionEvidenceSnapshot:
    """Parse exact ignored owner evidence for Linear Decisions 1 through 201."""

    try:
        payload = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise CanonError(
            "CLAIM_DECISION_EVIDENCE_INVALID",
            "decision evidence snapshot must be valid UTF-8 JSON",
            path,
        ) from exc
    _validate_json_utf8_strings(payload, path)
    top_fields = {
        "schema_version",
        "linear_v3_document_id",
        "owner",
        "evidence_entries",
    }
    if not isinstance(payload, dict) or set(payload) != top_fields:
        raise CanonError(
            "CLAIM_DECISION_EVIDENCE_INVALID",
            "decision evidence snapshot uses an unsupported closed shape",
            path,
        )
    if payload["schema_version"] != 1 or isinstance(payload["schema_version"], bool):
        raise CanonError(
            "CLAIM_DECISION_EVIDENCE_INVALID",
            "decision evidence schema_version must equal 1",
            path,
        )
    document_id = _claim_string(payload, "linear_v3_document_id", path)
    owner = _claim_string(payload, "owner", path)
    if document_id != "96b93346-271d-46fc-beab-43ff7e286b5d" or owner != "Devan Warner":
        raise CanonError(
            "CLAIM_DECISION_EVIDENCE_INVALID",
            "decision evidence must bind the exact v3 document and owner",
            path,
        )
    raw_entries = payload["evidence_entries"]
    if not isinstance(raw_entries, list):
        raise CanonError(
            "CLAIM_DECISION_EVIDENCE_INVALID",
            "evidence_entries must be an array",
            path,
        )
    entry_fields = {
        "decision_number",
        "evidence_kind",
        "entity_id",
        "evidence_locator",
        "author",
        "owner_evidence_text",
        "owner_evidence_rationale",
        "v3_clause",
        "mapping_status",
        "mapping_reviewed_by",
        "mapping_rationale",
    }
    entries: list[DecisionEvidenceEntry] = []
    locators: set[str] = set()
    for raw_entry in raw_entries:
        if not isinstance(raw_entry, dict) or set(raw_entry) != entry_fields:
            raise CanonError(
                "CLAIM_DECISION_EVIDENCE_INVALID",
                "decision evidence entry uses an unsupported closed shape",
                path,
            )
        decision_number = raw_entry["decision_number"]
        if (
            not isinstance(decision_number, int)
            or isinstance(decision_number, bool)
            or not 1 <= decision_number <= 201
        ):
            raise CanonError(
                "CLAIM_DECISION_EVIDENCE_INVALID",
                "decision_number must be 1 through 201",
                path,
            )
        evidence_kind = _claim_string(raw_entry, "evidence_kind", path)
        entity_id = _claim_string(raw_entry, "entity_id", path)
        locator = _claim_string(raw_entry, "evidence_locator", path)
        author = _claim_string(raw_entry, "author", path)
        owner_text = _claim_string(raw_entry, "owner_evidence_text", path)
        owner_rationale = _claim_string(raw_entry, "owner_evidence_rationale", path)
        v3_clause = _claim_string(raw_entry, "v3_clause", path)
        mapping_status = _claim_string(raw_entry, "mapping_status", path)
        mapping_rationale = _claim_string(raw_entry, "mapping_rationale", path)
        reviewed_by = raw_entry["mapping_reviewed_by"]
        if reviewed_by is not None:
            if not isinstance(reviewed_by, str) or not reviewed_by.strip():
                raise CanonError(
                    "CLAIM_DECISION_EVIDENCE_INVALID",
                    "mapping_reviewed_by must be null or nonblank",
                    path,
                )
        if (
            evidence_kind not in {"ledger", "comment"}
            or UUID_PATTERN.fullmatch(entity_id) is None
        ):
            raise CanonError(
                "CLAIM_DECISION_EVIDENCE_INVALID",
                "evidence kind or entity UUID is invalid",
                path,
            )
        expected_locator = (
            f"linear-{evidence_kind}:{entity_id}:decision:{decision_number}"
        )
        if locator != expected_locator or author != owner:
            raise CanonError(
                "CLAIM_DECISION_EVIDENCE_INVALID",
                "evidence locator, author, and decision number must agree",
                path,
            )
        if mapping_status == "independently_reviewed":
            if reviewed_by is None:
                raise CanonError(
                    "CLAIM_DECISION_EVIDENCE_INVALID",
                    "reviewed mapping requires mapping_reviewed_by",
                    path,
                )
        elif mapping_status == "unreviewed":
            if reviewed_by is not None:
                raise CanonError(
                    "CLAIM_DECISION_EVIDENCE_INVALID",
                    "unreviewed mapping cannot name a reviewer",
                    path,
                )
        else:
            raise CanonError(
                "CLAIM_DECISION_EVIDENCE_INVALID",
                "mapping_status must be independently_reviewed or unreviewed",
                path,
            )
        if locator in locators:
            raise CanonError(
                "CLAIM_DECISION_EVIDENCE_INVALID",
                f"duplicate evidence locator: {locator}",
                path,
            )
        locators.add(locator)
        entries.append(
            DecisionEvidenceEntry(
                decision_number,
                evidence_kind,
                entity_id,
                locator,
                author,
                owner_text,
                owner_rationale,
                v3_clause,
                mapping_status,
                reviewed_by,
                mapping_rationale,
            )
        )
    if tuple(item.decision_number for item in entries) != tuple(range(1, 202)):
        raise CanonError(
            "CLAIM_DECISION_EVIDENCE_INVALID",
            "decision evidence must contain sorted unique Decisions 1 through 201",
            path,
        )
    return DecisionEvidenceSnapshot(document_id, owner, tuple(entries))


def _atomic_claim_from_dict(value: object, path: Path) -> AtomicClaim:
    value_fields = frozenset(value) if isinstance(value, dict) else frozenset()
    if not isinstance(value, dict) or value_fields not in (
        CLAIM_FIELDS,
        CLAIM_FIELDS | DECISION_CLAIM_FIELDS,
    ):
        raise CanonError(
            "CLAIM_INVALID",
            "claim must contain exactly the supported fields",
            path,
        )
    strings = {
        field: _claim_string(value, field, path)
        for field in (
            "claim_id",
            "source_id",
            "source_location",
            "original_text",
            "concept",
            "subject",
            "predicate",
            "value",
            "modality",
            "scope",
            "disposition",
            "target_class",
            "rationale",
        )
    }
    if CLAIM_ID_PATTERN.fullmatch(strings["claim_id"]) is None:
        raise CanonError(
            "CLAIM_ID_INVALID",
            "claim_id must use a stable uppercase domain-prefixed ID",
            path,
        )
    if CONCEPT_PATTERN.fullmatch(strings["concept"]) is None:
        raise CanonError(
            "CLAIM_CONCEPT_INVALID",
            "concept must be a normalized lowercase key",
            path,
        )
    location_kind, location_number = _parse_source_location(
        strings["source_location"], path
    )
    conditions = _claim_string_array(value, "conditions", path)
    exceptions = _claim_string_array(value, "exceptions", path)
    authority_claim = value["authority_claim"]
    if not isinstance(authority_claim, bool):
        raise CanonError(
            "CLAIM_INVALID",
            "authority_claim must be a boolean",
            path,
        )
    owner_approval = value["owner_approval"]
    if owner_approval is not None:
        if not isinstance(owner_approval, str) or not owner_approval.strip():
            raise CanonError(
                "CLAIM_INVALID",
                "owner_approval must be null or a nonblank evidence string",
                path,
            )
        _require_utf8(owner_approval, path)
    decision_owner_approval_valid = False
    decision_evidence_valid = False
    if location_kind == "decision":
        evidence_match = (
            DECISION_EVIDENCE_PATTERN.fullmatch(owner_approval)
            if owner_approval is not None
            else None
        )
        decision_owner_approval_valid = bool(
            strings["source_id"] == "LINEAR-CANON-V3"
            and evidence_match is not None
            and int(evidence_match.group(1)) == location_number
        )
        if not DECISION_CLAIM_FIELDS.issubset(value):
            raise CanonError(
                "CLAIM_DECISION_PROVENANCE_REQUIRED",
                "decision claim requires exact owner evidence text and rationale",
                path,
            )
        owner_evidence_text = _claim_string(value, "owner_evidence_text", path)
        owner_evidence_rationale = _claim_string(
            value, "owner_evidence_rationale", path
        )
        decision_evidence_valid = True
    else:
        if DECISION_CLAIM_FIELDS & set(value):
            raise CanonError(
                "CLAIM_INVALID",
                "owner evidence fields are decision-claim-only",
                path,
            )
        owner_evidence_text = None
        owner_evidence_rationale = None
    target_id = value["target_id"]
    if target_id is not None:
        if (
            not isinstance(target_id, str)
            or TARGET_ID_PATTERN.fullmatch(target_id) is None
        ):
            raise CanonError(
                "CLAIM_TARGET_INVALID",
                "target_id must be null or a globally valid planned stable ID",
                path,
            )
    try:
        modality = Modality(strings["modality"])
        disposition = ClaimDisposition(strings["disposition"])
        target_class = ClaimTargetClass(strings["target_class"])
    except ValueError as exc:
        raise CanonError(
            "CLAIM_ENUM_INVALID",
            "claim uses an unsupported closed enum value",
            path,
        ) from exc
    _validate_claim_destination(disposition, target_class, target_id, path)
    _validate_decision_claim_law(
        source_id=strings["source_id"],
        location_kind=location_kind,
        location_number=location_number,
        disposition=disposition,
        target_class=target_class,
        target_id=target_id,
        owner_approval_valid=decision_owner_approval_valid,
        owner_evidence_valid=decision_evidence_valid,
        path=path,
        provenance_code="CLAIM_DECISION_PROVENANCE_REQUIRED",
        authority_code="CLAIM_DECISION_MAPPING_AUTHORITY",
    )
    return AtomicClaim(
        claim_id=strings["claim_id"],
        source_id=strings["source_id"],
        source_location=strings["source_location"],
        concept=strings["concept"],
        subject=strings["subject"],
        predicate=strings["predicate"],
        value=strings["value"],
        modality=modality,
        scope=strings["scope"],
        conditions=conditions,
        exceptions=exceptions,
        authority_claim=authority_claim,
        owner_approval=owner_approval,
        disposition=disposition,
        target_id=target_id,
        original_text=strings["original_text"],
        target_class=target_class,
        rationale=strings["rationale"],
        owner_evidence_text=owner_evidence_text,
        owner_evidence_rationale=owner_evidence_rationale,
    )


def _validate_claim_destination(
    disposition: ClaimDisposition,
    target_class: ClaimTargetClass,
    target_id: str | None,
    path: Path,
) -> None:
    if disposition in TARGET_REQUIRED_DISPOSITIONS:
        if target_id is None or target_class not in TARGET_CLASSES:
            raise CanonError(
                "CLAIM_TARGET_REQUIRED",
                "keep, rewrite, and compose require a planned canonical target",
                path,
            )
        return
    expected = {
        ClaimDisposition.CONFLICT: ClaimTargetClass.DECISION_DOCKET,
        ClaimDisposition.PROVENANCE_ONLY: ClaimTargetClass.PROVENANCE,
        ClaimDisposition.REJECT: ClaimTargetClass.REJECTION,
    }[disposition]
    if target_id is not None or target_class is not expected:
        raise CanonError(
            "CLAIM_TARGET_FORBIDDEN",
            f"{disposition.value} cannot carry an automatic canonical winner",
            path,
        )


def _validate_decision_claim_law(
    *,
    source_id: str,
    location_kind: str,
    location_number: int | None,
    disposition: ClaimDisposition,
    target_class: ClaimTargetClass,
    target_id: str | None,
    owner_approval_valid: bool,
    owner_evidence_valid: bool,
    path: Path,
    provenance_code: str,
    authority_code: str,
) -> None:
    """Enforce the shared raw/tracked Decision 1-201 authority boundary."""

    if location_kind != "decision":
        return
    if (
        source_id != "LINEAR-CANON-V3"
        or location_number is None
        or not 1 <= location_number <= 201
        or not owner_approval_valid
        or not owner_evidence_valid
    ):
        raise CanonError(
            provenance_code,
            "Decision 1-201 requires exact owner approval and owner evidence",
            path,
        )
    expected_target_class = {
        ClaimDisposition.PROVENANCE_ONLY: ClaimTargetClass.PROVENANCE,
        ClaimDisposition.CONFLICT: ClaimTargetClass.DECISION_DOCKET,
    }
    if (
        disposition not in expected_target_class
        or target_id is not None
        or target_class is not expected_target_class[disposition]
    ):
        raise CanonError(
            authority_code,
            "Decision mappings are provenance/conflict evidence, not canonical owners",
            path,
        )


def _section_disposition_from_dict(
    value: object,
    path: Path,
) -> SourceSectionDisposition:
    if not isinstance(value, dict) or set(value) != SECTION_DISPOSITION_FIELDS:
        raise CanonError(
            "CLAIM_SECTION_DISPOSITION_INVALID",
            "source section disposition must contain exactly the supported fields",
            path,
        )
    if value["disposition"] != "no_normative_claims":
        raise CanonError(
            "CLAIM_SECTION_DISPOSITION_INVALID",
            "section disposition must equal no_normative_claims",
            path,
        )
    source_id = _claim_string(value, "source_id", path)
    source_location = _claim_string(value, "source_location", path)
    rationale = _claim_string(value, "rationale", path)
    _parse_source_location(source_location, path)
    return SourceSectionDisposition(source_id, source_location, rationale)


def _claim_string(value: Mapping[str, object], field: str, path: Path) -> str:
    result = value.get(field)
    if not isinstance(result, str) or not result.strip():
        raise CanonError(
            "CLAIM_INVALID",
            f"{field} must be a nonblank string",
            path,
        )
    _require_utf8(result, path)
    return result


def _claim_string_array(
    value: Mapping[str, object],
    field: str,
    path: Path,
) -> tuple[str, ...]:
    raw = value.get(field)
    if not isinstance(raw, list):
        raise CanonError("CLAIM_INVALID", f"{field} must be an array", path)
    result: list[str] = []
    for item in raw:
        if not isinstance(item, str) or not item.strip():
            raise CanonError(
                "CLAIM_INVALID",
                f"{field} entries must be nonblank strings",
                path,
            )
        _require_utf8(item, path)
        result.append(item)
    return tuple(result)


def _require_utf8(value: str, path: Path) -> None:
    try:
        value.encode("utf-8")
    except UnicodeEncodeError as exc:
        raise CanonError(
            "CLAIM_INVALID", "claim strings must be valid UTF-8", path
        ) from exc


def _parse_source_location(value: str, path: Path) -> tuple[str, int | None]:
    if value == "document":
        return ("document", None)
    if match := LINE_LOCATION_PATTERN.fullmatch(value):
        return ("line", int(match.group(1)))
    if match := DECISION_LOCATION_PATTERN.fullmatch(value):
        return ("decision", int(match.group(1)))
    raise CanonError(
        "CLAIM_SOURCE_LOCATION_INVALID",
        "source_location must be document, line:N, or decision:N",
        path,
    )


def _require_unique(
    values: Sequence[str] | object,
    code: str,
    label: str,
    path: Path,
) -> None:
    seen: set[str] = set()
    for value in values:
        if value in seen:
            raise CanonError(code, f"duplicate {label}: {value}", path)
        seen.add(value)


def import_claim_batches(
    root: Path,
    input_dir: Path,
    catalog_path: Path,
    output_path: Path,
    decision_evidence_path: Path | None = None,
) -> ClaimImportResult:
    """Validate and deterministically integrate all ignored claim batches."""

    root = _normalized_absolute(root)
    input_dir = _normalized_absolute(input_dir)
    catalog_path = _normalized_absolute(catalog_path)
    output_path = _normalized_absolute(output_path)
    expected_input = root / ".codex/canon-migration/claims"
    if input_dir != expected_input:
        raise CanonError(
            "CLAIM_INPUT_PATH_UNSAFE",
            "claim input must be the ignored .codex/canon-migration/claims directory",
            input_dir,
        )
    _require_ignored_claim_input(root, input_dir)
    expected_output = root / "docs/canon/migration/claim-dispositions.json"
    if output_path != expected_output:
        raise CanonError(
            "CLAIM_OUTPUT_PATH_UNSAFE",
            "tracked claim dispositions must use the canonical migration path",
            output_path,
        )
    _require_claim_sources_verified(catalog_path, root)
    catalog_bytes = _read_catalog_bytes(catalog_path, allow_missing=False)
    assert catalog_bytes is not None
    records = _parse_catalog_bytes(catalog_bytes, catalog_path)
    inventories = _source_inventories(root, records)
    batches = _read_claim_batches(input_dir)
    claims = tuple(
        sorted(
            (claim for batch_item in batches for claim in batch_item.claims),
            key=lambda item: item.claim_id,
        )
    )
    dispositions = tuple(
        sorted(
            (
                item
                for batch_item in batches
                for item in batch_item.source_section_dispositions
            ),
            key=lambda item: (item.source_id, item.source_location),
        )
    )
    _require_unique(
        (item.claim_id for item in claims),
        "CLAIM_ID_DUPLICATE",
        "claim_id",
        input_dir,
    )
    _require_unique_semantic_owner(claims, input_dir)
    inventory_by_id = {item.record.source_id: item for item in inventories}
    decision_evidence_bytes: bytes | None = None
    decision_snapshot: DecisionEvidenceSnapshot | None = None
    linear_inventory = inventory_by_id.get("LINEAR-CANON-V3")
    if linear_inventory is not None:
        if decision_evidence_path is None:
            decision_evidence_path = (
                root / ".codex/canon-migration/sources/linear-decision-evidence.json"
            )
        decision_evidence_path = _normalized_absolute(decision_evidence_path)
        _require_ignored_decision_evidence(root, decision_evidence_path)
        decision_evidence_bytes = _read_catalog_bytes(
            decision_evidence_path, allow_missing=False
        )
        assert decision_evidence_bytes is not None
        decision_snapshot = parse_decision_evidence_snapshot(
            decision_evidence_bytes, decision_evidence_path
        )
        _validate_decision_claim_bindings(
            claims,
            decision_snapshot,
            linear_inventory,
            input_dir,
        )
    section_claims: dict[tuple[str, str], list[str]] = {}
    for item in claims:
        inventory = inventory_by_id.get(item.source_id)
        if inventory is None:
            raise CanonError(
                "CLAIM_SOURCE_UNKNOWN",
                f"claim references unknown source_id: {item.source_id}",
                input_dir,
            )
        section = _claim_section(inventory, item.source_location, input_dir)
        _validate_original_text(inventory, item, input_dir)
        section_claims.setdefault((item.source_id, section), []).append(item.claim_id)
    section_dispositions: dict[tuple[str, str], SourceSectionDisposition] = {}
    for item in dispositions:
        inventory = inventory_by_id.get(item.source_id)
        if inventory is None:
            raise CanonError(
                "CLAIM_SOURCE_UNKNOWN",
                f"section disposition references unknown source_id: {item.source_id}",
                input_dir,
            )
        section = _claim_section(inventory, item.source_location, input_dir)
        key = (item.source_id, section)
        if key in section_dispositions:
            raise CanonError(
                "CLAIM_SECTION_DISPOSITION_DUPLICATE",
                f"duplicate source section disposition: {item.source_id} {section}",
                input_dir,
            )
        if key in section_claims:
            raise CanonError(
                "CLAIM_SECTION_DISPOSITION_CONFLICT",
                "a source section cannot contain claims and also declare no normative claims",
                input_dir,
            )
        section_dispositions[key] = item
    expected_sections = tuple(
        (inventory.record.source_id, section)
        for inventory in inventories
        for section in inventory.sections
    )
    uncovered = tuple(
        {"source_id": source_id, "source_location": section}
        for source_id, section in expected_sections
        if (source_id, section) not in section_claims
        and (source_id, section) not in section_dispositions
    )
    if uncovered:
        preview = ", ".join(
            f"{item['source_id']}:{item['source_location']}" for item in uncovered[:8]
        )
        raise CanonError(
            "CLAIM_COVERAGE_INCOMPLETE",
            f"registered source sections lack disposition ({len(uncovered)}): {preview}",
            input_dir,
        )
    payload = _claim_disposition_payload(
        catalog_bytes,
        inventories,
        claims,
        section_claims,
        section_dispositions,
        uncovered,
        decision_evidence_bytes,
        decision_snapshot,
    )
    _require_inventory_snapshots_bound(inventories)
    _require_claim_sources_verified(catalog_path, root)
    final_catalog_bytes = _read_catalog_bytes(catalog_path, allow_missing=False)
    if final_catalog_bytes != catalog_bytes:
        raise CanonError(
            "CLAIM_SOURCE_VERIFICATION_FAILED",
            "source catalog changed during claim import",
            catalog_path,
        )
    if decision_evidence_path is not None and decision_evidence_bytes is not None:
        final_evidence = _read_catalog_bytes(
            decision_evidence_path, allow_missing=False
        )
        if final_evidence != decision_evidence_bytes:
            raise CanonError(
                "CLAIM_DECISION_EVIDENCE_CHANGED",
                "decision evidence changed during claim import",
                decision_evidence_path,
            )
    _revalidate_inventory_snapshots(inventories)
    _write_claim_json(
        output_path,
        payload,
        validate=lambda: _revalidate_inventory_snapshots(inventories),
    )
    return ClaimImportResult(
        source_count=len(inventories),
        section_count=len(expected_sections),
        linear_decision_count=sum(
            1
            for inventory in inventories
            for section in inventory.sections
            if inventory.record.source_id == "LINEAR-CANON-V3"
            and section.startswith("decision:")
        ),
        claim_count=len(claims),
        output_path=output_path,
    )


def _require_claim_sources_verified(catalog_path: Path, root: Path) -> None:
    findings = verify_catalog(catalog_path, root)
    if not findings:
        return
    finding = findings[0]
    raise CanonError(
        "CLAIM_SOURCE_VERIFICATION_FAILED",
        f"{finding.code}: {finding.message}",
        finding.path or catalog_path,
        finding.line,
    )


def _require_ignored_decision_evidence(root: Path, path: Path) -> None:
    expected = root / ".codex/canon-migration/sources/linear-decision-evidence.json"
    if path != expected:
        raise CanonError(
            "CLAIM_DECISION_EVIDENCE_PATH_UNSAFE",
            "decision evidence must use the exact ignored migration path",
            path,
        )
    relative = path.relative_to(root).as_posix()
    ignored = _git_result(root, "check-ignore", "--no-index", "-q", "--", relative)
    tracked = _git_result(root, "ls-files", "--", relative)
    if ignored.returncode != 0 or tracked.returncode != 0 or tracked.stdout.strip():
        raise CanonError(
            "CLAIM_DECISION_EVIDENCE_PATH_UNSAFE",
            "decision evidence must remain ignored and untracked",
            path,
        )


def _validate_decision_claim_bindings(
    claims: tuple[AtomicClaim, ...],
    snapshot: DecisionEvidenceSnapshot,
    linear_inventory: _SourceInventory,
    path: Path,
) -> None:
    decision_claims: dict[int, AtomicClaim] = {}
    for item in claims:
        kind, number = _parse_source_location(item.source_location, path)
        if item.source_id != "LINEAR-CANON-V3" or kind != "decision":
            continue
        assert number is not None
        if number in decision_claims:
            raise CanonError(
                "CLAIM_DECISION_MAPPING_DUPLICATE",
                f"duplicate claim mapping for Decision {number}",
                path,
            )
        decision_claims[number] = item
    if tuple(sorted(decision_claims)) != tuple(range(1, 202)):
        raise CanonError(
            "CLAIM_DECISION_MAPPING_INCOMPLETE",
            "Linear v3 requires exactly one evidence-backed claim for Decisions 1 through 201",
            path,
        )
    for entry in snapshot.evidence_entries:
        item = decision_claims[entry.decision_number]
        if (
            item.owner_approval != entry.evidence_locator
            or item.owner_evidence_text != entry.owner_evidence_text
            or item.owner_evidence_rationale != entry.owner_evidence_rationale
            or item.original_text != entry.v3_clause
            or item.value != entry.v3_clause
        ):
            raise CanonError(
                "CLAIM_DECISION_MAPPING_MISMATCH",
                f"Decision {entry.decision_number} claim does not match exact owner evidence and v3 clause",
                path,
            )
        if entry.v3_clause not in linear_inventory.text:
            raise CanonError(
                "CLAIM_DECISION_MAPPING_MISMATCH",
                f"Decision {entry.decision_number} v3 clause is absent from exact registered bytes",
                path,
            )
        if (
            item.disposition
            not in {
                ClaimDisposition.PROVENANCE_ONLY,
                ClaimDisposition.CONFLICT,
            }
            or item.target_id is not None
        ):
            raise CanonError(
                "CLAIM_DECISION_MAPPING_AUTHORITY",
                "decision mappings are provenance/conflict evidence, not automatic canonical owners",
                path,
            )
        if entry.mapping_status == "unreviewed" and item.disposition not in {
            ClaimDisposition.PROVENANCE_ONLY,
            ClaimDisposition.CONFLICT,
        }:
            raise CanonError(
                "CLAIM_DECISION_MAPPING_UNREVIEWED",
                f"unreviewed Decision {entry.decision_number} mapping must remain provenance/conflict only",
                path,
            )


def _require_ignored_claim_input(root: Path, input_dir: Path) -> None:
    try:
        relative = input_dir.relative_to(root).as_posix()
    except ValueError as exc:
        raise CanonError(
            "CLAIM_INPUT_PATH_UNSAFE",
            "claim input must be inside the repository",
            input_dir,
        ) from exc
    ignored = _git_result(root, "check-ignore", "--no-index", "-q", "--", relative)
    if ignored.returncode != 0:
        raise CanonError(
            "CLAIM_INPUT_NOT_IGNORED",
            "raw claim batches must remain under ignored repository state",
            input_dir,
        )
    tracked = _git_result(root, "ls-files", "--", relative)
    if tracked.returncode != 0 or tracked.stdout.strip():
        raise CanonError(
            "CLAIM_INPUT_TRACKED",
            "raw claim batches must not be tracked or staged",
            input_dir,
        )


def _read_claim_batches(input_dir: Path) -> tuple[ClaimBatch, ...]:
    batches: list[ClaimBatch] = []
    with _open_directory_absolute_nofollow(input_dir) as descriptor:
        try:
            names = sorted(os.listdir(descriptor))
        except OSError as exc:
            raise CanonError(
                "CLAIM_INPUT_PATH_UNSAFE",
                "unable to inspect claim batch directory",
                input_dir,
            ) from exc
        if not names:
            raise CanonError("CLAIM_BATCH_MISSING", "no claim batches found", input_dir)
        for name in names:
            if not name.endswith(".json") or "/" in name or name in {".", ".."}:
                raise CanonError(
                    "CLAIM_INPUT_PATH_UNSAFE",
                    f"unsupported claim batch entry: {name}",
                    input_dir / name,
                )
            try:
                before = os.stat(name, dir_fd=descriptor, follow_symlinks=False)
                if not stat.S_ISREG(before.st_mode):
                    raise OSError(errno.ELOOP, "claim batch is not a regular file")
                file_descriptor = os.open(
                    name,
                    os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0),
                    dir_fd=descriptor,
                )
                try:
                    opened = os.fstat(file_descriptor)
                    if _claim_file_signature(before) != _claim_file_signature(opened):
                        raise OSError(errno.ESTALE, "claim batch changed before open")
                    raw = _read_descriptor(file_descriptor)
                    opened_after = os.fstat(file_descriptor)
                    after = os.stat(name, dir_fd=descriptor, follow_symlinks=False)
                    if _claim_file_signature(opened_after) != _claim_file_signature(
                        opened
                    ) or _claim_file_signature(after) != _claim_file_signature(opened):
                        raise CanonError(
                            "CLAIM_INPUT_CHANGED",
                            "claim batch changed during descriptor read",
                            input_dir / name,
                        )
                finally:
                    os.close(file_descriptor)
            except OSError as exc:
                raise CanonError(
                    "CLAIM_INPUT_PATH_UNSAFE",
                    "claim batch must be a stable no-follow regular file",
                    input_dir / name,
                ) from exc
            batches.append(parse_claim_batch(raw, input_dir / name))
    _require_unique(
        (item.batch_id for item in batches),
        "CLAIM_BATCH_DUPLICATE",
        "batch_id",
        input_dir,
    )
    return tuple(sorted(batches, key=lambda item: item.batch_id))


def _claim_file_signature(info: os.stat_result) -> tuple[int, int, int, int, int]:
    return (
        info.st_dev,
        info.st_ino,
        info.st_size,
        info.st_mtime_ns,
        info.st_ctime_ns,
    )


def _source_inventories(
    root: Path,
    records: tuple[SourceRecord, ...],
) -> tuple[_SourceInventory, ...]:
    inventories: list[_SourceInventory] = []
    for record in records:
        relative_text = record.repo_path or record.raw_path
        assert relative_text is not None
        relative = Path(relative_text)
        if relative.is_absolute() or ".." in relative.parts:
            raise CanonError(
                "CLAIM_SOURCE_PATH_UNSAFE",
                "registered source path is unsafe",
                relative,
            )
        source_path = root / relative
        raw, identity = _read_claim_source_snapshot(source_path)
        content_sha256 = hashlib.sha256(raw).hexdigest()
        expected_sha256 = record.content_sha256 or record.raw_sha256
        assert expected_sha256 is not None
        if content_sha256 != expected_sha256 or (
            record.raw_byte_length is not None and len(raw) != record.raw_byte_length
        ):
            raise CanonError(
                "CLAIM_SOURCE_VERIFICATION_FAILED",
                "inventory bytes do not match the registered source snapshot",
                source_path,
            )
        try:
            text = raw.decode("utf-8")
        except UnicodeDecodeError as exc:
            raise CanonError(
                "CLAIM_SOURCE_INVALID_UTF8",
                "claim source must be valid UTF-8",
                source_path,
            ) from exc
        lines = tuple(text.splitlines())
        is_markdown = relative.suffix.lower() in {".md", ".markdown"}
        heading_lines = tuple(
            number
            for number, line in enumerate(lines, 1)
            if is_markdown and MARKDOWN_HEADING_PATTERN.match(line)
        )
        sections = tuple(f"line:{number}" for number in heading_lines)
        if not sections:
            sections = ("document",)
        if record.source_id == "LINEAR-CANON-V3":
            sections = (*sections, *(f"decision:{number}" for number in range(1, 202)))
        inventories.append(
            _SourceInventory(
                record,
                source_path,
                raw,
                identity,
                len(raw),
                content_sha256,
                text,
                lines,
                sections,
                heading_lines,
            )
        )
    return tuple(sorted(inventories, key=lambda item: item.record.source_id))


def _require_inventory_snapshots_bound(
    inventories: tuple[_SourceInventory, ...],
) -> None:
    for inventory in inventories:
        raw = inventory.raw
        expected_sha256 = inventory.record.content_sha256 or inventory.record.raw_sha256
        assert expected_sha256 is not None
        if (
            len(raw) != inventory.byte_length
            or hashlib.sha256(raw).hexdigest() != inventory.content_sha256
            or inventory.content_sha256 != expected_sha256
            or (
                inventory.record.raw_byte_length is not None
                and inventory.byte_length != inventory.record.raw_byte_length
            )
        ):
            raise CanonError(
                "CLAIM_SOURCE_VERIFICATION_FAILED",
                "inventory snapshot changed or is not bound to registered bytes",
                Path(inventory.record.repo_path or inventory.record.raw_path or ""),
            )


def _read_claim_source_snapshot(
    source_path: Path,
) -> tuple[bytes, tuple[int, int, int, int, int]]:
    try:
        with _open_parent_nofollow(source_path) as (
            parent_descriptor,
            name,
            absolute,
        ):
            before = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
            if not stat.S_ISREG(before.st_mode):
                raise CanonError(
                    "CLAIM_SOURCE_PATH_UNSAFE",
                    "claim source must be a no-follow regular file",
                    absolute,
                )
            descriptor = os.open(
                name,
                os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0),
                dir_fd=parent_descriptor,
            )
            try:
                opened = os.fstat(descriptor)
                if _claim_file_signature(before) != _claim_file_signature(opened):
                    raise CanonError(
                        "CLAIM_SOURCE_CHANGED",
                        "claim source changed before descriptor open",
                        absolute,
                    )
                raw = _read_descriptor(descriptor)
                opened_after = os.fstat(descriptor)
                after = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
                identity = _claim_file_signature(opened)
                if (
                    _claim_file_signature(opened_after) != identity
                    or _claim_file_signature(after) != identity
                ):
                    raise CanonError(
                        "CLAIM_SOURCE_CHANGED",
                        "claim source changed during descriptor read",
                        absolute,
                    )
                return raw, identity
            finally:
                os.close(descriptor)
    except CanonError:
        raise
    except (FileNotFoundError, OSError) as exc:
        raise CanonError(
            "CLAIM_SOURCE_PATH_UNSAFE",
            "claim source must be a stable no-follow regular file",
            source_path,
        ) from exc


def _revalidate_inventory_snapshots(
    inventories: tuple[_SourceInventory, ...],
) -> None:
    _require_inventory_snapshots_bound(inventories)
    for inventory in inventories:
        raw, identity = _read_claim_source_snapshot(inventory.source_path)
        if raw != inventory.raw or identity != inventory.identity:
            raise CanonError(
                "CLAIM_SOURCE_CHANGED",
                "claim source changed after inventory snapshot",
                inventory.source_path,
            )


def _claim_section(
    inventory: _SourceInventory,
    location: str,
    path: Path,
) -> str:
    kind, number = _parse_source_location(location, path)
    if kind == "document":
        if inventory.heading_lines:
            raise CanonError(
                "CLAIM_SOURCE_LOCATION_INVALID",
                "document location is invalid for a sectioned Markdown source",
                path,
            )
        return "document"
    assert number is not None
    if kind == "decision":
        if inventory.record.source_id != "LINEAR-CANON-V3" or not 1 <= number <= 201:
            raise CanonError(
                "CLAIM_SOURCE_LOCATION_INVALID",
                "decision locations are Linear v3 Decision 1 through 201 only",
                path,
            )
        return f"decision:{number}"
    if number > len(inventory.lines):
        raise CanonError(
            "CLAIM_SOURCE_LOCATION_INVALID",
            f"source line does not exist: {location}",
            path,
        )
    if not inventory.heading_lines:
        return "document"
    headings = tuple(item for item in inventory.heading_lines if item <= number)
    if not headings:
        raise CanonError(
            "CLAIM_SOURCE_LOCATION_INVALID",
            "source line precedes the first Markdown section",
            path,
        )
    return f"line:{headings[-1]}"


def _validate_original_text(
    inventory: _SourceInventory,
    claim: AtomicClaim,
    path: Path,
) -> None:
    kind, number = _parse_source_location(claim.source_location, path)
    if kind != "line":
        if not _source_contains_original_text(inventory, claim.original_text):
            raise CanonError(
                "CLAIM_ORIGINAL_TEXT_MISMATCH",
                f"claim original_text is absent from exact source bytes for {claim.source_location}",
                path,
            )
        return
    assert number is not None
    line = inventory.lines[number - 1]
    if claim.original_text not in line:
        raise CanonError(
            "CLAIM_ORIGINAL_TEXT_MISMATCH",
            f"claim original_text is not present at {claim.source_location}",
            path,
        )


def _source_contains_original_text(
    inventory: _SourceInventory,
    original_text: str,
) -> bool:
    if original_text in inventory.text:
        return True
    source_path = inventory.record.repo_path or inventory.record.raw_path or ""
    if Path(source_path).suffix.lower() != ".json":
        return False
    try:
        payload = json.loads(inventory.text)
    except json.JSONDecodeError:
        return False
    return original_text in _json_scalar_strings(payload)


def _json_scalar_strings(value: object) -> frozenset[str]:
    strings: set[str] = set()
    if isinstance(value, str):
        strings.add(value)
    elif isinstance(value, list):
        for item in value:
            strings.update(_json_scalar_strings(item))
    elif isinstance(value, dict):
        for key, item in value.items():
            strings.add(str(key))
            strings.update(_json_scalar_strings(item))
    return frozenset(strings)


def _semantic_payload(item: AtomicClaim) -> dict[str, object]:
    return {
        "concept": item.concept,
        "subject": item.subject,
        "predicate": item.predicate,
        "value": item.value,
        "modality": item.modality.value,
        "scope": item.scope,
        "conditions": list(item.conditions),
        "exceptions": list(item.exceptions),
        "authority_claim": item.authority_claim,
    }


def _require_unique_semantic_owner(
    claims: tuple[AtomicClaim, ...],
    path: Path,
) -> None:
    owners_by_semantic: dict[str, set[tuple[str, str]]] = {}
    claim_ids_by_semantic: dict[str, list[str]] = {}
    for item in claims:
        semantic_sha = hashlib.sha256(stable_json(_semantic_payload(item))).hexdigest()
        claim_ids_by_semantic.setdefault(semantic_sha, []).append(item.claim_id)
        if (
            item.target_id is not None
            and item.disposition is not ClaimDisposition.CONFLICT
        ):
            owners_by_semantic.setdefault(semantic_sha, set()).add(
                (item.target_class.value, item.target_id)
            )
    for semantic_sha, owners in sorted(owners_by_semantic.items()):
        if len(owners) > 1:
            claim_ids = ", ".join(sorted(claim_ids_by_semantic[semantic_sha]))
            raise CanonError(
                "CLAIM_SEMANTIC_OWNER_CONFLICT",
                f"identical normalized semantics have divergent target owners: {claim_ids}",
                path,
            )


def _claim_disposition_payload(
    catalog_bytes: bytes,
    inventories: tuple[_SourceInventory, ...],
    claims: tuple[AtomicClaim, ...],
    section_claims: dict[tuple[str, str], list[str]],
    section_dispositions: dict[tuple[str, str], SourceSectionDisposition],
    uncovered: tuple[dict[str, str], ...],
    decision_evidence_bytes: bytes | None,
    decision_snapshot: DecisionEvidenceSnapshot | None,
) -> dict[str, object]:
    decision_entry_by_number = {
        entry.decision_number: entry
        for entry in (decision_snapshot.evidence_entries if decision_snapshot else ())
    }
    groups: dict[str, list[str]] = {}
    for item in claims:
        semantic_sha = hashlib.sha256(stable_json(_semantic_payload(item))).hexdigest()
        groups.setdefault(semantic_sha, []).append(item.claim_id)
    coverage: list[dict[str, object]] = []
    for inventory in inventories:
        for section in inventory.sections:
            key = (inventory.record.source_id, section)
            claim_ids = sorted(section_claims.get(key, ()))
            disposition = section_dispositions.get(key)
            coverage.append(
                {
                    "claim_ids": claim_ids,
                    "disposition": "claims" if claim_ids else "no_normative_claims",
                    "rationale_sha256": (
                        hashlib.sha256(
                            disposition.rationale.encode("utf-8")
                        ).hexdigest()
                        if disposition is not None
                        else None
                    ),
                    "source_id": inventory.record.source_id,
                    "source_location": section,
                }
            )
    return {
        "catalog_sha256": hashlib.sha256(catalog_bytes).hexdigest(),
        "decision_evidence_sha256": (
            hashlib.sha256(decision_evidence_bytes).hexdigest()
            if decision_evidence_bytes is not None
            else None
        ),
        "decision_mapping_counts": {
            "independently_reviewed": sum(
                entry.mapping_status == "independently_reviewed"
                for entry in (
                    decision_snapshot.evidence_entries if decision_snapshot else ()
                )
            ),
            "unreviewed": sum(
                entry.mapping_status == "unreviewed"
                for entry in (
                    decision_snapshot.evidence_entries if decision_snapshot else ()
                )
            ),
        },
        "claims": [
            {
                "authority_claim": item.authority_claim,
                "claim_id": item.claim_id,
                "concept": item.concept,
                "decision_mapping_status": (
                    decision_entry_by_number[
                        int(item.source_location.split(":", 1)[1])
                    ].mapping_status
                    if item.source_id == "LINEAR-CANON-V3"
                    and item.source_location.startswith("decision:")
                    else None
                ),
                "disposition": item.disposition.value,
                "owner_approval_sha256": (
                    hashlib.sha256(item.owner_approval.encode("utf-8")).hexdigest()
                    if item.owner_approval is not None
                    else None
                ),
                "owner_evidence_rationale_sha256": (
                    hashlib.sha256(
                        item.owner_evidence_rationale.encode("utf-8")
                    ).hexdigest()
                    if item.owner_evidence_rationale is not None
                    else None
                ),
                "owner_evidence_text_sha256": (
                    hashlib.sha256(item.owner_evidence_text.encode("utf-8")).hexdigest()
                    if item.owner_evidence_text is not None
                    else None
                ),
                "rationale_sha256": hashlib.sha256(
                    item.rationale.encode("utf-8")
                ).hexdigest(),
                "source_id": item.source_id,
                "source_location": item.source_location,
                "target_class": item.target_class.value,
                "target_id": item.target_id,
            }
            for item in claims
        ],
        "coverage": sorted(
            coverage,
            key=lambda item: (str(item["source_id"]), str(item["source_location"])),
        ),
        "linear_decision_count": sum(
            1
            for inventory in inventories
            for section in inventory.sections
            if inventory.record.source_id == "LINEAR-CANON-V3"
            and section.startswith("decision:")
        ),
        "schema_version": 1,
        "section_count": sum(len(item.sections) for item in inventories),
        "semantic_groups": [
            {"claim_ids": sorted(claim_ids), "semantic_sha256": semantic_sha}
            for semantic_sha, claim_ids in sorted(groups.items())
        ],
        "source_count": len(inventories),
        "uncovered": list(uncovered),
    }


def _retain_claim_recovery(
    parent_descriptor: int,
    name: str,
    content: bytes,
    absolute: Path,
    label: str,
    *,
    created_names: set[str] | None = None,
) -> Path:
    digest = hashlib.sha256(content).hexdigest()
    base = f".{name}.claim-recovery-{label}-{digest}"
    for collision in range(256):
        candidate = base if collision == 0 else f"{base}-{collision:02x}"
        candidate_path = absolute.with_name(candidate)
        try:
            descriptor = os.open(
                candidate,
                os.O_WRONLY
                | os.O_CREAT
                | os.O_EXCL
                | os.O_NOFOLLOW
                | getattr(os, "O_CLOEXEC", 0),
                0o600,
                dir_fd=parent_descriptor,
            )
        except FileExistsError:
            try:
                info = os.stat(
                    candidate,
                    dir_fd=parent_descriptor,
                    follow_symlinks=False,
                )
                if not stat.S_ISREG(info.st_mode):
                    continue
                existing_descriptor = os.open(
                    candidate,
                    os.O_RDONLY
                    | os.O_NONBLOCK
                    | os.O_NOFOLLOW
                    | getattr(os, "O_CLOEXEC", 0),
                    dir_fd=parent_descriptor,
                )
                try:
                    opened = os.fstat(existing_descriptor)
                    if not stat.S_ISREG(opened.st_mode) or _claim_file_signature(
                        opened
                    ) != _claim_file_signature(info):
                        continue
                    existing = _read_descriptor(existing_descriptor)
                    opened_after = os.fstat(existing_descriptor)
                    if _claim_file_signature(opened_after) != _claim_file_signature(
                        opened
                    ):
                        continue
                finally:
                    os.close(existing_descriptor)
                if existing == content:
                    return candidate_path
            except (FileNotFoundError, OSError):
                pass
            continue
        except OSError as exc:
            raise CanonError(
                "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                "unable to create deterministic claim recovery",
                candidate_path,
            ) from exc
        try:
            view = memoryview(content)
            while view:
                written = os.write(descriptor, view)
                if written == 0:
                    raise OSError(errno.EIO, "short recovery write")
                view = view[written:]
            os.fsync(descriptor)
        except OSError:
            try:
                os.unlink(candidate, dir_fd=parent_descriptor)
            except OSError:
                pass
            raise CanonError(
                "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                "unable to retain exact claim recovery bytes",
                candidate_path,
            )
        finally:
            os.close(descriptor)
        try:
            os.fsync(parent_descriptor)
        except OSError as exc:
            raise CanonError(
                "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                "claim recovery bytes retained but directory sync failed",
                candidate_path,
            ) from exc
        if created_names is not None:
            created_names.add(candidate)
        return candidate_path
    raise CanonError(
        "CLAIM_OUTPUT_RECOVERY_REQUIRED",
        f"deterministic claim recovery probes exhausted for {label}",
        absolute.with_name(base),
    )


def _remove_created_claim_recovery(
    parent_descriptor: int,
    artifact: Path | None,
    expected: bytes,
    created_names: set[str],
) -> None:
    if artifact is None or artifact.name not in created_names:
        return
    raw, _identity = _read_claim_output_at(
        parent_descriptor,
        artifact.name,
        artifact,
        allow_missing=False,
    )
    if raw != expected:
        raise CanonError(
            "CLAIM_OUTPUT_RECOVERY_REQUIRED",
            "claim recovery changed before successful cleanup",
            artifact,
        )
    os.unlink(artifact.name, dir_fd=parent_descriptor)
    created_names.remove(artifact.name)


def _read_claim_output_at(
    parent_descriptor: int,
    name: str,
    path: Path,
    *,
    allow_missing: bool,
) -> tuple[bytes | None, tuple[int, int] | None]:
    try:
        before = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
    except FileNotFoundError:
        if allow_missing:
            return None, None
        raise CanonError(
            "CLAIM_OUTPUT_PATH_UNSAFE",
            "claim output disappeared during transaction",
            path,
        )
    if not stat.S_ISREG(before.st_mode):
        raise CanonError(
            "CLAIM_OUTPUT_PATH_UNSAFE",
            "claim output must remain a no-follow regular file",
            path,
        )
    try:
        descriptor = os.open(
            name,
            os.O_RDONLY | os.O_NONBLOCK | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0),
            dir_fd=parent_descriptor,
        )
    except OSError as exc:
        raise CanonError(
            "CLAIM_OUTPUT_PATH_UNSAFE",
            "claim output must remain a stable no-follow regular file",
            path,
        ) from exc
    try:
        opened = os.fstat(descriptor)
        if _claim_file_signature(opened) != _claim_file_signature(before):
            raise CanonError(
                "CLAIM_OUTPUT_CHANGED",
                "claim output changed before descriptor open",
                path,
            )
        raw = _read_descriptor(descriptor)
        opened_after = os.fstat(descriptor)
        after = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
        if _claim_file_signature(opened_after) != _claim_file_signature(
            opened
        ) or _claim_file_signature(after) != _claim_file_signature(opened):
            raise CanonError(
                "CLAIM_OUTPUT_CHANGED",
                "claim output changed during descriptor read",
                path,
            )
        return raw, (opened.st_dev, opened.st_ino)
    finally:
        os.close(descriptor)


def _write_claim_json(
    path: Path,
    payload: object,
    *,
    validate: Callable[[], None] | None = None,
) -> None:
    content = stable_json(payload)
    with _open_parent_nofollow(path) as (parent_descriptor, name, absolute):
        try:
            initial_bytes, initial_identity = _read_claim_output_at(
                parent_descriptor,
                name,
                absolute,
                allow_missing=True,
            )
        except CanonError as exc:
            raise CanonError(
                "CLAIM_OUTPUT_PATH_UNSAFE",
                "claim output must be a no-follow regular file",
                absolute,
            ) from exc
        temporary = f".{name}.claim-tmp-{hashlib.sha256(content).hexdigest()}"
        temporary_exists = False
        displaced_retained = False
        created_recoveries: set[str] = set()
        transaction_recovery: Path | None = None
        prior_recovery: Path | None = None
        try:
            descriptor = os.open(
                temporary,
                os.O_WRONLY
                | os.O_CREAT
                | os.O_EXCL
                | os.O_NOFOLLOW
                | getattr(os, "O_CLOEXEC", 0),
                0o600,
                dir_fd=parent_descriptor,
            )
            temporary_exists = True
            try:
                view = memoryview(content)
                while view:
                    written = os.write(descriptor, view)
                    if written == 0:
                        raise OSError(errno.EIO, "short claim output write")
                    view = view[written:]
                os.fsync(descriptor)
            finally:
                os.close(descriptor)
            if validate is not None:
                validate()
            if initial_identity is None:
                try:
                    transaction_recovery = _retain_claim_recovery(
                        parent_descriptor,
                        name,
                        content,
                        absolute,
                        "transaction",
                        created_names=created_recoveries,
                    )
                except CanonError as recovery_error:
                    displaced_retained = True
                    raise CanonError(
                        "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                        f"transaction staging retained at {temporary}",
                        absolute.with_name(temporary),
                    ) from recovery_error
                try:
                    _rename_noreplace(
                        temporary,
                        name,
                        source_directory=parent_descriptor,
                        destination_directory=parent_descriptor,
                    )
                except FileExistsError as exc:
                    _remove_created_claim_recovery(
                        parent_descriptor,
                        transaction_recovery,
                        content,
                        created_recoveries,
                    )
                    raise CanonError(
                        "CLAIM_OUTPUT_CHANGED",
                        "claim output appeared during atomic installation",
                        absolute,
                    ) from exc
                temporary_exists = False
                installed_bytes, installed_identity = _read_claim_output_at(
                    parent_descriptor,
                    name,
                    absolute,
                    allow_missing=False,
                )
                if validate is not None:
                    try:
                        validate()
                    except CanonError:
                        displaced_retained = True
                        try:
                            current_bytes, current_identity = _read_claim_output_at(
                                parent_descriptor,
                                name,
                                absolute,
                                allow_missing=False,
                            )
                        except CanonError as concurrent_error:
                            recovery = _retain_claim_recovery(
                                parent_descriptor,
                                name,
                                content,
                                absolute,
                                "transaction",
                            )
                            raise CanonError(
                                "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                                "unsafe concurrent output preserved; transaction retained at "
                                f"{recovery.name}",
                                recovery,
                            ) from concurrent_error
                        if (
                            current_identity != installed_identity
                            or current_bytes != installed_bytes
                        ):
                            recovery = _retain_claim_recovery(
                                parent_descriptor,
                                name,
                                content,
                                absolute,
                                "transaction",
                            )
                            raise CanonError(
                                "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                                f"concurrent output preserved; transaction retained at {recovery.name}",
                                recovery,
                            )
                        os.unlink(name, dir_fd=parent_descriptor)
                        _remove_created_claim_recovery(
                            parent_descriptor,
                            transaction_recovery,
                            content,
                            created_recoveries,
                        )
                        os.fsync(parent_descriptor)
                        raise
            else:
                current_bytes, current_identity = _read_claim_output_at(
                    parent_descriptor,
                    name,
                    absolute,
                    allow_missing=False,
                )
                if (
                    current_identity != initial_identity
                    or current_bytes != initial_bytes
                ):
                    raise CanonError(
                        "CLAIM_OUTPUT_CHANGED",
                        "claim output changed before atomic installation",
                        absolute,
                    )
                try:
                    transaction_recovery = _retain_claim_recovery(
                        parent_descriptor,
                        name,
                        content,
                        absolute,
                        "transaction",
                        created_names=created_recoveries,
                    )
                    prior_recovery = _retain_claim_recovery(
                        parent_descriptor,
                        name,
                        initial_bytes or b"",
                        absolute,
                        "prior",
                        created_names=created_recoveries,
                    )
                except CanonError as recovery_error:
                    displaced_retained = True
                    raise CanonError(
                        "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                        "prior output remains canonical; transaction staging retained at "
                        f"{temporary}",
                        absolute.with_name(temporary),
                    ) from recovery_error
                _rename_exchange(
                    temporary,
                    name,
                    source_directory=parent_descriptor,
                    destination_directory=parent_descriptor,
                )
                displaced_bytes, displaced_identity = _read_claim_output_at(
                    parent_descriptor,
                    temporary,
                    absolute.with_name(temporary),
                    allow_missing=False,
                )
                if (
                    displaced_identity != initial_identity
                    or displaced_bytes != initial_bytes
                ):
                    try:
                        _rename_exchange(
                            temporary,
                            name,
                            source_directory=parent_descriptor,
                            destination_directory=parent_descriptor,
                        )
                    except (CanonError, OSError) as rollback_error:
                        displaced_retained = True
                        raise CanonError(
                            "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                            f"concurrent output retained at {temporary}",
                            absolute.with_name(temporary),
                        ) from rollback_error
                    raise CanonError(
                        "CLAIM_OUTPUT_CHANGED",
                        "claim output changed during atomic installation",
                        absolute,
                    )
                installed_bytes, installed_identity = _read_claim_output_at(
                    parent_descriptor,
                    name,
                    absolute,
                    allow_missing=False,
                )
                if installed_bytes != content:
                    displaced_retained = True
                    raise CanonError(
                        "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                        f"prior claim output retained at {temporary}",
                        absolute.with_name(temporary),
                    )
                if validate is not None:
                    try:
                        validate()
                    except CanonError:
                        displaced_retained = True
                        try:
                            current_bytes, current_identity = _read_claim_output_at(
                                parent_descriptor,
                                name,
                                absolute,
                                allow_missing=False,
                            )
                        except CanonError as concurrent_error:
                            transaction_recovery = _retain_claim_recovery(
                                parent_descriptor,
                                name,
                                content,
                                absolute,
                                "transaction",
                            )
                            prior_recovery = _retain_claim_recovery(
                                parent_descriptor,
                                name,
                                initial_bytes or b"",
                                absolute,
                                "prior",
                            )
                            displaced_retained = True
                            os.fsync(parent_descriptor)
                            raise CanonError(
                                "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                                "unsafe concurrent output preserved; recovery artifacts retained at "
                                f"{prior_recovery.name} and {transaction_recovery.name}; "
                                f"ambiguous exchange artifact retained at {temporary}",
                                prior_recovery,
                            ) from concurrent_error
                        if (
                            current_identity != installed_identity
                            or current_bytes != installed_bytes
                        ):
                            transaction_recovery = _retain_claim_recovery(
                                parent_descriptor,
                                name,
                                content,
                                absolute,
                                "transaction",
                            )
                            prior_recovery = _retain_claim_recovery(
                                parent_descriptor,
                                name,
                                initial_bytes or b"",
                                absolute,
                                "prior",
                            )
                            displaced_retained = True
                            os.fsync(parent_descriptor)
                            raise CanonError(
                                "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                                "concurrent output preserved; recovery artifacts retained at "
                                f"{prior_recovery.name} and {transaction_recovery.name}; "
                                f"ambiguous exchange artifact retained at {temporary}",
                                prior_recovery,
                            )
                        try:
                            _rename_exchange(
                                temporary,
                                name,
                                source_directory=parent_descriptor,
                                destination_directory=parent_descriptor,
                            )
                            os.unlink(temporary, dir_fd=parent_descriptor)
                            temporary_exists = False
                            _remove_created_claim_recovery(
                                parent_descriptor,
                                transaction_recovery,
                                content,
                                created_recoveries,
                            )
                            _remove_created_claim_recovery(
                                parent_descriptor,
                                prior_recovery,
                                initial_bytes or b"",
                                created_recoveries,
                            )
                            os.fsync(parent_descriptor)
                        except (CanonError, OSError) as rollback_error:
                            transaction_recovery = _retain_claim_recovery(
                                parent_descriptor,
                                name,
                                content,
                                absolute,
                                "transaction",
                            )
                            prior_recovery = _retain_claim_recovery(
                                parent_descriptor,
                                name,
                                initial_bytes or b"",
                                absolute,
                                "prior",
                            )
                            displaced_retained = True
                            os.fsync(parent_descriptor)
                            raise CanonError(
                                "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                                "source-validation rollback failed; recovery artifacts retained at "
                                f"{prior_recovery.name} and {transaction_recovery.name}; "
                                f"ambiguous exchange artifact retained at {temporary}",
                                prior_recovery,
                            ) from rollback_error
                        raise
                os.unlink(temporary, dir_fd=parent_descriptor)
                temporary_exists = False
            _remove_created_claim_recovery(
                parent_descriptor,
                transaction_recovery,
                content,
                created_recoveries,
            )
            _remove_created_claim_recovery(
                parent_descriptor,
                prior_recovery,
                initial_bytes or b"",
                created_recoveries,
            )
            os.fsync(parent_descriptor)
        except CanonError:
            if temporary_exists and not displaced_retained:
                try:
                    os.unlink(temporary, dir_fd=parent_descriptor)
                except OSError:
                    pass
            raise
        except OSError as exc:
            if temporary_exists and not displaced_retained:
                try:
                    os.unlink(temporary, dir_fd=parent_descriptor)
                except OSError:
                    pass
            raise CanonError(
                "CLAIM_OUTPUT_WRITE",
                "unable to atomically write deterministic claim output",
                absolute,
            ) from exc


def validate_tracked_canon_evidence(
    root: Path,
) -> TrackedCanonEvidenceSnapshot | None:
    """Validate tracked migration evidence offline, without raw source content."""

    root = _normalized_absolute(root)
    migration_root = root / "docs/canon/migration"
    catalog_path = migration_root / "source-catalog.json"
    dispositions_path = migration_root / "claim-dispositions.json"
    baseline_path = migration_root / "conflict-docket-baseline.json"
    paths = (catalog_path, dispositions_path, baseline_path)
    present = tuple(os.path.lexists(path) for path in paths)
    if not any(present):
        return None
    if not all(present):
        missing = paths[present.index(False)]
        raise CanonError(
            "TRACKED_EVIDENCE_MISSING",
            "source catalog, claim dispositions, and conflict baseline are all required",
            missing,
        )

    catalog_bytes = _read_catalog_bytes(catalog_path, allow_missing=False)
    disposition_bytes = _read_catalog_bytes(dispositions_path, allow_missing=False)
    baseline_bytes = _read_catalog_bytes(baseline_path, allow_missing=False)
    assert catalog_bytes is not None
    assert disposition_bytes is not None
    assert baseline_bytes is not None
    records = _parse_catalog_bytes(catalog_bytes, catalog_path)
    payload = _tracked_json_object(disposition_bytes, dispositions_path)
    if set(payload) != TRACKED_DISPOSITION_FIELDS or payload.get("schema_version") != 1:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "claim dispositions use an unsupported closed shape",
            dispositions_path,
        )
    if payload.get("catalog_sha256") != hashlib.sha256(catalog_bytes).hexdigest():
        raise CanonError(
            "CLAIM_DISPOSITIONS_STALE",
            "claim dispositions are not bound to the current source catalog",
            dispositions_path,
        )

    collections = {
        name: payload.get(name)
        for name in ("claims", "coverage", "semantic_groups", "uncovered")
    }
    if not all(isinstance(value, list) for value in collections.values()):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "claim disposition record collections must be arrays",
            dispositions_path,
        )
    claims = tuple(
        _validate_tracked_claim(item, dispositions_path)
        for item in collections["claims"]
    )
    claim_ids = tuple(str(item["claim_id"]) for item in claims)
    if claim_ids != tuple(sorted(set(claim_ids))):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked claims must have unique sorted claim IDs",
            dispositions_path,
        )
    source_ids = tuple(record.source_id for record in records)
    source_id_set = set(source_ids)
    for claim in claims:
        if claim["source_id"] not in source_id_set:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                f"tracked claim references unknown source_id: {claim['source_id']}",
                dispositions_path,
            )

    decision_numbers = tuple(
        int(str(item["source_location"]).split(":", 1)[1])
        for item in claims
        if item["source_id"] == "LINEAR-CANON-V3"
        and str(item["source_location"]).startswith("decision:")
    )
    if "LINEAR-CANON-V3" in source_id_set and decision_numbers != tuple(range(1, 202)):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked dispositions require exact Decision 1 through 201 claims",
            dispositions_path,
        )
    evidence_sha = payload.get("decision_evidence_sha256")
    if "LINEAR-CANON-V3" in source_id_set:
        if not _is_sha256(evidence_sha):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "decision evidence checksum is invalid",
                dispositions_path,
            )
    elif evidence_sha is not None:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "decision evidence checksum requires a Linear source",
            dispositions_path,
        )
    decision_fingerprint = _decision_evidence_fingerprint_sha256(
        claims,
        evidence_sha,
        dispositions_path,
    )

    claim_by_id = {str(item["claim_id"]): item for item in claims}
    coverage_keys: list[tuple[str, str]] = []
    covered_claim_ids: list[str] = []
    for item in collections["coverage"]:
        if not isinstance(item, dict) or set(item) != TRACKED_COVERAGE_FIELDS:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "coverage entry uses an unsupported closed shape",
                dispositions_path,
            )
        source_id = _claim_string(item, "source_id", dispositions_path)
        source_location = _claim_string(item, "source_location", dispositions_path)
        _parse_source_location(source_location, dispositions_path)
        if source_id not in source_id_set:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                f"coverage references unknown source_id: {source_id}",
                dispositions_path,
            )
        entry_ids = item.get("claim_ids")
        disposition = item.get("disposition")
        rationale_sha = item.get("rationale_sha256")
        if (
            disposition not in {"claims", "no_normative_claims"}
            or not isinstance(entry_ids, list)
            or any(not isinstance(claim_id, str) for claim_id in entry_ids)
            or entry_ids != sorted(set(entry_ids))
        ):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "coverage disposition or claim IDs are invalid",
                dispositions_path,
            )
        if disposition == "claims":
            valid_disposition = bool(entry_ids) and rationale_sha is None
        else:
            valid_disposition = not entry_ids and _is_sha256(rationale_sha)
        if not valid_disposition:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "coverage rationale and claim IDs contradict its disposition",
                dispositions_path,
            )
        for claim_id in entry_ids:
            claim = claim_by_id.get(claim_id)
            if claim is None or claim["source_id"] != source_id:
                raise CanonError(
                    "CLAIM_DISPOSITIONS_INVALID",
                    "coverage references an unknown or cross-source claim ID",
                    dispositions_path,
                )
        coverage_keys.append((source_id, source_location))
        covered_claim_ids.extend(entry_ids)
    if coverage_keys != sorted(set(coverage_keys)):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "coverage entries must be unique and sorted",
            dispositions_path,
        )
    if set(source_ids) != {source_id for source_id, _ in coverage_keys}:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "coverage must retain every catalog source",
            dispositions_path,
        )
    if tuple(sorted(covered_claim_ids)) != claim_ids or len(covered_claim_ids) != len(
        set(covered_claim_ids)
    ):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "coverage must retain every tracked claim exactly once",
            dispositions_path,
        )

    grouped_claim_ids: list[str] = []
    previous_group_sha = ""
    for item in collections["semantic_groups"]:
        if not isinstance(item, dict) or set(item) != {
            "claim_ids",
            "semantic_sha256",
        }:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "semantic group uses an unsupported closed shape",
                dispositions_path,
            )
        semantic_sha = item.get("semantic_sha256")
        group_ids = item.get("claim_ids")
        if (
            not _is_sha256(semantic_sha)
            or not isinstance(group_ids, list)
            or any(not isinstance(claim_id, str) for claim_id in group_ids)
            or group_ids != sorted(set(group_ids))
            or any(claim_id not in claim_by_id for claim_id in group_ids)
            or str(semantic_sha) <= previous_group_sha
        ):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "semantic groups must be sorted and reference exact claim IDs",
                dispositions_path,
            )
        previous_group_sha = str(semantic_sha)
        grouped_claim_ids.extend(group_ids)
    if tuple(sorted(grouped_claim_ids)) != claim_ids or len(grouped_claim_ids) != len(
        set(grouped_claim_ids)
    ):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "semantic groups must retain every claim exactly once",
            dispositions_path,
        )

    uncovered_keys: list[tuple[str, str]] = []
    for item in collections["uncovered"]:
        if not isinstance(item, dict) or set(item) != {"source_id", "source_location"}:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "uncovered entry uses an unsupported closed shape",
                dispositions_path,
            )
        source_id = _claim_string(item, "source_id", dispositions_path)
        location = _claim_string(item, "source_location", dispositions_path)
        _parse_source_location(location, dispositions_path)
        if source_id not in source_id_set:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "uncovered entry references an unknown source",
                dispositions_path,
            )
        uncovered_keys.append((source_id, location))
    if uncovered_keys != sorted(set(uncovered_keys)) or uncovered_keys:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked coverage must be complete, unique, and sorted",
            dispositions_path,
        )

    counts = {
        "source_count": len(records),
        "section_count": len(coverage_keys),
        "linear_decision_count": len(decision_numbers),
    }
    for name, expected in counts.items():
        if (
            not isinstance(payload.get(name), int)
            or isinstance(payload.get(name), bool)
            or payload[name] != expected
        ):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                f"{name} differs from the tracked evidence graph",
                dispositions_path,
            )
    expected_mapping_counts = {
        status: sum(item["decision_mapping_status"] == status for item in claims)
        for status in ("independently_reviewed", "unreviewed")
    }
    if payload.get("decision_mapping_counts") != expected_mapping_counts:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "decision mapping counts differ from tracked claims",
            dispositions_path,
        )
    baseline = _tracked_json_object(baseline_bytes, baseline_path)
    if (
        set(baseline)
        != {
            "schema_version",
            "claim_dispositions_sha256",
            "decision_evidence_fingerprint_sha256",
            "resolution_provenance",
            "dockets",
        }
        or baseline.get("schema_version") != 1
        or not isinstance(baseline.get("dockets"), list)
    ):
        raise CanonError(
            "CONFLICT_BASELINE_INVALID",
            "conflict baseline uses an unsupported closed shape",
            baseline_path,
        )
    if baseline.get("decision_evidence_fingerprint_sha256") != decision_fingerprint:
        raise CanonError(
            "CONFLICT_DECISION_EVIDENCE_STALE",
            "conflict baseline is not bound to exact Decision 1-201 evidence",
            baseline_path,
        )
    if baseline.get("claim_dispositions_sha256") != hashlib.sha256(
        disposition_bytes
    ).hexdigest():
        raise CanonError(
            "CONFLICT_BASELINE_STALE",
            "conflict baseline is not bound to current claim dispositions",
            baseline_path,
        )
    return TrackedCanonEvidenceSnapshot(
        source_catalog_bytes=catalog_bytes,
        claim_dispositions_bytes=disposition_bytes,
        conflict_baseline_bytes=baseline_bytes,
        source_count=len(records),
        claim_count=len(claims),
        section_count=len(coverage_keys),
        linear_decision_count=len(decision_numbers),
        decision_evidence_fingerprint_sha256=decision_fingerprint,
    )


def tracked_decision_evidence_fingerprint_sha256(
    disposition_bytes: bytes,
    path: Path | None = None,
) -> str | None:
    """Fingerprint ordered tracked Decision 1-201 evidence without raw content."""

    source_path = path or Path("docs/canon/migration/claim-dispositions.json")
    payload = _tracked_json_object(disposition_bytes, source_path)
    if (
        set(payload) != TRACKED_DISPOSITION_FIELDS
        or payload.get("schema_version") != 1
        or not isinstance(payload.get("claims"), list)
    ):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "claim dispositions use an unsupported closed shape",
            source_path,
        )
    claims = tuple(
        _validate_tracked_claim(item, source_path) for item in payload["claims"]
    )
    evidence_sha = payload.get("decision_evidence_sha256")
    has_linear_decisions = any(
        item["source_id"] == "LINEAR-CANON-V3"
        and str(item["source_location"]).startswith("decision:")
        for item in claims
    )
    if has_linear_decisions and not _is_sha256(evidence_sha):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "decision evidence checksum is invalid",
            source_path,
        )
    if not has_linear_decisions and evidence_sha is not None:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "decision evidence checksum requires Linear Decision claims",
            source_path,
        )
    return _decision_evidence_fingerprint_sha256(claims, evidence_sha, source_path)


def _decision_evidence_fingerprint_sha256(
    claims: Sequence[Mapping[str, object]],
    decision_evidence_sha256: object,
    path: Path,
) -> str | None:
    rows = [
        {
            "claim_id": item["claim_id"],
            "source_id": item["source_id"],
            "source_location": item["source_location"],
            "owner_approval_sha256": item["owner_approval_sha256"],
            "owner_evidence_text_sha256": item["owner_evidence_text_sha256"],
            "owner_evidence_rationale_sha256": item[
                "owner_evidence_rationale_sha256"
            ],
            "decision_mapping_status": item["decision_mapping_status"],
            "disposition": item["disposition"],
            "target_class": item["target_class"],
            "target_id": item["target_id"],
        }
        for item in claims
        if item["source_id"] == "LINEAR-CANON-V3"
        and str(item["source_location"]).startswith("decision:")
    ]
    if not rows:
        return None
    decision_numbers = tuple(
        int(str(item["source_location"]).split(":", 1)[1]) for item in rows
    )
    if decision_numbers != tuple(range(1, 202)):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "Decision evidence fingerprint requires ordered Decisions 1 through 201",
            path,
        )
    return hashlib.sha256(
        stable_json(
            {
                "decision_evidence_sha256": decision_evidence_sha256,
                "decisions": rows,
            }
        )
    ).hexdigest()


def _tracked_json_object(raw: bytes, path: Path) -> dict[str, object]:
    try:
        value = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise CanonError(
            "TRACKED_EVIDENCE_INVALID",
            "tracked evidence must be valid UTF-8 JSON",
            path,
        ) from exc
    _validate_json_utf8_strings(value, path)
    if not isinstance(value, dict):
        raise CanonError(
            "TRACKED_EVIDENCE_INVALID",
            "tracked evidence root must be an object",
            path,
        )
    return value


def claim_coverage(
    disposition_path: Path,
    *,
    concept_prefix: str | None = None,
    target_class: str | None = None,
    repository_root: Path | None = None,
    catalog_path: Path | None = None,
) -> ClaimCoverageReport:
    """Load deterministic disposition evidence and filter only its claim view."""

    disposition_path = _normalized_absolute(disposition_path)
    if repository_root is None:
        try:
            repository_root = disposition_path.parents[3]
        except IndexError as exc:
            raise CanonError(
                "CLAIM_DISPOSITIONS_PATH_UNSAFE",
                "unable to derive repository root from canonical disposition path",
                disposition_path,
            ) from exc
    repository_root = _normalized_absolute(repository_root)
    if catalog_path is None:
        catalog_path = repository_root / "docs/canon/migration/source-catalog.json"
    catalog_path = _normalized_absolute(catalog_path)
    _require_claim_sources_verified(catalog_path, repository_root)
    catalog_bytes = _read_catalog_bytes(catalog_path, allow_missing=False)
    assert catalog_bytes is not None
    records = _parse_catalog_bytes(catalog_bytes, catalog_path)
    inventories = _source_inventories(repository_root, records)
    inventory_by_id = {item.record.source_id: item for item in inventories}
    coverage_decision_evidence_bytes: bytes | None = None
    coverage_decision_snapshot: DecisionEvidenceSnapshot | None = None
    coverage_decision_path: Path | None = None
    if "LINEAR-CANON-V3" in inventory_by_id:
        coverage_decision_path = (
            repository_root
            / ".codex/canon-migration/sources/linear-decision-evidence.json"
        )
        _require_ignored_decision_evidence(repository_root, coverage_decision_path)
        coverage_decision_evidence_bytes = _read_catalog_bytes(
            coverage_decision_path, allow_missing=False
        )
        assert coverage_decision_evidence_bytes is not None
        coverage_decision_snapshot = parse_decision_evidence_snapshot(
            coverage_decision_evidence_bytes,
            coverage_decision_path,
        )
    expected_keys = tuple(
        sorted(
            (inventory.record.source_id, section)
            for inventory in inventories
            for section in inventory.sections
        )
    )
    expected_key_set = set(expected_keys)
    raw = _read_catalog_bytes(disposition_path, allow_missing=False)
    assert raw is not None
    try:
        payload = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "claim dispositions must be valid UTF-8 JSON",
            disposition_path,
        ) from exc
    if (
        not isinstance(payload, dict)
        or set(payload) != TRACKED_DISPOSITION_FIELDS
        or payload["schema_version"] != 1
    ):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "claim dispositions use an unsupported closed shape",
            disposition_path,
        )
    catalog_sha = hashlib.sha256(catalog_bytes).hexdigest()
    if payload["catalog_sha256"] != catalog_sha:
        raise CanonError(
            "CLAIM_DISPOSITIONS_STALE",
            "claim dispositions are not bound to the current source catalog",
            disposition_path,
        )
    expected_evidence_sha = (
        hashlib.sha256(coverage_decision_evidence_bytes).hexdigest()
        if coverage_decision_evidence_bytes is not None
        else None
    )
    if payload["decision_evidence_sha256"] != expected_evidence_sha:
        raise CanonError(
            "CLAIM_DISPOSITIONS_STALE",
            "claim dispositions are not bound to current decision evidence",
            disposition_path,
        )
    expected_mapping_counts = {
        "independently_reviewed": sum(
            entry.mapping_status == "independently_reviewed"
            for entry in (
                coverage_decision_snapshot.evidence_entries
                if coverage_decision_snapshot
                else ()
            )
        ),
        "unreviewed": sum(
            entry.mapping_status == "unreviewed"
            for entry in (
                coverage_decision_snapshot.evidence_entries
                if coverage_decision_snapshot
                else ()
            )
        ),
    }
    if payload["decision_mapping_counts"] != expected_mapping_counts:
        raise CanonError(
            "CLAIM_DISPOSITIONS_STALE",
            "decision mapping counts differ from current evidence",
            disposition_path,
        )
    claims = payload["claims"]
    coverage = payload["coverage"]
    semantic_groups = payload["semantic_groups"]
    uncovered = payload["uncovered"]
    if not all(
        isinstance(items, list)
        for items in (claims, coverage, semantic_groups, uncovered)
    ):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "claim disposition record collections must be arrays",
            disposition_path,
        )
    normalized_claims = tuple(
        _validate_tracked_claim(item, disposition_path) for item in claims
    )
    derived_claim_ids: dict[tuple[str, str], list[str]] = {
        key: [] for key in expected_keys
    }
    for item in normalized_claims:
        source_id = str(item["source_id"])
        inventory = inventory_by_id.get(source_id)
        if inventory is None:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                f"tracked claim references unknown source_id: {source_id}",
                disposition_path,
            )
        section = _claim_section(
            inventory,
            str(item["source_location"]),
            disposition_path,
        )
        derived_claim_ids[(source_id, section)].append(str(item["claim_id"]))
    exact_claim_ids_by_section = {
        key: sorted(value) for key, value in derived_claim_ids.items()
    }
    if coverage_decision_snapshot is not None:
        decision_claims = {
            int(str(item["source_location"]).split(":", 1)[1]): item
            for item in normalized_claims
            if item["source_id"] == "LINEAR-CANON-V3"
            and str(item["source_location"]).startswith("decision:")
        }
        if tuple(sorted(decision_claims)) != tuple(range(1, 202)):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "tracked dispositions require exact Decision 1 through 201 claims",
                disposition_path,
            )
        for entry in coverage_decision_snapshot.evidence_entries:
            expected_hash = hashlib.sha256(
                entry.evidence_locator.encode("utf-8")
            ).hexdigest()
            tracked_decision = decision_claims[entry.decision_number]
            if (
                tracked_decision["owner_approval_sha256"] != expected_hash
                or tracked_decision["owner_evidence_text_sha256"]
                != hashlib.sha256(entry.owner_evidence_text.encode("utf-8")).hexdigest()
                or tracked_decision["owner_evidence_rationale_sha256"]
                != hashlib.sha256(
                    entry.owner_evidence_rationale.encode("utf-8")
                ).hexdigest()
                or tracked_decision["decision_mapping_status"] != entry.mapping_status
            ):
                raise CanonError(
                    "CLAIM_DISPOSITIONS_STALE",
                    f"Decision {entry.decision_number} evidence hashes or review state differ",
                    disposition_path,
                )
    claim_ids = tuple(str(item["claim_id"]) for item in normalized_claims)
    if claim_ids != tuple(sorted(claim_ids)) or len(claim_ids) != len(set(claim_ids)):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked claims must have unique sorted claim IDs",
            disposition_path,
        )
    coverage_keys: list[tuple[str, str]] = []
    for item in coverage:
        if not isinstance(item, dict) or set(item) != TRACKED_COVERAGE_FIELDS:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "coverage entry uses an unsupported closed shape",
                disposition_path,
            )
        source_id = _claim_string(item, "source_id", disposition_path)
        source_location = _claim_string(item, "source_location", disposition_path)
        _parse_source_location(source_location, disposition_path)
        disposition = item["disposition"]
        entry_claim_ids = item["claim_ids"]
        rationale_sha = item["rationale_sha256"]
        if disposition not in {"claims", "no_normative_claims"} or not isinstance(
            entry_claim_ids, list
        ):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "coverage disposition or claim IDs are invalid",
                disposition_path,
            )
        if any(
            not isinstance(claim_id, str) or claim_id not in set(claim_ids)
            for claim_id in entry_claim_ids
        ):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "coverage references an unknown claim ID",
                disposition_path,
            )
        if entry_claim_ids != sorted(set(entry_claim_ids)):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "coverage claim IDs must be unique and sorted",
                disposition_path,
            )
        if disposition == "claims":
            valid = bool(entry_claim_ids) and rationale_sha is None
        else:
            valid = not entry_claim_ids and _is_sha256(rationale_sha)
        if not valid:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "coverage rationale and claim IDs contradict its disposition",
                disposition_path,
            )
        if entry_claim_ids != exact_claim_ids_by_section.get(
            (source_id, source_location)
        ):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "coverage claim IDs do not match tracked claims for the source section",
                disposition_path,
            )
        coverage_keys.append((source_id, source_location))
    if coverage_keys != sorted(coverage_keys) or len(coverage_keys) != len(
        set(coverage_keys)
    ):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "coverage entries must be unique and sorted",
            disposition_path,
        )
    extra_keys = set(coverage_keys) - expected_key_set
    if extra_keys:
        first = sorted(extra_keys)[0]
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            f"coverage contains an unregistered source section: {first[0]}:{first[1]}",
            disposition_path,
        )
    grouped_claim_ids: list[str] = []
    previous_group_sha = ""
    for item in semantic_groups:
        if not isinstance(item, dict) or set(item) != {
            "claim_ids",
            "semantic_sha256",
        }:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "semantic group uses an unsupported closed shape",
                disposition_path,
            )
        semantic_sha = item["semantic_sha256"]
        group_ids = item["claim_ids"]
        if (
            not _is_sha256(semantic_sha)
            or not isinstance(group_ids, list)
            or group_ids != sorted(set(group_ids))
            or any(claim_id not in set(claim_ids) for claim_id in group_ids)
            or semantic_sha <= previous_group_sha
        ):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "semantic groups must be sorted and reference exact claim IDs",
                disposition_path,
            )
        previous_group_sha = semantic_sha
        grouped_claim_ids.extend(group_ids)
    if sorted(grouped_claim_ids) != sorted(claim_ids):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "semantic groups must retain every claim exactly once",
            disposition_path,
        )
    if target_class is not None:
        try:
            ClaimTargetClass(target_class)
        except ValueError as exc:
            raise CanonError(
                "CLAIM_FILTER_INVALID",
                "target-class filter is not a closed target class",
                disposition_path,
            ) from exc
    filtered = tuple(
        dict(item)
        for item in normalized_claims
        if isinstance(item, dict)
        and (
            concept_prefix is None
            or str(item.get("concept", "")).startswith(concept_prefix)
        )
        and (target_class is None or item.get("target_class") == target_class)
    )
    normalized_uncovered: list[dict[str, str]] = []
    for item in uncovered:
        if not isinstance(item, dict) or set(item) != {"source_id", "source_location"}:
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                "uncovered entry is invalid",
                disposition_path,
            )
        normalized_uncovered.append(
            {
                "source_id": _claim_string(item, "source_id", disposition_path),
                "source_location": _claim_string(
                    item, "source_location", disposition_path
                ),
            }
        )
    for count_field in ("source_count", "section_count", "linear_decision_count"):
        if (
            not isinstance(payload[count_field], int)
            or isinstance(payload[count_field], bool)
            or payload[count_field] < 0
        ):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                f"{count_field} must be a non-negative integer",
                disposition_path,
            )
    if payload["section_count"] != len(coverage):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "section_count must equal the exact coverage inventory",
            disposition_path,
        )
    missing_keys = expected_key_set - set(coverage_keys)
    derived_uncovered = {
        (item["source_id"], item["source_location"]) for item in normalized_uncovered
    }
    derived_uncovered.update(missing_keys)
    actual_source_count = len(inventories)
    actual_section_count = len(expected_keys)
    actual_decision_count = sum(
        source_id == "LINEAR-CANON-V3" and location.startswith("decision:")
        for source_id, location in expected_keys
    )
    counts_match = (
        payload["source_count"] == actual_source_count
        and payload["section_count"] == actual_section_count
        and payload["linear_decision_count"] == actual_decision_count
    )
    _require_claim_sources_verified(catalog_path, repository_root)
    final_catalog_bytes = _read_catalog_bytes(catalog_path, allow_missing=False)
    if final_catalog_bytes != catalog_bytes:
        raise CanonError(
            "CLAIM_DISPOSITIONS_STALE",
            "source catalog changed during coverage validation",
            catalog_path,
        )
    if coverage_decision_path is not None:
        final_evidence = _read_catalog_bytes(
            coverage_decision_path, allow_missing=False
        )
        if final_evidence != coverage_decision_evidence_bytes:
            raise CanonError(
                "CLAIM_DECISION_EVIDENCE_CHANGED",
                "decision evidence changed during coverage validation",
                coverage_decision_path,
            )
    return ClaimCoverageReport(
        complete=not derived_uncovered and counts_match,
        claims=tuple(sorted(filtered, key=lambda item: str(item.get("claim_id", "")))),
        uncovered=tuple(
            sorted(
                (
                    {"source_id": source_id, "source_location": location}
                    for source_id, location in derived_uncovered
                ),
                key=lambda item: (item["source_id"], item["source_location"]),
            )
        ),
        source_count=actual_source_count,
        section_count=actual_section_count,
        linear_decision_count=actual_decision_count,
    )


def _validate_tracked_claim(value: object, path: Path) -> dict[str, object]:
    if not isinstance(value, dict) or set(value) != TRACKED_CLAIM_FIELDS:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked claim uses an unsupported closed shape",
            path,
        )
    for field_name in ("claim_id", "concept", "source_id", "source_location"):
        _claim_string(value, field_name, path)
    if CLAIM_ID_PATTERN.fullmatch(str(value["claim_id"])) is None:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked claim_id is invalid",
            path,
        )
    if CONCEPT_PATTERN.fullmatch(str(value["concept"])) is None:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked concept key is invalid",
            path,
        )
    location_kind, location_number = _parse_source_location(
        str(value["source_location"]), path
    )
    try:
        disposition = ClaimDisposition(str(value["disposition"]))
        target_class = ClaimTargetClass(str(value["target_class"]))
    except ValueError as exc:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked claim uses an unsupported disposition or target class",
            path,
        ) from exc
    target_id = value["target_id"]
    if target_id is not None and (
        not isinstance(target_id, str) or TARGET_ID_PATTERN.fullmatch(target_id) is None
    ):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked target ID is invalid",
            path,
        )
    _validate_claim_destination(disposition, target_class, target_id, path)
    if not isinstance(value["authority_claim"], bool):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked claim authority_claim must be boolean",
            path,
        )
    owner_approval_sha = value["owner_approval_sha256"]
    owner_approval_valid = _is_sha256(owner_approval_sha)
    if owner_approval_sha is not None and not owner_approval_valid:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked owner approval checksum is invalid",
            path,
        )
    for evidence_hash_field in (
        "owner_evidence_text_sha256",
        "owner_evidence_rationale_sha256",
    ):
        evidence_hash = value[evidence_hash_field]
        if evidence_hash is not None and not _is_sha256(evidence_hash):
            raise CanonError(
                "CLAIM_DISPOSITIONS_INVALID",
                f"tracked {evidence_hash_field} is invalid",
                path,
            )
    mapping_status = value["decision_mapping_status"]
    if mapping_status not in {None, "independently_reviewed", "unreviewed"}:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked decision_mapping_status is invalid",
            path,
        )
    has_decision_evidence = (
        mapping_status is not None
        and _is_sha256(value["owner_evidence_text_sha256"])
        and _is_sha256(value["owner_evidence_rationale_sha256"])
    )
    if location_kind != "decision" and has_decision_evidence:
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked decision evidence fields contradict source_location",
            path,
        )
    _validate_decision_claim_law(
        source_id=str(value["source_id"]),
        location_kind=location_kind,
        location_number=location_number,
        disposition=disposition,
        target_class=target_class,
        target_id=target_id,
        owner_approval_valid=owner_approval_valid,
        owner_evidence_valid=has_decision_evidence,
        path=path,
        provenance_code="CLAIM_DISPOSITIONS_INVALID",
        authority_code="CLAIM_DISPOSITIONS_INVALID",
    )
    if not _is_sha256(value["rationale_sha256"]):
        raise CanonError(
            "CLAIM_DISPOSITIONS_INVALID",
            "tracked claim rationale checksum is invalid",
            path,
        )
    return dict(value)


def _is_sha256(value: object) -> bool:
    return isinstance(value, str) and re.fullmatch(r"[0-9a-f]{64}", value) is not None
