"""Manifest and canonical document loading for the Ambitions canon compiler."""

from __future__ import annotations

import errno
import os
import re
import stat
import tomllib
from dataclasses import replace
from pathlib import Path, PurePosixPath

from tools.ambitions_canon.model import (
    AuthorityState,
    CanonDocument,
    CanonError,
    CanonManifest,
    DocumentKind,
    ManifestEntry,
)
from tools.ambitions_canon.parser import parse_canon_document


MANIFEST_PATH = Path("docs/canon/MANIFEST.toml")
MANIFEST_FIELDS = frozenset(
    {
        "schema_version",
        "canon_revision",
        "authority_state",
        "compiler_version",
        "normative_files",
        "generated_files",
    }
)
WINDOWS_DRIVE = re.compile(r"^[A-Za-z]:")
DIRECTORY_OPEN_FLAGS = (
    os.O_RDONLY
    | os.O_DIRECTORY
    | os.O_NOFOLLOW
    | getattr(os, "O_CLOEXEC", 0)
)
FILE_OPEN_FLAGS = os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0)
READ_CHUNK_SIZE = 64 * 1024


def load_manifest(root: Path) -> CanonManifest:
    """Load and validate the repository's closed canon manifest contract."""

    source_path = MANIFEST_PATH
    repository_root = _resolved_repository_root(root, source_path)
    text = _read_confined_utf8(
        repository_root,
        MANIFEST_PATH,
        source_path,
        missing_code="CANON_MANIFEST_READ",
        read_code="CANON_MANIFEST_READ",
        missing_message="unable to read canon manifest",
        read_message="unable to read canon manifest",
    )

    try:
        data = tomllib.loads(text)
    except tomllib.TOMLDecodeError as exc:
        raise CanonError(
            "CANON_MANIFEST_PARSE",
            "invalid TOML",
            source_path,
        ) from exc

    if not isinstance(data, dict):
        raise CanonError(
            "CANON_MANIFEST_FIELD",
            "manifest must be a table",
            source_path,
        )
    unknown = sorted(set(data) - MANIFEST_FIELDS)
    if unknown:
        raise CanonError(
            "CANON_MANIFEST_FIELD",
            f"unknown field: {unknown[0]}",
            source_path,
        )
    missing = sorted(MANIFEST_FIELDS - set(data))
    if missing:
        raise CanonError(
            "CANON_MANIFEST_FIELD",
            f"missing required field: {missing[0]}",
            source_path,
        )

    schema_version = _integer(data, "schema_version", source_path)
    if schema_version != 1:
        raise CanonError(
            "CANON_MANIFEST_SCHEMA_VERSION",
            f"unsupported schema version: {schema_version}",
            source_path,
        )
    canon_revision = _integer(data, "canon_revision", source_path)
    if canon_revision < 0:
        raise CanonError(
            "CANON_MANIFEST_FIELD",
            "canon_revision must be non-negative",
            source_path,
        )
    compiler_version = _string(data, "compiler_version", source_path)
    authority_state_text = _string(data, "authority_state", source_path)
    try:
        authority_state = AuthorityState(authority_state_text)
    except ValueError as exc:
        raise CanonError(
            "CANON_MANIFEST_AUTHORITY_STATE",
            f"unknown authority state: {authority_state_text}",
            source_path,
        ) from exc

    normative_paths = _path_list(data, "normative_files", source_path)
    generated_paths = _path_list(data, "generated_files", source_path)
    _reject_duplicates(normative_paths, "normative_files", source_path)
    _reject_duplicates(generated_paths, "generated_files", source_path)

    for path in normative_paths:
        _validate_role(path, generated=False, source_path=source_path)
    for path in generated_paths:
        _validate_role(path, generated=True, source_path=source_path)
    overlap = sorted(set(normative_paths) & set(generated_paths), key=str)
    if overlap:
        raise CanonError(
            "CANON_MANIFEST_PATH_ROLE",
            f"path cannot be normative and generated: {overlap[0].as_posix()}",
            source_path,
        )

    return CanonManifest(
        schema_version=schema_version,
        canon_revision=canon_revision,
        authority_state=authority_state,
        compiler_version=compiler_version,
        normative_files=tuple(ManifestEntry(path) for path in normative_paths),
        generated_files=tuple(generated_paths),
        source_path=source_path,
        repository_root=repository_root,
        source_bytes=text.encode("utf-8"),
    )


def load_documents(
    root: Path,
    manifest: CanonManifest,
) -> tuple[CanonDocument, ...]:
    """Read only confined normative files and parse them deterministically."""

    repository_root = _resolved_repository_root(root, manifest.source_path)
    documents: list[CanonDocument] = []
    for entry in manifest.normative_files:
        path = _validate_relative_path(entry.path.as_posix(), manifest.source_path)
        _validate_role(path, generated=False, source_path=manifest.source_path)
        document_source_path = Path("docs/canon") / path
        text = _read_confined_utf8(
            repository_root,
            document_source_path,
            document_source_path,
            missing_code="CANON_MANIFEST_DOCUMENT_MISSING",
            read_code="CANON_MANIFEST_DOCUMENT_READ",
            missing_message="normative document is missing or unreadable",
            read_message="unable to read normative document",
        )
        documents.append(
            replace(
                parse_canon_document(document_source_path, text),
                source_bytes=text.encode("utf-8"),
            )
        )

    ordered = tuple(
        sorted(documents, key=lambda item: (item.spec_id, item.source_path.as_posix()))
    )
    _require_active_constitution(manifest, ordered)
    return ordered


def _resolved_repository_root(root: Path, source_path: Path) -> Path:
    try:
        resolved_root = root.resolve(strict=True)
    except OSError as exc:
        raise CanonError(
            "CANON_MANIFEST_READ",
            "repository root is missing or unreadable",
            source_path,
        ) from exc
    if not resolved_root.is_dir():
        raise CanonError(
            "CANON_MANIFEST_READ",
            "repository root is not a directory",
            source_path,
        )
    return resolved_root


def _read_confined_utf8(
    repository_root: Path,
    relative_path: Path,
    source_path: Path,
    *,
    missing_code: str,
    read_code: str,
    missing_message: str,
    read_message: str,
) -> str:
    """Read through no-follow descriptors rooted at the trusted repository."""

    descriptors: list[int] = []
    try:
        root_descriptor = os.open(repository_root, DIRECTORY_OPEN_FLAGS)
        descriptors.append(root_descriptor)
        current_descriptor = root_descriptor
        for component in relative_path.parts[:-1]:
            current_descriptor = os.open(
                component,
                DIRECTORY_OPEN_FLAGS,
                dir_fd=current_descriptor,
            )
            descriptors.append(current_descriptor)

        file_descriptor = os.open(
            relative_path.parts[-1],
            FILE_OPEN_FLAGS,
            dir_fd=current_descriptor,
        )
        descriptors.append(file_descriptor)
        if not stat.S_ISREG(os.fstat(file_descriptor).st_mode):
            raise CanonError(read_code, read_message, source_path)

        chunks: list[bytes] = []
        while chunk := os.read(file_descriptor, READ_CHUNK_SIZE):
            chunks.append(chunk)
        try:
            return b"".join(chunks).decode("utf-8")
        except UnicodeDecodeError as exc:
            raise CanonError(read_code, read_message, source_path) from exc
    except CanonError:
        raise
    except OSError as exc:
        if exc.errno in (errno.ELOOP, errno.ENOTDIR):
            raise CanonError(
                "CANON_MANIFEST_PATH_ESCAPE",
                "canonical path contains a symlink or invalid directory",
                source_path,
            ) from exc
        if exc.errno == errno.ENOENT:
            raise CanonError(missing_code, missing_message, source_path) from exc
        raise CanonError(read_code, read_message, source_path) from exc
    finally:
        for descriptor in reversed(descriptors):
            try:
                os.close(descriptor)
            except OSError:
                pass


def _integer(data: dict[str, object], key: str, path: Path) -> int:
    value = data[key]
    if not isinstance(value, int) or isinstance(value, bool):
        raise CanonError(
            "CANON_MANIFEST_FIELD",
            f"{key} must be an integer",
            path,
        )
    return value


def _string(data: dict[str, object], key: str, path: Path) -> str:
    value = data[key]
    if not isinstance(value, str) or not value:
        raise CanonError(
            "CANON_MANIFEST_FIELD",
            f"{key} must be a non-empty string",
            path,
        )
    return value


def _path_list(
    data: dict[str, object],
    key: str,
    source_path: Path,
) -> tuple[Path, ...]:
    value = data[key]
    if not isinstance(value, list):
        raise CanonError(
            "CANON_MANIFEST_FIELD",
            f"{key} must be an array",
            source_path,
        )
    paths: list[Path] = []
    for item in value:
        if not isinstance(item, str):
            raise CanonError(
                "CANON_MANIFEST_FIELD",
                f"{key} must contain only strings",
                source_path,
            )
        paths.append(_validate_relative_path(item, source_path))
    return tuple(paths)


def _validate_relative_path(raw: str, source_path: Path) -> Path:
    if (
        not raw
        or "\\" in raw
        or WINDOWS_DRIVE.match(raw)
        or PurePosixPath(raw).is_absolute()
    ):
        raise CanonError(
            "CANON_MANIFEST_PATH_INVALID",
            f"path must be relative to docs/canon: {raw}",
            source_path,
        )
    pure = PurePosixPath(raw)
    if str(pure) != raw or any(part in ("", ".", "..") for part in pure.parts):
        raise CanonError(
            "CANON_MANIFEST_PATH_INVALID",
            f"path is not canonical: {raw}",
            source_path,
        )
    return Path(*pure.parts)


def _reject_duplicates(paths: tuple[Path, ...], role: str, source_path: Path) -> None:
    seen: set[Path] = set()
    for path in paths:
        if path in seen:
            raise CanonError(
                "CANON_MANIFEST_PATH_DUPLICATE",
                f"duplicate {role} path: {path.as_posix()}",
                source_path,
            )
        seen.add(path)


def _validate_role(path: Path, *, generated: bool, source_path: Path) -> None:
    is_generated = bool(path.parts) and path.parts[0] == "generated"
    if generated != is_generated or (generated and len(path.parts) == 1):
        role = "generated" if generated else "normative"
        raise CanonError(
            "CANON_MANIFEST_PATH_ROLE",
            f"invalid {role} path: {path.as_posix()}",
            source_path,
        )
    if not generated and path.suffix.lower() != ".md":
        raise CanonError(
            "CANON_MANIFEST_PATH_ROLE",
            f"normative document must be Markdown: {path.as_posix()}",
            source_path,
        )


def _require_active_constitution(
    manifest: CanonManifest,
    documents: tuple[CanonDocument, ...],
) -> None:
    if manifest.authority_state is not AuthorityState.ACTIVE:
        return
    count = sum(
        document.kind is DocumentKind.CONSTITUTION for document in documents
    )
    if count != 1:
        raise CanonError(
            "CANON_MANIFEST_CONSTITUTION_REQUIRED",
            f"active authority requires exactly one Constitution; found {count}",
            manifest.source_path,
        )
