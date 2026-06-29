from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_approval_decision_assembler import CatalogApprovalDecisionAssemblerOptions, compile_catalog_approval_decision_assembler
from foundry.catalog_reviewer_completion_intake import CatalogReviewerCompletionIntakeOptions, compile_catalog_reviewer_completion_intake
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_reviewer_completion_intake_blocks_without_review_packets(tmp_path: Path):
    inputs_path = _write_decision_inputs(tmp_path, [_decision_input_packet("education"), _decision_input_packet("health", domain="health_wellness_reference")])

    result = compile_catalog_reviewer_completion_intake(
        CatalogReviewerCompletionIntakeOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "completion-intake",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog reviewer completion intake tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; reviewer completion intake tooling only"
    assert result["recordCounts"]["decisionInputPackets"] == 2
    assert result["recordCounts"]["reviewPackets"] == 0
    assert result["recordCounts"]["completedReviewCompletions"] == 0
    assert result["recordCounts"]["completedDecisionArtifacts"] == 0
    assert result["recordCounts"]["blockedReviewCompletions"] == 2
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "missing_review_packets_block_without_approval")
    assert result["reviewCompletionArtifactPath"] == ""

    completion = read_json(Path(result["outputRoot"]) / "catalog-approval-decision-completion.json")
    assert completion["kind"] == "ambitions.sourceAtlas.catalogApprovalDecisionCompletionUnavailable.v1"


def test_catalog_reviewer_completion_intake_emits_assembler_compatible_completion(tmp_path: Path):
    packet = _decision_input_packet("education")
    inputs_path = _write_decision_inputs(tmp_path, [packet])
    review_packets_path = _write_review_packets(tmp_path, [_review_packet_for(packet)])

    result = compile_catalog_reviewer_completion_intake(
        CatalogReviewerCompletionIntakeOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "completion-intake",
            review_packets_path=review_packets_path,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["reviewPackets"] == 1
    assert result["recordCounts"]["completedReviewCompletions"] == 1
    assert result["recordCounts"]["completedDecisionArtifacts"] == 1
    assert result["recordCounts"]["approvedEntries"] == 1
    assert result["recordCounts"]["blockedReviewCompletions"] == 0
    assert _check(result, "completed_artifact_matches_decision_assembler_contract")

    completion_path = Path(result["reviewCompletionArtifactPath"])
    completion = read_json(completion_path)
    assert completion["kind"] == "ambitions.sourceAtlas.catalogApprovalDecisionCompletion.v1"
    assert completion["completed_entries"][0]["proposal_id"] == packet["proposal_id"]

    assembler = compile_catalog_approval_decision_assembler(
        CatalogApprovalDecisionAssemblerOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "assembler",
            review_completion_path=completion_path,
            created_at=CREATED_AT,
        )
    )
    assert assembler["valid"], assembler["issues"]
    assert assembler["recordCounts"]["completedDecisionArtifacts"] == 1


def test_catalog_reviewer_completion_intake_rejects_outside_legal_without_artifact(tmp_path: Path):
    packet = _decision_input_packet("education")
    inputs_path = _write_decision_inputs(tmp_path, [packet])
    review_packet = _review_packet_for(packet)
    review_packet["legal_terms_review"]["outside_legal_status"] = "approved"
    review_packet["legal_terms_review"]["outside_legal_approval_artifact"] = ""
    review_packets_path = _write_review_packets(tmp_path, [review_packet])

    result = compile_catalog_reviewer_completion_intake(
        CatalogReviewerCompletionIntakeOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "completion-intake",
            review_packets_path=review_packets_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("outside legal approval requires outside_legal_approval_artifact" in issue for issue in result["issues"])
    assert result["recordCounts"]["completedReviewCompletions"] == 0


def test_catalog_reviewer_completion_intake_rejects_private_review_packet(tmp_path: Path):
    packet = _decision_input_packet("education")
    inputs_path = _write_decision_inputs(tmp_path, [packet])
    review_packet = _review_packet_for(packet)
    review_packet["goal_text"] = "Use this for my private schedule"
    review_packets_path = _write_review_packets(tmp_path, [review_packet])

    result = compile_catalog_reviewer_completion_intake(
        CatalogReviewerCompletionIntakeOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "completion-intake",
            review_packets_path=review_packets_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "review_packet_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_reviewer_completion_intake_rejects_completed_packet_without_api_entry(tmp_path: Path):
    packet = _decision_input_packet("education")
    inputs_path = _write_decision_inputs(tmp_path, [packet])
    review_packet = _review_packet_for(packet)
    del review_packet["api_governance_review"]["api_policy_entry"]
    review_packets_path = _write_review_packets(tmp_path, [review_packet])

    result = compile_catalog_reviewer_completion_intake(
        CatalogReviewerCompletionIntakeOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "completion-intake",
            review_packets_path=review_packets_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("api_governance_review.api_policy_entry required" in issue for issue in result["issues"])
    assert result["recordCounts"]["completedReviewCompletions"] == 0


def _write_decision_inputs(tmp_path: Path, packets: list[dict[str, object]]) -> Path:
    path = tmp_path / "decision-input-packets.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.catalogApprovalDecisionInputPackets.v1",
            "createdAt": CREATED_AT,
            "decisionInputPackets": packets,
        },
    )
    return path


def _write_review_packets(tmp_path: Path, packets: list[dict[str, object]]) -> Path:
    path = tmp_path / "source-review-completion-packets.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.catalogSourceReviewCompletionPackets.v1",
            "createdAt": CREATED_AT,
            "sourceReviewCompletionPackets": packets,
        },
    )
    return path


def _decision_input_packet(suffix: str, *, domain: str = "education_credentialing") -> dict[str, object]:
    proposal_id = f"catalog_terms_resolution.{suffix}"
    intake_id = f"catalog_governance_intake.{suffix}"
    source_id = f"catalog.candidate.{suffix}"
    return {
        "schema_version": "1.0.0",
        "decision_input_id": f"catalog_approval_decision_input.{suffix}",
        "preflight_id": f"catalog_approval_preflight.{suffix}",
        "proposal_id": proposal_id,
        "request_id": f"catalog_registry_approval_request.{suffix}",
        "intake_id": intake_id,
        "candidate_id": f"catalog_candidate.{suffix}",
        "domain_guess": domain,
        "source_id": source_id,
        "source_name": "Example Public Reference Candidate",
        "created_at": CREATED_AT,
        "packet_status": "blocked_review_required",
        "draft_decision_artifact": {
            "kind": "ambitions.sourceAtlas.catalogApprovalFinalizerDecision.v1",
            "decision_status": "draft_not_approved",
            "selected_proposal_ids": [proposal_id],
        },
        "blocking_reasons": [
            "source_lane_review_required",
            "legal_terms_review_required",
            "api_governance_review_required",
            "approval_artifact_still_required",
        ],
        "non_claims": ["decision input packet only", "not approval"],
    }


def _review_packet_for(packet: dict[str, object]) -> dict[str, object]:
    source_id = f"approved.public.reference.{str(packet['proposal_id']).rsplit('.', 1)[-1]}"
    license_id = f"{source_id}.terms"
    api_policy_id = f"api.{source_id}.v1"
    return {
        "completion_packet_id": f"catalog_source_review_completion.{packet['proposal_id']}",
        "proposal_id": packet["proposal_id"],
        "intake_id": packet["intake_id"],
        "completion_status": "completed",
        "review_owner": "Ambitions owner technical review fixture",
        "reviewed_at": "2026-06-28",
        "source_lane_review": {
            "status": "completed",
            "source_lane_entry": {
                "source_id": source_id,
                "source_name": "Approved Public Reference Fixture",
                "source_class": "official_government",
                "authority_class": "official_government",
                "jurisdiction": "US",
                "domain_scope": ["education_credentialing"],
                "claim_classes_allowed": ["public_program_reference"],
                "claim_classes_forbidden": ["admissions_guarantee", "legal_advice"],
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
                "allowed_artifact_classes": ["official_public_source", "public_reference_claim", "public_provenance"],
                "forbidden_artifact_classes": [
                    "private_goal_graph",
                    "final_user_path",
                    "final_schedule",
                    "step_list",
                    "personalized_plan",
                ],
                "r2_object_key_prefix": "source-atlas/v1/stable/education-credentialing-reference",
                "non_claims": ["not admissions guarantee", "not legal advice"],
                "schema_version": "1.0.0",
            },
        },
        "legal_terms_review": {
            "status": "completed",
            "outside_legal_status": "not_claimed",
            "outside_legal_approval_artifact": "",
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
                "non_claims": ["not legal advice", "not outside legal approval"],
                "schema_version": "1.0.0",
            },
        },
        "api_governance_review": {
            "status": "completed",
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
        },
        "non_claims": ["review packet fixture only", "not legal approval"],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
