"""Lossless level-two Markdown sections and constrained table parsing."""

from __future__ import annotations

import re

from .errors import Diagnostic, ProductDocsError
from .models import Section


HEADING = re.compile(r"(?m)^## ([^\r\n]+)(\r?\n|$)")


def parse_sections(body: str) -> tuple[Section, ...]:
    matches = tuple(HEADING.finditer(body))
    if not matches:
        raise ProductDocsError(Diagnostic("missing-sections", "Document body must contain level-two contract headings"))
    if body[:matches[0].start()].strip():
        raise ProductDocsError(Diagnostic("body-before-sections", "Document body must begin with a level-two contract heading"))
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
        raise ProductDocsError(Diagnostic("duplicate-section-heading", "Level-two contract headings must be unique"))
    return sections


def render_sections(sections: tuple[Section, ...]) -> str:
    return "".join(f"## {section.heading}{section.heading_ending}{section.body}" for section in sections)


def parse_markdown_table(table: str) -> tuple[dict[str, str], ...]:
    lines = [line.strip() for line in table.splitlines() if line.strip()]
    if len(lines) < 2:
        raise ProductDocsError(Diagnostic("invalid-table", "A Markdown table requires a header and separator"))

    def cells(line: str) -> list[str]:
        if not line.startswith("|") or not line.endswith("|"):
            raise ProductDocsError(Diagnostic("invalid-table", "Table rows must begin and end with pipes"))
        return [cell.strip() for cell in line[1:-1].split("|")]

    headers = cells(lines[0])
    separators = cells(lines[1])
    if len(headers) != len(separators) or not all(re.fullmatch(r":?-{3,}:?", separator) for separator in separators):
        raise ProductDocsError(Diagnostic("invalid-table-separator", "Table separator must match the header width"))
    rows = []
    for line in lines[2:]:
        values = cells(line)
        if len(values) != len(headers):
            raise ProductDocsError(Diagnostic("table-width-mismatch", "Table row width does not match the header"))
        rows.append(dict(zip(headers, values, strict=True)))
    return tuple(rows)
