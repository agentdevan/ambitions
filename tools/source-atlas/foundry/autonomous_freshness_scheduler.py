"""Autonomous freshness and review work planner for Source Atlas.

This planner closes a gap between the supervised production loop and future
cron operation: it turns current frontier, source-lane, legal, API, R2, native,
and supervisor evidence into deterministic work queues for review, harvest,
pack rebuild, and execute-gated publish operations. It does not run live
harvests, write to R2, deploy Workers, mutate native runtime, or approve legal
posture.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime, timedelta
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


AUTONOMOUS_FRESHNESS_PLANNER_KIND = "ambitions.sourceAtlas.autonomousFreshnessPlanner.v1"
AUTONOMOUS_FRESHNESS_PLANNER_VERSION = "source-atlas-autonomous-freshness-planner-train-124"

FRESHNESS_NON_CLAIMS = [
    "freshness and review work planning only",
    "not a live harvest runner",
    "not an automatic production R2 writer",
    "not a Worker deployer",
    "not native runtime mutation",
    "not outside legal approval",
    "not full Source Atlas Green",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not native physical-device proof",
    "not independent accessibility proof",
    "not literal universal coverage",
    "not final user plans, schedules, Steps, priority order, recovery paths, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]

ACTION_ORDER = {
    "candidate_frontier_review": 10,
    "source_lane_review": 20,
    "terms_review": 30,
    "governed_harvest_refresh": 40,
    "pack_rebuild": 50,
    "r2_publish_gate": 60,
    "native_runtime_recertification": 70,
    "monitor_current_production": 80,
}

CURRENT_REVIEW_STATES = {"current", "approved", "approved_with_attribution", "reviewed"}


@dataclass(frozen=True)
class AutonomousFreshnessPlannerOptions:
    frontier_config_path: Path
    source_lane_registry_path: Path
    legal_terms_registry_path: Path
    api_governance_registry_path: Path
    production_target_ledger_path: Path
    production_recertification_path: Path
    production_sweep_path: Path
    autonomous_production_supervisor_path: Path | None
    output_root: Path
    created_at: str = "2026-06-29T03:00:00Z"
    run_label: str = "current"
    lookahead_days: int = 30


def run_autonomous_freshness_planner(options: AutonomousFreshnessPlannerOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    frontier_config = _read_required_json(options.frontier_config_path, "frontier config", issues)
    source_registry = _read_required_json(options.source_lane_registry_path, "source lane registry", issues)
    legal_registry = _read_required_json(options.legal_terms_registry_path, "legal terms registry", issues)
    api_registry = _read_required_json(options.api_governance_registry_path, "API governance registry", issues)
    ledger = _read_required_json(options.production_target_ledger_path, "production target ledger", issues)
    recertification = _read_required_json(options.production_recertification_path, "production recertification", issues)
    sweep = _read_required_json(options.production_sweep_path, "production sweep", issues)
    supervisor = _read_optional_json(options.autonomous_production_supervisor_path, "autonomous production supervisor", issues)

    created_day = _date_from_iso(options.created_at)
    horizon_day = created_day + timedelta(days=max(options.lookahead_days, 0)) if created_day else None

    input_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "frontierConfigPath": str(options.frontier_config_path),
                "sourceLaneRegistryPath": str(options.source_lane_registry_path),
                "legalTermsRegistryPath": str(options.legal_terms_registry_path),
                "apiGovernanceRegistryPath": str(options.api_governance_registry_path),
                "productionTargetLedgerPath": str(options.production_target_ledger_path),
                "productionRecertificationPath": str(options.production_recertification_path),
                "productionSweepPath": str(options.production_sweep_path),
                "autonomousProductionSupervisorPath": str(options.autonomous_production_supervisor_path) if options.autonomous_production_supervisor_path else None,
                "frontiers": frontier_config,
                "sourceLanes": source_registry,
                "legalTerms": legal_registry,
                "apiPolicies": api_registry,
            },
            "source-atlas-autonomous-freshness-planner-input",
        )
    )
    issues.extend(input_privacy_issues)

    frontiers = _frontiers_by_domain(frontier_config)
    source_lanes = _source_lanes_by_id(source_registry)
    licenses = _licenses_by_id(legal_registry)
    api_policies = _api_policies_by_id(api_registry)
    ledger_domains = _domains_by_id(ledger)
    recert_domains = _domains_by_id(recertification)
    sweep_domains = _domains_by_id(sweep)

    domain_plans = [
        _domain_plan(
            domain_id=domain_id,
            frontier=frontier,
            source_lanes=source_lanes,
            licenses=licenses,
            api_policies=api_policies,
            ledger_domain=ledger_domains.get(domain_id),
            recert_domain=recert_domains.get(domain_id),
            sweep_domain=sweep_domains.get(domain_id),
            created_day=created_day,
            horizon_day=horizon_day,
        )
        for domain_id, frontier in frontiers.items()
    ]
    candidate_plans = _candidate_plans(supervisor, frontiers)
    work_items = sorted(
        [*_domain_work_items(domain_plans), *_candidate_work_items(candidate_plans)],
        key=lambda item: (ACTION_ORDER.get(item["nextAction"], 999), item["domainID"]),
    )

    output_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "domainPlans": _privacy_domain_plan_view(domain_plans),
                "candidatePlans": candidate_plans,
                "workItems": _privacy_work_item_view(work_items),
            },
            "source-atlas-autonomous-freshness-planner-output",
        )
    )
    issues.extend(output_privacy_issues)

    queue_counts = _queue_counts(work_items)
    record_counts = {
        "configuredDomains": len(frontiers),
        "domainPlans": len(domain_plans),
        "candidateDomains": len(candidate_plans),
        "workItems": len(work_items),
        "monitorItems": queue_counts["monitorItems"],
        "reviewItems": queue_counts["reviewItems"],
        "harvestItems": queue_counts["harvestItems"],
        "packItems": queue_counts["packItems"],
        "r2PublishGateItems": queue_counts["r2PublishGateItems"],
        "nativeRecertificationItems": queue_counts["nativeRecertificationItems"],
        "productionWritesExecuted": queue_counts["productionWritesExecuted"],
        "liveHarvestsExecuted": queue_counts["liveHarvestsExecuted"],
        "remoteMutations": queue_counts["remoteMutations"],
        "nativeRuntimeMutations": queue_counts["nativeRuntimeMutations"],
        "finalOutputsGenerated": queue_counts["finalOutputsGenerated"],
        "privacyIssues": len(input_privacy_issues) + len(output_privacy_issues),
    }
    checks = [
        _check("frontier_config_loaded", isinstance(frontier_config, dict), [] if isinstance(frontier_config, dict) else ["frontier config missing_or_unreadable"]),
        _check("source_lane_registry_loaded", isinstance(source_registry, dict), [] if isinstance(source_registry, dict) else ["source lane registry missing_or_unreadable"]),
        _check("legal_terms_registry_loaded", isinstance(legal_registry, dict), [] if isinstance(legal_registry, dict) else ["legal terms registry missing_or_unreadable"]),
        _check("api_governance_registry_loaded", isinstance(api_registry, dict), [] if isinstance(api_registry, dict) else ["API governance registry missing_or_unreadable"]),
        _check("production_evidence_loaded", isinstance(ledger, dict) and isinstance(recertification, dict) and isinstance(sweep, dict), _production_evidence_issues(ledger, recertification, sweep)),
        _check("domain_plans_emitted", bool(domain_plans), [] if domain_plans else ["no configured domains found"]),
        _check("candidate_domains_remain_review_only", all(item["nextAction"] == "candidate_frontier_review" for item in candidate_plans), ["candidate domain promoted beyond review"] if any(item["nextAction"] != "candidate_frontier_review" for item in candidate_plans) else []),
        _check("planner_is_non_executing", _unsafe_count(queue_counts) == 0, _unsafe_count_issues(queue_counts)),
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check("output_privacy_scan_passed", not output_privacy_issues, output_privacy_issues),
    ]
    valid = not issues and bool(domain_plans) and all(check["passed"] for check in checks)
    allowed_claims = []
    if valid:
        allowed_claims = [
            "autonomous_freshness_review_work_planning_green",
            "configured_domain_review_windows_computed",
            "r2_publish_actions_remain_execute_gated",
        ]
        if candidate_plans:
            allowed_claims.append("candidate_frontier_review_work_queued")
        if queue_counts["monitorItems"]:
            allowed_claims.append("current_production_domains_have_monitor_work_items")

    report_path = output_root / "autonomous-freshness-planner-report.json"
    markdown_path = output_root / "autonomous-freshness-planner-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_FRESHNESS_PLANNER_KIND,
        "versionID": AUTONOMOUS_FRESHNESS_PLANNER_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "planID": stable_id(
            "source_atlas.autonomous_freshness_plan",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "lookaheadDays": options.lookahead_days,
                "domainPlans": domain_plans,
                "candidatePlans": candidate_plans,
            },
        ),
        "status": "Source Green for autonomous freshness and review work planning" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; autonomous freshness/review planning only",
        "overallReadinessStatus": "freshness_review_workplan_ready" if valid else "blocked_or_partial",
        "executionMode": "plan_only_no_live_harvest_no_r2_write",
        "lookaheadDays": options.lookahead_days,
        "recordCounts": record_counts,
        "queueCounts": queue_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "domainPlans": domain_plans,
        "candidatePlans": candidate_plans,
        "workItems": work_items,
        "actionSummary": _action_summary(work_items),
        "reviewQueue": [item for item in work_items if item["queue"] == "review"],
        "harvestQueue": [item for item in work_items if item["queue"] == "harvest"],
        "packQueue": [item for item in work_items if item["queue"] == "pack"],
        "r2PublishQueue": [item for item in work_items if item["queue"] == "r2_publish"],
        "nativeRecertificationQueue": [item for item in work_items if item["queue"] == "native_recertification"],
        "allowedClaims": allowed_claims,
        "blockedClaims": _blocked_claims(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": input_privacy_issues + output_privacy_issues,
        "nonClaims": FRESHNESS_NON_CLAIMS,
        "evidencePaths": {
            "frontierConfig": str(options.frontier_config_path),
            "sourceLaneRegistry": str(options.source_lane_registry_path),
            "legalTermsRegistry": str(options.legal_terms_registry_path),
            "apiGovernanceRegistry": str(options.api_governance_registry_path),
            "productionTargetLedger": str(options.production_target_ledger_path),
            "productionRecertification": str(options.production_recertification_path),
            "productionSweep": str(options.production_sweep_path),
            "autonomousProductionSupervisor": str(options.autonomous_production_supervisor_path) if options.autonomous_production_supervisor_path else None,
        },
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
        },
    }
    report["outputHashes"] = {"reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"})}
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = autonomous_freshness_planner_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def autonomous_freshness_planner_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    queue_counts = report["queueCounts"]
    lines = [
        "# Source Atlas Autonomous Freshness Planner Train 124",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Execution mode: {report['executionMode']}",
        "",
        "Scope completed:",
        "- Computed domain review and terms windows from current frontiers, source lanes, legal terms, API policies, production ledger, recertification proof, production sweep, and supervised loop evidence.",
        "- Emitted deterministic review, harvest, pack, R2 publish-gate, and native recertification queues.",
        "- Kept candidate domains in frontier-review only state.",
        "- Performed no live harvest, production R2 write, Worker deploy, native runtime mutation, active registry mutation, or final user output generation.",
        "",
        "Counts:",
        f"- Configured domains: {counts['configuredDomains']}",
        f"- Candidate domains: {counts['candidateDomains']}",
        f"- Work items: {counts['workItems']}",
        f"- Monitor items: {queue_counts['monitorItems']}",
        f"- Review items: {queue_counts['reviewItems']}",
        f"- Harvest items: {queue_counts['harvestItems']}",
        f"- Pack items: {queue_counts['packItems']}",
        f"- R2 publish-gate items: {queue_counts['r2PublishGateItems']}",
        f"- Native recertification items: {queue_counts['nativeRecertificationItems']}",
        f"- Production writes executed: {queue_counts['productionWritesExecuted']}",
        f"- Live harvests executed: {queue_counts['liveHarvestsExecuted']}",
        f"- Remote mutations: {queue_counts['remoteMutations']}",
        f"- Native runtime mutations: {queue_counts['nativeRuntimeMutations']}",
        f"- Final outputs generated: {queue_counts['finalOutputsGenerated']}",
        "",
        "Work items:",
        "",
        "| Domain | Action | Queue | State | Gate | Reasons |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for item in report.get("workItems", []):
        lines.append(
            "| {domain} | {action} | {queue} | {state} | {gate} | {reasons} |".format(
                domain=item["domainID"],
                action=item["nextAction"],
                queue=item["queue"],
                state=item["state"],
                gate=item["requiredGate"],
                reasons="<br>".join(item.get("reasons", [])) or "none",
            )
        )
    lines.extend(["", "Allowed claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("allowedClaims", [])) if report.get("allowedClaims") else lines.append("- None")
    lines.extend(["", "Blocked claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("blockedClaims", []))
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Planner inputs and outputs are public domain IDs, source IDs, review windows, gates, proof paths, and public/reference operation metadata only.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, priority order, recovery paths, or personalized paths.",
            "",
            "Validation not run:",
            "- No live harvest was run by the planner.",
            "- No production R2 write was run by the planner.",
            "- No Worker deploy was run by the planner.",
            "- No native XCTest/build-for-testing was run by the planner.",
            "- No outside legal approval, Release Green, App Store readiness, native physical-device proof, independent accessibility proof, or literal universal coverage was claimed.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: autonomous freshness planner module, CLI command, tests, generated artifacts, and QA evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: release proof, outside legal artifact, independent accessibility/device proof, and execute-gated production writes remain separate gates.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.extend(
        [
            "",
            "Rollback plan:",
            "- Revert Train 124 autonomous freshness planner module, CLI wiring, focused tests, generated artifacts, and QA evidence.",
            "- Continue using the Train 123 supervisor and individual production sweep/recertification reports directly if this planner regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _domain_plan(
    *,
    domain_id: str,
    frontier: dict[str, Any],
    source_lanes: dict[str, dict[str, Any]],
    licenses: dict[str, dict[str, Any]],
    api_policies: dict[str, dict[str, Any]],
    ledger_domain: dict[str, Any] | None,
    recert_domain: dict[str, Any] | None,
    sweep_domain: dict[str, Any] | None,
    created_day: date | None,
    horizon_day: date | None,
) -> dict[str, Any]:
    source_ids = sorted(_list_value(frontier, "source_ids"))
    lane_windows = [_source_lane_window(source_id, source_lanes.get(source_id), created_day, horizon_day) for source_id in source_ids]
    legal_windows = [_legal_window(window, licenses, created_day, horizon_day) for window in lane_windows]
    api_windows = [_api_window(window, api_policies) for window in lane_windows]
    ledger_ready = bool(ledger_domain and ledger_domain.get("readinessStatus") == "bounded_production_target_ready")
    recertified = bool(recert_domain and recert_domain.get("recertified") is True)
    sweep_ready = bool(sweep_domain and sweep_domain.get("ready") is True)
    sweep_r2_ready = bool(sweep_domain and (sweep_domain.get("r2") or {}).get("remoteUploadReadbackReady") is True)
    review_due = [item for item in lane_windows if item["windowState"] in {"due_soon", "due", "overdue", "missing"}]
    legal_due = [item for item in legal_windows if item["windowState"] in {"due_soon", "due", "overdue", "missing"}]
    api_blocked = [item for item in api_windows if item["apiReady"] is not True]

    action = "monitor_current_production"
    state = "current"
    reasons: list[str] = []
    if review_due:
        action = "source_lane_review"
        state = "review_needed"
        reasons.extend(f"source:{item['sourceID']}:{item['windowState']}" for item in review_due)
    elif legal_due:
        action = "terms_review"
        state = "terms_needed"
        reasons.extend(f"license:{item['licenseID']}:{item['windowState']}" for item in legal_due)
    elif api_blocked:
        action = "governed_harvest_refresh"
        state = "api_governance_needed"
        reasons.extend(f"api:{item['apiPolicyID']}:{','.join(item['issues'])}" for item in api_blocked)
    elif ledger_domain is None or not ledger_ready:
        action = "governed_harvest_refresh"
        state = "claim_or_ledger_refresh_needed"
        reasons.extend(_ledger_reasons(ledger_domain))
    elif sweep_domain is not None and not _pack_valid(sweep_domain):
        action = "pack_rebuild"
        state = "pack_rebuild_needed"
        reasons.extend(_nested_issues(sweep_domain.get("pack"), "pack") or ["pack proof missing or invalid"])
    elif sweep_domain is not None and not sweep_r2_ready:
        action = "r2_publish_gate"
        state = "r2_publish_gate_needed"
        reasons.extend(_nested_issues(sweep_domain.get("r2"), "r2") or ["remote R2 upload/readback proof missing or invalid"])
    elif recert_domain is None or not recertified or not sweep_ready:
        action = "native_runtime_recertification"
        state = "recertification_needed"
        reasons.extend(_recert_reasons(recert_domain, sweep_domain))
    else:
        reasons.append("current within review and terms windows")

    return {
        "domainID": domain_id,
        "frontierID": frontier.get("frontier_id") or domain_id,
        "sourceIDs": source_ids,
        "claimClasses": sorted(_list_value(frontier, "claim_classes")),
        "jurisdictions": sorted(_list_value(frontier, "jurisdictions")),
        "freshnessSLAs": sorted(_list_value(frontier, "freshness_slas")),
        "sourceReviewWindows": lane_windows,
        "legalWindows": legal_windows,
        "apiWindows": api_windows,
        "ledgerReady": ledger_ready,
        "recertified": recertified,
        "sweepReady": sweep_ready,
        "r2UploadReadbackReady": sweep_r2_ready,
        "nextAction": action,
        "state": state,
        "requiredGate": _required_gate(action),
        "queue": _queue_for_action(action),
        "reasons": sorted(set(reasons)),
        "nonClaims": [
            "not universal coverage",
            "not outside legal approval",
            "not release readiness",
            "not a final user plan, schedule, or Step generator",
        ],
    }


def _candidate_plans(supervisor: Any, frontiers: dict[str, dict[str, Any]]) -> list[dict[str, Any]]:
    if not isinstance(supervisor, dict):
        return []
    candidates = []
    for item in supervisor.get("workQueue", []):
        if not isinstance(item, dict):
            continue
        domain_id = item.get("domainID")
        if not isinstance(domain_id, str) or domain_id in frontiers:
            continue
        blockers = [blocker for blocker in item.get("blockers", []) if isinstance(blocker, str)]
        if "coverage_frontier_missing" not in blockers and item.get("requiredGate") != "frontier_governance_review":
            continue
        candidates.append(
            {
                "domainID": domain_id,
                "nextAction": "candidate_frontier_review",
                "queue": "review",
                "state": "candidate_only_review_required",
                "requiredGate": "frontier_governance_review",
                "sourceIDs": [],
                "reasons": sorted(set(blockers or ["candidate frontier not configured"])),
                "executedSafeLocalIntake": item.get("executed") is True and item.get("safeAction") is True,
                "artifactPaths": sorted(str(path) for path in item.get("artifactPaths", []) if isinstance(path, str)),
                "remoteMutation": False,
                "nativeRuntimeMutation": False,
                "finalOutputGenerated": False,
                "productionWriteExecuted": False,
                "liveHarvestExecuted": False,
                "nonClaims": [
                    "candidate-only frontier",
                    "not claim authority",
                    "not pack-ready",
                    "not production-ready",
                ],
            }
        )
    return sorted(candidates, key=lambda item: item["domainID"])


def _domain_work_items(domain_plans: list[dict[str, Any]]) -> list[dict[str, Any]]:
    items = []
    for plan in domain_plans:
        items.append(
            {
                "domainID": plan["domainID"],
                "nextAction": plan["nextAction"],
                "queue": plan["queue"],
                "state": plan["state"],
                "requiredGate": plan["requiredGate"],
                "sourceIDs": plan["sourceIDs"],
                "reasons": plan["reasons"],
                "remoteMutation": False,
                "nativeRuntimeMutation": False,
                "finalOutputGenerated": False,
                "productionWriteExecuted": False,
                "liveHarvestExecuted": False,
            }
        )
    return items


def _candidate_work_items(candidate_plans: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "domainID": item["domainID"],
            "nextAction": item["nextAction"],
            "queue": item["queue"],
            "state": item["state"],
            "requiredGate": item["requiredGate"],
            "sourceIDs": item["sourceIDs"],
            "reasons": item["reasons"],
            "remoteMutation": False,
            "nativeRuntimeMutation": False,
            "finalOutputGenerated": False,
            "productionWriteExecuted": False,
            "liveHarvestExecuted": False,
        }
        for item in candidate_plans
    ]


def _source_lane_window(
    source_id: str,
    lane: dict[str, Any] | None,
    created_day: date | None,
    horizon_day: date | None,
) -> dict[str, Any]:
    if not isinstance(lane, dict):
        return {
            "sourceID": source_id,
            "reviewStatus": "missing",
            "nextReviewDueAt": None,
            "windowState": "missing",
            "licenseID": None,
            "apiPolicyID": None,
            "freshnessSLA": None,
        }
    due_day = _date_from_iso(str(lane.get("next_review_due_at", "")))
    review_status = str(lane.get("review_status", "unknown"))
    if review_status not in CURRENT_REVIEW_STATES:
        state = "due"
    else:
        state = _window_state(due_day, created_day, horizon_day)
    return {
        "sourceID": source_id,
        "reviewStatus": review_status,
        "nextReviewDueAt": due_day.isoformat() if due_day else None,
        "windowState": state,
        "licenseID": lane.get("license_id"),
        "apiPolicyID": lane.get("api_policy_id"),
        "freshnessSLA": lane.get("freshness_sla"),
        "redistributionPolicy": lane.get("redistribution_policy"),
        "r2PackPolicy": lane.get("r2_pack_policy"),
    }


def _legal_window(
    lane_window: dict[str, Any],
    licenses: dict[str, dict[str, Any]],
    created_day: date | None,
    horizon_day: date | None,
) -> dict[str, Any]:
    license_id = lane_window.get("licenseID")
    license_record = licenses.get(str(license_id)) if isinstance(license_id, str) else None
    if not isinstance(license_record, dict):
        return {
            "sourceID": lane_window.get("sourceID"),
            "licenseID": license_id,
            "packOutputAllowed": False,
            "outsideLegalStatus": "missing",
            "expiresAt": None,
            "windowState": "missing",
            "attributionRequired": False,
        }
    expires_at = _date_from_iso(str(license_record.get("expires_at", "")))
    state = _window_state(expires_at, created_day, horizon_day)
    if license_record.get("pack_output_allowed") is not True:
        state = "due"
    if license_record.get("outside_legal_required") is True and license_record.get("outside_legal_status") not in {"approved", "not_required"}:
        state = "due"
    return {
        "sourceID": lane_window.get("sourceID"),
        "licenseID": license_id,
        "packOutputAllowed": license_record.get("pack_output_allowed") is True,
        "outsideLegalStatus": license_record.get("outside_legal_status"),
        "expiresAt": expires_at.isoformat() if expires_at else None,
        "windowState": state,
        "attributionRequired": license_record.get("attribution_required") is True,
    }


def _api_window(lane_window: dict[str, Any], api_policies: dict[str, dict[str, Any]]) -> dict[str, Any]:
    policy_id = lane_window.get("apiPolicyID")
    policy = api_policies.get(str(policy_id)) if isinstance(policy_id, str) else None
    issues = []
    if not isinstance(policy, dict):
        issues.append("api_policy_missing")
        return {
            "sourceID": lane_window.get("sourceID"),
            "apiPolicyID": policy_id,
            "apiReady": False,
            "liveFlagRequired": None,
            "executeFlagRequired": None,
            "highVolumeReviewRequired": None,
            "issues": issues,
        }
    if policy.get("live_flag_required") is not True:
        issues.append("live_flag_not_required")
    if policy.get("execute_flag_required") is not True:
        issues.append("execute_flag_not_required")
    if policy.get("secret_redaction_required") is not True:
        issues.append("secret_redaction_not_required")
    if policy.get("high_volume_review_required") is True:
        if not policy.get("budget_policy_id") and not policy.get("budget_owner"):
            issues.append("high_volume_budget_owner_missing")
        if not policy.get("daily_budget_limit") and not policy.get("monthly_budget_limit"):
            issues.append("high_volume_budget_limit_missing")
    return {
        "sourceID": lane_window.get("sourceID"),
        "apiPolicyID": policy_id,
        "apiReady": not issues,
        "liveFlagRequired": policy.get("live_flag_required") is True,
        "executeFlagRequired": policy.get("execute_flag_required") is True,
        "highVolumeReviewRequired": policy.get("high_volume_review_required") is True,
        "issues": issues,
    }


def _window_state(due_day: date | None, created_day: date | None, horizon_day: date | None) -> str:
    if due_day is None:
        return "missing"
    if created_day is not None and due_day < created_day:
        return "overdue"
    if created_day is not None and due_day == created_day:
        return "due"
    if horizon_day is not None and due_day <= horizon_day:
        return "due_soon"
    return "current"


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - defensive.
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _read_optional_json(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        return None
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - defensive.
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _frontiers_by_domain(value: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(value, dict):
        return {}
    return {
        item["frontier_id"]: item
        for item in value.get("frontiers", [])
        if isinstance(item, dict) and isinstance(item.get("frontier_id"), str)
    }


def _source_lanes_by_id(value: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(value, dict):
        return {}
    return {
        item["source_id"]: item
        for item in value.get("source_lanes", [])
        if isinstance(item, dict) and isinstance(item.get("source_id"), str)
    }


def _licenses_by_id(value: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(value, dict):
        return {}
    return {
        item["license_id"]: item
        for item in value.get("licenses", [])
        if isinstance(item, dict) and isinstance(item.get("license_id"), str)
    }


def _api_policies_by_id(value: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(value, dict):
        return {}
    return {
        item["api_policy_id"]: item
        for item in value.get("api_policies", [])
        if isinstance(item, dict) and isinstance(item.get("api_policy_id"), str)
    }


def _domains_by_id(value: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(value, dict):
        return {}
    return {
        item["domainID"]: item
        for item in value.get("domains", [])
        if isinstance(item, dict) and isinstance(item.get("domainID"), str)
    }


def _list_value(value: dict[str, Any] | None, key: str) -> list[str]:
    if not isinstance(value, dict):
        return []
    raw = value.get(key, [])
    if isinstance(raw, list):
        return [str(item) for item in raw if item]
    if isinstance(raw, str) and raw:
        return [raw]
    return []


def _date_from_iso(value: str) -> date | None:
    if not value:
        return None
    try:
        if value.endswith("Z"):
            value = value[:-1] + "+00:00"
        return datetime.fromisoformat(value).date()
    except ValueError:
        try:
            return date.fromisoformat(value[:10])
        except ValueError:
            return None


def _ledger_reasons(domain: dict[str, Any] | None) -> list[str]:
    if not isinstance(domain, dict):
        return ["production target ledger domain missing"]
    reasons = [str(item) for item in domain.get("blockedReasons", []) if isinstance(item, str)]
    if domain.get("claimGraphProofComplete") is not True:
        reasons.append("claim graph proof missing or incomplete")
    if not reasons:
        reasons.append("production target ledger not ready")
    return reasons


def _recert_reasons(recert_domain: dict[str, Any] | None, sweep_domain: dict[str, Any] | None) -> list[str]:
    reasons = []
    if not isinstance(recert_domain, dict):
        reasons.append("production recertification domain missing")
    elif recert_domain.get("recertified") is not True:
        reasons.extend(str(item) for item in recert_domain.get("blockers", []) if isinstance(item, str))
        if not reasons:
            reasons.append("production recertification not ready")
    if isinstance(sweep_domain, dict) and sweep_domain.get("ready") is not True:
        reasons.extend(str(item) for item in sweep_domain.get("issues", []) if isinstance(item, str))
        if not reasons:
            reasons.append("production sweep not ready")
    return reasons or ["native/runtime recertification required"]


def _nested_issues(value: Any, prefix: str) -> list[str]:
    if not isinstance(value, dict):
        return [f"{prefix} proof missing"]
    return [str(item) for item in value.get("issues", []) if isinstance(item, str)]


def _pack_valid(sweep_domain: dict[str, Any]) -> bool:
    pack = sweep_domain.get("pack")
    return isinstance(pack, dict) and pack.get("valid") is True


def _required_gate(action: str) -> str:
    return {
        "candidate_frontier_review": "frontier_governance_review",
        "source_lane_review": "source_lane_legal_api_review",
        "terms_review": "terms_license_review_and_approval_artifact_when_required",
        "governed_harvest_refresh": "fixture_first_live_requires_live_execute_budget",
        "pack_rebuild": "pack_schema_license_provenance_private_scan",
        "r2_publish_gate": "execute_budget_owner_approval_credentials_upload_readback_sha256",
        "native_runtime_recertification": "focused_native_request_privacy_offline_no_account_tests",
        "monitor_current_production": "next_due_review_or_freshness_window",
    }.get(action, "manual_review")


def _queue_for_action(action: str) -> str:
    return {
        "candidate_frontier_review": "review",
        "source_lane_review": "review",
        "terms_review": "review",
        "governed_harvest_refresh": "harvest",
        "pack_rebuild": "pack",
        "r2_publish_gate": "r2_publish",
        "native_runtime_recertification": "native_recertification",
        "monitor_current_production": "monitor",
    }.get(action, "review")


def _queue_counts(work_items: list[dict[str, Any]]) -> dict[str, int]:
    return {
        "items": len(work_items),
        "monitorItems": sum(1 for item in work_items if item["queue"] == "monitor"),
        "reviewItems": sum(1 for item in work_items if item["queue"] == "review"),
        "harvestItems": sum(1 for item in work_items if item["queue"] == "harvest"),
        "packItems": sum(1 for item in work_items if item["queue"] == "pack"),
        "r2PublishGateItems": sum(1 for item in work_items if item["queue"] == "r2_publish"),
        "nativeRecertificationItems": sum(1 for item in work_items if item["queue"] == "native_recertification"),
        "productionWritesExecuted": sum(1 for item in work_items if item.get("productionWriteExecuted") is True),
        "liveHarvestsExecuted": sum(1 for item in work_items if item.get("liveHarvestExecuted") is True),
        "remoteMutations": sum(1 for item in work_items if item.get("remoteMutation") is True),
        "nativeRuntimeMutations": sum(1 for item in work_items if item.get("nativeRuntimeMutation") is True),
        "finalOutputsGenerated": sum(1 for item in work_items if item.get("finalOutputGenerated") is True),
    }


def _unsafe_count(queue_counts: dict[str, int]) -> int:
    return (
        queue_counts["productionWritesExecuted"]
        + queue_counts["liveHarvestsExecuted"]
        + queue_counts["remoteMutations"]
        + queue_counts["nativeRuntimeMutations"]
        + queue_counts["finalOutputsGenerated"]
    )


def _unsafe_count_issues(queue_counts: dict[str, int]) -> list[str]:
    keys = {"productionWritesExecuted", "liveHarvestsExecuted", "remoteMutations", "nativeRuntimeMutations", "finalOutputsGenerated"}
    return [f"{key}={value}" for key, value in sorted(queue_counts.items()) if key in keys and value]


def _production_evidence_issues(ledger: Any, recertification: Any, sweep: Any) -> list[str]:
    issues = []
    if not isinstance(ledger, dict):
        issues.append("production target ledger missing_or_unreadable")
    if not isinstance(recertification, dict):
        issues.append("production recertification missing_or_unreadable")
    if not isinstance(sweep, dict):
        issues.append("production sweep missing_or_unreadable")
    return issues


def _privacy_domain_plan_view(domain_plans: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "domainID": item["domainID"],
            "nextAction": item["nextAction"],
            "state": item["state"],
            "requiredGate": item["requiredGate"],
            "sourceCount": len(item.get("sourceIDs", [])),
            "reasonCount": len(item.get("reasons", [])),
        }
        for item in domain_plans
    ]


def _privacy_work_item_view(work_items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "domainID": item["domainID"],
            "nextAction": item["nextAction"],
            "queue": item["queue"],
            "state": item["state"],
            "requiredGate": item["requiredGate"],
            "productionWriteExecuted": item["productionWriteExecuted"],
            "remoteMutation": item["remoteMutation"],
            "nativeRuntimeMutation": item["nativeRuntimeMutation"],
            "finalOutputGenerated": item["finalOutputGenerated"],
        }
        for item in work_items
    ]


def _action_summary(work_items: list[dict[str, Any]]) -> dict[str, int]:
    summary: dict[str, int] = {}
    for item in work_items:
        action = item["nextAction"]
        summary[action] = summary.get(action, 0) + 1
    return dict(sorted(summary.items(), key=lambda pair: (ACTION_ORDER.get(pair[0], 999), pair[0])))


def _blocked_claims() -> list[str]:
    return sorted(
        {
            "full_source_atlas_green",
            "outside_legal_approval",
            "release_green",
            "runtime_release_green",
            "app_store_readiness",
            "testflight_readiness",
            "native_device_green",
            "independent_accessibility_green",
            "literal_universal_coverage",
            "automatic_r2_write_without_execute_budget_approval",
            "new_remote_r2_write_executed_by_freshness_planner",
            "uncontrolled_live_harvest",
            "active_registry_mutation_by_freshness_planner",
            "source_atlas_private_goal_text_processing",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(issues))}
