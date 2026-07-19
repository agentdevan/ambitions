"""Launch-floor supervisor for governed missing-shard expansion.

This compiler audits the continuous expansion state for every durable
missing-shard event. It combines queue, review-gate, activation-executor, and
fallback-metric evidence into backlog, stale-event, resolution-rate, and
fallback-regression reports. It does not execute harvest, registry, R2, native,
or final-output work.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .missing_shard_review_gate import APPROVED_STATUS
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_MISSING_SHARD_EXPANSION_SUPERVISOR_KIND = "ambitions.sourceAtlas.missingShardExpansionSupervisor.v1"
SOURCE_ATLAS_MISSING_SHARD_EXPANSION_SUPERVISOR_VERSION = "source-atlas-missing-shard-expansion-supervisor-lff-m04-l04"

SUPERVISOR_STATES = (
    "monitor_only",
    "review_only",
    "approved_execute",
    "held",
    "blocked",
)

FORBIDDEN_SUPERVISOR_CLAIMS = {
    "active_registry_mutation",
    "source_atlas_launch_floor_ready",
    "launch_floor_complete",
    "release_green",
    "outside_legal_approval",
    "production_r2_write_complete",
    "native_activation_complete",
    "final_user_plans_schedules_steps_from_source_atlas_or_r2",
    "private_life_graph_in_source_atlas_or_r2",
}

MISSING_SHARD_EXPANSION_SUPERVISOR_NON_CLAIMS = [
    "missing-shard expansion supervision and audit reports only",
    "not harvest execution",
    "not active registry mutation",
    "not claim extraction proof",
    "not pack output proof",
    "not R2 publication or promotion proof",
    "not native activation proof",
    "not outside legal approval",
    "not launch-floor complete",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class MissingShardExpansionSupervisorOptions:
    missing_shard_queue_path: Path
    review_gate_path: Path
    activation_executor_path: Path
    fallback_metric_path: Path
    output_root: Path
    previous_fallback_metric_path: Path | None = None
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"
    as_of: str = "2026-07-01T00:00:00Z"


def compile_missing_shard_expansion_supervisor(options: MissingShardExpansionSupervisorOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    queue = _read_required(options.missing_shard_queue_path, "missing-shard queue", issues)
    review_gate = _read_required(options.review_gate_path, "missing-shard review gate", issues)
    activation_executor = _read_required(options.activation_executor_path, "missing-shard activation executor", issues)
    fallback_metric = _read_required(options.fallback_metric_path, "source-needed fallback metric", issues)
    previous_fallback_metric = _read_optional(options.previous_fallback_metric_path, issues)

    input_privacy_issues = privacy_findings_for_value(
        {
            "missingShardQueuePath": str(options.missing_shard_queue_path),
            "reviewGatePath": str(options.review_gate_path),
            "activationExecutorPath": str(options.activation_executor_path),
            "fallbackMetricPath": str(options.fallback_metric_path),
            "previousFallbackMetricPath": str(options.previous_fallback_metric_path) if options.previous_fallback_metric_path else "",
            "runLabel": options.run_label,
            "asOf": options.as_of,
        },
        "missing-shard-expansion-supervisor-input",
    )
    input_shape_issues = _input_shape_issues(queue, review_gate, activation_executor, fallback_metric)
    events = _queue_events(queue)
    gate_decisions = _gate_decisions_by_event(review_gate)
    activation_summary_by_event = _activation_summary_by_event(activation_executor)
    backlog_items = [
        _backlog_item(
            event,
            gate_decisions.get(str(event.get("eventID") or "")),
            activation_summary_by_event.get(str(event.get("eventID") or "")),
            as_of=options.as_of,
        )
        for event in events
    ]
    backlog_items = [item for item in backlog_items if item is not None]

    backlog_report = _backlog_report(backlog_items, options.as_of)
    stale_event_report = _stale_event_report(backlog_items, options.as_of)
    resolution_rate_report = _resolution_rate_report(backlog_items)
    fallback_regression_report = _fallback_regression_report(fallback_metric, previous_fallback_metric)
    supervisor_state_counts = _counts(backlog_items, "supervisorState")
    output_privacy_issues = privacy_findings_for_value(
        {
            "backlogItems": backlog_items,
            "backlogReport": backlog_report,
            "staleEventReport": stale_event_report,
            "resolutionRateReport": resolution_rate_report,
            "fallbackRegressionReport": fallback_regression_report,
        },
        "missing-shard-expansion-supervisor-output",
    )
    unsafe_counts = _unsafe_counts(activation_executor, backlog_items)
    record_counts = {
        "queueEvents": len(events),
        "supervisedEvents": len(backlog_items),
        "monitorOnlyEvents": supervisor_state_counts.get("monitor_only", 0),
        "reviewOnlyEvents": supervisor_state_counts.get("review_only", 0),
        "approvedExecuteEvents": supervisor_state_counts.get("approved_execute", 0),
        "heldEvents": supervisor_state_counts.get("held", 0),
        "blockedEvents": supervisor_state_counts.get("blocked", 0),
        "staleEvents": stale_event_report["staleEventCount"],
        "firstReviewOverdueEvents": stale_event_report["firstReviewOverdueEventCount"],
        "sourceLaneQueuedEvents": _gate_count(backlog_items, "sourceLaneState", "queued"),
        "sourceLaneApprovedEvents": _gate_count(backlog_items, "sourceLaneState", "approved"),
        "legalQueuedEvents": _gate_count(backlog_items, "legalState", "queued"),
        "legalApprovedEvents": _gate_count(backlog_items, "legalState", "approved"),
        "apiQueuedEvents": _gate_count(backlog_items, "apiState", "queued"),
        "apiApprovedEvents": _gate_count(backlog_items, "apiState", "approved"),
        "resolvedEvents": resolution_rate_report["resolvedEvents"],
        "unresolvedEvents": resolution_rate_report["unresolvedEvents"],
        "resolutionRateBps": resolution_rate_report["resolutionRateBps"],
        "fallbackMetricLawfulGoals": fallback_regression_report["currentDenominator"] or 0,
        "fallbackMetricSourceNeeded": fallback_regression_report["currentNumerator"] or 0,
        "fallbackMetricRateBps": fallback_regression_report["currentRateBps"] or 0,
        "fallbackMetricPreviousRateBps": fallback_regression_report["previousRateBps"] or 0,
        "fallbackMetricDeltaBps": fallback_regression_report["deltaBps"] or 0,
        "privacyIssues": len(input_privacy_issues) + len(output_privacy_issues),
        **unsafe_counts,
    }
    checks = _checks(
        issues=issues,
        input_shape_issues=input_shape_issues,
        input_privacy_issues=input_privacy_issues,
        output_privacy_issues=output_privacy_issues,
        record_counts=record_counts,
        backlog_items=backlog_items,
        fallback_regression_report=fallback_regression_report,
    )
    all_issues = sorted(set([*issues, *input_shape_issues, *input_privacy_issues, *output_privacy_issues]))
    valid = not all_issues and all(check["passed"] for check in checks)
    output_paths = {
        "report": str(output_root / "missing-shard-expansion-supervisor.json"),
        "backlog": str(output_root / "backlog-by-governance-state.json"),
        "staleEvents": str(output_root / "stale-event-report.json"),
        "resolutionAndFallbackRegression": str(output_root / "resolution-fallback-regression-report.json"),
        "closeout": str(output_root / "closeout.md"),
        "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
        "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
    }
    report = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_MISSING_SHARD_EXPANSION_SUPERVISOR_KIND,
        "versionID": SOURCE_ATLAS_MISSING_SHARD_EXPANSION_SUPERVISOR_VERSION,
        "createdAt": options.created_at,
        "asOf": options.as_of,
        "runLabel": options.run_label,
        "supervisorID": stable_id(
            "source_atlas.missing_shard_expansion_supervisor",
            {
                "missingShardQueuePath": str(options.missing_shard_queue_path),
                "reviewGatePath": str(options.review_gate_path),
                "activationExecutorPath": str(options.activation_executor_path),
                "fallbackMetricPath": str(options.fallback_metric_path),
                "previousFallbackMetricPath": str(options.previous_fallback_metric_path) if options.previous_fallback_metric_path else "",
                "recordCounts": record_counts,
            },
        ),
        "valid": valid,
        "status": "Source Green for missing-shard expansion supervisor" if valid else "Red: missing-shard expansion supervisor failed validation",
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; missing-shard supervision and regression audit only",
        "supervisorStates": list(SUPERVISOR_STATES),
        "recordCounts": record_counts,
        "backlogReport": backlog_report,
        "backlogItems": backlog_items,
        "staleEventReport": stale_event_report,
        "resolutionRateReport": resolution_rate_report,
        "fallbackRegressionReport": fallback_regression_report,
        "checks": checks,
        "issues": all_issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*input_privacy_issues, *output_privacy_issues])),
        "allowedClaims": _allowed_claims(valid, record_counts, fallback_regression_report),
        "blockedClaims": sorted(FORBIDDEN_SUPERVISOR_CLAIMS),
        "nonClaims": MISSING_SHARD_EXPANSION_SUPERVISOR_NON_CLAIMS,
        "evidencePaths": {
            "missingShardQueue": str(options.missing_shard_queue_path),
            "reviewGate": str(options.review_gate_path),
            "activationExecutor": str(options.activation_executor_path),
            "fallbackMetric": str(options.fallback_metric_path),
            "previousFallbackMetric": str(options.previous_fallback_metric_path) if options.previous_fallback_metric_path else None,
        },
        "outputPaths": output_paths,
    }
    write_json(output_root / "backlog-by-governance-state.json", backlog_report)
    write_json(output_root / "stale-event-report.json", stale_event_report)
    write_json(output_root / "resolution-fallback-regression-report.json", {
        "kind": "ambitions.sourceAtlas.missingShardResolutionFallbackRegressionReport.v1",
        "createdAt": options.created_at,
        "resolutionRateReport": resolution_rate_report,
        "fallbackRegressionReport": fallback_regression_report,
    })
    write_json(output_root / "missing-shard-expansion-supervisor.json", report)
    report["outputHashes"] = {
        "report": stable_hash(read_json(output_root / "missing-shard-expansion-supervisor.json")),
        "backlog": stable_hash(read_json(output_root / "backlog-by-governance-state.json")),
        "staleEvents": stable_hash(read_json(output_root / "stale-event-report.json")),
        "resolutionAndFallbackRegression": stable_hash(read_json(output_root / "resolution-fallback-regression-report.json")),
    }
    markdown = missing_shard_expansion_supervisor_markdown(report)
    report["outputHashes"]["markdownPayload"] = stable_hash(markdown)
    write_json(output_root / "missing-shard-expansion-supervisor.json", report)
    (output_root / "closeout.md").write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    return report


def missing_shard_expansion_supervisor_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    fallback = report["fallbackRegressionReport"]
    lines = [
        "# Source Atlas Missing-Shard Expansion Supervisor LFF-M04-L04",
        "",
        f"Status: {report['status']}",
        f"Valid: {str(report['valid']).lower()}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "## Current Proved Capability",
        "",
        f"- Supervised missing-shard events: {counts['supervisedEvents']}",
        f"- Monitor-only/review-only/approved-execute/held/blocked: {counts['monitorOnlyEvents']}/{counts['reviewOnlyEvents']}/{counts['approvedExecuteEvents']}/{counts['heldEvents']}/{counts['blockedEvents']}",
        f"- Stale events: {counts['staleEvents']}",
        f"- Resolved/unresolved events: {counts['resolvedEvents']}/{counts['unresolvedEvents']}",
        f"- Resolution rate bps: {counts['resolutionRateBps']}",
        f"- Fallback metric lawful/source-needed/rate bps: {counts['fallbackMetricLawfulGoals']}/{counts['fallbackMetricSourceNeeded']}/{counts['fallbackMetricRateBps']}",
        f"- Fallback regression status: {fallback['regressionStatus']}",
        f"- R2 writes/native activations/final outputs: {counts['r2WriteOperations']}/{counts['nativeActivationOperations']}/{counts['finalOutputArtifacts']}",
        "",
        "## Backlog",
        "",
        f"- Domain backlog entries: {len(report['backlogReport']['byDomain'])}",
        f"- Subdomain backlog entries: {len(report['backlogReport']['bySubdomain'])}",
        f"- Source-lane/legal/API combinations: {len(report['backlogReport']['bySourceLaneLegalApiState'])}",
        "",
        "## Checks",
        "",
    ]
    lines.extend(f"- `{check['name']}`: {'PASS' if check['passed'] else 'FAIL'}" for check in report["checks"])
    lines.extend(
        [
            "",
            "## Product Law Preserved",
            "",
            "- Supervisor inputs and outputs are public/reference queue IDs, domain/subdomain IDs, source-lane/legal/API states, proof paths, and aggregate rates.",
            "- No harvest, active registry mutation, R2 write, native activation, private runtime mutation, or final user output is executed.",
            "- Fallback and resolution rates are audit metrics only; they do not prove launch-floor completion by themselves.",
            "",
            "## Non-Claims",
            "",
        ]
    )
    lines.extend(f"- {claim}" for claim in report["nonClaims"])
    if report["issues"]:
        lines.extend(["", "## Issues", ""])
        lines.extend(f"- {issue}" for issue in report["issues"])
    return "\n".join(lines) + "\n"


def _backlog_item(event: dict[str, Any], gate_decision: dict[str, Any] | None, activation_summary: dict[str, Any] | None, *, as_of: str) -> dict[str, Any] | None:
    event_id = str(event.get("eventID") or "")
    if not event_id:
        return None
    review_gates = event.get("reviewGates") if isinstance(event.get("reviewGates"), dict) else {}
    gate_decisions = gate_decision.get("gateDecisions") if isinstance(gate_decision, dict) and isinstance(gate_decision.get("gateDecisions"), dict) else {}
    source_lane_state = str(gate_decisions.get("sourceLaneReview") or review_gates.get("sourceLaneReview") or "missing")
    legal_state = str(gate_decisions.get("legalTermsReview") or review_gates.get("legalTermsReview") or "missing")
    api_state = str(gate_decisions.get("apiPolicyReview") or review_gates.get("apiPolicyReview") or "missing")
    resolution = event.get("resolution") if isinstance(event.get("resolution"), dict) else {}
    sla = event.get("sla") if isinstance(event.get("sla"), dict) else {}
    stage_status_counts = activation_summary.get("stageStatusCounts") if isinstance(activation_summary, dict) else {}
    supervisor_state, reason = _supervisor_state(event, gate_decision, activation_summary, as_of)
    return {
        "eventID": event_id,
        "workItemID": event.get("workItemID"),
        "domainID": event.get("domainID"),
        "subdomainID": event.get("subdomainID"),
        "coverageLabel": event.get("coverageLabel"),
        "sourceNeededCause": event.get("sourceNeededCause"),
        "missingReasonClass": _path(event, "missingReason", "class"),
        "supervisorState": supervisor_state,
        "supervisorReason": reason,
        "sourceLaneState": source_lane_state,
        "legalState": legal_state,
        "apiState": api_state,
        "noPrivateDataState": str(gate_decisions.get("noPrivateDataScan") or review_gates.get("noPrivateDataScan") or "missing"),
        "gateStatus": gate_decision.get("gateStatus") if isinstance(gate_decision, dict) else "missing_review_gate_decision",
        "activationStageStatusCounts": dict(sorted((stage_status_counts or {}).items())),
        "resolutionState": str(resolution.get("resolutionState") or "unresolved"),
        "firstReviewDueAt": sla.get("firstReviewDueAt"),
        "sourceLaneReviewDueAt": sla.get("sourceLaneReviewDueAt"),
        "legalApiReviewDueAt": sla.get("legalApiReviewDueAt"),
        "staleIfUnresolvedAt": sla.get("staleIfUnresolvedAt"),
        "firstReviewOverdue": _is_due(sla.get("firstReviewDueAt"), as_of) and str(resolution.get("resolutionState") or "unresolved") == "unresolved",
        "stale": _is_due(sla.get("staleIfUnresolvedAt"), as_of) and str(resolution.get("resolutionState") or "unresolved") == "unresolved",
        "publicReferenceOnly": event.get("publicReferenceOnly") is True,
        "privateContextPresent": event.get("privateContextPresent") is True,
        "finalOutputAllowed": event.get("finalOutputAllowed") is True,
        "r2WritePerformed": bool(activation_summary.get("r2WritePerformed")) if isinstance(activation_summary, dict) else False,
        "nativeActivationPerformed": bool(activation_summary.get("nativeActivationPerformed")) if isinstance(activation_summary, dict) else False,
        "finalOutputGenerated": bool(activation_summary.get("finalOutputGenerated")) if isinstance(activation_summary, dict) else False,
    }


def _supervisor_state(event: dict[str, Any], gate_decision: dict[str, Any] | None, activation_summary: dict[str, Any] | None, as_of: str) -> tuple[str, str]:
    resolution = event.get("resolution") if isinstance(event.get("resolution"), dict) else {}
    if str(resolution.get("resolutionState") or "unresolved") != "unresolved":
        return "monitor_only", "event_has_resolution_artifact"
    if event.get("privateContextPresent") is True or event.get("finalOutputAllowed") is True:
        return "blocked", "event_breaks_source_atlas_privacy_or_final_output_law"
    stage_counts = activation_summary.get("stageStatusCounts") if isinstance(activation_summary, dict) else {}
    if stage_counts.get("execute_authorized", 0) or stage_counts.get("dry_run_ready", 0):
        return "approved_execute", "activation_stage_authorized_or_dry_run_ready"
    gate_status = str(gate_decision.get("gateStatus") if isinstance(gate_decision, dict) else "")
    if gate_status == APPROVED_STATUS:
        return "held", "review_gate_approved_but_activation_approval_or_execute_gate_still_required"
    if gate_status.startswith("blocked_pending"):
        return "review_only", "review_legal_api_approval_required"
    if _is_due(_path(event, "sla", "staleIfUnresolvedAt"), as_of):
        return "held", "unresolved_event_is_stale"
    if gate_status.startswith("blocked_invalid") or gate_status.startswith("rejected"):
        return "blocked", gate_status
    if gate_status:
        return "review_only", gate_status
    return "blocked", "missing_review_gate_decision"


def _backlog_report(backlog_items: list[dict[str, Any]], as_of: str) -> dict[str, Any]:
    return {
        "kind": "ambitions.sourceAtlas.missingShardBacklogByGovernanceState.v1",
        "asOf": as_of,
        "totalBacklogItems": len(backlog_items),
        "bySupervisorState": _counts(backlog_items, "supervisorState"),
        "byDomain": _grouped_backlog(backlog_items, "domainID"),
        "bySubdomain": _grouped_backlog(backlog_items, "subdomainID"),
        "bySourceLaneLegalApiState": _grouped_backlog(backlog_items, ("sourceLaneState", "legalState", "apiState")),
        "byMissingReasonClass": _counts(backlog_items, "missingReasonClass"),
    }


def _grouped_backlog(items: list[dict[str, Any]], key: str | tuple[str, ...]) -> list[dict[str, Any]]:
    groups: dict[str, list[dict[str, Any]]] = {}
    for item in items:
        if isinstance(key, tuple):
            value = "|".join(str(item.get(part) or "missing") for part in key)
        else:
            value = str(item.get(key) or "missing")
        groups.setdefault(value, []).append(item)
    rows = []
    for value, group in groups.items():
        rows.append(
            {
                "key": value,
                "count": len(group),
                "supervisorStates": _counts(group, "supervisorState"),
                "sourceLaneStates": _counts(group, "sourceLaneState"),
                "legalStates": _counts(group, "legalState"),
                "apiStates": _counts(group, "apiState"),
                "staleEvents": sum(1 for item in group if item.get("stale") is True),
            }
        )
    return sorted(rows, key=lambda row: (-row["count"], row["key"]))


def _stale_event_report(backlog_items: list[dict[str, Any]], as_of: str) -> dict[str, Any]:
    stale_events = [item for item in backlog_items if item.get("stale") is True]
    first_review_overdue = [item for item in backlog_items if item.get("firstReviewOverdue") is True]
    return {
        "kind": "ambitions.sourceAtlas.missingShardStaleEventReport.v1",
        "asOf": as_of,
        "staleEventCount": len(stale_events),
        "firstReviewOverdueEventCount": len(first_review_overdue),
        "staleEventIDs": sorted(str(item["eventID"]) for item in stale_events),
        "firstReviewOverdueEventIDs": sorted(str(item["eventID"]) for item in first_review_overdue),
        "byDomain": _grouped_backlog(stale_events, "domainID"),
        "bySourceLaneLegalApiState": _grouped_backlog(stale_events, ("sourceLaneState", "legalState", "apiState")),
    }


def _resolution_rate_report(backlog_items: list[dict[str, Any]]) -> dict[str, Any]:
    total = len(backlog_items)
    resolved = sum(1 for item in backlog_items if item.get("resolutionState") != "unresolved")
    rate = resolved / total if total else None
    return {
        "kind": "ambitions.sourceAtlas.missingShardResolutionRateReport.v1",
        "totalEvents": total,
        "resolvedEvents": resolved,
        "unresolvedEvents": total - resolved,
        "resolutionRate": rate,
        "resolutionRateBps": round((rate or 0.0) * 10_000, 4),
        "resolutionStates": _counts(backlog_items, "resolutionState"),
    }


def _fallback_regression_report(fallback_metric: Any, previous_fallback_metric: Any) -> dict[str, Any]:
    counts = fallback_metric.get("recordCounts") if isinstance(fallback_metric, dict) else {}
    current_numerator = _int(counts.get("sourceNeededFallbacks") or counts.get("sourceNeededFallbackNumerator"))
    current_denominator = _int(counts.get("lawfulGoals") or counts.get("lawfulGoalDenominator"))
    current_rate = _rate(current_numerator, current_denominator)
    previous_counts = previous_fallback_metric.get("recordCounts") if isinstance(previous_fallback_metric, dict) else {}
    previous_numerator = _int(previous_counts.get("sourceNeededFallbacks") or previous_counts.get("sourceNeededFallbackNumerator"))
    previous_denominator = _int(previous_counts.get("lawfulGoals") or previous_counts.get("lawfulGoalDenominator"))
    previous_rate = _rate(previous_numerator, previous_denominator)
    embedded_regression = fallback_metric.get("regression") if isinstance(fallback_metric, dict) and isinstance(fallback_metric.get("regression"), dict) else {}
    if previous_rate is None:
        previous_rate = embedded_regression.get("previousRate") if isinstance(embedded_regression.get("previousRate"), (int, float)) else None
    delta = current_rate - previous_rate if current_rate is not None and previous_rate is not None else None
    return {
        "kind": "ambitions.sourceAtlas.missingShardFallbackRegressionReport.v1",
        "goldenGauntletRerunPresent": bool(isinstance(fallback_metric, dict) and fallback_metric.get("valid") is True),
        "currentNumerator": current_numerator,
        "currentDenominator": current_denominator,
        "currentRate": current_rate,
        "currentRateBps": round((current_rate or 0.0) * 10_000, 4),
        "previousMetricPresent": isinstance(previous_fallback_metric, dict) or previous_rate is not None,
        "previousNumerator": previous_numerator,
        "previousDenominator": previous_denominator,
        "previousRate": previous_rate,
        "previousRateBps": round((previous_rate or 0.0) * 10_000, 4),
        "delta": delta,
        "deltaBps": round((delta or 0.0) * 10_000, 4),
        "regressionStatus": _regression_status(delta),
        "fallbackUnder5Percent": bool(current_rate is not None and current_rate < 0.05),
    }


def _checks(
    *,
    issues: list[str],
    input_shape_issues: list[str],
    input_privacy_issues: list[str],
    output_privacy_issues: list[str],
    record_counts: dict[str, Any],
    backlog_items: list[dict[str, Any]],
    fallback_regression_report: dict[str, Any],
) -> list[dict[str, Any]]:
    return [
        _check("inputs_loaded", not issues, issues),
        _check("input_shapes_valid", not input_shape_issues, input_shape_issues),
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check("output_privacy_scan_passed", not output_privacy_issues, output_privacy_issues),
        _check(
            "every_queue_event_supervised",
            record_counts["queueEvents"] == record_counts["supervisedEvents"] and record_counts["supervisedEvents"] > 0,
            [] if record_counts["queueEvents"] == record_counts["supervisedEvents"] and record_counts["supervisedEvents"] > 0 else ["not every queue event has a supervisor state"],
        ),
        _check(
            "all_required_supervisor_states_distinguished",
            all(state in record_counts for state in ("monitorOnlyEvents", "reviewOnlyEvents", "approvedExecuteEvents", "heldEvents", "blockedEvents")),
            [],
        ),
        _check(
            "backlog_has_governance_state",
            all(item.get("sourceLaneState") and item.get("legalState") and item.get("apiState") for item in backlog_items),
            [] if all(item.get("sourceLaneState") and item.get("legalState") and item.get("apiState") for item in backlog_items) else ["backlog item missing source/legal/API state"],
        ),
        _check(
            "unsafe_mutations_absent",
            record_counts["r2WriteOperations"] == 0
            and record_counts["nativeActivationOperations"] == 0
            and record_counts["activeRegistryMutations"] == 0
            and record_counts["finalOutputArtifacts"] == 0,
            _unsafe_issue_strings(record_counts),
        ),
        _check(
            "fallback_gauntlet_rerun_measured",
            fallback_regression_report["goldenGauntletRerunPresent"] and fallback_regression_report["currentDenominator"] is not None,
            [] if fallback_regression_report["goldenGauntletRerunPresent"] and fallback_regression_report["currentDenominator"] is not None else ["fallback metric rerun missing"],
        ),
    ]


def _allowed_claims(valid: bool, counts: dict[str, Any], fallback: dict[str, Any]) -> list[str]:
    if not valid:
        return []
    claims = [
        "missing_shard_expansion_supervisor_green",
        "every_current_missing_shard_event_supervised",
        "backlog_by_domain_subdomain_source_legal_api_state_emitted",
        "stale_event_report_emitted",
        "resolution_and_fallback_regression_report_emitted",
        "unsafe_mutations_remain_absent",
    ]
    if counts["reviewOnlyEvents"] > 0:
        claims.append("review_only_missing_shard_backlog_distinguished")
    if fallback["previousMetricPresent"]:
        claims.append("fallback_regression_compared_to_previous_metric")
    else:
        claims.append("fallback_regression_current_metric_measured_without_prior_claim")
    return claims


def _unsafe_counts(activation_executor: Any, backlog_items: list[dict[str, Any]]) -> dict[str, int]:
    counts = activation_executor.get("recordCounts") if isinstance(activation_executor, dict) and isinstance(activation_executor.get("recordCounts"), dict) else {}
    return {
        "activeRegistryMutations": _int(counts.get("activeRegistryMutations")) or 0,
        "r2WriteOperations": (_int(counts.get("r2WriteOperations")) or 0) + sum(1 for item in backlog_items if item.get("r2WritePerformed") is True),
        "nativeActivationOperations": (_int(counts.get("nativeActivationOperations")) or 0) + sum(1 for item in backlog_items if item.get("nativeActivationPerformed") is True),
        "finalOutputArtifacts": (_int(counts.get("finalOutputArtifacts")) or 0) + sum(1 for item in backlog_items if item.get("finalOutputGenerated") is True),
        "coverageCounterMutations": _int(counts.get("coverageCounterMutations")) or 0,
    }


def _unsafe_issue_strings(counts: dict[str, Any]) -> list[str]:
    issues = []
    for field in ("activeRegistryMutations", "r2WriteOperations", "nativeActivationOperations", "finalOutputArtifacts"):
        if counts.get(field):
            issues.append(f"{field} must remain zero in supervisor audit mode")
    return issues


def _input_shape_issues(queue: Any, review_gate: Any, activation_executor: Any, fallback_metric: Any) -> list[str]:
    issues: list[str] = []
    if not isinstance(queue, dict) or queue.get("kind") != "ambitions.sourceAtlas.missingShardEventQueue.v1" or queue.get("valid") is not True:
        issues.append("missing-shard queue must be a valid ambitions.sourceAtlas.missingShardEventQueue.v1 artifact")
    if not isinstance(review_gate, dict) or review_gate.get("kind") != "ambitions.sourceAtlas.missingShardReviewGate.v1" or review_gate.get("valid") is not True:
        issues.append("missing-shard review gate must be a valid ambitions.sourceAtlas.missingShardReviewGate.v1 artifact")
    if not isinstance(activation_executor, dict) or activation_executor.get("kind") != "ambitions.sourceAtlas.missingShardActivationExecutor.v1" or activation_executor.get("valid") is not True:
        issues.append("missing-shard activation executor must be a valid ambitions.sourceAtlas.missingShardActivationExecutor.v1 artifact")
    if not isinstance(fallback_metric, dict) or fallback_metric.get("kind") != "ambitions.sourceAtlas.sourceNeededFallbackMetric.v1" or fallback_metric.get("valid") is not True:
        issues.append("fallback metric must be a valid ambitions.sourceAtlas.sourceNeededFallbackMetric.v1 artifact")
    return issues


def _queue_events(queue: Any) -> list[dict[str, Any]]:
    if not isinstance(queue, dict) or not isinstance(queue.get("events"), list):
        return []
    return [event for event in queue["events"] if isinstance(event, dict)]


def _gate_decisions_by_event(review_gate: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(review_gate, dict) or not isinstance(review_gate.get("gateDecisions"), list):
        return {}
    return {
        str(item.get("eventID")): item
        for item in review_gate["gateDecisions"]
        if isinstance(item, dict) and item.get("eventID")
    }


def _activation_summary_by_event(activation_executor: Any) -> dict[str, dict[str, Any]]:
    summaries: dict[str, dict[str, Any]] = {}
    if not isinstance(activation_executor, dict) or not isinstance(activation_executor.get("stageDecisions"), list):
        return summaries
    for decision in activation_executor["stageDecisions"]:
        if not isinstance(decision, dict) or not decision.get("eventID"):
            continue
        event_id = str(decision["eventID"])
        summary = summaries.setdefault(
            event_id,
            {
                "stageStatusCounts": {},
                "r2WritePerformed": False,
                "nativeActivationPerformed": False,
                "finalOutputGenerated": False,
            },
        )
        status = str(decision.get("stageStatus") or "missing")
        summary["stageStatusCounts"][status] = summary["stageStatusCounts"].get(status, 0) + 1
        summary["r2WritePerformed"] = summary["r2WritePerformed"] or decision.get("r2WritePerformed") is True
        summary["nativeActivationPerformed"] = summary["nativeActivationPerformed"] or decision.get("nativeActivationPerformed") is True
        summary["finalOutputGenerated"] = summary["finalOutputGenerated"] or decision.get("finalOutputGenerated") is True
    return summaries


def _read_required(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing at {path}")
        return None
    return read_json(path)


def _read_optional(path: Path | None, issues: list[str]) -> Any:
    if path is None:
        return None
    if not path.exists():
        issues.append(f"optional previous fallback metric missing at {path}")
        return None
    return read_json(path)


def _counts(items: list[dict[str, Any]], field: str) -> dict[str, int]:
    counts: dict[str, int] = {}
    for item in items:
        value = str(item.get(field) or "missing")
        counts[value] = counts.get(value, 0) + 1
    return dict(sorted(counts.items()))


def _gate_count(items: list[dict[str, Any]], field: str, value: str) -> int:
    return sum(1 for item in items if item.get(field) == value)


def _path(value: Any, *parts: str) -> Any:
    current = value
    for part in parts:
        if not isinstance(current, dict):
            return None
        current = current.get(part)
    return current


def _parse_timestamp(value: Any) -> datetime | None:
    if not isinstance(value, str) or not value:
        return None
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(timezone.utc)


def _is_due(due_at: Any, as_of: str) -> bool:
    due = _parse_timestamp(due_at)
    current = _parse_timestamp(as_of)
    return bool(due and current and due <= current)


def _int(value: Any) -> int | None:
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, float):
        return int(value)
    if isinstance(value, str) and value.strip().isdigit():
        return int(value.strip())
    return None


def _rate(numerator: int | None, denominator: int | None) -> float | None:
    if numerator is None or denominator in {None, 0}:
        return None
    return numerator / denominator


def _regression_status(delta: float | None) -> str:
    if delta is None:
        return "no_previous_metric"
    if delta <= 0:
        return "improved_or_flat"
    if delta < 0.005:
        return "minor_increase_under_review_threshold"
    return "regressed_review_required"


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(issues))}
