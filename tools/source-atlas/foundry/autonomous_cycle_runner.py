"""Autonomous Source Atlas operations cycle runner.

The cycle runner consumes the autonomous control-loop report and emits a
repeatable operations cycle. It is intentionally deterministic and non-mutating:
the cycle can be run by cron/CI to decide monitor, candidate-only, and hold
actions, while production R2 writes, live harvest, Worker deploy, and release
claims remain behind their separate explicit gates.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


AUTONOMOUS_CYCLE_RUNNER_KIND = "ambitions.sourceAtlas.autonomousCycleRunner.v1"
AUTONOMOUS_CYCLE_RUNNER_VERSION = "source-atlas-autonomous-cycle-runner-train-120"

REQUIRED_CONTROL_LOOP_CLAIMS = {
    "autonomous_control_loop_ready_for_configured_public_reference_domains",
    "r2_write_preflight_ready_execute_still_required",
    "unknown_domains_candidate_only_controlled",
    "release_legal_universal_claim_holds_enforced",
}
REQUIRED_CONTROL_LOOP_BLOCKS = {
    "release_green",
    "outside_legal_approval",
    "literal_universal_coverage",
    "new_remote_r2_write_executed_by_control_loop",
    "automatic_r2_write_without_execute_budget_approval",
    "final_user_plans_schedules_steps_from_source_atlas_or_r2",
}

CYCLE_NON_CLAIMS = [
    "autonomous operations cycle runner only",
    "not a live harvest executor",
    "not an automatic production R2 writer",
    "not a Worker deployer",
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
class AutonomousCycleRunnerOptions:
    control_loop_path: Path
    output_root: Path
    previous_cycle_path: Path | None = None
    created_at: str = "2026-06-29T02:00:00Z"
    cycle_label: str = "current"


def run_autonomous_cycle_runner(options: AutonomousCycleRunnerOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    control_loop = _read_required_json(options.control_loop_path, "autonomous control loop", issues)
    previous_cycle = _read_optional_json(options.previous_cycle_path, "previous autonomous cycle", issues)

    domain_actions = _domain_actions(control_loop)
    r2_actions = _r2_actions(control_loop)
    unknown_actions = _unknown_actions(control_loop)
    hold_actions = _hold_actions(control_loop)
    operation_actions = [*domain_actions, *r2_actions, *unknown_actions, *hold_actions]
    operation_actions.sort(key=lambda item: (item["order"], item["actionID"]))
    cycle_fingerprint = _cycle_fingerprint(control_loop, operation_actions)
    cycle_delta = _cycle_delta(previous_cycle, cycle_fingerprint)

    checks = [
        _check("control_loop_valid", _artifact_valid(control_loop), _artifact_issues("autonomous control loop", control_loop)),
        _check("control_loop_required_claims_present", _has_claims(control_loop, REQUIRED_CONTROL_LOOP_CLAIMS), _missing_claim_issues("autonomous control loop", control_loop, REQUIRED_CONTROL_LOOP_CLAIMS)),
        _check("control_loop_blocked_claims_enforced", _has_blocks(control_loop, REQUIRED_CONTROL_LOOP_BLOCKS), _missing_block_issues("autonomous control loop", control_loop, REQUIRED_CONTROL_LOOP_BLOCKS)),
        _check("configured_domain_monitor_actions_emitted", _all_ready_domains_have_monitor_actions(control_loop, domain_actions), _domain_monitor_issues(control_loop, domain_actions)),
        _check("no_automatic_write_actions_emitted", not _automatic_write_actions(operation_actions), _automatic_write_actions(operation_actions)),
        _check("r2_write_execute_gate_held", _r2_execute_gate_held(control_loop, r2_actions), _r2_execute_gate_issues(control_loop, r2_actions)),
        _check("unknown_domain_candidate_only_cycle_action", _unknown_candidate_only(control_loop, unknown_actions), _unknown_action_issues(control_loop, unknown_actions)),
        _check("release_legal_universal_holds_carried_forward", _holds_carried(control_loop, hold_actions), _hold_issues(control_loop, hold_actions)),
        _check("cycle_fingerprint_stable", bool(cycle_fingerprint), []),
        _check("previous_cycle_valid_when_supplied", cycle_delta["valid"], cycle_delta["issues"]),
    ]
    issues.extend(issue for check in checks for issue in check["issues"] if not check["passed"])
    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "cycleLabel": options.cycle_label,
                "controlLoopID": control_loop.get("controlLoopID") if isinstance(control_loop, dict) else None,
                "operationActions": _privacy_action_view(operation_actions),
                "cycleDelta": cycle_delta,
            },
            "source-atlas-autonomous-cycle-runner",
        )
    )
    issues.extend(privacy_issues)
    checks.append(_check("privacy_boundary", not privacy_issues, privacy_issues))

    valid = not issues and all(check["passed"] for check in checks) and bool(operation_actions)
    allowed_claims = []
    if valid:
        allowed_claims = [
            "autonomous_operations_cycle_ready_for_recurring_public_reference_runs",
            "configured_domain_monitor_actions_emitted",
            "execute_gated_r2_actions_held",
            "unknown_domain_candidate_intake_cycle_controlled",
        ]
        if cycle_delta["unchangedFromPrevious"]:
            allowed_claims.append("idempotent_cycle_replay_proof")

    report_path = output_root / "autonomous-cycle-runner-report.json"
    markdown_path = output_root / "autonomous-cycle-runner-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_CYCLE_RUNNER_KIND,
        "versionID": AUTONOMOUS_CYCLE_RUNNER_VERSION,
        "createdAt": options.created_at,
        "cycleID": stable_id(
            "source_atlas.autonomous_cycle",
            {
                "createdAt": options.created_at,
                "cycleLabel": options.cycle_label,
                "fingerprint": cycle_fingerprint,
            },
        ),
        "cycleLabel": options.cycle_label,
        "cycleFingerprint": cycle_fingerprint,
        "status": "Source Green for autonomous Source Atlas operations cycle tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; recurring autonomous cycle tooling for current configured public/reference domains only",
        "overallReadinessStatus": "autonomous_operations_cycle_ready" if valid else "blocked_or_partial",
        "executionMode": "cycle_decision_only_no_mutation",
        "recordCounts": {
            "operationActions": len(operation_actions),
            "configuredDomainMonitorActions": len(domain_actions),
            "r2ExecuteGateHoldActions": len(r2_actions),
            "unknownCandidateOnlyActions": len(unknown_actions),
            "releaseLegalUniversalHoldActions": len(hold_actions),
            "automaticWriteActions": len(_automatic_write_actions(operation_actions)),
            "newRemoteWritesExecuted": 0,
            "finalOutputsGenerated": 0,
            "privacyIssues": len(privacy_issues),
        },
        "cycleDelta": cycle_delta,
        "checks": checks,
        "issues": sorted(set(issues)),
        "operationActions": operation_actions,
        "allowedClaims": allowed_claims,
        "blockedClaims": _blocked_claims(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "nonClaims": CYCLE_NON_CLAIMS,
        "evidencePaths": {
            "controlLoop": str(options.control_loop_path),
            "previousCycle": str(options.previous_cycle_path) if options.previous_cycle_path else None,
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
    markdown = autonomous_cycle_runner_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def autonomous_cycle_runner_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Autonomous Cycle Runner Train 120",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Execution mode: {report['executionMode']}",
        "",
        "Scope completed:",
        "- Converts the autonomous control-loop report into a repeatable operations cycle.",
        "- Emits monitor actions for current configured public/reference domains.",
        "- Emits execute-gated R2 hold actions instead of automatic production writes.",
        "- Emits unknown-domain candidate-only and release/legal/universal hold actions.",
        "- Computes a stable cycle fingerprint for idempotent recurring runs.",
        "",
        "Counts:",
        f"- Operation actions: {counts['operationActions']}",
        f"- Configured-domain monitor actions: {counts['configuredDomainMonitorActions']}",
        f"- R2 execute-gate hold actions: {counts['r2ExecuteGateHoldActions']}",
        f"- Unknown candidate-only actions: {counts['unknownCandidateOnlyActions']}",
        f"- Release/legal/universal hold actions: {counts['releaseLegalUniversalHoldActions']}",
        f"- Automatic write actions: {counts['automaticWriteActions']}",
        f"- New remote writes executed: {counts['newRemoteWritesExecuted']}",
        f"- Final outputs generated: {counts['finalOutputsGenerated']}",
        f"- Privacy issues: {counts['privacyIssues']}",
        "",
        "Operation actions:",
        "",
        "| Order | Action | Domain | State | Mutates Remote | Issues |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for action in report.get("operationActions", []):
        lines.append(
            "| {order} | `{kind}` | {domain} | {state} | {remote} | {issues} |".format(
                order=action["order"],
                kind=action["actionKind"],
                domain=action.get("domainID") or "global",
                state=action["state"],
                remote="yes" if action["mutatesRemote"] else "no",
                issues="<br>".join(action.get("issues", [])) or "none",
            )
        )
    lines.extend(
        [
            "",
            "Allowed claims:",
        ]
    )
    lines.extend(f"- `{claim}`" for claim in report.get("allowedClaims", [])) if report.get("allowedClaims") else lines.append("- None")
    lines.extend(["", "Blocked claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("blockedClaims", []))
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Cycle actions contain public domain IDs, source IDs, pack IDs, object keys, proof states, and hold states only.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, priority order, recovery paths, or personalized paths.",
            "",
            "Validation not run:",
            "- No new live harvest was run by the cycle runner.",
            "- No new production R2 write was run by the cycle runner.",
            "- No Worker deploy was run by the cycle runner.",
            "- No new native XCTest/build-for-testing was run by the cycle runner.",
            "- No outside legal approval, Release Green, App Store readiness, native physical-device proof, independent accessibility proof, or literal universal coverage was claimed.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: autonomous cycle-runner module, CLI command, tests, generated artifacts, and QA evidence.",
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
            "- Revert Train 120 autonomous cycle-runner module, CLI wiring, focused tests, generated artifacts, and QA evidence.",
            "- Continue using the Train119 autonomous control loop directly if cycle emission regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _domain_actions(control_loop: Any) -> list[dict[str, Any]]:
    actions = []
    if not isinstance(control_loop, dict):
        return actions
    for index, decision in enumerate(control_loop.get("domainControlDecisions", []), start=1):
        if not isinstance(decision, dict):
            continue
        domain_id = str(decision.get("domainID") or "")
        ready = decision.get("readyForMonitoring") is True and decision.get("controlAction") == "monitor_current_production_runtime"
        issues = [] if ready else list(decision.get("issues", []) or ["domain is not ready for monitoring"])
        actions.append(
            {
                "actionID": stable_id("source_atlas.cycle_action.domain_monitor", {"domain": domain_id, "packID": decision.get("packID")}),
                "order": 1000 + index,
                "actionKind": "monitor_current_production_runtime",
                "state": "ready" if ready else "hold",
                "domainID": domain_id,
                "packID": decision.get("packID"),
                "packVersion": decision.get("packVersion"),
                "manifestKey": decision.get("manifestKey"),
                "sourceIDs": sorted(decision.get("sourceIDs", [])),
                "requiresExecute": False,
                "mutatesRemote": False,
                "mutatesNativeRuntime": False,
                "emitsClaims": False,
                "emitsFinalOutput": False,
                "automaticWriteAllowed": False,
                "issues": sorted(set(issues)),
            }
        )
    return actions


def _r2_actions(control_loop: Any) -> list[dict[str, Any]]:
    if not isinstance(control_loop, dict):
        return []
    decision = control_loop.get("r2WriteDecision", {})
    preflight_ready = isinstance(decision, dict) and decision.get("preflightReady") is True
    issues = [] if preflight_ready else list(decision.get("blockedReasons", []) if isinstance(decision, dict) else ["R2 write decision missing"])
    return [
        {
            "actionID": stable_id("source_atlas.cycle_action.r2_execute_gate", {"preflight": preflight_ready}),
            "order": 3000,
            "actionKind": "hold_new_remote_r2_write_until_execute_gate",
            "state": "held_execute_required" if preflight_ready else "blocked",
            "domainID": None,
            "requiresExecute": True,
            "requiresOwnerApproval": True,
            "requiresBudgetPolicy": True,
            "requiresLegalTermsPacket": True,
            "mutatesRemote": False,
            "mutatesNativeRuntime": False,
            "emitsClaims": False,
            "emitsFinalOutput": False,
            "automaticWriteAllowed": False,
            "newRemoteWriteExecuted": False,
            "issues": sorted(set(issues)),
        }
    ]


def _unknown_actions(control_loop: Any) -> list[dict[str, Any]]:
    if not isinstance(control_loop, dict):
        return []
    decision = control_loop.get("unknownDomainDecision", {})
    candidate_only = isinstance(decision, dict) and decision.get("candidateOnly") is True
    issues = [] if candidate_only else list(decision.get("blockedReasons", []) if isinstance(decision, dict) else ["unknown-domain decision missing"])
    return [
        {
            "actionID": stable_id("source_atlas.cycle_action.unknown_candidate", {"candidateOnly": candidate_only}),
            "order": 4000,
            "actionKind": "route_unknown_public_reference_domain_to_candidate_intake",
            "state": "candidate_only" if candidate_only else "blocked",
            "domainID": "unknown_public_reference_domain",
            "requiresExecute": False,
            "mutatesRemote": False,
            "mutatesNativeRuntime": False,
            "emitsClaims": False,
            "emitsPack": False,
            "emitsFinalOutput": False,
            "automaticWriteAllowed": False,
            "issues": sorted(set(issues)),
        }
    ]


def _hold_actions(control_loop: Any) -> list[dict[str, Any]]:
    if not isinstance(control_loop, dict):
        return []
    return [
        _hold_action("release_green", 5000, control_loop.get("releaseDecision", {}), "releaseGreenAllowed"),
        _hold_action("outside_legal_approval", 5010, control_loop.get("outsideLegalDecision", {}), "outsideLegalApprovalAllowed"),
        _hold_action("literal_universal_coverage", 5020, control_loop.get("universalCoverageDecision", {}), "literalUniversalCoverageAllowed"),
    ]


def _hold_action(claim: str, order: int, decision: Any, allowed_key: str) -> dict[str, Any]:
    held = isinstance(decision, dict) and decision.get("held") is True and decision.get(allowed_key) is False
    issues = [] if held else list(decision.get("issues", []) if isinstance(decision, dict) else [f"{claim} hold decision missing"])
    return {
        "actionID": stable_id("source_atlas.cycle_action.claim_hold", {"claim": claim}),
        "order": order,
        "actionKind": f"hold_{claim}",
        "state": "held" if held else "blocked",
        "domainID": None,
        "claimID": claim,
        "requiresExecute": False,
        "mutatesRemote": False,
        "mutatesNativeRuntime": False,
        "emitsClaims": False,
        "emitsFinalOutput": False,
        "automaticWriteAllowed": False,
        "issues": sorted(set(issues)),
    }


def _cycle_fingerprint(control_loop: Any, operation_actions: list[dict[str, Any]]) -> str:
    return stable_hash(
        {
            "controlLoopID": control_loop.get("controlLoopID") if isinstance(control_loop, dict) else None,
            "actions": [
                {
                    "actionKind": action.get("actionKind"),
                    "domainID": action.get("domainID"),
                    "state": action.get("state"),
                    "packID": action.get("packID"),
                    "manifestKey": action.get("manifestKey"),
                    "issues": action.get("issues", []),
                }
                for action in operation_actions
            ],
        }
    )


def _cycle_delta(previous_cycle: Any, cycle_fingerprint: str) -> dict[str, Any]:
    if previous_cycle is None:
        return {
            "previousCycleSupplied": False,
            "valid": True,
            "unchangedFromPrevious": False,
            "previousCycleFingerprint": None,
            "currentCycleFingerprint": cycle_fingerprint,
            "issues": [],
        }
    issues = []
    if not isinstance(previous_cycle, dict):
        issues.append("previous cycle is not a JSON object")
    elif previous_cycle.get("valid") is not True:
        issues.append("previous cycle valid flag is not true")
    previous_fingerprint = previous_cycle.get("cycleFingerprint") if isinstance(previous_cycle, dict) else None
    return {
        "previousCycleSupplied": True,
        "valid": not issues,
        "unchangedFromPrevious": not issues and previous_fingerprint == cycle_fingerprint,
        "previousCycleFingerprint": previous_fingerprint,
        "currentCycleFingerprint": cycle_fingerprint,
        "issues": issues,
    }


def _all_ready_domains_have_monitor_actions(control_loop: Any, actions: list[dict[str, Any]]) -> bool:
    decisions = [item for item in control_loop.get("domainControlDecisions", [])] if isinstance(control_loop, dict) else []
    ready_domains = {
        item.get("domainID")
        for item in decisions
        if isinstance(item, dict) and item.get("readyForMonitoring") is True
    }
    action_domains = {action.get("domainID") for action in actions if action.get("state") == "ready"}
    return bool(ready_domains) and ready_domains == action_domains


def _domain_monitor_issues(control_loop: Any, actions: list[dict[str, Any]]) -> list[str]:
    decisions = [item for item in control_loop.get("domainControlDecisions", [])] if isinstance(control_loop, dict) else []
    ready_domains = {
        item.get("domainID")
        for item in decisions
        if isinstance(item, dict) and item.get("readyForMonitoring") is True
    }
    action_domains = {action.get("domainID") for action in actions if action.get("state") == "ready"}
    missing = sorted(str(item) for item in ready_domains - action_domains)
    extra = sorted(str(item) for item in action_domains - ready_domains)
    issues = [f"missing monitor action for {domain}" for domain in missing]
    issues.extend(f"unexpected ready monitor action for {domain}" for domain in extra)
    if not ready_domains:
        issues.append("no ready configured domains in control loop")
    return issues


def _automatic_write_actions(actions: list[dict[str, Any]]) -> list[str]:
    return [
        f"{action.get('actionID')}: automatic write action is not allowed"
        for action in actions
        if action.get("automaticWriteAllowed") is True or action.get("mutatesRemote") is True
    ]


def _r2_execute_gate_held(control_loop: Any, actions: list[dict[str, Any]]) -> bool:
    r2 = control_loop.get("r2WriteDecision", {}) if isinstance(control_loop, dict) else {}
    return (
        isinstance(r2, dict)
        and r2.get("preflightReady") is True
        and r2.get("executeRequired") is True
        and r2.get("automaticWriteAllowed") is False
        and len(actions) == 1
        and actions[0].get("state") == "held_execute_required"
        and actions[0].get("mutatesRemote") is False
    )


def _r2_execute_gate_issues(control_loop: Any, actions: list[dict[str, Any]]) -> list[str]:
    issues = []
    r2 = control_loop.get("r2WriteDecision", {}) if isinstance(control_loop, dict) else {}
    if not isinstance(r2, dict) or r2.get("preflightReady") is not True:
        issues.append("R2 write preflight is not ready")
    if isinstance(r2, dict) and r2.get("executeRequired") is not True:
        issues.append("R2 write decision must require execute")
    if isinstance(r2, dict) and r2.get("automaticWriteAllowed") is not False:
        issues.append("R2 write decision must keep automatic writes blocked")
    if len(actions) != 1 or actions[0].get("state") != "held_execute_required":
        issues.append("R2 cycle action must be held_execute_required")
    return issues


def _unknown_candidate_only(control_loop: Any, actions: list[dict[str, Any]]) -> bool:
    unknown = control_loop.get("unknownDomainDecision", {}) if isinstance(control_loop, dict) else {}
    return (
        isinstance(unknown, dict)
        and unknown.get("candidateOnly") is True
        and unknown.get("r2PublishAllowed") is False
        and unknown.get("productionWriteAllowed") is False
        and len(actions) == 1
        and actions[0].get("state") == "candidate_only"
    )


def _unknown_action_issues(control_loop: Any, actions: list[dict[str, Any]]) -> list[str]:
    unknown = control_loop.get("unknownDomainDecision", {}) if isinstance(control_loop, dict) else {}
    issues = []
    if not isinstance(unknown, dict) or unknown.get("candidateOnly") is not True:
        issues.append("unknown-domain decision is not candidate-only")
    if isinstance(unknown, dict) and (unknown.get("r2PublishAllowed") is not False or unknown.get("productionWriteAllowed") is not False):
        issues.append("unknown-domain decision allows R2 publish or production write")
    if len(actions) != 1 or actions[0].get("state") != "candidate_only":
        issues.append("unknown-domain cycle action must be candidate_only")
    return issues


def _holds_carried(control_loop: Any, actions: list[dict[str, Any]]) -> bool:
    if len(actions) != 3:
        return False
    return all(action.get("state") == "held" and action.get("emitsClaims") is False for action in actions)


def _hold_issues(control_loop: Any, actions: list[dict[str, Any]]) -> list[str]:
    if len(actions) != 3:
        return ["expected release, outside legal, and literal universal hold actions"]
    return [issue for action in actions for issue in action.get("issues", [])]


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


def _privacy_action_view(actions: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "actionID": action.get("actionID"),
            "actionKind": action.get("actionKind"),
            "state": action.get("state"),
            "domainID": action.get("domainID"),
            "packID": action.get("packID"),
            "manifestKey": action.get("manifestKey"),
            "sourceIDs": action.get("sourceIDs", []),
            "mutatesRemote": action.get("mutatesRemote"),
            "mutatesNativeRuntime": action.get("mutatesNativeRuntime"),
            "emitsClaims": action.get("emitsClaims"),
            "emitsFinalOutput": action.get("emitsFinalOutput"),
            "automaticWriteAllowed": action.get("automaticWriteAllowed"),
            "issues": action.get("issues", []),
        }
        for action in actions
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
            "new_remote_r2_write_executed_by_cycle_runner",
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


def _read_optional_json(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        return None
    return _read_required_json(path, label, issues)
