"""Durable missing-shard event queue for Source Atlas LFF-M04.

This compiler starts the governed expansion pipeline for metric-detected
source-needed fallbacks. It stores only public/reference queue metadata and
must not store private goals, captures, schedules, receipts, personalization,
behavior history, account/device identifiers, or private life graph data.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

from .boundary import boundary_issues_for_value, is_boundary_line
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_MISSING_SHARD_EVENT_QUEUE_KIND = "ambitions.sourceAtlas.missingShardEventQueue.v1"
SOURCE_ATLAS_MISSING_SHARD_EVENT_QUEUE_VERSION = "source-atlas-missing-shard-event-queue-lff-m04-l01"

ALLOWED_INPUT_EXPANSION_STATES = {"metric_detected_pending_lff_m04", "queued"}
FORBIDDEN_QUEUE_CLAIMS = {
    "source_atlas_launch_floor_ready",
    "launch_floor_complete",
    "full_source_atlas_green",
    "release_green",
    "app_store_readiness",
    "testflight_readiness",
    "outside_legal_approval",
    "final_user_plans_schedules_steps_from_source_atlas_or_r2",
    "private_life_graph_in_source_atlas_or_r2",
    "source_atlas_generates_final_personalized_plans",
    "source_atlas_generates_final_schedules",
    "source_atlas_generates_final_steps",
}


@dataclass(frozen=True)
class MissingShardEventQueueOptions:
    missing_shard_events_path: Path
    output_root: Path
    fallback_metric_path: Path | None = None
    previous_queue_path: Path | None = None
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"


def compile_missing_shard_event_queue(options: MissingShardEventQueueOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    report_path = output_root / "missing-shard-event-queue.json"
    markdown_path = output_root / "missing-shard-event-queue.md"
    closeout_path = output_root / "closeout.md"

    issues: list[str] = []
    event_ledger = _read_required(options.missing_shard_events_path, "missing-shard event ledger", issues)
    fallback_metric = _read_optional(options.fallback_metric_path, issues)
    previous_queue = _read_optional(options.previous_queue_path, issues)
    source_events = _source_events(event_ledger, issues)
    privacy_issues = _privacy_issues(
        {
            "runLabel": options.run_label,
            "missingShardEvents": str(options.missing_shard_events_path),
            "fallbackMetric": str(options.fallback_metric_path) if options.fallback_metric_path else None,
        },
        "missing-shard-event-queue-input",
    )
    privacy_issues.extend(_privacy_issues(source_events, "missing-shard-event-queue-source-events"))

    queue_items, duplicate_count = _queue_items(
        source_events,
        fallback_metric=fallback_metric,
        previous_queue=previous_queue,
        created_at=options.created_at,
        run_label=options.run_label,
        source_path=options.missing_shard_events_path,
        issues=issues,
    )
    privacy_issues.extend(_privacy_issues(queue_items, "missing-shard-event-queue-items"))

    durable_count = sum(1 for item in queue_items if item.get("expansionState") == "queued")
    valid = not issues and not privacy_issues and len(queue_items) == len({item["eventID"] for item in queue_items})
    valid = valid and durable_count == len(queue_items) and bool(queue_items)
    counts = {
        "sourceEvents": len(source_events),
        "queuedEvents": len(queue_items),
        "durableExpansionEvents": durable_count,
        "reconciledDuplicateEvents": duplicate_count,
        "eventsMissingRequiredFields": sum(1 for issue in issues if "missing required field" in issue),
        "privateContextEvents": sum(1 for event in source_events if event.get("privateContextPresent") is True),
        "finalOutputsGenerated": sum(1 for event in source_events if event.get("finalOutputAllowed") is True),
        "lawfulEvents": sum(1 for event in source_events if event.get("lawfulIntent") is True),
        "publicReferenceEvents": sum(1 for event in source_events if event.get("publicReferenceOnly") is True),
        "privacyIssues": len(privacy_issues),
    }
    report = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_MISSING_SHARD_EVENT_QUEUE_KIND,
        "versionID": SOURCE_ATLAS_MISSING_SHARD_EVENT_QUEUE_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "queueID": stable_id(
            "source_atlas.missing_shard_event_queue",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "missingShardEvents": str(options.missing_shard_events_path),
                "recordCounts": counts,
            },
        ),
        "status": "Source Green for durable missing-shard event queue" if valid else "Red: missing-shard queue failed validation",
        "valid": valid,
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "events": queue_items,
        "backlogReport": _backlog_report(queue_items, options.created_at),
        "lffM00Counters": {
            "missingShardEvents": len(queue_items),
            "missingShardEventsWithDurableExpansion": durable_count,
            "continuousMissingShardExpansionCounter": 1 if durable_count == len(queue_items) and queue_items else 0,
            "privateContextEvents": counts["privateContextEvents"],
            "finalOutputsGenerated": counts["finalOutputsGenerated"],
        },
        "recordCounts": counts,
        "checks": _checks(queue_items, issues, privacy_issues),
        "issues": sorted(set(issues)),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set(privacy_issues)),
        "allowedClaims": ["durable_missing_shard_event_queue_started"] if valid else [],
        "blockedClaims": sorted(FORBIDDEN_QUEUE_CLAIMS),
        "nonClaims": [
            "not launch-floor complete",
            "not source review approval",
            "not legal or API approval",
            "not harvest execution",
            "not R2 publication proof",
            "not native activation proof",
            "not final user plans, schedules, or Steps",
            "not private goal routing",
            *NON_CLAIMS,
        ],
        "evidencePaths": {
            "missingShardEvents": str(options.missing_shard_events_path),
            "fallbackMetric": str(options.fallback_metric_path) if options.fallback_metric_path else None,
            "previousQueue": str(options.previous_queue_path) if options.previous_queue_path else None,
        },
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
            "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
        },
    }
    markdown = missing_shard_event_queue_markdown(report)
    report["outputHashes"] = {
        "reportPayload": stable_hash(report),
        "markdownPayload": stable_hash(markdown),
    }
    write_json(report_path, report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    return report


def missing_shard_event_queue_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lff_m00 = report["lffM00Counters"]
    lines = [
        "# Source Atlas Missing-Shard Event Queue LFF-M04-L01",
        "",
        f"Status: {report['status']}",
        f"Queue valid: {str(report['valid']).lower()}",
        "",
        "## Current Proved Capability",
        "",
        f"- Source events read: {counts['sourceEvents']}",
        f"- Durable queued events: {counts['durableExpansionEvents']}",
        f"- Reconciled duplicate events: {counts['reconciledDuplicateEvents']}",
        f"- Private-context events: {counts['privateContextEvents']}",
        f"- Final outputs generated: {counts['finalOutputsGenerated']}",
        f"- Privacy issues: {counts['privacyIssues']}",
        "",
        "## LFF-M00 Counters",
        "",
        f"- Missing-shard events: {lff_m00['missingShardEvents']}",
        f"- Missing-shard events with durable expansion: {lff_m00['missingShardEventsWithDurableExpansion']}",
        f"- Continuous missing-shard expansion counter: {lff_m00['continuousMissingShardExpansionCounter']}",
        "",
        "## Backlog",
        "",
    ]
    backlog = report["backlogReport"]
    lines.append(f"- Total open queue items: {backlog['totalOpenItems']}")
    lines.append(f"- Queue states: {backlog['byExpansionState']}")
    lines.append(f"- Missing reason classes: {backlog['byMissingReasonClass']}")
    lines.extend(["", "## Checks", ""])
    for check in report["checks"]:
        lines.append(f"- `{check['name']}`: {'PASS' if check['passed'] else 'FAIL'}")
    lines.extend(["", "## Non-Claims", ""])
    for non_claim in report["nonClaims"]:
        lines.append(f"- {non_claim}")
    if report["issues"]:
        lines.extend(["", "## Issues", ""])
        for issue in report["issues"]:
            lines.append(f"- {issue}")
    return "\n".join(lines) + "\n"


def _queue_items(
    source_events: list[dict[str, Any]],
    *,
    fallback_metric: Any,
    previous_queue: Any,
    created_at: str,
    run_label: str,
    source_path: Path,
    issues: list[str],
) -> tuple[list[dict[str, Any]], int]:
    previous_by_event_id = _previous_items(previous_queue)
    items_by_event_id: dict[str, dict[str, Any]] = {}
    duplicate_count = 0
    for index, event in enumerate(source_events):
        required_missing = [
            field
            for field in ("eventID", "createdAt", "domainID", "subdomainID", "sourceIntentID", "sourceNeededCause")
            if not event.get(field)
        ]
        if required_missing:
            issues.append(f"event[{index}] missing required field(s): {', '.join(required_missing)}")
            continue
        if event.get("publicReferenceOnly") is not True:
            issues.append(f"{event['eventID']} is not public/reference-only")
            continue
        if event.get("privateContextPresent") is True:
            issues.append(f"{event['eventID']} carries private context")
            continue
        if event.get("finalOutputAllowed") is True:
            issues.append(f"{event['eventID']} allows final output")
            continue
        if event.get("lawfulIntent") is not True:
            issues.append(f"{event['eventID']} is not a lawful missing-shard event")
            continue
        expansion_state = str(event.get("expansionState") or "")
        if expansion_state not in ALLOWED_INPUT_EXPANSION_STATES:
            issues.append(f"{event['eventID']} has unsupported input expansion state {expansion_state}")
            continue
        if event["eventID"] in items_by_event_id:
            duplicate_count += 1
            continue

        previous_item = previous_by_event_id.get(str(event["eventID"]))
        source_needed_cause = str(event.get("sourceNeededCause") or "unknown")
        coverage_label = str(event.get("coverageLabel") or "source_needed")
        missing_reason = _missing_reason(source_needed_cause, coverage_label)
        work_item_seed = {
            "eventID": event["eventID"],
            "sourceIntentID": event["sourceIntentID"],
            "domainID": event["domainID"],
            "subdomainID": event["subdomainID"],
            "sourceNeededCause": source_needed_cause,
        }
        work_item_id = str(event.get("workItemID") or stable_id("source_atlas.expansion_work_item", work_item_seed))
        items_by_event_id[str(event["eventID"])] = {
            "eventID": event["eventID"],
            "queueItemID": stable_id("source_atlas.missing_shard_queue_item", work_item_seed),
            "workItemID": work_item_id,
            "eventType": "durable_missing_shard_expansion_queue",
            "createdAt": created_at,
            "detectedAt": event.get("createdAt"),
            "runLabel": run_label,
            "domainID": event["domainID"],
            "subdomainID": event["subdomainID"],
            "sourceIntentID": event["sourceIntentID"],
            "sanitizedIntentClass": event.get("sanitizedIntentClass"),
            "coverageLabel": coverage_label,
            "sourceNeededCause": source_needed_cause,
            "expectedRoutingState": event.get("expectedRoutingState"),
            "publicReferenceOnly": True,
            "privateContextPresent": False,
            "privateContextAllowed": False,
            "finalOutputAllowed": False,
            "lawfulIntent": True,
            "expansionState": "queued",
            "candidateState": "candidate_only_until_approved",
            "approvalState": previous_item.get("approvalState", "not_reviewed") if previous_item else "not_reviewed",
            "requiredNextGate": "LFF-M04-L02",
            "nextIssue": "AMB-1626",
            "sourceAuditProvenance": {
                "missingShardEventLedgerPath": str(source_path),
                "fallbackMetricPath": _fallback_metric_path(fallback_metric),
                "fallbackMetricID": fallback_metric.get("metricID") if isinstance(fallback_metric, dict) else None,
                "fallbackMetricRunLabel": fallback_metric.get("runLabel") if isinstance(fallback_metric, dict) else run_label,
                "sourceEventID": event["eventID"],
                "sourceEventHash": stable_hash(event),
            },
            "missingReason": missing_reason,
            "reviewGates": {
                "publicReferenceClassification": "passed",
                "sourceLaneReview": "queued",
                "legalTermsReview": "queued",
                "apiPolicyReview": "queued",
                "noPrivateDataScan": "passed",
                "ownerApproval": "not_required_for_queue",
            },
            "sla": _sla(created_at, missing_reason["class"]),
            "resolution": {
                "resolutionState": "unresolved",
                "resolutionEventID": previous_item.get("resolution", {}).get("resolutionEventID") if previous_item else None,
                "resolutionArtifactPath": previous_item.get("resolution", {}).get("resolutionArtifactPath") if previous_item else None,
                "eventualResolutionRequiredBeforeLaunch": True,
            },
        }
    return list(items_by_event_id.values()), duplicate_count


def _source_events(event_ledger: Any, issues: list[str]) -> list[dict[str, Any]]:
    if not isinstance(event_ledger, dict):
        issues.append("missing-shard event ledger is not an object")
        return []
    events = event_ledger.get("events") or event_ledger.get("missingShardEvents") or []
    if not isinstance(events, list):
        issues.append("missing-shard event ledger events are not a list")
        return []
    return [event for event in events if isinstance(event, dict)]


def _missing_reason(source_needed_cause: str, coverage_label: str) -> dict[str, str]:
    if source_needed_cause == "missing_shard":
        reason_class = "missing_corpus_shard"
    elif source_needed_cause == "missing_freshness":
        reason_class = "missing_freshness_review"
    elif source_needed_cause == "missing_domain":
        reason_class = "missing_domain_or_subdomain_source_lane"
    elif source_needed_cause == "insufficient_public_source":
        reason_class = "insufficient_public_source"
    else:
        reason_class = source_needed_cause or coverage_label
    return {
        "class": reason_class,
        "source": "queued",
        "corpus": "queued",
        "review": "queued",
        "legal": "queued",
        "api": "queued",
    }


def _sla(created_at: str, reason_class: str) -> dict[str, str]:
    created = _parse_timestamp(created_at)
    first_review_days = 7 if reason_class in {"missing_corpus_shard", "missing_domain_or_subdomain_source_lane"} else 14
    return {
        "queuedAt": created_at,
        "firstReviewDueAt": _format_timestamp(created + timedelta(days=first_review_days)),
        "sourceLaneReviewDueAt": _format_timestamp(created + timedelta(days=14)),
        "legalApiReviewDueAt": _format_timestamp(created + timedelta(days=21)),
        "staleIfUnresolvedAt": _format_timestamp(created + timedelta(days=30)),
    }


def _backlog_report(queue_items: list[dict[str, Any]], created_at: str) -> dict[str, Any]:
    return {
        "createdAt": created_at,
        "totalOpenItems": len(queue_items),
        "byExpansionState": _counts(queue_items, "expansionState"),
        "byCandidateState": _counts(queue_items, "candidateState"),
        "byApprovalState": _counts(queue_items, "approvalState"),
        "byCoverageLabel": _counts(queue_items, "coverageLabel"),
        "bySourceNeededCause": _counts(queue_items, "sourceNeededCause"),
        "byMissingReasonClass": _counts_nested(queue_items, ("missingReason", "class")),
        "topDomains": _top_counts(queue_items, "domainID", limit=20),
        "topSubdomains": _top_counts(queue_items, "subdomainID", limit=20),
        "oldestQueuedAt": min((str(item.get("createdAt")) for item in queue_items), default=None),
    }


def _checks(queue_items: list[dict[str, Any]], issues: list[str], privacy_issues: list[str]) -> list[dict[str, Any]]:
    return [
        {
            "name": "queue_items_present",
            "passed": bool(queue_items),
            "severity": "red",
            "issues": [] if queue_items else ["no queue items emitted"],
        },
        {
            "name": "every_queue_item_durable",
            "passed": all(item.get("expansionState") == "queued" and item.get("workItemID") for item in queue_items),
            "severity": "red",
            "issues": [] if all(item.get("expansionState") == "queued" and item.get("workItemID") for item in queue_items) else ["non-durable queue item"],
        },
        {
            "name": "public_reference_boundary",
            "passed": not privacy_issues and all(item.get("publicReferenceOnly") is True and item.get("privateContextPresent") is False for item in queue_items),
            "severity": "red",
            "issues": privacy_issues,
        },
        {
            "name": "no_final_outputs",
            "passed": all(item.get("finalOutputAllowed") is False for item in queue_items),
            "severity": "red",
            "issues": [] if all(item.get("finalOutputAllowed") is False for item in queue_items) else ["queue item allows final output"],
        },
        {
            "name": "required_schema_fields",
            "passed": not issues,
            "severity": "red",
            "issues": issues,
        },
    ]


def _previous_items(previous_queue: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(previous_queue, dict):
        return {}
    events = previous_queue.get("events")
    if not isinstance(events, list):
        return {}
    return {str(event.get("eventID")): event for event in events if isinstance(event, dict) and event.get("eventID")}


def _fallback_metric_path(fallback_metric: Any) -> str | None:
    if not isinstance(fallback_metric, dict):
        return None
    paths = fallback_metric.get("outputPaths")
    if isinstance(paths, dict):
        return paths.get("emitEvidence") or paths.get("report")
    return None


def _read_required(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing at {path}")
        return None
    return read_json(path)


def _read_optional(path: Path | None, issues: list[str]) -> Any:
    if path is None:
        return None
    if not path.exists():
        issues.append(f"optional input missing at {path}")
        return None
    return read_json(path)


def _privacy_issues(value: Any, context: str) -> list[str]:
    return [
        issue.format()
        for issue in boundary_issues_for_value(value, context)
        if not is_boundary_line(issue.detail)
    ]


def _counts(items: list[dict[str, Any]], field: str) -> dict[str, int]:
    counts: dict[str, int] = {}
    for item in items:
        value = str(item.get(field) or "missing")
        counts[value] = counts.get(value, 0) + 1
    return dict(sorted(counts.items()))


def _counts_nested(items: list[dict[str, Any]], path: tuple[str, str]) -> dict[str, int]:
    outer, inner = path
    counts: dict[str, int] = {}
    for item in items:
        outer_value = item.get(outer)
        value = str(outer_value.get(inner) if isinstance(outer_value, dict) else "missing")
        counts[value] = counts.get(value, 0) + 1
    return dict(sorted(counts.items()))


def _top_counts(items: list[dict[str, Any]], field: str, *, limit: int) -> list[dict[str, Any]]:
    counts = _counts(items, field)
    ordered = sorted(counts.items(), key=lambda pair: (-pair[1], pair[0]))
    return [{"value": value, "count": count} for value, count in ordered[:limit]]


def _parse_timestamp(value: str) -> datetime:
    normalized = value.replace("Z", "+00:00")
    try:
        parsed = datetime.fromisoformat(normalized)
    except ValueError:
        parsed = datetime(2026, 7, 1, tzinfo=timezone.utc)
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(timezone.utc)


def _format_timestamp(value: datetime) -> str:
    return value.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
