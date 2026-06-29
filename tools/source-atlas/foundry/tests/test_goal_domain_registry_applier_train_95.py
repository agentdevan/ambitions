from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.goal_domain_registry_applier import (
    GoalDomainRegistryApplierOptions,
    compile_goal_domain_registry_applier,
    write_goal_domain_registry_applier_report,
)
from foundry.model import read_json, write_json


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
TRAIN_94_EMPTY_PLAN = SOURCE_ATLAS_ROOT / "generated" / "goal-domain-registry-mutation-plan" / "train-94-fixture" / "planned-registry-mutations.json"
CREATED_AT = "2026-06-28T00:00:00Z"


def test_goal_domain_registry_applier_accepts_train_94_empty_plan_as_noop(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)

    result = compile_goal_domain_registry_applier(
        GoalDomainRegistryApplierOptions(
            plan_path=TRAIN_94_EMPTY_PLAN,
            output_root=tmp_path / "applier",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for goal-domain registry applier tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; goal-domain registry applier tooling only"
    assert result["recordCounts"]["goalDomainPlannedRegistryMutations"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert _check(result, "catalog_applier_reused")
    assert _check(result, "dry_run_writes_no_active_registries")


def test_goal_domain_registry_applier_dry_run_emits_candidate_registries_without_target_writes(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    plan_path = _write_goal_domain_plan(tmp_path, [_goal_domain_mutation()])

    result = compile_goal_domain_registry_applier(
        GoalDomainRegistryApplierOptions(
            plan_path=plan_path,
            output_root=tmp_path / "applier",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["goalDomainPlannedRegistryMutations"] == 1
    assert result["recordCounts"]["normalizedRegistryMutations"] == 1
    assert result["recordCounts"]["candidateRegistryMutations"] == 1
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert read_json(paths["source"])["source_lanes"] == []
    assert read_json(paths["legal"])["licenses"] == []
    assert read_json(paths["api"])["api_policies"] == []

    candidate_source = read_json(Path(result["outputPaths"]["candidateSourceLaneRegistry"]))
    assert candidate_source["source_lanes"][0]["source_id"] == "approved.goal_domain.fixture"
    normalized = read_json(Path(result["outputPaths"]["normalizedPlan"]))
    assert normalized["plannedRegistryMutations"][0]["mutation_id"] == "goal-domain-registry-mutation.fixture"


def test_goal_domain_registry_applier_execute_requires_approval_artifact(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    plan_path = _write_goal_domain_plan(tmp_path, [_goal_domain_mutation()])

    result = compile_goal_domain_registry_applier(
        GoalDomainRegistryApplierOptions(
            plan_path=plan_path,
            output_root=tmp_path / "applier",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            execute=True,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "approval_gate_passed")
    assert any("--approval-artifact" in issue for issue in result["issues"])
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert read_json(paths["source"])["source_lanes"] == []


def test_goal_domain_registry_applier_execute_writes_temp_registries_after_approval(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    plan_path = _write_goal_domain_plan(tmp_path, [_goal_domain_mutation()])
    approval_path = _write_approval(tmp_path)

    result = compile_goal_domain_registry_applier(
        GoalDomainRegistryApplierOptions(
            plan_path=plan_path,
            output_root=tmp_path / "applier",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            approval_artifact=approval_path,
            execute=True,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert _check(result, "approval_gate_passed")
    assert _check(result, "execute_blocked_until_wrapper_gates_pass")
    assert result["recordCounts"]["activeRegistryMutations"] == 1
    assert read_json(paths["source"])["source_lanes"][0]["source_id"] == "approved.goal_domain.fixture"
    assert read_json(paths["legal"])["licenses"][0]["license_id"] == "approved.goal_domain.fixture.terms"
    assert read_json(paths["api"])["api_policies"][0]["api_policy_id"] == "api.approved_goal_domain_fixture.v1"


def test_goal_domain_registry_applier_rejects_private_plan_without_writes(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    private_mutation = _goal_domain_mutation()
    private_mutation["goal_text"] = "Use this for my private schedule"
    plan_path = _write_goal_domain_plan(tmp_path, [private_mutation])

    result = compile_goal_domain_registry_applier(
        GoalDomainRegistryApplierOptions(
            plan_path=plan_path,
            output_root=tmp_path / "applier",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            execute=True,
            approval_artifact=_write_approval(tmp_path),
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "goal_domain_plan_privacy_scan_passed")
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert read_json(paths["source"])["source_lanes"] == []


def test_goal_domain_registry_applier_report_writer_emits_markdown_and_json(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    plan_path = _write_goal_domain_plan(tmp_path, [_goal_domain_mutation()])
    markdown_path = tmp_path / "source-atlas-goal-domain-registry-applier-train-95.md"
    json_path = tmp_path / "source-atlas-goal-domain-registry-applier-train-95.json"

    result = write_goal_domain_registry_applier_report(
        markdown_path,
        json_path,
        plan_path=plan_path,
        output_root=tmp_path / "applier",
        source_lane_registry_path=paths["source"],
        legal_terms_registry_path=paths["legal"],
        api_governance_registry_path=paths["api"],
        created_at=CREATED_AT,
    )

    assert result["valid"], result["issues"]
    assert markdown_path.exists()
    assert json_path.exists()
    assert "Source Atlas Goal-Domain Registry Applier Train 95" in markdown_path.read_text(encoding="utf-8")
    persisted = read_json(json_path)
    assert persisted["recordCounts"]["candidateRegistryMutations"] == 1
    assert persisted["recordCounts"]["activeRegistryMutations"] == 0


def _write_empty_registries(tmp_path: Path) -> dict[str, Path]:
    source = tmp_path / "source-lane-registry.json"
    legal = tmp_path / "legal-terms-registry.json"
    api = tmp_path / "api-governance-registry.json"
    write_json(
        source,
        {
            "kind": "ambitions.sourceAtlas.sourceLaneRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "source_lanes": [],
        },
    )
    write_json(
        legal,
        {
            "kind": "ambitions.sourceAtlas.legalTermsRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "licenses": [],
        },
    )
    write_json(
        api,
        {
            "kind": "ambitions.sourceAtlas.apiGovernanceRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "api_policies": [],
        },
    )
    return {"source": source, "legal": legal, "api": api}


def _write_goal_domain_plan(tmp_path: Path, mutations: list[dict[str, object]]) -> Path:
    path = tmp_path / "goal-domain-planned-registry-mutations.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.goalDomainPlannedRegistryMutations.v1",
            "createdAt": CREATED_AT,
            "plannedRegistryMutations": mutations,
            "nonClaims": ["fixture plan only", "not active registry mutation", "not R2 publish"],
        },
    )
    return path


def _write_approval(tmp_path: Path) -> Path:
    path = tmp_path / "goal-domain-registry-apply-approval.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.goalDomainRegistryApplyApproval.v1",
            "approvalStatus": "approved_for_fixture_temp_registry_apply",
            "approvedAt": CREATED_AT,
            "approvedBy": "Ambitions owner technical review fixture",
            "nonClaims": ["fixture approval only", "not outside legal approval", "not R2 publish"],
        },
    )
    return path


def _goal_domain_mutation() -> dict[str, object]:
    source_id = "approved.goal_domain.fixture"
    license_id = "approved.goal_domain.fixture.terms"
    api_policy_id = "api.approved_goal_domain_fixture.v1"
    return {
        "mutationID": "goal-domain-registry-mutation.fixture",
        "bundleID": "goal-domain-review-bundle.fixture",
        "requestID": "goal-domain-request.fixture",
        "requestedDomain": "education_credentialing",
        "matchedDomainID": "education_credentialing",
        "createdAt": CREATED_AT,
        "completionStatus": "completed_review_ready_for_registry_apply_planning",
        "status": "dry_run_ready_for_separate_registry_apply",
        "activeRegistryWritten": False,
        "sourceLaneEntry": {
            "source_id": source_id,
            "source_name": "Approved Goal Domain Fixture",
            "source_class": "official_government",
            "authority_class": "official_government",
            "jurisdiction": "US",
            "domain_scope": ["education_credentialing"],
            "claim_classes_allowed": ["public_reference_claim"],
            "claim_classes_forbidden": ["legal_advice", "personalized_plan"],
            "license_id": license_id,
            "license_url": "https://example.gov/license",
            "terms_url": "https://example.gov/terms",
            "rights_url": "https://example.gov/rights",
            "attribution_required": True,
            "redistribution_policy": "redistributable_with_attribution",
            "r2_pack_policy": "pack_allowed_with_attribution",
            "lookup_policy": "lookup_allowed_public_reference_only",
            "crosswalk_policy": "not_crosswalk_source",
            "review_status": "reviewed",
            "review_owner": "Ambitions owner technical review fixture",
            "last_reviewed_at": "2026-06-28",
            "next_review_due_at": "2026-12-28",
            "freshness_sla": "quarterly_public_reference_recheck",
            "api_mode": "static_https_fixture_first",
            "api_policy_id": api_policy_id,
            "rate_policy_id": "rate.approved_goal_domain_fixture.v1",
            "budget_policy_id": "budget.approved_goal_domain_fixture.v1",
            "secret_policy_id": "secret.no_secret_static_page.v1",
            "allowed_artifact_classes": [
                "official_public_source",
                "public_reference_claim",
                "public_requirement",
                "public_provenance",
            ],
            "forbidden_artifact_classes": [
                "final_user_path",
                "final_schedule",
                "step_list",
                "personalized_plan",
                "private_goal_graph",
            ],
            "non_claims": ["not legal advice", "not a personalized education plan", "not outside legal approval"],
            "schema_version": "1.0.0",
            "r2_object_key_prefix": "source-atlas/v1/stable/goal-domain-fixture",
        },
        "legalTermsEntry": {
            "license_id": license_id,
            "license_name": "Approved Goal Domain Fixture Terms",
            "license_url": "https://example.gov/license",
            "terms_url": "https://example.gov/terms",
            "rights_url": "https://example.gov/rights",
            "redistribution_allowed": True,
            "modification_allowed": False,
            "commercial_use_allowed": False,
            "attribution_required": True,
            "share_alike_required": False,
            "source_specific_restrictions": ["cite source URL"],
            "pack_output_allowed": True,
            "lookup_output_allowed": True,
            "review_required": False,
            "outside_legal_required": False,
            "outside_legal_status": "not_claimed",
            "approval_artifact_path": "",
            "effective_date": "2026-06-28",
            "reviewed_at": "2026-06-28",
            "review_owner": "Ambitions owner technical review fixture",
            "expires_at": "2026-12-28",
            "non_claims": ["not outside legal approval", "not legal advice"],
            "schema_version": "1.0.0",
        },
        "apiPolicyEntry": {
            "api_policy_id": api_policy_id,
            "source_id": source_id,
            "api_mode": "static_https_fixture_first",
            "key_required": False,
            "env_var_name": "",
            "missing_key_behavior": "no_key_required",
            "rate_limit_per_second": 1,
            "rate_limit_per_minute": 30,
            "daily_budget_limit": 10,
            "monthly_budget_limit": 300,
            "max_records_per_run": 5,
            "max_pages_per_run": 5,
            "timeout_seconds": 120,
            "retry_policy": "retry_429_500_502_503_504_only",
            "backoff_policy": "exponential_jitter",
            "circuit_breaker_policy": "stop_after_retry_budget",
            "live_flag_required": True,
            "execute_flag_required": True,
            "secret_redaction_required": True,
            "high_volume_review_required": False,
            "budget_owner": "source-atlas-foundry",
            "evidence_output_policy": "public_reference_metadata_only",
            "schema_version": "1.0.0",
        },
        "blockingReasons": ["planner_does_not_write_active_registries", "separate_registry_apply_required"],
        "claimOutputAllowed": False,
        "packOutputAllowed": False,
        "r2PublishAllowed": False,
        "nativeActivationAllowed": False,
        "publicReferenceOnly": True,
        "nonClaims": ["planned registry mutation only", "not active registry mutation", "not claim output", "not R2 publish"],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return bool(next(check for check in result["checks"] if check["name"] == name)["passed"])
