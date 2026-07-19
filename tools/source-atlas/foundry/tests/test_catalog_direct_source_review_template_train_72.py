from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_direct_source_review_gate import CatalogDirectSourceReviewGateOptions, compile_catalog_direct_source_review_gate
from foundry.catalog_direct_source_review_template import (
    CatalogDirectSourceReviewTemplateOptions,
    compile_catalog_direct_source_review_template,
)
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_direct_source_review_template_emits_blocked_templates(tmp_path: Path):
    candidates_path = _write_resolution_candidates(tmp_path, [_resolution_candidate("education"), _resolution_candidate("health", domain="health_wellness_reference")])

    result = compile_catalog_direct_source_review_template(
        CatalogDirectSourceReviewTemplateOptions(
            resolution_candidates_path=candidates_path,
            output_root=tmp_path / "templates",
            reviewer="Ambitions source review",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog direct-source review template tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; direct-source review templates only"
    assert result["recordCounts"]["resolutionCandidates"] == 2
    assert result["recordCounts"]["directSourceReviewPacketTemplates"] == 2
    assert result["recordCounts"]["completedDirectSourceReviews"] == 0
    assert result["recordCounts"]["completedSourceReviewCompletionPackets"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "templates_are_blocked_not_completed")
    assert _check(result, "templates_are_gate_compatible")

    templates = read_json(Path(result["outputRoot"]) / "direct-source-review-packet-templates.json")["directSourceReviewPackets"]
    assert all(template["completion_status"] == "blocked_review_required" for template in templates)
    assert all(template["draft_source_lane_entry"]["review_status"] == "review_required" for template in templates)
    assert all(template["draft_legal_terms_entry"]["pack_output_allowed"] is False for template in templates)
    assert all(template["draft_api_policy_entry"]["live_flag_required"] is True for template in templates)
    assert all("source_lane_entry" in template["reviewer_only_fields"] for template in templates)


def test_catalog_direct_source_review_template_feeds_train_71_as_blocked(tmp_path: Path):
    candidate = _resolution_candidate("education")
    candidates_path = _write_resolution_candidates(tmp_path, [candidate])
    templates = compile_catalog_direct_source_review_template(
        CatalogDirectSourceReviewTemplateOptions(
            resolution_candidates_path=candidates_path,
            output_root=tmp_path / "templates",
            created_at=CREATED_AT,
        )
    )

    gate = compile_catalog_direct_source_review_gate(
        CatalogDirectSourceReviewGateOptions(
            resolution_candidates_path=candidates_path,
            output_root=tmp_path / "gate",
            direct_source_reviews_path=Path(templates["outputPaths"]["directSourceReviewPackets"]),
            created_at=CREATED_AT,
        )
    )

    assert gate["valid"], gate["issues"]
    assert gate["recordCounts"]["directSourceReviewPackets"] == 1
    assert gate["recordCounts"]["sourceReviewCompletionPackets"] == 1
    assert gate["recordCounts"]["completedSourceReviewCompletionPackets"] == 0
    assert gate["recordCounts"]["blockedSourceReviewCompletionPackets"] == 1
    packet = read_json(Path(gate["outputRoot"]) / "source-review-completion-packets.json")["sourceReviewCompletionPackets"][0]
    assert packet["completion_status"] == "blocked_direct_source_review_required"
    assert "direct_source_review_status_blocked_review_required" in packet["blocking_reasons"]


def test_catalog_direct_source_review_template_rejects_private_candidate_input(tmp_path: Path):
    candidate = _resolution_candidate("education")
    candidate["goal_text"] = "I need this for my private schedule"
    candidates_path = _write_resolution_candidates(tmp_path, [candidate])

    result = compile_catalog_direct_source_review_template(
        CatalogDirectSourceReviewTemplateOptions(
            resolution_candidates_path=candidates_path,
            output_root=tmp_path / "templates",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_direct_source_review_template_stable_ordering(tmp_path: Path):
    candidates_path = _write_resolution_candidates(
        tmp_path,
        [
            _resolution_candidate("z", domain="health_wellness_reference", source_name="Zed Agency"),
            _resolution_candidate("a", domain="education_credentialing", source_name="Alpha Agency"),
        ],
    )

    first = compile_catalog_direct_source_review_template(
        CatalogDirectSourceReviewTemplateOptions(resolution_candidates_path=candidates_path, output_root=tmp_path / "first", created_at=CREATED_AT)
    )
    second = compile_catalog_direct_source_review_template(
        CatalogDirectSourceReviewTemplateOptions(resolution_candidates_path=candidates_path, output_root=tmp_path / "second", created_at=CREATED_AT)
    )

    first_templates = read_json(Path(first["outputRoot"]) / "direct-source-review-packet-templates.json")["directSourceReviewPackets"]
    second_templates = read_json(Path(second["outputRoot"]) / "direct-source-review-packet-templates.json")["directSourceReviewPackets"]
    assert first_templates == second_templates
    assert first_templates == sorted(first_templates, key=lambda item: (item["domain_guess"], item["source_name"], item["candidate_id"], item["resolution_id"]))


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
        "candidate_locators": [
            {
                "locator_class": "distribution_url",
                "url": f"https://example.gov/public-data/{suffix}.json",
                "source_field": "candidate_review.distribution_urls[0]",
                "evidence_role": "candidate_locator_only",
                "authority_use_allowed": False,
                "review_required": True,
            },
            {
                "locator_class": "draft_legal_terms_url",
                "url": "https://creativecommons.org/licenses/by/4.0/legalcode.en",
                "source_field": "decision_input.legal_terms_decision.current_entry.terms_url",
                "evidence_role": "candidate_locator_only",
                "authority_use_allowed": False,
                "review_required": True,
            },
        ],
        "locatorSummary": {
            "locatorCandidateCount": 2,
            "directSourceLocatorCandidateCount": 1,
            "termsLocatorCandidateCount": 1,
        },
        "missing_locator_classes": ["publisher_url", "source_specific_terms_url", "jurisdiction_evidence"],
        "required_evidence": ["direct_source_authority_evidence", "legal_terms_review_record", "api_governance_policy_record"],
        "blocking_reasons": ["direct_source_authority_resolution_required"],
        "non_claims": ["direct-source resolution candidate only", "not approval"],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
