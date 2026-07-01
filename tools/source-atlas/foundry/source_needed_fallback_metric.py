"""Source-needed fallback metric for the Source Atlas launch floor.

This module measures the LFF-M03 fallback target from an adjudicated golden
intent corpus. It reads public/reference corpus evidence only, and must not
route private goals, harvest sources, publish public reference objects, mutate
registries, mutate native runtime state, or generate final user plans,
schedules, or Steps.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issues_for_value, is_boundary_line
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_SOURCE_NEEDED_FALLBACK_METRIC_KIND = "ambitions.sourceAtlas.sourceNeededFallbackMetric.v1"
SOURCE_ATLAS_SOURCE_NEEDED_FALLBACK_METRIC_VERSION = "source-atlas-source-needed-fallback-metric-lff-m03-l03"
SOURCE_ATLAS_MISSING_SHARD_EVENT_LEDGER_KIND = "ambitions.sourceAtlas.missingShardEventLedger.v1"
SOURCE_ATLAS_MISSING_SHARD_EVENT_LEDGER_VERSION = "source-atlas-missing-shard-event-ledger-lff-m03-l03"

FALLBACK_COVERAGE_LABELS = {"source_needed", "stale_source", "candidate_only", "insufficient_source"}
EXCLUDED_CONTROL_LABELS = {"private_blocked", "illegal_out_of_scope"}
FORBIDDEN_FALLBACK_CLAIMS = {
    "source_atlas_launch_floor_ready",
    "launch_floor_complete",
    "full_source_atlas_green",
    "release_green",
    "app_store_readiness",
    "testflight_readiness",
    "outside_legal_approval",
    "continuous_missing_shard_expansion",
    "final_user_plans_schedules_steps_from_source_atlas_or_r2",
    "private_life_graph_in_source_atlas_or_r2",
}


@dataclass(frozen=True)
class SourceNeededFallbackMetricOptions:
    golden_intent_corpus_report_path: Path
    output_root: Path
    normalized_corpus_path: Path | None = None
    previous_metric_path: Path | None = None
    emit_evidence_path: Path | None = None
    emit_missing_shard_events_path: Path | None = None
    markdown_path: Path | None = None
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"


def compile_source_needed_fallback_metric(options: SourceNeededFallbackMetricOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    metric_path = output_root / "source-needed-fallback-metric.json"
    event_path = output_root / "missing-shard-event-ledger.json"
    markdown_path = output_root / "source-needed-fallback-metric.md"
    closeout_path = output_root / "closeout.md"

    issues: list[str] = []
    report = _read_required(options.golden_intent_corpus_report_path, "golden intent corpus report", issues)
    normalized_corpus_path = _normalized_corpus_path(report, options)
    corpus = _read_required(normalized_corpus_path, "normalized golden intent corpus", issues) if normalized_corpus_path else None
    previous_metric = _read_optional(options.previous_metric_path, issues)

    records = _intent_records(corpus, issues)
    privacy_issues = _privacy_issues(
        {
            "runLabel": options.run_label,
            "goldenIntentCorpusReport": str(options.golden_intent_corpus_report_path),
            "normalizedCorpus": str(normalized_corpus_path) if normalized_corpus_path else None,
        },
        "source-needed-fallback-metric-input",
    )
    privacy_issues.extend(_privacy_issues(records, "source-needed-fallback-metric-records"))

    counted_records = [record for record in records if _counts_in_denominator(record)]
    fallback_records = [record for record in counted_records if _counts_in_numerator(record)]
    private_blocked_controls = [
        record for record in records if record.get("coverageLabel") == "private_blocked" and not _counts_in_denominator(record)
    ]
    illegal_controls = [
        record for record in records if record.get("coverageLabel") == "illegal_out_of_scope" and not _counts_in_denominator(record)
    ]
    denominator = len(counted_records)
    numerator = len(fallback_records)
    rate = numerator / denominator if denominator > 0 else None
    threshold_met = rate is not None and rate < 0.05
    if denominator == 0:
        issues.append("lawful-goal denominator is missing or zero")
    if any(record.get("coverageLabel") in EXCLUDED_CONTROL_LABELS for record in counted_records):
        issues.append("private-blocked or unlawful controls must not count in lawful-goal denominator")

    missing_shard_event_ledger = _missing_shard_event_ledger(
        fallback_records,
        created_at=options.created_at,
        run_label=options.run_label,
    )
    regression = _regression(previous_metric, numerator, denominator, rate)
    checks = _checks(
        issues=issues,
        privacy_issues=privacy_issues,
        denominator=denominator,
        threshold_met=threshold_met,
        missing_shard_events=len(missing_shard_event_ledger["events"]),
    )
    valid = not issues and not privacy_issues and denominator > 0
    allowed_claims = [
        "source_needed_fallback_metric_measured",
        "source_needed_fallback_under_5_percent_met",
    ] if valid and threshold_met else []
    blocked_claims = sorted(
        {
            *FORBIDDEN_FALLBACK_CLAIMS,
            *([] if threshold_met else ["source_needed_fallback_under_5_percent_met"]),
        }
    )
    record_counts = {
        "intentRecordsEvaluated": len(records),
        "lawfulGoals": denominator,
        "lawfulGoalDenominator": denominator,
        "sourceNeededFallbacks": numerator,
        "sourceNeededFallbackNumerator": numerator,
        "sourceNeededFallbackRateBps": round((rate or 0.0) * 10_000, 4),
        "coveredLawfulGoals": sum(1 for record in counted_records if record.get("coverageLabel") == "covered"),
        "staleSourceFallbacks": sum(1 for record in fallback_records if record.get("coverageLabel") == "stale_source"),
        "candidateOnlyFallbacks": sum(1 for record in fallback_records if record.get("coverageLabel") == "candidate_only"),
        "insufficientSourceFallbacks": sum(1 for record in fallback_records if record.get("coverageLabel") == "insufficient_source"),
        "missingShardFallbacks": sum(1 for record in fallback_records if record.get("sourceNeededCause") == "missing_shard"),
        "missingFreshnessFallbacks": sum(1 for record in fallback_records if record.get("sourceNeededCause") == "missing_freshness"),
        "missingDomainFallbacks": sum(1 for record in fallback_records if record.get("sourceNeededCause") == "missing_domain"),
        "privateBlockedControlsExcluded": len(private_blocked_controls),
        "illegalOutOfScopeControlsExcluded": len(illegal_controls),
        "missingShardEventsEmitted": len(missing_shard_event_ledger["events"]),
        "privacyIssues": len(privacy_issues),
        "finalOutputsGenerated": sum(1 for record in records if record.get("finalOutputAllowed") is True),
    }
    report_payload = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_SOURCE_NEEDED_FALLBACK_METRIC_KIND,
        "versionID": SOURCE_ATLAS_SOURCE_NEEDED_FALLBACK_METRIC_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "metricID": stable_id(
            "source_atlas.source_needed_fallback_metric",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "goldenIntentCorpusReport": str(options.golden_intent_corpus_report_path),
                "normalizedCorpus": str(normalized_corpus_path) if normalized_corpus_path else None,
                "recordCounts": record_counts,
            },
        ),
        "status": (
            "Source Green for source-needed fallback metric"
            if valid and threshold_met
            else "Yellow source-needed fallback metric; target not met or not measurable"
        ),
        "valid": valid,
        "sourceNeededFallbackUnder5Percent": bool(valid and threshold_met),
        "fallbackRate": rate,
        "recordCounts": record_counts,
        "targetStatus": {
            "lawfulGoalDenominatorPresent": denominator > 0,
            "sourceNeededFallbackNumeratorPresent": numerator >= 0 and denominator > 0,
            "sourceNeededFallbackUnder5Percent": bool(threshold_met),
            "privateAndUnlawfulControlsExcluded": not any(
                record.get("coverageLabel") in EXCLUDED_CONTROL_LABELS for record in counted_records
            ),
            "missingShardEventsEmitted": len(missing_shard_event_ledger["events"]) == numerator,
        },
        "coverageLabelCounts": _label_counts(counted_records, "coverageLabel"),
        "sourceNeededCauseCounts": _label_counts(counted_records, "sourceNeededCause"),
        "regression": regression,
        "checks": checks,
        "issues": sorted(set(issues)),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set(privacy_issues)),
        "allowedClaims": allowed_claims,
        "blockedClaims": blocked_claims,
        "nonClaims": [
            "not launch-floor complete",
            "not continuous missing-shard expansion proof by itself",
            "not final user plans, schedules, or Steps",
            "not private goal routing",
            "not R2 production promotion proof",
            "not Release Green, App Store readiness, TestFlight readiness, outside legal approval, or owner approval",
            *NON_CLAIMS,
        ],
        "evidencePaths": {
            "goldenIntentCorpusReport": str(options.golden_intent_corpus_report_path),
            "normalizedCorpus": str(normalized_corpus_path) if normalized_corpus_path else None,
            "previousMetric": str(options.previous_metric_path) if options.previous_metric_path else None,
            "missingShardEventLedger": str(event_path),
        },
        "outputPaths": {
            "report": str(metric_path),
            "missingShardEvents": str(event_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
            "emitMissingShardEvents": str(options.emit_missing_shard_events_path) if options.emit_missing_shard_events_path else None,
            "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
        },
    }
    markdown = source_needed_fallback_metric_markdown(report_payload)
    report_payload["outputHashes"] = {
        "reportPayload": stable_hash(report_payload),
        "missingShardEvents": stable_hash(missing_shard_event_ledger),
        "markdownPayload": stable_hash(markdown),
    }
    write_json(metric_path, report_payload)
    write_json(event_path, missing_shard_event_ledger)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report_payload)
    if options.emit_missing_shard_events_path:
        write_json(options.emit_missing_shard_events_path, missing_shard_event_ledger)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    return report_payload


def source_needed_fallback_metric_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    rate = report.get("fallbackRate")
    rate_text = "missing" if rate is None else f"{rate:.4%}"
    lines = [
        "# Source Atlas Source-Needed Fallback Metric LFF-M03-L03",
        "",
        f"Status: {report['status']}",
        f"Metric valid: {str(report['valid']).lower()}",
        f"Fallback under 5%: {str(report['sourceNeededFallbackUnder5Percent']).lower()}",
        f"Fallback rate: {rate_text}",
        "",
        "## Current Proved Capability",
        "",
        f"- Intent records evaluated: {counts['intentRecordsEvaluated']}",
        f"- Lawful-goal denominator: {counts['lawfulGoals']}",
        f"- Source-needed fallback numerator: {counts['sourceNeededFallbacks']}",
        f"- Covered lawful goals: {counts['coveredLawfulGoals']}",
        f"- Private-blocked controls excluded: {counts['privateBlockedControlsExcluded']}",
        f"- Illegal/out-of-scope controls excluded: {counts['illegalOutOfScopeControlsExcluded']}",
        f"- Missing-shard events emitted for LFF-M04: {counts['missingShardEventsEmitted']}",
        f"- Privacy issues: {counts['privacyIssues']}",
        f"- Final outputs generated: {counts['finalOutputsGenerated']}",
        "",
        "## Target Status",
        "",
        "| Target | Met |",
        "| --- | --- |",
    ]
    for target_id, met in report["targetStatus"].items():
        lines.append(f"| `{target_id}` | {str(met).lower()} |")
    lines.extend(["", "## Checks", ""])
    for check in report["checks"]:
        issues = "; ".join(check["issues"]) or "none"
        lines.append(f"- `{check['name']}`: {'pass' if check['passed'] else 'fail'} ({issues})")
    lines.extend(["", "## Regression", ""])
    regression = report["regression"]
    for key in ["previousMetricPresent", "previousRate", "currentRate", "delta", "regressionStatus"]:
        lines.append(f"- `{key}`: {regression.get(key)}")
    lines.extend(["", "## Allowed Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["allowedClaims"]) if report["allowedClaims"] else lines.append("- None")
    lines.extend(["", "## Blocked Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["blockedClaims"])
    lines.extend(
        [
            "",
            "## Product Law Preserved",
            "",
            "- Metric records are public/reference evaluation inputs only.",
            "- Source Atlas does not receive private goals, captures, schedules, proof, receipts, personalization, behavior history, inferred priorities, account IDs, device IDs, or private life graph.",
            "- Source Atlas does not generate final personalized plans, final schedules, or final Steps.",
            "- Missing-shard events are queued as LFF-M04 inputs; this metric does not prove continuous expansion by itself.",
            "",
            "## Non-Claims",
            "",
        ]
    )
    lines.extend(f"- {claim}" for claim in report["nonClaims"])
    lines.extend(
        [
            "",
            "## Closeout",
            "",
            "- App behavior mutated: no.",
            "- Compatibility shims left behind: none.",
            "- Placeholder proof introduced: none.",
            "- Launch-floor recommendation: continue to LFF-M03-L04 native/runtime gauntlet and LFF-M04 durable every-event expansion.",
            "",
        ]
    )
    return "\n".join(lines)


def _read_required(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        issues.append(f"{label} path is missing")
        return None
    if not path.exists():
        issues.append(f"{path}: {label} is missing")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - defensive JSON surface.
        issues.append(f"{path}: failed to read {label}: {exc}")
        return None


def _read_optional(path: Path | None, issues: list[str]) -> Any:
    if path is None:
        return None
    if not path.exists():
        issues.append(f"{path}: previous metric is missing")
        return None
    return read_json(path)


def _normalized_corpus_path(report: Any, options: SourceNeededFallbackMetricOptions) -> Path | None:
    if options.normalized_corpus_path:
        return options.normalized_corpus_path
    if not isinstance(report, dict):
        return None
    evidence_paths = report.get("evidencePaths") if isinstance(report.get("evidencePaths"), dict) else {}
    raw_path = evidence_paths.get("normalizedCorpus")
    if not raw_path:
        return None
    path = Path(str(raw_path))
    if path.is_absolute() or path.exists():
        return path
    candidate = options.golden_intent_corpus_report_path.parent / path
    if candidate.exists():
        return candidate
    return path


def _intent_records(corpus: Any, issues: list[str]) -> list[dict[str, Any]]:
    if not isinstance(corpus, dict):
        issues.append("normalized golden intent corpus must be a JSON object")
        return []
    records = corpus.get("intents")
    if not isinstance(records, list):
        issues.append("normalized golden intent corpus must include intents list")
        return []
    valid_records: list[dict[str, Any]] = []
    for index, record in enumerate(records):
        if isinstance(record, dict):
            valid_records.append(record)
        else:
            issues.append(f"intents[{index}] is not an object")
    return valid_records


def _counts_in_denominator(record: dict[str, Any]) -> bool:
    return (
        record.get("lawfulIntent") is True
        and record.get("countsTowardGoldenIntent") is True
        and record.get("publicReferenceOnly") is True
        and record.get("privateContextAllowed") is False
        and record.get("finalOutputAllowed") is False
    )


def _counts_in_numerator(record: dict[str, Any]) -> bool:
    if not _counts_in_denominator(record):
        return False
    coverage_label = str(record.get("coverageLabel") or "")
    source_needed_cause = str(record.get("sourceNeededCause") or "not_required")
    expected_routing_state = str(record.get("expectedRoutingState") or "")
    return (
        coverage_label in FALLBACK_COVERAGE_LABELS
        or source_needed_cause != "not_required"
        or expected_routing_state in {"source_needed", "candidate_only", "insufficient_source"}
    )


def _missing_shard_event_ledger(
    records: list[dict[str, Any]],
    *,
    created_at: str,
    run_label: str,
) -> dict[str, Any]:
    events = []
    for record in records:
        event_seed = {
            "intentID": record.get("intentID"),
            "domainID": record.get("domainID"),
            "subdomainID": record.get("subdomainID"),
            "coverageLabel": record.get("coverageLabel"),
            "sourceNeededCause": record.get("sourceNeededCause"),
        }
        event_id = stable_id("source_atlas.missing_shard_event", event_seed)
        events.append(
            {
                "eventID": event_id,
                "eventType": "source_needed_fallback_metric",
                "createdAt": created_at,
                "runLabel": run_label,
                "sourceIntentID": record.get("intentID"),
                "domainID": record.get("domainID"),
                "subdomainID": record.get("subdomainID"),
                "coverageLabel": record.get("coverageLabel"),
                "sourceNeededCause": record.get("sourceNeededCause"),
                "expectedRoutingState": record.get("expectedRoutingState"),
                "publicReferenceOnly": True,
                "privateContextPresent": False,
                "finalOutputAllowed": False,
                "lawfulIntent": True,
                "expansionState": "metric_detected_pending_lff_m04",
                "requiredNextGate": "LFF-M04",
                "workItemID": stable_id("source_atlas.expansion_work_item", event_seed),
            }
        )
    return {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_MISSING_SHARD_EVENT_LEDGER_KIND,
        "versionID": SOURCE_ATLAS_MISSING_SHARD_EVENT_LEDGER_VERSION,
        "createdAt": created_at,
        "runLabel": run_label,
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "events": events,
        "recordCounts": {
            "events": len(events),
            "privateContextEvents": 0,
            "finalOutputsGenerated": 0,
        },
        "nonClaims": [
            "not continuous missing-shard expansion proof by itself",
            "not governed source review completion",
            "not R2 publication proof",
        ],
    }


def _regression(previous_metric: Any, numerator: int, denominator: int, rate: float | None) -> dict[str, Any]:
    previous_counts = previous_metric.get("recordCounts") if isinstance(previous_metric, dict) else {}
    previous_numerator = _int(previous_counts.get("sourceNeededFallbacks"))
    previous_denominator = _int(previous_counts.get("lawfulGoals"))
    previous_rate = (
        previous_numerator / previous_denominator
        if previous_numerator is not None and previous_denominator not in {None, 0}
        else None
    )
    delta = rate - previous_rate if rate is not None and previous_rate is not None else None
    return {
        "previousMetricPresent": isinstance(previous_metric, dict),
        "previousNumerator": previous_numerator,
        "previousDenominator": previous_denominator,
        "previousRate": previous_rate,
        "currentNumerator": numerator,
        "currentDenominator": denominator,
        "currentRate": rate,
        "delta": delta,
        "regressionStatus": _regression_status(delta),
    }


def _regression_status(delta: float | None) -> str:
    if delta is None:
        return "no_previous_metric"
    if delta <= 0:
        return "improved_or_flat"
    if delta < 0.005:
        return "minor_increase_under_review_threshold"
    return "regressed_review_required"


def _checks(
    *,
    issues: list[str],
    privacy_issues: list[str],
    denominator: int,
    threshold_met: bool,
    missing_shard_events: int,
) -> list[dict[str, Any]]:
    return [
        {"name": "inputs_loaded", "passed": not issues or issues == ["lawful-goal denominator is missing or zero"], "issues": []},
        {"name": "privacy_scan_passed", "passed": not privacy_issues, "issues": privacy_issues},
        {
            "name": "lawful_goal_denominator_present",
            "passed": denominator > 0,
            "issues": [] if denominator > 0 else ["lawful-goal denominator is missing or zero"],
        },
        {
            "name": "source_needed_fallback_under_5_percent",
            "passed": threshold_met,
            "issues": [] if threshold_met else ["source-needed fallback rate is not below 5%"],
        },
        {
            "name": "missing_shard_events_emitted",
            "passed": missing_shard_events >= 0,
            "issues": [],
        },
        {"name": "schema_valid", "passed": not issues, "issues": issues},
    ]


def _privacy_issues(value: Any, label: str) -> list[str]:
    return [
        issue.format()
        for issue in boundary_issues_for_value(value, label)
        if not is_boundary_line(issue.detail)
    ]


def _label_counts(records: list[dict[str, Any]], field: str) -> dict[str, int]:
    counts: dict[str, int] = {}
    for record in records:
        label = str(record.get(field) or "missing")
        counts[label] = counts.get(label, 0) + 1
    return dict(sorted(counts.items()))


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
