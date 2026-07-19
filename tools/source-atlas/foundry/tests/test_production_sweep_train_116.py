from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import read_json, write_json  # noqa: E402
from foundry.production_sweep import ProductionSweepOptions, run_production_sweep  # noqa: E402


CREATED_AT = "2026-06-29T00:20:00Z"
VERSION = "20260628T000000Z"


def test_production_sweep_reconciles_current_production_without_requiring_future_write(tmp_path: Path):
    paths = _fixture_paths(tmp_path, with_bucket=False, with_approval=False, with_legal=False)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "current_configured_production_operational_sweep_green"
    assert result["recordCounts"]["configuredDomains"] == 2
    assert result["recordCounts"]["remoteR2UploadsReconciled"] == 2
    assert result["recordCounts"]["newRemoteWriteBlockedReasons"] == 3
    assert result["futureRemoteWritePreflight"]["credentialsAvailable"] is True
    assert result["futureRemoteWritePreflight"]["bucketConfigured"] is False
    assert result["futureRemoteWritePreflight"]["readyForNewRemoteWrite"] is False
    assert "current_remote_r2_upload_readback_reconciled" in result["allowedClaims"]
    assert "future_remote_r2_write_preflight_ready" in result["blockedClaims"]
    assert _check(result, "remote_r2_upload_readback_reconciled_for_all_domains")
    assert _report_does_not_expose_secret_names(Path(result["outputPaths"]["report"]))


def test_production_sweep_can_require_future_remote_write_preflight(tmp_path: Path):
    paths = _fixture_paths(tmp_path, with_bucket=False, with_approval=False, with_legal=False)

    result = _run(tmp_path, paths, require_new_write_ready=True)

    assert not result["valid"]
    assert not _check(result, "future_remote_write_ready_when_required")
    assert any("new remote writes require --r2-bucket" in issue for issue in result["issues"])


def test_production_sweep_allows_future_remote_write_preflight_with_valid_artifacts(tmp_path: Path, monkeypatch):
    monkeypatch.setattr("foundry.production_sweep.shutil.which", lambda name: "/usr/local/bin/wrangler" if name == "wrangler" else None)
    paths = _fixture_paths(tmp_path, with_bucket=True, with_approval=True, with_legal=True)

    result = _run(tmp_path, paths, require_new_write_ready=True)

    assert result["valid"], result["issues"]
    assert result["futureRemoteWritePreflight"]["readyForNewRemoteWrite"] is True
    assert result["futureRemoteWritePreflight"]["approvalArtifactValidation"]["valid"] is True
    assert "future_remote_r2_write_preflight_ready" in result["allowedClaims"]
    assert "future_remote_r2_write_preflight_ready" not in result["blockedClaims"]


def test_production_sweep_reconciles_supplied_goal_domain_gauntlet(tmp_path: Path, monkeypatch):
    monkeypatch.setattr("foundry.production_sweep.shutil.which", lambda name: "/usr/local/bin/wrangler" if name == "wrangler" else None)
    paths = _fixture_paths(tmp_path, with_bucket=True, with_approval=True, with_legal=True)
    paths["gauntlet"] = paths["ledger"].parent / "goal-domain-gauntlet.json"
    write_json(paths["gauntlet"], _gauntlet())

    result = _run(tmp_path, paths, require_new_write_ready=True)

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["goalDomainGauntletValid"] is True
    assert result["recordCounts"]["goalDomainGauntletCases"] == 2
    assert "representative_goal_domain_gauntlet_reconciled" in result["allowedClaims"]


def test_production_sweep_blocks_malformed_owner_approval_artifact(tmp_path: Path, monkeypatch):
    monkeypatch.setattr("foundry.production_sweep.shutil.which", lambda name: "/usr/local/bin/wrangler" if name == "wrangler" else None)
    paths = _fixture_paths(tmp_path, with_bucket=True, with_approval=True, with_legal=True)
    write_json(paths["approval"], {"approved": True, "artifactClass": "owner_stable_publish_approval"})

    result = _run(tmp_path, paths, require_new_write_ready=True)

    assert not result["valid"]
    assert result["futureRemoteWritePreflight"]["approvalArtifactValidation"]["valid"] is False
    assert any("valid owner approval artifact" in issue for issue in result["issues"])


def test_production_sweep_blocks_when_r2_report_loses_upload_readback(tmp_path: Path):
    paths = _fixture_paths(tmp_path, with_bucket=True, with_approval=True, with_legal=True)
    r2 = read_json(paths["r2_education"])
    r2["productionR2Uploaded"] = False
    r2["operation"]["success"] = False
    write_json(paths["r2_education"], r2)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert result["recordCounts"]["remoteR2UploadsReconciled"] == 1
    assert not _check(result, "remote_r2_upload_readback_reconciled_for_all_domains")
    assert any("education_credentialing: production R2 upload is not true" in issue for issue in result["issues"])


def _run(tmp_path: Path, paths: dict[str, Path], *, require_new_write_ready: bool = False) -> dict:
    return run_production_sweep(
        ProductionSweepOptions(
            production_target_ledger_path=paths["ledger"],
            production_finish_line_gate_path=paths["finish_line"],
            arbitrary_domain_gate_path=paths["arbitrary_gate"],
            goal_domain_gauntlet_path=paths.get("gauntlet"),
            output_root=tmp_path / "production-sweep",
            created_at=CREATED_AT,
            env_file_paths=(paths["env"],),
            approval_artifact_path=paths.get("approval"),
            legal_approval_packet_path=paths.get("legal"),
            require_new_remote_write_ready=require_new_write_ready,
        )
    )


def _fixture_paths(tmp_path: Path, *, with_bucket: bool, with_approval: bool, with_legal: bool) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {
        "ledger": root / "production-target-ledger.json",
        "finish_line": root / "production-finish-line.json",
        "arbitrary_gate": root / "arbitrary-domain-gate.json",
        "pack_education": root / "pack-education.json",
        "pack_finance": root / "pack-finance.json",
        "r2_education": root / "r2-education.json",
        "r2_finance": root / "r2-finance.json",
        "env": root / ".env",
    }
    if with_approval:
        paths["approval"] = root / "approval.json"
        write_json(paths["approval"], _approval())
    if with_legal:
        paths["legal"] = root / "legal.json"
        write_json(paths["legal"], {"valid": True, "artifactClass": "internal_terms_approval"})
    paths["env"].parent.mkdir(parents=True, exist_ok=True)
    env_lines = [
        "CLOUDFLARE_API_TOKEN=test-control-token",
        "CLOUDFLARE_R2_ACCESS_KEY_ID=test-access-id",
        "CLOUDFLARE_R2_SECRET_ACCESS_KEY=test-access-secret",
    ]
    if with_bucket:
        env_lines.append("SOURCE_ATLAS_R2_PRODUCTION_BUCKET=ambitions-source-atlas-prod")
    paths["env"].write_text("\n".join(env_lines) + "\n", encoding="utf-8")
    write_json(paths["pack_education"], _pack("education_credentialing"))
    write_json(paths["pack_finance"], _pack("finance_public_reference"))
    write_json(paths["r2_education"], _r2("education_credentialing"))
    write_json(paths["r2_finance"], _r2("finance_public_reference"))
    write_json(paths["ledger"], _ledger(paths))
    write_json(paths["finish_line"], _finish_line())
    write_json(paths["arbitrary_gate"], _arbitrary_gate())
    return paths


def _ledger(paths: dict[str, Path]) -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "domains": [
            _ledger_domain("education_credentialing", paths["pack_education"], paths["r2_education"], claim_count=8),
            _ledger_domain("finance_public_reference", paths["pack_finance"], paths["r2_finance"], claim_count=4),
        ],
    }


def _ledger_domain(domain: str, pack_path: Path, r2_path: Path, *, claim_count: int) -> dict:
    return {
        "domainID": domain,
        "readinessStatus": "bounded_production_target_ready",
        "frontierConfigured": True,
        "claimGraphProofComplete": True,
        "packProductionProofComplete": True,
        "r2ProductionProofComplete": True,
        "gatewayProofComplete": True,
        "nativeRegistryProofComplete": True,
        "nativeRuntimeBoundaryProofComplete": True,
        "nativeUsabilityProofComplete": True,
        "packableClaimCount": claim_count,
        "sourceIDs": [f"{domain}.official_source"],
        "packProductionPath": str(pack_path),
        "r2PublisherPath": str(r2_path),
        "blockedReasons": [],
    }


def _pack(domain: str) -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.packProductionManifest.v1",
        "valid": True,
        "environment": "production",
        "channel": "stable",
        "domain": domain,
        "packID": f"source-atlas/v1/domain/{domain}/{VERSION}",
        "packVersion": VERSION,
        "recordCounts": {"claims": 3, "sources": 1},
        "nonPrivateScan": {"passed": True, "issues": []},
        "checks": [{"name": name, "passed": True, "issues": []} for name in _pack_checks()],
    }


def _r2(domain: str) -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PackPublisherReport.v1",
        "valid": True,
        "environment": "production",
        "channel": "stable",
        "mode": "remote_r2",
        "executeRequested": True,
        "productionR2Uploaded": True,
        "realR2CredentialsUsed": True,
        "packID": f"source-atlas/v1/domain/{domain}/{VERSION}",
        "packVersion": VERSION,
        "objectCount": 13,
        "operation": {
            "success": True,
            "executed": True,
            "bucket": "ambitions-source-atlas-prod",
            "currentPointer": {"key": f"source-atlas/v1/production/stable/{domain}/current.json"},
        },
        "currentPointer": {
            "publicReferenceOnly": True,
            "manifestKey": f"source-atlas/v1/production/stable/{domain}/{VERSION}/manifest.json",
            "lastKnownGoodKey": f"source-atlas/v1/production/stable/{domain}/lkg.json",
            "revocationManifestKey": f"source-atlas/v1/production/stable/{domain}/revocations.json",
        },
        "checks": [{"name": name, "passed": True, "issues": []} for name in _r2_checks()],
    }


def _approval() -> dict:
    required_gates = [
        "execute flag",
        "owner approval artifact",
        "legal/terms approval packet",
        "budget policy",
        "public object keys",
        "non-private payload scan",
        "upload/readback SHA-256 verification",
        "current pointer after readback only",
        "rollback/LKG/revocation plan",
    ]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionR2OwnerApproval.v1",
        "approvalID": "source-atlas/r2-owner-approval/test",
        "approvalType": "bounded_configured_public_reference_production_r2_write_preflight",
        "approvalStatus": "approved_for_future_bounded_configured_public_reference_r2_write_preflight",
        "approved": True,
        "createdAt": CREATED_AT,
        "owner": "test owner",
        "environment": "production",
        "channel": "stable",
        "bucket": "ambitions-source-atlas-prod",
        "requiredExecutionGates": required_gates,
        "outsideLegalApprovalClaimed": False,
        "releaseGreenClaimed": False,
        "literalUniversalCoverageClaimed": False,
        "privacyBoundary": "public/reference/freshness only; no private user context",
        "nonClaims": ["not outside legal approval", "not Release Green", "not literal universal coverage"],
        "domainScopes": [
            _approval_scope("education_credentialing"),
            _approval_scope("finance_public_reference"),
        ],
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


def _gauntlet() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainGauntlet.v1",
        "valid": True,
        "overallReadinessStatus": "representative_goal_domain_gauntlet_green",
        "allowedClaims": [
            "representative_goal_domain_gauntlet_green",
            "configured_frontier_goal_domain_runtime_routing",
            "unknown_public_reference_domains_candidate_only",
        ],
        "blockedClaims": ["literal_universal_coverage", "release_green", "outside_legal_approval"],
        "recordCounts": {
            "configuredGauntletCases": 2,
            "configuredCasesBlocked": 0,
            "unknownCasesBlocked": 0,
            "finalOutputsGenerated": 0,
        },
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
        "overallReadinessStatus": "governed_arbitrary_domain_handling_ready",
        "recordCounts": {
            "unknownProbeDomains": 2,
            "candidateClaims": 0,
            "candidateR2PublishOperations": 0,
            "candidateNativeActivationOperations": 0,
            "candidateProductionWrites": 0,
        },
        "issues": [],
    }


def _pack_checks() -> list[str]:
    return [
        "governance_registries_valid",
        "pack_slices_written",
        "pack_contains_only_packable_claims",
        "restricted_and_crosswalk_claims_excluded",
        "manifest_hashes_present",
        "revocation_lkg_rollback_present",
        "private_object_keys_blocked",
        "non_private_scan_passed",
        "required_artifacts_valid",
        "legal_terms_approval_packet_valid",
        "no_final_plan_schedule_step_output",
    ]


def _r2_checks() -> list[str]:
    return [
        "object_keys_public",
        "payloads_public_reference_only",
        "source_license_slices_present",
        "non_private_scan_passed",
        "legal_terms_approval_packet_valid",
        "production_target_ledger_gate",
        "remote_r2_public_reference_transport_only",
        "upload_readback_checksums",
        "current_pointer_after_readback_only",
        "no_final_plan_schedule_step_output",
    ]


def _check(result: dict, name: str) -> bool:
    return any(check["name"] == name and check["passed"] for check in result["checks"])


def _report_does_not_expose_secret_names(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    return "CLOUDFLARE_API_TOKEN" not in text and "SECRET_ACCESS_KEY" not in text
