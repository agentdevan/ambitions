"""Review packet templates for blocked Source Atlas goal-domain work orders.

Train 90 makes blocked review-required work orders machine-visible. This
compiler turns those blocks into deterministic packet templates for the review
lanes that must precede registry mutations, claims, packs, R2 publish, native
activation, or local composition.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .goal_domain_work_order_executor import REVIEW_REQUIRED_STAGES
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


GOAL_DOMAIN_REVIEW_PACKETS_VERSION = "source-atlas-goal-domain-review-packets-train-92"
GOAL_DOMAIN_REVIEW_PACKETS_KIND = "ambitions.sourceAtlas.goalDomainReviewPackets.v1"

REVIEW_LANES = {
    "direct_source_resolution": "direct_source_authority_resolution",
    "source_lane_review": "source_lane_governance",
    "legal_terms_review": "legal_terms_review",
    "api_governance_review": "api_governance_review",
}
REQUIRED_REVIEWER_FIELDS = {
    "direct_source_resolution": [
        "publisher_identity",
        "source_directness",
        "publisher_authority_class",
        "jurisdiction",
        "official_locator",
        "authority_limitations",
        "review_decision",
        "review_evidence_path",
    ],
    "source_lane_review": [
        "source_id",
        "source_class",
        "authority_class",
        "jurisdiction",
        "claim_classes_allowed",
        "claim_classes_forbidden",
        "redistribution_policy",
        "r2_pack_policy",
        "allowed_artifact_classes",
        "forbidden_artifact_classes",
        "review_status",
        "review_evidence_path",
    ],
    "legal_terms_review": [
        "license_id",
        "license_url",
        "terms_url",
        "rights_url",
        "redistribution_allowed",
        "attribution_required",
        "pack_output_allowed",
        "outside_legal_required",
        "outside_legal_status",
        "approval_artifact_path",
        "review_evidence_path",
    ],
    "api_governance_review": [
        "api_policy_id",
        "api_mode",
        "key_required",
        "env_var_name",
        "missing_key_behavior",
        "rate_limit_per_second",
        "daily_budget_limit",
        "max_records_per_run",
        "live_flag_required",
        "execute_flag_required",
        "secret_redaction_required",
        "budget_owner",
        "review_evidence_path",
    ],
}
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}

REVIEW_PACKET_NON_CLAIMS = [
    "review packet templates only",
    "not completed review",
    "not source authority",
    "not legal approval",
    "not outside legal approval",
    "not active registry mutation",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not production R2 upload",
    "not native activation proof",
    "not universal coverage",
    "not app runtime readiness",
    "not release readiness",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class GoalDomainReviewPacketOptions:
    executor_manifest_path: Path
    output_root: Path
    reviewer: str = ""
    created_at: str | None = None


def compile_goal_domain_review_packets(options: GoalDomainReviewPacketOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    executor_manifest = read_json(options.executor_manifest_path)
    executor_manifest_issues = _executor_manifest_issues(executor_manifest)
    executor_report_path = _path_or_none(executor_manifest.get("outputPaths", {}).get("executorReport"))
    execution_records_path = _path_or_none(executor_manifest.get("outputPaths", {}).get("executionRecords"))
    executor_report = read_json(executor_report_path) if executor_report_path and executor_report_path.exists() else {}
    execution_payload = read_json(execution_records_path) if execution_records_path and execution_records_path.exists() else {}
    work_orders_path = _path_or_none(executor_report.get("workOrdersPath"))
    work_orders_payload = read_json(work_orders_path) if work_orders_path and work_orders_path.exists() else {}
    execution_records = _execution_records(executor_report, execution_payload)
    work_orders = _work_orders(work_orders_payload)
    work_order_by_id = {str(order.get("orderID") or ""): order for order in work_orders}

    report_issues = _executor_report_issues(executor_report, executor_report_path, execution_records)
    work_order_issues = _work_order_issues(work_orders_payload, work_orders_path, work_orders)
    selected_records = [
        record
        for record in execution_records
        if record.get("executionStatus") == "blocked_review_required" and record.get("stage") in REVIEW_REQUIRED_STAGES
    ]
    packets = [
        _review_packet(record, work_order_by_id.get(str(record.get("orderID") or "")), created_at, reviewer=options.reviewer)
        for record in selected_records
    ]
    packets = sorted(packets, key=lambda item: (item["requestID"], item["stageIndex"], item["packetID"]))
    review_summary = _review_summary(packets)
    record_counts = {
        "inputExecutionRecords": len(execution_records),
        "selectedBlockedReviewRecords": len(selected_records),
        "reviewPackets": len(packets),
        "completedReviewPackets": 0,
        "approvalArtifactsEmitted": 0,
        "activeRegistryMutations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    packet_collection = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainReviewPacketTemplates.v1",
        "versionID": GOAL_DOMAIN_REVIEW_PACKETS_VERSION,
        "createdAt": created_at,
        "reviewPackets": packets,
        "nonClaims": [
            "template collection only",
            "not completed review",
            "not source authority",
            "not legal approval",
            "not registry mutation",
            "not claim output",
            "not pack output",
            "not R2 publish",
        ],
    }
    artifact = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_REVIEW_PACKETS_KIND,
        "versionID": GOAL_DOMAIN_REVIEW_PACKETS_VERSION,
        "createdAt": created_at,
        "executorManifestPath": str(options.executor_manifest_path),
        "executorReportPath": str(executor_report_path) if executor_report_path else "",
        "executionRecordsPath": str(execution_records_path) if execution_records_path else "",
        "workOrdersPath": str(work_orders_path) if work_orders_path else "",
        "reviewer": options.reviewer,
        "reviewSummary": review_summary,
        "reviewPackets": packets,
        "completedReviews": [],
        "activeRegistryMutations": [],
        "recordCounts": record_counts,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": REVIEW_PACKET_NON_CLAIMS,
    }

    input_privacy_issues = privacy_findings_for_value(
        {
            "executorManifest": executor_manifest,
            "executorReport": executor_report,
            "executionRecords": execution_payload,
            "workOrders": work_orders_payload,
        },
        "goal-domain-review-packets-input",
    )
    output_privacy_issues = privacy_findings_for_value(
        {"artifact": artifact, "packetCollection": packet_collection},
        "goal-domain-review-packets",
    )
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    checks = [
        {"name": "executor_manifest_valid", "passed": not executor_manifest_issues, "issues": executor_manifest_issues},
        {"name": "executor_report_valid", "passed": not report_issues, "issues": report_issues},
        {"name": "work_orders_valid", "passed": not work_order_issues, "issues": work_order_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "only_blocked_review_required_records_selected",
            "passed": bool(packets)
            and all(packet["completionStatus"] == "blocked_review_required" for packet in packets)
            and len(packets) == len(selected_records),
            "issues": [],
        },
        {
            "name": "every_review_packet_requires_manual_review",
            "passed": all(packet["manualReviewRequired"] is True and packet["requiredReviewerFields"] for packet in packets),
            "issues": [],
        },
        {
            "name": "review_packets_emit_no_approval_or_registry_mutations",
            "passed": record_counts["approvalArtifactsEmitted"] == 0
            and record_counts["activeRegistryMutations"] == 0
            and all(packet["approvalArtifactEmitted"] is False and packet["registryMutationAllowed"] is False for packet in packets),
            "issues": [],
        },
        {
            "name": "review_packets_emit_no_claims_packs_r2_or_native_activation",
            "passed": record_counts["claims"] == 0
            and record_counts["packableClaims"] == 0
            and record_counts["r2PackableArtifacts"] == 0
            and record_counts["r2PublishOperations"] == 0
            and record_counts["nativeActivationOperations"] == 0
            and all(
                packet["claimOutputAllowed"] is False
                and packet["packOutputAllowed"] is False
                and packet["r2PublishAllowed"] is False
                and packet["nativeActivationAllowed"] is False
                for packet in packets
            ),
            "issues": [],
        },
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
        {"name": "privacy_scan_passed", "passed": not output_privacy_issues, "issues": output_privacy_issues},
    ]
    issues: list[str] = []
    issues.extend(executor_manifest_issues)
    issues.extend(report_issues)
    issues.extend(work_order_issues)
    issues.extend(input_privacy_issues)
    issues.extend(output_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    output_paths = {
        "reviewPacketReport": str(output_root / "goal-domain-review-packets.json"),
        "reviewPacketTemplates": str(output_root / "review-packet-templates.json"),
        "manifest": str(output_root / "manifest.json"),
        "closeout": str(output_root / "closeout.md"),
    }
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainReviewPacketsManifest.v1",
        "versionID": GOAL_DOMAIN_REVIEW_PACKETS_VERSION,
        "createdAt": created_at,
        "status": "Source Green for goal-domain review packet template tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; review packet templates only",
        "executorManifestPath": str(options.executor_manifest_path),
        "recordCounts": record_counts,
        "reviewSummary": review_summary,
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": output_paths,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": REVIEW_PACKET_NON_CLAIMS,
    }

    write_json(output_root / "goal-domain-review-packets.json", artifact)
    write_json(output_root / "review-packet-templates.json", packet_collection)
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "reviewPacketReport": stable_hash(read_json(output_root / "goal-domain-review-packets.json")),
        "reviewPacketTemplates": stable_hash(read_json(output_root / "review-packet-templates.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(goal_domain_review_packets_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_goal_domain_review_packets_report(
    markdown_path: Path,
    json_path: Path,
    *,
    executor_manifest_path: Path,
    output_root: Path,
    reviewer: str = "",
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_goal_domain_review_packets(
        GoalDomainReviewPacketOptions(
            executor_manifest_path=executor_manifest_path,
            output_root=output_root,
            reviewer=reviewer,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(goal_domain_review_packets_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def goal_domain_review_packets_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Goal-Domain Review Packets Train 92",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic review packet templates for blocked Train 90 review-required work orders.",
        "- Packets cover direct-source, source-lane, legal/terms, and API-governance review lanes.",
        "- Packets remain blocked_review_required and cannot emit approvals or registry mutations.",
        "- No claims, packs, R2 writes, native activations, final plans, schedules, or Steps are emitted.",
        "",
        "Counts:",
        f"- Input execution records: {counts['inputExecutionRecords']}",
        f"- Selected blocked review records: {counts['selectedBlockedReviewRecords']}",
        f"- Review packets: {counts['reviewPackets']}",
        f"- Completed review packets: {counts['completedReviewPackets']}",
        f"- Approval artifacts emitted: {counts['approvalArtifactsEmitted']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        "",
        "Review summary:",
    ]
    for item in result.get("reviewSummary", []):
        lines.append(f"- {item['reviewLane']}: {item['packetCount']} packets")
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
            "- Review packets are governance templates, not source authority.",
            "- Private Ambitions runtime context remains local.",
            "- Source Atlas does not generate final user plans, schedules, Steps, or personalized paths.",
            "",
            "Validation run:",
            "- See train closeout for exact command output.",
            "",
            "Validation not run:",
            "- Live network/API discovery was not run.",
            "- Production R2 upload/readback was not run.",
            "- Native XCTest/build-for-testing was not required for this tooling-only train.",
            "- Outside legal approval was not run or claimed.",
            "",
            "Proof artifacts:",
        ]
    )
    for path in result.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _review_packet(record: dict[str, Any], work_order: dict[str, Any] | None, created_at: str, *, reviewer: str) -> dict[str, Any]:
    stage = str(record.get("stage") or "")
    payload = {
        "orderID": record.get("orderID"),
        "requestID": record.get("requestID"),
        "stage": stage,
        "createdAt": created_at,
    }
    blocked_until = _blocked_until(stage, record, work_order)
    return {
        "packetID": stable_id("source_atlas_goal_domain_review_packet", payload),
        "orderID": str(record.get("orderID") or ""),
        "requestID": str(record.get("requestID") or ""),
        "requestedDomain": str(record.get("requestedDomain") or ""),
        "matchedDomainID": record.get("matchedDomainID"),
        "lane": str(record.get("lane") or ""),
        "stageIndex": int(record.get("stageIndex") or 0),
        "stage": stage,
        "reviewLane": REVIEW_LANES.get(stage, "unknown_review_lane"),
        "createdAt": created_at,
        "reviewer": reviewer,
        "completionStatus": "blocked_review_required",
        "manualReviewRequired": True,
        "requiredReviewerFields": REQUIRED_REVIEWER_FIELDS.get(stage, []),
        "candidateSourceIDs": sorted(str(item) for item in (work_order or {}).get("candidateSourceIDs", []) if item),
        "sourceWorkOrder": {
            "status": (work_order or {}).get("status"),
            "description": (work_order or {}).get("description"),
            "requiredEvidence": list((work_order or {}).get("requiredEvidence", [])) if isinstance((work_order or {}).get("requiredEvidence"), list) else [],
            "blockedBy": sorted(set([*record.get("blockedBy", []), *((work_order or {}).get("blockedBy", []) or [])])),
        },
        "blockedUntil": blocked_until,
        "approvalArtifactEmitted": False,
        "registryMutationAllowed": False,
        "claimOutputAllowed": False,
        "packOutputAllowed": False,
        "r2PackableArtifactAllowed": False,
        "r2PublishAllowed": False,
        "nativeActivationAllowed": False,
        "liveAllowed": False,
        "executeAllowed": False,
        "publicReferenceOnly": True,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": [
            "review packet template only",
            "not completed review",
            "not source authority",
            "not legal approval",
            "not registry mutation",
            "not claim output",
            "not pack output",
            "not R2 publish",
            "not final user plans, schedules, or Steps",
        ],
    }


def _blocked_until(stage: str, record: dict[str, Any], work_order: dict[str, Any] | None) -> list[str]:
    base = ["completed_manual_review_packet", "review_evidence_artifact"]
    if stage == "direct_source_resolution":
        base.extend(["direct_publisher_locator", "authority_classification"])
    elif stage == "source_lane_review":
        base.extend(["source_lane_registry_decision", "allowed_and_forbidden_artifact_classes"])
    elif stage == "legal_terms_review":
        base.extend(["license_terms_rights_decision", "redistribution_packability_decision"])
    elif stage == "api_governance_review":
        base.extend(["api_key_rate_budget_policy", "live_execute_secret_redaction_policy"])
    required = []
    if isinstance(record.get("requiredEvidence"), list):
        required.extend(str(item) for item in record["requiredEvidence"])
    if work_order and isinstance(work_order.get("requiredEvidence"), list):
        required.extend(str(item) for item in work_order["requiredEvidence"])
    return sorted(set([*base, *required]))


def _review_summary(packets: list[dict[str, Any]]) -> list[dict[str, Any]]:
    by_lane: dict[str, list[dict[str, Any]]] = {}
    by_domain: dict[str, int] = {}
    for packet in packets:
        by_lane.setdefault(packet["reviewLane"], []).append(packet)
        by_domain[packet["matchedDomainID"] or packet["requestedDomain"]] = by_domain.get(packet["matchedDomainID"] or packet["requestedDomain"], 0) + 1
    return [
        {
            "reviewLane": lane,
            "packetCount": len(items),
            "requestIDs": sorted({item["requestID"] for item in items}),
            "domainCounts": [
                {"domain": domain, "packetCount": count}
                for domain, count in sorted(_domain_counts(items).items())
            ],
            "completedReviewPackets": 0,
            "approvalArtifactsEmitted": 0,
            "activeRegistryMutations": 0,
            "nonClaims": ["review summary only", "not approval", "not source authority", "not claim output"],
        }
        for lane, items in sorted(by_lane.items())
    ]


def _domain_counts(packets: list[dict[str, Any]]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for packet in packets:
        domain = str(packet.get("matchedDomainID") or packet.get("requestedDomain") or "unknown")
        counts[domain] = counts.get(domain, 0) + 1
    return counts


def _executor_manifest_issues(manifest: Any) -> list[str]:
    if not isinstance(manifest, dict):
        return ["executor manifest must be an object"]
    issues: list[str] = []
    if manifest.get("valid") is not True:
        issues.append("executor manifest must be valid")
    output_paths = manifest.get("outputPaths", {})
    if not isinstance(output_paths, dict) or not output_paths.get("executorReport"):
        issues.append("executor manifest missing outputPaths.executorReport")
    if not isinstance(output_paths, dict) or not output_paths.get("executionRecords"):
        issues.append("executor manifest missing outputPaths.executionRecords")
    return issues


def _executor_report_issues(report: Any, path: Path | None, records: list[dict[str, Any]]) -> list[str]:
    if path is None or not path.exists():
        return ["executor report missing"]
    if not isinstance(report, dict):
        return ["executor report must be an object"]
    issues: list[str] = []
    if not records:
        issues.append("executor report must include execution records")
    counts = report.get("recordCounts", {})
    if isinstance(counts, dict) and counts.get("blockedReviewRequired") != len([item for item in records if item.get("executionStatus") == "blocked_review_required"]):
        issues.append("executor report blockedReviewRequired count mismatch")
    return issues


def _work_order_issues(payload: Any, path: Path | None, work_orders: list[dict[str, Any]]) -> list[str]:
    if path is None or not path.exists():
        return ["work orders artifact missing"]
    if not isinstance(payload, dict):
        return ["work orders artifact must be an object"]
    if not work_orders:
        return ["work orders artifact must include workOrders"]
    return []


def _execution_records(report: Any, execution_payload: Any) -> list[dict[str, Any]]:
    if isinstance(execution_payload, dict) and isinstance(execution_payload.get("executionRecords"), list):
        return [item for item in execution_payload["executionRecords"] if isinstance(item, dict)]
    if isinstance(report, dict) and isinstance(report.get("executionRecords"), list):
        return [item for item in report["executionRecords"] if isinstance(item, dict)]
    return []


def _work_orders(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("workOrders"), list):
        return [item for item in payload["workOrders"] if isinstance(item, dict)]
    return []


def _path_or_none(value: Any) -> Path | None:
    if isinstance(value, str) and value:
        return Path(value)
    return None


def _contains_forbidden_output_marker(value: Any) -> bool:
    if isinstance(value, str):
        return value in FORBIDDEN_OUTPUT_MARKERS
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(_contains_forbidden_output_marker(item) for item in value.values())
    return False
