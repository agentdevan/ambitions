#!/usr/bin/env python3
"""Fail-closed parser for the Swift meaningful-mutation registry."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path


KNOWN_STATUSES = {"durable", "projectionOnly", "adapter", "previewOnly", "unproven"}
POSITIVE_STATUSES = {"durable", "projectionOnly", "adapter"}


@dataclass(frozen=True)
class RegistryIssue:
    code: str
    line: int
    message: str


@dataclass(frozen=True)
class RegistryRow:
    kind: str
    line: int
    fields: dict[str, str]

    @property
    def source_path(self) -> str:
        return string_value(self.fields.get("sourcePath", "")) or ""

    @property
    def status(self) -> str:
        return enum_value(self.fields.get("status", "")) or ""

    @property
    def rationale(self) -> str:
        return string_value(self.fields.get("rationale", "")) or ""

    @property
    def proof_test_ids(self) -> list[str]:
        return string_array_value(self.fields.get("proofTestIDs", "[]"))

    @property
    def replay_test_id(self) -> str:
        return string_value(self.fields.get("replayTestID", "")) or ""


@dataclass(frozen=True)
class RegistryInventory:
    mutations: list[RegistryRow]
    write_paths: list[RegistryRow]
    issues: list[RegistryIssue]


def _line(text: str, index: int) -> int:
    return text.count("\n", 0, index) + 1


def _skip_noncode(text: str, index: int) -> int:
    if text.startswith("//", index):
        newline = text.find("\n", index + 2)
        return len(text) if newline == -1 else newline + 1
    if text.startswith("/*", index):
        end = text.find("*/", index + 2)
        return len(text) if end == -1 else end + 2
    if text[index] == '"':
        index += 1
        while index < len(text):
            if text[index] == "\\":
                index += 2
            elif text[index] == '"':
                return index + 1
            else:
                index += 1
        return len(text)
    return index


def _balanced_call(text: str, open_index: int) -> tuple[str | None, int, str | None]:
    depth = 0
    index = open_index
    while index < len(text):
        skipped = _skip_noncode(text, index)
        if skipped != index:
            index = skipped
            continue
        char = text[index]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return text[open_index + 1:index], index + 1, None
            if depth < 0:
                return None, index + 1, "unexpected closing parenthesis"
        index += 1
    return None, len(text), "unterminated registry call"


def _array_body(text: str, marker: str) -> tuple[str | None, int, RegistryIssue | None]:
    match = re.search(rf"\b{re.escape(marker)}\b[^=]*=\s*\[", text)
    if match is None:
        return None, 0, RegistryIssue("registry-array-missing", 1, f"Registry array `{marker}` is missing.")
    open_index = match.end() - 1
    depth = 0
    index = open_index
    while index < len(text):
        skipped = _skip_noncode(text, index)
        if skipped != index:
            index = skipped
            continue
        if text[index] == "[":
            depth += 1
        elif text[index] == "]":
            depth -= 1
            if depth == 0:
                return text[open_index + 1:index], open_index + 1, None
        index += 1
    return None, open_index + 1, RegistryIssue("registry-array-unbalanced", _line(text, open_index), f"Registry array `{marker}` is unterminated.")


def _calls(text: str) -> tuple[list[tuple[str, int, str]], list[RegistryIssue]]:
    calls: list[tuple[str, int, str]] = []
    issues: list[RegistryIssue] = []
    index = 0
    while index < len(text):
        skipped = _skip_noncode(text, index)
        if skipped != index:
            index = skipped
            continue
        if text[index].isalpha() or text[index] == "_":
            start = index
            index += 1
            while index < len(text) and (text[index].isalnum() or text[index] == "_"):
                index += 1
            name = text[start:index]
            if name not in {"mutation", "writePath"}:
                continue
            lookahead = index
            while lookahead < len(text) and text[lookahead].isspace():
                lookahead += 1
            if lookahead >= len(text) or text[lookahead] != "(":
                issues.append(RegistryIssue("registry-call-missing-parenthesis", _line(text, start), f"`{name}` row is malformed."))
                continue
            body, end, error = _balanced_call(text, lookahead)
            if error:
                issues.append(RegistryIssue("registry-call-unbalanced", _line(text, start), f"`{name}`: {error}."))
                index = end
                continue
            calls.append((name, _line(text, start), body or ""))
            index = end
            continue
        index += 1
    return calls, issues


def _split_top_level(value: str, delimiter: str) -> list[str]:
    parts: list[str] = []
    start = 0
    index = 0
    depths = {"(": 0, "[": 0, "{": 0}
    closing = {")": "(", "]": "[", "}": "{"}
    while index < len(value):
        skipped = _skip_noncode(value, index)
        if skipped != index:
            index = skipped
            continue
        char = value[index]
        if char in depths:
            depths[char] += 1
        elif char in closing:
            depths[closing[char]] -= 1
        elif char == delimiter and not any(depths.values()):
            parts.append(value[start:index].strip())
            start = index + 1
        index += 1
    parts.append(value[start:].strip())
    return [part for part in parts if part]


def _labeled_fields(body: str, line: int) -> tuple[dict[str, str], list[RegistryIssue]]:
    fields: dict[str, str] = {}
    issues: list[RegistryIssue] = []
    for argument in _split_top_level(body, ","):
        pieces = _split_top_level(argument, ":")
        if len(pieces) != 2 or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", pieces[0]):
            issues.append(RegistryIssue("registry-argument-unlabeled", line, f"Registry argument must be explicitly labeled: `{argument}`."))
            continue
        label, value = pieces
        if label in fields:
            issues.append(RegistryIssue("registry-argument-duplicate", line, f"Duplicate registry field `{label}`."))
            continue
        fields[label] = value.strip()
    return fields, issues


def string_value(value: str) -> str | None:
    match = re.fullmatch(r'"((?:\\.|[^"\\])*)"', value.strip(), re.DOTALL)
    if match is None:
        return None
    return bytes(match.group(1), "utf-8").decode("unicode_escape")


def enum_value(value: str) -> str | None:
    match = re.fullmatch(r"\.([A-Za-z_][A-Za-z0-9_]*)", value.strip())
    return match.group(1) if match else None


def string_array_value(value: str) -> list[str]:
    stripped = value.strip()
    if stripped == "[]":
        return []
    if not (stripped.startswith("[") and stripped.endswith("]")):
        return []
    result: list[str] = []
    for part in _split_top_level(stripped[1:-1], ","):
        parsed = string_value(part)
        if parsed is None:
            return []
        result.append(parsed)
    return result


def _validate_row(row: RegistryRow) -> list[RegistryIssue]:
    issues: list[RegistryIssue] = []
    required = {"status", "rationale", "sourcePath"}
    if row.kind == "mutation":
        required |= {"id", "commandKind"}
    for field in sorted(required - set(row.fields)):
        issues.append(RegistryIssue("registry-field-missing", row.line, f"`{row.kind}` row is missing `{field}`."))
    if not row.source_path:
        issues.append(RegistryIssue("registry-source-invalid", row.line, f"`{row.kind}` sourcePath must be a string."))
    if not row.rationale:
        issues.append(RegistryIssue("registry-rationale-missing", row.line, f"`{row.kind}` row requires a non-empty row-specific rationale."))
    if not row.status:
        issues.append(RegistryIssue("registry-status-missing", row.line, f"`{row.kind}` row requires an explicit enum status."))
    elif row.status not in KNOWN_STATUSES:
        issues.append(RegistryIssue("registry-status-unknown", row.line, f"Unknown registry status `{row.status}`."))
    if row.status in POSITIVE_STATUSES:
        required_lineage = {"executorOwner", "eventKind", "projectionOwner", "receiptOwner", "replayTestID", "proofTestIDs"}
        for field in sorted(required_lineage):
            value = row.fields.get(field, "")
            populated = bool(string_array_value(value)) if field == "proofTestIDs" else bool(string_value(value))
            if not populated:
                issues.append(RegistryIssue("registry-positive-proof-missing", row.line, f"Positive `{row.status}` row requires row-specific `{field}` evidence."))
    return issues


def parse_registry(text: str) -> RegistryInventory:
    calls: list[tuple[str, int, str]] = []
    issues: list[RegistryIssue] = []
    for marker, expected_kind in (("descriptors", "mutation"), ("writePaths", "writePath")):
        body, offset, issue = _array_body(text, marker)
        if issue:
            issues.append(issue)
            continue
        array_calls, array_issues = _calls(body or "")
        for kind, relative_line, call_body in array_calls:
            absolute_line = _line(text, offset) + relative_line - 1
            if kind != expected_kind:
                issues.append(RegistryIssue("registry-row-wrong-array", absolute_line, f"`{kind}` row appears in `{marker}`."))
            calls.append((kind, absolute_line, call_body))
        issues.extend(
            RegistryIssue(issue.code, _line(text, offset) + issue.line - 1, issue.message)
            for issue in array_issues
        )
    mutations: list[RegistryRow] = []
    write_paths: list[RegistryRow] = []
    for kind, line, body in calls:
        fields, field_issues = _labeled_fields(body, line)
        issues.extend(field_issues)
        row = RegistryRow(kind, line, fields)
        issues.extend(_validate_row(row))
        (mutations if kind == "mutation" else write_paths).append(row)

    for marker, actual, label in (
        ("declaredMutationRowCount", len(mutations), "mutation"),
        ("declaredWritePathRowCount", len(write_paths), "write-path"),
    ):
        matches = re.findall(rf"\b{marker}\s*=\s*(\d+)\b", text)
        if len(matches) != 1:
            issues.append(RegistryIssue("registry-count-marker-missing", 1, f"Registry requires exactly one `{marker}` marker."))
        elif int(matches[0]) != actual:
            issues.append(RegistryIssue("registry-parser-count-loss", 1, f"Declared {label} count {matches[0]} does not match parsed count {actual}."))

    return RegistryInventory(mutations, write_paths, issues)


def parse_registry_file(path: Path) -> RegistryInventory:
    return parse_registry(path.read_text(encoding="utf-8", errors="replace"))
