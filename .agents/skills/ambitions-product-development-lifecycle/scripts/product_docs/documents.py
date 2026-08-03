"""Parse and persist the lightweight product-development documents."""

from __future__ import annotations

import os
from pathlib import Path
import tempfile
import tomllib

from .errors import Diagnostic, ProductDocsError
from .markdown import parse_sections, render_sections
from .models import DocumentStatus, DocumentType, ProductDocument


_METADATA_KEYS = frozenset(("initiative", "document_type", "status", "upstream"))
_MEMORY_PATH = Path("<memory>")


def _split_frontmatter(contents: str) -> tuple[str, str]:
    if not contents.startswith("+++"):
        raise ProductDocsError(Diagnostic("missing-frontmatter", "Document must begin with TOML frontmatter"))
    lines = contents.splitlines(keepends=True)
    if not lines or lines[0].rstrip("\r\n") != "+++":
        raise ProductDocsError(Diagnostic("missing-frontmatter", "Document must begin with a +++ line"))
    for index, line in enumerate(lines[1:], start=1):
        if line.rstrip("\r\n") == "+++":
            return "".join(lines[1:index]), "".join(lines[index + 1:])
    raise ProductDocsError(Diagnostic("unterminated-frontmatter", "TOML frontmatter is not terminated"))


def _contents_and_path(source: Path | str) -> tuple[str, Path]:
    if isinstance(source, Path):
        return source.read_text(encoding="utf-8"), source
    if source.startswith("+++") or "\n" in source or "\r" in source:
        return source, _MEMORY_PATH
    candidate = Path(source)
    if candidate.exists():
        return candidate.read_text(encoding="utf-8"), candidate
    return source, _MEMORY_PATH


def _frontmatter(frontmatter: str) -> tuple[str, DocumentType, DocumentStatus, str]:
    try:
        metadata = tomllib.loads(frontmatter)
    except tomllib.TOMLDecodeError as error:
        raise ProductDocsError(Diagnostic("invalid-frontmatter", f"Malformed TOML frontmatter: {error}")) from error
    if set(metadata) != _METADATA_KEYS or not all(isinstance(value, str) for value in metadata.values()):
        raise ProductDocsError(
            Diagnostic("invalid-frontmatter", "Frontmatter must contain only initiative, document_type, status, and upstream strings")
        )
    try:
        document_type = DocumentType(metadata["document_type"])
        status = DocumentStatus(metadata["status"])
    except ValueError as error:
        raise ProductDocsError(Diagnostic("invalid-frontmatter", str(error))) from error
    return metadata["initiative"], document_type, status, metadata["upstream"]


def parse_document(source: Path | str, *, repository_root: Path | None = None) -> ProductDocument:
    """Parse the four-field frontmatter and lossless level-two sections."""
    del repository_root
    contents, source_path = _contents_and_path(source)
    frontmatter, body = _split_frontmatter(contents)
    initiative, document_type, status, upstream = _frontmatter(frontmatter)
    return ProductDocument(
        initiative=initiative,
        document_type=document_type,
        status=status,
        upstream=upstream,
        sections=parse_sections(body),
        source_path=source_path,
    )


def render_document(document: ProductDocument) -> str:
    frontmatter = "\n".join(
        (
            "initiative = " + repr(document.initiative),
            "document_type = " + repr(document.document_type.value),
            "status = " + repr(document.status.value),
            "upstream = " + repr(document.upstream),
        )
    )
    return f"+++\n{frontmatter}\n+++\n{render_sections(document.sections)}"


def append_history_event(document: ProductDocument, event: str) -> ProductDocument:
    """The simplified lifecycle has no review-history artifact."""
    del document, event
    raise ProductDocsError(Diagnostic("unsupported-operation", "Review history is not part of product documents"))


def write_document_atomic(target: Path, document: ProductDocument | str, *, repository_root: Path | None = None) -> None:
    contents = render_document(document) if isinstance(document, ProductDocument) else document
    target = Path(target)
    target.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(prefix=f".{target.name}.", suffix=".tmp", dir=target.parent)
    temporary_path = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="") as handle:
            handle.write(contents)
            handle.flush()
            os.fsync(handle.fileno())
        parse_document(temporary_path, repository_root=repository_root)
        temporary_path.replace(target)
    except Exception:
        temporary_path.unlink(missing_ok=True)
        raise
