#!/usr/bin/env python3
"""Validate repo-intelligence evidence packets without requiring jsonschema."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SCHEMA = ROOT / ".codex/schemas/repo-intelligence-evidence.schema.json"
REQUIRED_TOP = [
    "batch_id",
    "timestamp_utc",
    "status",
    "tools",
    "advisory_findings",
    "runner_integration",
    "violations",
    "non_claims",
    "rollback",
]
REQUIRED_TOOLS = {
    "codegraph": ["available", "version", "index_present", "status_command", "notes"],
    "semble": ["available", "version", "index_present", "notes"],
    "understand_anything": ["available", "used", "sandbox_only", "notes"],
}
REQUIRED_RUNNER = [
    "ios26_sequential_primary_front_door",
    "ios26_shape_check_present",
    "ios26_sequence_hook_present",
    "canonical_runner_prompt_hook_present",
    "final_gate_fields_present",
    "fallback_behavior_present",
]


def validate(data: dict[str, Any]) -> tuple[str, list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    for key in REQUIRED_TOP:
        if key not in data:
            errors.append(f"missing required field: {key}")
    if data.get("status") not in {"GREEN", "YELLOW", "RED"}:
        errors.append("status must be GREEN, YELLOW, or RED")
    tools = data.get("tools", {})
    if not isinstance(tools, dict):
        errors.append("tools must be an object")
    else:
        for tool, fields in REQUIRED_TOOLS.items():
            value = tools.get(tool)
            if not isinstance(value, dict):
                errors.append(f"tools.{tool} must be an object")
                continue
            for field in fields:
                if field not in value:
                    errors.append(f"tools.{tool}.{field} missing")
    runner = data.get("runner_integration", {})
    if not isinstance(runner, dict):
        errors.append("runner_integration must be an object")
    else:
        for field in REQUIRED_RUNNER:
            if field not in runner:
                errors.append(f"runner_integration.{field} missing")

    findings = data.get("advisory_findings", [])
    if not isinstance(findings, list):
        errors.append("advisory_findings must be a list")
    else:
        for index, finding in enumerate(findings):
            if not isinstance(finding, dict):
                errors.append(f"advisory_findings[{index}] must be an object")
                continue
            if finding.get("accepted"):
                if not finding.get("resolved_paths"):
                    errors.append(f"accepted finding {index} has no resolved_paths")
                if finding.get("direct_file_verification") is not True:
                    errors.append(f"accepted finding {index} lacks direct file verification")
                if str(finding.get("tool", "")).lower().replace(" ", "_") in {"understand_anything", "understand-anything"}:
                    errors.append(f"accepted finding {index} uses Understand Anything as proof")
                if not finding.get("validation_evidence"):
                    warnings.append(f"accepted finding {index} has no validation_evidence")

    if data.get("violations"):
        errors.extend(f"packet violation: {item}" for item in data["violations"])
    if errors:
        return "RED", errors, warnings
    if warnings or data.get("status") == "YELLOW":
        return "YELLOW", errors, warnings
    return "GREEN", errors, warnings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("packet", type=Path)
    args = parser.parse_args()

    if not SCHEMA.exists():
        print(f"RED: missing schema {SCHEMA.relative_to(ROOT)}")
        return 1
    try:
        data = json.loads(args.packet.read_text(encoding="utf-8"))
    except Exception as exc:
        print(f"RED: cannot read evidence JSON: {exc}")
        return 1

    status, errors, warnings = validate(data)
    print(f"{status}: repo-intelligence evidence check {args.packet}")
    for error in errors:
        print(f"RED: {error}")
    for warning in warnings:
        print(f"YELLOW: {warning}")
    return {"GREEN": 0, "YELLOW": 2, "RED": 1}[status]


if __name__ == "__main__":
    raise SystemExit(main())
