from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import read_json
from foundry.r2_public_gateway_release import (
    PublicGatewayReleaseOptions,
    discover_production_publisher_reports,
    run_public_gateway_release,
    validate_native_registry_coherence,
    verify_public_gateway,
)


CREATED_AT = "2026-06-28T00:00:00Z"


def test_gateway_release_discovers_latest_production_report_per_domain(tmp_path: Path):
    root = tmp_path / "publisher"
    older = _publisher_report_path(root, "education_credentialing", "20260627T000000Z")
    newer = _publisher_report_path(root, "education_credentialing", "20260628T000000Z")
    civic = _publisher_report_path(root, "public_civic_requirements", "20260628T041500Z")
    _publisher_report_path(root, "education_credentialing", "20260628T010000Z", environment="staging", channel="candidate", production_uploaded=False)

    discovery = discover_production_publisher_reports(root)

    assert discovery["valid"], discovery["issues"]
    assert discovery["selectedReportCount"] == 2
    assert discovery["selectedPublisherReports"] == [str(newer), str(civic)]
    assert any(item["path"] == str(older) for item in discovery["supersededReports"])
    assert len(discovery["skippedReports"]) == 1


def test_gateway_release_prefers_higher_train_number_when_pack_version_ties(tmp_path: Path):
    root = tmp_path / "publisher"
    train29 = _publisher_report_path(
        root,
        "occupation_foundation",
        "20260628T000000Z",
        report_dir="train-29-production-remote-r2",
    )
    train101 = _publisher_report_path(
        root,
        "occupation_foundation",
        "20260628T000000Z",
        report_dir="train-101-env-backed-production-remote-r2",
    )

    discovery = discover_production_publisher_reports(root)

    assert discovery["valid"], discovery["issues"]
    assert discovery["selectedPublisherReports"] == [str(train101)]
    assert any(item["path"] == str(train29) for item in discovery["supersededReports"])


def test_gateway_release_dry_run_generates_allowlist_without_deploy(tmp_path: Path):
    root = tmp_path / "publisher"
    _publisher_report_path(root, "education_credentialing", "20260628T000000Z")

    result = run_public_gateway_release(
        PublicGatewayReleaseOptions(
            publisher_report_root=root,
            output_root=tmp_path / "release",
            created_at=CREATED_AT,
            worker_allowlist_path=tmp_path / "worker" / "allowed-object-keys.generated.js",
        )
    )

    assert result["valid"], result["issues"]
    assert result["selectedPublisherReportCount"] == 1
    assert result["allowedObjectKeyCount"] == 5
    assert result["deployReport"]["attempted"] is False
    assert result["liveVerification"] is None
    artifact = read_json(Path(result["outputPaths"]["allowlistArtifact"]))
    assert artifact["allowedObjectKeyCount"] == 5


def test_gateway_release_validates_native_registry_coherence(tmp_path: Path):
    root = tmp_path / "publisher"
    education = _publisher_report_path(root, "education_credentialing", "20260628T000000Z")
    civic = _publisher_report_path(root, "public_civic_requirements", "20260628T041500Z")
    registry = _native_registry_artifact(
        tmp_path / "source-atlas-public-refresh-targets.json",
        [
            ("education_credentialing", "20260628T000000Z"),
            ("public_civic_requirements", "20260628T041500Z"),
        ],
    )

    discovery = discover_production_publisher_reports(root)
    gate = validate_native_registry_coherence(
        registry_path=registry,
        selected_reports=discovery["selectedReports"],
    )
    result = run_public_gateway_release(
        PublicGatewayReleaseOptions(
            publisher_report_root=root,
            output_root=tmp_path / "release",
            created_at=CREATED_AT,
            worker_allowlist_path=tmp_path / "worker" / "allowed-object-keys.generated.js",
            native_registry_artifact_path=registry,
        )
    )

    assert gate["valid"], gate["issues"]
    assert gate["matchedTargetCount"] == 2
    assert result["valid"], result["issues"]
    assert result["nativeRegistryCoherenceGate"]["matchedTargetCount"] == 2
    assert {item["publisherReport"] for item in result["nativeRegistryCoherenceGate"]["matches"]} == {str(education), str(civic)}


def test_gateway_release_blocks_native_registry_pack_mismatch(tmp_path: Path):
    root = tmp_path / "publisher"
    _publisher_report_path(root, "education_credentialing", "20260628T000000Z")
    registry = _native_registry_artifact(
        tmp_path / "source-atlas-public-refresh-targets.json",
        [("education_credentialing", "20260627T000000Z")],
    )

    result = run_public_gateway_release(
        PublicGatewayReleaseOptions(
            publisher_report_root=root,
            output_root=tmp_path / "release",
            created_at=CREATED_AT,
            worker_allowlist_path=tmp_path / "worker" / "allowed-object-keys.generated.js",
            native_registry_artifact_path=registry,
        )
    )

    assert not result["valid"]
    assert any("does not match selected publisher report" in issue for issue in result["issues"])


def test_gateway_release_blocks_deploy_without_execute(tmp_path: Path):
    root = tmp_path / "publisher"
    _publisher_report_path(root, "education_credentialing", "20260628T000000Z")
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
            execute=False,
        )
    )

    assert not result["valid"]
    assert "Worker deploy requires --execute" in result["issues"]
    assert result["deployReport"]["attempted"] is False


def test_gateway_live_verifier_checks_allowlist_hashes_and_private_blocks(tmp_path: Path):
    root = tmp_path / "publisher"
    report = _publisher_report_path(root, "education_credentialing", "20260628T000000Z")
    release = run_public_gateway_release(
        PublicGatewayReleaseOptions(
            publisher_report_root=root,
            output_root=tmp_path / "release",
            created_at=CREATED_AT,
            worker_allowlist_path=tmp_path / "worker" / "allowed-object-keys.generated.js",
        )
    )

    responses = _responses_for_report(report)

    def fake_request(_base_url: str, path: str, method: str):
        if "goal_text=" in path or "/users/" in path:
            return 404, b"Not found", {}
        if method == "HEAD":
            return 200, b"", {"X-Source-Atlas-Public-Reference": "true"}
        body = responses[path]
        return 200, body, {"X-Source-Atlas-Public-Reference": "true"}

    verification = verify_public_gateway(
        allowlist_path=Path(release["outputPaths"]["allowlistArtifact"]),
        publisher_reports=(report,),
        base_url="https://example.invalid",
        created_at=CREATED_AT,
        worker_version_id="fixture-version",
        request_fn=fake_request,
    )

    assert verification["valid"], verification["issues"]
    assert verification["headCheckCount"] == 5
    assert verification["publicCheckCount"] == 3
    assert verification["blockedChecksPassed"] is True


def _publisher_report_path(
    root: Path,
    domain: str,
    version: str,
    *,
    environment: str = "production",
    channel: str = "stable",
    production_uploaded: bool = True,
    report_dir: str | None = None,
) -> Path:
    report_root = root / (report_dir or f"{domain}-{version}")
    report_root.mkdir(parents=True, exist_ok=True)
    path = report_root / "r2-publisher-report.json"
    key_root = f"source-atlas/v1/{environment}/{channel}/{domain}"
    current_body = _body("current", domain, version)
    manifest_body = _body("manifest", domain, version)
    pack_body = _body("pack", domain, version)
    lkg_body = _body("lkg", domain, version)
    revocations_body = _body("revocations", domain, version)
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
        "productionR2Uploaded": production_uploaded,
        "checks": [
            {"name": "pack_artifacts_valid", "passed": True, "issues": []},
            {"name": "upload_readback_checksums", "passed": True, "issues": []},
        ],
        "currentPointer": {
            "kind": "ambitions.sourceAtlas.currentPackPointer.v1",
            "environment": environment,
            "channel": channel,
            "packID": f"source-atlas/v1/domain/{domain}/{version}",
            "packVersion": version,
            "manifestKey": f"{key_root}/{version}/manifest.json",
            "manifestSHA256": _sha(manifest_body),
            "packSHA256": _sha(pack_body),
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
                "expectedSHA256": _sha(current_body),
                "actualSHA256": _sha(current_body),
            },
            "readbackResults": [
                _readback("lkg", f"{key_root}/lkg.json", lkg_body),
                _readback("manifest", f"{key_root}/{version}/manifest.json", manifest_body),
                _readback("pack", f"{key_root}/{version}/pack.json", pack_body),
                _readback("revocations", f"{key_root}/revocations.json", revocations_body),
            ],
        },
        "issues": [],
        "privacyBoundary": "public/reference/freshness only; no private life graph, goals, captures, calendar data, proof, receipts, personalization, behavior history, or private user context",
        "nonClaims": ["not a private user-data backend", "not a final user plan, schedule, or Step generator"],
    }
    path.write_text(json.dumps(report, indent=2, sort_keys=True), encoding="utf-8")
    return path


def _native_registry_artifact(path: Path, targets: list[tuple[str, str]]) -> Path:
    entries = [
        {
            "status": "active",
            "allowedModes": ["startup"],
            "target": {
                "id": f"source-atlas-refresh-target.{domain}.stable.{version}",
                "domainID": domain,
                "targetPackID": f"source-atlas/v1/domain/{domain}/{version}",
                "environment": "production",
                "channel": "stable",
                "schemaVersion": "1.0.0",
                "appVersion": "1.0",
                "publicLocale": "en-US",
            },
            "nonClaims": ["not a private user-data backend", "not a final user plan, schedule, or Step generator"],
        }
        for domain, version in targets
    ]
    artifact = {
        "artifactID": "source_atlas_public_refresh_targets.fixture",
        "createdAt": CREATED_AT,
        "schemaVersion": 1,
        "publicReferenceOnly": True,
        "registry": {"entries": entries},
        "nonClaims": ["not a private user-data backend", "not a final user plan, schedule, or Step generator"],
    }
    path.write_text(json.dumps(artifact, indent=2, sort_keys=True), encoding="utf-8")
    return path


def _responses_for_report(path: Path) -> dict[str, bytes]:
    report = read_json(path)
    domain = report["packID"].split("/")[-2]
    version = report["packVersion"]
    return {
        report["operation"]["currentPointer"]["key"]: _body("current", domain, version),
        report["currentPointer"]["manifestKey"]: _body("manifest", domain, version),
        next(item["objectKey"] for item in report["operation"]["readbackResults"] if item["label"] == "pack"): _body("pack", domain, version),
    }


def _readback(label: str, object_key: str, body: bytes) -> dict[str, object]:
    sha = _sha(body)
    return {
        "label": label,
        "objectKey": object_key,
        "passed": True,
        "success": True,
        "expectedSHA256": sha,
        "actualSHA256": sha,
    }


def _body(label: str, domain: str, version: str) -> bytes:
    return f"{label}:{domain}:{version}".encode("utf-8")


def _sha(body: bytes) -> str:
    return hashlib.sha256(body).hexdigest()
