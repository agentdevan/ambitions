from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_production_supervisor import (  # noqa: E402
    AutonomousProductionSupervisorOptions,
    run_autonomous_production_supervisor,
)
from foundry.model import read_json, write_json  # noqa: E402
from foundry.r2_owner_approval import REQUIRED_EXECUTION_GATES  # noqa: E402


CREATED_AT = "2026-06-29T02:45:00Z"
DOMAINS = ("education_credentialing", "finance_public_reference")
VERSION = "20260628T000000Z"


def test_supervisor_observes_current_production_domains_without_mutation(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "supervised_autonomous_work_loop_ready"
    assert result["recordCounts"]["configuredDomains"] == 2
    assert result["recordCounts"]["plannedDomains"] == 2
    assert result["queueCounts"]["observed"] == 2
    assert result["queueCounts"]["executedSafe"] == 0
    assert result["queueCounts"]["productionWritesExecuted"] == 0
    assert result["queueCounts"]["remoteMutations"] == 0
    assert result["queueCounts"]["nativeRuntimeMutations"] == 0
    assert result["queueCounts"]["finalOutputsGenerated"] == 0
    assert "supervised_autonomous_source_atlas_work_loop_green" in result["allowedClaims"]
    assert "configured_production_domains_observed_without_mutation" in result["allowedClaims"]
    assert "release_green" in result["blockedClaims"]


def test_supervisor_executes_safe_candidate_frontier_intake_when_requested(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(
        tmp_path,
        paths,
        requested_domains=("volunteering_public_reference",),
        execute_safe_actions=True,
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["plannedDomains"] == 3
    assert result["queueCounts"]["observed"] == 2
    assert result["queueCounts"]["executedSafe"] == 1
    assert result["recordCounts"]["frontierIntakeArtifacts"] > 0
    assert "candidate_or_fixture_safe_actions_executed" in result["allowedClaims"]
    candidate = next(item for item in result["workQueue"] if item["domainID"] == "volunteering_public_reference")
    assert candidate["state"] == "executed_safe_local_or_candidate_action"
    assert candidate["executed"] is True
    assert all("frontier-intake" in path for path in candidate["artifactPaths"])


def test_supervisor_integrates_freshness_and_maintenance_when_registries_are_supplied(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(
        tmp_path,
        paths,
        requested_domains=("volunteering_public_reference",),
        execute_safe_actions=True,
        integrate_maintenance=True,
    )

    assert result["valid"], result["issues"]
    assert result["stageSummaries"]["freshnessPlanner"]["valid"] is True
    assert result["stageSummaries"]["maintenanceExecutor"]["valid"] is True
    assert result["recordCounts"]["freshnessWorkItems"] == 3
    assert result["recordCounts"]["maintenanceWorkItems"] == 3
    assert result["recordCounts"]["maintenanceMonitorSnapshots"] == 2
    assert result["recordCounts"]["maintenanceReviewPackets"] == 1
    assert result["maintenanceCounts"]["productionWritesExecuted"] == 0
    assert result["maintenanceCounts"]["remoteMutations"] == 0
    assert result["maintenanceCounts"]["nativeRuntimeMutations"] == 0
    assert result["maintenanceCounts"]["finalOutputsGenerated"] == 0
    assert "freshness_planning_and_local_maintenance_integrated" in result["allowedClaims"]
    assert "maintenance_artifacts_written_without_unsafe_mutation" in result["allowedClaims"]
    review = next(item for item in result["maintenanceQueue"] if item["domainID"] == "volunteering_public_reference")
    assert review["status"] == "executed_safe"
    assert all(Path(path).exists() for path in review["artifactPaths"])


def test_supervisor_integrates_promotion_control_when_approval_inputs_are_supplied(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(
        tmp_path,
        paths,
        requested_domains=("volunteering_public_reference",),
        execute_safe_actions=True,
        integrate_maintenance=True,
        integrate_promotion=True,
    )

    assert result["valid"], result["issues"]
    assert result["stageSummaries"]["promotionRunner"]["valid"] is True
    assert result["promotionCounts"]["promotionDecisions"] == 3
    assert result["promotionCounts"]["monitorOnlyDecisions"] == 2
    assert result["promotionCounts"]["candidateReviewOnlyDecisions"] == 1
    assert result["promotionCounts"]["r2WritesExecuted"] == 0
    assert result["promotionCounts"]["remoteMutations"] == 0
    assert result["promotionCounts"]["nativeRuntimeMutations"] == 0
    assert result["promotionCounts"]["finalOutputsGenerated"] == 0
    assert "promotion_control_integrated" in result["allowedClaims"]
    assert "promotion_decisions_emitted_without_remote_or_native_mutation" in result["allowedClaims"]


def test_supervisor_queues_candidate_intake_without_execute_safe_actions(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths, requested_domains=("volunteering_public_reference",))

    assert result["valid"], result["issues"]
    assert result["queueCounts"]["executedSafe"] == 0
    assert result["queueCounts"]["plannedNotExecuted"] == 1
    candidate = next(item for item in result["workQueue"] if item["domainID"] == "volunteering_public_reference")
    assert candidate["state"] == "queued_requires_execute_safe_actions"
    assert candidate["executed"] is False


def test_supervisor_blocks_when_cycle_attempts_remote_mutation(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    cycle = read_json(paths["cycle"])
    cycle["operationActions"][0]["mutatesRemote"] = True
    write_json(paths["cycle"], cycle)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _check(result, "production_orchestrator_valid")
    assert any("monitor action must not mutate remote state" in issue for issue in result["issues"])


def _run(
    tmp_path: Path,
    paths: dict[str, Path],
    *,
    requested_domains: tuple[str, ...] = (),
    execute_safe_actions: bool = False,
    integrate_maintenance: bool = False,
    integrate_promotion: bool = False,
) -> dict:
    return run_autonomous_production_supervisor(
        AutonomousProductionSupervisorOptions(
            frontier_config_path=paths["frontier"],
            source_lane_registry_path=paths["source_registry"],
            legal_terms_registry_path=paths["legal_registry"] if integrate_maintenance else None,
            api_governance_registry_path=paths["api_registry"] if integrate_maintenance else None,
            owner_approval_path=paths["owner_approval"] if integrate_promotion else None,
            legal_approval_packet_path=paths["legal_packet"] if integrate_promotion else None,
            promotion_bucket="ambitions-source-atlas-prod" if integrate_promotion else None,
            production_target_ledger_path=paths["ledger"],
            production_recertification_path=paths["recertification"],
            production_finish_line_gate_path=paths["finish_line"],
            production_sweep_path=paths["sweep"],
            arbitrary_domain_gate_path=paths["arbitrary"],
            goal_domain_gauntlet_path=paths["gauntlet"],
            autonomous_control_loop_path=paths["control_loop"],
            autonomous_cycle_path=paths["cycle"],
            requested_domains=requested_domains,
            output_root=tmp_path / f"supervisor-{len(list(tmp_path.glob('supervisor-*')))}",
            created_at=CREATED_AT,
            run_label="test-supervisor",
            execute_safe_actions=execute_safe_actions,
        )
    )


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {
        "frontier": root / "coverage-frontiers.json",
        "source_registry": root / "source-lane-registry.json",
        "legal_registry": root / "legal-terms-registry.json",
        "api_registry": root / "api-governance-registry.json",
        "owner_approval": root / "owner-approval.json",
        "legal_packet": root / "legal-approval-packet.json",
        "ledger": root / "production-target-ledger.json",
        "recertification": root / "production-recertification.json",
        "finish_line": root / "production-finish-line-gate.json",
        "sweep": root / "production-sweep.json",
        "arbitrary": root / "arbitrary-domain-gate.json",
        "gauntlet": root / "goal-domain-gauntlet.json",
        "control_loop": root / "autonomous-control-loop.json",
        "cycle": root / "autonomous-cycle.json",
    }
    write_json(paths["frontier"], _frontier_config())
    write_json(paths["source_registry"], _source_registry())
    write_json(paths["legal_registry"], _legal_registry())
    write_json(paths["api_registry"], _api_registry())
    write_json(paths["owner_approval"], _owner_approval())
    write_json(paths["legal_packet"], _legal_packet())
    write_json(paths["ledger"], _ledger())
    write_json(paths["recertification"], _recertification())
    write_json(paths["finish_line"], _finish_line())
    write_json(paths["sweep"], _sweep())
    write_json(paths["arbitrary"], _arbitrary())
    write_json(paths["gauntlet"], _gauntlet())
    write_json(paths["control_loop"], _control_loop())
    write_json(paths["cycle"], _cycle())
    return paths


def _frontier_config() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.coverageFrontiers.v1",
        "schema_version": "1.0.0",
        "frontiers": [
            {
                "frontier_id": "education_credentialing",
                "domain": "education_credentialing",
                "goal_intent_classes": ["credential_reference"],
                "claim_classes": ["credential_requirement"],
                "jurisdictions": ["US"],
                "source_ids": ["education_credentialing.official_source"],
                "non_claims": ["not admissions guarantee"],
            },
            {
                "frontier_id": "finance_public_reference",
                "domain": "finance_public_reference",
                "goal_intent_classes": ["public_financial_reference"],
                "claim_classes": ["public_financial_education"],
                "jurisdictions": ["US"],
                "source_ids": ["finance_public_reference.official_source"],
                "non_claims": ["not financial advice"],
            },
        ],
    }


def _source_registry() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.sourceLaneRegistry.v1",
        "schema_version": "1.0.0",
        "source_lanes": [
            {
                "source_id": f"{domain}.official_source",
                "review_status": "reviewed",
                "next_review_due_at": "2026-09-29",
                "license_id": f"{domain}.terms",
                "api_policy_id": "api.static_public_page.v1",
                "freshness_sla": "quarterly_public_reference_recheck",
                "redistribution_policy": "redistributable_with_attribution",
                "r2_pack_policy": "pack_allowed_with_attribution",
            }
            for domain in DOMAINS
        ],
    }


def _legal_registry() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.legalTermsRegistry.v1",
        "schema_version": "1.0.0",
        "licenses": [
            {
                "license_id": f"{domain}.terms",
                "pack_output_allowed": True,
                "attribution_required": True,
                "outside_legal_required": False,
                "outside_legal_status": "not_claimed",
                "expires_at": "2026-09-29",
            }
            for domain in DOMAINS
        ],
    }


def _api_registry() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.apiGovernanceRegistry.v1",
        "schema_version": "1.0.0",
        "api_policies": [
            {
                "api_policy_id": "api.static_public_page.v1",
                "source_id": "static.public.page",
                "api_mode": "static_https_fixture_first",
                "key_required": False,
                "live_flag_required": True,
                "execute_flag_required": True,
                "secret_redaction_required": True,
                "high_volume_review_required": False,
                "daily_budget_limit": 50,
                "rate_limit_per_second": 1,
            }
        ],
    }


def _owner_approval() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionR2OwnerApproval.v1",
        "approved": True,
        "approvalStatus": "approved_for_future_bounded_configured_public_reference_r2_write_preflight",
        "environment": "production",
        "channel": "stable",
        "bucket": "ambitions-source-atlas-prod",
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


def _legal_packet() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.legalTermsApprovalPacket.v1",
        "status": "Green",
        "outsideLegalApprovalClaimed": False,
        "releaseGreenClaimed": False,
        "literalUniversalCoverageClaimed": False,
    }


def _ledger() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "overallReadinessStatus": "configured_frontiers_bounded_production_target_ready",
        "recordCounts": {
            "configuredFrontiers": 2,
            "boundedProductionTargetReady": 2,
            "configuredDomainsNotReady": 0,
            "orphanProductionDomains": 0,
        },
        "allowedClaims": ["bounded_production_target_for_configured_frontiers", "bounded_production_target_per_ready_frontier"],
        "blockedClaims": ["full_source_atlas_green", "outside_legal_approval", "release_green", "literal_universal_coverage"],
        "domains": [_ledger_domain(domain) for domain in DOMAINS],
        "issues": [],
    }


def _ledger_domain(domain: str) -> dict:
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
        "packableClaimCount": 3,
        "sourceIDs": [f"{domain}.official_source"],
        "blockedReasons": [],
    }


def _recertification() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionRecertification.v1",
        "valid": True,
        "recordCounts": {"recertifiedDomains": 2, "blockedDomains": 0},
        "domains": [{"domainID": domain, "recertified": True, "blockers": []} for domain in DOMAINS],
        "issues": [],
    }


def _finish_line() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionFinishLineGate.v1",
        "valid": True,
        "allowedClaims": [
            "bounded_configured_production_target",
            "internal_terms_review",
            "production_r2_write_readback",
            "bounded_live_transport",
            "bounded_configured_runtime_green",
            "gateway_native_runtime_recertification",
        ],
        "blockedClaims": ["outside_legal_approval", "runtime_green", "release_green", "universal_coverage"],
        "recordCounts": {"productionDomains": 2, "r2ReportsValid": 2, "r2ReportsBlocked": 0, "recertifiedDomains": 2},
        "issues": [],
    }


def _sweep() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionSweep.v1",
        "valid": True,
        "overallReadinessStatus": "current_configured_production_operational_sweep_green",
        "allowedClaims": [
            "current_configured_frontier_production_sweep",
            "current_remote_r2_upload_readback_reconciled",
            "governed_arbitrary_public_reference_domain_routing_reconciled",
            "representative_goal_domain_gauntlet_reconciled",
        ],
        "blockedClaims": ["full_source_atlas_green", "outside_legal_approval", "release_green", "literal_universal_coverage", "final_user_plans_schedules_steps_from_source_atlas_or_r2"],
        "recordCounts": {"configuredDomains": 2, "domainsReady": 2, "domainsBlocked": 0, "remoteR2UploadsReconciled": 2, "privacyIssues": 0},
        "domains": [_sweep_domain(domain) for domain in DOMAINS],
        "issues": [],
    }


def _sweep_domain(domain: str) -> dict:
    return {
        "domainID": domain,
        "ready": True,
        "issues": [],
        "pack": {
            "valid": True,
            "issues": [],
            "packID": f"source-atlas/v1/domain/{domain}/{VERSION}",
        },
        "r2": {
            "valid": True,
            "issues": [],
            "remoteUploadReadbackReady": True,
            "manifestKey": f"source-atlas/v1/production/stable/{domain}/{VERSION}/manifest.json",
        },
    }


def _arbitrary() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.arbitraryDomainHandlingGate.v1",
        "valid": True,
        "allowedClaims": ["governed_arbitrary_public_reference_domain_handling"],
        "blockedClaims": ["full_source_atlas_green", "outside_legal_approval", "release_green", "literal_universal_coverage", "final_user_plans_schedules_steps_from_source_atlas_or_r2"],
        "recordCounts": {"configuredFrontiers": 2, "candidateClaims": 0, "candidateProductionWrites": 0, "candidateR2PublishOperations": 0},
        "issues": [],
    }


def _gauntlet() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainGauntlet.v1",
        "valid": True,
        "allowedClaims": ["representative_goal_domain_gauntlet_green", "configured_frontier_goal_domain_runtime_routing", "unknown_public_reference_domains_candidate_only"],
        "blockedClaims": ["full_source_atlas_green", "outside_legal_approval", "release_green", "literal_universal_coverage", "final_user_plans_schedules_steps_from_source_atlas_or_r2"],
        "recordCounts": {"configuredFrontiers": 2, "configuredGauntletCases": 2, "configuredCasesPassed": 2, "configuredCasesBlocked": 0, "unknownCasesCandidateOnly": 2, "unknownCasesBlocked": 0, "finalOutputsGenerated": 0, "privacyIssues": 0},
        "issues": [],
    }


def _control_loop() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousControlLoop.v1",
        "valid": True,
        "allowedClaims": [
            "autonomous_control_loop_ready_for_configured_public_reference_domains",
            "r2_write_preflight_ready_execute_still_required",
            "unknown_domains_candidate_only_controlled",
            "release_legal_universal_claim_holds_enforced",
        ],
        "blockedClaims": ["full_source_atlas_green", "outside_legal_approval", "release_green", "literal_universal_coverage", "final_user_plans_schedules_steps_from_source_atlas_or_r2"],
        "recordCounts": {"configuredDomains": 2, "domainsReadyForMonitoring": 2, "domainsBlocked": 0, "automaticR2WritesAllowed": 0, "privacyIssues": 0},
        "issues": [],
    }


def _cycle() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousCycleRunner.v1",
        "valid": True,
        "cycleID": "source_atlas.autonomous_cycle.test",
        "cycleFingerprint": "cycle-fixture",
        "allowedClaims": [
            "autonomous_operations_cycle_ready_for_recurring_public_reference_runs",
            "configured_domain_monitor_actions_emitted",
            "execute_gated_r2_actions_held",
            "unknown_domain_candidate_intake_cycle_controlled",
        ],
        "blockedClaims": [
            "full_source_atlas_green",
            "outside_legal_approval",
            "release_green",
            "literal_universal_coverage",
            "automatic_r2_write_without_execute_budget_approval",
            "new_remote_r2_write_executed_by_cycle_runner",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        ],
        "recordCounts": {"operationActions": 7, "configuredDomainMonitorActions": 2, "finalOutputsGenerated": 0, "privacyIssues": 0},
        "operationActions": [
            *[_monitor_action(index, domain) for index, domain in enumerate(DOMAINS, start=1)],
            _r2_hold_action(),
            _unknown_action(),
            *_claim_holds(),
        ],
        "issues": [],
    }


def _monitor_action(order: int, domain: str) -> dict:
    return {
        "actionID": f"monitor-{domain}",
        "order": order,
        "actionKind": "monitor_current_production_runtime",
        "domainID": domain,
        "packID": f"source-atlas/v1/domain/{domain}/{VERSION}",
        "manifestKey": f"source-atlas/v1/production/stable/{domain}/{VERSION}/manifest.json",
        "sourceIDs": [f"{domain}.official_source"],
        "mutatesRemote": False,
        "mutatesNativeRuntime": False,
        "emitsFinalOutput": False,
        "issues": [],
    }


def _r2_hold_action() -> dict:
    return {"actionID": "hold-r2-write", "order": 3, "actionKind": "hold_new_remote_r2_write_until_execute_gate", "state": "held_execute_required", "requiresExecute": True, "mutatesRemote": False, "automaticWriteAllowed": False, "issues": []}


def _unknown_action() -> dict:
    return {"actionID": "unknown-domain", "order": 4, "actionKind": "route_unknown_public_reference_domain_to_candidate_intake", "state": "candidate_only", "emitsClaims": False, "emitsPack": False, "mutatesRemote": False, "issues": []}


def _claim_holds() -> list[dict]:
    return [
        {"actionID": "hold-release", "order": 5, "actionKind": "hold_release_green", "state": "held", "emitsClaims": False, "issues": []},
        {"actionID": "hold-legal", "order": 6, "actionKind": "hold_outside_legal_approval", "state": "held", "emitsClaims": False, "issues": []},
        {"actionID": "hold-universal", "order": 7, "actionKind": "hold_literal_universal_coverage", "state": "held", "emitsClaims": False, "issues": []},
    ]


def _check(result: dict, name: str) -> bool:
    return any(check["name"] == name and check["passed"] for check in result["checks"])
