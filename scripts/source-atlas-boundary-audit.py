#!/usr/bin/env python3
"""Audit Source Atlas fixtures, bundles, and R2 plans for private-data boundary drift."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "tools" / "source-atlas"))

from foundry.boundary import boundary_issue_strings, boundary_issues_for_json_file
from foundry.boundary_audit import audit_json_file as audit_boundary_json_file
from foundry.model import read_json
from foundry.validator import validate_bundle, validate_r2_object_keys


DEFAULT_TARGETS = [
    "tools/source-atlas/fixtures/boundary",
    "source-atlas/fixtures",
]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Source Atlas public/reference boundary audit")
    parser.add_argument("targets", nargs="*", default=DEFAULT_TARGETS)
    parser.add_argument("--bundle-root", action="append", default=[])
    parser.add_argument("--r2-plan", action="append", default=[])
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args(argv)

    results: list[dict[str, Any]] = []
    for target in args.targets:
        path = (REPO_ROOT / target).resolve()
        if not path.exists():
            results.append({"target": target, "valid": False, "issues": [f"missing target: {target}"]})
            continue
        if path.is_file():
            results.append(audit_boundary_json_file(path))
        else:
            for json_path in sorted(path.rglob("*.json")):
                results.append(audit_boundary_json_file(json_path))

    for bundle in args.bundle_root:
        bundle_path = (REPO_ROOT / bundle).resolve() if not Path(bundle).is_absolute() else Path(bundle)
        validation = validate_bundle(bundle_path)
        results.append({"target": str(bundle_path), "valid": validation["valid"], "issues": validation["issues"], "kind": "bundle"})

    for plan in args.r2_plan:
        plan_path = (REPO_ROOT / plan).resolve() if not Path(plan).is_absolute() else Path(plan)
        results.append(audit_r2_plan(plan_path))

    failed = [result for result in results if not result["valid"]]
    payload = {
        "valid": not failed,
        "auditedCount": len(results),
        "failedCount": len(failed),
        "results": results,
    }
    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(f"Source Atlas boundary audit: {'PASS' if payload['valid'] else 'FAIL'} ({len(results)} targets)")
        for result in failed:
            print(f"- {result['target']}")
            for issue in result["issues"]:
                print(f"  {issue}")
    return 0 if payload["valid"] else 1


def audit_r2_plan(path: Path) -> dict[str, Any]:
    value = read_json(path)
    keys = [item.get("objectKey", "") for item in value.get("objects", []) if isinstance(item, dict)]
    issues = validate_r2_object_keys(keys)
    issues.extend(boundary_issue_strings(boundary_issues_for_json_file(path, str(path.relative_to(REPO_ROOT)))))
    return {"target": str(path.relative_to(REPO_ROOT)), "valid": not issues, "issues": issues, "kind": "r2-plan"}


if __name__ == "__main__":
    raise SystemExit(main())
