from __future__ import annotations

import json
import sys
from pathlib import Path
from shutil import copyfile

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

import foundry.r2_pack_publisher as publisher_module  # noqa: E402
from foundry.model import read_json  # noqa: E402
from foundry.public_reference_delivery_chain import (  # noqa: E402
    DEFAULT_SOURCE_IDS,
    PublicReferenceDeliveryChainOptions,
    run_public_reference_delivery_chain,
)


CREATED_AT = "2026-06-28T00:00:00Z"


def test_public_reference_delivery_chain_runs_harvest_to_native_review_required_with_local_r2_simulation(tmp_path: Path):
    result = run_public_reference_delivery_chain(
        PublicReferenceDeliveryChainOptions(
            output_root=tmp_path / "delivery-chain",
            domain="occupation_foundation",
            source_ids=DEFAULT_SOURCE_IDS,
            limit=5,
            r2_mode="local_simulation",
            execute_r2=True,
            r2_budget_policy="budget.source_atlas.train_100.local",
            native_public_locale="en-US",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for public-reference delivery chain tooling"
    assert result["deliveryComplete"] is True
    assert result["productionR2Uploaded"] is False
    assert result["nativeActiveTargets"] is False
    assert result["recordCounts"]["packableClaims"] > 0
    assert result["recordCounts"]["r2PublishOperations"] == 1
    assert result["stages"]["r2Publisher"]["operation"]["executed"] is True
    assert result["stages"]["r2Publisher"]["operation"]["currentPointer"]["updated"] is True
    assert result["stages"]["nativeRefreshRegistry"]["targetCount"] == 1
    assert result["stages"]["nativeRefreshRegistry"]["reviewRequiredTargetCount"] == 1

    artifact = read_json(Path(result["outputPaths"]["nativeRefreshArtifact"]))
    entry = artifact["registry"]["entries"][0]
    assert entry["status"] == "review_required"
    assert entry["target"]["domainID"] == "occupation_foundation"
    assert "no production Cloudflare R2 upload/readback proof" in result["productionNonClaims"]


def test_public_reference_delivery_chain_dry_run_emits_native_target_without_local_store_write(tmp_path: Path):
    output_root = tmp_path / "delivery-chain"
    result = run_public_reference_delivery_chain(
        PublicReferenceDeliveryChainOptions(
            output_root=output_root,
            domain="occupation_foundation",
            source_ids=DEFAULT_SOURCE_IDS,
            limit=3,
            r2_mode="dry_run",
            execute_r2=False,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["deliveryComplete"] is True
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["stages"]["r2Publisher"]["operation"]["executed"] is False
    assert result["stages"]["r2Publisher"]["operation"]["dryRun"] is True
    assert not (output_root / "local-r2-store").exists()
    assert result["stages"]["nativeRefreshRegistry"]["targetCount"] == 1


def test_public_reference_delivery_chain_remote_r2_execute_stays_blocked_without_bucket(tmp_path: Path):
    result = run_public_reference_delivery_chain(
        PublicReferenceDeliveryChainOptions(
            output_root=tmp_path / "delivery-chain",
            domain="occupation_foundation",
            source_ids=DEFAULT_SOURCE_IDS,
            limit=3,
            r2_mode="remote_r2",
            execute_r2=True,
            r2_budget_policy="budget.source_atlas.train_100.remote",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert result["deliveryComplete"] is False
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert any("remote_r2 execute requires --bucket or SOURCE_ATLAS_R2_STAGING_BUCKET" in issue for issue in result["issues"])
    assert "nativeRefreshRegistry: stage did not run" in result["issues"]


def test_public_reference_delivery_chain_remote_r2_uses_env_file_for_bucket_and_credentials(tmp_path: Path, monkeypatch):
    env_file = _remote_env_file(tmp_path)
    remote_store = tmp_path / "fake-remote"
    monkeypatch.setattr(publisher_module, "_run_wrangler", _fake_wrangler(remote_store))

    result = run_public_reference_delivery_chain(
        PublicReferenceDeliveryChainOptions(
            output_root=tmp_path / "delivery-chain",
            domain="occupation_foundation",
            source_ids=DEFAULT_SOURCE_IDS,
            limit=3,
            r2_mode="remote_r2",
            execute_r2=True,
            r2_budget_policy="budget.source_atlas.train_101.remote",
            r2_env_file_paths=(env_file,),
            production_target_ledger_path=_production_target_ledger(tmp_path, ["occupation_foundation"]),
            native_public_locale="en-US",
            created_at=CREATED_AT,
        )
    )

    publisher = result["stages"]["r2Publisher"]
    encoded = json.dumps(result, sort_keys=True)
    assert result["valid"], result["issues"]
    assert result["deliveryComplete"] is True
    assert result["recordCounts"]["r2PublishOperations"] == 1
    assert result["productionR2Uploaded"] is False
    assert publisher["realR2CredentialsUsed"] is True
    assert publisher["r2Environment"]["bucketSource"] == "env"
    assert publisher["r2Environment"]["envFilesLoaded"] == ["r2.env"]
    assert publisher["operation"]["remoteR2"] is True
    assert publisher["operation"]["currentPointer"]["updated"] is True
    assert "fixture-cloudflare-token-value" not in encoded
    assert "fixture-access-key-value" not in encoded
    assert "fixture-secret-key-value" not in encoded


def test_public_reference_delivery_chain_preflight_rejects_private_context(tmp_path: Path):
    result = run_public_reference_delivery_chain(
        PublicReferenceDeliveryChainOptions(
            output_root=tmp_path / "delivery-chain",
            domain="occupation_foundation",
            source_ids=DEFAULT_SOURCE_IDS,
            native_public_locale="my schedule",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert any("first_person_private_context" in issue for issue in result["issues"])
    assert result["stageSummaries"] == {}


def _remote_env_file(tmp_path: Path) -> Path:
    path = tmp_path / "r2.env"
    path.write_text(
        "\n".join(
            [
                "SOURCE_ATLAS_R2_STAGING_BUCKET=ambitions-source-atlas-staging",
                "CLOUDFLARE_API_TOKEN=fixture-cloudflare-token-value",
                "CLOUDFLARE_R2_ACCESS_KEY_ID=fixture-access-key-value",
                "CLOUDFLARE_R2_SECRET_ACCESS_KEY=fixture-secret-key-value",
            ]
        )
        + "\n",
        encoding="utf-8",
    )
    return path


def _production_target_ledger(tmp_path: Path, ready_domains: list[str]) -> Path:
    path = tmp_path / "production-target-ledger.json"
    ledger = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "ledgerID": "source-atlas/production-target-ledger/train-101-fixture",
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


def _fake_wrangler(remote_store: Path):
    def run(args: list[str], *, env: dict[str, str] | None = None) -> dict[str, object]:
        command = args[3]
        bucket_and_key = args[4]
        _, object_key = bucket_and_key.split("/", 1)
        if command == "put":
            source = Path(args[args.index("--file") + 1])
            destination = remote_store / object_key
            destination.parent.mkdir(parents=True, exist_ok=True)
            copyfile(source, destination)
            return {"success": True, "returnCode": 0, "stdout": "fake upload", "stderr": ""}
        if command == "get":
            destination = Path(args[args.index("--file") + 1])
            source = remote_store / object_key
            if not source.exists():
                return {"success": False, "returnCode": 1, "stdout": "", "stderr": "not found"}
            destination.parent.mkdir(parents=True, exist_ok=True)
            copyfile(source, destination)
            return {"success": True, "returnCode": 0, "stdout": "fake readback", "stderr": ""}
        return {"success": False, "returnCode": 2, "stdout": "", "stderr": "unsupported fake command"}

    return run
