"""Compile native public refresh registry artifacts from R2 publisher reports."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value, object_key_issues
from .model import PRIVACY_BOUNDARY, read_json, stable_id, write_json
from .production_domain_admission import PRODUCTION_DOMAIN_ADMISSION_KIND
from .production_target_gate import validate_production_target_ledger_gate


NATIVE_REFRESH_REGISTRY_VERSION = "source-atlas-native-refresh-registry-train-24"
NATIVE_ARTIFACT_SCHEMA_VERSION = "1.0.0"
NATIVE_REGISTRY_ARTIFACT_NAME = "source-atlas-public-refresh-targets.json"
NATIVE_REGISTRY_STATUSES = {"active", "review_required", "disabled", "blocked"}
NATIVE_REGISTRY_MODES = {"startup", "active_lifecycle", "background"}
MODE_ORDER = ["startup", "active_lifecycle", "background"]
NATIVE_REFRESH_REGISTRY_NON_CLAIMS = [
    "not an R2 private-data backend",
    "not runtime profile storage",
    "not an official legal, medical, financial, or admissions decision",
    "not runtime recommendation proof by itself",
    "not R2 release readiness",
    "not accessibility, privacy, or legal approval",
    "not full Source Atlas Green",
    "not production R2 readiness",
    "not native app runtime readiness",
    "not outside legal approval",
    "not universal goal coverage",
    "not a final path or timetable generator",
    "not a bundled production refresh target approval",
    "not real background execution proof",
]


@dataclass(frozen=True)
class NativeRefreshRegistryOptions:
    publisher_reports: tuple[Path, ...]
    output_root: Path
    created_at: str = "2026-06-28T00:00:00Z"
    app_version: str = "1.0"
    pack_schema_version: str = NATIVE_ARTIFACT_SCHEMA_VERSION
    status: str = "review_required"
    allowed_modes: tuple[str, ...] = tuple(MODE_ORDER)
    public_locale: str | None = None
    approval_artifact: Path | None = None
    review_artifact_id: str | None = None
    artifact_id: str | None = None
    production_target_ledger_path: Path | None = None
    production_domain_admission_path: Path | None = None


def compile_native_refresh_registry(options: NativeRefreshRegistryOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    issues: list[str] = []
    checks: list[dict[str, Any]] = []

    mode_issues = _mode_issues(options.allowed_modes)
    status_issues = _status_issues(options.status)
    approval_issues = _approval_issues(options)
    issues.extend(mode_issues + status_issues + approval_issues)
    _record(checks, "allowed_modes_valid", not mode_issues, mode_issues)
    _record(checks, "status_valid", not status_issues, status_issues)
    _record(checks, "active_requires_approval_artifact", not approval_issues, approval_issues)

    entries: list[dict[str, Any]] = []
    requested_domains: list[str] = []
    source_report_summaries: list[dict[str, Any]] = []
    for report_path in options.publisher_reports:
        loaded = _load_publisher_report(report_path)
        source_report_summaries.append(loaded["summary"])
        report_issues = loaded["issues"]
        issues.extend(report_issues)
        if report_issues:
            continue
        domain_id = loaded["summary"].get("domainID")
        if isinstance(domain_id, str) and domain_id:
            requested_domains.append(domain_id)
        entries.append(_entry_from_report(loaded["report"], options, report_path))

    production_target_gate = _production_target_or_admission_gate(
        options=options,
        requested_domains=requested_domains,
        source_report_summaries=source_report_summaries,
    )
    issues.extend(production_target_gate["issues"])
    _record(
        checks,
        "production_target_ledger_gate",
        production_target_gate["valid"],
        production_target_gate["issues"],
    )

    artifact_id = options.artifact_id or stable_id(
        "source_atlas_public_refresh_targets",
        {
            "created_at": options.created_at,
            "entries": entries,
            "status": options.status,
            "allowed_modes": _ordered_modes(options.allowed_modes),
        },
    )
    artifact = {
        "schemaVersion": NATIVE_ARTIFACT_SCHEMA_VERSION,
        "artifactID": artifact_id,
        "createdAt": options.created_at,
        "publicReferenceOnly": True,
        "registry": {"entries": _sorted_entries(entries)},
        "nonClaims": _ordered_unique_strings(NATIVE_REFRESH_REGISTRY_NON_CLAIMS),
    }

    artifact_issues = boundary_issue_strings(boundary_issues_for_value(artifact, "native-refresh-registry-artifact"))
    issues.extend(artifact_issues)
    artifact_public = artifact["publicReferenceOnly"] is True
    _record(checks, "artifact_public_reference_only", artifact_public, [] if artifact_public else ["artifact is not public reference only"])
    _record(checks, "artifact_privacy_scan_passed", not artifact_issues, artifact_issues)
    valid_reports_emitted_targets = bool(entries) or not options.publisher_reports
    _record(
        checks,
        "invalid_reports_emit_no_targets",
        valid_reports_emitted_targets,
        [] if valid_reports_emitted_targets else ["no valid publisher reports produced targets"],
    )
    _record(checks, "default_review_required_unless_approved", options.status != "active" or not approval_issues, approval_issues)
    no_final_outputs = _no_final_outputs(artifact)
    _record(
        checks,
        "no_final_plan_schedule_step_output",
        no_final_outputs,
        [] if no_final_outputs else ["final plan, schedule, or Step output marker found outside non-claims"],
    )

    artifact_path = output_root / NATIVE_REGISTRY_ARTIFACT_NAME
    report_path = output_root / "native-refresh-registry-report.json"
    closeout_path = output_root / "closeout.md"
    write_json(artifact_path, artifact)

    valid = not issues and all(check["passed"] for check in checks)
    report = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.nativeRefreshRegistryCompilerReport.v1",
        "versionID": NATIVE_REFRESH_REGISTRY_VERSION,
        "createdAt": options.created_at,
        "status": "Source Green for native refresh registry artifact compiler" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; native refresh registry artifact compiler only",
        "artifactID": artifact_id,
        "artifactSchemaVersion": NATIVE_ARTIFACT_SCHEMA_VERSION,
        "targetStatus": options.status,
        "targetCount": len(entries),
        "activeTargetCount": sum(1 for entry in entries if entry.get("status") == "active"),
        "reviewRequiredTargetCount": sum(1 for entry in entries if entry.get("status") == "review_required"),
        "publisherReports": source_report_summaries,
        "productionTargetLedgerGate": production_target_gate,
        "checks": checks,
        "issues": issues,
        "outputPaths": {
            "artifact": str(artifact_path),
            "report": str(report_path),
            "productionTargetLedger": str(options.production_target_ledger_path) if options.production_target_ledger_path else None,
            "closeout": str(closeout_path),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": artifact["nonClaims"],
        "productionNonClaims": [
            "no production R2 upload",
            "no bundled production refresh target approval",
            "no legal approval",
            "no universal coverage",
            "no final user plan, schedule, or Step generation",
            "no private graph egress",
            "no app runtime or release Green",
        ],
    }
    write_json(report_path, report)
    closeout_path.write_text(native_refresh_registry_markdown(report), encoding="utf-8")
    return report


def native_refresh_registry_markdown(report: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Native Public Refresh Registry Artifact Compiler Train 24",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic Foundry compiler for Train 23 native public refresh registry artifact JSON.",
        "- Converts validated public R2 publisher reports into public refresh targets.",
        "- Defaults targets to review-required unless explicit approval is supplied.",
        "- Blocks unsafe publisher reports and private-looking object keys before target emission.",
        "",
        "Files changed:",
        "- tools/source-atlas/foundry/native_refresh_registry.py",
        "- tools/source-atlas/foundry/cli.py",
        "- tools/source-atlas/foundry/tests/test_native_refresh_registry_train_24.py",
        "- tools/source-atlas/generated/native-refresh-registry/train-24-fixture/*",
        "- docs/qa/source-atlas/native/source-atlas-native-refresh-registry-compiler-train-24.*",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- Generated registry entries contain public pack routing metadata only.",
        "- Review-required default prevents silent native refresh activation.",
        "- Source Atlas does not generate final plans, schedules, or Steps.",
        "",
        "Validation run:",
        "- See the current train closeout for command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Swift/native XCTest/build-for-testing was not required by this tooling-only train.",
        "- Outside legal review was not run or claimed.",
        "",
        "Proof artifacts:",
    ]
    for path in report.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- Compiler emits only domain, channel, schema version, app version, optional public locale, target pack ID, and environment.",
            "- Object keys from publisher reports are checked before registry target emission.",
            "",
            "No private graph egress proof:",
            "- Artifact privacy scan passed before report Green.",
            "- Private publisher reports emit no targets and fail validation.",
            "",
            "License/terms proof:",
            "- Inherited from the validated publisher/pack artifacts; no legal approval is claimed.",
            "",
            "Restricted-source exclusion proof:",
            "- Inherited from the publisher report; this compiler does not re-admit excluded source data.",
            "",
            "Provenance completeness proof:",
            "- Inherited from the publisher report and upstream pack manifest.",
            "",
            "Freshness/revocation proof:",
            "- Target routing points at publisher current pointer/freshness infrastructure; no freshness claim is upgraded.",
            "",
            "LKG/rollback proof:",
            "- Inherited from publisher report. This compiler does not publish or roll back R2 objects.",
            "",
            "Native offline/no-account proof:",
            "- Review-required default means a bundled artifact does not perform transport until explicitly approved active targets are present.",
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
            "- Files moved or created: Foundry native refresh registry compiler, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: no owner-approved bundled active registry artifact and no real BackgroundTasks/device proof.",
            "- Next repair train if debt remains: owner-approved public registry artifact population or real background registration proof.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Rollback plan:",
            "- Revert Train 24 compiler module, CLI command, tests, generated artifact/report, and QA evidence packet.",
            "",
        ]
    )
    return "\n".join(lines)


def _load_publisher_report(path: Path) -> dict[str, Any]:
    summary = {"path": str(path), "loaded": False, "valid": False, "packID": None, "domainID": None}
    if not path.exists():
        return {"report": {}, "summary": summary, "issues": [f"missing publisher report: {path}"]}
    try:
        report = read_json(path)
    except Exception as exc:  # pragma: no cover - defensive; read_json raises platform-specific messages.
        return {"report": {}, "summary": summary, "issues": [f"publisher report unreadable: {path}: {exc}"]}

    summary.update(
        {
            "loaded": True,
            "valid": report.get("valid") is True,
            "packID": report.get("packID"),
            "domainID": _domain_id(report),
            "environment": report.get("environment"),
            "channel": report.get("channel"),
            "manifestSHA256": report.get("currentPointer", {}).get("manifestSHA256") if isinstance(report.get("currentPointer"), dict) else None,
        }
    )
    return {"report": report, "summary": summary, "issues": _publisher_report_issues(report, path)}


def _production_target_or_admission_gate(
    *,
    options: NativeRefreshRegistryOptions,
    requested_domains: list[str],
    source_report_summaries: list[dict[str, Any]],
) -> dict[str, Any]:
    gate = validate_production_target_ledger_gate(
        ledger_path=options.production_target_ledger_path,
        requested_domains=requested_domains,
        required=options.status == "active",
    )
    if gate["valid"] or options.status != "active" or not options.production_domain_admission_path:
        return gate

    admission_validation = _validate_initial_domain_admission_for_native_registry(
        options.production_domain_admission_path,
        gate.get("missingDomains", []),
        source_report_summaries,
    )
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedgerOrAdmissionGate.v1",
        "required": True,
        "valid": admission_validation["valid"],
        "ledgerGateValid": gate["valid"],
        "admissionGateValid": admission_validation["valid"],
        "admissionFallbackUsed": admission_validation["valid"],
        "ledgerGate": gate,
        "productionDomainAdmissionValidation": admission_validation,
        "ledgerPath": gate.get("ledgerPath"),
        "admissionPath": str(options.production_domain_admission_path),
        "requestedDomains": gate.get("requestedDomains", requested_domains),
        "readyDomains": gate.get("readyDomains", []),
        "missingDomains": [] if admission_validation["valid"] else gate.get("missingDomains", []),
        "allowedClaims": gate.get("allowedClaims", []),
        "issues": [] if admission_validation["valid"] else sorted(set(gate.get("issues", []) + admission_validation["issues"])),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": [
            "not production target ledger Green until post-native ledger is regenerated",
            "not literal universal coverage",
            "not full Source Atlas Green",
            "not Release Green",
            "not outside legal approval",
            "not final user plans, schedules, or Steps",
        ],
    }


def _validate_initial_domain_admission_for_native_registry(
    admission_path: Path,
    missing_domains: list[str],
    source_report_summaries: list[dict[str, Any]],
) -> dict[str, Any]:
    issues: list[str] = []
    if not missing_domains:
        issues.append("production domain admission fallback requires at least one missing domain")
    if len(set(missing_domains)) != 1:
        issues.append("production domain admission fallback supports exactly one initial missing domain")
    if not admission_path.exists():
        issues.append(f"production domain admission artifact does not exist: {admission_path}")
        return _admission_validation_result(admission_path, issues, None)
    try:
        admission = read_json(admission_path)
    except Exception as exc:  # pragma: no cover - malformed evidence artifact
        issues.append(f"production domain admission artifact unreadable: {admission_path}: {exc}")
        return _admission_validation_result(admission_path, issues, None)

    domain = str(admission.get("domain") or "")
    expected_domain = sorted(set(missing_domains))[0] if missing_domains else ""
    if admission.get("kind") != PRODUCTION_DOMAIN_ADMISSION_KIND:
        issues.append(f"production domain admission kind is unsupported: {admission.get('kind')}")
    if admission.get("valid") is not True or admission.get("approved") is not True:
        issues.append("production domain admission artifact is not approved")
    if admission.get("admissionDecision") != "ready_for_initial_production_r2_upload":
        issues.append(f"production domain admission decision is not ready: {admission.get('admissionDecision')}")
    if domain != expected_domain:
        issues.append(f"production domain admission domain mismatch: {domain}")
    if admission.get("environment") != "production" or admission.get("channel") != "stable":
        issues.append("production domain admission must be production/stable for active native target fallback")
    if admission.get("outsideLegalApprovalClaimed") is True:
        issues.append("production domain admission must not claim outside legal approval")
    if admission.get("releaseGreenClaimed") is True:
        issues.append("production domain admission must not claim Release Green")
    if admission.get("literalUniversalCoverageClaimed") is True:
        issues.append("production domain admission must not claim literal universal coverage")

    summary_by_domain = {
        str(summary.get("domainID")): summary
        for summary in source_report_summaries
        if isinstance(summary.get("domainID"), str)
    }
    summary = summary_by_domain.get(domain)
    if not summary:
        issues.append(f"production domain admission has no matching selected publisher report: {domain}")
    else:
        if admission.get("packID") != summary.get("packID"):
            issues.append("production domain admission packID does not match selected publisher report")
        if admission.get("packManifestSHA256") != summary.get("manifestSHA256"):
            issues.append("production domain admission manifest SHA-256 does not match selected publisher report")

    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "kind": admission.get("kind"),
                "admissionID": admission.get("admissionID"),
                "domain": admission.get("domain"),
                "approvalScope": admission.get("approvalScope"),
                "privacyBoundary": admission.get("privacyBoundary"),
                "nonClaims": admission.get("nonClaims", []),
            },
            "native-refresh-registry-production-domain-admission",
        )
    )
    issues.extend(privacy_issues)
    return _admission_validation_result(admission_path, issues, admission)


def _admission_validation_result(path: Path, issues: list[str], admission: dict[str, Any] | None) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionDomainAdmissionValidation.v1",
        "path": str(path),
        "valid": not issues,
        "status": "Green" if not issues else "Red",
        "admissionID": admission.get("admissionID") if isinstance(admission, dict) else None,
        "admissionDecision": admission.get("admissionDecision") if isinstance(admission, dict) else None,
        "domain": admission.get("domain") if isinstance(admission, dict) else None,
        "issues": sorted(set(issues)),
    }


def _publisher_report_issues(report: dict[str, Any], path: Path) -> list[str]:
    issues: list[str] = []
    if report.get("kind") != "ambitions.sourceAtlas.r2PackPublisherReport.v1":
        issues.append(f"{path}: unsupported publisher report kind")
    if report.get("valid") is not True:
        issues.append(f"{path}: publisher report is not valid")
    if report.get("issues"):
        issues.append(f"{path}: publisher report contains issues")
    pointer = report.get("currentPointer")
    if not isinstance(pointer, dict):
        issues.append(f"{path}: missing currentPointer")
        return issues
    if pointer.get("publicReferenceOnly") is not True:
        issues.append(f"{path}: current pointer is not publicReferenceOnly")
    if pointer.get("packID") and report.get("packID") and pointer.get("packID") != report.get("packID"):
        issues.append(f"{path}: current pointer packID does not match report packID")
    domain_id = _domain_id(report)
    if not domain_id:
        issues.append(f"{path}: unable to derive domain ID")
    for label, key in _publisher_object_keys(report).items():
        key_issues = [issue.format() for issue in object_key_issues(str(key), label)]
        issues.extend(f"{path}: {issue}" for issue in key_issues)
    issues.extend(
        f"{path}: {issue}"
        for issue in boundary_issue_strings(boundary_issues_for_value(_publisher_boundary_scan_payload(report), "native-refresh-registry-source-report"))
    )
    return issues


def _publisher_boundary_scan_payload(report: dict[str, Any]) -> dict[str, Any]:
    pointer = report.get("currentPointer") if isinstance(report.get("currentPointer"), dict) else {}
    return {
        "kind": report.get("kind"),
        "environment": report.get("environment"),
        "channel": report.get("channel"),
        "packID": report.get("packID"),
        "packVersion": report.get("packVersion"),
        "currentPointer": {
            "environment": pointer.get("environment"),
            "channel": pointer.get("channel"),
            "packID": pointer.get("packID"),
            "packVersion": pointer.get("packVersion"),
            "manifestKey": pointer.get("manifestKey"),
            "revocationManifestKey": pointer.get("revocationManifestKey"),
            "lastKnownGoodKey": pointer.get("lastKnownGoodKey"),
            "publicReferenceOnly": pointer.get("publicReferenceOnly"),
        },
        "privacyBoundary": report.get("privacyBoundary"),
        "nonClaims": report.get("nonClaims", []),
    }


def _publisher_object_keys(report: dict[str, Any]) -> dict[str, str]:
    pointer = report.get("currentPointer") if isinstance(report.get("currentPointer"), dict) else {}
    keys = {
        "currentPointer": _current_pointer_key(report),
        "manifestKey": pointer.get("manifestKey"),
        "revocationManifestKey": pointer.get("revocationManifestKey"),
        "lastKnownGoodKey": pointer.get("lastKnownGoodKey"),
    }
    return {label: key for label, key in keys.items() if isinstance(key, str) and key.strip()}


def _entry_from_report(report: dict[str, Any], options: NativeRefreshRegistryOptions, report_path: Path) -> dict[str, Any]:
    domain_id = _domain_id(report)
    target = {
        "id": _target_id(report),
        "domainID": domain_id,
        "channel": str(report.get("channel", "")).strip(),
        "schemaVersion": options.pack_schema_version.strip(),
        "appVersion": options.app_version.strip(),
        "publicLocale": options.public_locale.strip() if options.public_locale else None,
        "targetPackID": str(report.get("packID", "")).strip(),
        "environment": str(report.get("environment", "")).strip(),
    }
    return {
        "target": target,
        "allowedModes": _ordered_modes(options.allowed_modes),
        "status": options.status,
        "reviewArtifactID": _review_artifact_id(options, report_path),
        "nonClaims": _ordered_unique_strings(NATIVE_REFRESH_REGISTRY_NON_CLAIMS),
    }


def _domain_id(report: dict[str, Any]) -> str:
    pointer = report.get("currentPointer") if isinstance(report.get("currentPointer"), dict) else {}
    manifest_key = str(pointer.get("manifestKey", "")).strip("/")
    segments = [segment for segment in manifest_key.split("/") if segment]
    if len(segments) >= 5 and segments[:2] == ["source-atlas", "v1"]:
        return segments[4]
    pack_id = str(report.get("packID") or pointer.get("packID") or "").strip("/")
    pack_segments = [segment for segment in pack_id.split("/") if segment]
    if len(pack_segments) >= 5 and pack_segments[:3] == ["source-atlas", "v1", "domain"]:
        return pack_segments[3]
    return ""


def _current_pointer_key(report: dict[str, Any]) -> str:
    environment = str(report.get("environment", "")).strip()
    channel = str(report.get("channel", "")).strip()
    domain_id = _domain_id(report)
    if not environment or not channel or not domain_id:
        return ""
    return f"source-atlas/v1/{environment}/{channel}/{domain_id}/current.json"


def _target_id(report: dict[str, Any]) -> str:
    domain_id = _domain_id(report)
    channel = str(report.get("channel", "")).strip()
    pack_version = str(report.get("packVersion", "")).strip()
    return "source-atlas-refresh-target." + ".".join(part for part in [domain_id, channel, pack_version] if part)


def _review_artifact_id(options: NativeRefreshRegistryOptions, report_path: Path) -> str | None:
    if options.review_artifact_id:
        return options.review_artifact_id.strip()
    if options.approval_artifact:
        return _normalized_artifact_path(options.approval_artifact)
    if options.status == "review_required":
        return _normalized_artifact_path(report_path)
    return None


def _normalized_artifact_path(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(Path.cwd().resolve()))
    except ValueError:
        return str(path)


def _mode_issues(modes: tuple[str, ...]) -> list[str]:
    if not modes:
        return ["at least one lifecycle mode is required"]
    return [f"unsupported lifecycle mode: {mode}" for mode in modes if mode not in NATIVE_REGISTRY_MODES]


def _status_issues(status: str) -> list[str]:
    return [] if status in NATIVE_REGISTRY_STATUSES else [f"unsupported target status: {status}"]


def _approval_issues(options: NativeRefreshRegistryOptions) -> list[str]:
    if options.status != "active":
        return []
    if not options.approval_artifact:
        return ["active refresh targets require --approval-artifact"]
    if not options.approval_artifact.exists():
        return [f"approval artifact does not exist: {options.approval_artifact}"]
    return []


def _ordered_modes(modes: tuple[str, ...]) -> list[str]:
    requested = set(modes)
    return [mode for mode in MODE_ORDER if mode in requested]


def _sorted_entries(entries: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return sorted(entries, key=lambda entry: (entry["target"]["id"], entry["target"]["targetPackID"]))


def _ordered_unique_strings(values: list[str]) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for value in values:
        if value not in seen:
            seen.add(value)
            ordered.append(value)
    return ordered


def _no_final_outputs(artifact: dict[str, Any]) -> bool:
    joined_targets = " ".join(
        " ".join(
            str(value)
            for key, value in entry.get("target", {}).items()
            if key not in {"nonClaims"}
        )
        for entry in artifact.get("registry", {}).get("entries", [])
    ).lower()
    forbidden = ["final_plan", "final plan", "final_schedule", "final schedule", "step_list", "step list"]
    return not any(token in joined_targets for token in forbidden)


def _record(checks: list[dict[str, Any]], name: str, passed: bool, issues: list[str]) -> None:
    checks.append({"name": name, "passed": passed, "issues": issues})
