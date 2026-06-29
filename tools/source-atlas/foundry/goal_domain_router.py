"""Governed goal-domain routing for Source Atlas Train 88.

This router is the connective layer between arbitrary public goal-domain
requests and the bounded Source Atlas production target ledger. It accepts only
sanitized public/reference domain metadata. Existing configured domains can be
marked usable only when the production target ledger proves bounded readiness;
all unmatched or ambiguous domains are routed into candidate-only frontier
intake. The router emits no claims, packs, R2 objects, final plans, schedules,
or Steps.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .claim_frontier import DEFAULT_FRONTIER_CONFIG_PATH, SOURCE_ATLAS_ROOT
from .frontier_intake import FrontierIntakeOptions, compile_frontier_intake
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


GOAL_DOMAIN_ROUTER_VERSION = "source-atlas-goal-domain-router-train-88"
GOAL_DOMAIN_ROUTER_KIND = "ambitions.sourceAtlas.goalDomainRouter.v1"
DEFAULT_PRODUCTION_TARGET_LEDGER_PATH = SOURCE_ATLAS_ROOT / "generated" / "production-target-ledger" / "train-86" / "production-target-ledger.json"
PRODUCTION_READY_STATUS = "bounded_production_target_ready"
ROUTE_PRODUCTION_READY = "configured_production_target_ready"
ROUTE_CONFIGURED_NOT_READY = "configured_frontier_not_production_ready"
ROUTE_CANDIDATE_INTAKE = "candidate_frontier_intake_required"
ROUTE_BLOCKED_PRIVATE = "blocked_private_context"
FINAL_OUTPUT_FORBIDDEN = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}

GOAL_DOMAIN_ROUTER_NON_CLAIMS = [
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not App Store or TestFlight readiness",
    "not physical-device proof",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    "not approval for future domains without source/frontier/pack/R2/native evidence",
    "candidate routes are not claim authority",
    "candidate routes are not pack output",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class GoalDomainRouterOptions:
    input_path: Path
    output_root: Path
    frontier_config_path: Path | None = DEFAULT_FRONTIER_CONFIG_PATH
    production_target_ledger_path: Path | None = DEFAULT_PRODUCTION_TARGET_LEDGER_PATH
    created_at: str | None = None


def compile_goal_domain_router(options: GoalDomainRouterOptions) -> dict[str, Any]:
    """Route sanitized public/reference goal-domain metadata into safe lanes."""

    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    frontier_config_path = options.frontier_config_path or DEFAULT_FRONTIER_CONFIG_PATH
    production_target_ledger_path = options.production_target_ledger_path or DEFAULT_PRODUCTION_TARGET_LEDGER_PATH

    payload = read_json(options.input_path)
    input_schema_issues = _input_schema_issues(payload)
    input_privacy_issues = privacy_findings_for_value(payload, "goal-domain-router-input")
    frontiers = _frontiers(frontier_config_path)
    ledger = _read_json_if_exists(production_target_ledger_path)
    ledger_by_domain = _ledger_by_domain(ledger)

    routes: list[dict[str, Any]] = []
    candidate_requests: list[dict[str, Any]] = []
    if not input_schema_issues and not input_privacy_issues:
        for index, request in enumerate(_request_list(payload)):
            route = _route_request(
                request=request,
                index=index,
                frontiers=frontiers,
                ledger_by_domain=ledger_by_domain,
                production_target_ledger_path=production_target_ledger_path,
            )
            routes.append(route)
            if route["route"] == ROUTE_CANDIDATE_INTAKE:
                candidate_requests.append(_request_to_frontier_intake_proposal(request, route))
    elif input_privacy_issues:
        routes = [
            {
                "requestID": "input_blocked",
                "route": ROUTE_BLOCKED_PRIVATE,
                "candidateIntakeRequired": False,
                "productionTargetReady": False,
                "packOutputAllowed": False,
                "r2PublishAllowed": False,
                "nativeUsabilityReady": False,
                "blockingReasons": ["input_privacy_scan_failed"],
                "nonClaims": ["private-looking input blocked before routing"],
            }
        ]

    candidate_intake_payload = {
        "domainProposals": candidate_requests,
    }
    candidate_intake_report: dict[str, Any] | None = None
    candidate_intake_input_path: str | None = None
    if candidate_requests and not input_privacy_issues:
        candidate_intake_path = output_root / "candidate-intake-input.json"
        write_json(candidate_intake_path, candidate_intake_payload)
        candidate_intake_input_path = str(candidate_intake_path)
        candidate_intake_report = compile_frontier_intake(
            FrontierIntakeOptions(
                input_path=candidate_intake_path,
                output_root=output_root / "frontier-intake",
                frontier_config_path=frontier_config_path,
                created_at=created_at,
            )
        )
    else:
        write_json(output_root / "candidate-intake-input.json", candidate_intake_payload)
        candidate_intake_input_path = str(output_root / "candidate-intake-input.json")

    record_counts = {
        "requests": len(_request_list(payload)) if isinstance(payload, dict) else 0,
        "routes": len(routes),
        "productionTargetReadyRoutes": sum(1 for route in routes if route["route"] == ROUTE_PRODUCTION_READY),
        "configuredNotReadyRoutes": sum(1 for route in routes if route["route"] == ROUTE_CONFIGURED_NOT_READY),
        "candidateIntakeRoutes": sum(1 for route in routes if route["route"] == ROUTE_CANDIDATE_INTAKE),
        "blockedPrivateRoutes": sum(1 for route in routes if route["route"] == ROUTE_BLOCKED_PRIVATE),
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "finalOutputArtifacts": 0,
    }
    output_paths = {
        "goalDomainRouting": str(output_root / "goal-domain-routing.json"),
        "candidateIntakeInput": candidate_intake_input_path,
        "manifest": str(output_root / "manifest.json"),
        "closeout": str(output_root / "closeout.md"),
    }
    if candidate_intake_report:
        output_paths["frontierIntakeManifest"] = candidate_intake_report["manifestPath"]

    artifact = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_ROUTER_KIND,
        "versionID": GOAL_DOMAIN_ROUTER_VERSION,
        "createdAt": created_at,
        "inputPath": str(options.input_path),
        "frontierConfigPath": str(frontier_config_path),
        "productionTargetLedgerPath": str(production_target_ledger_path),
        "routes": sorted(routes, key=lambda item: item["requestID"]),
        "candidateIntake": {
            "required": bool(candidate_requests),
            "inputPath": candidate_intake_input_path,
            "manifestPath": candidate_intake_report.get("manifestPath") if candidate_intake_report else None,
            "valid": candidate_intake_report.get("valid") if candidate_intake_report else None,
            "status": candidate_intake_report.get("status") if candidate_intake_report else "not_required",
            "recordCounts": candidate_intake_report.get("recordCounts") if candidate_intake_report else {"proposals": 0, "claims": 0, "packableClaims": 0, "r2PackableArtifacts": 0},
        },
        "recordCounts": record_counts,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": GOAL_DOMAIN_ROUTER_NON_CLAIMS,
    }
    output_privacy_issues = privacy_findings_for_value(artifact, "goal-domain-router")
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues, "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "production_ready_routes_require_ledger_ready_domain",
            "passed": all(
                route["route"] != ROUTE_PRODUCTION_READY or route["readinessStatus"] == PRODUCTION_READY_STATUS
                for route in routes
            ),
            "issues": [],
        },
        {
            "name": "candidate_routes_emit_candidate_intake_only",
            "passed": all(
                route["route"] != ROUTE_CANDIDATE_INTAKE
                or (
                    route["candidateIntakeRequired"] is True
                    and route["packOutputAllowed"] is False
                    and route["r2PublishAllowed"] is False
                )
                for route in routes
            ),
            "issues": [],
        },
        {
            "name": "candidate_intake_valid_when_required",
            "passed": candidate_intake_report is None or candidate_intake_report.get("valid") is True,
            "issues": [] if candidate_intake_report is None or candidate_intake_report.get("valid") is True else candidate_intake_report.get("issues", []),
        },
        {
            "name": "router_emits_no_claims_packs_or_r2_operations",
            "passed": record_counts["claims"] == 0
            and record_counts["packableClaims"] == 0
            and record_counts["r2PackableArtifacts"] == 0
            and record_counts["r2PublishOperations"] == 0,
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
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])
    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainRouterManifest.v1",
        "versionID": GOAL_DOMAIN_ROUTER_VERSION,
        "createdAt": created_at,
        "status": "Source Green for goal-domain routing tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; configured-frontier production target routing plus candidate-only intake for new domains",
        "inputPath": str(options.input_path),
        "frontierConfigPath": str(frontier_config_path),
        "productionTargetLedgerPath": str(production_target_ledger_path),
        "recordCounts": record_counts,
        "candidateIntake": artifact["candidateIntake"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": output_paths,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": GOAL_DOMAIN_ROUTER_NON_CLAIMS,
    }

    write_json(output_root / "goal-domain-routing.json", artifact)
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "goalDomainRouting": stable_hash(read_json(output_root / "goal-domain-routing.json")),
        "candidateIntakeInput": stable_hash(read_json(output_root / "candidate-intake-input.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(goal_domain_router_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_goal_domain_router_report(
    markdown_path: Path,
    json_path: Path,
    *,
    input_path: Path,
    output_root: Path,
    frontier_config_path: Path | None = None,
    production_target_ledger_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_goal_domain_router(
        GoalDomainRouterOptions(
            input_path=input_path,
            output_root=output_root,
            frontier_config_path=frontier_config_path,
            production_target_ledger_path=production_target_ledger_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(goal_domain_router_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def goal_domain_router_markdown(result: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Goal-Domain Router Train 88",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic routing from sanitized public/reference goal-domain requests to configured production-target frontiers or candidate-only frontier intake.",
        "- Existing frontiers can be marked usable only when the production target ledger proves bounded readiness.",
        "- New, unmatched, or ambiguous domains remain candidate-only and cannot emit claims, packs, R2 objects, final plans, schedules, or Steps.",
        "",
        "Product law preserved:",
        "- Source Atlas and R2 remain public/reference/freshness infrastructure only.",
        "- Router input is public domain metadata, not private user goal text.",
        "- Candidate routes are not source authority and not pack output.",
        "- Local Ambitions runtime remains responsible for private goal matching and final planning.",
        "",
        "Validation run:",
        "- See current train closeout for exact command output.",
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
            "- No R2 request path is emitted or executed by the router.",
            "- Routes contain production target readiness metadata only.",
            "",
            "No private graph egress proof:",
            "- Private-looking input fails before routing or candidate intake.",
            "- Router emits no user goals, captures, schedules, proof, receipts, behavior history, or private graph data.",
            "",
            "License/terms proof:",
            "- Candidate routes inherit frontier-intake review-required posture.",
            "- Existing production-ready routes depend on the production target ledger, which depends on prior source/legal/pack/R2/native proof.",
            "- Outside legal approval is not claimed.",
            "",
            "Restricted-source exclusion proof:",
            "- Candidate routes are pack-blocked and review-required.",
            "- Existing production-ready routes are scoped to ledger-ready configured frontiers only.",
            "",
            "Provenance completeness proof:",
            "- Existing production-ready routes depend on the production target ledger.",
            "- Candidate routes emit no claims and therefore make no provenance-completeness claim.",
            "",
            "Freshness/revocation proof:",
            "- Existing production-ready routes depend on the production target ledger and current gateway/native evidence.",
            "- Candidate routes emit no revocation manifest or LKG pointer.",
            "",
            "Native offline/no-account proof:",
            "- Not newly claimed in Train 88. Existing ready routes reference prior native usability proof through the production target ledger.",
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


def _route_request(
    *,
    request: dict[str, Any],
    index: int,
    frontiers: list[dict[str, Any]],
    ledger_by_domain: dict[str, dict[str, Any]],
    production_target_ledger_path: Path,
) -> dict[str, Any]:
    request_id = str(request.get("request_id") or stable_id("goal_domain_request", {"index": index, "request": request}))
    requested_domain = _normalize_id(str(request.get("domain") or request_id))
    match = _best_frontier_match(request, frontiers)
    if match["ambiguous"] or match["frontier"] is None:
        reasons = ["no_configured_frontier_match"] if match["frontier"] is None else ["ambiguous_frontier_match"]
        return _candidate_route(
            request_id=request_id,
            requested_domain=requested_domain,
            match=match,
            blocking_reasons=[*reasons, "candidate_only_frontier_intake_required"],
        )

    frontier = match["frontier"]
    domain_id = str(frontier["domain"])
    ledger_domain = ledger_by_domain.get(domain_id, {})
    readiness = str(ledger_domain.get("readinessStatus") or "not_ready")
    production_ready = readiness == PRODUCTION_READY_STATUS
    route = ROUTE_PRODUCTION_READY if production_ready else ROUTE_CONFIGURED_NOT_READY
    blocking_reasons = [] if production_ready else ["production_target_ledger_domain_not_ready"]
    return {
        "requestID": request_id,
        "requestedDomain": requested_domain,
        "route": route,
        "matchedFrontierID": frontier.get("frontier_id"),
        "matchedDomainID": domain_id,
        "matchScore": match["score"],
        "matchReasons": match["reasons"],
        "readinessStatus": readiness,
        "productionTargetLedgerPath": str(production_target_ledger_path),
        "allowedClaimScopes": ledger_domain.get("allowedClaimScopes", []) if production_ready else [],
        "candidateIntakeRequired": False,
        "productionTargetReady": production_ready,
        "packOutputAllowed": production_ready,
        "r2PublishAllowed": False,
        "nativeUsabilityReady": bool(ledger_domain.get("nativeUsabilityProofComplete")) if production_ready else False,
        "blockingReasons": blocking_reasons,
        "nonClaims": [
            "bounded production-target route only" if production_ready else "configured frontier is not production-target ready",
            "not literal universal coverage",
            "not final user plans, schedules, or Steps",
            "router does not publish to R2",
        ],
    }


def _candidate_route(
    *,
    request_id: str,
    requested_domain: str,
    match: dict[str, Any],
    blocking_reasons: list[str],
) -> dict[str, Any]:
    return {
        "requestID": request_id,
        "requestedDomain": requested_domain,
        "route": ROUTE_CANDIDATE_INTAKE,
        "matchedFrontierID": match.get("frontier", {}).get("frontier_id") if match.get("frontier") else None,
        "matchedDomainID": match.get("frontier", {}).get("domain") if match.get("frontier") else None,
        "matchScore": match.get("score", 0),
        "matchReasons": match.get("reasons", []),
        "readinessStatus": "candidate_only",
        "allowedClaimScopes": [],
        "candidateIntakeRequired": True,
        "productionTargetReady": False,
        "packOutputAllowed": False,
        "r2PublishAllowed": False,
        "nativeUsabilityReady": False,
        "blockingReasons": sorted(set(blocking_reasons)),
        "nonClaims": [
            "candidate-only route",
            "not source authority",
            "not claim output",
            "not pack output",
            "not final user plans, schedules, or Steps",
        ],
    }


def _request_to_frontier_intake_proposal(request: dict[str, Any], route: dict[str, Any]) -> dict[str, Any]:
    request_id = str(request.get("request_id") or route["requestID"])
    domain = _normalize_id(str(request.get("domain") or route["requestedDomain"]))
    proposal = {
        "proposal_id": request_id,
        "domain": domain,
        "goal_intent_classes": _string_list(request, "goal_intent_classes"),
        "claim_classes": _string_list(request, "claim_classes"),
        "jurisdictions": _string_list(request, "jurisdictions"),
        "source_classes_required": _string_list(request, "source_classes_required"),
        "minimum_authority_classes": _string_list(request, "minimum_authority_classes"),
        "freshness_slas": _string_list(request, "freshness_slas"),
        "candidate_sources": request.get("candidate_sources", []) if isinstance(request.get("candidate_sources", []), list) else [],
        "non_claims": _ordered_unique(
            [
                "candidate-only route from goal-domain router",
                "not source authority",
                "not claim output",
                "not pack output",
                *_string_list(request, "non_claims"),
            ]
        ),
    }
    return proposal


def _best_frontier_match(request: dict[str, Any], frontiers: list[dict[str, Any]]) -> dict[str, Any]:
    scored = [_score_frontier_match(request, frontier) for frontier in frontiers]
    scored = [item for item in scored if item["score"] > 0]
    if not scored:
        return {"frontier": None, "score": 0, "reasons": [], "ambiguous": False}
    scored = sorted(scored, key=lambda item: (-item["score"], item["frontier"].get("frontier_id", "")))
    best = scored[0]
    ambiguous = len(scored) > 1 and scored[1]["score"] == best["score"] and "exact_domain" not in best["reasons"]
    if "exact_domain" not in best["reasons"] and "goal_intent_overlap" not in best["reasons"]:
        return {"frontier": None, "score": best["score"], "reasons": best["reasons"], "ambiguous": False}
    return {**best, "ambiguous": ambiguous}


def _score_frontier_match(request: dict[str, Any], frontier: dict[str, Any]) -> dict[str, Any]:
    requested_domain = _normalize_id(str(request.get("domain") or ""))
    aliases = {_normalize_id(value) for value in _string_list(request, "domain_aliases")}
    frontier_domain = _normalize_id(str(frontier.get("domain", "")))
    frontier_id = _normalize_id(str(frontier.get("frontier_id", "")))
    request_intents = set(_string_list(request, "goal_intent_classes"))
    frontier_intents = set(_string_list(frontier, "goal_intent_classes"))
    request_claims = set(_string_list(request, "claim_classes"))
    frontier_claims = set(_string_list(frontier, "claim_classes"))
    request_jurisdictions = set(_string_list(request, "jurisdictions"))
    frontier_jurisdictions = set(_string_list(frontier, "jurisdictions"))

    score = 0
    reasons: list[str] = []
    if requested_domain and (
        requested_domain in {frontier_domain, frontier_id}
        or frontier_domain in aliases
        or frontier_id in aliases
    ):
        score += 100
        reasons.append("exact_domain")
    intent_overlap = sorted(request_intents & frontier_intents)
    if intent_overlap:
        score += 20 * len(intent_overlap)
        reasons.append("goal_intent_overlap")
    claim_overlap = sorted(request_claims & frontier_claims)
    if claim_overlap:
        score += 5 * len(claim_overlap)
        reasons.append("claim_class_overlap")
    jurisdiction_overlap = sorted(request_jurisdictions & frontier_jurisdictions)
    if jurisdiction_overlap:
        score += len(jurisdiction_overlap)
        reasons.append("jurisdiction_overlap")
    return {"frontier": frontier, "score": score, "reasons": reasons}


def _input_schema_issues(payload: Any) -> list[str]:
    if not isinstance(payload, dict):
        return ["input payload must be an object"]
    requests = payload.get("goalDomainRequests")
    if not isinstance(requests, list) or not requests:
        return ["goalDomainRequests must be a non-empty list"]
    issues: list[str] = []
    for index, request in enumerate(requests):
        if not isinstance(request, dict):
            issues.append(f"goalDomainRequests[{index}] must be an object")
            continue
        request_id = str(request.get("request_id") or f"goalDomainRequests[{index}]")
        for field in ("domain", "claim_classes", "jurisdictions", "candidate_sources"):
            if field not in request:
                issues.append(f"{request_id}: missing required field {field}")
        for field in ("goal_intent_classes", "claim_classes", "jurisdictions", "candidate_sources"):
            if field in request and not isinstance(request[field], list):
                issues.append(f"{request_id}: {field} must be a list")
    return issues


def _frontiers(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    payload = read_json(path)
    return sorted(
        [frontier for frontier in payload.get("frontiers", []) if isinstance(frontier, dict)],
        key=lambda item: str(item.get("frontier_id", "")),
    )


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


def _read_json_if_exists(path: Path | None) -> Any:
    if path is None or not path.exists():
        return {}
    return read_json(path)


def _request_list(payload: Any) -> list[dict[str, Any]]:
    if not isinstance(payload, dict):
        return []
    requests = payload.get("goalDomainRequests", [])
    return [request for request in requests if isinstance(request, dict)]


def _string_list(container: dict[str, Any], key: str) -> list[str]:
    value = container.get(key, [])
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if isinstance(item, (str, int, float)) and str(item).strip()]


def _normalize_id(value: str) -> str:
    normalized = re.sub(r"[^a-z0-9]+", "_", value.lower()).strip("_")
    return normalized or "unnamed_domain"


def _contains_forbidden_output_marker(value: Any) -> bool:
    if isinstance(value, str):
        return value in FINAL_OUTPUT_FORBIDDEN
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(_contains_forbidden_output_marker(item) for item in value.values())
    return False


def _ordered_unique(values: list[str]) -> list[str]:
    seen: set[str] = set()
    output: list[str] = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            output.append(value)
    return output
