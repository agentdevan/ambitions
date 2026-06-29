"""First-time production admission gate for new Source Atlas domains.

This gate exists to avoid a circular dependency for a domain's first production
R2 write: the production target ledger needs R2 proof, while the R2 publisher
needs production-target proof. Admission is intentionally narrower than the
ledger. It can authorize only the initial production/stable R2 write for one
domain after pack, legal/terms, frontier, and privacy gates have already passed.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value, object_key_issues
from .claim_frontier import DEFAULT_FRONTIER_CONFIG_PATH
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, read_json, stable_hash, stable_id, write_json
from .pack_production import validate_pack_production_artifacts
from .production_target_gate import domain_id_from_pack_id
from .r2_owner_approval import REQUIRED_EXECUTION_GATES
from .terms_approval_packet import validate_terms_approval_packet_for_entries
from .terms_registry import terms_entry


PRODUCTION_DOMAIN_ADMISSION_KIND = "ambitions.sourceAtlas.productionDomainAdmission.v1"
PRODUCTION_DOMAIN_ADMISSION_VERSION = "source-atlas-production-domain-admission-train-131"

ADMISSION_NON_CLAIMS = [
    "not production target ledger Green",
    "not gateway release proof",
    "not native runtime proof",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not outside legal approval",
    "not literal universal coverage",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class ProductionDomainAdmissionOptions:
    domain: str
    pack_root: Path
    output_root: Path
    frontier_config_path: Path = DEFAULT_FRONTIER_CONFIG_PATH
    production_target_ledger_path: Path | None = None
    legal_approval_packet: Path | None = None
    created_at: str = "2026-06-29T06:30:00Z"
    environment: str = "production"
    channel: str = "stable"
    bucket: str = "ambitions-source-atlas-prod"
    owner: str = "Ambitions owner technical authorization captured in current Source Atlas goal thread"


def build_production_domain_admission(options: ProductionDomainAdmissionOptions) -> dict[str, Any]:
    options.output_root.mkdir(parents=True, exist_ok=True)
    issues: list[str] = []
    checks: list[dict[str, Any]] = []

    manifest_path = options.pack_root / "manifest.json"
    pack_report_path = options.pack_root / "pack-production-report.json"
    manifest = _read_json(manifest_path, "pack manifest", issues)
    pack_report = _read_json(pack_report_path, "pack production report", issues)
    artifact_validation = validate_pack_production_artifacts(options.pack_root) if options.pack_root.exists() else {
        "valid": False,
        "issues": [f"pack root does not exist: {options.pack_root}"],
    }
    legal_validation = _legal_validation(options)
    frontier_validation = _frontier_validation(options)
    ledger_validation = _previous_ledger_validation(options)
    scope_validation = _pack_scope_validation(options, manifest, pack_report)
    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "domain": options.domain,
                "environment": options.environment,
                "channel": options.channel,
                "bucket": options.bucket,
                "packID": manifest.get("pack_id") if isinstance(manifest, dict) else None,
                "objectKeys": manifest.get("object_keys") if isinstance(manifest, dict) else None,
            },
            "production-domain-admission",
        )
    )

    _record(checks, "frontier_configured_for_domain", frontier_validation["valid"], frontier_validation["issues"])
    _record(checks, "pack_artifacts_valid", artifact_validation.get("valid") is True, artifact_validation.get("issues", []))
    _record(checks, "pack_scope_matches_requested_domain", scope_validation["valid"], scope_validation["issues"])
    _record(checks, "legal_terms_approval_packet_valid", legal_validation["valid"], legal_validation["issues"])
    _record(checks, "previous_ledger_valid_and_domain_not_ready", ledger_validation["valid"], ledger_validation["issues"])
    _record(checks, "privacy_scan_passed", not privacy_issues, privacy_issues)

    issues.extend(frontier_validation["issues"])
    issues.extend(artifact_validation.get("issues", []))
    issues.extend(scope_validation["issues"])
    issues.extend(legal_validation["issues"])
    issues.extend(ledger_validation["issues"])
    issues.extend(privacy_issues)

    manifest_sha256 = file_sha256(manifest_path) if manifest_path.exists() else None
    legal_packet_sha256 = file_sha256(options.legal_approval_packet) if options.legal_approval_packet and options.legal_approval_packet.exists() else None
    prefix = f"source-atlas/v1/{options.environment}/{options.channel}/{options.domain}/"
    valid = not issues and all(check["passed"] for check in checks)
    report = {
        "schemaVersion": 1,
        "kind": PRODUCTION_DOMAIN_ADMISSION_KIND,
        "versionID": PRODUCTION_DOMAIN_ADMISSION_VERSION,
        "admissionID": stable_id(
            "source_atlas.production_domain_admission",
            {
                "domain": options.domain,
                "createdAt": options.created_at,
                "packManifestSHA256": manifest_sha256,
            },
        ),
        "approvalID": stable_id(
            "source_atlas.production_domain_initial_r2_approval",
            {
                "domain": options.domain,
                "environment": options.environment,
                "channel": options.channel,
                "packManifestSHA256": manifest_sha256,
            },
        ),
        "approvalType": "initial_domain_public_reference_production_r2_write",
        "approvalStatus": "approved_for_initial_production_r2_upload" if valid else "blocked_initial_production_r2_upload",
        "approved": valid,
        "createdAt": options.created_at,
        "owner": options.owner,
        "domain": options.domain,
        "environment": options.environment,
        "channel": options.channel,
        "bucket": options.bucket,
        "admissionDecision": "ready_for_initial_production_r2_upload" if valid else "blocked",
        "approvalScope": {
            "domain": options.domain,
            "environment": options.environment,
            "channel": options.channel,
            "objectPrefix": prefix,
            "currentPointerKey": f"{prefix}current.json",
            "lkgPointerKey": f"{prefix}lkg.json",
            "revocationKey": f"{prefix}revocations.json",
        },
        "requiredExecutionGates": sorted(REQUIRED_EXECUTION_GATES),
        "packRoot": str(options.pack_root),
        "packID": manifest.get("pack_id") if isinstance(manifest, dict) else None,
        "packManifestPath": str(manifest_path),
        "packManifestSHA256": manifest_sha256,
        "legalApprovalPacket": str(options.legal_approval_packet) if options.legal_approval_packet else None,
        "legalApprovalPacketSHA256": legal_packet_sha256,
        "frontierConfigPath": str(options.frontier_config_path),
        "productionTargetLedgerPath": str(options.production_target_ledger_path) if options.production_target_ledger_path else None,
        "frontierValidation": frontier_validation,
        "legalTermsApprovalPacketValidation": legal_validation,
        "previousProductionTargetLedgerValidation": ledger_validation,
        "artifactValidation": artifact_validation,
        "scopeValidation": scope_validation,
        "checks": checks,
        "issues": sorted(set(issues)),
        "outsideLegalApprovalClaimed": False,
        "releaseGreenClaimed": False,
        "literalUniversalCoverageClaimed": False,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": ADMISSION_NON_CLAIMS,
        "valid": valid,
        "status": "Source Green for initial production domain admission gate" if valid else "Red",
    }
    report["outputHashes"] = {
        "admissionPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"})
    }

    report_path = options.output_root / "production-domain-admission-report.json"
    markdown_path = options.output_root / "closeout.md"
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    report["outputPaths"] = {"report": str(report_path), "closeout": str(markdown_path)}
    write_json(report_path, report)
    markdown_path.write_text(production_domain_admission_markdown(report), encoding="utf-8")
    return report


def validate_production_domain_admission_artifact(
    admission_path: Path | None,
    *,
    domain: str,
    environment: str,
    channel: str,
    pack_root: Path,
    legal_approval_packet: Path | None,
) -> dict[str, Any]:
    issues: list[str] = []
    if admission_path is None:
        issues.append("production domain admission artifact path was not supplied")
        return _validation_result(None, issues)
    if not admission_path.exists():
        issues.append(f"production domain admission artifact does not exist: {admission_path}")
        return _validation_result(str(admission_path), issues)
    try:
        admission = read_json(admission_path)
    except Exception as exc:  # pragma: no cover - malformed evidence artifact
        issues.append(f"production domain admission artifact unreadable: {admission_path}: {exc}")
        return _validation_result(str(admission_path), issues)

    if admission.get("kind") != PRODUCTION_DOMAIN_ADMISSION_KIND:
        issues.append(f"production domain admission kind is unsupported: {admission.get('kind')}")
    if admission.get("schemaVersion") != 1:
        issues.append("production domain admission schemaVersion must be 1")
    if admission.get("valid") is not True or admission.get("approved") is not True:
        issues.append("production domain admission artifact is not approved")
    if admission.get("admissionDecision") != "ready_for_initial_production_r2_upload":
        issues.append(f"production domain admission decision is not ready: {admission.get('admissionDecision')}")
    if admission.get("domain") != domain:
        issues.append(f"production domain admission domain mismatch: {admission.get('domain')}")
    if admission.get("environment") != environment:
        issues.append(f"production domain admission environment mismatch: {admission.get('environment')}")
    if admission.get("channel") != channel:
        issues.append(f"production domain admission channel mismatch: {admission.get('channel')}")
    if admission.get("outsideLegalApprovalClaimed") is True:
        issues.append("production domain admission must not claim outside legal approval")
    if admission.get("releaseGreenClaimed") is True:
        issues.append("production domain admission must not claim Release Green")
    if admission.get("literalUniversalCoverageClaimed") is True:
        issues.append("production domain admission must not claim literal universal coverage")

    manifest_path = pack_root / "manifest.json"
    actual_manifest_sha = file_sha256(manifest_path) if manifest_path.exists() else None
    if admission.get("packManifestSHA256") != actual_manifest_sha:
        issues.append("production domain admission pack manifest SHA-256 does not match current pack root")
    expected_legal_sha = file_sha256(legal_approval_packet) if legal_approval_packet and legal_approval_packet.exists() else None
    if admission.get("legalApprovalPacketSHA256") != expected_legal_sha:
        issues.append("production domain admission legal approval packet SHA-256 does not match current packet")

    scope = admission.get("approvalScope") if isinstance(admission.get("approvalScope"), dict) else {}
    for label in ("objectPrefix", "currentPointerKey", "lkgPointerKey", "revocationKey"):
        value = str(scope.get(label, ""))
        issues.extend(issue.format() for issue in object_key_issues(value, label=f"productionDomainAdmission.{label}"))
        if f"/{domain}/" not in value:
            issues.append(f"production domain admission {label} does not include domain ID")

    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(_admission_privacy_view(admission), "production-domain-admission-validation")
    )
    issues.extend(privacy_issues)
    result = _validation_result(str(admission_path), issues)
    result.update(
        {
            "kind": admission.get("kind"),
            "admissionID": admission.get("admissionID"),
            "admissionDecision": admission.get("admissionDecision"),
            "domain": admission.get("domain"),
            "artifactSHA256": stable_hash(admission),
            "privacyIssues": privacy_issues,
        }
    )
    return result


def production_domain_admission_markdown(report: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Initial Production Domain Admission",
        "",
        f"Status: {report['status']}",
        f"Domain: `{report['domain']}`",
        f"Decision: `{report['admissionDecision']}`",
        "",
        "Scope completed:",
        "- First-time production/stable R2 write admission for one public/reference domain.",
        "- Pack, legal/terms, frontier, previous-ledger, and privacy gates before R2 upload.",
        "- Scoped owner technical approval metadata for the requested domain only.",
        "",
        "Checks:",
    ]
    for check in report.get("checks", []):
        lines.append(f"- {check['name']}: {'pass' if check['passed'] else 'fail'}")
    lines.extend(["", "Issues:"])
    lines.extend(f"- {issue}" for issue in report.get("issues", [])) if report.get("issues") else lines.append("- none")
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.append("")
    return "\n".join(lines)


def _legal_validation(options: ProductionDomainAdmissionOptions) -> dict[str, Any]:
    source_ids = _publisher_source_ids(options.pack_root)
    if not options.legal_approval_packet:
        return _legal_result(source_ids, ["production domain admission requires legal approval packet"])
    if not options.legal_approval_packet.exists():
        return _legal_result(source_ids, [f"legal approval packet does not exist: {options.legal_approval_packet}"])
    entries = []
    issues: list[str] = []
    for source_id in source_ids:
        try:
            entries.append(terms_entry(source_id))
        except KeyError:
            issues.append(f"{source_id}: no terms registry entry for legal approval packet validation")
    packet = read_json(options.legal_approval_packet) if not issues else None
    validation = validate_terms_approval_packet_for_entries(
        packet,
        terms_entries=entries,
        requested_artifact_classes={"official_public_source", "public_reference_claim", "public_provenance", "public_freshness"},
        now_date=options.created_at[:10],
    )
    validation["packetPath"] = str(options.legal_approval_packet)
    validation["packetSHA256"] = file_sha256(options.legal_approval_packet)
    if issues:
        validation["valid"] = False
        validation["status"] = "Red"
        validation["issues"] = issues + validation.get("issues", [])
    return validation


def _frontier_validation(options: ProductionDomainAdmissionOptions) -> dict[str, Any]:
    issues: list[str] = []
    frontier_config = _read_json(options.frontier_config_path, "frontier config", issues)
    frontier = None
    if isinstance(frontier_config, dict):
        for item in frontier_config.get("frontiers", []):
            if isinstance(item, dict) and item.get("frontier_id") == options.domain:
                frontier = item
                break
    if not frontier:
        issues.append(f"{options.domain}: missing active coverage frontier config")
    source_ids = set(_publisher_source_ids(options.pack_root))
    frontier_sources = set(frontier.get("source_ids", [])) if isinstance(frontier, dict) else set()
    missing_sources = sorted(source_ids - frontier_sources)
    if missing_sources:
        issues.append(f"{options.domain}: frontier config missing pack source IDs: {', '.join(missing_sources)}")
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionDomainFrontierValidation.v1",
        "valid": not issues,
        "frontierID": frontier.get("frontier_id") if isinstance(frontier, dict) else None,
        "sourceIDs": sorted(source_ids),
        "issues": issues,
    }


def _previous_ledger_validation(options: ProductionDomainAdmissionOptions) -> dict[str, Any]:
    issues: list[str] = []
    if options.production_target_ledger_path is None:
        issues.append("initial production domain admission requires previous production target ledger path")
        return _ledger_result(options, None, issues)
    ledger = _read_json(options.production_target_ledger_path, "production target ledger", issues)
    if not isinstance(ledger, dict):
        return _ledger_result(options, ledger, issues)
    if ledger.get("kind") != "ambitions.sourceAtlas.productionTargetLedger.v1":
        issues.append("production target ledger kind is unsupported")
    if ledger.get("valid") is not True:
        issues.append("production target ledger valid flag is not true")
    if ledger.get("orphanProductionDomains"):
        issues.append("production target ledger contains orphan production domains")
    if ledger.get("configuredDomainsNotReady"):
        issues.append("production target ledger contains configured domains that are not ready")
    ready_domains = {
        item.get("domainID")
        for item in ledger.get("domains", [])
        if isinstance(item, dict) and item.get("readinessStatus") == "bounded_production_target_ready"
    }
    if options.domain in ready_domains:
        issues.append(f"{options.domain}: already bounded production target ready; use production target ledger gate")
    return _ledger_result(options, ledger, issues)


def _pack_scope_validation(options: ProductionDomainAdmissionOptions, manifest: Any, pack_report: Any) -> dict[str, Any]:
    issues: list[str] = []
    if not isinstance(manifest, dict):
        return {"valid": False, "issues": ["pack manifest is not readable"]}
    pack_id = str(manifest.get("pack_id", ""))
    if domain_id_from_pack_id(pack_id) != options.domain:
        issues.append(f"pack manifest domain mismatch: {pack_id}")
    if not _object_keys_match_scope(manifest, options):
        issues.append("pack manifest object keys do not match requested production/stable domain scope")
    if isinstance(pack_report, dict):
        if pack_report.get("valid") is not True:
            issues.append("pack production report valid flag is not true")
        if pack_report.get("environment") != options.environment:
            issues.append(f"pack production environment mismatch: {pack_report.get('environment')}")
        if pack_report.get("channel") != options.channel:
            issues.append(f"pack production channel mismatch: {pack_report.get('channel')}")
        if pack_report.get("domain") != options.domain:
            issues.append(f"pack production domain mismatch: {pack_report.get('domain')}")
        if pack_report.get("nonPrivateScan", {}).get("passed") is not True:
            issues.append("pack production non-private scan did not pass")
        if pack_report.get("legalTermsApprovalPacketValidation", {}).get("valid") is not True:
            issues.append("pack production legal/terms approval validation did not pass")
    return {"valid": not issues, "issues": issues}


def _object_keys_match_scope(manifest: dict[str, Any], options: ProductionDomainAdmissionOptions) -> bool:
    object_keys = manifest.get("object_keys")
    if not isinstance(object_keys, dict):
        return False
    prefix = f"source-atlas/v1/{options.environment}/{options.channel}/{options.domain}/"
    return all(str(value).startswith(prefix) for value in object_keys.values() if value)


def _publisher_source_ids(pack_root: Path) -> list[str]:
    path = pack_root / "sources.json"
    if not path.exists():
        return []
    return sorted(
        source.get("source_id")
        for source in read_json(path).get("sources", [])
        if source.get("source_id")
    )


def _read_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - malformed evidence artifact
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _legal_result(source_ids: list[str], issues: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.legalTermsApprovalPacketValidation.v1",
        "valid": False,
        "status": "Red",
        "sourceIDs": source_ids,
        "issues": issues,
    }


def _ledger_result(options: ProductionDomainAdmissionOptions, ledger: Any, issues: list[str]) -> dict[str, Any]:
    ready_domains = []
    if isinstance(ledger, dict):
        ready_domains = sorted(
            item.get("domainID")
            for item in ledger.get("domains", [])
            if isinstance(item, dict) and item.get("readinessStatus") == "bounded_production_target_ready"
        )
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.previousProductionTargetLedgerValidation.v1",
        "valid": not issues,
        "ledgerPath": str(options.production_target_ledger_path) if options.production_target_ledger_path else None,
        "ledgerID": ledger.get("ledgerID") if isinstance(ledger, dict) else None,
        "readyDomains": ready_domains,
        "domainAlreadyReady": options.domain in ready_domains,
        "issues": issues,
    }


def _admission_privacy_view(admission: dict[str, Any]) -> dict[str, Any]:
    return {
        "kind": admission.get("kind"),
        "admissionID": admission.get("admissionID"),
        "approvalID": admission.get("approvalID"),
        "approvalType": admission.get("approvalType"),
        "approvalStatus": admission.get("approvalStatus"),
        "domain": admission.get("domain"),
        "environment": admission.get("environment"),
        "channel": admission.get("channel"),
        "approvalScope": admission.get("approvalScope"),
        "privacyBoundary": admission.get("privacyBoundary"),
        "nonClaims": admission.get("nonClaims", []),
    }


def _validation_result(path: str | None, issues: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionDomainAdmissionValidation.v1",
        "path": path,
        "valid": not issues,
        "status": "Green" if not issues else "Red",
        "issues": sorted(set(issues)),
    }


def _record(checks: list[dict[str, Any]], name: str, passed: bool, issues: list[str]) -> None:
    checks.append({"name": name, "passed": passed, "issues": [] if passed else issues})
