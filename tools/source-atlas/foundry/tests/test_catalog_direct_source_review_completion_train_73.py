from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_direct_source_review_completion import (
    CatalogDirectSourceReviewCompletionOptions,
    compile_catalog_direct_source_review_completion,
)
from foundry.catalog_direct_source_review_gate import CatalogDirectSourceReviewGateOptions, compile_catalog_direct_source_review_gate
from foundry.catalog_direct_source_review_template import (
    CatalogDirectSourceReviewTemplateOptions,
    compile_catalog_direct_source_review_template,
)
from foundry.catalog_reviewer_completion_intake import CatalogReviewerCompletionIntakeOptions, compile_catalog_reviewer_completion_intake
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_direct_source_review_completion_blocks_without_evidence(tmp_path: Path):
    candidates_path = _write_resolution_candidates(tmp_path, [_resolution_candidate("education"), _resolution_candidate("health", domain="health_wellness_reference")])
    templates = compile_catalog_direct_source_review_template(
        CatalogDirectSourceReviewTemplateOptions(
            resolution_candidates_path=candidates_path,
            output_root=tmp_path / "templates",
            created_at=CREATED_AT,
        )
    )

    result = compile_catalog_direct_source_review_completion(
        CatalogDirectSourceReviewCompletionOptions(
            templates_path=Path(templates["outputPaths"]["directSourceReviewPackets"]),
            output_root=tmp_path / "completion",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog direct-source review completion assembler tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; direct-source review completion assembler tooling only"
    assert result["recordCounts"]["directSourceReviewTemplates"] == 2
    assert result["recordCounts"]["reviewEvidenceRecords"] == 0
    assert result["recordCounts"]["directSourceReviewPackets"] == 2
    assert result["recordCounts"]["completedDirectSourceReviews"] == 0
    assert result["recordCounts"]["blockedDirectSourceReviews"] == 2
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "missing_evidence_blocks_without_completion")

    packets = read_json(Path(result["outputRoot"]) / "direct-source-review-packets.json")["directSourceReviewPackets"]
    assert all(packet["completion_status"] == "blocked_review_evidence_required" for packet in packets)

    gate = compile_catalog_direct_source_review_gate(
        CatalogDirectSourceReviewGateOptions(
            resolution_candidates_path=candidates_path,
            output_root=tmp_path / "gate",
            direct_source_reviews_path=Path(result["outputPaths"]["directSourceReviewPackets"]),
            created_at=CREATED_AT,
        )
    )
    assert gate["valid"], gate["issues"]
    assert gate["recordCounts"]["completedSourceReviewCompletionPackets"] == 0
    assert gate["recordCounts"]["blockedSourceReviewCompletionPackets"] == 2


def test_catalog_direct_source_review_completion_completed_fixture_flows_to_train_67(tmp_path: Path):
    candidate = _resolution_candidate("education")
    candidates_path = _write_resolution_candidates(tmp_path, [candidate])
    templates = compile_catalog_direct_source_review_template(
        CatalogDirectSourceReviewTemplateOptions(
            resolution_candidates_path=candidates_path,
            output_root=tmp_path / "templates",
            created_at=CREATED_AT,
        )
    )
    evidence_path = _write_review_evidence(tmp_path, [_completed_review_evidence(candidate)])
    decision_inputs_path = _write_decision_inputs(tmp_path, [_decision_input_packet("education")])

    completion = compile_catalog_direct_source_review_completion(
        CatalogDirectSourceReviewCompletionOptions(
            templates_path=Path(templates["outputPaths"]["directSourceReviewPackets"]),
            output_root=tmp_path / "completion",
            review_evidence_path=evidence_path,
            created_at=CREATED_AT,
        )
    )

    assert completion["valid"], completion["issues"]
    assert completion["recordCounts"]["completedDirectSourceReviews"] == 1
    assert completion["recordCounts"]["blockedDirectSourceReviews"] == 0
    assert _check(completion, "completed_packets_require_direct_source_not_catalog")

    gate = compile_catalog_direct_source_review_gate(
        CatalogDirectSourceReviewGateOptions(
            resolution_candidates_path=candidates_path,
            output_root=tmp_path / "gate",
            direct_source_reviews_path=Path(completion["outputPaths"]["directSourceReviewPackets"]),
            created_at=CREATED_AT,
        )
    )
    assert gate["valid"], gate["issues"]
    assert gate["recordCounts"]["completedSourceReviewCompletionPackets"] == 1

    intake = compile_catalog_reviewer_completion_intake(
        CatalogReviewerCompletionIntakeOptions(
            decision_inputs_path=decision_inputs_path,
            output_root=tmp_path / "intake",
            review_packets_path=Path(gate["outputPaths"]["sourceReviewCompletionPackets"]),
            created_at=CREATED_AT,
        )
    )
    assert intake["valid"], intake["issues"]
    assert intake["recordCounts"]["completedReviewCompletions"] == 1
    assert intake["recordCounts"]["completedDecisionArtifacts"] == 1


def test_catalog_direct_source_review_completion_rejects_outside_legal_without_artifact(tmp_path: Path):
    candidate = _resolution_candidate("education")
    templates_path = _templates_path(tmp_path, candidate)
    evidence = _completed_review_evidence(candidate)
    evidence["legal_terms_entry"]["outside_legal_required"] = True
    evidence["legal_terms_entry"]["approval_artifact_path"] = ""
    evidence_path = _write_review_evidence(tmp_path, [evidence])

    result = compile_catalog_direct_source_review_completion(
        CatalogDirectSourceReviewCompletionOptions(
            templates_path=templates_path,
            output_root=tmp_path / "completion",
            review_evidence_path=evidence_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert result["recordCounts"]["completedDirectSourceReviews"] == 0
    assert any("outside legal required source requires approval_artifact_path" in issue for issue in result["issues"])


def test_catalog_direct_source_review_completion_rejects_catalog_candidate_completion(tmp_path: Path):
    candidate = _resolution_candidate("education")
    templates_path = _templates_path(tmp_path, candidate)
    evidence = _completed_review_evidence(candidate)
    evidence["source_lane_entry"]["source_id"] = "catalog.candidate.education"
    evidence["source_lane_entry"]["source_class"] = "public_catalog"
    evidence_path = _write_review_evidence(tmp_path, [evidence])

    result = compile_catalog_direct_source_review_completion(
        CatalogDirectSourceReviewCompletionOptions(
            templates_path=templates_path,
            output_root=tmp_path / "completion",
            review_evidence_path=evidence_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert result["recordCounts"]["completedDirectSourceReviews"] == 0
    assert any("source_lane_entry.source_id must not remain catalog.candidate" in issue for issue in result["issues"])
    assert any("source_lane_entry.source_class must not be public_catalog" in issue for issue in result["issues"])


def test_catalog_direct_source_review_completion_rejects_private_evidence(tmp_path: Path):
    candidate = _resolution_candidate("education")
    templates_path = _templates_path(tmp_path, candidate)
    evidence = _completed_review_evidence(candidate)
    evidence["goal_text"] = "I need this for my private schedule"
    evidence_path = _write_review_evidence(tmp_path, [evidence])

    result = compile_catalog_direct_source_review_completion(
        CatalogDirectSourceReviewCompletionOptions(
            templates_path=templates_path,
            output_root=tmp_path / "completion",
            review_evidence_path=evidence_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "review_evidence_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_direct_source_review_completion_stable_ordering(tmp_path: Path):
    candidates_path = _write_resolution_candidates(
        tmp_path,
        [
            _resolution_candidate("z", domain="health_wellness_reference", source_name="Zed Agency"),
            _resolution_candidate("a", domain="education_credentialing", source_name="Alpha Agency"),
        ],
    )
    templates = compile_catalog_direct_source_review_template(
        CatalogDirectSourceReviewTemplateOptions(
            resolution_candidates_path=candidates_path,
            output_root=tmp_path / "templates",
            created_at=CREATED_AT,
        )
    )

    first = compile_catalog_direct_source_review_completion(
        CatalogDirectSourceReviewCompletionOptions(
            templates_path=Path(templates["outputPaths"]["directSourceReviewPackets"]),
            output_root=tmp_path / "first",
            created_at=CREATED_AT,
        )
    )
    second = compile_catalog_direct_source_review_completion(
        CatalogDirectSourceReviewCompletionOptions(
            templates_path=Path(templates["outputPaths"]["directSourceReviewPackets"]),
            output_root=tmp_path / "second",
            created_at=CREATED_AT,
        )
    )

    first_packets = read_json(Path(first["outputRoot"]) / "direct-source-review-packets.json")["directSourceReviewPackets"]
    second_packets = read_json(Path(second["outputRoot"]) / "direct-source-review-packets.json")["directSourceReviewPackets"]
    assert first_packets == second_packets
    assert first_packets == sorted(first_packets, key=lambda item: (item["candidate_id"], item["resolution_id"]))


def _templates_path(tmp_path: Path, candidate: dict[str, object]) -> Path:
    candidates_path = _write_resolution_candidates(tmp_path, [candidate])
    templates = compile_catalog_direct_source_review_template(
        CatalogDirectSourceReviewTemplateOptions(
            resolution_candidates_path=candidates_path,
            output_root=tmp_path / "templates",
            created_at=CREATED_AT,
        )
    )
    return Path(templates["outputPaths"]["directSourceReviewPackets"])


def _write_resolution_candidates(tmp_path: Path, candidates: list[dict[str, object]]) -> Path:
    path = tmp_path / "direct-source-resolution-candidates.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.catalogDirectSourceResolutionCandidates.v1",
            "createdAt": CREATED_AT,
            "resolutionCandidates": candidates,
        },
    )
    return path


def _write_review_evidence(tmp_path: Path, records: list[dict[str, object]]) -> Path:
    path = tmp_path / "direct-source-review-evidence.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.catalogDirectSourceReviewEvidence.v1",
            "createdAt": CREATED_AT,
            "directSourceReviewEvidence": records,
        },
    )
    return path


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


def _resolution_candidate(suffix: str, *, domain: str = "education_credentialing", source_name: str = "Example Public Reference Candidate") -> dict[str, object]:
    return {
        "schema_version": "1.0.0",
        "resolution_id": f"catalog_direct_source_resolution.{suffix}",
        "created_at": CREATED_AT,
        "status": "blocked_direct_source_review_required",
        "catalog_source_status": "discovery_only_not_authority",
        "review_required": True,
        "direct_source_authority_allowed": False,
        "pack_output_allowed": False,
        "r2_packable_artifact_allowed": False,
        "work_item_id": f"catalog_review_work_item.{suffix}",
        "proposal_id": f"catalog_terms_resolution.{suffix}",
        "intake_id": f"catalog_governance_intake.{suffix}",
        "candidate_id": f"catalog_candidate.{suffix}",
        "decision_input_id": f"catalog_approval_decision_input.{suffix}",
        "source_id": f"catalog.candidate.{suffix}",
        "source_name": source_name,
        "domain_guess": domain,
        "candidate_locators": [],
        "locatorSummary": {
            "locatorCandidateCount": 0,
            "directSourceLocatorCandidateCount": 0,
            "termsLocatorCandidateCount": 0,
        },
        "missing_locator_classes": ["publisher_url", "source_specific_terms_url"],
        "blocking_reasons": ["direct_source_authority_resolution_required"],
        "non_claims": ["direct-source resolution candidate only", "not approval"],
    }


def _decision_input_packet(suffix: str) -> dict[str, object]:
    return {
        "schema_version": "1.0.0",
        "decision_input_id": f"catalog_approval_decision_input.{suffix}",
        "proposal_id": f"catalog_terms_resolution.{suffix}",
        "intake_id": f"catalog_governance_intake.{suffix}",
        "candidate_id": f"catalog_candidate.{suffix}",
        "source_id": f"catalog.candidate.{suffix}",
        "domain_guess": "education_credentialing",
        "source_name": "Example Public Reference Candidate",
        "packet_status": "blocked_review_required",
        "draft_decision_artifact": {
            "kind": "ambitions.sourceAtlas.catalogApprovalFinalizerDecision.v1",
            "decision_status": "draft_not_approved",
            "selected_proposal_ids": [f"catalog_terms_resolution.{suffix}"],
        },
        "non_claims": ["decision input packet only", "not approval"],
    }


def _completed_review_evidence(candidate: dict[str, object]) -> dict[str, object]:
    source_id = f"approved.public.reference.{candidate['candidate_id']}"
    license_id = f"{source_id}.terms"
    api_policy_id = f"api.{source_id}.v1"
    return {
        "direct_source_review_packet_id": f"direct_source_review.{candidate['candidate_id']}",
        "resolution_id": candidate["resolution_id"],
        "candidate_id": candidate["candidate_id"],
        "completion_status": "completed",
        "review_owner": "Ambitions owner technical review fixture",
        "reviewed_at": "2026-06-28",
        "outside_legal_status": "not_claimed",
        "outside_legal_approval_artifact": "",
        "review_artifacts": ["docs/qa/source-atlas/legal/fixture-review-artifact.md"],
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
        "non_claims": ["direct-source review evidence fixture only", "not legal approval"],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
