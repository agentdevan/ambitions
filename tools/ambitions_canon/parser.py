"""Parser for canonical Markdown specification contracts."""

from __future__ import annotations

import re
import tomllib
from pathlib import Path

from tools.ambitions_canon.model import (
    CanonDocument,
    CanonError,
    DocumentKind,
    Modality,
    Requirement,
)


FRONT = "+++"
REQ_HEADING = re.compile(
    r"^##\s+([A-Z][A-Z0-9-]+-\d{3})\s+—\s+(.+?)\s*$"
)
SECTION = re.compile(r"^<!--\s*canon-section:\s*([a-z0-9-]+)\s*-->$")
LEVEL_TWO_HEADING = re.compile(r"^##\s+.+?\s*$")
FIELD = re.compile(
    r"^- \*\*(Concept|Modality|Scope|Status|Verification|Supersedes):\*\*"
    r"\s*(.*?)\s*$"
)
METADATA_SHAPED = re.compile(r"^- \*\*([^*\n]+):\*\*\s*.*$")
BACKTICK_VALUE = re.compile(r"^`([^`\n]+)`$")
BACKTICK_LIST = re.compile(r"^`[^`\n]+`(?:\s*,\s*`[^`\n]+`)*$")
BACKTICK_ITEM = re.compile(r"`([^`\n]+)`")
TOML_LINE_LOCATION = re.compile(
    r"^.+ \(at line ([1-9]\d*), column [1-9]\d*\)$"
)
TOML_END_LOCATION = re.compile(r"^.+ \(at end of document\)$")

REQUIRED_FRONT_MATTER = {
    "spec_id": str,
    "title": str,
    "kind": str,
    "status": str,
    "owner_domain": str,
    "canon_revision": int,
    "owns_concepts": list,
    "inherits": list,
    "depends_on": list,
    "source_owners": list,
}
REQUIRED_FIELDS = (
    "Concept",
    "Modality",
    "Scope",
    "Status",
    "Verification",
    "Supersedes",
)


def parse_front_matter(
    text: str,
    path: Path,
) -> tuple[dict[str, object], str, int]:
    """Parse the leading TOML block and retain body line correspondence."""

    lines = text.splitlines()
    if not lines or lines[0] != FRONT:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "missing opening delimiter",
            path,
            1,
        )
    try:
        closing = lines.index(FRONT, 1)
    except ValueError as exc:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "missing closing delimiter",
            path,
            len(lines),
        ) from exc

    try:
        metadata = tomllib.loads("\n".join(lines[1:closing]))
    except tomllib.TOMLDecodeError as exc:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "invalid TOML",
            path,
            _toml_source_line(exc, closing),
        ) from exc

    return metadata, "\n".join(lines[closing + 1 :]) + "\n", closing + 2


def _toml_source_line(exc: tomllib.TOMLDecodeError, closing: int) -> int:
    message = str(exc)
    if match := TOML_LINE_LOCATION.fullmatch(message):
        return int(match.group(1)) + 1
    if TOML_END_LOCATION.fullmatch(message):
        return max(1, closing)
    return 1


def parse_canon_document(path: Path, text: str) -> CanonDocument:
    """Parse one canonical Markdown document without global registry checks."""

    metadata, body, body_start_line = parse_front_matter(text, path)
    _validate_front_matter(metadata, path)

    body_lines = body.splitlines()
    sections = frozenset(
        match.group(1)
        for line in body_lines
        if (match := SECTION.fullmatch(line)) is not None
    )
    requirement_starts = _requirement_starts(body_lines, path, body_start_line)
    requirements = tuple(
        _parse_requirement(
            path,
            body_lines,
            start,
            _requirement_end(body_lines, start),
            heading,
            body_start_line,
        )
        for start, heading in requirement_starts
    )

    kind_value = metadata["kind"]
    assert isinstance(kind_value, str)
    try:
        kind = DocumentKind(kind_value)
    except ValueError as exc:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            f"invalid kind: {kind_value}",
            path,
            1,
        ) from exc

    profile = metadata.get("profile")
    if profile is not None and not isinstance(profile, str):
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "profile must be a string",
            path,
            1,
        )

    return CanonDocument(
        spec_id=_string(metadata, "spec_id"),
        title=_string(metadata, "title"),
        kind=kind,
        status=_string(metadata, "status"),
        owner_domain=_string(metadata, "owner_domain"),
        canon_revision=_integer(metadata, "canon_revision"),
        profile=profile,
        owns_concepts=_string_tuple(metadata, "owns_concepts"),
        inherits=_string_tuple(metadata, "inherits"),
        depends_on=_string_tuple(metadata, "depends_on"),
        source_owners=_string_tuple(metadata, "source_owners"),
        sections=sections,
        not_applicable=(),
        requirements=requirements,
        source_path=path,
    )


def _validate_front_matter(metadata: dict[str, object], path: Path) -> None:
    for key, expected_type in REQUIRED_FRONT_MATTER.items():
        if key not in metadata:
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"missing required field: {key}",
                path,
                1,
            )
        value = metadata[key]
        if expected_type is int:
            valid_type = isinstance(value, int) and not isinstance(value, bool)
        else:
            valid_type = isinstance(value, expected_type)
        if not valid_type:
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"invalid field type: {key}",
                path,
                1,
            )

    for key in ("owns_concepts", "inherits", "depends_on", "source_owners"):
        value = metadata[key]
        assert isinstance(value, list)
        if not all(isinstance(item, str) for item in value):
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"field must contain only strings: {key}",
                path,
                1,
            )


def _requirement_starts(
    lines: list[str],
    path: Path,
    body_start_line: int,
) -> list[tuple[int, re.Match[str]]]:
    starts: list[tuple[int, re.Match[str]]] = []
    seen: set[str] = set()
    for index, line in enumerate(lines):
        match = REQ_HEADING.fullmatch(line)
        if match is None:
            continue
        requirement_id = match.group(1)
        if requirement_id in seen:
            raise CanonError(
                "CANON_REQUIREMENT_DUPLICATE",
                f"duplicate requirement ID: {requirement_id}",
                path,
                body_start_line + index,
            )
        seen.add(requirement_id)
        starts.append((index, match))
    return starts


def _parse_requirement(
    path: Path,
    lines: list[str],
    start: int,
    end: int,
    heading: re.Match[str],
    body_start_line: int,
) -> Requirement:
    cursor = start + 1
    while cursor < end and lines[cursor] == "":
        cursor += 1

    fields: dict[str, tuple[str, int]] = {}
    while cursor < end:
        match = FIELD.fullmatch(lines[cursor])
        if match is None:
            break
        name, value = match.groups()
        source_line = body_start_line + cursor
        if name in fields:
            raise CanonError(
                "CANON_REQUIREMENT_FIELD",
                f"duplicate requirement field: {name}",
                path,
                source_line,
            )
        fields[name] = (value, source_line)
        cursor += 1

    for name in REQUIRED_FIELDS:
        if name not in fields:
            raise CanonError(
                "CANON_REQUIREMENT_FIELD",
                f"missing requirement field: {name}",
                path,
                body_start_line + start,
            )

    _reject_metadata_residue(path, lines, cursor, end, body_start_line)

    concept = _backtick_value(path, fields["Concept"], "Concept")
    modality_text = _backtick_value(path, fields["Modality"], "Modality")
    try:
        modality = Modality(modality_text)
    except ValueError as exc:
        raise CanonError(
            "CANON_REQUIREMENT_MODALITY",
            f"invalid modality: {modality_text}",
            path,
            fields["Modality"][1],
        ) from exc
    scope = fields["Scope"][0]
    if not scope:
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            "empty requirement field: Scope",
            path,
            fields["Scope"][1],
        )
    status = _backtick_value(path, fields["Status"], "Status")
    verification = _backtick_list(path, fields["Verification"], "Verification")
    supersedes = _backtick_list(path, fields["Supersedes"], "Supersedes")

    while cursor < end and lines[cursor] == "":
        cursor += 1
    body_end = end
    while body_end > cursor and lines[body_end - 1] == "":
        body_end -= 1

    return Requirement(
        requirement_id=heading.group(1),
        title=heading.group(2),
        concept=concept,
        modality=modality,
        scope=scope,
        status=status,
        verification=verification,
        supersedes=supersedes,
        body="\n".join(lines[cursor:body_end]),
        source_path=path,
        line=body_start_line + start,
    )


def _requirement_end(lines: list[str], start: int) -> int:
    for index in range(start + 1, len(lines)):
        line = lines[index]
        if LEVEL_TWO_HEADING.fullmatch(line) or SECTION.fullmatch(line):
            return index
    return len(lines)


def _reject_metadata_residue(
    path: Path,
    lines: list[str],
    start: int,
    end: int,
    body_start_line: int,
) -> None:
    for index in range(start, end):
        match = METADATA_SHAPED.fullmatch(lines[index])
        if match is None:
            continue
        name = match.group(1)
        qualifier = "duplicate" if name in REQUIRED_FIELDS else "unknown"
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            f"{qualifier} requirement field: {name}",
            path,
            body_start_line + index,
        )


def _backtick_value(
    path: Path,
    field: tuple[str, int],
    name: str,
) -> str:
    value, line = field
    match = BACKTICK_VALUE.fullmatch(value)
    if match is None or match.group(1) != match.group(1).strip():
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            f"{name} must be one backtick value",
            path,
            line,
        )
    return match.group(1)


def _backtick_list(
    path: Path,
    field: tuple[str, int],
    name: str,
) -> tuple[str, ...]:
    value, line = field
    if value == "none":
        return ()
    if BACKTICK_LIST.fullmatch(value) is None:
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            f"{name} must be a backtick list or literal none",
            path,
            line,
        )
    items = tuple(match.group(1) for match in BACKTICK_ITEM.finditer(value))
    if any(item != item.strip() for item in items):
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            f"{name} contains an invalid backtick value",
            path,
            line,
        )
    return items


def _string(metadata: dict[str, object], key: str) -> str:
    value = metadata[key]
    assert isinstance(value, str)
    return value


def _integer(metadata: dict[str, object], key: str) -> int:
    value = metadata[key]
    assert isinstance(value, int) and not isinstance(value, bool)
    return value


def _string_tuple(metadata: dict[str, object], key: str) -> tuple[str, ...]:
    value = metadata[key]
    assert isinstance(value, list)
    return tuple(value)
