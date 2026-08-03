"""Lossless level-two Markdown section parsing."""

from __future__ import annotations

import re

from .errors import Diagnostic, ProductDocsError
from .models import Section


HEADING = re.compile(r"(?m)^## ([^\r\n]+)(\r?\n|$)")


def parse_sections(body: str) -> tuple[Section, ...]:
    matches = tuple(HEADING.finditer(body))
    if not matches:
        raise ProductDocsError(
            Diagnostic("missing-sections", "Document body must contain level-two headings")
        )
    if body[:matches[0].start()].strip():
        raise ProductDocsError(
            Diagnostic(
                "body-before-sections",
                "Document body must begin with a level-two heading",
            )
        )
    sections = tuple(
        Section(
            match.group(1),
            body[match.end(): matches[index + 1].start() if index + 1 < len(matches) else len(body)],
            match.group(2),
        )
        for index, match in enumerate(matches)
    )
    headings = tuple(section.heading for section in sections)
    if len(headings) != len(set(headings)):
        raise ProductDocsError(
            Diagnostic("duplicate-section-heading", "Level-two headings must be unique")
        )
    return sections


def render_sections(sections: tuple[Section, ...]) -> str:
    return "".join(f"## {section.heading}{section.heading_ending}{section.body}" for section in sections)
