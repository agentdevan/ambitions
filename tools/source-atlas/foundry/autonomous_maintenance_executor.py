"""Safe executor for Source Atlas freshness maintenance work plans.

The Train 124 planner decides what should happen next. This executor turns
that plan into local operational artifacts: monitor snapshots, source/terms
review packets, and held gate packets for harvest, pack, R2, and native work.
It never performs live harvest, R2 write, Worker deploy, native mutation, legal
approval, or final user-output generation.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .autonomous_freshness_scheduler import ACTION_ORDER, FRESHNESS_NON_CLAIMS
from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


AUTONOMOUS_MAINTENANCE_EXECUTOR_KIND = "ambitions.sourceAtlas.autonomousMaintenanceExecutor.v1"
AUTONOMOUS_MAINTENANCE_EXECUTOR_VERSION = "source-atlas-autonomous-maintenance-executor-train-125"

MONITOR_ACTIONS = {"monitor_current_production"}
SAFE_REVIEW_ACTIONS = {"candidate_frontier_review", "source_lane_review", "terms_review"}
HELD_GATE_ACTIONS = {
    "governed_harvest_refresh",
    "pack_rebuild",
    "r2_publish_gate",
    "native_runtime_recertification",
}

MAINTENANCE_NON_CLAIMS = [
    "safe local maintenance executor only",
    "not a live harvest runner",
    "not an automatic production R2 writer",
    "not a Worker deployer",
    "not native runtime mutation",
    "not active registry mutation",
    "not outside legal approval",
    "not full Source Atlas Green",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not native physical-device proof",
    "not independent accessibility proof",
    "not literal universal coverage",
    "not final user plans, schedules, Steps, priority order, recovery paths, or personalized paths from Source Atlas/R2",
    *FRESHNESS_NON_CLAIMS,
]


@dataclass(frozen=True)
class AutonomousMaintenanceExecutorOptions:
    freshness_plan_path: Path
    output_root: Path
    created_at: str = "2026-06-29T03:15:00Z"
    run_label: str = "current"
    execute_safe_actions: bool = False


def run_autonomous_maintenance_executor(options: AutonomousMaintenanceExecutorOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    plan = _read_required_json(options.freshness_plan_path, "freshness plan", issues)
    input_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "freshnessPlanPath": str(options.freshness_plan_path),
                "freshnessPlan": plan,
                "executeSafeActions": options.execute_safe_actions,
            },
            "source-atlas-autonomous-maintenance-executor-input",
        )
    )
    issues.extend(input_privacy_issues)
    if isinstance(plan, dict) and plan.get("valid") is not True:
        issues.append("freshness plan is not valid")

    domain_plans = _domain_plans_by_id(plan)
    action_results: list[dict[str, Any]] = []
    artifacts: list[dict[str, str]] = []
    if isinstance(plan, dict) and not input_privacy_issues and plan.get("valid") is True:
        for work_item in _work_items(plan):
            execution = _execute_work_item(work_item, domain_plans.get(str(work_item.get("domainID"))), options)
            action_results.append(execution["result"])
            artifacts.extend(execution["artifacts"])

    action_results.sort(key=lambda item: (ACTION_ORDER.get(item["nextAction"], 999), item["domainID"]))
    artifacts.sort(key=lambda item: (item["domainID"], item["kind"], item["path"]))
    record_counts = _record_counts(action_results)
    output_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "actionResults": _privacy_action_view(action_results),
                "artifactCount": len(artifacts),
                "recordCounts": record_counts,
            },
            "source-atlas-autonomous-maintenance-executor-output",
        )
    )
    issues.extend(output_privacy_issues)
    checks = [
        _check("freshness_plan_loaded", isinstance(plan, dict), [] if isinstance(plan, dict) else ["freshness plan missing_or_unreadable"]),
        _check("freshness_plan_valid", isinstance(plan, dict) and plan.get("valid") is True, [] if isinstance(plan, dict) and plan.get("valid") is True else ["freshness plan is not valid"]),
        _check("work_items_loaded", bool(action_results), [] if action_results else ["no work items loaded"]),
        _check("safe_actions_respect_execute_flag", options.execute_safe_actions or record_counts["reviewPacketsWritten"] == 0, ["review packet written without execute-safe-actions"] if not options.execute_safe_actions and record_counts["reviewPacketsWritten"] else []),
        _check("no_unsafe_mutations", _unsafe_count(record_counts) == 0, _unsafe_issues(record_counts)),
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check("output_privacy_scan_passed", not output_privacy_issues, output_privacy_issues),
    ]
    valid = not issues and all(check["passed"] for check in checks)
    allowed_claims = []
    if valid:
        allowed_claims = [
            "autonomous_maintenance_executor_green",
            "configured_domain_monitor_snapshots_written",
            "unsafe_mutations_remain_blocked",
        ]
        if record_counts["reviewPacketsWritten"] > 0:
            allowed_claims.append("candidate_and_review_work_packets_written")
        if record_counts["heldGatePacketsWritten"] > 0:
            allowed_claims.append("production_gated_work_packets_written_without_execution")

    report_path = output_root / "autonomous-maintenance-executor-report.json"
    markdown_path = output_root / "autonomous-maintenance-executor-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_MAINTENANCE_EXECUTOR_KIND,
        "versionID": AUTONOMOUS_MAINTENANCE_EXECUTOR_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "executionID": stable_id(
            "source_atlas.autonomous_maintenance_execution",
            {
                "freshnessPlan": str(options.freshness_plan_path),
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "executeSafeActions": options.execute_safe_actions,
                "actionResults": action_results,
            },
        ),
        "status": "Source Green for autonomous Source Atlas maintenance execution" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; safe local maintenance execution only",
        "overallReadinessStatus": "autonomous_maintenance_execution_ready" if valid else "blocked_or_partial",
        "executionMode": "execute_safe_local_actions" if options.execute_safe_actions else "observe_and_hold_only",
        "executeSafeActionsRequested": options.execute_safe_actions,
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "actionResults": action_results,
        "artifacts": artifacts,
        "allowedClaims": allowed_claims,
        "blockedClaims": _blocked_claims(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": input_privacy_issues + output_privacy_issues,
        "nonClaims": MAINTENANCE_NON_CLAIMS,
        "evidencePaths": {
            "freshnessPlan": str(options.freshness_plan_path),
        },
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
        },
    }
    report["outputHashes"] = _artifact_hashes(artifacts)
    report["outputHashes"]["reportPayload"] = stable_hash({key: value for key, value in report.items() if key != "outputHashes"})
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = autonomous_maintenance_executor_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def autonomous_maintenance_executor_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Autonomous Maintenance Executor Train 125",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Execution mode: {report['executionMode']}",
        "",
        "Scope completed:",
        "- Consumed the autonomous freshness/review work plan.",
        "- Wrote local monitor snapshots for current configured production domains.",
        "- Wrote local review packets for safe review work when `--execute-safe-actions` was supplied.",
        "- Held harvest, pack, R2, and native work behind explicit gates without mutation.",
        "- Performed no live harvest, production R2 write, Worker deploy, native runtime mutation, active registry mutation, or final user output generation.",
        "",
        "Counts:",
        f"- Work items processed: {counts['workItemsProcessed']}",
        f"- Monitor snapshots written: {counts['monitorSnapshotsWritten']}",
        f"- Review packets written: {counts['reviewPacketsWritten']}",
        f"- Held gate packets written: {counts['heldGatePacketsWritten']}",
        f"- Planned not executed: {counts['plannedNotExecuted']}",
        f"- Production writes executed: {counts['productionWritesExecuted']}",
        f"- Live harvests executed: {counts['liveHarvestsExecuted']}",
        f"- Remote mutations: {counts['remoteMutations']}",
        f"- Native runtime mutations: {counts['nativeRuntimeMutations']}",
        f"- Final outputs generated: {counts['finalOutputsGenerated']}",
        "",
        "Action results:",
        "",
        "| Domain | Action | Status | Gate | Artifacts |",
        "| --- | --- | --- | --- | --- |",
    ]
    for result in report.get("actionResults", []):
        lines.append(
            "| {domain} | {action} | {status} | {gate} | {artifacts} |".format(
                domain=result["domainID"],
                action=result["nextAction"],
                status=result["status"],
                gate=result["requiredGate"],
                artifacts="<br>".join(result.get("artifactPaths", [])) or "none",
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
            "- Executor inputs and outputs are public domain IDs, source IDs, review gates, proof paths, and local operational artifacts only.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, priority order, recovery paths, or personalized paths.",
            "",
            "Validation not run:",
            "- No live harvest was run by the executor.",
            "- No production R2 write was run by the executor.",
            "- No Worker deploy was run by the executor.",
            "- No native XCTest/build-for-testing was run by the executor.",
            "- No outside legal approval, Release Green, App Store readiness, native physical-device proof, independent accessibility proof, or literal universal coverage was claimed.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: autonomous maintenance executor module, CLI command, tests, generated artifacts, and QA evidence.",
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
            "- Revert Train 125 autonomous maintenance executor module, CLI wiring, focused tests, generated artifacts, and QA evidence.",
            "- Continue using the Train 124 freshness planner directly if this executor regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _execute_work_item(
    work_item: dict[str, Any],
    domain_plan: dict[str, Any] | None,
    options: AutonomousMaintenanceExecutorOptions,
) -> dict[str, Any]:
    action = str(work_item.get("nextAction", ""))
    domain_id = str(work_item.get("domainID", "unknown_domain"))
    if action in MONITOR_ACTIONS:
        return _write_monitor_snapshot(work_item, domain_plan, options)
    if action in SAFE_REVIEW_ACTIONS:
        if not options.execute_safe_actions:
            return {
                "result": _result(work_item, "planned_not_executed", "review artifact generation requires --execute-safe-actions", []),
                "artifacts": [],
            }
        return _write_review_packet(work_item, domain_plan, options)
    if action in HELD_GATE_ACTIONS:
        return _write_held_gate_packet(work_item, domain_plan, options)
    return {
        "result": _result(work_item, "blocked_by_gate", f"unknown maintenance action requires manual review: {action}", []),
        "artifacts": [],
    }


def _write_monitor_snapshot(
    work_item: dict[str, Any],
    domain_plan: dict[str, Any] | None,
    options: AutonomousMaintenanceExecutorOptions,
) -> dict[str, Any]:
    domain_id = str(work_item["domainID"])
    path = options.output_root / "monitor" / domain_id / "monitor-snapshot.json"
    payload = {
        "kind": "ambitions.sourceAtlas.monitorSnapshot.v1",
        "createdAt": options.created_at,
        "domainID": domain_id,
        "state": work_item.get("state"),
        "sourceIDs": work_item.get("sourceIDs", []),
        "requiredGate": work_item.get("requiredGate"),
        "reasons": work_item.get("reasons", []),
        "sourceReviewWindows": (domain_plan or {}).get("sourceReviewWindows", []),
        "legalWindows": (domain_plan or {}).get("legalWindows", []),
        "apiWindows": (domain_plan or {}).get("apiWindows", []),
        "nonClaims": _non_claims(),
    }
    write_json(path, payload)
    return {
        "result": _result(work_item, "observed_snapshot_written", "current production monitor snapshot written", [str(path)]),
        "artifacts": _artifacts(domain_id, "monitor_snapshot", [path]),
    }


def _write_review_packet(
    work_item: dict[str, Any],
    domain_plan: dict[str, Any] | None,
    options: AutonomousMaintenanceExecutorOptions,
) -> dict[str, Any]:
    domain_id = str(work_item["domainID"])
    path = options.output_root / "review" / domain_id / "review-packet.json"
    markdown_path = options.output_root / "review" / domain_id / "review-packet.md"
    packet = {
        "kind": "ambitions.sourceAtlas.reviewPacket.v1",
        "createdAt": options.created_at,
        "domainID": domain_id,
        "nextAction": work_item.get("nextAction"),
        "state": work_item.get("state"),
        "requiredGate": work_item.get("requiredGate"),
        "sourceIDs": work_item.get("sourceIDs", []),
        "reasons": work_item.get("reasons", []),
        "sourceReviewWindows": (domain_plan or {}).get("sourceReviewWindows", []),
        "legalWindows": (domain_plan or {}).get("legalWindows", []),
        "apiWindows": (domain_plan or {}).get("apiWindows", []),
        "reviewChecklist": _review_checklist(str(work_item.get("nextAction", ""))),
        "artifactInputs": _safe_artifact_inputs(work_item),
        "nonClaims": _non_claims(),
    }
    write_json(path, packet)
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(_review_packet_markdown(packet), encoding="utf-8")
    return {
        "result": _result(work_item, "executed_safe", "local review packet written", [str(path), str(markdown_path)]),
        "artifacts": _artifacts(domain_id, "review_packet", [path, markdown_path]),
    }


def _write_held_gate_packet(
    work_item: dict[str, Any],
    domain_plan: dict[str, Any] | None,
    options: AutonomousMaintenanceExecutorOptions,
) -> dict[str, Any]:
    domain_id = str(work_item["domainID"])
    path = options.output_root / "held-gates" / domain_id / f"{work_item['nextAction']}.json"
    payload = {
        "kind": "ambitions.sourceAtlas.heldGatePacket.v1",
        "createdAt": options.created_at,
        "domainID": domain_id,
        "nextAction": work_item.get("nextAction"),
        "state": work_item.get("state"),
        "requiredGate": work_item.get("requiredGate"),
        "sourceIDs": work_item.get("sourceIDs", []),
        "reasons": work_item.get("reasons", []),
        "heldBecause": _held_because(str(work_item.get("nextAction", ""))),
        "sourceReviewWindows": (domain_plan or {}).get("sourceReviewWindows", []),
        "legalWindows": (domain_plan or {}).get("legalWindows", []),
        "apiWindows": (domain_plan or {}).get("apiWindows", []),
        "productionWriteExecuted": False,
        "liveHarvestExecuted": False,
        "remoteMutation": False,
        "nativeRuntimeMutation": False,
        "finalOutputGenerated": False,
        "nonClaims": _non_claims(),
    }
    write_json(path, payload)
    return {
        "result": _result(work_item, "blocked_by_gate_packet_written", "held gate packet written without execution", [str(path)]),
        "artifacts": _artifacts(domain_id, "held_gate_packet", [path]),
    }


def _review_packet_markdown(packet: dict[str, Any]) -> str:
    lines = [
        f"# Source Atlas Review Packet - {packet['domainID']}",
        "",
        f"Action: `{packet['nextAction']}`",
        f"Gate: `{packet['requiredGate']}`",
        "",
        "Reasons:",
    ]
    lines.extend(f"- {reason}" for reason in packet.get("reasons", [])) if packet.get("reasons") else lines.append("- None")
    lines.extend(["", "Checklist:"])
    lines.extend(f"- {item}" for item in packet.get("reviewChecklist", []))
    lines.extend(["", "Non-claims:"])
    lines.extend(f"- {item}" for item in packet.get("nonClaims", []))
    lines.append("")
    return "\n".join(lines)


def _review_checklist(action: str) -> list[str]:
    if action == "candidate_frontier_review":
        return [
            "confirm the domain is public/reference only",
            "define coverage frontier and non-claims before source authority",
            "classify candidate sources as discovery-only until reviewed",
            "block claims, pack output, and R2 output until source/legal/API governance passes",
        ]
    if action == "source_lane_review":
        return [
            "recheck authority class, jurisdiction, and directness",
            "recheck allowed and forbidden claim classes",
            "confirm redistribution and R2 pack policies",
            "update next review due date only after current source-lane review",
        ]
    if action == "terms_review":
        return [
            "recheck license URL, terms URL, rights URL, and attribution posture",
            "block pack output for missing or ambiguous redistribution posture",
            "attach outside legal artifact only when source-specific approval exists",
            "update expiration date only after current review",
        ]
    return ["manual review required"]


def _held_because(action: str) -> list[str]:
    if action == "governed_harvest_refresh":
        return ["live harvest remains behind explicit live, execute, API, rate, and budget gates"]
    if action == "pack_rebuild":
        return ["pack rebuild remains behind pack schema, license, provenance, and non-private scan gates"]
    if action == "r2_publish_gate":
        return ["production R2 write remains behind execute, budget, owner approval, credential, upload/readback, and SHA-256 gates"]
    if action == "native_runtime_recertification":
        return ["native runtime recertification remains behind focused request privacy, hash, quarantine, LKG, offline, and no-account proof"]
    return ["manual gate required"]


def _safe_artifact_inputs(work_item: dict[str, Any]) -> dict[str, Any]:
    return {
        "artifactPaths": [path for path in work_item.get("artifactPaths", []) if isinstance(path, str)],
        "executedSafeLocalIntake": work_item.get("executedSafeLocalIntake") is True,
    }


def _result(work_item: dict[str, Any], status: str, message: str, artifact_paths: list[str]) -> dict[str, Any]:
    return {
        "domainID": str(work_item.get("domainID", "unknown_domain")),
        "nextAction": str(work_item.get("nextAction", "")),
        "queue": str(work_item.get("queue", "")),
        "state": str(work_item.get("state", "")),
        "requiredGate": str(work_item.get("requiredGate", "manual_review")),
        "status": status,
        "message": message,
        "artifactPaths": artifact_paths,
        "productionWriteExecuted": False,
        "liveHarvestExecuted": False,
        "remoteMutation": False,
        "nativeRuntimeMutation": False,
        "finalOutputGenerated": False,
        "nonClaims": _non_claims(),
    }


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - defensive.
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _work_items(plan: dict[str, Any]) -> list[dict[str, Any]]:
    return [item for item in plan.get("workItems", []) if isinstance(item, dict)]


def _domain_plans_by_id(plan: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(plan, dict):
        return {}
    return {
        item["domainID"]: item
        for item in plan.get("domainPlans", [])
        if isinstance(item, dict) and isinstance(item.get("domainID"), str)
    }


def _record_counts(action_results: list[dict[str, Any]]) -> dict[str, int]:
    return {
        "workItemsProcessed": len(action_results),
        "monitorSnapshotsWritten": sum(1 for item in action_results if item["status"] == "observed_snapshot_written"),
        "reviewPacketsWritten": sum(1 for item in action_results if item["status"] == "executed_safe"),
        "heldGatePacketsWritten": sum(1 for item in action_results if item["status"] == "blocked_by_gate_packet_written"),
        "plannedNotExecuted": sum(1 for item in action_results if item["status"] == "planned_not_executed"),
        "blockedByGate": sum(1 for item in action_results if item["status"] in {"blocked_by_gate_packet_written", "blocked_by_gate"}),
        "productionWritesExecuted": sum(1 for item in action_results if item.get("productionWriteExecuted") is True),
        "liveHarvestsExecuted": sum(1 for item in action_results if item.get("liveHarvestExecuted") is True),
        "remoteMutations": sum(1 for item in action_results if item.get("remoteMutation") is True),
        "nativeRuntimeMutations": sum(1 for item in action_results if item.get("nativeRuntimeMutation") is True),
        "finalOutputsGenerated": sum(1 for item in action_results if item.get("finalOutputGenerated") is True),
    }


def _unsafe_count(record_counts: dict[str, int]) -> int:
    return (
        record_counts["productionWritesExecuted"]
        + record_counts["liveHarvestsExecuted"]
        + record_counts["remoteMutations"]
        + record_counts["nativeRuntimeMutations"]
        + record_counts["finalOutputsGenerated"]
    )


def _unsafe_issues(record_counts: dict[str, int]) -> list[str]:
    keys = {"productionWritesExecuted", "liveHarvestsExecuted", "remoteMutations", "nativeRuntimeMutations", "finalOutputsGenerated"}
    return [f"{key}={value}" for key, value in sorted(record_counts.items()) if key in keys and value]


def _privacy_action_view(action_results: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "domainID": item["domainID"],
            "nextAction": item["nextAction"],
            "status": item["status"],
            "requiredGate": item["requiredGate"],
            "artifactCount": len(item.get("artifactPaths", [])),
            "productionWriteExecuted": item["productionWriteExecuted"],
            "remoteMutation": item["remoteMutation"],
            "nativeRuntimeMutation": item["nativeRuntimeMutation"],
            "finalOutputGenerated": item["finalOutputGenerated"],
        }
        for item in action_results
    ]


def _artifacts(domain_id: str, kind: str, paths: list[Path]) -> list[dict[str, str]]:
    return [{"domainID": domain_id, "kind": kind, "path": str(path)} for path in paths]


def _artifact_hashes(artifacts: list[dict[str, str]]) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for artifact in artifacts:
        path = Path(artifact["path"])
        if path.exists() and path.suffix == ".json":
            hashes[f"{artifact['domainID']}:{artifact['kind']}:{path.name}"] = stable_hash(read_json(path))
    return dict(sorted(hashes.items()))


def _non_claims() -> list[str]:
    return [
        "not universal coverage",
        "not outside legal approval",
        "not release readiness",
        "not claim authority by itself",
        "not pack output by itself",
        "not R2 write readiness by itself",
        "not a final user plan, schedule, or Step generator",
    ]


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
            "new_remote_r2_write_executed_by_maintenance_executor",
            "uncontrolled_live_harvest",
            "active_registry_mutation_by_maintenance_executor",
            "source_atlas_private_goal_text_processing",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(issues))}
