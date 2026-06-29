from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_freshness_scheduler import (  # noqa: E402
    AutonomousFreshnessPlannerOptions,
    run_autonomous_freshness_planner,
)
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-29T03:00:00Z"
DOMAINS = ("education_credentialing", "finance_public_reference")


def test_freshness_planner_monitors_current_domains_and_queues_candidate_review(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "freshness_review_workplan_ready"
    assert result["recordCounts"]["configuredDomains"] == 2
    assert result["recordCounts"]["candidateDomains"] == 1
    assert result["queueCounts"]["monitorItems"] == 2
    assert result["queueCounts"]["reviewItems"] == 1
    assert result["queueCounts"]["productionWritesExecuted"] == 0
    assert result["queueCounts"]["liveHarvestsExecuted"] == 0
    assert result["queueCounts"]["remoteMutations"] == 0
    assert result["queueCounts"]["nativeRuntimeMutations"] == 0
    assert result["queueCounts"]["finalOutputsGenerated"] == 0
    assert "autonomous_freshness_review_work_planning_green" in result["allowedClaims"]
    assert "candidate_frontier_review_work_queued" in result["allowedClaims"]
    assert "release_green" in result["blockedClaims"]

    candidate = next(item for item in result["candidatePlans"] if item["domainID"] == "volunteering_public_reference")
    assert candidate["state"] == "candidate_only_review_required"
    assert candidate["requiredGate"] == "frontier_governance_review"


def test_freshness_planner_routes_source_review_due_inside_lookahead(tmp_path: Path):
    paths = _fixture_paths(tmp_path, include_supervisor=False)
    source_registry = read_json(paths["source_registry"])
    source_registry["source_lanes"][0]["next_review_due_at"] = "2026-07-10"
    write_json(paths["source_registry"], source_registry)

    result = _run(tmp_path, paths)

    plan = _domain_plan(result, "education_credentialing")
    assert result["valid"], result["issues"]
    assert plan["nextAction"] == "source_lane_review"
    assert plan["queue"] == "review"
    assert plan["sourceReviewWindows"][0]["windowState"] == "due_soon"
    assert result["queueCounts"]["reviewItems"] == 1


def test_freshness_planner_routes_terms_review_for_expiring_license(tmp_path: Path):
    paths = _fixture_paths(tmp_path, include_supervisor=False)
    legal_registry = read_json(paths["legal_registry"])
    legal_registry["licenses"][1]["expires_at"] = "2026-07-01"
    write_json(paths["legal_registry"], legal_registry)

    result = _run(tmp_path, paths)

    plan = _domain_plan(result, "finance_public_reference")
    assert result["valid"], result["issues"]
    assert plan["nextAction"] == "terms_review"
    assert plan["queue"] == "review"
    assert plan["legalWindows"][0]["windowState"] == "due_soon"


def test_freshness_planner_routes_pack_and_r2_gate_without_executing_writes(tmp_path: Path):
    paths = _fixture_paths(tmp_path, include_supervisor=False)
    sweep = read_json(paths["sweep"])
    sweep["domains"][0]["pack"]["valid"] = False
    sweep["domains"][0]["pack"]["issues"] = ["manifest hash missing"]
    sweep["domains"][1]["r2"]["remoteUploadReadbackReady"] = False
    sweep["domains"][1]["r2"]["issues"] = ["readback proof missing"]
    write_json(paths["sweep"], sweep)

    result = _run(tmp_path, paths)

    education = _domain_plan(result, "education_credentialing")
    finance = _domain_plan(result, "finance_public_reference")
    assert result["valid"], result["issues"]
    assert education["nextAction"] == "pack_rebuild"
    assert education["queue"] == "pack"
    assert finance["nextAction"] == "r2_publish_gate"
    assert finance["queue"] == "r2_publish"
    assert result["queueCounts"]["packItems"] == 1
    assert result["queueCounts"]["r2PublishGateItems"] == 1
    assert result["queueCounts"]["productionWritesExecuted"] == 0
    assert result["queueCounts"]["remoteMutations"] == 0


def _run(tmp_path: Path, paths: dict[str, Path]) -> dict:
    return run_autonomous_freshness_planner(
        AutonomousFreshnessPlannerOptions(
            frontier_config_path=paths["frontier"],
            source_lane_registry_path=paths["source_registry"],
            legal_terms_registry_path=paths["legal_registry"],
            api_governance_registry_path=paths["api_registry"],
            production_target_ledger_path=paths["ledger"],
            production_recertification_path=paths["recertification"],
            production_sweep_path=paths["sweep"],
            autonomous_production_supervisor_path=paths.get("supervisor"),
            output_root=tmp_path / f"freshness-{len(list(tmp_path.glob('freshness-*')))}",
            created_at=CREATED_AT,
            run_label="test-freshness-planner",
            lookahead_days=30,
        )
    )


def _domain_plan(result: dict, domain_id: str) -> dict:
    return next(item for item in result["domainPlans"] if item["domainID"] == domain_id)


def _fixture_paths(tmp_path: Path, *, include_supervisor: bool = True) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {
        "frontier": root / "coverage-frontiers.json",
        "source_registry": root / "source-lane-registry.json",
        "legal_registry": root / "legal-terms-registry.json",
        "api_registry": root / "api-governance-registry.json",
        "ledger": root / "production-target-ledger.json",
        "recertification": root / "production-recertification.json",
        "sweep": root / "production-sweep.json",
    }
    if include_supervisor:
        paths["supervisor"] = root / "autonomous-production-supervisor.json"
    write_json(paths["frontier"], _frontiers())
    write_json(paths["source_registry"], _source_registry())
    write_json(paths["legal_registry"], _legal_registry())
    write_json(paths["api_registry"], _api_registry())
    write_json(paths["ledger"], _ledger())
    write_json(paths["recertification"], _recertification())
    write_json(paths["sweep"], _sweep())
    if include_supervisor:
        write_json(paths["supervisor"], _supervisor())
    return paths


def _frontiers() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.coverageFrontiers.v1",
        "schema_version": "1.0.0",
        "frontiers": [
            {
                "frontier_id": "education_credentialing",
                "domain": "education_credentialing",
                "source_ids": ["education_credentialing.official_source"],
                "claim_classes": ["credential_requirement"],
                "jurisdictions": ["US"],
                "freshness_slas": ["quarterly_source_review"],
            },
            {
                "frontier_id": "finance_public_reference",
                "domain": "finance_public_reference",
                "source_ids": ["finance_public_reference.official_source"],
                "claim_classes": ["public_financial_reference"],
                "jurisdictions": ["US"],
                "freshness_slas": ["quarterly_source_review"],
            },
        ],
    }


def _source_registry() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.sourceLaneRegistry.v1",
        "schema_version": "1.0.0",
        "source_lanes": [
            _source_lane("education_credentialing", "education_terms"),
            _source_lane("finance_public_reference", "finance_terms"),
        ],
    }


def _source_lane(domain: str, license_id: str) -> dict:
    return {
        "source_id": f"{domain}.official_source",
        "review_status": "reviewed",
        "next_review_due_at": "2026-09-29",
        "license_id": license_id,
        "api_policy_id": "api.static_public_page.v1",
        "freshness_sla": "quarterly_source_review",
        "redistribution_policy": "redistributable_with_attribution",
        "r2_pack_policy": "pack_allowed_with_attribution",
    }


def _legal_registry() -> dict:
    return {
        "kind": "ambitions.sourceAtlas.legalTermsRegistry.v1",
        "schema_version": "1.0.0",
        "licenses": [
            _license("education_terms"),
            _license("finance_terms"),
        ],
    }


def _license(license_id: str) -> dict:
    return {
        "license_id": license_id,
        "pack_output_allowed": True,
        "attribution_required": True,
        "outside_legal_required": False,
        "outside_legal_status": "not_claimed",
        "expires_at": "2026-09-29",
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
                "rate_limit_per_second": 1,
                "daily_budget_limit": 50,
            }
        ],
    }


def _ledger() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "domains": [_ledger_domain(domain) for domain in DOMAINS],
    }


def _ledger_domain(domain: str) -> dict:
    return {
        "domainID": domain,
        "readinessStatus": "bounded_production_target_ready",
        "claimGraphProofComplete": True,
        "packableClaimCount": 3,
        "blockedReasons": [],
    }


def _recertification() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionRecertificationGate.v1",
        "valid": True,
        "domains": [
            {"domainID": domain, "recertified": True, "blockers": []}
            for domain in DOMAINS
        ],
    }


def _sweep() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionSweep.v1",
        "valid": True,
        "domains": [_sweep_domain(domain) for domain in DOMAINS],
    }


def _sweep_domain(domain: str) -> dict:
    return {
        "domainID": domain,
        "ready": True,
        "issues": [],
        "pack": {"valid": True, "issues": [], "packID": f"source-atlas/v1/domain/{domain}/20260628T000000Z"},
        "r2": {
            "valid": True,
            "issues": [],
            "remoteUploadReadbackReady": True,
            "manifestKey": f"source-atlas/v1/production/stable/{domain}/20260628T000000Z/manifest.json",
        },
    }


def _supervisor() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousProductionSupervisor.v1",
        "valid": True,
        "workQueue": [
            {
                "domainID": "volunteering_public_reference",
                "nextAction": "define_coverage_frontier",
                "state": "executed_safe_local_or_candidate_action",
                "requiredGate": "frontier_governance_review",
                "executed": True,
                "safeAction": True,
                "artifactPaths": ["tools/source-atlas/generated/frontier-intake/volunteering_public_reference/frontier-intake.json"],
                "blockers": ["coverage_frontier_missing"],
            }
        ],
    }
