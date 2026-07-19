from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_registry_activation_chain import (  # noqa: E402
    AutonomousRegistryActivationChainOptions,
    run_autonomous_registry_activation_chain,
)
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-28T22:20:00Z"


def test_autonomous_registry_activation_chain_rehearses_candidate_domain_and_blocks_active_apply(tmp_path: Path):
    paths = _write_chain_inputs(tmp_path)

    result = run_autonomous_registry_activation_chain(
        AutonomousRegistryActivationChainOptions(
            expansion_chain_report_path=paths["expansion_report"],
            output_root=tmp_path / "activation-chain",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for autonomous registry activation readiness chain"
    assert result["recordCounts"]["reviewPacketTemplates"] == 4
    assert result["recordCounts"]["completionEvidenceRecords"] == 0
    assert result["recordCounts"]["completedReviewPackets"] == 0
    assert result["recordCounts"]["blockedReviewCompletions"] == 4
    assert result["recordCounts"]["plannedRegistryMutations"] == 0
    assert result["recordCounts"]["blockedRegistryMutations"] == 1
    assert result["recordCounts"]["rehearsalPlannedRegistryMutations"] == 1
    assert result["recordCounts"]["rehearsalAppliedTempRegistryMutations"] == 1
    assert result["recordCounts"]["activeRegistryApplyAllowed"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert _check(result, "rehearsal_blocks_active_registry_apply")
    assert _check(result, "chain_emits_no_claims_packs_r2_or_native_activation")

    gate_summary = result["stageSummaries"]["rehearsalActiveApplyGate"]
    assert gate_summary["activeRegistryApplyAllowed"] is False
    assert gate_summary["activeRegistryApplyDecision"] == "blocked_fixture_or_rehearsal_evidence"
    assert read_json(paths["source"])["source_lanes"] == []


def test_autonomous_registry_activation_chain_accepts_production_ready_route_without_review_templates(tmp_path: Path):
    paths = _write_production_ready_chain_inputs(tmp_path)

    result = run_autonomous_registry_activation_chain(
        AutonomousRegistryActivationChainOptions(
            expansion_chain_report_path=paths["expansion_report"],
            output_root=tmp_path / "activation-chain",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["routes"] == 1
    assert result["recordCounts"]["productionReadyRoutes"] == 1
    assert result["recordCounts"]["candidateRoutes"] == 0
    assert result["recordCounts"]["registryActivationNotRequiredRoutes"] == 1
    assert result["recordCounts"]["reviewPacketTemplates"] == 0
    assert result["recordCounts"]["completionEvidenceRecords"] == 0
    assert result["recordCounts"]["completedReviewPackets"] == 0
    assert result["recordCounts"]["blockedReviewCompletions"] == 0
    assert result["recordCounts"]["plannedRegistryMutations"] == 0
    assert result["recordCounts"]["rehearsalPlannedRegistryMutations"] == 0
    assert result["recordCounts"]["rehearsalAppliedTempRegistryMutations"] == 0
    assert result["recordCounts"]["activeRegistryApplyAllowed"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert _check(result, "review_packet_templates_found_or_not_required")
    assert _check(result, "registry_activation_stage_matches_expansion_path")
    assert _check(result, "chain_emits_no_claims_packs_r2_or_native_activation")
    assert "registryActivationNotRequired" in result["stageSummaries"]
    assert "reviewCompletionIntake" not in result["stageSummaries"]

    not_required = read_json(Path(result["outputPaths"]["registryActivationNotRequired"]))
    assert not_required["kind"] == "ambitions.sourceAtlas.autonomousRegistryActivationNotRequired.v1"
    assert not_required["valid"] is True
    assert not_required["recordCounts"]["registryActivationNotRequiredRoutes"] == 1
    assert not_required["recordCounts"]["activeRegistryMutations"] == 0


def test_autonomous_registry_activation_chain_rejects_private_expansion_report_before_registry_stages(tmp_path: Path):
    paths = _write_chain_inputs(tmp_path)
    expansion_report = read_json(paths["expansion_report"])
    expansion_report["goalText"] = "my schedule for this week"
    write_json(paths["expansion_report"], expansion_report)

    result = run_autonomous_registry_activation_chain(
        AutonomousRegistryActivationChainOptions(
            expansion_chain_report_path=paths["expansion_report"],
            output_root=tmp_path / "activation-chain",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert result["stages"] == {}
    assert result["recordCounts"]["reviewPacketTemplates"] == 4
    assert result["recordCounts"]["rehearsalPlannedRegistryMutations"] == 0
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_autonomous_registry_activation_chain_requires_review_templates(tmp_path: Path):
    paths = _write_chain_inputs(tmp_path)
    expansion_report = read_json(paths["expansion_report"])
    expansion_report["outputPaths"] = {}
    write_json(paths["expansion_report"], expansion_report)

    result = run_autonomous_registry_activation_chain(
        AutonomousRegistryActivationChainOptions(
            expansion_chain_report_path=paths["expansion_report"],
            output_root=tmp_path / "activation-chain",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert "expansion chain report does not expose review packet templates" in result["issues"]
    assert result["recordCounts"]["reviewPacketTemplates"] == 0
    assert result["stages"] == {}


def _write_chain_inputs(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "inputs"
    root.mkdir(parents=True, exist_ok=True)
    review_templates = root / "review-packet-templates.json"
    expansion_report = root / "autonomous-domain-expansion-chain-report.json"
    registries = _write_empty_registries(root)
    write_json(review_templates, _review_packet_templates())
    write_json(
        expansion_report,
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.autonomousDomainExpansionChain.v1",
            "versionID": "source-atlas-autonomous-domain-expansion-chain-train-107",
            "createdAt": CREATED_AT,
            "status": "Source Green for autonomous candidate-domain expansion chain",
            "valid": True,
            "recordCounts": {
                "candidateInputs": 1,
                "reviewPackets": 4,
                "activeRegistryMutations": 0,
                "claims": 0,
                "r2PublishOperations": 0,
                "nativeActivationOperations": 0,
            },
            "outputPaths": {"reviewPacketTemplates": str(review_templates)},
            "nonClaims": ["not source authority", "not active registry mutation"],
        },
    )
    return {"review_templates": review_templates, "expansion_report": expansion_report, **registries}


def _write_production_ready_chain_inputs(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "inputs"
    root.mkdir(parents=True, exist_ok=True)
    registries = _write_empty_registries(root)
    review_not_required = root / "review-not-required-manifest.json"
    expansion_report = root / "autonomous-domain-expansion-chain-report.json"
    write_json(
        review_not_required,
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.goalDomainReviewPacketsNotRequired.v1",
            "versionID": "source-atlas-autonomous-domain-expansion-chain-train-107",
            "createdAt": CREATED_AT,
            "status": "Source Green for review-not-required production-ready route evidence",
            "valid": True,
            "recordCounts": {
                "inputExecutionRecords": 4,
                "selectedBlockedReviewRecords": 0,
                "reviewPackets": 0,
                "completedReviewPackets": 0,
                "approvalArtifactsEmitted": 0,
                "activeRegistryMutations": 0,
                "claims": 0,
                "r2PublishOperations": 0,
                "nativeActivationOperations": 0,
            },
            "nonClaims": ["review-not-required marker only", "not registry mutation"],
        },
    )
    write_json(
        expansion_report,
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.autonomousDomainExpansionChain.v1",
            "versionID": "source-atlas-autonomous-domain-expansion-chain-train-107",
            "createdAt": CREATED_AT,
            "status": "Source Green for autonomous domain expansion chain",
            "valid": True,
            "recordCounts": {
                "candidateInputs": 1,
                "routes": 1,
                "candidateRoutes": 0,
                "productionReadyRoutes": 1,
                "blockedReviewRequired": 0,
                "reviewPackets": 0,
                "activeRegistryMutations": 0,
                "claims": 0,
                "r2PublishOperations": 0,
                "nativeActivationOperations": 0,
            },
            "outputPaths": {"reviewPackets": str(review_not_required), "reviewPacketTemplates": ""},
            "nonClaims": ["not registry mutation", "not R2 publish", "not native activation"],
        },
    )
    return {"review_not_required": review_not_required, "expansion_report": expansion_report, **registries}


def _review_packet_templates() -> dict:
    lanes = [
        (
            "direct_source_authority_resolution",
            "direct_source_resolution",
            [
                "publisher_identity",
                "source_directness",
                "publisher_authority_class",
                "jurisdiction",
                "official_locator",
                "authority_limitations",
                "review_decision",
                "review_evidence_path",
            ],
        ),
        (
            "source_lane_governance",
            "source_lane_review",
            [
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
        ),
        (
            "legal_terms_review",
            "legal_terms_review",
            [
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
        ),
        (
            "api_governance_review",
            "api_governance_review",
            [
                "api_policy_id",
                "api_mode",
                "key_required",
                "missing_key_behavior",
                "rate_limit_per_second",
                "rate_limit_per_minute",
                "daily_budget_limit",
                "monthly_budget_limit",
                "max_records_per_run",
                "max_pages_per_run",
                "timeout_seconds",
                "retry_policy",
                "backoff_policy",
                "circuit_breaker_policy",
                "live_flag_required",
                "execute_flag_required",
                "secret_redaction_required",
                "high_volume_review_required",
                "budget_owner",
                "review_evidence_path",
            ],
        ),
    ]
    return {
        "kind": "ambitions.sourceAtlas.goalDomainReviewPacketTemplates.v1",
        "createdAt": CREATED_AT,
        "reviewPackets": [
            {
                "packetID": f"source_atlas_goal_domain_review_packet.{index}",
                "orderID": f"source_atlas_domain_work_order.{index}",
                "requestID": "frontier_intake_proposal.public_benefits_reference",
                "requestedDomain": "public_benefits_reference",
                "matchedDomainID": None,
                "stage": stage,
                "stageIndex": index,
                "reviewLane": review_lane,
                "requiredReviewerFields": required_fields,
                "candidateSourceIDs": ["candidate_source.public_benefits_reference"],
                "completionStatus": "blocked_review_required",
                "manualReviewRequired": True,
                "approvalArtifactEmitted": False,
                "registryMutationAllowed": False,
                "claimOutputAllowed": False,
                "packOutputAllowed": False,
                "r2PublishAllowed": False,
                "nativeActivationAllowed": False,
                "nonClaims": ["review packet template only", "not source authority", "not legal approval"],
            }
            for index, (review_lane, stage, required_fields) in enumerate(lanes, start=1)
        ],
        "nonClaims": ["template collection only", "not completed review"],
    }


def _write_empty_registries(root: Path) -> dict[str, Path]:
    source = root / "source-lane-registry.json"
    legal = root / "legal-terms-registry.json"
    api = root / "api-governance-registry.json"
    write_json(
        source,
        {
            "kind": "ambitions.sourceAtlas.sourceLaneRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "source_lanes": [],
        },
    )
    write_json(
        legal,
        {
            "kind": "ambitions.sourceAtlas.legalTermsRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "licenses": [],
        },
    )
    write_json(
        api,
        {
            "kind": "ambitions.sourceAtlas.apiGovernanceRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "api_policies": [],
        },
    )
    return {"source": source, "legal": legal, "api": api}


def _check(result: dict[str, object], name: str) -> bool:
    return bool(next(check for check in result["checks"] if check["name"] == name)["passed"])
