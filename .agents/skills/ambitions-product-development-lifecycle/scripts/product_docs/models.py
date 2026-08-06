"""Small typed records for product-development documents."""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from pathlib import Path

from .errors import Diagnostic


class DocumentType(str, Enum):
    RESEARCH = "research"
    SCOPE = "scope"
    DESIGN = "design"


class DocumentStatus(str, Enum):
    DRAFT = "draft"
    APPROVED = "approved"


@dataclass(frozen=True)
class Section:
    heading: str
    body: str
    heading_ending: str = "\n"


@dataclass(frozen=True)
class ProductDocument:
    initiative: str
    document_type: DocumentType
    status: DocumentStatus
    upstream: str
    sections: tuple[Section, ...]
    source_path: Path


@dataclass(frozen=True)
class ValidationResult:
    valid: bool
    diagnostics: tuple[Diagnostic, ...]
    grooming_complete: bool = False
