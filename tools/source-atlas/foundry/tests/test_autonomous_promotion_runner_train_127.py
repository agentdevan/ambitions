from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_promotion_runner import (  # noqa: E402
    AutonomousPromotionRunnerOptions,
    run_autonomous_promotion_runner,
)
from foundry.model import write_json  # noqa: E402
from foundry.r2_owner_approval import REQUIRED_EXECUTION_GATES  # noqa: E402


CREATED_AT = "2026-06-29T03:45:00Z"
DOMAINS = ("education_credentialing", "finance_public_reference")
BUCKET = "ambitions-source-atlas-prod"


def test_promotion_runner_reconciles_monitor_and_candidate_review_without_mutation(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "autonomous_promotion_control_ready"
    assert result["recordCounts"]["promotionDecisions"] == 2
    assert result["recordCounts"]["monitorOnlyDecisions"] == 1
    assert result["recordCounts"]["candidateReviewOnlyDecisions"] == 1
    assert result["recordCounts"]["r2WritesExecuted"] == 0
    assert result["recordCounts"]["remoteMutations"] == 0
    assert result["recordCounts"]["nativeRuntimeMutations"] == 0
    assert result["recordCounts"]["finalOutputsGenerated"] == 0
    assert "autonomous_promotion_control_green" in result["allowedClaims"]
    assert "candidate_and_review_domains_remain_non_packable" in result["allowedClaims"]
    monitor = next(item for item in result["promotionDecisions"] if item["domainID"] == "education_credentialing")
    candidate = next(item for item in result["promotionDecisions"] if item["domainID"] == "volunteering_public_reference")
    assert monitor["promotionState"] == "monitor_only_current"
    assert monitor["r2State"] == "existing_remote_upload_readback_reconciled"
    assert candidate["promotionState"] == "candidate_or_source_review_only"
    assert "review-only action cannot emit claims, packs, or R2 writes" in candidate["blockers"]


def test_promotion_runner_holds_r2_publish_gate_without_execute(tmp_path: Path):
    paths = _fixture_paths(tmp_path, maintenance_queue=[_r2_gate_item("education_credentialing")])

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["heldGateDecisions"] == 1
    assert result["recordCounts"]["promotionCommands"] == 1
    assert result["recordCounts"]["r2HeldCommands"] == 1
    assert result["recordCounts"]["r2ExecutePreflightCommands"] == 0
    assert result["recordCounts"]["r2WritesExecuted"] == 0
    decision = result["promotionDecisions"][0]
    assert decision["promotionState"] == "r2_publish_execute_gate_held"
    assert decision["r2State"] == "held_execute_flag_required"
    assert "execute-r2 flag was not supplied" in decision["blockers"]
    command = result["promotionCommandQueue"][0]
    assert command["status"] == "held"
    assert "--execute" not in command["argv"]


def test_promotion_runner_emits_execute_preflight_command_without_writing(tmp_path: Path):
    paths = _fixture_paths(tmp_path, maintenance_queue=[_r2_gate_item("education_credentialing")])

    result = _run(tmp_path, paths, execute_r2=True)

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["r2ExecutePreflightCommands"] == 1
    assert result["recordCounts"]["r2WritesExecuted"] == 0
    assert result["recordCounts"]["remoteMutations"] == 0
    assert "r2_execute_preflight_commands_emitted_without_remote_write" in result["allowedClaims"]
    decision = result["promotionDecisions"][0]
    assert decision["promotionState"] == "r2_execute_preflight_command_ready"
    assert decision["r2State"] == "execute_preflight_ready_command_emitted_no_write"
    command = result["promotionCommandQueue"][0]
    assert command["status"] == "execute_preflight_ready_not_executed"
    assert "--execute" in command["argv"]
    assert command["productionWriteExecuted"] is False


def test_promotion_runner_blocks_execute_r2_without_owner_approval(tmp_path: Path):
    paths = _fixture_paths(tmp_path, maintenance_queue=[_r2_gate_item("education_credentialing")])
    paths["owner"] = None

    result = _run(tmp_path, paths, execute_r2=True)

    assert not result["valid"]
    assert any("execute-r2 requires a valid owner approval artifact" in issue for issue in result["issues"])
    assert result["recordCounts"]["r2WritesExecuted"] == 0
    decision = result["promotionDecisions"][0]
    assert decision["promotionState"] == "r2_publish_execute_gate_held"
    assert "owner approval artifact is invalid" in decision["blockers"]


def test_promotion_runner_rejects_private_domain_before_decisions(tmp_path: Path):
    paths = _fixture_paths(tmp_path, maintenance_queue=[_monitor_item("my schedule")])

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert result["privacyIssues"]
    assert any("first_person_private_context" in issue or "schedule_or_capacity" in issue for issue in result["issues"])
    assert result["recordCounts"]["promotionDecisions"] == 0


def _run(tmp_path: Path, paths: dict[str, Path | None], *, execute_r2: bool = False) -> dict:
    return run_autonomous_promotion_runner(
        AutonomousPromotionRunnerOptions(
            supervisor_report_path=paths["supervisor"],
            production_sweep_path=paths["sweep"],
            owner_approval_path=paths["owner"],
            legal_terms_registry_path=paths["legal_registry"],
            api_governance_registry_path=paths["api_registry"],
            legal_approval_packet_path=paths["legal_packet"],
            output_root=tmp_path / f"promotion-{len(list(tmp_path.glob('promotion-*')))}",
            created_at=CREATED_AT,
            run_label="test-promotion",
            bucket=BUCKET,
            execute_r2=execute_r2,
        )
    )


def _fixture_paths(tmp_path: Path, *, maintenance_queue: list[dict] | None = None) -> dict[str, Path | None]:
    root = tmp_path / "fixtures"
    paths = {
        "supervisor": root / "supervisor.json",
        "sweep": root / "sweep.json",
        "owner": root / "owner-approval.json",
        "legal_registry": root / "legal-terms-registry.json",
        "api_registry": root / "api-governance-registry.json",
        "legal_packet": root / "legal-approval-packet.json",
    }
    write_json(paths["supervisor"], _supervisor(maintenance_queue))
    write_json(paths["sweep"], _sweep())
    write_json(paths["owner"], _owner_approval())
    write_json(paths["legal_registry"], _legal_registry())
    write_json(paths["api_registry"], _api_registry())
    write_json(paths["legal_packet"], _legal_packet())
    return paths


def _supervisor(maintenance_queue: list[dict] | None) -> dict:
    queue = maintenance_queue if maintenance_queue is not None else [
        _monitor_item("education_credentialing"),
        _candidate_item("volunteering_public_reference"),
    ]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousProductionSupervisor.v1",
        "valid": True,
        "recordCounts": {"configuredDomains": 2, "workQueueItems": len(queue), "productionWritesExecuted": 0, "remoteMutations": 0},
        "queueCounts": {"productionWritesExecuted": 0, "remoteMutations": 0, "nativeRuntimeMutations": 0, "finalOutputsGenerated": 0},
        "maintenanceCounts": {"productionWritesExecuted": 0, "remoteMutations": 0, "nativeRuntimeMutations": 0, "finalOutputsGenerated": 0},
        "maintenanceQueue": queue,
        "workQueue": [],
        "issues": [],
        "privacyIssues": [],
        "allowedClaims": ["supervised_autonomous_source_atlas_work_loop_green"],
        "blockedClaims": ["release_green", "literal_universal_coverage", "outside_legal_approval"],
    }


def _monitor_item(domain_id: str) -> dict:
    return {
        "domainID": domain_id,
        "nextAction": "monitor_current_production",
        "status": "observed_snapshot_written",
        "requiredGate": "next_due_review_or_freshness_window",
        "artifactPaths": [f"tools/source-atlas/generated/autonomous-production-supervisor/test/monitor/{domain_id}/monitor-snapshot.json"],
        "productionWriteExecuted": False,
        "remoteMutation": False,
        "nativeRuntimeMutation": False,
        "finalOutputGenerated": False,
    }


def _candidate_item(domain_id: str) -> dict:
    return {
        "domainID": domain_id,
        "nextAction": "candidate_frontier_review",
        "status": "executed_safe",
        "requiredGate": "frontier_governance_review",
        "artifactPaths": [f"tools/source-atlas/generated/autonomous-production-supervisor/test/review/{domain_id}/review-packet.json"],
        "productionWriteExecuted": False,
        "remoteMutation": False,
        "nativeRuntimeMutation": False,
        "finalOutputGenerated": False,
    }


def _r2_gate_item(domain_id: str) -> dict:
    return {
        "domainID": domain_id,
        "nextAction": "r2_publish_gate",
        "status": "blocked_by_gate_packet_written",
        "requiredGate": "execute_budget_owner_approval_credentials_upload_readback_sha256",
        "artifactPaths": [f"tools/source-atlas/generated/autonomous-production-supervisor/test/held/{domain_id}/gate-packet.json"],
        "productionWriteExecuted": False,
        "remoteMutation": False,
        "nativeRuntimeMutation": False,
        "finalOutputGenerated": False,
    }


def _sweep() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionSweep.v1",
        "valid": True,
        "recordCounts": {"configuredDomains": 2, "domainsReady": 2, "domainsBlocked": 0, "remoteR2UploadsReconciled": 2, "privacyIssues": 0},
        "domains": [_sweep_domain(domain) for domain in DOMAINS],
        "futureRemoteWritePreflight": {
            "kind": "ambitions.sourceAtlas.futureRemoteWritePreflight.v1",
            "environment": "production",
            "readyForNewRemoteWrite": True,
            "blockedReasons": [],
            "wranglerInstalled": True,
            "credentialsAvailable": True,
            "credentialEnvNameCount": 3,
            "credentialGroupsPresent": ["cloudflare_control", "cloudflare_r2_access_pair"],
            "bucketConfigured": True,
            "bucketSource": "explicit",
            "currentProductionBucketsObserved": [BUCKET],
            "approvalArtifactPresent": True,
            "legalApprovalPacketPresent": True,
            "secretValuesPrinted": False,
        },
        "allowedClaims": ["future_remote_r2_write_preflight_ready"],
        "blockedClaims": ["release_green", "literal_universal_coverage", "outside_legal_approval"],
        "issues": [],
        "privacyIssues": [],
    }


def _sweep_domain(domain_id: str) -> dict:
    version = "20260628T000000Z"
    return {
        "domainID": domain_id,
        "ready": True,
        "packableClaimCount": 3,
        "sourceIDs": [f"{domain_id}.official_source"],
        "pack": {
            "path": f"tools/source-atlas/generated/pack-production/{domain_id}/pack-production-report.json",
            "valid": True,
            "issues": [],
            "packID": f"source-atlas/v1/domain/{domain_id}/{version}",
        },
        "r2": {
            "path": f"tools/source-atlas/generated/r2-publisher/{domain_id}/r2-publisher-report.json",
            "valid": True,
            "remoteUploadReadbackReady": True,
            "manifestKey": f"source-atlas/v1/production/stable/{domain_id}/{version}/manifest.json",
            "currentKey": f"source-atlas/v1/production/stable/{domain_id}/current.json",
            "issues": [],
        },
        "issues": [],
    }


def _owner_approval() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionR2OwnerApproval.v1",
        "approved": True,
        "approvalStatus": "approved_for_future_bounded_configured_public_reference_r2_write_preflight",
        "environment": "production",
        "channel": "stable",
        "bucket": BUCKET,
        "domainScopes": [
            {
                "domainID": domain,
                "environment": "production",
                "channel": "stable",
                "approvedObjectKeyPrefix": f"source-atlas/v1/production/stable/{domain}/",
                "approvedCurrentPointerKey": f"source-atlas/v1/production/stable/{domain}/current.json",
                "approvedLKGPointerKey": f"source-atlas/v1/production/stable/{domain}/lkg.json",
                "approvedRevocationKey": f"source-atlas/v1/production/stable/{domain}/revocations.json",
            }
            for domain in DOMAINS
        ],
        "requiredExecutionGates": sorted(REQUIRED_EXECUTION_GATES),
        "outsideLegalApprovalClaimed": False,
        "releaseGreenClaimed": False,
        "literalUniversalCoverageClaimed": False,
        "privacyIssues": [],
        "issues": [],
    }


def _legal_registry() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.legalTermsRegistry.v1",
        "schema_version": "1.0.0",
        "licenses": [{"license_id": f"{domain}.terms", "pack_output_allowed": True} for domain in DOMAINS],
    }


def _api_registry() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.apiGovernanceRegistry.v1",
        "schema_version": "1.0.0",
        "api_policies": [{"api_policy_id": "api.static_public_page.v1", "key_required": False}],
    }


def _legal_packet() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.legalTermsApprovalPacket.v1",
        "status": "Green",
        "outsideLegalApprovalClaimed": False,
        "releaseGreenClaimed": False,
        "literalUniversalCoverageClaimed": False,
    }
