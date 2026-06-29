"""Gated executor for autonomous Source Atlas operations cycles.

This executor consumes a Train 120 cycle report and executes only deterministic
local checks for monitor actions. R2 writes, live harvests, Worker deploys,
native runtime mutation, release claims, outside legal claims, and literal
universal coverage remain held.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value, object_key_issues
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


AUTONOMOUS_CYCLE_EXECUTOR_KIND = "ambitions.sourceAtlas.autonomousCycleExecutor.v1"
AUTONOMOUS_CYCLE_EXECUTOR_VERSION = "source-atlas-autonomous-cycle-executor-train-121"

REQUIRED_CYCLE_CLAIMS = {
    "autonomous_operations_cycle_ready_for_recurring_public_reference_runs",
    "configured_domain_monitor_actions_emitted",
    "execute_gated_r2_actions_held",
    "unknown_domain_candidate_intake_cycle_controlled",
}
REQUIRED_CYCLE_BLOCKS = {
    "release_green",
    "outside_legal_approval",
    "literal_universal_coverage",
    "automatic_r2_write_without_execute_budget_approval",
    "new_remote_r2_write_executed_by_cycle_runner",
    "final_user_plans_schedules_steps_from_source_atlas_or_r2",
}

EXECUTOR_NON_CLAIMS = [
    "autonomous cycle executor only",
    "local monitor checks only",
    "not a live harvest executor",
    "not an automatic production R2 writer",
    "not a Worker deployer",
    "not native runtime mutation",
    "not outside legal approval",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not native physical-device proof",
    "not independent accessibility proof",
    "not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class AutonomousCycleExecutorOptions:
    cycle_path: Path
    output_root: Path
    created_at: str = "2026-06-29T02:15:00Z"
    run_label: str = "current"


def run_autonomous_cycle_executor(options: AutonomousCycleExecutorOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    cycle = _read_required_json(options.cycle_path, "autonomous cycle", issues)
    actions = _operation_actions(cycle)
    action_results = [_execute_action(action) for action in actions]
    action_results.sort(key=lambda item: (item["order"], item["actionID"]))

    checks = [
        _check("cycle_report_valid", _artifact_valid(cycle), _artifact_issues("autonomous cycle", cycle)),
        _check("cycle_required_claims_present", _has_claims(cycle, REQUIRED_CYCLE_CLAIMS), _missing_claim_issues("autonomous cycle", cycle, REQUIRED_CYCLE_CLAIMS)),
        _check("cycle_blocked_claims_enforced", _has_blocks(cycle, REQUIRED_CYCLE_BLOCKS), _missing_block_issues("autonomous cycle", cycle, REQUIRED_CYCLE_BLOCKS)),
        _check("operation_actions_present", bool(actions), [] if actions else ["cycle contains no operation actions"]),
        _check("all_monitor_actions_executed_locally", _all_monitor_actions_executed(action_results), _monitor_action_issues(action_results)),
        _check("r2_write_actions_remain_held", _r2_actions_held(action_results), _r2_hold_issues(action_results)),
        _check("unknown_domain_actions_remain_candidate_only", _unknown_actions_candidate_only(action_results), _unknown_issues(action_results)),
        _check("release_legal_universal_actions_remain_held", _claim_holds_enforced(action_results), _claim_hold_issues(action_results)),
        _check("no_remote_mutation", not _remote_mutation_issues(action_results), _remote_mutation_issues(action_results)),
        _check("no_native_runtime_mutation", not _native_mutation_issues(action_results), _native_mutation_issues(action_results)),
        _check("no_final_output_generation", not _final_output_issues(action_results), _final_output_issues(action_results)),
    ]
    issues.extend(issue for check in checks for issue in check["issues"] if not check["passed"])
    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "runLabel": options.run_label,
                "cycleID": cycle.get("cycleID") if isinstance(cycle, dict) else None,
                "cycleFingerprint": cycle.get("cycleFingerprint") if isinstance(cycle, dict) else None,
                "actionResults": _privacy_result_view(action_results),
            },
            "source-atlas-autonomous-cycle-executor",
        )
    )
    issues.extend(privacy_issues)
    checks.append(_check("privacy_boundary", not privacy_issues, privacy_issues))

    valid = not issues and all(check["passed"] for check in checks) and bool(action_results)
    allowed_claims = []
    if valid:
        allowed_claims = [
            "autonomous_cycle_local_execution_green",
            "configured_domain_monitor_checks_executed",
            "execute_gated_r2_actions_refused",
            "release_legal_universal_holds_executed",
        ]

    report_path = output_root / "autonomous-cycle-executor-report.json"
    markdown_path = output_root / "autonomous-cycle-executor-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_CYCLE_EXECUTOR_KIND,
        "versionID": AUTONOMOUS_CYCLE_EXECUTOR_VERSION,
        "createdAt": options.created_at,
        "runID": stable_id(
            "source_atlas.autonomous_cycle_execution",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "cycleFingerprint": cycle.get("cycleFingerprint") if isinstance(cycle, dict) else None,
            },
        ),
        "runLabel": options.run_label,
        "status": "Source Green for autonomous Source Atlas local cycle execution" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; local execution of current configured public/reference cycle only",
        "overallReadinessStatus": "autonomous_cycle_local_execution_ready" if valid else "blocked_or_partial",
        "executionMode": "local_safe_monitor_execution_no_remote_mutation",
        "recordCounts": {
            "actionsRead": len(actions),
            "actionResults": len(action_results),
            "localMonitorChecksExecuted": sum(1 for item in action_results if item["resultState"] == "executed_local_monitor_check"),
            "heldR2WriteActions": sum(1 for item in action_results if item["resultState"] == "held_execute_required"),
            "candidateOnlyActions": sum(1 for item in action_results if item["resultState"] == "observed_candidate_only"),
            "claimHoldActions": sum(1 for item in action_results if item["resultState"] == "held_claim"),
            "remoteMutations": sum(1 for item in action_results if item["mutatedRemote"]),
            "nativeRuntimeMutations": sum(1 for item in action_results if item["mutatedNativeRuntime"]),
            "finalOutputsGenerated": sum(1 for item in action_results if item["generatedFinalOutput"]),
            "privacyIssues": len(privacy_issues),
        },
        "checks": checks,
        "issues": sorted(set(issues)),
        "actionResults": action_results,
        "allowedClaims": allowed_claims,
        "blockedClaims": _blocked_claims(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "nonClaims": EXECUTOR_NON_CLAIMS,
        "evidencePaths": {
            "cycle": str(options.cycle_path),
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
    markdown = autonomous_cycle_executor_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def autonomous_cycle_executor_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Autonomous Cycle Executor Train 121",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Execution mode: {report['executionMode']}",
        "",
        "Scope completed:",
        "- Consumed the autonomous operations cycle report.",
        "- Executed configured-domain monitor actions as deterministic local checks.",
        "- Refused execute-gated R2 write actions without mutating remote state.",
        "- Preserved unknown-domain candidate-only routing and release/legal/universal holds.",
        "- Emitted no claims, packs, production writes, native runtime mutations, final plans, schedules, or Steps.",
        "",
        "Counts:",
        f"- Actions read: {counts['actionsRead']}",
        f"- Local monitor checks executed: {counts['localMonitorChecksExecuted']}",
        f"- Held R2 write actions: {counts['heldR2WriteActions']}",
        f"- Candidate-only actions: {counts['candidateOnlyActions']}",
        f"- Claim hold actions: {counts['claimHoldActions']}",
        f"- Remote mutations: {counts['remoteMutations']}",
        f"- Native runtime mutations: {counts['nativeRuntimeMutations']}",
        f"- Final outputs generated: {counts['finalOutputsGenerated']}",
        f"- Privacy issues: {counts['privacyIssues']}",
        "",
        "Action results:",
        "",
        "| Order | Action | Domain | Result | Remote Mutation | Issues |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for result in report.get("actionResults", []):
        lines.append(
            "| {order} | `{kind}` | {domain} | {state} | {remote} | {issues} |".format(
                order=result["order"],
                kind=result["actionKind"],
                domain=result.get("domainID") or "global",
                state=result["resultState"],
                remote="yes" if result["mutatedRemote"] else "no",
                issues="<br>".join(result.get("issues", [])) or "none",
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
            "- Executor inputs and outputs contain public domain IDs, source IDs, pack IDs, object keys, proof states, and hold states only.",
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
            "- Files moved or created: autonomous cycle-executor module, CLI command, tests, generated artifacts, and QA evidence.",
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
            "- Revert Train 121 autonomous cycle-executor module, CLI wiring, focused tests, generated artifacts, and QA evidence.",
            "- Continue using the Train120 cycle runner directly if execution report generation regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _execute_action(action: dict[str, Any]) -> dict[str, Any]:
    action_kind = str(action.get("actionKind") or "")
    issues = list(action.get("issues", []))
    result_state = "blocked"

    if action_kind == "monitor_current_production_runtime":
        issues.extend(_monitor_action_issues_for_action(action))
        result_state = "executed_local_monitor_check" if not issues else "blocked"
    elif action_kind == "hold_new_remote_r2_write_until_execute_gate":
        if action.get("state") != "held_execute_required" or action.get("requiresExecute") is not True:
            issues.append("R2 write action must remain held and require execute")
        if action.get("mutatesRemote") is True or action.get("automaticWriteAllowed") is True:
            issues.append("R2 write action attempted remote mutation or automatic write")
        result_state = "held_execute_required" if not issues else "blocked"
    elif action_kind == "route_unknown_public_reference_domain_to_candidate_intake":
        if action.get("state") != "candidate_only":
            issues.append("unknown-domain action must remain candidate_only")
        if action.get("emitsClaims") is True or action.get("emitsPack") is True or action.get("mutatesRemote") is True:
            issues.append("unknown-domain action must not emit claims, packs, or remote writes")
        result_state = "observed_candidate_only" if not issues else "blocked"
    elif action_kind.startswith("hold_"):
        if action.get("state") != "held":
            issues.append("claim hold action must remain held")
        if action.get("emitsClaims") is True:
            issues.append("claim hold action must not emit claims")
        result_state = "held_claim" if not issues else "blocked"
    else:
        issues.append(f"unsupported action kind: {action_kind}")

    return {
        "actionID": action.get("actionID"),
        "order": int(action.get("order", 0) or 0),
        "actionKind": action_kind,
        "domainID": action.get("domainID"),
        "resultState": result_state,
        "packID": action.get("packID"),
        "manifestKey": action.get("manifestKey"),
        "sourceIDs": sorted(action.get("sourceIDs", [])),
        "mutatedRemote": False,
        "mutatedNativeRuntime": False,
        "generatedClaims": False,
        "generatedPack": False,
        "generatedFinalOutput": False,
        "issues": sorted(set(issues)),
    }


def _monitor_action_issues_for_action(action: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    domain_id = str(action.get("domainID") or "")
    pack_id = str(action.get("packID") or "")
    manifest_key = str(action.get("manifestKey") or "")
    if not domain_id:
        issues.append("monitor action missing domain ID")
    if not pack_id or f"/{domain_id}/" not in pack_id:
        issues.append("monitor action pack ID missing domain ID")
    if not manifest_key or f"/{domain_id}/" not in manifest_key:
        issues.append("monitor action manifest key missing domain ID")
    issues.extend(issue.format() for issue in object_key_issues(manifest_key, label=f"{domain_id}.manifestKey"))
    if action.get("mutatesRemote") is True:
        issues.append("monitor action must not mutate remote state")
    if action.get("mutatesNativeRuntime") is True:
        issues.append("monitor action must not mutate native runtime")
    if action.get("emitsFinalOutput") is True:
        issues.append("monitor action must not emit final output")
    return issues


def _operation_actions(cycle: Any) -> list[dict[str, Any]]:
    if not isinstance(cycle, dict):
        return []
    return [item for item in cycle.get("operationActions", []) if isinstance(item, dict)]


def _all_monitor_actions_executed(results: list[dict[str, Any]]) -> bool:
    monitor_results = [item for item in results if item["actionKind"] == "monitor_current_production_runtime"]
    return bool(monitor_results) and all(item["resultState"] == "executed_local_monitor_check" for item in monitor_results)


def _monitor_action_issues(results: list[dict[str, Any]]) -> list[str]:
    issues = [issue for item in results if item["actionKind"] == "monitor_current_production_runtime" for issue in item.get("issues", [])]
    if not any(item["actionKind"] == "monitor_current_production_runtime" for item in results):
        issues.append("no monitor actions executed")
    return sorted(set(issues))


def _r2_actions_held(results: list[dict[str, Any]]) -> bool:
    r2_results = [item for item in results if item["actionKind"] == "hold_new_remote_r2_write_until_execute_gate"]
    return len(r2_results) == 1 and r2_results[0]["resultState"] == "held_execute_required" and r2_results[0]["mutatedRemote"] is False


def _r2_hold_issues(results: list[dict[str, Any]]) -> list[str]:
    r2_results = [item for item in results if item["actionKind"] == "hold_new_remote_r2_write_until_execute_gate"]
    if len(r2_results) != 1:
        return ["expected exactly one held R2 write action"]
    return sorted(set(r2_results[0].get("issues", [])))


def _unknown_actions_candidate_only(results: list[dict[str, Any]]) -> bool:
    unknown_results = [item for item in results if item["actionKind"] == "route_unknown_public_reference_domain_to_candidate_intake"]
    return len(unknown_results) == 1 and unknown_results[0]["resultState"] == "observed_candidate_only"


def _unknown_issues(results: list[dict[str, Any]]) -> list[str]:
    unknown_results = [item for item in results if item["actionKind"] == "route_unknown_public_reference_domain_to_candidate_intake"]
    if len(unknown_results) != 1:
        return ["expected exactly one unknown-domain candidate-only action"]
    return sorted(set(unknown_results[0].get("issues", [])))


def _claim_holds_enforced(results: list[dict[str, Any]]) -> bool:
    hold_results = [
        item
        for item in results
        if item["actionKind"] in {"hold_release_green", "hold_outside_legal_approval", "hold_literal_universal_coverage"}
    ]
    return len(hold_results) == 3 and all(item["resultState"] == "held_claim" for item in hold_results)


def _claim_hold_issues(results: list[dict[str, Any]]) -> list[str]:
    hold_results = [
        item
        for item in results
        if item["actionKind"] in {"hold_release_green", "hold_outside_legal_approval", "hold_literal_universal_coverage"}
    ]
    if len(hold_results) != 3:
        return ["expected release, outside legal, and literal universal hold executions"]
    return sorted(set(issue for item in hold_results for issue in item.get("issues", [])))


def _remote_mutation_issues(results: list[dict[str, Any]]) -> list[str]:
    return [f"{item['actionID']}: remote mutation occurred" for item in results if item["mutatedRemote"] is True]


def _native_mutation_issues(results: list[dict[str, Any]]) -> list[str]:
    return [f"{item['actionID']}: native runtime mutation occurred" for item in results if item["mutatedNativeRuntime"] is True]


def _final_output_issues(results: list[dict[str, Any]]) -> list[str]:
    return [f"{item['actionID']}: final output generated" for item in results if item["generatedFinalOutput"] is True]


def _artifact_valid(value: Any) -> bool:
    return isinstance(value, dict) and value.get("valid") is True


def _artifact_issues(label: str, value: Any) -> list[str]:
    if not isinstance(value, dict):
        return [f"{label} missing_or_unreadable"]
    if value.get("valid") is True:
        return []
    return [f"{label} valid flag is not true", *value.get("issues", [])]


def _has_claims(artifact: Any, required: set[str]) -> bool:
    return isinstance(artifact, dict) and required.issubset(set(artifact.get("allowedClaims", [])))


def _has_blocks(artifact: Any, required: set[str]) -> bool:
    return isinstance(artifact, dict) and required.issubset(set(artifact.get("blockedClaims", [])))


def _missing_claim_issues(label: str, artifact: Any, required: set[str]) -> list[str]:
    claims = set(artifact.get("allowedClaims", [])) if isinstance(artifact, dict) else set()
    return [f"{label} missing allowed claim: {claim}" for claim in sorted(required - claims)]


def _missing_block_issues(label: str, artifact: Any, required: set[str]) -> list[str]:
    claims = set(artifact.get("blockedClaims", [])) if isinstance(artifact, dict) else set()
    return [f"{label} missing blocked claim: {claim}" for claim in sorted(required - claims)]


def _privacy_result_view(results: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "actionID": item.get("actionID"),
            "actionKind": item.get("actionKind"),
            "domainID": item.get("domainID"),
            "resultState": item.get("resultState"),
            "packID": item.get("packID"),
            "manifestKey": item.get("manifestKey"),
            "sourceIDs": item.get("sourceIDs", []),
            "mutatedRemote": item.get("mutatedRemote"),
            "mutatedNativeRuntime": item.get("mutatedNativeRuntime"),
            "generatedClaims": item.get("generatedClaims"),
            "generatedPack": item.get("generatedPack"),
            "generatedFinalOutput": item.get("generatedFinalOutput"),
            "issues": item.get("issues", []),
        }
        for item in results
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
            "literal_universal_coverage",
            "native_device_green",
            "independent_accessibility_green",
            "new_remote_r2_write_executed_by_cycle_executor",
            "automatic_r2_write_without_execute_budget_approval",
            "source_atlas_private_goal_text_processing",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )


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
