"""Lifecycle document parsing, rendering, history append, and atomic persistence."""

from __future__ import annotations

from dataclasses import replace
import os
from pathlib import Path
import tempfile

from .constants import TEMPLATE_PROFILES
from .errors import Diagnostic, ProductDocsError
from .markdown import HEADING, parse_sections, render_sections
from .models import LifecycleDocument, Section
from .toml_codec import parse_frontmatter, render_frontmatter


def _split_frontmatter(contents: str) -> tuple[str, str]:
    if not contents.startswith("+++"):
        raise ProductDocsError(Diagnostic("missing-frontmatter", "Document must begin with TOML frontmatter"))
    first_line_end = contents.find("\n")
    if first_line_end == -1 or contents[:first_line_end].rstrip("\r") != "+++":
        raise ProductDocsError(Diagnostic("missing-frontmatter", "Document must begin with a +++ line"))
    closing = contents.find("\n+++", first_line_end)
    if closing == -1:
        raise ProductDocsError(Diagnostic("unterminated-frontmatter", "TOML frontmatter is not terminated"))
    closing_line_end = contents.find("\n", closing + 1)
    if closing_line_end == -1:
        raise ProductDocsError(Diagnostic("unterminated-frontmatter", "TOML frontmatter is not followed by a document body"))
    if contents[closing + 1:closing_line_end].rstrip("\r") != "+++":
        raise ProductDocsError(Diagnostic("unterminated-frontmatter", "TOML frontmatter closing delimiter is invalid"))
    return contents[first_line_end + 1:closing], contents[closing_line_end + 1:]


def _contents_and_path(source: Path | str) -> tuple[str, Path | None]:
    if isinstance(source, Path):
        return source.read_text(encoding="utf-8"), source
    if source.startswith("+++") or "\n" in source or "\r" in source:
        return source, None
    candidate = Path(source)
    if candidate.exists():
        return candidate.read_text(encoding="utf-8"), candidate
    return source, None


def parse_document(source: Path | str, *, repository_root: Path | None = None) -> LifecycleDocument:
    contents, source_path = _contents_and_path(source)
    root = (repository_root or Path.cwd()).resolve()
    frontmatter, body = _split_frontmatter(contents)
    metadata = parse_frontmatter(frontmatter, root)
    sections = parse_sections(body)
    expected_headings = TEMPLATE_PROFILES[metadata.document_type.value]
    actual_headings = tuple(section.heading for section in sections)
    if actual_headings != expected_headings:
        raise ProductDocsError(Diagnostic("section-order-mismatch", "Document headings must match its immutable template profile"))
    first_heading = HEADING.search(body)
    assert first_heading is not None  # parse_sections already established this invariant.
    return LifecycleDocument(
        metadata=metadata,
        sections=sections,
        source_path=source_path,
        body_prefix=body[:first_heading.start()],
    )


def render_document(document: LifecycleDocument) -> str:
    body = document.body_prefix + render_sections(document.sections)
    return f"+++\n{render_frontmatter(document.metadata)}\n+++\n{body.rstrip(chr(10)).rstrip(chr(13))}\n"


def append_history_event(document: LifecycleDocument, event: str) -> LifecycleDocument:
    if not event.strip():
        raise ProductDocsError(Diagnostic("empty-history-event", "Review history event must not be empty"))
    sections = list(document.sections)
    for index, section in enumerate(sections):
        if section.heading == "Review history":
            separator = "" if not section.body or section.body.endswith("\n") else "\n"
            sections[index] = replace(section, body=f"{section.body}{separator}{event.rstrip()}\n")
            return replace(document, sections=tuple(sections))
    raise ProductDocsError(Diagnostic("missing-review-history", "Document requires a Review history section"))


def write_document_atomic(target: Path, document: LifecycleDocument | str, *, repository_root: Path | None = None) -> None:
    contents = render_document(document) if isinstance(document, LifecycleDocument) else document
    target = Path(target)
    root = (repository_root or Path.cwd()).resolve()
    target.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(prefix=f".{target.name}.", suffix=".tmp", dir=target.parent)
    temporary_path = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="") as handle:
            handle.write(contents)
            handle.flush()
            os.fsync(handle.fileno())
        parse_document(temporary_path, repository_root=root)
        temporary_path.replace(target)
    except Exception:
        temporary_path.unlink(missing_ok=True)
        raise
