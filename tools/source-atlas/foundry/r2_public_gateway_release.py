"""Orchestrate public Worker gateway allowlist release from publisher evidence."""

from __future__ import annotations

import hashlib
import re
import subprocess
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import PRIVACY_BOUNDARY, read_json, write_json
from .r2_public_gateway_allowlist import (
    PUBLIC_GATEWAY_NON_CLAIMS,
    PublicGatewayAllowlistOptions,
    compile_public_gateway_allowlist,
)
from .production_domain_admission import PRODUCTION_DOMAIN_ADMISSION_KIND
from .production_target_gate import validate_production_target_ledger_gate


PUBLIC_GATEWAY_RELEASE_VERSION = "source-atlas-r2-public-gateway-release-train-83"
DEFAULT_GATEWAY_BASE_URL = "https://ambitions-source-atlas-public-gateway.devanwarner.workers.dev"


@dataclass(frozen=True)
class PublicGatewayReleaseOptions:
    publisher_report_root: Path
    output_root: Path
    created_at: str = "2026-06-28T00:00:00Z"
    worker_allowlist_path: Path | None = None
    worker_config_path: Path | None = None
    base_url: str = DEFAULT_GATEWAY_BASE_URL
    deploy: bool = False
    execute: bool = False
    verify_live: bool = False
    production_target_ledger_path: Path | None = None
    production_domain_admission_path: Path | None = None
    native_registry_artifact_path: Path | None = None


HttpRequestFn = Callable[[str, str], tuple[int, bytes, dict[str, str]]]


def run_public_gateway_release(options: PublicGatewayReleaseOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    issues: list[str] = []
    checks: list[dict[str, Any]] = []

    discovery = discover_production_publisher_reports(options.publisher_report_root)
    issues.extend(discovery["issues"])
    _record(checks, "publisher_report_discovery", not discovery["issues"], discovery["issues"])
    _record(
        checks,
        "eligible_reports_found",
        bool(discovery["selectedPublisherReports"]),
        [] if discovery["selectedPublisherReports"] else ["no eligible production/stable remote R2 publisher reports found"],
    )

    selected_domains = [
        str(item.get("domainID"))
        for item in discovery.get("selectedReports", [])
        if isinstance(item, dict) and isinstance(item.get("domainID"), str)
    ]
    production_target_gate = _production_target_or_admission_gate(
        options=options,
        requested_domains=selected_domains,
        selected_reports=discovery.get("selectedReports", []),
    )
    issues.extend(production_target_gate["issues"])
    _record(
        checks,
        "production_target_ledger_gate",
        production_target_gate["valid"],
        production_target_gate["issues"],
    )

    native_registry_gate = validate_native_registry_coherence(
        registry_path=options.native_registry_artifact_path,
        selected_reports=discovery.get("selectedReports", []),
    )
    issues.extend(native_registry_gate["issues"])
    _record(
        checks,
        "native_refresh_registry_coherence",
        native_registry_gate["valid"],
        native_registry_gate["issues"],
    )

    deploy_gate_issues = _deploy_gate_issues(options)
    issues.extend(deploy_gate_issues)
    _record(checks, "deploy_execute_gate", not deploy_gate_issues, deploy_gate_issues)

    allowlist_report = compile_public_gateway_allowlist(
        PublicGatewayAllowlistOptions(
            publisher_reports=tuple(Path(path) for path in discovery["selectedPublisherReports"]),
            output_root=output_root / "allowlist",
            created_at=options.created_at,
            worker_allowlist_path=options.worker_allowlist_path,
        )
    )
    if not allowlist_report.get("valid"):
        issues.extend(f"allowlist: {issue}" for issue in allowlist_report.get("issues", []))
    _record(
        checks,
        "allowlist_compiler_valid",
        allowlist_report.get("valid") is True,
        allowlist_report.get("issues", []),
    )

    deploy_report = _deploy_worker(options, output_root) if options.deploy and options.execute and not issues else _planned_deploy(options)
    if deploy_report.get("attempted") and not deploy_report.get("success"):
        issues.extend(deploy_report.get("issues", []))
    _record(
        checks,
        "worker_deploy",
        not deploy_report.get("attempted") or deploy_report.get("success") is True,
        deploy_report.get("issues", []),
    )

    live_verification: dict[str, Any] | None = None
    if options.verify_live and not issues:
        live_verification = verify_public_gateway(
            allowlist_path=Path(allowlist_report["outputPaths"]["artifact"]),
            publisher_reports=tuple(Path(path) for path in discovery["selectedPublisherReports"]),
            base_url=options.base_url,
            created_at=options.created_at,
            worker_version_id=deploy_report.get("workerVersionID"),
        )
        if not live_verification.get("valid"):
            issues.extend(live_verification.get("issues", []))
    elif options.verify_live:
        live_verification = _skipped_live_verification(options, issues)
    _record(
        checks,
        "live_gateway_verification",
        not options.verify_live or (live_verification or {}).get("valid") is True,
        [] if not options.verify_live else (live_verification or {}).get("issues", []),
    )

    live_path = output_root / "public-gateway-live-verification.json"
    if live_verification is not None:
        write_json(live_path, live_verification)

    discovery_path = output_root / "publisher-report-discovery.json"
    deploy_path = output_root / "worker-deploy-report.json"
    report_path = output_root / "public-gateway-release-report.json"
    closeout_path = output_root / "closeout.md"
    write_json(discovery_path, discovery)
    write_json(deploy_path, deploy_report)

    valid = not issues and all(check["passed"] for check in checks)
    report = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublicGatewayReleaseReport.v1",
        "versionID": PUBLIC_GATEWAY_RELEASE_VERSION,
        "createdAt": options.created_at,
        "status": "Source Green for public gateway release orchestrator" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; public gateway release orchestration only",
        "publisherReportRoot": str(options.publisher_report_root),
        "selectedPublisherReportCount": len(discovery["selectedPublisherReports"]),
        "allowedObjectKeyCount": allowlist_report.get("allowedObjectKeyCount", 0),
        "deployRequested": options.deploy,
        "executeRequested": options.execute,
        "liveVerificationRequested": options.verify_live,
        "productionTargetLedgerGate": production_target_gate,
        "nativeRegistryCoherenceGate": native_registry_gate,
        "checks": checks,
        "issues": issues,
        "discovery": discovery,
        "allowlistReport": allowlist_report,
        "deployReport": deploy_report,
        "liveVerification": live_verification,
        "outputPaths": {
            "report": str(report_path),
            "discovery": str(discovery_path),
            "allowlistReport": allowlist_report["outputPaths"]["report"],
            "allowlistArtifact": allowlist_report["outputPaths"]["artifact"],
            "generatedWorkerAllowlist": allowlist_report["outputPaths"]["generatedWorkerAllowlist"],
            "deployReport": str(deploy_path),
            "productionTargetLedger": str(options.production_target_ledger_path) if options.production_target_ledger_path else None,
            "nativeRegistryArtifact": str(options.native_registry_artifact_path) if options.native_registry_artifact_path else None,
            "liveVerification": str(live_path) if live_verification is not None else None,
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
    closeout_path.write_text(public_gateway_release_markdown(report), encoding="utf-8")
    return report


def discover_production_publisher_reports(root: Path) -> dict[str, Any]:
    issues: list[str] = []
    skipped: list[dict[str, Any]] = []
    eligible_by_domain: dict[str, dict[str, Any]] = {}
    superseded: list[dict[str, Any]] = []
    all_paths = sorted(root.glob("**/r2-publisher-report.json")) if root.exists() else []
    if not root.exists():
        issues.append(f"publisher report root missing: {root}")

    for path in all_paths:
        try:
            report = read_json(path)
        except Exception as exc:  # pragma: no cover - defensive.
            issues.append(f"{path}: unreadable publisher report: {exc}")
            continue
        summary = _report_summary(path, report)
        if not _is_production_remote_report(report):
            skipped.append(summary | {"reason": "not production/stable remote R2 upload proof"})
            continue
        if report.get("valid") is not True:
            issues.append(f"{path}: eligible production/stable remote R2 report is not valid")
            continue
        domain = summary.get("domainID")
        if not domain:
            issues.append(f"{path}: unable to derive domain ID from manifest key")
            continue
        current = eligible_by_domain.get(domain)
        if current is None or _report_sort_key(summary) > _report_sort_key(current):
            if current is not None:
                superseded.append(current | {"reason": "older report superseded for domain"})
            eligible_by_domain[domain] = summary
        else:
            superseded.append(summary | {"reason": "older report superseded for domain"})

    selected = [eligible_by_domain[key] for key in sorted(eligible_by_domain)]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublicGatewayPublisherReportDiscovery.v1",
        "publisherReportRoot": str(root),
        "totalReportCount": len(all_paths),
        "selectedReportCount": len(selected),
        "selectedPublisherReports": [item["path"] for item in selected],
        "selectedReports": selected,
        "skippedReports": skipped,
        "supersededReports": superseded,
        "issues": issues,
        "valid": not issues and bool(selected),
    }


def _production_target_or_admission_gate(
    *,
    options: PublicGatewayReleaseOptions,
    requested_domains: list[str],
    selected_reports: list[dict[str, Any]],
) -> dict[str, Any]:
    required = options.deploy and options.execute
    gate = validate_production_target_ledger_gate(
        ledger_path=options.production_target_ledger_path,
        requested_domains=requested_domains,
        required=required,
    )
    if gate["valid"] or not required or not options.production_domain_admission_path:
        return gate

    admission_validation = _validate_initial_domain_admission_for_gateway(
        options.production_domain_admission_path,
        gate.get("missingDomains", []),
        selected_reports,
    )
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedgerOrAdmissionGate.v1",
        "required": required,
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
            "not production target ledger Green until post-gateway ledger is regenerated",
            "not literal universal coverage",
            "not full Source Atlas Green",
            "not Release Green",
            "not outside legal approval",
            "not final user plans, schedules, or Steps",
        ],
    }


def _validate_initial_domain_admission_for_gateway(
    admission_path: Path,
    missing_domains: list[str],
    selected_reports: list[dict[str, Any]],
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
        issues.append("production domain admission must be production/stable for gateway deploy fallback")
    if admission.get("outsideLegalApprovalClaimed") is True:
        issues.append("production domain admission must not claim outside legal approval")
    if admission.get("releaseGreenClaimed") is True:
        issues.append("production domain admission must not claim Release Green")
    if admission.get("literalUniversalCoverageClaimed") is True:
        issues.append("production domain admission must not claim literal universal coverage")

    selected_by_domain = {
        str(report.get("domainID")): report
        for report in selected_reports
        if isinstance(report, dict) and isinstance(report.get("domainID"), str)
    }
    selected = selected_by_domain.get(domain)
    if not selected:
        issues.append(f"production domain admission has no matching selected publisher report: {domain}")
    elif admission.get("packID") != selected.get("packID"):
        issues.append("production domain admission packID does not match selected publisher report")

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
            "public-gateway-production-domain-admission",
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


def validate_native_registry_coherence(
    *,
    registry_path: Path | None,
    selected_reports: list[dict[str, Any]],
) -> dict[str, Any]:
    """Ensure native active refresh targets match selected production reports."""

    if registry_path is None:
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.nativeRegistryCoherenceGate.v1",
            "required": False,
            "valid": True,
            "issues": [],
            "activeTargetCount": 0,
            "selectedReportCount": len(selected_reports),
            "matchedTargetCount": 0,
            "nonClaims": PUBLIC_GATEWAY_NON_CLAIMS,
        }
    issues: list[str] = []
    if not registry_path.exists():
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.nativeRegistryCoherenceGate.v1",
            "required": True,
            "valid": False,
            "issues": [f"native registry artifact missing: {registry_path}"],
            "activeTargetCount": 0,
            "selectedReportCount": len(selected_reports),
            "matchedTargetCount": 0,
            "nonClaims": PUBLIC_GATEWAY_NON_CLAIMS,
        }

    try:
        registry = read_json(registry_path)
    except Exception as exc:  # pragma: no cover - defensive.
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.nativeRegistryCoherenceGate.v1",
            "required": True,
            "valid": False,
            "issues": [f"native registry artifact unreadable: {registry_path}: {exc}"],
            "activeTargetCount": 0,
            "selectedReportCount": len(selected_reports),
            "matchedTargetCount": 0,
            "nonClaims": PUBLIC_GATEWAY_NON_CLAIMS,
        }

    if registry.get("publicReferenceOnly") is not True:
        issues.append(f"{registry_path}: publicReferenceOnly must be true")
    boundary_issues = boundary_issue_strings(boundary_issues_for_value(registry, "native-registry-coherence-gate"))
    issues.extend(boundary_issues)

    active_targets = _active_native_targets(registry)
    selected_by_domain = {
        str(report.get("domainID")): report
        for report in selected_reports
        if isinstance(report, dict) and isinstance(report.get("domainID"), str)
    }
    active_by_domain = {
        target["domainID"]: target
        for target in active_targets
        if isinstance(target.get("domainID"), str)
    }

    missing_selected = sorted(set(active_by_domain) - set(selected_by_domain))
    extra_selected = sorted(set(selected_by_domain) - set(active_by_domain))
    for domain in missing_selected:
        issues.append(f"native registry active target has no selected production publisher report: {domain}")
    for domain in extra_selected:
        issues.append(f"selected production publisher report missing from native active registry: {domain}")

    matches: list[dict[str, Any]] = []
    for domain in sorted(set(active_by_domain) & set(selected_by_domain)):
        target = active_by_domain[domain]
        report = selected_by_domain[domain]
        target_pack_id = str(target.get("targetPackID") or "")
        report_pack_id = str(report.get("packID") or "")
        target_issues: list[str] = []
        if target.get("environment") != "production":
            target_issues.append("native target environment is not production")
        if target.get("channel") != "stable":
            target_issues.append("native target channel is not stable")
        if target_pack_id != report_pack_id:
            target_issues.append(f"native target packID {target_pack_id} does not match selected publisher report {report_pack_id}")
        issues.extend(f"{domain}: {issue}" for issue in target_issues)
        matches.append(
            {
                "domainID": domain,
                "targetPackID": target_pack_id,
                "selectedPackID": report_pack_id,
                "publisherReport": report.get("path"),
                "targetID": target.get("id"),
                "matched": not target_issues,
            }
        )

    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.nativeRegistryCoherenceGate.v1",
        "required": True,
        "valid": not issues,
        "registryPath": str(registry_path),
        "artifactID": registry.get("artifactID"),
        "activeTargetCount": len(active_targets),
        "selectedReportCount": len(selected_reports),
        "matchedTargetCount": sum(1 for item in matches if item["matched"]),
        "activeDomains": sorted(active_by_domain),
        "selectedDomains": sorted(selected_by_domain),
        "matches": matches,
        "issues": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PUBLIC_GATEWAY_NON_CLAIMS,
    }


def verify_public_gateway(
    *,
    allowlist_path: Path,
    publisher_reports: tuple[Path, ...],
    base_url: str,
    created_at: str,
    worker_version_id: str | None = None,
    request_fn: HttpRequestFn | None = None,
) -> dict[str, Any]:
    request = request_fn or _http_request
    issues: list[str] = []
    allowlist = read_json(allowlist_path)
    allowed_keys = allowlist.get("allowedObjectKeys", [])
    head_checks: list[dict[str, Any]] = []
    for key in allowed_keys:
        status, _body, headers = request(base_url, key, "HEAD")
        passed = status == 200 and headers.get("X-Source-Atlas-Public-Reference") == "true"
        if not passed:
            issues.append(f"HEAD failed for {key}: status={status}")
        head_checks.append(
            {
                "objectKey": key,
                "status": status,
                "publicReferenceHeader": headers.get("X-Source-Atlas-Public-Reference"),
                "passed": passed,
            }
        )

    public_checks: list[dict[str, Any]] = []
    for report_path in publisher_reports:
        report = read_json(report_path)
        domain = _domain_id_from_manifest_key(report.get("currentPointer", {}).get("manifestKey", ""))
        readbacks = {item.get("label"): item for item in report.get("operation", {}).get("readbackResults", []) if isinstance(item, dict)}
        selected = [
            ("current", report.get("operation", {}).get("currentPointer", {}).get("key"), report.get("operation", {}).get("currentPointer", {}).get("expectedSHA256")),
            ("manifest", report.get("currentPointer", {}).get("manifestKey"), readbacks.get("manifest", {}).get("expectedSHA256")),
            ("pack", readbacks.get("pack", {}).get("objectKey"), readbacks.get("pack", {}).get("expectedSHA256")),
        ]
        for label, key, expected_sha in selected:
            status, body, headers = request(base_url, str(key), "GET")
            actual_sha = hashlib.sha256(body).hexdigest() if status == 200 else None
            matched = status == 200 and isinstance(expected_sha, str) and actual_sha == expected_sha
            if not matched:
                issues.append(f"GET SHA mismatch for {key}: status={status}")
            public_checks.append(
                {
                    "domain": domain,
                    "label": label,
                    "objectKey": key,
                    "status": status,
                    "expectedSHA256": expected_sha,
                    "actualSHA256": actual_sha,
                    "matched": matched,
                    "publicReferenceHeader": headers.get("X-Source-Atlas-Public-Reference"),
                }
            )

    blocked_checks: list[dict[str, Any]] = []
    negative_paths = [
        "source-atlas/v1/production/stable/users/current.json",
        _first_current_key(publisher_reports) + "?goal_text=private" if publisher_reports else "source-atlas/v1/production/stable/current.json?goal_text=private",
    ]
    for path in negative_paths:
        status, _body, _headers = request(base_url, path, "GET")
        blocked = status in {403, 404}
        if not blocked:
            issues.append(f"negative request was not blocked: {path}: status={status}")
        blocked_checks.append({"path": path, "status": status, "blocked": blocked})

    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublicGatewayLiveVerification.v1",
        "createdAt": created_at,
        "workerVersionID": worker_version_id,
        "baseURL": base_url,
        "allowlistPath": str(allowlist_path),
        "headCheckCount": len(head_checks),
        "headChecksPassed": all(item["passed"] for item in head_checks),
        "publicCheckCount": len(public_checks),
        "publicChecksPassed": all(item["matched"] and item["publicReferenceHeader"] == "true" for item in public_checks),
        "blockedChecksPassed": all(item["blocked"] for item in blocked_checks),
        "valid": not issues,
        "issues": issues,
        "headChecks": head_checks,
        "publicChecks": public_checks,
        "blockedChecks": blocked_checks,
        "nonClaims": PUBLIC_GATEWAY_NON_CLAIMS,
    }


def public_gateway_release_markdown(report: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Public R2 Gateway Release Orchestrator Train 83",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Discovers current production/stable remote R2 publisher reports from a report root.",
        "- Selects the latest eligible report per domain.",
        "- Validates the native active refresh registry against selected production reports when a registry artifact is provided.",
        "- Regenerates the public Worker allowlist from selected reports.",
        "- Keeps Worker deployment behind --deploy and --execute.",
        "- Keeps live gateway checks behind --verify-live.",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- Gateway release artifacts contain public object keys and pack metadata only.",
        "- Source Atlas does not generate final plans, schedules, or Steps.",
        "",
        "Proof artifacts:",
    ]
    for path in report.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("productionNonClaims", []))
    native_gate = report.get("nativeRegistryCoherenceGate")
    if isinstance(native_gate, dict) and native_gate.get("required"):
        lines.extend(
            [
                "",
                "Native registry coherence:",
                f"- Active targets: {native_gate.get('activeTargetCount')}",
                f"- Selected publisher reports: {native_gate.get('selectedReportCount')}",
                f"- Matched targets: {native_gate.get('matchedTargetCount')}",
            ]
        )
        for issue in native_gate.get("issues", []):
            lines.append(f"- Issue: {issue}")
    lines.extend(
        [
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Compatibility shims left behind: none.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Rollback plan:",
            "- Revert Train 83 release orchestrator module, CLI command, tests, generated artifacts, and QA evidence.",
            "- Redeploy the previous Worker version if a deployed Worker regression is found.",
            "",
        ]
    )
    return "\n".join(lines)


def _deploy_worker(options: PublicGatewayReleaseOptions, output_root: Path) -> dict[str, Any]:
    config_path = options.worker_config_path
    if config_path is None:
        return {"attempted": False, "success": False, "issues": ["worker config path is required for deploy"]}
    args = ["wrangler", "deploy", "--config", str(config_path)]
    try:
        completed = subprocess.run(args, capture_output=True, text=True, check=False, timeout=120)
    except (subprocess.SubprocessError, OSError) as exc:
        return {"attempted": True, "success": False, "args": args, "issues": [str(exc)]}
    stdout = completed.stdout or ""
    stderr = completed.stderr or ""
    worker_version_id = _worker_version_id(stdout + "\n" + stderr)
    return {
        "attempted": True,
        "success": completed.returncode == 0,
        "args": args,
        "returnCode": completed.returncode,
        "stdout": stdout,
        "stderr": stderr,
        "workerVersionID": worker_version_id,
        "issues": [] if completed.returncode == 0 else ["wrangler deploy failed"],
        "outputRoot": str(output_root),
    }


def _planned_deploy(options: PublicGatewayReleaseOptions) -> dict[str, Any]:
    return {
        "attempted": False,
        "success": None,
        "deployRequested": options.deploy,
        "executeRequested": options.execute,
        "workerConfigPath": str(options.worker_config_path) if options.worker_config_path else None,
        "issues": [],
    }


def _deploy_gate_issues(options: PublicGatewayReleaseOptions) -> list[str]:
    issues: list[str] = []
    if options.deploy and not options.execute:
        issues.append("Worker deploy requires --execute")
    if options.deploy and options.worker_config_path is None:
        issues.append("Worker deploy requires --worker-config")
    if options.deploy and options.worker_config_path is not None and not options.worker_config_path.exists():
        issues.append(f"worker config does not exist: {options.worker_config_path}")
    return issues


def _http_request(base_url: str, path: str, method: str) -> tuple[int, bytes, dict[str, str]]:
    url = base_url.rstrip("/") + "/" + path.lstrip("/")
    request = urllib.request.Request(url, method=method, headers={"User-Agent": "SourceAtlasGatewayRelease/1.0"})
    try:
        with urllib.request.urlopen(request, timeout=20) as response:
            return response.status, response.read(), dict(response.headers)
    except urllib.error.HTTPError as exc:
        return exc.code, exc.read(), dict(exc.headers)


def _skipped_live_verification(options: PublicGatewayReleaseOptions, prior_issues: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublicGatewayLiveVerification.v1",
        "createdAt": options.created_at,
        "baseURL": options.base_url,
        "valid": False,
        "issues": ["live verification skipped because earlier release gates failed"] + list(prior_issues),
    }


def _report_summary(path: Path, report: dict[str, Any]) -> dict[str, Any]:
    manifest_key = report.get("currentPointer", {}).get("manifestKey")
    return {
        "path": str(path),
        "domainID": _domain_id_from_manifest_key(manifest_key),
        "packID": report.get("packID"),
        "packVersion": report.get("packVersion"),
        "createdAt": report.get("createdAt"),
        "environment": report.get("environment"),
        "channel": report.get("channel"),
        "mode": report.get("mode"),
        "valid": report.get("valid") is True,
        "productionR2Uploaded": report.get("productionR2Uploaded") is True,
    }


def _is_production_remote_report(report: dict[str, Any]) -> bool:
    return (
        report.get("kind") == "ambitions.sourceAtlas.r2PackPublisherReport.v1"
        and report.get("environment") == "production"
        and report.get("channel") == "stable"
        and report.get("mode") == "remote_r2"
        and report.get("productionR2Uploaded") is True
    )


def _report_sort_key(summary: dict[str, Any]) -> tuple[str, str, str, str]:
    return (
        str(summary.get("packVersion") or ""),
        str(summary.get("createdAt") or ""),
        f"{_train_number_from_path(str(summary.get('path') or '')):08d}",
        str(summary.get("path") or ""),
    )


def _train_number_from_path(path: str) -> int:
    matches = re.findall(r"train-(\d+)", path)
    if not matches:
        return -1
    return max(int(match) for match in matches)


def _active_native_targets(registry: dict[str, Any]) -> list[dict[str, Any]]:
    entries = registry.get("registry", {}).get("entries", [])
    targets: list[dict[str, Any]] = []
    for entry in entries if isinstance(entries, list) else []:
        if not isinstance(entry, dict) or entry.get("status") != "active":
            continue
        raw_target = entry.get("target")
        if not isinstance(raw_target, dict):
            continue
        target = dict(raw_target)
        if "domainID" in target:
            targets.append(target)
    return sorted(targets, key=lambda item: str(item.get("domainID", "")))


def _domain_id_from_manifest_key(manifest_key: Any) -> str | None:
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


def _first_current_key(publisher_reports: tuple[Path, ...]) -> str:
    for report_path in publisher_reports:
        report = read_json(report_path)
        key = report.get("operation", {}).get("currentPointer", {}).get("key")
        if isinstance(key, str) and key:
            return key
    return "source-atlas/v1/production/stable/current.json"


def _worker_version_id(output: str) -> str | None:
    for line in output.splitlines():
        if line.strip().startswith("Current Version ID:"):
            return line.split(":", 1)[1].strip()
    return None


def _record(checks: list[dict[str, Any]], name: str, passed: bool, issues: list[str]) -> None:
    checks.append({"name": name, "passed": passed, "issues": issues})
