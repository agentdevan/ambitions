#!/usr/bin/env python3
"""Validate the machine-readable product-experience scenario gate index."""

from __future__ import annotations

from collections import defaultdict
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
INDEX_PATH = ROOT / "docs" / "qa" / "product-experience-scenario-gates.yaml"

REQUIRED_FIELDS = {
    "id",
    "group",
    "user_visible_behavior",
    "current_status",
    "evidence_paths",
    "required_future_proof",
    "last_verified_commit",
    "canon_source",
    "owner_area",
    "tests",
}

VALID_STATUSES = {"Existing", "Partial", "Missing", "Unknown"}


def _unquote(value: str) -> str:
    value = value.strip()
    if value == "[]":
        return value
    if len(value) >= 2 and value[0] == value[-1] == '"':
        return bytes(value[1:-1], "utf-8").decode("unicode_escape")
    return value


def load_simple_yaml(path: Path) -> list[dict[str, object]]:
    gates: list[dict[str, object]] = []
    current: dict[str, object] | None = None
    list_field: str | None = None

    for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        line = raw_line.rstrip()
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or stripped == "gates:":
            continue

        if line.startswith("  - id: "):
            if current is not None:
                gates.append(current)
            current = {"id": _unquote(line.split(":", 1)[1])}
            list_field = None
            continue

        if current is None:
            raise ValueError(f"line {line_number}: content before first gate")

        if line.startswith("    ") and not line.startswith("      - "):
            key, separator, value = stripped.partition(":")
            if separator != ":":
                raise ValueError(f"line {line_number}: expected key/value pair")
            value = value.strip()
            if value == "":
                current[key] = []
                list_field = key
            elif value == "[]":
                current[key] = []
                list_field = None
            else:
                current[key] = _unquote(value)
                list_field = None
            continue

        if line.startswith("      - "):
            if list_field is None:
                raise ValueError(f"line {line_number}: list item without list field")
            current.setdefault(list_field, [])
            target = current[list_field]
            if not isinstance(target, list):
                raise ValueError(f"line {line_number}: field {list_field} is not a list")
            target.append(_unquote(stripped[2:].strip()))
            continue

        raise ValueError(f"line {line_number}: unsupported YAML shape")

    if current is not None:
        gates.append(current)
    return gates


def main() -> int:
    if not INDEX_PATH.exists():
        print(f"RED: missing {INDEX_PATH.relative_to(ROOT)}", file=sys.stderr)
        return 1

    try:
        gates = load_simple_yaml(INDEX_PATH)
    except ValueError as error:
        print(f"RED: could not parse {INDEX_PATH.relative_to(ROOT)}: {error}", file=sys.stderr)
        return 1

    errors: list[str] = []
    seen: set[str] = set()
    summary: dict[str, dict[str, int]] = defaultdict(lambda: defaultdict(int))

    for index, gate in enumerate(gates, start=1):
        missing = sorted(REQUIRED_FIELDS - set(gate))
        gate_id = str(gate.get("id", f"<gate {index}>"))
        for field in missing:
            errors.append(f"{gate_id}: missing required field {field}")

        if gate_id in seen:
            errors.append(f"{gate_id}: duplicate gate id")
        seen.add(gate_id)

        status = gate.get("current_status")
        if status not in VALID_STATUSES:
            errors.append(f"{gate_id}: invalid current_status {status!r}")

        evidence_paths = gate.get("evidence_paths")
        if not isinstance(evidence_paths, list):
            errors.append(f"{gate_id}: evidence_paths must be a list")

        tests = gate.get("tests")
        if not isinstance(tests, list):
            errors.append(f"{gate_id}: tests must be a list")

        required_future_proof = gate.get("required_future_proof")
        if not isinstance(required_future_proof, str) or not required_future_proof.strip():
            errors.append(f"{gate_id}: required_future_proof is empty")

        canon_source = gate.get("canon_source")
        if not isinstance(canon_source, str) or not canon_source.strip():
            errors.append(f"{gate_id}: canon_source is empty")

        commit = gate.get("last_verified_commit")
        if not isinstance(commit, str) or not re.fullmatch(r"[0-9a-f]{40}", commit):
            errors.append(f"{gate_id}: last_verified_commit must be a 40-character SHA")

        group = str(gate.get("group", "Unknown group"))
        if status in VALID_STATUSES:
            summary[group][str(status)] += 1

    if errors:
        print("# Product Experience Gate Index Check")
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1

    print("# Product Experience Gate Index Check")
    print(f"GREEN: {len(gates)} gates validated")
    for group in sorted(summary):
        counts = ", ".join(
            f"{status}={summary[group].get(status, 0)}"
            for status in ("Existing", "Partial", "Missing", "Unknown")
        )
        print(f"{group}: {counts}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
