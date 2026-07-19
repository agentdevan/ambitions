"""Command line entry point for Source Atlas Foundry."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from . import __version__
from .adapters import ADAPTER_VERSION, harvest_sources
from .api_governance import validate_api_governance, write_api_governance_report
from .arbitrary_goal_domain_gate import (
    ArbitraryDomainHandlingGateOptions,
    arbitrary_domain_handling_gate_markdown,
    run_arbitrary_domain_handling_gate,
)
from .autonomous_operations_planner import (
    AutonomousOperationsPlannerOptions,
    autonomous_operations_plan_markdown,
    compile_autonomous_operations_plan,
)
from .autonomous_operations_executor import (
    AutonomousOperationsExecutorOptions,
    autonomous_operations_execution_markdown,
    run_autonomous_operations_executor,
)
from .autonomous_domain_expansion_chain import (
    AutonomousDomainExpansionChainOptions,
    autonomous_domain_expansion_chain_markdown,
    run_autonomous_domain_expansion_chain,
)
from .autonomous_registry_activation_chain import (
    AutonomousRegistryActivationChainOptions,
    autonomous_registry_activation_chain_markdown,
    run_autonomous_registry_activation_chain,
)
from .autonomous_end_to_end_chain import (
    AutonomousEndToEndChainOptions,
    autonomous_end_to_end_chain_markdown,
    run_autonomous_end_to_end_chain,
)
from .autonomous_control_loop import (
    AutonomousControlLoopOptions,
    autonomous_control_loop_markdown,
    run_autonomous_control_loop,
)
from .autonomous_cycle_runner import (
    AutonomousCycleRunnerOptions,
    autonomous_cycle_runner_markdown,
    run_autonomous_cycle_runner,
)
from .autonomous_cycle_executor import (
    AutonomousCycleExecutorOptions,
    autonomous_cycle_executor_markdown,
    run_autonomous_cycle_executor,
)
from .autonomous_production_orchestrator import (
    AutonomousProductionOrchestratorOptions,
    autonomous_production_orchestrator_markdown,
    run_autonomous_production_orchestrator,
)
from .autonomous_production_supervisor import (
    AutonomousProductionSupervisorOptions,
    autonomous_production_supervisor_markdown,
    run_autonomous_production_supervisor,
)
from .autonomous_freshness_scheduler import (
    AutonomousFreshnessPlannerOptions,
    autonomous_freshness_planner_markdown,
    run_autonomous_freshness_planner,
)
from .autonomous_maintenance_executor import (
    AutonomousMaintenanceExecutorOptions,
    autonomous_maintenance_executor_markdown,
    run_autonomous_maintenance_executor,
)
from .autonomous_promotion_runner import (
    AutonomousPromotionRunnerOptions,
    autonomous_promotion_runner_markdown,
    run_autonomous_promotion_runner,
)
from .source_atlas_completion_audit import (
    SourceAtlasCompletionAuditOptions,
    run_source_atlas_completion_audit,
    source_atlas_completion_audit_markdown,
)
from .source_atlas_launch_floor_ledger import (
    SourceAtlasLaunchFloorLedgerOptions,
    build_source_atlas_launch_floor_ledger,
    source_atlas_launch_floor_ledger_markdown,
)
from .launch_floor_domain_taxonomy import (
    DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH,
    LaunchFloorDomainTaxonomyOptions,
    compile_launch_floor_domain_taxonomy,
    launch_floor_domain_taxonomy_markdown,
)
from .launch_floor_shard_corpus import (
    DEFAULT_LAUNCH_FLOOR_SHARD_CORPUS_PATH,
    LaunchFloorShardCorpusOptions,
    compile_launch_floor_shard_corpus,
    launch_floor_shard_corpus_markdown,
)
from .launch_floor_shard_corpus_compiler import (
    DEFAULT_API_GOVERNANCE_REGISTRY_PATH,
    DEFAULT_LEGAL_TERMS_REGISTRY_PATH,
    DEFAULT_PRODUCTION_TARGET_LEDGER_PATH,
    DEFAULT_SOURCE_LANE_REGISTRY_PATH,
    LaunchFloorShardCorpusCompilerOptions,
    compile_launch_floor_shard_corpus_bulk,
    launch_floor_shard_corpus_compiler_markdown,
)
from .launch_floor_r2_layout_proof import (
    DEFAULT_LAUNCH_FLOOR_SHARD_CORPUS_MANIFEST_PATH,
    READBACK_MODES,
    LaunchFloorR2LayoutProofOptions,
    launch_floor_r2_layout_proof_markdown,
    run_launch_floor_r2_layout_proof,
)
from .launch_floor_native_shard_index_proof import (
    DEFAULT_R2_LAYOUT_INVENTORY_PATH,
    LaunchFloorNativeShardIndexProofOptions,
    launch_floor_native_shard_index_proof_markdown,
    run_launch_floor_native_shard_index_proof,
)
from .launch_floor_golden_intent_corpus import (
    LaunchFloorGoldenIntentCorpusOptions,
    compile_launch_floor_golden_intent_corpus,
    launch_floor_golden_intent_corpus_markdown,
)
from .launch_floor_governance_renewal import (
    LaunchFloorGovernanceRenewalOptions,
    compile_launch_floor_governance_renewal,
    launch_floor_governance_renewal_markdown,
)
from .source_needed_fallback_metric import (
    SourceNeededFallbackMetricOptions,
    compile_source_needed_fallback_metric,
    source_needed_fallback_metric_markdown,
)
from .missing_shard_event_queue import (
    MissingShardEventQueueOptions,
    compile_missing_shard_event_queue,
    missing_shard_event_queue_markdown,
)
from .missing_shard_review_gate import (
    MissingShardReviewGateOptions,
    compile_missing_shard_review_gate,
    missing_shard_review_gate_markdown,
)
from .missing_shard_activation_executor import (
    MissingShardActivationExecutorOptions,
    compile_missing_shard_activation_executor,
    missing_shard_activation_executor_markdown,
)
from .missing_shard_expansion_supervisor import (
    MissingShardExpansionSupervisorOptions,
    compile_missing_shard_expansion_supervisor,
    missing_shard_expansion_supervisor_markdown,
)
from .release_proof_packet import (
    SourceAtlasReleaseProofPacketOptions,
    run_source_atlas_release_proof_packet,
    source_atlas_release_proof_packet_markdown,
)
from .volunteering_public_reference_activation import (
    VolunteeringPublicReferenceActivationOptions,
    run_volunteering_public_reference_activation,
    volunteering_public_reference_activation_markdown,
)
from .boundary_audit import audit_bundle, audit_fixture_root, audit_r2_plan, merge_results
from .broad_domain_discovery import BroadDomainDiscoveryOptions, build_broad_domain_discovery, write_broad_domain_discovery_report
from .broad_occupational_foundation import (
    build_broad_occupational_foundation,
    promote_broad_occupation_pack_proof,
    run_stable_promote_proof,
    write_stable_promotion_report,
)
from .catalog_candidate_review import CatalogCandidateReviewOptions, compile_catalog_candidate_review, write_catalog_candidate_review_report
from .catalog_discovery import CatalogDiscoveryOptions, run_catalog_discovery, write_catalog_discovery_report
from .catalog_governance_intake import CatalogGovernanceIntakeOptions, compile_catalog_governance_intake, write_catalog_governance_intake_report
from .catalog_approval_finalizer import CatalogApprovalFinalizerOptions, compile_catalog_approval_finalizer, write_catalog_approval_finalizer_report
from .catalog_approval_preflight import CatalogApprovalPreflightOptions, compile_catalog_approval_preflight, write_catalog_approval_preflight_report
from .catalog_approval_decision_inputs import (
    CatalogApprovalDecisionInputsOptions,
    compile_catalog_approval_decision_inputs,
    write_catalog_approval_decision_inputs_report,
)
from .catalog_approval_decision_assembler import (
    CatalogApprovalDecisionAssemblerOptions,
    compile_catalog_approval_decision_assembler,
    write_catalog_approval_decision_assembler_report,
)
from .catalog_approval_chain import CatalogApprovalChainOptions, run_catalog_approval_chain, write_catalog_approval_chain_report
from .catalog_reviewer_completion_intake import (
    CatalogReviewerCompletionIntakeOptions,
    compile_catalog_reviewer_completion_intake,
    write_catalog_reviewer_completion_intake_report,
)
from .catalog_reviewer_completion_template import (
    CatalogReviewerCompletionTemplateOptions,
    compile_catalog_reviewer_completion_template,
    write_catalog_reviewer_completion_template_report,
)
from .catalog_review_work_queue import (
    CatalogReviewWorkQueueOptions,
    compile_catalog_review_work_queue,
    write_catalog_review_work_queue_report,
)
from .catalog_direct_source_resolution import (
    CatalogDirectSourceResolutionOptions,
    compile_catalog_direct_source_resolution,
    write_catalog_direct_source_resolution_report,
)
from .catalog_direct_source_review_gate import (
    CatalogDirectSourceReviewGateOptions,
    compile_catalog_direct_source_review_gate,
    write_catalog_direct_source_review_gate_report,
)
from .catalog_direct_source_review_template import (
    CatalogDirectSourceReviewTemplateOptions,
    compile_catalog_direct_source_review_template,
    write_catalog_direct_source_review_template_report,
)
from .catalog_direct_source_review_completion import (
    CatalogDirectSourceReviewCompletionOptions,
    compile_catalog_direct_source_review_completion,
    write_catalog_direct_source_review_completion_report,
)
from .catalog_direct_source_approval_chain import (
    CatalogDirectSourceApprovalChainOptions,
    run_catalog_direct_source_approval_chain,
    write_catalog_direct_source_approval_chain_report,
)
from .catalog_registry_approval_request import CatalogRegistryApprovalRequestOptions, compile_catalog_registry_approval_request, write_catalog_registry_approval_request_report
from .catalog_registry_applier import CatalogRegistryApplierOptions, compile_catalog_registry_applier, write_catalog_registry_applier_report
from .catalog_registry_mutation_plan import CatalogRegistryMutationPlanOptions, compile_catalog_registry_mutation_plan, write_catalog_registry_mutation_plan_report
from .catalog_terms_resolution import CatalogTermsResolutionOptions, compile_catalog_terms_resolution, write_catalog_terms_resolution_report
from .catalog_transport import CatalogTransportOptions, run_catalog_transport, write_catalog_transport_report
from .certification import ADAPTER_CERTIFICATIONS, certify_registry, certified_source_records
from .compiler import compile_bundle
from .coverage_benchmark import coverage_diff, run_golden_benchmarks
from .claim_frontier import ClaimFrontierOptions, compile_claim_frontier
from .frontier_intake import FrontierIntakeOptions, compile_frontier_intake, write_frontier_intake_report
from .deep_research_frontier_intake import (
    DeepResearchFrontierIntakeOptions,
    deep_research_frontier_intake_markdown,
    run_deep_research_frontier_intake,
)
from .goal_domain_production_lanes import GoalDomainProductionLaneOptions, compile_goal_domain_production_lanes, write_goal_domain_production_lanes_report
from .goal_domain_active_registry_apply_gate import (
    GoalDomainActiveRegistryApplyGateOptions,
    compile_goal_domain_active_registry_apply_gate,
    write_goal_domain_active_registry_apply_gate_report,
)
from .goal_domain_production_activation import (
    GoalDomainProductionActivationOptions,
    compile_goal_domain_production_activation,
    write_goal_domain_production_activation_report,
)
from .goal_domain_registry_apply_rehearsal import (
    GoalDomainRegistryApplyRehearsalOptions,
    run_goal_domain_registry_apply_rehearsal,
    write_goal_domain_registry_apply_rehearsal_report,
)
from .goal_domain_registry_applier import (
    GoalDomainRegistryApplierOptions,
    compile_goal_domain_registry_applier,
    write_goal_domain_registry_applier_report,
)
from .goal_domain_registry_mutation_plan import (
    GoalDomainRegistryMutationPlanOptions,
    compile_goal_domain_registry_mutation_plan,
    write_goal_domain_registry_mutation_plan_report,
)
from .goal_domain_review_completion_intake import (
    GoalDomainReviewCompletionIntakeOptions,
    compile_goal_domain_review_completion_intake,
    write_goal_domain_review_completion_intake_report,
)
from .goal_domain_review_packets import GoalDomainReviewPacketOptions, compile_goal_domain_review_packets, write_goal_domain_review_packets_report
from .goal_domain_router import GoalDomainRouterOptions, compile_goal_domain_router, write_goal_domain_router_report
from .goal_domain_source_specific_apply_packet import (
    GoalDomainSourceSpecificApplyPacketOptions,
    compile_goal_domain_source_specific_apply_packet,
    write_goal_domain_source_specific_apply_packet_report,
)
from .goal_domain_work_order_executor import EXECUTOR_MODES, GoalDomainWorkOrderExecutorOptions, run_goal_domain_work_order_executor, write_goal_domain_work_order_executor_report
from .goal_domain_gauntlet import DEFAULT_UNKNOWN_PROBES, GoalDomainGauntletOptions, goal_domain_gauntlet_markdown, run_goal_domain_gauntlet
from .legal_readiness import build_terms_registry, write_legal_review_packet
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, write_json
from .native_refresh_registry import (
    MODE_ORDER,
    NATIVE_REGISTRY_MODES,
    NATIVE_REGISTRY_STATUSES,
    NativeRefreshRegistryOptions,
    compile_native_refresh_registry,
    native_refresh_registry_markdown,
)
from .native_runtime_current_proof import (
    NativeRuntimeCurrentProofOptions,
    native_runtime_current_proof_markdown,
    run_native_runtime_current_proof,
)
from .pack_production import PackProductionOptions, build_pack_production
from .production_domain_admission import (
    ProductionDomainAdmissionOptions,
    build_production_domain_admission,
    production_domain_admission_markdown,
)
from .publisher import build_r2_plan, execute_r2_plan, write_r2_plan
from .public_reference_delivery_chain import (
    DEFAULT_SOURCE_IDS,
    PublicReferenceDeliveryChainOptions,
    public_reference_delivery_chain_markdown,
    run_public_reference_delivery_chain,
)
from .public_reference_adapters import emit_all_adapter_fixtures, run_all_adapters
from .green_reconciliation import build_green_reconciliation
from .governance_registry import validate_governance_registries, write_governance_registry_report
from .harvest_runner import RUN_MODES, GovernedHarvestOptions, run_governed_harvest
from .live_adapter_validation import ADAPTER_ALIASES, LiveRunOptions, run_live_adapter_validation
from .r2_pack_publisher import PUBLISHER_MODES, PackR2PublisherOptions, r2_pack_publisher_markdown, run_pack_r2_publisher
from .r2_live_inventory import R2LiveInventoryOptions, r2_live_inventory_markdown, run_r2_live_inventory
from .r2_hygiene_cleanup import R2HygieneCleanupOptions, r2_hygiene_cleanup_markdown, run_r2_hygiene_cleanup
from .r2_owner_approval import R2OwnerApprovalOptions, build_r2_owner_approval, r2_owner_approval_markdown
from .r2_public_gateway_allowlist import (
    PublicGatewayAllowlistOptions,
    compile_public_gateway_allowlist,
    public_gateway_allowlist_markdown,
)
from .r2_public_gateway_release import (
    DEFAULT_GATEWAY_BASE_URL,
    PublicGatewayReleaseOptions,
    public_gateway_release_markdown,
    run_public_gateway_release,
)
from .production_target_ledger import (
    ProductionTargetLedgerOptions,
    build_production_target_ledger,
    production_target_ledger_markdown,
)
from .production_recertification_gate import (
    ProductionRecertificationOptions,
    production_recertification_markdown,
    run_production_recertification_gate,
)
from .production_finish_line_gate import (
    ProductionFinishLineGateOptions,
    production_finish_line_gate_markdown,
    run_production_finish_line_gate,
)
from .production_sweep import (
    ProductionSweepOptions,
    production_sweep_markdown,
    run_production_sweep,
)
from .registry import PATHWAY_SEEDS, SOURCE_REGISTRY
from .r2_operations_proof import R2_OPERATION_MODES, run_r2_operations_proof
from .r2_contracts import (
    build_last_known_good_manifest,
    build_revocation_manifest,
    freshness_manifest_schema,
    last_known_good_schema,
    release_manifest_schema,
    object_layout,
    revocation_manifest_schema,
    validate_promotion_gate,
    write_manifest_contracts,
)
from .validator import validate_bundle
from .workbench import build_workbench
from .terms_registry import terms_registry_artifact, validate_terms_registry
from .terms_review_packet import build_terms_distribution_review
from .terms_approval_packet import build_terms_approval_packet

try:
    from dotenv import load_dotenv
except ModuleNotFoundError:
    def load_dotenv(*_args: object, **_kwargs: object) -> bool:
        return False


def print_json(value: Any) -> None:
    print(json.dumps(value, indent=2, sort_keys=True, ensure_ascii=False))


def load_foundry_env() -> list[str]:
    source_atlas_root = Path(__file__).resolve().parents[1]
    repo_root = source_atlas_root.parents[1]
    candidates = [
        repo_root / ".env",
        source_atlas_root / ".env",
        Path(__file__).resolve().parent / ".env",
    ]
    loaded: list[str] = []
    for candidate in candidates:
        if candidate.exists() and load_dotenv(candidate, override=False):
            loaded.append(str(candidate))
    return loaded


def doctor() -> dict[str, Any]:
    return {
        "tool": "source-atlas-foundry",
        "version": __version__,
        "sourceCount": len(SOURCE_REGISTRY),
        "adapterSDK": "source-atlas-adapter-sdk-v1",
        "broadCoverageTrain01": {
            "adapters": ["onet.database", "bls.public.data.api", "wikidata.crosswalk", "openalex.dataset", "usajobs.search"],
            "fixtureMode": "deterministic",
            "privateRuntimeBoundary": "Source Atlas gathers public/reference/freshness facts; Private Life Runtime composes locally later.",
        },
        "pathwaySeedCount": len(PATHWAY_SEEDS),
        "adapterVersion": ADAPTER_VERSION,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
        "r2Posture": {
            "default": "staging plan only",
            "directUpload": "requires --execute and --confirm-public-reference-only",
            "credentialHandling": "no credentials are read, stored, or printed by the foundry",
        },
        "envFiles": load_foundry_env(),
        "sourceLanes": sorted({source["adapter"] for source in SOURCE_REGISTRY}),
        "highImpactExamples": [pathway["id"] for pathway in PATHWAY_SEEDS],
    }


def main(argv: list[str] | None = None) -> int:
    load_foundry_env()
    parser = argparse.ArgumentParser(description="Source Atlas Foundry")
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("doctor")
    sub.add_parser("catalog")
    sub.add_parser("sources")
    sub.add_parser("adapters")
    sub.add_parser("certify")
    sub.add_parser("terms-registry")
    sub.add_parser("terms-review")
    terms_approval_parser = sub.add_parser("terms-approval-packet")
    terms_approval_parser.add_argument("--source", action="append", dest="sources")
    terms_approval_parser.add_argument("--json", default="docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-packet-train-27.json")
    terms_approval_parser.add_argument("--created-at")
    terms_approval_parser.add_argument("--reviewer")

    adapter_fixture_parser = sub.add_parser("adapter-fixtures")
    adapter_fixture_parser.add_argument("--output-root", default="tools/source-atlas/fixtures/adapters")

    adapter_run_parser = sub.add_parser("run-adapters")
    adapter_run_parser.add_argument("--source-state", default="current")

    live_parser = sub.add_parser("run-adapters-live")
    live_parser.add_argument("--adapter", choices=sorted(ADAPTER_ALIASES), required=True)
    live_parser.add_argument("--limit", type=int, default=5)
    live_parser.add_argument("--fixture-fallback", choices=["forbidden", "allowed"], default="forbidden")
    live_parser.add_argument("--emit-evidence", required=True)
    live_parser.add_argument("--no-pack", action="store_true")
    live_parser.add_argument("--pack-candidates", action="store_true")
    live_parser.add_argument("--validate-terms", action="store_true")
    live_parser.add_argument("--validate-privacy", action="store_true")
    live_parser.add_argument("--rate-limit-safe", action="store_true")
    live_parser.add_argument("--timeout", type=float, default=20.0)

    broad_parser = sub.add_parser("broad-occupation-pack")
    broad_parser.add_argument("action", nargs="?", choices=["generate", "promote-proof", "stable-promote-proof"], default="generate")
    broad_parser.add_argument("--output-root", default="tools/source-atlas/generated")
    broad_parser.add_argument("--docs-root", default="docs/qa/source-atlas")
    broad_parser.add_argument("--pack-root", default="tools/source-atlas/generated/broad-occupational-foundation")
    broad_parser.add_argument("--dry-run", action="store_true")
    broad_parser.add_argument("--r2-validation-prefix", default="source-atlas/v1/validation/adapter-train-01")
    broad_parser.add_argument("--source-prefix")
    broad_parser.add_argument("--stable-prefix")
    broad_parser.add_argument("--require-owner-approval", action="store_true")
    broad_parser.add_argument("--require-terms-green", action="store_true")
    broad_parser.add_argument("--require-privacy-green", action="store_true")
    broad_parser.add_argument("--require-checksums", action="store_true")
    broad_parser.add_argument("--require-revocation", action="store_true")
    broad_parser.add_argument("--require-lkg", action="store_true")
    broad_parser.add_argument("--require-rollback", action="store_true")
    broad_parser.add_argument("--emit-evidence")
    broad_parser.add_argument("--execute", action="store_true")
    broad_parser.add_argument("--bucket")
    broad_parser.add_argument("--channel", default="validation")
    broad_parser.add_argument("--readback-root")
    broad_parser.add_argument("--confirm-public-reference-only", action="store_true")
    broad_parser.add_argument("--markdown")

    reconcile_parser = sub.add_parser("green-reconciliation")
    reconcile_parser.add_argument("--emit-evidence", default="docs/qa/source-atlas/adapter-broad-coverage-green-reconciliation.json")
    reconcile_parser.add_argument("--live-evidence", default="docs/qa/source-atlas/live-adapter-validation.json")
    reconcile_parser.add_argument("--terms-review", default="docs/qa/source-atlas/source-terms-distribution-review.json")
    reconcile_parser.add_argument("--coverage-ledger", default="docs/qa/source-atlas/source-atlas-coverage-ledger.json")
    reconcile_parser.add_argument("--promotion-proof", default="docs/qa/source-atlas/broad-occupation-pack-promotion-proof.json")
    reconcile_parser.add_argument("--production-r2-proof", default="docs/qa/source-atlas/production-r2-operations-proof.json")


    legal_review_parser = sub.add_parser("legal-review-readiness")
    legal_review_parser.add_argument("--markdown", default="docs/qa/source-atlas/source-atlas-legal-review-readiness.md")
    legal_review_parser.add_argument("--json", default="docs/qa/source-atlas/source-atlas-legal-review-readiness.json")

    api_governance_parser = sub.add_parser("api-governance-check")
    api_governance_parser.add_argument("--config", default="tools/source-atlas/config/source_api_governance.json")
    api_governance_parser.add_argument("--emit-evidence")
    api_governance_parser.add_argument("--markdown")

    governance_parser = sub.add_parser("governance-registry-check")
    governance_parser.add_argument("--source-lanes")
    governance_parser.add_argument("--legal-terms")
    governance_parser.add_argument("--api-governance")
    governance_parser.add_argument("--emit-evidence")
    governance_parser.add_argument("--markdown")

    harvest_parser = sub.add_parser("harvest")
    harvest_parser.add_argument("--output-root", required=True)
    harvest_parser.add_argument("--run-id", required=True)
    harvest_parser.add_argument("--source", action="append", dest="sources")
    harvest_parser.add_argument("--limit", type=int, default=25)

    governed_harvest_parser = sub.add_parser("governed-harvest")
    governed_harvest_parser.add_argument("--output-root", required=True)
    governed_harvest_parser.add_argument("--run-id", required=True)
    governed_harvest_parser.add_argument("--mode", choices=sorted(RUN_MODES), default="fixture")
    governed_harvest_parser.add_argument("--source", action="append", dest="sources")
    governed_harvest_parser.add_argument("--limit", type=int, default=25)
    governed_harvest_parser.add_argument("--live", action="store_true")
    governed_harvest_parser.add_argument("--execute", action="store_true")
    governed_harvest_parser.add_argument("--created-at")

    claim_frontier_parser = sub.add_parser("claim-frontier")
    claim_frontier_parser.add_argument("--input-root", required=True)
    claim_frontier_parser.add_argument("--output-root", required=True)
    claim_frontier_parser.add_argument("--frontier-config")
    claim_frontier_parser.add_argument("--created-at")

    pack_production_parser = sub.add_parser("pack-production")
    pack_production_parser.add_argument("--input-root", required=True)
    pack_production_parser.add_argument("--output-root", required=True)
    pack_production_parser.add_argument("--domain", default="occupation_foundation")
    pack_production_parser.add_argument("--environment", choices=["staging", "production"], default="staging")
    pack_production_parser.add_argument("--channel", default="candidate")
    pack_production_parser.add_argument("--pack-version")
    pack_production_parser.add_argument("--created-at", default="2026-06-27T00:00:00Z")
    pack_production_parser.add_argument("--execute", action="store_true")
    pack_production_parser.add_argument("--approval-artifact")
    pack_production_parser.add_argument("--legal-approval-packet")
    pack_production_parser.add_argument("--budget-policy")

    production_domain_admission_parser = sub.add_parser("production-domain-admission")
    production_domain_admission_parser.add_argument("--domain", required=True)
    production_domain_admission_parser.add_argument("--pack-root", required=True)
    production_domain_admission_parser.add_argument("--output-root", required=True)
    production_domain_admission_parser.add_argument("--frontier-config", default="tools/source-atlas/frontier/coverage-frontiers.json")
    production_domain_admission_parser.add_argument("--production-target-ledger")
    production_domain_admission_parser.add_argument("--legal-approval-packet")
    production_domain_admission_parser.add_argument("--created-at", default="2026-06-29T06:30:00Z")
    production_domain_admission_parser.add_argument("--environment", default="production")
    production_domain_admission_parser.add_argument("--channel", default="stable")
    production_domain_admission_parser.add_argument("--bucket", default="ambitions-source-atlas-prod")
    production_domain_admission_parser.add_argument("--owner")
    production_domain_admission_parser.add_argument("--emit-evidence")
    production_domain_admission_parser.add_argument("--markdown")

    volunteering_public_reference_activation_parser = sub.add_parser("volunteering-public-reference-activation")
    volunteering_public_reference_activation_parser.add_argument("--output-root", required=True)
    volunteering_public_reference_activation_parser.add_argument("--frontier-config", default="tools/source-atlas/frontier/coverage-frontiers.json")
    volunteering_public_reference_activation_parser.add_argument("--created-at", default="2026-06-29T05:30:00Z")
    volunteering_public_reference_activation_parser.add_argument("--run-label", default="current")
    volunteering_public_reference_activation_parser.add_argument("--emit-evidence")
    volunteering_public_reference_activation_parser.add_argument("--markdown")

    r2_pack_publisher_parser = sub.add_parser("pack-r2-publisher")
    r2_pack_publisher_parser.add_argument("--pack-root", required=True)
    r2_pack_publisher_parser.add_argument("--output-root", required=True)
    r2_pack_publisher_parser.add_argument("--environment", choices=["staging", "production"], default="staging")
    r2_pack_publisher_parser.add_argument("--channel", default="candidate")
    r2_pack_publisher_parser.add_argument("--mode", choices=sorted(PUBLISHER_MODES), default="dry_run")
    r2_pack_publisher_parser.add_argument("--created-at", default="2026-06-27T00:00:00Z")
    r2_pack_publisher_parser.add_argument("--execute", action="store_true")
    r2_pack_publisher_parser.add_argument("--approval-artifact")
    r2_pack_publisher_parser.add_argument("--legal-approval-packet")
    r2_pack_publisher_parser.add_argument("--budget-policy")
    r2_pack_publisher_parser.add_argument("--bucket")
    r2_pack_publisher_parser.add_argument("--local-store-root")
    r2_pack_publisher_parser.add_argument("--readback-root")
    r2_pack_publisher_parser.add_argument("--corrupt-readback-label")
    r2_pack_publisher_parser.add_argument("--production-target-ledger")
    r2_pack_publisher_parser.add_argument("--production-domain-admission")
    r2_pack_publisher_parser.add_argument("--env-file", action="append", dest="env_files")
    r2_pack_publisher_parser.add_argument("--emit-evidence")
    r2_pack_publisher_parser.add_argument("--markdown")

    r2_live_inventory_parser = sub.add_parser("r2-live-inventory")
    r2_live_inventory_parser.add_argument("--production-target-ledger", required=True)
    r2_live_inventory_parser.add_argument("--output-root", required=True)
    r2_live_inventory_parser.add_argument("--hygiene-policy", default="tools/source-atlas/governance/r2-production-hygiene-policy.json")
    r2_live_inventory_parser.add_argument("--bucket", default="ambitions-source-atlas-prod")
    r2_live_inventory_parser.add_argument("--prefix", default="source-atlas/")
    r2_live_inventory_parser.add_argument("--env-file", action="append", dest="env_files")
    r2_live_inventory_parser.add_argument("--account-id")
    r2_live_inventory_parser.add_argument("--created-at", default="2026-06-29T00:00:00Z")
    r2_live_inventory_parser.add_argument("--verify-known-checksums", action="store_true")
    r2_live_inventory_parser.add_argument("--max-checksum-reads", type=int)
    r2_live_inventory_parser.add_argument("--emit-evidence")
    r2_live_inventory_parser.add_argument("--markdown")

    r2_hygiene_cleanup_parser = sub.add_parser("r2-hygiene-cleanup")
    r2_hygiene_cleanup_parser.add_argument("--inventory", required=True)
    r2_hygiene_cleanup_parser.add_argument("--output-root", required=True)
    r2_hygiene_cleanup_parser.add_argument("--bucket", default="ambitions-source-atlas-prod")
    r2_hygiene_cleanup_parser.add_argument("--prefix", default="source-atlas/")
    r2_hygiene_cleanup_parser.add_argument("--env-file", action="append", dest="env_files")
    r2_hygiene_cleanup_parser.add_argument("--account-id")
    r2_hygiene_cleanup_parser.add_argument("--created-at", default="2026-06-29T00:00:00Z")
    r2_hygiene_cleanup_parser.add_argument("--execute", action="store_true")
    r2_hygiene_cleanup_parser.add_argument("--emit-evidence")
    r2_hygiene_cleanup_parser.add_argument("--markdown")

    r2_owner_approval_parser = sub.add_parser("r2-owner-approval")
    r2_owner_approval_parser.add_argument("--production-target-ledger", required=True)
    r2_owner_approval_parser.add_argument("--production-finish-line-gate", required=True)
    r2_owner_approval_parser.add_argument("--output-root", required=True)
    r2_owner_approval_parser.add_argument("--created-at", default="2026-06-29T01:20:00Z")
    r2_owner_approval_parser.add_argument("--environment", default="production")
    r2_owner_approval_parser.add_argument("--channel", default="stable")
    r2_owner_approval_parser.add_argument("--bucket", default="ambitions-source-atlas-prod")
    r2_owner_approval_parser.add_argument("--owner")
    r2_owner_approval_parser.add_argument("--emit-evidence")
    r2_owner_approval_parser.add_argument("--markdown")

    native_refresh_parser = sub.add_parser("native-refresh-registry")
    native_refresh_parser.add_argument("--publisher-report", action="append", required=True)
    native_refresh_parser.add_argument("--output-root", required=True)
    native_refresh_parser.add_argument("--created-at", default="2026-06-28T00:00:00Z")
    native_refresh_parser.add_argument("--app-version", default="1.0")
    native_refresh_parser.add_argument("--pack-schema-version", default="1.0.0")
    native_refresh_parser.add_argument("--status", choices=sorted(NATIVE_REGISTRY_STATUSES), default="review_required")
    native_refresh_parser.add_argument("--allowed-mode", action="append", choices=sorted(NATIVE_REGISTRY_MODES))
    native_refresh_parser.add_argument("--public-locale")
    native_refresh_parser.add_argument("--approval-artifact")
    native_refresh_parser.add_argument("--review-artifact-id")
    native_refresh_parser.add_argument("--artifact-id")
    native_refresh_parser.add_argument("--production-target-ledger")
    native_refresh_parser.add_argument("--production-domain-admission")
    native_refresh_parser.add_argument("--emit-evidence")
    native_refresh_parser.add_argument("--markdown")

    native_runtime_current_parser = sub.add_parser("native-runtime-current-proof")
    native_runtime_current_parser.add_argument("--production-target-ledger", required=True)
    native_runtime_current_parser.add_argument("--gateway-release-report", required=True)
    native_runtime_current_parser.add_argument("--native-registry-artifact", required=True)
    native_runtime_current_parser.add_argument("--output-root", required=True)
    native_runtime_current_parser.add_argument("--created-at", default="2026-06-29T01:00:00Z")
    native_runtime_current_parser.add_argument("--xcode-result", default="NOT_RUN")
    native_runtime_current_parser.add_argument("--xcode-passed", type=int, default=0)
    native_runtime_current_parser.add_argument("--xcode-failed", type=int, default=0)
    native_runtime_current_parser.add_argument("--xcode-skipped", type=int, default=0)
    native_runtime_current_parser.add_argument("--xcode-duration-ms", type=int)
    native_runtime_current_parser.add_argument("--xcode-log-path")
    native_runtime_current_parser.add_argument("--xcresult-path")
    native_runtime_current_parser.add_argument("--xcode-profile")
    native_runtime_current_parser.add_argument("--test-suite", action="append", dest="test_suites")
    native_runtime_current_parser.add_argument("--endpoint")
    native_runtime_current_parser.add_argument("--branch")
    native_runtime_current_parser.add_argument("--commit-sha")
    native_runtime_current_parser.add_argument("--worktree-dirty-entry-count", type=int)
    native_runtime_current_parser.add_argument("--emit-evidence")
    native_runtime_current_parser.add_argument("--markdown")

    release_proof_packet_parser = sub.add_parser("source-atlas-release-proof-packet")
    release_proof_packet_parser.add_argument("--native-runtime-report", required=True)
    release_proof_packet_parser.add_argument("--output-root", required=True)
    release_proof_packet_parser.add_argument("--build-summary")
    release_proof_packet_parser.add_argument("--source-atlas-pytest-result", default="NOT_RUN")
    release_proof_packet_parser.add_argument("--source-atlas-pytest-passed", type=int, default=0)
    release_proof_packet_parser.add_argument("--source-atlas-pytest-failed", type=int, default=0)
    release_proof_packet_parser.add_argument("--boundary-audit-result", default="NOT_RUN")
    release_proof_packet_parser.add_argument("--no-private-egress-result", default="NOT_RUN")
    release_proof_packet_parser.add_argument("--green-standard-result", default="NOT_RUN")
    release_proof_packet_parser.add_argument("--local-first-result", default="NOT_RUN")
    release_proof_packet_parser.add_argument("--git-diff-check-result", default="NOT_RUN")
    release_proof_packet_parser.add_argument("--build-for-testing-result", default="NOT_RUN")
    release_proof_packet_parser.add_argument("--focused-native-result", default="NOT_RUN")
    release_proof_packet_parser.add_argument("--focused-native-passed", type=int, default=0)
    release_proof_packet_parser.add_argument("--focused-native-failed", type=int, default=0)
    release_proof_packet_parser.add_argument("--focused-native-skipped", type=int, default=0)
    release_proof_packet_parser.add_argument("--physical-device-proof")
    release_proof_packet_parser.add_argument("--accessibility-proof")
    release_proof_packet_parser.add_argument("--visual-review-proof")
    release_proof_packet_parser.add_argument("--app-store-connect-proof")
    release_proof_packet_parser.add_argument("--testflight-proof")
    release_proof_packet_parser.add_argument("--privacy-legal-release-signoff")
    release_proof_packet_parser.add_argument("--owner-release-approval")
    release_proof_packet_parser.add_argument("--created-at", default="2026-06-29T05:15:00Z")
    release_proof_packet_parser.add_argument("--run-label", default="current")
    release_proof_packet_parser.add_argument("--branch")
    release_proof_packet_parser.add_argument("--commit-sha")
    release_proof_packet_parser.add_argument("--environment")
    release_proof_packet_parser.add_argument("--emit-evidence")
    release_proof_packet_parser.add_argument("--markdown")

    goal_domain_gauntlet_parser = sub.add_parser("goal-domain-gauntlet")
    goal_domain_gauntlet_parser.add_argument("--frontier-config", required=True)
    goal_domain_gauntlet_parser.add_argument("--production-target-ledger", required=True)
    goal_domain_gauntlet_parser.add_argument("--arbitrary-domain-gate", required=True)
    goal_domain_gauntlet_parser.add_argument("--native-runtime-report")
    goal_domain_gauntlet_parser.add_argument("--output-root", required=True)
    goal_domain_gauntlet_parser.add_argument("--created-at", default="2026-06-29T01:30:00Z")
    goal_domain_gauntlet_parser.add_argument("--unknown-probe-domain", action="append", dest="unknown_probe_domains")
    goal_domain_gauntlet_parser.add_argument("--emit-evidence")
    goal_domain_gauntlet_parser.add_argument("--markdown")

    public_reference_delivery_chain_parser = sub.add_parser("public-reference-delivery-chain")
    public_reference_delivery_chain_parser.add_argument("--output-root", required=True)
    public_reference_delivery_chain_parser.add_argument("--domain", default="occupation_foundation")
    public_reference_delivery_chain_parser.add_argument("--source", action="append", dest="sources")
    public_reference_delivery_chain_parser.add_argument("--harvest-mode", choices=sorted(RUN_MODES), default="fixture")
    public_reference_delivery_chain_parser.add_argument("--limit", type=int, default=25)
    public_reference_delivery_chain_parser.add_argument("--live", action="store_true")
    public_reference_delivery_chain_parser.add_argument("--execute-harvest", action="store_true")
    public_reference_delivery_chain_parser.add_argument("--environment", choices=["staging", "production"], default="staging")
    public_reference_delivery_chain_parser.add_argument("--channel", default="candidate")
    public_reference_delivery_chain_parser.add_argument("--pack-version")
    public_reference_delivery_chain_parser.add_argument("--r2-mode", choices=sorted(PUBLISHER_MODES), default="dry_run")
    public_reference_delivery_chain_parser.add_argument("--execute-r2", action="store_true")
    public_reference_delivery_chain_parser.add_argument("--r2-bucket")
    public_reference_delivery_chain_parser.add_argument("--r2-local-store-root")
    public_reference_delivery_chain_parser.add_argument("--r2-readback-root")
    public_reference_delivery_chain_parser.add_argument("--r2-budget-policy")
    public_reference_delivery_chain_parser.add_argument("--r2-approval-artifact")
    public_reference_delivery_chain_parser.add_argument("--r2-env-file", action="append", dest="r2_env_files")
    public_reference_delivery_chain_parser.add_argument("--legal-approval-packet")
    public_reference_delivery_chain_parser.add_argument("--production-target-ledger")
    public_reference_delivery_chain_parser.add_argument("--native-status", choices=sorted(NATIVE_REGISTRY_STATUSES), default="review_required")
    public_reference_delivery_chain_parser.add_argument("--native-allowed-mode", action="append", choices=sorted(NATIVE_REGISTRY_MODES))
    public_reference_delivery_chain_parser.add_argument("--native-public-locale")
    public_reference_delivery_chain_parser.add_argument("--native-approval-artifact")
    public_reference_delivery_chain_parser.add_argument("--app-version", default="1.0")
    public_reference_delivery_chain_parser.add_argument("--pack-schema-version", default="1.0.0")
    public_reference_delivery_chain_parser.add_argument("--created-at")
    public_reference_delivery_chain_parser.add_argument("--emit-evidence")
    public_reference_delivery_chain_parser.add_argument("--markdown")

    public_gateway_allowlist_parser = sub.add_parser("r2-public-gateway-allowlist")
    public_gateway_allowlist_parser.add_argument("--publisher-report", action="append", required=True)
    public_gateway_allowlist_parser.add_argument("--output-root", required=True)
    public_gateway_allowlist_parser.add_argument("--created-at", default="2026-06-28T00:00:00Z")
    public_gateway_allowlist_parser.add_argument("--worker-allowlist-path")
    public_gateway_allowlist_parser.add_argument("--emit-evidence")
    public_gateway_allowlist_parser.add_argument("--markdown")

    public_gateway_release_parser = sub.add_parser("r2-public-gateway-release")
    public_gateway_release_parser.add_argument("--publisher-report-root", default="tools/source-atlas/generated/r2-publisher")
    public_gateway_release_parser.add_argument("--output-root", required=True)
    public_gateway_release_parser.add_argument("--created-at", default="2026-06-28T00:00:00Z")
    public_gateway_release_parser.add_argument("--worker-allowlist-path")
    public_gateway_release_parser.add_argument("--worker-config")
    public_gateway_release_parser.add_argument("--base-url", default=DEFAULT_GATEWAY_BASE_URL)
    public_gateway_release_parser.add_argument("--deploy", action="store_true")
    public_gateway_release_parser.add_argument("--execute", action="store_true")
    public_gateway_release_parser.add_argument("--verify-live", action="store_true")
    public_gateway_release_parser.add_argument("--production-target-ledger")
    public_gateway_release_parser.add_argument("--production-domain-admission")
    public_gateway_release_parser.add_argument("--native-registry-artifact")
    public_gateway_release_parser.add_argument("--emit-evidence")
    public_gateway_release_parser.add_argument("--markdown")

    production_target_ledger_parser = sub.add_parser("production-target-ledger")
    production_target_ledger_parser.add_argument("--frontier-config", default="tools/source-atlas/frontier/coverage-frontiers.json")
    production_target_ledger_parser.add_argument("--source-lane-registry", default="tools/source-atlas/governance/source-lane-registry.json")
    production_target_ledger_parser.add_argument("--claim-frontier-report-root", default="tools/source-atlas/generated/claim-frontier")
    production_target_ledger_parser.add_argument("--pack-production-report-root", default="tools/source-atlas/generated/pack-production")
    production_target_ledger_parser.add_argument("--r2-publisher-report-root", default="tools/source-atlas/generated/r2-publisher")
    production_target_ledger_parser.add_argument("--gateway-release-report")
    production_target_ledger_parser.add_argument("--native-registry-report")
    production_target_ledger_parser.add_argument("--native-registry-artifact")
    production_target_ledger_parser.add_argument("--native-runtime-closeout")
    production_target_ledger_parser.add_argument("--output-root", required=True)
    production_target_ledger_parser.add_argument("--created-at", default="2026-06-28T00:00:00Z")
    production_target_ledger_parser.add_argument("--emit-evidence")
    production_target_ledger_parser.add_argument("--markdown")

    production_recertification_parser = sub.add_parser("production-recertification")
    production_recertification_parser.add_argument("--production-target-ledger", required=True)
    production_recertification_parser.add_argument("--gateway-release-report", required=True)
    production_recertification_parser.add_argument("--native-runtime-report", required=True)
    production_recertification_parser.add_argument("--native-registry-artifact")
    production_recertification_parser.add_argument("--output-root", required=True)
    production_recertification_parser.add_argument("--created-at", default="2026-06-28T00:00:00Z")
    production_recertification_parser.add_argument("--emit-evidence")
    production_recertification_parser.add_argument("--markdown")

    production_finish_line_parser = sub.add_parser("production-finish-line-gate")
    production_finish_line_parser.add_argument("--production-target-ledger", required=True)
    production_finish_line_parser.add_argument("--gateway-release-report", required=True)
    production_finish_line_parser.add_argument("--native-runtime-report", required=True)
    production_finish_line_parser.add_argument("--native-registry-artifact")
    production_finish_line_parser.add_argument("--legal-terms-approval-packet")
    production_finish_line_parser.add_argument("--coverage-report")
    production_finish_line_parser.add_argument("--release-approval-artifact")
    production_finish_line_parser.add_argument("--output-root", required=True)
    production_finish_line_parser.add_argument("--created-at", default="2026-06-28T00:00:00Z")
    production_finish_line_parser.add_argument("--no-compile-internal-terms-approval", action="store_true")
    production_finish_line_parser.add_argument("--emit-evidence")
    production_finish_line_parser.add_argument("--markdown")

    production_sweep_parser = sub.add_parser("production-sweep")
    production_sweep_parser.add_argument("--production-target-ledger", required=True)
    production_sweep_parser.add_argument("--production-finish-line-gate", required=True)
    production_sweep_parser.add_argument("--arbitrary-domain-gate", required=True)
    production_sweep_parser.add_argument("--goal-domain-gauntlet")
    production_sweep_parser.add_argument("--output-root", required=True)
    production_sweep_parser.add_argument("--created-at", default="2026-06-29T00:20:00Z")
    production_sweep_parser.add_argument("--environment", choices=["staging", "production"], default="production")
    production_sweep_parser.add_argument("--r2-bucket")
    production_sweep_parser.add_argument("--env-file", action="append", dest="env_files")
    production_sweep_parser.add_argument("--approval-artifact")
    production_sweep_parser.add_argument("--legal-approval-packet")
    production_sweep_parser.add_argument("--require-new-remote-write-ready", action="store_true")
    production_sweep_parser.add_argument("--emit-evidence")
    production_sweep_parser.add_argument("--markdown")

    autonomous_control_loop_parser = sub.add_parser("autonomous-control-loop")
    autonomous_control_loop_parser.add_argument("--production-sweep", required=True)
    autonomous_control_loop_parser.add_argument("--goal-domain-gauntlet", required=True)
    autonomous_control_loop_parser.add_argument("--owner-approval", required=True)
    autonomous_control_loop_parser.add_argument("--native-runtime-report", required=True)
    autonomous_control_loop_parser.add_argument("--production-finish-line-gate", required=True)
    autonomous_control_loop_parser.add_argument("--arbitrary-domain-gate", required=True)
    autonomous_control_loop_parser.add_argument("--autonomous-end-to-end-chain")
    autonomous_control_loop_parser.add_argument("--output-root", required=True)
    autonomous_control_loop_parser.add_argument("--created-at", default="2026-06-29T01:45:00Z")
    autonomous_control_loop_parser.add_argument("--environment", choices=["staging", "production"], default="production")
    autonomous_control_loop_parser.add_argument("--channel", default="stable")
    autonomous_control_loop_parser.add_argument("--bucket")
    autonomous_control_loop_parser.add_argument("--emit-evidence")
    autonomous_control_loop_parser.add_argument("--markdown")

    autonomous_cycle_runner_parser = sub.add_parser("autonomous-cycle-runner")
    autonomous_cycle_runner_parser.add_argument("--control-loop", required=True)
    autonomous_cycle_runner_parser.add_argument("--output-root", required=True)
    autonomous_cycle_runner_parser.add_argument("--previous-cycle")
    autonomous_cycle_runner_parser.add_argument("--created-at", default="2026-06-29T02:00:00Z")
    autonomous_cycle_runner_parser.add_argument("--cycle-label", default="current")
    autonomous_cycle_runner_parser.add_argument("--emit-evidence")
    autonomous_cycle_runner_parser.add_argument("--markdown")

    autonomous_cycle_executor_parser = sub.add_parser("autonomous-cycle-executor")
    autonomous_cycle_executor_parser.add_argument("--cycle", required=True)
    autonomous_cycle_executor_parser.add_argument("--output-root", required=True)
    autonomous_cycle_executor_parser.add_argument("--created-at", default="2026-06-29T02:15:00Z")
    autonomous_cycle_executor_parser.add_argument("--run-label", default="current")
    autonomous_cycle_executor_parser.add_argument("--emit-evidence")
    autonomous_cycle_executor_parser.add_argument("--markdown")

    autonomous_production_orchestrator_parser = sub.add_parser("autonomous-production-orchestrator")
    autonomous_production_orchestrator_parser.add_argument("--production-target-ledger", required=True)
    autonomous_production_orchestrator_parser.add_argument("--production-finish-line-gate", required=True)
    autonomous_production_orchestrator_parser.add_argument("--production-sweep", required=True)
    autonomous_production_orchestrator_parser.add_argument("--arbitrary-domain-gate", required=True)
    autonomous_production_orchestrator_parser.add_argument("--goal-domain-gauntlet", required=True)
    autonomous_production_orchestrator_parser.add_argument("--autonomous-control-loop", required=True)
    autonomous_production_orchestrator_parser.add_argument("--autonomous-cycle", required=True)
    autonomous_production_orchestrator_parser.add_argument("--output-root", required=True)
    autonomous_production_orchestrator_parser.add_argument("--created-at", default="2026-06-29T02:30:00Z")
    autonomous_production_orchestrator_parser.add_argument("--run-label", default="current")
    autonomous_production_orchestrator_parser.add_argument("--emit-evidence")
    autonomous_production_orchestrator_parser.add_argument("--markdown")

    autonomous_production_supervisor_parser = sub.add_parser("autonomous-production-supervisor")
    autonomous_production_supervisor_parser.add_argument("--frontier-config", default="tools/source-atlas/frontier/coverage-frontiers.json")
    autonomous_production_supervisor_parser.add_argument("--source-lane-registry", default="tools/source-atlas/governance/source-lane-registry.json")
    autonomous_production_supervisor_parser.add_argument("--legal-terms-registry", default="tools/source-atlas/governance/legal-terms-registry.json")
    autonomous_production_supervisor_parser.add_argument("--api-governance-registry", default="tools/source-atlas/governance/api-governance-registry.json")
    autonomous_production_supervisor_parser.add_argument("--owner-approval")
    autonomous_production_supervisor_parser.add_argument("--legal-approval-packet")
    autonomous_production_supervisor_parser.add_argument("--promotion-bucket")
    autonomous_production_supervisor_parser.add_argument("--production-target-ledger", required=True)
    autonomous_production_supervisor_parser.add_argument("--production-recertification", required=True)
    autonomous_production_supervisor_parser.add_argument("--production-finish-line-gate", required=True)
    autonomous_production_supervisor_parser.add_argument("--production-sweep", required=True)
    autonomous_production_supervisor_parser.add_argument("--arbitrary-domain-gate", required=True)
    autonomous_production_supervisor_parser.add_argument("--goal-domain-gauntlet", required=True)
    autonomous_production_supervisor_parser.add_argument("--autonomous-control-loop", required=True)
    autonomous_production_supervisor_parser.add_argument("--autonomous-cycle", required=True)
    autonomous_production_supervisor_parser.add_argument("--requested-domain", action="append", dest="requested_domains")
    autonomous_production_supervisor_parser.add_argument("--output-root", required=True)
    autonomous_production_supervisor_parser.add_argument("--created-at", default="2026-06-29T02:45:00Z")
    autonomous_production_supervisor_parser.add_argument("--run-label", default="current")
    autonomous_production_supervisor_parser.add_argument("--execute-safe-actions", action="store_true")
    autonomous_production_supervisor_parser.add_argument("--execute-r2", action="store_true")
    autonomous_production_supervisor_parser.add_argument("--allow-fixture-delivery-chain", action="store_true")
    autonomous_production_supervisor_parser.add_argument("--delivery-chain-limit", type=int, default=5)
    autonomous_production_supervisor_parser.add_argument("--lookahead-days", type=int, default=30)
    autonomous_production_supervisor_parser.add_argument("--emit-evidence")
    autonomous_production_supervisor_parser.add_argument("--markdown")

    autonomous_freshness_parser = sub.add_parser("autonomous-freshness-scheduler")
    autonomous_freshness_parser.add_argument("--frontier-config", default="tools/source-atlas/frontier/coverage-frontiers.json")
    autonomous_freshness_parser.add_argument("--source-lane-registry", default="tools/source-atlas/governance/source-lane-registry.json")
    autonomous_freshness_parser.add_argument("--legal-terms-registry", default="tools/source-atlas/governance/legal-terms-registry.json")
    autonomous_freshness_parser.add_argument("--api-governance-registry", default="tools/source-atlas/governance/api-governance-registry.json")
    autonomous_freshness_parser.add_argument("--production-target-ledger", required=True)
    autonomous_freshness_parser.add_argument("--production-recertification", required=True)
    autonomous_freshness_parser.add_argument("--production-sweep", required=True)
    autonomous_freshness_parser.add_argument("--autonomous-production-supervisor")
    autonomous_freshness_parser.add_argument("--output-root", required=True)
    autonomous_freshness_parser.add_argument("--created-at", default="2026-06-29T03:00:00Z")
    autonomous_freshness_parser.add_argument("--run-label", default="current")
    autonomous_freshness_parser.add_argument("--lookahead-days", type=int, default=30)
    autonomous_freshness_parser.add_argument("--emit-evidence")
    autonomous_freshness_parser.add_argument("--markdown")

    autonomous_maintenance_parser = sub.add_parser("autonomous-maintenance-executor")
    autonomous_maintenance_parser.add_argument("--freshness-plan", required=True)
    autonomous_maintenance_parser.add_argument("--output-root", required=True)
    autonomous_maintenance_parser.add_argument("--created-at", default="2026-06-29T03:15:00Z")
    autonomous_maintenance_parser.add_argument("--run-label", default="current")
    autonomous_maintenance_parser.add_argument("--execute-safe-actions", action="store_true")
    autonomous_maintenance_parser.add_argument("--emit-evidence")
    autonomous_maintenance_parser.add_argument("--markdown")

    autonomous_promotion_parser = sub.add_parser("autonomous-promotion-runner")
    autonomous_promotion_parser.add_argument("--supervisor-report", required=True)
    autonomous_promotion_parser.add_argument("--production-sweep", required=True)
    autonomous_promotion_parser.add_argument("--owner-approval")
    autonomous_promotion_parser.add_argument("--legal-terms-registry", default="tools/source-atlas/governance/legal-terms-registry.json")
    autonomous_promotion_parser.add_argument("--api-governance-registry", default="tools/source-atlas/governance/api-governance-registry.json")
    autonomous_promotion_parser.add_argument("--legal-approval-packet")
    autonomous_promotion_parser.add_argument("--output-root", required=True)
    autonomous_promotion_parser.add_argument("--created-at", default="2026-06-29T03:45:00Z")
    autonomous_promotion_parser.add_argument("--run-label", default="current")
    autonomous_promotion_parser.add_argument("--environment", choices=["staging", "production"], default="production")
    autonomous_promotion_parser.add_argument("--channel", default="stable")
    autonomous_promotion_parser.add_argument("--bucket")
    autonomous_promotion_parser.add_argument("--execute-r2", action="store_true")
    autonomous_promotion_parser.add_argument("--emit-evidence")
    autonomous_promotion_parser.add_argument("--markdown")

    completion_audit_parser = sub.add_parser("source-atlas-completion-audit")
    completion_audit_parser.add_argument("--production-supervisor", required=True)
    completion_audit_parser.add_argument("--production-sweep", required=True)
    completion_audit_parser.add_argument("--production-finish-line-gate", required=True)
    completion_audit_parser.add_argument("--production-recertification", required=True)
    completion_audit_parser.add_argument("--production-target-ledger", required=True)
    completion_audit_parser.add_argument("--arbitrary-domain-gate", required=True)
    completion_audit_parser.add_argument("--goal-domain-gauntlet", required=True)
    completion_audit_parser.add_argument("--source-lane-registry", default="tools/source-atlas/governance/source-lane-registry.json")
    completion_audit_parser.add_argument("--legal-terms-registry", default="tools/source-atlas/governance/legal-terms-registry.json")
    completion_audit_parser.add_argument("--api-governance-registry", default="tools/source-atlas/governance/api-governance-registry.json")
    completion_audit_parser.add_argument("--native-runtime-report")
    completion_audit_parser.add_argument("--release-proof-packet")
    completion_audit_parser.add_argument("--legal-approval-packet")
    completion_audit_parser.add_argument("--owner-approval")
    completion_audit_parser.add_argument("--launch-floor-ledger")
    completion_audit_parser.add_argument("--output-root", required=True)
    completion_audit_parser.add_argument("--created-at", default="2026-06-29T04:45:00Z")
    completion_audit_parser.add_argument("--run-label", default="current")
    completion_audit_parser.add_argument("--emit-evidence")
    completion_audit_parser.add_argument("--markdown")

    launch_floor_taxonomy_parser = sub.add_parser("launch-floor-domain-taxonomy")
    launch_floor_taxonomy_parser.add_argument("--taxonomy", default=str(DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH))
    launch_floor_taxonomy_parser.add_argument("--source-lane-registry", default="tools/source-atlas/governance/source-lane-registry.json")
    launch_floor_taxonomy_parser.add_argument("--production-target-ledger", default="tools/source-atlas/generated/production-target-ledger/train-131-tetradeca-current/production-target-ledger.json")
    launch_floor_taxonomy_parser.add_argument("--output-root", required=True)
    launch_floor_taxonomy_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    launch_floor_taxonomy_parser.add_argument("--run-label", default="current")
    launch_floor_taxonomy_parser.add_argument("--emit-evidence")
    launch_floor_taxonomy_parser.add_argument("--markdown")

    launch_floor_shard_corpus_parser = sub.add_parser("launch-floor-shard-corpus")
    launch_floor_shard_corpus_parser.add_argument("--manifest", default=str(DEFAULT_LAUNCH_FLOOR_SHARD_CORPUS_PATH))
    launch_floor_shard_corpus_parser.add_argument("--launch-floor-taxonomy", default=str(DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH))
    launch_floor_shard_corpus_parser.add_argument("--output-root", required=True)
    launch_floor_shard_corpus_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    launch_floor_shard_corpus_parser.add_argument("--run-label", default="current")
    launch_floor_shard_corpus_parser.add_argument("--emit-evidence")
    launch_floor_shard_corpus_parser.add_argument("--markdown")

    launch_floor_shard_corpus_compiler_parser = sub.add_parser("launch-floor-shard-corpus-compiler")
    launch_floor_shard_corpus_compiler_parser.add_argument("--production-target-ledger", default=str(DEFAULT_PRODUCTION_TARGET_LEDGER_PATH))
    launch_floor_shard_corpus_compiler_parser.add_argument("--source-lane-registry", default=str(DEFAULT_SOURCE_LANE_REGISTRY_PATH))
    launch_floor_shard_corpus_compiler_parser.add_argument("--legal-terms-registry", default=str(DEFAULT_LEGAL_TERMS_REGISTRY_PATH))
    launch_floor_shard_corpus_compiler_parser.add_argument("--api-governance-registry", default=str(DEFAULT_API_GOVERNANCE_REGISTRY_PATH))
    launch_floor_shard_corpus_compiler_parser.add_argument("--launch-floor-taxonomy", default=str(DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH))
    launch_floor_shard_corpus_compiler_parser.add_argument("--source-units")
    launch_floor_shard_corpus_compiler_parser.add_argument("--max-partition-shards", type=int, default=100000)
    launch_floor_shard_corpus_compiler_parser.add_argument("--output-root", required=True)
    launch_floor_shard_corpus_compiler_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    launch_floor_shard_corpus_compiler_parser.add_argument("--run-label", default="current")
    launch_floor_shard_corpus_compiler_parser.add_argument("--emit-evidence")
    launch_floor_shard_corpus_compiler_parser.add_argument("--markdown")
    launch_floor_shard_corpus_compiler_parser.add_argument("--emit-manifest")

    launch_floor_r2_layout_proof_parser = sub.add_parser("launch-floor-r2-layout-proof")
    launch_floor_r2_layout_proof_parser.add_argument("--shard-corpus-manifest", default=str(DEFAULT_LAUNCH_FLOOR_SHARD_CORPUS_MANIFEST_PATH))
    launch_floor_r2_layout_proof_parser.add_argument("--launch-floor-taxonomy", default=str(DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH))
    launch_floor_r2_layout_proof_parser.add_argument("--output-root", required=True)
    launch_floor_r2_layout_proof_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    launch_floor_r2_layout_proof_parser.add_argument("--run-label", default="current")
    launch_floor_r2_layout_proof_parser.add_argument("--readback-mode", choices=sorted(READBACK_MODES), default="full")
    launch_floor_r2_layout_proof_parser.add_argument("--sample-stride", type=int, default=97)
    launch_floor_r2_layout_proof_parser.add_argument("--gateway-load-probe-count", type=int, default=1000)
    launch_floor_r2_layout_proof_parser.add_argument("--simulate-readback-mismatch-object-key")
    launch_floor_r2_layout_proof_parser.add_argument("--emit-evidence")
    launch_floor_r2_layout_proof_parser.add_argument("--markdown")

    launch_floor_native_shard_index_parser = sub.add_parser("launch-floor-native-shard-index-proof")
    launch_floor_native_shard_index_parser.add_argument("--shard-corpus-manifest", default=str(DEFAULT_LAUNCH_FLOOR_SHARD_CORPUS_MANIFEST_PATH))
    launch_floor_native_shard_index_parser.add_argument("--r2-layout-inventory", default=str(DEFAULT_R2_LAYOUT_INVENTORY_PATH))
    launch_floor_native_shard_index_parser.add_argument("--output-root", required=True)
    launch_floor_native_shard_index_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    launch_floor_native_shard_index_parser.add_argument("--run-label", default="current")
    launch_floor_native_shard_index_parser.add_argument("--xcode-result", default="NOT_RUN")
    launch_floor_native_shard_index_parser.add_argument("--xcode-passed", type=int, default=0)
    launch_floor_native_shard_index_parser.add_argument("--xcode-failed", type=int, default=0)
    launch_floor_native_shard_index_parser.add_argument("--xcode-skipped", type=int, default=0)
    launch_floor_native_shard_index_parser.add_argument("--xcode-duration-ms", type=int)
    launch_floor_native_shard_index_parser.add_argument("--xcode-log-path")
    launch_floor_native_shard_index_parser.add_argument("--xcode-profile")
    launch_floor_native_shard_index_parser.add_argument("--branch")
    launch_floor_native_shard_index_parser.add_argument("--commit-sha")
    launch_floor_native_shard_index_parser.add_argument("--worktree-dirty-entry-count", type=int)
    launch_floor_native_shard_index_parser.add_argument("--test-suite", action="append", dest="test_suites")
    launch_floor_native_shard_index_parser.add_argument("--emit-evidence")
    launch_floor_native_shard_index_parser.add_argument("--markdown")

    launch_floor_golden_intent_parser = sub.add_parser("launch-floor-golden-intent-corpus")
    launch_floor_golden_intent_parser.add_argument("--input", action="append", dest="inputs", required=True)
    launch_floor_golden_intent_parser.add_argument(
        "--input-format",
        choices=["auto", "canonical", "goal-domain-gauntlet", "launch-floor-taxonomy"],
        default="auto",
    )
    launch_floor_golden_intent_parser.add_argument("--source-lane-registry", default=str(DEFAULT_SOURCE_LANE_REGISTRY_PATH))
    launch_floor_golden_intent_parser.add_argument("--production-target-ledger", default=str(DEFAULT_PRODUCTION_TARGET_LEDGER_PATH))
    launch_floor_golden_intent_parser.add_argument("--target-count", type=int, default=50_000)
    launch_floor_golden_intent_parser.add_argument("--intents-per-subdomain", type=int, default=10)
    launch_floor_golden_intent_parser.add_argument("--control-records-per-domain", type=int, default=2)
    launch_floor_golden_intent_parser.add_argument("--output-root", required=True)
    launch_floor_golden_intent_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    launch_floor_golden_intent_parser.add_argument("--run-label", default="current")
    launch_floor_golden_intent_parser.add_argument("--emit-evidence")
    launch_floor_golden_intent_parser.add_argument("--markdown")

    launch_floor_governance_parser = sub.add_parser("launch-floor-governance-renewal")
    launch_floor_governance_parser.add_argument("--source-lane-registry", default=str(DEFAULT_SOURCE_LANE_REGISTRY_PATH))
    launch_floor_governance_parser.add_argument("--legal-terms-registry", default=str(DEFAULT_LEGAL_TERMS_REGISTRY_PATH))
    launch_floor_governance_parser.add_argument("--api-governance-registry", default=str(DEFAULT_API_GOVERNANCE_REGISTRY_PATH))
    launch_floor_governance_parser.add_argument("--launch-floor-taxonomy", default=str(DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH))
    launch_floor_governance_parser.add_argument("--production-target-ledger", default=str(DEFAULT_PRODUCTION_TARGET_LEDGER_PATH))
    launch_floor_governance_parser.add_argument(
        "--output-root",
        default="tools/source-atlas/generated/source-atlas-launch-floor-governance-renewal/current",
    )
    launch_floor_governance_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    launch_floor_governance_parser.add_argument("--run-label", default="current")
    launch_floor_governance_parser.add_argument("--emit-evidence")
    launch_floor_governance_parser.add_argument("--markdown")

    source_needed_fallback_parser = sub.add_parser("source-needed-fallback-metric")
    source_needed_fallback_parser.add_argument(
        "--golden-intent-corpus-report",
        default="docs/qa/source-atlas/source-atlas-launch-floor-golden-intent-corpus-lff-m03.json",
    )
    source_needed_fallback_parser.add_argument("--normalized-corpus")
    source_needed_fallback_parser.add_argument("--previous-metric")
    source_needed_fallback_parser.add_argument("--output-root", required=True)
    source_needed_fallback_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    source_needed_fallback_parser.add_argument("--run-label", default="current")
    source_needed_fallback_parser.add_argument("--emit-evidence")
    source_needed_fallback_parser.add_argument("--emit-missing-shard-events")
    source_needed_fallback_parser.add_argument("--markdown")

    missing_shard_event_queue_parser = sub.add_parser("missing-shard-event-queue")
    missing_shard_event_queue_parser.add_argument(
        "--missing-shard-events",
        default="docs/qa/source-atlas/source-atlas-missing-shard-events-lff-m03.json",
    )
    missing_shard_event_queue_parser.add_argument(
        "--fallback-metric",
        default="docs/qa/source-atlas/source-atlas-source-needed-fallback-metric-lff-m03.json",
    )
    missing_shard_event_queue_parser.add_argument("--previous-queue")
    missing_shard_event_queue_parser.add_argument("--output-root", required=True)
    missing_shard_event_queue_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    missing_shard_event_queue_parser.add_argument("--run-label", default="current")
    missing_shard_event_queue_parser.add_argument("--emit-evidence")
    missing_shard_event_queue_parser.add_argument("--markdown")

    missing_shard_review_gate_parser = sub.add_parser("missing-shard-review-gate")
    missing_shard_review_gate_parser.add_argument(
        "--missing-shard-queue",
        default="docs/qa/source-atlas/source-atlas-missing-shard-event-queue-lff-m04.json",
    )
    missing_shard_review_gate_parser.add_argument(
        "--source-lane-registry",
        default="tools/source-atlas/governance/source-lane-registry.json",
    )
    missing_shard_review_gate_parser.add_argument(
        "--legal-terms-registry",
        default="tools/source-atlas/governance/legal-terms-registry.json",
    )
    missing_shard_review_gate_parser.add_argument(
        "--api-governance-registry",
        default="tools/source-atlas/governance/api-governance-registry.json",
    )
    missing_shard_review_gate_parser.add_argument("--approval-artifact")
    missing_shard_review_gate_parser.add_argument("--output-root", required=True)
    missing_shard_review_gate_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    missing_shard_review_gate_parser.add_argument("--run-label", default="current")
    missing_shard_review_gate_parser.add_argument("--execute", action="store_true")
    missing_shard_review_gate_parser.add_argument("--allow-active-registry-write", action="store_true")
    missing_shard_review_gate_parser.add_argument("--emit-evidence")
    missing_shard_review_gate_parser.add_argument("--markdown")

    missing_shard_activation_executor_parser = sub.add_parser("missing-shard-activation-executor")
    missing_shard_activation_executor_parser.add_argument(
        "--review-gate",
        default="docs/qa/source-atlas/source-atlas-missing-shard-review-gate-lff-m04.json",
    )
    missing_shard_activation_executor_parser.add_argument("--activation-approval")
    missing_shard_activation_executor_parser.add_argument("--output-root", required=True)
    missing_shard_activation_executor_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    missing_shard_activation_executor_parser.add_argument("--run-label", default="current")
    missing_shard_activation_executor_parser.add_argument("--execute", action="store_true")
    missing_shard_activation_executor_parser.add_argument("--allow-r2-write", action="store_true")
    missing_shard_activation_executor_parser.add_argument("--allow-native-activation", action="store_true")
    missing_shard_activation_executor_parser.add_argument("--emit-evidence")
    missing_shard_activation_executor_parser.add_argument("--markdown")

    missing_shard_expansion_supervisor_parser = sub.add_parser("missing-shard-expansion-supervisor")
    missing_shard_expansion_supervisor_parser.add_argument(
        "--missing-shard-queue",
        default="docs/qa/source-atlas/source-atlas-missing-shard-event-queue-lff-m04.json",
    )
    missing_shard_expansion_supervisor_parser.add_argument(
        "--review-gate",
        default="docs/qa/source-atlas/source-atlas-missing-shard-review-gate-lff-m04.json",
    )
    missing_shard_expansion_supervisor_parser.add_argument(
        "--activation-executor",
        default="docs/qa/source-atlas/source-atlas-missing-shard-activation-executor-lff-m04.json",
    )
    missing_shard_expansion_supervisor_parser.add_argument(
        "--fallback-metric",
        default="docs/qa/source-atlas/source-atlas-source-needed-fallback-metric-lff-m03.json",
    )
    missing_shard_expansion_supervisor_parser.add_argument("--previous-fallback-metric")
    missing_shard_expansion_supervisor_parser.add_argument("--output-root", required=True)
    missing_shard_expansion_supervisor_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    missing_shard_expansion_supervisor_parser.add_argument("--as-of", default="2026-07-01T00:00:00Z")
    missing_shard_expansion_supervisor_parser.add_argument("--run-label", default="current")
    missing_shard_expansion_supervisor_parser.add_argument("--emit-evidence")
    missing_shard_expansion_supervisor_parser.add_argument("--markdown")

    launch_floor_parser = sub.add_parser("source-atlas-launch-floor-ledger")
    launch_floor_parser.add_argument("--frontier-config", default="tools/source-atlas/frontier/coverage-frontiers.json")
    launch_floor_parser.add_argument("--source-lane-registry", default="tools/source-atlas/governance/source-lane-registry.json")
    launch_floor_parser.add_argument("--legal-terms-registry", default="tools/source-atlas/governance/legal-terms-registry.json")
    launch_floor_parser.add_argument("--api-governance-registry", default="tools/source-atlas/governance/api-governance-registry.json")
    launch_floor_parser.add_argument("--production-target-ledger", default="tools/source-atlas/generated/production-target-ledger/train-131-tetradeca-current/production-target-ledger.json")
    launch_floor_parser.add_argument("--r2-live-inventory", default="tools/source-atlas/generated/r2-live-inventory/train-137-post-hygiene-resolution-inventory/r2-live-inventory-report.json")
    launch_floor_parser.add_argument("--goal-domain-gauntlet", default="docs/qa/source-atlas/source-atlas-goal-domain-gauntlet-train-131.json")
    launch_floor_parser.add_argument("--completion-audit", default="docs/qa/source-atlas/source-atlas-completion-audit-train-132.json")
    launch_floor_parser.add_argument("--release-proof-packet", default="docs/qa/source-atlas/source-atlas-release-proof-packet-train-132.json")
    launch_floor_parser.add_argument("--production-supervisor", default="tools/source-atlas/generated/autonomous-production-supervisor/train-133-current-proof-refresh/autonomous-production-supervisor-report.json")
    launch_floor_parser.add_argument("--autonomous-control-loop", default="tools/source-atlas/generated/autonomous-control-loop/train-131-tetradeca-final/autonomous-control-loop-report.json")
    launch_floor_parser.add_argument("--autonomous-domain-expansion-chain", default="tools/source-atlas/generated/autonomous-domain-expansion-chain/train-107-current/autonomous-domain-expansion-chain-report.json")
    launch_floor_parser.add_argument("--launch-floor-taxonomy", default=str(DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH))
    launch_floor_parser.add_argument("--shard-corpus-manifest")
    launch_floor_parser.add_argument("--r2-layout-proof")
    launch_floor_parser.add_argument("--golden-intent-corpus")
    launch_floor_parser.add_argument("--fallback-metric")
    launch_floor_parser.add_argument("--missing-shard-events")
    launch_floor_parser.add_argument("--missing-shard-review-gate")
    launch_floor_parser.add_argument("--missing-shard-activation-executor")
    launch_floor_parser.add_argument("--missing-shard-expansion-supervisor")
    launch_floor_parser.add_argument("--native-runtime-bridge-gauntlet-source", default="Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasRuntimeBridgeCoverageGauntletTests.swift")
    launch_floor_parser.add_argument("--output-root", required=True)
    launch_floor_parser.add_argument("--created-at", default="2026-07-01T00:00:00Z")
    launch_floor_parser.add_argument("--run-label", default="current")
    launch_floor_parser.add_argument("--emit-evidence")
    launch_floor_parser.add_argument("--markdown")

    arbitrary_domain_gate_parser = sub.add_parser("arbitrary-domain-handling-gate")
    arbitrary_domain_gate_parser.add_argument("--frontier-config", default="tools/source-atlas/frontier/coverage-frontiers.json")
    arbitrary_domain_gate_parser.add_argument("--source-lane-registry", default="tools/source-atlas/governance/source-lane-registry.json")
    arbitrary_domain_gate_parser.add_argument("--production-target-ledger", required=True)
    arbitrary_domain_gate_parser.add_argument("--production-recertification", required=True)
    arbitrary_domain_gate_parser.add_argument("--finish-line-gate")
    arbitrary_domain_gate_parser.add_argument("--unknown-probe-domain", action="append", dest="unknown_probe_domains")
    arbitrary_domain_gate_parser.add_argument("--output-root", required=True)
    arbitrary_domain_gate_parser.add_argument("--created-at", default="2026-06-29T00:00:00Z")
    arbitrary_domain_gate_parser.add_argument("--emit-evidence")
    arbitrary_domain_gate_parser.add_argument("--markdown")

    autonomous_operations_parser = sub.add_parser("autonomous-operations-plan")
    autonomous_operations_parser.add_argument("--frontier-config", default="tools/source-atlas/frontier/coverage-frontiers.json")
    autonomous_operations_parser.add_argument("--source-lane-registry", default="tools/source-atlas/governance/source-lane-registry.json")
    autonomous_operations_parser.add_argument("--production-target-ledger")
    autonomous_operations_parser.add_argument("--production-recertification")
    autonomous_operations_parser.add_argument("--requested-domain", action="append", dest="requested_domains")
    autonomous_operations_parser.add_argument("--output-root", required=True)
    autonomous_operations_parser.add_argument("--created-at", default="2026-06-28T00:00:00Z")
    autonomous_operations_parser.add_argument("--emit-evidence")
    autonomous_operations_parser.add_argument("--markdown")

    autonomous_operations_executor_parser = sub.add_parser("autonomous-operations-execute")
    autonomous_operations_executor_parser.add_argument("--operations-plan", required=True)
    autonomous_operations_executor_parser.add_argument("--output-root", required=True)
    autonomous_operations_executor_parser.add_argument("--created-at", default="2026-06-28T00:00:00Z")
    autonomous_operations_executor_parser.add_argument("--execute-safe-actions", action="store_true")
    autonomous_operations_executor_parser.add_argument("--allow-fixture-delivery-chain", action="store_true")
    autonomous_operations_executor_parser.add_argument("--frontier-config")
    autonomous_operations_executor_parser.add_argument("--delivery-chain-limit", type=int, default=5)
    autonomous_operations_executor_parser.add_argument("--emit-evidence")
    autonomous_operations_executor_parser.add_argument("--markdown")

    autonomous_domain_expansion_chain_parser = sub.add_parser("autonomous-domain-expansion-chain")
    autonomous_domain_expansion_chain_parser.add_argument("--executor-report", required=True)
    autonomous_domain_expansion_chain_parser.add_argument("--output-root", required=True)
    autonomous_domain_expansion_chain_parser.add_argument("--frontier-config")
    autonomous_domain_expansion_chain_parser.add_argument("--production-target-ledger")
    autonomous_domain_expansion_chain_parser.add_argument("--mode", choices=sorted(EXECUTOR_MODES), default="fixture")
    autonomous_domain_expansion_chain_parser.add_argument("--reviewer", default="")
    autonomous_domain_expansion_chain_parser.add_argument("--created-at", default="2026-06-28T00:00:00Z")
    autonomous_domain_expansion_chain_parser.add_argument("--emit-evidence")
    autonomous_domain_expansion_chain_parser.add_argument("--markdown")

    autonomous_registry_activation_chain_parser = sub.add_parser("autonomous-registry-activation-chain")
    autonomous_registry_activation_chain_parser.add_argument("--expansion-chain-report", required=True)
    autonomous_registry_activation_chain_parser.add_argument("--output-root", required=True)
    autonomous_registry_activation_chain_parser.add_argument("--completion-evidence")
    autonomous_registry_activation_chain_parser.add_argument("--source-specific-apply-input")
    autonomous_registry_activation_chain_parser.add_argument("--source-lane-registry")
    autonomous_registry_activation_chain_parser.add_argument("--legal-terms-registry")
    autonomous_registry_activation_chain_parser.add_argument("--api-governance-registry")
    autonomous_registry_activation_chain_parser.add_argument("--created-at", default="2026-06-28T00:00:00Z")
    autonomous_registry_activation_chain_parser.add_argument("--emit-evidence")
    autonomous_registry_activation_chain_parser.add_argument("--markdown")

    autonomous_end_to_end_chain_parser = sub.add_parser("autonomous-end-to-end-chain")
    autonomous_end_to_end_chain_parser.add_argument("--frontier-config", default="tools/source-atlas/frontier/coverage-frontiers.json")
    autonomous_end_to_end_chain_parser.add_argument("--source-lane-registry", default="tools/source-atlas/governance/source-lane-registry.json")
    autonomous_end_to_end_chain_parser.add_argument("--legal-terms-registry")
    autonomous_end_to_end_chain_parser.add_argument("--api-governance-registry")
    autonomous_end_to_end_chain_parser.add_argument("--production-target-ledger")
    autonomous_end_to_end_chain_parser.add_argument("--production-recertification")
    autonomous_end_to_end_chain_parser.add_argument("--refresh-production-recertification", action="store_true")
    autonomous_end_to_end_chain_parser.add_argument("--gateway-release-report")
    autonomous_end_to_end_chain_parser.add_argument("--native-runtime-report")
    autonomous_end_to_end_chain_parser.add_argument("--native-registry-artifact")
    autonomous_end_to_end_chain_parser.add_argument("--requested-domain", action="append", dest="requested_domains")
    autonomous_end_to_end_chain_parser.add_argument("--output-root", required=True)
    autonomous_end_to_end_chain_parser.add_argument("--created-at", default="2026-06-28T00:00:00Z")
    autonomous_end_to_end_chain_parser.add_argument("--execute-safe-actions", action="store_true")
    autonomous_end_to_end_chain_parser.add_argument("--allow-fixture-delivery-chain", action="store_true")
    autonomous_end_to_end_chain_parser.add_argument("--delivery-chain-limit", type=int, default=5)
    autonomous_end_to_end_chain_parser.add_argument("--domain-expansion-mode", choices=sorted(EXECUTOR_MODES), default="fixture")
    autonomous_end_to_end_chain_parser.add_argument("--reviewer", default="")
    autonomous_end_to_end_chain_parser.add_argument("--emit-evidence")
    autonomous_end_to_end_chain_parser.add_argument("--markdown")

    broad_domain_parser = sub.add_parser("broad-domain-discovery")
    broad_domain_parser.add_argument("--output-root", required=True)
    broad_domain_parser.add_argument("--frontier-config")
    broad_domain_parser.add_argument("--created-at")
    broad_domain_parser.add_argument("--emit-evidence")
    broad_domain_parser.add_argument("--markdown")

    frontier_intake_parser = sub.add_parser("frontier-intake")
    frontier_intake_parser.add_argument("--input", required=True)
    frontier_intake_parser.add_argument("--output-root", required=True)
    frontier_intake_parser.add_argument("--frontier-config")
    frontier_intake_parser.add_argument("--created-at")
    frontier_intake_parser.add_argument("--emit-evidence")
    frontier_intake_parser.add_argument("--markdown")

    deep_research_frontier_intake_parser = sub.add_parser("deep-research-frontier-intake")
    deep_research_frontier_intake_parser.add_argument("--input", required=True)
    deep_research_frontier_intake_parser.add_argument("--output-root", required=True)
    deep_research_frontier_intake_parser.add_argument("--frontier-config")
    deep_research_frontier_intake_parser.add_argument("--source-lane-registry")
    deep_research_frontier_intake_parser.add_argument("--created-at")
    deep_research_frontier_intake_parser.add_argument("--emit-evidence")
    deep_research_frontier_intake_parser.add_argument("--markdown")

    goal_domain_router_parser = sub.add_parser("goal-domain-router")
    goal_domain_router_parser.add_argument("--input", required=True)
    goal_domain_router_parser.add_argument("--output-root", required=True)
    goal_domain_router_parser.add_argument("--frontier-config")
    goal_domain_router_parser.add_argument("--production-target-ledger")
    goal_domain_router_parser.add_argument("--launch-floor-taxonomy")
    goal_domain_router_parser.add_argument("--created-at")
    goal_domain_router_parser.add_argument("--emit-evidence")
    goal_domain_router_parser.add_argument("--markdown")

    goal_domain_production_lanes_parser = sub.add_parser("goal-domain-production-lanes")
    goal_domain_production_lanes_parser.add_argument("--router-manifest", required=True)
    goal_domain_production_lanes_parser.add_argument("--output-root", required=True)
    goal_domain_production_lanes_parser.add_argument("--production-target-ledger")
    goal_domain_production_lanes_parser.add_argument("--created-at")
    goal_domain_production_lanes_parser.add_argument("--emit-evidence")
    goal_domain_production_lanes_parser.add_argument("--markdown")

    goal_domain_work_order_executor_parser = sub.add_parser("goal-domain-work-order-executor")
    goal_domain_work_order_executor_parser.add_argument("--production-lanes-manifest", required=True)
    goal_domain_work_order_executor_parser.add_argument("--output-root", required=True)
    goal_domain_work_order_executor_parser.add_argument("--mode", choices=sorted(EXECUTOR_MODES), default="fixture")
    goal_domain_work_order_executor_parser.add_argument("--created-at")
    goal_domain_work_order_executor_parser.add_argument("--emit-evidence")
    goal_domain_work_order_executor_parser.add_argument("--markdown")

    goal_domain_review_packets_parser = sub.add_parser("goal-domain-review-packets")
    goal_domain_review_packets_parser.add_argument("--executor-manifest", required=True)
    goal_domain_review_packets_parser.add_argument("--output-root", required=True)
    goal_domain_review_packets_parser.add_argument("--reviewer", default="")
    goal_domain_review_packets_parser.add_argument("--created-at")
    goal_domain_review_packets_parser.add_argument("--emit-evidence")
    goal_domain_review_packets_parser.add_argument("--markdown")

    goal_domain_review_completion_intake_parser = sub.add_parser("goal-domain-review-completion-intake")
    goal_domain_review_completion_intake_parser.add_argument("--review-templates", required=True)
    goal_domain_review_completion_intake_parser.add_argument("--output-root", required=True)
    goal_domain_review_completion_intake_parser.add_argument("--completion-evidence")
    goal_domain_review_completion_intake_parser.add_argument("--created-at")
    goal_domain_review_completion_intake_parser.add_argument("--emit-evidence")
    goal_domain_review_completion_intake_parser.add_argument("--markdown")

    goal_domain_registry_mutation_plan_parser = sub.add_parser("goal-domain-registry-mutation-plan")
    goal_domain_registry_mutation_plan_parser.add_argument("--review-completions", required=True)
    goal_domain_registry_mutation_plan_parser.add_argument("--output-root", required=True)
    goal_domain_registry_mutation_plan_parser.add_argument("--execute", action="store_true")
    goal_domain_registry_mutation_plan_parser.add_argument("--allow-active-registry-write", action="store_true")
    goal_domain_registry_mutation_plan_parser.add_argument("--created-at")
    goal_domain_registry_mutation_plan_parser.add_argument("--emit-evidence")
    goal_domain_registry_mutation_plan_parser.add_argument("--markdown")

    goal_domain_registry_applier_parser = sub.add_parser("goal-domain-registry-applier")
    goal_domain_registry_applier_parser.add_argument("--plan", required=True)
    goal_domain_registry_applier_parser.add_argument("--output-root", required=True)
    goal_domain_registry_applier_parser.add_argument("--source-lane-registry")
    goal_domain_registry_applier_parser.add_argument("--legal-terms-registry")
    goal_domain_registry_applier_parser.add_argument("--api-governance-registry")
    goal_domain_registry_applier_parser.add_argument("--approval-artifact")
    goal_domain_registry_applier_parser.add_argument("--execute", action="store_true")
    goal_domain_registry_applier_parser.add_argument("--allow-active-registry-write", action="store_true")
    goal_domain_registry_applier_parser.add_argument("--created-at")
    goal_domain_registry_applier_parser.add_argument("--emit-evidence")
    goal_domain_registry_applier_parser.add_argument("--markdown")

    goal_domain_registry_apply_rehearsal_parser = sub.add_parser("goal-domain-registry-apply-rehearsal")
    goal_domain_registry_apply_rehearsal_parser.add_argument("--review-templates", required=True)
    goal_domain_registry_apply_rehearsal_parser.add_argument("--output-root", required=True)
    goal_domain_registry_apply_rehearsal_parser.add_argument("--source-lane-registry")
    goal_domain_registry_apply_rehearsal_parser.add_argument("--legal-terms-registry")
    goal_domain_registry_apply_rehearsal_parser.add_argument("--api-governance-registry")
    goal_domain_registry_apply_rehearsal_parser.add_argument("--created-at")
    goal_domain_registry_apply_rehearsal_parser.add_argument("--emit-evidence")
    goal_domain_registry_apply_rehearsal_parser.add_argument("--markdown")

    goal_domain_active_registry_apply_gate_parser = sub.add_parser("goal-domain-active-registry-apply-gate")
    goal_domain_active_registry_apply_gate_parser.add_argument("--plan", required=True)
    goal_domain_active_registry_apply_gate_parser.add_argument("--output-root", required=True)
    goal_domain_active_registry_apply_gate_parser.add_argument("--review-evidence")
    goal_domain_active_registry_apply_gate_parser.add_argument("--source-lane-registry")
    goal_domain_active_registry_apply_gate_parser.add_argument("--legal-terms-registry")
    goal_domain_active_registry_apply_gate_parser.add_argument("--api-governance-registry")
    goal_domain_active_registry_apply_gate_parser.add_argument("--approval-artifact")
    goal_domain_active_registry_apply_gate_parser.add_argument("--execute", action="store_true")
    goal_domain_active_registry_apply_gate_parser.add_argument("--allow-active-registry-write", action="store_true")
    goal_domain_active_registry_apply_gate_parser.add_argument("--created-at")
    goal_domain_active_registry_apply_gate_parser.add_argument("--emit-evidence")
    goal_domain_active_registry_apply_gate_parser.add_argument("--markdown")

    goal_domain_source_specific_apply_packet_parser = sub.add_parser("goal-domain-source-specific-apply-packet")
    goal_domain_source_specific_apply_packet_parser.add_argument("--input", required=True)
    goal_domain_source_specific_apply_packet_parser.add_argument("--output-root", required=True)
    goal_domain_source_specific_apply_packet_parser.add_argument("--source-lane-registry")
    goal_domain_source_specific_apply_packet_parser.add_argument("--legal-terms-registry")
    goal_domain_source_specific_apply_packet_parser.add_argument("--api-governance-registry")
    goal_domain_source_specific_apply_packet_parser.add_argument("--created-at")
    goal_domain_source_specific_apply_packet_parser.add_argument("--emit-evidence")
    goal_domain_source_specific_apply_packet_parser.add_argument("--markdown")

    goal_domain_production_activation_parser = sub.add_parser("goal-domain-production-activation")
    goal_domain_production_activation_parser.add_argument("--input", required=True)
    goal_domain_production_activation_parser.add_argument("--output-root", required=True)
    goal_domain_production_activation_parser.add_argument("--target-source-lane-registry")
    goal_domain_production_activation_parser.add_argument("--target-legal-terms-registry")
    goal_domain_production_activation_parser.add_argument("--target-api-governance-registry")
    goal_domain_production_activation_parser.add_argument("--execute-active-registry", action="store_true")
    goal_domain_production_activation_parser.add_argument("--allow-active-registry-write", action="store_true")
    goal_domain_production_activation_parser.add_argument("--created-at")
    goal_domain_production_activation_parser.add_argument("--emit-evidence")
    goal_domain_production_activation_parser.add_argument("--markdown")

    catalog_discovery_parser = sub.add_parser("catalog-discovery")
    catalog_discovery_parser.add_argument("--input-root", required=True)
    catalog_discovery_parser.add_argument("--output-root", required=True)
    catalog_discovery_parser.add_argument("--created-at")
    catalog_discovery_parser.add_argument("--emit-evidence")
    catalog_discovery_parser.add_argument("--markdown")

    catalog_transport_parser = sub.add_parser("catalog-transport")
    catalog_transport_parser.add_argument("--plan", required=True)
    catalog_transport_parser.add_argument("--output-root", required=True)
    catalog_transport_parser.add_argument("--mode", choices=["fixture", "dry_run", "live"], default="fixture")
    catalog_transport_parser.add_argument("--live", action="store_true")
    catalog_transport_parser.add_argument("--execute", action="store_true")
    catalog_transport_parser.add_argument("--created-at")
    catalog_transport_parser.add_argument("--emit-evidence")
    catalog_transport_parser.add_argument("--markdown")

    catalog_candidate_review_parser = sub.add_parser("catalog-candidate-review")
    catalog_candidate_review_parser.add_argument("--input", required=True)
    catalog_candidate_review_parser.add_argument("--output-root", required=True)
    catalog_candidate_review_parser.add_argument("--created-at")
    catalog_candidate_review_parser.add_argument("--emit-evidence")
    catalog_candidate_review_parser.add_argument("--markdown")

    catalog_governance_intake_parser = sub.add_parser("catalog-governance-intake")
    catalog_governance_intake_parser.add_argument("--input", required=True)
    catalog_governance_intake_parser.add_argument("--output-root", required=True)
    catalog_governance_intake_parser.add_argument("--created-at")
    catalog_governance_intake_parser.add_argument("--emit-evidence")
    catalog_governance_intake_parser.add_argument("--markdown")

    catalog_registry_mutation_plan_parser = sub.add_parser("catalog-registry-mutation-plan")
    catalog_registry_mutation_plan_parser.add_argument("--input", required=True)
    catalog_registry_mutation_plan_parser.add_argument("--output-root", required=True)
    catalog_registry_mutation_plan_parser.add_argument("--approval-artifact")
    catalog_registry_mutation_plan_parser.add_argument("--execute", action="store_true")
    catalog_registry_mutation_plan_parser.add_argument("--created-at")
    catalog_registry_mutation_plan_parser.add_argument("--emit-evidence")
    catalog_registry_mutation_plan_parser.add_argument("--markdown")

    catalog_registry_applier_parser = sub.add_parser("catalog-registry-applier")
    catalog_registry_applier_parser.add_argument("--plan", required=True)
    catalog_registry_applier_parser.add_argument("--output-root", required=True)
    catalog_registry_applier_parser.add_argument("--source-lane-registry")
    catalog_registry_applier_parser.add_argument("--legal-terms-registry")
    catalog_registry_applier_parser.add_argument("--api-governance-registry")
    catalog_registry_applier_parser.add_argument("--execute", action="store_true")
    catalog_registry_applier_parser.add_argument("--allow-active-registry-write", action="store_true")
    catalog_registry_applier_parser.add_argument("--created-at")
    catalog_registry_applier_parser.add_argument("--emit-evidence")
    catalog_registry_applier_parser.add_argument("--markdown")

    catalog_registry_approval_request_parser = sub.add_parser("catalog-registry-approval-request")
    catalog_registry_approval_request_parser.add_argument("--input", required=True)
    catalog_registry_approval_request_parser.add_argument("--output-root", required=True)
    catalog_registry_approval_request_parser.add_argument("--intake-id", action="append", dest="intake_ids")
    catalog_registry_approval_request_parser.add_argument("--created-at")
    catalog_registry_approval_request_parser.add_argument("--emit-evidence")
    catalog_registry_approval_request_parser.add_argument("--markdown")

    catalog_terms_resolution_parser = sub.add_parser("catalog-terms-resolution")
    catalog_terms_resolution_parser.add_argument("--input", required=True)
    catalog_terms_resolution_parser.add_argument("--output-root", required=True)
    catalog_terms_resolution_parser.add_argument("--created-at")
    catalog_terms_resolution_parser.add_argument("--emit-evidence")
    catalog_terms_resolution_parser.add_argument("--markdown")

    catalog_approval_finalizer_parser = sub.add_parser("catalog-approval-finalizer")
    catalog_approval_finalizer_parser.add_argument("--terms-proposals", required=True)
    catalog_approval_finalizer_parser.add_argument("--output-root", required=True)
    catalog_approval_finalizer_parser.add_argument("--decision-artifact")
    catalog_approval_finalizer_parser.add_argument("--created-at")
    catalog_approval_finalizer_parser.add_argument("--emit-evidence")
    catalog_approval_finalizer_parser.add_argument("--markdown")

    catalog_approval_preflight_parser = sub.add_parser("catalog-approval-preflight")
    catalog_approval_preflight_parser.add_argument("--terms-proposals", required=True)
    catalog_approval_preflight_parser.add_argument("--output-root", required=True)
    catalog_approval_preflight_parser.add_argument("--created-at")
    catalog_approval_preflight_parser.add_argument("--emit-evidence")
    catalog_approval_preflight_parser.add_argument("--markdown")

    catalog_approval_decision_inputs_parser = sub.add_parser("catalog-approval-decision-inputs")
    catalog_approval_decision_inputs_parser.add_argument("--preflight-records", required=True)
    catalog_approval_decision_inputs_parser.add_argument("--output-root", required=True)
    catalog_approval_decision_inputs_parser.add_argument("--created-at")
    catalog_approval_decision_inputs_parser.add_argument("--decision-owner", default="")
    catalog_approval_decision_inputs_parser.add_argument("--emit-evidence")
    catalog_approval_decision_inputs_parser.add_argument("--markdown")

    catalog_approval_decision_assembler_parser = sub.add_parser("catalog-approval-decision-assembler")
    catalog_approval_decision_assembler_parser.add_argument("--decision-inputs", required=True)
    catalog_approval_decision_assembler_parser.add_argument("--output-root", required=True)
    catalog_approval_decision_assembler_parser.add_argument("--review-completion")
    catalog_approval_decision_assembler_parser.add_argument("--created-at")
    catalog_approval_decision_assembler_parser.add_argument("--emit-evidence")
    catalog_approval_decision_assembler_parser.add_argument("--markdown")

    catalog_approval_chain_parser = sub.add_parser("catalog-approval-chain")
    catalog_approval_chain_parser.add_argument("--decision-inputs", required=True)
    catalog_approval_chain_parser.add_argument("--terms-proposals", required=True)
    catalog_approval_chain_parser.add_argument("--draft-governance-packets", required=True)
    catalog_approval_chain_parser.add_argument("--output-root", required=True)
    catalog_approval_chain_parser.add_argument("--review-completion")
    catalog_approval_chain_parser.add_argument("--source-lane-registry")
    catalog_approval_chain_parser.add_argument("--legal-terms-registry")
    catalog_approval_chain_parser.add_argument("--api-governance-registry")
    catalog_approval_chain_parser.add_argument("--execute-registry-apply", action="store_true")
    catalog_approval_chain_parser.add_argument("--allow-active-registry-write", action="store_true")
    catalog_approval_chain_parser.add_argument("--created-at")
    catalog_approval_chain_parser.add_argument("--emit-evidence")
    catalog_approval_chain_parser.add_argument("--markdown")

    catalog_reviewer_completion_intake_parser = sub.add_parser("catalog-reviewer-completion-intake")
    catalog_reviewer_completion_intake_parser.add_argument("--decision-inputs", required=True)
    catalog_reviewer_completion_intake_parser.add_argument("--output-root", required=True)
    catalog_reviewer_completion_intake_parser.add_argument("--review-packets")
    catalog_reviewer_completion_intake_parser.add_argument("--created-at")
    catalog_reviewer_completion_intake_parser.add_argument("--emit-evidence")
    catalog_reviewer_completion_intake_parser.add_argument("--markdown")

    catalog_reviewer_completion_template_parser = sub.add_parser("catalog-reviewer-completion-template")
    catalog_reviewer_completion_template_parser.add_argument("--decision-inputs", required=True)
    catalog_reviewer_completion_template_parser.add_argument("--output-root", required=True)
    catalog_reviewer_completion_template_parser.add_argument("--reviewer", default="")
    catalog_reviewer_completion_template_parser.add_argument("--created-at")
    catalog_reviewer_completion_template_parser.add_argument("--emit-evidence")
    catalog_reviewer_completion_template_parser.add_argument("--markdown")

    catalog_review_work_queue_parser = sub.add_parser("catalog-review-work-queue")
    catalog_review_work_queue_parser.add_argument("--decision-inputs", required=True)
    catalog_review_work_queue_parser.add_argument("--output-root", required=True)
    catalog_review_work_queue_parser.add_argument("--review-packets")
    catalog_review_work_queue_parser.add_argument("--created-at")
    catalog_review_work_queue_parser.add_argument("--emit-evidence")
    catalog_review_work_queue_parser.add_argument("--markdown")

    catalog_direct_source_resolution_parser = sub.add_parser("catalog-direct-source-resolution")
    catalog_direct_source_resolution_parser.add_argument("--work-items", required=True)
    catalog_direct_source_resolution_parser.add_argument("--output-root", required=True)
    catalog_direct_source_resolution_parser.add_argument("--candidate-review")
    catalog_direct_source_resolution_parser.add_argument("--decision-inputs")
    catalog_direct_source_resolution_parser.add_argument("--created-at")
    catalog_direct_source_resolution_parser.add_argument("--emit-evidence")
    catalog_direct_source_resolution_parser.add_argument("--markdown")

    catalog_direct_source_review_gate_parser = sub.add_parser("catalog-direct-source-review-gate")
    catalog_direct_source_review_gate_parser.add_argument("--resolution-candidates", required=True)
    catalog_direct_source_review_gate_parser.add_argument("--output-root", required=True)
    catalog_direct_source_review_gate_parser.add_argument("--direct-source-reviews")
    catalog_direct_source_review_gate_parser.add_argument("--created-at")
    catalog_direct_source_review_gate_parser.add_argument("--emit-evidence")
    catalog_direct_source_review_gate_parser.add_argument("--markdown")

    catalog_direct_source_review_template_parser = sub.add_parser("catalog-direct-source-review-template")
    catalog_direct_source_review_template_parser.add_argument("--resolution-candidates", required=True)
    catalog_direct_source_review_template_parser.add_argument("--output-root", required=True)
    catalog_direct_source_review_template_parser.add_argument("--reviewer", default="")
    catalog_direct_source_review_template_parser.add_argument("--created-at")
    catalog_direct_source_review_template_parser.add_argument("--emit-evidence")
    catalog_direct_source_review_template_parser.add_argument("--markdown")

    catalog_direct_source_review_completion_parser = sub.add_parser("catalog-direct-source-review-completion")
    catalog_direct_source_review_completion_parser.add_argument("--templates", required=True)
    catalog_direct_source_review_completion_parser.add_argument("--output-root", required=True)
    catalog_direct_source_review_completion_parser.add_argument("--review-evidence")
    catalog_direct_source_review_completion_parser.add_argument("--created-at")
    catalog_direct_source_review_completion_parser.add_argument("--emit-evidence")
    catalog_direct_source_review_completion_parser.add_argument("--markdown")

    catalog_direct_source_approval_chain_parser = sub.add_parser("catalog-direct-source-approval-chain")
    catalog_direct_source_approval_chain_parser.add_argument("--templates", required=True)
    catalog_direct_source_approval_chain_parser.add_argument("--resolution-candidates", required=True)
    catalog_direct_source_approval_chain_parser.add_argument("--decision-inputs", required=True)
    catalog_direct_source_approval_chain_parser.add_argument("--terms-proposals", required=True)
    catalog_direct_source_approval_chain_parser.add_argument("--draft-governance-packets", required=True)
    catalog_direct_source_approval_chain_parser.add_argument("--output-root", required=True)
    catalog_direct_source_approval_chain_parser.add_argument("--review-evidence")
    catalog_direct_source_approval_chain_parser.add_argument("--source-lane-registry")
    catalog_direct_source_approval_chain_parser.add_argument("--legal-terms-registry")
    catalog_direct_source_approval_chain_parser.add_argument("--api-governance-registry")
    catalog_direct_source_approval_chain_parser.add_argument("--execute-registry-apply", action="store_true")
    catalog_direct_source_approval_chain_parser.add_argument("--allow-active-registry-write", action="store_true")
    catalog_direct_source_approval_chain_parser.add_argument("--created-at")
    catalog_direct_source_approval_chain_parser.add_argument("--emit-evidence")
    catalog_direct_source_approval_chain_parser.add_argument("--markdown")

    compile_parser = sub.add_parser("compile")
    compile_parser.add_argument("--output-root", required=True)
    compile_parser.add_argument("--version-id", required=True)
    compile_parser.add_argument("--channel", default="staging")
    compile_parser.add_argument("--harvest-root")

    validate_parser = sub.add_parser("validate")
    validate_parser.add_argument("--bundle-root", required=True)

    workbench_parser = sub.add_parser("workbench")
    workbench_parser.add_argument("--bundle-root", required=True)
    workbench_parser.add_argument("--output")

    coverage_parser = sub.add_parser("coverage-diff")
    coverage_parser.add_argument("--bundle-root", required=True)
    coverage_parser.add_argument("--previous-bundle-root")
    coverage_parser.add_argument("--output")

    benchmark_parser = sub.add_parser("benchmark")
    benchmark_parser.add_argument("--bundle-root", required=True)
    benchmark_parser.add_argument("--output")

    boundary_parser = sub.add_parser("boundary-audit")
    boundary_parser.add_argument("--fixture-root", default="tools/source-atlas/fixtures/boundary")
    boundary_parser.add_argument("--bundle-root", action="append", default=[])
    boundary_parser.add_argument("--r2-plan", action="append", default=[])

    plan_parser = sub.add_parser("r2-plan")
    plan_parser.add_argument("--bundle-root", required=True)
    plan_parser.add_argument("--bucket", required=True)
    plan_parser.add_argument("--prefix", default="source-atlas/v1")
    plan_parser.add_argument("--channel", default="staging")
    plan_parser.add_argument("--output")

    contract_parser = sub.add_parser("r2-contracts")
    contract_parser.add_argument("--output-root")
    contract_parser.add_argument("--prefix", default="source-atlas/v1")

    revocation_parser = sub.add_parser("revocation-manifest")
    revocation_parser.add_argument("--bundle-root", required=True)
    revocation_parser.add_argument("--revoked-artifact-id", action="append", default=[])
    revocation_parser.add_argument("--reason", default="dry-run contract")
    revocation_parser.add_argument("--output")

    lkg_parser = sub.add_parser("last-known-good")
    lkg_parser.add_argument("--bundle-root", required=True)
    lkg_parser.add_argument("--channel", default="staging")
    lkg_parser.add_argument("--output")

    promotion_parser = sub.add_parser("promotion-gate")
    promotion_parser.add_argument("--bundle-root", required=True)
    promotion_parser.add_argument("--r2-plan", required=True)
    promotion_parser.add_argument("--revocation")
    promotion_parser.add_argument("--channel", default="staging")
    promotion_parser.add_argument("--output")

    upload_parser = sub.add_parser("upload-r2")
    upload_parser.add_argument("--plan", required=True)
    upload_parser.add_argument("--execute", action="store_true")
    upload_parser.add_argument("--confirm-public-reference-only", action="store_true")

    r2_ops_parser = sub.add_parser("r2-operations-proof")
    r2_ops_parser.add_argument("--mode", choices=sorted(R2_OPERATION_MODES), required=True)
    r2_ops_parser.add_argument("--environment", choices=["staging", "production"], required=True)
    r2_ops_parser.add_argument("--bundle-root", required=True)
    r2_ops_parser.add_argument("--bucket")
    r2_ops_parser.add_argument("--prefix")
    r2_ops_parser.add_argument("--channel", default="staging")
    r2_ops_parser.add_argument("--output")
    r2_ops_parser.add_argument("--readback-root")
    r2_ops_parser.add_argument("--execute", action="store_true")
    r2_ops_parser.add_argument("--confirm-public-reference-only", action="store_true")
    r2_ops_parser.add_argument("--revoked-artifact-id", action="append", default=[])
    r2_ops_parser.add_argument("--candidate-manifest")
    r2_ops_parser.add_argument("--last-known-good")
    r2_ops_parser.add_argument("--env-file", action="append", default=[])

    explain_parser = sub.add_parser("explain")
    explain_parser.add_argument("--focus", choices=["architecture", "automation", "runtime-boundary"], default="architecture")

    args = parser.parse_args(argv)
    if args.command == "doctor":
        print_json(doctor())
        return 0
    if args.command == "catalog":
        print_json({"sources": SOURCE_REGISTRY, "pathwaySeeds": PATHWAY_SEEDS, "privacyBoundary": PRIVACY_BOUNDARY})
        return 0
    if args.command == "sources":
        print_json({"sources": certified_source_records(), "privacyBoundary": PRIVACY_BOUNDARY, "nonClaims": NON_CLAIMS})
        return 0
    if args.command == "adapters":
        print_json({"adapterVersion": ADAPTER_VERSION, "adapters": ADAPTER_CERTIFICATIONS, "privacyBoundary": PRIVACY_BOUNDARY, "nonClaims": NON_CLAIMS})
        return 0
    if args.command == "certify":
        result = certify_registry()
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "terms-registry":
        result = terms_registry_artifact()
        result["validation"] = validate_terms_registry()
        result["legalReadiness"] = build_terms_registry()
        result["valid"] = result["validation"]["valid"] and result["legalReadiness"]["valid"]
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "legal-review-readiness":
        result = write_legal_review_packet(Path(args.markdown), Path(args.json))
        print_json(result)
        return 0 if result["termsRegistryStatus"] == "Green" else 1
    if args.command == "api-governance-check":
        config_path = Path(args.config)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/source-atlas-api-rate-governance.json")
            result = write_api_governance_report(Path(args.markdown), json_path, config_path)
        else:
            result = validate_api_governance(config_path, output_path=Path(args.emit_evidence) if args.emit_evidence else None)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "governance-registry-check":
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/governance/source-atlas-governance-train-01.json")
            result = write_governance_registry_report(
                Path(args.markdown),
                json_path,
                source_lane_path=Path(args.source_lanes) if args.source_lanes else None,
                legal_terms_path=Path(args.legal_terms) if args.legal_terms else None,
                api_governance_path=Path(args.api_governance) if args.api_governance else None,
            )
        else:
            result = validate_governance_registries(
                source_lane_path=Path(args.source_lanes) if args.source_lanes else None,
                legal_terms_path=Path(args.legal_terms) if args.legal_terms else None,
                api_governance_path=Path(args.api_governance) if args.api_governance else None,
                output_path=Path(args.emit_evidence) if args.emit_evidence else None,
            )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "terms-review":
        result = build_terms_distribution_review(Path("docs/qa/source-atlas/source-terms-distribution-review.json"))
        print_json(result)
        return 0 if result["registryValidation"]["valid"] else 1
    if args.command == "terms-approval-packet":
        from .terms_registry import SOURCE_TERMS_REGISTRY

        requested = set(args.sources or [])
        entries = [
            entry
            for entry in SOURCE_TERMS_REGISTRY
            if not requested or entry["source_id"] in requested
        ]
        missing = sorted(requested - {entry["source_id"] for entry in entries})
        if missing:
            parser.error("terms-approval-packet unknown source ids: " + ", ".join(missing))
        result = build_terms_approval_packet(
            entries,
            output_path=Path(args.json),
            created_at=args.created_at,
            reviewer=args.reviewer or "Codex internal Source Atlas legal/terms review under explicit user authorization",
        )
        print_json(result)
        return 0 if result["status"] in {"Green", "Yellow"} else 1
    if args.command == "adapter-fixtures":
        result = emit_all_adapter_fixtures(Path(args.output_root))
        print_json(result)
        return 0
    if args.command == "run-adapters":
        result = {"outputs": run_all_adapters(args.source_state)}
        print_json(result)
        return 0
    if args.command == "run-adapters-live":
        result = run_live_adapter_validation(
            LiveRunOptions(
                adapter=args.adapter,
                limit=args.limit,
                fixture_fallback=args.fixture_fallback,
                emit_evidence=Path(args.emit_evidence),
                no_pack=args.no_pack,
                pack_candidates=args.pack_candidates,
                validate_terms=args.validate_terms,
                validate_privacy=args.validate_privacy,
                rate_limit_safe=args.rate_limit_safe,
                timeout=args.timeout,
            )
        )
        print_json(result)
        return 0 if result["status"] == "Green" else 1
    if args.command == "broad-occupation-pack":
        if args.action == "stable-promote-proof":
            if args.dry_run == args.execute:
                parser.error("broad-occupation-pack stable-promote-proof requires exactly one of --dry-run or --execute")
            missing = [
                name
                for name, value in {
                    "--bucket": args.bucket,
                    "--source-prefix": args.source_prefix,
                    "--stable-prefix": args.stable_prefix,
                    "--emit-evidence": args.emit_evidence,
                }.items()
                if not value
            ]
            if missing:
                parser.error("broad-occupation-pack stable-promote-proof missing required flags: " + ", ".join(missing))
            result = run_stable_promote_proof(
                dry_run=args.dry_run,
                execute=args.execute,
                bucket=args.bucket,
                source_prefix=args.source_prefix,
                stable_prefix=args.stable_prefix,
                require_owner_approval=args.require_owner_approval,
                require_terms_green=args.require_terms_green,
                require_privacy_green=args.require_privacy_green,
                require_checksums=args.require_checksums,
                require_revocation=args.require_revocation,
                require_lkg=args.require_lkg,
                require_rollback=args.require_rollback,
                emit_evidence=Path(args.emit_evidence),
            )
            if args.markdown:
                write_stable_promotion_report(Path(args.markdown), Path(args.emit_evidence), result)
            print_json(result)
            return 0 if result["status"] in {"Green", "Yellow"} else 1
        if args.action == "promote-proof":
            emit_evidence = Path(args.emit_evidence or "docs/qa/source-atlas/broad-occupation-pack-promotion-proof.json")
            result = promote_broad_occupation_pack_proof(
                Path(args.pack_root),
                dry_run=args.dry_run,
                r2_validation_prefix=args.r2_validation_prefix,
                require_terms_green=args.require_terms_green,
                require_privacy_green=args.require_privacy_green,
                require_checksums=args.require_checksums,
                require_revocation=args.require_revocation,
                require_lkg=args.require_lkg,
                emit_evidence=emit_evidence,
                execute=args.execute,
                bucket=args.bucket,
                channel=args.channel,
                readback_root=Path(args.readback_root) if args.readback_root else None,
                confirm_public_reference_only=args.confirm_public_reference_only,
            )
            print_json(result)
            return 0 if result["status"] == "Green" else 1
        result = build_broad_occupational_foundation(Path(args.output_root), Path(args.docs_root))
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "green-reconciliation":
        result = build_green_reconciliation(
            Path(args.emit_evidence),
            live_evidence_path=Path(args.live_evidence),
            terms_review_path=Path(args.terms_review),
            coverage_ledger_path=Path(args.coverage_ledger),
            promotion_proof_path=Path(args.promotion_proof),
            production_r2_proof_path=Path(args.production_r2_proof),
        )
        print_json(result)
        return 0
    if args.command == "harvest":
        result = harvest_sources(Path(args.output_root), args.run_id, source_ids=args.sources, limit=args.limit)
        print_json(result)
        return 0 if result["privacyScan"]["passed"] else 1
    if args.command == "governed-harvest":
        result = run_governed_harvest(
            GovernedHarvestOptions(
                output_root=Path(args.output_root),
                run_id=args.run_id,
                mode=args.mode,
                source_ids=args.sources,
                limit=args.limit,
                live=args.live,
                execute=args.execute,
                created_at=args.created_at,
            )
        )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "claim-frontier":
        result = compile_claim_frontier(
            ClaimFrontierOptions(
                input_root=Path(args.input_root),
                output_root=Path(args.output_root),
                frontier_config_path=Path(args.frontier_config) if args.frontier_config else None,
                created_at=args.created_at,
            )
        )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "pack-production":
        result = build_pack_production(
            PackProductionOptions(
                input_root=Path(args.input_root),
                output_root=Path(args.output_root),
                domain=args.domain,
                environment=args.environment,
                channel=args.channel,
                pack_version=args.pack_version,
                created_at=args.created_at,
                execute=args.execute,
                approval_artifact=Path(args.approval_artifact) if args.approval_artifact else None,
                legal_approval_packet=Path(args.legal_approval_packet) if args.legal_approval_packet else None,
                budget_policy=args.budget_policy,
            )
        )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "volunteering-public-reference-activation":
        result = run_volunteering_public_reference_activation(
            VolunteeringPublicReferenceActivationOptions(
                output_root=Path(args.output_root),
                frontier_config_path=Path(args.frontier_config),
                created_at=args.created_at,
                run_label=args.run_label,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(volunteering_public_reference_activation_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "production-domain-admission":
        result = build_production_domain_admission(
            ProductionDomainAdmissionOptions(
                domain=args.domain,
                pack_root=Path(args.pack_root),
                output_root=Path(args.output_root),
                frontier_config_path=Path(args.frontier_config),
                production_target_ledger_path=Path(args.production_target_ledger) if args.production_target_ledger else None,
                legal_approval_packet=Path(args.legal_approval_packet) if args.legal_approval_packet else None,
                created_at=args.created_at,
                environment=args.environment,
                channel=args.channel,
                bucket=args.bucket,
                owner=args.owner or "Ambitions owner technical authorization captured in current Source Atlas goal thread",
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(production_domain_admission_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "pack-r2-publisher":
        result = run_pack_r2_publisher(
            PackR2PublisherOptions(
                pack_root=Path(args.pack_root),
                output_root=Path(args.output_root),
                environment=args.environment,
                channel=args.channel,
                mode=args.mode,
                created_at=args.created_at,
                execute=args.execute,
                approval_artifact=Path(args.approval_artifact) if args.approval_artifact else None,
                legal_approval_packet=Path(args.legal_approval_packet) if args.legal_approval_packet else None,
                budget_policy=args.budget_policy,
                bucket=args.bucket,
                local_store_root=Path(args.local_store_root) if args.local_store_root else None,
                readback_root=Path(args.readback_root) if args.readback_root else None,
                corrupt_readback_label=args.corrupt_readback_label,
                production_target_ledger_path=Path(args.production_target_ledger) if args.production_target_ledger else None,
                production_domain_admission_path=Path(args.production_domain_admission) if args.production_domain_admission else None,
                env_file_paths=tuple(Path(path) for path in args.env_files) if args.env_files else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(r2_pack_publisher_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "r2-live-inventory":
        result = run_r2_live_inventory(
            R2LiveInventoryOptions(
                production_target_ledger_path=Path(args.production_target_ledger),
                output_root=Path(args.output_root),
                hygiene_policy_path=Path(args.hygiene_policy) if args.hygiene_policy else None,
                bucket=args.bucket,
                prefix=args.prefix,
                env_file_paths=tuple(Path(path) for path in args.env_files) if args.env_files else None,
                account_id=args.account_id,
                created_at=args.created_at,
                verify_known_checksums=args.verify_known_checksums,
                max_checksum_reads=args.max_checksum_reads,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(r2_live_inventory_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "r2-hygiene-cleanup":
        result = run_r2_hygiene_cleanup(
            R2HygieneCleanupOptions(
                inventory_path=Path(args.inventory),
                output_root=Path(args.output_root),
                bucket=args.bucket,
                prefix=args.prefix,
                env_file_paths=tuple(Path(path) for path in args.env_files) if args.env_files else None,
                account_id=args.account_id,
                created_at=args.created_at,
                execute=args.execute,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(r2_hygiene_cleanup_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "r2-owner-approval":
        result = build_r2_owner_approval(
            R2OwnerApprovalOptions(
                production_target_ledger_path=Path(args.production_target_ledger),
                production_finish_line_gate_path=Path(args.production_finish_line_gate),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                environment=args.environment,
                channel=args.channel,
                bucket=args.bucket,
                owner=args.owner or "Ambitions owner technical authorization captured in current Source Atlas goal thread",
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(r2_owner_approval_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "native-refresh-registry":
        result = compile_native_refresh_registry(
            NativeRefreshRegistryOptions(
                publisher_reports=tuple(Path(path) for path in args.publisher_report),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                app_version=args.app_version,
                pack_schema_version=args.pack_schema_version,
                status=args.status,
                allowed_modes=tuple(args.allowed_mode or MODE_ORDER),
                public_locale=args.public_locale,
                approval_artifact=Path(args.approval_artifact) if args.approval_artifact else None,
                review_artifact_id=args.review_artifact_id,
                artifact_id=args.artifact_id,
                production_target_ledger_path=Path(args.production_target_ledger) if args.production_target_ledger else None,
                production_domain_admission_path=Path(args.production_domain_admission) if args.production_domain_admission else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(native_refresh_registry_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "native-runtime-current-proof":
        result = run_native_runtime_current_proof(
            NativeRuntimeCurrentProofOptions(
                production_target_ledger_path=Path(args.production_target_ledger),
                gateway_release_report_path=Path(args.gateway_release_report),
                native_registry_artifact_path=Path(args.native_registry_artifact),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                xcode_result=args.xcode_result,
                xcode_passed=args.xcode_passed,
                xcode_failed=args.xcode_failed,
                xcode_skipped=args.xcode_skipped,
                xcode_duration_ms=args.xcode_duration_ms,
                xcode_log_path=args.xcode_log_path,
                xcresult_path=args.xcresult_path,
                xcode_profile=args.xcode_profile,
                test_suites=tuple(args.test_suites or ()),
                endpoint=args.endpoint,
                branch=args.branch,
                commit_sha=args.commit_sha,
                worktree_dirty_entry_count=args.worktree_dirty_entry_count,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(native_runtime_current_proof_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "source-atlas-release-proof-packet":
        result = run_source_atlas_release_proof_packet(
            SourceAtlasReleaseProofPacketOptions(
                native_runtime_report_path=Path(args.native_runtime_report),
                output_root=Path(args.output_root),
                build_summary_path=Path(args.build_summary) if args.build_summary else None,
                source_atlas_pytest_result=args.source_atlas_pytest_result,
                source_atlas_pytest_passed=args.source_atlas_pytest_passed,
                source_atlas_pytest_failed=args.source_atlas_pytest_failed,
                boundary_audit_result=args.boundary_audit_result,
                no_private_egress_result=args.no_private_egress_result,
                green_standard_result=args.green_standard_result,
                local_first_result=args.local_first_result,
                git_diff_check_result=args.git_diff_check_result,
                build_for_testing_result=args.build_for_testing_result,
                focused_native_result=args.focused_native_result,
                focused_native_passed=args.focused_native_passed,
                focused_native_failed=args.focused_native_failed,
                focused_native_skipped=args.focused_native_skipped,
                physical_device_proof_path=Path(args.physical_device_proof) if args.physical_device_proof else None,
                accessibility_proof_path=Path(args.accessibility_proof) if args.accessibility_proof else None,
                visual_review_proof_path=Path(args.visual_review_proof) if args.visual_review_proof else None,
                app_store_connect_proof_path=Path(args.app_store_connect_proof) if args.app_store_connect_proof else None,
                testflight_proof_path=Path(args.testflight_proof) if args.testflight_proof else None,
                privacy_legal_release_signoff_path=Path(args.privacy_legal_release_signoff) if args.privacy_legal_release_signoff else None,
                owner_release_approval_path=Path(args.owner_release_approval) if args.owner_release_approval else None,
                created_at=args.created_at,
                run_label=args.run_label,
                branch=args.branch,
                commit_sha=args.commit_sha,
                environment=args.environment,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(source_atlas_release_proof_packet_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-gauntlet":
        result = run_goal_domain_gauntlet(
            GoalDomainGauntletOptions(
                frontier_config_path=Path(args.frontier_config),
                production_target_ledger_path=Path(args.production_target_ledger),
                arbitrary_domain_gate_path=Path(args.arbitrary_domain_gate),
                native_runtime_report_path=Path(args.native_runtime_report) if args.native_runtime_report else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                unknown_probe_domains=tuple(args.unknown_probe_domains) if args.unknown_probe_domains else DEFAULT_UNKNOWN_PROBES,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(goal_domain_gauntlet_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "public-reference-delivery-chain":
        result = run_public_reference_delivery_chain(
            PublicReferenceDeliveryChainOptions(
                output_root=Path(args.output_root),
                domain=args.domain,
                source_ids=tuple(args.sources) if args.sources else DEFAULT_SOURCE_IDS,
                harvest_mode=args.harvest_mode,
                limit=args.limit,
                live=args.live,
                execute_harvest=args.execute_harvest,
                environment=args.environment,
                channel=args.channel,
                pack_version=args.pack_version,
                r2_mode=args.r2_mode,
                execute_r2=args.execute_r2,
                r2_bucket=args.r2_bucket,
                r2_local_store_root=Path(args.r2_local_store_root) if args.r2_local_store_root else None,
                r2_readback_root=Path(args.r2_readback_root) if args.r2_readback_root else None,
                r2_budget_policy=args.r2_budget_policy,
                r2_approval_artifact=Path(args.r2_approval_artifact) if args.r2_approval_artifact else None,
                r2_env_file_paths=tuple(Path(path) for path in args.r2_env_files) if args.r2_env_files else None,
                legal_approval_packet=Path(args.legal_approval_packet) if args.legal_approval_packet else None,
                production_target_ledger_path=Path(args.production_target_ledger) if args.production_target_ledger else None,
                native_status=args.native_status,
                native_allowed_modes=tuple(args.native_allowed_mode or MODE_ORDER),
                native_public_locale=args.native_public_locale,
                native_approval_artifact=Path(args.native_approval_artifact) if args.native_approval_artifact else None,
                app_version=args.app_version,
                pack_schema_version=args.pack_schema_version,
                created_at=args.created_at,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(public_reference_delivery_chain_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "r2-public-gateway-allowlist":
        result = compile_public_gateway_allowlist(
            PublicGatewayAllowlistOptions(
                publisher_reports=tuple(Path(path) for path in args.publisher_report),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                worker_allowlist_path=Path(args.worker_allowlist_path) if args.worker_allowlist_path else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(public_gateway_allowlist_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "r2-public-gateway-release":
        result = run_public_gateway_release(
            PublicGatewayReleaseOptions(
                publisher_report_root=Path(args.publisher_report_root),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                worker_allowlist_path=Path(args.worker_allowlist_path) if args.worker_allowlist_path else None,
                worker_config_path=Path(args.worker_config) if args.worker_config else None,
                base_url=args.base_url,
                deploy=args.deploy,
                execute=args.execute,
                verify_live=args.verify_live,
                production_target_ledger_path=Path(args.production_target_ledger) if args.production_target_ledger else None,
                production_domain_admission_path=Path(args.production_domain_admission) if args.production_domain_admission else None,
                native_registry_artifact_path=Path(args.native_registry_artifact) if args.native_registry_artifact else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(public_gateway_release_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "production-target-ledger":
        result = build_production_target_ledger(
            ProductionTargetLedgerOptions(
                frontier_config_path=Path(args.frontier_config),
                source_lane_registry_path=Path(args.source_lane_registry),
                claim_frontier_report_root=Path(args.claim_frontier_report_root),
                pack_production_report_root=Path(args.pack_production_report_root),
                r2_publisher_report_root=Path(args.r2_publisher_report_root),
                gateway_release_report_path=Path(args.gateway_release_report) if args.gateway_release_report else None,
                native_registry_report_path=Path(args.native_registry_report) if args.native_registry_report else None,
                native_registry_artifact_path=Path(args.native_registry_artifact) if args.native_registry_artifact else None,
                native_runtime_closeout_path=Path(args.native_runtime_closeout) if args.native_runtime_closeout else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(production_target_ledger_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "production-recertification":
        result = run_production_recertification_gate(
            ProductionRecertificationOptions(
                production_target_ledger_path=Path(args.production_target_ledger),
                gateway_release_report_path=Path(args.gateway_release_report),
                native_runtime_report_path=Path(args.native_runtime_report),
                native_registry_artifact_path=Path(args.native_registry_artifact) if args.native_registry_artifact else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(production_recertification_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "production-finish-line-gate":
        result = run_production_finish_line_gate(
            ProductionFinishLineGateOptions(
                production_target_ledger_path=Path(args.production_target_ledger),
                gateway_release_report_path=Path(args.gateway_release_report),
                native_runtime_report_path=Path(args.native_runtime_report),
                native_registry_artifact_path=Path(args.native_registry_artifact) if args.native_registry_artifact else None,
                legal_terms_approval_packet_path=Path(args.legal_terms_approval_packet) if args.legal_terms_approval_packet else None,
                coverage_report_path=Path(args.coverage_report) if args.coverage_report else None,
                release_approval_artifact_path=Path(args.release_approval_artifact) if args.release_approval_artifact else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                compile_internal_terms_approval=not args.no_compile_internal_terms_approval,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(production_finish_line_gate_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "production-sweep":
        result = run_production_sweep(
            ProductionSweepOptions(
                production_target_ledger_path=Path(args.production_target_ledger),
                production_finish_line_gate_path=Path(args.production_finish_line_gate),
                arbitrary_domain_gate_path=Path(args.arbitrary_domain_gate),
                goal_domain_gauntlet_path=Path(args.goal_domain_gauntlet) if args.goal_domain_gauntlet else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                environment=args.environment,
                r2_bucket=args.r2_bucket,
                env_file_paths=tuple(Path(path) for path in args.env_files) if args.env_files else None,
                approval_artifact_path=Path(args.approval_artifact) if args.approval_artifact else None,
                legal_approval_packet_path=Path(args.legal_approval_packet) if args.legal_approval_packet else None,
                require_new_remote_write_ready=args.require_new_remote_write_ready,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(production_sweep_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-control-loop":
        result = run_autonomous_control_loop(
            AutonomousControlLoopOptions(
                production_sweep_path=Path(args.production_sweep),
                goal_domain_gauntlet_path=Path(args.goal_domain_gauntlet),
                owner_approval_path=Path(args.owner_approval),
                native_runtime_report_path=Path(args.native_runtime_report),
                production_finish_line_gate_path=Path(args.production_finish_line_gate),
                arbitrary_domain_gate_path=Path(args.arbitrary_domain_gate),
                autonomous_end_to_end_chain_path=Path(args.autonomous_end_to_end_chain) if args.autonomous_end_to_end_chain else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                environment=args.environment,
                channel=args.channel,
                bucket=args.bucket,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_control_loop_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-cycle-runner":
        result = run_autonomous_cycle_runner(
            AutonomousCycleRunnerOptions(
                control_loop_path=Path(args.control_loop),
                output_root=Path(args.output_root),
                previous_cycle_path=Path(args.previous_cycle) if args.previous_cycle else None,
                created_at=args.created_at,
                cycle_label=args.cycle_label,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_cycle_runner_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-cycle-executor":
        result = run_autonomous_cycle_executor(
            AutonomousCycleExecutorOptions(
                cycle_path=Path(args.cycle),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_cycle_executor_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-production-orchestrator":
        result = run_autonomous_production_orchestrator(
            AutonomousProductionOrchestratorOptions(
                production_target_ledger_path=Path(args.production_target_ledger),
                production_finish_line_gate_path=Path(args.production_finish_line_gate),
                production_sweep_path=Path(args.production_sweep),
                arbitrary_domain_gate_path=Path(args.arbitrary_domain_gate),
                goal_domain_gauntlet_path=Path(args.goal_domain_gauntlet),
                autonomous_control_loop_path=Path(args.autonomous_control_loop),
                autonomous_cycle_path=Path(args.autonomous_cycle),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_production_orchestrator_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-production-supervisor":
        result = run_autonomous_production_supervisor(
            AutonomousProductionSupervisorOptions(
                frontier_config_path=Path(args.frontier_config),
                source_lane_registry_path=Path(args.source_lane_registry),
                legal_terms_registry_path=Path(args.legal_terms_registry),
                api_governance_registry_path=Path(args.api_governance_registry),
                owner_approval_path=Path(args.owner_approval) if args.owner_approval else None,
                legal_approval_packet_path=Path(args.legal_approval_packet) if args.legal_approval_packet else None,
                promotion_bucket=args.promotion_bucket,
                production_target_ledger_path=Path(args.production_target_ledger),
                production_recertification_path=Path(args.production_recertification),
                production_finish_line_gate_path=Path(args.production_finish_line_gate),
                production_sweep_path=Path(args.production_sweep),
                arbitrary_domain_gate_path=Path(args.arbitrary_domain_gate),
                goal_domain_gauntlet_path=Path(args.goal_domain_gauntlet),
                autonomous_control_loop_path=Path(args.autonomous_control_loop),
                autonomous_cycle_path=Path(args.autonomous_cycle),
                requested_domains=tuple(args.requested_domains or ()),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                execute_safe_actions=args.execute_safe_actions,
                execute_r2=args.execute_r2,
                allow_fixture_delivery_chain=args.allow_fixture_delivery_chain,
                delivery_chain_limit=args.delivery_chain_limit,
                lookahead_days=args.lookahead_days,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_production_supervisor_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-freshness-scheduler":
        result = run_autonomous_freshness_planner(
            AutonomousFreshnessPlannerOptions(
                frontier_config_path=Path(args.frontier_config),
                source_lane_registry_path=Path(args.source_lane_registry),
                legal_terms_registry_path=Path(args.legal_terms_registry),
                api_governance_registry_path=Path(args.api_governance_registry),
                production_target_ledger_path=Path(args.production_target_ledger),
                production_recertification_path=Path(args.production_recertification),
                production_sweep_path=Path(args.production_sweep),
                autonomous_production_supervisor_path=Path(args.autonomous_production_supervisor) if args.autonomous_production_supervisor else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                lookahead_days=args.lookahead_days,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_freshness_planner_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-maintenance-executor":
        result = run_autonomous_maintenance_executor(
            AutonomousMaintenanceExecutorOptions(
                freshness_plan_path=Path(args.freshness_plan),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                execute_safe_actions=args.execute_safe_actions,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_maintenance_executor_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-promotion-runner":
        result = run_autonomous_promotion_runner(
            AutonomousPromotionRunnerOptions(
                supervisor_report_path=Path(args.supervisor_report),
                production_sweep_path=Path(args.production_sweep),
                owner_approval_path=Path(args.owner_approval) if args.owner_approval else None,
                legal_terms_registry_path=Path(args.legal_terms_registry),
                api_governance_registry_path=Path(args.api_governance_registry),
                legal_approval_packet_path=Path(args.legal_approval_packet) if args.legal_approval_packet else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                environment=args.environment,
                channel=args.channel,
                bucket=args.bucket,
                execute_r2=args.execute_r2,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_promotion_runner_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "source-atlas-completion-audit":
        result = run_source_atlas_completion_audit(
            SourceAtlasCompletionAuditOptions(
                production_supervisor_path=Path(args.production_supervisor),
                production_sweep_path=Path(args.production_sweep),
                production_finish_line_gate_path=Path(args.production_finish_line_gate),
                production_recertification_path=Path(args.production_recertification),
                production_target_ledger_path=Path(args.production_target_ledger),
                arbitrary_domain_gate_path=Path(args.arbitrary_domain_gate),
                goal_domain_gauntlet_path=Path(args.goal_domain_gauntlet),
                source_lane_registry_path=Path(args.source_lane_registry) if args.source_lane_registry else None,
                legal_terms_registry_path=Path(args.legal_terms_registry) if args.legal_terms_registry else None,
                api_governance_registry_path=Path(args.api_governance_registry) if args.api_governance_registry else None,
                native_runtime_report_path=Path(args.native_runtime_report) if args.native_runtime_report else None,
                release_proof_packet_path=Path(args.release_proof_packet) if args.release_proof_packet else None,
                legal_approval_packet_path=Path(args.legal_approval_packet) if args.legal_approval_packet else None,
                owner_approval_path=Path(args.owner_approval) if args.owner_approval else None,
                launch_floor_ledger_path=Path(args.launch_floor_ledger) if args.launch_floor_ledger else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(source_atlas_completion_audit_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "launch-floor-domain-taxonomy":
        result = compile_launch_floor_domain_taxonomy(
            LaunchFloorDomainTaxonomyOptions(
                taxonomy_path=Path(args.taxonomy),
                source_lane_registry_path=Path(args.source_lane_registry) if args.source_lane_registry else None,
                production_target_ledger_path=Path(args.production_target_ledger) if args.production_target_ledger else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(launch_floor_domain_taxonomy_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "launch-floor-shard-corpus":
        result = compile_launch_floor_shard_corpus(
            LaunchFloorShardCorpusOptions(
                manifest_path=Path(args.manifest),
                launch_floor_taxonomy_path=Path(args.launch_floor_taxonomy) if args.launch_floor_taxonomy else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(launch_floor_shard_corpus_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "launch-floor-shard-corpus-compiler":
        result = compile_launch_floor_shard_corpus_bulk(
            LaunchFloorShardCorpusCompilerOptions(
                production_target_ledger_path=Path(args.production_target_ledger),
                source_lane_registry_path=Path(args.source_lane_registry),
                legal_terms_registry_path=Path(args.legal_terms_registry),
                api_governance_registry_path=Path(args.api_governance_registry),
                launch_floor_taxonomy_path=Path(args.launch_floor_taxonomy),
                source_units_path=Path(args.source_units) if args.source_units else None,
                max_partition_shards=args.max_partition_shards,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
                emit_manifest_path=Path(args.emit_manifest) if args.emit_manifest else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(launch_floor_shard_corpus_compiler_markdown(result), encoding="utf-8")
        if args.emit_manifest:
            write_json(Path(args.emit_manifest), read_json(Path(result["outputPaths"]["manifest"])))
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "launch-floor-r2-layout-proof":
        result = run_launch_floor_r2_layout_proof(
            LaunchFloorR2LayoutProofOptions(
                shard_corpus_manifest_path=Path(args.shard_corpus_manifest),
                launch_floor_taxonomy_path=Path(args.launch_floor_taxonomy) if args.launch_floor_taxonomy else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                readback_mode=args.readback_mode,
                sample_stride=args.sample_stride,
                gateway_load_probe_count=args.gateway_load_probe_count,
                simulate_readback_mismatch_object_key=args.simulate_readback_mismatch_object_key,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(launch_floor_r2_layout_proof_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "launch-floor-native-shard-index-proof":
        result = run_launch_floor_native_shard_index_proof(
            LaunchFloorNativeShardIndexProofOptions(
                shard_corpus_manifest_path=Path(args.shard_corpus_manifest),
                r2_layout_inventory_path=Path(args.r2_layout_inventory),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                xcode_result=args.xcode_result,
                xcode_passed=args.xcode_passed,
                xcode_failed=args.xcode_failed,
                xcode_skipped=args.xcode_skipped,
                xcode_duration_ms=args.xcode_duration_ms,
                xcode_log_path=args.xcode_log_path,
                xcode_profile=args.xcode_profile,
                branch=args.branch,
                commit_sha=args.commit_sha,
                worktree_dirty_entry_count=args.worktree_dirty_entry_count,
                test_suites=tuple(args.test_suites or ()),
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(launch_floor_native_shard_index_proof_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "launch-floor-golden-intent-corpus":
        result = compile_launch_floor_golden_intent_corpus(
            LaunchFloorGoldenIntentCorpusOptions(
                input_paths=tuple(Path(path) for path in args.inputs),
                input_format=args.input_format,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                source_lane_registry_path=Path(args.source_lane_registry) if args.source_lane_registry else None,
                production_target_ledger_path=Path(args.production_target_ledger) if args.production_target_ledger else None,
                target_count=args.target_count,
                intents_per_subdomain=args.intents_per_subdomain,
                control_records_per_domain=args.control_records_per_domain,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(launch_floor_golden_intent_corpus_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "launch-floor-governance-renewal":
        result = compile_launch_floor_governance_renewal(
            LaunchFloorGovernanceRenewalOptions(
                source_lane_registry_path=Path(args.source_lane_registry),
                legal_terms_registry_path=Path(args.legal_terms_registry),
                api_governance_registry_path=Path(args.api_governance_registry),
                launch_floor_taxonomy_path=Path(args.launch_floor_taxonomy),
                production_target_ledger_path=Path(args.production_target_ledger),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            coverage_records = read_json(Path(result["outputPaths"]["coverageMap"])).get("coverageRecords", [])
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(
                launch_floor_governance_renewal_markdown(result, coverage_records),
                encoding="utf-8",
            )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "source-needed-fallback-metric":
        result = compile_source_needed_fallback_metric(
            SourceNeededFallbackMetricOptions(
                golden_intent_corpus_report_path=Path(args.golden_intent_corpus_report),
                normalized_corpus_path=Path(args.normalized_corpus) if args.normalized_corpus else None,
                previous_metric_path=Path(args.previous_metric) if args.previous_metric else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                emit_missing_shard_events_path=Path(args.emit_missing_shard_events)
                if args.emit_missing_shard_events
                else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(source_needed_fallback_metric_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "missing-shard-event-queue":
        result = compile_missing_shard_event_queue(
            MissingShardEventQueueOptions(
                missing_shard_events_path=Path(args.missing_shard_events),
                fallback_metric_path=Path(args.fallback_metric) if args.fallback_metric else None,
                previous_queue_path=Path(args.previous_queue) if args.previous_queue else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(missing_shard_event_queue_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "missing-shard-review-gate":
        result = compile_missing_shard_review_gate(
            MissingShardReviewGateOptions(
                missing_shard_queue_path=Path(args.missing_shard_queue),
                source_lane_registry_path=Path(args.source_lane_registry) if args.source_lane_registry else None,
                legal_terms_registry_path=Path(args.legal_terms_registry) if args.legal_terms_registry else None,
                api_governance_registry_path=Path(args.api_governance_registry) if args.api_governance_registry else None,
                approval_artifact_path=Path(args.approval_artifact) if args.approval_artifact else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                execute=args.execute,
                allow_active_registry_write=args.allow_active_registry_write,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(missing_shard_review_gate_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "missing-shard-activation-executor":
        result = compile_missing_shard_activation_executor(
            MissingShardActivationExecutorOptions(
                review_gate_path=Path(args.review_gate),
                activation_approval_path=Path(args.activation_approval) if args.activation_approval else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                execute=args.execute,
                allow_r2_write=args.allow_r2_write,
                allow_native_activation=args.allow_native_activation,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(missing_shard_activation_executor_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "missing-shard-expansion-supervisor":
        result = compile_missing_shard_expansion_supervisor(
            MissingShardExpansionSupervisorOptions(
                missing_shard_queue_path=Path(args.missing_shard_queue),
                review_gate_path=Path(args.review_gate),
                activation_executor_path=Path(args.activation_executor),
                fallback_metric_path=Path(args.fallback_metric),
                previous_fallback_metric_path=Path(args.previous_fallback_metric)
                if args.previous_fallback_metric
                else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                as_of=args.as_of,
                run_label=args.run_label,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(missing_shard_expansion_supervisor_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "source-atlas-launch-floor-ledger":
        result = build_source_atlas_launch_floor_ledger(
            SourceAtlasLaunchFloorLedgerOptions(
                frontier_config_path=Path(args.frontier_config),
                source_lane_registry_path=Path(args.source_lane_registry),
                legal_terms_registry_path=Path(args.legal_terms_registry),
                api_governance_registry_path=Path(args.api_governance_registry),
                production_target_ledger_path=Path(args.production_target_ledger),
                r2_live_inventory_path=Path(args.r2_live_inventory),
                goal_domain_gauntlet_path=Path(args.goal_domain_gauntlet),
                completion_audit_path=Path(args.completion_audit),
                release_proof_packet_path=Path(args.release_proof_packet),
                production_supervisor_path=Path(args.production_supervisor) if args.production_supervisor else None,
                autonomous_control_loop_path=Path(args.autonomous_control_loop) if args.autonomous_control_loop else None,
                autonomous_domain_expansion_chain_path=Path(args.autonomous_domain_expansion_chain)
                if args.autonomous_domain_expansion_chain
                else None,
                launch_floor_taxonomy_path=Path(args.launch_floor_taxonomy) if args.launch_floor_taxonomy else None,
                shard_corpus_manifest_path=Path(args.shard_corpus_manifest) if args.shard_corpus_manifest else None,
                r2_layout_proof_path=Path(args.r2_layout_proof) if args.r2_layout_proof else None,
                golden_intent_corpus_path=Path(args.golden_intent_corpus) if args.golden_intent_corpus else None,
                fallback_metric_path=Path(args.fallback_metric) if args.fallback_metric else None,
                missing_shard_events_path=Path(args.missing_shard_events) if args.missing_shard_events else None,
                missing_shard_review_gate_path=Path(args.missing_shard_review_gate)
                if args.missing_shard_review_gate
                else None,
                missing_shard_activation_executor_path=Path(args.missing_shard_activation_executor)
                if args.missing_shard_activation_executor
                else None,
                missing_shard_expansion_supervisor_path=Path(args.missing_shard_expansion_supervisor)
                if args.missing_shard_expansion_supervisor
                else None,
                native_runtime_bridge_gauntlet_source_path=Path(args.native_runtime_bridge_gauntlet_source)
                if args.native_runtime_bridge_gauntlet_source
                else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                run_label=args.run_label,
                emit_evidence_path=Path(args.emit_evidence) if args.emit_evidence else None,
                markdown_path=Path(args.markdown) if args.markdown else None,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(source_atlas_launch_floor_ledger_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "arbitrary-domain-handling-gate":
        result = run_arbitrary_domain_handling_gate(
            ArbitraryDomainHandlingGateOptions(
                frontier_config_path=Path(args.frontier_config),
                source_lane_registry_path=Path(args.source_lane_registry),
                production_target_ledger_path=Path(args.production_target_ledger),
                production_recertification_path=Path(args.production_recertification),
                finish_line_gate_path=Path(args.finish_line_gate) if args.finish_line_gate else None,
                output_root=Path(args.output_root),
                created_at=args.created_at,
                unknown_probe_domains=tuple(args.unknown_probe_domains or DEFAULT_UNKNOWN_PROBES),
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(arbitrary_domain_handling_gate_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-operations-plan":
        result = compile_autonomous_operations_plan(
            AutonomousOperationsPlannerOptions(
                frontier_config_path=Path(args.frontier_config),
                source_lane_registry_path=Path(args.source_lane_registry),
                production_target_ledger_path=Path(args.production_target_ledger) if args.production_target_ledger else None,
                production_recertification_path=Path(args.production_recertification) if args.production_recertification else None,
                requested_domains=tuple(args.requested_domains or ()),
                output_root=Path(args.output_root),
                created_at=args.created_at,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_operations_plan_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-operations-execute":
        result = run_autonomous_operations_executor(
            AutonomousOperationsExecutorOptions(
                operations_plan_path=Path(args.operations_plan),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                execute_safe_actions=args.execute_safe_actions,
                allow_fixture_delivery_chain=args.allow_fixture_delivery_chain,
                frontier_config_path=Path(args.frontier_config) if args.frontier_config else None,
                delivery_chain_limit=args.delivery_chain_limit,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_operations_execution_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-domain-expansion-chain":
        result = run_autonomous_domain_expansion_chain(
            AutonomousDomainExpansionChainOptions(
                executor_report_path=Path(args.executor_report),
                output_root=Path(args.output_root),
                frontier_config_path=Path(args.frontier_config) if args.frontier_config else None,
                production_target_ledger_path=Path(args.production_target_ledger) if args.production_target_ledger else None,
                mode=args.mode,
                reviewer=args.reviewer,
                created_at=args.created_at,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_domain_expansion_chain_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-registry-activation-chain":
        result = run_autonomous_registry_activation_chain(
            AutonomousRegistryActivationChainOptions(
                expansion_chain_report_path=Path(args.expansion_chain_report),
                output_root=Path(args.output_root),
                completion_evidence_path=Path(args.completion_evidence) if args.completion_evidence else None,
                source_specific_apply_input_path=Path(args.source_specific_apply_input) if args.source_specific_apply_input else None,
                source_lane_registry_path=Path(args.source_lane_registry) if args.source_lane_registry else None,
                legal_terms_registry_path=Path(args.legal_terms_registry) if args.legal_terms_registry else None,
                api_governance_registry_path=Path(args.api_governance_registry) if args.api_governance_registry else None,
                created_at=args.created_at,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_registry_activation_chain_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "autonomous-end-to-end-chain":
        result = run_autonomous_end_to_end_chain(
            AutonomousEndToEndChainOptions(
                frontier_config_path=Path(args.frontier_config),
                source_lane_registry_path=Path(args.source_lane_registry),
                legal_terms_registry_path=Path(args.legal_terms_registry) if args.legal_terms_registry else None,
                api_governance_registry_path=Path(args.api_governance_registry) if args.api_governance_registry else None,
                production_target_ledger_path=Path(args.production_target_ledger) if args.production_target_ledger else None,
                production_recertification_path=Path(args.production_recertification) if args.production_recertification else None,
                gateway_release_report_path=Path(args.gateway_release_report) if args.gateway_release_report else None,
                native_runtime_report_path=Path(args.native_runtime_report) if args.native_runtime_report else None,
                native_registry_artifact_path=Path(args.native_registry_artifact) if args.native_registry_artifact else None,
                requested_domains=tuple(args.requested_domains or ()),
                output_root=Path(args.output_root),
                created_at=args.created_at,
                refresh_production_recertification=args.refresh_production_recertification,
                execute_safe_actions=args.execute_safe_actions,
                allow_fixture_delivery_chain=args.allow_fixture_delivery_chain,
                delivery_chain_limit=args.delivery_chain_limit,
                domain_expansion_mode=args.domain_expansion_mode,
                reviewer=args.reviewer,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(autonomous_end_to_end_chain_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "broad-domain-discovery":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-broad-domain-discovery-train-07.json")
            result = write_broad_domain_discovery_report(
                Path(args.markdown),
                json_path,
                output_root=output_root,
                frontier_config_path=Path(args.frontier_config) if args.frontier_config else None,
                created_at=args.created_at,
            )
        else:
            result = build_broad_domain_discovery(
                BroadDomainDiscoveryOptions(
                    output_root=output_root,
                    frontier_config_path=Path(args.frontier_config) if args.frontier_config else None,
                    created_at=args.created_at,
                )
            )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "frontier-intake":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-frontier-intake-train-52.json")
            result = write_frontier_intake_report(
                Path(args.markdown),
                json_path,
                input_path=Path(args.input),
                output_root=output_root,
                frontier_config_path=Path(args.frontier_config) if args.frontier_config else None,
                created_at=args.created_at,
            )
        else:
            result = compile_frontier_intake(
                FrontierIntakeOptions(
                    input_path=Path(args.input),
                    output_root=output_root,
                    frontier_config_path=Path(args.frontier_config) if args.frontier_config else None,
                    created_at=args.created_at,
                )
            )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "deep-research-frontier-intake":
        result = run_deep_research_frontier_intake(
            DeepResearchFrontierIntakeOptions(
                input_path=Path(args.input),
                output_root=Path(args.output_root),
                frontier_config_path=Path(args.frontier_config) if args.frontier_config else None,
                source_lane_registry_path=Path(args.source_lane_registry) if args.source_lane_registry else None,
                created_at=args.created_at,
            )
        )
        if args.emit_evidence:
            write_json(Path(args.emit_evidence), result)
        if args.markdown:
            Path(args.markdown).parent.mkdir(parents=True, exist_ok=True)
            Path(args.markdown).write_text(deep_research_frontier_intake_markdown(result), encoding="utf-8")
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-router":
        output_root = Path(args.output_root)
        production_target_ledger_path = Path(args.production_target_ledger) if args.production_target_ledger else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-goal-domain-router-train-88.json")
            result = write_goal_domain_router_report(
                Path(args.markdown),
                json_path,
                input_path=Path(args.input),
                output_root=output_root,
                frontier_config_path=Path(args.frontier_config) if args.frontier_config else None,
                production_target_ledger_path=production_target_ledger_path,
                launch_floor_taxonomy_path=Path(args.launch_floor_taxonomy) if args.launch_floor_taxonomy else None,
                created_at=args.created_at,
            )
        else:
            result = compile_goal_domain_router(
                GoalDomainRouterOptions(
                    input_path=Path(args.input),
                    output_root=output_root,
                    frontier_config_path=Path(args.frontier_config) if args.frontier_config else None,
                    production_target_ledger_path=production_target_ledger_path,
                    launch_floor_taxonomy_path=Path(args.launch_floor_taxonomy) if args.launch_floor_taxonomy else None,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-production-lanes":
        output_root = Path(args.output_root)
        production_target_ledger_path = Path(args.production_target_ledger) if args.production_target_ledger else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-goal-domain-production-lanes-train-89.json")
            result = write_goal_domain_production_lanes_report(
                Path(args.markdown),
                json_path,
                router_manifest_path=Path(args.router_manifest),
                output_root=output_root,
                production_target_ledger_path=production_target_ledger_path,
                created_at=args.created_at,
            )
        else:
            result = compile_goal_domain_production_lanes(
                GoalDomainProductionLaneOptions(
                    router_manifest_path=Path(args.router_manifest),
                    output_root=output_root,
                    production_target_ledger_path=production_target_ledger_path,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-work-order-executor":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-goal-domain-work-order-executor-train-90.json")
            result = write_goal_domain_work_order_executor_report(
                Path(args.markdown),
                json_path,
                production_lanes_manifest_path=Path(args.production_lanes_manifest),
                output_root=output_root,
                mode=args.mode,
                created_at=args.created_at,
            )
        else:
            result = run_goal_domain_work_order_executor(
                GoalDomainWorkOrderExecutorOptions(
                    production_lanes_manifest_path=Path(args.production_lanes_manifest),
                    output_root=output_root,
                    mode=args.mode,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-review-packets":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-goal-domain-review-packets-train-92.json")
            result = write_goal_domain_review_packets_report(
                Path(args.markdown),
                json_path,
                executor_manifest_path=Path(args.executor_manifest),
                output_root=output_root,
                reviewer=args.reviewer,
                created_at=args.created_at,
            )
        else:
            result = compile_goal_domain_review_packets(
                GoalDomainReviewPacketOptions(
                    executor_manifest_path=Path(args.executor_manifest),
                    output_root=output_root,
                    reviewer=args.reviewer,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-review-completion-intake":
        output_root = Path(args.output_root)
        completion_evidence = Path(args.completion_evidence) if args.completion_evidence else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-goal-domain-review-completion-intake-train-93.json")
            result = write_goal_domain_review_completion_intake_report(
                Path(args.markdown),
                json_path,
                review_templates_path=Path(args.review_templates),
                output_root=output_root,
                completion_evidence_path=completion_evidence,
                created_at=args.created_at,
            )
        else:
            result = compile_goal_domain_review_completion_intake(
                GoalDomainReviewCompletionIntakeOptions(
                    review_templates_path=Path(args.review_templates),
                    output_root=output_root,
                    completion_evidence_path=completion_evidence,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-registry-mutation-plan":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-goal-domain-registry-mutation-plan-train-94.json")
            result = write_goal_domain_registry_mutation_plan_report(
                Path(args.markdown),
                json_path,
                review_completions_path=Path(args.review_completions),
                output_root=output_root,
                execute=args.execute,
                allow_active_registry_write=args.allow_active_registry_write,
                created_at=args.created_at,
            )
        else:
            result = compile_goal_domain_registry_mutation_plan(
                GoalDomainRegistryMutationPlanOptions(
                    review_completions_path=Path(args.review_completions),
                    output_root=output_root,
                    execute=args.execute,
                    allow_active_registry_write=args.allow_active_registry_write,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-registry-applier":
        output_root = Path(args.output_root)
        source_lane_registry = Path(args.source_lane_registry) if args.source_lane_registry else None
        legal_terms_registry = Path(args.legal_terms_registry) if args.legal_terms_registry else None
        api_governance_registry = Path(args.api_governance_registry) if args.api_governance_registry else None
        approval_artifact = Path(args.approval_artifact) if args.approval_artifact else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-goal-domain-registry-applier-train-95.json")
            result = write_goal_domain_registry_applier_report(
                Path(args.markdown),
                json_path,
                plan_path=Path(args.plan),
                output_root=output_root,
                source_lane_registry_path=source_lane_registry,
                legal_terms_registry_path=legal_terms_registry,
                api_governance_registry_path=api_governance_registry,
                approval_artifact=approval_artifact,
                execute=args.execute,
                allow_active_registry_write=args.allow_active_registry_write,
                created_at=args.created_at,
            )
        else:
            result = compile_goal_domain_registry_applier(
                GoalDomainRegistryApplierOptions(
                    plan_path=Path(args.plan),
                    output_root=output_root,
                    source_lane_registry_path=source_lane_registry,
                    legal_terms_registry_path=legal_terms_registry,
                    api_governance_registry_path=api_governance_registry,
                    approval_artifact=approval_artifact,
                    execute=args.execute,
                    allow_active_registry_write=args.allow_active_registry_write,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-registry-apply-rehearsal":
        output_root = Path(args.output_root)
        source_lane_registry = Path(args.source_lane_registry) if args.source_lane_registry else None
        legal_terms_registry = Path(args.legal_terms_registry) if args.legal_terms_registry else None
        api_governance_registry = Path(args.api_governance_registry) if args.api_governance_registry else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-goal-domain-registry-apply-rehearsal-train-96.json")
            result = write_goal_domain_registry_apply_rehearsal_report(
                Path(args.markdown),
                json_path,
                review_templates_path=Path(args.review_templates),
                output_root=output_root,
                source_lane_registry_path=source_lane_registry,
                legal_terms_registry_path=legal_terms_registry,
                api_governance_registry_path=api_governance_registry,
                created_at=args.created_at,
            )
        else:
            result = run_goal_domain_registry_apply_rehearsal(
                GoalDomainRegistryApplyRehearsalOptions(
                    review_templates_path=Path(args.review_templates),
                    output_root=output_root,
                    source_lane_registry_path=source_lane_registry,
                    legal_terms_registry_path=legal_terms_registry,
                    api_governance_registry_path=api_governance_registry,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-active-registry-apply-gate":
        output_root = Path(args.output_root)
        review_evidence = Path(args.review_evidence) if args.review_evidence else None
        source_lane_registry = Path(args.source_lane_registry) if args.source_lane_registry else None
        legal_terms_registry = Path(args.legal_terms_registry) if args.legal_terms_registry else None
        api_governance_registry = Path(args.api_governance_registry) if args.api_governance_registry else None
        approval_artifact = Path(args.approval_artifact) if args.approval_artifact else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-goal-domain-active-registry-apply-gate-train-97.json")
            result = write_goal_domain_active_registry_apply_gate_report(
                Path(args.markdown),
                json_path,
                plan_path=Path(args.plan),
                output_root=output_root,
                review_evidence_path=review_evidence,
                source_lane_registry_path=source_lane_registry,
                legal_terms_registry_path=legal_terms_registry,
                api_governance_registry_path=api_governance_registry,
                approval_artifact=approval_artifact,
                execute=args.execute,
                allow_active_registry_write=args.allow_active_registry_write,
                created_at=args.created_at,
            )
        else:
            result = compile_goal_domain_active_registry_apply_gate(
                GoalDomainActiveRegistryApplyGateOptions(
                    plan_path=Path(args.plan),
                    output_root=output_root,
                    review_evidence_path=review_evidence,
                    source_lane_registry_path=source_lane_registry,
                    legal_terms_registry_path=legal_terms_registry,
                    api_governance_registry_path=api_governance_registry,
                    approval_artifact=approval_artifact,
                    execute=args.execute,
                    allow_active_registry_write=args.allow_active_registry_write,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-source-specific-apply-packet":
        output_root = Path(args.output_root)
        source_lane_registry = Path(args.source_lane_registry) if args.source_lane_registry else None
        legal_terms_registry = Path(args.legal_terms_registry) if args.legal_terms_registry else None
        api_governance_registry = Path(args.api_governance_registry) if args.api_governance_registry else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-goal-domain-source-specific-apply-packet-train-98.json")
            result = write_goal_domain_source_specific_apply_packet_report(
                Path(args.markdown),
                json_path,
                input_path=Path(args.input),
                output_root=output_root,
                source_lane_registry_path=source_lane_registry,
                legal_terms_registry_path=legal_terms_registry,
                api_governance_registry_path=api_governance_registry,
                created_at=args.created_at,
            )
        else:
            result = compile_goal_domain_source_specific_apply_packet(
                GoalDomainSourceSpecificApplyPacketOptions(
                    input_path=Path(args.input),
                    output_root=output_root,
                    source_lane_registry_path=source_lane_registry,
                    legal_terms_registry_path=legal_terms_registry,
                    api_governance_registry_path=api_governance_registry,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "goal-domain-production-activation":
        output_root = Path(args.output_root)
        target_source_lane_registry = Path(args.target_source_lane_registry) if args.target_source_lane_registry else None
        target_legal_terms_registry = Path(args.target_legal_terms_registry) if args.target_legal_terms_registry else None
        target_api_governance_registry = Path(args.target_api_governance_registry) if args.target_api_governance_registry else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-goal-domain-production-activation-train-99.json")
            result = write_goal_domain_production_activation_report(
                Path(args.markdown),
                json_path,
                input_path=Path(args.input),
                output_root=output_root,
                target_source_lane_registry_path=target_source_lane_registry,
                target_legal_terms_registry_path=target_legal_terms_registry,
                target_api_governance_registry_path=target_api_governance_registry,
                execute_active_registry=args.execute_active_registry,
                allow_active_registry_write=args.allow_active_registry_write,
                created_at=args.created_at,
            )
        else:
            result = compile_goal_domain_production_activation(
                GoalDomainProductionActivationOptions(
                    input_path=Path(args.input),
                    output_root=output_root,
                    target_source_lane_registry_path=target_source_lane_registry,
                    target_legal_terms_registry_path=target_legal_terms_registry,
                    target_api_governance_registry_path=target_api_governance_registry,
                    execute_active_registry=args.execute_active_registry,
                    allow_active_registry_write=args.allow_active_registry_write,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-discovery":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-discovery-train-53.json")
            result = write_catalog_discovery_report(
                Path(args.markdown),
                json_path,
                input_root=Path(args.input_root),
                output_root=output_root,
                created_at=args.created_at,
            )
        else:
            result = run_catalog_discovery(
                CatalogDiscoveryOptions(
                    input_root=Path(args.input_root),
                    output_root=output_root,
                    created_at=args.created_at,
                )
            )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-transport":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-transport-train-54.json")
            result = write_catalog_transport_report(
                Path(args.markdown),
                json_path,
                plan_path=Path(args.plan),
                output_root=output_root,
                mode=args.mode,
                live=args.live,
                execute=args.execute,
                created_at=args.created_at,
            )
        else:
            result = run_catalog_transport(
                CatalogTransportOptions(
                    plan_path=Path(args.plan),
                    output_root=output_root,
                    mode=args.mode,
                    live=args.live,
                    execute=args.execute,
                    created_at=args.created_at,
                )
            )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-candidate-review":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-candidate-review-train-56.json")
            result = write_catalog_candidate_review_report(
                Path(args.markdown),
                json_path,
                input_path=Path(args.input),
                output_root=output_root,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_candidate_review(
                CatalogCandidateReviewOptions(
                    input_path=Path(args.input),
                    output_root=output_root,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-governance-intake":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-governance-intake-train-57.json")
            result = write_catalog_governance_intake_report(
                Path(args.markdown),
                json_path,
                input_path=Path(args.input),
                output_root=output_root,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_governance_intake(
                CatalogGovernanceIntakeOptions(
                    input_path=Path(args.input),
                    output_root=output_root,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-registry-mutation-plan":
        output_root = Path(args.output_root)
        approval_artifact = Path(args.approval_artifact) if args.approval_artifact else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-registry-mutation-plan-train-58.json")
            result = write_catalog_registry_mutation_plan_report(
                Path(args.markdown),
                json_path,
                input_path=Path(args.input),
                output_root=output_root,
                approval_artifact=approval_artifact,
                execute=args.execute,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_registry_mutation_plan(
                CatalogRegistryMutationPlanOptions(
                    input_path=Path(args.input),
                    output_root=output_root,
                    approval_artifact=approval_artifact,
                    execute=args.execute,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-registry-applier":
        output_root = Path(args.output_root)
        source_lane_registry = Path(args.source_lane_registry) if args.source_lane_registry else None
        legal_terms_registry = Path(args.legal_terms_registry) if args.legal_terms_registry else None
        api_governance_registry = Path(args.api_governance_registry) if args.api_governance_registry else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-registry-applier-train-60.json")
            result = write_catalog_registry_applier_report(
                Path(args.markdown),
                json_path,
                plan_path=Path(args.plan),
                output_root=output_root,
                source_lane_registry_path=source_lane_registry,
                legal_terms_registry_path=legal_terms_registry,
                api_governance_registry_path=api_governance_registry,
                execute=args.execute,
                allow_active_registry_write=args.allow_active_registry_write,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_registry_applier(
                CatalogRegistryApplierOptions(
                    plan_path=Path(args.plan),
                    output_root=output_root,
                    source_lane_registry_path=source_lane_registry,
                    legal_terms_registry_path=legal_terms_registry,
                    api_governance_registry_path=api_governance_registry,
                    execute=args.execute,
                    allow_active_registry_write=args.allow_active_registry_write,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-registry-approval-request":
        output_root = Path(args.output_root)
        intake_ids = tuple(args.intake_ids or ())
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-registry-approval-request-train-59.json")
            result = write_catalog_registry_approval_request_report(
                Path(args.markdown),
                json_path,
                input_path=Path(args.input),
                output_root=output_root,
                intake_ids=intake_ids,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_registry_approval_request(
                CatalogRegistryApprovalRequestOptions(
                    input_path=Path(args.input),
                    output_root=output_root,
                    intake_ids=intake_ids,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-terms-resolution":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-terms-resolution-train-61.json")
            result = write_catalog_terms_resolution_report(
                Path(args.markdown),
                json_path,
                input_path=Path(args.input),
                output_root=output_root,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_terms_resolution(
                CatalogTermsResolutionOptions(
                    input_path=Path(args.input),
                    output_root=output_root,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-approval-finalizer":
        output_root = Path(args.output_root)
        decision_artifact = Path(args.decision_artifact) if args.decision_artifact else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-approval-finalizer-train-62.json")
            result = write_catalog_approval_finalizer_report(
                Path(args.markdown),
                json_path,
                terms_proposals_path=Path(args.terms_proposals),
                output_root=output_root,
                decision_artifact=decision_artifact,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_approval_finalizer(
                CatalogApprovalFinalizerOptions(
                    terms_proposals_path=Path(args.terms_proposals),
                    output_root=output_root,
                    decision_artifact=decision_artifact,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-approval-preflight":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-approval-preflight-train-63.json")
            result = write_catalog_approval_preflight_report(
                Path(args.markdown),
                json_path,
                terms_proposals_path=Path(args.terms_proposals),
                output_root=output_root,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_approval_preflight(
                CatalogApprovalPreflightOptions(
                    terms_proposals_path=Path(args.terms_proposals),
                    output_root=output_root,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-approval-decision-inputs":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-approval-decision-inputs-train-64.json")
            result = write_catalog_approval_decision_inputs_report(
                Path(args.markdown),
                json_path,
                preflight_records_path=Path(args.preflight_records),
                output_root=output_root,
                created_at=args.created_at,
                decision_owner=args.decision_owner,
            )
        else:
            result = compile_catalog_approval_decision_inputs(
                CatalogApprovalDecisionInputsOptions(
                    preflight_records_path=Path(args.preflight_records),
                    output_root=output_root,
                    created_at=args.created_at,
                    decision_owner=args.decision_owner,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-approval-decision-assembler":
        output_root = Path(args.output_root)
        review_completion = Path(args.review_completion) if args.review_completion else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-approval-decision-assembler-train-65.json")
            result = write_catalog_approval_decision_assembler_report(
                Path(args.markdown),
                json_path,
                decision_inputs_path=Path(args.decision_inputs),
                output_root=output_root,
                review_completion_path=review_completion,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_approval_decision_assembler(
                CatalogApprovalDecisionAssemblerOptions(
                    decision_inputs_path=Path(args.decision_inputs),
                    output_root=output_root,
                    review_completion_path=review_completion,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-approval-chain":
        output_root = Path(args.output_root)
        review_completion = Path(args.review_completion) if args.review_completion else None
        source_lane_registry = Path(args.source_lane_registry) if args.source_lane_registry else None
        legal_terms_registry = Path(args.legal_terms_registry) if args.legal_terms_registry else None
        api_governance_registry = Path(args.api_governance_registry) if args.api_governance_registry else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-approval-chain-train-66.json")
            result = write_catalog_approval_chain_report(
                Path(args.markdown),
                json_path,
                decision_inputs_path=Path(args.decision_inputs),
                terms_proposals_path=Path(args.terms_proposals),
                draft_governance_packets_path=Path(args.draft_governance_packets),
                output_root=output_root,
                review_completion_path=review_completion,
                source_lane_registry_path=source_lane_registry,
                legal_terms_registry_path=legal_terms_registry,
                api_governance_registry_path=api_governance_registry,
                execute_registry_apply=args.execute_registry_apply,
                allow_active_registry_write=args.allow_active_registry_write,
                created_at=args.created_at,
            )
        else:
            result = run_catalog_approval_chain(
                CatalogApprovalChainOptions(
                    decision_inputs_path=Path(args.decision_inputs),
                    terms_proposals_path=Path(args.terms_proposals),
                    draft_governance_packets_path=Path(args.draft_governance_packets),
                    output_root=output_root,
                    review_completion_path=review_completion,
                    source_lane_registry_path=source_lane_registry,
                    legal_terms_registry_path=legal_terms_registry,
                    api_governance_registry_path=api_governance_registry,
                    execute_registry_apply=args.execute_registry_apply,
                    allow_active_registry_write=args.allow_active_registry_write,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-reviewer-completion-intake":
        output_root = Path(args.output_root)
        review_packets = Path(args.review_packets) if args.review_packets else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-reviewer-completion-intake-train-67.json")
            result = write_catalog_reviewer_completion_intake_report(
                Path(args.markdown),
                json_path,
                decision_inputs_path=Path(args.decision_inputs),
                output_root=output_root,
                review_packets_path=review_packets,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_reviewer_completion_intake(
                CatalogReviewerCompletionIntakeOptions(
                    decision_inputs_path=Path(args.decision_inputs),
                    output_root=output_root,
                    review_packets_path=review_packets,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-reviewer-completion-template":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-reviewer-completion-template-train-68.json")
            result = write_catalog_reviewer_completion_template_report(
                Path(args.markdown),
                json_path,
                decision_inputs_path=Path(args.decision_inputs),
                output_root=output_root,
                reviewer=args.reviewer,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_reviewer_completion_template(
                CatalogReviewerCompletionTemplateOptions(
                    decision_inputs_path=Path(args.decision_inputs),
                    output_root=output_root,
                    reviewer=args.reviewer,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-review-work-queue":
        output_root = Path(args.output_root)
        review_packets = Path(args.review_packets) if args.review_packets else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-review-work-queue-train-69.json")
            result = write_catalog_review_work_queue_report(
                Path(args.markdown),
                json_path,
                decision_inputs_path=Path(args.decision_inputs),
                output_root=output_root,
                review_packets_path=review_packets,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_review_work_queue(
                CatalogReviewWorkQueueOptions(
                    decision_inputs_path=Path(args.decision_inputs),
                    output_root=output_root,
                    review_packets_path=review_packets,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-direct-source-resolution":
        output_root = Path(args.output_root)
        candidate_review = Path(args.candidate_review) if args.candidate_review else None
        decision_inputs = Path(args.decision_inputs) if args.decision_inputs else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-direct-source-resolution-train-70.json")
            result = write_catalog_direct_source_resolution_report(
                Path(args.markdown),
                json_path,
                work_items_path=Path(args.work_items),
                output_root=output_root,
                candidate_review_path=candidate_review,
                decision_inputs_path=decision_inputs,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_direct_source_resolution(
                CatalogDirectSourceResolutionOptions(
                    work_items_path=Path(args.work_items),
                    output_root=output_root,
                    candidate_review_path=candidate_review,
                    decision_inputs_path=decision_inputs,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-direct-source-review-gate":
        output_root = Path(args.output_root)
        direct_source_reviews = Path(args.direct_source_reviews) if args.direct_source_reviews else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-direct-source-review-gate-train-71.json")
            result = write_catalog_direct_source_review_gate_report(
                Path(args.markdown),
                json_path,
                resolution_candidates_path=Path(args.resolution_candidates),
                output_root=output_root,
                direct_source_reviews_path=direct_source_reviews,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_direct_source_review_gate(
                CatalogDirectSourceReviewGateOptions(
                    resolution_candidates_path=Path(args.resolution_candidates),
                    output_root=output_root,
                    direct_source_reviews_path=direct_source_reviews,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-direct-source-review-template":
        output_root = Path(args.output_root)
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-direct-source-review-template-train-72.json")
            result = write_catalog_direct_source_review_template_report(
                Path(args.markdown),
                json_path,
                resolution_candidates_path=Path(args.resolution_candidates),
                output_root=output_root,
                reviewer=args.reviewer,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_direct_source_review_template(
                CatalogDirectSourceReviewTemplateOptions(
                    resolution_candidates_path=Path(args.resolution_candidates),
                    output_root=output_root,
                    reviewer=args.reviewer,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-direct-source-review-completion":
        output_root = Path(args.output_root)
        review_evidence = Path(args.review_evidence) if args.review_evidence else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-direct-source-review-completion-train-73.json")
            result = write_catalog_direct_source_review_completion_report(
                Path(args.markdown),
                json_path,
                templates_path=Path(args.templates),
                output_root=output_root,
                review_evidence_path=review_evidence,
                created_at=args.created_at,
            )
        else:
            result = compile_catalog_direct_source_review_completion(
                CatalogDirectSourceReviewCompletionOptions(
                    templates_path=Path(args.templates),
                    output_root=output_root,
                    review_evidence_path=review_evidence,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "catalog-direct-source-approval-chain":
        output_root = Path(args.output_root)
        review_evidence = Path(args.review_evidence) if args.review_evidence else None
        source_lane_registry = Path(args.source_lane_registry) if args.source_lane_registry else None
        legal_terms_registry = Path(args.legal_terms_registry) if args.legal_terms_registry else None
        api_governance_registry = Path(args.api_governance_registry) if args.api_governance_registry else None
        if args.markdown:
            json_path = Path(args.emit_evidence) if args.emit_evidence else Path("docs/qa/source-atlas/domain-expansion/source-atlas-catalog-direct-source-approval-chain-train-74.json")
            result = write_catalog_direct_source_approval_chain_report(
                Path(args.markdown),
                json_path,
                templates_path=Path(args.templates),
                resolution_candidates_path=Path(args.resolution_candidates),
                decision_inputs_path=Path(args.decision_inputs),
                terms_proposals_path=Path(args.terms_proposals),
                draft_governance_packets_path=Path(args.draft_governance_packets),
                output_root=output_root,
                review_evidence_path=review_evidence,
                source_lane_registry_path=source_lane_registry,
                legal_terms_registry_path=legal_terms_registry,
                api_governance_registry_path=api_governance_registry,
                execute_registry_apply=args.execute_registry_apply,
                allow_active_registry_write=args.allow_active_registry_write,
                created_at=args.created_at,
            )
        else:
            result = run_catalog_direct_source_approval_chain(
                CatalogDirectSourceApprovalChainOptions(
                    templates_path=Path(args.templates),
                    resolution_candidates_path=Path(args.resolution_candidates),
                    decision_inputs_path=Path(args.decision_inputs),
                    terms_proposals_path=Path(args.terms_proposals),
                    draft_governance_packets_path=Path(args.draft_governance_packets),
                    output_root=output_root,
                    review_evidence_path=review_evidence,
                    source_lane_registry_path=source_lane_registry,
                    legal_terms_registry_path=legal_terms_registry,
                    api_governance_registry_path=api_governance_registry,
                    execute_registry_apply=args.execute_registry_apply,
                    allow_active_registry_write=args.allow_active_registry_write,
                    created_at=args.created_at,
                )
            )
            if args.emit_evidence:
                write_json(Path(args.emit_evidence), result)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "compile":
        result = compile_bundle(
            Path(args.output_root),
            args.version_id,
            args.channel,
            harvest_root=Path(args.harvest_root) if args.harvest_root else None,
        )
        print_json(result)
        return 0
    if args.command == "validate":
        result = validate_bundle(Path(args.bundle_root))
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "workbench":
        result = build_workbench(Path(args.bundle_root), output_path=Path(args.output) if args.output else None)
        print_json(result)
        return 0 if result["valid"] and result["conflictCount"] == 0 else 1
    if args.command == "coverage-diff":
        result = coverage_diff(
            Path(args.bundle_root),
            previous_bundle_root=Path(args.previous_bundle_root) if args.previous_bundle_root else None,
            output_path=Path(args.output) if args.output else None,
        )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "benchmark":
        result = run_golden_benchmarks(Path(args.bundle_root), output_path=Path(args.output) if args.output else None)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "boundary-audit":
        results = [audit_fixture_root(Path(args.fixture_root))]
        results.extend(audit_bundle(Path(bundle_root)) for bundle_root in args.bundle_root)
        results.extend(audit_r2_plan(Path(plan_path)) for plan_path in args.r2_plan)
        result = merge_results(results)
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "r2-plan":
        bundle_root = Path(args.bundle_root)
        if args.output:
            result = write_r2_plan(bundle_root, args.bucket, args.prefix, args.channel, Path(args.output))
            result["planPath"] = args.output
        else:
            result = build_r2_plan(bundle_root, args.bucket, args.prefix, args.channel)
        print_json(result)
        return 0 if result["validForUpload"] else 1
    if args.command == "r2-contracts":
        if args.output_root:
            result = write_manifest_contracts(Path(args.output_root), args.prefix)
        else:
            result = {
                "layout": object_layout(args.prefix),
                "releaseManifestSchema": release_manifest_schema(),
                "freshnessManifestSchema": freshness_manifest_schema(),
                "revocationManifestSchema": revocation_manifest_schema(),
                "lastKnownGoodSchema": last_known_good_schema(),
            }
        print_json(result)
        return 0
    if args.command == "revocation-manifest":
        result = build_revocation_manifest(
            Path(args.bundle_root),
            revoked_artifact_ids=args.revoked_artifact_id,
            reason=args.reason,
            output_path=Path(args.output) if args.output else None,
        )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "last-known-good":
        result = build_last_known_good_manifest(
            Path(args.bundle_root),
            args.channel,
            output_path=Path(args.output) if args.output else None,
        )
        print_json(result)
        return 0 if result["valid"] else 1
    if args.command == "promotion-gate":
        result = validate_promotion_gate(
            Path(args.bundle_root),
            Path(args.r2_plan),
            revocation_path=Path(args.revocation) if args.revocation else None,
            channel=args.channel,
            output_path=Path(args.output) if args.output else None,
        )
        print_json(result)
        return 0 if result["validForPromotion"] else 1
    if args.command == "upload-r2":
        plan = read_json(Path(args.plan))
        result = execute_r2_plan(plan, execute=args.execute, confirm_public_reference_only=args.confirm_public_reference_only)
        print_json(result)
        return 0 if result.get("success") else 1
    if args.command == "r2-operations-proof":
        result = run_r2_operations_proof(
            mode=args.mode,
            environment=args.environment,
            bundle_root=Path(args.bundle_root),
            bucket=args.bucket,
            prefix=args.prefix,
            channel=args.channel,
            output_path=Path(args.output) if args.output else None,
            readback_root=Path(args.readback_root) if args.readback_root else None,
            execute=args.execute,
            confirm_public_reference_only=args.confirm_public_reference_only,
            revoked_artifact_ids=args.revoked_artifact_id,
            candidate_manifest_path=Path(args.candidate_manifest) if args.candidate_manifest else None,
            last_known_good_path=Path(args.last_known_good) if args.last_known_good else None,
            env_file_paths=[Path(path) for path in args.env_file] if args.env_file else None,
        )
        print_json(result)
        return 0 if result["status"] in {"Green", "Yellow"} else 1
    if args.command == "explain":
        print_json(explain(args.focus))
        return 0
    return 1


def explain(focus: str) -> dict[str, Any]:
    if focus == "automation":
        return {
            "focus": focus,
            "lanes": [
                "official source adapters fetch or snapshot public/reference sources",
                "normalizers emit SourceRecord, ClaimRecord, RequirementRecord, PathwayRecord, and SkillAtom data",
                "validators reject private context, unsupported claim states, missing provenance, and unsafe runtime roles",
                "compiler writes immutable versioned bundles",
                "R2 staging plan uploads candidate bundles only after validation",
                "promotion should be handled by a Cloudflare Worker gate before stable channel exposure",
            ],
        }
    if focus == "certification":
        return {
            "focus": focus,
            "registry": "Every source must declare authority tier, license posture, source type, cadence, jurisdiction, fixture expectations, drift checks, unavailable-source behavior, and privacy expectations.",
            "adapters": "Every adapter must declare source types, fixture expectations, drift checks, unavailable-source behavior, credential posture, and public/reference privacy expectations.",
            "promotion": "Certification is a validation gate; unsupported sources, missing provenance, blocked authenticated sources, and metadata-only discovery used as claim truth block promotion.",
            "nonClaims": NON_CLAIMS,
        }
    if focus == "runtime-boundary":
        return {
            "focus": focus,
            "law": "Source Atlas knows public/reference structure; Private Life Runtime knows the user; the join happens locally.",
            "forbidden": [
                "private user context in source requests",
                "private life graph in R2",
                "R2 as personal-data backend",
                "packs as user-visible marketplace center",
            ],
        }
    return {
        "focus": focus,
        "layers": [
            "source registry",
            "adapter snapshots",
            "claim graph",
            "requirement graph",
            "pathway lattice",
            "skill transfer graph",
            "freshness broker",
            "bundle compiler",
            "R2 staging plan",
            "promotion receipt",
            "local runtime verifier/cache",
        ],
    }


if __name__ == "__main__":
    raise SystemExit(main())
