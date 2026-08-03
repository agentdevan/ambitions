"""Typed, deterministic I/O for product-development lifecycle documents."""

from .documents import append_history_event, parse_document, render_document, write_document_atomic
from .errors import Diagnostic, ProductDocsError
from .markdown import parse_markdown_table
from .models import (
    AuthorityClass,
    DocumentStatus,
    DocumentType,
    EvidenceFile,
    InputBinding,
    InputKind,
    LifecycleDocument,
    ReviewLane,
    ReviewVerdict,
)

__all__ = (
    "append_history_event",
    "AuthorityClass",
    "Diagnostic",
    "DocumentStatus",
    "DocumentType",
    "EvidenceFile",
    "InputBinding",
    "InputKind",
    "LifecycleDocument",
    "parse_document",
    "parse_markdown_table",
    "ProductDocsError",
    "render_document",
    "ReviewLane",
    "ReviewVerdict",
    "write_document_atomic",
)
