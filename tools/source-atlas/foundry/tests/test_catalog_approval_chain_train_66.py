from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_approval_chain import CatalogApprovalChainOptions, run_catalog_approval_chain
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_approval_chain_blocks_without_reviewer_completion(tmp_path: Path):
    packet = _decision_input_packet("education")
    inputs_path = _write_decision_inputs(tmp_path, [packet])
    terms_path = _write_terms_proposals(tmp_path, [_terms_proposal_for(packet)])
    drafts_path = _write_draft_packets(tmp_path, [_draft_packet_for(packet)])

    result = run_catalog_approval_chain(
        CatalogApprovalChainOptions(
            decision_inputs_path=inputs_path,
            terms_proposals_path=terms_path,
            draft_governance_packets_path=drafts_path,
            output_root=tmp_path / "chain",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog approval chain proof tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; approval chain proof tooling only"
    assert result["recordCounts"]["decisionInputPackets"] == 1
    assert result["recordCounts"]["completedDecisionArtifacts"] == 0
    assert result["recordCounts"]["completedApprovalArtifacts"] == 0
    assert result["recordCounts"]["plannedRegistryMutations"] == 0
    assert result["recordCounts"]["candidateRegistryMutations"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert _check(result, "missing_completion_blocks_without_red")
    assert _check(result, "chain_emits_no_claims_or_packs")


def test_catalog_approval_chain_valid_completion_reaches_candidate_registry_dry_run(tmp_path: Path):
    packet = _decision_input_packet("education")
    inputs_path = _write_decision_inputs(tmp_path, [packet])
    terms_path = _write_terms_proposals(tmp_path, [_terms_proposal_for(packet)])
    drafts_path = _write_draft_packets(tmp_path, [_draft_packet_for(packet)])
    completion_path = tmp_path / "completion.json"
    write_json(completion_path, _completion_for(packet))
    registries = _write_empty_registries(tmp_path)

    result = run_catalog_approval_chain(
        CatalogApprovalChainOptions(
            decision_inputs_path=inputs_path,
            terms_proposals_path=terms_path,
            draft_governance_packets_path=drafts_path,
            output_root=tmp_path / "chain",
            review_completion_path=completion_path,
            source_lane_registry_path=registries["source"],
            legal_terms_registry_path=registries["legal"],
            api_governance_registry_path=registries["api"],
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["completedDecisionArtifacts"] == 1
    assert result["recordCounts"]["completedApprovalArtifacts"] == 1
    assert result["recordCounts"]["plannedRegistryMutations"] == 1
    assert result["recordCounts"]["candidateRegistryMutations"] == 1
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert read_json(registries["source"])["source_lanes"] == []
    assert result["stageResults"]["registryApplier"]["recordCounts"]["candidateRegistryMutations"] == 1


def test_catalog_approval_chain_rejects_malformed_completion(tmp_path: Path):
    packet = _decision_input_packet("education")
    inputs_path = _write_decision_inputs(tmp_path, [packet])
    terms_path = _write_terms_proposals(tmp_path, [_terms_proposal_for(packet)])
    drafts_path = _write_draft_packets(tmp_path, [_draft_packet_for(packet)])
    completion = _completion_for(packet)
    del completion["completed_entries"][0]["api_policy_entry"]["retry_policy"]
    completion_path = tmp_path / "completion.json"
    write_json(completion_path, completion)

    result = run_catalog_approval_chain(
        CatalogApprovalChainOptions(
            decision_inputs_path=inputs_path,
            terms_proposals_path=terms_path,
            draft_governance_packets_path=drafts_path,
            output_root=tmp_path / "chain",
            review_completion_path=completion_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "decision_assembler_valid")
    assert not _check(result, "provided_completion_must_be_valid")
    assert any("retry_policy required" in issue for issue in result["issues"])
    assert result["recordCounts"]["completedDecisionArtifacts"] == 0


def test_catalog_approval_chain_rejects_private_completion(tmp_path: Path):
    packet = _decision_input_packet("education")
    inputs_path = _write_decision_inputs(tmp_path, [packet])
    terms_path = _write_terms_proposals(tmp_path, [_terms_proposal_for(packet)])
    drafts_path = _write_draft_packets(tmp_path, [_draft_packet_for(packet)])
    completion = _completion_for(packet)
    completion["goal_text"] = "I need this for my private plan"
    completion_path = tmp_path / "completion.json"
    write_json(completion_path, completion)

    result = run_catalog_approval_chain(
        CatalogApprovalChainOptions(
            decision_inputs_path=inputs_path,
            terms_proposals_path=terms_path,
            draft_governance_packets_path=drafts_path,
            output_root=tmp_path / "chain",
            review_completion_path=completion_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])
    assert result["recordCounts"]["activeRegistryMutations"] == 0


def _write_decision_inputs(tmp_path: Path, packets: list[dict[str, object]]) -> Path:
    path = tmp_path / "decision-input-packets.json"
    write_json(path, {"kind": "ambitions.sourceAtlas.catalogApprovalDecisionInputPackets.v1", "createdAt": CREATED_AT, "decisionInputPackets": packets})
    return path


def _write_terms_proposals(tmp_path: Path, proposals: list[dict[str, object]]) -> Path:
    path = tmp_path / "terms-resolution-proposals.json"
    write_json(path, {"kind": "ambitions.sourceAtlas.catalogTermsResolutionProposals.v1", "createdAt": CREATED_AT, "termsResolutionProposals": proposals})
    return path


def _write_draft_packets(tmp_path: Path, packets: list[dict[str, object]]) -> Path:
    path = tmp_path / "draft-governance-packets.json"
    write_json(path, {"kind": "ambitions.sourceAtlas.catalogDraftGovernancePackets.v1", "createdAt": CREATED_AT, "draftGovernancePackets": packets})
    return path


def _decision_input_packet(suffix: str) -> dict[str, object]:
    proposal_id = f"catalog_terms_resolution.{suffix}"
    intake_id = f"catalog_governance_intake.{suffix}"
    source_id = f"catalog.candidate.{suffix}"
    return {
        "schema_version": "1.0.0",
        "decision_input_id": f"catalog_approval_decision_input.{suffix}",
        "proposal_id": proposal_id,
        "request_id": f"catalog_registry_approval_request.{suffix}",
        "intake_id": intake_id,
        "candidate_id": f"catalog_candidate.{suffix}",
        "domain_guess": "education_credentialing",
        "source_id": source_id,
        "source_name": "Example Public Reference Candidate",
        "draft_decision_artifact": {"kind": "ambitions.sourceAtlas.catalogApprovalFinalizerDecision.v1", "decision_status": "draft_not_approved"},
        "blocking_reasons": ["approval_artifact_still_required"],
        "non_claims": ["decision input packet only", "not approval"],
    }


def _terms_proposal_for(packet: dict[str, object]) -> dict[str, object]:
    return {
        "schema_version": "1.0.0",
        "proposal_id": packet["proposal_id"],
        "request_id": packet["request_id"],
        "intake_id": packet["intake_id"],
        "candidate_id": packet["candidate_id"],
        "domain_guess": packet["domain_guess"],
        "status": "terms_resolution_proposed",
        "source_id": packet["source_id"],
        "source_name": packet["source_name"],
        "resolved_approval_artifact_template": {
            "kind": "ambitions.sourceAtlas.catalogRegistryMutationApproval.v1",
            "approval_status": "draft_not_approved",
            "selected_intake_ids": [packet["intake_id"]],
            "approved_entries": [{"intake_id": packet["intake_id"]}],
        },
        "blocking_reasons": ["approval_artifact_still_required"],
        "non_claims": ["terms resolution proposal only", "not approval"],
    }


def _draft_packet_for(packet: dict[str, object]) -> dict[str, object]:
    return {
        "schema_version": "1.0.0",
        "packet_id": f"catalog_candidate_review_packet.{packet['candidate_id']}",
        "intake_id": packet["intake_id"],
        "candidate_id": packet["candidate_id"],
        "domain_guess": packet["domain_guess"],
        "review_status": "review_required",
        "blocking_reasons": ["review_required"],
        "non_claims": ["draft governance intake only", "not active registry mutation"],
    }


def _completion_for(packet: dict[str, object]) -> dict[str, object]:
    source_id = f"approved.public.reference.{str(packet['proposal_id']).rsplit('.', 1)[-1]}"
    license_id = f"{source_id}.terms"
    api_policy_id = f"api.{source_id}.v1"
    return {
        "kind": "ambitions.sourceAtlas.catalogApprovalDecisionCompletion.v1",
        "completion_status": "completed",
        "decision_artifact_id": f"source-atlas/catalog-approval-finalizer-decision/{packet['proposal_id']}",
        "review_owner": "Ambitions owner technical review fixture",
        "reviewed_at": "2026-06-28",
        "source_lane_review_complete": True,
        "legal_terms_review_complete": True,
        "api_governance_review_complete": True,
        "outside_legal_status": "not_claimed",
        "outside_legal_approval_artifact": "",
        "completed_entries": [
            {
                "proposal_id": packet["proposal_id"],
                "intake_id": packet["intake_id"],
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
                    "forbidden_artifact_classes": ["private_goal_graph", "final_user_path", "final_schedule", "step_list", "personalized_plan"],
                    "r2_object_key_prefix": "source-atlas/v1/stable/education-credentialing-reference",
                    "non_claims": ["not admissions guarantee", "not legal advice"],
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
                    "non_claims": ["not legal advice", "not outside legal approval"],
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


def _write_empty_registries(tmp_path: Path) -> dict[str, Path]:
    source = tmp_path / "source-lane-registry.json"
    legal = tmp_path / "legal-terms-registry.json"
    api = tmp_path / "api-governance-registry.json"
    write_json(source, {"kind": "ambitions.sourceAtlas.sourceLaneRegistry.v1", "registries_version": "test", "schema_version": "1.0.0", "updated_at": CREATED_AT, "source_lanes": []})
    write_json(legal, {"kind": "ambitions.sourceAtlas.legalTermsRegistry.v1", "registries_version": "test", "schema_version": "1.0.0", "updated_at": CREATED_AT, "licenses": []})
    write_json(api, {"kind": "ambitions.sourceAtlas.apiGovernanceRegistry.v1", "registries_version": "test", "schema_version": "1.0.0", "updated_at": CREATED_AT, "api_policies": []})
    return {"source": source, "legal": legal, "api": api}


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
