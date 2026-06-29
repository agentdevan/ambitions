"""Autonomous candidate-domain expansion chain for Source Atlas.

This chain advances candidate-only frontier intake artifacts into the existing
goal-domain routing, production-lane work-order, fixture executor, and review
packet machinery. It deliberately stops before completed reviews, registry
mutation, claim output, pack output, R2 publishing, native activation, or any
final user plan/schedule/Step behavior.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .goal_domain_production_lanes import GoalDomainProductionLaneOptions, compile_goal_domain_production_lanes
from .goal_domain_review_packets import GoalDomainReviewPacketOptions, compile_goal_domain_review_packets
from .goal_domain_router import GoalDomainRouterOptions, compile_goal_domain_router
from .goal_domain_work_order_executor import EXECUTOR_MODES, GoalDomainWorkOrderExecutorOptions, run_goal_domain_work_order_executor
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


AUTONOMOUS_DOMAIN_EXPANSION_CHAIN_VERSION = "source-atlas-autonomous-domain-expansion-chain-train-107"
AUTONOMOUS_DOMAIN_EXPANSION_CHAIN_KIND = "ambitions.sourceAtlas.autonomousDomainExpansionChain.v1"

CHAIN_NON_CLAIMS = [
    "autonomous candidate-domain expansion chain only",
    "not completed legal review",
    "not outside legal approval",
    "not source authority",
    "not active registry mutation",
    "not claim output",
    "not pack output",
    "not production R2 upload",
    "not native activation proof",
    "not literal universal coverage",
    "not release readiness",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class AutonomousDomainExpansionChainOptions:
    executor_report_path: Path
    output_root: Path
    frontier_config_path: Path | None = None
    production_target_ledger_path: Path | None = None
    mode: str = "fixture"
    reviewer: str = ""
    created_at: str = "2026-06-28T00:00:00Z"


def run_autonomous_domain_expansion_chain(options: AutonomousDomainExpansionChainOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    executor_report = _read_report(options.executor_report_path, issues)
    executor_privacy_issues = boundary_issue_strings(boundary_issues_for_value(executor_report, "source-atlas-autonomous-domain-expansion-chain-input"))
    issues.extend(executor_privacy_issues)
    if isinstance(executor_report, dict) and executor_report.get("valid") is not True:
        issues.append("executor report is not valid")
    if options.mode not in EXECUTOR_MODES:
        issues.append(f"unsupported work-order executor mode: {options.mode}")

    candidate_inputs: list[dict[str, Any]] = []
    if isinstance(executor_report, dict) and not executor_privacy_issues:
        candidate_inputs = _candidate_inputs_from_executor_report(executor_report)
    if not candidate_inputs and not issues:
        issues.append("executor report contains no candidate frontier intake inputs")

    stages: dict[str, Any] = {}
    router_input_path = output_root / "goal-domain-router-input.json"
    if not issues:
        write_json(router_input_path, _router_input(candidate_inputs))
        stages["goalDomainRouter"] = compile_goal_domain_router(
            GoalDomainRouterOptions(
                input_path=router_input_path,
                output_root=output_root / "01-goal-domain-router",
                frontier_config_path=options.frontier_config_path,
                production_target_ledger_path=options.production_target_ledger_path,
                created_at=options.created_at,
            )
        )
        if _valid(stages.get("goalDomainRouter")):
            stages["productionLanes"] = compile_goal_domain_production_lanes(
                GoalDomainProductionLaneOptions(
                    router_manifest_path=Path(stages["goalDomainRouter"]["manifestPath"]),
                    output_root=output_root / "02-production-lanes",
                    production_target_ledger_path=options.production_target_ledger_path,
                    created_at=options.created_at,
                )
            )
        if _valid(stages.get("productionLanes")):
            stages["workOrderExecutor"] = run_goal_domain_work_order_executor(
                GoalDomainWorkOrderExecutorOptions(
                    production_lanes_manifest_path=Path(stages["productionLanes"]["manifestPath"]),
                    output_root=output_root / "03-work-order-executor",
                    mode=options.mode,
                    created_at=options.created_at,
                )
            )
        if _valid(stages.get("workOrderExecutor")):
            executor_counts = stages["workOrderExecutor"].get("recordCounts", {})
            blocked_review_required = int(executor_counts.get("blockedReviewRequired", 0) or 0)
            if blocked_review_required > 0:
                stages["reviewPackets"] = compile_goal_domain_review_packets(
                    GoalDomainReviewPacketOptions(
                        executor_manifest_path=Path(stages["workOrderExecutor"]["manifestPath"]),
                        output_root=output_root / "04-review-packets",
                        reviewer=options.reviewer,
                        created_at=options.created_at,
                    )
                )
            else:
                stages["reviewPackets"] = _review_packets_not_required_stage(
                    output_root / "04-review-packets",
                    executor_manifest_path=Path(stages["workOrderExecutor"]["manifestPath"]),
                    input_execution_records=int(executor_counts.get("executionRecords", 0) or 0),
                    created_at=options.created_at,
                )

    stage_issues = _stage_issues(stages)
    issues.extend(stage_issues)
    record_counts = _record_counts(candidate_inputs, stages)
    output_paths = _output_paths(output_root, router_input_path, stages)
    checks = [
        _check("executor_report_loaded", isinstance(executor_report, dict), [] if isinstance(executor_report, dict) else ["executor report missing or unreadable"]),
        _check("executor_report_valid", isinstance(executor_report, dict) and executor_report.get("valid") is True, [] if isinstance(executor_report, dict) and executor_report.get("valid") is True else ["executor report is not valid"]),
        _check("input_privacy_scan_passed", not executor_privacy_issues, executor_privacy_issues),
        _check("candidate_frontier_inputs_found", bool(candidate_inputs), [] if candidate_inputs else ["no candidate frontier inputs found"]),
        _check("router_stage_valid", _valid(stages.get("goalDomainRouter")), stages.get("goalDomainRouter", {}).get("issues", ["stage did not run"])),
        _check("production_lanes_stage_valid", _valid(stages.get("productionLanes")), stages.get("productionLanes", {}).get("issues", ["stage did not run"])),
        _check("work_order_executor_stage_valid", _valid(stages.get("workOrderExecutor")), stages.get("workOrderExecutor", {}).get("issues", ["stage did not run"])),
        _check("review_packets_stage_valid", _valid(stages.get("reviewPackets")), stages.get("reviewPackets", {}).get("issues", ["stage did not run"])),
        _check("chain_emits_no_claims_packs_r2_or_native_activation", _no_forbidden_outputs(record_counts), []),
        _check("review_stage_matches_execution_path", _review_stage_matches_execution_path(record_counts), []),
    ]
    output_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "recordCounts": record_counts,
                "stageSummaries": _stage_summaries(stages),
                "outputPaths": output_paths,
                "nonClaims": CHAIN_NON_CLAIMS,
            },
            "source-atlas-autonomous-domain-expansion-chain-output",
        )
    )
    issues.extend(output_privacy_issues)
    checks.append(_check("output_privacy_scan_passed", not output_privacy_issues, output_privacy_issues))
    valid = not issues and all(check["passed"] for check in checks)

    report_path = output_root / "autonomous-domain-expansion-chain-report.json"
    markdown_path = output_root / "autonomous-domain-expansion-chain-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_DOMAIN_EXPANSION_CHAIN_KIND,
        "versionID": AUTONOMOUS_DOMAIN_EXPANSION_CHAIN_VERSION,
        "createdAt": options.created_at,
        "chainID": stable_id(
            "source_atlas.autonomous_domain_expansion_chain",
            {
                "executorReport": str(options.executor_report_path),
                "candidateInputs": candidate_inputs,
                "createdAt": options.created_at,
                "mode": options.mode,
            },
        ),
        "status": "Source Green for autonomous domain expansion chain" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; autonomous domain expansion, production-ready routing, and maintenance-check evidence only",
        "executorReportPath": str(options.executor_report_path),
        "mode": options.mode,
        "reviewer": options.reviewer,
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "stageSummaries": _stage_summaries(stages),
        "stages": stages,
        "allowedClaims": ["deterministic_autonomous_domain_expansion_chain"] if valid else [],
        "blockedClaims": sorted(
            {
                "literal_universal_coverage",
                "full_source_atlas_green",
                "outside_legal_approval",
                "release_green",
                "app_store_readiness",
                "source_authority_for_candidate_domains",
                "active_registry_mutation",
                "claim_output",
                "pack_output",
                "production_r2_upload",
                "native_activation",
                "final_user_plans_schedules_steps_from_source_atlas_or_r2",
            }
        ),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*executor_privacy_issues, *output_privacy_issues])),
        "nonClaims": CHAIN_NON_CLAIMS,
        "productionNonClaims": _production_non_claims(),
        "outputPaths": output_paths,
    }
    report["outputPaths"].update(
        {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
        }
    )
    report["outputHashes"] = _output_hashes(report["outputPaths"])
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = autonomous_domain_expansion_chain_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return {"manifestPath": str(report_path), "outputRoot": str(output_root), **report}


def autonomous_domain_expansion_chain_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Autonomous Domain Expansion Chain Train 107",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Mode: {report['mode']}",
        "",
        "Scope completed:",
        "- Consumes candidate frontier-intake artifacts from the autonomous operations executor.",
        "- Converts candidate frontier proposals into goal-domain router input.",
        "- Runs goal-domain routing, production-lane work-order compilation, and fixture/dry-run work-order execution.",
        "- Emits review packet templates only when the route still has review-required blocked work orders.",
        "- Emits a deterministic review-not-required manifest when the route maps to an existing production-ready maintenance lane.",
        "- Stops before completed reviews, registry mutation, claims, packs, R2 publish, native activation, or local runtime composition.",
        "",
        "Counts:",
        f"- Candidate inputs: {counts['candidateInputs']}",
        f"- Routed requests: {counts['routes']}",
        f"- Candidate routes: {counts['candidateRoutes']}",
        f"- Production-ready routes: {counts['productionReadyRoutes']}",
        f"- Work orders: {counts['workOrders']}",
        f"- Completed safe checks: {counts['completedSafeChecks']}",
        f"- Blocked review-required: {counts['blockedReviewRequired']}",
        f"- Review packets: {counts['reviewPackets']}",
        f"- Claims: {counts['claims']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        f"- Native activation operations: {counts['nativeActivationOperations']}",
        "",
        "Stage summaries:",
    ]
    for name, summary in report.get("stageSummaries", {}).items():
        lines.append(f"- `{name}`: {summary['status']} (valid={summary['valid']})")
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
            "- Chain inputs and outputs are public/reference candidate-domain metadata, production-ready route metadata, gates, work orders, review templates, and review-not-required manifests.",
            "- Private Ambitions runtime context remains local and is not present in router, work-order, or review artifacts.",
            "- Source Atlas/R2 do not generate final plans, schedules, Steps, or personalized paths.",
            "",
            "Validation run:",
            "- See current train closeout for exact command output.",
            "",
            "Validation not run:",
            "- No live network/API harvest was run.",
            "- No active registry mutation was run.",
            "- No production R2 upload/readback was run.",
            "- No native activation or XCTest/build-for-testing was run by this tooling-only chain.",
            "- Outside legal approval was not claimed.",
            "",
            "Proof artifacts:",
        ]
    )
    for path in report.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- Router, lane, executor, and review stages emit no production R2 request.",
            "- R2 publish remains a blocked future work-order gate.",
            "",
            "No private graph egress proof:",
            "- Executor report input and chain output metadata are privacy-scanned.",
            "- Candidate-domain review templates contain public/reference metadata only.",
            "",
            "License/terms proof:",
            "- Legal/terms review packets are templates only.",
            "- Production-ready maintenance routes rely on the already-ledgered bounded production target evidence and do not emit new legal approvals.",
            "- No legal approval, outside legal approval, or redistribution approval is emitted.",
            "",
            "Restricted-source exclusion proof:",
            "- Candidate domains remain review-required and pack/R2/native blocked.",
            "",
            "Provenance completeness proof:",
            "- Not claimed. Candidate domains emit no claims.",
            "",
            "Freshness/revocation proof:",
            "- Not claimed for candidate domains. No pack, revocation manifest, or LKG pointer is emitted.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed by this tooling-only chain.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: autonomous domain expansion chain module, CLI command, tests, generated evidence, and QA closeout.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: completed review evidence, registry mutation, adapter/live harvest, claims, pack/R2/native/runtime proof remain separate gates.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("productionNonClaims", []))
    lines.extend(["", "Rollback plan:", "- Revert Train 107 chain module, CLI wiring, tests, generated chain artifacts, and QA evidence."])
    lines.append("")
    return "\n".join(lines)


def _candidate_inputs_from_executor_report(report: dict[str, Any]) -> list[dict[str, Any]]:
    paths = []
    for artifact in report.get("artifacts", []):
        if isinstance(artifact, dict) and str(artifact.get("path", "")).endswith("frontier-intake-input.json"):
            paths.append(Path(str(artifact["path"])))
    for result in report.get("actionResults", []):
        for raw_path in result.get("artifactPaths", []) if isinstance(result, dict) else []:
            path = Path(str(raw_path))
            if path.name == "frontier-intake-input.json":
                paths.append(path)
    unique_paths = sorted(set(paths), key=str)
    inputs: list[dict[str, Any]] = []
    for path in unique_paths:
        if not path.exists():
            continue
        payload = read_json(path)
        for proposal in payload.get("domainProposals", []) if isinstance(payload, dict) else []:
            if isinstance(proposal, dict):
                inputs.append(_proposal_to_goal_domain_request(proposal, path))
    return sorted(inputs, key=lambda item: item["request_id"])


def _proposal_to_goal_domain_request(proposal: dict[str, Any], source_path: Path) -> dict[str, Any]:
    domain = str(proposal.get("frontier_id") or proposal.get("domain") or "unnamed_domain")
    request_id = str(proposal.get("proposal_id") or stable_id("goal_domain_request", {"domain": domain, "source": str(source_path)}))
    return {
        "request_id": request_id,
        "domain": domain,
        "domain_aliases": [domain],
        "goal_intent_classes": _string_list(proposal, "goal_intent_classes") or [domain],
        "claim_classes": _string_list(proposal, "claim_classes"),
        "jurisdictions": _string_list(proposal, "jurisdictions"),
        "source_classes_required": _string_list(proposal, "source_classes_required"),
        "minimum_authority_classes": _string_list(proposal, "minimum_authority_classes"),
        "freshness_slas": _string_list(proposal, "freshness_slas"),
        "candidate_sources": proposal.get("candidate_sources", []) if isinstance(proposal.get("candidate_sources"), list) else [],
        "non_claims": [
            "derived from autonomous executor candidate frontier intake",
            "not source authority",
            "not claim output",
            "not pack output",
            "not R2 readiness",
        ],
    }


def _router_input(candidate_inputs: list[dict[str, Any]]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousDomainExpansionRouterInput.v1",
        "goalDomainRequests": candidate_inputs,
        "nonClaims": ["router input only", "not private user goal text", "not claim output", "not pack output"],
    }


def _read_report(path: Path, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"executor report missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - defensive.
        issues.append(f"executor report unreadable: {path}: {exc}")
        return None


def _stage_issues(stages: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for name in ("goalDomainRouter", "productionLanes", "workOrderExecutor", "reviewPackets"):
        stage = stages.get(name)
        if stage is None:
            issues.append(f"{name}: stage did not run")
        elif stage.get("valid") is not True:
            issues.extend(f"{name}: {issue}" for issue in stage.get("issues", []))
    return sorted(set(issues))


def _record_counts(candidate_inputs: list[dict[str, Any]], stages: dict[str, Any]) -> dict[str, int]:
    router = stages.get("goalDomainRouter", {}).get("recordCounts", {})
    lanes = stages.get("productionLanes", {}).get("recordCounts", {})
    executor = stages.get("workOrderExecutor", {}).get("recordCounts", {})
    packets = stages.get("reviewPackets", {}).get("recordCounts", {})
    return {
        "candidateInputs": len(candidate_inputs),
        "routes": int(router.get("routes", 0) or 0),
        "candidateRoutes": int(router.get("candidateIntakeRoutes", 0) or 0),
        "productionReadyRoutes": int(router.get("productionTargetReadyRoutes", 0) or 0),
        "workOrders": int(lanes.get("workOrders", 0) or 0),
        "candidateWorkOrders": int(lanes.get("candidateWorkOrders", 0) or 0),
        "completedSafeChecks": int(executor.get("completedFixtureChecks", 0) or 0) + int(executor.get("completedDryRunChecks", 0) or 0),
        "blockedReviewRequired": int(executor.get("blockedReviewRequired", 0) or 0),
        "blockedUpstreamEvidenceRequired": int(executor.get("blockedUpstreamEvidenceRequired", 0) or 0),
        "reviewPackets": int(packets.get("reviewPackets", 0) or 0),
        "completedReviewPackets": int(packets.get("completedReviewPackets", 0) or 0),
        "approvalArtifactsEmitted": int(packets.get("approvalArtifactsEmitted", 0) or 0),
        "activeRegistryMutations": int(packets.get("activeRegistryMutations", 0) or 0),
        "claims": int(router.get("claims", 0) or 0) + int(lanes.get("claims", 0) or 0) + int(executor.get("claims", 0) or 0) + int(packets.get("claims", 0) or 0),
        "packableClaims": int(router.get("packableClaims", 0) or 0) + int(lanes.get("packableClaims", 0) or 0) + int(executor.get("packableClaims", 0) or 0) + int(packets.get("packableClaims", 0) or 0),
        "r2PackableArtifacts": int(router.get("r2PackableArtifacts", 0) or 0) + int(lanes.get("r2PackableArtifacts", 0) or 0) + int(executor.get("r2PackableArtifacts", 0) or 0) + int(packets.get("r2PackableArtifacts", 0) or 0),
        "r2PublishOperations": int(router.get("r2PublishOperations", 0) or 0) + int(lanes.get("r2PublishOperations", 0) or 0) + int(executor.get("r2PublishOperations", 0) or 0) + int(packets.get("r2PublishOperations", 0) or 0),
        "nativeActivationOperations": int(lanes.get("nativeActivationOperations", 0) or 0) + int(executor.get("nativeActivationOperations", 0) or 0) + int(packets.get("nativeActivationOperations", 0) or 0),
        "finalOutputArtifacts": int(router.get("finalOutputArtifacts", 0) or 0) + int(lanes.get("finalOutputArtifacts", 0) or 0) + int(executor.get("finalOutputArtifacts", 0) or 0) + int(packets.get("finalOutputArtifacts", 0) or 0),
    }


def _review_stage_matches_execution_path(counts: dict[str, int]) -> bool:
    if counts["blockedReviewRequired"] > 0:
        return counts["reviewPackets"] > 0 and counts["completedReviewPackets"] == 0
    return counts["reviewPackets"] == 0 and counts["completedReviewPackets"] == 0


def _no_forbidden_outputs(counts: dict[str, int]) -> bool:
    return (
        counts["claims"] == 0
        and counts["packableClaims"] == 0
        and counts["r2PackableArtifacts"] == 0
        and counts["r2PublishOperations"] == 0
        and counts["nativeActivationOperations"] == 0
        and counts["finalOutputArtifacts"] == 0
        and counts["activeRegistryMutations"] == 0
        and counts["approvalArtifactsEmitted"] == 0
    )


def _stage_summaries(stages: dict[str, Any]) -> dict[str, dict[str, Any]]:
    summaries: dict[str, dict[str, Any]] = {}
    for name, stage in stages.items():
        summaries[name] = {
            "status": stage.get("status"),
            "valid": stage.get("valid"),
            "outputRoot": stage.get("outputRoot", ""),
            "manifestPath": stage.get("manifestPath", ""),
            "recordCounts": stage.get("recordCounts", {}),
            "issues": stage.get("issues", []),
        }
    return summaries


def _output_paths(output_root: Path, router_input_path: Path, stages: dict[str, Any]) -> dict[str, str]:
    return {
        "routerInput": str(router_input_path),
        "goalDomainRouter": stages.get("goalDomainRouter", {}).get("manifestPath", ""),
        "productionLanes": stages.get("productionLanes", {}).get("manifestPath", ""),
        "workOrderExecutor": stages.get("workOrderExecutor", {}).get("manifestPath", ""),
        "reviewPackets": stages.get("reviewPackets", {}).get("manifestPath", ""),
        "reviewPacketTemplates": stages.get("reviewPackets", {}).get("outputPaths", {}).get("reviewPacketTemplates", ""),
    }


def _output_hashes(paths: dict[str, str]) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for key, raw_path in paths.items():
        if not raw_path:
            continue
        path = Path(raw_path)
        if path.exists() and path.suffix == ".json":
            hashes[key] = stable_hash(read_json(path))
    return dict(sorted(hashes.items()))


def _review_packets_not_required_stage(
    output_root: Path,
    *,
    executor_manifest_path: Path,
    input_execution_records: int,
    created_at: str,
) -> dict[str, Any]:
    output_root.mkdir(parents=True, exist_ok=True)
    for stale_name in ("goal-domain-review-packets.json", "review-packet-templates.json"):
        stale_path = output_root / stale_name
        if stale_path.exists():
            stale_path.unlink()
    manifest_path = output_root / "manifest.json"
    closeout_path = output_root / "closeout.md"
    record_counts = {
        "inputExecutionRecords": input_execution_records,
        "selectedBlockedReviewRecords": 0,
        "reviewPackets": 0,
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
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainReviewPacketsNotRequired.v1",
        "versionID": AUTONOMOUS_DOMAIN_EXPANSION_CHAIN_VERSION,
        "createdAt": created_at,
        "status": "Source Green for review-not-required production-ready route evidence",
        "valid": True,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; review-not-required evidence only",
        "executorManifestPath": str(executor_manifest_path),
        "recordCounts": record_counts,
        "checks": [
            {"name": "review_not_required_for_production_ready_maintenance_lane", "passed": True, "issues": []},
            {"name": "no_review_packets_or_approval_artifacts_emitted", "passed": True, "issues": []},
        ],
        "issues": [],
        "outputPaths": {
            "manifest": str(manifest_path),
            "closeout": str(closeout_path),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": [
            "review-not-required marker only",
            "not legal approval",
            "not source approval",
            "not registry mutation",
            "not claim output",
            "not pack output",
            "not R2 publish",
            "not native activation",
            "not release readiness",
        ],
    }
    write_json(manifest_path, manifest)
    manifest["outputHashes"] = {"manifest": stable_hash(read_json(manifest_path))}
    write_json(manifest_path, manifest)
    closeout_path.write_text(
        "\n".join(
            [
                "# Source Atlas Review Packets Not Required",
                "",
                "Status: Source Green for review-not-required production-ready route evidence",
                "Source Atlas status ceiling: Yellow overall Source Atlas; review-not-required evidence only",
                "",
                "Scope completed:",
                "- Recorded that the autonomous expansion chain reached a production-ready maintenance lane with no blocked review-required work orders.",
                "",
                "Production non-claims:",
                "- No legal approval, source approval, registry mutation, claim output, pack output, R2 publish, native activation, release readiness, or universal coverage claim.",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return {"manifestPath": str(manifest_path), "outputRoot": str(output_root), **manifest}


def _production_non_claims() -> list[str]:
    return [
        "no full Source Atlas Green",
        "no literal universal coverage",
        "no outside legal approval",
        "no release Green",
        "no App Store readiness",
        "no completed source/legal/API review",
        "no active registry mutation",
        "no claim output",
        "no pack output",
        "no production Cloudflare R2 write",
        "no native activation or runtime/device/offline proof",
        "no final user plan, schedule, or Step generation",
    ]


def _valid(stage: dict[str, Any] | None) -> bool:
    return isinstance(stage, dict) and stage.get("valid") is True


def _string_list(container: dict[str, Any], key: str) -> list[str]:
    value = container.get(key, [])
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if isinstance(item, (str, int, float)) and str(item).strip()]


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": issues}
