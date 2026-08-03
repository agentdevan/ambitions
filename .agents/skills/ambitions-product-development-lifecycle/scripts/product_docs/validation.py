"""Structural validation for product-development documents."""

from __future__ import annotations

from pathlib import Path
import re

from .constants import TEMPLATE_PROFILES
from .documents import parse_document
from .errors import Diagnostic, ProductDocsError
from .models import DocumentStatus, DocumentType, ProductDocument, ValidationResult


_PLACEHOLDER = re.compile(r"PRODUCT-DOC-DRAFT:|\b(?:TODO|TBD)\b|\[(?:placeholder|fill in)\]", re.IGNORECASE)
_REQUIREMENT_ID = re.compile(r"REQ-[0-9]{3}")
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


def _validate_grooming(directory: Path, design: ProductDocument | None) -> list[Diagnostic]:
    implementation = directory / "implementation"
    if not implementation.exists():
        return []

    diagnostics: list[Diagnostic] = []
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
        if not _GROOMING_DOCUMENT.fullmatch(path.read_text(encoding="utf-8")):
            diagnostics.append(
                _diagnostic(
                    "invalid-grooming-file",
                    f"Implementation grooming file must have a nonempty top-level heading and body: {filename}",
                    path=path,
                )
            )
    return diagnostics


def validate_initiative(directory: Path | str) -> ValidationResult:
    """Validate present phase documents and their approval order."""
    directory = Path(directory)
    diagnostics: list[Diagnostic] = []
    documents: dict[DocumentType, ProductDocument] = {}
    for document_type in DocumentType:
        path = directory / f"{document_type.value}.md"
        if not path.exists():
            continue
        try:
            document = parse_document(path)
        except ProductDocsError as error:
            diagnostics.extend(error.diagnostics)
            continue
        documents[document_type] = document
        diagnostics.extend(validate_document(document).diagnostics)

    research = documents.get(DocumentType.RESEARCH)
    scope = documents.get(DocumentType.SCOPE)
    design = documents.get(DocumentType.DESIGN)
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
    diagnostics.extend(_validate_grooming(directory, design))
    return ValidationResult(valid=not diagnostics, diagnostics=tuple(diagnostics))
