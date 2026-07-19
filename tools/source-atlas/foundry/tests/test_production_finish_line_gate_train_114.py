from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import read_json, write_json
from foundry.production_finish_line_gate import (
    ProductionFinishLineGateOptions,
    run_production_finish_line_gate,
)


CREATED_AT = "2026-06-28T23:58:00Z"
DOMAIN = "occupation_foundation"
VERSION = "20260628T000000Z"


def test_production_finish_line_gate_allows_bounded_configured_finish_line(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "bounded_configured_production_finish_line_green"
    assert result["recordCounts"]["productionDomains"] == 1
    assert result["recordCounts"]["productionSourceIDs"] == 1
    assert result["recordCounts"]["r2ReportsValid"] == 1
    assert result["recordCounts"]["recertifiedDomains"] == 1
    assert "bounded_configured_production_target" in result["allowedClaims"]
    assert "internal_terms_review" in result["allowedClaims"]
    assert "production_r2_write_readback" in result["allowedClaims"]
    assert "bounded_live_transport" in result["allowedClaims"]
    assert "bounded_configured_runtime_green" in result["allowedClaims"]
    assert "gateway_native_runtime_recertification" in result["allowedClaims"]
    assert "outside_legal_approval" in result["blockedClaims"]
    assert "runtime_green" in result["blockedClaims"]
    assert "release_green" in result["blockedClaims"]
    assert "universal_coverage" in result["blockedClaims"]
    assert Path(result["outputPaths"]["compiledLegalTermsApprovalPacket"]).exists()


def test_production_finish_line_gate_blocks_when_any_r2_report_is_not_remote_execute(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    r2 = read_json(paths["r2"])
    r2["mode"] = "dry_run"
    r2["executeRequested"] = False
    r2["productionR2Uploaded"] = False
    r2["realR2CredentialsUsed"] = False
    write_json(paths["r2"], r2)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert "production_r2_write_readback" in result["blockedClaims"]
    assert any(
        check["name"] == "production_r2_write_readback_all_configured_domains" and not check["passed"]
        for check in result["checks"]
    )


def _run(tmp_path: Path, paths: dict[str, Path]) -> dict:
    return run_production_finish_line_gate(
        ProductionFinishLineGateOptions(
            production_target_ledger_path=paths["ledger"],
            gateway_release_report_path=paths["gateway"],
            native_runtime_report_path=paths["native_runtime"],
            native_registry_artifact_path=paths["registry"],
            output_root=tmp_path / "finish-line",
            created_at=CREATED_AT,
        )
    )


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {
        "ledger": root / "ledger.json",
        "gateway": root / "gateway.json",
        "native_runtime": root / "native-runtime.json",
        "registry": root / "source-atlas-public-refresh-targets.json",
        "r2": root / "r2-publisher-report.json",
    }
    write_json(paths["r2"], _r2_report(str(paths["r2"])))
    write_json(paths["ledger"], _ledger(str(paths["r2"])))
    write_json(paths["gateway"], _gateway(str(paths["r2"])))
    write_json(paths["native_runtime"], _native_runtime())
    write_json(paths["registry"], _native_registry())
    return paths


def _ledger(r2_path: str) -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "configuredDomainsNotReady": [],
        "domains": [
            {
                "domainID": DOMAIN,
                "readinessStatus": "bounded_production_target_ready",
                "frontierConfigured": True,
                "claimGraphProofComplete": True,
                "packProductionProofComplete": True,
                "r2ProductionProofComplete": True,
                "gatewayProofComplete": True,
                "nativeRegistryProofComplete": True,
                "nativeRuntimeBoundaryProofComplete": True,
                "nativeUsabilityProofComplete": True,
                "r2PublisherPath": r2_path,
                "packableClaimCount": 3,
                "sourceIDs": ["onet.database"],
                "allowedClaimScopes": ["bounded_production_target"],
                "blockedReasons": [],
                "nonClaims": ["not a private user-data backend", "not a final user plan, schedule, or Step generator"],
            }
        ],
        "nonClaims": ["not a private user-data backend", "not universal coverage"],
    }


def _gateway(r2_path: str) -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublicGatewayReleaseReport.v1",
        "valid": True,
        "discovery": {
            "selectedReports": [
                {
                    "domainID": DOMAIN,
                    "packID": f"source-atlas/v1/domain/{DOMAIN}/{VERSION}",
                    "packVersion": VERSION,
                    "path": r2_path,
                    "valid": True,
                    "productionR2Uploaded": True,
                    "environment": "production",
                    "channel": "stable",
                }
            ],
            "selectedPublisherReports": [r2_path],
        },
        "liveVerification": {
            "valid": True,
            "headChecksPassed": True,
            "publicChecksPassed": True,
            "blockedChecksPassed": True,
            "issues": [],
            "publicChecks": [
                {
                    "domain": DOMAIN,
                    "label": label,
                    "objectKey": f"source-atlas/v1/production/stable/{DOMAIN}/{VERSION}/{label}.json",
                    "status": 200,
                    "matched": True,
                    "publicReferenceHeader": "true",
                }
                for label in ("current", "manifest", "pack")
            ],
        },
        "nonClaims": ["not a private user-data backend", "not universal coverage"],
    }


def _native_runtime() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.nativeRuntimeCurrentProof.v1",
        "valid": True,
        "status": "Native Runtime Green for configured Source Atlas public-pack runtime / Yellow overall Source Atlas",
        "product_law_preserved": True,
        "configuredFrontiers": [DOMAIN],
        "xcodeBuildMCP": {
            "result": "SUCCEEDED",
            "passed": 12,
            "failed": 0,
            "skipped": 0,
        },
        "recordCounts": {
            "configuredDomains": 1,
            "domainsBlocked": 0,
            "xcodeFailed": 0,
            "xcodeSkipped": 0,
        },
        "runtimeGreenClaim": {
            "claimID": "bounded_configured_runtime_green",
            "allowed": True,
        },
        "allowedClaims": ["bounded_configured_runtime_green"],
        "native_runtime_proof": {
            "target_domain": DOMAIN,
            "target_pack_id": f"source-atlas/v1/domain/{DOMAIN}/{VERSION}",
            "default_app_container_wired": True,
            "live_urlsession_test": "SourceAtlasPublicPackRemoteTransportTests/live",
            "live_lifecycle_test": "SourceAtlasPublicPackLifecycleRefreshServiceTests/live",
        },
        "validation_run": [{"status": "passed"}, {"status": "passed"}],
        "proofSummary": {
            "r2RequestPrivacyProof": "Public manifest requests only.",
            "noPrivateGraphEgressProof": "No private graph fields leave the device.",
            "nativeOfflineNoAccountProof": "Offline no-account fallback passed.",
            "runtimeCompositionProof": "Source Atlas remains reference-only.",
        },
        "nonClaims": ["not a private user-data backend", "not universal coverage"],
    }


def _native_registry() -> dict:
    return {
        "artifactID": "source_atlas_public_refresh_targets.fixture",
        "schemaVersion": 1,
        "publicReferenceOnly": True,
        "registry": {
            "entries": [
                {
                    "status": "active",
                    "allowedModes": ["startup"],
                    "target": {
                        "id": f"source-atlas-refresh-target.{DOMAIN}.stable.{VERSION}",
                        "domainID": DOMAIN,
                        "targetPackID": f"source-atlas/v1/domain/{DOMAIN}/{VERSION}",
                        "environment": "production",
                        "channel": "stable",
                        "schemaVersion": "1.0.0",
                        "appVersion": "1.0",
                        "publicLocale": "en-US",
                    },
                    "nonClaims": ["not a private user-data backend", "not a final user plan, schedule, or Step generator"],
                }
            ]
        },
        "nonClaims": ["not a private user-data backend", "not universal coverage"],
    }


def _r2_report(path: str) -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PackPublisherReport.v1",
        "status": "Source Green for R2 publisher gate harness",
        "valid": True,
        "environment": "production",
        "channel": "stable",
        "mode": "remote_r2",
        "executeRequested": True,
        "productionR2Uploaded": True,
        "realR2CredentialsUsed": True,
        "packID": f"source-atlas/v1/domain/{DOMAIN}/{VERSION}",
        "operation": {"success": True, "remoteR2": True},
        "checks": [
            {"name": "remote_r2_public_reference_transport_only", "passed": True},
            {"name": "upload_readback_checksums", "passed": True},
            {"name": "current_pointer_after_readback_only", "passed": True},
            {"name": "source_license_slices_present", "passed": True},
            {"name": "non_private_scan_passed", "passed": True},
            {"name": "revocation_lkg_rollback_present", "passed": True},
            {"name": "no_final_plan_schedule_step_output", "passed": True},
        ],
        "outputPaths": {"report": path},
        "nonClaims": ["not a private user-data backend", "not universal coverage"],
    }
