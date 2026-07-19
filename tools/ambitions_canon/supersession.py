"""Closed durable supersession-ledger parsing."""

from __future__ import annotations

import hashlib
import json
import os
import re
import stat
import sys
import tomllib
from dataclasses import dataclass
from pathlib import Path

from tools.ambitions_canon.model import CanonError, CanonManifest, SupersessionEntry


LEDGER_PATH = Path("docs/canon/decisions/SUPERSESSION_LEDGER.toml")
_ENTRY_REQUIRED = frozenset(
    {
        "conflict_id",
        "old_ids",
        "decision_date",
        "owner",
        "decision_source",
        "resolution",
        "decision_base_commit",
        "integration_evidence_sha256",
        "superseded_artifacts",
    }
)
_ENTRY_ALLOWED = _ENTRY_REQUIRED | {"resulting_id"}
_DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
_COMMIT = re.compile(r"^[0-9a-f]{40}$")
_SHA256 = re.compile(r"^[0-9a-f]{64}$")
_RESOLUTIONS = frozenset({"keep_a", "keep_b", "compose", "reject_both"})


@dataclass(frozen=True, slots=True)
class SupersessionLedger:
    schema_version: int
    entries: tuple[SupersessionEntry, ...]
    source_path: Path
    source_bytes: bytes

    @property
    def retired_ids(self) -> frozenset[str]:
        return frozenset(
            identifier for entry in self.entries for identifier in entry.old_ids
        )


def load_supersession_ledger(path: Path) -> SupersessionLedger:
    """Load the exact version-1 ledger or fail with a stable public code."""

    path = Path(path)
    try:
        descriptor = _open_file_nofollow(path)
        try:
            metadata = os.fstat(descriptor)
            if not stat.S_ISREG(metadata.st_mode):
                raise OSError("ledger is not a regular file")
            chunks: list[bytes] = []
            while True:
                chunk = os.read(descriptor, 64 * 1024)
                if not chunk:
                    break
                chunks.append(chunk)
            source_bytes = b"".join(chunks)
        finally:
            os.close(descriptor)
        text = source_bytes.decode("utf-8")
    except (OSError, UnicodeError) as exc:
        raise CanonError(
            "CANON_SUPERSESSION_LEDGER_READ",
            "unable to read UTF-8 supersession ledger",
            path,
        ) from exc
    try:
        data = tomllib.loads(text)
    except tomllib.TOMLDecodeError as exc:
        raise _schema_error(path, "invalid supersession ledger TOML") from exc
    if not isinstance(data, dict) or set(data) != {"schema_version", "entries"}:
        raise _schema_error(path, "ledger fields must be schema_version and entries")
    schema_version = data["schema_version"]
    raw_entries = data["entries"]
    if (
        isinstance(schema_version, bool)
        or schema_version != 1
        or not isinstance(raw_entries, list)
    ):
        raise _schema_error(path, "ledger schema_version must be 1 and entries a list")

    entries: list[SupersessionEntry] = []
    seen_conflicts: set[str] = set()
    seen_old_ids: set[str] = set()
    for raw in raw_entries:
        if (
            not isinstance(raw, dict)
            or not _ENTRY_REQUIRED <= set(raw)
            or not set(raw) <= _ENTRY_ALLOWED
        ):
            raise _schema_error(path, "ledger entry fields do not match version 1")
        conflict_id = _string(raw["conflict_id"], path, "conflict_id")
        old_ids = _string_list(raw["old_ids"], path, "old_ids", allow_empty=False)
        resulting_id = (
            _string(raw["resulting_id"], path, "resulting_id")
            if "resulting_id" in raw
            else None
        )
        decision_date = _string(raw["decision_date"], path, "decision_date")
        owner = _string(raw["owner"], path, "owner")
        decision_source = _string(raw["decision_source"], path, "decision_source")
        resolution = _string(raw["resolution"], path, "resolution")
        decision_base_commit = _string(
            raw["decision_base_commit"], path, "decision_base_commit"
        )
        integration_evidence_sha256 = _string(
            raw["integration_evidence_sha256"],
            path,
            "integration_evidence_sha256",
        )
        artifacts = _string_list(
            raw["superseded_artifacts"],
            path,
            "superseded_artifacts",
            allow_empty=True,
        )
        if (
            conflict_id in seen_conflicts
            or seen_old_ids.intersection(old_ids)
            or resulting_id in old_ids
            or _DATE.fullmatch(decision_date) is None
            or resolution not in _RESOLUTIONS
            or _COMMIT.fullmatch(decision_base_commit) is None
            or _SHA256.fullmatch(integration_evidence_sha256) is None
            or integration_evidence_sha256
            != integration_evidence_digest(
                conflict_id=conflict_id,
                old_ids=old_ids,
                resulting_id=resulting_id,
                decision_date=decision_date,
                owner=owner,
                decision_source=decision_source,
                resolution=resolution,
                decision_base_commit=decision_base_commit,
                superseded_artifacts=artifacts,
            )
        ):
            raise _schema_error(path, "ledger entry identity or provenance is invalid")
        seen_conflicts.add(conflict_id)
        seen_old_ids.update(old_ids)
        entries.append(
            SupersessionEntry(
                conflict_id=conflict_id,
                old_ids=old_ids,
                resulting_id=resulting_id,
                decision_date=decision_date,
                owner=owner,
                decision_source=decision_source,
                resolution=resolution,
                decision_base_commit=decision_base_commit,
                integration_evidence_sha256=integration_evidence_sha256,
                superseded_artifacts=artifacts,
            )
        )
    ordered = tuple(sorted(entries, key=lambda entry: entry.conflict_id))
    if tuple(entries) != ordered:
        raise _schema_error(path, "ledger entries must be sorted by conflict_id")
    return SupersessionLedger(1, ordered, path, source_bytes)


def load_manifest_supersession_ledger(
    manifest: CanonManifest,
) -> SupersessionLedger | None:
    """Load the mandatory fixed ledger for repository-backed manifests."""

    if manifest.repository_root is None:
        return None
    path = manifest.repository_root / LEDGER_PATH
    try:
        return load_supersession_ledger(path)
    except CanonError as exc:
        if (
            exc.code == "CANON_SUPERSESSION_LEDGER_READ"
            and not os.path.lexists(path)
        ):
            raise CanonError(
                "CANON_SUPERSESSION_LEDGER_MISSING",
                "repository-backed canon requires the fixed supersession ledger",
                path,
            ) from exc
        raise


def _string(value: object, path: Path, field: str) -> str:
    if not isinstance(value, str) or not value or value != value.strip():
        raise _schema_error(path, f"{field} must be a non-empty trimmed string")
    return value


def _string_list(
    value: object,
    path: Path,
    field: str,
    *,
    allow_empty: bool,
) -> tuple[str, ...]:
    if not isinstance(value, list) or (not value and not allow_empty):
        raise _schema_error(path, f"{field} must be a string list")
    values = tuple(_string(item, path, field) for item in value)
    if values != tuple(sorted(set(values))):
        raise _schema_error(path, f"{field} must be unique and sorted")
    return values


def _schema_error(path: Path, message: str) -> CanonError:
    return CanonError("CANON_SUPERSESSION_LEDGER_SCHEMA", message, path)


def integration_evidence_digest(
    *,
    conflict_id: str,
    old_ids: tuple[str, ...],
    resulting_id: str | None,
    decision_date: str,
    owner: str,
    decision_source: str,
    resolution: str,
    decision_base_commit: str,
    superseded_artifacts: tuple[str, ...],
) -> str:
    payload = {
        "conflict_id": conflict_id,
        "decision_base_commit": decision_base_commit,
        "decision_date": decision_date,
        "decision_source": decision_source,
        "old_ids": list(old_ids),
        "owner": owner,
        "resolution": resolution,
        "resulting_id": resulting_id,
        "superseded_artifacts": list(superseded_artifacts),
    }
    return hashlib.sha256(
        json.dumps(
            payload,
            ensure_ascii=False,
            separators=(",", ":"),
            sort_keys=True,
        ).encode("utf-8")
    ).hexdigest()


def _open_file_nofollow(path: Path) -> int:
    absolute = Path(os.path.abspath(path))
    parts = absolute.parts
    if (
        sys.platform == "darwin"
        and len(parts) > 1
        and parts[1] in {"etc", "tmp", "var"}
    ):
        absolute = Path("/private").joinpath(*parts[1:])
        parts = absolute.parts
    directory_flags = (
        os.O_RDONLY
        | os.O_DIRECTORY
        | os.O_NOFOLLOW
        | getattr(os, "O_CLOEXEC", 0)
    )
    current = os.open("/", directory_flags)
    try:
        for component in parts[1:-1]:
            next_descriptor = os.open(
                component,
                directory_flags,
                dir_fd=current,
            )
            os.close(current)
            current = next_descriptor
        return os.open(
            parts[-1],
            os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0),
            dir_fd=current,
        )
    finally:
        os.close(current)
