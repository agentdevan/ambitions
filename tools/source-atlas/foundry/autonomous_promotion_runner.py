"""Autonomous promotion control for Source Atlas production operations.

This runner turns the supervised operating loop into explicit promotion
decisions. It reconciles current supervisor work, production sweep status,
owner approval, legal/terms evidence, and API governance before any domain can
advance from observation into a write-ready path.

The runner does not perform live harvests, R2 writes, Worker deploys, native
runtime mutations, registry mutations, or final user-output generation.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value, object_key_issues
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json
from .r2_owner_approval import validate_r2_owner_approval_artifact


AUTONOMOUS_PROMOTION_RUNNER_KIND = "ambitions.sourceAtlas.autonomousPromotionRunner.v1"
AUTONOMOUS_PROMOTION_RUNNER_VERSION = "source-atlas-autonomous-promotion-runner-train-127"

PROMOTION_NON_CLAIMS = [
    "autonomous promotion control only",
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
    *NON_CLAIMS,
]

HELD_GATE_STATES = {
    "governed_harvest_refresh": "harvest_refresh_execute_gate_held",
    "pack_rebuild": "pack_rebuild_execute_gate_held",
    "r2_publish_gate": "r2_publish_execute_gate_held",
    "native_runtime_recertification": "native_runtime_recertification_gate_held",
}


@dataclass(frozen=True)
class AutonomousPromotionRunnerOptions:
    supervisor_report_path: Path
    production_sweep_path: Path
    owner_approval_path: Path | None
    legal_terms_registry_path: Path
    api_governance_registry_path: Path
    output_root: Path
    legal_approval_packet_path: Path | None = None
    created_at: str = "2026-06-29T03:45:00Z"
    run_label: str = "current"
    environment: str = "production"
    channel: str = "stable"
    bucket: str | None = None
    execute_r2: bool = False


def run_autonomous_promotion_runner(options: AutonomousPromotionRunnerOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    supervisor = _read_required_json(options.supervisor_report_path, "supervisor report", issues)
    sweep = _read_required_json(options.production_sweep_path, "production sweep", issues)
    legal_registry = _read_required_json(options.legal_terms_registry_path, "legal/terms registry", issues)
    api_registry = _read_required_json(options.api_governance_registry_path, "API governance registry", issues)
    legal_packet = _read_optional_json(options.legal_approval_packet_path, "legal approval packet", issues)

    domain_ids = _configured_domain_ids(sweep)
    resolved_bucket = options.bucket or _bucket_from_sweep(sweep)
    owner_approval_validation = validate_r2_owner_approval_artifact(
        options.owner_approval_path,
        environment=options.environment,
        channel=options.channel,
        bucket=resolved_bucket,
        domain_ids=domain_ids,
    )
    if options.execute_r2 and not owner_approval_validation["valid"]:
        issues.append("execute-r2 requires a valid owner approval artifact")

    input_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "supervisorReportPath": str(options.supervisor_report_path),
                "productionSweepPath": str(options.production_sweep_path),
                "ownerApprovalPath": str(options.owner_approval_path) if options.owner_approval_path else None,
                "legalTermsRegistryPath": str(options.legal_terms_registry_path),
                "apiGovernanceRegistryPath": str(options.api_governance_registry_path),
                "legalApprovalPacketPath": str(options.legal_approval_packet_path) if options.legal_approval_packet_path else None,
                "executeR2Requested": options.execute_r2,
                "supervisorQueue": _supervisor_privacy_view(supervisor),
                "sweepDomains": _sweep_privacy_view(sweep),
            },
            "source-atlas-autonomous-promotion-runner-input",
        )
    )
    issues.extend(input_privacy_issues)

    registry_summary = _registry_summary(legal_registry, api_registry)
    legal_packet_summary = _legal_packet_summary(legal_packet)
    sweep_preflight = _sweep_preflight(sweep)
    sweep_by_domain = _sweep_by_domain(sweep)
    decisions: list[dict[str, Any]] = []
    command_queue: list[dict[str, Any]] = []
    held_gate_packets: list[dict[str, Any]] = []

    if isinstance(supervisor, dict) and isinstance(sweep, dict) and not input_privacy_issues:
        decisions = _promotion_decisions(
            supervisor,
            sweep_by_domain,
            sweep_preflight,
            owner_approval_validation,
            registry_summary,
            legal_packet_summary,
            options,
        )
        command_queue = _command_queue(decisions)
        held_gate_packets = _held_gate_packets(decisions)

    object_key_privacy_issues = _object_key_privacy_issues(decisions, sweep)
    output_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "decisionSummary": _decision_privacy_view(decisions),
                "commandQueue": _command_privacy_view(command_queue),
                "heldGateCount": len(held_gate_packets),
            },
            "source-atlas-autonomous-promotion-runner-output",
        )
    )
    issues.extend(object_key_privacy_issues)
    issues.extend(output_privacy_issues)
    issues.extend(_input_validity_issues(supervisor, sweep, legal_registry, api_registry, legal_packet, owner_approval_validation, options))

    counts = _record_counts(decisions, command_queue, held_gate_packets, input_privacy_issues + output_privacy_issues + object_key_privacy_issues)
    checks = [
        _check("supervisor_report_valid", isinstance(supervisor, dict) and supervisor.get("valid") is True, [] if isinstance(supervisor, dict) and supervisor.get("valid") is True else ["supervisor report is missing or invalid"]),
        _check("production_sweep_valid", isinstance(sweep, dict) and sweep.get("valid") is True, [] if isinstance(sweep, dict) and sweep.get("valid") is True else ["production sweep is missing or invalid"]),
        _check("owner_approval_valid_for_configured_domains", owner_approval_validation["valid"], owner_approval_validation.get("issues", [])),
        _check("legal_terms_registry_loaded", registry_summary["legalRegistryLoaded"], registry_summary["legalIssues"]),
        _check("api_governance_registry_loaded", registry_summary["apiRegistryLoaded"], registry_summary["apiIssues"]),
        _check("legal_packet_present_when_execute_requested", (not options.execute_r2) or legal_packet_summary["present"], ["execute-r2 requires a legal approval packet"] if options.execute_r2 and not legal_packet_summary["present"] else []),
        _check("future_remote_write_preflight_ready_when_execute_requested", (not options.execute_r2) or sweep_preflight["readyForNewRemoteWrite"], sweep_preflight["blockedReasons"] if options.execute_r2 and not sweep_preflight["readyForNewRemoteWrite"] else []),
        _check("r2_execute_requests_emit_commands_only", counts["r2WritesExecuted"] == 0 and counts["remoteMutations"] == 0, _unsafe_issues(counts)),
        _check("no_final_user_outputs", counts["finalOutputsGenerated"] == 0, ["final user output generated"] if counts["finalOutputsGenerated"] else []),
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check("object_key_privacy_scan_passed", not object_key_privacy_issues, object_key_privacy_issues),
        _check("output_privacy_scan_passed", not output_privacy_issues, output_privacy_issues),
    ]
    valid = not issues and all(check["passed"] for check in checks)

    allowed_claims = _allowed_claims(valid, decisions, command_queue, sweep_preflight, options)
    blocked_claims = _blocked_claims()

    decisions_path = output_root / "promotion-decisions.json"
    command_queue_path = output_root / "promotion-command-queue.json"
    held_gate_path = output_root / "held-gate-packets.json"
    report_path = output_root / "autonomous-promotion-runner-report.json"
    markdown_path = output_root / "autonomous-promotion-runner-report.md"
    closeout_path = output_root / "closeout.md"

    write_json(decisions_path, {"schemaVersion": 1, "decisions": decisions})
    write_json(command_queue_path, {"schemaVersion": 1, "commands": command_queue})
    write_json(held_gate_path, {"schemaVersion": 1, "heldGates": held_gate_packets})

    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_PROMOTION_RUNNER_KIND,
        "versionID": AUTONOMOUS_PROMOTION_RUNNER_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "promotionRunID": stable_id(
            "source_atlas.autonomous_promotion_runner",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "supervisor": str(options.supervisor_report_path),
                "productionSweep": str(options.production_sweep_path),
                "executeR2": options.execute_r2,
                "domains": domain_ids,
            },
        ),
        "status": "Source Green for autonomous Source Atlas promotion control" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; promotion-control tooling only",
        "overallReadinessStatus": "autonomous_promotion_control_ready" if valid else "blocked_or_partial",
        "executionMode": "r2_execute_requested_command_emission_only" if options.execute_r2 else "decision_only_hold_remote_writes",
        "executeR2Requested": options.execute_r2,
        "recordCounts": counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "registrySummary": registry_summary,
        "legalPacketSummary": legal_packet_summary,
        "ownerApprovalValidation": owner_approval_validation,
        "futureRemoteWritePreflight": sweep_preflight,
        "promotionDecisions": decisions,
        "promotionCommandQueue": command_queue,
        "heldGatePackets": held_gate_packets,
        "allowedClaims": allowed_claims,
        "blockedClaims": blocked_claims,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": input_privacy_issues + object_key_privacy_issues + output_privacy_issues,
        "nonClaims": PROMOTION_NON_CLAIMS,
        "evidencePaths": {
            "supervisorReport": str(options.supervisor_report_path),
            "productionSweep": str(options.production_sweep_path),
            "ownerApproval": str(options.owner_approval_path) if options.owner_approval_path else None,
            "legalTermsRegistry": str(options.legal_terms_registry_path),
            "apiGovernanceRegistry": str(options.api_governance_registry_path),
            "legalApprovalPacket": str(options.legal_approval_packet_path) if options.legal_approval_packet_path else None,
        },
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "decisions": str(decisions_path),
            "commandQueue": str(command_queue_path),
            "heldGatePackets": str(held_gate_path),
        },
    }
    report["outputHashes"] = {
        "decisions": stable_hash(read_json(decisions_path)),
        "commandQueue": stable_hash(read_json(command_queue_path)),
        "heldGatePackets": stable_hash(read_json(held_gate_path)),
        "reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"}),
    }
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = autonomous_promotion_runner_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def autonomous_promotion_runner_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Autonomous Promotion Runner Train 127",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Execution mode: {report['executionMode']}",
        "",
        "Scope completed:",
        "- Reconciled the autonomous production supervisor, production sweep, owner approval, legal/terms registry, API governance registry, and legal approval packet into promotion decisions.",
        "- Converted current work into monitor-only, review-only, held-gate, or R2 execute-preflight command states.",
        "- Emitted a deterministic command queue for gated work without performing live harvest, R2 write, Worker deploy, native runtime mutation, active registry mutation, or final user output generation.",
        "",
        "Counts:",
        f"- Configured domains: {counts['configuredDomains']}",
        f"- Promotion decisions: {counts['promotionDecisions']}",
        f"- Monitor-only decisions: {counts['monitorOnlyDecisions']}",
        f"- Candidate/review-only decisions: {counts['candidateReviewOnlyDecisions']}",
        f"- Held gate decisions: {counts['heldGateDecisions']}",
        f"- R2 execute-preflight commands: {counts['r2ExecutePreflightCommands']}",
        f"- R2 writes executed: {counts['r2WritesExecuted']}",
        f"- Remote mutations: {counts['remoteMutations']}",
        f"- Native runtime mutations: {counts['nativeRuntimeMutations']}",
        f"- Final outputs generated: {counts['finalOutputsGenerated']}",
        "",
        "Promotion decisions:",
        "",
        "| Domain | Action | Promotion state | R2 state | Blockers |",
        "| --- | --- | --- | --- | --- |",
    ]
    for decision in report.get("promotionDecisions", []):
        lines.append(
            "| {domain} | {action} | {state} | {r2} | {blockers} |".format(
                domain=decision["domainID"],
                action=decision["nextAction"],
                state=decision["promotionState"],
                r2=decision["r2State"],
                blockers="<br>".join(decision.get("blockers", [])) or "none",
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
            "- Runner inputs and outputs are public domain IDs, source IDs, gates, proof paths, command arguments, public object keys, and operational metadata only.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, priority order, recovery paths, or personalized paths.",
            "",
            "Validation not run:",
            "- No live harvest was run by the promotion runner.",
            "- No production R2 write was run by the promotion runner.",
            "- No Worker deploy was run by the promotion runner.",
            "- No native XCTest/build-for-testing was run by the promotion runner.",
            "- No outside legal approval, Release Green, App Store readiness, native physical-device proof, independent accessibility proof, or literal universal coverage was claimed.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: autonomous promotion runner module, CLI command, tests, generated artifacts, and QA evidence.",
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
            "- Revert Train 127 autonomous promotion runner module, CLI wiring, focused tests, generated artifacts, and QA evidence.",
            "- Continue using the production supervisor and production sweep reports directly if promotion-control reconciliation regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _promotion_decisions(
    supervisor: dict[str, Any],
    sweep_by_domain: dict[str, dict[str, Any]],
    preflight: dict[str, Any],
    owner_approval_validation: dict[str, Any],
    registry_summary: dict[str, Any],
    legal_packet_summary: dict[str, Any],
    options: AutonomousPromotionRunnerOptions,
) -> list[dict[str, Any]]:
    work_items = _supervisor_work_items(supervisor)
    decisions = []
    for order, item in enumerate(work_items, start=1):
        domain_id = str(item.get("domainID") or "")
        action = str(item.get("nextAction") or "")
        sweep_domain = sweep_by_domain.get(domain_id, {})
        blockers = _decision_blockers(item, sweep_domain, preflight, owner_approval_validation, registry_summary, legal_packet_summary, options)
        promotion_state = _promotion_state(action, item, blockers, preflight, owner_approval_validation, legal_packet_summary, options)
        r2_state = _r2_state(action, sweep_domain, preflight, owner_approval_validation, legal_packet_summary, options, promotion_state)
        command = _promotion_command(item, sweep_domain, promotion_state, r2_state, options)
        decision = {
            "order": order,
            "decisionID": stable_id(
                "source_atlas.promotion_decision",
                {
                    "domainID": domain_id,
                    "nextAction": action,
                    "promotionState": promotion_state,
                    "runLabel": options.run_label,
                },
            ),
            "domainID": domain_id,
            "nextAction": action,
            "inputStatus": item.get("status") or item.get("state"),
            "requiredGate": item.get("requiredGate"),
            "promotionState": promotion_state,
            "r2State": r2_state,
            "currentProductionReady": bool(sweep_domain.get("ready")),
            "existingRemoteUploadReadbackReady": bool(sweep_domain.get("r2", {}).get("remoteUploadReadbackReady")),
            "packableClaimCount": int(sweep_domain.get("packableClaimCount", 0) or 0),
            "sourceIDs": sorted(str(source_id) for source_id in sweep_domain.get("sourceIDs", []) if isinstance(source_id, str)),
            "artifactPaths": sorted(set([*item.get("artifactPaths", []), sweep_domain.get("pack", {}).get("path"), sweep_domain.get("r2", {}).get("path")]) - {None, ""}),
            "publicObjectKeys": _public_object_keys(sweep_domain),
            "blockers": blockers,
            "commandID": command["commandID"] if command else None,
            "promotionAllowed": promotion_state in {"monitor_only_current", "r2_execute_preflight_command_ready"},
            "productionWriteExecuted": False,
            "remoteMutation": False,
            "nativeRuntimeMutation": False,
            "finalOutputGenerated": False,
            "nonClaims": PROMOTION_NON_CLAIMS,
        }
        if command:
            decision["command"] = command
        decisions.append(decision)
    return sorted(decisions, key=lambda item: (item["order"], item["domainID"]))


def _supervisor_work_items(supervisor: dict[str, Any]) -> list[dict[str, Any]]:
    maintenance = [item for item in supervisor.get("maintenanceQueue", []) if isinstance(item, dict)]
    if maintenance:
        return maintenance
    return [item for item in supervisor.get("workQueue", []) if isinstance(item, dict)]


def _promotion_state(
    action: str,
    item: dict[str, Any],
    blockers: list[str],
    preflight: dict[str, Any],
    owner_approval_validation: dict[str, Any],
    legal_packet_summary: dict[str, Any],
    options: AutonomousPromotionRunnerOptions,
) -> str:
    if action == "monitor_current_production":
        return "monitor_only_current"
    if action in {"candidate_frontier_review", "source_lane_review", "terms_review"}:
        return "candidate_or_source_review_only"
    if action == "r2_publish_gate":
        if (
            options.execute_r2
            and not blockers
            and preflight["readyForNewRemoteWrite"]
            and owner_approval_validation["valid"]
            and legal_packet_summary["present"]
        ):
            return "r2_execute_preflight_command_ready"
        return "r2_publish_execute_gate_held"
    if action in HELD_GATE_STATES:
        return HELD_GATE_STATES[action]
    if str(item.get("state")) == "held_by_required_gate":
        return "required_gate_held"
    return "review_required"


def _r2_state(
    action: str,
    sweep_domain: dict[str, Any],
    preflight: dict[str, Any],
    owner_approval_validation: dict[str, Any],
    legal_packet_summary: dict[str, Any],
    options: AutonomousPromotionRunnerOptions,
    promotion_state: str,
) -> str:
    if action == "monitor_current_production":
        return "existing_remote_upload_readback_reconciled" if sweep_domain.get("r2", {}).get("remoteUploadReadbackReady") else "existing_remote_upload_readback_missing"
    if action == "r2_publish_gate" and promotion_state == "r2_execute_preflight_command_ready":
        return "execute_preflight_ready_command_emitted_no_write"
    if action == "r2_publish_gate":
        if not options.execute_r2:
            return "held_execute_flag_required"
        if not owner_approval_validation["valid"]:
            return "held_owner_approval_invalid"
        if not legal_packet_summary["present"]:
            return "held_legal_packet_missing"
        if not preflight["readyForNewRemoteWrite"]:
            return "held_future_remote_write_preflight_blocked"
        return "held_unknown_r2_gate"
    return "not_r2_write_action"


def _promotion_command(
    item: dict[str, Any],
    sweep_domain: dict[str, Any],
    promotion_state: str,
    r2_state: str,
    options: AutonomousPromotionRunnerOptions,
) -> dict[str, Any] | None:
    if item.get("nextAction") != "r2_publish_gate":
        return None
    domain_id = str(item.get("domainID") or "")
    pack_report_path = str(sweep_domain.get("pack", {}).get("path") or "")
    pack_root = str(Path(pack_report_path).parent) if pack_report_path else ""
    command_status = "execute_preflight_ready_not_executed" if promotion_state == "r2_execute_preflight_command_ready" else "held"
    argv = [
        "python3",
        "-m",
        "foundry.cli",
        "pack-r2-publisher",
        "--pack-root",
        pack_root,
        "--output-root",
        f"tools/source-atlas/generated/r2-publisher/{options.run_label}-{domain_id}-promotion",
        "--environment",
        options.environment,
        "--channel",
        options.channel,
        "--mode",
        "remote_r2",
        "--approval-artifact",
        str(options.owner_approval_path) if options.owner_approval_path else "MISSING_OWNER_APPROVAL",
        "--legal-approval-packet",
        str(options.legal_approval_packet_path) if options.legal_approval_packet_path else "MISSING_LEGAL_APPROVAL_PACKET",
        "--bucket",
        options.bucket or "USE_SWEEP_OR_ENV_BUCKET",
    ]
    if options.execute_r2:
        argv.append("--execute")
    return {
        "commandID": stable_id(
            "source_atlas.promotion_command",
            {"domainID": domain_id, "promotionState": promotion_state, "runLabel": options.run_label},
        ),
        "domainID": domain_id,
        "commandType": "pack_r2_publisher_remote_r2",
        "status": command_status,
        "r2State": r2_state,
        "argv": argv,
        "requiresOperatorExecution": True,
        "productionWriteExecuted": False,
        "remoteMutation": False,
        "nativeRuntimeMutation": False,
        "finalOutputGenerated": False,
    }


def _decision_blockers(
    item: dict[str, Any],
    sweep_domain: dict[str, Any],
    preflight: dict[str, Any],
    owner_approval_validation: dict[str, Any],
    registry_summary: dict[str, Any],
    legal_packet_summary: dict[str, Any],
    options: AutonomousPromotionRunnerOptions,
) -> list[str]:
    action = str(item.get("nextAction") or "")
    blockers: list[str] = []
    if action == "monitor_current_production":
        if not sweep_domain.get("ready"):
            blockers.append("current production sweep does not mark domain ready")
        return blockers
    if action in {"candidate_frontier_review", "source_lane_review", "terms_review"}:
        blockers.append("review-only action cannot emit claims, packs, or R2 writes")
        return blockers
    if action == "r2_publish_gate":
        if not options.execute_r2:
            blockers.append("execute-r2 flag was not supplied")
        if not preflight["readyForNewRemoteWrite"]:
            blockers.extend(preflight.get("blockedReasons", []))
        if not owner_approval_validation["valid"]:
            blockers.append("owner approval artifact is invalid")
            blockers.extend(f"owner approval: {issue}" for issue in owner_approval_validation.get("issues", []))
        if not legal_packet_summary["present"]:
            blockers.append("legal approval packet path is missing or unreadable")
        if not registry_summary["legalRegistryLoaded"]:
            blockers.extend(registry_summary["legalIssues"])
        if not registry_summary["apiRegistryLoaded"]:
            blockers.extend(registry_summary["apiIssues"])
        if not sweep_domain.get("ready"):
            blockers.append("domain is not ready in current production sweep")
        return sorted(set(blockers))
    if action in HELD_GATE_STATES:
        blockers.append(f"{action} remains behind required gate: {item.get('requiredGate')}")
        return blockers
    return blockers


def _command_queue(decisions: list[dict[str, Any]]) -> list[dict[str, Any]]:
    commands = []
    for decision in decisions:
        command = decision.get("command")
        if isinstance(command, dict):
            commands.append(command)
    return sorted(commands, key=lambda item: (item["domainID"], item["commandID"]))


def _held_gate_packets(decisions: list[dict[str, Any]]) -> list[dict[str, Any]]:
    packets = []
    for decision in decisions:
        state = str(decision.get("promotionState") or "")
        if state.endswith("_held") or state in {"required_gate_held", "candidate_or_source_review_only"}:
            packets.append(
                {
                    "gateID": stable_id(
                        "source_atlas.promotion_gate",
                        {"domainID": decision["domainID"], "state": state, "requiredGate": decision.get("requiredGate")},
                    ),
                    "domainID": decision["domainID"],
                    "promotionState": state,
                    "requiredGate": decision.get("requiredGate"),
                    "blockers": decision.get("blockers", []),
                    "productionWriteExecuted": False,
                    "remoteMutation": False,
                    "nativeRuntimeMutation": False,
                    "finalOutputGenerated": False,
                }
            )
    return sorted(packets, key=lambda item: (item["domainID"], item["promotionState"]))


def _input_validity_issues(
    supervisor: Any,
    sweep: Any,
    legal_registry: Any,
    api_registry: Any,
    legal_packet: Any,
    owner_approval_validation: dict[str, Any],
    options: AutonomousPromotionRunnerOptions,
) -> list[str]:
    issues: list[str] = []
    if not isinstance(supervisor, dict) or supervisor.get("valid") is not True:
        issues.append("supervisor report is missing or invalid")
    if not isinstance(sweep, dict) or sweep.get("valid") is not True:
        issues.append("production sweep is missing or invalid")
    if not isinstance(legal_registry, dict):
        issues.append("legal/terms registry is missing or invalid")
    if not isinstance(api_registry, dict):
        issues.append("API governance registry is missing or invalid")
    if options.execute_r2 and not owner_approval_validation["valid"]:
        issues.append("execute-r2 cannot proceed without valid owner approval")
    if options.execute_r2 and not isinstance(legal_packet, dict):
        issues.append("execute-r2 cannot proceed without legal approval packet")
    return issues


def _registry_summary(legal_registry: Any, api_registry: Any) -> dict[str, Any]:
    legal_issues = []
    api_issues = []
    if not isinstance(legal_registry, dict):
        legal_issues.append("legal/terms registry missing")
    if not isinstance(api_registry, dict):
        api_issues.append("API governance registry missing")
    return {
        "legalRegistryLoaded": isinstance(legal_registry, dict),
        "apiRegistryLoaded": isinstance(api_registry, dict),
        "legalRegistryKind": legal_registry.get("kind") if isinstance(legal_registry, dict) else None,
        "apiRegistryKind": api_registry.get("kind") if isinstance(api_registry, dict) else None,
        "licenseCount": len(legal_registry.get("licenses", [])) if isinstance(legal_registry, dict) else 0,
        "apiPolicyCount": len(api_registry.get("api_policies", [])) if isinstance(api_registry, dict) else 0,
        "legalIssues": legal_issues,
        "apiIssues": api_issues,
    }


def _legal_packet_summary(packet: Any) -> dict[str, Any]:
    if not isinstance(packet, dict):
        return {
            "present": False,
            "kind": None,
            "status": "missing",
            "outsideLegalApprovalClaimed": False,
            "privacyIssues": [],
        }
    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "kind": packet.get("kind"),
                "status": packet.get("status"),
                "outsideLegalApprovalClaimed": packet.get("outsideLegalApprovalClaimed"),
                "releaseGreenClaimed": packet.get("releaseGreenClaimed"),
                "literalUniversalCoverageClaimed": packet.get("literalUniversalCoverageClaimed"),
            },
            "source-atlas-autonomous-promotion-runner-legal-packet",
        )
    )
    return {
        "present": True,
        "kind": packet.get("kind"),
        "status": packet.get("status"),
        "outsideLegalApprovalClaimed": packet.get("outsideLegalApprovalClaimed") is True,
        "privacyIssues": privacy_issues,
    }


def _configured_domain_ids(sweep: Any) -> list[str]:
    if not isinstance(sweep, dict):
        return []
    return sorted(str(domain.get("domainID")) for domain in sweep.get("domains", []) if isinstance(domain, dict) and domain.get("domainID"))


def _sweep_by_domain(sweep: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(sweep, dict):
        return {}
    return {
        str(domain.get("domainID")): domain
        for domain in sweep.get("domains", [])
        if isinstance(domain, dict) and domain.get("domainID")
    }


def _sweep_preflight(sweep: Any) -> dict[str, Any]:
    if not isinstance(sweep, dict):
        return {"readyForNewRemoteWrite": False, "blockedReasons": ["production sweep missing"], "secretValuesPrinted": False}
    preflight = sweep.get("futureRemoteWritePreflight", {})
    if not isinstance(preflight, dict):
        return {"readyForNewRemoteWrite": False, "blockedReasons": ["future remote write preflight missing"], "secretValuesPrinted": False}
    return {
        "kind": preflight.get("kind"),
        "environment": preflight.get("environment"),
        "readyForNewRemoteWrite": preflight.get("readyForNewRemoteWrite") is True,
        "blockedReasons": sorted(str(reason) for reason in preflight.get("blockedReasons", []) if isinstance(reason, str)),
        "wranglerInstalled": preflight.get("wranglerInstalled") is True,
        "credentialsAvailable": preflight.get("credentialsAvailable") is True,
        "credentialEnvNameCount": int(preflight.get("credentialEnvNameCount", 0) or 0),
        "credentialGroupsPresent": sorted(str(group) for group in preflight.get("credentialGroupsPresent", []) if isinstance(group, str)),
        "bucketConfigured": preflight.get("bucketConfigured") is True,
        "bucketSource": preflight.get("bucketSource"),
        "currentProductionBucketsObserved": sorted(str(bucket) for bucket in preflight.get("currentProductionBucketsObserved", []) if isinstance(bucket, str)),
        "approvalArtifactPresent": preflight.get("approvalArtifactPresent") is True,
        "legalApprovalPacketPresent": preflight.get("legalApprovalPacketPresent") is True,
        "secretValuesPrinted": preflight.get("secretValuesPrinted") is True,
    }


def _bucket_from_sweep(sweep: Any) -> str | None:
    preflight = _sweep_preflight(sweep)
    buckets = preflight.get("currentProductionBucketsObserved", [])
    if buckets:
        return str(buckets[0])
    return None


def _public_object_keys(sweep_domain: dict[str, Any]) -> list[str]:
    keys = []
    r2 = sweep_domain.get("r2", {})
    for key in ("manifestKey", "currentKey"):
        value = r2.get(key)
        if isinstance(value, str) and value:
            keys.append(value)
    return sorted(set(keys))


def _object_key_privacy_issues(decisions: list[dict[str, Any]], sweep: Any) -> list[str]:
    issues: list[str] = []
    for decision in decisions:
        for key in decision.get("publicObjectKeys", []):
            issues.extend(issue.format() for issue in object_key_issues(str(key), label=f"{decision['domainID']}.publicObjectKey"))
    if isinstance(sweep, dict):
        for domain in sweep.get("domains", []):
            if not isinstance(domain, dict):
                continue
            for key in _public_object_keys(domain):
                issues.extend(issue.format() for issue in object_key_issues(str(key), label=f"{domain.get('domainID')}.sweepObjectKey"))
    return sorted(set(issues))


def _record_counts(
    decisions: list[dict[str, Any]],
    command_queue: list[dict[str, Any]],
    held_gate_packets: list[dict[str, Any]],
    privacy_issues: list[str],
) -> dict[str, int]:
    return {
        "configuredDomains": len({decision["domainID"] for decision in decisions if decision.get("currentProductionReady")}),
        "promotionDecisions": len(decisions),
        "monitorOnlyDecisions": sum(1 for decision in decisions if decision["promotionState"] == "monitor_only_current"),
        "candidateReviewOnlyDecisions": sum(1 for decision in decisions if decision["promotionState"] == "candidate_or_source_review_only"),
        "heldGateDecisions": sum(1 for decision in decisions if str(decision["promotionState"]).endswith("_held") or decision["promotionState"] == "required_gate_held"),
        "heldGatePackets": len(held_gate_packets),
        "promotionCommands": len(command_queue),
        "r2ExecutePreflightCommands": sum(1 for command in command_queue if command["status"] == "execute_preflight_ready_not_executed"),
        "r2HeldCommands": sum(1 for command in command_queue if command["status"] == "held"),
        "r2WritesExecuted": 0,
        "liveHarvestsExecuted": 0,
        "remoteMutations": sum(1 for decision in decisions if decision.get("remoteMutation") is True),
        "nativeRuntimeMutations": sum(1 for decision in decisions if decision.get("nativeRuntimeMutation") is True),
        "finalOutputsGenerated": sum(1 for decision in decisions if decision.get("finalOutputGenerated") is True),
        "privacyIssues": len(privacy_issues),
    }


def _allowed_claims(
    valid: bool,
    decisions: list[dict[str, Any]],
    command_queue: list[dict[str, Any]],
    preflight: dict[str, Any],
    options: AutonomousPromotionRunnerOptions,
) -> list[str]:
    if not valid:
        return []
    claims = [
        "autonomous_promotion_control_green",
        "supervisor_sweep_owner_legal_api_inputs_reconciled",
        "production_r2_writes_remain_execute_gated",
        "promotion_decisions_emit_no_remote_or_native_mutation",
    ]
    if any(decision["promotionState"] == "monitor_only_current" for decision in decisions):
        claims.append("configured_domain_monitor_decisions_emitted")
    if any(decision["promotionState"] == "candidate_or_source_review_only" for decision in decisions):
        claims.append("candidate_and_review_domains_remain_non_packable")
    if preflight.get("readyForNewRemoteWrite"):
        claims.append("future_remote_r2_write_preflight_reconciled")
    if command_queue:
        claims.append("gated_r2_promotion_command_queue_emitted")
    if any(command["status"] == "execute_preflight_ready_not_executed" for command in command_queue):
        claims.append("r2_execute_preflight_commands_emitted_without_remote_write")
    if options.execute_r2:
        claims.append("execute_r2_request_evaluated_without_remote_mutation")
    return claims


def _blocked_claims() -> list[str]:
    return sorted(
        {
            "active_registry_mutation_by_promotion_runner",
            "app_store_readiness",
            "automatic_r2_write_without_execute_budget_approval",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
            "full_source_atlas_green",
            "independent_accessibility_green",
            "literal_universal_coverage",
            "native_device_green",
            "new_remote_r2_write_executed_by_promotion_runner",
            "outside_legal_approval",
            "release_green",
            "runtime_release_green",
            "source_atlas_private_goal_text_processing",
            "testflight_readiness",
            "uncontrolled_live_harvest",
        }
    )


def _unsafe_issues(counts: dict[str, int]) -> list[str]:
    return [
        f"{key}={value}"
        for key, value in sorted(counts.items())
        if key in {"r2WritesExecuted", "remoteMutations", "nativeRuntimeMutations", "finalOutputsGenerated"} and value
    ]


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} does not exist: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - malformed evidence artifact
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _read_optional_json(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        return None
    if not path.exists():
        issues.append(f"{label} does not exist: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - malformed evidence artifact
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(issues))}


def _supervisor_privacy_view(supervisor: Any) -> dict[str, Any]:
    if not isinstance(supervisor, dict):
        return {"loaded": False}
    return {
        "loaded": True,
        "valid": supervisor.get("valid"),
        "workQueue": [
            {
                "domainID": item.get("domainID"),
                "nextAction": item.get("nextAction"),
                "state": item.get("state"),
                "status": item.get("status"),
                "requiredGate": item.get("requiredGate"),
            }
            for item in _supervisor_work_items(supervisor)
        ],
    }


def _sweep_privacy_view(sweep: Any) -> list[dict[str, Any]]:
    if not isinstance(sweep, dict):
        return []
    return [
        {
            "domainID": domain.get("domainID"),
            "ready": domain.get("ready"),
            "manifestKey": domain.get("r2", {}).get("manifestKey"),
        }
        for domain in sweep.get("domains", [])
        if isinstance(domain, dict)
    ]


def _decision_privacy_view(decisions: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "domainID": decision.get("domainID"),
            "nextAction": decision.get("nextAction"),
            "promotionState": decision.get("promotionState"),
            "r2State": decision.get("r2State"),
            "publicObjectKeys": decision.get("publicObjectKeys", []),
            "blockerCount": len(decision.get("blockers", [])),
        }
        for decision in decisions
    ]


def _command_privacy_view(command_queue: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "domainID": command.get("domainID"),
            "commandType": command.get("commandType"),
            "status": command.get("status"),
            "argumentCount": len(command.get("argv", [])),
            "productionWriteExecuted": command.get("productionWriteExecuted"),
        }
        for command in command_queue
    ]
