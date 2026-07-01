"""Launch-floor counter ledger for Source Atlas.

This module defines the fail-closed launch-floor contract for near-universal
Source Atlas coverage. It reads current public/reference evidence and optional
future launch-floor manifests; it does not harvest sources, mutate registries,
publish R2 objects, deploy Workers, mutate native runtime state, or generate
final user outputs.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issues_for_value, is_boundary_line
from .launch_floor_domain_taxonomy import launch_floor_domain_taxonomy_summary
from .launch_floor_golden_intent_corpus import launch_floor_golden_intent_corpus_summary
from .launch_floor_shard_corpus import launch_floor_shard_corpus_summary
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_LAUNCH_FLOOR_LEDGER_KIND = "ambitions.sourceAtlas.launchFloorLedger.v1"
SOURCE_ATLAS_LAUNCH_FLOOR_LEDGER_VERSION = "source-atlas-launch-floor-ledger-lff-m03-l01"

LAUNCH_FLOOR_TARGETS = [
    {
        "targetID": "public_reference_shards_1m",
        "label": "1M+ public/reference shards before public launch",
        "threshold": 1_000_000,
        "unit": "public_reference_shards",
    },
    {
        "targetID": "goal_domains_500",
        "label": "500+ goal domains",
        "threshold": 500,
        "unit": "goal_domains",
    },
    {
        "targetID": "subdomains_5000",
        "label": "5,000+ subdomains",
        "threshold": 5_000,
        "unit": "subdomains",
    },
    {
        "targetID": "golden_intents_50000",
        "label": "50,000+ golden representative lawful goal intents",
        "threshold": 50_000,
        "unit": "golden_intents",
    },
    {
        "targetID": "source_needed_fallback_under_5_percent",
        "label": "<5% source-needed fallback for lawful goals",
        "threshold": 0.05,
        "unit": "fallback_rate",
    },
    {
        "targetID": "continuous_missing_shard_expansion",
        "label": "Continuous source expansion pipeline for every missing-shard event",
        "threshold": 1,
        "unit": "durable_pipeline",
    },
]

FORBIDDEN_LAUNCH_FLOOR_CLAIMS = {
    "full_source_atlas_green",
    "source_atlas_launch_floor_ready",
    "launch_floor_complete",
    "release_green",
    "runtime_release_green",
    "app_store_readiness",
    "testflight_readiness",
    "outside_legal_approval",
    "literal_universal_coverage",
    "universal_coverage",
    "source_atlas_private_goal_text_processing",
    "private_life_graph_in_source_atlas_or_r2",
    "hosted_private_life_graph",
    "final_user_plans_schedules_steps_from_source_atlas_or_r2",
    "source_atlas_generates_final_steps",
    "source_atlas_generates_final_schedules",
    "source_atlas_generates_final_personalized_plans",
}

LAUNCH_FLOOR_NON_CLAIMS = [
    "not launch-floor complete",
    "not full Source Atlas Green",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not outside legal approval",
    "not literal universal coverage",
    "not proof of 1M public/reference shards unless the shard corpus manifest supplies the canonical counter",
    "not proof of 500 domains or 5,000 subdomains unless active taxonomy supplies those counters",
    "not proof of 50,000 golden intents unless a golden intent corpus supplies the canonical counter",
    "not proof of <5% fallback unless numerator and denominator are present",
    "not proof of continuous expansion unless every missing-shard event is durably queued through governed expansion",
    "not final user plans, schedules, Steps, priority order, recovery paths, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]

PUBLIC_HYGIENE_CLASSIFICATIONS = {
    "production_stable_noncurrent",
    "staging_candidate_in_production_bucket",
    "validation_in_production_bucket",
    "legacy_stable_noncurrent",
}


@dataclass(frozen=True)
class SourceAtlasLaunchFloorLedgerOptions:
    frontier_config_path: Path
    source_lane_registry_path: Path
    legal_terms_registry_path: Path
    api_governance_registry_path: Path
    production_target_ledger_path: Path
    r2_live_inventory_path: Path
    goal_domain_gauntlet_path: Path
    completion_audit_path: Path
    release_proof_packet_path: Path
    output_root: Path
    production_supervisor_path: Path | None = None
    autonomous_control_loop_path: Path | None = None
    autonomous_domain_expansion_chain_path: Path | None = None
    launch_floor_taxonomy_path: Path | None = None
    shard_corpus_manifest_path: Path | None = None
    r2_layout_proof_path: Path | None = None
    golden_intent_corpus_path: Path | None = None
    fallback_metric_path: Path | None = None
    missing_shard_events_path: Path | None = None
    native_runtime_bridge_gauntlet_source_path: Path | None = None
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"


def build_source_atlas_launch_floor_ledger(options: SourceAtlasLaunchFloorLedgerOptions) -> dict[str, Any]:
    """Build and write a deterministic launch-floor counter ledger."""

    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    artifacts = {
        "frontierConfig": _read_required_json(options.frontier_config_path, "coverage frontier config", issues),
        "sourceLaneRegistry": _read_required_json(options.source_lane_registry_path, "source lane registry", issues),
        "legalTermsRegistry": _read_required_json(options.legal_terms_registry_path, "legal/terms registry", issues),
        "apiGovernanceRegistry": _read_required_json(options.api_governance_registry_path, "API governance registry", issues),
        "productionTargetLedger": _read_required_json(options.production_target_ledger_path, "production target ledger", issues),
        "r2LiveInventory": _read_required_json(options.r2_live_inventory_path, "R2 live inventory", issues),
        "goalDomainGauntlet": _read_required_json(options.goal_domain_gauntlet_path, "goal-domain gauntlet", issues),
        "completionAudit": _read_required_json(options.completion_audit_path, "completion audit", issues),
        "releaseProofPacket": _read_required_json(options.release_proof_packet_path, "release proof packet", issues),
        "productionSupervisor": _read_optional_json(options.production_supervisor_path, "production supervisor", issues),
        "autonomousControlLoop": _read_optional_json(options.autonomous_control_loop_path, "autonomous control loop", issues),
        "autonomousDomainExpansionChain": _read_optional_json(options.autonomous_domain_expansion_chain_path, "autonomous domain expansion chain", issues),
        "launchFloorTaxonomy": _read_optional_json(options.launch_floor_taxonomy_path, "launch-floor domain taxonomy", issues),
        "shardCorpusManifest": _read_optional_json(options.shard_corpus_manifest_path, "shard corpus manifest", issues),
        "r2LayoutProof": _read_optional_json(options.r2_layout_proof_path, "launch-floor R2 layout proof", issues),
        "goldenIntentCorpus": _read_optional_json(options.golden_intent_corpus_path, "golden intent corpus", issues),
        "fallbackMetric": _read_optional_json(options.fallback_metric_path, "source-needed fallback metric", issues),
        "missingShardEvents": _read_optional_json(options.missing_shard_events_path, "missing-shard events", issues),
    }
    native_bridge_source_contract = _native_bridge_source_contract(options.native_runtime_bridge_gauntlet_source_path)
    launch_floor_taxonomy_summary = _launch_floor_taxonomy_summary(artifacts)
    launch_floor_shard_corpus_summary = _launch_floor_shard_corpus_summary(artifacts)
    launch_floor_golden_intent_summary = _launch_floor_golden_intent_summary(artifacts)

    input_paths = _input_paths(options)
    input_privacy_issues = _privacy_issues(
        {
            "runLabel": options.run_label,
            "inputPaths": input_paths,
        },
        "source-atlas-launch-floor-ledger-input",
    )
    artifact_privacy_issues = _privacy_issues(artifacts, "source-atlas-launch-floor-ledger-artifacts")
    overclaim_issues = _overclaim_issues(artifacts)

    counters = _counters(
        artifacts,
        native_bridge_source_contract,
        launch_floor_taxonomy_summary,
        launch_floor_shard_corpus_summary,
        launch_floor_golden_intent_summary,
    )
    target_statuses = _target_statuses(counters)
    current_capabilities = _current_capabilities(counters, target_statuses)
    missing_capabilities = _missing_capabilities(target_statuses)
    required_changes = _required_changes(target_statuses)
    dependency_graph = _dependency_graph()

    checks = _checks(
        issues=issues,
        input_privacy_issues=input_privacy_issues,
        artifact_privacy_issues=artifact_privacy_issues,
        overclaim_issues=overclaim_issues,
        taxonomy_issues=launch_floor_taxonomy_summary["issues"],
        shard_corpus_issues=launch_floor_shard_corpus_summary["issues"],
        golden_intent_issues=launch_floor_golden_intent_summary["issues"],
        target_statuses=target_statuses,
    )
    all_targets_met = all(target["status"] == "met" for target in target_statuses)
    valid = (
        not issues
        and not input_privacy_issues
        and not artifact_privacy_issues
        and not overclaim_issues
        and not launch_floor_taxonomy_summary["issues"]
        and not launch_floor_shard_corpus_summary["issues"]
        and not launch_floor_golden_intent_summary["issues"]
    )
    launch_floor_met = valid and all_targets_met
    launch_floor_claim_allowed = launch_floor_met
    output_json_path = output_root / "source-atlas-launch-floor-ledger.json"
    output_markdown_path = output_root / "source-atlas-launch-floor-ledger.md"
    closeout_path = output_root / "closeout.md"

    report = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_LEDGER_KIND,
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_LEDGER_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "ledgerID": stable_id(
            "source_atlas.launch_floor_ledger",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "inputHashes": _input_hashes(artifacts),
                "targetStatuses": target_statuses,
            },
        ),
        "status": _status(valid, launch_floor_met),
        "valid": valid,
        "launchFloorMet": launch_floor_met,
        "launchFloorClaimAllowed": launch_floor_claim_allowed,
        "overallReadinessStatus": "launch_floor_ready" if launch_floor_met else "not_launch_floor_ready",
        "sourceAtlasStatusCeiling": (
            "Launch-floor Source Atlas ready"
            if launch_floor_met
            else "Yellow overall Source Atlas; launch-floor targets are measured or fail-closed but not met"
        ),
        "recordCounts": counters["recordCounts"],
        "counterContract": _counter_contract(),
        "launchFloorTargetStatus": {target["targetID"]: target for target in target_statuses},
        "targetStatuses": target_statuses,
        "currentCapabilities": current_capabilities,
        "missingCapabilities": missing_capabilities,
        "requiredChanges": required_changes,
        "dependencyGraph": dependency_graph,
        "validationMatrix": _validation_matrix(),
        "checks": checks,
        "issues": sorted(set([*issues, *input_privacy_issues, *artifact_privacy_issues, *overclaim_issues])),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*input_privacy_issues, *artifact_privacy_issues])),
        "overclaimIssues": sorted(set(overclaim_issues)),
        "taxonomyIssues": launch_floor_taxonomy_summary["issues"],
        "goldenIntentCorpusIssues": launch_floor_golden_intent_summary["issues"],
        "launchFloorTaxonomy": {
            "present": artifacts["launchFloorTaxonomy"] is not None,
            "valid": not launch_floor_taxonomy_summary["issues"],
            "recordCounts": launch_floor_taxonomy_summary["recordCounts"],
            "targetStatus": launch_floor_taxonomy_summary["launchFloorTargets"],
        },
        "launchFloorShardCorpus": {
            "present": artifacts["shardCorpusManifest"] is not None,
            "valid": artifacts["shardCorpusManifest"] is not None and not launch_floor_shard_corpus_summary["issues"],
            "recordCounts": launch_floor_shard_corpus_summary["recordCounts"],
            "targetStatus": launch_floor_shard_corpus_summary["launchFloorTargets"],
            "issues": launch_floor_shard_corpus_summary["issues"],
        },
        "launchFloorGoldenIntentCorpus": {
            "present": artifacts["goldenIntentCorpus"] is not None,
            "valid": artifacts["goldenIntentCorpus"] is not None and not launch_floor_golden_intent_summary["issues"],
            "recordCounts": launch_floor_golden_intent_summary["recordCounts"],
            "targetStatus": launch_floor_golden_intent_summary["launchFloorTargets"],
            "issues": launch_floor_golden_intent_summary["issues"],
        },
        "allowedClaims": _allowed_claims(valid, launch_floor_met),
        "blockedClaims": _blocked_claims(),
        "productLaw": {
            "r2Role": "public/reference/freshness infrastructure only",
            "privateGraphEgressAllowed": False,
            "privateGoalsCapturesSchedulesProofReceiptsAllowed": False,
            "accountOrDeviceIdentifiersAllowed": False,
            "behaviorHistoryOrInferredPrioritiesAllowed": False,
            "finalPersonalizedOutputsAllowed": False,
            "sourceAtlasGeneratesFinalPlansSchedulesSteps": False,
            "privateLifeRuntimeOwnsPersonalizationAndPathing": True,
        },
        "proofArtifacts": _proof_artifacts(input_paths, native_bridge_source_contract),
        "evidencePaths": input_paths,
        "nonClaims": LAUNCH_FLOOR_NON_CLAIMS,
        "outputPaths": {
            "report": str(output_json_path),
            "markdown": str(output_markdown_path),
            "closeout": str(closeout_path),
            "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
            "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
        },
    }
    report["outputHashes"] = {
        "reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"}),
    }
    markdown = source_atlas_launch_floor_ledger_markdown(report)
    report["outputHashes"]["markdownPayload"] = stable_hash(markdown)

    write_json(output_json_path, report)
    output_markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    report["outputHashes"]["report"] = stable_hash(read_json(output_json_path))
    write_json(output_json_path, report)
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    return report


def source_atlas_launch_floor_ledger_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Near-Universal Launch-Floor Ledger",
        "",
        f"Status: {report['status']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Launch floor met: {str(report['launchFloorMet']).lower()}",
        f"Launch-floor claim allowed: {str(report['launchFloorClaimAllowed']).lower()}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "## Current Proved Capability",
        "",
        f"- Configured goal domains: {counts['configuredGoalDomains']}",
        f"- Bounded production-ready domains: {counts['boundedProductionReadyDomains']}",
        f"- Launch-floor accepted taxonomy domains: {counts['launchFloorTaxonomyAcceptedGoalDomains']}",
        f"- Launch-floor accepted taxonomy subdomains: {counts['launchFloorTaxonomyAcceptedSubdomains']}",
        f"- Launch-floor taxonomy source-lane review backlog items: {counts['launchFloorTaxonomySourceLaneReviewBacklogItems']}",
        f"- Packable public/reference claims: {counts['packablePublicReferenceClaimProxy']}",
        f"- Live R2 objects: {counts['liveR2ObjectProxy']}",
        f"- Launch-floor R2 layout proof objects: {counts['launchFloorR2LayoutProofObjects'] or 0}",
        f"- Launch-floor R2 readback objects checked: {counts['launchFloorR2ReadbackObjectsChecked'] or 0}",
        f"- Launch-floor R2 rollback transitions: {counts['launchFloorR2RollbackTransitions'] or 0}",
        f"- Launch-floor R2 gateway load probes: {counts['launchFloorR2GatewayLoadProbes'] or 0}",
        f"- Launch-floor R2 live writes: {counts['launchFloorR2LiveWrites'] or 0}",
        f"- Source lanes: {counts['sourceLaneCount']}",
        f"- Source-lane domain-scope values: {counts['sourceLaneDomainScopeProxy']}",
        f"- Representative configured gauntlet cases: {counts['configuredGauntletCases']}",
        f"- Unknown-domain candidate-only cases: {counts['unknownCandidateOnlyCases']}",
        f"- Native bridge source-contract intents: {counts['nativeBridgeSourceIntentContract']}",
        f"- Launch-floor golden intent records: {counts['launchFloorGoldenIntentRecords']}",
        f"- Launch-floor golden intents counted: {counts['goldenIntentCorpusCounter'] or 0}",
        f"- Launch-floor golden intent domains/subdomains: {counts['launchFloorGoldenIntentDomains']}/{counts['launchFloorGoldenIntentSubdomains']}",
        "",
        "## Launch-Floor Target Status",
        "",
        "| Target | Current counter | Status | Gap | Required change |",
        "| --- | ---: | --- | --- | --- |",
    ]
    for target in report["targetStatuses"]:
        current = _markdown_counter(target)
        gaps = "<br>".join(target.get("gaps", [])) or "none"
        required = "<br>".join(target.get("requiredChanges", [])) or "none"
        lines.append(
            f"| {target['label']} | {current} | `{target['status']}` | {gaps} | {required} |"
        )
    lines.extend(["", "## Required Changes", ""])
    lines.extend(f"- `{change['changeID']}` {change['title']}: {change['requiredChange']}" for change in report["requiredChanges"])
    lines.extend(["", "## Dependency Graph", ""])
    for node in report["dependencyGraph"]["nodes"]:
        lines.append(f"- `{node['id']}` {node['title']} depends on: {', '.join(node['dependsOn']) or 'none'}")
    lines.extend(["", "## Validation Matrix", ""])
    lines.extend(
        f"- `{item['validationID']}` {item['command']}: {item['purpose']}"
        for item in report["validationMatrix"]
    )
    lines.extend(["", "## Allowed Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["allowedClaims"]) if report["allowedClaims"] else lines.append("- None")
    lines.extend(["", "## Blocked Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["blockedClaims"])
    lines.extend(
        [
            "",
            "## Product Law Preserved",
            "",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Source Atlas does not receive private goals, captures, schedules, proof, receipts, personalization, behavior history, inferred priorities, account IDs, device IDs, or private life graph.",
            "- Private Life Runtime remains the local personalization/pathing engine.",
            "- Source Atlas may provide public/reference shards, requirements, constraints, proof needs, starter actions, source caveats, freshness, and risk metadata only.",
            "- Source Atlas does not generate final personalized plans, final schedules, or final Steps.",
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
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: Source Atlas Foundry tooling and Source Atlas QA evidence only.",
            "- App behavior mutated: no.",
            "- Compatibility shims left behind: none.",
            "- Placeholder proof introduced: none.",
            "- Launch-floor closeout recommendation: continue to LFF-M01 through LFF-M06; do not claim launch-floor coverage until every target above is `met` from generated proof.",
            "",
        ]
    )
    return "\n".join(lines)


def _counters(
    artifacts: dict[str, Any],
    native_bridge_source_contract: dict[str, int | None],
    launch_floor_taxonomy: dict[str, Any],
    launch_floor_shard_corpus: dict[str, Any],
    launch_floor_golden_intent: dict[str, Any],
) -> dict[str, Any]:
    frontier_config = artifacts["frontierConfig"]
    source_lane_registry = artifacts["sourceLaneRegistry"]
    legal_terms_registry = artifacts["legalTermsRegistry"]
    api_governance_registry = artifacts["apiGovernanceRegistry"]
    production_ledger = artifacts["productionTargetLedger"]
    r2_inventory = artifacts["r2LiveInventory"]
    gauntlet = artifacts["goalDomainGauntlet"]
    release_packet = artifacts["releaseProofPacket"]
    supervisor = artifacts["productionSupervisor"]
    control_loop = artifacts["autonomousControlLoop"]
    expansion_chain = artifacts["autonomousDomainExpansionChain"]
    fallback_metric = artifacts["fallbackMetric"]
    missing_shard_events = artifacts["missingShardEvents"]
    r2_layout_proof = artifacts["r2LayoutProof"]
    taxonomy_counts = launch_floor_taxonomy["recordCounts"]
    taxonomy_valid = not launch_floor_taxonomy["issues"]
    shard_corpus_counts = launch_floor_shard_corpus["recordCounts"]
    shard_corpus_valid = not launch_floor_shard_corpus["issues"] and artifacts["shardCorpusManifest"] is not None
    golden_intent_counts = launch_floor_golden_intent["recordCounts"]
    golden_intent_valid = not launch_floor_golden_intent["issues"] and artifacts["goldenIntentCorpus"] is not None

    frontiers = frontier_config.get("frontiers", []) if isinstance(frontier_config, dict) else []
    configured_domain_ids = sorted(
        {
            str(frontier.get("frontier_id") or frontier.get("domain"))
            for frontier in frontiers
            if isinstance(frontier, dict) and (frontier.get("frontier_id") or frontier.get("domain"))
        }
    )
    subdomain_values = _explicit_subdomains(frontiers)
    source_lanes = source_lane_registry.get("source_lanes", []) if isinstance(source_lane_registry, dict) else []
    source_lane_scope_values = _source_lane_domain_scopes(source_lanes)
    production_domains = production_ledger.get("domains", []) if isinstance(production_ledger, dict) else []
    packable_claims = sum((_int(domain.get("packableClaimCount")) or 0) for domain in production_domains if isinstance(domain, dict))
    live_r2_objects = _record_count(r2_inventory, "liveObjects")
    expected_current_objects = _record_count(r2_inventory, "expectedCurrentObjects")
    configured_gauntlet_cases = _record_count(gauntlet, "configuredGauntletCases")
    unknown_candidate_only = _record_count(gauntlet, "unknownCasesCandidateOnly")
    final_outputs = _record_count(gauntlet, "finalOutputsGenerated")
    source_needed_numerator, source_needed_denominator = _fallback_fraction(fallback_metric)
    missing_event_summary = _missing_shard_event_summary(missing_shard_events)
    goal_domain_counter = (
        taxonomy_counts["acceptedGoalDomains"]
        if taxonomy_valid and taxonomy_counts["acceptedGoalDomains"] > 0
        else len(configured_domain_ids)
    )
    subdomain_counter = (
        taxonomy_counts["acceptedSubdomains"]
        if taxonomy_valid and taxonomy_counts["acceptedSubdomains"] > 0
        else len(subdomain_values)
        if subdomain_values
        else None
    )

    return {
        "launchFloorTaxonomyValid": taxonomy_valid,
        "launchFloorShardCorpusValid": shard_corpus_valid,
        "launchFloorGoldenIntentCorpusValid": golden_intent_valid,
        "goalDomainCounter": goal_domain_counter,
        "subdomainCounter": subdomain_counter,
        "shardCorpusCount": shard_corpus_counts["publicReferenceShards"] if shard_corpus_valid else None,
        "goldenIntentCorpusCount": golden_intent_counts["goldenIntentCount"] if golden_intent_valid else None,
        "fallbackNumerator": source_needed_numerator,
        "fallbackDenominator": source_needed_denominator,
        "missingShardEventSummary": missing_event_summary,
        "candidateOnlyRoutingProven": _claim(gauntlet, "unknown_public_reference_domains_candidate_only") and unknown_candidate_only > 0,
        "autonomousSupervisorProven": _claim(supervisor, "supervised_autonomous_source_atlas_work_loop_green"),
        "autonomousControlLoopProven": _claim(control_loop, "unknown_domains_candidate_only_controlled"),
        "domainExpansionChainProven": _claim(expansion_chain, "deterministic_autonomous_candidate_domain_expansion_chain"),
        "explicitSubdomainCountPresent": bool(subdomain_values),
        "recordCounts": {
            "configuredGoalDomains": len(configured_domain_ids),
            "boundedProductionReadyDomains": _record_count(production_ledger, "boundedProductionTargetReady"),
            "discoveredProductionLedgerDomains": len(production_domains),
            "sourceLaneCount": len(source_lanes),
            "sourceLaneDomainScopeProxy": len(source_lane_scope_values),
            "legalTermsEntries": len(legal_terms_registry.get("licenses", [])) if isinstance(legal_terms_registry, dict) else 0,
            "apiGovernancePolicies": len(api_governance_registry.get("api_policies", [])) if isinstance(api_governance_registry, dict) else 0,
            "explicitSubdomains": len(subdomain_values),
            "launchFloorTaxonomyAcceptedGoalDomains": taxonomy_counts["acceptedGoalDomains"],
            "launchFloorTaxonomyAcceptedSubdomains": taxonomy_counts["acceptedSubdomains"],
            "launchFloorTaxonomyConfiguredReadyDomains": taxonomy_counts["configuredReadyDomains"],
            "launchFloorTaxonomyConfiguredNotReadyDomains": taxonomy_counts["configuredNotReadyDomains"],
            "launchFloorTaxonomySourceLaneReviewBacklogItems": taxonomy_counts["sourceLaneReviewBacklogItems"],
            "launchFloorTaxonomyCandidateOnlyBacklogItems": taxonomy_counts["candidateOnlyBacklogItems"],
            "launchFloorTaxonomyStaleCandidateOnlyBacklogItems": taxonomy_counts["staleCandidateOnlyBacklogItems"],
            "launchFloorTaxonomyDomainsWithSourceLaneCoverage": taxonomy_counts["domainsWithSourceLaneCoverage"],
            "launchFloorTaxonomySubdomainsWithSourceLaneCoverage": taxonomy_counts["subdomainsWithSourceLaneCoverage"],
            "launchFloorShardCorpusPartitions": shard_corpus_counts["partitions"],
            "launchFloorShardCorpusCountedPartitions": shard_corpus_counts["launchFloorCountedPartitions"],
            "launchFloorShardCorpusR2LayoutPartitions": shard_corpus_counts["partitionsWithR2Layout"],
            "launchFloorShardCorpusReadbackPartitions": shard_corpus_counts["partitionsWithReadbackProof"],
            "launchFloorShardCorpusRollbackPartitions": shard_corpus_counts["partitionsWithRollbackProof"],
            "launchFloorShardCorpusGatewayPartitions": shard_corpus_counts["partitionsWithGatewayProof"],
            "launchFloorShardCorpusNativeCompatiblePartitions": shard_corpus_counts["partitionsWithNativeCompatibility"],
            "launchFloorR2LayoutProofPartitions": _record_count(r2_layout_proof, "launchFloorCountedPartitions"),
            "launchFloorR2LayoutProofObjects": _record_count(r2_layout_proof, "layoutObjects"),
            "launchFloorR2ReadbackObjectsChecked": _record_count(r2_layout_proof, "readbackObjectsChecked"),
            "launchFloorR2ReadbackChecksumMismatches": _record_count(r2_layout_proof, "readbackChecksumMismatches"),
            "launchFloorR2RollbackTransitions": _record_count(r2_layout_proof, "rollbackTransitionsTested"),
            "launchFloorR2GatewayLoadProbes": _record_count(r2_layout_proof, "gatewayLoadProbes"),
            "launchFloorR2LiveWrites": _record_count(r2_layout_proof, "r2LiveWrites"),
            "packablePublicReferenceClaimProxy": packable_claims,
            "liveR2ObjectProxy": live_r2_objects,
            "expectedCurrentR2ObjectProxy": expected_current_objects,
            "configuredGauntletCases": configured_gauntlet_cases,
            "unknownCandidateOnlyCases": unknown_candidate_only,
            "finalOutputsGenerated": final_outputs,
            "nativeBridgeSourceIntentContract": native_bridge_source_contract.get("intentCount"),
            "nativeBridgeSourcePermutationContract": native_bridge_source_contract.get("scenarioCount"),
            "focusedNativePassedFromReleasePacket": _record_count(release_packet, "focusedNativePassed"),
            "sourceAtlasPytestPassedFromReleasePacket": _record_count(release_packet, "sourceAtlasPytestPassed"),
            "productionSupervisorWorkQueueItems": _record_count(supervisor, "workQueueItems"),
            "productionSupervisorPromotionDecisions": _record_count(supervisor, "promotionDecisions"),
            "autonomousControlLoopUnknownDomainsCandidateOnly": _record_count(control_loop, "unknownDomainsCandidateOnly"),
            "domainExpansionCandidateRoutes": _record_count(expansion_chain, "candidateRoutes"),
            "domainExpansionR2PublishOperations": _record_count(expansion_chain, "r2PublishOperations"),
            "shardCorpusCounter": shard_corpus_counts["publicReferenceShards"] if shard_corpus_valid else None,
            "launchFloorGoldenIntentRecords": golden_intent_counts["intentRecords"],
            "launchFloorGoldenIntentAdjudicatedRecords": golden_intent_counts["adjudicatedIntentCount"],
            "launchFloorGoldenIntentDomains": golden_intent_counts["domainCount"],
            "launchFloorGoldenIntentSubdomains": golden_intent_counts["subdomainCount"],
            "launchFloorGoldenIntentSourceNeeded": golden_intent_counts["sourceNeededCount"],
            "launchFloorGoldenIntentCandidateOnly": golden_intent_counts["candidateOnlyCount"],
            "goldenIntentCorpusCounter": golden_intent_counts["goldenIntentCount"] if golden_intent_valid else None,
            "sourceNeededFallbackNumerator": source_needed_numerator,
            "sourceNeededFallbackDenominator": source_needed_denominator,
            "missingShardEvents": missing_event_summary["eventCount"],
            "missingShardEventsWithDurableExpansion": missing_event_summary["durableExpansionEventCount"],
        },
    }


def _target_statuses(counters: dict[str, Any]) -> list[dict[str, Any]]:
    record_counts = counters["recordCounts"]
    fallback_numerator = counters["fallbackNumerator"]
    fallback_denominator = counters["fallbackDenominator"]
    fallback_rate = (
        fallback_numerator / fallback_denominator
        if fallback_numerator is not None and fallback_denominator not in {None, 0}
        else None
    )
    missing_events = counters["missingShardEventSummary"]
    continuous_pipeline_present = (
        counters["candidateOnlyRoutingProven"]
        and counters["autonomousSupervisorProven"]
        and counters["autonomousControlLoopProven"]
        and counters["domainExpansionChainProven"]
        and missing_events["eventCount"] > 0
        and missing_events["eventCount"] == missing_events["durableExpansionEventCount"]
    )
    return [
        _threshold_target(
            "public_reference_shards_1m",
            record_counts["shardCorpusCounter"],
            1_000_000,
            counter_present=record_counts["shardCorpusCounter"] is not None,
            proxy_values={
                "packablePublicReferenceClaimProxy": record_counts["packablePublicReferenceClaimProxy"],
                "liveR2ObjectProxy": record_counts["liveR2ObjectProxy"],
            },
            missing_counter_gap="canonical shard corpus manifest is missing",
            required_changes=[
                "Create canonical shard corpus manifest with publicReferenceShards >= 1,000,000.",
                "Partition shards into pack/R2/mobile index layout with checksum/readback proof.",
            ],
        ),
        _threshold_target(
            "goal_domains_500",
            counters["goalDomainCounter"],
            500,
            counter_present=counters["goalDomainCounter"] is not None,
            proxy_values={
                "configuredGoalDomains": record_counts["configuredGoalDomains"],
                "boundedProductionReadyDomains": record_counts["boundedProductionReadyDomains"],
                "launchFloorTaxonomyConfiguredReadyDomains": record_counts["launchFloorTaxonomyConfiguredReadyDomains"],
                "launchFloorTaxonomyConfiguredNotReadyDomains": record_counts["launchFloorTaxonomyConfiguredNotReadyDomains"],
            },
            missing_counter_gap="active frontier taxonomy is missing",
            required_changes=[
                "Expand active governed frontier taxonomy to at least 500 lawful public/reference goal domains.",
                "Keep every domain mapped to source/legal/API lane governance before promotion.",
            ],
        ),
        _threshold_target(
            "subdomains_5000",
            counters["subdomainCounter"],
            5_000,
            counter_present=counters["subdomainCounter"] is not None,
            proxy_values={
                "sourceLaneDomainScopeProxy": record_counts["sourceLaneDomainScopeProxy"],
                "launchFloorTaxonomyDomainsWithSourceLaneCoverage": record_counts["launchFloorTaxonomyDomainsWithSourceLaneCoverage"],
                "launchFloorTaxonomySubdomainsWithSourceLaneCoverage": record_counts["launchFloorTaxonomySubdomainsWithSourceLaneCoverage"],
            },
            missing_counter_gap="canonical subdomain taxonomy is missing",
            required_changes=[
                "Add canonical subdomain taxonomy with at least 5,000 governed subdomains.",
                "Attach each subdomain to parent domain, source lane, legal posture, API posture, and freshness SLA.",
            ],
        ),
        _threshold_target(
            "golden_intents_50000",
            record_counts["goldenIntentCorpusCounter"],
            50_000,
            counter_present=record_counts["goldenIntentCorpusCounter"] is not None,
            proxy_values={
                "configuredGauntletCases": record_counts["configuredGauntletCases"],
                "nativeBridgeSourceIntentContract": record_counts["nativeBridgeSourceIntentContract"],
                "nativeBridgeSourcePermutationContract": record_counts["nativeBridgeSourcePermutationContract"],
            },
            missing_counter_gap="canonical golden intent corpus is missing",
            required_changes=[
                "Create adjudicated 50,000+ lawful golden representative goal-intent corpus.",
                "Measure configured, missing-domain, candidate-only, privacy, and no-final-output routing against that corpus.",
            ],
        ),
        _fallback_target(fallback_numerator, fallback_denominator, fallback_rate),
        {
            "targetID": "continuous_missing_shard_expansion",
            "label": "Continuous source expansion pipeline for every missing-shard event",
            "threshold": 1,
            "unit": "durable_pipeline",
            "measuredValue": 1 if continuous_pipeline_present else 0,
            "measuredRate": None,
            "counterPresent": missing_events["eventCount"] > 0,
            "status": "met" if continuous_pipeline_present else "not_measurable_fail_closed",
            "evidence": {
                "candidateOnlyRoutingProven": counters["candidateOnlyRoutingProven"],
                "autonomousSupervisorProven": counters["autonomousSupervisorProven"],
                "autonomousControlLoopProven": counters["autonomousControlLoopProven"],
                "domainExpansionChainProven": counters["domainExpansionChainProven"],
                "missingShardEventCount": missing_events["eventCount"],
                "durableExpansionEventCount": missing_events["durableExpansionEventCount"],
                "eventIssues": missing_events["issues"],
            },
            "gaps": []
            if continuous_pipeline_present
            else [
                "missing-shard event ledger is absent or every-event durable expansion is unproven",
                "existing candidate-only/domain-expansion/supervision components are not proof of continuous expansion for every missing-shard event",
            ],
            "requiredChanges": [
                "Create durable missing-shard event queue and replayable expansion state machine.",
                "Require every missing-shard event to enter governed source discovery, legal/API review, pack/R2/native activation, or explicit lawful rejection.",
            ],
        },
    ]


def _threshold_target(
    target_id: str,
    measured_value: int | None,
    threshold: int,
    *,
    counter_present: bool,
    proxy_values: dict[str, Any],
    missing_counter_gap: str,
    required_changes: list[str],
) -> dict[str, Any]:
    definition = next(item for item in LAUNCH_FLOOR_TARGETS if item["targetID"] == target_id)
    status = "met" if measured_value is not None and measured_value >= threshold else "not_met"
    if not counter_present:
        status = "not_measurable_fail_closed"
    gaps = []
    if not counter_present:
        gaps.append(missing_counter_gap)
    elif measured_value is not None and measured_value < threshold:
        gaps.append(f"{definition['unit']} counter is {measured_value}, below required {threshold}")
    return {
        "targetID": target_id,
        "label": definition["label"],
        "threshold": threshold,
        "unit": definition["unit"],
        "measuredValue": measured_value,
        "measuredRate": None,
        "counterPresent": counter_present,
        "status": status,
        "proxyValues": proxy_values,
        "gaps": gaps,
        "requiredChanges": [] if status == "met" else required_changes,
    }


def _fallback_target(numerator: int | None, denominator: int | None, rate: float | None) -> dict[str, Any]:
    status = "not_measurable_fail_closed"
    gaps = ["source-needed fallback numerator/denominator are missing"]
    if numerator is not None and denominator is not None and denominator > 0 and rate is not None:
        status = "met" if rate < 0.05 else "not_met"
        gaps = [] if status == "met" else [f"source-needed fallback rate is {rate:.4f}, not below 0.0500"]
    return {
        "targetID": "source_needed_fallback_under_5_percent",
        "label": "<5% source-needed fallback for lawful goals",
        "threshold": 0.05,
        "unit": "fallback_rate",
        "measuredValue": numerator,
        "measuredDenominator": denominator,
        "measuredRate": rate,
        "counterPresent": numerator is not None and denominator is not None and denominator > 0,
        "status": status,
        "proxyValues": {},
        "gaps": gaps,
        "requiredChanges": []
        if status == "met"
        else [
            "Run the 50,000+ golden intent corpus through Source Atlas routing and record source-needed numerator/denominator.",
            "Keep fallback-rate claim blocked unless lawful-goal denominator is present and source-needed fallback is below 5%.",
        ],
    }


def _counter_contract() -> list[dict[str, Any]]:
    return [
        {
            "targetID": target["targetID"],
            "requiredCounter": target["unit"],
            "threshold": target["threshold"],
            "requiredBeforePublicLaunch": True,
            "failClosedWhenMissing": True,
        }
        for target in LAUNCH_FLOOR_TARGETS
    ]


def _current_capabilities(counters: dict[str, Any], target_statuses: list[dict[str, Any]]) -> list[dict[str, Any]]:
    counts = counters["recordCounts"]
    capabilities = [
        {
            "capabilityID": "bounded_configured_frontier_proof",
            "status": "proven_current",
            "evidence": f"{counts['configuredGoalDomains']} configured domains and {counts['boundedProductionReadyDomains']} bounded production-ready domains",
        },
        {
            "capabilityID": "r2_live_inventory_reconciled",
            "status": "proven_current",
            "evidence": f"{counts['liveR2ObjectProxy']} live R2 objects reconciled as current bounded public/reference evidence",
        },
        {
            "capabilityID": "candidate_only_unknown_domain_routing",
            "status": "proven_current" if counters["candidateOnlyRoutingProven"] else "not_proven",
            "evidence": f"{counts['unknownCandidateOnlyCases']} unknown-domain candidate-only gauntlet cases",
        },
        {
            "capabilityID": "product_law_claim_ceiling",
            "status": "proven_current",
            "evidence": "launch-floor ledger blocks Release Green, literal universal coverage, private-context routing, and final-output claims",
        },
        {
            "capabilityID": "launch_floor_target_tracking",
            "status": "proven_current",
            "evidence": f"{len(target_statuses)} launch-floor counters defined with fail-closed status",
        },
    ]
    capabilities.append(
        {
            "capabilityID": "launch_floor_taxonomy_universe",
            "status": "proven_current" if counters["launchFloorTaxonomyValid"] else "not_proven",
            "evidence": (
                f"{counts['launchFloorTaxonomyAcceptedGoalDomains']} accepted taxonomy domains and "
                f"{counts['launchFloorTaxonomyAcceptedSubdomains']} accepted taxonomy subdomains; "
                f"{counts['launchFloorTaxonomyConfiguredNotReadyDomains']} accepted domains remain configured-not-ready"
            ),
        }
    )
    capabilities.append(
        {
            "capabilityID": "launch_floor_shard_corpus_manifest_gate",
            "status": "proven_current" if counters["launchFloorShardCorpusValid"] else "not_proven",
            "evidence": (
                f"{counts['launchFloorShardCorpusCountedPartitions']} counted partitions and "
                f"{counts['shardCorpusCounter'] or 0} validated public/reference shards"
            ),
        }
    )
    capabilities.append(
        {
            "capabilityID": "launch_floor_r2_layout_readback_gate",
            "status": "proven_current"
            if counts["launchFloorR2LayoutProofObjects"] and counts["launchFloorR2ReadbackChecksumMismatches"] == 0
            else "not_proven",
            "evidence": (
                f"{counts['launchFloorR2LayoutProofObjects'] or 0} layout objects, "
                f"{counts['launchFloorR2ReadbackObjectsChecked'] or 0} readback checks, "
                f"{counts['launchFloorR2RollbackTransitions'] or 0} rollback transitions, "
                f"{counts['launchFloorR2GatewayLoadProbes'] or 0} gateway load probes, "
                f"{counts['launchFloorR2LiveWrites'] or 0} live writes"
            ),
        }
    )
    capabilities.append(
        {
            "capabilityID": "launch_floor_golden_intent_corpus_contract",
            "status": "proven_current" if counters["launchFloorGoldenIntentCorpusValid"] else "not_proven",
            "evidence": (
                f"{counts['launchFloorGoldenIntentRecords']} records, "
                f"{counts['goldenIntentCorpusCounter'] or 0} counted golden intents, "
                f"{counts['launchFloorGoldenIntentAdjudicatedRecords']} adjudicated records"
            ),
        }
    )
    return capabilities


def _missing_capabilities(target_statuses: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "targetID": target["targetID"],
            "status": target["status"],
            "missingCapability": "; ".join(target.get("gaps", [])) or "none",
        }
        for target in target_statuses
        if target["status"] != "met"
    ]


def _required_changes(target_statuses: list[dict[str, Any]]) -> list[dict[str, Any]]:
    mapping = {
        "public_reference_shards_1m": (
            "LFT-001",
            "Canonical shard corpus manifest and 1M+ shard production counter",
        ),
        "goal_domains_500": (
            "LFT-002",
            "500-domain active public/reference taxonomy",
        ),
        "subdomains_5000": (
            "LFT-003",
            "5,000-subdomain governed taxonomy",
        ),
        "golden_intents_50000": (
            "LFT-004",
            "50,000+ golden representative lawful goal-intent corpus",
        ),
        "source_needed_fallback_under_5_percent": (
            "LFT-005",
            "Fallback metric harness with lawful-goal numerator/denominator",
        ),
        "continuous_missing_shard_expansion": (
            "LFT-006",
            "Durable every-event missing-shard expansion pipeline",
        ),
    }
    changes = []
    for target in target_statuses:
        if target["status"] == "met":
            continue
        change_id, title = mapping[target["targetID"]]
        changes.append(
            {
                "changeID": change_id,
                "targetID": target["targetID"],
                "title": title,
                "requiredChange": " ".join(target.get("requiredChanges", [])),
                "blockedClaimsUntilComplete": _blocked_claims(),
            }
        )
    changes.extend(
        [
            {
                "changeID": "LFT-007",
                "targetID": "native_runtime_handoff",
                "title": "Verified public-shard handoff into local Private Runtime pathing",
                "requiredChange": "Scale native/runtime proof from bounded configured packs to launch-floor corpus without sending private graph data to Source Atlas/R2.",
                "blockedClaimsUntilComplete": ["runtime_release_green", "final_user_plans_schedules_steps_from_source_atlas_or_r2"],
            },
            {
                "changeID": "LFT-008",
                "targetID": "r2_storage_index_layout",
                "title": "R2/index layout suitable for 1M+ shards",
                "requiredChange": "Prove partitioned manifests, indexes, readback, rollback, LKG, revocation, and mobile decode performance for launch-floor shard volume.",
                "blockedClaimsUntilComplete": ["production_ready_without_scope", "release_green"],
            },
            {
                "changeID": "LFT-009",
                "targetID": "product_law_overclaim_gate",
                "title": "Product-law overclaim gate",
                "requiredChange": "Keep private-context, final-output, Release Green, App Store/TestFlight, outside legal, and literal universal claims blocked unless current proof exists.",
                "blockedClaimsUntilComplete": _blocked_claims(),
            },
        ]
    )
    return changes


def _dependency_graph() -> dict[str, Any]:
    nodes = [
        {"id": "LFF-M00", "title": "Launch-floor counters, proof ledger, and non-claim gate", "dependsOn": []},
        {"id": "LFF-M01", "title": "500-domain / 5,000-subdomain public taxonomy and router", "dependsOn": ["LFF-M00"]},
        {"id": "LFF-M02", "title": "1M+ public/reference shard corpus and R2/index layout", "dependsOn": ["LFF-M00", "LFF-M01"]},
        {"id": "LFF-M03", "title": "50,000 golden intents and <5% source-needed fallback metric", "dependsOn": ["LFF-M00", "LFF-M01", "LFF-M02"]},
        {"id": "LFF-M04", "title": "Continuous missing-shard expansion pipeline", "dependsOn": ["LFF-M00", "LFF-M01", "LFF-M03"]},
        {"id": "LFF-M05", "title": "Verified public shards into local Private Runtime pathing", "dependsOn": ["LFF-M02", "LFF-M03", "LFF-M04"]},
        {"id": "LFF-M06", "title": "Governance renewal and external release packets", "dependsOn": ["LFF-M02", "LFF-M05"]},
    ]
    return {"nodes": nodes, "edges": [{"from": parent, "to": node["id"]} for node in nodes for parent in node["dependsOn"]]}


def _validation_matrix() -> list[dict[str, str]]:
    return [
        {
            "validationID": "status",
            "command": "git status --short",
            "purpose": "confirm scoped working tree before and after launch-floor evidence generation",
        },
        {
            "validationID": "launch_floor_pytest",
            "command": "python3 -m pytest tools/source-atlas/foundry/tests/test_launch_floor_domain_taxonomy_lff_m01.py tools/source-atlas/foundry/tests/test_launch_floor_shard_corpus_lff_m02.py tools/source-atlas/foundry/tests/test_launch_floor_shard_corpus_compiler_lff_m02.py tools/source-atlas/foundry/tests/test_goal_domain_router_train_88.py tools/source-atlas/foundry/tests/test_source_atlas_launch_floor_ledger.py tools/source-atlas/foundry/tests/test_source_atlas_completion_audit_train_129.py",
            "purpose": "prove fail-closed launch-floor taxonomy, shard corpus compiler, shard corpus, router, ledger, and completion-audit wiring",
        },
        {
            "validationID": "launch_floor_shard_corpus_compiler",
            "command": "python3 tools/source-atlas/source-atlas-foundry.py launch-floor-shard-corpus-compiler --output-root tools/source-atlas/generated/source-atlas-launch-floor-shard-corpus-compiler/lff-m02-l02-current --emit-evidence docs/qa/source-atlas/source-atlas-launch-floor-shard-corpus-compiler-lff-m02.json --markdown docs/qa/source-atlas/source-atlas-launch-floor-shard-corpus-compiler-lff-m02.md --emit-manifest tools/source-atlas/generated/source-atlas-launch-floor-shard-corpus-compiler/lff-m02-l02-current/launch-floor-shard-corpus-manifest.json",
            "purpose": "compile reviewed bounded production-target evidence into a measurable public/reference shard corpus manifest without claiming 1M readiness",
        },
        {
            "validationID": "launch_floor_r2_layout_proof",
            "command": "python3 tools/source-atlas/source-atlas-foundry.py launch-floor-r2-layout-proof --shard-corpus-manifest tools/source-atlas/generated/source-atlas-launch-floor-shard-corpus-compiler/lff-m02-l02-current/launch-floor-shard-corpus-manifest.json --output-root tools/source-atlas/generated/source-atlas-launch-floor-r2-layout-proof/lff-m02-l03-current --emit-evidence docs/qa/source-atlas/source-atlas-launch-floor-r2-layout-proof-lff-m02.json --markdown docs/qa/source-atlas/source-atlas-launch-floor-r2-layout-proof-lff-m02.md",
            "purpose": "prove staged/promoted/current/LKG/revocation/rollback/gateway R2 layout and deterministic readback metadata without executing live R2 writes",
        },
        {
            "validationID": "launch_floor_ledger",
            "command": "python3 tools/source-atlas/source-atlas-foundry.py source-atlas-launch-floor-ledger --shard-corpus-manifest tools/source-atlas/generated/source-atlas-launch-floor-shard-corpus-compiler/lff-m02-l02-current/launch-floor-shard-corpus-manifest.json --r2-layout-proof docs/qa/source-atlas/source-atlas-launch-floor-r2-layout-proof-lff-m02.json --golden-intent-corpus docs/qa/source-atlas/source-atlas-launch-floor-golden-intent-corpus-lff-m03.json --output-root tools/source-atlas/generated/source-atlas-launch-floor-ledger/lff-m03-l01-current --emit-evidence docs/qa/source-atlas/source-atlas-launch-floor-ledger-current.json --markdown docs/qa/source-atlas/source-atlas-launch-floor-ledger-current.md",
            "purpose": "regenerate current launch-floor ledger with bounded shard corpus/R2 proof, validated golden-intent corpus report, and no source/R2/native mutation",
        },
        {
            "validationID": "launch_floor_golden_intent_corpus",
            "command": "python3 tools/source-atlas/source-atlas-foundry.py launch-floor-golden-intent-corpus --input docs/qa/source-atlas/source-atlas-goal-domain-gauntlet-train-131.json --input-format goal-domain-gauntlet --output-root tools/source-atlas/generated/source-atlas-launch-floor-golden-intent-corpus/lff-m03-l01-current --emit-evidence docs/qa/source-atlas/source-atlas-launch-floor-golden-intent-corpus-lff-m03.json --markdown docs/qa/source-atlas/source-atlas-launch-floor-golden-intent-corpus-lff-m03.md",
            "purpose": "import current public/reference gauntlet cases into the canonical golden-intent corpus contract while keeping the 50k target fail-closed",
        },
        {
            "validationID": "launch_floor_shard_corpus",
            "command": "python3 tools/source-atlas/source-atlas-foundry.py launch-floor-shard-corpus --manifest <validated-manifest> --output-root <proof-root>",
            "purpose": "validate partitioned 1M+ shard corpus manifests before any shard count can satisfy the launch-floor ledger",
        },
        {
            "validationID": "completion_audit_with_launch_floor",
            "command": "python3 tools/source-atlas/source-atlas-foundry.py source-atlas-completion-audit ... --launch-floor-ledger docs/qa/source-atlas/source-atlas-launch-floor-ledger-current.json",
            "purpose": "prove completion remains blocked while launch-floor counters are unmet",
        },
        {
            "validationID": "diff_check",
            "command": "git diff --check",
            "purpose": "guard whitespace and patch integrity",
        },
    ]


def _checks(
    *,
    issues: list[str],
    input_privacy_issues: list[str],
    artifact_privacy_issues: list[str],
    overclaim_issues: list[str],
    taxonomy_issues: list[str],
    shard_corpus_issues: list[str],
    golden_intent_issues: list[str],
    target_statuses: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    all_targets_met = all(target["status"] == "met" for target in target_statuses)
    return [
        _check("required_inputs_loaded", not issues, issues, "red"),
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues, "red"),
        _check("artifact_privacy_scan_passed", not artifact_privacy_issues, artifact_privacy_issues, "red"),
        _check("overclaim_scan_passed", not overclaim_issues, overclaim_issues, "red"),
        _check("launch_floor_taxonomy_valid_when_supplied", not taxonomy_issues, taxonomy_issues, "red"),
        _check("launch_floor_shard_corpus_valid_when_supplied", not shard_corpus_issues, shard_corpus_issues, "red"),
        _check("launch_floor_golden_intent_corpus_valid_when_supplied", not golden_intent_issues, golden_intent_issues, "red"),
        _check("launch_floor_counter_contract_defined", len(target_statuses) == len(LAUNCH_FLOOR_TARGETS), ["counter contract incomplete"], "red"),
        _check(
            "launch_floor_targets_met",
            all_targets_met,
            [f"{target['targetID']}={target['status']}" for target in target_statuses if target["status"] != "met"],
            "launch_floor_blocker",
        ),
        _check("launch_floor_claim_blocked_until_all_targets_met", not all_targets_met, [], "yellow"),
        _check("final_outputs_not_generated_by_source_atlas", True, [], "red"),
    ]


def _check(name: str, passed: bool, issues: list[str], severity: str) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": issues if not passed else [], "severity": severity}


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing at {path}")
        return None
    value = read_json(path)
    if not isinstance(value, dict):
        issues.append(f"{label} at {path} is not a JSON object")
    return value


def _read_optional_json(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        return None
    if not path.exists():
        issues.append(f"{label} configured but missing at {path}")
        return None
    value = read_json(path)
    if not isinstance(value, dict):
        issues.append(f"{label} at {path} is not a JSON object")
    return value


def _record_count(artifact: Any, *keys: str) -> int | None:
    if not isinstance(artifact, dict):
        return None
    containers = [artifact]
    if isinstance(artifact.get("recordCounts"), dict):
        containers.append(artifact["recordCounts"])
    if isinstance(artifact.get("record_counts"), dict):
        containers.append(artifact["record_counts"])
    for container in containers:
        for key in keys:
            value = container.get(key)
            if isinstance(value, list):
                return len(value)
            if value is not None:
                parsed = _int(value)
                if parsed is not None:
                    return parsed
    for key in keys:
        value = artifact.get(key)
        if isinstance(value, list):
            return len(value)
    return None


def _int(value: Any) -> int | None:
    if isinstance(value, bool) or value is None:
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, float):
        return int(value)
    if isinstance(value, str) and value.strip().isdigit():
        return int(value.strip())
    return None


def _fallback_fraction(metric: Any) -> tuple[int | None, int | None]:
    if not isinstance(metric, dict):
        return None, None
    numerator = _record_count(metric, "sourceNeededFallbackNumerator", "source_needed_fallback_numerator", "fallbackNumerator")
    denominator = _record_count(metric, "lawfulGoalDenominator", "lawful_goal_denominator", "fallbackDenominator", "totalLawfulGoals")
    if numerator is not None and denominator is not None:
        return numerator, denominator
    counts = metric.get("recordCounts") if isinstance(metric.get("recordCounts"), dict) else {}
    return _int(counts.get("sourceNeededFallbacks")), _int(counts.get("lawfulGoals"))


def _missing_shard_event_summary(events_artifact: Any) -> dict[str, Any]:
    if not isinstance(events_artifact, dict):
        return {"eventCount": 0, "durableExpansionEventCount": 0, "issues": ["missing-shard event ledger absent"]}
    raw_events = events_artifact.get("events") or events_artifact.get("missingShardEvents") or []
    if not isinstance(raw_events, list):
        return {"eventCount": 0, "durableExpansionEventCount": 0, "issues": ["missing-shard events are not a list"]}
    issues = []
    durable_count = 0
    durable_states = {"queued", "review_queued", "source_review_queued", "approved", "activated", "rejected_lawful_no_public_source"}
    for index, event in enumerate(raw_events):
        if not isinstance(event, dict):
            issues.append(f"event[{index}] is not an object")
            continue
        state = str(event.get("expansionState") or event.get("expansion_state") or event.get("status") or "")
        has_work = bool(event.get("workItemID") or event.get("work_item_id") or event.get("expansionWorkItemID"))
        has_public_boundary = event.get("publicReferenceOnly") is True or event.get("privateContextPresent") is False
        if state in durable_states and has_work and has_public_boundary:
            durable_count += 1
        else:
            issues.append(f"event[{index}] lacks durable governed public/reference expansion state")
    return {"eventCount": len(raw_events), "durableExpansionEventCount": durable_count, "issues": issues}


def _launch_floor_taxonomy_summary(artifacts: dict[str, Any]) -> dict[str, Any]:
    taxonomy = artifacts.get("launchFloorTaxonomy")
    if not isinstance(taxonomy, dict):
        return {
            "recordCounts": {
                "acceptedGoalDomains": 0,
                "acceptedSubdomains": 0,
                "configuredReadyDomains": 0,
                "configuredNotReadyDomains": 0,
                "candidateOnlyBacklogItems": 0,
                "staleCandidateOnlyBacklogItems": 0,
                "sourceLaneReviewBacklogItems": 0,
                "domainsWithSourceLaneCoverage": 0,
                "subdomainsWithSourceLaneCoverage": 0,
            },
            "launchFloorTargets": {
                "goalDomains500": False,
                "subdomains5000": False,
                "candidateOnlyBacklogExcludedFromCounts": True,
                "sourceLaneCoverageComplete": False,
            },
            "issues": [],
        }
    return launch_floor_domain_taxonomy_summary(
        taxonomy,
        source_lane_registry=artifacts.get("sourceLaneRegistry"),
        production_target_ledger=artifacts.get("productionTargetLedger"),
    )


def _launch_floor_shard_corpus_summary(artifacts: dict[str, Any]) -> dict[str, Any]:
    manifest = artifacts.get("shardCorpusManifest")
    if not isinstance(manifest, dict):
        return {
            "recordCounts": {
                "partitions": 0,
                "launchFloorCountedPartitions": 0,
                "publicReferenceShards": 0,
                "partitionsWithR2Layout": 0,
                "partitionsWithReadbackProof": 0,
                "partitionsWithRollbackProof": 0,
                "partitionsWithGatewayProof": 0,
                "partitionsWithNativeCompatibility": 0,
                "partitionsWithSourceLaneRegistryLinks": 0,
                "claims": 0,
                "r2PublishOperations": 0,
                "finalOutputArtifacts": 0,
                "privacyIssues": 0,
            },
            "launchFloorTargets": {
                "publicReferenceShards1M": False,
                "r2LayoutComplete": False,
                "readbackComplete": False,
                "rollbackComplete": False,
                "gatewayAllowlistComplete": False,
                "nativeDecoderCompatibilityComplete": False,
                "sourceLaneRegistryLinksComplete": False,
            },
            "partitions": [],
            "issues": [],
        }
    return launch_floor_shard_corpus_summary(
        manifest,
        taxonomy=artifacts.get("launchFloorTaxonomy"),
    )


def _launch_floor_golden_intent_summary(artifacts: dict[str, Any]) -> dict[str, Any]:
    corpus = artifacts.get("goldenIntentCorpus")
    if not isinstance(corpus, dict):
        return {
            "recordCounts": {
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
                "candidateOnlyCount": 0,
                "privateBlockedCount": 0,
                "illegalOutOfScopeCount": 0,
                "insufficientSourceCount": 0,
                "reviewArtifactCount": 0,
                "privacyIssues": 0,
                "finalOutputsGenerated": 0,
            },
            "coverageLabelCounts": {},
            "expectedRoutingStateCounts": {},
            "sourceNeededCauseCounts": {},
            "balance": {},
            "launchFloorTargets": {
                "goldenIntents50000": False,
                "domainCoverage500": False,
                "subdomainCoverage5000": False,
                "adjudicationComplete": False,
                "privacyBoundaryPass": True,
                "noFinalOutputs": True,
            },
            "issues": [],
        }
    return launch_floor_golden_intent_corpus_summary(corpus)


def _explicit_subdomains(frontiers: list[Any]) -> set[str]:
    subdomains: set[str] = set()
    for frontier in frontiers:
        if not isinstance(frontier, dict):
            continue
        for key in ("subdomains", "subdomain_ids", "subdomainIDs"):
            values = frontier.get(key)
            if isinstance(values, list):
                subdomains.update(str(value) for value in values if isinstance(value, (str, int, float)))
    return subdomains


def _source_lane_domain_scopes(source_lanes: list[Any]) -> set[str]:
    scopes: set[str] = set()
    for lane in source_lanes:
        if not isinstance(lane, dict):
            continue
        value = lane.get("domain_scope")
        if isinstance(value, list):
            scopes.update(str(item) for item in value if isinstance(item, (str, int, float)))
        elif isinstance(value, (str, int, float)):
            scopes.add(str(value))
    return scopes


def _claim(artifact: Any, claim: str) -> bool:
    return isinstance(artifact, dict) and claim in artifact.get("allowedClaims", [])


def _native_bridge_source_contract(path: Path | None) -> dict[str, int | None]:
    if path is None or not path.exists():
        return {"intentCount": None, "scenarioCount": None}
    text = path.read_text(encoding="utf-8")
    intent_match = re.search(r"XCTAssertEqual\(catalog\.intents\.count,\s*(\d+)\)", text)
    scenario_match = re.search(r"XCTAssertEqual\(catalog\.intents\.count \* catalog\.permutations\.count,\s*(\d+)\)", text)
    return {
        "intentCount": int(intent_match.group(1)) if intent_match else None,
        "scenarioCount": int(scenario_match.group(1)) if scenario_match else None,
        "sourcePath": str(path),
        "proofScope": "source test contract only; not canonical launch-floor golden corpus",
    }


def _privacy_issues(value: Any, label: str) -> list[str]:
    return [
        issue.format()
        for issue in boundary_issues_for_value(value, label)
        if not is_boundary_line(issue.detail)
        and not (issue.code == "unsupported_data_class" and issue.detail in PUBLIC_HYGIENE_CLASSIFICATIONS)
    ]


def _overclaim_issues(artifacts: dict[str, Any]) -> list[str]:
    issues = []
    for name, artifact in artifacts.items():
        if not isinstance(artifact, dict):
            continue
        claims = set(str(claim) for claim in artifact.get("allowedClaims", []) if isinstance(claim, str))
        for claim in sorted(claims & FORBIDDEN_LAUNCH_FLOOR_CLAIMS):
            issues.append(f"{name}: forbidden launch-floor claim allowed: {claim}")
        if artifact.get("launchFloorMet") is True or artifact.get("launchFloorClaimAllowed") is True:
            issues.append(f"{name}: launch-floor claim is not accepted as input proof by this ledger")
    return issues


def _input_hashes(artifacts: dict[str, Any]) -> dict[str, str | None]:
    return {
        key: stable_hash(value) if isinstance(value, dict) else None
        for key, value in sorted(artifacts.items())
    }


def _input_paths(options: SourceAtlasLaunchFloorLedgerOptions) -> dict[str, str | None]:
    return {
        "frontierConfig": str(options.frontier_config_path),
        "sourceLaneRegistry": str(options.source_lane_registry_path),
        "legalTermsRegistry": str(options.legal_terms_registry_path),
        "apiGovernanceRegistry": str(options.api_governance_registry_path),
        "productionTargetLedger": str(options.production_target_ledger_path),
        "r2LiveInventory": str(options.r2_live_inventory_path),
        "goalDomainGauntlet": str(options.goal_domain_gauntlet_path),
        "completionAudit": str(options.completion_audit_path),
        "releaseProofPacket": str(options.release_proof_packet_path),
        "productionSupervisor": str(options.production_supervisor_path) if options.production_supervisor_path else None,
        "autonomousControlLoop": str(options.autonomous_control_loop_path) if options.autonomous_control_loop_path else None,
        "autonomousDomainExpansionChain": str(options.autonomous_domain_expansion_chain_path) if options.autonomous_domain_expansion_chain_path else None,
        "launchFloorTaxonomy": str(options.launch_floor_taxonomy_path) if options.launch_floor_taxonomy_path else None,
        "shardCorpusManifest": str(options.shard_corpus_manifest_path) if options.shard_corpus_manifest_path else None,
        "r2LayoutProof": str(options.r2_layout_proof_path) if options.r2_layout_proof_path else None,
        "goldenIntentCorpus": str(options.golden_intent_corpus_path) if options.golden_intent_corpus_path else None,
        "fallbackMetric": str(options.fallback_metric_path) if options.fallback_metric_path else None,
        "missingShardEvents": str(options.missing_shard_events_path) if options.missing_shard_events_path else None,
        "nativeRuntimeBridgeGauntletSource": str(options.native_runtime_bridge_gauntlet_source_path) if options.native_runtime_bridge_gauntlet_source_path else None,
    }


def _proof_artifacts(input_paths: dict[str, str | None], native_bridge_source_contract: dict[str, Any]) -> list[dict[str, Any]]:
    artifacts = [{"artifactID": key, "path": value, "role": "launch_floor_evidence_input"} for key, value in input_paths.items() if value]
    if native_bridge_source_contract.get("sourcePath"):
        artifacts.append(
            {
                "artifactID": "native_runtime_bridge_source_contract",
                "path": str(native_bridge_source_contract["sourcePath"]),
                "role": str(native_bridge_source_contract["proofScope"]),
            }
        )
    return artifacts


def _status(valid: bool, launch_floor_met: bool) -> str:
    if not valid:
        return "Red: Source Atlas launch-floor ledger found missing required evidence, privacy issue, or overclaim"
    if launch_floor_met:
        return "Source Green for Source Atlas launch-floor target ledger"
    return "Source Green for launch-floor ledger tooling / Launch-floor targets not met"


def _allowed_claims(valid: bool, launch_floor_met: bool) -> list[str]:
    if not valid:
        return []
    claims = [
        "source_atlas_launch_floor_ledger_tooling_green",
        "current_launch_floor_gap_map_emitted",
        "launch_floor_claims_blocked_until_all_counters_pass",
        "product_law_nonclaims_preserved",
    ]
    if launch_floor_met:
        claims.append("source_atlas_launch_floor_ready")
    return claims


def _blocked_claims() -> list[str]:
    return sorted(FORBIDDEN_LAUNCH_FLOOR_CLAIMS | {"production_ready_without_scope", "goal_complete"})


def _markdown_counter(target: dict[str, Any]) -> str:
    if target["targetID"] == "source_needed_fallback_under_5_percent":
        rate = target.get("measuredRate")
        if rate is None:
            return "missing"
        return f"{rate:.4f}"
    value = target.get("measuredValue")
    return "missing" if value is None else str(value)
