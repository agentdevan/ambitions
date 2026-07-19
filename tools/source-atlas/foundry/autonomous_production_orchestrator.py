"""Top-level autonomous production orchestrator for Source Atlas.

This orchestrator is intentionally bigger than a proof wrapper: it reconciles
the current production target, finish-line, sweep, arbitrary-domain, goal
gauntlet, control-loop, and cycle evidence into one operating envelope. It also
runs the local cycle executor so the report proves that recurring autonomous
actions are executable without mutating R2 or native runtime state.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .autonomous_cycle_executor import (
    AutonomousCycleExecutorOptions,
    run_autonomous_cycle_executor,
)
from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


AUTONOMOUS_PRODUCTION_ORCHESTRATOR_KIND = "ambitions.sourceAtlas.autonomousProductionOrchestrator.v1"
AUTONOMOUS_PRODUCTION_ORCHESTRATOR_VERSION = "source-atlas-autonomous-production-orchestrator-train-122"

REQUIRED_FINISH_LINE_CLAIMS = {
    "bounded_configured_production_target",
    "internal_terms_review",
    "production_r2_write_readback",
    "bounded_live_transport",
    "bounded_configured_runtime_green",
    "gateway_native_runtime_recertification",
}
REQUIRED_SWEEP_CLAIMS = {
    "current_configured_frontier_production_sweep",
    "current_remote_r2_upload_readback_reconciled",
    "governed_arbitrary_public_reference_domain_routing_reconciled",
    "representative_goal_domain_gauntlet_reconciled",
}
REQUIRED_CONTROL_LOOP_CLAIMS = {
    "autonomous_control_loop_ready_for_configured_public_reference_domains",
    "r2_write_preflight_ready_execute_still_required",
    "unknown_domains_candidate_only_controlled",
    "release_legal_universal_claim_holds_enforced",
}
REQUIRED_CYCLE_CLAIMS = {
    "autonomous_operations_cycle_ready_for_recurring_public_reference_runs",
    "configured_domain_monitor_actions_emitted",
    "execute_gated_r2_actions_held",
    "unknown_domain_candidate_intake_cycle_controlled",
}
REQUIRED_EXECUTOR_CLAIMS = {
    "autonomous_cycle_local_execution_green",
    "configured_domain_monitor_checks_executed",
    "execute_gated_r2_actions_refused",
    "release_legal_universal_holds_executed",
}
REQUIRED_BLOCKED_CLAIMS = {
    "full_source_atlas_green",
    "outside_legal_approval",
    "release_green",
    "literal_universal_coverage",
    "final_user_plans_schedules_steps_from_source_atlas_or_r2",
}

ORCHESTRATOR_NON_CLAIMS = [
    "bounded autonomous production operating envelope only",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not native physical-device proof",
    "not independent accessibility proof",
    "not literal universal coverage",
    "not permission for automatic R2 writes",
    "not a new production R2 write",
    "not a live harvest",
    "not a Worker deploy",
    "not native runtime mutation",
    "not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class AutonomousProductionOrchestratorOptions:
    production_target_ledger_path: Path
    production_finish_line_gate_path: Path
    production_sweep_path: Path
    arbitrary_domain_gate_path: Path
    goal_domain_gauntlet_path: Path
    autonomous_control_loop_path: Path
    autonomous_cycle_path: Path
    output_root: Path
    created_at: str = "2026-06-29T02:30:00Z"
    run_label: str = "current"


def run_autonomous_production_orchestrator(options: AutonomousProductionOrchestratorOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    artifacts = {
        "productionTargetLedger": _read_required_json(options.production_target_ledger_path, "production target ledger", issues),
        "productionFinishLineGate": _read_required_json(options.production_finish_line_gate_path, "production finish-line gate", issues),
        "productionSweep": _read_required_json(options.production_sweep_path, "production sweep", issues),
        "arbitraryDomainGate": _read_required_json(options.arbitrary_domain_gate_path, "arbitrary-domain gate", issues),
        "goalDomainGauntlet": _read_required_json(options.goal_domain_gauntlet_path, "goal-domain gauntlet", issues),
        "autonomousControlLoop": _read_required_json(options.autonomous_control_loop_path, "autonomous control loop", issues),
        "autonomousCycle": _read_required_json(options.autonomous_cycle_path, "autonomous cycle", issues),
    }

    cycle_executor = run_autonomous_cycle_executor(
        AutonomousCycleExecutorOptions(
            cycle_path=options.autonomous_cycle_path,
            output_root=output_root / "cycle-executor",
            created_at=options.created_at,
            run_label=options.run_label,
        )
    )
    artifacts["autonomousCycleExecutor"] = cycle_executor

    matrix = _readiness_matrix(artifacts)
    remaining_work = _remaining_work(matrix)
    checks = _checks(artifacts, matrix, remaining_work)
    issues.extend(issue for check in checks for issue in check["issues"] if not check["passed"])

    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "runLabel": options.run_label,
                "readinessMatrix": matrix,
                "remainingWork": remaining_work,
                "artifactFingerprints": _artifact_fingerprints(artifacts),
            },
            "source-atlas-autonomous-production-orchestrator",
        )
    )
    issues.extend(privacy_issues)
    checks.append(_check("privacy_boundary", not privacy_issues, privacy_issues))

    valid = not issues and all(check["passed"] for check in checks)
    configured_domain_count = _configured_domain_count(artifacts)
    allowed_claims = []
    if valid:
        allowed_claims = [
            "bounded_autonomous_source_atlas_production_orchestrator_green",
            "configured_frontier_public_reference_production_system_operational",
            "current_remote_r2_upload_readback_reconciled_for_configured_domains",
            "autonomous_monitor_cycle_executable_without_remote_mutation",
            "governed_arbitrary_public_reference_domain_handling_operational",
        ]

    report_path = output_root / "autonomous-production-orchestrator-report.json"
    markdown_path = output_root / "autonomous-production-orchestrator-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_PRODUCTION_ORCHESTRATOR_KIND,
        "versionID": AUTONOMOUS_PRODUCTION_ORCHESTRATOR_VERSION,
        "createdAt": options.created_at,
        "runID": stable_id(
            "source_atlas.autonomous_production_orchestrator",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "artifacts": _artifact_fingerprints(artifacts),
            },
        ),
        "runLabel": options.run_label,
        "status": "Source Green for bounded autonomous Source Atlas production orchestrator" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": (
            "Yellow overall Source Atlas; bounded configured public/reference production "
            "orchestrator only"
        ),
        "overallReadinessStatus": "bounded_autonomous_production_operational" if valid else "blocked_or_partial",
        "configuredDomainCount": configured_domain_count,
        "readinessMatrix": matrix,
        "remainingCompletionWork": remaining_work,
        "recordCounts": {
            "configuredDomains": configured_domain_count,
            "productionDomainsReady": _path(artifacts, "productionTargetLedger", "recordCounts", "boundedProductionTargetReady") or 0,
            "remoteR2UploadsReconciled": _path(artifacts, "productionSweep", "recordCounts", "remoteR2UploadsReconciled") or 0,
            "goalDomainGauntletCases": _path(artifacts, "goalDomainGauntlet", "recordCounts", "configuredGauntletCases") or 0,
            "unknownProbeCasesCandidateOnly": _path(artifacts, "goalDomainGauntlet", "recordCounts", "unknownCasesCandidateOnly") or 0,
            "autonomousCycleActions": _path(artifacts, "autonomousCycle", "recordCounts", "operationActions") or 0,
            "localCycleActionsExecuted": _path(cycle_executor, "recordCounts", "actionResults") or 0,
            "localMonitorChecksExecuted": _path(cycle_executor, "recordCounts", "localMonitorChecksExecuted") or 0,
            "remoteMutations": _path(cycle_executor, "recordCounts", "remoteMutations") or 0,
            "nativeRuntimeMutations": _path(cycle_executor, "recordCounts", "nativeRuntimeMutations") or 0,
            "finalOutputsGenerated": _final_outputs_generated(artifacts),
            "privacyIssues": len(privacy_issues),
        },
        "checks": checks,
        "issues": sorted(set(issues)),
        "allowedClaims": allowed_claims,
        "blockedClaims": _blocked_claims(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "nonClaims": ORCHESTRATOR_NON_CLAIMS,
        "evidencePaths": _evidence_paths(options, cycle_executor),
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "cycleExecutor": str(cycle_executor.get("outputPaths", {}).get("report", "")),
        },
    }
    report["outputHashes"] = {"reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"})}
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = autonomous_production_orchestrator_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def autonomous_production_orchestrator_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    matrix = report["readinessMatrix"]
    lines = [
        "# Source Atlas Autonomous Production Orchestrator Train 122",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        "",
        "Scope completed:",
        "- Reconciled production target, production finish-line, production sweep, arbitrary-domain gate, goal-domain gauntlet, control loop, cycle runner, and local cycle executor evidence.",
        "- Produced one operating envelope for configured public/reference domains.",
        "- Executed recurring cycle monitor actions locally while refusing remote/native mutation and final-output generation.",
        "- Separated bounded production operation from outside legal, Release Green, device, accessibility, and literal universal-coverage claims.",
        "",
        "Counts:",
        f"- Configured domains: {counts['configuredDomains']}",
        f"- Production domains ready: {counts['productionDomainsReady']}",
        f"- Remote R2 uploads/readbacks reconciled: {counts['remoteR2UploadsReconciled']}",
        f"- Goal-domain gauntlet cases: {counts['goalDomainGauntletCases']}",
        f"- Autonomous cycle actions: {counts['autonomousCycleActions']}",
        f"- Local cycle actions executed: {counts['localCycleActionsExecuted']}",
        f"- Local monitor checks executed: {counts['localMonitorChecksExecuted']}",
        f"- Remote mutations: {counts['remoteMutations']}",
        f"- Native runtime mutations: {counts['nativeRuntimeMutations']}",
        f"- Final outputs generated: {counts['finalOutputsGenerated']}",
        f"- Privacy issues: {counts['privacyIssues']}",
        "",
        "Readiness matrix:",
        "",
        "| Area | State | Ready | Evidence | Issues |",
        "| --- | --- | --- | --- | --- |",
    ]
    for item in matrix:
        lines.append(
            "| {area} | {state} | {ready} | {evidence} | {issues} |".format(
                area=item["area"],
                state=item["state"],
                ready="yes" if item["ready"] else "no",
                evidence=item["evidence"],
                issues="<br>".join(item["issues"]) or "none",
            )
        )
    lines.extend(["", "Allowed claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("allowedClaims", [])) if report.get("allowedClaims") else lines.append("- None")
    lines.extend(["", "Blocked claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("blockedClaims", []))
    lines.extend(["", "Remaining completion work:"])
    for item in report.get("remainingCompletionWork", []):
        lines.append(f"- {item['area']}: {item['state']} ({item['reason']})")
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Evidence is source/frontier/pack/R2/gateway/native/control metadata only.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, priority order, recovery paths, or personalized paths.",
            "",
            "Validation not run:",
            "- No new live harvest was run by this orchestrator.",
            "- No new production R2 write was run by this orchestrator.",
            "- No Worker deploy was run by this orchestrator.",
            "- No native XCTest/build-for-testing was run by this orchestrator.",
            "- No outside legal approval, Release Green, App Store readiness, native physical-device proof, independent accessibility proof, or literal universal coverage was claimed.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: autonomous production orchestrator module, CLI command, tests, generated artifacts, and QA evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: release proof, outside legal artifact, independent accessibility/device proof, and future execute-gated production writes remain separate gates.",
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
            "- Revert Train 122 autonomous production orchestrator module, CLI wiring, focused tests, generated artifacts, and QA evidence.",
            "- Continue using the individual production sweep, control loop, cycle runner, and cycle executor reports directly if orchestration regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _readiness_matrix(artifacts: dict[str, Any]) -> list[dict[str, Any]]:
    ledger = artifacts["productionTargetLedger"]
    finish_line = artifacts["productionFinishLineGate"]
    sweep = artifacts["productionSweep"]
    arbitrary = artifacts["arbitraryDomainGate"]
    gauntlet = artifacts["goalDomainGauntlet"]
    control_loop = artifacts["autonomousControlLoop"]
    cycle = artifacts["autonomousCycle"]
    cycle_executor = artifacts["autonomousCycleExecutor"]
    return [
        _area(
            "production_target",
            "configured_frontiers_ready",
            _artifact_valid(ledger)
            and _path(ledger, "overallReadinessStatus") == "configured_frontiers_bounded_production_target_ready"
            and _path(ledger, "recordCounts", "configuredDomainsNotReady") == 0
            and _path(ledger, "recordCounts", "orphanProductionDomains") == 0,
            "production target ledger",
            _artifact_issues("production target ledger", ledger),
        ),
        _area(
            "internal_legal_terms",
            "source_specific_internal_terms_review_ready",
            _artifact_valid(finish_line) and REQUIRED_FINISH_LINE_CLAIMS.issubset(set(finish_line.get("allowedClaims", []))),
            "production finish-line gate",
            _claim_issues("production finish-line gate", finish_line, REQUIRED_FINISH_LINE_CLAIMS),
        ),
        _area(
            "live_transport_and_r2",
            "current_remote_r2_upload_readback_reconciled",
            _artifact_valid(sweep)
            and REQUIRED_SWEEP_CLAIMS.issubset(set(sweep.get("allowedClaims", [])))
            and _path(sweep, "recordCounts", "domainsBlocked") == 0
            and _path(sweep, "recordCounts", "remoteR2UploadsReconciled")
            == _path(sweep, "recordCounts", "configuredDomains"),
            "production sweep",
            _claim_issues("production sweep", sweep, REQUIRED_SWEEP_CLAIMS),
        ),
        _area(
            "ambitions_runtime_boundary",
            "bounded_configured_runtime_green_not_release_green",
            _artifact_valid(finish_line)
            and "bounded_configured_runtime_green" in finish_line.get("allowedClaims", [])
            and "release_green" in finish_line.get("blockedClaims", []),
            "production finish-line gate",
            _blocked_claim_required_issues("production finish-line gate", finish_line, {"release_green"}),
        ),
        _area(
            "arbitrary_goal_domains",
            "configured_domains_route_to_production_unknown_domains_candidate_only",
            _artifact_valid(arbitrary)
            and "governed_arbitrary_public_reference_domain_handling" in arbitrary.get("allowedClaims", [])
            and _path(arbitrary, "recordCounts", "candidateClaims") == 0
            and _path(arbitrary, "recordCounts", "candidateProductionWrites") == 0,
            "arbitrary-domain handling gate",
            _artifact_issues("arbitrary-domain handling gate", arbitrary),
        ),
        _area(
            "representative_goal_domain_gauntlet",
            "configured_cases_pass_unknown_cases_candidate_only",
            _artifact_valid(gauntlet)
            and _path(gauntlet, "recordCounts", "configuredCasesBlocked") == 0
            and _path(gauntlet, "recordCounts", "unknownCasesBlocked") == 0
            and _path(gauntlet, "recordCounts", "finalOutputsGenerated") == 0,
            "goal-domain gauntlet",
            _artifact_issues("goal-domain gauntlet", gauntlet),
        ),
        _area(
            "autonomous_control_loop",
            "monitoring_ready_writes_held",
            _artifact_valid(control_loop) and REQUIRED_CONTROL_LOOP_CLAIMS.issubset(set(control_loop.get("allowedClaims", []))),
            "autonomous control loop",
            _claim_issues("autonomous control loop", control_loop, REQUIRED_CONTROL_LOOP_CLAIMS),
        ),
        _area(
            "autonomous_cycle_runner",
            "recurring_cycle_actions_emitted",
            _artifact_valid(cycle) and REQUIRED_CYCLE_CLAIMS.issubset(set(cycle.get("allowedClaims", []))),
            "autonomous cycle runner",
            _claim_issues("autonomous cycle runner", cycle, REQUIRED_CYCLE_CLAIMS),
        ),
        _area(
            "autonomous_cycle_execution",
            "local_cycle_actions_executed_no_mutation",
            _artifact_valid(cycle_executor)
            and REQUIRED_EXECUTOR_CLAIMS.issubset(set(cycle_executor.get("allowedClaims", [])))
            and _path(cycle_executor, "recordCounts", "remoteMutations") == 0
            and _path(cycle_executor, "recordCounts", "nativeRuntimeMutations") == 0
            and _path(cycle_executor, "recordCounts", "finalOutputsGenerated") == 0,
            "autonomous cycle executor",
            _claim_issues("autonomous cycle executor", cycle_executor, REQUIRED_EXECUTOR_CLAIMS),
        ),
        _area(
            "claim_ceiling",
            "release_legal_universal_and_final_output_claims_blocked",
            _required_blocks_present(artifacts),
            "all gate reports",
            _required_block_issues(artifacts),
        ),
    ]


def _checks(artifacts: dict[str, Any], matrix: list[dict[str, Any]], remaining_work: list[dict[str, Any]]) -> list[dict[str, Any]]:
    domain_count = _configured_domain_count(artifacts)
    checks = [
        _check("all_required_artifacts_valid", all(_artifact_valid(value) for value in artifacts.values()), _all_artifact_issues(artifacts)),
        _check("readiness_matrix_all_green", all(item["ready"] for item in matrix), _matrix_issues(matrix)),
        _check("configured_domains_present", domain_count > 0, [] if domain_count > 0 else ["no configured domains found"]),
        _check("r2_readback_reconciled_for_every_configured_domain", _r2_reconciled(artifacts), _r2_reconciled_issues(artifacts)),
        _check("remaining_work_is_human_or_forbidden_only", _remaining_work_is_allowed(remaining_work), _remaining_work_issues(remaining_work)),
        _check("no_remote_or_native_mutation_from_orchestrator", _cycle_executor_safe(artifacts), _cycle_executor_safety_issues(artifacts)),
        _check("no_final_output_generation", _final_outputs_generated(artifacts) == 0, ["final outputs generated"] if _final_outputs_generated(artifacts) else []),
    ]
    return checks


def _remaining_work(matrix: list[dict[str, Any]]) -> list[dict[str, Any]]:
    remaining = [
        {
            "area": "outside_legal_approval",
            "state": "not_claimed",
            "reason": "outside legal approval requires an explicit current outside legal artifact",
            "codexCanComplete": False,
        },
        {
            "area": "release_green",
            "state": "not_claimed",
            "reason": "Release Green requires umbrella release proof, current device proof, accessibility proof, rollback proof, and owner approval",
            "codexCanComplete": False,
        },
        {
            "area": "literal_universal_coverage",
            "state": "forbidden_claim",
            "reason": "Source Atlas supports governed arbitrary public/reference domain expansion, not literal universal coverage",
            "codexCanComplete": False,
        },
        {
            "area": "future_remote_r2_write",
            "state": "execute_gated",
            "reason": "future R2 writes require explicit execute, budget, approval, and credentials; this orchestrator reconciles current proof only",
            "codexCanComplete": True,
        },
    ]
    for item in matrix:
        if not item["ready"]:
            remaining.append(
                {
                    "area": item["area"],
                    "state": "blocked",
                    "reason": "; ".join(item["issues"]) or "readiness check failed",
                    "codexCanComplete": True,
                }
            )
    return remaining


def _matrix_issues(matrix: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    for item in matrix:
        if item["ready"]:
            continue
        item_issues = item.get("issues", [])
        if item_issues:
            issues.extend(f"{item['area']}: {issue}" for issue in item_issues)
        else:
            issues.append(str(item["area"]))
    return issues


def _remaining_work_is_allowed(items: list[dict[str, Any]]) -> bool:
    allowed = {
        "outside_legal_approval",
        "release_green",
        "literal_universal_coverage",
        "future_remote_r2_write",
    }
    return all(item["area"] in allowed for item in items)


def _remaining_work_issues(items: list[dict[str, Any]]) -> list[str]:
    return [f"unexpected remaining blocker: {item['area']}" for item in items if item["area"] not in {"outside_legal_approval", "release_green", "literal_universal_coverage", "future_remote_r2_write"}]


def _required_blocks_present(artifacts: dict[str, Any]) -> bool:
    return not _required_block_issues(artifacts)


def _required_block_issues(artifacts: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for label, artifact in artifacts.items():
        if label == "productionTargetLedger":
            required = {"full_source_atlas_green", "outside_legal_approval", "release_green", "literal_universal_coverage"}
        elif label == "productionFinishLineGate":
            required = {"outside_legal_approval", "release_green", "universal_coverage"}
        else:
            required = REQUIRED_BLOCKED_CLAIMS & set(_all_claims(artifact))
        issues.extend(_blocked_claim_required_issues(label, artifact, required))
    return sorted(set(issues))


def _all_claims(artifact: Any) -> list[str]:
    if not isinstance(artifact, dict):
        return []
    return list(artifact.get("blockedClaims", [])) + list(artifact.get("allowedClaims", []))


def _r2_reconciled(artifacts: dict[str, Any]) -> bool:
    sweep = artifacts["productionSweep"]
    if not isinstance(sweep, dict):
        return False
    counts = sweep.get("recordCounts", {})
    return (
        counts.get("configuredDomains", 0) > 0
        and counts.get("remoteR2UploadsReconciled") == counts.get("configuredDomains")
        and counts.get("domainsBlocked") == 0
    )


def _r2_reconciled_issues(artifacts: dict[str, Any]) -> list[str]:
    sweep = artifacts["productionSweep"]
    if not isinstance(sweep, dict):
        return ["production sweep missing"]
    counts = sweep.get("recordCounts", {})
    issues = []
    if counts.get("configuredDomains", 0) <= 0:
        issues.append("no configured domains in production sweep")
    if counts.get("remoteR2UploadsReconciled") != counts.get("configuredDomains"):
        issues.append("remote R2 upload/readback count does not match configured domain count")
    if counts.get("domainsBlocked") != 0:
        issues.append("production sweep has blocked domains")
    return issues


def _cycle_executor_safe(artifacts: dict[str, Any]) -> bool:
    executor = artifacts["autonomousCycleExecutor"]
    return (
        _path(executor, "recordCounts", "remoteMutations") == 0
        and _path(executor, "recordCounts", "nativeRuntimeMutations") == 0
        and _path(executor, "recordCounts", "finalOutputsGenerated") == 0
    )


def _cycle_executor_safety_issues(artifacts: dict[str, Any]) -> list[str]:
    executor = artifacts["autonomousCycleExecutor"]
    issues = []
    if _path(executor, "recordCounts", "remoteMutations") != 0:
        issues.append("cycle executor remote mutation count is nonzero")
    if _path(executor, "recordCounts", "nativeRuntimeMutations") != 0:
        issues.append("cycle executor native runtime mutation count is nonzero")
    if _path(executor, "recordCounts", "finalOutputsGenerated") != 0:
        issues.append("cycle executor final-output count is nonzero")
    return issues


def _final_outputs_generated(artifacts: dict[str, Any]) -> int:
    total = 0
    for artifact in artifacts.values():
        if isinstance(artifact, dict):
            total += int(_path(artifact, "recordCounts", "finalOutputsGenerated") or 0)
            total += int(_path(artifact, "recordCounts", "finalOutputs") or 0)
    return total


def _configured_domain_count(artifacts: dict[str, Any]) -> int:
    for artifact_name, key in [
        ("productionTargetLedger", "configuredFrontiers"),
        ("productionSweep", "configuredDomains"),
        ("goalDomainGauntlet", "configuredFrontiers"),
        ("autonomousControlLoop", "configuredDomains"),
    ]:
        count = _path(artifacts.get(artifact_name), "recordCounts", key)
        if isinstance(count, int) and count > 0:
            return count
    domains = _path(artifacts.get("productionTargetLedger"), "domains")
    return len(domains) if isinstance(domains, list) else 0


def _all_artifact_issues(artifacts: dict[str, Any]) -> list[str]:
    return sorted(
        set(
            issue
            for label, artifact in artifacts.items()
            for issue in _artifact_issues(label, artifact)
        )
    )


def _artifact_valid(value: Any) -> bool:
    return isinstance(value, dict) and value.get("valid") is True


def _artifact_issues(label: str, value: Any) -> list[str]:
    if not isinstance(value, dict):
        return [f"{label} missing_or_unreadable"]
    if value.get("valid") is True:
        return []
    return [f"{label} valid flag is not true", *value.get("issues", [])]


def _claim_issues(label: str, artifact: Any, required: set[str]) -> list[str]:
    issues = _artifact_issues(label, artifact)
    if isinstance(artifact, dict):
        claims = set(artifact.get("allowedClaims", []))
        issues.extend(f"{label} missing allowed claim: {claim}" for claim in sorted(required - claims))
    return sorted(set(issues))


def _blocked_claim_required_issues(label: str, artifact: Any, required: set[str]) -> list[str]:
    if not required:
        return []
    if not isinstance(artifact, dict):
        return [f"{label} missing blocked claims"]
    blocked = set(artifact.get("blockedClaims", []))
    allowed = set(artifact.get("allowedClaims", []))
    issues = [f"{label} missing blocked claim: {claim}" for claim in sorted(required - blocked)]
    issues.extend(f"{label} incorrectly allowed blocked claim: {claim}" for claim in sorted(required & allowed))
    return issues


def _area(area: str, state: str, ready: bool, evidence: str, issues: list[str]) -> dict[str, Any]:
    return {
        "area": area,
        "state": state,
        "ready": bool(ready),
        "evidence": evidence,
        "issues": sorted(set(issues)) if not ready else [],
    }


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
            "new_remote_r2_write_executed_by_orchestrator",
            "source_atlas_private_goal_text_processing",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )


def _artifact_fingerprints(artifacts: dict[str, Any]) -> dict[str, str]:
    return {label: stable_hash(_fingerprint_payload(value)) for label, value in sorted(artifacts.items())}


def _fingerprint_payload(value: Any) -> Any:
    if not isinstance(value, dict):
        return value
    return {
        "kind": value.get("kind"),
        "versionID": value.get("versionID"),
        "valid": value.get("valid"),
        "status": value.get("status"),
        "overallReadinessStatus": value.get("overallReadinessStatus"),
        "recordCounts": value.get("recordCounts"),
        "allowedClaims": value.get("allowedClaims"),
        "blockedClaims": value.get("blockedClaims"),
        "issues": value.get("issues"),
    }


def _evidence_paths(options: AutonomousProductionOrchestratorOptions, cycle_executor: dict[str, Any]) -> dict[str, str]:
    return {
        "productionTargetLedger": str(options.production_target_ledger_path),
        "productionFinishLineGate": str(options.production_finish_line_gate_path),
        "productionSweep": str(options.production_sweep_path),
        "arbitraryDomainGate": str(options.arbitrary_domain_gate_path),
        "goalDomainGauntlet": str(options.goal_domain_gauntlet_path),
        "autonomousControlLoop": str(options.autonomous_control_loop_path),
        "autonomousCycle": str(options.autonomous_cycle_path),
        "autonomousCycleExecutor": str(cycle_executor.get("outputPaths", {}).get("report", "")),
    }


def _path(value: Any, *keys: str) -> Any:
    current = value
    for key in keys:
        if not isinstance(current, dict):
            return None
        current = current.get(key)
    return current


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(issues))}


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - malformed evidence artifact.
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None
