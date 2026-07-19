"""End-to-end autonomous Source Atlas operations chain.

This train composes the current deterministic Source Atlas operation layers:
planning, gated execution, candidate-domain expansion, and registry activation
readiness. It chooses the candidate path only when the executor actually emits
candidate frontier-intake artifacts; current production-ready domains are
observed and recorded without creating stale review or registry work.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .autonomous_domain_expansion_chain import (
    AutonomousDomainExpansionChainOptions,
    run_autonomous_domain_expansion_chain,
)
from .autonomous_operations_executor import (
    AutonomousOperationsExecutorOptions,
    run_autonomous_operations_executor,
)
from .autonomous_operations_planner import (
    AUTONOMOUS_OPERATIONS_NON_CLAIMS,
    AutonomousOperationsPlannerOptions,
    compile_autonomous_operations_plan,
)
from .autonomous_registry_activation_chain import (
    AutonomousRegistryActivationChainOptions,
    run_autonomous_registry_activation_chain,
)
from .boundary import boundary_issue_strings, boundary_issues_for_value
from .governance_registry import API_GOVERNANCE_REGISTRY_PATH, LEGAL_TERMS_REGISTRY_PATH, SOURCE_LANE_REGISTRY_PATH
from .model import PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json
from .production_recertification_gate import (
    ProductionRecertificationOptions,
    run_production_recertification_gate,
)


AUTONOMOUS_END_TO_END_CHAIN_VERSION = "source-atlas-autonomous-end-to-end-chain-train-113"
AUTONOMOUS_END_TO_END_CHAIN_KIND = "ambitions.sourceAtlas.autonomousEndToEndChain.v1"

CHAIN_NON_CLAIMS = [
    "autonomous end-to-end operations chain only",
    "not uncontrolled live harvest",
    "not automatic production R2 write",
    "not active registry mutation",
    "not outside legal approval",
    "not full Source Atlas Green",
    "not literal universal coverage",
    "not release readiness",
    "not App Store or TestFlight readiness",
    "not native device/offline proof",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    *AUTONOMOUS_OPERATIONS_NON_CLAIMS,
]


@dataclass(frozen=True)
class AutonomousEndToEndChainOptions:
    frontier_config_path: Path
    source_lane_registry_path: Path
    output_root: Path
    production_target_ledger_path: Path | None = None
    production_recertification_path: Path | None = None
    gateway_release_report_path: Path | None = None
    native_runtime_report_path: Path | None = None
    native_registry_artifact_path: Path | None = None
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    requested_domains: tuple[str, ...] = ()
    created_at: str = "2026-06-28T00:00:00Z"
    refresh_production_recertification: bool = False
    execute_safe_actions: bool = False
    allow_fixture_delivery_chain: bool = False
    delivery_chain_limit: int = 5
    domain_expansion_mode: str = "fixture"
    reviewer: str = ""


def run_autonomous_end_to_end_chain(options: AutonomousEndToEndChainOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    input_bundle = {
        "frontierConfigPath": str(options.frontier_config_path),
        "sourceLaneRegistryPath": str(options.source_lane_registry_path),
        "productionTargetLedgerPath": str(options.production_target_ledger_path) if options.production_target_ledger_path else None,
        "productionRecertificationPath": str(options.production_recertification_path) if options.production_recertification_path else None,
        "gatewayReleaseReportPath": str(options.gateway_release_report_path) if options.gateway_release_report_path else None,
        "nativeRuntimeReportPath": str(options.native_runtime_report_path) if options.native_runtime_report_path else None,
        "nativeRegistryArtifactPath": str(options.native_registry_artifact_path) if options.native_registry_artifact_path else None,
        "legalTermsRegistryPath": str(options.legal_terms_registry_path) if options.legal_terms_registry_path else None,
        "apiGovernanceRegistryPath": str(options.api_governance_registry_path) if options.api_governance_registry_path else None,
        "requestedDomains": list(options.requested_domains),
        "refreshProductionRecertification": options.refresh_production_recertification,
        "executeSafeActions": options.execute_safe_actions,
        "allowFixtureDeliveryChain": options.allow_fixture_delivery_chain,
        "deliveryChainLimit": options.delivery_chain_limit,
        "domainExpansionMode": options.domain_expansion_mode,
        "reviewer": options.reviewer,
    }
    input_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(input_bundle, "source-atlas-autonomous-end-to-end-chain-input")
    )
    issues.extend(input_privacy_issues)

    stages: dict[str, Any] = {}
    recertification_path = options.production_recertification_path
    if not input_privacy_issues:
        recertification_issues = _refresh_recertification_issues(options)
        issues.extend(recertification_issues)
        if not recertification_issues and options.refresh_production_recertification:
            stages["productionRecertification"] = run_production_recertification_gate(
                ProductionRecertificationOptions(
                    production_target_ledger_path=options.production_target_ledger_path,  # type: ignore[arg-type]
                    gateway_release_report_path=options.gateway_release_report_path,  # type: ignore[arg-type]
                    native_runtime_report_path=options.native_runtime_report_path,  # type: ignore[arg-type]
                    native_registry_artifact_path=options.native_registry_artifact_path,
                    output_root=output_root / "00-production-recertification",
                    created_at=options.created_at,
                )
            )
            if _valid(stages.get("productionRecertification")):
                recertification_path = Path(stages["productionRecertification"]["outputPaths"]["report"])
        stages["operationsPlan"] = compile_autonomous_operations_plan(
            AutonomousOperationsPlannerOptions(
                frontier_config_path=options.frontier_config_path,
                source_lane_registry_path=options.source_lane_registry_path,
                production_target_ledger_path=options.production_target_ledger_path,
                production_recertification_path=recertification_path,
                requested_domains=options.requested_domains,
                output_root=output_root / "01-autonomous-operations-plan",
                created_at=options.created_at,
            )
        )
        if _valid(stages.get("operationsPlan")):
            stages["operationsExecutor"] = run_autonomous_operations_executor(
                AutonomousOperationsExecutorOptions(
                    operations_plan_path=Path(stages["operationsPlan"]["outputPaths"]["report"]),
                    output_root=output_root / "02-autonomous-operations-execution",
                    created_at=options.created_at,
                    execute_safe_actions=options.execute_safe_actions,
                    allow_fixture_delivery_chain=options.allow_fixture_delivery_chain,
                    frontier_config_path=options.frontier_config_path,
                    delivery_chain_limit=options.delivery_chain_limit,
                )
            )
        if _valid(stages.get("operationsExecutor")):
            frontier_intake_artifacts = _frontier_intake_artifact_count(stages["operationsExecutor"])
            if frontier_intake_artifacts > 0:
                stages["domainExpansion"] = run_autonomous_domain_expansion_chain(
                    AutonomousDomainExpansionChainOptions(
                        executor_report_path=Path(stages["operationsExecutor"]["manifestPath"]),
                        output_root=output_root / "03-autonomous-domain-expansion",
                        frontier_config_path=options.frontier_config_path,
                        production_target_ledger_path=options.production_target_ledger_path,
                        mode=options.domain_expansion_mode,
                        reviewer=options.reviewer,
                        created_at=options.created_at,
                    )
                )
                if _valid(stages.get("domainExpansion")):
                    stages["registryActivation"] = run_autonomous_registry_activation_chain(
                        AutonomousRegistryActivationChainOptions(
                            expansion_chain_report_path=Path(stages["domainExpansion"]["manifestPath"]),
                            output_root=output_root / "04-autonomous-registry-activation",
                            source_lane_registry_path=options.source_lane_registry_path,
                            legal_terms_registry_path=options.legal_terms_registry_path,
                            api_governance_registry_path=options.api_governance_registry_path,
                            created_at=options.created_at,
                        )
                    )
            else:
                stages["domainExpansionNotRequired"] = _domain_expansion_not_required_stage(
                    output_root / "03-domain-expansion-not-required",
                    operations_plan_path=Path(stages["operationsPlan"]["outputPaths"]["report"]),
                    executor_report_path=Path(stages["operationsExecutor"]["manifestPath"]),
                    requested_domains=options.requested_domains,
                    created_at=options.created_at,
                )
                stages["registryActivationNotRequired"] = _registry_activation_not_required_stage(
                    output_root / "04-registry-activation-not-required",
                    domain_expansion_not_required_path=Path(stages["domainExpansionNotRequired"]["manifestPath"]),
                    executor_report_path=Path(stages["operationsExecutor"]["manifestPath"]),
                    created_at=options.created_at,
                )

    issues.extend(_stage_issues(stages))
    record_counts = _record_counts(stages, requested_domains=options.requested_domains)
    output_paths = _output_paths(stages)
    checks = [
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check(
            "production_recertification_refreshed_when_requested",
            _recertification_refresh_check(options, stages),
            _recertification_refresh_check_issues(options, stages),
        ),
        _check("operations_plan_valid", _valid(stages.get("operationsPlan")), _stage_check_issues(stages.get("operationsPlan"))),
        _check("operations_executor_valid", _valid(stages.get("operationsExecutor")), _stage_check_issues(stages.get("operationsExecutor"))),
        _check("candidate_expansion_path_selected_only_when_needed", _candidate_path_matches_executor(stages), _candidate_path_mismatch_issues(stages)),
        _check("registry_activation_path_matches_expansion_path", _registry_path_matches_expansion(stages), _registry_path_mismatch_issues(stages)),
        _check("chain_emits_no_claims_packs_r2_native_or_private_runtime_outputs", _no_forbidden_outputs(record_counts), []),
    ]
    output_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "recordCounts": record_counts,
                "stageSummaries": _stage_summaries(stages),
                "outputPaths": output_paths,
                "nonClaims": CHAIN_NON_CLAIMS,
            },
            "source-atlas-autonomous-end-to-end-chain-output",
        )
    )
    issues.extend(output_privacy_issues)
    checks.append(_check("output_privacy_scan_passed", not output_privacy_issues, output_privacy_issues))
    valid = not issues and all(check["passed"] for check in checks)

    report_path = output_root / "autonomous-end-to-end-chain-report.json"
    markdown_path = output_root / "autonomous-end-to-end-chain-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_END_TO_END_CHAIN_KIND,
        "versionID": AUTONOMOUS_END_TO_END_CHAIN_VERSION,
        "createdAt": options.created_at,
        "chainID": stable_id(
            "source_atlas.autonomous_end_to_end_chain",
            {
                "requestedDomains": list(options.requested_domains),
                "frontierConfigPath": str(options.frontier_config_path),
                "productionTargetLedgerPath": str(options.production_target_ledger_path) if options.production_target_ledger_path else "",
                "productionRecertificationPath": str(options.production_recertification_path) if options.production_recertification_path else "",
                "refreshProductionRecertification": options.refresh_production_recertification,
                "createdAt": options.created_at,
                "executeSafeActions": options.execute_safe_actions,
            },
        ),
        "status": "Source Green for autonomous end-to-end operations chain" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; deterministic autonomous operations orchestration only",
        "executionMode": "execute_safe_actions" if options.execute_safe_actions else "dry_run_plan_observation",
        "refreshProductionRecertification": options.refresh_production_recertification,
        "requestedDomains": list(options.requested_domains),
        "targetRegistryPaths": {
            "sourceLaneRegistry": str(options.source_lane_registry_path or SOURCE_LANE_REGISTRY_PATH),
            "legalTermsRegistry": str(options.legal_terms_registry_path or LEGAL_TERMS_REGISTRY_PATH),
            "apiGovernanceRegistry": str(options.api_governance_registry_path or API_GOVERNANCE_REGISTRY_PATH),
        },
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "stageSummaries": _stage_summaries(stages),
        "stages": stages,
        "allowedClaims": ["deterministic_autonomous_end_to_end_operations_orchestration"] if valid else [],
        "blockedClaims": sorted(
            {
                "literal_universal_coverage",
                "full_source_atlas_green",
                "outside_legal_approval",
                "release_green",
                "app_store_readiness",
                "uncontrolled_live_harvest",
                "automatic_r2_write_without_execute_budget_approval",
                "active_registry_mutation",
                "claim_output_for_candidate_domains",
                "pack_output_for_candidate_domains",
                "production_r2_upload",
                "native_runtime_green_without_device_offline_proof",
                "final_user_plans_schedules_steps_from_source_atlas_or_r2",
            }
        ),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*input_privacy_issues, *output_privacy_issues])),
        "nonClaims": CHAIN_NON_CLAIMS,
        "productionNonClaims": _production_non_claims(),
        "outputPaths": {
            **output_paths,
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
        },
    }
    report["outputHashes"] = _output_hashes(report["outputPaths"])
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = autonomous_end_to_end_chain_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return {"manifestPath": str(report_path), "outputRoot": str(output_root), **report}


def autonomous_end_to_end_chain_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Autonomous End-to-End Chain Train 113",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Execution mode: {report['executionMode']}",
        f"Production recertification refreshed: {'yes' if report.get('refreshProductionRecertification') else 'no'}",
        "",
        "Scope completed:",
        "- Optionally refreshes the bounded production recertification gate before planning when current ledger, gateway, native registry, and native runtime proof inputs are provided.",
        "- Composes autonomous operations planning, gated execution, candidate-domain expansion, and registry activation readiness into one deterministic command.",
        "- Resolves requested domain aliases before execution.",
        "- Observes current production-ready domains without generating review or registry work.",
        "- Runs candidate-domain frontier intake, routing, work-order execution, review packets, and registry readiness rehearsal only when candidate frontier artifacts are actually emitted.",
        "- Stops before live harvest, active registry mutation, pack output, production R2 upload, native runtime proof, release proof, or final user planning behavior.",
        "",
        "Counts:",
        f"- Requested domains: {counts['requestedDomains']}",
        f"- Resolved requested aliases: {counts['resolvedRequestedDomainAliases']}",
        f"- Unmatched requested domains: {counts['unmatchedRequestedDomains']}",
        f"- Planned domains: {counts['plannedDomains']}",
        f"- Observed domains: {counts['observedDomains']}",
        f"- Safe actions executed: {counts['safeActionsExecuted']}",
        f"- Frontier intake artifacts: {counts['frontierIntakeArtifacts']}",
        f"- Candidate expansion stages: {counts['candidateExpansionStages']}",
        f"- Candidate routes: {counts['candidateRoutes']}",
        f"- Production-ready routes: {counts['productionReadyRoutes']}",
        f"- Review packets: {counts['reviewPackets']}",
        f"- Registry activation not required routes: {counts['registryActivationNotRequiredRoutes']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        f"- Native activation operations: {counts['nativeActivationOperations']}",
        f"- Recertified domains: {counts['recertifiedDomains']}",
        f"- Recertification blocked domains: {counts['recertificationBlockedDomains']}",
        f"- Recertification gateway live domains: {counts['recertificationGatewayLiveDomains']}",
        f"- Recertification native registry matches: {counts['recertificationNativeRegistryMatches']}",
        f"- Recertification native runtime frontiers: {counts['recertificationNativeRuntimeFrontiers']}",
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
            "- Chain inputs and outputs are domain IDs, public/reference source IDs, gates, proof paths, candidate governance artifacts, and stage manifests.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 do not generate final plans, schedules, Steps, priority order, or personalized paths.",
            "",
            "Validation run:",
            "- See current train closeout for exact command output.",
            "",
            "Validation not run:",
            "- No live network/API harvest was run.",
            "- No active registry mutation was run.",
            "- No production Cloudflare R2 upload/readback was run.",
            "- No native XCTest/build-for-testing was required for this tooling-only chain.",
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
            "- The chain does not execute production R2 actions.",
            "- Candidate-domain expansion and registry readiness stages emit no R2 object keys or publish requests.",
            "- Current production-ready observation retains existing R2 proof as evidence path only.",
            "",
            "No private graph egress proof:",
            "- Requested domains, stage inputs, and stage outputs are boundary-scanned.",
            "- Private-looking requested domains fail before planning or execution.",
            "",
            "License/terms proof:",
            "- Candidate routes remain review-required and pack/R2 blocked.",
            "- Production-ready observed routes rely on existing ledger/recertification evidence and emit no new legal approval.",
            "- Outside legal approval is not claimed without source-specific approval artifacts.",
            "",
            "Restricted-source exclusion proof:",
            "- Candidate outputs emit no claims, packs, R2 publishes, or native activation.",
            "- Restricted-source exclusion remains enforced by downstream source-lane, legal, pack, and R2 gates.",
            "",
            "Provenance completeness proof:",
            "- Not claimed for new candidate domains because this chain emits no new claims.",
            "",
            "Freshness/revocation proof:",
            "- When refresh is requested, the chain re-runs the production recertification gate and feeds the fresh report into planning.",
            "- No stable pointer, R2 object, revocation manifest, or LKG pointer is modified by this chain.",
            "",
            "LKG/rollback proof:",
            "- No stable pointer, R2 object, or active registry write is changed. Rollback is artifact removal.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed by this tooling-only chain.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: live harvest, production R2 write/readback, native runtime/device/offline proof, release proof, and outside legal approval remain separate proof gates.",
            "- Next repair train if debt remains: connect this end-to-end chain to approved source-specific review evidence, then governed harvest/pack/R2/native recertification gates.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report["productionNonClaims"])
    lines.extend(["", "Rollback plan:", "- Revert Train 113 end-to-end recertification bridge changes, CLI wiring, tests, generated chain artifacts, and QA evidence."])
    lines.append("")
    return "\n".join(lines)


def _domain_expansion_not_required_stage(
    output_root: Path,
    *,
    operations_plan_path: Path,
    executor_report_path: Path,
    requested_domains: tuple[str, ...],
    created_at: str,
) -> dict[str, Any]:
    output_root.mkdir(parents=True, exist_ok=True)
    manifest_path = output_root / "manifest.json"
    closeout_path = output_root / "closeout.md"
    record_counts = {
        "requestedDomains": len(requested_domains),
        "frontierIntakeArtifacts": 0,
        "candidateExpansionStages": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
        "activeRegistryMutations": 0,
    }
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousDomainExpansionNotRequired.v1",
        "versionID": AUTONOMOUS_END_TO_END_CHAIN_VERSION,
        "createdAt": created_at,
        "status": "Source Green for domain-expansion-not-required route evidence",
        "valid": True,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; no-expansion evidence only",
        "operationsPlanPath": str(operations_plan_path),
        "executorReportPath": str(executor_report_path),
        "recordCounts": record_counts,
        "checks": [
            {"name": "executor_emitted_no_candidate_frontier_intake_artifacts", "passed": True, "issues": []},
            {"name": "no_candidate_expansion_or_review_artifacts_emitted", "passed": True, "issues": []},
        ],
        "issues": [],
        "outputPaths": {"manifest": str(manifest_path), "closeout": str(closeout_path)},
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": [
            "domain-expansion-not-required marker only",
            "not source approval",
            "not legal approval",
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
                "# Source Atlas Domain Expansion Not Required",
                "",
                "Status: Source Green for domain-expansion-not-required route evidence",
                "Source Atlas status ceiling: Yellow overall Source Atlas; no-expansion evidence only",
                "",
                "Scope completed:",
                "- Recorded that the end-to-end chain observed current production-ready domains and emitted no candidate frontier-intake artifacts.",
                "",
                "Production non-claims:",
                "- No source approval, legal approval, registry mutation, claim output, pack output, R2 publish, native activation, release readiness, or universal coverage claim.",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return {"manifestPath": str(manifest_path), "outputRoot": str(output_root), **manifest}


def _registry_activation_not_required_stage(
    output_root: Path,
    *,
    domain_expansion_not_required_path: Path,
    executor_report_path: Path,
    created_at: str,
) -> dict[str, Any]:
    output_root.mkdir(parents=True, exist_ok=True)
    manifest_path = output_root / "manifest.json"
    closeout_path = output_root / "closeout.md"
    record_counts = {
        "registryActivationNotRequiredRoutes": 1,
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
        "kind": "ambitions.sourceAtlas.autonomousEndToEndRegistryActivationNotRequired.v1",
        "versionID": AUTONOMOUS_END_TO_END_CHAIN_VERSION,
        "createdAt": created_at,
        "status": "Source Green for registry-activation-not-required end-to-end evidence",
        "valid": True,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; registry-activation-not-required evidence only",
        "domainExpansionNotRequiredPath": str(domain_expansion_not_required_path),
        "executorReportPath": str(executor_report_path),
        "recordCounts": record_counts,
        "checks": [
            {"name": "no_candidate_expansion_means_no_registry_activation", "passed": True, "issues": []},
            {"name": "no_review_completion_or_registry_mutation_emitted", "passed": True, "issues": []},
        ],
        "issues": [],
        "outputPaths": {"manifest": str(manifest_path), "closeout": str(closeout_path)},
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": [
            "registry-activation-not-required marker only",
            "not active registry mutation",
            "not source approval",
            "not legal approval",
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
                "# Source Atlas End-to-End Registry Activation Not Required",
                "",
                "Status: Source Green for registry-activation-not-required end-to-end evidence",
                "Source Atlas status ceiling: Yellow overall Source Atlas; registry-activation-not-required evidence only",
                "",
                "Scope completed:",
                "- Recorded that no registry activation path was needed because the end-to-end chain emitted no candidate expansion artifacts.",
                "",
                "Production non-claims:",
                "- No active registry mutation, source approval, legal approval, claim output, pack output, R2 publish, native activation, release readiness, or universal coverage claim.",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return {"manifestPath": str(manifest_path), "outputRoot": str(output_root), **manifest}


def _frontier_intake_artifact_count(executor_report: dict[str, Any]) -> int:
    counts = executor_report.get("recordCounts", {}) if isinstance(executor_report.get("recordCounts"), dict) else {}
    count = int(counts.get("frontierIntakeArtifacts", 0) or 0)
    if count:
        return count
    return sum(1 for artifact in executor_report.get("artifacts", []) if isinstance(artifact, dict) and artifact.get("kind") == "frontier_intake")


def _refresh_recertification_issues(options: AutonomousEndToEndChainOptions) -> list[str]:
    if not options.refresh_production_recertification:
        return []
    issues: list[str] = []
    required = {
        "production target ledger": options.production_target_ledger_path,
        "gateway release report": options.gateway_release_report_path,
        "native runtime report": options.native_runtime_report_path,
    }
    for label, path in required.items():
        if path is None:
            issues.append(f"refresh production recertification requires {label} path")
        elif not path.exists():
            issues.append(f"refresh production recertification {label} does not exist: {path}")
    if options.native_registry_artifact_path is not None and not options.native_registry_artifact_path.exists():
        issues.append(f"refresh production recertification native registry artifact does not exist: {options.native_registry_artifact_path}")
    return issues


def _recertification_refresh_check(options: AutonomousEndToEndChainOptions, stages: dict[str, Any]) -> bool:
    if not options.refresh_production_recertification:
        return "productionRecertification" not in stages
    return _valid(stages.get("productionRecertification"))


def _recertification_refresh_check_issues(options: AutonomousEndToEndChainOptions, stages: dict[str, Any]) -> list[str]:
    if _recertification_refresh_check(options, stages):
        return []
    if not options.refresh_production_recertification:
        return ["production recertification stage ran without refresh request"]
    return _stage_check_issues(stages.get("productionRecertification"))


def _stage_issues(stages: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for name, stage in stages.items():
        if isinstance(stage, dict) and stage.get("valid") is not True:
            issues.extend(f"{name}: {issue}" for issue in stage.get("issues", []) or stage.get("evaluationIssues", []))
    return issues


def _stage_check_issues(stage: Any) -> list[str]:
    if isinstance(stage, dict):
        return list(stage.get("issues", []) or stage.get("evaluationIssues", []))
    return ["stage did not run"]


def _candidate_path_matches_executor(stages: dict[str, Any]) -> bool:
    executor = stages.get("operationsExecutor")
    if not _valid(executor):
        return False
    has_frontier_artifacts = _frontier_intake_artifact_count(executor) > 0
    if has_frontier_artifacts:
        return _valid(stages.get("domainExpansion")) and "domainExpansionNotRequired" not in stages
    return _valid(stages.get("domainExpansionNotRequired")) and "domainExpansion" not in stages


def _candidate_path_mismatch_issues(stages: dict[str, Any]) -> list[str]:
    if _candidate_path_matches_executor(stages):
        return []
    executor = stages.get("operationsExecutor")
    if not _valid(executor):
        return ["operations executor did not run or is invalid"]
    if _frontier_intake_artifact_count(executor) > 0:
        return ["frontier intake artifacts require candidate domain expansion stage"]
    return ["no frontier intake artifacts should emit domainExpansionNotRequired only"]


def _registry_path_matches_expansion(stages: dict[str, Any]) -> bool:
    if "domainExpansion" in stages:
        return _valid(stages.get("registryActivation")) and "registryActivationNotRequired" not in stages
    if "domainExpansionNotRequired" in stages:
        return _valid(stages.get("registryActivationNotRequired")) and "registryActivation" not in stages
    return False


def _registry_path_mismatch_issues(stages: dict[str, Any]) -> list[str]:
    if _registry_path_matches_expansion(stages):
        return []
    if "domainExpansion" in stages:
        return ["candidate domain expansion requires registry activation readiness stage"]
    if "domainExpansionNotRequired" in stages:
        return ["no-expansion path requires registryActivationNotRequired stage only"]
    return ["domain expansion path did not run"]


def _record_counts(stages: dict[str, Any], *, requested_domains: tuple[str, ...]) -> dict[str, int]:
    recert_counts = _counts(stages.get("productionRecertification"))
    plan_counts = _counts(stages.get("operationsPlan"))
    executor_counts = _counts(stages.get("operationsExecutor"))
    expansion_counts = _counts(stages.get("domainExpansion"))
    registry_counts = _counts(stages.get("registryActivation"))
    no_expansion_counts = _counts(stages.get("domainExpansionNotRequired"))
    no_registry_counts = _counts(stages.get("registryActivationNotRequired"))
    return {
        "requestedDomains": int(plan_counts.get("requestedDomains", len(requested_domains)) or 0),
        "resolvedRequestedDomainAliases": int(plan_counts.get("resolvedRequestedDomainAliases", 0) or 0),
        "unmatchedRequestedDomains": int(plan_counts.get("unmatchedRequestedDomains", 0) or 0),
        "plannedDomains": int(plan_counts.get("plannedDomains", executor_counts.get("plannedDomains", 0)) or 0),
        "observedDomains": int(executor_counts.get("observedDomains", 0) or 0),
        "safeActionsExecuted": int(executor_counts.get("safeActionsExecuted", 0) or 0),
        "plannedNotExecuted": int(executor_counts.get("plannedNotExecuted", 0) or 0),
        "blockedByGate": int(executor_counts.get("blockedByGate", 0) or 0),
        "frontierIntakeArtifacts": int(executor_counts.get("frontierIntakeArtifacts", 0) or 0),
        "deliveryChainArtifacts": int(executor_counts.get("deliveryChainArtifacts", 0) or 0),
        "candidateExpansionStages": 1 if "domainExpansion" in stages else 0,
        "domainExpansionNotRequiredStages": 1 if "domainExpansionNotRequired" in stages else 0,
        "candidateInputs": int(expansion_counts.get("candidateInputs", 0) or 0),
        "routes": int(expansion_counts.get("routes", 0) or 0),
        "candidateRoutes": int(expansion_counts.get("candidateRoutes", 0) or 0),
        "productionReadyRoutes": int(expansion_counts.get("productionReadyRoutes", 0) or 0),
        "reviewPackets": int(expansion_counts.get("reviewPackets", 0) or 0)
        or int(registry_counts.get("reviewPacketTemplates", 0) or 0),
        "reviewPacketTemplates": int(registry_counts.get("reviewPacketTemplates", 0) or 0),
        "registryActivationNotRequiredRoutes": int(registry_counts.get("registryActivationNotRequiredRoutes", 0) or 0)
        + int(no_registry_counts.get("registryActivationNotRequiredRoutes", 0) or 0),
        "activeRegistryMutations": int(expansion_counts.get("activeRegistryMutations", 0) or 0)
        + int(registry_counts.get("activeRegistryMutations", 0) or 0)
        + int(no_registry_counts.get("activeRegistryMutations", 0) or 0),
        "claims": _sum_count("claims", executor_counts, expansion_counts, registry_counts, no_expansion_counts, no_registry_counts),
        "packableClaims": _sum_count("packableClaims", executor_counts, expansion_counts, registry_counts, no_expansion_counts, no_registry_counts),
        "r2PackableArtifacts": _sum_count("r2PackableArtifacts", executor_counts, expansion_counts, registry_counts, no_expansion_counts, no_registry_counts),
        "r2PublishOperations": _sum_count("r2PublishOperations", executor_counts, expansion_counts, registry_counts, no_expansion_counts, no_registry_counts),
        "nativeActivationOperations": _sum_count("nativeActivationOperations", executor_counts, expansion_counts, registry_counts, no_expansion_counts, no_registry_counts),
        "finalOutputArtifacts": _sum_count("finalOutputArtifacts", executor_counts, expansion_counts, registry_counts, no_expansion_counts, no_registry_counts),
        "productionWritesExecuted": int(executor_counts.get("productionWritesExecuted", 0) or 0),
        "unsafeExecutionAttempts": int(executor_counts.get("unsafeExecutionAttempts", 0) or 0),
        "recertifiedDomains": int(recert_counts.get("recertifiedDomains", 0) or 0),
        "recertificationBlockedDomains": int(recert_counts.get("blockedDomains", 0) or 0),
        "recertificationGatewayLiveDomains": int(recert_counts.get("gatewayLiveDomains", 0) or 0),
        "recertificationNativeRegistryMatches": int(recert_counts.get("nativeRegistryMatches", 0) or 0),
        "recertificationNativeRuntimeFrontiers": int(recert_counts.get("nativeRuntimeFrontiers", 0) or 0),
    }


def _no_forbidden_outputs(counts: dict[str, int]) -> bool:
    return (
        counts["claims"] == 0
        and counts["packableClaims"] == 0
        and counts["r2PackableArtifacts"] == 0
        and counts["r2PublishOperations"] == 0
        and counts["nativeActivationOperations"] == 0
        and counts["finalOutputArtifacts"] == 0
        and counts["activeRegistryMutations"] == 0
        and counts["productionWritesExecuted"] == 0
        and counts["unsafeExecutionAttempts"] == 0
    )


def _sum_count(key: str, *counts: dict[str, Any]) -> int:
    return sum(int(item.get(key, 0) or 0) for item in counts)


def _counts(stage: Any) -> dict[str, Any]:
    if isinstance(stage, dict) and isinstance(stage.get("recordCounts"), dict):
        return stage["recordCounts"]
    return {}


def _stage_summaries(stages: dict[str, Any]) -> dict[str, dict[str, Any]]:
    summaries: dict[str, dict[str, Any]] = {}
    for name, stage in stages.items():
        summaries[name] = {
            "status": stage.get("status") if isinstance(stage, dict) else "",
            "valid": stage.get("valid") if isinstance(stage, dict) else False,
            "outputRoot": stage.get("outputRoot", "") if isinstance(stage, dict) else "",
            "manifestPath": stage.get("manifestPath", "") if isinstance(stage, dict) else "",
            "recordCounts": stage.get("recordCounts", {}) if isinstance(stage, dict) else {},
            "issues": stage.get("issues", []) if isinstance(stage, dict) else ["stage did not run"],
        }
    return summaries


def _output_paths(stages: dict[str, Any]) -> dict[str, str]:
    paths: dict[str, str] = {}
    for name, stage in stages.items():
        if not isinstance(stage, dict):
            continue
        paths[name] = str(stage.get("manifestPath") or stage.get("outputPaths", {}).get("report") or "")
        stage_paths = stage.get("outputPaths", {})
        if isinstance(stage_paths, dict):
            for key, value in stage_paths.items():
                if value:
                    paths[f"{name}.{key}"] = str(value)
    return dict(sorted(paths.items()))


def _output_hashes(paths: dict[str, str]) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for key, raw_path in paths.items():
        if not raw_path:
            continue
        path = Path(raw_path)
        if path.exists() and path.suffix == ".json":
            hashes[key] = stable_hash(read_json(path))
    return dict(sorted(hashes.items()))


def _production_non_claims() -> list[str]:
    return [
        "no full Source Atlas Green",
        "no literal universal coverage",
        "no outside legal approval",
        "no release Green",
        "no App Store readiness",
        "no uncontrolled live harvest",
        "no active registry mutation",
        "no claim output from this chain",
        "no pack output from this chain",
        "no production Cloudflare R2 write",
        "no native runtime/device/offline proof",
        "no final user plan, schedule, or Step generation",
    ]


def _valid(stage: Any) -> bool:
    return isinstance(stage, dict) and stage.get("valid") is True


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": issues}
