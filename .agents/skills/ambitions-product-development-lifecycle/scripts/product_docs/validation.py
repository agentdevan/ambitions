"""Structural validation for product-development documents."""

from __future__ import annotations

from dataclasses import replace
from pathlib import Path
import re

from .constants import TEMPLATE_PROFILES
from .documents import parse_document
from .errors import Diagnostic, ProductDocsError
from .models import DocumentStatus, DocumentType, ProductDocument, ValidationResult


_PLACEHOLDER = re.compile(r"PRODUCT-DOC-DRAFT:|\b(?:TODO|TBD)\b|\[(?:placeholder|fill in)\]", re.IGNORECASE)
_REQUIREMENT_ID = re.compile(r"REQ-[0-9]{3}")
_INITIATIVE_SLUG = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*\Z")
_GROOMING_DOCUMENT = re.compile(r"\A#\s+(?P<heading>\S[^\r\n]*)(?:\r?\n)(?P<body>.*\S)\s*\Z", re.DOTALL)
_GROOMING_FILES = ("plan.md", "tasks.md", "verification.md")


def _diagnostic(code: str, message: str, *, path: Path | None = None, section: str | None = None) -> Diagnostic:
    return Diagnostic(code, message, path=str(path) if path is not None else None, section=section)


def validate_document(document: ProductDocument) -> ValidationResult:
    """Validate a single document without checking its lifecycle neighbours."""
    diagnostics: list[Diagnostic] = []
    if not isinstance(document.document_type, DocumentType) or not isinstance(document.status, DocumentStatus):
        diagnostics.append(_diagnostic("invalid-metadata", "Document type and status must use supported values", path=document.source_path))
        return ValidationResult(valid=False, diagnostics=tuple(diagnostics))
    if not document.initiative.strip():
        diagnostics.append(_diagnostic("invalid-metadata", "initiative must not be empty", path=document.source_path))
    if document.source_path.name != "<memory>" and document.source_path.name != f"{document.document_type.value}.md":
        diagnostics.append(_diagnostic("canonical-filename", f"{document.document_type.value} documents must use {document.document_type.value}.md", path=document.source_path))

    headings = {section.heading for section in document.sections}
    for heading in TEMPLATE_PROFILES[document.document_type.value]:
        if heading not in headings:
            diagnostics.append(_diagnostic("missing-required-heading", f"Missing required heading: {heading}", path=document.source_path, section=heading))
    if document.status is DocumentStatus.APPROVED:
        for section in document.sections:
            if _PLACEHOLDER.search(section.body):
                diagnostics.append(_diagnostic("approved-placeholder", "Approved documents cannot contain unresolved placeholders", path=document.source_path, section=section.heading))
        if (
            document.document_type is DocumentType.SCOPE
            and not _REQUIREMENT_ID.search(_section_body(document, "Requirements"))
        ):
            diagnostics.append(
                _diagnostic(
                    "missing-scope-requirement",
                    "Approved Scope must define at least one REQ-### requirement",
                    path=document.source_path,
                    section="Requirements",
                )
            )
    return ValidationResult(valid=not diagnostics, diagnostics=tuple(diagnostics))


def _section_body(document: ProductDocument, heading: str) -> str:
    return next((section.body for section in document.sections if section.heading == heading), "")


def _validate_traceability(scope: ProductDocument, design: ProductDocument) -> list[Diagnostic]:
    scope_requirements = set(_REQUIREMENT_ID.findall(_section_body(scope, "Requirements")))
    design_requirements = set(_REQUIREMENT_ID.findall(_section_body(design, "Requirement traceability")))
    return [
        _diagnostic(
            "missing-design-traceability",
            f"Design requirement traceability is missing {requirement}",
            path=design.source_path,
            section="Requirement traceability",
        )
        for requirement in sorted(scope_requirements - design_requirements)
    ]


def _validate_grooming(
    directory: Path, design: ProductDocument | None
) -> tuple[list[Diagnostic], bool]:
    implementation = directory / "implementation"
    if not implementation.exists():
        return [], False

    diagnostics: list[Diagnostic] = []
    if not implementation.is_dir():
        return (
            [
                _diagnostic(
                    "invalid-grooming-directory",
                    "Implementation grooming must be a directory",
                    path=implementation,
                )
            ],
            False,
        )
    try:
        present_entries = {entry.name: entry for entry in implementation.iterdir()}
    except OSError:
        return (
            [
                _diagnostic(
                    "document-read-error",
                    "Implementation grooming directory could not be read",
                    path=implementation,
                )
            ],
            False,
        )
    for filename in sorted(set(present_entries) - set(_GROOMING_FILES)):
        diagnostics.append(
            _diagnostic(
                "unexpected-grooming-file",
                f"Unexpected implementation grooming entry: {filename}",
                path=present_entries[filename],
            )
        )
    if design is None or design.status is not DocumentStatus.APPROVED:
        diagnostics.append(
            _diagnostic(
                "design-not-approved",
                "Implementation grooming requires approved Design",
                path=design.source_path if design is not None else directory / "design.md",
            )
        )
    for filename in _GROOMING_FILES:
        path = implementation / filename
        if not path.is_file():
            diagnostics.append(_diagnostic("missing-grooming-file", f"Missing implementation grooming file: {filename}", path=path))
            continue
        try:
            contents = path.read_text(encoding="utf-8")
        except UnicodeError:
            diagnostics.append(
                _diagnostic(
                    "document-decode-error",
                    "File must contain valid UTF-8 text",
                    path=path,
                )
            )
            continue
        except OSError:
            diagnostics.append(
                _diagnostic(
                    "document-read-error",
                    "File could not be read",
                    path=path,
                )
            )
            continue
        if not _GROOMING_DOCUMENT.fullmatch(contents):
            diagnostics.append(
                _diagnostic(
                    "invalid-grooming-file",
                    f"Implementation grooming file must have a nonempty top-level heading and body: {filename}",
                    path=path,
                )
            )
    return diagnostics, not diagnostics


def _repository_relative_diagnostics(
    diagnostics: list[Diagnostic], repository_root: Path | None
) -> list[Diagnostic]:
    if repository_root is None:
        return diagnostics
    root = Path(repository_root).resolve()
    normalized: list[Diagnostic] = []
    for diagnostic in diagnostics:
        path = Path(diagnostic.path) if diagnostic.path is not None else None
        if path is not None and path.is_absolute():
            try:
                path = path.resolve().relative_to(root)
            except (OSError, ValueError):
                pass
        normalized.append(
            replace(diagnostic, path=str(path) if path is not None else None)
        )
    return normalized


def validate_initiative(
    directory: Path | str, *, repository_root: Path | None = None
) -> ValidationResult:
    """Validate present phase documents and their approval order."""
    directory = Path(directory)
    diagnostics: list[Diagnostic] = []
    documents: dict[DocumentType, ProductDocument] = {}
    initiative_slug = directory.name
    if not _INITIATIVE_SLUG.fullmatch(initiative_slug):
        diagnostics.append(
            _diagnostic(
                "invalid-initiative-directory",
                "Initiative directory name must be a lowercase hyphenated slug",
                path=directory,
            )
        )
    for document_type in DocumentType:
        path = directory / f"{document_type.value}.md"
        if not path.exists():
            continue
        try:
            document = parse_document(path, repository_root=repository_root)
        except ProductDocsError as error:
            diagnostics.extend(error.diagnostics)
            continue
        documents[document_type] = document
        diagnostics.extend(validate_document(document).diagnostics)
        if document.initiative != initiative_slug:
            diagnostics.append(
                _diagnostic(
                    "initiative-mismatch",
                    f"Document initiative must match directory slug {initiative_slug}",
                    path=document.source_path,
                )
            )

    research = documents.get(DocumentType.RESEARCH)
    scope = documents.get(DocumentType.SCOPE)
    design = documents.get(DocumentType.DESIGN)
    if research is not None and research.upstream != "":
        diagnostics.append(
            _diagnostic(
                "invalid-upstream",
                "Research must not declare an upstream document",
                path=research.source_path,
            )
        )
    if scope is not None:
        if scope.upstream != "research.md":
            diagnostics.append(_diagnostic("invalid-upstream", "Scope must use research.md as its upstream", path=scope.source_path))
        if scope.status is DocumentStatus.APPROVED and (research is None or research.status is not DocumentStatus.APPROVED):
            diagnostics.append(_diagnostic("research-not-approved", "Approved Scope requires approved Research", path=scope.source_path))
    if design is not None:
        if design.upstream != "scope.md":
            diagnostics.append(_diagnostic("invalid-upstream", "Design must use scope.md as its upstream", path=design.source_path))
        if design.status is DocumentStatus.APPROVED and (scope is None or scope.status is not DocumentStatus.APPROVED):
            diagnostics.append(_diagnostic("scope-not-approved", "Approved Design requires approved Scope", path=design.source_path))
    if scope is not None and design is not None:
        diagnostics.extend(_validate_traceability(scope, design))
    grooming_diagnostics, grooming_complete = _validate_grooming(directory, design)
    diagnostics.extend(grooming_diagnostics)
    diagnostics = _repository_relative_diagnostics(diagnostics, repository_root)
    return ValidationResult(
        valid=not diagnostics,
        diagnostics=tuple(diagnostics),
        grooming_complete=grooming_complete,
    )
