from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import read_json, write_json
from foundry.production_recertification_gate import (
    ProductionRecertificationOptions,
    run_production_recertification_gate,
)


CREATED_AT = "2026-06-28T20:20:00Z"
DOMAINS = ("education_credentialing", "public_civic_requirements")


def test_production_recertification_gate_passes_current_coherent_chain(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "bounded_configured_production_runtime_recertified"
    assert result["recordCounts"]["recertifiedDomains"] == 2
    assert result["allowedClaims"] == [
        "bounded_configured_source_atlas_production_runtime_ready",
        "bounded_configured_frontier_current_production_runtime_ready",
    ]
    assert result["universalCoverageClaimAllowed"] is False
    assert all(domain["gatewayCurrentManifestPackVerified"] for domain in result["domains"])
    assert all(domain["nativeRegistryMatched"] for domain in result["domains"])
    assert all(domain["nativeRuntimeCovered"] for domain in result["domains"])


def test_production_recertification_gate_blocks_stale_ledger_r2_path(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    ledger = read_json(paths["ledger"])
    ledger["domains"][0]["r2PublisherPath"] = "tools/source-atlas/generated/r2-publisher/old/r2-publisher-report.json"
    write_json(paths["ledger"], ledger)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    domain = _domain(result, "education_credentialing")
    assert "production_target_ledger_r2_path_not_current_gateway_selection" in domain["blockers"]
    assert any("production_target_ledger_r2_path_not_current_gateway_selection" in issue for issue in result["issues"])


def test_production_recertification_gate_blocks_missing_gateway_manifest_check(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    gateway = read_json(paths["gateway"])
    gateway["liveVerification"]["publicChecks"] = [
        item
        for item in gateway["liveVerification"]["publicChecks"]
        if not (item["domain"] == "public_civic_requirements" and item["label"] == "manifest")
    ]
    write_json(paths["gateway"], gateway)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    domain = _domain(result, "public_civic_requirements")
    assert "gateway_live_public_check_missing_or_failed_manifest" in domain["blockers"]


def test_production_recertification_gate_blocks_missing_native_runtime_domain(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    runtime = read_json(paths["native_runtime"])
    runtime["configuredFrontiers"] = ["education_credentialing"]
    write_json(paths["native_runtime"], runtime)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    domain = _domain(result, "public_civic_requirements")
    assert "native_runtime_current_r2_proof_missing_for_domain" in domain["blockers"]


def _run(tmp_path: Path, paths: dict[str, Path]) -> dict:
    return run_production_recertification_gate(
        ProductionRecertificationOptions(
            production_target_ledger_path=paths["ledger"],
            gateway_release_report_path=paths["gateway"],
            native_runtime_report_path=paths["native_runtime"],
            native_registry_artifact_path=paths["registry"],
            output_root=tmp_path / "recertification",
            created_at=CREATED_AT,
        )
    )


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    ledger = _ledger()
    gateway = _gateway()
    native_runtime = _native_runtime()
    registry = _native_registry()
    paths = {
        "ledger": root / "ledger.json",
        "gateway": root / "gateway.json",
        "native_runtime": root / "native-runtime.json",
        "registry": root / "source-atlas-public-refresh-targets.json",
    }
    write_json(paths["ledger"], ledger)
    write_json(paths["gateway"], gateway)
    write_json(paths["native_runtime"], native_runtime)
    write_json(paths["registry"], registry)
    return paths


def _ledger() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "domains": [_ledger_domain(domain, _version(domain)) for domain in DOMAINS],
        "nonClaims": ["not a private user-data backend", "not universal coverage"],
    }


def _ledger_domain(domain: str, version: str) -> dict:
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
        "r2PublisherPath": _publisher_path(domain, version),
        "packableClaimCount": 3,
        "sourceIDs": [f"{domain}.source"],
        "allowedClaimScopes": ["bounded_production_target"],
        "blockedReasons": [],
        "nonClaims": ["not a private user-data backend", "not a final user plan, schedule, or Step generator"],
    }


def _gateway() -> dict:
    selected = [_selected_report(domain, _version(domain)) for domain in DOMAINS]
    public_checks = []
    for domain in DOMAINS:
        for label in ("current", "manifest", "pack"):
            public_checks.append(
                {
                    "domain": domain,
                    "label": label,
                    "objectKey": f"source-atlas/v1/production/stable/{domain}/{_version(domain)}/{label}.json",
                    "status": 200,
                    "matched": True,
                    "publicReferenceHeader": "true",
                }
            )
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublicGatewayReleaseReport.v1",
        "valid": True,
        "discovery": {
            "selectedReports": selected,
            "selectedPublisherReports": [item["path"] for item in selected],
        },
        "liveVerification": {
            "valid": True,
            "headChecksPassed": True,
            "publicChecksPassed": True,
            "blockedChecksPassed": True,
            "issues": [],
            "publicChecks": public_checks,
        },
        "nonClaims": ["not a private user-data backend", "not universal coverage"],
    }


def _selected_report(domain: str, version: str) -> dict:
    return {
        "domainID": domain,
        "packID": f"source-atlas/v1/domain/{domain}/{version}",
        "packVersion": version,
        "path": _publisher_path(domain, version),
        "valid": True,
        "productionR2Uploaded": True,
        "environment": "production",
        "channel": "stable",
    }


def _native_runtime() -> dict:
    return {
        "artifactID": "source_atlas_native_runtime.fixture",
        "configuredFrontiers": list(DOMAINS),
        "xcodeBuildMCP": {
            "result": "SUCCEEDED",
            "passed": 12,
            "failed": 0,
            "skipped": 0,
        },
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
                        "id": f"source-atlas-refresh-target.{domain}.stable.{_version(domain)}",
                        "domainID": domain,
                        "targetPackID": f"source-atlas/v1/domain/{domain}/{_version(domain)}",
                        "environment": "production",
                        "channel": "stable",
                        "schemaVersion": "1.0.0",
                        "appVersion": "1.0",
                        "publicLocale": "en-US",
                    },
                    "nonClaims": ["not a private user-data backend", "not a final user plan, schedule, or Step generator"],
                }
                for domain in DOMAINS
            ]
        },
        "nonClaims": ["not a private user-data backend", "not universal coverage"],
    }


def _publisher_path(domain: str, version: str) -> str:
    return f"tools/source-atlas/generated/r2-publisher/train-104-{domain}/r2-publisher-report.json"


def _version(domain: str) -> str:
    versions = {
        "education_credentialing": "20260628T000000Z",
        "public_civic_requirements": "20260628T041500Z",
    }
    return versions[domain]


def _domain(result: dict, domain_id: str) -> dict:
    return next(item for item in result["domains"] if item["domainID"] == domain_id)
