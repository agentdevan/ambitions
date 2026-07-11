"""Lossless, offline provenance registration for canon migration sources."""

from __future__ import annotations

import ctypes
import errno
import hashlib
import json
import os
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
    _open_parent_nofollow,
    _read_descriptor,
    _rename_noreplace,
)
from tools.ambitions_canon.model import CanonError, Finding, GapSeverity
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
