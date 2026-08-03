"""Stable diagnostic types for lifecycle document validation."""

from __future__ import annotations

from dataclasses import dataclass
from collections.abc import Iterable


@dataclass(frozen=True)
class Diagnostic:
    code: str
    message: str
    path: str | None = None
    section: str | None = None
    identifier: str | None = None
    remediation: str | None = None

    def as_dict(self) -> dict[str, str | None]:
        return {
            "code": self.code,
            "message": self.message,
            "path": self.path,
            "section": self.section,
            "identifier": self.identifier,
            "remediation": self.remediation,
        }


class ProductDocsError(Exception):
    """A validation failure with one or more stable diagnostics."""

    def __init__(self, diagnostics: Diagnostic | Iterable[Diagnostic]) -> None:
        if isinstance(diagnostics, Diagnostic):
            diagnostics = (diagnostics,)
        else:
            diagnostics = tuple(diagnostics)
        if not diagnostics:
            raise ValueError("ProductDocsError requires at least one diagnostic")
        self.diagnostics = diagnostics
        super().__init__("; ".join(diagnostic.message for diagnostic in diagnostics))
