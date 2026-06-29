from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import read_json, write_json  # noqa: E402
from foundry.native_runtime_current_proof import (  # noqa: E402
    NativeRuntimeCurrentProofOptions,
    run_native_runtime_current_proof,
)


CREATED_AT = "2026-06-29T01:00:00Z"
VERSION = "20260628T000000Z"
REQUIRED_SUITES = [
    "SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests",
    "SourceAtlasPublicPackRemoteTransportTests",
    "SourceAtlasPublicPackLifecycleRefreshServiceTests",
    "SourceAtlasPublicPackFetchPipelineTests",
    "SourceAtlasPublicPackRepositoryBackedRemoteRefreshTests",
    "SourceAtlasPublicPackAppRefreshCoordinatorTests",
    "SourceAtlasOfflineNoAccountScenarioTests",
    "SourceAtlasLocalReferenceCompositionProofTests",
]


def test_native_runtime_current_proof_allows_bounded_configured_runtime_green(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "bounded_configured_native_runtime_green"
    assert result["recordCounts"]["configuredDomains"] == 2
    assert result["recordCounts"]["domainsRuntimeReady"] == 2
    assert result["recordCounts"]["xcodePassed"] == 72
    assert "bounded_configured_runtime_green" in result["allowedClaims"]
    assert "release_green" in result["blockedClaims"]
    assert "literal_universal_coverage" in result["blockedClaims"]
    assert result["runtimeGreenClaim"]["allowed"] is True
    assert _check(result, "focused_native_tests_passed")
    assert _check(result, "all_configured_domains_runtime_ready")


def test_native_runtime_current_proof_blocks_registry_pack_mismatch(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    registry = read_json(paths["registry"])
    registry["registry"]["entries"][0]["target"]["targetPackID"] = "source-atlas/v1/domain/education_credentialing/other"
    write_json(paths["registry"], registry)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert "bounded_configured_runtime_green" not in result["allowedClaims"]
    assert any("education_credentialing: native_registry_pack_id_mismatch" in issue for issue in result["issues"])


def test_native_runtime_current_proof_blocks_skipped_or_missing_native_suite(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(
        tmp_path,
        paths,
        xcode_skipped=1,
        test_suites=[suite for suite in REQUIRED_SUITES if suite != "SourceAtlasLocalReferenceCompositionProofTests"],
    )

    assert not result["valid"]
    assert any("xcodeBuildMCP skipped count is not zero" in issue for issue in result["issues"])
    assert any(
        "focused native suite missing: SourceAtlasLocalReferenceCompositionProofTests" in issue
        for issue in result["issues"]
    )


def _run(
    tmp_path: Path,
    paths: dict[str, Path],
    *,
    xcode_skipped: int = 0,
    test_suites: list[str] | None = None,
) -> dict:
    return run_native_runtime_current_proof(
        NativeRuntimeCurrentProofOptions(
            production_target_ledger_path=paths["ledger"],
            gateway_release_report_path=paths["gateway"],
            native_registry_artifact_path=paths["registry"],
            output_root=tmp_path / "native-runtime-current-proof",
            created_at=CREATED_AT,
            xcode_result="SUCCEEDED",
            xcode_passed=72,
            xcode_failed=0,
            xcode_skipped=xcode_skipped,
            xcode_duration_ms=1234,
            xcode_log_path="/tmp/source-atlas-native.log",
            xcresult_path="/tmp/source-atlas-native.xcresult",
            xcode_profile="ambitions-ios",
            test_suites=tuple(test_suites or REQUIRED_SUITES),
            endpoint="https://ambitions-source-atlas-public-gateway.example.test",
            branch="main",
            commit_sha="abcdef123456",
            worktree_dirty_entry_count=1,
        )
    )


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {
        "ledger": root / "production-target-ledger.json",
        "gateway": root / "gateway-release.json",
        "registry": root / "source-atlas-public-refresh-targets.json",
    }
    domains = ["education_credentialing", "finance_public_reference"]
    write_json(paths["ledger"], _ledger(domains))
    write_json(paths["gateway"], _gateway(domains))
    write_json(paths["registry"], _registry(domains))
    return paths


def _ledger(domains: list[str]) -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "domains": [
            {
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
                "r2PublisherPath": f"tools/source-atlas/generated/r2-publisher/{domain}/r2-publisher-report.json",
                "packableClaimCount": 4,
                "sourceIDs": [f"{domain}.official_source"],
                "allowedClaimScopes": ["bounded_production_target"],
                "blockedReasons": [],
            }
            for domain in domains
        ],
    }


def _gateway(domains: list[str]) -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublicGatewayReleaseReport.v1",
        "valid": True,
        "discovery": {
            "selectedReports": [
                {
                    "domainID": domain,
                    "packID": _pack_id(domain),
                    "packVersion": VERSION,
                    "path": f"tools/source-atlas/generated/r2-publisher/{domain}/r2-publisher-report.json",
                    "valid": True,
                    "productionR2Uploaded": True,
                    "environment": "production",
                    "channel": "stable",
                }
                for domain in domains
            ],
        },
        "liveVerification": {
            "valid": True,
            "headChecksPassed": True,
            "publicChecksPassed": True,
            "blockedChecksPassed": True,
            "issues": [],
            "publicChecks": [
                {
                    "domain": domain,
                    "label": label,
                    "objectKey": f"source-atlas/v1/production/stable/{domain}/{VERSION}/{label}.json",
                    "status": 200,
                    "matched": True,
                    "publicReferenceHeader": "true",
                }
                for domain in domains
                for label in ("current", "manifest", "pack")
            ],
        },
    }


def _registry(domains: list[str]) -> dict:
    return {
        "artifactID": "source_atlas_public_refresh_targets.test",
        "schemaVersion": "1.0.0",
        "createdAt": CREATED_AT,
        "publicReferenceOnly": True,
        "registry": {
            "entries": [
                {
                    "status": "active",
                    "allowedModes": ["startup"],
                    "target": {
                        "id": f"source-atlas-refresh-target.{domain}.stable.{VERSION}",
                        "domainID": domain,
                        "environment": "production",
                        "channel": "stable",
                        "schemaVersion": "1.0.0",
                        "appVersion": "1.0",
                        "publicLocale": "en-US",
                        "targetPackID": _pack_id(domain),
                    },
                    "nonClaims": ["not a final user plan", "not a Step generator"],
                }
                for domain in domains
            ]
        },
        "nonClaims": ["not a private user-data backend", "not universal coverage"],
    }


def _pack_id(domain: str) -> str:
    return f"source-atlas/v1/domain/{domain}/{VERSION}"


def _check(result: dict, name: str) -> bool:
    return any(check["name"] == name and check["passed"] for check in result["checks"])
