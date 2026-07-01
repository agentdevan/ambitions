from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import write_json  # noqa: E402
from foundry.source_atlas_launch_floor_ledger import (  # noqa: E402
    SourceAtlasLaunchFloorLedgerOptions,
    build_source_atlas_launch_floor_ledger,
)


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = Path(__file__).resolve().parents[4]

FRONTIER_CONFIG = SOURCE_ATLAS_ROOT / "frontier" / "coverage-frontiers.json"
SOURCE_LANE_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "source-lane-registry.json"
LEGAL_TERMS_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "legal-terms-registry.json"
API_GOVERNANCE_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "api-governance-registry.json"
PRODUCTION_TARGET_LEDGER = SOURCE_ATLAS_ROOT / "generated" / "production-target-ledger" / "train-131-tetradeca-current" / "production-target-ledger.json"
R2_LIVE_INVENTORY = SOURCE_ATLAS_ROOT / "generated" / "r2-live-inventory" / "train-137-post-hygiene-resolution-inventory" / "r2-live-inventory-report.json"
GOAL_DOMAIN_GAUNTLET = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-goal-domain-gauntlet-train-131.json"
COMPLETION_AUDIT = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-completion-audit-train-132.json"
RELEASE_PROOF_PACKET = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-release-proof-packet-train-132.json"
PRODUCTION_SUPERVISOR = SOURCE_ATLAS_ROOT / "generated" / "autonomous-production-supervisor" / "train-133-current-proof-refresh" / "autonomous-production-supervisor-report.json"
AUTONOMOUS_CONTROL_LOOP = SOURCE_ATLAS_ROOT / "generated" / "autonomous-control-loop" / "train-131-tetradeca-final" / "autonomous-control-loop-report.json"
AUTONOMOUS_DOMAIN_EXPANSION_CHAIN = SOURCE_ATLAS_ROOT / "generated" / "autonomous-domain-expansion-chain" / "train-107-current" / "autonomous-domain-expansion-chain-report.json"
LAUNCH_FLOOR_TAXONOMY = SOURCE_ATLAS_ROOT / "frontier" / "launch-floor-domain-taxonomy.json"
NATIVE_BRIDGE_GAUNTLET_SOURCE = REPO_ROOT / "Native" / "AmbitionsTests" / "LocalRuntimeOS" / "SourceAtlas" / "SourceAtlasRuntimeBridgeCoverageGauntletTests.swift"


def test_launch_floor_ledger_current_repo_evidence_fails_closed(tmp_path: Path):
    result = build_source_atlas_launch_floor_ledger(_current_options(tmp_path))

    assert result["valid"], result["issues"]
    assert result["launchFloorMet"] is False
    assert result["launchFloorClaimAllowed"] is False
    counts = result["recordCounts"]
    assert counts["configuredGoalDomains"] == 14
    assert counts["boundedProductionReadyDomains"] == 14
    assert counts["launchFloorTaxonomyAcceptedGoalDomains"] == 500
    assert counts["launchFloorTaxonomyAcceptedSubdomains"] == 5000
    assert counts["launchFloorTaxonomyConfiguredReadyDomains"] == 14
    assert counts["launchFloorTaxonomyConfiguredNotReadyDomains"] == 486
    assert counts["launchFloorTaxonomySourceLaneReviewBacklogItems"] == 486
    assert counts["packablePublicReferenceClaimProxy"] == 71
    assert counts["liveR2ObjectProxy"] == 196
    assert counts["sourceLaneCount"] == 34
    assert counts["sourceLaneDomainScopeProxy"] == 44
    assert counts["configuredGauntletCases"] == 14
    assert counts["nativeBridgeSourceIntentContract"] == 100
    assert counts["nativeBridgeSourcePermutationContract"] == 1000
    assert result["launchFloorTargetStatus"]["goal_domains_500"]["status"] == "met"
    assert result["launchFloorTargetStatus"]["public_reference_shards_1m"]["status"] == "not_measurable_fail_closed"
    assert result["launchFloorTargetStatus"]["subdomains_5000"]["status"] == "met"
    assert result["launchFloorTargetStatus"]["golden_intents_50000"]["status"] == "not_measurable_fail_closed"
    assert result["launchFloorTargetStatus"]["source_needed_fallback_under_5_percent"]["status"] == "not_measurable_fail_closed"
    assert result["launchFloorTargetStatus"]["continuous_missing_shard_expansion"]["status"] == "not_measurable_fail_closed"
    assert "source_atlas_launch_floor_ready" in result["blockedClaims"]
    assert "final_user_plans_schedules_steps_from_source_atlas_or_r2" in result["blockedClaims"]


def test_launch_floor_ledger_can_pass_only_with_canonical_launch_floor_counters(tmp_path: Path):
    paths = _passing_fixture_paths(tmp_path)

    result = build_source_atlas_launch_floor_ledger(
        SourceAtlasLaunchFloorLedgerOptions(
            frontier_config_path=paths["frontier"],
            source_lane_registry_path=paths["source_registry"],
            legal_terms_registry_path=paths["legal_registry"],
            api_governance_registry_path=paths["api_registry"],
            production_target_ledger_path=paths["production_ledger"],
            r2_live_inventory_path=paths["r2_inventory"],
            goal_domain_gauntlet_path=paths["gauntlet"],
            completion_audit_path=paths["completion"],
            release_proof_packet_path=paths["release"],
            production_supervisor_path=paths["supervisor"],
            autonomous_control_loop_path=paths["control_loop"],
            autonomous_domain_expansion_chain_path=paths["expansion_chain"],
            shard_corpus_manifest_path=paths["shard_manifest"],
            golden_intent_corpus_path=paths["golden_corpus"],
            fallback_metric_path=paths["fallback_metric"],
            missing_shard_events_path=paths["missing_events"],
            output_root=tmp_path / "launch-floor-pass",
            created_at="2026-07-01T00:00:00Z",
            run_label="synthetic-contract-pass",
        )
    )

    assert result["valid"], result["issues"]
    assert result["launchFloorMet"] is True
    assert result["launchFloorClaimAllowed"] is True
    assert all(target["status"] == "met" for target in result["targetStatuses"])
    assert "source_atlas_launch_floor_ready" in result["allowedClaims"]
    assert result["recordCounts"]["configuredGoalDomains"] == 500
    assert result["recordCounts"]["explicitSubdomains"] == 5000
    assert result["recordCounts"]["shardCorpusCounter"] == 1_000_000
    assert result["recordCounts"]["goldenIntentCorpusCounter"] == 50_000
    assert result["recordCounts"]["sourceNeededFallbackNumerator"] == 49
    assert result["recordCounts"]["sourceNeededFallbackDenominator"] == 1000


def test_launch_floor_ledger_rejects_forbidden_input_overclaim(tmp_path: Path):
    paths = _passing_fixture_paths(tmp_path)
    release = _release_packet()
    release["allowedClaims"].append("release_green")
    write_json(paths["release"], release)

    result = build_source_atlas_launch_floor_ledger(
        SourceAtlasLaunchFloorLedgerOptions(
            frontier_config_path=paths["frontier"],
            source_lane_registry_path=paths["source_registry"],
            legal_terms_registry_path=paths["legal_registry"],
            api_governance_registry_path=paths["api_registry"],
            production_target_ledger_path=paths["production_ledger"],
            r2_live_inventory_path=paths["r2_inventory"],
            goal_domain_gauntlet_path=paths["gauntlet"],
            completion_audit_path=paths["completion"],
            release_proof_packet_path=paths["release"],
            output_root=tmp_path / "launch-floor-overclaim",
            created_at="2026-07-01T00:00:00Z",
            run_label="synthetic-overclaim",
        )
    )

    assert result["valid"] is False
    assert any("release_green" in issue for issue in result["overclaimIssues"])
    assert result["launchFloorMet"] is False
    assert result["allowedClaims"] == []


def _current_options(tmp_path: Path) -> SourceAtlasLaunchFloorLedgerOptions:
    return SourceAtlasLaunchFloorLedgerOptions(
        frontier_config_path=FRONTIER_CONFIG,
        source_lane_registry_path=SOURCE_LANE_REGISTRY,
        legal_terms_registry_path=LEGAL_TERMS_REGISTRY,
        api_governance_registry_path=API_GOVERNANCE_REGISTRY,
        production_target_ledger_path=PRODUCTION_TARGET_LEDGER,
        r2_live_inventory_path=R2_LIVE_INVENTORY,
        goal_domain_gauntlet_path=GOAL_DOMAIN_GAUNTLET,
        completion_audit_path=COMPLETION_AUDIT,
        release_proof_packet_path=RELEASE_PROOF_PACKET,
        production_supervisor_path=PRODUCTION_SUPERVISOR,
        autonomous_control_loop_path=AUTONOMOUS_CONTROL_LOOP,
        autonomous_domain_expansion_chain_path=AUTONOMOUS_DOMAIN_EXPANSION_CHAIN,
        launch_floor_taxonomy_path=LAUNCH_FLOOR_TAXONOMY,
        native_runtime_bridge_gauntlet_source_path=NATIVE_BRIDGE_GAUNTLET_SOURCE,
        output_root=tmp_path / "current-launch-floor",
        created_at="2026-07-01T00:00:00Z",
        run_label="current-test",
    )


def _passing_fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {
        "frontier": root / "frontiers.json",
        "source_registry": root / "source-lanes.json",
        "legal_registry": root / "legal.json",
        "api_registry": root / "api.json",
        "production_ledger": root / "production-ledger.json",
        "r2_inventory": root / "r2-inventory.json",
        "gauntlet": root / "gauntlet.json",
        "completion": root / "completion.json",
        "release": root / "release.json",
        "supervisor": root / "supervisor.json",
        "control_loop": root / "control-loop.json",
        "expansion_chain": root / "expansion-chain.json",
        "shard_manifest": root / "shard-manifest.json",
        "golden_corpus": root / "golden-corpus.json",
        "fallback_metric": root / "fallback.json",
        "missing_events": root / "missing-events.json",
    }
    write_json(paths["frontier"], _frontier_config())
    write_json(paths["source_registry"], {"kind": "ambitions.sourceAtlas.sourceLaneRegistry.v1", "source_lanes": [{"source_id": "synthetic.public", "domain_scope": ["domain_000"]}]})
    write_json(paths["legal_registry"], {"kind": "ambitions.sourceAtlas.legalTermsRegistry.v1", "licenses": [{"license_id": "synthetic.public"}]})
    write_json(paths["api_registry"], {"kind": "ambitions.sourceAtlas.apiGovernanceRegistry.v1", "api_policies": [{"api_policy_id": "synthetic.public"}]})
    write_json(paths["production_ledger"], _production_ledger())
    write_json(paths["r2_inventory"], {"kind": "ambitions.sourceAtlas.r2LiveInventory.v1", "valid": True, "recordCounts": {"liveObjects": 1_000_000, "expectedCurrentObjects": 1_000_000}, "allowedClaims": []})
    write_json(paths["gauntlet"], _gauntlet())
    write_json(paths["completion"], {"kind": "ambitions.sourceAtlas.completionAudit.v1", "valid": True, "allowedClaims": ["source_atlas_completion_audit_green"], "recordCounts": {}})
    write_json(paths["release"], _release_packet())
    write_json(paths["supervisor"], {"kind": "ambitions.sourceAtlas.autonomousProductionSupervisor.v1", "valid": True, "allowedClaims": ["supervised_autonomous_source_atlas_work_loop_green"], "recordCounts": {"workQueueItems": 2, "promotionDecisions": 2}})
    write_json(paths["control_loop"], {"kind": "ambitions.sourceAtlas.autonomousControlLoop.v1", "valid": True, "allowedClaims": ["unknown_domains_candidate_only_controlled"], "recordCounts": {"unknownDomainsCandidateOnly": 2}})
    write_json(paths["expansion_chain"], {"kind": "ambitions.sourceAtlas.autonomousDomainExpansionChain.v1", "valid": True, "allowedClaims": ["deterministic_autonomous_candidate_domain_expansion_chain"], "recordCounts": {"candidateRoutes": 2, "r2PublishOperations": 0}})
    write_json(paths["shard_manifest"], {"kind": "ambitions.sourceAtlas.shardCorpusManifest.v1", "recordCounts": {"publicReferenceShards": 1_000_000}})
    write_json(paths["golden_corpus"], {"kind": "ambitions.sourceAtlas.goldenIntentCorpus.v1", "recordCounts": {"goldenIntentCount": 50_000}})
    write_json(paths["fallback_metric"], {"kind": "ambitions.sourceAtlas.sourceNeededFallbackMetric.v1", "recordCounts": {"sourceNeededFallbacks": 49, "lawfulGoals": 1000}})
    write_json(paths["missing_events"], _missing_events())
    return paths


def _frontier_config() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.coverageFrontierConfig.v1",
        "frontiers": [
            {
                "frontier_id": f"domain_{domain_index:03d}",
                "domain": f"domain_{domain_index:03d}",
                "subdomains": [f"domain_{domain_index:03d}.subdomain_{subdomain_index:02d}" for subdomain_index in range(10)],
                "source_ids": ["synthetic.public"],
                "goal_intent_classes": ["public_reference"],
            }
            for domain_index in range(500)
        ],
    }


def _production_ledger() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "allowedClaims": ["bounded_production_target_for_configured_frontiers"],
        "blockedClaims": ["literal_universal_coverage"],
        "universalCoverageClaimAllowed": False,
        "recordCounts": {"boundedProductionTargetReady": 500, "configuredFrontiers": 500},
        "domains": [
            {"domainID": f"domain_{index:03d}", "packableClaimCount": 2000, "readinessStatus": "bounded_production_target_ready"}
            for index in range(500)
        ],
    }


def _gauntlet() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.goalDomainGauntlet.v1",
        "valid": True,
        "allowedClaims": ["unknown_public_reference_domains_candidate_only"],
        "blockedClaims": ["literal_universal_coverage"],
        "recordCounts": {"configuredGauntletCases": 50_000, "unknownCasesCandidateOnly": 2, "finalOutputsGenerated": 0},
    }


def _release_packet() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.releaseProofPacket.v1",
        "valid": True,
        "allowedClaims": ["source_atlas_release_proof_packet_green", "release_overclaim_blocked"],
        "blockedClaims": ["release_green", "app_store_readiness", "testflight_readiness"],
        "recordCounts": {"focusedNativePassed": 72, "sourceAtlasPytestPassed": 502},
    }


def _missing_events() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.missingShardEventLedger.v1",
        "events": [
            {
                "eventID": "missing-shard-001",
                "expansionState": "source_review_queued",
                "workItemID": "work-001",
                "publicReferenceOnly": True,
                "privateContextPresent": False,
            },
            {
                "eventID": "missing-shard-002",
                "expansionState": "approved",
                "workItemID": "work-002",
                "publicReferenceOnly": True,
                "privateContextPresent": False,
            },
        ],
    }
