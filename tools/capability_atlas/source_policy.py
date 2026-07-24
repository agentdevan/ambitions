"""Repository source enumeration policy for capability discovery."""

from __future__ import annotations

import hashlib
from pathlib import Path
from typing import Iterable

from tools.capability_atlas.model import (
    CapabilityDiscoveryError,
    SourceFamily,
    SourceFile,
    load_json_object,
)


SOURCE_REGISTER_PATH = Path("docs/capabilities/discovery-source-register.json")
TEXT_SUFFIXES = frozenset(
    {
        ".json",
        ".md",
        ".py",
        ".sh",
        ".swift",
        ".toml",
        ".txt",
        ".yaml",
        ".yml",
    }
)
EXCLUDED_PARTS = frozenset(
    {
        ".build",
        ".git",
        ".idea",
        ".swiftpm",
        ".venv",
        ".vscode",
        "DerivedData",
        "__pycache__",
        "build",
        "node_modules",
        "venv",
    }
)


def load_source_families(repository_root: Path) -> tuple[SourceFamily, ...]:
    """Load and validate the configured source families."""

    register_path = repository_root / SOURCE_REGISTER_PATH
    payload = load_json_object(register_path)
    families_payload = payload.get("source_families")
    if not isinstance(families_payload, list):
        raise CapabilityDiscoveryError(
            f"source_families must be a list: {register_path}"
        )
    families = tuple(SourceFamily.from_mapping(item) for item in families_payload)
    identifiers = [item.family_id for item in families]
    if len(identifiers) != len(set(identifiers)):
        raise CapabilityDiscoveryError("duplicate source family id")
    return tuple(sorted(families, key=lambda item: item.family_id))


def is_excluded_path(relative_path: Path) -> bool:
    """Return whether repository policy excludes a path from discovery."""

    return any(part in EXCLUDED_PARTS for part in relative_path.parts)


def is_text_candidate(relative_path: Path) -> bool:
    """Return whether the path is eligible for deterministic UTF-8 reading."""

    return relative_path.suffix.casefold() in TEXT_SUFFIXES


def enumerate_family_paths(
    repository_root: Path,
    family: SourceFamily,
) -> tuple[Path, ...]:
    """Expand one source family into unique, deterministic repository paths."""

    matched: set[Path] = set()
    for pattern in family.path_patterns:
        try:
            matches: Iterable[Path] = repository_root.glob(pattern)
        except (OSError, ValueError) as exc:
            raise CapabilityDiscoveryError(
                f"invalid source pattern {pattern!r} for {family.family_id}: {exc}"
            ) from exc
        for absolute_path in matches:
            if not absolute_path.is_file():
                continue
            relative_path = absolute_path.relative_to(repository_root)
            if is_excluded_path(relative_path):
                continue
            matched.add(relative_path)
    return tuple(sorted(matched, key=lambda item: item.as_posix()))


def read_source_file(repository_root: Path, family: SourceFamily, path: Path) -> SourceFile:
    """Read metadata for an eligible UTF-8 source file."""

    absolute_path = repository_root / path
    try:
        raw = absolute_path.read_bytes()
        text = raw.decode("utf-8")
    except (OSError, UnicodeDecodeError) as exc:
        raise CapabilityDiscoveryError(f"cannot read text source {path}: {exc}") from exc
    return SourceFile(
        family_id=family.family_id,
        authority_class=family.authority_class,
        path=path.as_posix(),
        sha256=hashlib.sha256(raw).hexdigest(),
        byte_count=len(raw),
        line_count=len(text.splitlines()),
    )


def read_text(repository_root: Path, relative_path: Path) -> str:
    """Read one UTF-8 repository source."""

    try:
        return (repository_root / relative_path).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as exc:
        raise CapabilityDiscoveryError(
            f"cannot read text source {relative_path}: {exc}"
        ) from exc
