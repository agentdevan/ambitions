from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_maintenance_executor import (  # noqa: E402
    AutonomousMaintenanceExecutorOptions,
    run_autonomous_maintenance_executor,
)
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-29T03:15:00Z"


def test_maintenance_executor_writes_monitor_and_review_artifacts_when_safe_actions_enabled(tmp_path: Path):
    plan_path = _plan_path(tmp_path, _freshness_plan())

    result = _run(tmp_path, plan_path, execute_safe_actions=True)

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["workItemsProcessed"] == 2
    assert result["recordCounts"]["monitorSnapshotsWritten"] == 1
    assert result["recordCounts"]["reviewPacketsWritten"] == 1
    assert result["recordCounts"]["productionWritesExecuted"] == 0
    assert result["recordCounts"]["remoteMutations"] == 0
    assert result["recordCounts"]["nativeRuntimeMutations"] == 0
    assert result["recordCounts"]["finalOutputsGenerated"] == 0
    assert "autonomous_maintenance_executor_green" in result["allowedClaims"]
    assert "candidate_and_review_work_packets_written" in result["allowedClaims"]

    monitor = next(item for item in result["actionResults"] if item["domainID"] == "education_credentialing")
    review = next(item for item in result["actionResults"] if item["domainID"] == "volunteering_public_reference")
    assert monitor["status"] == "observed_snapshot_written"
    assert review["status"] == "executed_safe"
    assert all(Path(path).exists() for path in monitor["artifactPaths"] + review["artifactPaths"])


def test_maintenance_executor_holds_review_without_safe_action_flag(tmp_path: Path):
    plan_path = _plan_path(tmp_path, _freshness_plan())

    result = _run(tmp_path, plan_path, execute_safe_actions=False)

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["monitorSnapshotsWritten"] == 1
    assert result["recordCounts"]["reviewPacketsWritten"] == 0
    assert result["recordCounts"]["plannedNotExecuted"] == 1
    review = next(item for item in result["actionResults"] if item["domainID"] == "volunteering_public_reference")
    assert review["status"] == "planned_not_executed"
    assert review["artifactPaths"] == []


def test_maintenance_executor_writes_held_gate_packets_without_executing_production_work(tmp_path: Path):
    plan = _freshness_plan()
    plan["workItems"] = [
        _work_item("education_credentialing", "pack_rebuild", "pack", "pack_rebuild_needed", "pack_schema_license_provenance_private_scan"),
        _work_item("finance_public_reference", "r2_publish_gate", "r2_publish", "r2_publish_gate_needed", "execute_budget_owner_approval_credentials_upload_readback_sha256"),
        _work_item("health_wellness_reference", "native_runtime_recertification", "native_recertification", "recertification_needed", "focused_native_request_privacy_offline_no_account_tests"),
    ]
    plan_path = _plan_path(tmp_path, plan)

    result = _run(tmp_path, plan_path, execute_safe_actions=True)

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["heldGatePacketsWritten"] == 3
    assert result["recordCounts"]["productionWritesExecuted"] == 0
    assert result["recordCounts"]["liveHarvestsExecuted"] == 0
    assert result["recordCounts"]["remoteMutations"] == 0
    assert result["recordCounts"]["nativeRuntimeMutations"] == 0
    assert all(item["status"] == "blocked_by_gate_packet_written" for item in result["actionResults"])
    assert all(Path(path).exists() for item in result["actionResults"] for path in item["artifactPaths"])


def test_maintenance_executor_rejects_private_work_plan_before_execution(tmp_path: Path):
    plan = _freshness_plan()
    plan["workItems"][0]["domainID"] = "my schedule"
    plan_path = _plan_path(tmp_path, plan)

    result = _run(tmp_path, plan_path, execute_safe_actions=True)

    assert not result["valid"]
    assert result["privacyIssues"]
    assert any("first_person_private_context" in issue for issue in result["issues"])
    assert result["recordCounts"]["workItemsProcessed"] == 0


def _run(tmp_path: Path, plan_path: Path, *, execute_safe_actions: bool) -> dict:
    return run_autonomous_maintenance_executor(
        AutonomousMaintenanceExecutorOptions(
            freshness_plan_path=plan_path,
            output_root=tmp_path / f"maintenance-{len(list(tmp_path.glob('maintenance-*')))}",
            created_at=CREATED_AT,
            run_label="test-maintenance-executor",
            execute_safe_actions=execute_safe_actions,
        )
    )


def _plan_path(tmp_path: Path, plan: dict) -> Path:
    path = tmp_path / "freshness-plan.json"
    write_json(path, plan)
    return path


def _freshness_plan() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousFreshnessPlanner.v1",
        "valid": True,
        "planID": "source_atlas.autonomous_freshness_plan.test",
        "workItems": [
            _work_item("education_credentialing", "monitor_current_production", "monitor", "current", "next_due_review_or_freshness_window"),
            _work_item("volunteering_public_reference", "candidate_frontier_review", "review", "candidate_only_review_required", "frontier_governance_review"),
        ],
        "domainPlans": [
            {
                "domainID": "education_credentialing",
                "sourceIDs": ["education_credentialing.official_source"],
                "sourceReviewWindows": [
                    {
                        "sourceID": "education_credentialing.official_source",
                        "reviewStatus": "reviewed",
                        "nextReviewDueAt": "2026-09-29",
                        "windowState": "current",
                    }
                ],
                "legalWindows": [
                    {
                        "licenseID": "education_terms",
                        "packOutputAllowed": True,
                        "expiresAt": "2026-09-29",
                        "windowState": "current",
                    }
                ],
                "apiWindows": [
                    {
                        "apiPolicyID": "api.static_public_page.v1",
                        "apiReady": True,
                        "issues": [],
                    }
                ],
            }
        ],
        "privacyIssues": [],
        "nonClaims": ["not release readiness"],
    }


def _work_item(domain_id: str, action: str, queue: str, state: str, gate: str) -> dict:
    return {
        "domainID": domain_id,
        "nextAction": action,
        "queue": queue,
        "state": state,
        "requiredGate": gate,
        "sourceIDs": [] if domain_id == "volunteering_public_reference" else [f"{domain_id}.official_source"],
        "reasons": ["test reason"],
        "productionWriteExecuted": False,
        "liveHarvestExecuted": False,
        "remoteMutation": False,
        "nativeRuntimeMutation": False,
        "finalOutputGenerated": False,
    }
