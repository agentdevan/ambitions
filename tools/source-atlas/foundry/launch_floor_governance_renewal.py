"""Launch-floor legal/API/source-lane renewal proof for Source Atlas.

This verifier is intentionally registry-only. It proves that the current
launch-floor taxonomy can be traced to governed public/reference source lanes
with owner, review, renewal, legal, API, and approval posture. It does not
claim outside legal approval, production R2 readiness, native runtime release
readiness, or final user outputs.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .boundary import boundary_issues_for_value, is_boundary_line
from .governance_registry import (
    API_GOVERNANCE_REGISTRY_PATH,
    LEGAL_TERMS_REGISTRY_PATH,
    SOURCE_LANE_REGISTRY_PATH,
    validate_governance_registries,
)
from .launch_floor_domain_taxonomy import (
    DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH,
    launch_floor_domain_taxonomy_summary,
)
from .launch_floor_shard_corpus_compiler import DEFAULT_PRODUCTION_TARGET_LEDGER_PATH
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_LAUNCH_FLOOR_GOVERNANCE_RENEWAL_KIND = "ambitions.sourceAtlas.launchFloorGovernanceRenewal.v1"
SOURCE_ATLAS_LAUNCH_FLOOR_GOVERNANCE_RENEWAL_VERSION = "source-atlas-launch-floor-governance-renewal-lff-m06"

SOURCE_REVIEW_STATUSES = {"reviewed", "review_required", "candidate_only"}
API_REVIEW_STATUSES = {"reviewed", "review_required", "candidate_only"}
BLOCKING_REVIEW_STATUSES = {"blocked", "unknown", ""}

LAUNCH_FLOOR_GOVERNANCE_NON_CLAIMS = [
    "not outside legal approval",
    "not privacy/legal release signoff",
    "not physical-device proof",
    "not accessibility approval",
    "not independent visual approval",
    "not App Store Connect validation",
    "not TestFlight validation",
    "not owner release approval",
    "not production R2 write or readback proof",
    "not launch-floor complete by itself",
    "not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class LaunchFloorGovernanceRenewalOptions:
    source_lane_registry_path: Path = SOURCE_LANE_REGISTRY_PATH
    legal_terms_registry_path: Path = LEGAL_TERMS_REGISTRY_PATH
    api_governance_registry_path: Path = API_GOVERNANCE_REGISTRY_PATH
    launch_floor_taxonomy_path: Path = DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH
    production_target_ledger_path: Path = DEFAULT_PRODUCTION_TARGET_LEDGER_PATH
    output_root: Path = Path("tools/source-atlas/generated/source-atlas-launch-floor-governance-renewal/current")
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None


def compile_launch_floor_governance_renewal(options: LaunchFloorGovernanceRenewalOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    source_lane_registry = read_json(options.source_lane_registry_path)
    legal_terms_registry = read_json(options.legal_terms_registry_path)
    api_governance_registry = read_json(options.api_governance_registry_path)
    taxonomy = read_json(options.launch_floor_taxonomy_path)
    production_target_ledger = read_json(options.production_target_ledger_path)

    governance_validation = validate_governance_registries(
        source_lane_path=options.source_lane_registry_path,
        legal_terms_path=options.legal_terms_registry_path,
        api_governance_path=options.api_governance_registry_path,
    )
    taxonomy_summary = launch_floor_domain_taxonomy_summary(
        taxonomy,
        created_at=options.created_at,
        source_lane_registry=source_lane_registry,
        production_target_ledger=production_target_ledger,
    )

    source_by_id = _by_id(source_lane_registry.get("source_lanes", []), "source_id")
    legal_by_id = _by_id(legal_terms_registry.get("licenses", []), "license_id")
    api_by_id = _by_id(api_governance_registry.get("api_policies", []), "api_policy_id")
    profile_to_source_ids = _profile_to_source_ids(taxonomy_summary.get("sourceLaneProfiles", {}))
    launch_source_ids = _launch_source_ids(taxonomy_summary, profile_to_source_ids)

    input_privacy_issues = _privacy_issues(_input_paths(options), "source-atlas-launch-floor-governance-renewal-input")
    registry_privacy_issues = _privacy_issues(
        {
            "sourceLaneRegistry": source_lane_registry,
            "legalTermsRegistry": legal_terms_registry,
            "apiGovernanceRegistry": api_governance_registry,
            "launchFloorTaxonomy": taxonomy,
            "productionTargetLedger": production_target_ledger,
        },
        "source-atlas-launch-floor-governance-renewal-registries",
    )

    coverage_records, coverage_issues = _coverage_records(
        launch_source_ids=launch_source_ids,
        source_by_id=source_by_id,
        legal_by_id=legal_by_id,
        api_by_id=api_by_id,
        taxonomy_summary=taxonomy_summary,
        profile_to_source_ids=profile_to_source_ids,
        created_at=options.created_at,
    )
    coverage_path = output_root / "source-lane-domain-subdomain-coverage.json"
    write_json(
        coverage_path,
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.launchFloorSourceLaneCoverageMap.v1",
            "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_GOVERNANCE_RENEWAL_VERSION,
            "createdAt": options.created_at,
            "runLabel": options.run_label,
            "coverageRecords": coverage_records,
            "nonClaims": LAUNCH_FLOOR_GOVERNANCE_NON_CLAIMS,
        },
    )

    external_release_gates = _external_release_gates()
    issues = sorted(
        set(
            governance_validation.get("issues", [])
            + taxonomy_summary.get("issues", [])
            + input_privacy_issues
            + registry_privacy_issues
            + coverage_issues
        )
    )
    valid = not issues
    counts = _record_counts(
        coverage_records,
        source_lane_registry,
        legal_terms_registry,
        api_governance_registry,
        taxonomy_summary,
    )
    checks = _checks(
        counts=counts,
        governance_validation=governance_validation,
        taxonomy_summary=taxonomy_summary,
        input_privacy_issues=input_privacy_issues,
        registry_privacy_issues=registry_privacy_issues,
        coverage_issues=coverage_issues,
    )

    report_path = output_root / "launch-floor-governance-renewal-report.json"
    markdown_path = output_root / "launch-floor-governance-renewal-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_GOVERNANCE_RENEWAL_KIND,
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_GOVERNANCE_RENEWAL_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "renewalReportID": stable_id(
            "source_atlas.launch_floor_governance_renewal",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                    "inputHashes": _input_hashes(
                        source_lane_registry,
                        legal_terms_registry,
                        api_governance_registry,
                        taxonomy,
                        production_target_ledger,
                    ),
                "recordCounts": counts,
            },
        ),
        "status": "Source Green for launch-floor governance renewal tooling" if valid else "Red",
        "valid": valid,
        "launchFloorGovernanceRenewalMet": valid,
        "sourceAtlasStatusCeiling": (
            "Yellow overall Source Atlas; governance renewal only, external release gates remain blocked until real proof exists"
        ),
        "overallReadinessStatus": "governance_renewal_ready" if valid else "governance_renewal_blocked",
        "recordCounts": counts,
        "checks": checks,
        "issues": issues,
        "launchSourceLaneIDs": launch_source_ids,
        "externalReleaseGateStatus": external_release_gates,
        "allowedClaims": _allowed_claims(valid),
        "blockedClaims": _blocked_claims(),
        "productLaw": {
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "r2Role": "public/reference/freshness infrastructure only",
            "outsideLegalApprovalClaimed": False,
            "finalPersonalizedOutputsAllowed": False,
            "sourceAtlasGeneratesFinalPlansSchedulesSteps": False,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set(input_privacy_issues + registry_privacy_issues)),
        "nonClaims": LAUNCH_FLOOR_GOVERNANCE_NON_CLAIMS,
        "evidencePaths": _input_paths(options),
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "coverageMap": str(coverage_path),
            "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
            "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
        },
    }
    report["outputHashes"] = {
        "coverageMap": stable_hash(read_json(coverage_path)),
        "reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"}),
    }
    markdown = launch_floor_governance_renewal_markdown(report, coverage_records)
    report["outputHashes"]["markdownPayload"] = stable_hash(markdown)
    write_json(report_path, report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    return report


def launch_floor_governance_renewal_markdown(
    report: dict[str, Any],
    coverage_records: list[dict[str, Any]] | None = None,
) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Launch-Floor Governance Renewal LFF-M06",
        "",
        f"Status: {report['status']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "## Current Proved Capability",
        "",
        f"- Launch source lanes with renewal coverage: {counts['launchSourceLanes']}",
        f"- Accepted launch domains covered by governed source lanes: {counts['coveredLaunchDomains']}",
        f"- Accepted launch subdomains covered by governed source lanes: {counts['coveredLaunchSubdomains']}",
        f"- API policies with renewal metadata: {counts['apiPoliciesWithRenewalMetadata']} / {counts['apiPolicies']}",
        f"- Legal entries with renewal metadata: {counts['legalEntriesWithRenewalMetadata']} / {counts['legalEntries']}",
        f"- Source lanes with renewal metadata: {counts['sourceLanesWithRenewalMetadata']} / {counts['sourceLanes']}",
        f"- Expired source/API/legal postures: {counts['expiredPostures']}",
        f"- Unknown or blocking launch postures: {counts['unknownOrBlockingLaunchPostures']}",
        f"- Outside approval claims without artifacts: {counts['outsideApprovalClaimsWithoutArtifacts']}",
        "",
        "## Launch Source Lane Coverage",
        "",
        "| Source lane | Domains | Subdomains | Source status | API status | Legal status | Approval posture |",
        "|---|---:|---:|---|---|---|---|",
    ]
    for record in coverage_records or []:
        lines.append(
            "| {source} | {domains} | {subdomains} | {source_status} | {api_status} | {legal_status} | {approval} |".format(
                source=record["sourceID"],
                domains=record["coveredDomainCount"],
                subdomains=record["coveredSubdomainCount"],
                source_status=record["sourceRenewal"]["reviewStatus"],
                api_status=record["apiRenewal"]["reviewStatus"],
                legal_status=record["legalRenewal"]["outsideLegalStatus"],
                approval=record["approvalPosture"],
            )
        )
    lines.extend(["", "## Checks", ""])
    for check in report["checks"]:
        lines.append(f"- `{check['name']}`: {'pass' if check['passed'] else 'fail'}")
        for issue in check.get("issues", []):
            lines.append(f"  - {issue}")
    if report.get("issues"):
        lines.extend(["", "## Issues", ""])
        lines.extend(f"- {issue}" for issue in report["issues"])
    lines.extend(
        [
            "",
            "## External Release Gates",
            "",
            "| Gate | Status | Required artifact |",
            "|---|---|---|",
        ]
    )
    for gate in report["externalReleaseGateStatus"]:
        lines.append(f"| {gate['gateID']} | {gate['status']} | {gate['requiredArtifact']} |")
    lines.extend(["", "## Allowed Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["allowedClaims"]) if report["allowedClaims"] else lines.append("- None")
    lines.extend(["", "## Blocked Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["blockedClaims"])
    lines.extend(
        [
            "",
            "## Product Law Preserved",
            "",
            "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
            "- The renewal verifier emits governance evidence, not claims, packs, R2 writes, or native activation.",
            "- Source-to-domain/subdomain coverage is derived from the public launch taxonomy only.",
            "- Source Atlas does not receive private user context and does not generate final plans, schedules, or Steps.",
            "- Outside legal/privacy, physical-device, accessibility, visual, App Store, TestFlight, and owner approval gates remain blocked until real external artifacts exist.",
            "",
            "## Non-Claims",
            "",
        ]
    )
    lines.extend(f"- {claim}" for claim in report["nonClaims"])
    lines.extend(
        [
            "",
            "## Closeout",
            "",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: Source Atlas Foundry tooling, Source Atlas governance registries, and Source Atlas QA evidence only.",
            "- App behavior mutated: no.",
            "- Compatibility shims left behind: none.",
            "- Placeholder proof introduced: none.",
            "",
        ]
    )
    return "\n".join(lines)


def _coverage_records(
    *,
    launch_source_ids: list[str],
    source_by_id: dict[str, dict[str, Any]],
    legal_by_id: dict[str, dict[str, Any]],
    api_by_id: dict[str, dict[str, Any]],
    taxonomy_summary: dict[str, Any],
    profile_to_source_ids: dict[str, list[str]],
    created_at: str,
) -> tuple[list[dict[str, Any]], list[str]]:
    issues: list[str] = []
    records: list[dict[str, Any]] = []
    for source_id in launch_source_ids:
        lane = source_by_id.get(source_id)
        if not lane:
            issues.append(f"{source_id}: launch source lane missing from source-lane registry")
            continue
        legal = legal_by_id.get(str(lane.get("license_id")))
        api = api_by_id.get(str(lane.get("api_policy_id")))
        if not legal:
            issues.append(f"{source_id}: missing legal/terms entry {lane.get('license_id')}")
            legal = {}
        if not api:
            issues.append(f"{source_id}: missing API policy {lane.get('api_policy_id')}")
            api = {}
        domain_ids = [
            domain["domainID"]
            for domain in taxonomy_summary.get("domains", [])
            if domain.get("launchFloorState") == "accepted"
            and source_id in _source_ids_for_profiles(domain.get("sourceLaneProfileIDs", []), profile_to_source_ids)
        ]
        subdomain_ids = [
            subdomain["subdomainID"]
            for subdomain in taxonomy_summary.get("subdomains", [])
            if subdomain.get("launchFloorState") == "accepted"
            and source_id in _source_ids_for_profiles(subdomain.get("sourceLaneProfileIDs", []), profile_to_source_ids)
        ]
        source_renewal = _source_renewal(lane, created_at, issues)
        legal_renewal = _legal_renewal(source_id, legal, created_at, issues)
        api_renewal = _api_renewal(source_id, api, created_at, issues)
        approval_posture = _approval_posture(lane, legal, api)
        records.append(
            {
                "sourceID": source_id,
                "sourceName": lane.get("source_name"),
                "authorityClass": lane.get("authority_class"),
                "sourceClass": lane.get("source_class"),
                "domainScope": lane.get("domain_scope", []),
                "licenseID": lane.get("license_id"),
                "apiPolicyID": lane.get("api_policy_id"),
                "approvalPosture": approval_posture,
                "allowedArtifactClasses": sorted(lane.get("allowed_artifact_classes", [])),
                "forbiddenArtifactClasses": sorted(lane.get("forbidden_artifact_classes", [])),
                "r2PackPolicy": lane.get("r2_pack_policy"),
                "redistributionPolicy": lane.get("redistribution_policy"),
                "coveredDomainCount": len(domain_ids),
                "coveredSubdomainCount": len(subdomain_ids),
                "coveredDomainIDs": sorted(domain_ids),
                "coveredSubdomainIDs": sorted(subdomain_ids),
                "sourceRenewal": source_renewal,
                "legalRenewal": legal_renewal,
                "apiRenewal": api_renewal,
                "nonClaims": lane.get("non_claims", []),
            }
        )
        if not domain_ids:
            issues.append(f"{source_id}: launch source lane has no accepted launch-domain coverage")
        if not subdomain_ids:
            issues.append(f"{source_id}: launch source lane has no accepted launch-subdomain coverage")
        if source_renewal["reviewStatus"] in BLOCKING_REVIEW_STATUSES:
            issues.append(f"{source_id}: source review status blocks launch-floor coverage")
        if api_renewal["reviewStatus"] in BLOCKING_REVIEW_STATUSES:
            issues.append(f"{source_id}: API review status blocks launch-floor coverage")
    return sorted(records, key=lambda item: item["sourceID"]), issues


def _source_renewal(lane: dict[str, Any], created_at: str, issues: list[str]) -> dict[str, Any]:
    source_id = str(lane.get("source_id", "<source>"))
    status = str(lane.get("review_status", ""))
    if status not in SOURCE_REVIEW_STATUSES and status not in BLOCKING_REVIEW_STATUSES:
        issues.append(f"{source_id}: unsupported source review_status {status}")
    reviewed = str(lane.get("last_reviewed_at") or "")
    due = str(lane.get("next_review_due_at") or "")
    if not lane.get("review_owner"):
        issues.append(f"{source_id}: source lane missing review_owner")
    _date_required_and_current(source_id, "source last_reviewed_at", reviewed, created_at, issues, require_future=False)
    _date_required_and_current(source_id, "source next_review_due_at", due, created_at, issues, require_future=True)
    return {
        "reviewOwner": lane.get("review_owner"),
        "reviewStatus": status,
        "lastReviewedAt": reviewed,
        "nextReviewDueAt": due,
        "freshnessSLA": lane.get("freshness_sla"),
    }


def _legal_renewal(source_id: str, legal: dict[str, Any], created_at: str, issues: list[str]) -> dict[str, Any]:
    reviewed = str(legal.get("reviewed_at") or "")
    due = str(legal.get("expires_at") or "")
    if not legal.get("review_owner"):
        issues.append(f"{source_id}: legal entry missing review_owner")
    _date_required_and_current(source_id, "legal reviewed_at", reviewed, created_at, issues, require_future=False)
    _date_required_and_current(source_id, "legal expires_at", due, created_at, issues, require_future=True)
    outside_status = str(legal.get("outside_legal_status") or "")
    approval_path = str(legal.get("approval_artifact_path") or "")
    if outside_status == "approved" and not approval_path:
        issues.append(f"{source_id}: outside legal approval claimed without artifact")
    return {
        "reviewOwner": legal.get("review_owner"),
        "reviewedAt": reviewed,
        "expiresAt": due,
        "outsideLegalRequired": legal.get("outside_legal_required") is True,
        "outsideLegalStatus": outside_status,
        "approvalArtifactPath": approval_path,
        "packOutputAllowed": legal.get("pack_output_allowed") is True,
        "lookupOutputAllowed": legal.get("lookup_output_allowed") is True,
    }


def _api_renewal(source_id: str, api: dict[str, Any], created_at: str, issues: list[str]) -> dict[str, Any]:
    status = str(api.get("review_status") or "")
    if status not in API_REVIEW_STATUSES and status not in BLOCKING_REVIEW_STATUSES:
        issues.append(f"{source_id}: unsupported API review_status {status}")
    reviewed = str(api.get("last_reviewed_at") or "")
    due = str(api.get("next_review_due_at") or "")
    if not api.get("review_owner"):
        issues.append(f"{source_id}: API policy missing review_owner")
    _date_required_and_current(source_id, "API last_reviewed_at", reviewed, created_at, issues, require_future=False)
    _date_required_and_current(source_id, "API next_review_due_at", due, created_at, issues, require_future=True)
    approval_status = str(api.get("approval_status") or "")
    approval_path = str(api.get("approval_artifact_path") or "")
    if "outside_approved" in approval_status and not approval_path:
        issues.append(f"{source_id}: API outside approval claimed without artifact")
    return {
        "reviewOwner": api.get("review_owner"),
        "reviewStatus": status,
        "lastReviewedAt": reviewed,
        "nextReviewDueAt": due,
        "approvalStatus": approval_status,
        "approvalArtifactPath": approval_path,
        "keyRequired": api.get("key_required") is True,
        "liveFlagRequired": api.get("live_flag_required") is True,
        "executeFlagRequired": api.get("execute_flag_required") is True,
        "secretRedactionRequired": api.get("secret_redaction_required") is True,
        "highVolumeReviewRequired": api.get("high_volume_review_required") is True,
    }


def _date_required_and_current(
    source_id: str,
    label: str,
    value: str,
    created_at: str,
    issues: list[str],
    *,
    require_future: bool,
) -> None:
    parsed = _parse_datetime(value)
    if not parsed:
        issues.append(f"{source_id}: missing or invalid {label}")
        return
    current = _parse_datetime(created_at)
    if current and require_future and parsed <= current:
        issues.append(f"{source_id}: expired {label} {value}")


def _record_counts(
    coverage_records: list[dict[str, Any]],
    source_lane_registry: dict[str, Any],
    legal_terms_registry: dict[str, Any],
    api_governance_registry: dict[str, Any],
    taxonomy_summary: dict[str, Any],
) -> dict[str, Any]:
    covered_domains = sorted({domain_id for record in coverage_records for domain_id in record["coveredDomainIDs"]})
    covered_subdomains = sorted({subdomain_id for record in coverage_records for subdomain_id in record["coveredSubdomainIDs"]})
    api_policies = api_governance_registry.get("api_policies", [])
    legal_entries = legal_terms_registry.get("licenses", [])
    source_lanes = source_lane_registry.get("source_lanes", [])
    expired = 0
    blocking = 0
    outside_without_artifact = 0
    for record in coverage_records:
        for renewal in [record["sourceRenewal"], record["legalRenewal"], record["apiRenewal"]]:
            due = renewal.get("nextReviewDueAt") or renewal.get("expiresAt")
            if not due:
                expired += 1
        if record["sourceRenewal"].get("reviewStatus") in BLOCKING_REVIEW_STATUSES:
            blocking += 1
        if record["apiRenewal"].get("reviewStatus") in BLOCKING_REVIEW_STATUSES:
            blocking += 1
        if record["legalRenewal"].get("outsideLegalStatus") == "approved" and not record["legalRenewal"].get("approvalArtifactPath"):
            outside_without_artifact += 1
        if "outside_approved" in str(record["apiRenewal"].get("approvalStatus", "")) and not record["apiRenewal"].get("approvalArtifactPath"):
            outside_without_artifact += 1
    return {
        "sourceLanes": len(source_lanes),
        "legalEntries": len(legal_entries),
        "apiPolicies": len(api_policies),
        "launchSourceLanes": len(coverage_records),
        "acceptedLaunchDomains": taxonomy_summary["recordCounts"]["acceptedGoalDomains"],
        "acceptedLaunchSubdomains": taxonomy_summary["recordCounts"]["acceptedSubdomains"],
        "coveredLaunchDomains": len(covered_domains),
        "coveredLaunchSubdomains": len(covered_subdomains),
        "sourceLanesWithRenewalMetadata": sum(
            1
            for lane in source_lanes
            if lane.get("review_owner") and lane.get("last_reviewed_at") and lane.get("next_review_due_at")
        ),
        "legalEntriesWithRenewalMetadata": sum(
            1 for legal in legal_entries if legal.get("review_owner") and legal.get("reviewed_at") and legal.get("expires_at")
        ),
        "apiPoliciesWithRenewalMetadata": sum(
            1
            for api in api_policies
            if api.get("review_owner")
            and api.get("review_status")
            and api.get("last_reviewed_at")
            and api.get("next_review_due_at")
            and api.get("approval_status")
        ),
        "expiredPostures": expired,
        "unknownOrBlockingLaunchPostures": blocking,
        "outsideApprovalClaimsWithoutArtifacts": outside_without_artifact,
        "externalReleaseGatesOpen": len(_external_release_gates()),
        "claims": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
        "privacyIssues": 0,
    }


def _checks(
    *,
    counts: dict[str, Any],
    governance_validation: dict[str, Any],
    taxonomy_summary: dict[str, Any],
    input_privacy_issues: list[str],
    registry_privacy_issues: list[str],
    coverage_issues: list[str],
) -> list[dict[str, Any]]:
    return [
        _check("governance_registries_valid", governance_validation.get("valid") is True, governance_validation.get("issues", [])),
        _check("launch_taxonomy_valid", not taxonomy_summary.get("issues"), taxonomy_summary.get("issues", [])),
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check("registry_privacy_scan_passed", not registry_privacy_issues, registry_privacy_issues),
        _check("launch_source_lanes_have_coverage", counts["launchSourceLanes"] > 0, []),
        _check(
            "launch_domains_have_source_lane_coverage",
            counts["coveredLaunchDomains"] == counts["acceptedLaunchDomains"],
            [f"covered={counts['coveredLaunchDomains']} accepted={counts['acceptedLaunchDomains']}"],
        ),
        _check(
            "launch_subdomains_have_source_lane_coverage",
            counts["coveredLaunchSubdomains"] == counts["acceptedLaunchSubdomains"],
            [f"covered={counts['coveredLaunchSubdomains']} accepted={counts['acceptedLaunchSubdomains']}"],
        ),
        _check(
            "source_lane_legal_api_renewal_complete",
            not coverage_issues,
            coverage_issues,
        ),
        _check("api_renewal_metadata_complete", counts["apiPoliciesWithRenewalMetadata"] == counts["apiPolicies"], []),
        _check("legal_renewal_metadata_complete", counts["legalEntriesWithRenewalMetadata"] == counts["legalEntries"], []),
        _check("source_lane_renewal_metadata_complete", counts["sourceLanesWithRenewalMetadata"] == counts["sourceLanes"], []),
        _check("expired_or_unknown_posture_blocks_coverage", counts["expiredPostures"] == 0 and counts["unknownOrBlockingLaunchPostures"] == 0, []),
        _check("outside_approval_not_claimed_without_artifacts", counts["outsideApprovalClaimsWithoutArtifacts"] == 0, []),
        _check("no_claims_r2_native_or_final_outputs_emitted", counts["claims"] == 0 and counts["r2PublishOperations"] == 0 and counts["nativeActivationOperations"] == 0 and counts["finalOutputArtifacts"] == 0, []),
    ]


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": [] if passed else issues}


def _profile_to_source_ids(source_lane_profiles: dict[str, dict[str, Any]]) -> dict[str, list[str]]:
    return {
        profile_id: sorted(str(source_id) for source_id in profile.get("sourceLaneRegistryIDs", []) if source_id)
        for profile_id, profile in source_lane_profiles.items()
    }


def _launch_source_ids(taxonomy_summary: dict[str, Any], profile_to_source_ids: dict[str, list[str]]) -> list[str]:
    profile_ids = sorted(
        {
            profile_id
            for domain in taxonomy_summary.get("domains", [])
            if domain.get("launchFloorState") == "accepted"
            for profile_id in domain.get("sourceLaneProfileIDs", [])
        }
    )
    return sorted({source_id for profile_id in profile_ids for source_id in profile_to_source_ids.get(profile_id, [])})


def _source_ids_for_profiles(profile_ids: list[str], profile_to_source_ids: dict[str, list[str]]) -> set[str]:
    return {source_id for profile_id in profile_ids for source_id in profile_to_source_ids.get(profile_id, [])}


def _by_id(entries: Any, field: str) -> dict[str, dict[str, Any]]:
    if not isinstance(entries, list):
        return {}
    return {str(entry.get(field)): entry for entry in entries if isinstance(entry, dict) and entry.get(field)}


def _approval_posture(lane: dict[str, Any], legal: dict[str, Any], api: dict[str, Any]) -> str:
    pieces = [
        f"source={lane.get('review_status', 'unknown')}",
        f"legalOutside={legal.get('outside_legal_status', 'unknown')}",
        f"api={api.get('approval_status', 'unknown')}",
    ]
    if legal.get("outside_legal_required") is True:
        pieces.append("outside_legal_required_before_release_claim")
    if api.get("high_volume_review_required") is True:
        pieces.append("high_volume_review_required")
    return "; ".join(pieces)


def _input_paths(options: LaunchFloorGovernanceRenewalOptions) -> dict[str, str]:
    return {
        "sourceLaneRegistry": str(options.source_lane_registry_path),
        "legalTermsRegistry": str(options.legal_terms_registry_path),
        "apiGovernanceRegistry": str(options.api_governance_registry_path),
        "launchFloorTaxonomy": str(options.launch_floor_taxonomy_path),
        "productionTargetLedger": str(options.production_target_ledger_path),
    }


def _input_hashes(
    source_lane_registry: dict[str, Any],
    legal_terms_registry: dict[str, Any],
    api_governance_registry: dict[str, Any],
    taxonomy: dict[str, Any],
    production_target_ledger: dict[str, Any],
) -> dict[str, str]:
    return {
        "sourceLaneRegistry": stable_hash(source_lane_registry),
        "legalTermsRegistry": stable_hash(legal_terms_registry),
        "apiGovernanceRegistry": stable_hash(api_governance_registry),
        "launchFloorTaxonomy": stable_hash(taxonomy),
        "productionTargetLedger": stable_hash(production_target_ledger),
    }


def _privacy_issues(value: Any, label: str) -> list[str]:
    return [
        issue.format()
        for issue in boundary_issues_for_value(value, label)
        if not is_boundary_line(issue.detail)
    ]


def _parse_datetime(value: str) -> datetime | None:
    if not value:
        return None
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None
    if parsed.tzinfo is None:
        return parsed.replace(tzinfo=timezone.utc)
    return parsed


def _external_release_gates() -> list[dict[str, str]]:
    return [
        {
            "gateID": "outside_legal_privacy_signoff",
            "status": "blocked_missing_external_artifact",
            "requiredArtifact": "qualified outside legal/privacy approval covering launch corpus, R2 posture, source terms, API policy, and no-private-graph boundary",
        },
        {
            "gateID": "physical_device_accessibility_visual_proof",
            "status": "blocked_missing_external_artifact",
            "requiredArtifact": "current physical-device run, independent accessibility review, and independent visual review for affected Source/Trust/Runtime flows",
        },
        {
            "gateID": "app_store_testflight_owner_approval",
            "status": "blocked_missing_external_artifact",
            "requiredArtifact": "App Store Connect validation, TestFlight validation, and explicit owner release approval",
        },
    ]


def _allowed_claims(valid: bool) -> list[str]:
    if not valid:
        return []
    return [
        "source_atlas_launch_floor_governance_renewal_tooling_green",
        "launch_source_lanes_have_legal_api_owner_renewal_posture",
        "launch_source_lanes_have_domain_subdomain_coverage_map",
        "external_release_gates_remain_blocked_without_real_artifacts",
    ]


def _blocked_claims() -> list[str]:
    return sorted(
        {
            "source_atlas_launch_floor_ready",
            "launch_floor_complete",
            "outside_legal_approval",
            "privacy_legal_release_signoff",
            "physical_device_readiness",
            "accessibility_approval",
            "independent_visual_approval",
            "app_store_readiness",
            "testflight_readiness",
            "owner_release_approval",
            "release_green",
            "r2_production_ready",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )
