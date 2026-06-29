from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_candidate_review import CatalogCandidateReviewOptions, compile_catalog_candidate_review
from foundry.catalog_discovery import CatalogDiscoveryOptions, run_catalog_discovery
from foundry.catalog_governance_intake import CatalogGovernanceIntakeOptions, compile_catalog_governance_intake
from foundry.catalog_registry_mutation_plan import CatalogRegistryMutationPlanOptions, compile_catalog_registry_mutation_plan
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"
FIXTURE_ROOT = Path("tools/source-atlas/fixtures/catalog-discovery/train-53-catalogs")


def test_catalog_registry_mutation_plan_blocks_all_drafts_without_approval(tmp_path: Path):
    intake = _run_intake(tmp_path)
    result = compile_catalog_registry_mutation_plan(
        CatalogRegistryMutationPlanOptions(
            input_path=Path(intake["outputRoot"]) / "draft-governance-packets.json",
            output_root=tmp_path / "mutation-plan",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for approval-gated catalog registry mutation planning"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; registry mutation planning only"
    assert result["recordCounts"]["draftGovernancePackets"] == 6
    assert result["recordCounts"]["plannedRegistryMutations"] == 0
    assert result["recordCounts"]["blockedRegistryMutations"] == 6
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["approvedSourceLanes"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "approval_required_for_planned_mutations")
    assert _check(result, "no_active_registry_mutations_written")
    assert _check(result, "registry_mutation_plan_emits_no_claims")
    assert result["issues"] == []

    blocked = read_json(Path(result["outputRoot"]) / "blocked-registry-mutations.json")["blockedRegistryMutations"]
    assert all(item["status"] == "blocked" for item in blocked)
    assert all("approval_artifact_required" in item["blocking_reasons"] for item in blocked)
    assert read_json(Path(result["outputRoot"]) / "active-registry-mutations.json")["activeRegistryMutations"] == []


def test_catalog_registry_mutation_plan_execute_requires_valid_approval(tmp_path: Path):
    intake = _run_intake(tmp_path)
    result = compile_catalog_registry_mutation_plan(
        CatalogRegistryMutationPlanOptions(
            input_path=Path(intake["outputRoot"]) / "draft-governance-packets.json",
            output_root=tmp_path / "mutation-plan",
            execute=True,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "execute_requires_approval_artifact")
    assert any("--execute requires a valid catalog registry mutation approval artifact" in issue for issue in result["issues"])


def test_catalog_registry_mutation_plan_valid_approval_creates_dry_run_planned_mutation(tmp_path: Path):
    intake = _run_intake(tmp_path)
    drafts_path = Path(intake["outputRoot"]) / "draft-governance-packets.json"
    first_draft = read_json(drafts_path)["draftGovernancePackets"][0]
    approval_path = tmp_path / "approval.json"
    write_json(approval_path, _approval_for(first_draft))

    result = compile_catalog_registry_mutation_plan(
        CatalogRegistryMutationPlanOptions(
            input_path=drafts_path,
            output_root=tmp_path / "mutation-plan",
            approval_artifact=approval_path,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["draftGovernancePackets"] == 6
    assert result["recordCounts"]["plannedRegistryMutations"] == 1
    assert result["recordCounts"]["blockedRegistryMutations"] == 5
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["approvedSourceLanes"] == 1
    assert result["approvalValidation"]["valid"] is True
    planned = read_json(Path(result["outputRoot"]) / "planned-registry-mutations.json")["plannedRegistryMutations"]
    assert planned[0]["active_registry_written"] is False
    assert planned[0]["status"] == "dry_run_ready_for_separate_registry_apply"
    assert planned[0]["source_lane_entry"]["review_status"] == "reviewed"
    assert planned[0]["legal_terms_entry"]["pack_output_allowed"] is True
    assert planned[0]["api_policy_entry"]["live_flag_required"] is True
    assert planned[0]["api_policy_entry"]["execute_flag_required"] is True


def test_catalog_registry_mutation_plan_rejects_malformed_approval(tmp_path: Path):
    intake = _run_intake(tmp_path)
    drafts_path = Path(intake["outputRoot"]) / "draft-governance-packets.json"
    first_draft = read_json(drafts_path)["draftGovernancePackets"][0]
    approval_path = tmp_path / "bad-approval.json"
    approval = _approval_for(first_draft)
    approval["approved_entries"][0]["source_lane_entry"]["source_class"] = "public_catalog"
    approval["approved_entries"][0]["legal_terms_entry"]["pack_output_allowed"] = False
    write_json(approval_path, approval)

    result = compile_catalog_registry_mutation_plan(
        CatalogRegistryMutationPlanOptions(
            input_path=drafts_path,
            output_root=tmp_path / "mutation-plan",
            approval_artifact=approval_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert result["approvalValidation"]["valid"] is False
    assert any("cannot remain public_catalog" in issue for issue in result["issues"])
    assert any("pack_output_allowed must be true" in issue for issue in result["issues"])


def test_catalog_registry_mutation_plan_rejects_private_approval_payload(tmp_path: Path):
    intake = _run_intake(tmp_path)
    drafts_path = Path(intake["outputRoot"]) / "draft-governance-packets.json"
    first_draft = read_json(drafts_path)["draftGovernancePackets"][0]
    approval_path = tmp_path / "private-approval.json"
    approval = _approval_for(first_draft)
    approval["goal_text"] = "I need this for my private plan"
    write_json(approval_path, approval)

    result = compile_catalog_registry_mutation_plan(
        CatalogRegistryMutationPlanOptions(
            input_path=drafts_path,
            output_root=tmp_path / "mutation-plan",
            approval_artifact=approval_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "approval_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def _run_intake(tmp_path: Path) -> dict[str, object]:
    discovery = run_catalog_discovery(
        CatalogDiscoveryOptions(
            input_root=FIXTURE_ROOT,
            output_root=tmp_path / "catalog-discovery",
            created_at=CREATED_AT,
        )
    )
    review = compile_catalog_candidate_review(
        CatalogCandidateReviewOptions(
            input_path=Path(discovery["outputRoot"]) / "candidate-sources.json",
            output_root=tmp_path / "candidate-review",
            created_at=CREATED_AT,
        )
    )
    return compile_catalog_governance_intake(
        CatalogGovernanceIntakeOptions(
            input_path=Path(review["outputRoot"]) / "review-packets.json",
            output_root=tmp_path / "governance-intake",
            created_at=CREATED_AT,
        )
    )


def _approval_for(draft: dict[str, object]) -> dict[str, object]:
    source_id = "approved.example.education_reference"
    return {
        "kind": "ambitions.sourceAtlas.catalogRegistryMutationApproval.v1",
        "approval_artifact_id": "source-atlas/catalog-registry-mutation-approval/test-fixture",
        "approval_status": "approved",
        "review_owner": "Ambitions owner technical review fixture",
        "reviewed_at": "2026-06-28",
        "source_lane_review_complete": True,
        "legal_terms_review_complete": True,
        "api_governance_review_complete": True,
        "outside_legal_status": "not_claimed",
        "selected_intake_ids": [draft["intake_id"]],
        "approved_entries": [
            {
                "intake_id": draft["intake_id"],
                "source_lane_entry": {
                    "source_id": source_id,
                    "source_name": "Approved Example Education Reference",
                    "source_class": "official_government",
                    "authority_class": "official_government",
                    "jurisdiction": "US",
                    "review_status": "reviewed",
                    "r2_pack_policy": "pack_allowed_with_attribution",
                },
                "legal_terms_entry": {
                    "license_id": "approved_example_public_terms",
                    "license_name": "Approved Example Public Terms",
                    "license_url": "https://example.gov/license",
                    "terms_url": "https://example.gov/terms",
                    "rights_url": "https://example.gov/rights",
                    "redistribution_allowed": True,
                    "pack_output_allowed": True,
                    "review_required": False,
                    "outside_legal_status": "not_claimed",
                    "review_owner": "Ambitions owner technical review fixture",
                    "reviewed_at": "2026-06-28",
                },
                "api_policy_entry": {
                    "api_policy_id": "api.approved_example_public_reference.v1",
                    "source_id": source_id,
                    "api_mode": "static_https_fixture_first",
                    "missing_key_behavior": "not_required",
                    "retry_policy": "bounded_retry",
                    "backoff_policy": "exponential_backoff",
                    "circuit_breaker_policy": "stop_after_budget_or_errors",
                    "budget_owner": "Ambitions owner technical review fixture",
                    "evidence_output_policy": "public_reference_only",
                    "live_flag_required": True,
                    "execute_flag_required": True,
                    "secret_redaction_required": True,
                },
            }
        ],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
