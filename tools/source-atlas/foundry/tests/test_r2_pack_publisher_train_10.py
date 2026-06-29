from __future__ import annotations

import json
import sys
from pathlib import Path
from shutil import copyfile

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

import foundry.r2_pack_publisher as publisher_module
from foundry import r2_operations_proof
from foundry.claim_frontier import ClaimFrontierOptions, compile_claim_frontier
from foundry.harvest_runner import GovernedHarvestOptions, run_governed_harvest
from foundry.model import read_json
from foundry.pack_production import PackProductionOptions, build_pack_production
from foundry.production_domain_admission import ProductionDomainAdmissionOptions, build_production_domain_admission
from foundry.r2_owner_approval import R2_OWNER_APPROVAL_KIND, REQUIRED_EXECUTION_GATES
from foundry.r2_operations_proof import run_r2_operations_proof
from foundry.r2_pack_publisher import PackR2PublisherOptions, run_pack_r2_publisher
from foundry.terms_approval_packet import build_terms_approval_packet
from foundry.terms_registry import terms_entry


CREATED_AT = "2026-06-27T00:00:00Z"
SOURCE_ID = "nara.constitution.presidency"
DOMAIN = "public_civic_requirements"


def test_pack_r2_publisher_dry_run_validates_generalized_pack_without_writes(tmp_path: Path):
    pack_root = _civic_pack(tmp_path)
    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="staging",
            channel="candidate",
            mode="dry_run",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for R2 publisher gate harness"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; R2 publisher tooling only"
    assert result["productionR2Uploaded"] is False
    assert result["realR2CredentialsUsed"] is False
    assert result["operation"]["executed"] is False
    assert result["operation"]["dryRun"] is True
    assert result["operation"]["wouldUpdateCurrentPointer"] is True
    assert result["currentPointer"]["manifestSHA256"]
    assert "not production R2 upload proof" in result["nonClaims"]
    assert Path(result["outputPaths"]["requestPrivacy"]).exists()
    assert result["r2Environment"]["secretValuesPrinted"] is False
    assert result["realR2CredentialsUsed"] is False
    assert result["operation"]["executed"] is False


def test_pack_r2_publisher_local_simulation_uploads_readback_then_updates_current(tmp_path: Path):
    pack_root = _civic_pack(tmp_path)
    manifest = read_json(pack_root / "manifest.json")
    store_root = tmp_path / "local-r2"
    previous_lkg = store_root / manifest["object_keys"]["lkg"]
    previous_lkg.parent.mkdir(parents=True)
    previous_lkg.write_text('{"previous":"safe-lkg"}\n', encoding="utf-8")

    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="staging",
            channel="candidate",
            mode="local_simulation",
            created_at=CREATED_AT,
            execute=True,
            budget_policy="budget.source_atlas.train_10.local",
            local_store_root=store_root,
        )
    )

    assert result["valid"], result["issues"]
    operation = result["operation"]
    assert operation["executed"] is True
    assert operation["success"] is True
    assert operation["currentPointer"]["updated"] is True
    assert operation["previousPointers"]["lastKnownGood"]["exists"] is True
    assert all(item["passed"] for item in operation["readbackResults"])

    current_key = manifest["object_keys"]["current"]
    current_pointer = store_root / current_key
    assert current_pointer.exists()
    assert read_json(current_pointer)["manifestKey"] == manifest["object_keys"]["manifest"]
    assert read_json(Path(result["outputPaths"]["uploadReadback"]))["currentPointer"]["updated"] is True


def test_pack_r2_publisher_blocks_production_stable_execute_without_approval(tmp_path: Path):
    pack_root = _civic_pack(tmp_path, environment="production", channel="stable")
    legal_packet = _legal_packet(tmp_path)
    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="production",
            channel="stable",
            mode="local_simulation",
            created_at=CREATED_AT,
            execute=True,
            budget_policy="budget.source_atlas.train_10.local",
            legal_approval_packet=legal_packet,
            local_store_root=tmp_path / "local-r2",
        )
    )

    assert not result["valid"]
    assert "production/stable execute requires --approval-artifact" in result["issues"]
    assert next(check for check in result["checks"] if check["name"] == "execute_gate")["passed"] is False
    assert result["operation"]["executed"] is False


def test_pack_r2_publisher_blocks_production_stable_without_legal_approval_packet(tmp_path: Path):
    pack_root = _civic_pack(tmp_path, environment="production", channel="stable")
    owner_approval = _owner_approval(tmp_path)
    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="production",
            channel="stable",
            mode="local_simulation",
            created_at=CREATED_AT,
            execute=True,
            approval_artifact=owner_approval,
            budget_policy="budget.source_atlas.train_10.local",
            local_store_root=tmp_path / "local-r2",
        )
    )

    assert not result["valid"]
    assert "production/stable R2 publisher requires --legal-approval-packet" in result["issues"]
    assert next(check for check in result["checks"] if check["name"] == "legal_terms_approval_packet_valid")["passed"] is False
    assert result["operation"]["executed"] is False


def test_pack_r2_publisher_production_stable_accepts_legal_packet_then_simulates_write(tmp_path: Path):
    pack_root = _civic_pack(tmp_path, environment="production", channel="stable")
    owner_approval = _owner_approval(tmp_path)
    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="production",
            channel="stable",
            mode="local_simulation",
            created_at=CREATED_AT,
            execute=True,
            approval_artifact=owner_approval,
            legal_approval_packet=_legal_packet(tmp_path),
            budget_policy="budget.source_atlas.train_10.local",
            local_store_root=tmp_path / "local-r2",
            production_target_ledger_path=_production_target_ledger(tmp_path, [DOMAIN]),
        )
    )

    assert result["valid"], result["issues"]
    assert result["legalTermsApprovalPacketValidation"]["valid"]
    assert result["operation"]["executed"] is True
    assert result["operation"]["currentPointer"]["updated"] is True


def test_pack_r2_publisher_remote_r2_uploads_readbacks_then_updates_current(tmp_path: Path, monkeypatch):
    pack_root = _civic_pack(tmp_path, environment="production", channel="stable")
    owner_approval = _owner_approval(tmp_path)
    env_file = _remote_env_file(tmp_path)
    remote_store = tmp_path / "fake-remote"
    monkeypatch.setattr(publisher_module, "_run_wrangler", _fake_wrangler(remote_store))

    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="production",
            channel="stable",
            mode="remote_r2",
            created_at=CREATED_AT,
            execute=True,
            approval_artifact=owner_approval,
            legal_approval_packet=_legal_packet(tmp_path),
            budget_policy="budget.source_atlas.train_29.remote",
            readback_root=tmp_path / "readback",
            production_target_ledger_path=_production_target_ledger(tmp_path, [DOMAIN]),
            env_file_paths=(env_file,),
        )
    )

    encoded = json.dumps(result, sort_keys=True)
    assert result["valid"], result["issues"]
    assert result["productionR2Uploaded"] is True
    assert result["realR2CredentialsUsed"] is True
    assert result["r2Environment"]["bucketSource"] == "env"
    assert result["r2Environment"]["credentialEnvNamesPresent"] == [
        "CLOUDFLARE_API_TOKEN",
        "CLOUDFLARE_R2_ACCESS_KEY_ID",
        "CLOUDFLARE_R2_SECRET_ACCESS_KEY",
    ]
    assert result["r2Environment"]["secretValuesPrinted"] is False
    assert "fixture-cloudflare-token-value" not in encoded
    assert "fixture-access-key-value" not in encoded
    assert "fixture-secret-key-value" not in encoded
    assert result["operation"]["remoteR2"] is True
    assert result["operation"]["currentPointer"]["updated"] is True
    assert all(item["passed"] for item in result["operation"]["readbackResults"])
    assert "not production R2 upload proof" not in result["nonClaims"]


def test_pack_r2_publisher_blocks_remote_r2_execute_without_production_target_ledger(tmp_path: Path, monkeypatch):
    pack_root = _civic_pack(tmp_path, environment="production", channel="stable")
    owner_approval = _owner_approval(tmp_path)
    env_file = _remote_env_file(tmp_path)
    remote_store = tmp_path / "fake-remote"
    monkeypatch.setattr(publisher_module, "_run_wrangler", _fake_wrangler(remote_store))

    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="production",
            channel="stable",
            mode="remote_r2",
            created_at=CREATED_AT,
            execute=True,
            approval_artifact=owner_approval,
            legal_approval_packet=_legal_packet(tmp_path),
            budget_policy="budget.source_atlas.train_86.remote",
            readback_root=tmp_path / "readback",
            env_file_paths=(env_file,),
        )
    )

    assert not result["valid"]
    assert result["operation"]["executed"] is False
    assert "production target ledger is required for this activation path" in result["issues"]
    check = next(check for check in result["checks"] if check["name"] == "production_target_ledger_gate")
    assert check["passed"] is False


def test_pack_r2_publisher_remote_r2_requires_bucket(tmp_path: Path):
    pack_root = _civic_pack(tmp_path, environment="production", channel="stable")
    owner_approval = _owner_approval(tmp_path)
    env_file = _remote_env_file(tmp_path, include_bucket=False)
    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="production",
            channel="stable",
            mode="remote_r2",
            created_at=CREATED_AT,
            execute=True,
            approval_artifact=owner_approval,
            legal_approval_packet=_legal_packet(tmp_path),
            budget_policy="budget.source_atlas.train_29.remote",
            env_file_paths=(env_file,),
        )
    )

    assert not result["valid"]
    assert "remote_r2 execute requires --bucket or SOURCE_ATLAS_R2_PRODUCTION_BUCKET" in result["issues"]
    assert result["operation"]["executed"] is False


def test_pack_r2_publisher_blocks_malformed_owner_approval_artifact(tmp_path: Path):
    pack_root = _civic_pack(tmp_path, environment="production", channel="stable")
    owner_approval = tmp_path / "owner-approval.json"
    owner_approval.write_text('{"approved":true}\n', encoding="utf-8")

    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="production",
            channel="stable",
            mode="local_simulation",
            created_at=CREATED_AT,
            execute=True,
            approval_artifact=owner_approval,
            legal_approval_packet=_legal_packet(tmp_path),
            budget_policy="budget.source_atlas.train_131.local",
            local_store_root=tmp_path / "local-r2",
            production_target_ledger_path=_production_target_ledger(tmp_path, [DOMAIN]),
        )
    )

    assert not result["valid"]
    assert next(check for check in result["checks"] if check["name"] == "owner_approval_artifact_valid")["passed"] is False
    assert any("owner approval kind is unsupported" in issue for issue in result["issues"])
    assert result["operation"]["executed"] is False


def test_pack_r2_publisher_initial_domain_admission_breaks_first_r2_write_cycle(tmp_path: Path):
    pack_root = _civic_pack(tmp_path, environment="production", channel="stable")
    legal_packet = _legal_packet(tmp_path)
    previous_ledger = _production_target_ledger(tmp_path, ["education_credentialing"])
    admission = build_production_domain_admission(
        ProductionDomainAdmissionOptions(
            domain=DOMAIN,
            pack_root=pack_root,
            output_root=tmp_path / "admission",
            frontier_config_path=_frontier_config(tmp_path),
            production_target_ledger_path=previous_ledger,
            legal_approval_packet=legal_packet,
            created_at=CREATED_AT,
        )
    )

    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="production",
            channel="stable",
            mode="local_simulation",
            created_at=CREATED_AT,
            execute=True,
            approval_artifact=Path(admission["outputPaths"]["report"]),
            legal_approval_packet=legal_packet,
            budget_policy="budget.source_atlas.train_131.initial",
            local_store_root=tmp_path / "local-r2",
            production_target_ledger_path=previous_ledger,
            production_domain_admission_path=Path(admission["outputPaths"]["report"]),
        )
    )

    assert admission["valid"], admission["issues"]
    assert result["valid"], result["issues"]
    assert result["productionTargetLedgerGate"]["admissionFallbackUsed"] is True
    assert result["productionTargetLedgerGate"]["admissionGateValid"] is True
    assert result["ownerApprovalArtifactValidation"]["valid"] is True
    assert result["operation"]["executed"] is True
    assert result["operation"]["currentPointer"]["updated"] is True


def test_pack_r2_publisher_does_not_update_current_pointer_on_corrupt_readback(tmp_path: Path):
    pack_root = _civic_pack(tmp_path)
    manifest = read_json(pack_root / "manifest.json")
    store_root = tmp_path / "local-r2"
    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="staging",
            channel="candidate",
            mode="local_simulation",
            created_at=CREATED_AT,
            execute=True,
            budget_policy="budget.source_atlas.train_10.local",
            local_store_root=store_root,
            corrupt_readback_label="manifest",
        )
    )

    assert not result["valid"]
    assert any("readback checksum mismatch" in issue for issue in result["issues"])
    assert result["operation"]["currentPointer"]["updated"] is False
    assert not (store_root / manifest["object_keys"]["current"]).exists()


def test_pack_r2_publisher_rejects_private_object_key_before_simulated_write(tmp_path: Path):
    pack_root = _civic_pack(tmp_path)
    plan_path = pack_root / "r2-dry-run-plan.json"
    plan = read_json(plan_path)
    plan["objects"][0]["objectKey"] = "source-atlas/v1/staging/candidate/users/private-goal-pack/pack.json"
    plan_path.write_text(json.dumps(plan, indent=2, sort_keys=True), encoding="utf-8")

    result = run_pack_r2_publisher(
        PackR2PublisherOptions(
            pack_root=pack_root,
            output_root=tmp_path / "publisher",
            environment="staging",
            channel="candidate",
            mode="local_simulation",
            created_at=CREATED_AT,
            execute=True,
            budget_policy="budget.source_atlas.train_10.local",
            local_store_root=tmp_path / "local-r2",
        )
    )

    assert not result["valid"]
    assert any("private_r2_object_key_segment" in issue for issue in result["issues"])
    assert result["operation"]["executed"] is False
    assert not (tmp_path / "local-r2").exists()


def test_r2_operations_proof_accepts_current_pack_manifest_provenance(tmp_path: Path, monkeypatch):
    monkeypatch.setattr(r2_operations_proof.shutil, "which", lambda _: None)
    pack_root = _civic_pack(tmp_path, environment="production", channel="stable")

    proof = run_r2_operations_proof(
        mode="dry-run",
        environment="production",
        bundle_root=pack_root,
        channel="stable",
        env={},
    )

    assert proof["status"] == "Yellow"
    promotion_gate = next(check for check in proof["checks"] if check["name"] == "promotion_gate")
    assert promotion_gate["passed"] is True, promotion_gate
    assert len(proof["objectKeyShape"]) >= 10
    assert "missing receipt index" not in json.dumps(proof["checks"])


def test_r2_operations_proof_loads_explicit_env_file_without_secret_values(tmp_path: Path, monkeypatch):
    monkeypatch.setattr(r2_operations_proof.shutil, "which", lambda _: None)
    pack_root = _civic_pack(tmp_path, environment="production", channel="stable")
    env_file = tmp_path / ".env"
    env_file.write_text(
        "\n".join(
            [
                "SOURCE_ATLAS_R2_PRODUCTION_BUCKET=fixture-source-atlas-bucket",
                "CLOUDFLARE_API_TOKEN=fixture-cloudflare-token-value",
                "CLOUDFLARE_R2_ACCESS_KEY_ID=fixture-access-key-value",
                "CLOUDFLARE_R2_SECRET_ACCESS_KEY=fixture-secret-key-value",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    proof = run_r2_operations_proof(
        mode="dry-run",
        environment="production",
        bundle_root=pack_root,
        channel="stable",
        env_file_paths=[env_file],
    )

    encoded = json.dumps(proof, sort_keys=True)
    assert proof["status"] == "Yellow"
    assert proof["bucket"] == "fixture-source-atlas-bucket"
    assert proof["credentialHandling"]["available"] is True
    assert proof["credentialHandling"]["envFilesLoaded"] == [".env"]
    assert proof["credentialHandling"]["envNamesPresent"] == [
        "CLOUDFLARE_API_TOKEN",
        "CLOUDFLARE_R2_ACCESS_KEY_ID",
        "CLOUDFLARE_R2_SECRET_ACCESS_KEY",
    ]
    assert proof["credentialHandling"]["secretValuesPrinted"] is False
    assert "fixture-cloudflare-token-value" not in encoded
    assert "fixture-access-key-value" not in encoded
    assert "fixture-secret-key-value" not in encoded
    assert proof["logRedaction"]["passed"], proof["logRedaction"]


def _civic_pack(tmp_path: Path, *, environment: str = "staging", channel: str = "candidate") -> Path:
    harvest = run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / f"governed-harvest-{environment}-{channel}",
            run_id=f"nara-civic-{environment}-{channel}",
            mode="fixture",
            source_ids=[SOURCE_ID],
            limit=6,
            created_at=CREATED_AT,
        ),
        env={},
    )
    assert harvest["valid"], harvest["issues"]
    frontier = compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=Path(harvest["runRoot"]),
            output_root=tmp_path / f"claim-frontier-{environment}-{channel}",
            created_at=CREATED_AT,
        )
    )
    assert frontier["valid"], frontier["issues"]
    pack = build_pack_production(
        PackProductionOptions(
            input_root=Path(frontier["outputRoot"]),
            output_root=tmp_path / f"pack-production-{environment}-{channel}",
            domain=DOMAIN,
            environment=environment,
            channel=channel,
            created_at=CREATED_AT,
            legal_approval_packet=_legal_packet(tmp_path) if environment == "production" or channel == "stable" else None,
        )
    )
    assert pack["valid"], pack["issues"]
    return Path(pack["outputRoot"])


def _legal_packet(tmp_path: Path) -> Path:
    path = tmp_path / "nara-legal-approval.json"
    if not path.exists():
        build_terms_approval_packet([terms_entry(SOURCE_ID)], output_path=path, created_at=CREATED_AT)
    return path


def _owner_approval(tmp_path: Path, *, domain: str = DOMAIN, bucket: str = "ambitions-source-atlas-prod") -> Path:
    path = tmp_path / f"{domain}-owner-approval.json"
    prefix = f"source-atlas/v1/production/stable/{domain}/"
    approval = {
        "schemaVersion": 1,
        "kind": R2_OWNER_APPROVAL_KIND,
        "approvalID": f"source-atlas/test-owner-approval/{domain}",
        "approvalType": "test_scoped_public_reference_production_r2_write",
        "approvalStatus": "approved_for_test_public_reference_r2_write",
        "approved": True,
        "createdAt": CREATED_AT,
        "environment": "production",
        "channel": "stable",
        "bucket": bucket,
        "domainScopes": [
            {
                "domainID": domain,
                "environment": "production",
                "channel": "stable",
                "approvedObjectKeyPrefix": prefix,
                "approvedCurrentPointerKey": f"{prefix}current.json",
                "approvedLKGPointerKey": f"{prefix}lkg.json",
                "approvedRevocationKey": f"{prefix}revocations.json",
                "sourceIDs": [SOURCE_ID],
            }
        ],
        "requiredExecutionGates": sorted(REQUIRED_EXECUTION_GATES),
        "outsideLegalApprovalClaimed": False,
        "releaseGreenClaimed": False,
        "literalUniversalCoverageClaimed": False,
        "privacyBoundary": "public/reference R2 object-key approval only",
        "nonClaims": ["not outside legal approval", "not Release Green", "not literal universal coverage"],
    }
    path.write_text(json.dumps(approval, indent=2, sort_keys=True), encoding="utf-8")
    return path


def _frontier_config(tmp_path: Path) -> Path:
    path = tmp_path / "coverage-frontiers.json"
    path.write_text(
        json.dumps(
            {
                "schemaVersion": 1,
                "kind": "ambitions.sourceAtlas.coverageFrontiers.v1",
                "frontiers": [
                    {
                        "frontier_id": DOMAIN,
                        "domain": DOMAIN,
                        "goal_intent_classes": ["public_civic_reference"],
                        "claim_classes": ["constitutional_requirement"],
                        "jurisdictions": ["US"],
                        "minimum_authority_classes": ["official_government"],
                        "source_ids": [SOURCE_ID],
                    }
                ],
            },
            indent=2,
            sort_keys=True,
        ),
        encoding="utf-8",
    )
    return path


def _production_target_ledger(tmp_path: Path, ready_domains: list[str]) -> Path:
    path = tmp_path / "production-target-ledger.json"
    ledger = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "ledgerID": "source-atlas/production-target-ledger/train-86-fixture",
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


def _remote_env_file(tmp_path: Path, *, include_bucket: bool = True) -> Path:
    path = tmp_path / "r2.env"
    lines = []
    if include_bucket:
        lines.append("SOURCE_ATLAS_R2_PRODUCTION_BUCKET=ambitions-source-atlas-prod")
    lines.extend(
        [
            "CLOUDFLARE_API_TOKEN=fixture-cloudflare-token-value",
            "CLOUDFLARE_R2_ACCESS_KEY_ID=fixture-access-key-value",
            "CLOUDFLARE_R2_SECRET_ACCESS_KEY=fixture-secret-key-value",
        ]
    )
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
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
