"""Production target readiness ledger for Source Atlas.

This ledger discovers current evidence across coverage frontiers, claim graphs,
pack production, R2 publishing, public gateway release, and native refresh
artifacts. It is intentionally claim-scoped: it can prove bounded readiness for
configured frontiers, and it must surface orphan or incomplete production
evidence instead of letting broad Source Atlas claims outrun proof.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issues_for_value, is_boundary_line
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, write_json
from .r2_public_gateway_release import discover_production_publisher_reports


PRODUCTION_TARGET_LEDGER_VERSION = "source-atlas-production-target-ledger-train-84"
PRODUCTION_TARGET_LEDGER_KIND = "ambitions.sourceAtlas.productionTargetLedger.v1"
PACK_READY_POLICIES = {"pack_allowed", "pack_allowed_with_attribution"}
STATUS_RANK = {
    "not_started": 0,
    "candidate_only": 1,
    "source_review_ready": 2,
    "adapter_ready": 3,
    "claim_graph_ready": 4,
    "pack_staging_ready": 5,
    "r2_stable_ready": 6,
    "app_runtime_ready": 7,
    "production_ready": 8,
}
PRODUCTION_TARGET_LEDGER_NON_CLAIMS = [
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not App Store or TestFlight readiness",
    "not physical-device proof",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    "not approval for future domains without source/frontier/pack/R2/native evidence",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class ProductionTargetLedgerOptions:
    frontier_config_path: Path
    source_lane_registry_path: Path
    claim_frontier_report_root: Path
    pack_production_report_root: Path
    r2_publisher_report_root: Path
    output_root: Path
    gateway_release_report_path: Path | None = None
    native_registry_report_path: Path | None = None
    native_registry_artifact_path: Path | None = None
    native_runtime_closeout_path: Path | None = None
    created_at: str = "2026-06-28T00:00:00Z"


def build_production_target_ledger(options: ProductionTargetLedgerOptions) -> dict[str, Any]:
    """Build and write a deterministic production target readiness ledger."""

    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    frontier_config = _read_json_if_exists(options.frontier_config_path)
    source_lane_registry = _read_json_if_exists(options.source_lane_registry_path)
    claim_reports = _discover_claim_frontier_reports(options.claim_frontier_report_root)
    pack_reports = _discover_pack_production_reports(options.pack_production_report_root)
    r2_discovery = discover_production_publisher_reports(options.r2_publisher_report_root)
    r2_reports = _selected_r2_reports(r2_discovery)
    gateway_report = _read_json_if_exists(options.gateway_release_report_path)
    native_registry_report = _read_json_if_exists(options.native_registry_report_path)
    native_registry_artifact = _native_registry_artifact(options, native_registry_report)
    native_runtime_closeout = _read_json_if_exists(options.native_runtime_closeout_path)

    evidence_bundle = {
        "frontierConfig": frontier_config,
        "sourceLaneRegistry": source_lane_registry,
        "claimReports": claim_reports,
        "packReports": pack_reports,
        "r2Discovery": r2_discovery,
        "gatewayReleaseReport": gateway_report,
        "nativeRegistryReport": native_registry_report,
        "nativeRegistryArtifact": native_registry_artifact,
        "nativeRuntimeCloseout": native_runtime_closeout,
    }
    privacy_issues = [
        issue.format()
        for issue in boundary_issues_for_value(evidence_bundle, "source-atlas-production-target-ledger")
        if not _allowed_boundary_issue_detail(issue.detail)
    ]

    configured_frontiers = _configured_frontiers(frontier_config)
    source_lanes = _source_lanes_by_id(source_lane_registry)
    claim_by_domain = _best_claim_frontiers_by_domain(claim_reports)
    pack_by_domain = _best_pack_reports_by_domain(pack_reports)
    r2_by_domain = _r2_reports_by_domain(r2_reports)
    gateway_domains = _gateway_ready_domains(gateway_report)
    native_registry_domains = _native_registry_domains(native_registry_report, native_registry_artifact)
    native_runtime_ready = _native_runtime_ready(native_runtime_closeout)

    all_domains = sorted(
        set(configured_frontiers)
        | set(claim_by_domain)
        | set(pack_by_domain)
        | set(r2_by_domain)
        | gateway_domains
        | native_registry_domains
    )
    domains = [
        _domain_ledger(
            domain=domain,
            frontier=configured_frontiers.get(domain),
            source_lanes=source_lanes,
            claim_report=claim_by_domain.get(domain),
            pack_report=pack_by_domain.get(domain),
            r2_report=r2_by_domain.get(domain),
            gateway_ready=domain in gateway_domains,
            native_registry_ready=domain in native_registry_domains,
            native_runtime_ready=native_runtime_ready,
        )
        for domain in all_domains
    ]

    orphan_domains = sorted(domain["domainID"] for domain in domains if not domain["frontierConfigured"])
    ready_domains = sorted(
        domain["domainID"]
        for domain in domains
        if domain["readinessStatus"] == "bounded_production_target_ready"
    )
    configured_domains = sorted(configured_frontiers)
    configured_not_ready = sorted(set(configured_domains) - set(ready_domains))
    global_blockers = _global_blockers(orphan_domains, configured_not_ready, privacy_issues, r2_discovery, domains)
    allowed_claims = []
    if configured_domains and not configured_not_ready and not orphan_domains and not privacy_issues:
        allowed_claims.append("bounded_production_target_for_configured_frontiers")
    if ready_domains:
        allowed_claims.append("bounded_production_target_per_ready_frontier")

    report_path = output_root / "production-target-ledger.json"
    markdown_path = output_root / "production-target-ledger.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": PRODUCTION_TARGET_LEDGER_KIND,
        "versionID": PRODUCTION_TARGET_LEDGER_VERSION,
        "createdAt": options.created_at,
        "ledgerID": f"source-atlas/production-target-ledger/{stable_hash({'domains': domains, 'blockers': global_blockers})[:16]}",
        "status": "Source Green for production target ledger" if not privacy_issues else "Red",
        "valid": not privacy_issues,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; bounded configured-frontier production target ledger only",
        "overallReadinessStatus": "configured_frontiers_bounded_production_target_ready"
        if allowed_claims == [
            "bounded_production_target_for_configured_frontiers",
            "bounded_production_target_per_ready_frontier",
        ]
        else "blocked_or_partial",
        "universalCoverageClaimAllowed": False,
        "allowedClaims": allowed_claims,
        "blockedClaims": sorted(
            {
                "literal_universal_coverage",
                "full_source_atlas_green",
                "outside_legal_approval",
                "release_green",
                "app_store_readiness",
                *("configured_frontier_production_target" for _ in configured_not_ready),
            }
        ),
        "recordCounts": {
            "configuredFrontiers": len(configured_domains),
            "discoveredDomains": len(all_domains),
            "productionR2Domains": len(r2_by_domain),
            "gatewayReadyDomains": len(gateway_domains),
            "nativeRegistryDomains": len(native_registry_domains),
            "boundedProductionTargetReady": len(ready_domains),
            "orphanProductionDomains": len(orphan_domains),
            "configuredDomainsNotReady": len(configured_not_ready),
        },
        "domains": domains,
        "orphanProductionDomains": orphan_domains,
        "configuredDomainsNotReady": configured_not_ready,
        "globalBlockers": global_blockers,
        "evidencePaths": _evidence_paths(options),
        "r2Discovery": {
            "totalReportCount": r2_discovery.get("totalReportCount", 0),
            "selectedReportCount": r2_discovery.get("selectedReportCount", 0),
            "skippedReportCount": len(r2_discovery.get("skippedReports", [])),
            "supersededReportCount": len(r2_discovery.get("supersededReports", [])),
            "issues": r2_discovery.get("issues", []),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "nonClaims": PRODUCTION_TARGET_LEDGER_NON_CLAIMS,
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
        },
    }
    write_json(report_path, report)
    markdown = production_target_ledger_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def production_target_ledger_markdown(report: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Production Target Ledger Train 84",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Universal coverage claim allowed: {'yes' if report['universalCoverageClaimAllowed'] else 'no'}",
        "",
        "## Domain Ledger",
        "",
        "| Domain | Readiness | Frontier | Claim | Pack | R2 | Gateway | Native | Blockers |",
        "| --- | --- | --- | --- | --- | --- | --- | --- | --- |",
    ]
    for domain in report["domains"]:
        blockers = "<br>".join(domain["blockedReasons"])
        lines.append(
            "| {domain} | {readiness} | {frontier} | {claim} | {pack} | {r2} | {gateway} | {native} | {blockers} |".format(
                domain=domain["domainID"],
                readiness=domain["readinessStatus"],
                frontier="yes" if domain["frontierConfigured"] else "no",
                claim="yes" if domain["claimGraphProofComplete"] else "no",
                pack="yes" if domain["packProductionProofComplete"] else "no",
                r2="yes" if domain["r2ProductionProofComplete"] else "no",
                gateway="yes" if domain["gatewayProofComplete"] else "no",
                native="yes" if domain["nativeUsabilityProofComplete"] else "no",
                blockers=blockers,
            )
        )
    lines.extend(["", "## Global Blockers", ""])
    lines.extend(f"- {blocker}" for blocker in report["globalBlockers"])
    lines.extend(["", "## Allowed Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["allowedClaims"])
    lines.extend(["", "## Production Non-Claims", ""])
    lines.extend(f"- {claim}" for claim in report["nonClaims"])
    lines.extend(
        [
            "",
            "## Closeout",
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Ledger evidence is source/frontier/pack/R2/gateway/native proof metadata only.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, or personalized paths.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Compatibility shims left behind: none.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Rollback plan:",
            "- Revert the Train 84 ledger module, CLI wiring, focused tests, generated ledger artifacts, QA evidence, and the StatCan frontier config addition if needed.",
            "",
        ]
    )
    return "\n".join(lines)


def _domain_ledger(
    *,
    domain: str,
    frontier: dict[str, Any] | None,
    source_lanes: dict[str, dict[str, Any]],
    claim_report: dict[str, Any] | None,
    pack_report: dict[str, Any] | None,
    r2_report: dict[str, Any] | None,
    gateway_ready: bool,
    native_registry_ready: bool,
    native_runtime_ready: bool,
) -> dict[str, Any]:
    source_ids = sorted(_list_value(frontier, "source_ids"))
    source_blockers = _source_lane_blockers(source_ids, source_lanes)
    claim_ready = _claim_report_ready(claim_report)
    pack_ready = _pack_report_ready(pack_report)
    r2_ready = _r2_report_ready(r2_report)
    native_ready = native_registry_ready and native_runtime_ready
    blocked = []
    if frontier is None:
        blocked.append("frontier_config_missing")
    if source_blockers:
        blocked.extend(source_blockers)
    if not claim_ready:
        blocked.append("claim_frontier_proof_missing_or_incomplete")
    if not pack_ready:
        blocked.append("pack_production_proof_missing_or_incomplete")
    if not r2_ready:
        blocked.append("production_r2_upload_readback_missing_or_incomplete")
    if not gateway_ready:
        blocked.append("public_gateway_live_verification_missing_or_incomplete")
    if not native_registry_ready:
        blocked.append("native_refresh_registry_target_missing_or_inactive")
    if not native_runtime_ready:
        blocked.append("native_runtime_boundary_proof_missing_or_incomplete")

    if not blocked:
        readiness = "bounded_production_target_ready"
    elif frontier is None and r2_ready:
        readiness = "orphan_production_evidence_blocked"
    elif r2_ready:
        readiness = "production_r2_ready_but_not_native_or_frontier_ready"
    elif pack_ready:
        readiness = "pack_production_ready"
    elif claim_ready:
        readiness = "claim_graph_ready"
    else:
        readiness = "not_ready"

    return {
        "domainID": domain,
        "frontierConfigured": frontier is not None,
        "sourceIDs": source_ids,
        "configuredStatusCeiling": (frontier or {}).get("status_ceiling"),
        "claimGraphProofComplete": claim_ready,
        "claimGraphStatus": (claim_report or {}).get("status"),
        "packableClaimCount": _int_value(claim_report, "packable_claim_count"),
        "packProductionProofComplete": pack_ready,
        "packProductionPath": (pack_report or {}).get("_path"),
        "r2ProductionProofComplete": r2_ready,
        "r2PublisherPath": (r2_report or {}).get("_path"),
        "gatewayProofComplete": gateway_ready,
        "nativeRegistryProofComplete": native_registry_ready,
        "nativeRuntimeBoundaryProofComplete": native_runtime_ready,
        "nativeUsabilityProofComplete": native_ready,
        "readinessStatus": readiness,
        "allowedClaimScopes": ["bounded_production_target"] if readiness == "bounded_production_target_ready" else [],
        "blockedReasons": sorted(set(blocked)),
        "nonClaims": [
            "not universal coverage",
            "not Release Green",
            "not outside legal approval",
            "not final user plans, schedules, or Steps",
        ],
    }


def _discover_claim_frontier_reports(root: Path) -> list[dict[str, Any]]:
    reports = []
    for path in sorted(root.glob("**/coverage-frontier-report.json")) if root.exists() else []:
        report = _read_json_if_exists(path)
        if isinstance(report, dict):
            report["_path"] = str(path)
            reports.append(report)
    return reports


def _discover_pack_production_reports(root: Path) -> list[dict[str, Any]]:
    reports = []
    for path in sorted(root.glob("**/pack-production-report.json")) if root.exists() else []:
        report = _read_json_if_exists(path)
        if isinstance(report, dict):
            report["_path"] = str(path)
            reports.append(report)
    return reports


def _selected_r2_reports(discovery: dict[str, Any]) -> list[dict[str, Any]]:
    reports = []
    for path_text in discovery.get("selectedPublisherReports", []):
        path = Path(path_text)
        report = _read_json_if_exists(path)
        if isinstance(report, dict):
            report["_path"] = str(path)
            reports.append(report)
    return reports


def _configured_frontiers(frontier_config: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(frontier_config, dict):
        return {}
    return {
        str(item.get("frontier_id")): item
        for item in frontier_config.get("frontiers", [])
        if isinstance(item, dict) and isinstance(item.get("frontier_id"), str)
    }


def _source_lanes_by_id(registry: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(registry, dict):
        return {}
    return {
        str(item.get("source_id")): item
        for item in registry.get("source_lanes", [])
        if isinstance(item, dict) and isinstance(item.get("source_id"), str)
    }


def _best_claim_frontiers_by_domain(reports: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    best: dict[str, dict[str, Any]] = {}
    for report in reports:
        path = report.get("_path")
        for frontier in report.get("frontiers", []):
            if not isinstance(frontier, dict):
                continue
            domain = str(frontier.get("frontier_id") or frontier.get("domain") or "")
            if not domain:
                continue
            candidate = dict(frontier)
            candidate["_path"] = path
            if _claim_sort_key(candidate) >= _claim_sort_key(best.get(domain)):
                best[domain] = candidate
    return best


def _best_pack_reports_by_domain(reports: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    best: dict[str, dict[str, Any]] = {}
    for report in reports:
        domain = str(report.get("domain") or _frontier_id_from_pack_id(str(report.get("packID", ""))))
        if not domain:
            continue
        if _pack_report_ready(report) and _report_sort_key(report) >= _report_sort_key(best.get(domain)):
            best[domain] = report
    return best


def _r2_reports_by_domain(reports: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    ready: dict[str, dict[str, Any]] = {}
    for report in reports:
        domain = _frontier_id_from_pack_id(str(report.get("packID", "")))
        if domain and _r2_report_ready(report):
            ready[domain] = report
    return ready


def _gateway_ready_domains(report: Any) -> set[str]:
    if not isinstance(report, dict) or report.get("valid") is not True:
        return set()
    live = report.get("liveVerification")
    if not isinstance(live, dict) or live.get("valid") is not True:
        return set()
    if not (live.get("headChecksPassed") and live.get("publicChecksPassed") and live.get("blockedChecksPassed")):
        return set()
    domains: set[str] = set()
    for selected in report.get("discovery", {}).get("selectedReports", []):
        if isinstance(selected, dict) and isinstance(selected.get("domainID"), str):
            domains.add(selected["domainID"])
    return domains


def _native_registry_domains(report: Any, artifact: Any) -> set[str]:
    if not isinstance(report, dict) or report.get("valid") is not True:
        return set()
    if not isinstance(artifact, dict) or artifact.get("publicReferenceOnly") is not True:
        return set()
    domains: set[str] = set()
    for entry in artifact.get("registry", {}).get("entries", []):
        if not isinstance(entry, dict) or entry.get("status") != "active":
            continue
        target = entry.get("target", {})
        if isinstance(target, dict) and isinstance(target.get("domainID"), str):
            domains.add(target["domainID"])
    return domains


def _native_registry_artifact(options: ProductionTargetLedgerOptions, report: Any) -> Any:
    if options.native_registry_artifact_path:
        return _read_json_if_exists(options.native_registry_artifact_path)
    if isinstance(report, dict):
        artifact_path = report.get("outputPaths", {}).get("artifact")
        if isinstance(artifact_path, str):
            return _read_json_if_exists(Path(artifact_path))
    return None


def _native_runtime_ready(closeout: Any) -> bool:
    if not isinstance(closeout, dict):
        return False
    xcode = closeout.get("xcodeBuildMCP")
    proof_summary = closeout.get("proofSummary")
    if isinstance(xcode, dict) and isinstance(proof_summary, dict):
        return (
            xcode.get("result") == "SUCCEEDED"
            and int(xcode.get("passed", 0)) > 0
            and int(xcode.get("failed", 1)) == 0
            and int(xcode.get("skipped", 1)) == 0
            and bool(closeout.get("configuredFrontiers"))
            and bool(proof_summary.get("r2RequestPrivacyProof"))
            and bool(proof_summary.get("noPrivateGraphEgressProof"))
            and bool(proof_summary.get("nativeOfflineNoAccountProof"))
        )
    status = str(closeout.get("status", ""))
    counts = closeout.get("record_counts", {})
    return (
        "Native Boundary Green" in status
        and isinstance(counts, dict)
        and int(counts.get("passed", 0)) > 0
        and int(counts.get("failed", 1)) == 0
        and bool(closeout.get("r2_request_privacy_proof"))
        and bool(closeout.get("no_private_graph_egress_proof"))
        and bool(closeout.get("native_offline_no_account_proof"))
    )


def _claim_report_ready(report: dict[str, Any] | None) -> bool:
    if not isinstance(report, dict):
        return False
    return (
        str(report.get("status")) in {"claim_graph_ready", "pack_staging_ready", "r2_stable_ready", "app_runtime_ready", "production_ready"}
        and _int_value(report, "packable_claim_count") > 0
        and _nested_bool(report, "legal_posture_completeness", "complete")
        and _nested_bool(report, "provenance_completeness", "complete")
        and _nested_bool(report, "authority_coverage", "complete")
        and not _list_value(report, "missing_claim_classes")
        and str(report.get("gold_set_status", "not_required")) in {"passed", "complete", "present", "not_required"}
    )


def _pack_report_ready(report: dict[str, Any] | None) -> bool:
    if not isinstance(report, dict):
        return False
    return (
        report.get("valid") is True
        and report.get("environment") == "production"
        and report.get("channel") == "stable"
        and report.get("artifactValidation", {}).get("valid") is True
        and report.get("legalTermsApprovalPacketValidation", {}).get("valid") is True
        and report.get("nonPrivateScan", {}).get("passed") is True
    )


def _r2_report_ready(report: dict[str, Any] | None) -> bool:
    if not isinstance(report, dict):
        return False
    return (
        report.get("valid") is True
        and report.get("environment") == "production"
        and report.get("channel") == "stable"
        and report.get("mode") == "remote_r2"
        and report.get("productionR2Uploaded") is True
        and report.get("operation", {}).get("success") is True
    )


def _source_lane_blockers(source_ids: list[str], source_lanes: dict[str, dict[str, Any]]) -> list[str]:
    blockers = []
    for source_id in source_ids:
        lane = source_lanes.get(source_id)
        if not lane:
            blockers.append(f"{source_id}: source_lane_missing")
            continue
        if lane.get("review_status") != "reviewed":
            blockers.append(f"{source_id}: source_lane_not_reviewed")
        if lane.get("r2_pack_policy") not in PACK_READY_POLICIES:
            blockers.append(f"{source_id}: r2_pack_policy_not_allowed")
    return blockers


def _global_blockers(
    orphan_domains: list[str],
    configured_not_ready: list[str],
    privacy_issues: list[str],
    r2_discovery: dict[str, Any],
    domains: list[dict[str, Any]],
) -> list[str]:
    blockers = []
    blockers.extend(f"{domain}: production evidence exists without configured frontier" for domain in orphan_domains)
    blockers.extend(f"{domain}: configured frontier is not production target ready" for domain in configured_not_ready)
    blockers.extend(f"privacy: {issue}" for issue in privacy_issues)
    blockers.extend(f"r2_discovery: {issue}" for issue in r2_discovery.get("issues", []))
    if any(domain["readinessStatus"] != "bounded_production_target_ready" for domain in domains):
        blockers.append("not all discovered/configured domains are bounded production target ready")
    blockers.append("literal universal coverage remains blocked by Source Atlas product law")
    return sorted(set(blockers))


def _read_json_if_exists(path: Path | None) -> Any:
    if path is None or not path.exists():
        return None
    return read_json(path)


def _claim_sort_key(report: dict[str, Any] | None) -> tuple[int, int, str]:
    if not isinstance(report, dict):
        return (-1, -1, "")
    return (
        STATUS_RANK.get(str(report.get("status", "")), 0),
        _int_value(report, "packable_claim_count"),
        str(report.get("_path", "")),
    )


def _report_sort_key(report: dict[str, Any] | None) -> tuple[str, str, str]:
    if not isinstance(report, dict):
        return ("", "", "")
    return (str(report.get("createdAt", "")), str(report.get("packID", "")), str(report.get("_path", "")))


def _frontier_id_from_pack_id(pack_id: str) -> str:
    marker = "source-atlas/v1/domain/"
    if marker not in pack_id:
        return ""
    return pack_id.split(marker, 1)[1].split("/", 1)[0]


def _nested_bool(container: dict[str, Any] | None, key: str, nested_key: str) -> bool:
    if not isinstance(container, dict):
        return False
    nested = container.get(key)
    return isinstance(nested, dict) and nested.get(nested_key) is True


def _list_value(container: dict[str, Any] | None, key: str) -> list[str]:
    if not isinstance(container, dict):
        return []
    value = container.get(key, [])
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if isinstance(item, (str, int, float))]


def _int_value(container: dict[str, Any] | None, key: str) -> int:
    if not isinstance(container, dict):
        return 0
    try:
        return int(container.get(key, 0))
    except (TypeError, ValueError):
        return 0


def _evidence_paths(options: ProductionTargetLedgerOptions) -> dict[str, str | None]:
    return {
        "frontierConfig": str(options.frontier_config_path),
        "sourceLaneRegistry": str(options.source_lane_registry_path),
        "claimFrontierReportRoot": str(options.claim_frontier_report_root),
        "packProductionReportRoot": str(options.pack_production_report_root),
        "r2PublisherReportRoot": str(options.r2_publisher_report_root),
        "gatewayReleaseReport": str(options.gateway_release_report_path) if options.gateway_release_report_path else None,
        "nativeRegistryReport": str(options.native_registry_report_path) if options.native_registry_report_path else None,
        "nativeRegistryArtifact": str(options.native_registry_artifact_path) if options.native_registry_artifact_path else None,
        "nativeRuntimeCloseout": str(options.native_runtime_closeout_path) if options.native_runtime_closeout_path else None,
    }


def _allowed_boundary_issue_detail(detail: str) -> bool:
    lowered = detail.lower()
    return is_boundary_line(detail) or (
        lowered.startswith("no goal text")
        and "private life graph" in lowered
        and "source atlas/r2" in lowered
    ) or (
        lowered.startswith("no tests send")
        and "private life graph" in lowered
        and "source atlas/r2" in lowered
    )
