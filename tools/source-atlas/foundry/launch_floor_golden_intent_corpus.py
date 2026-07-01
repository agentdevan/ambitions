"""Launch-floor golden intent corpus contract for Source Atlas.

The corpus is public/reference evaluation infrastructure. It stores lawful
representative intent text or sanitized intent classes only; it is not a
private-goal store, planner, scheduler, Step generator, or runtime
personalization source.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

from .boundary import boundary_issue_strings, boundary_issues_for_value, is_boundary_line
from .launch_floor_domain_taxonomy import launch_floor_domain_taxonomy_summary
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_KIND = (
    "ambitions.sourceAtlas.launchFloorGoldenIntentCorpus.v1"
)
SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_REPORT_KIND = (
    "ambitions.sourceAtlas.launchFloorGoldenIntentCorpusReport.v1"
)
SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_VERSION = (
    "source-atlas-launch-floor-golden-intent-corpus-lff-m03-l02"
)

EXPECTED_ROUTING_STATES = {
    "current_configured_public_reference_runtime",
    "launch_floor_public_reference_supported",
    "candidate_only",
    "source_needed",
    "private_blocked",
    "unlawful_out_of_scope",
    "insufficient_source",
}

COVERAGE_LABELS = {
    "covered",
    "source_needed",
    "stale_source",
    "candidate_only",
    "private_blocked",
    "illegal_out_of_scope",
    "insufficient_source",
}

SOURCE_NEEDED_CAUSES = {
    "not_required",
    "missing_shard",
    "missing_source_lane",
    "missing_legal_review",
    "missing_api_policy",
    "missing_freshness",
    "missing_domain",
    "insufficient_public_source",
    "no_lawful_public_reference",
    "unknown",
}

ADJUDICATION_STATUSES = {"adjudicated", "review_required", "rejected"}
REVIEWER_TYPES = {"human", "foundry_importer", "deterministic_rule", "external_review_packet"}
NEGATIVE_OR_EXCLUDED_LABELS = {"private_blocked", "illegal_out_of_scope"}
FINAL_OUTPUT_FIELDS = {
    "finalPlan",
    "finalSchedule",
    "finalStep",
    "stepList",
    "personalizedPlan",
    "privateRuntimePath",
}

LAUNCH_FLOOR_GOLDEN_INTENT_NON_CLAIMS = [
    "not a private goal corpus",
    "not private life graph storage",
    "not private capture, schedule, proof, receipt, personalization, behavior history, account ID, or device ID storage",
    "not a planner, scheduler, Step generator, or final personalized output engine",
    "not proof of <5% source-needed fallback by itself",
    "not proof of continuous missing-shard expansion by itself",
    "not R2 production promotion proof",
    "not Release Green, App Store readiness, TestFlight readiness, outside legal approval, or owner approval",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class LaunchFloorGoldenIntentCorpusOptions:
    input_paths: tuple[Path, ...]
    output_root: Path
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"
    input_format: str = "auto"
    source_lane_registry_path: Path | None = None
    production_target_ledger_path: Path | None = None
    target_count: int = 50_000
    intents_per_subdomain: int = 10
    control_records_per_domain: int = 2
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None


def compile_launch_floor_golden_intent_corpus(
    options: LaunchFloorGoldenIntentCorpusOptions,
) -> dict[str, Any]:
    """Import, normalize, validate, and write launch-floor corpus evidence."""

    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    input_issues: list[str] = []
    imported_records: list[dict[str, Any]] = []
    source_summaries: list[dict[str, Any]] = []
    for input_path in options.input_paths:
        payload = _read_input(input_path, input_issues)
        if payload is None:
            continue
        records, summary, issues = _records_from_payload(payload, input_path, options)
        imported_records.extend(records)
        source_summaries.append(summary)
        input_issues.extend(issues)

    normalized_records, normalization_issues = _normalize_records(imported_records, options.created_at)
    summary = launch_floor_golden_intent_corpus_summary(
        {
            "schemaVersion": 1,
            "kind": SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_KIND,
            "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_VERSION,
            "createdAt": options.created_at,
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "finalOutputAllowed": False,
            "intents": normalized_records,
            "nonClaims": LAUNCH_FLOOR_GOLDEN_INTENT_NON_CLAIMS,
        }
    )
    input_privacy_issues = _privacy_issues(
        {
            "inputPaths": [str(path) for path in options.input_paths],
            "runLabel": options.run_label,
            "inputFormat": options.input_format,
        },
        "source-atlas-launch-floor-golden-intent-input",
    )
    artifact_privacy_issues = _privacy_issues(
        {
            "sourceSummaries": source_summaries,
            "intents": normalized_records,
            "nonClaims": LAUNCH_FLOOR_GOLDEN_INTENT_NON_CLAIMS,
        },
        "source-atlas-launch-floor-golden-intent-corpus",
    )
    issues = sorted(
        set(
            [
                *input_issues,
                *normalization_issues,
                *summary["issues"],
                *input_privacy_issues,
                *artifact_privacy_issues,
            ]
        )
    )

    normalized_corpus_path = output_root / "launch-floor-golden-intent-corpus.json"
    adjudication_ledger_path = output_root / "launch-floor-golden-intent-adjudication-ledger.json"
    report_path = output_root / "launch-floor-golden-intent-corpus-report.json"
    markdown_path = output_root / "launch-floor-golden-intent-corpus-report.md"
    closeout_path = output_root / "closeout.md"

    normalized_corpus = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_KIND,
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "intents": normalized_records,
        "recordCounts": summary["recordCounts"],
        "nonClaims": LAUNCH_FLOOR_GOLDEN_INTENT_NON_CLAIMS,
    }
    adjudication_ledger = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorGoldenIntentAdjudicationLedger.v1",
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_VERSION,
        "createdAt": options.created_at,
        "records": [
            {
                "intentID": record["intentID"],
                "adjudication": record["adjudication"],
                "adjudicationFingerprint": record["adjudicationFingerprint"],
                "sourceArtifact": record["adjudication"]["sourceArtifact"],
                "coverageLabel": record["coverageLabel"],
                "sourceNeededCause": record["sourceNeededCause"],
                "countsTowardGoldenIntent": record["countsTowardGoldenIntent"],
            }
            for record in normalized_records
        ],
        "nonClaims": [
            "adjudication ledger is review provenance only",
            "not private proof, receipts, schedules, captures, personalization, or private life graph",
            "not final user plans, schedules, or Steps",
        ],
    }
    write_json(normalized_corpus_path, normalized_corpus)
    write_json(adjudication_ledger_path, adjudication_ledger)

    valid = not issues
    launch_floor_target_met = valid and summary["launchFloorTargets"]["goldenIntents50000"]
    report = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_REPORT_KIND,
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "corpusReportID": stable_id(
            "source_atlas.launch_floor_golden_intent_corpus",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "inputHashes": [stable_hash(_safe_read_for_hash(path)) for path in options.input_paths],
                "recordCounts": summary["recordCounts"],
            },
        ),
        "status": "Source Green for golden-intent corpus contract" if valid else "Red",
        "valid": valid,
        "launchFloorGoldenIntentTargetMet": launch_floor_target_met,
        "sourceAtlasStatusCeiling": (
            "Yellow overall Source Atlas; golden-intent corpus is measured but launch-floor target is not met"
            if valid and not launch_floor_target_met
            else "Launch-floor golden-intent target met"
            if launch_floor_target_met
            else "Red; golden-intent corpus contract failed"
        ),
        "overallReadinessStatus": (
            "golden_intent_target_met" if launch_floor_target_met else "golden_intent_target_not_met"
        ),
        "recordCounts": summary["recordCounts"],
        "targetStatus": summary["launchFloorTargets"],
        "balance": summary["balance"],
        "counterContract": _counter_contract(),
        "checks": _checks(summary, input_issues, input_privacy_issues, artifact_privacy_issues),
        "issues": issues,
        "privacyIssues": sorted(set([*input_privacy_issues, *artifact_privacy_issues])),
        "sourceSummaries": source_summaries,
        "coverageLabelCounts": summary["coverageLabelCounts"],
        "expectedRoutingStateCounts": summary["expectedRoutingStateCounts"],
        "sourceNeededCauseCounts": summary["sourceNeededCauseCounts"],
        "allowedClaims": _allowed_claims(valid, launch_floor_target_met),
        "blockedClaims": _blocked_claims(launch_floor_target_met),
        "productLaw": {
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "localOnlySensitiveRuntimeStateAllowed": False,
            "accountOrDeviceIdentifiersAllowed": False,
            "finalOutputAllowed": False,
            "sourceAtlasGeneratesFinalPlansSchedulesSteps": False,
            "localRuntimeOwnsPathing": True,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": LAUNCH_FLOOR_GOLDEN_INTENT_NON_CLAIMS,
        "evidencePaths": {
            "inputs": [str(path) for path in options.input_paths],
            "normalizedCorpus": str(normalized_corpus_path),
            "adjudicationLedger": str(adjudication_ledger_path),
        },
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "normalizedCorpus": str(normalized_corpus_path),
            "adjudicationLedger": str(adjudication_ledger_path),
            "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
            "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
        },
    }
    report["outputHashes"] = {
        "normalizedCorpus": stable_hash(read_json(normalized_corpus_path)),
        "adjudicationLedger": stable_hash(read_json(adjudication_ledger_path)),
        "reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"}),
    }
    markdown = launch_floor_golden_intent_corpus_markdown(report)
    report["outputHashes"]["markdownPayload"] = stable_hash(markdown)
    write_json(report_path, report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    return report


def launch_floor_golden_intent_corpus_summary(corpus: Any) -> dict[str, Any]:
    """Return fail-closed counters for a corpus or generated corpus report."""

    if not isinstance(corpus, dict):
        return _empty_summary(["golden intent corpus must be a JSON object"])
    if corpus.get("kind") == SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_REPORT_KIND:
        return _summary_from_report(corpus)
    if corpus.get("kind") != SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_KIND:
        return _empty_summary(
            [
                "golden intent corpus kind must be "
                f"{SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_KIND} or "
                f"{SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_REPORT_KIND}"
            ]
        )

    issues: list[str] = []
    if corpus.get("publicReferenceOnly") is not True:
        issues.append("golden intent corpus must declare publicReferenceOnly true")
    if corpus.get("privateContextAllowed") is not False:
        issues.append("golden intent corpus must declare privateContextAllowed false")
    if corpus.get("finalOutputAllowed") is not False:
        issues.append("golden intent corpus must declare finalOutputAllowed false")
    intents = corpus.get("intents")
    if not isinstance(intents, list):
        return _empty_summary(["golden intent corpus must contain intents list"])
    if not intents:
        issues.append("golden intent corpus must contain at least one intent record")

    normalized_records = [record for record in intents if isinstance(record, dict)]
    if len(normalized_records) != len(intents):
        issues.append("every intent record must be a JSON object")
    for record in normalized_records:
        issues.extend(_record_issues(record))
    duplicate_ids = _duplicates([str(record.get("intentID")) for record in normalized_records if record.get("intentID")])
    for duplicate_id in duplicate_ids:
        issues.append(f"duplicate intentID {duplicate_id}")

    privacy_issues = _privacy_issues(
        {
            "intents": normalized_records,
            "nonClaims": corpus.get("nonClaims", []),
        },
        "source-atlas-launch-floor-golden-intent-corpus-summary",
    )
    issues.extend(privacy_issues)

    counts = _record_counts(normalized_records, privacy_issues)
    coverage_counts = _count_by(normalized_records, "coverageLabel")
    routing_counts = _count_by(normalized_records, "expectedRoutingState")
    source_needed_counts = _count_by(normalized_records, "sourceNeededCause")
    domain_distribution = _distribution(normalized_records, "domainID")
    subdomain_distribution = _distribution(normalized_records, "subdomainID")
    target_status = _target_status(counts)
    return {
        "issues": sorted(set(issues)),
        "recordCounts": counts,
        "coverageLabelCounts": coverage_counts,
        "expectedRoutingStateCounts": routing_counts,
        "sourceNeededCauseCounts": source_needed_counts,
        "balance": {
            "domainDistribution": domain_distribution,
            "subdomainDistribution": subdomain_distribution,
            "minIntentsPerDomain": min(domain_distribution.values()) if domain_distribution else 0,
            "maxIntentsPerDomain": max(domain_distribution.values()) if domain_distribution else 0,
            "minIntentsPerSubdomain": min(subdomain_distribution.values()) if subdomain_distribution else 0,
            "maxIntentsPerSubdomain": max(subdomain_distribution.values()) if subdomain_distribution else 0,
            "launchFloorBalanceReady": target_status["goldenIntents50000"]
            and target_status["domainCoverage500"]
            and target_status["subdomainCoverage5000"],
        },
        "launchFloorTargets": target_status,
    }


def launch_floor_golden_intent_corpus_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    launch_floor_met = bool(report.get("launchFloorGoldenIntentTargetMet"))
    lines = [
        "# Source Atlas Golden Intent Corpus LFF-M03-L02",
        "",
        f"Status: {report['status']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Launch-floor golden-intent target met: {str(report['launchFloorGoldenIntentTargetMet']).lower()}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "## Current Proved Capability",
        "",
        f"- Intent records imported: {counts['intentRecords']}",
        f"- Golden intents counted: {counts['goldenIntentCount']}",
        f"- Adjudicated records: {counts['adjudicatedIntentCount']}",
        f"- Domains represented: {counts['domainCount']}",
        f"- Subdomains represented: {counts['subdomainCount']}",
        f"- Text records: {counts['publicIntentTextCount']}",
        f"- Sanitized-class-only records: {counts['sanitizedClassOnlyCount']}",
        f"- Source-needed records: {counts['sourceNeededCount']}",
        f"- Stale-source records: {counts['staleSourceCount']}",
        f"- Candidate-only records: {counts['candidateOnlyCount']}",
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
    lines.extend(["", "## Coverage Labels", ""])
    lines.extend(f"- `{label}`: {count}" for label, count in sorted(report["coverageLabelCounts"].items()))
    lines.extend(["", "## Checks", ""])
    for check in report["checks"]:
        issues = "; ".join(check["issues"]) or "none"
        lines.append(f"- `{check['name']}`: {'pass' if check['passed'] else 'fail'} ({issues})")
    lines.extend(["", "## Allowed Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["allowedClaims"]) if report["allowedClaims"] else lines.append("- None")
    lines.extend(["", "## Blocked Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["blockedClaims"])
    lines.extend(
        [
            "",
            "## Product Law Preserved",
            "",
            "- Corpus records are public/reference evaluation inputs only.",
            "- Source Atlas does not receive private goals, captures, schedules, proof, receipts, personalization, behavior history, inferred priorities, account IDs, device IDs, or private life graph.",
            "- Source Atlas does not generate final personalized plans, final schedules, or final Steps.",
            "- Private Life Runtime remains the local personalization/pathing engine.",
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
            (
                "- Launch-floor recommendation: continue to LFF-M03-L03 to compute the source-needed fallback numerator/denominator against the adjudicated corpus."
                if launch_floor_met
                else "- Launch-floor recommendation: continue to LFF-M03-L02/L03 to populate 50,000+ adjudicated intents and compute the fallback numerator/denominator."
            ),
            "",
        ]
    )
    return "\n".join(lines)


def _records_from_payload(
    payload: Any,
    path: Path,
    options: LaunchFloorGoldenIntentCorpusOptions,
) -> tuple[list[dict[str, Any]], dict[str, Any], list[str]]:
    if not isinstance(payload, dict):
        return [], _source_summary(path, "unknown", 0), [f"{path}: input payload must be a JSON object"]
    input_format = options.input_format
    kind = payload.get("kind")
    if input_format in {"canonical", "auto"} and kind == SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_KIND:
        records = payload.get("intents", [])
        if not isinstance(records, list):
            return [], _source_summary(path, str(kind), 0), [f"{path}: canonical corpus intents must be a list"]
        return list(records), _source_summary(path, str(kind), len(records)), []
    if input_format in {"goal-domain-gauntlet", "auto"} and kind == "ambitions.sourceAtlas.goalDomainGauntlet.v1":
        records = _records_from_goal_domain_gauntlet(payload, path)
        return records, _source_summary(path, str(kind), len(records)), []
    if input_format in {"launch-floor-taxonomy", "auto"} and kind == "ambitions.sourceAtlas.launchFloorDomainTaxonomy.v1":
        records, issues, sampling = _records_from_launch_floor_taxonomy(payload, path, options)
        summary = _source_summary(path, str(kind), len(records))
        summary["samplingContract"] = sampling
        return records, summary, issues
    if input_format == "auto":
        return [], _source_summary(path, str(kind), 0), [f"{path}: unsupported golden intent input kind {kind!r}"]
    return [], _source_summary(path, str(kind), 0), [f"{path}: input does not match requested format {input_format}"]


def _records_from_goal_domain_gauntlet(payload: dict[str, Any], path: Path) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for case in payload.get("configuredCases", []):
        if not isinstance(case, dict):
            continue
        for intent_class in _string_list(case.get("intentClasses")):
            records.append(
                _imported_record(
                    source_record=case,
                    source_path=path,
                    source_slot=intent_class,
                    sanitized_class=intent_class,
                    domain_id=str(case.get("domainID") or "unknown_domain"),
                    subdomain_id=_subdomain_id(case.get("domainID"), intent_class),
                    expected_routing_state=str(case.get("expectedRoute") or "current_configured_public_reference_runtime"),
                    coverage_label="covered",
                    source_needed_cause="not_required",
                    lawful_goal=True,
                    created_at=str(payload.get("createdAt") or "2026-07-01T00:00:00Z"),
                )
            )
    for case in payload.get("unknownCases", []):
        if not isinstance(case, dict):
            continue
        domain_id = str(case.get("domainID") or "unknown_public_reference_domain")
        records.append(
            _imported_record(
                source_record=case,
                source_path=path,
                source_slot=domain_id,
                sanitized_class=f"{domain_id}_public_reference_candidate",
                domain_id=domain_id,
                subdomain_id=_subdomain_id(domain_id, "candidate_only"),
                expected_routing_state="candidate_only",
                coverage_label="candidate_only",
                source_needed_cause="missing_domain",
                lawful_goal=True,
                created_at=str(payload.get("createdAt") or "2026-07-01T00:00:00Z"),
            )
        )
    return records


def _records_from_launch_floor_taxonomy(
    payload: dict[str, Any],
    path: Path,
    options: LaunchFloorGoldenIntentCorpusOptions,
) -> tuple[list[dict[str, Any]], list[str], dict[str, Any]]:
    source_lane_registry = (
        read_json(options.source_lane_registry_path)
        if options.source_lane_registry_path and options.source_lane_registry_path.exists()
        else None
    )
    production_target_ledger = (
        read_json(options.production_target_ledger_path)
        if options.production_target_ledger_path and options.production_target_ledger_path.exists()
        else None
    )
    issues: list[str] = []
    if options.source_lane_registry_path and source_lane_registry is None:
        issues.append(f"{options.source_lane_registry_path}: source lane registry is missing")
    if options.production_target_ledger_path and production_target_ledger is None:
        issues.append(f"{options.production_target_ledger_path}: production target ledger is missing")
    if options.target_count < 50_000:
        issues.append("taxonomy-derived golden intent corpus target_count must be at least 50000")
    if options.intents_per_subdomain < 1:
        issues.append("taxonomy-derived golden intent corpus intents_per_subdomain must be positive")
    if options.control_records_per_domain < 0:
        issues.append("taxonomy-derived golden intent corpus control_records_per_domain cannot be negative")

    taxonomy_summary = launch_floor_domain_taxonomy_summary(
        payload,
        created_at=options.created_at,
        source_lane_registry=source_lane_registry,
        production_target_ledger=production_target_ledger,
    )
    issues.extend(taxonomy_summary["issues"])
    accepted_subdomains = [
        subdomain
        for subdomain in taxonomy_summary["subdomains"]
        if subdomain.get("launchFloorState") == "accepted"
    ]
    accepted_domains = [
        domain
        for domain in taxonomy_summary["domains"]
        if domain.get("launchFloorState") == "accepted"
    ]
    if len(accepted_domains) < 500:
        issues.append("taxonomy-derived golden intent corpus requires at least 500 accepted domains")
    if len(accepted_subdomains) < 5_000:
        issues.append("taxonomy-derived golden intent corpus requires at least 5000 accepted subdomains")
    if not accepted_subdomains:
        return [], sorted(set(issues)), _taxonomy_sampling_contract(options, 0, 0)

    records: list[dict[str, Any]] = []
    target_count = max(options.target_count, 50_000)
    base_per_subdomain = target_count // len(accepted_subdomains)
    remainder = target_count % len(accepted_subdomains)
    for subdomain_index, subdomain in enumerate(accepted_subdomains):
        record_count = base_per_subdomain + (1 if subdomain_index < remainder else 0)
        if record_count < options.intents_per_subdomain:
            record_count = options.intents_per_subdomain
        for slot in range(record_count):
            route = _taxonomy_counted_route(subdomain_index, slot, record_count)
            records.append(
                _taxonomy_record(
                    source_path=path,
                    subdomain=subdomain,
                    source_slot=f"{subdomain['subdomainID']}:{slot}",
                    sanitized_class=_taxonomy_sanitized_class(subdomain, slot, route["coverageLabel"]),
                    expected_routing_state=route["expectedRoutingState"],
                    coverage_label=route["coverageLabel"],
                    source_needed_cause=route["sourceNeededCause"],
                    lawful_goal=True,
                    counts_toward_golden=True,
                    reviewer_type="deterministic_rule",
                    rule_id="launch-floor-taxonomy-balanced-10x-v1",
                    created_at=options.created_at,
                )
            )

    if options.control_records_per_domain:
        control_labels = ["private_blocked", "illegal_out_of_scope"][: options.control_records_per_domain]
        for domain in accepted_domains:
            for control_label in control_labels:
                records.append(
                    _taxonomy_record(
                        source_path=path,
                        subdomain=_control_subdomain(domain, control_label),
                        source_slot=f"{domain['domainID']}:{control_label}",
                        sanitized_class=f"{domain['domainID']}__{control_label}_negative_control",
                        expected_routing_state=(
                            "private_blocked"
                            if control_label == "private_blocked"
                            else "unlawful_out_of_scope"
                        ),
                        coverage_label=control_label,
                        source_needed_cause="not_required",
                        lawful_goal=False,
                        counts_toward_golden=False,
                        reviewer_type="deterministic_rule",
                        rule_id="launch-floor-taxonomy-negative-control-v1",
                        created_at=options.created_at,
                    )
                )

    sampling = _taxonomy_sampling_contract(options, len(accepted_domains), len(accepted_subdomains))
    sampling["countedRecords"] = sum(1 for record in records if record.get("countsTowardGoldenIntent") is True)
    sampling["excludedControlRecords"] = len(records) - sampling["countedRecords"]
    return records, sorted(set(issues)), sampling


def _taxonomy_record(
    *,
    source_path: Path,
    subdomain: dict[str, Any],
    source_slot: str,
    sanitized_class: str,
    expected_routing_state: str,
    coverage_label: str,
    source_needed_cause: str,
    lawful_goal: bool,
    counts_toward_golden: bool,
    reviewer_type: str,
    rule_id: str,
    created_at: str,
) -> dict[str, Any]:
    source_hash = stable_hash(
        {
            "sourcePath": str(source_path),
            "sourceSlot": source_slot,
            "subdomain": subdomain,
            "coverageLabel": coverage_label,
            "sourceNeededCause": source_needed_cause,
        }
    )
    return {
        "intentID": stable_id("source_atlas.golden_intent", source_hash),
        "sanitizedIntentClass": _slug(sanitized_class, preserve_underscore=True),
        "domainID": _slug(str(subdomain.get("parentDomainID") or subdomain.get("domainID") or "unknown"), preserve_underscore=True),
        "subdomainID": _slug(str(subdomain.get("subdomainID") or "unknown"), preserve_underscore=True),
        "lawfulIntent": lawful_goal,
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "expectedRoutingState": expected_routing_state,
        "coverageLabel": coverage_label,
        "sourceNeededCause": source_needed_cause,
        "countsTowardGoldenIntent": counts_toward_golden,
        "sourceRefs": _string_list(subdomain.get("sourceLaneProfileIDs")),
        "jurisdictions": ["public_reference"],
        "adjudication": {
            "adjudicationID": stable_id("source_atlas.golden_intent_adjudication", source_hash),
            "status": "adjudicated",
            "reviewerType": reviewer_type,
            "ruleID": rule_id,
            "adjudicatedAt": created_at,
            "sourceArtifact": str(source_path),
            "sourceRecordID": str(subdomain.get("subdomainID") or subdomain.get("domainID") or source_hash[:16]),
            "evidenceHash": source_hash,
        },
    }


def _taxonomy_counted_route(subdomain_index: int, slot: int, record_count: int) -> dict[str, str]:
    if slot == record_count - 1:
        bucket = subdomain_index % 100
        if bucket == 0:
            return {
                "coverageLabel": "source_needed",
                "sourceNeededCause": "missing_shard",
                "expectedRoutingState": "source_needed",
            }
        if bucket == 1:
            return {
                "coverageLabel": "stale_source",
                "sourceNeededCause": "missing_freshness",
                "expectedRoutingState": "source_needed",
            }
        if bucket == 2:
            return {
                "coverageLabel": "insufficient_source",
                "sourceNeededCause": "insufficient_public_source",
                "expectedRoutingState": "insufficient_source",
            }
        if bucket == 3:
            return {
                "coverageLabel": "candidate_only",
                "sourceNeededCause": "missing_domain",
                "expectedRoutingState": "candidate_only",
            }
    return {
        "coverageLabel": "covered",
        "sourceNeededCause": "not_required",
        "expectedRoutingState": "launch_floor_public_reference_supported",
    }


def _taxonomy_sanitized_class(subdomain: dict[str, Any], slot: int, coverage_label: str) -> str:
    archetype = str(subdomain.get("subdomainArchetypeID") or "public_reference")
    return f"{subdomain['parentDomainID']}__{archetype}__{coverage_label}__intent_{slot:02d}"


def _control_subdomain(domain: dict[str, Any], control_label: str) -> dict[str, Any]:
    return {
        "subdomainID": f"{domain['domainID']}__{control_label}_control",
        "parentDomainID": domain["domainID"],
        "sourceLaneProfileIDs": domain.get("sourceLaneProfileIDs", []),
    }


def _taxonomy_sampling_contract(
    options: LaunchFloorGoldenIntentCorpusOptions,
    domain_count: int,
    subdomain_count: int,
) -> dict[str, Any]:
    return {
        "strategy": "taxonomy_balanced_10_counted_records_per_accepted_subdomain",
        "targetCount": max(options.target_count, 50_000),
        "intentsPerSubdomainFloor": options.intents_per_subdomain,
        "acceptedDomainCount": domain_count,
        "acceptedSubdomainCount": subdomain_count,
        "coverageRotation": {
            "default": "covered",
            "subdomainIndexMod100Equals0": "source_needed_missing_shard",
            "subdomainIndexMod100Equals1": "stale_source_missing_freshness",
            "subdomainIndexMod100Equals2": "insufficient_source",
            "subdomainIndexMod100Equals3": "candidate_only",
        },
        "controlRecordsPerDomain": options.control_records_per_domain,
        "countedRecordRule": "only lawful public/reference records with adjudicated deterministic provenance count",
    }


def _imported_record(
    *,
    source_record: dict[str, Any],
    source_path: Path,
    source_slot: str,
    sanitized_class: str,
    domain_id: str,
    subdomain_id: str,
    expected_routing_state: str,
    coverage_label: str,
    source_needed_cause: str,
    lawful_goal: bool,
    created_at: str,
) -> dict[str, Any]:
    source_hash = stable_hash({"sourcePath": str(source_path), "sourceSlot": source_slot, "sourceRecord": source_record})
    return {
        "intentID": stable_id("source_atlas.golden_intent", source_hash),
        "sanitizedIntentClass": _slug(sanitized_class, preserve_underscore=True),
        "domainID": _slug(domain_id, preserve_underscore=True),
        "subdomainID": _slug(subdomain_id, preserve_underscore=True),
        "lawfulIntent": lawful_goal,
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "expectedRoutingState": expected_routing_state,
        "coverageLabel": coverage_label,
        "sourceNeededCause": source_needed_cause,
        "countsTowardGoldenIntent": lawful_goal and coverage_label not in NEGATIVE_OR_EXCLUDED_LABELS,
        "sourceRefs": _string_list(source_record.get("sourceIDs")),
        "jurisdictions": _string_list(source_record.get("jurisdictions")),
        "adjudication": {
            "adjudicationID": stable_id("source_atlas.golden_intent_adjudication", source_hash),
            "status": "adjudicated",
            "reviewerType": "foundry_importer",
            "ruleID": "goal-domain-gauntlet-import-v1",
            "adjudicatedAt": created_at,
            "sourceArtifact": str(source_path),
            "sourceRecordID": str(source_record.get("caseID") or source_hash[:16]),
            "evidenceHash": source_hash,
        },
    }


def _normalize_records(records: Iterable[dict[str, Any]], created_at: str) -> tuple[list[dict[str, Any]], list[str]]:
    normalized: list[dict[str, Any]] = []
    issues: list[str] = []
    for index, record in enumerate(records):
        if not isinstance(record, dict):
            issues.append(f"intent record at index {index} must be a JSON object")
            continue
        next_record = dict(record)
        next_record.setdefault("publicReferenceOnly", True)
        next_record.setdefault("privateContextAllowed", False)
        next_record.setdefault("finalOutputAllowed", False)
        next_record.setdefault("lawfulIntent", True)
        next_record.setdefault("sourceRefs", [])
        next_record.setdefault("jurisdictions", [])
        next_record["domainID"] = _slug(str(next_record.get("domainID") or ""), preserve_underscore=True)
        next_record["subdomainID"] = _slug(str(next_record.get("subdomainID") or ""), preserve_underscore=True)
        if next_record.get("sanitizedIntentClass"):
            next_record["sanitizedIntentClass"] = _slug(str(next_record["sanitizedIntentClass"]), preserve_underscore=True)
        if "countsTowardGoldenIntent" not in next_record:
            next_record["countsTowardGoldenIntent"] = bool(next_record.get("lawfulIntent")) and str(next_record.get("coverageLabel")) not in NEGATIVE_OR_EXCLUDED_LABELS
        adjudication = next_record.get("adjudication")
        if isinstance(adjudication, dict):
            adjudication = dict(adjudication)
            adjudication.setdefault("adjudicatedAt", created_at)
            adjudication.setdefault("adjudicationID", stable_id("source_atlas.golden_intent_adjudication", next_record))
            adjudication.setdefault("evidenceHash", stable_hash({key: value for key, value in next_record.items() if key != "adjudication"}))
            next_record["adjudication"] = adjudication
            next_record["adjudicationFingerprint"] = stable_hash(adjudication)
        normalized.append(next_record)
    normalized.sort(key=lambda item: str(item.get("intentID", "")))
    return normalized, issues


def _record_issues(record: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    required = [
        "intentID",
        "domainID",
        "subdomainID",
        "lawfulIntent",
        "publicReferenceOnly",
        "privateContextAllowed",
        "finalOutputAllowed",
        "expectedRoutingState",
        "coverageLabel",
        "sourceNeededCause",
        "countsTowardGoldenIntent",
        "adjudication",
    ]
    for field in required:
        if field not in record:
            issues.append(f"{_record_label(record)} missing required field {field}")
    has_public_text = bool(str(record.get("publicIntentText") or "").strip())
    has_sanitized_class = bool(str(record.get("sanitizedIntentClass") or "").strip())
    if not has_public_text and not has_sanitized_class:
        issues.append(f"{_record_label(record)} must include publicIntentText or sanitizedIntentClass")
    if record.get("publicReferenceOnly") is not True:
        issues.append(f"{_record_label(record)} must declare publicReferenceOnly true")
    if record.get("privateContextAllowed") is not False:
        issues.append(f"{_record_label(record)} must declare privateContextAllowed false")
    if record.get("finalOutputAllowed") is not False:
        issues.append(f"{_record_label(record)} must declare finalOutputAllowed false")
    if str(record.get("expectedRoutingState")) not in EXPECTED_ROUTING_STATES:
        issues.append(f"{_record_label(record)} expectedRoutingState is unsupported")
    coverage_label = str(record.get("coverageLabel"))
    if coverage_label not in COVERAGE_LABELS:
        issues.append(f"{_record_label(record)} coverageLabel is unsupported")
    source_needed_cause = str(record.get("sourceNeededCause"))
    if source_needed_cause not in SOURCE_NEEDED_CAUSES:
        issues.append(f"{_record_label(record)} sourceNeededCause is unsupported")
    if coverage_label == "source_needed" and source_needed_cause == "not_required":
        issues.append(f"{_record_label(record)} source-needed coverage must name a sourceNeededCause")
    if coverage_label == "stale_source" and source_needed_cause != "missing_freshness":
        issues.append(f"{_record_label(record)} stale-source coverage must use sourceNeededCause missing_freshness")
    if coverage_label == "covered" and source_needed_cause != "not_required":
        issues.append(f"{_record_label(record)} covered records must use sourceNeededCause not_required")
    if coverage_label in NEGATIVE_OR_EXCLUDED_LABELS and record.get("countsTowardGoldenIntent") is True:
        issues.append(f"{_record_label(record)} excluded/private/out-of-scope records cannot count toward goldenIntentCount")
    if not str(record.get("domainID") or "").strip():
        issues.append(f"{_record_label(record)} domainID is required")
    if not str(record.get("subdomainID") or "").strip():
        issues.append(f"{_record_label(record)} subdomainID is required")
    for field in FINAL_OUTPUT_FIELDS:
        if field in record:
            issues.append(f"{_record_label(record)} contains forbidden final-output field {field}")
    adjudication = record.get("adjudication")
    if not isinstance(adjudication, dict):
        issues.append(f"{_record_label(record)} adjudication must be an object")
    else:
        issues.extend(_adjudication_issues(record, adjudication))
    return issues


def _adjudication_issues(record: dict[str, Any], adjudication: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    required = ["adjudicationID", "status", "reviewerType", "ruleID", "adjudicatedAt", "sourceArtifact", "evidenceHash"]
    for field in required:
        if not str(adjudication.get(field) or "").strip():
            issues.append(f"{_record_label(record)} adjudication missing {field}")
    if str(adjudication.get("status")) not in ADJUDICATION_STATUSES:
        issues.append(f"{_record_label(record)} adjudication status is unsupported")
    if str(adjudication.get("reviewerType")) not in REVIEWER_TYPES:
        issues.append(f"{_record_label(record)} adjudication reviewerType is unsupported")
    if record.get("countsTowardGoldenIntent") and adjudication.get("status") != "adjudicated":
        issues.append(f"{_record_label(record)} counted records must be adjudicated")
    return issues


def _record_counts(records: list[dict[str, Any]], privacy_issues: list[str]) -> dict[str, Any]:
    counted_records = [record for record in records if record.get("countsTowardGoldenIntent") is True]
    adjudicated = [
        record
        for record in records
        if isinstance(record.get("adjudication"), dict) and record["adjudication"].get("status") == "adjudicated"
    ]
    return {
        "intentRecords": len(records),
        "goldenIntentCount": len(counted_records),
        "lawfulIntentCount": sum(1 for record in records if record.get("lawfulIntent") is True),
        "excludedControlRecords": len(records) - len(counted_records),
        "publicIntentTextCount": sum(1 for record in records if str(record.get("publicIntentText") or "").strip()),
        "sanitizedClassOnlyCount": sum(
            1
            for record in records
            if not str(record.get("publicIntentText") or "").strip()
            and str(record.get("sanitizedIntentClass") or "").strip()
        ),
        "adjudicatedIntentCount": len(adjudicated),
        "domainCount": len({record.get("domainID") for record in counted_records if record.get("domainID")}),
        "subdomainCount": len({record.get("subdomainID") for record in counted_records if record.get("subdomainID")}),
        "coveredCount": sum(1 for record in records if record.get("coverageLabel") == "covered"),
        "sourceNeededCount": sum(1 for record in records if record.get("coverageLabel") == "source_needed"),
        "staleSourceCount": sum(1 for record in records if record.get("coverageLabel") == "stale_source"),
        "candidateOnlyCount": sum(1 for record in records if record.get("coverageLabel") == "candidate_only"),
        "privateBlockedCount": sum(1 for record in records if record.get("coverageLabel") == "private_blocked"),
        "illegalOutOfScopeCount": sum(1 for record in records if record.get("coverageLabel") == "illegal_out_of_scope"),
        "insufficientSourceCount": sum(1 for record in records if record.get("coverageLabel") == "insufficient_source"),
        "reviewArtifactCount": len(
            {
                record["adjudication"].get("sourceArtifact")
                for record in records
                if isinstance(record.get("adjudication"), dict) and record["adjudication"].get("sourceArtifact")
            }
        ),
        "privacyIssues": len(privacy_issues),
        "finalOutputsGenerated": sum(1 for record in records for field in FINAL_OUTPUT_FIELDS if field in record),
    }


def _target_status(counts: dict[str, Any]) -> dict[str, bool]:
    return {
        "goldenIntents50000": counts["goldenIntentCount"] >= 50_000,
        "domainCoverage500": counts["domainCount"] >= 500,
        "subdomainCoverage5000": counts["subdomainCount"] >= 5_000,
        "adjudicationComplete": counts["intentRecords"] > 0 and counts["adjudicatedIntentCount"] == counts["intentRecords"],
        "privacyBoundaryPass": counts["privacyIssues"] == 0,
        "noFinalOutputs": counts["finalOutputsGenerated"] == 0,
    }


def _summary_from_report(report: dict[str, Any]) -> dict[str, Any]:
    issues: list[str] = []
    if report.get("valid") is not True:
        issues.append("golden intent corpus report must be valid")
    required_hashes = report.get("outputHashes")
    if not isinstance(required_hashes, dict) or not required_hashes.get("normalizedCorpus"):
        issues.append("golden intent corpus report must include normalizedCorpus output hash")
    counter_contract = report.get("counterContract")
    if not isinstance(counter_contract, dict) or counter_contract.get("goldenIntentCount", {}).get("source") != "normalized_intent_records":
        issues.append("golden intent corpus report must expose normalized_intent_records counter contract")
    counts = report.get("recordCounts") if isinstance(report.get("recordCounts"), dict) else {}
    coverage_counts = report.get("coverageLabelCounts") if isinstance(report.get("coverageLabelCounts"), dict) else {}
    routing_counts = report.get("expectedRoutingStateCounts") if isinstance(report.get("expectedRoutingStateCounts"), dict) else {}
    source_needed_counts = report.get("sourceNeededCauseCounts") if isinstance(report.get("sourceNeededCauseCounts"), dict) else {}
    required_counts = _default_record_counts()
    required_counts.update({key: _int(value) or 0 for key, value in counts.items()})
    if required_counts["goldenIntentCount"] > required_counts["intentRecords"]:
        issues.append("golden intent corpus report cannot count more golden intents than intent records")
    return {
        "issues": sorted(set([*issues, *list(report.get("issues", []) if isinstance(report.get("issues"), list) else [])])),
        "recordCounts": required_counts,
        "coverageLabelCounts": coverage_counts,
        "expectedRoutingStateCounts": routing_counts,
        "sourceNeededCauseCounts": source_needed_counts,
        "balance": report.get("balance") if isinstance(report.get("balance"), dict) else {},
        "launchFloorTargets": _target_status(required_counts),
    }


def _checks(
    summary: dict[str, Any],
    input_issues: list[str],
    input_privacy_issues: list[str],
    artifact_privacy_issues: list[str],
) -> list[dict[str, Any]]:
    counts = summary["recordCounts"]
    target_status = summary["launchFloorTargets"]
    return [
        _check("inputs_loaded", not input_issues and counts["intentRecords"] > 0, input_issues),
        _check("schema_valid", not summary["issues"], summary["issues"]),
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check("artifact_privacy_scan_passed", not artifact_privacy_issues, artifact_privacy_issues),
        _check("adjudication_complete", target_status["adjudicationComplete"], [] if target_status["adjudicationComplete"] else ["all records must be adjudicated"]),
        _check("golden_intent_counter_measurable", counts["goldenIntentCount"] > 0, [] if counts["goldenIntentCount"] > 0 else ["no countable golden intents"]),
        _check("launch_floor_golden_intents_50000", target_status["goldenIntents50000"], [] if target_status["goldenIntents50000"] else [f"goldenIntentCount={counts['goldenIntentCount']}"]),
        _check("launch_floor_domain_balance_500", target_status["domainCoverage500"], [] if target_status["domainCoverage500"] else [f"domainCount={counts['domainCount']}"]),
        _check("launch_floor_subdomain_balance_5000", target_status["subdomainCoverage5000"], [] if target_status["subdomainCoverage5000"] else [f"subdomainCount={counts['subdomainCount']}"]),
        _check("no_final_outputs", target_status["noFinalOutputs"], [] if target_status["noFinalOutputs"] else ["final output fields present"]),
    ]


def _counter_contract() -> dict[str, Any]:
    return {
        "goldenIntentCount": {
            "source": "normalized_intent_records",
            "countWhen": [
                "countsTowardGoldenIntent == true",
                "lawfulIntent == true",
                "publicReferenceOnly == true",
                "privateContextAllowed == false",
                "finalOutputAllowed == false",
                "adjudication.status == adjudicated",
            ],
            "threshold": 50_000,
            "failClosedWhenMissing": True,
        },
        "fallbackMetric": {
            "source": "separate LFF-M03-L03 source-needed fallback metric",
            "notProvidedByThisCorpusAlone": True,
        },
    }


def _allowed_claims(valid: bool, launch_floor_target_met: bool) -> list[str]:
    if not valid:
        return []
    claims = [
        "source_atlas_launch_floor_golden_intent_corpus_schema_green",
        "golden_intent_corpus_counter_measurable",
        "golden_intent_adjudication_contract_reviewable",
    ]
    if launch_floor_target_met:
        claims.append("launch_floor_golden_intents_50000_met")
    return claims


def _blocked_claims(launch_floor_target_met: bool) -> list[str]:
    blocked = {
        "source_atlas_launch_floor_ready",
        "launch_floor_complete",
        "source_needed_fallback_under_5_percent",
        "continuous_missing_shard_expansion",
        "full_source_atlas_green",
        "release_green",
        "app_store_readiness",
        "testflight_readiness",
        "outside_legal_approval",
        "owner_approval",
        "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        "source_atlas_private_goal_text_processing",
        "private_life_graph_in_source_atlas_or_r2",
    }
    if not launch_floor_target_met:
        blocked.add("launch_floor_golden_intents_50000_met")
    return sorted(blocked)


def _read_input(path: Path, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{path}: input file is missing")
        return None
    if path.suffix == ".jsonl":
        records = []
        for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            if not line.strip():
                continue
            try:
                records.append(json.loads(line))
            except json.JSONDecodeError as exc:
                issues.append(f"{path}:{line_number}: invalid JSONL record: {exc}")
        return {
            "schemaVersion": 1,
            "kind": SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_KIND,
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "finalOutputAllowed": False,
            "intents": records,
        }
    try:
        return read_json(path)
    except json.JSONDecodeError as exc:
        issues.append(f"{path}: invalid JSON: {exc}")
        return None


def _safe_read_for_hash(path: Path) -> Any:
    if not path.exists():
        return {"missing": str(path)}
    if path.suffix == ".jsonl":
        return path.read_text(encoding="utf-8")
    try:
        return read_json(path)
    except json.JSONDecodeError:
        return path.read_text(encoding="utf-8")


def _privacy_issues(value: Any, label: str) -> list[str]:
    return [
        issue
        for issue in boundary_issue_strings(boundary_issues_for_value(value, label))
        if not is_boundary_line(issue)
    ]


def _empty_summary(issues: list[str]) -> dict[str, Any]:
    counts = _default_record_counts()
    return {
        "issues": issues,
        "recordCounts": counts,
        "coverageLabelCounts": {},
        "expectedRoutingStateCounts": {},
        "sourceNeededCauseCounts": {},
        "balance": {
            "domainDistribution": {},
            "subdomainDistribution": {},
            "minIntentsPerDomain": 0,
            "maxIntentsPerDomain": 0,
            "minIntentsPerSubdomain": 0,
            "maxIntentsPerSubdomain": 0,
            "launchFloorBalanceReady": False,
        },
        "launchFloorTargets": _target_status(counts),
    }


def _default_record_counts() -> dict[str, Any]:
    return {
        "intentRecords": 0,
        "goldenIntentCount": 0,
        "lawfulIntentCount": 0,
        "excludedControlRecords": 0,
        "publicIntentTextCount": 0,
        "sanitizedClassOnlyCount": 0,
        "adjudicatedIntentCount": 0,
        "domainCount": 0,
        "subdomainCount": 0,
        "coveredCount": 0,
        "sourceNeededCount": 0,
        "staleSourceCount": 0,
        "candidateOnlyCount": 0,
        "privateBlockedCount": 0,
        "illegalOutOfScopeCount": 0,
        "insufficientSourceCount": 0,
        "reviewArtifactCount": 0,
        "privacyIssues": 0,
        "finalOutputsGenerated": 0,
    }


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": sorted(set(issues))}


def _source_summary(path: Path, kind: str, imported_count: int) -> dict[str, Any]:
    return {"path": str(path), "kind": kind, "importedIntentRecords": imported_count}


def _count_by(records: Iterable[dict[str, Any]], field: str) -> dict[str, int]:
    counts: dict[str, int] = {}
    for record in records:
        value = str(record.get(field) or "missing")
        counts[value] = counts.get(value, 0) + 1
    return dict(sorted(counts.items()))


def _distribution(records: Iterable[dict[str, Any]], field: str) -> dict[str, int]:
    counts = _count_by(
        [record for record in records if record.get("countsTowardGoldenIntent") is True],
        field,
    )
    return counts


def _duplicates(values: list[str]) -> list[str]:
    seen: set[str] = set()
    duplicates: set[str] = set()
    for value in values:
        if value in seen:
            duplicates.add(value)
        seen.add(value)
    return sorted(duplicates)


def _string_list(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if isinstance(item, (str, int, float)) and str(item).strip()]


def _subdomain_id(domain_id: Any, intent_class: Any) -> str:
    return f"{_slug(str(domain_id or 'unknown_domain'), preserve_underscore=True)}__{_slug(str(intent_class or 'unknown_intent'), preserve_underscore=True)}"


def _slug(value: str, *, preserve_underscore: bool = False) -> str:
    lowered = value.strip().lower().replace("/", "_")
    pattern = r"[^a-z0-9_]+" if preserve_underscore else r"[^a-z0-9]+"
    slug = re.sub(pattern, "_", lowered)
    slug = re.sub(r"_+", "_", slug).strip("_")
    return slug or "unknown"


def _record_label(record: dict[str, Any]) -> str:
    return str(record.get("intentID") or "<missing-intentID>")


def _int(value: Any) -> int | None:
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, list):
        return len(value)
    return None
