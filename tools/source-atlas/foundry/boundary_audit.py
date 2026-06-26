"""Boundary-audit runner for Source Atlas Foundry."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_json_file, object_key_issues, request_shape_issues
from .model import read_json
from .validator import validate_bundle, validate_r2_object_keys


def audit_fixture_root(fixture_root: Path) -> dict[str, Any]:
    results: list[dict[str, Any]] = []
    if not fixture_root.exists():
        return {"valid": False, "auditedCount": 0, "failedCount": 1, "results": [{"target": str(fixture_root), "valid": False, "issues": ["missing fixture root"]}]}
    for path in sorted(fixture_root.rglob("*.json")):
        results.append(audit_json_file(path))
    return _summary(results)


def audit_bundle(bundle_root: Path) -> dict[str, Any]:
    validation = validate_bundle(bundle_root)
    return {
        "valid": validation["valid"],
        "auditedCount": 1,
        "failedCount": 0 if validation["valid"] else 1,
        "results": [{"target": str(bundle_root), "valid": validation["valid"], "issues": validation["issues"], "kind": "bundle"}],
    }


def audit_r2_plan(plan_path: Path) -> dict[str, Any]:
    value = read_json(plan_path)
    keys = [item.get("objectKey", "") for item in value.get("objects", []) if isinstance(item, dict)]
    issues = validate_r2_object_keys(keys)
    issues.extend(boundary_issue_strings(boundary_issues_for_json_file(plan_path, str(plan_path))))
    valid = not issues
    return {
        "valid": valid,
        "auditedCount": 1,
        "failedCount": 0 if valid else 1,
        "results": [{"target": str(plan_path), "valid": valid, "issues": issues, "kind": "r2-plan"}],
    }


def audit_json_file(path: Path) -> dict[str, Any]:
    value = read_json(path)
    issues = boundary_issue_strings(boundary_issues_for_json_file(path, str(path)))
    if isinstance(value, dict):
        payload = value.get("payload", value)
        if isinstance(payload, dict):
            issues.extend(boundary_issue_strings(boundary_issues_for_json_file(path, str(path))) if payload is value else [])
            if payload.get("kind") == "ambitions.sourceAtlas.boundaryRequestFixture.v1":
                issues.extend(issue.format() for issue in request_shape_issues(payload.get("request", {}), str(path)))
            if "objectKey" in payload and isinstance(payload["objectKey"], str):
                issues.extend(issue.format() for issue in object_key_issues(payload["objectKey"], str(path)))
            if "objects" in payload and isinstance(payload["objects"], list):
                keys = [item.get("objectKey", "") for item in payload["objects"] if isinstance(item, dict)]
                issues.extend(validate_r2_object_keys(keys))
        expected_valid = value.get("expectedValid")
        expected_codes = value.get("expectedIssueCodes", [])
        if expected_valid is False:
            missing_codes = [code for code in expected_codes if not any(code in issue for issue in issues)]
            return {
                "target": str(path),
                "valid": bool(issues) and not missing_codes,
                "issues": [] if bool(issues) and not missing_codes else [f"negative fixture missing expected issue codes {missing_codes or expected_codes}"],
            }
        if expected_valid is True:
            return {"target": str(path), "valid": not issues, "issues": issues}
    return {"target": str(path), "valid": not issues, "issues": issues}


def merge_results(results: list[dict[str, Any]]) -> dict[str, Any]:
    flattened: list[dict[str, Any]] = []
    for result in results:
        flattened.extend(result.get("results", []))
    return _summary(flattened)


def _summary(results: list[dict[str, Any]]) -> dict[str, Any]:
    failed = [result for result in results if not result["valid"]]
    return {
        "valid": not failed,
        "auditedCount": len(results),
        "failedCount": len(failed),
        "results": results,
    }
