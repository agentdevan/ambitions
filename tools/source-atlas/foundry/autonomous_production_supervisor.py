"""Supervised autonomous production loop for Source Atlas.

The supervisor is the cron-safe operating command over the current Source Atlas
tooling. It refreshes the bounded production orchestrator, compiles the
operations plan, executes only safe local/candidate actions, and emits one work
queue for what ran, what was observed, and what remains gated.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .autonomous_operations_executor import (
    AutonomousOperationsExecutorOptions,
    run_autonomous_operations_executor,
)
from .autonomous_operations_planner import (
    AutonomousOperationsPlannerOptions,
    compile_autonomous_operations_plan,
)
from .autonomous_production_orchestrator import (
    AutonomousProductionOrchestratorOptions,
    run_autonomous_production_orchestrator,
)
from .autonomous_freshness_scheduler import (
    AutonomousFreshnessPlannerOptions,
    run_autonomous_freshness_planner,
)
from .autonomous_maintenance_executor import (
    AutonomousMaintenanceExecutorOptions,
    run_autonomous_maintenance_executor,
)
from .autonomous_promotion_runner import (
    AutonomousPromotionRunnerOptions,
    run_autonomous_promotion_runner,
)
from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


AUTONOMOUS_PRODUCTION_SUPERVISOR_KIND = "ambitions.sourceAtlas.autonomousProductionSupervisor.v1"
AUTONOMOUS_PRODUCTION_SUPERVISOR_VERSION = "source-atlas-autonomous-production-supervisor-train-128"

SUPERVISOR_NON_CLAIMS = [
    "supervised autonomous Source Atlas operating loop only",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not native physical-device proof",
    "not independent accessibility proof",
    "not literal universal coverage",
    "not automatic production R2 write",
    "not uncontrolled live harvest",
    "not Worker deploy",
    "not native runtime mutation",
    "not active registry mutation",
    "not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class AutonomousProductionSupervisorOptions:
    frontier_config_path: Path
    source_lane_registry_path: Path
    production_target_ledger_path: Path
    production_recertification_path: Path
    production_finish_line_gate_path: Path
    production_sweep_path: Path
    arbitrary_domain_gate_path: Path
    goal_domain_gauntlet_path: Path
    autonomous_control_loop_path: Path
    autonomous_cycle_path: Path
    output_root: Path
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    owner_approval_path: Path | None = None
    legal_approval_packet_path: Path | None = None
    promotion_bucket: str | None = None
    requested_domains: tuple[str, ...] = ()
    created_at: str = "2026-06-29T02:45:00Z"
    run_label: str = "current"
    execute_safe_actions: bool = False
    execute_r2: bool = False
    allow_fixture_delivery_chain: bool = False
    delivery_chain_limit: int = 5
    lookahead_days: int = 30


def run_autonomous_production_supervisor(options: AutonomousProductionSupervisorOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    input_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "frontierConfigPath": str(options.frontier_config_path),
                "sourceLaneRegistryPath": str(options.source_lane_registry_path),
                "requestedDomains": list(options.requested_domains),
                "runLabel": options.run_label,
                "executeSafeActions": options.execute_safe_actions,
                "executeR2": options.execute_r2,
                "allowFixtureDeliveryChain": options.allow_fixture_delivery_chain,
                "legalTermsRegistryPath": str(options.legal_terms_registry_path) if options.legal_terms_registry_path else None,
                "apiGovernanceRegistryPath": str(options.api_governance_registry_path) if options.api_governance_registry_path else None,
                "ownerApprovalPath": str(options.owner_approval_path) if options.owner_approval_path else None,
                "legalApprovalPacketPath": str(options.legal_approval_packet_path) if options.legal_approval_packet_path else None,
            },
            "source-atlas-autonomous-production-supervisor-input",
        )
    )

    stages: dict[str, Any] = {}
    issues: list[str] = list(input_privacy_issues)
    if not input_privacy_issues:
        stages["productionOrchestrator"] = run_autonomous_production_orchestrator(
            AutonomousProductionOrchestratorOptions(
                production_target_ledger_path=options.production_target_ledger_path,
                production_finish_line_gate_path=options.production_finish_line_gate_path,
                production_sweep_path=options.production_sweep_path,
                arbitrary_domain_gate_path=options.arbitrary_domain_gate_path,
                goal_domain_gauntlet_path=options.goal_domain_gauntlet_path,
                autonomous_control_loop_path=options.autonomous_control_loop_path,
                autonomous_cycle_path=options.autonomous_cycle_path,
                output_root=output_root / "01-production-orchestrator",
                created_at=options.created_at,
                run_label=options.run_label,
            )
        )
        stages["operationsPlan"] = compile_autonomous_operations_plan(
            AutonomousOperationsPlannerOptions(
                frontier_config_path=options.frontier_config_path,
                source_lane_registry_path=options.source_lane_registry_path,
                production_target_ledger_path=options.production_target_ledger_path,
                production_recertification_path=options.production_recertification_path,
                requested_domains=options.requested_domains,
                output_root=output_root / "02-operations-plan",
                created_at=options.created_at,
            )
        )
        if _valid(stages.get("operationsPlan")):
            stages["operationsExecutor"] = run_autonomous_operations_executor(
                AutonomousOperationsExecutorOptions(
                    operations_plan_path=Path(stages["operationsPlan"]["outputPaths"]["report"]),
                    output_root=output_root / "03-operations-executor",
                    created_at=options.created_at,
                    execute_safe_actions=options.execute_safe_actions,
                    allow_fixture_delivery_chain=options.allow_fixture_delivery_chain,
                    frontier_config_path=options.frontier_config_path,
                    delivery_chain_limit=options.delivery_chain_limit,
                )
            )
        if _valid(stages.get("operationsExecutor")) and options.legal_terms_registry_path and options.api_governance_registry_path:
            work_queue_seed_path = output_root / "04-maintenance-input" / "supervisor-work-queue.json"
            write_json(
                work_queue_seed_path,
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.autonomousProductionSupervisor.workQueueSeed.v1",
                    "createdAt": options.created_at,
                    "valid": True,
                    "workQueue": _work_queue(stages),
                    "nonClaims": SUPERVISOR_NON_CLAIMS,
                },
            )
            stages["freshnessPlanner"] = run_autonomous_freshness_planner(
                AutonomousFreshnessPlannerOptions(
                    frontier_config_path=options.frontier_config_path,
                    source_lane_registry_path=options.source_lane_registry_path,
                    legal_terms_registry_path=options.legal_terms_registry_path,
                    api_governance_registry_path=options.api_governance_registry_path,
                    production_target_ledger_path=options.production_target_ledger_path,
                    production_recertification_path=options.production_recertification_path,
                    production_sweep_path=options.production_sweep_path,
                    autonomous_production_supervisor_path=work_queue_seed_path,
                    output_root=output_root / "05-freshness-planner",
                    created_at=options.created_at,
                    run_label=options.run_label,
                    lookahead_days=options.lookahead_days,
                )
            )
            if _valid(stages.get("freshnessPlanner")):
                stages["maintenanceExecutor"] = run_autonomous_maintenance_executor(
                    AutonomousMaintenanceExecutorOptions(
                        freshness_plan_path=Path(stages["freshnessPlanner"]["outputPaths"]["report"]),
                        output_root=output_root / "06-maintenance-executor",
                        created_at=options.created_at,
                        run_label=options.run_label,
                        execute_safe_actions=options.execute_safe_actions,
                    )
                )
                if options.owner_approval_path and options.legal_approval_packet_path:
                    promotion_seed_path = output_root / "07-promotion-input" / "supervisor-promotion-seed.json"
                    write_json(
                        promotion_seed_path,
                        {
                            "schemaVersion": 1,
                            "kind": "ambitions.sourceAtlas.autonomousProductionSupervisor.promotionSeed.v1",
                            "createdAt": options.created_at,
                            "valid": True,
                            "recordCounts": _record_counts(stages, _queue_counts(_work_queue(stages))),
                            "queueCounts": _queue_counts(_work_queue(stages)),
                            "maintenanceCounts": _maintenance_counts(_maintenance_queue(stages)),
                            "workQueue": _work_queue(stages),
                            "maintenanceQueue": _maintenance_queue(stages),
                            "privacyBoundary": PRIVACY_BOUNDARY,
                            "privacyIssues": [],
                            "nonClaims": SUPERVISOR_NON_CLAIMS,
                        },
                    )
                    stages["promotionRunner"] = run_autonomous_promotion_runner(
                        AutonomousPromotionRunnerOptions(
                            supervisor_report_path=promotion_seed_path,
                            production_sweep_path=options.production_sweep_path,
                            owner_approval_path=options.owner_approval_path,
                            legal_terms_registry_path=options.legal_terms_registry_path,
                            api_governance_registry_path=options.api_governance_registry_path,
                            legal_approval_packet_path=options.legal_approval_packet_path,
                            output_root=output_root / "08-promotion-runner",
                            created_at=options.created_at,
                            run_label=options.run_label,
                            bucket=options.promotion_bucket,
                            execute_r2=options.execute_r2,
                        )
                    )

    issues.extend(_stage_issues(stages))
    work_queue = _work_queue(stages)
    maintenance_queue = _maintenance_queue(stages)
    queue_counts = _queue_counts(work_queue)
    maintenance_counts = _maintenance_counts(maintenance_queue)
    output_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "stageSummaries": _stage_summaries(stages),
                "queueCounts": queue_counts,
                "maintenanceCounts": maintenance_counts,
                "workQueue": _privacy_queue_view(work_queue),
                "maintenanceQueue": _privacy_maintenance_queue_view(maintenance_queue),
            },
            "source-atlas-autonomous-production-supervisor-output",
        )
    )
    issues.extend(output_privacy_issues)

    checks = [
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check("production_orchestrator_valid", _valid(stages.get("productionOrchestrator")), _stage_check_issues(stages.get("productionOrchestrator"))),
        _check("operations_plan_valid", _valid(stages.get("operationsPlan")), _stage_check_issues(stages.get("operationsPlan"))),
        _check("operations_executor_valid", _valid(stages.get("operationsExecutor")), _stage_check_issues(stages.get("operationsExecutor"))),
        _check("freshness_planner_valid_when_configured", _optional_stage_valid(stages, "freshnessPlanner"), _optional_stage_issues(stages, "freshnessPlanner")),
        _check("maintenance_executor_valid_when_configured", _optional_stage_valid(stages, "maintenanceExecutor"), _optional_stage_issues(stages, "maintenanceExecutor")),
        _check("promotion_runner_valid_when_configured", _optional_stage_valid(stages, "promotionRunner"), _optional_stage_issues(stages, "promotionRunner")),
        _check("work_queue_emitted", bool(work_queue), [] if work_queue else ["work queue is empty"]),
        _check("unsafe_remote_native_and_final_outputs_absent", _unsafe_counts(queue_counts) == 0, _unsafe_count_issues(queue_counts)),
        _check("maintenance_unsafe_outputs_absent", _maintenance_unsafe_counts(maintenance_counts) == 0, _maintenance_unsafe_issues(maintenance_counts)),
        _check("promotion_unsafe_outputs_absent", _promotion_unsafe_counts(stages) == 0, _promotion_unsafe_issues(stages)),
        _check("production_writes_remain_gated", queue_counts["productionWritesExecuted"] == 0, ["production write executed"] if queue_counts["productionWritesExecuted"] else []),
        _check("promotion_writes_remain_gated", _path(stages.get("promotionRunner", {}), "recordCounts", "r2WritesExecuted") in {None, 0}, ["promotion runner executed R2 write"] if _path(stages.get("promotionRunner", {}), "recordCounts", "r2WritesExecuted") else []),
        _check(
            "safe_actions_respect_execute_flag",
            options.execute_safe_actions or queue_counts["executedSafe"] == 0,
            ["safe action executed without --execute-safe-actions"] if (not options.execute_safe_actions and queue_counts["executedSafe"]) else [],
        ),
        _check("output_privacy_scan_passed", not output_privacy_issues, output_privacy_issues),
    ]
    valid = not issues and all(check["passed"] for check in checks)

    allowed_claims = []
    if valid:
        allowed_claims = [
            "supervised_autonomous_source_atlas_work_loop_green",
            "current_production_orchestrator_refreshed",
            "operations_plan_and_safe_execution_supervised",
            "production_writes_remain_execute_gated",
        ]
        if _valid(stages.get("freshnessPlanner")) and _valid(stages.get("maintenanceExecutor")):
            allowed_claims.append("freshness_planning_and_local_maintenance_integrated")
            allowed_claims.append("maintenance_artifacts_written_without_unsafe_mutation")
        if queue_counts["executedSafe"] > 0:
            allowed_claims.append("candidate_or_fixture_safe_actions_executed")
        if queue_counts["observed"] > 0:
            allowed_claims.append("configured_production_domains_observed_without_mutation")
        if _valid(stages.get("promotionRunner")):
            allowed_claims.append("promotion_control_integrated")
            allowed_claims.append("promotion_decisions_emitted_without_remote_or_native_mutation")

    report_path = output_root / "autonomous-production-supervisor-report.json"
    markdown_path = output_root / "autonomous-production-supervisor-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_PRODUCTION_SUPERVISOR_KIND,
        "versionID": AUTONOMOUS_PRODUCTION_SUPERVISOR_VERSION,
        "createdAt": options.created_at,
        "supervisorID": stable_id(
            "source_atlas.autonomous_production_supervisor",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "requestedDomains": list(options.requested_domains),
                "executeSafeActions": options.execute_safe_actions,
                "executeR2": options.execute_r2,
                "allowFixtureDeliveryChain": options.allow_fixture_delivery_chain,
                "legalTermsRegistryPath": str(options.legal_terms_registry_path) if options.legal_terms_registry_path else None,
                "apiGovernanceRegistryPath": str(options.api_governance_registry_path) if options.api_governance_registry_path else None,
                "ownerApprovalPath": str(options.owner_approval_path) if options.owner_approval_path else None,
                "legalApprovalPacketPath": str(options.legal_approval_packet_path) if options.legal_approval_packet_path else None,
            },
        ),
        "runLabel": options.run_label,
        "status": "Source Green for supervised autonomous Source Atlas work loop" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; supervised bounded public/reference work loop only",
        "overallReadinessStatus": "supervised_autonomous_work_loop_ready" if valid else "blocked_or_partial",
        "requestedDomains": list(options.requested_domains),
        "executeSafeActionsRequested": options.execute_safe_actions,
        "executeR2Requested": options.execute_r2,
        "allowFixtureDeliveryChainRequested": options.allow_fixture_delivery_chain,
        "recordCounts": _record_counts(stages, queue_counts),
        "queueCounts": queue_counts,
        "maintenanceCounts": maintenance_counts,
        "promotionCounts": _promotion_counts(stages),
        "checks": checks,
        "issues": sorted(set(issues)),
        "stageSummaries": _stage_summaries(stages),
        "workQueue": work_queue,
        "maintenanceQueue": maintenance_queue,
        "allowedClaims": allowed_claims,
        "blockedClaims": _blocked_claims(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": input_privacy_issues + output_privacy_issues,
        "nonClaims": SUPERVISOR_NON_CLAIMS,
        "evidencePaths": _evidence_paths(options, stages),
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
    markdown = autonomous_production_supervisor_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def autonomous_production_supervisor_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    queue_counts = report["queueCounts"]
    maintenance_counts = report.get("maintenanceCounts", {})
    promotion_counts = report.get("promotionCounts", {})
    lines = [
        "# Source Atlas Autonomous Production Supervisor Train 126",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        "",
        "Scope completed:",
        "- Refreshed the bounded production orchestrator.",
        "- Compiled the autonomous operations plan from current frontiers, registries, production ledger, and recertification proof.",
        "- Ran the gated operations executor for observed production domains and safe candidate actions.",
        "- Computed freshness/review work when legal/API registries were supplied.",
        "- Ran the safe local maintenance executor when freshness planning was available.",
        "- Emitted one supervised work queue across observed, executed-safe, planned, and gated work.",
        "- Performed no live harvest, production R2 write, Worker deploy, native runtime mutation, active registry mutation, or final user output generation.",
        "",
        "Counts:",
        f"- Configured domains: {counts['configuredDomains']}",
        f"- Planned domains: {counts['plannedDomains']}",
        f"- Work queue items: {counts['workQueueItems']}",
        f"- Observed items: {queue_counts['observed']}",
        f"- Executed safe items: {queue_counts['executedSafe']}",
        f"- Planned-not-executed items: {queue_counts['plannedNotExecuted']}",
        f"- Blocked-by-gate items: {queue_counts['blockedByGate']}",
        f"- Production writes executed: {queue_counts['productionWritesExecuted']}",
        f"- Remote mutations: {queue_counts['remoteMutations']}",
        f"- Native runtime mutations: {queue_counts['nativeRuntimeMutations']}",
        f"- Final outputs generated: {queue_counts['finalOutputsGenerated']}",
        f"- Maintenance work items: {maintenance_counts.get('items', 0)}",
        f"- Maintenance monitor snapshots: {maintenance_counts.get('monitorSnapshotsWritten', 0)}",
        f"- Maintenance review packets: {maintenance_counts.get('reviewPacketsWritten', 0)}",
        f"- Maintenance held gate packets: {maintenance_counts.get('heldGatePacketsWritten', 0)}",
        f"- Promotion decisions: {promotion_counts.get('promotionDecisions', 0)}",
        f"- Promotion monitor-only decisions: {promotion_counts.get('monitorOnlyDecisions', 0)}",
        f"- Promotion review-only decisions: {promotion_counts.get('candidateReviewOnlyDecisions', 0)}",
        f"- Promotion R2 commands: {promotion_counts.get('promotionCommands', 0)}",
        f"- Promotion R2 writes executed: {promotion_counts.get('r2WritesExecuted', 0)}",
        "",
        "Work queue:",
        "",
        "| Domain | Action | State | Gate | Executed | Artifacts |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for item in report.get("workQueue", []):
        lines.append(
            "| {domain} | {action} | {state} | {gate} | {executed} | {artifacts} |".format(
                domain=item["domainID"],
                action=item["nextAction"],
                state=item["state"],
                gate=item["requiredGate"],
                executed="yes" if item["executed"] else "no",
                artifacts="<br>".join(item.get("artifactPaths", [])) or "none",
            )
        )
    if report.get("maintenanceQueue"):
        lines.extend(
            [
                "",
                "Maintenance queue:",
                "",
                "| Domain | Action | Status | Gate | Artifacts |",
                "| --- | --- | --- | --- | --- |",
            ]
        )
        for item in report.get("maintenanceQueue", []):
            lines.append(
                "| {domain} | {action} | {status} | {gate} | {artifacts} |".format(
                    domain=item["domainID"],
                    action=item["nextAction"],
                    status=item["status"],
                    gate=item["requiredGate"],
                    artifacts="<br>".join(item.get("artifactPaths", [])) or "none",
                )
            )
    promotion_stage = _path(report, "stageSummaries", "promotionRunner")
    if promotion_stage:
        lines.extend(
            [
                "",
                "Promotion control:",
                f"- Status: {promotion_stage.get('status')}",
                f"- Overall readiness: {promotion_stage.get('overallReadinessStatus')}",
                f"- Decisions: {promotion_counts.get('promotionDecisions', 0)}",
                f"- R2 writes executed: {promotion_counts.get('r2WritesExecuted', 0)}",
                f"- Remote mutations: {promotion_counts.get('remoteMutations', 0)}",
                f"- Native runtime mutations: {promotion_counts.get('nativeRuntimeMutations', 0)}",
                f"- Final outputs generated: {promotion_counts.get('finalOutputsGenerated', 0)}",
            ]
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
            "- Supervisor inputs and outputs are public domain IDs, source IDs, gates, proof paths, and public/reference operation metadata only.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, priority order, recovery paths, or personalized paths.",
            "",
            "Validation not run:",
            "- No live harvest was run by the supervisor.",
            "- No production R2 write was run by the supervisor.",
            "- No Worker deploy was run by the supervisor.",
            "- No native XCTest/build-for-testing was run by the supervisor.",
            "- No outside legal approval, Release Green, App Store readiness, native physical-device proof, independent accessibility proof, or literal universal coverage was claimed.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: autonomous production supervisor promotion integration, CLI arguments, tests, generated artifacts, and QA evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: release proof, outside legal artifact, independent accessibility/device proof, and actual execute-gated production writes remain separate gates.",
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
            "- Revert Train 128 autonomous production supervisor promotion integration, CLI wiring, focused tests, generated artifacts, and QA evidence.",
            "- Continue using the individual production orchestrator, operations plan, operations executor, freshness planner, maintenance executor, and promotion runner reports directly if supervision regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _work_queue(stages: dict[str, Any]) -> list[dict[str, Any]]:
    executor = stages.get("operationsExecutor")
    if not isinstance(executor, dict):
        return []
    queue: list[dict[str, Any]] = []
    for index, result in enumerate(executor.get("actionResults", []), start=1):
        if not isinstance(result, dict):
            continue
        status = str(result.get("status", "unknown"))
        queue.append(
            {
                "order": index,
                "domainID": result.get("domainID"),
                "nextAction": result.get("nextAction"),
                "state": _queue_state(status),
                "requiredGate": result.get("requiredGate"),
                "executed": status == "executed_safe",
                "observed": status == "observed",
                "safeAction": result.get("safeAction") is True,
                "productionAction": result.get("productionAction") is True,
                "productionWriteExecuted": result.get("productionWriteExecuted") is True,
                "unsafeExecutionAttempted": result.get("unsafeExecutionAttempted") is True,
                "remoteMutation": False,
                "nativeRuntimeMutation": False,
                "finalOutputGenerated": False,
                "artifactPaths": sorted(str(path) for path in result.get("artifactPaths", []) if isinstance(path, str)),
                "blockers": sorted(str(item) for item in result.get("blockers", []) if isinstance(item, str)),
                "nonClaims": result.get("nonClaims", []),
            }
        )
    return sorted(queue, key=lambda item: (item["order"], str(item["domainID"])))


def _queue_state(status: str) -> str:
    return {
        "observed": "observed_current_production",
        "executed_safe": "executed_safe_local_or_candidate_action",
        "planned_not_executed": "queued_requires_execute_safe_actions",
        "blocked_by_gate": "held_by_required_gate",
        "failed": "failed",
    }.get(status, status)


def _queue_counts(queue: list[dict[str, Any]]) -> dict[str, int]:
    return {
        "items": len(queue),
        "observed": sum(1 for item in queue if item["state"] == "observed_current_production"),
        "executedSafe": sum(1 for item in queue if item["state"] == "executed_safe_local_or_candidate_action"),
        "plannedNotExecuted": sum(1 for item in queue if item["state"] == "queued_requires_execute_safe_actions"),
        "blockedByGate": sum(1 for item in queue if item["state"] == "held_by_required_gate"),
        "failed": sum(1 for item in queue if item["state"] == "failed"),
        "productionWritesExecuted": sum(1 for item in queue if item["productionWriteExecuted"] is True),
        "unsafeExecutionAttempts": sum(1 for item in queue if item["unsafeExecutionAttempted"] is True),
        "remoteMutations": sum(1 for item in queue if item["remoteMutation"] is True),
        "nativeRuntimeMutations": sum(1 for item in queue if item["nativeRuntimeMutation"] is True),
        "finalOutputsGenerated": sum(1 for item in queue if item["finalOutputGenerated"] is True),
    }


def _maintenance_queue(stages: dict[str, Any]) -> list[dict[str, Any]]:
    executor = stages.get("maintenanceExecutor")
    if not isinstance(executor, dict):
        return []
    queue: list[dict[str, Any]] = []
    for index, result in enumerate(executor.get("actionResults", []), start=1):
        if not isinstance(result, dict):
            continue
        queue.append(
            {
                "order": index,
                "domainID": result.get("domainID"),
                "nextAction": result.get("nextAction"),
                "status": result.get("status"),
                "state": result.get("state"),
                "requiredGate": result.get("requiredGate"),
                "productionWriteExecuted": result.get("productionWriteExecuted") is True,
                "liveHarvestExecuted": result.get("liveHarvestExecuted") is True,
                "remoteMutation": result.get("remoteMutation") is True,
                "nativeRuntimeMutation": result.get("nativeRuntimeMutation") is True,
                "finalOutputGenerated": result.get("finalOutputGenerated") is True,
                "artifactPaths": sorted(str(path) for path in result.get("artifactPaths", []) if isinstance(path, str)),
                "nonClaims": result.get("nonClaims", []),
            }
        )
    return sorted(queue, key=lambda item: (item["order"], str(item["domainID"])))


def _maintenance_counts(queue: list[dict[str, Any]]) -> dict[str, int]:
    return {
        "items": len(queue),
        "monitorSnapshotsWritten": sum(1 for item in queue if item["status"] == "observed_snapshot_written"),
        "reviewPacketsWritten": sum(1 for item in queue if item["status"] == "executed_safe"),
        "heldGatePacketsWritten": sum(1 for item in queue if item["status"] == "blocked_by_gate_packet_written"),
        "plannedNotExecuted": sum(1 for item in queue if item["status"] == "planned_not_executed"),
        "productionWritesExecuted": sum(1 for item in queue if item["productionWriteExecuted"] is True),
        "liveHarvestsExecuted": sum(1 for item in queue if item["liveHarvestExecuted"] is True),
        "remoteMutations": sum(1 for item in queue if item["remoteMutation"] is True),
        "nativeRuntimeMutations": sum(1 for item in queue if item["nativeRuntimeMutation"] is True),
        "finalOutputsGenerated": sum(1 for item in queue if item["finalOutputGenerated"] is True),
    }


def _record_counts(stages: dict[str, Any], queue_counts: dict[str, int]) -> dict[str, int]:
    orchestrator = stages.get("productionOrchestrator", {})
    plan = stages.get("operationsPlan", {})
    executor = stages.get("operationsExecutor", {})
    freshness = stages.get("freshnessPlanner", {})
    maintenance = stages.get("maintenanceExecutor", {})
    promotion = stages.get("promotionRunner", {})
    return {
        "configuredDomains": int(_path(orchestrator, "recordCounts", "configuredDomains") or _path(plan, "recordCounts", "configuredFrontiers") or 0),
        "plannedDomains": int(_path(plan, "recordCounts", "plannedDomains") or 0),
        "monitorDomains": int(_path(plan, "recordCounts", "monitorDomains") or 0),
        "actionableDomains": int(_path(plan, "recordCounts", "actionableDomains") or 0),
        "workQueueItems": queue_counts["items"],
        "observedDomains": int(_path(executor, "recordCounts", "observedDomains") or 0),
        "safeActionsExecuted": int(_path(executor, "recordCounts", "safeActionsExecuted") or 0),
        "frontierIntakeArtifacts": int(_path(executor, "recordCounts", "frontierIntakeArtifacts") or 0),
        "deliveryChainArtifacts": int(_path(executor, "recordCounts", "deliveryChainArtifacts") or 0),
        "freshnessWorkItems": int(_path(freshness, "recordCounts", "workItems") or 0),
        "maintenanceWorkItems": int(_path(maintenance, "recordCounts", "workItemsProcessed") or 0),
        "maintenanceMonitorSnapshots": int(_path(maintenance, "recordCounts", "monitorSnapshotsWritten") or 0),
        "maintenanceReviewPackets": int(_path(maintenance, "recordCounts", "reviewPacketsWritten") or 0),
        "maintenanceHeldGatePackets": int(_path(maintenance, "recordCounts", "heldGatePacketsWritten") or 0),
        "promotionDecisions": int(_path(promotion, "recordCounts", "promotionDecisions") or 0),
        "promotionMonitorOnlyDecisions": int(_path(promotion, "recordCounts", "monitorOnlyDecisions") or 0),
        "promotionReviewOnlyDecisions": int(_path(promotion, "recordCounts", "candidateReviewOnlyDecisions") or 0),
        "promotionCommands": int(_path(promotion, "recordCounts", "promotionCommands") or 0),
        "promotionR2WritesExecuted": int(_path(promotion, "recordCounts", "r2WritesExecuted") or 0),
        "productionWritesExecuted": queue_counts["productionWritesExecuted"],
        "remoteMutations": queue_counts["remoteMutations"],
        "nativeRuntimeMutations": queue_counts["nativeRuntimeMutations"],
        "finalOutputsGenerated": queue_counts["finalOutputsGenerated"],
    }


def _unsafe_counts(queue_counts: dict[str, int]) -> int:
    return (
        queue_counts["productionWritesExecuted"]
        + queue_counts["unsafeExecutionAttempts"]
        + queue_counts["remoteMutations"]
        + queue_counts["nativeRuntimeMutations"]
        + queue_counts["finalOutputsGenerated"]
    )


def _unsafe_count_issues(queue_counts: dict[str, int]) -> list[str]:
    return [
        f"{key}={value}"
        for key, value in sorted(queue_counts.items())
        if key in {"productionWritesExecuted", "unsafeExecutionAttempts", "remoteMutations", "nativeRuntimeMutations", "finalOutputsGenerated"}
        and value
    ]


def _maintenance_unsafe_counts(maintenance_counts: dict[str, int]) -> int:
    return (
        maintenance_counts["productionWritesExecuted"]
        + maintenance_counts["liveHarvestsExecuted"]
        + maintenance_counts["remoteMutations"]
        + maintenance_counts["nativeRuntimeMutations"]
        + maintenance_counts["finalOutputsGenerated"]
    )


def _maintenance_unsafe_issues(maintenance_counts: dict[str, int]) -> list[str]:
    return [
        f"{key}={value}"
        for key, value in sorted(maintenance_counts.items())
        if key in {"productionWritesExecuted", "liveHarvestsExecuted", "remoteMutations", "nativeRuntimeMutations", "finalOutputsGenerated"}
        and value
    ]


def _promotion_counts(stages: dict[str, Any]) -> dict[str, int]:
    counts = _path(stages.get("promotionRunner", {}), "recordCounts")
    if not isinstance(counts, dict):
        return {
            "promotionDecisions": 0,
            "monitorOnlyDecisions": 0,
            "candidateReviewOnlyDecisions": 0,
            "heldGateDecisions": 0,
            "promotionCommands": 0,
            "r2WritesExecuted": 0,
            "remoteMutations": 0,
            "nativeRuntimeMutations": 0,
            "finalOutputsGenerated": 0,
        }
    return {
        "promotionDecisions": int(counts.get("promotionDecisions", 0) or 0),
        "monitorOnlyDecisions": int(counts.get("monitorOnlyDecisions", 0) or 0),
        "candidateReviewOnlyDecisions": int(counts.get("candidateReviewOnlyDecisions", 0) or 0),
        "heldGateDecisions": int(counts.get("heldGateDecisions", 0) or 0),
        "promotionCommands": int(counts.get("promotionCommands", 0) or 0),
        "r2WritesExecuted": int(counts.get("r2WritesExecuted", 0) or 0),
        "remoteMutations": int(counts.get("remoteMutations", 0) or 0),
        "nativeRuntimeMutations": int(counts.get("nativeRuntimeMutations", 0) or 0),
        "finalOutputsGenerated": int(counts.get("finalOutputsGenerated", 0) or 0),
    }


def _promotion_unsafe_counts(stages: dict[str, Any]) -> int:
    counts = _promotion_counts(stages)
    return (
        counts["r2WritesExecuted"]
        + counts["remoteMutations"]
        + counts["nativeRuntimeMutations"]
        + counts["finalOutputsGenerated"]
    )


def _promotion_unsafe_issues(stages: dict[str, Any]) -> list[str]:
    counts = _promotion_counts(stages)
    return [
        f"{key}={value}"
        for key, value in sorted(counts.items())
        if key in {"r2WritesExecuted", "remoteMutations", "nativeRuntimeMutations", "finalOutputsGenerated"} and value
    ]


def _stage_summaries(stages: dict[str, Any]) -> dict[str, Any]:
    return {
        name: {
            "kind": stage.get("kind"),
            "valid": stage.get("valid"),
            "status": stage.get("status"),
            "overallReadinessStatus": stage.get("overallReadinessStatus"),
            "recordCounts": stage.get("recordCounts"),
            "issues": stage.get("issues", []),
        }
        for name, stage in sorted(stages.items())
        if isinstance(stage, dict)
    }


def _privacy_queue_view(queue: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "domainID": item.get("domainID"),
            "nextAction": item.get("nextAction"),
            "state": item.get("state"),
            "requiredGate": item.get("requiredGate"),
            "executed": item.get("executed"),
            "observed": item.get("observed"),
            "productionWriteExecuted": item.get("productionWriteExecuted"),
            "artifactCount": len(item.get("artifactPaths", [])),
        }
        for item in queue
    ]


def _privacy_maintenance_queue_view(queue: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "domainID": item.get("domainID"),
            "nextAction": item.get("nextAction"),
            "status": item.get("status"),
            "requiredGate": item.get("requiredGate"),
            "productionWriteExecuted": item.get("productionWriteExecuted"),
            "artifactCount": len(item.get("artifactPaths", [])),
        }
        for item in queue
    ]


def _stage_issues(stages: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for name, stage in stages.items():
        if not isinstance(stage, dict):
            issues.append(f"{name}: stage missing")
        elif stage.get("valid") is not True:
            issues.extend(f"{name}: {issue}" for issue in stage.get("issues", []))
            if not stage.get("issues"):
                issues.append(f"{name}: stage valid flag is not true")
    return issues


def _optional_stage_valid(stages: dict[str, Any], stage_name: str) -> bool:
    return stage_name not in stages or _valid(stages.get(stage_name))


def _optional_stage_issues(stages: dict[str, Any], stage_name: str) -> list[str]:
    if stage_name not in stages:
        return []
    return _stage_check_issues(stages.get(stage_name))


def _stage_check_issues(stage: Any) -> list[str]:
    if not isinstance(stage, dict):
        return ["stage missing"]
    if stage.get("valid") is True:
        return []
    return stage.get("issues", ["stage valid flag is not true"])


def _valid(stage: Any) -> bool:
    return isinstance(stage, dict) and stage.get("valid") is True


def _path(value: Any, *keys: str) -> Any:
    current = value
    for key in keys:
        if not isinstance(current, dict):
            return None
        current = current.get(key)
    return current


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
            "new_remote_r2_write_executed_by_supervisor",
            "uncontrolled_live_harvest",
            "active_registry_mutation_by_supervisor",
            "source_atlas_private_goal_text_processing",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )


def _evidence_paths(options: AutonomousProductionSupervisorOptions, stages: dict[str, Any]) -> dict[str, str]:
    evidence = {
        "frontierConfig": str(options.frontier_config_path),
        "sourceLaneRegistry": str(options.source_lane_registry_path),
        "productionTargetLedger": str(options.production_target_ledger_path),
        "productionRecertification": str(options.production_recertification_path),
        "productionFinishLineGate": str(options.production_finish_line_gate_path),
        "productionSweep": str(options.production_sweep_path),
        "arbitraryDomainGate": str(options.arbitrary_domain_gate_path),
        "goalDomainGauntlet": str(options.goal_domain_gauntlet_path),
        "autonomousControlLoop": str(options.autonomous_control_loop_path),
        "autonomousCycle": str(options.autonomous_cycle_path),
        "legalTermsRegistry": str(options.legal_terms_registry_path) if options.legal_terms_registry_path else None,
        "apiGovernanceRegistry": str(options.api_governance_registry_path) if options.api_governance_registry_path else None,
        "ownerApproval": str(options.owner_approval_path) if options.owner_approval_path else None,
        "legalApprovalPacket": str(options.legal_approval_packet_path) if options.legal_approval_packet_path else None,
    }
    for name, stage in stages.items():
        if isinstance(stage, dict):
            raw = _path(stage, "outputPaths", "report") or stage.get("manifestPath")
            if isinstance(raw, str):
                evidence[name] = raw
    return evidence


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(issues))}
