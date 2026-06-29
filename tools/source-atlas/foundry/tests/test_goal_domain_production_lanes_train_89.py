from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.goal_domain_production_lanes import (
    CANDIDATE_ROUTE_STAGES,
    CONFIGURED_BLOCKED_STAGES,
    READY_ROUTE_STAGES,
    GoalDomainProductionLaneOptions,
    compile_goal_domain_production_lanes,
)
from foundry.goal_domain_router import GoalDomainRouterOptions, compile_goal_domain_router
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"
FIXTURE_PATH = Path("tools/source-atlas/fixtures/goal-domain-router/train-88-goal-domain-requests.json")
LEDGER_PATH = Path("tools/source-atlas/generated/production-target-ledger/train-86/production-target-ledger.json")


def test_goal_domain_production_lanes_compile_ready_and_candidate_work_orders(tmp_path: Path):
    router = _compile_router(tmp_path / "router")
    result = _compile_lanes(tmp_path / "lanes", Path(router["manifestPath"]))

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for goal-domain production-lane work-order tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; autonomous production-lane work orders only"
    assert result["recordCounts"]["routes"] == 3
    assert result["recordCounts"]["productionReadyRoutes"] == 1
    assert result["recordCounts"]["candidateRoutes"] == 2
    assert result["recordCounts"]["configuredBlockedRoutes"] == 0
    assert result["recordCounts"]["workOrders"] == len(READY_ROUTE_STAGES) + 2 * len(CANDIDATE_ROUTE_STAGES)
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert result["recordCounts"]["finalOutputArtifacts"] == 0
    assert _check(result, "candidate_routes_have_complete_gate_work_orders")
    assert _check(result, "work_orders_default_to_no_live_or_execute")
    assert _check(result, "work_orders_emit_no_claims_packs_r2_or_native_activation")

    lanes = read_json(Path(result["outputRoot"]) / "goal-domain-production-lanes.json")
    summaries = {item["requestID"]: item for item in lanes["laneSummaries"]}
    assert summaries["known-education-credentialing"]["lane"] == "ready_public_reference_runtime_lane"
    assert summaries["known-education-credentialing"]["workOrderCount"] == len(READY_ROUTE_STAGES)
    assert summaries["known-education-credentialing"]["ledgerEvidence"]["r2ProductionProofComplete"] is True
    assert summaries["new-language-learning-public-reference"]["lane"] == "candidate_domain_expansion_lane"
    assert summaries["new-language-learning-public-reference"]["candidateSourceCount"] == 2
    assert summaries["ambiguous-public-program-reference"]["lane"] == "candidate_domain_expansion_lane"
    assert summaries["ambiguous-public-program-reference"]["candidateSourceCount"] == 1


def test_goal_domain_production_lanes_candidate_orders_are_gated_and_non_executing(tmp_path: Path):
    router = _compile_router(tmp_path / "router")
    result = _compile_lanes(tmp_path / "lanes", Path(router["manifestPath"]))
    orders = read_json(Path(result["outputRoot"]) / "domain-work-orders.json")["workOrders"]

    candidate_orders = [order for order in orders if order["lane"] == "candidate_domain_expansion_lane"]
    assert len(candidate_orders) == 2 * len(CANDIDATE_ROUTE_STAGES)
    assert all(order["defaultMode"] == "fixture_or_dry_run" for order in orders)
    assert all(order["liveAllowed"] is False for order in orders)
    assert all(order["executeAllowed"] is False for order in orders)
    assert all(order["emitsClaims"] is False for order in orders)
    assert all(order["emitsPackOutput"] is False for order in orders)
    assert all(order["writesR2"] is False for order in orders)
    assert all(order["activatesNativeRuntime"] is False for order in orders)

    language_orders = [order for order in candidate_orders if order["requestID"] == "new-language-learning-public-reference"]
    assert {order["stage"] for order in language_orders} == {stage for stage, _ in CANDIDATE_ROUTE_STAGES}
    r2_gate = next(order for order in language_orders if order["stage"] == "r2_publish_gate")
    assert r2_gate["requiresApprovalArtifact"] is True
    assert "r2_publish_owner_approval" in r2_gate["requiredEvidence"]
    assert sorted(r2_gate["candidateSourceIDs"]) == [
        "candidate_source.702962ae5d7c1538",
        "candidate_source.85bb4e608bcf1482",
    ]


def test_goal_domain_production_lanes_do_not_promote_configured_domain_without_ledger(tmp_path: Path):
    missing_ledger = tmp_path / "missing-ledger.json"
    router = compile_goal_domain_router(
        GoalDomainRouterOptions(
            input_path=FIXTURE_PATH,
            output_root=tmp_path / "router",
            production_target_ledger_path=missing_ledger,
            created_at=CREATED_AT,
        )
    )
    result = _compile_lanes(tmp_path / "lanes", Path(router["manifestPath"]), production_target_ledger_path=missing_ledger)

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["productionReadyRoutes"] == 0
    assert result["recordCounts"]["configuredBlockedRoutes"] == 1
    assert result["recordCounts"]["workOrders"] == len(CONFIGURED_BLOCKED_STAGES) + 2 * len(CANDIDATE_ROUTE_STAGES)
    lanes = read_json(Path(result["outputRoot"]) / "goal-domain-production-lanes.json")
    known = next(item for item in lanes["laneSummaries"] if item["requestID"] == "known-education-credentialing")
    assert known["lane"] == "configured_frontier_blocked_lane"
    assert known["productionTargetReady"] is False
    assert "production_target_ledger_domain_not_ready" in known["blockedBy"]


def test_goal_domain_production_lanes_reject_invalid_router_manifest(tmp_path: Path):
    manifest_path = tmp_path / "invalid-router-manifest.json"
    write_json(
        manifest_path,
        {
            "valid": False,
            "outputPaths": {},
        },
    )

    result = compile_goal_domain_production_lanes(
        GoalDomainProductionLaneOptions(
            router_manifest_path=manifest_path,
            output_root=tmp_path / "lanes",
            production_target_ledger_path=LEDGER_PATH,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "router_manifest_valid")
    assert any("router manifest must be valid" in issue for issue in result["issues"])


def test_goal_domain_production_lanes_stable_ordering_is_deterministic(tmp_path: Path):
    router = _compile_router(tmp_path / "router")
    first = _compile_lanes(tmp_path / "first", Path(router["manifestPath"]))
    second = _compile_lanes(tmp_path / "second", Path(router["manifestPath"]))

    first_orders = read_json(Path(first["outputRoot"]) / "domain-work-orders.json")["workOrders"]
    second_orders = read_json(Path(second["outputRoot"]) / "domain-work-orders.json")["workOrders"]
    assert [order["orderID"] for order in first_orders] == [order["orderID"] for order in second_orders]
    assert first_orders == sorted(first_orders, key=lambda item: (item["requestID"], item["stageIndex"], item["orderID"]))


def _compile_router(tmp_path: Path) -> dict[str, object]:
    return compile_goal_domain_router(
        GoalDomainRouterOptions(
            input_path=FIXTURE_PATH,
            output_root=tmp_path,
            production_target_ledger_path=LEDGER_PATH,
            created_at=CREATED_AT,
        )
    )


def _compile_lanes(
    tmp_path: Path,
    router_manifest_path: Path,
    *,
    production_target_ledger_path: Path | None = LEDGER_PATH,
) -> dict[str, object]:
    return compile_goal_domain_production_lanes(
        GoalDomainProductionLaneOptions(
            router_manifest_path=router_manifest_path,
            output_root=tmp_path,
            production_target_ledger_path=production_target_ledger_path,
            created_at=CREATED_AT,
        )
    )


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
