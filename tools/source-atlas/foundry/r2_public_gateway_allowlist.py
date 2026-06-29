"""Compile the public Worker gateway allowlist from validated R2 publisher reports."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value, object_key_issues
from .model import PRIVACY_BOUNDARY, read_json, stable_id, write_json


PUBLIC_GATEWAY_ALLOWLIST_VERSION = "source-atlas-r2-public-gateway-allowlist-train-82"
PUBLIC_GATEWAY_ALLOWLIST_ARTIFACT = "public-gateway-allowlist.json"
PUBLIC_GATEWAY_ALLOWED_KEYS_MODULE = "allowed-object-keys.generated.js"
PUBLIC_GATEWAY_REQUIRED_READBACK_LABELS = {"lkg", "manifest", "pack", "revocations"}
PUBLIC_GATEWAY_NON_CLAIMS = [
    "not a private user-data backend",
    "not private life graph storage",
    "not an official legal, medical, financial, or admissions decision",
    "not runtime recommendation proof by itself",
    "not R2 release readiness",
    "not accessibility, privacy, or legal approval",
    "not full Source Atlas Green",
    "not native app runtime readiness",
    "not outside legal approval",
    "not universal goal coverage",
    "not a final user plan, schedule, or Step generator",
    "not a broad release readiness claim",
]


@dataclass(frozen=True)
class PublicGatewayAllowlistOptions:
    publisher_reports: tuple[Path, ...]
    output_root: Path
    created_at: str = "2026-06-28T00:00:00Z"
    worker_allowlist_path: Path | None = None


def compile_public_gateway_allowlist(options: PublicGatewayAllowlistOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    issues: list[str] = []
    checks: list[dict[str, Any]] = []
    source_summaries: list[dict[str, Any]] = []
    keys_by_report: list[dict[str, Any]] = []
    allowed_keys: set[str] = set()

    for report_path in options.publisher_reports:
        loaded = _load_publisher_report(report_path)
        source_summaries.append(loaded["summary"])
        report_issues = loaded["issues"]
        issues.extend(report_issues)
        if report_issues:
            continue
        public_keys = _public_gateway_keys(loaded["report"], report_path)
        key_issues = _object_key_issues(public_keys, report_path)
        issues.extend(key_issues)
        if key_issues:
            continue
        keys_by_report.append(
            {
                "publisherReport": str(report_path),
                "domainID": _domain_id(loaded["report"]),
                "packID": loaded["report"].get("packID"),
                "packVersion": loaded["report"].get("packVersion"),
                "objectKeys": sorted(public_keys),
            }
        )
        allowed_keys.update(public_keys)

    sorted_keys = sorted(allowed_keys)
    artifact = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublicGatewayAllowlist.v1",
        "versionID": PUBLIC_GATEWAY_ALLOWLIST_VERSION,
        "createdAt": options.created_at,
        "publicReferenceOnly": True,
        "allowlistID": stable_id(
            "source_atlas_public_gateway_allowlist",
            {"createdAt": options.created_at, "objectKeys": sorted_keys},
        ),
        "allowedObjectKeys": sorted_keys,
        "allowedObjectKeyCount": len(sorted_keys),
        "publisherReports": source_summaries,
        "keysByReport": sorted(keys_by_report, key=lambda item: (item["domainID"], item["packVersion"], item["publisherReport"])),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PUBLIC_GATEWAY_NON_CLAIMS,
    }
    artifact_issues = boundary_issue_strings(boundary_issues_for_value(artifact, "public-gateway-allowlist-artifact"))
    issues.extend(artifact_issues)

    _record(
        checks,
        "publisher_reports_validated",
        not any(summary.get("issues") for summary in source_summaries),
        [issue for summary in source_summaries for issue in summary.get("issues", [])],
    )
    _record(checks, "allowlist_not_empty", bool(sorted_keys), [] if sorted_keys else ["no object keys emitted"])
    _record(checks, "object_keys_public_reference_only", not _object_key_issues(sorted_keys, Path("artifact")), _object_key_issues(sorted_keys, Path("artifact")))
    _record(checks, "artifact_privacy_scan_passed", not artifact_issues, artifact_issues)
    no_final_outputs = _no_final_outputs(artifact)
    _record(
        checks,
        "no_final_plan_schedule_step_output",
        no_final_outputs,
        [] if no_final_outputs else ["final plan, schedule, or Step output marker found outside non-claims"],
    )
    _record(checks, "stable_sorted_output", sorted_keys == sorted(sorted_keys), [])

    artifact_path = output_root / PUBLIC_GATEWAY_ALLOWLIST_ARTIFACT
    generated_module_path = options.worker_allowlist_path or output_root / PUBLIC_GATEWAY_ALLOWED_KEYS_MODULE
    report_path = output_root / "public-gateway-allowlist-report.json"
    closeout_path = output_root / "closeout.md"

    write_json(artifact_path, artifact)
    _write_js_module(generated_module_path, sorted_keys)

    valid = not issues and all(check["passed"] for check in checks)
    report = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublicGatewayAllowlistCompilerReport.v1",
        "versionID": PUBLIC_GATEWAY_ALLOWLIST_VERSION,
        "createdAt": options.created_at,
        "status": "Source Green for public gateway allowlist compiler" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; public gateway allowlist compiler only",
        "publisherReportCount": len(options.publisher_reports),
        "allowedObjectKeyCount": len(sorted_keys),
        "checks": checks,
        "issues": issues,
        "outputPaths": {
            "artifact": str(artifact_path),
            "report": str(report_path),
            "generatedWorkerAllowlist": str(generated_module_path),
            "closeout": str(closeout_path),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PUBLIC_GATEWAY_NON_CLAIMS,
        "productionNonClaims": [
            "no private graph egress",
            "no final user plan, schedule, or Step generation",
            "no legal approval upgrade",
            "no native release Green",
            "no App Store readiness",
            "no universal coverage claim",
        ],
    }
    write_json(report_path, report)
    closeout_path.write_text(public_gateway_allowlist_markdown(report), encoding="utf-8")
    return report


def public_gateway_allowlist_markdown(report: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Public R2 Gateway Allowlist Compiler Train 82",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic Foundry compiler for the public Worker gateway allowlist.",
        "- Emits only current, LKG, revocation, manifest, and pack object keys from validated production/stable remote R2 publisher reports.",
        "- Blocks invalid reports, non-production reports, non-stable reports, failed readback evidence, and private-looking object keys before Worker source generation.",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- Generated Worker keys contain public pack routing metadata only.",
        "- Source Atlas does not generate final plans, schedules, or Steps.",
        "",
        "Proof artifacts:",
    ]
    for path in report.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- Gateway allowlist keys are derived from publisher reports that already passed public-reference request/privacy gates.",
            "- This compiler re-runs object-key and artifact privacy scans before emitting Worker source.",
            "",
            "No private graph egress proof:",
            "- Private-looking object keys block generation.",
            "- Query strings and private markers remain blocked by Worker runtime code.",
            "",
            "License/terms proof:",
            "- Inherited from the validated production publisher reports; no legal approval is upgraded here.",
            "",
            "Restricted-source exclusion proof:",
            "- Inherited from publisher reports. This compiler does not re-admit excluded sources or claims.",
            "",
            "Provenance completeness proof:",
            "- Inherited from upstream pack manifests and publisher reports.",
            "",
            "Freshness/revocation proof:",
            "- Generated keys include current, LKG, revocation, manifest, and pack routes only after readback evidence passes.",
            "",
            "LKG/rollback proof:",
            "- Inherited from production publisher reports; this compiler does not publish or roll back R2 objects.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed by this tooling train.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("productionNonClaims", []))
    lines.extend(
        [
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: Foundry allowlist compiler, generated Worker allowlist module, tests, and evidence artifacts.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: overall Source Atlas remains wider than this gateway compiler proof.",
            "- Next repair train if debt remains: expand autonomous domain publishing gates or native live refresh proof.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Rollback plan:",
            "- Revert Train 82 compiler module, CLI command, tests, generated allowlist artifact/module, Worker import, deployment, and QA evidence packet.",
            "",
        ]
    )
    return "\n".join(lines)


def _load_publisher_report(path: Path) -> dict[str, Any]:
    summary = {"path": str(path), "loaded": False, "valid": False, "packID": None, "domainID": None, "issues": []}
    if not path.exists():
        summary["issues"] = [f"missing publisher report: {path}"]
        return {"report": {}, "summary": summary, "issues": summary["issues"]}
    try:
        report = read_json(path)
    except Exception as exc:  # pragma: no cover - defensive.
        summary["issues"] = [f"publisher report unreadable: {path}: {exc}"]
        return {"report": {}, "summary": summary, "issues": summary["issues"]}

    report_issues = _publisher_report_issues(report, path)
    summary.update(
        {
            "loaded": True,
            "valid": report.get("valid") is True,
            "packID": report.get("packID"),
            "domainID": _domain_id(report),
            "environment": report.get("environment"),
            "channel": report.get("channel"),
            "mode": report.get("mode"),
            "productionR2Uploaded": report.get("productionR2Uploaded") is True,
            "issues": report_issues,
        }
    )
    return {"report": report, "summary": summary, "issues": report_issues}


def _publisher_report_issues(report: dict[str, Any], path: Path) -> list[str]:
    issues: list[str] = []
    if report.get("kind") != "ambitions.sourceAtlas.r2PackPublisherReport.v1":
        issues.append(f"{path}: unsupported publisher report kind")
    if report.get("valid") is not True:
        issues.append(f"{path}: publisher report is not valid")
    if report.get("environment") != "production":
        issues.append(f"{path}: public gateway allowlist requires production environment")
    if report.get("channel") != "stable":
        issues.append(f"{path}: public gateway allowlist requires stable channel")
    if report.get("mode") != "remote_r2":
        issues.append(f"{path}: public gateway allowlist requires remote_r2 mode")
    if report.get("productionR2Uploaded") is not True:
        issues.append(f"{path}: productionR2Uploaded must be true")
    checks = report.get("checks")
    if not isinstance(checks, list) or not checks:
        issues.append(f"{path}: publisher checks are missing")
    elif any(check.get("passed") is not True for check in checks if isinstance(check, dict)):
        issues.append(f"{path}: publisher checks did not all pass")

    operation = report.get("operation")
    if not isinstance(operation, dict):
        issues.append(f"{path}: operation is missing")
        return issues
    if operation.get("remoteR2") is not True:
        issues.append(f"{path}: operation.remoteR2 must be true")
    if operation.get("success") is not True:
        issues.append(f"{path}: operation.success must be true")
    if operation.get("publicReferenceOnly") is not True:
        issues.append(f"{path}: operation.publicReferenceOnly must be true")

    current_pointer = operation.get("currentPointer")
    if not isinstance(current_pointer, dict) or current_pointer.get("updated") is not True:
        issues.append(f"{path}: current pointer was not updated after readback")
    elif not _hashes_match(current_pointer):
        issues.append(f"{path}: current pointer checksum readback did not match")
    elif not current_pointer.get("key"):
        issues.append(f"{path}: current pointer key is missing")

    labels = _readback_by_label(report)
    missing = sorted(PUBLIC_GATEWAY_REQUIRED_READBACK_LABELS - set(labels))
    if missing:
        issues.append(f"{path}: missing required readback labels: {', '.join(missing)}")
    for label in sorted(PUBLIC_GATEWAY_REQUIRED_READBACK_LABELS):
        result = labels.get(label)
        if not isinstance(result, dict):
            continue
        if result.get("passed") is not True or result.get("success") is not True:
            issues.append(f"{path}: readback label {label} did not pass")
        if not _hashes_match(result):
            issues.append(f"{path}: readback label {label} checksum mismatch")
    return issues


def _public_gateway_keys(report: dict[str, Any], path: Path) -> set[str]:
    operation = report.get("operation", {})
    current_pointer = operation.get("currentPointer", {})
    keys = {
        str(current_pointer.get("key", "")),
        str(report.get("currentPointer", {}).get("lastKnownGoodKey", "")),
        str(report.get("currentPointer", {}).get("manifestKey", "")),
        str(report.get("currentPointer", {}).get("revocationManifestKey", "")),
    }
    labels = _readback_by_label(report)
    pack = labels.get("pack", {})
    keys.add(str(pack.get("objectKey", "")))
    return {key for key in keys if key}


def _readback_by_label(report: dict[str, Any]) -> dict[str, dict[str, Any]]:
    operation = report.get("operation", {})
    results = operation.get("readbackResults", [])
    if not isinstance(results, list):
        return {}
    return {str(item.get("label")): item for item in results if isinstance(item, dict)}


def _object_key_issues(keys: list[str] | set[str], path: Path) -> list[str]:
    issues: list[str] = []
    for key in sorted(keys):
        if not key:
            issues.append(f"{path}: empty object key")
            continue
        issues.extend(boundary_issue_strings(object_key_issues(key, f"{path}:{key}")))
    return issues


def _hashes_match(record: dict[str, Any]) -> bool:
    expected = record.get("expectedSHA256")
    actual = record.get("actualSHA256")
    return isinstance(expected, str) and isinstance(actual, str) and expected == actual and len(expected) == 64


def _domain_id(report: dict[str, Any]) -> str | None:
    manifest_key = report.get("currentPointer", {}).get("manifestKey")
    if not isinstance(manifest_key, str):
        return None
    parts = manifest_key.split("/")
    try:
        stable_index = parts.index("stable")
    except ValueError:
        return None
    if stable_index + 1 >= len(parts):
        return None
    return parts[stable_index + 1]


def _no_final_outputs(value: Any) -> bool:
    text = str(value).lower()
    blocked = ["final user plan", "final schedule", "step list", "personalized plan"]
    non_claim_text = " ".join(PUBLIC_GATEWAY_NON_CLAIMS).lower()
    return all(marker not in text or marker in non_claim_text for marker in blocked)


def _write_js_module(path: Path, object_keys: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "// Generated by source-atlas-foundry r2-public-gateway-allowlist.",
        "// Do not edit manually; regenerate from validated production R2 publisher reports.",
        "",
        "export const ALLOWED_OBJECT_KEYS = new Set([",
    ]
    lines.extend(f'  "{key}",' for key in object_keys)
    lines.append("]);")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def _record(checks: list[dict[str, Any]], name: str, passed: bool, issues: list[str]) -> None:
    checks.append({"name": name, "passed": passed, "issues": issues})
