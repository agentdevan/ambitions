from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import read_json, write_json  # noqa: E402
from foundry.source_atlas_completion_audit import (  # noqa: E402
    SourceAtlasCompletionAuditOptions,
    run_source_atlas_completion_audit,
)


CREATED_AT = "2026-06-29T04:45:00Z"


def test_completion_audit_maps_full_goal_without_claiming_completion(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["goalComplete"] is False
    assert result["goalCompletionClaimed"] is False
    assert result["completionClaimAllowed"] is False
    assert result["overallReadinessStatus"] == "yellow_goal_incomplete_gap_mapped"
    assert result["recordCounts"]["requirements"] == 15
    assert result["recordCounts"]["provenCurrentRequirements"] >= 4
    assert result["recordCounts"]["sourceGreenScopedRequirements"] >= 7
    assert result["recordCounts"]["yellowRequirements"] >= 2
    assert "source_atlas_completion_audit_green" in result["allowedClaims"]
    assert "full_source_atlas_green" in result["blockedClaims"]
    release = _requirement(result, "release_readiness")
    assert release["status"] == "yellow_needs_stronger_proof"
    assert "releaseProofPacket" in release["evidence"]
    assert any("Release Green" in gap for gap in release["gaps"])
    assert any("physical_device_proof" in gap for gap in release["gaps"])
    legal = _requirement(result, "legal_terms_approval")
    assert legal["status"] == "source_green_scoped"
    assert any("outside legal" in gap for gap in legal["gaps"])
    launch_floor = _requirement(result, "near_universal_launch_floor")
    assert launch_floor["status"] == "yellow_needs_stronger_proof"
    assert "launchFloorLedger" in launch_floor["evidence"]
    assert any("golden_intents_50000" in gap for gap in launch_floor["gaps"])
    assert any(item["workItemID"].endswith("outside_legal_approval_artifact") for item in result["nextWorkQueue"])
    assert any(item["sourceRequirementID"] == "autonomous_domain_expansion" for item in result["nextWorkQueue"])
    assert result["recordCounts"]["privacyIssues"] == 0
    assert result["recordCounts"]["overclaimIssues"] == 0


def test_completion_audit_blocks_native_requirement_when_native_report_missing_but_stays_valid(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    paths["native"] = None

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    native = _requirement(result, "native_fetch_cache_verify")
    assert native["status"] == "blocked_missing_artifact"
    assert "native_runtime_report" not in result["issues"]
    assert result["goalComplete"] is False
    assert any(item["sourceRequirementID"] == "native_fetch_cache_verify" for item in result["nextWorkQueue"])


def test_completion_audit_blocks_launch_floor_when_ledger_missing_but_stays_valid(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    paths["launch_floor"] = None

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    launch_floor = _requirement(result, "near_universal_launch_floor")
    assert launch_floor["status"] == "blocked_missing_artifact"
    assert result["recordCounts"]["launchFloorTargets"] == 0
    assert result["goalComplete"] is False
    assert any(item["sourceRequirementID"] == "near_universal_launch_floor" for item in result["nextWorkQueue"])


def test_completion_audit_rejects_private_domain_context(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    supervisor = read_json(paths["supervisor"])
    supervisor["maintenanceQueue"][0]["domainID"] = "my schedule"
    write_json(paths["supervisor"], supervisor)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert result["privacyIssues"]
    assert _requirement(result, "security_privacy_boundary")["status"] == "red_boundary_violation"
    assert any("schedule_or_capacity" in issue or "first_person_private_context" in issue for issue in result["issues"])
    assert result["goalComplete"] is False


def test_completion_audit_rejects_forbidden_release_green_claim(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    finish = read_json(paths["finish"])
    finish["allowedClaims"].append("release_green")
    write_json(paths["finish"], finish)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert result["overclaimIssues"]
    assert any("release_green" in issue for issue in result["overclaimIssues"])
    assert _requirement(result, "completion_claim_control")["status"] == "red_boundary_violation"
    assert result["allowedClaims"] == []
    assert result["goalComplete"] is False


def _run(tmp_path: Path, paths: dict[str, Path | None]) -> dict:
    return run_source_atlas_completion_audit(
        SourceAtlasCompletionAuditOptions(
            production_supervisor_path=paths["supervisor"],
            production_sweep_path=paths["sweep"],
            production_finish_line_gate_path=paths["finish"],
            production_recertification_path=paths["recertification"],
            production_target_ledger_path=paths["ledger"],
            arbitrary_domain_gate_path=paths["arbitrary"],
            goal_domain_gauntlet_path=paths["gauntlet"],
            source_lane_registry_path=paths["source_registry"],
            legal_terms_registry_path=paths["legal_registry"],
            api_governance_registry_path=paths["api_registry"],
            native_runtime_report_path=paths["native"],
            release_proof_packet_path=paths["release_packet"],
            legal_approval_packet_path=paths["legal_packet"],
            owner_approval_path=paths["owner"],
            launch_floor_ledger_path=paths["launch_floor"],
            output_root=tmp_path / f"completion-audit-{len(list(tmp_path.glob('completion-audit-*')))}",
            created_at=CREATED_AT,
            run_label="test-completion-audit",
        )
    )


def _requirement(result: dict, requirement_id: str) -> dict:
    return next(item for item in result["requirementEvaluations"] if item["requirementID"] == requirement_id)


def _fixture_paths(tmp_path: Path) -> dict[str, Path | None]:
    root = tmp_path / "fixtures"
    paths: dict[str, Path | None] = {
        "supervisor": root / "supervisor.json",
        "sweep": root / "sweep.json",
        "finish": root / "finish-line.json",
        "recertification": root / "recertification.json",
        "ledger": root / "ledger.json",
        "arbitrary": root / "arbitrary.json",
        "gauntlet": root / "gauntlet.json",
        "source_registry": root / "source-registry.json",
        "legal_registry": root / "legal-registry.json",
        "api_registry": root / "api-registry.json",
        "native": root / "native-runtime.json",
        "release_packet": root / "release-proof-packet.json",
        "legal_packet": root / "legal-packet.json",
        "owner": root / "owner.json",
        "launch_floor": root / "launch-floor-ledger.json",
    }
    write_json(paths["supervisor"], _supervisor())
    write_json(paths["sweep"], _sweep())
    write_json(paths["finish"], _finish_line())
    write_json(paths["recertification"], _recertification())
    write_json(paths["ledger"], _ledger())
    write_json(paths["arbitrary"], _arbitrary())
    write_json(paths["gauntlet"], _gauntlet())
    write_json(paths["source_registry"], _source_registry())
    write_json(paths["legal_registry"], _legal_registry())
    write_json(paths["api_registry"], _api_registry())
    write_json(paths["native"], _native_runtime())
    write_json(paths["release_packet"], _release_packet())
    write_json(paths["legal_packet"], _legal_packet())
    write_json(paths["owner"], _owner())
    write_json(paths["launch_floor"], _launch_floor_ledger())
    return paths


def _supervisor() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousProductionSupervisor.v1",
        "valid": True,
        "status": "Source Green for supervised autonomous Source Atlas work loop",
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; supervised bounded public/reference work loop only",
        "allowedClaims": [
            "supervised_autonomous_source_atlas_work_loop_green",
            "promotion_control_integrated",
            "promotion_decisions_emitted_without_remote_or_native_mutation",
        ],
        "blockedClaims": ["full_source_atlas_green", "release_green", "literal_universal_coverage", "outside_legal_approval"],
        "recordCounts": {
            "configuredDomains": 13,
            "promotionDecisions": 14,
            "productionWritesExecuted": 0,
            "remoteMutations": 0,
            "nativeRuntimeMutations": 0,
            "finalOutputsGenerated": 0,
        },
        "maintenanceQueue": [
            {
                "domainID": "education_credentialing",
                "nextAction": "monitor_current_production",
                "status": "observed_snapshot_written",
                "productionWriteExecuted": False,
                "remoteMutation": False,
                "nativeRuntimeMutation": False,
                "finalOutputGenerated": False,
            },
            {
                "domainID": "volunteering_public_reference",
                "nextAction": "candidate_frontier_review",
                "status": "executed_safe",
                "requiredGate": "frontier_governance_review",
                "productionWriteExecuted": False,
                "remoteMutation": False,
                "nativeRuntimeMutation": False,
                "finalOutputGenerated": False,
            },
        ],
        "privacyIssues": [],
        "issues": [],
    }


def _sweep() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionSweep.v1",
        "valid": True,
        "status": "Source Green for current configured production sweep",
        "allowedClaims": [
            "current_configured_frontier_production_sweep",
            "current_remote_r2_upload_readback_reconciled",
            "future_remote_r2_write_preflight_ready",
        ],
        "blockedClaims": ["full_source_atlas_green", "release_green", "literal_universal_coverage", "outside_legal_approval"],
        "recordCounts": {
            "configuredDomains": 13,
            "domainsReady": 13,
            "packReportsValid": 13,
            "r2ReportsValid": 13,
            "remoteR2UploadsReconciled": 13,
            "privacyIssues": 0,
        },
        "domains": [{"domainID": "education_credentialing", "ready": True, "packableClaimCount": 8, "sourceIDs": ["education.official"]}],
        "privacyIssues": [],
        "issues": [],
    }


def _finish_line() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionFinishLineGate.v1",
        "valid": True,
        "status": "Source Green for bounded configured production finish-line gate",
        "allowedClaims": [
            "bounded_configured_production_target",
            "internal_terms_review",
            "production_r2_write_readback",
            "bounded_live_transport",
            "bounded_configured_runtime_green",
        ],
        "blockedClaims": ["outside_legal_approval", "runtime_green", "release_green", "universal_coverage", "literal_universal_coverage"],
        "recordCounts": {"productionDomains": 13, "r2ReportsValid": 13, "privacyIssues": 0},
        "privacyIssues": [],
        "issues": [],
    }


def _recertification() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionRecertification.v1",
        "valid": True,
        "status": "Source Green for bounded configured production/runtime recertification",
        "allowedClaims": ["bounded_configured_source_atlas_production_runtime_ready"],
        "blockedClaims": ["full_source_atlas_green", "release_green", "literal_universal_coverage", "outside_legal_approval"],
        "recordCounts": {"recertifiedDomains": 13, "gatewayLiveDomains": 13, "nativeRegistryMatches": 13, "privacyIssues": 0},
        "privacyIssues": [],
        "issues": [],
    }


def _ledger() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "status": "Source Green for production target ledger",
        "allowedClaims": ["bounded_production_target_for_configured_frontiers"],
        "blockedClaims": ["full_source_atlas_green", "release_green", "literal_universal_coverage", "outside_legal_approval"],
        "universalCoverageClaimAllowed": False,
        "recordCounts": {"configuredFrontiers": 13, "boundedProductionTargetReady": 13},
        "privacyIssues": [],
        "issues": [],
    }


def _arbitrary() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.arbitraryDomainHandlingGate.v1",
        "valid": True,
        "status": "Source Green for governed arbitrary public/reference domain handling",
        "allowedClaims": ["governed_arbitrary_public_reference_domain_handling"],
        "blockedClaims": ["full_source_atlas_green", "release_green", "literal_universal_coverage", "outside_legal_approval"],
        "recordCounts": {"configuredFrontiers": 13, "candidateClaims": 0, "candidateR2PublishOperations": 0},
        "privacyIssues": [],
        "issues": [],
    }


def _gauntlet() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainGauntlet.v1",
        "valid": True,
        "status": "Source Green for representative configured goal-domain gauntlet",
        "allowedClaims": [
            "representative_goal_domain_gauntlet_green",
            "configured_frontier_goal_domain_runtime_routing",
            "unknown_public_reference_domains_candidate_only",
        ],
        "blockedClaims": ["full_source_atlas_green", "release_green", "literal_universal_coverage", "outside_legal_approval"],
        "recordCounts": {"configuredCasesPassed": 13, "finalOutputsGenerated": 0, "privacyIssues": 0},
        "checks": [{"name": "no_final_plan_schedule_step_output", "passed": True, "issues": []}],
        "privacyIssues": [],
        "issues": [],
    }


def _source_registry() -> dict:
    return {"kind": "ambitions.sourceAtlas.sourceLaneRegistry.v1", "source_lanes": [{"source_id": "education.official"}]}


def _legal_registry() -> dict:
    return {"kind": "ambitions.sourceAtlas.legalTermsRegistry.v1", "licenses": [{"license_id": "education.terms"}]}


def _api_registry() -> dict:
    return {"kind": "ambitions.sourceAtlas.apiGovernanceRegistry.v1", "api_policies": [{"api_policy_id": "api.public.static"}]}


def _native_runtime() -> dict:
    return {
        "artifactID": "source-atlas-native-runtime-current-r2",
        "kind": "ambitions.sourceAtlas.nativeRuntimeCurrentProof.v1",
        "valid": True,
        "status": "Native Runtime Green for configured Source Atlas public-pack live gateway consumption / Yellow overall Source Atlas",
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; Native Runtime Green is scoped to configured Source Atlas public-pack live gateway consumption.",
        "proofSummary": {
            "r2RequestPrivacyProof": "Public Worker endpoint only; no private goal, capture, schedule, proof, account, device, or private graph context.",
            "noPrivateGraphEgressProof": "No-private-graph audit passed.",
            "lkgRollbackProof": "LKG fallback works without blocking local planning.",
            "nativeOfflineNoAccountProof": "Offline no-account tests passed.",
            "runtimeCompositionProof": "Local inspection/composition remains reference-only.",
        },
        "xcodeBuildMCP": {"result": "SUCCEEDED", "passed": 72, "failed": 0, "skipped": 0},
        "knownRisks": ["Release Green still requires umbrella release evidence and approvals outside this train."],
    }


def _release_packet() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.releaseProofPacket.v1",
        "valid": True,
        "status": "Source Green for Source Atlas release-input proof packet / Yellow release ceiling",
        "sourceAtlasReleaseInputsReady": True,
        "releaseReviewPacketReady": False,
        "releaseGreenClaimAllowed": False,
        "allowedClaims": [
            "source_atlas_release_proof_packet_green",
            "source_atlas_release_inputs_current",
            "release_overclaim_blocked",
        ],
        "blockedClaims": ["release_green", "app_store_readiness", "testflight_readiness", "literal_universal_coverage"],
        "missingExternalReleaseGateIDs": [
            "physical_device_proof",
            "independent_accessibility_proof",
            "independent_visual_review",
            "app_store_connect_validation",
            "testflight_validation",
            "privacy_legal_release_signoff",
            "owner_release_approval",
        ],
        "recordCounts": {
            "sourceValidationGates": 8,
            "sourceValidationGatesPassed": 8,
            "externalReleaseGates": 7,
            "externalReleaseArtifactsPresent": 0,
            "missingExternalReleaseArtifacts": 7,
            "privacyIssues": 0,
        },
        "privacyIssues": [],
        "issues": [],
    }


def _legal_packet() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.legalTermsApprovalPacket.v1",
        "status": "Green",
        "outsideLegalApprovalClaimed": False,
        "outsideLegalApprovalBoundary": "outside legal approval requires a current source-specific approval artifact",
    }


def _owner() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.r2OwnerApproval.v1",
        "valid": True,
        "status": "Source Green for scoped owner R2 write preflight approval",
        "approved": True,
        "outsideLegalApprovalClaimed": False,
        "literalUniversalCoverageClaimed": False,
    }


def _launch_floor_ledger() -> dict:
    target_statuses = [
        {"targetID": "public_reference_shards_1m", "status": "not_measurable_fail_closed"},
        {"targetID": "goal_domains_500", "status": "not_met"},
        {"targetID": "subdomains_5000", "status": "not_measurable_fail_closed"},
        {"targetID": "golden_intents_50000", "status": "not_measurable_fail_closed"},
        {"targetID": "source_needed_fallback_under_5_percent", "status": "not_measurable_fail_closed"},
        {"targetID": "continuous_missing_shard_expansion", "status": "not_measurable_fail_closed"},
    ]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorLedger.v1",
        "valid": True,
        "status": "Source Green for launch-floor ledger tooling / Launch-floor targets not met",
        "launchFloorMet": False,
        "launchFloorClaimAllowed": False,
        "targetStatuses": target_statuses,
        "blockedClaims": ["source_atlas_launch_floor_ready", "release_green", "literal_universal_coverage"],
        "privacyIssues": [],
        "overclaimIssues": [],
    }
