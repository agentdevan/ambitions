from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.native_refresh_registry import NativeRefreshRegistryOptions, compile_native_refresh_registry
from foundry.production_target_gate import validate_production_target_ledger_gate
from foundry.r2_public_gateway_release import PublicGatewayReleaseOptions, run_public_gateway_release


CREATED_AT = "2026-06-28T00:00:00Z"


def test_production_target_gate_accepts_requested_ready_domains(tmp_path: Path):
    ledger = _ledger_path(tmp_path, ["education_credentialing"])

    gate = validate_production_target_ledger_gate(
        ledger_path=ledger,
        requested_domains=["education_credentialing"],
        required=True,
    )

    assert gate["valid"], gate["issues"]
    assert gate["requestedDomains"] == ["education_credentialing"]
    assert gate["missingDomains"] == []
    assert "bounded_production_target_for_configured_frontiers" in gate["allowedClaims"]


def test_production_target_gate_rejects_missing_domain(tmp_path: Path):
    ledger = _ledger_path(tmp_path, ["education_credentialing"])

    gate = validate_production_target_ledger_gate(
        ledger_path=ledger,
        requested_domains=["public_civic_requirements"],
        required=True,
    )

    assert not gate["valid"]
    assert gate["missingDomains"] == ["public_civic_requirements"]
    assert "public_civic_requirements: not bounded production target ready in production target ledger" in gate["issues"]


def test_gateway_deploy_execute_requires_production_target_ledger(tmp_path: Path):
    root = tmp_path / "publisher"
    _publisher_report_path(root, "education_credentialing")
    config = tmp_path / "wrangler.jsonc"
    config.write_text("{}", encoding="utf-8")

    result = run_public_gateway_release(
        PublicGatewayReleaseOptions(
            publisher_report_root=root,
            output_root=tmp_path / "release",
            created_at=CREATED_AT,
            worker_allowlist_path=tmp_path / "worker" / "allowed-object-keys.generated.js",
            worker_config_path=config,
            deploy=True,
            execute=True,
        )
    )

    assert not result["valid"]
    assert "production target ledger is required for this activation path" in result["issues"]
    assert result["deployReport"]["attempted"] is False


def test_gateway_deploy_execute_accepts_matching_production_target_ledger(tmp_path: Path, monkeypatch):
    from foundry import r2_public_gateway_release

    root = tmp_path / "publisher"
    _publisher_report_path(root, "education_credentialing")
    ledger = _ledger_path(tmp_path, ["education_credentialing"])
    config = tmp_path / "wrangler.jsonc"
    config.write_text("{}", encoding="utf-8")

    def fake_deploy(_options, _output_root):
        return {
            "attempted": True,
            "success": True,
            "args": ["wrangler", "deploy"],
            "returnCode": 0,
            "stdout": "Current Version ID: train-85-fixture\n",
            "stderr": "",
            "workerVersionID": "train-85-fixture",
            "issues": [],
        }

    monkeypatch.setattr(r2_public_gateway_release, "_deploy_worker", fake_deploy)

    result = run_public_gateway_release(
        PublicGatewayReleaseOptions(
            publisher_report_root=root,
            output_root=tmp_path / "release",
            created_at=CREATED_AT,
            worker_allowlist_path=tmp_path / "worker" / "allowed-object-keys.generated.js",
            worker_config_path=config,
            deploy=True,
            execute=True,
            production_target_ledger_path=ledger,
        )
    )

    assert result["valid"], result["issues"]
    assert result["productionTargetLedgerGate"]["valid"] is True
    assert result["deployReport"]["attempted"] is True


def test_native_active_refresh_requires_production_target_ledger(tmp_path: Path):
    report = _publisher_report_path(tmp_path / "publisher", "education_credentialing")
    approval = tmp_path / "owner-approval.md"
    approval.write_text("active target fixture approval\n", encoding="utf-8")

    result = compile_native_refresh_registry(
        NativeRefreshRegistryOptions(
            publisher_reports=(report,),
            output_root=tmp_path / "native-registry",
            created_at=CREATED_AT,
            status="active",
            approval_artifact=approval,
        )
    )

    assert not result["valid"]
    assert "production target ledger is required for this activation path" in result["issues"]
    assert result["activeTargetCount"] == 1


def test_native_active_refresh_accepts_matching_production_target_ledger(tmp_path: Path):
    report = _publisher_report_path(tmp_path / "publisher", "education_credentialing")
    ledger = _ledger_path(tmp_path, ["education_credentialing"])
    approval = tmp_path / "owner-approval.md"
    approval.write_text("active target fixture approval\n", encoding="utf-8")

    result = compile_native_refresh_registry(
        NativeRefreshRegistryOptions(
            publisher_reports=(report,),
            output_root=tmp_path / "native-registry",
            created_at=CREATED_AT,
            status="active",
            approval_artifact=approval,
            production_target_ledger_path=ledger,
        )
    )

    assert result["valid"], result["issues"]
    assert result["productionTargetLedgerGate"]["valid"] is True
    assert result["activeTargetCount"] == 1


def _ledger_path(tmp_path: Path, ready_domains: list[str]) -> Path:
    path = tmp_path / "production-target-ledger.json"
    ledger = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "ledgerID": "source-atlas/production-target-ledger/train-85-fixture",
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
                "readinessStatus": "bounded_production_target_ready",
            }
            for domain in sorted(ready_domains)
        ],
    }
    path.write_text(json.dumps(ledger, indent=2, sort_keys=True), encoding="utf-8")
    return path


def _publisher_report_path(root: Path, domain: str) -> Path:
    report_root = root / domain
    report_root.mkdir(parents=True, exist_ok=True)
    path = report_root / "r2-publisher-report.json"
    version = "20260628T000000Z"
    key_root = f"source-atlas/v1/production/stable/{domain}"
    report = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PackPublisherReport.v1",
        "createdAt": CREATED_AT,
        "valid": True,
        "status": "Source Green for R2 publisher gate harness",
        "environment": "production",
        "channel": "stable",
        "mode": "remote_r2",
        "packID": f"source-atlas/v1/domain/{domain}/{version}",
        "packVersion": version,
        "productionR2Uploaded": True,
        "checks": [
            {"name": "pack_artifacts_valid", "passed": True, "issues": []},
            {"name": "upload_readback_checksums", "passed": True, "issues": []},
        ],
        "currentPointer": {
            "kind": "ambitions.sourceAtlas.currentPackPointer.v1",
            "environment": "production",
            "channel": "stable",
            "packID": f"source-atlas/v1/domain/{domain}/{version}",
            "packVersion": version,
            "manifestKey": f"{key_root}/{version}/manifest.json",
            "manifestSHA256": "0" * 64,
            "packSHA256": "1" * 64,
            "revocationManifestKey": f"{key_root}/revocations.json",
            "lastKnownGoodKey": f"{key_root}/lkg.json",
            "publicReferenceOnly": True,
            "dataClass": "public_freshness",
        },
        "operation": {
            "kind": "ambitions.sourceAtlas.r2PublisherOperation.v1",
            "remoteR2": True,
            "success": True,
            "publicReferenceOnly": True,
            "currentPointer": {
                "key": f"{key_root}/current.json",
                "updated": True,
                "expectedSHA256": "2" * 64,
                "actualSHA256": "2" * 64,
            },
            "readbackResults": [
                _readback("lkg", f"{key_root}/lkg.json"),
                _readback("manifest", f"{key_root}/{version}/manifest.json"),
                _readback("pack", f"{key_root}/{version}/pack.json"),
                _readback("revocations", f"{key_root}/revocations.json"),
            ],
        },
        "issues": [],
        "privacyBoundary": "public/reference/freshness only; no private life graph, goals, captures, calendar data, proof, receipts, personalization, behavior history, or private user context",
        "nonClaims": ["not a private user-data backend", "not a final user plan, schedule, or Step generator"],
    }
    path.write_text(json.dumps(report, indent=2, sort_keys=True), encoding="utf-8")
    return path


def _readback(label: str, object_key: str) -> dict[str, object]:
    return {
        "label": label,
        "objectKey": object_key,
        "passed": True,
        "success": True,
        "expectedSHA256": "3" * 64,
        "actualSHA256": "3" * 64,
    }
