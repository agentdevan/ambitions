from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import read_json
from foundry.r2_public_gateway_allowlist import PublicGatewayAllowlistOptions, compile_public_gateway_allowlist


CREATED_AT = "2026-06-28T00:00:00Z"


def test_public_gateway_allowlist_compiles_from_valid_production_reports(tmp_path: Path):
    first = _publisher_report_path(tmp_path, "education_credentialing")
    second = _publisher_report_path(tmp_path, "health_wellness_reference")
    worker_allowlist = tmp_path / "worker" / "allowed-object-keys.generated.js"

    result = compile_public_gateway_allowlist(
        PublicGatewayAllowlistOptions(
            publisher_reports=(second, first),
            output_root=tmp_path / "allowlist",
            created_at=CREATED_AT,
            worker_allowlist_path=worker_allowlist,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for public gateway allowlist compiler"
    assert result["allowedObjectKeyCount"] == 10

    artifact = read_json(Path(result["outputPaths"]["artifact"]))
    assert artifact["publicReferenceOnly"] is True
    assert artifact["allowedObjectKeys"] == sorted(artifact["allowedObjectKeys"])
    assert artifact["allowedObjectKeys"] == [
        "source-atlas/v1/production/stable/education_credentialing/20260628T000000Z/manifest.json",
        "source-atlas/v1/production/stable/education_credentialing/20260628T000000Z/pack.json",
        "source-atlas/v1/production/stable/education_credentialing/current.json",
        "source-atlas/v1/production/stable/education_credentialing/lkg.json",
        "source-atlas/v1/production/stable/education_credentialing/revocations.json",
        "source-atlas/v1/production/stable/health_wellness_reference/20260628T000000Z/manifest.json",
        "source-atlas/v1/production/stable/health_wellness_reference/20260628T000000Z/pack.json",
        "source-atlas/v1/production/stable/health_wellness_reference/current.json",
        "source-atlas/v1/production/stable/health_wellness_reference/lkg.json",
        "source-atlas/v1/production/stable/health_wellness_reference/revocations.json",
    ]
    generated = worker_allowlist.read_text(encoding="utf-8")
    assert "export const ALLOWED_OBJECT_KEYS = new Set([" in generated
    assert generated.count("source-atlas/v1/production/stable/") == 10
    assert "goal_text" not in generated


def test_public_gateway_allowlist_rejects_staging_report(tmp_path: Path):
    report_path = _publisher_report_path(tmp_path, "education_credentialing", environment="staging", channel="candidate")

    result = compile_public_gateway_allowlist(
        PublicGatewayAllowlistOptions(
            publisher_reports=(report_path,),
            output_root=tmp_path / "allowlist",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("requires production environment" in issue for issue in result["issues"])
    assert any("requires stable channel" in issue for issue in result["issues"])
    artifact = read_json(Path(result["outputPaths"]["artifact"]))
    assert artifact["allowedObjectKeys"] == []


def test_public_gateway_allowlist_blocks_private_object_key_before_worker_source(tmp_path: Path):
    report_path = _publisher_report_path(tmp_path, "users")

    result = compile_public_gateway_allowlist(
        PublicGatewayAllowlistOptions(
            publisher_reports=(report_path,),
            output_root=tmp_path / "allowlist",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("private_r2_object_key_segment" in issue for issue in result["issues"])
    artifact = read_json(Path(result["outputPaths"]["artifact"]))
    assert artifact["allowedObjectKeys"] == []


def test_public_gateway_allowlist_rejects_failed_pack_readback(tmp_path: Path):
    report_path = _publisher_report_path(tmp_path, "education_credentialing", pack_readback_passed=False)

    result = compile_public_gateway_allowlist(
        PublicGatewayAllowlistOptions(
            publisher_reports=(report_path,),
            output_root=tmp_path / "allowlist",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("readback label pack did not pass" in issue for issue in result["issues"])
    artifact = read_json(Path(result["outputPaths"]["artifact"]))
    assert artifact["allowedObjectKeys"] == []


def _publisher_report_path(
    tmp_path: Path,
    domain: str,
    *,
    environment: str = "production",
    channel: str = "stable",
    pack_readback_passed: bool = True,
) -> Path:
    root = f"source-atlas/v1/{environment}/{channel}/{domain}"
    version = "20260628T000000Z"
    path = tmp_path / f"{domain}-r2-publisher-report.json"
    report = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PackPublisherReport.v1",
        "createdAt": CREATED_AT,
        "valid": True,
        "status": "Source Green for R2 publisher gate harness",
        "environment": environment,
        "channel": channel,
        "mode": "remote_r2",
        "packID": f"source-atlas/v1/domain/{domain}/{version}",
        "packVersion": version,
        "productionR2Uploaded": environment == "production" and channel == "stable",
        "currentPointer": {
            "kind": "ambitions.sourceAtlas.currentPackPointer.v1",
            "environment": environment,
            "channel": channel,
            "packID": f"source-atlas/v1/domain/{domain}/{version}",
            "packVersion": version,
            "manifestKey": f"{root}/{version}/manifest.json",
            "manifestSHA256": "a" * 64,
            "packSHA256": "b" * 64,
            "revocationManifestKey": f"{root}/revocations.json",
            "lastKnownGoodKey": f"{root}/lkg.json",
            "publicReferenceOnly": True,
            "dataClass": "public_freshness",
        },
        "checks": [
            {"name": "pack_artifacts_valid", "passed": True, "issues": []},
            {"name": "object_keys_public", "passed": True, "issues": []},
            {"name": "upload_readback_checksums", "passed": True, "issues": []},
        ],
        "operation": {
            "kind": "ambitions.sourceAtlas.r2PublisherOperation.v1",
            "mode": "remote_r2",
            "remoteR2": True,
            "success": True,
            "publicReferenceOnly": True,
            "currentPointer": {
                "key": f"{root}/current.json",
                "updated": True,
                "expectedSHA256": "c" * 64,
                "actualSHA256": "c" * 64,
            },
            "readbackResults": [
                _readback("lkg", f"{root}/lkg.json", "d" * 64),
                _readback("manifest", f"{root}/{version}/manifest.json", "a" * 64),
                _readback("pack", f"{root}/{version}/pack.json", "b" * 64, passed=pack_readback_passed),
                _readback("revocations", f"{root}/revocations.json", "e" * 64),
            ],
        },
        "issues": [],
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


def _readback(label: str, object_key: str, sha: str, *, passed: bool = True) -> dict[str, object]:
    return {
        "label": label,
        "objectKey": object_key,
        "passed": passed,
        "success": passed,
        "expectedSHA256": sha,
        "actualSHA256": sha if passed else "f" * 64,
    }
