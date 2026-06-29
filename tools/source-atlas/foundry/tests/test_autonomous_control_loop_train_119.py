from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_control_loop import AutonomousControlLoopOptions, run_autonomous_control_loop  # noqa: E402
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-29T01:45:00Z"
DOMAINS = ("education_credentialing", "finance_public_reference")


def test_autonomous_control_loop_reconciles_production_proofs_into_run_hold_decisions(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "autonomous_control_loop_ready"
    assert result["recordCounts"]["configuredDomains"] == 2
    assert result["recordCounts"]["domainsReadyForMonitoring"] == 2
    assert result["recordCounts"]["automaticR2WritesAllowed"] == 0
    assert result["r2WriteDecision"]["decision"] == "preflight_ready_execute_still_required"
    assert result["r2WriteDecision"]["executeRequired"] is True
    assert result["r2WriteDecision"]["automaticWriteAllowed"] is False
    assert result["unknownDomainDecision"]["candidateOnly"] is True
    assert result["releaseDecision"]["releaseGreenAllowed"] is False
    assert result["outsideLegalDecision"]["outsideLegalApprovalAllowed"] is False
    assert result["universalCoverageDecision"]["literalUniversalCoverageAllowed"] is False
    assert "autonomous_control_loop_ready_for_configured_public_reference_domains" in result["allowedClaims"]
    assert "r2_write_preflight_ready_execute_still_required" in result["allowedClaims"]
    assert "literal_universal_coverage" in result["blockedClaims"]
    assert _check(result, "release_hold_enforced")


def test_autonomous_control_loop_blocks_when_future_r2_preflight_is_not_ready(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    sweep = read_json(paths["sweep"])
    sweep["allowedClaims"].remove("future_remote_r2_write_preflight_ready")
    sweep["futureRemoteWritePreflight"]["readyForNewRemoteWrite"] = False
    sweep["futureRemoteWritePreflight"]["blockedReasons"] = ["new remote write preflight blocked in fixture"]
    write_json(paths["sweep"], sweep)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _check(result, "future_r2_write_preflight_ready")
    assert not _check(result, "production_sweep_has_required_claims")
    assert "r2_write_preflight_ready_execute_still_required" not in result["allowedClaims"]
    assert any("new remote write preflight blocked" in issue for issue in result["issues"])


def test_autonomous_control_loop_blocks_if_gauntlet_generates_final_outputs(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    gauntlet = read_json(paths["gauntlet"])
    gauntlet["recordCounts"]["finalOutputsGenerated"] = 1
    write_json(paths["gauntlet"], gauntlet)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _check(result, "goal_domain_gauntlet_emits_no_final_outputs")
    assert any("goal-domain gauntlet generated final outputs" in issue for issue in result["issues"])


def test_autonomous_control_loop_requires_finish_line_release_legal_universal_holds(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    finish_line = read_json(paths["finish_line"])
    finish_line["blockedClaims"] = ["outside_legal_approval"]
    write_json(paths["finish_line"], finish_line)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _check(result, "finish_line_claims_and_blocks_enforced")
    assert not _check(result, "release_hold_enforced")
    assert not _check(result, "literal_universal_hold_enforced")
    assert any("release_green must remain blocked" in issue for issue in result["issues"])


def _run(tmp_path: Path, paths: dict[str, Path]) -> dict:
    return run_autonomous_control_loop(
        AutonomousControlLoopOptions(
            production_sweep_path=paths["sweep"],
            goal_domain_gauntlet_path=paths["gauntlet"],
            owner_approval_path=paths["approval"],
            native_runtime_report_path=paths["native"],
            production_finish_line_gate_path=paths["finish_line"],
            arbitrary_domain_gate_path=paths["arbitrary_gate"],
            output_root=tmp_path / "control-loop",
            created_at=CREATED_AT,
            bucket="ambitions-source-atlas-prod",
        )
    )


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {
        "sweep": root / "production-sweep.json",
        "gauntlet": root / "goal-domain-gauntlet.json",
        "approval": root / "owner-approval.json",
        "native": root / "native-runtime.json",
        "finish_line": root / "finish-line.json",
        "arbitrary_gate": root / "arbitrary-domain-gate.json",
    }
    write_json(paths["sweep"], _sweep())
    write_json(paths["gauntlet"], _gauntlet())
    write_json(paths["approval"], _approval())
    write_json(paths["native"], _native_runtime())
    write_json(paths["finish_line"], _finish_line())
    write_json(paths["arbitrary_gate"], _arbitrary_gate())
    return paths


def _sweep() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionSweep.v1",
        "valid": True,
        "allowedClaims": [
            "current_configured_frontier_production_sweep",
            "current_remote_r2_upload_readback_reconciled",
            "governed_arbitrary_public_reference_domain_routing_reconciled",
            "future_remote_r2_write_preflight_ready",
            "representative_goal_domain_gauntlet_reconciled",
        ],
        "futureRemoteWritePreflight": {
            "readyForNewRemoteWrite": True,
            "blockedReasons": [],
            "credentialGroupsPresent": ["cloudflare_control", "cloudflare_r2_access_pair"],
            "bucketConfigured": True,
            "environment": "production",
            "currentProductionBucketsObserved": ["ambitions-source-atlas-prod"],
        },
        "domains": [_sweep_domain(domain) for domain in DOMAINS],
        "issues": [],
    }


def _sweep_domain(domain: str) -> dict:
    version = "20260628T000000Z"
    return {
        "domainID": domain,
        "ready": True,
        "packableClaimCount": 3,
        "sourceIDs": [f"{domain}.official_source"],
        "pack": {
            "valid": True,
            "packID": f"source-atlas/v1/domain/{domain}/{version}",
            "packVersion": version,
        },
        "r2": {
            "valid": True,
            "remoteUploadReadbackReady": True,
            "packID": f"source-atlas/v1/domain/{domain}/{version}",
            "packVersion": version,
            "manifestKey": f"source-atlas/v1/production/stable/{domain}/{version}/manifest.json",
        },
        "issues": [],
    }


def _gauntlet() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainGauntlet.v1",
        "valid": True,
        "allowedClaims": [
            "representative_goal_domain_gauntlet_green",
            "configured_frontier_goal_domain_runtime_routing",
            "unknown_public_reference_domains_candidate_only",
        ],
        "recordCounts": {
            "configuredCasesBlocked": 0,
            "unknownCasesBlocked": 0,
            "finalOutputsGenerated": 0,
        },
        "issues": [],
    }


def _approval() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionR2OwnerApproval.v1",
        "approvalID": "source-atlas/r2-owner-approval/test",
        "approvalStatus": "approved_for_future_bounded_configured_public_reference_r2_write_preflight",
        "approvalType": "bounded_configured_public_reference_production_r2_write_preflight",
        "approved": True,
        "environment": "production",
        "channel": "stable",
        "bucket": "ambitions-source-atlas-prod",
        "outsideLegalApprovalClaimed": False,
        "releaseGreenClaimed": False,
        "literalUniversalCoverageClaimed": False,
        "requiredExecutionGates": [
            "budget policy",
            "current pointer after readback only",
            "execute flag",
            "legal/terms approval packet",
            "non-private payload scan",
            "owner approval artifact",
            "public object keys",
            "rollback/LKG/revocation plan",
            "upload/readback SHA-256 verification",
        ],
        "domainScopes": [_approval_scope(domain) for domain in DOMAINS],
        "nonClaims": ["not outside legal approval", "not Release Green", "not literal universal coverage"],
    }


def _approval_scope(domain: str) -> dict:
    prefix = f"source-atlas/v1/production/stable/{domain}/"
    return {
        "domainID": domain,
        "environment": "production",
        "channel": "stable",
        "approvedObjectKeyPrefix": prefix,
        "approvedCurrentPointerKey": f"{prefix}current.json",
        "approvedLKGPointerKey": f"{prefix}lkg.json",
        "approvedRevocationKey": f"{prefix}revocations.json",
        "sourceIDs": [f"{domain}.official_source"],
    }


def _native_runtime() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.nativeRuntimeCurrentProof.v1",
        "valid": True,
        "allowedClaims": ["bounded_configured_runtime_green"],
        "recordCounts": {
            "domainsBlocked": 0,
            "domainsRuntimeReady": 2,
        },
        "domainProofs": [{"domainID": domain, "runtimeReady": True} for domain in DOMAINS],
        "issues": [],
    }


def _finish_line() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionFinishLineGate.v1",
        "valid": True,
        "allowedClaims": [
            "bounded_configured_production_target",
            "internal_terms_review",
            "production_r2_write_readback",
            "bounded_live_transport",
            "bounded_configured_runtime_green",
            "gateway_native_runtime_recertification",
        ],
        "blockedClaims": ["release_green", "universal_coverage", "outside_legal_approval"],
        "issues": [],
    }


def _arbitrary_gate() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.arbitraryDomainHandlingGate.v1",
        "valid": True,
        "recordCounts": {
            "candidateClaims": 0,
            "candidateR2PublishOperations": 0,
            "candidateNativeActivationOperations": 0,
            "candidateProductionWrites": 0,
        },
        "issues": [],
    }


def _check(result: dict, name: str) -> bool:
    return any(check["name"] == name and check["passed"] for check in result["checks"])
