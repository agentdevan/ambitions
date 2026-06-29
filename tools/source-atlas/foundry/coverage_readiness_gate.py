"""Coverage readiness gate for Source Atlas frontier claims.

The coverage frontier compiler measures domain progress. This gate turns those
measurements plus R2/native/legal evidence into a claim ledger so broad
Source Atlas wording cannot outrun current proof.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .legal_release_claim_gate import _live_transport_proven, _production_r2_write_proven
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, utc_now, write_json


COVERAGE_READINESS_GATE_KIND = "ambitions.sourceAtlas.coverageReadinessGate.v1"
COVERAGE_READINESS_GATE_VERSION = "source-atlas-coverage-readiness-gate-train-41"
PACK_READY_POLICIES = {"pack_allowed", "pack_allowed_with_attribution"}


def build_coverage_readiness_gate(
    *,
    frontier_config: dict[str, Any],
    source_lane_registry: dict[str, Any],
    claim_frontier_reports: list[dict[str, Any]] | None = None,
    domain_scorecards: dict[str, Any] | None = None,
    r2_report: dict[str, Any] | None = None,
    r2_reports: list[dict[str, Any]] | None = None,
    gateway_readback_reports: list[dict[str, Any]] | None = None,
    native_transport_report: dict[str, Any] | None = None,
    legal_release_claim_gate: dict[str, Any] | None = None,
    evidence_paths: dict[str, str] | None = None,
    created_at: str | None = None,
    output_path: Path | None = None,
) -> dict[str, Any]:
    """Build a deterministic per-frontier readiness ledger."""

    created = created_at or utc_now()
    paths = evidence_paths or {}
    reports = claim_frontier_reports or []
    gate_issues = _gate_issues(
        frontier_config=frontier_config,
        source_lane_registry=source_lane_registry,
        claim_frontier_reports=reports,
        domain_scorecards=domain_scorecards,
        r2_report=r2_report,
        r2_reports=r2_reports,
        gateway_readback_reports=gateway_readback_reports,
        native_transport_report=native_transport_report,
        legal_release_claim_gate=legal_release_claim_gate,
    )
    frontiers = sorted(_frontier_entries(frontier_config), key=lambda item: item.get("frontier_id", ""))
    source_lanes_by_id = _source_lanes_by_id(source_lane_registry)
    claim_reports_by_frontier = _best_claim_reports_by_frontier(reports)
    scorecards_by_frontier = _scorecards_by_frontier(domain_scorecards)
    legal_allowed = set(_list_value(legal_release_claim_gate, "allowedClaims"))
    production_r2_by_frontier = _production_r2_reports_by_frontier([r2_report, *(r2_reports or [])])
    gateway_by_frontier = _gateway_readback_reports_by_frontier(gateway_readback_reports or [])
    native_ok = _live_transport_proven(native_transport_report)
    native_frontiers = _native_transport_frontiers(native_transport_report) if native_ok else set()

    frontier_ledgers = [
        _evaluate_frontier(
            frontier=frontier,
            source_lanes_by_id=source_lanes_by_id,
            claim_report=claim_reports_by_frontier.get(frontier.get("frontier_id")),
            scorecard=scorecards_by_frontier.get(frontier.get("frontier_id")),
            production_r2_proven=str(frontier.get("frontier_id")) in production_r2_by_frontier,
            gateway_transport_proven=str(frontier.get("frontier_id")) in gateway_by_frontier,
            native_transport_proven=str(frontier.get("frontier_id")) in native_frontiers,
            legal_allowed=legal_allowed,
        )
        for frontier in frontiers
    ]
    universal_issues = _universal_coverage_issues(frontier_ledgers)
    allowed_claims = sorted(
        {
            scope
            for frontier in frontier_ledgers
            for scope in frontier.get("allowedClaimScopes", [])
        }
    )
    blocked_claims = ["universal_coverage"]
    if any(frontier["readinessStatus"] != "bounded_production_target_ready" for frontier in frontier_ledgers):
        blocked_claims.append("source_atlas_runtime_green")
        blocked_claims.append("release_green")

    packet = {
        "schemaVersion": 1,
        "kind": COVERAGE_READINESS_GATE_KIND,
        "versionID": COVERAGE_READINESS_GATE_VERSION,
        "gateID": f"source-atlas/coverage-readiness-gate/{stable_hash({'frontiers': frontier_ledgers})[:16]}",
        "createdAt": created,
        "status": "Source Green for coverage readiness gate" if not gate_issues else "Red",
        "valid": not gate_issues,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; per-frontier readiness only",
        "universalCoverageClaimAllowed": False,
        "universalCoverageIssues": universal_issues,
        "allowedClaims": allowed_claims,
        "blockedClaims": sorted(set(blocked_claims)),
        "frontiers": frontier_ledgers,
        "recordCounts": {
            "configuredFrontiers": len(frontier_ledgers),
            "boundedProductionTargetReady": sum(
                1 for item in frontier_ledgers if item["readinessStatus"] == "bounded_production_target_ready"
            ),
            "boundedProductionR2Ready": sum(
                1 for item in frontier_ledgers if item["readinessStatus"] == "bounded_production_r2_ready"
            ),
            "claimGraphReady": sum(1 for item in frontier_ledgers if item["readinessStatus"] == "claim_graph_ready"),
            "candidateOnlyOrNotStarted": sum(
                1 for item in frontier_ledgers if item["readinessStatus"] in {"candidate_only", "not_started"}
            ),
            "packReadyFrontiers": sum(1 for item in frontier_ledgers if item["packOutputAllowed"]),
            "gatewayReadyFrontiers": sum(1 for item in frontier_ledgers if item["gatewayTransportProofComplete"]),
            "runtimeReadyFrontiers": sum(1 for item in frontier_ledgers if item["nativeTransportProofComplete"]),
        },
        "evidencePaths": paths,
        "gateIssues": gate_issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": [
            "not universal coverage",
            "not full Source Atlas Green",
            "not Release Green",
            "not Visual Green",
            "not App Store readiness",
            "not outside legal approval",
            "not final user plans, schedules, or Steps",
            *NON_CLAIMS,
        ],
    }
    if output_path:
        write_json(output_path, packet)
        output_path.with_suffix(".md").write_text(coverage_readiness_gate_markdown(packet), encoding="utf-8")
    return packet


def build_coverage_readiness_gate_from_paths(
    *,
    frontier_config_path: Path,
    source_lane_registry_path: Path,
    claim_frontier_report_paths: list[Path] | None = None,
    domain_scorecards_path: Path | None = None,
    r2_report_path: Path | None = None,
    r2_report_paths: list[Path] | None = None,
    gateway_readback_report_paths: list[Path] | None = None,
    native_transport_report_path: Path | None = None,
    legal_release_claim_gate_path: Path | None = None,
    created_at: str | None = None,
    output_path: Path | None = None,
) -> dict[str, Any]:
    """Load evidence paths and build the gate packet."""

    claim_paths = claim_frontier_report_paths or []
    evidence_paths = {
        "frontier_config": str(frontier_config_path),
        "source_lane_registry": str(source_lane_registry_path),
    }
    if claim_paths:
        evidence_paths["claim_frontier_reports"] = ", ".join(str(path) for path in claim_paths)
    if domain_scorecards_path:
        evidence_paths["domain_scorecards"] = str(domain_scorecards_path)
    r2_paths = r2_report_paths or []
    if r2_report_path:
        evidence_paths["r2_report"] = str(r2_report_path)
    if r2_paths:
        evidence_paths["r2_reports"] = ", ".join(str(path) for path in r2_paths)
    gateway_paths = gateway_readback_report_paths or []
    if gateway_paths:
        evidence_paths["gateway_readback_reports"] = ", ".join(str(path) for path in gateway_paths)
    if native_transport_report_path:
        evidence_paths["native_transport_report"] = str(native_transport_report_path)
    if legal_release_claim_gate_path:
        evidence_paths["legal_release_claim_gate"] = str(legal_release_claim_gate_path)

    return build_coverage_readiness_gate(
        frontier_config=read_json(frontier_config_path),
        source_lane_registry=read_json(source_lane_registry_path),
        claim_frontier_reports=[read_json(path) for path in claim_paths],
        domain_scorecards=read_json(domain_scorecards_path) if domain_scorecards_path else None,
        r2_report=read_json(r2_report_path) if r2_report_path else None,
        r2_reports=[read_json(path) for path in r2_paths],
        gateway_readback_reports=[read_json(path) for path in gateway_paths],
        native_transport_report=read_json(native_transport_report_path) if native_transport_report_path else None,
        legal_release_claim_gate=read_json(legal_release_claim_gate_path) if legal_release_claim_gate_path else None,
        evidence_paths=evidence_paths,
        created_at=created_at,
        output_path=output_path,
    )


def coverage_readiness_gate_markdown(packet: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Coverage Readiness Gate",
        "",
        f"Status: {packet['status']}",
        f"Source Atlas status ceiling: {packet['sourceAtlasStatusCeiling']}",
        f"Universal coverage claim allowed: {'yes' if packet['universalCoverageClaimAllowed'] else 'no'}",
        "",
        "| Frontier | Readiness | Pack | Gateway | Native | Allowed claim scopes | Blockers |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]
    for frontier in packet["frontiers"]:
        scopes = "<br>".join(f"`{scope}`" for scope in frontier["allowedClaimScopes"]) or ""
        blockers = "<br>".join(frontier["blockedReasons"]) or ""
        lines.append(
            "| {frontier} | {readiness} | {pack} | {gateway} | {native} | {scopes} | {blockers} |".format(
                frontier=frontier["frontierID"],
                readiness=frontier["readinessStatus"],
                pack="yes" if frontier["packOutputAllowed"] else "no",
                gateway="yes" if frontier["gatewayTransportProofComplete"] else "no",
                native="yes" if frontier["nativeTransportProofComplete"] else "no",
                scopes=scopes,
                blockers=blockers,
            )
        )
    lines.extend(["", "## Universal Coverage Blockers", ""])
    lines.extend(f"- {issue}" for issue in packet["universalCoverageIssues"])
    lines.extend(["", "## Non-Claims", ""])
    lines.extend(f"- {claim}" for claim in packet["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _evaluate_frontier(
    *,
    frontier: dict[str, Any],
    source_lanes_by_id: dict[str, dict[str, Any]],
    claim_report: dict[str, Any] | None,
    scorecard: dict[str, Any] | None,
    production_r2_proven: bool,
    gateway_transport_proven: bool,
    native_transport_proven: bool,
    legal_allowed: set[str],
) -> dict[str, Any]:
    frontier_id = str(frontier.get("frontier_id", ""))
    source_ids = sorted(_list_value(frontier, "source_ids"))
    missing_source_ids = [source_id for source_id in source_ids if source_id not in source_lanes_by_id]
    lane_entries = [source_lanes_by_id[source_id] for source_id in source_ids if source_id in source_lanes_by_id]
    unapproved_pack_lanes = [
        lane["source_id"]
        for lane in lane_entries
        if lane.get("r2_pack_policy") not in PACK_READY_POLICIES or lane.get("review_status") != "reviewed"
    ]
    packable_claim_count = _int_value(claim_report, "packable_claim_count")
    blocked_claim_count = _int_value(claim_report, "blocked_claim_count")
    candidate_count = _int_value(scorecard, "candidate_count")
    legal_complete = _nested_bool(claim_report, "legal_posture_completeness", "complete")
    provenance_complete = _nested_bool(claim_report, "provenance_completeness", "complete")
    missing_claim_classes = sorted(_list_value(claim_report, "missing_claim_classes"))
    authority_complete = _nested_bool(claim_report, "authority_coverage", "complete")
    gold_set_status = str((claim_report or {}).get("gold_set_status", "not_evaluated"))
    gold_set_complete = _gold_set_complete(frontier, gold_set_status)
    observed_status = _observed_status(frontier, claim_report, scorecard)
    evidence_ready = (
        production_r2_proven
        and packable_claim_count > 0
        and legal_complete
        and provenance_complete
        and not missing_claim_classes
        and authority_complete
        and gold_set_complete
        and not missing_source_ids
        and not unapproved_pack_lanes
    )
    production_target_ready = evidence_ready and native_transport_proven
    production_r2_ready = evidence_ready and not native_transport_proven

    if production_target_ready:
        readiness_status = "bounded_production_target_ready"
    elif production_r2_ready:
        readiness_status = "bounded_production_r2_ready"
    else:
        readiness_status = observed_status
    allowed_scopes: list[str] = []
    if production_target_ready:
        allowed_scopes.append("bounded_production_target")
    elif production_r2_ready:
        allowed_scopes.append("bounded_production_r2_target")
        if gateway_transport_proven:
            allowed_scopes.append("bounded_live_gateway_transport")
    elif (
        readiness_status == "claim_graph_ready"
        and packable_claim_count > 0
        and legal_complete
        and provenance_complete
        and not unapproved_pack_lanes
    ):
        allowed_scopes.append("frontier_claim_graph_ready")
    elif readiness_status in {"source_review_ready", "adapter_ready"} and legal_complete:
        allowed_scopes.append(f"frontier_{readiness_status}")

    blocked_reasons = _frontier_blockers(
        frontier=frontier,
        source_ids=source_ids,
        missing_source_ids=missing_source_ids,
        unapproved_pack_lanes=unapproved_pack_lanes,
        packable_claim_count=packable_claim_count,
        legal_complete=legal_complete,
        provenance_complete=provenance_complete,
        missing_claim_classes=missing_claim_classes,
        authority_complete=authority_complete,
        gold_set_complete=gold_set_complete,
        gold_set_status=gold_set_status,
        production_r2_proven=production_r2_proven,
        production_target_ready=production_target_ready,
        production_r2_ready=production_r2_ready,
        gateway_transport_proven=gateway_transport_proven,
        native_transport_proven=native_transport_proven,
        scorecard=scorecard,
        observed_status=observed_status,
    )
    return {
        "frontierID": frontier_id,
        "domain": frontier.get("domain", frontier_id),
        "configuredStatusCeiling": frontier.get("status_ceiling", "not_started"),
        "observedStatus": observed_status,
        "readinessStatus": readiness_status,
        "sourceIDs": source_ids,
        "missingSourceIDs": missing_source_ids,
        "sourceLanePolicies": [
            {
                "sourceID": lane.get("source_id"),
                "authorityClass": lane.get("authority_class"),
                "reviewStatus": lane.get("review_status"),
                "redistributionPolicy": lane.get("redistribution_policy"),
                "r2PackPolicy": lane.get("r2_pack_policy"),
            }
            for lane in lane_entries
        ],
        "legalPostureComplete": legal_complete,
        "provenanceComplete": provenance_complete,
        "claimClassCoverageComplete": not missing_claim_classes,
        "missingClaimClasses": missing_claim_classes,
        "authorityCoverageComplete": authority_complete,
        "goldSetComplete": gold_set_complete,
        "goldSetStatus": gold_set_status,
        "packableClaimCount": packable_claim_count,
        "blockedClaimCount": blocked_claim_count,
        "candidateCount": candidate_count,
        "packOutputAllowed": production_target_ready or production_r2_ready,
        "productionR2ProofComplete": production_target_ready or production_r2_ready,
        "gatewayTransportProofComplete": gateway_transport_proven,
        "nativeTransportProofComplete": native_transport_proven,
        "allowedClaimScopes": allowed_scopes,
        "blockedReasons": blocked_reasons,
        "nonClaims": [
            "not universal coverage",
            "not Release Green",
            "not a final user plan, schedule, or Step generator",
        ],
    }


def _frontier_blockers(
    *,
    frontier: dict[str, Any],
    source_ids: list[str],
    missing_source_ids: list[str],
    unapproved_pack_lanes: list[str],
    packable_claim_count: int,
    legal_complete: bool,
    provenance_complete: bool,
    missing_claim_classes: list[str],
    authority_complete: bool,
    gold_set_complete: bool,
    gold_set_status: str,
    production_r2_proven: bool,
    production_target_ready: bool,
    production_r2_ready: bool,
    gateway_transport_proven: bool,
    native_transport_proven: bool,
    scorecard: dict[str, Any] | None,
    observed_status: str,
) -> list[str]:
    blockers: list[str] = []
    if production_target_ready:
        return blockers
    if not source_ids:
        blockers.append("no_registered_source_lanes")
    if missing_source_ids:
        blockers.append("configured_source_lane_missing")
    if unapproved_pack_lanes:
        blockers.append("source_lane_not_pack_approved")
    if packable_claim_count <= 0:
        blockers.append("no_packable_claims")
    if not legal_complete:
        blockers.append("legal_posture_incomplete")
    if not provenance_complete:
        blockers.append("provenance_incomplete")
    if missing_claim_classes:
        blockers.append("claim_class_coverage_incomplete")
    if not authority_complete:
        blockers.append("authority_coverage_incomplete")
    if not gold_set_complete:
        blockers.append(f"gold_set_{gold_set_status}")
    if observed_status in {"candidate_only", "not_started"} or frontier.get("status_ceiling") == "candidate_only":
        blockers.append("frontier_below_pack_readiness")
    if observed_status == "claim_graph_ready" and packable_claim_count > 0:
        if not production_r2_proven:
            blockers.append("production_r2_proof_missing_for_frontier")
        if production_r2_proven and not gateway_transport_proven:
            blockers.append("gateway_transport_proof_missing_for_frontier")
        if production_r2_proven and not native_transport_proven:
            blockers.append("native_transport_proof_missing_for_frontier")
    if scorecard and observed_status in {"candidate_only", "not_started"}:
        blockers.extend(_list_value(scorecard, "blocking_reasons"))
    return sorted(set(blockers))


def _gold_set_complete(frontier: dict[str, Any], gold_set_status: str) -> bool:
    if frontier.get("gold_set_required") is not True:
        return True
    return gold_set_status in {"passed", "complete", "present", "not_required"}


def _universal_coverage_issues(frontiers: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    for frontier in frontiers:
        if frontier["readinessStatus"] != "bounded_production_target_ready":
            issues.append(f"{frontier['frontierID']}: not production/runtime ready")
        if not frontier["legalPostureComplete"]:
            issues.append(f"{frontier['frontierID']}: legal posture incomplete")
        if not frontier["provenanceComplete"]:
            issues.append(f"{frontier['frontierID']}: provenance incomplete")
        if not frontier["packOutputAllowed"]:
            issues.append(f"{frontier['frontierID']}: pack output not production-approved")
        if frontier["packOutputAllowed"] and not frontier["nativeTransportProofComplete"]:
            issues.append(f"{frontier['frontierID']}: native runtime proof incomplete")
    return sorted(set(issues))


def _gate_issues(**values: Any) -> list[str]:
    return boundary_issue_strings(boundary_issues_for_value(values, "source-atlas-coverage-readiness-gate"))


def _frontier_entries(frontier_config: dict[str, Any]) -> list[dict[str, Any]]:
    entries = frontier_config.get("frontiers", [])
    return [entry for entry in entries if isinstance(entry, dict)]


def _source_lanes_by_id(source_lane_registry: dict[str, Any]) -> dict[str, dict[str, Any]]:
    entries = source_lane_registry.get("source_lanes", [])
    return {
        str(entry.get("source_id")): entry
        for entry in entries
        if isinstance(entry, dict) and isinstance(entry.get("source_id"), str)
    }


def _best_claim_reports_by_frontier(reports: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    best: dict[str, dict[str, Any]] = {}
    rank = {
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
    for report in reports:
        for frontier in report.get("frontiers", []):
            if not isinstance(frontier, dict) or not isinstance(frontier.get("frontier_id"), str):
                continue
            frontier_id = frontier["frontier_id"]
            current = best.get(frontier_id)
            if current is None:
                best[frontier_id] = frontier
                continue
            current_score = rank.get(str(current.get("status")), 0) + _int_value(current, "packable_claim_count")
            next_score = rank.get(str(frontier.get("status")), 0) + _int_value(frontier, "packable_claim_count")
            if next_score > current_score:
                best[frontier_id] = frontier
    return best


def _scorecards_by_frontier(domain_scorecards: dict[str, Any] | None) -> dict[str, dict[str, Any]]:
    if not isinstance(domain_scorecards, dict):
        return {}
    return {
        str(item.get("frontier_id")): item
        for item in domain_scorecards.get("scorecards", [])
        if isinstance(item, dict) and isinstance(item.get("frontier_id"), str)
    }


def _observed_status(
    frontier: dict[str, Any],
    claim_report: dict[str, Any] | None,
    scorecard: dict[str, Any] | None,
) -> str:
    if isinstance(claim_report, dict) and isinstance(claim_report.get("status"), str):
        return claim_report["status"]
    if isinstance(scorecard, dict) and isinstance(scorecard.get("status"), str):
        return scorecard["status"]
    if isinstance(frontier.get("status_ceiling"), str):
        if frontier["status_ceiling"] == "candidate_only":
            return "candidate_only"
        return "not_started"
    return "not_started"


def _r2_report_targets_frontier(r2_report: dict[str, Any] | None, frontier_id: str) -> bool:
    if not isinstance(r2_report, dict):
        return False
    pack_id = str(r2_report.get("packID", ""))
    return f"/{frontier_id}/" in pack_id or pack_id.endswith(f"/{frontier_id}")


def _production_r2_reports_by_frontier(reports: list[dict[str, Any] | None]) -> dict[str, dict[str, Any]]:
    ready: dict[str, dict[str, Any]] = {}
    for report in reports:
        if not _production_r2_write_proven(report):
            continue
        frontier_id = _frontier_id_from_pack_report(report)
        if frontier_id:
            ready[frontier_id] = report
    return ready


def _gateway_readback_reports_by_frontier(reports: list[dict[str, Any] | None]) -> dict[str, dict[str, Any]]:
    ready: dict[str, dict[str, Any]] = {}
    for report in reports:
        if not isinstance(report, dict):
            continue
        consistency = report.get("pack_consistency", {})
        if (
            "green_for_bounded" in str(report.get("status", ""))
            and consistency.get("packIDConsistent") is True
            and consistency.get("packHashConsistent") is True
            and consistency.get("currentPointerHashConsistent") is True
        ):
            frontier_id = _frontier_id_from_pack_id(
                str(consistency.get("packID") or consistency.get("currentPackID") or report.get("packID", ""))
            )
            if frontier_id:
                ready[frontier_id] = report
            continue
        if _top_level_gateway_readback_report_proven(report):
            frontier_id = _frontier_id_from_pack_id(str(report.get("packID", "")))
            if frontier_id:
                ready[frontier_id] = report
    return ready


def _top_level_gateway_readback_report_proven(report: dict[str, Any]) -> bool:
    status = str(report.get("status", "")).lower()
    if report.get("valid") is not True:
        return False
    if status != "green" and "green_for_bounded" not in status:
        return False
    if not _frontier_id_from_pack_id(str(report.get("packID", ""))):
        return False
    for key in ("packSHA256", "manifestSHA256"):
        value = report.get(key)
        if not isinstance(value, str) or len(value) != 64:
            return False
    for key in ("r2RequestPrivacyProof", "noPrivateGraphEgressProof"):
        if not isinstance(report.get(key), str) or not report[key].strip():
            return False
    return True


def _native_transport_frontiers(native_transport_report: dict[str, Any] | None) -> set[str]:
    if not isinstance(native_transport_report, dict):
        return set()
    frontiers: set[str] = set()
    proofs = native_transport_report.get("native_runtime_proofs")
    if isinstance(proofs, list):
        for proof in proofs:
            if isinstance(proof, dict):
                frontiers.update(_native_transport_frontiers_from_proof(proof))
    frontiers.update(_native_transport_frontiers_from_proof(native_transport_report.get("native_runtime_proof")))
    return frontiers


def _native_transport_frontiers_from_proof(proof: Any) -> set[str]:
    if not isinstance(proof, dict):
        return set()
    target_domain = proof.get("target_domain")
    if isinstance(target_domain, str) and target_domain:
        return {target_domain}
    target_pack_id = str(proof.get("target_pack_id", ""))
    frontier_id = _frontier_id_from_pack_id(target_pack_id)
    return {frontier_id} if frontier_id else set()


def _frontier_id_from_pack_report(report: dict[str, Any] | None) -> str | None:
    if not isinstance(report, dict):
        return None
    return _frontier_id_from_pack_id(str(report.get("packID", "")))


def _frontier_id_from_pack_id(pack_id: str) -> str | None:
    marker = "source-atlas/v1/domain/"
    if marker not in pack_id:
        return None
    remainder = pack_id.split(marker, 1)[1]
    frontier_id = remainder.split("/", 1)[0]
    return frontier_id or None


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
    value = container.get(key, 0)
    return value if isinstance(value, int) else 0


def _nested_bool(container: dict[str, Any] | None, parent: str, child: str) -> bool:
    if not isinstance(container, dict):
        return False
    parent_value = container.get(parent, {})
    if not isinstance(parent_value, dict):
        return False
    return parent_value.get(child) is True
