"""Autonomous Source Atlas operations planner.

This planner turns current frontier, production-ledger, and recertification
evidence into deterministic next actions. It does not run live harvests,
publish to R2, deploy gateway code, or touch native runtime state. Those remain
behind the existing explicit execute, budget, approval, and runtime proof gates.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_id, write_json


AUTONOMOUS_OPERATIONS_PLANNER_VERSION = "source-atlas-autonomous-operations-planner-train-105"
AUTONOMOUS_OPERATIONS_PLANNER_KIND = "ambitions.sourceAtlas.autonomousOperationsPlanner.v1"

AUTONOMOUS_OPERATIONS_NON_CLAIMS = [
    "operations planner only",
    "not an uncontrolled live harvester",
    "not an automatic production R2 writer",
    "not a Worker deployer by itself",
    "not native runtime proof by itself",
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not App Store or TestFlight readiness",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]

ACTION_ORDER = {
    "define_coverage_frontier": 10,
    "complete_source_governance_review": 20,
    "run_governed_harvest_and_claim_frontier": 30,
    "run_pack_production": 40,
    "run_r2_publisher": 50,
    "run_public_gateway_release": 60,
    "compile_native_refresh_registry": 70,
    "run_native_runtime_proof": 80,
    "refresh_production_target_ledger": 90,
    "run_production_recertification": 100,
    "monitor_current_production_runtime": 110,
}


@dataclass(frozen=True)
class AutonomousOperationsPlannerOptions:
    frontier_config_path: Path
    source_lane_registry_path: Path
    output_root: Path
    production_target_ledger_path: Path | None = None
    production_recertification_path: Path | None = None
    requested_domains: tuple[str, ...] = ()
    created_at: str = "2026-06-28T00:00:00Z"


def compile_autonomous_operations_plan(options: AutonomousOperationsPlannerOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    frontier_config = _read_optional_json(options.frontier_config_path, "frontier config", issues)
    source_registry = _read_optional_json(options.source_lane_registry_path, "source lane registry", issues)
    ledger = _read_optional_json(options.production_target_ledger_path, "production target ledger", issues)
    recertification = _read_optional_json(options.production_recertification_path, "production recertification", issues)

    input_bundle = {
        "frontierConfigPath": str(options.frontier_config_path),
        "sourceLaneRegistryPath": str(options.source_lane_registry_path),
        "productionTargetLedgerPath": str(options.production_target_ledger_path) if options.production_target_ledger_path else None,
        "productionRecertificationPath": str(options.production_recertification_path) if options.production_recertification_path else None,
        "requestedDomains": list(options.requested_domains),
        "frontierConfig": frontier_config,
        "sourceLaneRegistry": source_registry,
        "productionTargetLedger": ledger,
        "productionRecertification": recertification,
    }
    privacy_issues = boundary_issue_strings(boundary_issues_for_value(input_bundle, "source-atlas-autonomous-operations-planner"))
    issues.extend(privacy_issues)

    frontiers = _frontiers_by_domain(frontier_config)
    source_lanes = _source_lanes_by_id(source_registry)
    ledger_domains = _ledger_domains(ledger)
    recert_domains = _recertified_domains(recertification)
    requested = set(options.requested_domains)
    requested_resolution = _resolve_requested_domains(requested, frontiers)
    domain_ids = sorted(
        set(frontiers)
        | set(ledger_domains)
        | set(recert_domains)
        | set(requested_resolution["aliasesByDomain"])
        | set(requested_resolution["unmatchedRequestedDomains"])
    )
    created_day = _date_from_iso(options.created_at)
    domain_plans = [
        _domain_plan(
            domain_id=domain_id,
            frontier=frontiers.get(domain_id),
            source_lanes=source_lanes,
            ledger_domain=ledger_domains.get(domain_id),
            recert_domain=recert_domains.get(domain_id),
            requested=domain_id in requested or domain_id in requested_resolution["aliasesByDomain"],
            requested_aliases=tuple(requested_resolution["aliasesByDomain"].get(domain_id, [])),
            created_day=created_day,
        )
        for domain_id in domain_ids
    ]
    domain_plans.sort(key=lambda item: (ACTION_ORDER.get(item["nextAction"], 999), item["domainID"]))

    global_blockers = _global_blockers(frontier_config, source_registry, ledger, recertification, domain_plans, privacy_issues)
    valid = not issues and bool(domain_plans)
    checks = [
        _check("frontier_config_loaded", isinstance(frontier_config, dict), [] if isinstance(frontier_config, dict) else ["frontier config missing_or_unreadable"]),
        _check("source_lane_registry_loaded", isinstance(source_registry, dict), [] if isinstance(source_registry, dict) else ["source lane registry missing_or_unreadable"]),
        _check("domain_plan_emitted", bool(domain_plans), [] if domain_plans else ["no domains available for operations planning"]),
        _check("privacy_boundary", not privacy_issues, privacy_issues),
        _check("planner_is_non_executing", True, []),
    ]

    report_path = output_root / "autonomous-operations-plan.json"
    markdown_path = output_root / "autonomous-operations-plan.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_OPERATIONS_PLANNER_KIND,
        "versionID": AUTONOMOUS_OPERATIONS_PLANNER_VERSION,
        "createdAt": options.created_at,
        "planID": stable_id("source_atlas.autonomous_operations_plan", {"domains": domain_plans, "createdAt": options.created_at}),
        "status": "Source Green for autonomous operations planning" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; autonomous operations planning only",
        "executionMode": "plan_only",
        "recordCounts": {
            "configuredFrontiers": len(frontiers),
            "ledgerDomains": len(ledger_domains),
            "recertifiedDomains": sum(1 for item in domain_plans if item["recertified"] is True),
            "requestedDomains": len(requested),
            "resolvedRequestedDomainAliases": sum(len(value) for value in requested_resolution["aliasesByDomain"].values()),
            "unmatchedRequestedDomains": len(requested_resolution["unmatchedRequestedDomains"]),
            "plannedDomains": len(domain_plans),
            "blockedDomains": sum(1 for item in domain_plans if item["readiness"] == "blocked"),
            "monitorDomains": sum(1 for item in domain_plans if item["nextAction"] == "monitor_current_production_runtime"),
            "actionableDomains": sum(1 for item in domain_plans if item["nextAction"] != "monitor_current_production_runtime"),
            "privacyIssues": len(privacy_issues),
        },
        "checks": checks,
        "issues": issues,
        "globalBlockers": global_blockers,
        "domainPlans": domain_plans,
        "requestedDomainResolution": requested_resolution,
        "actionSummary": _action_summary(domain_plans),
        "evidencePaths": {
            "frontierConfig": str(options.frontier_config_path),
            "sourceLaneRegistry": str(options.source_lane_registry_path),
            "productionTargetLedger": str(options.production_target_ledger_path) if options.production_target_ledger_path else None,
            "productionRecertification": str(options.production_recertification_path) if options.production_recertification_path else None,
        },
        "allowedClaims": ["deterministic_autonomous_operations_planning"] if valid else [],
        "blockedClaims": sorted(
            {
                "literal_universal_coverage",
                "full_source_atlas_green",
                "outside_legal_approval",
                "release_green",
                "app_store_readiness",
                "uncontrolled_live_harvest",
                "automatic_r2_write_without_execute_budget_approval",
                "final_user_plans_schedules_steps_from_source_atlas_or_r2",
            }
        ),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "nonClaims": AUTONOMOUS_OPERATIONS_NON_CLAIMS,
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
        },
    }
    markdown = autonomous_operations_plan_markdown(report)
    write_json(report_path, report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def autonomous_operations_plan_markdown(report: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Autonomous Operations Planner Train 105",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Execution mode: {report['executionMode']}",
        "",
        "## Action Summary",
        "",
    ]
    for action, count in report.get("actionSummary", {}).items():
        lines.append(f"- `{action}`: {count}")
    lines.extend(
        [
            "",
            "## Domain Plan",
            "",
            "| Domain | Readiness | Next Action | Gate | Command | Blockers |",
            "| --- | --- | --- | --- | --- | --- |",
        ]
    )
    for plan in report.get("domainPlans", []):
        blockers = "<br>".join(plan.get("blockers", []))
        command = plan.get("plannedCommand", "")
        lines.append(
            "| {domain} | {readiness} | {action} | {gate} | `{command}` | {blockers} |".format(
                domain=plan["domainID"],
                readiness=plan["readiness"],
                action=plan["nextAction"],
                gate=plan["requiredGate"],
                command=command,
                blockers=blockers,
            )
        )
    lines.extend(["", "## Global Blockers", ""])
    if report.get("globalBlockers"):
        lines.extend(f"- {blocker}" for blocker in report["globalBlockers"])
    else:
        lines.append("- None")
    lines.extend(["", "## Product Law Preserved", ""])
    lines.extend(
        [
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Planner inputs and outputs are domain IDs, source IDs, proof paths, and public/reference operation metadata only.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- The planner does not run live harvest, production R2 write, Worker deploy, or native runtime proof by itself.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, or personalized paths.",
        ]
    )
    lines.extend(["", "## Production Non-Claims", ""])
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.extend(
        [
            "",
            "## Rollback Plan",
            "",
            "- Revert Train 105 planner module, CLI wiring, tests, generated operations-plan artifacts, and QA evidence.",
            "- Continue using existing delivery-chain and recertification gates directly if planner routing regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _resolve_requested_domains(requested_domains: set[str], frontiers: dict[str, dict[str, Any]]) -> dict[str, Any]:
    alias_index: dict[str, set[str]] = {}
    for domain_id, frontier in frontiers.items():
        for alias in _frontier_aliases(domain_id, frontier):
            alias_index.setdefault(_normalize_id(alias), set()).add(domain_id)

    aliases_by_domain: dict[str, list[str]] = {}
    unmatched: list[str] = []
    ambiguous: dict[str, list[str]] = {}
    for requested in sorted(requested_domains):
        normalized = _normalize_id(requested)
        matches = sorted(alias_index.get(normalized, set()))
        if len(matches) == 1:
            aliases_by_domain.setdefault(matches[0], []).append(requested)
        elif len(matches) > 1:
            ambiguous[requested] = matches
            unmatched.append(requested)
        else:
            unmatched.append(requested)
    return {
        "aliasesByDomain": {key: sorted(values) for key, values in sorted(aliases_by_domain.items())},
        "unmatchedRequestedDomains": sorted(unmatched),
        "ambiguousRequestedDomains": dict(sorted(ambiguous.items())),
    }


def _frontier_aliases(domain_id: str, frontier: dict[str, Any]) -> list[str]:
    aliases = [
        domain_id,
        str(frontier.get("frontier_id") or ""),
        str(frontier.get("domain") or ""),
        *_list_value(frontier, "goal_intent_classes"),
        *_list_value(frontier, "domain_aliases"),
    ]
    return sorted({alias for alias in aliases if alias})


def _normalize_id(value: str) -> str:
    return value.strip().lower().replace("-", "_").replace(" ", "_")


def _domain_plan(
    *,
    domain_id: str,
    frontier: dict[str, Any] | None,
    source_lanes: dict[str, dict[str, Any]],
    ledger_domain: dict[str, Any] | None,
    recert_domain: dict[str, Any] | None,
    requested: bool,
    created_day: date | None,
    requested_aliases: tuple[str, ...] = (),
) -> dict[str, Any]:
    source_ids = sorted(_list_value(frontier, "source_ids"))
    source_review_due = _source_review_due(source_ids, source_lanes, created_day)
    blockers: list[str] = []
    if frontier is None:
        action = "define_coverage_frontier"
        readiness = "blocked"
        blockers.append("coverage_frontier_missing")
    elif source_review_due:
        action = "complete_source_governance_review"
        readiness = "review_due"
        blockers.extend(f"source_review_due:{source_id}" for source_id in source_review_due)
    else:
        ledger_blockers = _ledger_blockers(ledger_domain)
        recert_blockers = _recertification_blockers(recert_domain)
        if ledger_domain is None:
            action = "run_governed_harvest_and_claim_frontier"
            readiness = "not_started"
            blockers.append("production_target_ledger_domain_missing")
        elif ledger_domain.get("frontierConfigured") is not True or ledger_domain.get("claimGraphProofComplete") is not True:
            action = "run_governed_harvest_and_claim_frontier"
            readiness = "claim_graph_needed"
            blockers.extend(ledger_blockers or ["claim_frontier_proof_missing_or_incomplete"])
        elif ledger_domain.get("packProductionProofComplete") is not True:
            action = "run_pack_production"
            readiness = "pack_needed"
            blockers.extend(ledger_blockers or ["pack_production_proof_missing_or_incomplete"])
        elif ledger_domain.get("r2ProductionProofComplete") is not True:
            action = "run_r2_publisher"
            readiness = "r2_publish_needed"
            blockers.extend(ledger_blockers or ["production_r2_upload_readback_missing_or_incomplete"])
        elif ledger_domain.get("gatewayProofComplete") is not True:
            action = "run_public_gateway_release"
            readiness = "gateway_needed"
            blockers.extend(ledger_blockers or ["public_gateway_live_verification_missing_or_incomplete"])
        elif ledger_domain.get("nativeRegistryProofComplete") is not True:
            action = "compile_native_refresh_registry"
            readiness = "native_registry_needed"
            blockers.extend(ledger_blockers or ["native_refresh_registry_target_missing_or_inactive"])
        elif ledger_domain.get("nativeRuntimeBoundaryProofComplete") is not True or ledger_domain.get("nativeUsabilityProofComplete") is not True:
            action = "run_native_runtime_proof"
            readiness = "native_runtime_needed"
            blockers.extend(ledger_blockers or ["native_runtime_boundary_proof_missing_or_incomplete"])
        elif recert_domain is None:
            action = "run_production_recertification"
            readiness = "recertification_needed"
            blockers.append("production_recertification_domain_missing")
        elif recert_blockers:
            action = _action_for_recert_blockers(recert_blockers)
            readiness = "recertification_blocked"
            blockers.extend(recert_blockers)
        else:
            action = "monitor_current_production_runtime"
            readiness = "current_production_runtime_recertified"

    return {
        "domainID": domain_id,
        "requested": requested,
        "requestedAliases": list(requested_aliases),
        "frontierConfigured": frontier is not None,
        "ledgerReady": bool(ledger_domain and ledger_domain.get("readinessStatus") == "bounded_production_target_ready"),
        "recertified": bool(recert_domain and recert_domain.get("recertified") is True),
        "readiness": readiness,
        "nextAction": action,
        "requiredGate": _required_gate(action),
        "plannedCommand": _planned_command(action, domain_id),
        "sourceIDs": source_ids,
        "sourceReviewDue": source_review_due,
        "packableClaimCount": int((ledger_domain or {}).get("packableClaimCount", 0) or 0),
        "blockers": sorted(set(blockers)),
        "allowedArtifactClasses": sorted(_list_value(frontier, "claim_classes")) if frontier else [],
        "nonClaims": [
            "not universal coverage",
            "not outside legal approval",
            "not a final user plan, schedule, or Step generator",
        ],
    }


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


def _ledger_domains(value: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(value, dict):
        return {}
    return {
        item["domainID"]: item
        for item in value.get("domains", [])
        if isinstance(item, dict) and isinstance(item.get("domainID"), str)
    }


def _recertified_domains(value: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(value, dict):
        return {}
    return {
        item["domainID"]: item
        for item in value.get("domains", [])
        if isinstance(item, dict) and isinstance(item.get("domainID"), str)
    }


def _ledger_blockers(domain: dict[str, Any] | None) -> list[str]:
    if not isinstance(domain, dict):
        return ["production_target_ledger_domain_missing"]
    return [item for item in domain.get("blockedReasons", []) if isinstance(item, str)]


def _recertification_blockers(domain: dict[str, Any] | None) -> list[str]:
    if not isinstance(domain, dict):
        return ["production_recertification_domain_missing"]
    return [item for item in domain.get("blockers", []) if isinstance(item, str)]


def _action_for_recert_blockers(blockers: list[str]) -> str:
    if any("ledger" in blocker for blocker in blockers):
        return "refresh_production_target_ledger"
    if any("gateway" in blocker for blocker in blockers):
        return "run_public_gateway_release"
    if any("native_registry" in blocker for blocker in blockers):
        return "compile_native_refresh_registry"
    if any("native_runtime" in blocker for blocker in blockers):
        return "run_native_runtime_proof"
    return "run_production_recertification"


def _required_gate(action: str) -> str:
    return {
        "define_coverage_frontier": "frontier_governance_review",
        "complete_source_governance_review": "source_lane_legal_api_review",
        "run_governed_harvest_and_claim_frontier": "fixture_by_default_live_requires_live_execute_budget",
        "run_pack_production": "pack_schema_license_provenance_private_scan",
        "run_r2_publisher": "execute_budget_approval_credentials_upload_readback_sha256",
        "run_public_gateway_release": "worker_allowlist_live_verify_deploy_requires_execute",
        "compile_native_refresh_registry": "active_target_approval_and_registry_privacy_scan",
        "run_native_runtime_proof": "focused_native_runtime_request_privacy_offline_no_account_tests",
        "refresh_production_target_ledger": "current_artifact_discovery_and_privacy_scan",
        "run_production_recertification": "ledger_gateway_native_registry_runtime_coherence",
        "monitor_current_production_runtime": "next_due_review_or_freshness_window",
    }.get(action, "manual_review")


def _planned_command(action: str, domain_id: str) -> str:
    if action == "define_coverage_frontier":
        return f"source-atlas-foundry frontier-intake --domain {domain_id} --review-required"
    if action == "complete_source_governance_review":
        return f"source-atlas-foundry goal-domain-review-packets --domain {domain_id}"
    if action == "run_governed_harvest_and_claim_frontier":
        return f"source-atlas-foundry public-reference-delivery-chain --domain {domain_id} --harvest-mode fixture --r2-mode dry_run"
    if action == "run_pack_production":
        return f"source-atlas-foundry pack-production --domain {domain_id} --environment production --channel stable"
    if action == "run_r2_publisher":
        return f"source-atlas-foundry pack-r2-publisher --environment production --channel stable --mode remote_r2 --execute --approval-artifact <path> --budget-policy <id>"
    if action == "run_public_gateway_release":
        return "source-atlas-foundry r2-public-gateway-release --verify-live --production-target-ledger <path> --native-registry-artifact <path>"
    if action == "compile_native_refresh_registry":
        return "source-atlas-foundry native-refresh-registry --publisher-report <path> --status active --production-target-ledger <path>"
    if action == "run_native_runtime_proof":
        return "scripts/ambitions-xcode-build-for-testing.sh --batch green-standard # plus focused Source Atlas native suites"
    if action == "refresh_production_target_ledger":
        return "source-atlas-foundry production-target-ledger --gateway-release-report <path> --native-registry-report <path> --native-runtime-closeout <path>"
    if action == "run_production_recertification":
        return "source-atlas-foundry production-recertification --production-target-ledger <path> --gateway-release-report <path> --native-runtime-report <path>"
    return "none"


def _source_review_due(source_ids: list[str], source_lanes: dict[str, dict[str, Any]], created_day: date | None) -> list[str]:
    if created_day is None:
        return []
    due = []
    for source_id in source_ids:
        lane = source_lanes.get(source_id)
        if not isinstance(lane, dict):
            due.append(source_id)
            continue
        review_due = _date_from_iso(str(lane.get("next_review_due_at", "")))
        review_status = str(lane.get("review_status", ""))
        if review_status not in {"approved", "approved_with_attribution", "current", "reviewed"}:
            due.append(source_id)
        elif review_due is not None and review_due <= created_day:
            due.append(source_id)
    return sorted(set(due))


def _global_blockers(frontier_config: Any, source_registry: Any, ledger: Any, recertification: Any, domain_plans: list[dict[str, Any]], privacy_issues: list[str]) -> list[str]:
    blockers = []
    if not isinstance(frontier_config, dict):
        blockers.append("frontier_config_missing_or_unreadable")
    if not isinstance(source_registry, dict):
        blockers.append("source_lane_registry_missing_or_unreadable")
    if ledger is None:
        blockers.append("production_target_ledger_not_supplied")
    elif isinstance(ledger, dict) and ledger.get("valid") is not True:
        blockers.append("production_target_ledger_invalid")
    if recertification is None:
        blockers.append("production_recertification_not_supplied")
    elif isinstance(recertification, dict) and recertification.get("valid") is not True:
        blockers.append("production_recertification_invalid")
    if privacy_issues:
        blockers.append("privacy_boundary_issues_present")
    if any(plan["nextAction"] != "monitor_current_production_runtime" for plan in domain_plans):
        blockers.append("one_or_more_domains_need_operations")
    blockers.append("literal_universal_coverage_remains_blocked")
    return sorted(set(blockers))


def _action_summary(domain_plans: list[dict[str, Any]]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for plan in domain_plans:
        action = plan["nextAction"]
        counts[action] = counts.get(action, 0) + 1
    return dict(sorted(counts.items(), key=lambda item: (ACTION_ORDER.get(item[0], 999), item[0])))


def _list_value(value: dict[str, Any] | None, key: str) -> list[str]:
    raw = (value or {}).get(key, [])
    if not isinstance(raw, list):
        return []
    return [item for item in raw if isinstance(item, str)]


def _date_from_iso(value: str) -> date | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00")).date()
    except ValueError:
        try:
            return date.fromisoformat(value[:10])
        except ValueError:
            return None


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": issues}
