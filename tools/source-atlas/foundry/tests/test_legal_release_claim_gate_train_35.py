from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.legal_release_claim_gate import build_legal_release_claim_gate
from foundry.terms_approval_packet import build_terms_approval_packet
from foundry.terms_registry import terms_entry


CREATED_AT = "2026-06-28T00:00:00Z"


def test_claim_gate_allows_bounded_internal_terms_review_only():
    packet = build_terms_approval_packet(
        [terms_entry("onet.database"), terms_entry("bls.public.data.api")],
        created_at=CREATED_AT,
    )

    gate = build_legal_release_claim_gate(
        legal_packet=packet,
        source_ids=["onet.database", "bls.public.data.api"],
        requested_claims=[
            "source_atlas_terms_gate_green",
            "unqualified_legal_approval",
            "outside_legal_approval",
        ],
        created_at=CREATED_AT,
    )

    assert gate["status"] == "Source Green for release-claim gate"
    assert "source_atlas_terms_gate_green" in gate["allowedClaims"]
    assert "unqualified_legal_approval" in gate["blockedClaims"]
    assert "outside_legal_approval" in gate["blockedClaims"]
    assert any(
        "unqualified legal approval requires" in issue
        for item in gate["claimEvaluations"]
        if item["claimID"] == "unqualified_legal_approval"
        for issue in item["issues"]
    )


def test_outside_legal_claim_requires_source_specific_artifacts():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)
    packet["outsideLegalApprovalClaimed"] = True
    packet["sourceApprovals"][0]["outsideLegalStatus"] = "approved"

    gate = build_legal_release_claim_gate(
        legal_packet=packet,
        source_ids=["onet.database"],
        requested_claims=["outside_legal_approval"],
        created_at=CREATED_AT,
    )

    claim = gate["claimEvaluations"][0]
    assert not claim["allowed"]
    assert any("outside legal approval is not proven" in issue for issue in claim["issues"])


def test_outside_legal_claim_can_be_allowed_when_artifacts_are_source_specific():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)
    packet["outsideLegalApprovalClaimed"] = True
    packet["sourceApprovals"][0]["outsideLegalStatus"] = "approved"
    packet["sourceApprovals"][0]["outsideLegalApprovalArtifact"] = "docs/legal/onet-approval.pdf"
    packet["sourceApprovals"][0]["outsideLegalApprovalArtifactHash"] = "a" * 64

    gate = build_legal_release_claim_gate(
        legal_packet=packet,
        source_ids=["onet.database"],
        requested_claims=["outside_legal_approval"],
        created_at=CREATED_AT,
    )

    assert gate["allowedClaims"] == ["outside_legal_approval"]
    assert gate["blockedClaims"] == []


def test_production_r2_write_claim_requires_remote_execute_readback_report():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)
    dry_run_report = {
        "kind": "ambitions.sourceAtlas.r2PackPublisherReport.v1",
        "environment": "production",
        "channel": "stable",
        "mode": "dry_run",
        "executeRequested": False,
        "productionR2Uploaded": False,
        "realR2CredentialsUsed": False,
        "valid": True,
        "operation": {"success": True, "remoteR2": False},
        "checks": [],
    }

    blocked = build_legal_release_claim_gate(
        legal_packet=packet,
        source_ids=["onet.database"],
        r2_report=dry_run_report,
        requested_claims=["bounded_production_r2_write"],
        created_at=CREATED_AT,
    )
    assert blocked["blockedClaims"] == ["bounded_production_r2_write"]

    remote_report = copy.deepcopy(dry_run_report)
    remote_report.update(
        {
            "mode": "remote_r2",
            "executeRequested": True,
            "productionR2Uploaded": True,
            "realR2CredentialsUsed": True,
        }
    )
    remote_report["operation"] = {"success": True, "remoteR2": True}
    remote_report["checks"] = [
        {"name": "remote_r2_public_reference_transport_only", "passed": True},
        {"name": "upload_readback_checksums", "passed": True},
        {"name": "current_pointer_after_readback_only", "passed": True},
    ]

    allowed = build_legal_release_claim_gate(
        legal_packet=packet,
        source_ids=["onet.database"],
        r2_report=remote_report,
        requested_claims=["bounded_production_r2_write"],
        created_at=CREATED_AT,
    )
    assert allowed["allowedClaims"] == ["bounded_production_r2_write"]


def test_live_transport_claim_requires_native_gateway_runtime_proof():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)
    native_report = {
        "status": "green_for_bounded_worker_gateway_live_transport_yellow_overall_source_atlas",
        "product_law_preserved": True,
        "native_runtime_proof": {
            "default_app_container_wired": True,
            "live_urlsession_test": "SourceAtlasPublicPackRemoteTransportTests/live",
            "live_lifecycle_test": "SourceAtlasPublicPackLifecycleRefreshServiceTests/live",
        },
        "validation_run": [{"status": "passed"}, {"status": "passed"}],
    }

    gate = build_legal_release_claim_gate(
        legal_packet=packet,
        source_ids=["onet.database"],
        native_transport_report=native_report,
        requested_claims=["bounded_live_native_transport"],
        created_at=CREATED_AT,
    )

    assert gate["allowedClaims"] == ["bounded_live_native_transport"]


def test_live_transport_claim_accepts_current_native_runtime_current_proof_shape():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)
    native_report = {
        "kind": "ambitions.sourceAtlas.nativeRuntimeCurrentProof.v1",
        "valid": True,
        "productLawPreserved": True,
        "configuredFrontiers": ["occupation_foundation", "volunteering_public_reference"],
        "recordCounts": {
            "configuredDomains": 2,
            "domainsRuntimeReady": 2,
            "domainsBlocked": 0,
            "xcodeFailed": 0,
            "xcodeSkipped": 0,
        },
        "proofSummary": {
            "r2RequestPrivacyProof": "public request shape only",
            "noPrivateGraphEgressProof": "private graph fields absent",
        },
        "xcodeBuildMCP": {
            "result": "SUCCEEDED",
            "testRunnerEnv": {
                "SOURCE_ATLAS_LIVE_R2_ENDPOINT": "https://ambitions-source-atlas-public-gateway.example.test"
            },
        },
    }

    gate = build_legal_release_claim_gate(
        legal_packet=packet,
        source_ids=["onet.database"],
        native_transport_report=native_report,
        requested_claims=["bounded_live_native_transport"],
        created_at=CREATED_AT,
    )

    assert gate["allowedClaims"] == ["bounded_live_native_transport"]


def test_runtime_release_and_universal_claims_remain_blocked_without_umbrella_proof():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)

    gate = build_legal_release_claim_gate(
        legal_packet=packet,
        source_ids=["onet.database"],
        requested_claims=["source_atlas_runtime_green", "release_green", "universal_coverage"],
        created_at=CREATED_AT,
    )

    assert gate["allowedClaims"] == []
    assert gate["blockedClaims"] == [
        "source_atlas_runtime_green",
        "release_green",
        "universal_coverage",
    ]


def test_private_context_in_evidence_artifact_is_rejected():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)
    native_report = {
        "status": "green_for_bounded_worker_gateway_live_transport_yellow_overall_source_atlas",
        "goalText": "I need a private plan packed",
    }

    gate = build_legal_release_claim_gate(
        legal_packet=packet,
        source_ids=["onet.database"],
        native_transport_report=native_report,
        requested_claims=["bounded_live_native_transport"],
        created_at=CREATED_AT,
    )

    assert gate["status"] == "Red"
    assert gate["gateIssues"]
