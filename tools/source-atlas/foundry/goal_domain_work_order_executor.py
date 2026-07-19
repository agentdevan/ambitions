"""Fixture/dry-run executor for Source Atlas goal-domain work orders.

The executor consumes Train 89 work orders and performs only deterministic
public/reference checks. It never runs live network harvests, writes registries,
publishes R2 objects, activates native runtime paths, emits claims, or creates
personalized plans. Its purpose is to advance autonomous operation by making
safe completion and blocked gates machine-visible.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .goal_domain_production_lanes import LANE_CANDIDATE_EXPANSION, LANE_CONFIGURED_BLOCKED, LANE_READY_PUBLIC_REFERENCE
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, utc_now, write_json


GOAL_DOMAIN_WORK_ORDER_EXECUTOR_VERSION = "source-atlas-goal-domain-work-order-executor-train-90"
GOAL_DOMAIN_WORK_ORDER_EXECUTOR_KIND = "ambitions.sourceAtlas.goalDomainWorkOrderExecutor.v1"
EXECUTOR_MODES = {"fixture", "dry_run"}

SAFE_READY_STAGES = {
    "ledger_freshness_monitor",
    "r2_gateway_readback_monitor",
    "native_refresh_registry_monitor",
    "local_runtime_composition_monitor",
}
SAFE_CANDIDATE_STAGES = {"frontier_review", "source_discovery"}
REVIEW_REQUIRED_STAGES = {
    "direct_source_resolution",
    "source_lane_review",
    "legal_terms_review",
    "api_governance_review",
}
UPSTREAM_REQUIRED_STAGES = {
    "adapter_fixture_contract",
    "live_harvest_gate",
    "claim_graph_gate",
    "pack_production_gate",
    "r2_publish_gate",
    "native_activation_gate",
    "local_composition_gate",
}
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}

EXECUTOR_NON_CLAIMS = [
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not App Store or TestFlight readiness",
    "not physical-device proof",
    "not production R2 upload or overwrite",
    "not native activation proof",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    "not source authority",
    "not claim output",
    "not pack output",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class GoalDomainWorkOrderExecutorOptions:
    production_lanes_manifest_path: Path
    output_root: Path
    mode: str = "fixture"
    created_at: str | None = None


def run_goal_domain_work_order_executor(options: GoalDomainWorkOrderExecutorOptions) -> dict[str, Any]:
    """Evaluate routed-domain work orders without live or write side effects."""

    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    mode_issues = [] if options.mode in EXECUTOR_MODES else [f"unsupported executor mode: {options.mode}"]
    manifest = read_json(options.production_lanes_manifest_path)
    manifest_issues = _manifest_issues(manifest)
    work_orders_path = _path_or_none(manifest.get("outputPaths", {}).get("workOrders"))
    lanes_path = _path_or_none(manifest.get("outputPaths", {}).get("productionLanes"))
    work_orders_payload = read_json(work_orders_path) if work_orders_path and work_orders_path.exists() else {}
    lanes_payload = read_json(lanes_path) if lanes_path and lanes_path.exists() else {}
    work_orders = _work_orders(work_orders_payload)
    lane_summaries = _lane_summaries_by_request(lanes_payload)
    work_order_issues = _work_order_issues(work_orders_payload, work_orders_path)

    execution_records = [
        _execution_record(order, lane_summaries.get(str(order.get("requestID") or "")), options.mode, created_at)
        for order in work_orders
    ]
    execution_records = sorted(execution_records, key=lambda item: (item["requestID"], item["stageIndex"], item["orderID"]))
    domain_rollups = _domain_rollups(execution_records, lane_summaries)
    record_counts = {
        "workOrders": len(work_orders),
        "executionRecords": len(execution_records),
        "completedFixtureChecks": sum(1 for item in execution_records if item["executionStatus"] == "completed_fixture_check"),
        "completedDryRunChecks": sum(1 for item in execution_records if item["executionStatus"] == "completed_dry_run_check"),
        "blockedReviewRequired": sum(1 for item in execution_records if item["executionStatus"] == "blocked_review_required"),
        "blockedUpstreamEvidenceRequired": sum(1 for item in execution_records if item["executionStatus"] == "blocked_upstream_evidence_required"),
        "blockedConfiguredFrontier": sum(1 for item in execution_records if item["executionStatus"] == "blocked_configured_frontier"),
        "liveOperations": 0,
        "executeOperations": 0,
        "registryWriteOperations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    artifact = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_WORK_ORDER_EXECUTOR_KIND,
        "versionID": GOAL_DOMAIN_WORK_ORDER_EXECUTOR_VERSION,
        "createdAt": created_at,
        "mode": options.mode,
        "productionLanesManifestPath": str(options.production_lanes_manifest_path),
        "workOrdersPath": str(work_orders_path) if work_orders_path else "",
        "productionLanesPath": str(lanes_path) if lanes_path else "",
        "domainRollups": domain_rollups,
        "executionRecords": execution_records,
        "recordCounts": record_counts,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": EXECUTOR_NON_CLAIMS,
    }
    input_privacy_issues = privacy_findings_for_value(
        {
            "productionLanesManifest": manifest,
            "workOrders": work_orders_payload,
            "productionLanes": lanes_payload,
        },
        "goal-domain-work-order-executor-input",
    )
    output_privacy_issues = privacy_findings_for_value(artifact, "goal-domain-work-order-executor")
    checks = [
        {"name": "mode_valid", "passed": not mode_issues, "issues": mode_issues},
        {"name": "production_lanes_manifest_valid", "passed": not manifest_issues, "issues": manifest_issues},
        {"name": "work_orders_valid", "passed": not work_order_issues and bool(work_orders), "issues": work_order_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "safe_stages_can_complete_without_live_or_execute",
            "passed": all(
                item["executionStatus"].startswith("completed_")
                for item in execution_records
                if item["stage"] in SAFE_READY_STAGES | SAFE_CANDIDATE_STAGES
            ),
            "issues": [],
        },
        {
            "name": "review_gates_remain_blocked",
            "passed": all(
                item["executionStatus"] == "blocked_review_required"
                for item in execution_records
                if item["stage"] in REVIEW_REQUIRED_STAGES
            ),
            "issues": [],
        },
        {
            "name": "upstream_gates_remain_blocked",
            "passed": all(
                item["executionStatus"] == "blocked_upstream_evidence_required"
                for item in execution_records
                if item["stage"] in UPSTREAM_REQUIRED_STAGES
            ),
            "issues": [],
        },
        {
            "name": "executor_performs_no_live_write_claim_pack_r2_or_native_operations",
            "passed": record_counts["liveOperations"] == 0
            and record_counts["executeOperations"] == 0
            and record_counts["registryWriteOperations"] == 0
            and record_counts["claims"] == 0
            and record_counts["packableClaims"] == 0
            and record_counts["r2PackableArtifacts"] == 0
            and record_counts["r2PublishOperations"] == 0
            and record_counts["nativeActivationOperations"] == 0,
            "issues": [],
        },
        {
            "name": "no_final_plan_schedule_step_output",
            "passed": record_counts["finalOutputArtifacts"] == 0 and not _contains_forbidden_output_marker(artifact),
            "issues": [],
        },
        {"name": "privacy_scan_passed", "passed": not output_privacy_issues, "issues": output_privacy_issues},
    ]
    issues: list[str] = []
    issues.extend(mode_issues)
    issues.extend(manifest_issues)
    issues.extend(work_order_issues)
    issues.extend(input_privacy_issues)
    issues.extend(output_privacy_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    output_paths = {
        "executorReport": str(output_root / "work-order-executor-report.json"),
        "executionRecords": str(output_root / "execution-records.json"),
        "manifest": str(output_root / "manifest.json"),
        "closeout": str(output_root / "closeout.md"),
    }
    manifest_out = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainWorkOrderExecutorManifest.v1",
        "versionID": GOAL_DOMAIN_WORK_ORDER_EXECUTOR_VERSION,
        "createdAt": created_at,
        "status": "Source Green for goal-domain work-order fixture executor" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; fixture/dry-run work-order executor only",
        "mode": options.mode,
        "productionLanesManifestPath": str(options.production_lanes_manifest_path),
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": output_paths,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": EXECUTOR_NON_CLAIMS,
    }

    write_json(output_root / "work-order-executor-report.json", artifact)
    write_json(
        output_root / "execution-records.json",
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.goalDomainExecutionRecords.v1",
            "versionID": GOAL_DOMAIN_WORK_ORDER_EXECUTOR_VERSION,
            "createdAt": created_at,
            "executionRecords": execution_records,
            "nonClaims": ["execution records only", "not source authority", "not claim output", "not R2 publish"],
        },
    )
    write_json(output_root / "manifest.json", manifest_out)
    manifest_out["outputHashes"] = {
        "executorReport": stable_hash(read_json(output_root / "work-order-executor-report.json")),
        "executionRecords": stable_hash(read_json(output_root / "execution-records.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest_out)
    (output_root / "closeout.md").write_text(goal_domain_work_order_executor_markdown(manifest_out), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest_out}


def write_goal_domain_work_order_executor_report(
    markdown_path: Path,
    json_path: Path,
    *,
    production_lanes_manifest_path: Path,
    output_root: Path,
    mode: str = "fixture",
    created_at: str | None = None,
) -> dict[str, Any]:
    result = run_goal_domain_work_order_executor(
        GoalDomainWorkOrderExecutorOptions(
            production_lanes_manifest_path=production_lanes_manifest_path,
            output_root=output_root,
            mode=mode,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(goal_domain_work_order_executor_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def goal_domain_work_order_executor_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Goal-Domain Work-Order Executor Train 90",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Mode: {result['mode']}",
        "",
        "Scope completed:",
        "- Deterministic fixture/dry-run executor for Train 89 production-lane work orders.",
        "- Safe public/reference checks complete without live network or write execution.",
        "- Review, upstream evidence, R2, pack, native activation, and local composition gates remain blocked until required evidence exists.",
        "- No claims, packs, R2 writes, registry writes, native activations, final plans, schedules, or Steps are emitted.",
        "",
        "Counts:",
        f"- Work orders: {counts['workOrders']}",
        f"- Completed fixture checks: {counts['completedFixtureChecks']}",
        f"- Completed dry-run checks: {counts['completedDryRunChecks']}",
        f"- Blocked review-required: {counts['blockedReviewRequired']}",
        f"- Blocked upstream-evidence-required: {counts['blockedUpstreamEvidenceRequired']}",
        f"- Live operations: {counts['liveOperations']}",
        f"- Execute operations: {counts['executeOperations']}",
        f"- Claims: {counts['claims']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        "",
        "Product law preserved:",
        "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
        "- Executor consumes public work-order metadata only.",
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
    for path in result.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _execution_record(order: dict[str, Any], lane_summary: dict[str, Any] | None, mode: str, created_at: str) -> dict[str, Any]:
    stage = str(order.get("stage") or "")
    lane = str(order.get("lane") or "")
    status = _execution_status(order, lane_summary, mode)
    completed = status.startswith("completed_")
    return {
        "orderID": str(order.get("orderID") or ""),
        "requestID": str(order.get("requestID") or ""),
        "requestedDomain": str(order.get("requestedDomain") or ""),
        "matchedDomainID": order.get("matchedDomainID"),
        "lane": lane,
        "stageIndex": int(order.get("stageIndex") or 0),
        "stage": stage,
        "mode": mode,
        "executedAt": created_at,
        "executionStatus": status,
        "completed": completed,
        "liveOperationPerformed": False,
        "executeOperationPerformed": False,
        "registryWritePerformed": False,
        "r2PublishPerformed": False,
        "nativeActivationPerformed": False,
        "claimOutputEmitted": False,
        "packOutputEmitted": False,
        "requiredEvidence": list(order.get("requiredEvidence", [])) if isinstance(order.get("requiredEvidence"), list) else [],
        "blockedBy": _blocked_by(order, status),
        "nonClaims": [
            "execution record only",
            "not source authority",
            "not claim output",
            "not pack output",
            "not R2 publish",
            "not final user plans, schedules, or Steps",
        ],
    }


def _execution_status(order: dict[str, Any], lane_summary: dict[str, Any] | None, mode: str) -> str:
    stage = str(order.get("stage") or "")
    lane = str(order.get("lane") or "")
    if lane == LANE_READY_PUBLIC_REFERENCE and stage in SAFE_READY_STAGES:
        if _ready_evidence_complete(stage, lane_summary):
            return "completed_dry_run_check" if mode == "dry_run" else "completed_fixture_check"
        return "blocked_upstream_evidence_required"
    if lane == LANE_CANDIDATE_EXPANSION and stage in SAFE_CANDIDATE_STAGES:
        return "completed_dry_run_check" if mode == "dry_run" else "completed_fixture_check"
    if lane == LANE_CANDIDATE_EXPANSION and stage in REVIEW_REQUIRED_STAGES:
        return "blocked_review_required"
    if lane == LANE_CANDIDATE_EXPANSION and stage in UPSTREAM_REQUIRED_STAGES:
        return "blocked_upstream_evidence_required"
    if lane == LANE_CONFIGURED_BLOCKED:
        return "blocked_configured_frontier"
    return "blocked_upstream_evidence_required"


def _ready_evidence_complete(stage: str, lane_summary: dict[str, Any] | None) -> bool:
    if not lane_summary:
        return False
    ledger = lane_summary.get("ledgerEvidence", {})
    if stage == "ledger_freshness_monitor":
        return lane_summary.get("productionTargetReady") is True
    if stage == "r2_gateway_readback_monitor":
        return ledger.get("r2ProductionProofComplete") is True and ledger.get("gatewayProofComplete") is True
    if stage == "native_refresh_registry_monitor":
        return ledger.get("nativeUsabilityProofComplete") is True
    if stage == "local_runtime_composition_monitor":
        return ledger.get("nativeUsabilityProofComplete") is True
    return False


def _blocked_by(order: dict[str, Any], status: str) -> list[str]:
    if status.startswith("completed_"):
        return []
    existing = order.get("blockedBy", [])
    if not isinstance(existing, list):
        existing = []
    if status == "blocked_review_required":
        return sorted(set([*existing, "review_artifact_required"]))
    if status == "blocked_configured_frontier":
        return sorted(set([*existing, "production_target_evidence_required"]))
    return sorted(set([*existing, "upstream_evidence_required"]))


def _domain_rollups(execution_records: list[dict[str, Any]], lane_summaries: dict[str, dict[str, Any]]) -> list[dict[str, Any]]:
    records_by_request: dict[str, list[dict[str, Any]]] = {}
    for record in execution_records:
        records_by_request.setdefault(record["requestID"], []).append(record)
    rollups: list[dict[str, Any]] = []
    for request_id, records in sorted(records_by_request.items()):
        summary = lane_summaries.get(request_id, {})
        rollups.append(
            {
                "requestID": request_id,
                "requestedDomain": records[0]["requestedDomain"] if records else "",
                "matchedDomainID": records[0].get("matchedDomainID") if records else None,
                "lane": records[0]["lane"] if records else "",
                "workOrderCount": len(records),
                "completedCount": sum(1 for record in records if record["completed"] is True),
                "blockedCount": sum(1 for record in records if record["completed"] is False),
                "candidateSourceCount": summary.get("candidateSourceCount", 0),
                "productionTargetReady": summary.get("productionTargetReady") is True,
                "nonClaims": ["domain rollup only", "not source authority", "not claim output", "not pack output"],
            }
        )
    return rollups


def _manifest_issues(manifest: Any) -> list[str]:
    if not isinstance(manifest, dict):
        return ["production lanes manifest must be an object"]
    issues: list[str] = []
    if manifest.get("valid") is not True:
        issues.append("production lanes manifest must be valid")
    output_paths = manifest.get("outputPaths", {})
    if not isinstance(output_paths, dict) or not output_paths.get("workOrders"):
        issues.append("production lanes manifest missing outputPaths.workOrders")
    if not isinstance(output_paths, dict) or not output_paths.get("productionLanes"):
        issues.append("production lanes manifest missing outputPaths.productionLanes")
    return issues


def _work_order_issues(payload: Any, path: Path | None) -> list[str]:
    if path is None or not path.exists():
        return ["work orders artifact missing"]
    if not isinstance(payload, dict):
        return ["work orders artifact must be an object"]
    orders = payload.get("workOrders")
    if not isinstance(orders, list) or not orders:
        return ["work orders artifact must include non-empty workOrders"]
    return []


def _work_orders(payload: Any) -> list[dict[str, Any]]:
    if not isinstance(payload, dict):
        return []
    return [item for item in payload.get("workOrders", []) if isinstance(item, dict)]


def _lane_summaries_by_request(payload: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(payload, dict):
        return {}
    summaries = payload.get("laneSummaries", [])
    if not isinstance(summaries, list):
        return {}
    return {
        str(item.get("requestID")): item
        for item in summaries
        if isinstance(item, dict) and item.get("requestID")
    }


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
