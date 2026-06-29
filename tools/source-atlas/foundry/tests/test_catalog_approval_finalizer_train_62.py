from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_approval_finalizer import CatalogApprovalFinalizerOptions, compile_catalog_approval_finalizer
from foundry.catalog_registry_mutation_plan import CatalogRegistryMutationPlanOptions, compile_catalog_registry_mutation_plan
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_approval_finalizer_blocks_all_proposals_without_decision(tmp_path: Path):
    proposals_path = _write_terms_proposals(tmp_path, [_proposal("education"), _proposal("health", domain="health_wellness_reference")])

    result = compile_catalog_approval_finalizer(
        CatalogApprovalFinalizerOptions(
            terms_proposals_path=proposals_path,
            output_root=tmp_path / "approval-finalizer",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog approval finalizer tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; approval finalizer tooling only"
    assert result["recordCounts"]["termsResolutionProposals"] == 2
    assert result["recordCounts"]["completedApprovalArtifacts"] == 0
    assert result["recordCounts"]["approvedEntries"] == 0
    assert result["recordCounts"]["blockedApprovalFinalizations"] == 2
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "decision_required_for_completed_approvals")
    assert _check(result, "approval_finalizer_emits_no_claims")

    blocked = read_json(Path(result["outputRoot"]) / "blocked-approval-finalizations.json")["blockedApprovalFinalizations"]
    assert all(item["status"] == "blocked" for item in blocked)
    assert all("decision_artifact_required" in item["blocking_reasons"] for item in blocked)
    completed = read_json(Path(result["outputRoot"]) / "completed-approval-artifacts.json")["completedApprovalArtifacts"]
    assert completed == []


def test_catalog_approval_finalizer_valid_decision_emits_planner_ready_approval(tmp_path: Path):
    proposal = _proposal("education")
    proposals_path = _write_terms_proposals(tmp_path, [proposal])
    decision_path = tmp_path / "decision.json"
    write_json(decision_path, _decision_for(proposal))

    result = compile_catalog_approval_finalizer(
        CatalogApprovalFinalizerOptions(
            terms_proposals_path=proposals_path,
            output_root=tmp_path / "approval-finalizer",
            decision_artifact=decision_path,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["completedApprovalArtifacts"] == 1
    assert result["recordCounts"]["approvedEntries"] == 1
    assert result["recordCounts"]["blockedApprovalFinalizations"] == 0
    assert _check(result, "completed_approval_artifacts_match_planner_contract")

    approval = read_json(Path(result["outputRoot"]) / "catalog-registry-mutation-approval.json")
    assert approval["kind"] == "ambitions.sourceAtlas.catalogRegistryMutationApproval.v1"
    assert approval["approval_status"] == "approved"
    assert approval["source_lane_review_complete"] is True
    assert approval["legal_terms_review_complete"] is True
    assert approval["api_governance_review_complete"] is True
    assert approval["selected_intake_ids"] == [proposal["intake_id"]]

    draft_path = tmp_path / "draft-governance-packets.json"
    write_json(
        draft_path,
        {
            "draftGovernancePackets": [
                {
                    "intake_id": proposal["intake_id"],
                    "candidate_id": proposal["candidate_id"],
                    "domain_guess": proposal["domain_guess"],
                    "blocking_reasons": [],
                }
            ]
        },
    )
    plan = compile_catalog_registry_mutation_plan(
        CatalogRegistryMutationPlanOptions(
            input_path=draft_path,
            output_root=tmp_path / "mutation-plan",
            approval_artifact=Path(result["outputRoot"]) / "catalog-registry-mutation-approval.json",
            created_at=CREATED_AT,
        )
    )

    assert plan["valid"], plan["issues"]
    assert plan["recordCounts"]["plannedRegistryMutations"] == 1
    assert plan["recordCounts"]["blockedRegistryMutations"] == 0


def test_catalog_approval_finalizer_rejects_public_catalog_as_approved_authority(tmp_path: Path):
    proposal = _proposal("education")
    proposals_path = _write_terms_proposals(tmp_path, [proposal])
    decision = _decision_for(proposal)
    decision["approved_entries"][0]["source_lane_entry"]["source_class"] = "public_catalog"
    decision["approved_entries"][0]["source_lane_entry"]["authority_class"] = "public_catalog"
    decision_path = tmp_path / "decision.json"
    write_json(decision_path, decision)

    result = compile_catalog_approval_finalizer(
        CatalogApprovalFinalizerOptions(
            terms_proposals_path=proposals_path,
            output_root=tmp_path / "approval-finalizer",
            decision_artifact=decision_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "provided_decision_valid")
    assert any("cannot remain public_catalog" in issue for issue in result["issues"])
    assert result["recordCounts"]["completedApprovalArtifacts"] == 0


def test_catalog_approval_finalizer_rejects_outside_legal_claim_without_artifact(tmp_path: Path):
    proposal = _proposal("education")
    proposals_path = _write_terms_proposals(tmp_path, [proposal])
    decision = _decision_for(proposal)
    decision["outside_legal_status"] = "approved"
    decision["outside_legal_approval_artifact"] = ""
    decision_path = tmp_path / "decision.json"
    write_json(decision_path, decision)

    result = compile_catalog_approval_finalizer(
        CatalogApprovalFinalizerOptions(
            terms_proposals_path=proposals_path,
            output_root=tmp_path / "approval-finalizer",
            decision_artifact=decision_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("outside_legal_status approved requires outside_legal_approval_artifact" in issue for issue in result["issues"])
    assert result["recordCounts"]["completedApprovalArtifacts"] == 0


def test_catalog_approval_finalizer_rejects_private_decision_payload(tmp_path: Path):
    proposal = _proposal("education")
    proposals_path = _write_terms_proposals(tmp_path, [proposal])
    decision = _decision_for(proposal)
    decision["goal_text"] = "I need this for my private plan"
    decision_path = tmp_path / "decision.json"
    write_json(decision_path, decision)

    result = compile_catalog_approval_finalizer(
        CatalogApprovalFinalizerOptions(
            terms_proposals_path=proposals_path,
            output_root=tmp_path / "approval-finalizer",
            decision_artifact=decision_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "decision_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def _write_terms_proposals(tmp_path: Path, proposals: list[dict[str, object]]) -> Path:
    path = tmp_path / "terms-resolution-proposals.json"
    write_json(path, {"kind": "ambitions.sourceAtlas.catalogTermsResolutionProposals.v1", "createdAt": CREATED_AT, "termsResolutionProposals": proposals})
    return path


def _proposal(suffix: str, *, domain: str = "education_credentialing") -> dict[str, object]:
    proposal_id = f"catalog_terms_resolution.{suffix}"
    intake_id = f"catalog_governance_intake.{suffix}"
    return {
        "schema_version": "1.0.0",
        "proposal_id": proposal_id,
        "request_id": f"catalog_registry_approval_request.{suffix}",
        "intake_id": intake_id,
        "candidate_id": f"catalog_candidate.{suffix}",
        "domain_guess": domain,
        "status": "terms_resolution_proposed",
        "source_id": f"catalog.candidate.{suffix}",
        "source_name": "Example Public Reference Candidate",
        "resolved_approval_artifact_template": {
            "kind": "ambitions.sourceAtlas.catalogRegistryMutationApproval.v1",
            "approval_status": "draft_not_approved",
            "selected_intake_ids": [intake_id],
            "approved_entries": [{"intake_id": intake_id}],
        },
        "blocking_reasons": [
            "source_lane_review_required",
            "legal_terms_review_required",
            "api_governance_review_required",
            "approval_artifact_still_required",
        ],
        "non_claims": ["terms resolution proposal only", "not an approval"],
    }


def _decision_for(proposal: dict[str, object]) -> dict[str, object]:
    proposal_id = str(proposal["proposal_id"])
    intake_id = str(proposal["intake_id"])
    source_id = f"approved.public.reference.{proposal_id.rsplit('.', 1)[-1]}"
    license_id = f"{source_id}.terms"
    api_policy_id = f"api.{source_id}.v1"
    return {
        "kind": "ambitions.sourceAtlas.catalogApprovalFinalizerDecision.v1",
        "decision_artifact_id": f"source-atlas/catalog-approval-finalizer-decision/{proposal_id}",
        "decision_status": "approved",
        "review_owner": "Ambitions owner technical review fixture",
        "reviewed_at": "2026-06-28",
        "source_lane_review_complete": True,
        "legal_terms_review_complete": True,
        "api_governance_review_complete": True,
        "outside_legal_status": "not_claimed",
        "outside_legal_approval_artifact": "",
        "selected_proposal_ids": [proposal_id],
        "approved_entries": [
            {
                "proposal_id": proposal_id,
                "intake_id": intake_id,
                "source_lane_entry": {
                    "source_id": source_id,
                    "source_name": "Approved Public Reference Fixture",
                    "source_class": "official_government",
                    "authority_class": "official_government",
                    "jurisdiction": "US",
                    "domain_scope": ["education_credentialing"],
                    "claim_classes_allowed": ["public_program_reference"],
                    "claim_classes_forbidden": [
                        "admissions_guarantee",
                        "legal_advice",
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
                    "review_required": False,
                    "review_owner": "Ambitions owner technical review fixture",
                    "last_reviewed_at": "2026-06-28",
                    "next_review_due_at": "2026-09-28",
                    "freshness_sla": "quarterly_terms_and_reference_review",
                    "api_mode": "static_https_fixture_first",
                    "api_policy_id": api_policy_id,
                    "rate_policy_id": "rate.approved_public_reference_fixture.v1",
                    "budget_policy_id": "budget.approved_public_reference_fixture.v1",
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
                    "r2_object_key_prefix": "source-atlas/v1/stable/education-credentialing-reference",
                    "non_claims": [
                        "not admissions guarantee",
                        "not legal advice",
                        "not final user planning",
                    ],
                    "schema_version": "1.0.0",
                },
                "legal_terms_entry": {
                    "license_id": license_id,
                    "license_name": "Approved Public Reference Fixture Terms",
                    "license_url": "https://example.gov/license",
                    "terms_url": "https://example.gov/terms",
                    "rights_url": "https://example.gov/rights",
                    "redistribution_allowed": True,
                    "modification_allowed": True,
                    "commercial_use_allowed": True,
                    "attribution_required": True,
                    "share_alike_required": False,
                    "source_specific_restrictions": ["cite fixture public reference source"],
                    "pack_output_allowed": True,
                    "lookup_output_allowed": True,
                    "review_required": False,
                    "outside_legal_required": False,
                    "outside_legal_status": "not_claimed",
                    "approval_artifact_path": "",
                    "effective_date": "2026-06-28",
                    "reviewed_at": "2026-06-28",
                    "review_owner": "Ambitions owner technical review fixture",
                    "expires_at": "2026-09-28",
                    "non_claims": [
                        "not legal advice",
                        "not outside legal approval",
                        "not release readiness",
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
                    "daily_budget_limit": 10,
                    "monthly_budget_limit": 100,
                    "max_records_per_run": 5,
                    "max_pages_per_run": 3,
                    "timeout_seconds": 60,
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
            }
        ],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
