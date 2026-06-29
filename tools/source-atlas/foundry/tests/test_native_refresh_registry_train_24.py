from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import read_json
from foundry.native_refresh_registry import NativeRefreshRegistryOptions, compile_native_refresh_registry


CREATED_AT = "2026-06-28T00:00:00Z"


def test_native_refresh_registry_compiles_review_required_artifact_by_default(tmp_path: Path):
    report_path = _publisher_report_path(tmp_path)
    result = compile_native_refresh_registry(
        NativeRefreshRegistryOptions(
            publisher_reports=(report_path,),
            output_root=tmp_path / "native-registry",
            created_at=CREATED_AT,
            app_version="1.0",
            public_locale="en-US",
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for native refresh registry artifact compiler"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; native refresh registry artifact compiler only"
    assert result["targetCount"] == 1
    assert result["activeTargetCount"] == 0
    assert result["reviewRequiredTargetCount"] == 1

    artifact = read_json(Path(result["outputPaths"]["artifact"]))
    assert artifact["schemaVersion"] == "1.0.0"
    assert artifact["publicReferenceOnly"] is True
    assert artifact["artifactID"].startswith("source_atlas_public_refresh_targets.")
    assert "not a bundled production refresh target approval" in artifact["nonClaims"]
    entry = artifact["registry"]["entries"][0]
    assert entry["status"] == "review_required"
    assert entry["allowedModes"] == ["startup", "active_lifecycle", "background"]
    assert entry["target"] == {
        "appVersion": "1.0",
        "channel": "candidate",
        "domainID": "public_civic_requirements",
        "environment": "staging",
        "id": "source-atlas-refresh-target.public_civic_requirements.candidate.20260627T000000Z",
        "publicLocale": "en-US",
        "schemaVersion": "1.0.0",
        "targetPackID": "source-atlas/v1/domain/public_civic_requirements/20260627T000000Z",
    }
    assert "secret" not in json.dumps(artifact).lower()


def test_native_refresh_registry_active_status_requires_approval_artifact(tmp_path: Path):
    report_path = _publisher_report_path(tmp_path)
    result = compile_native_refresh_registry(
        NativeRefreshRegistryOptions(
            publisher_reports=(report_path,),
            output_root=tmp_path / "native-registry",
            created_at=CREATED_AT,
            status="active",
        )
    )

    assert not result["valid"]
    assert "active refresh targets require --approval-artifact" in result["issues"]
    assert result["activeTargetCount"] == 1


def test_native_refresh_registry_active_status_records_approval_artifact(tmp_path: Path):
    report_path = _publisher_report_path(tmp_path)
    approval = tmp_path / "owner-approval.md"
    approval.write_text("Train 24 fixture approval for local test only.\n", encoding="utf-8")
    ledger = _production_target_ledger_path(tmp_path)

    result = compile_native_refresh_registry(
        NativeRefreshRegistryOptions(
            publisher_reports=(report_path,),
            output_root=tmp_path / "native-registry",
            created_at=CREATED_AT,
            status="active",
            approval_artifact=approval,
            allowed_modes=("startup",),
            production_target_ledger_path=ledger,
        )
    )

    assert result["valid"], result["issues"]
    artifact = read_json(Path(result["outputPaths"]["artifact"]))
    entry = artifact["registry"]["entries"][0]
    assert entry["status"] == "active"
    assert entry["allowedModes"] == ["startup"]
    assert entry["reviewArtifactID"].endswith("owner-approval.md")


def test_native_refresh_registry_blocks_private_publisher_report_before_target_emission(tmp_path: Path):
    report_path = _publisher_report_path(
        tmp_path,
        manifest_key="source-atlas/v1/staging/candidate/users/20260627T000000Z/manifest.json",
        pack_id="source-atlas/v1/domain/users/20260627T000000Z",
    )
    result = compile_native_refresh_registry(
        NativeRefreshRegistryOptions(
            publisher_reports=(report_path,),
            output_root=tmp_path / "native-registry",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("private_r2_object_key_segment" in issue for issue in result["issues"])
    artifact = read_json(Path(result["outputPaths"]["artifact"]))
    assert artifact["registry"]["entries"] == []


def test_native_refresh_registry_rejects_invalid_publisher_report(tmp_path: Path):
    report_path = _publisher_report_path(tmp_path, valid=False)
    result = compile_native_refresh_registry(
        NativeRefreshRegistryOptions(
            publisher_reports=(report_path,),
            output_root=tmp_path / "native-registry",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("publisher report is not valid" in issue for issue in result["issues"])
    artifact = read_json(Path(result["outputPaths"]["artifact"]))
    assert artifact["registry"]["entries"] == []


def _publisher_report_path(
    tmp_path: Path,
    *,
    valid: bool = True,
    manifest_key: str = "source-atlas/v1/staging/candidate/public_civic_requirements/20260627T000000Z/manifest.json",
    pack_id: str = "source-atlas/v1/domain/public_civic_requirements/20260627T000000Z",
) -> Path:
    path = tmp_path / "r2-publisher-report.json"
    report = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PackPublisherReport.v1",
        "createdAt": "2026-06-27T00:00:00Z",
        "valid": valid,
        "status": "Source Green for R2 publisher gate harness" if valid else "Red",
        "environment": "staging",
        "channel": "candidate",
        "packID": pack_id,
        "packVersion": "20260627T000000Z",
        "issues": [] if valid else ["fixture invalid"],
        "productionR2Uploaded": False,
        "realR2CredentialsUsed": False,
        "currentPointer": {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.currentPackPointer.v1",
            "createdAt": "2026-06-27T00:00:00Z",
            "environment": "staging",
            "channel": "candidate",
            "packID": pack_id,
            "packVersion": "20260627T000000Z",
            "manifestKey": manifest_key,
            "manifestSHA256": "0" * 64,
            "packSHA256": "1" * 64,
            "revocationManifestKey": "source-atlas/v1/staging/candidate/public_civic_requirements/revocations.json",
            "lastKnownGoodKey": "source-atlas/v1/staging/candidate/public_civic_requirements/lkg.json",
            "publicReferenceOnly": True,
            "dataClass": "public_freshness",
        },
        "privacyBoundary": "public/reference/freshness only; no private life graph, goals, captures, calendar data, proof, receipts, personalization, behavior history, or private user context",
        "nonClaims": [
            "not a private user-data backend",
            "not private life graph storage",
            "not production R2 readiness",
            "not a final user plan, schedule, or Step generator",
        ],
    }
    path.write_text(json.dumps(report, indent=2, sort_keys=True), encoding="utf-8")
    return path


def _production_target_ledger_path(tmp_path: Path, *, domain: str = "public_civic_requirements", ready: bool = True) -> Path:
    path = tmp_path / "production-target-ledger.json"
    status = "bounded_production_target_ready" if ready else "pack_production_ready"
    ledger = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "ledgerID": "source-atlas/production-target-ledger/test",
        "overallReadinessStatus": "configured_frontiers_bounded_production_target_ready",
        "allowedClaims": [
            "bounded_production_target_for_configured_frontiers",
            "bounded_production_target_per_ready_frontier",
        ],
        "orphanProductionDomains": [],
        "configuredDomainsNotReady": [],
        "domains": [
            {
                "domainID": domain,
                "readinessStatus": status,
            }
        ],
    }
    path.write_text(json.dumps(ledger, indent=2, sort_keys=True), encoding="utf-8")
    return path
