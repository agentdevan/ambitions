"""Typed, deterministic I/O for product-development lifecycle documents."""

from .documents import parse_document, render_document, write_document_atomic
from .errors import Diagnostic, ProductDocsError
from .models import (
    DocumentStatus,
    DocumentType,
    ProductDocument,
    Section,
    ValidationResult,
)

__all__ = (
    "Diagnostic",
    "DocumentStatus",
    "DocumentType",
    "parse_document",
    "ProductDocument",
    "ProductDocsError",
    "render_document",
    "Section",
    "ValidationResult",
    "write_document_atomic",
)
