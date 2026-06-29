from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.coverage_readiness_gate import build_coverage_readiness_gate, build_coverage_readiness_gate_from_paths
from foundry.model import read_json


CREATED_AT = "2026-06-28T04:20:00Z"
SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = Path(__file__).resolve().parents[4]

FRONTIER_CONFIG = SOURCE_ATLAS_ROOT / "frontier" / "coverage-frontiers.json"
SOURCE_LANE_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "source-lane-registry.json"
CLAIM_REPORTS = [
    SOURCE_ATLAS_ROOT / "generated" / "claim-frontier" / "train-03-fixture" / "coverage-frontier-report.json",
    SOURCE_ATLAS_ROOT / "generated" / "claim-frontier" / "train-41-education-credential-fixture" / "coverage-frontier-report.json",
    SOURCE_ATLAS_ROOT / "generated" / "claim-frontier" / "train-40-civic-goldset" / "coverage-frontier-report.json",
]
DOMAIN_SCORECARDS = SOURCE_ATLAS_ROOT / "generated" / "broad-domain-discovery" / "train-07-fixture" / "domain-scorecards.json"
R2_REPORT = SOURCE_ATLAS_ROOT / "generated" / "r2-publisher" / "train-29-production-remote-r2" / "r2-publisher-report.json"
CIVIC_R2_REPORT = SOURCE_ATLAS_ROOT / "generated" / "r2-publisher" / "train-37-civic-production-remote-r2" / "r2-publisher-report.json"
CIVIC_GATEWAY_REPORT = REPO_ROOT / "docs" / "qa" / "source-atlas" / "r2" / "source-atlas-public-r2-worker-gateway-civic-readback-train-37.json"
NATIVE_REPORT = REPO_ROOT / "docs" / "qa" / "source-atlas" / "native" / "source-atlas-live-worker-gateway-dual-target-train-37.json"
LEGAL_GATE = REPO_ROOT / "docs" / "qa" / "source-atlas" / "legal" / "source-atlas-legal-release-claim-gate-train-35.json"


def test_coverage_readiness_gate_evaluates_all_configured_frontiers():
    gate = _build_gate()

    assert gate["valid"], gate["gateIssues"]
    assert gate["status"] == "Source Green for coverage readiness gate"
    assert gate["recordCounts"]["configuredFrontiers"] == _configured_frontier_count()
    assert gate["universalCoverageClaimAllowed"] is False
    assert "universal_coverage" in gate["blockedClaims"]

    occupation = _frontier(gate, "occupation_foundation")
    assert occupation["readinessStatus"] == "bounded_production_target_ready"
    assert occupation["packOutputAllowed"] is True
    assert occupation["productionR2ProofComplete"] is True
    assert occupation["nativeTransportProofComplete"] is True
    assert occupation["allowedClaimScopes"] == ["bounded_production_target"]


def test_candidate_only_frontiers_remain_below_pack_and_runtime_readiness():
    gate = _build_gate()
    candidate_frontiers = [
        item
        for item in gate["frontiers"]
        if item["configuredStatusCeiling"] == "candidate_only"
    ]

    if not candidate_frontiers:
        assert all(item["configuredStatusCeiling"] != "candidate_only" for item in gate["frontiers"])
        return

    assert all(item["packOutputAllowed"] is False for item in candidate_frontiers)
    assert all(item["nativeTransportProofComplete"] is False for item in candidate_frontiers)
    assert all(item["allowedClaimScopes"] == [] for item in candidate_frontiers)
    assert any(
        "no_registered_source_lanes" in item["blockedReasons"]
        for item in candidate_frontiers
        if item["sourceIDs"] == []
    )


def test_unpacked_claim_graph_frontier_does_not_become_production_ready():
    gate = _build_gate()
    civic = _frontier(gate, "public_civic_requirements")
    education = _frontier(gate, "education_credentialing")

    assert civic["readinessStatus"] == "claim_graph_ready"
    assert civic["packableClaimCount"] == 2
    assert civic["legalPostureComplete"] is True
    assert civic["provenanceComplete"] is True
    assert civic["goldSetComplete"] is True
    assert civic["goldSetStatus"] == "passed"
    assert civic["packOutputAllowed"] is False
    assert civic["nativeTransportProofComplete"] is True
    assert civic["allowedClaimScopes"] == ["frontier_claim_graph_ready"]
    assert "public_civic_requirements: pack output not production-approved" in gate["universalCoverageIssues"]

    assert education["readinessStatus"] == "claim_graph_ready"
    assert education["packableClaimCount"] == 8
    assert education["legalPostureComplete"] is True
    assert education["provenanceComplete"] is True
    assert education["claimClassCoverageComplete"] is True
    assert education["authorityCoverageComplete"] is True
    assert education["goldSetComplete"] is True
    assert education["goldSetStatus"] == "passed"
    assert education["packOutputAllowed"] is False
    assert education["allowedClaimScopes"] == ["frontier_claim_graph_ready"]
    assert "education_credentialing: pack output not production-approved" in gate["universalCoverageIssues"]


def test_civic_frontier_with_train37_transport_and_gold_set_reaches_bounded_target():
    gate = _build_gate_with_civic_r2()
    civic = _frontier(gate, "public_civic_requirements")

    assert civic["readinessStatus"] == "bounded_production_target_ready"
    assert civic["packableClaimCount"] == 2
    assert civic["packOutputAllowed"] is True
    assert civic["productionR2ProofComplete"] is True
    assert civic["gatewayTransportProofComplete"] is True
    assert civic["nativeTransportProofComplete"] is True
    assert civic["allowedClaimScopes"] == ["bounded_production_target"]
    assert civic["goldSetComplete"] is True
    assert civic["goldSetStatus"] == "passed"
    assert civic["blockedReasons"] == []
    assert "native_transport_proof_missing_for_frontier" not in civic["blockedReasons"]
    assert "production_r2_proof_missing_for_frontier" not in civic["blockedReasons"]
    assert "public_civic_requirements: pack output not production-approved" not in gate["universalCoverageIssues"]
    assert "universal_coverage" in gate["blockedClaims"]


def test_top_level_gateway_readback_report_schema_counts_as_gateway_proof():
    gate = build_coverage_readiness_gate(
        frontier_config=read_json(FRONTIER_CONFIG),
        source_lane_registry=read_json(SOURCE_LANE_REGISTRY),
        claim_frontier_reports=[read_json(path) for path in CLAIM_REPORTS],
        r2_report=read_json(R2_REPORT),
        gateway_readback_reports=[
            {
                "status": "Green",
                "valid": True,
                "packID": "source-atlas/v1/domain/occupation_foundation/2026-06-27T000000Z",
                "packSHA256": "a" * 64,
                "manifestSHA256": "b" * 64,
                "r2RequestPrivacyProof": "fixed public object-key GET/HEAD requests only",
                "noPrivateGraphEgressProof": "no goal, capture, schedule, proof, account, device, or graph context",
            }
        ],
        native_transport_report=read_json(NATIVE_REPORT),
        legal_release_claim_gate=read_json(LEGAL_GATE),
        created_at=CREATED_AT,
    )

    occupation = _frontier(gate, "occupation_foundation")
    assert occupation["readinessStatus"] == "bounded_production_target_ready"
    assert occupation["gatewayTransportProofComplete"] is True


def test_legacy_gateway_consistency_current_pack_id_counts_as_gateway_proof():
    gate = build_coverage_readiness_gate(
        frontier_config=read_json(FRONTIER_CONFIG),
        source_lane_registry=read_json(SOURCE_LANE_REGISTRY),
        claim_frontier_reports=[read_json(path) for path in CLAIM_REPORTS],
        r2_report=read_json(R2_REPORT),
        gateway_readback_reports=[
            {
                "status": "green_for_bounded_occupation_gateway_https_readback_yellow_overall_source_atlas",
                "pack_consistency": {
                    "currentPackID": "source-atlas/v1/domain/occupation_foundation/2026-06-27T000000Z",
                    "packIDConsistent": True,
                    "packHashConsistent": True,
                    "currentPointerHashConsistent": True,
                },
            }
        ],
        native_transport_report=read_json(NATIVE_REPORT),
        legal_release_claim_gate=read_json(LEGAL_GATE),
        created_at=CREATED_AT,
    )

    assert _frontier(gate, "occupation_foundation")["gatewayTransportProofComplete"] is True


def test_missing_r2_or_native_evidence_downgrades_bounded_production_target():
    gate = build_coverage_readiness_gate(
        frontier_config=read_json(FRONTIER_CONFIG),
        source_lane_registry=read_json(SOURCE_LANE_REGISTRY),
        claim_frontier_reports=[read_json(path) for path in CLAIM_REPORTS],
        domain_scorecards=read_json(DOMAIN_SCORECARDS),
        r2_report=None,
        native_transport_report=None,
        legal_release_claim_gate=read_json(LEGAL_GATE),
        created_at=CREATED_AT,
    )

    occupation = _frontier(gate, "occupation_foundation")
    assert occupation["readinessStatus"] == "claim_graph_ready"
    assert occupation["packOutputAllowed"] is False
    assert occupation["productionR2ProofComplete"] is False
    assert occupation["nativeTransportProofComplete"] is False
    assert "bounded_production_target" not in occupation["allowedClaimScopes"]
    assert "frontier_claim_graph_ready" in occupation["allowedClaimScopes"]


def test_private_context_in_evidence_artifact_is_rejected():
    native_report = copy.deepcopy(read_json(NATIVE_REPORT))
    native_report["goalText"] = "I need this packed into my private plan"

    gate = build_coverage_readiness_gate(
        frontier_config=read_json(FRONTIER_CONFIG),
        source_lane_registry=read_json(SOURCE_LANE_REGISTRY),
        claim_frontier_reports=[read_json(path) for path in CLAIM_REPORTS],
        domain_scorecards=read_json(DOMAIN_SCORECARDS),
        r2_report=read_json(R2_REPORT),
        native_transport_report=native_report,
        legal_release_claim_gate=read_json(LEGAL_GATE),
        created_at=CREATED_AT,
    )

    assert gate["status"] == "Red"
    assert gate["gateIssues"]


def _build_gate():
    return build_coverage_readiness_gate_from_paths(
        frontier_config_path=FRONTIER_CONFIG,
        source_lane_registry_path=SOURCE_LANE_REGISTRY,
        claim_frontier_report_paths=CLAIM_REPORTS,
        domain_scorecards_path=DOMAIN_SCORECARDS,
        r2_report_path=R2_REPORT,
        native_transport_report_path=NATIVE_REPORT,
        legal_release_claim_gate_path=LEGAL_GATE,
        created_at=CREATED_AT,
    )


def _configured_frontier_count() -> int:
    return len(read_json(FRONTIER_CONFIG)["frontiers"])


def _build_gate_with_civic_r2():
    return build_coverage_readiness_gate_from_paths(
        frontier_config_path=FRONTIER_CONFIG,
        source_lane_registry_path=SOURCE_LANE_REGISTRY,
        claim_frontier_report_paths=CLAIM_REPORTS,
        domain_scorecards_path=DOMAIN_SCORECARDS,
        r2_report_path=R2_REPORT,
        r2_report_paths=[CIVIC_R2_REPORT],
        gateway_readback_report_paths=[CIVIC_GATEWAY_REPORT],
        native_transport_report_path=NATIVE_REPORT,
        legal_release_claim_gate_path=LEGAL_GATE,
        created_at=CREATED_AT,
    )


def _frontier(gate: dict, frontier_id: str) -> dict:
    return next(item for item in gate["frontiers"] if item["frontierID"] == frontier_id)
