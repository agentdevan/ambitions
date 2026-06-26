#!/usr/bin/env python3
"""Focused Source Atlas no-private-graph egress audit."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "tools" / "source-atlas"))

from foundry.boundary import boundary_issue_strings, boundary_issues_for_json_file, object_key_issues
from foundry.model import read_json


DEFAULT_TARGETS = [
    "tools/source-atlas/foundry",
    "tools/source-atlas/fixtures",
    "tools/source-atlas/foundry/contracts",
    "docs/platform/SOURCE_ATLAS_FOUNDRY_BLUEPRINT.md",
]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Audit Source Atlas for private graph egress markers")
    parser.add_argument("targets", nargs="*", default=DEFAULT_TARGETS)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args(argv)

    issues: list[str] = []
    for target in args.targets:
        path = (REPO_ROOT / target).resolve()
        if not path.exists():
            issues.append(f"{target}: missing target")
            continue
        if path.is_dir():
            for json_path in sorted(path.rglob("*.json")):
                issues.extend(audit_json(json_path))
            for py_path in sorted(path.rglob("*.py")):
                issues.extend(audit_text(py_path))
        elif path.suffix == ".json":
            issues.extend(audit_json(path))
        else:
            issues.extend(audit_text(path))

    payload = {"valid": not issues, "issueCount": len(issues), "issues": issues}
    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(f"Source Atlas no-private-graph egress audit: {'PASS' if payload['valid'] else 'FAIL'}")
        for issue in issues:
            print(f"- {issue}")
    return 0 if payload["valid"] else 1


def audit_json(path: Path) -> list[str]:
    value = read_json(path)
    if isinstance(value, dict) and value.get("expectedValid") is False:
        return []
    expected = value.get("expectedBoundaryResult") if isinstance(value, dict) else None
    if expected == "reject":
        return []
    relative = display_path(path)
    issues = boundary_issue_strings(boundary_issues_for_json_file(path, relative))
    if isinstance(value, dict) and isinstance(value.get("objectKey"), str):
        issues.extend(issue.format() for issue in object_key_issues(value["objectKey"], relative))
    return issues


def audit_text(path: Path) -> list[str]:
    relative = display_path(path)
    findings: list[str] = []
    for index, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), start=1):
        lowered = line.lower()
        if "r2" not in lowered and "urlsession" not in lowered and "objectkey" not in lowered and "upload" not in lowered:
            continue
        if any(term in lowered for term in ["goaltext", "capturetext", "privatelif egraph".replace(" ", "")]):
            findings.append(f"{relative}:{index}: possible private graph egress marker")
        if any(term in lowered for term in ["private life graph", "goals", "captures", "receipts", "proof"]):
            if not any(marker in lowered for marker in ["must not", "never", "no private", "not a", "forbidden", "forbid", "reject", "not store", "not receive", "only", "public/reference", "private life graph in r2", "staging proof"]):
                findings.append(f"{relative}:{index}: review Source Atlas private graph egress wording")
    return findings


def display_path(path: Path) -> str:
    try:
        return str(path.relative_to(REPO_ROOT))
    except ValueError:
        return str(path)


if __name__ == "__main__":
    raise SystemExit(main())
