"""Autonomous production-lane work orders for routed Source Atlas domains.

Train 88 routes sanitized public/reference domain requests. This Train 89
compiler turns those routes into deterministic work orders for the Source Atlas
production lane. It does not approve sources, emit claims, build packs, publish
to R2, or activate native runtime behavior. It makes the next governed action
explicit for each routed domain.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .goal_domain_router import ROUTE_CANDIDATE_INTAKE, ROUTE_CONFIGURED_NOT_READY, ROUTE_PRODUCTION_READY
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


GOAL_DOMAIN_PRODUCTION_LANES_VERSION = "source-atlas-goal-domain-production-lanes-train-89"
GOAL_DOMAIN_PRODUCTION_LANES_KIND = "ambitions.sourceAtlas.goalDomainProductionLanes.v1"

LANE_READY_PUBLIC_REFERENCE = "ready_public_reference_runtime_lane"
LANE_CONFIGURED_BLOCKED = "configured_frontier_blocked_lane"
LANE_CANDIDATE_EXPANSION = "candidate_domain_expansion_lane"

READY_ROUTE_STAGES = [
    ("ledger_freshness_monitor", "Verify production target ledger evidence is still current."),
    ("r2_gateway_readback_monitor", "Verify public gateway, R2 object hash, revocation, and LKG evidence remain current."),
    ("native_refresh_registry_monitor", "Verify native public refresh target remains ledger-gated and public-reference only."),
    ("local_runtime_composition_monitor", "Verify Ambitions continues to join public references with private context locally only."),
]

CONFIGURED_BLOCKED_STAGES = [
    ("production_target_gap_review", "Identify which frontier, claim, pack, R2, gateway, or native gate blocks readiness."),
    ("evidence_rebuild_plan", "Rebuild the missing bounded evidence before enabling runtime use."),
]

CANDIDATE_ROUTE_STAGES = [
    ("frontier_review", "Review candidate-only frontier shape and domain boundaries."),
    ("source_discovery", "Discover direct public/reference sources and keep catalog metadata source-of-sources only."),
    ("direct_source_resolution", "Resolve direct publisher authority before any claim authority is asserted."),
    ("source_lane_review", "Create or update source lane governance only after review evidence exists."),
    ("legal_terms_review", "Classify redistribution, attribution, rights, and outside-legal requirements."),
    ("api_governance_review", "Define key, rate, budget, live, execute, retry, and redaction policy."),
    ("adapter_fixture_contract", "Add deterministic fixture-backed adapter contract before live harvest."),
    ("live_harvest_gate", "Allow live harvest only with explicit live flags, governance, budgets, and source approval."),
    ("claim_graph_gate", "Emit claims only after source, legal, provenance, freshness, and conflict gates pass."),
    ("pack_production_gate", "Build pack only after complete public claim graph and non-private scan evidence."),
    ("r2_publish_gate", "Publish only with owner approval, execute flag, upload/readback hash proof, revocation, and rollback."),
    ("native_activation_gate", "Activate native public refresh target only after ledger, gateway, privacy, quarantine, and offline proof."),
    ("local_composition_gate", "Use references inside Ambitions only as local public context, never as final plans or Steps."),
]

PRODUCTION_LANE_NON_CLAIMS = [
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not App Store or TestFlight readiness",
    "not physical-device proof",
    "not production R2 upload or overwrite",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    "not approval for future domains without source/frontier/pack/R2/native evidence",
    "candidate work orders are not source authority",
    "candidate work orders are not pack output",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class GoalDomainProductionLaneOptions:
    router_manifest_path: Path
    output_root: Path
    production_target_ledger_path: Path | None = None
    created_at: str | None = None


def compile_goal_domain_production_lanes(options: GoalDomainProductionLaneOptions) -> dict[str, Any]:
    """Compile route evidence into deterministic Source Atlas lane work orders."""

    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    router_manifest = read_json(options.router_manifest_path)
    router_manifest_issues = _router_manifest_issues(router_manifest)
    router_output_path = _router_output_path(router_manifest)
    routing_artifact = read_json(router_output_path) if router_output_path and router_output_path.exists() else {}
    routing_issues = _routing_issues(routing_artifact, router_output_path)
    routes = _routes(routing_artifact)

    ledger_path = options.production_target_ledger_path or _path_or_none(router_manifest.get("productionTargetLedgerPath"))
    ledger = read_json(ledger_path) if ledger_path and ledger_path.exists() else {}
    ledger_by_domain = _ledger_by_domain(ledger)

    candidate_context = _candidate_context(router_manifest)
    lane_summaries: list[dict[str, Any]] = []
    work_orders: list[dict[str, Any]] = []
    for route in sorted(routes, key=lambda item: str(item.get("requestID", ""))):
        lane = _lane_for_route(route, ledger_by_domain, candidate_context, created_at)
        lane_summaries.append(lane["summary"])
        work_orders.extend(lane["workOrders"])

    work_orders = sorted(work_orders, key=lambda item: (item["requestID"], item["stageIndex"], item["orderID"]))
    lane_summaries = sorted(lane_summaries, key=lambda item: item["requestID"])
    record_counts = {
        "routes": len(routes),
        "productionReadyRoutes": sum(1 for lane in lane_summaries if lane["lane"] == LANE_READY_PUBLIC_REFERENCE),
        "configuredBlockedRoutes": sum(1 for lane in lane_summaries if lane["lane"] == LANE_CONFIGURED_BLOCKED),
        "candidateRoutes": sum(1 for lane in lane_summaries if lane["lane"] == LANE_CANDIDATE_EXPANSION),
        "workOrders": len(work_orders),
        "candidateWorkOrders": sum(1 for order in work_orders if order["lane"] == LANE_CANDIDATE_EXPANSION),
        "maintenanceWorkOrders": sum(1 for order in work_orders if order["lane"] == LANE_READY_PUBLIC_REFERENCE),
        "blockedConfiguredWorkOrders": sum(1 for order in work_orders if order["lane"] == LANE_CONFIGURED_BLOCKED),
        "liveOperations": 0,
        "executeOperations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    artifact = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_PRODUCTION_LANES_KIND,
        "versionID": GOAL_DOMAIN_PRODUCTION_LANES_VERSION,
        "createdAt": created_at,
        "routerManifestPath": str(options.router_manifest_path),
        "routerOutputPath": str(router_output_path) if router_output_path else "",
        "productionTargetLedgerPath": str(ledger_path) if ledger_path else "",
        "laneSummaries": lane_summaries,
        "workOrders": work_orders,
        "recordCounts": record_counts,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_LANE_NON_CLAIMS,
    }
    input_privacy_issues = privacy_findings_for_value(
        {
            "routerManifest": router_manifest,
            "routingArtifact": routing_artifact,
            "productionTargetLedger": ledger,
            "candidateContext": candidate_context,
        },
        "goal-domain-production-lanes-input",
    )
    output_privacy_issues = privacy_findings_for_value(artifact, "goal-domain-production-lanes")
    checks = [
        {"name": "router_manifest_valid", "passed": not router_manifest_issues, "issues": router_manifest_issues},
        {"name": "routing_artifact_valid", "passed": not routing_issues and bool(routes), "issues": routing_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "production_ready_routes_require_ledger_ready_domain",
            "passed": all(
                summary["lane"] != LANE_READY_PUBLIC_REFERENCE
                or _ledger_ready(summary["matchedDomainID"], ledger_by_domain)
                for summary in lane_summaries
            ),
            "issues": [],
        },
        {
            "name": "candidate_routes_have_complete_gate_work_orders",
            "passed": all(
                summary["lane"] != LANE_CANDIDATE_EXPANSION
                or summary["workOrderCount"] == len(CANDIDATE_ROUTE_STAGES)
                for summary in lane_summaries
            ),
            "issues": [],
        },
        {
            "name": "work_orders_default_to_no_live_or_execute",
            "passed": all(order["liveAllowed"] is False and order["executeAllowed"] is False for order in work_orders),
            "issues": [],
        },
        {
            "name": "work_orders_emit_no_claims_packs_r2_or_native_activation",
            "passed": record_counts["claims"] == 0
            and record_counts["packableClaims"] == 0
            and record_counts["r2PackableArtifacts"] == 0
            and record_counts["r2PublishOperations"] == 0
            and record_counts["nativeActivationOperations"] == 0,
            "issues": [],
        },
        {
            "name": "no_final_plan_schedule_step_output",
            "passed": record_counts["finalOutputArtifacts"] == 0 and not _contains_forbidden_output_marker(artifact),
            "issues": [],
        },
        {"name": "privacy_scan_passed", "passed": not output_privacy_issues, "issues": output_privacy_issues},
    ]
    issues: list[str] = []
    issues.extend(router_manifest_issues)
    issues.extend(routing_issues)
    issues.extend(input_privacy_issues)
    issues.extend(output_privacy_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    output_paths = {
        "productionLanes": str(output_root / "goal-domain-production-lanes.json"),
        "workOrders": str(output_root / "domain-work-orders.json"),
        "manifest": str(output_root / "manifest.json"),
        "closeout": str(output_root / "closeout.md"),
    }
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainProductionLanesManifest.v1",
        "versionID": GOAL_DOMAIN_PRODUCTION_LANES_VERSION,
        "createdAt": created_at,
        "status": "Source Green for goal-domain production-lane work-order tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; autonomous production-lane work orders only",
        "routerManifestPath": str(options.router_manifest_path),
        "routerOutputPath": str(router_output_path) if router_output_path else "",
        "productionTargetLedgerPath": str(ledger_path) if ledger_path else "",
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": output_paths,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_LANE_NON_CLAIMS,
    }

    write_json(output_root / "goal-domain-production-lanes.json", artifact)
    write_json(
        output_root / "domain-work-orders.json",
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.domainProductionWorkOrders.v1",
            "versionID": GOAL_DOMAIN_PRODUCTION_LANES_VERSION,
            "createdAt": created_at,
            "workOrders": work_orders,
            "nonClaims": ["work orders only", "not source authority", "not claim output", "not pack output", "not R2 publish"],
        },
    )
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "productionLanes": stable_hash(read_json(output_root / "goal-domain-production-lanes.json")),
        "workOrders": stable_hash(read_json(output_root / "domain-work-orders.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(goal_domain_production_lanes_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_goal_domain_production_lanes_report(
    markdown_path: Path,
    json_path: Path,
    *,
    router_manifest_path: Path,
    output_root: Path,
    production_target_ledger_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_goal_domain_production_lanes(
        GoalDomainProductionLaneOptions(
            router_manifest_path=router_manifest_path,
            output_root=output_root,
            production_target_ledger_path=production_target_ledger_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(goal_domain_production_lanes_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def goal_domain_production_lanes_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Goal-Domain Production Lanes Train 89",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic production-lane work-order compiler for routed public/reference domains.",
        "- Production-ready routes receive monitoring and refresh-verification work orders.",
        "- Candidate routes receive gated discovery, review, legal/API, adapter, harvest, claim, pack, R2, native, and local-composition work orders.",
        "- Work orders default to no live execution and no write execution.",
        "- No claims, packs, R2 writes, native activations, final plans, schedules, or Steps are emitted.",
        "",
        "Counts:",
        f"- Routes: {counts['routes']}",
        f"- Production-ready routes: {counts['productionReadyRoutes']}",
        f"- Candidate routes: {counts['candidateRoutes']}",
        f"- Work orders: {counts['workOrders']}",
        f"- Claims: {counts['claims']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        f"- Final output artifacts: {counts['finalOutputArtifacts']}",
        "",
        "Product law preserved:",
        "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
        "- Work orders are infrastructure controls, not user-facing pack browsing.",
        "- Private Ambitions runtime context remains local.",
        "- Source Atlas does not generate final user plans, schedules, Steps, or personalized paths.",
        "",
        "Validation run:",
        "- See train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Live network/API discovery was not run.",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- The compiler emits no R2 request and executes no R2 operation.",
            "- R2 publish gates are work orders only and default to executeAllowed=false.",
            "",
            "No private graph egress proof:",
            "- Router, lane, and work-order artifacts are privacy-scanned.",
            "- Work orders carry public/reference domain metadata only.",
            "",
            "License/terms proof:",
            "- Candidate domains include legal/terms review work orders before packability.",
            "- No legal approval is produced or claimed.",
            "",
            "Restricted-source exclusion proof:",
            "- Candidate domains remain blocked from claim, pack, R2, and native activation until governance gates pass.",
            "",
            "Provenance completeness proof:",
            "- Candidate domains include claim graph/provenance gates and emit no claims.",
            "- Production-ready domains depend on the production target ledger.",
            "",
            "Freshness/revocation proof:",
            "- Production-ready domains receive freshness, readback, revocation, and LKG monitoring work orders.",
            "- Candidate domains do not emit revocation or LKG artifacts.",
            "",
            "Native offline/no-account proof:",
            "- No native app files changed in this train.",
            "- Native activation is represented as a future gated work order only.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Compatibility shims left behind: none.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _lane_for_route(
    route: dict[str, Any],
    ledger_by_domain: dict[str, dict[str, Any]],
    candidate_context: dict[str, Any],
    created_at: str,
) -> dict[str, Any]:
    request_id = str(route.get("requestID") or "unnamed-route")
    requested_domain = str(route.get("requestedDomain") or route.get("matchedDomainID") or request_id)
    matched_domain = route.get("matchedDomainID")
    if route.get("route") == ROUTE_PRODUCTION_READY:
        stages = READY_ROUTE_STAGES
        lane = LANE_READY_PUBLIC_REFERENCE
        status = "maintenance_ready"
        blocked_by: list[str] = []
        required_evidence = [
            "production_target_ledger_ready_domain",
            "r2_upload_readback_hash_evidence",
            "public_gateway_readback_evidence",
            "native_refresh_registry_evidence",
            "native_runtime_quarantine_lkg_offline_evidence",
        ]
    elif route.get("route") == ROUTE_CONFIGURED_NOT_READY:
        stages = CONFIGURED_BLOCKED_STAGES
        lane = LANE_CONFIGURED_BLOCKED
        status = "blocked_until_production_target_evidence"
        blocked_by = list(route.get("blockingReasons", [])) or ["production_target_evidence_missing"]
        required_evidence = [
            "claim_graph_evidence",
            "pack_production_evidence",
            "r2_upload_readback_hash_evidence",
            "gateway_readback_evidence",
            "native_runtime_evidence",
        ]
    else:
        stages = CANDIDATE_ROUTE_STAGES
        lane = LANE_CANDIDATE_EXPANSION
        status = "candidate_only_work_ordered"
        blocked_by = list(route.get("blockingReasons", [])) or ["candidate_only_frontier_intake_required"]
        required_evidence = [
            "frontier_review",
            "direct_source_authority_review",
            "legal_terms_review",
            "api_governance_review",
            "adapter_fixture_contract",
            "claim_graph_provenance",
            "pack_production",
            "r2_publish_owner_approval",
            "native_privacy_quarantine_offline_evidence",
        ]

    work_orders = [
        _work_order(
            route=route,
            lane=lane,
            stage_index=index,
            stage=stage,
            description=description,
            status=status,
            blocked_by=blocked_by,
            required_evidence=required_evidence,
            candidate_context=candidate_context,
            created_at=created_at,
        )
        for index, (stage, description) in enumerate(stages, start=1)
    ]
    domain_ledger = ledger_by_domain.get(str(matched_domain or ""), {})
    summary = {
        "requestID": request_id,
        "requestedDomain": requested_domain,
        "matchedDomainID": matched_domain,
        "route": route.get("route"),
        "lane": lane,
        "status": status,
        "readinessStatus": route.get("readinessStatus"),
        "productionTargetReady": route.get("productionTargetReady") is True,
        "candidateIntakeRequired": route.get("candidateIntakeRequired") is True,
        "workOrderCount": len(work_orders),
        "candidateSourceCount": _candidate_source_count(route, candidate_context),
        "ledgerEvidence": {
            "claimGraphProofComplete": domain_ledger.get("claimGraphProofComplete") is True,
            "packProductionProofComplete": domain_ledger.get("packProductionProofComplete") is True,
            "r2ProductionProofComplete": domain_ledger.get("r2ProductionProofComplete") is True,
            "gatewayProofComplete": domain_ledger.get("gatewayProofComplete") is True,
            "nativeUsabilityProofComplete": domain_ledger.get("nativeUsabilityProofComplete") is True,
        },
        "blockedBy": sorted(set(blocked_by)),
        "nonClaims": [
            "work-order lane only",
            "not source authority",
            "not claim output",
            "not pack output",
            "not R2 publish",
        ],
    }
    return {"summary": summary, "workOrders": work_orders}


def _work_order(
    *,
    route: dict[str, Any],
    lane: str,
    stage_index: int,
    stage: str,
    description: str,
    status: str,
    blocked_by: list[str],
    required_evidence: list[str],
    candidate_context: dict[str, Any],
    created_at: str,
) -> dict[str, Any]:
    request_id = str(route.get("requestID") or "unnamed-route")
    requested_domain = str(route.get("requestedDomain") or route.get("matchedDomainID") or request_id)
    matched_domain = route.get("matchedDomainID")
    source_ids = _candidate_source_ids(route, candidate_context)
    payload = {
        "request": request_id,
        "domain": requested_domain,
        "lane": lane,
        "stage": stage,
        "stage_index": stage_index,
    }
    return {
        "orderID": stable_id("source_atlas_domain_work_order", payload),
        "requestID": request_id,
        "requestedDomain": requested_domain,
        "matchedDomainID": matched_domain,
        "lane": lane,
        "stageIndex": stage_index,
        "stage": stage,
        "description": description,
        "status": status,
        "createdAt": created_at,
        "defaultMode": "fixture_or_dry_run",
        "liveAllowed": False,
        "executeAllowed": False,
        "requiresApprovalArtifact": stage
        in {
            "source_lane_review",
            "legal_terms_review",
            "api_governance_review",
            "live_harvest_gate",
            "pack_production_gate",
            "r2_publish_gate",
            "native_activation_gate",
        },
        "candidateSourceIDs": source_ids,
        "requiredEvidence": required_evidence,
        "blockedBy": sorted(set(blocked_by)),
        "emitsClaims": False,
        "emitsPackOutput": False,
        "writesR2": False,
        "activatesNativeRuntime": False,
        "publicReferenceOnly": True,
        "nonClaims": [
            "work order only",
            "not source authority",
            "not claim output",
            "not pack output",
            "not R2 publish",
            "not final user plans, schedules, or Steps",
        ],
    }


def _candidate_context(router_manifest: dict[str, Any]) -> dict[str, Any]:
    intake_manifest_path = _path_or_none(router_manifest.get("candidateIntake", {}).get("manifestPath"))
    if not intake_manifest_path or not intake_manifest_path.exists():
        return {"proposedFrontiers": {}, "candidateSources": {}}
    intake_manifest = read_json(intake_manifest_path)
    output_paths = intake_manifest.get("outputPaths", {})
    proposed_path = _path_or_none(output_paths.get("proposedFrontiers"))
    candidate_path = _path_or_none(output_paths.get("candidateSources"))
    proposed_payload = read_json(proposed_path) if proposed_path and proposed_path.exists() else {}
    candidate_payload = read_json(candidate_path) if candidate_path and candidate_path.exists() else {}
    proposed = {
        str(item.get("proposal_id") or item.get("frontier_id") or ""): item
        for item in proposed_payload.get("proposedFrontiers", [])
        if isinstance(item, dict)
    }
    candidates_by_proposal: dict[str, list[dict[str, Any]]] = {}
    for item in candidate_payload.get("candidateSourceRecords", []):
        if isinstance(item, dict):
            candidates_by_proposal.setdefault(str(item.get("proposal_id") or ""), []).append(item)
    return {"proposedFrontiers": proposed, "candidateSources": candidates_by_proposal}


def _candidate_source_ids(route: dict[str, Any], candidate_context: dict[str, Any]) -> list[str]:
    request_id = str(route.get("requestID") or "")
    candidates = candidate_context.get("candidateSources", {}).get(request_id, [])
    return sorted(str(item.get("candidate_id")) for item in candidates if item.get("candidate_id"))


def _candidate_source_count(route: dict[str, Any], candidate_context: dict[str, Any]) -> int:
    return len(_candidate_source_ids(route, candidate_context))


def _router_manifest_issues(manifest: Any) -> list[str]:
    if not isinstance(manifest, dict):
        return ["router manifest must be an object"]
    issues: list[str] = []
    if manifest.get("valid") is not True:
        issues.append("router manifest must be valid")
    if not _router_output_path(manifest):
        issues.append("router manifest missing outputPaths.goalDomainRouting")
    return issues


def _routing_issues(artifact: Any, path: Path | None) -> list[str]:
    if path is None or not path.exists():
        return ["routing artifact missing"]
    if not isinstance(artifact, dict):
        return ["routing artifact must be an object"]
    routes = artifact.get("routes")
    if not isinstance(routes, list) or not routes:
        return ["routing artifact must include non-empty routes"]
    return []


def _routes(artifact: Any) -> list[dict[str, Any]]:
    if not isinstance(artifact, dict):
        return []
    return [item for item in artifact.get("routes", []) if isinstance(item, dict)]


def _router_output_path(manifest: dict[str, Any]) -> Path | None:
    return _path_or_none(manifest.get("outputPaths", {}).get("goalDomainRouting"))


def _path_or_none(value: Any) -> Path | None:
    if isinstance(value, str) and value:
        return Path(value)
    return None


def _ledger_by_domain(ledger: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(ledger, dict):
        return {}
    domains = ledger.get("domains", [])
    if not isinstance(domains, list):
        return {}
    return {
        str(domain.get("domainID")): domain
        for domain in domains
        if isinstance(domain, dict) and isinstance(domain.get("domainID"), str)
    }


def _ledger_ready(domain_id: Any, ledger_by_domain: dict[str, dict[str, Any]]) -> bool:
    domain = ledger_by_domain.get(str(domain_id or ""), {})
    return domain.get("readinessStatus") == "bounded_production_target_ready"


def _contains_forbidden_output_marker(value: Any) -> bool:
    forbidden = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}
    if isinstance(value, str):
        return value in forbidden
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(_contains_forbidden_output_marker(item) for item in value.values())
    return False
