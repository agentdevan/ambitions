from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_registry_applier import CatalogRegistryApplierOptions, compile_catalog_registry_applier
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_registry_applier_dry_run_emits_candidate_copies_without_target_writes(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    plan_path = _write_plan(tmp_path, [_planned_mutation()])

    result = compile_catalog_registry_applier(
        CatalogRegistryApplierOptions(
            plan_path=plan_path,
            output_root=tmp_path / "applier",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for approval-gated catalog registry applier tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; registry applier tooling only"
    assert result["recordCounts"]["plannedRegistryMutations"] == 1
    assert result["recordCounts"]["candidateRegistryMutations"] == 1
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert _check(result, "dry_run_writes_no_active_registries")
    assert read_json(paths["source"])["source_lanes"] == []
    assert read_json(paths["legal"])["licenses"] == []
    assert read_json(paths["api"])["api_policies"] == []

    candidate_source = read_json(Path(result["outputPaths"]["candidateSourceLaneRegistry"]))
    assert candidate_source["source_lanes"][0]["source_id"] == "approved.example.education_reference"


def test_catalog_registry_applier_execute_writes_temp_registries_after_validation(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    plan_path = _write_plan(tmp_path, [_planned_mutation()])

    result = compile_catalog_registry_applier(
        CatalogRegistryApplierOptions(
            plan_path=plan_path,
            output_root=tmp_path / "applier",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            execute=True,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["activeRegistryMutations"] == 1
    assert _check(result, "execute_gate")
    assert _check(result, "execute_writes_only_after_validation")
    assert read_json(paths["source"])["source_lanes"][0]["source_id"] == "approved.example.education_reference"
    assert read_json(paths["legal"])["licenses"][0]["license_id"] == "approved_example_public_terms"
    assert read_json(paths["api"])["api_policies"][0]["api_policy_id"] == "api.approved_example_public_reference.v1"
    active = read_json(Path(result["outputPaths"]["activeRegistryMutations"]))["activeRegistryMutations"]
    assert active[0]["active_registry_written"] is True
    assert active[0]["registry_hashes_before"] != active[0]["registry_hashes_after"]


def test_catalog_registry_applier_execute_requires_explicit_registry_paths_for_planned_writes(tmp_path: Path):
    plan_path = _write_plan(tmp_path, [_planned_mutation()])

    result = compile_catalog_registry_applier(
        CatalogRegistryApplierOptions(
            plan_path=plan_path,
            output_root=tmp_path / "applier",
            execute=True,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "execute_gate")
    assert any("requires explicit registry target paths" in issue for issue in result["issues"])
    assert result["recordCounts"]["activeRegistryMutations"] == 0


def test_catalog_registry_applier_blocks_duplicate_registry_ids(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    mutation = _planned_mutation()
    source_registry = read_json(paths["source"])
    source_registry["source_lanes"] = [mutation["source_lane_entry"]]
    write_json(paths["source"], source_registry)
    plan_path = _write_plan(tmp_path, [mutation])

    result = compile_catalog_registry_applier(
        CatalogRegistryApplierOptions(
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
    assert not _check(result, "duplicate_ids_blocked")
    assert any("duplicate source_id" in issue for issue in result["issues"])
    assert result["recordCounts"]["activeRegistryMutations"] == 0


def test_catalog_registry_applier_blocks_incomplete_mutation_without_writes(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    mutation = _planned_mutation()
    del mutation["source_lane_entry"]["license_id"]
    plan_path = _write_plan(tmp_path, [mutation])

    result = compile_catalog_registry_applier(
        CatalogRegistryApplierOptions(
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
    assert not _check(result, "planned_mutations_complete")
    assert any("license_id must match" in issue for issue in result["issues"])
    assert read_json(paths["source"])["source_lanes"] == []
    assert result["recordCounts"]["activeRegistryMutations"] == 0


def test_catalog_registry_applier_empty_plan_is_valid_noop(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    plan_path = _write_plan(tmp_path, [])

    result = compile_catalog_registry_applier(
        CatalogRegistryApplierOptions(
            plan_path=plan_path,
            output_root=tmp_path / "applier",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            execute=True,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["plannedRegistryMutations"] == 0
    assert result["recordCounts"]["candidateRegistryMutations"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert read_json(paths["source"])["source_lanes"] == []


def _write_plan(tmp_path: Path, mutations: list[dict[str, object]]) -> Path:
    path = tmp_path / "planned-registry-mutations.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.catalogPlannedRegistryMutations.v1",
            "createdAt": CREATED_AT,
            "plannedRegistryMutations": mutations,
        },
    )
    return path


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


def _planned_mutation() -> dict[str, object]:
    source_id = "approved.example.education_reference"
    license_id = "approved_example_public_terms"
    api_policy_id = "api.approved_example_public_reference.v1"
    return {
        "schema_version": "1.0.0",
        "mutation_id": "catalog_registry_mutation.approved_example",
        "intake_id": "catalog_governance_intake.approved_example",
        "candidate_id": "catalog_candidate.approved_example",
        "domain_guess": "education_credentialing",
        "created_at": CREATED_AT,
        "execute_requested": False,
        "status": "dry_run_ready_for_separate_registry_apply",
        "active_registry_written": False,
        "source_lane_entry": {
            "source_id": source_id,
            "source_name": "Approved Example Education Reference",
            "source_class": "official_government",
            "authority_class": "official_government",
            "jurisdiction": "US",
            "domain_scope": ["education_credentialing"],
            "claim_classes_allowed": ["public_program_reference"],
            "claim_classes_forbidden": [
                "admissions_guarantee",
                "legal_advice",
                "financial_aid_guarantee",
                "final_user_path",
                "final_schedule",
                "step_list",
                "personalized_plan",
            ],
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
            "rate_policy_id": "rate.approved_example_public_reference.v1",
            "budget_policy_id": "budget.approved_example_public_reference.v1",
            "secret_policy_id": "secret.no_secret_static_page.v1",
            "allowed_artifact_classes": [
                "official_public_source",
                "public_reference_claim",
                "public_requirement",
                "public_provenance",
                "public_freshness",
            ],
            "forbidden_artifact_classes": [
                "final_user_path",
                "final_schedule",
                "step_list",
                "personalized_plan",
                "private_goal_graph",
            ],
            "non_claims": [
                "not admissions advice",
                "not legal advice",
                "not a personalized education plan",
                "not outside legal approval",
            ],
            "schema_version": "1.0.0",
            "r2_object_key_prefix": "source-atlas/v1/stable/education-reference",
            "review_required": False,
        },
        "legal_terms_entry": {
            "license_id": license_id,
            "license_name": "Approved Example Public Terms",
            "license_url": "https://example.gov/license",
            "terms_url": "https://example.gov/terms",
            "rights_url": "https://example.gov/rights",
            "redistribution_allowed": True,
            "modification_allowed": True,
            "commercial_use_allowed": True,
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
            "non_claims": [
                "not outside legal approval",
                "not terms approval beyond this fixture",
            ],
            "schema_version": "1.0.0",
        },
        "api_policy_entry": {
            "api_policy_id": api_policy_id,
            "source_id": source_id,
            "api_mode": "static_https_fixture_first",
            "key_required": False,
            "env_var_name": "",
            "missing_key_behavior": "no_key_required",
            "rate_limit_per_second": 1,
            "rate_limit_per_minute": 30,
            "daily_budget_limit": 50,
            "monthly_budget_limit": 500,
            "max_records_per_run": 6,
            "max_pages_per_run": 6,
            "timeout_seconds": 120,
            "retry_policy": "retry_429_500_502_503_504_only",
            "backoff_policy": "exponential_jitter",
            "circuit_breaker_policy": "stop_after_retry_budget",
            "live_flag_required": True,
            "execute_flag_required": True,
            "secret_redaction_required": True,
            "high_volume_review_required": False,
            "budget_owner": "source-atlas-foundry",
            "evidence_output_policy": "metadata_only_no_response_body_logs",
            "schema_version": "1.0.0",
        },
        "blocking_reasons": [
            "planner_does_not_write_active_registries",
            "separate_registry_apply_required",
        ],
        "non_claims": [
            "planned mutation only",
            "not active registry mutation",
            "not R2 publish",
            "not claim output",
        ],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
