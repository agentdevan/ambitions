from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_direct_source_resolution import (
    CatalogDirectSourceResolutionOptions,
    compile_catalog_direct_source_resolution,
)
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_direct_source_resolution_emits_blocked_candidates(tmp_path: Path):
    work_items_path = _write_work_items(tmp_path, [_work_item("education"), _work_item("health", domain="health_wellness_reference")])
    candidate_review_path = _write_candidate_review(
        tmp_path,
        [
            _candidate_packet("education"),
            _candidate_packet("health", domain="health_wellness_reference", dataset_url="https://example.gov/health/dataset"),
        ],
    )
    decision_inputs_path = _write_decision_inputs(tmp_path, [_decision_packet("education"), _decision_packet("health")])

    result = compile_catalog_direct_source_resolution(
        CatalogDirectSourceResolutionOptions(
            work_items_path=work_items_path,
            output_root=tmp_path / "direct-source-resolution",
            candidate_review_path=candidate_review_path,
            decision_inputs_path=decision_inputs_path,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog direct-source resolution candidate tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; direct-source resolution candidates only"
    assert result["recordCounts"]["reviewWorkItems"] == 2
    assert result["recordCounts"]["candidateReviewPackets"] == 2
    assert result["recordCounts"]["decisionInputPackets"] == 2
    assert result["recordCounts"]["directSourceResolutionCandidates"] == 2
    assert result["recordCounts"]["blockedFromAuthorityResolution"] == 2
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "all_resolution_candidates_remain_blocked")
    assert _check(result, "catalog_metadata_remains_discovery_only")
    assert _check(result, "locator_candidates_do_not_approve_authority")

    candidates = read_json(Path(result["outputRoot"]) / "direct-source-resolution-candidates.json")["resolutionCandidates"]
    assert all(candidate["status"] == "blocked_direct_source_review_required" for candidate in candidates)
    assert all(candidate["catalog_source_status"] == "discovery_only_not_authority" for candidate in candidates)
    assert all(candidate["direct_source_authority_allowed"] is False for candidate in candidates)
    assert all(candidate["pack_output_allowed"] is False for candidate in candidates)
    assert all("direct_source_authority_resolution_required" in candidate["blocking_reasons"] for candidate in candidates)
    assert all("source_specific_terms_url" in candidate["missing_locator_classes"] for candidate in candidates)
    assert all("jurisdiction_evidence" in candidate["missing_locator_classes"] for candidate in candidates)
    assert any(candidate["locatorSummary"]["locatorCandidateCount"] > 0 for candidate in candidates)


def test_catalog_direct_source_resolution_treats_locators_as_evidence_only(tmp_path: Path):
    work_items_path = _write_work_items(tmp_path, [_work_item("education")])
    candidate_review_path = _write_candidate_review(
        tmp_path,
        [
            _candidate_packet(
                "education",
                publisher_url="https://agency.example.gov",
                dataset_url="https://agency.example.gov/data/programs",
                terms_url="https://agency.example.gov/terms",
                rights_url="https://agency.example.gov/rights",
                api_docs_url="https://agency.example.gov/api",
            )
        ],
    )
    decision_inputs_path = _write_decision_inputs(tmp_path, [_decision_packet("education")])

    result = compile_catalog_direct_source_resolution(
        CatalogDirectSourceResolutionOptions(
            work_items_path=work_items_path,
            output_root=tmp_path / "direct-source-resolution",
            candidate_review_path=candidate_review_path,
            decision_inputs_path=decision_inputs_path,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["candidatesWithLocatorCandidates"] == 1
    assert result["recordCounts"]["missingDirectSourceLocator"] == 0
    candidate = read_json(Path(result["outputRoot"]) / "direct-source-resolution-candidates.json")["resolutionCandidates"][0]
    assert candidate["candidate_locators"]
    assert all(locator["authority_use_allowed"] is False for locator in candidate["candidate_locators"])
    assert all(locator["review_required"] is True for locator in candidate["candidate_locators"])
    assert candidate["direct_source_authority_allowed"] is False
    assert candidate["r2_packable_artifact_allowed"] is False
    assert "direct_source_locator_url" not in candidate["missing_locator_classes"]
    assert "authority_class_evidence" in candidate["missing_locator_classes"]
    assert "source_class_evidence" in candidate["missing_locator_classes"]


def test_catalog_direct_source_resolution_rejects_private_input(tmp_path: Path):
    work_item = _work_item("education")
    work_item["goal_text"] = "I need this for my private plan"
    work_items_path = _write_work_items(tmp_path, [work_item])

    result = compile_catalog_direct_source_resolution(
        CatalogDirectSourceResolutionOptions(
            work_items_path=work_items_path,
            output_root=tmp_path / "direct-source-resolution",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "work_items_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_direct_source_resolution_stable_ordering(tmp_path: Path):
    work_items_path = _write_work_items(
        tmp_path,
        [
            _work_item("z", domain="health_wellness_reference", source_name="Zed Agency"),
            _work_item("a", domain="education_credentialing", source_name="Alpha Agency"),
        ],
    )

    first = compile_catalog_direct_source_resolution(
        CatalogDirectSourceResolutionOptions(work_items_path=work_items_path, output_root=tmp_path / "first", created_at=CREATED_AT)
    )
    second = compile_catalog_direct_source_resolution(
        CatalogDirectSourceResolutionOptions(work_items_path=work_items_path, output_root=tmp_path / "second", created_at=CREATED_AT)
    )

    first_candidates = read_json(Path(first["outputRoot"]) / "direct-source-resolution-candidates.json")["resolutionCandidates"]
    second_candidates = read_json(Path(second["outputRoot"]) / "direct-source-resolution-candidates.json")["resolutionCandidates"]
    assert first_candidates == second_candidates
    assert first_candidates == sorted(
        first_candidates,
        key=lambda item: (item["domain_guess"], item["source_name"], item["candidate_id"], item["work_item_id"]),
    )


def _write_work_items(tmp_path: Path, work_items: list[dict[str, object]]) -> Path:
    path = tmp_path / "review-work-items.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.catalogReviewWorkItems.v1",
            "createdAt": CREATED_AT,
            "reviewWorkItems": work_items,
        },
    )
    return path


def _write_candidate_review(tmp_path: Path, packets: list[dict[str, object]]) -> Path:
    path = tmp_path / "review-packets.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.catalogCandidateReviewPackets.v1",
            "createdAt": CREATED_AT,
            "reviewPackets": packets,
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


def _work_item(suffix: str, *, domain: str = "education_credentialing", source_name: str = "Example Agency") -> dict[str, object]:
    return {
        "schema_version": "1.0.0",
        "work_item_id": f"catalog_review_work_item.{suffix}",
        "created_at": CREATED_AT,
        "status": "blocked_review_work_required",
        "proposal_id": f"catalog_terms_resolution.{suffix}",
        "intake_id": f"catalog_governance_intake.{suffix}",
        "candidate_id": f"catalog_candidate.{suffix}",
        "decision_input_id": f"catalog_approval_decision_input.{suffix}",
        "domain_guess": domain,
        "source_id": f"catalog.candidate.{suffix}",
        "source_name": source_name,
        "work_lanes": [
            "direct_source_authority_resolution",
            "source_lane_review",
            "legal_terms_review",
            "api_governance_review",
            "packability_decision",
        ],
        "blocking_reasons": ["source_lane_review_required", "legal_terms_review_required", "api_governance_review_required"],
        "non_claims": ["work item only", "not approval"],
    }


def _candidate_packet(
    suffix: str,
    *,
    domain: str = "education_credentialing",
    publisher_url: str = "",
    dataset_url: str = "https://example.gov/public-dataset",
    terms_url: str = "",
    rights_url: str = "",
    api_docs_url: str = "",
) -> dict[str, object]:
    return {
        "schema_version": "1.0.0",
        "packet_id": f"catalog_candidate_review_packet.{suffix}",
        "candidate_id": f"catalog_candidate.{suffix}",
        "publisher_name": "Example Agency",
        "publisher_url": publisher_url,
        "dataset_url": dataset_url,
        "distribution_urls": [f"https://example.gov/public-data/{suffix}.json"],
        "terms_url": terms_url,
        "rights_url": rights_url,
        "api_docs_url": api_docs_url,
        "authority_class_guess": "official_government",
        "source_class_guess": "public_catalog",
        "declared_jurisdiction": "unknown",
        "declared_license": "cc-by",
        "domain_guess": domain,
        "review_required": True,
        "claim_authority_allowed": False,
        "pack_output_allowed": False,
    }


def _decision_packet(suffix: str) -> dict[str, object]:
    return {
        "schema_version": "1.0.0",
        "decision_input_id": f"catalog_approval_decision_input.{suffix}",
        "proposal_id": f"catalog_terms_resolution.{suffix}",
        "intake_id": f"catalog_governance_intake.{suffix}",
        "candidate_id": f"catalog_candidate.{suffix}",
        "source_id": f"catalog.candidate.{suffix}",
        "domain_guess": "education_credentialing",
        "source_name": "Example Agency",
        "source_lane_decision": {
            "current_entry": {
                "source_id": f"catalog.candidate.{suffix}",
                "source_name": "Example Agency",
                "authority_class": "",
                "source_class": "",
                "jurisdiction": "",
                "review_status": "review_required",
            }
        },
        "legal_terms_decision": {
            "current_entry": {
                "license_id": f"review_required.catalog.candidate.{suffix}",
                "license_url": "https://creativecommons.org/licenses/by/4.0/legalcode.en",
                "terms_url": "https://creativecommons.org/licenses/by/4.0/legalcode.en",
                "rights_url": "https://creativecommons.org/licenses/by/4.0/",
                "review_required": True,
                "pack_output_allowed": False,
            }
        },
        "api_governance_decision": {
            "current_entry": {
                "api_mode": "review_required_before_live_harvest",
                "source_id": f"catalog.candidate.{suffix}",
                "secret_redaction_required": True,
            }
        },
        "non_claims": ["decision input packet only", "not approval"],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
