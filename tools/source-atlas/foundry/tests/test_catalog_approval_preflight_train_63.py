from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_approval_preflight import CatalogApprovalPreflightOptions, compile_catalog_approval_preflight
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_approval_preflight_blocks_incomplete_terms_proposals_without_approval(tmp_path: Path):
    input_path = _write_terms_proposals(tmp_path, [_incomplete_proposal("education"), _incomplete_proposal("health", domain="health_wellness_reference")])

    result = compile_catalog_approval_preflight(
        CatalogApprovalPreflightOptions(
            terms_proposals_path=input_path,
            output_root=tmp_path / "approval-preflight",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog approval decision preflight tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; decision preflight tooling only"
    assert result["recordCounts"]["termsResolutionProposals"] == 2
    assert result["recordCounts"]["decisionPreflightRecords"] == 2
    assert result["recordCounts"]["decisionReadyRecords"] == 0
    assert result["recordCounts"]["blockedDecisionRecords"] == 2
    assert result["recordCounts"]["decisionDraftTemplates"] == 2
    assert result["recordCounts"]["completedApprovalArtifacts"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "draft_templates_are_not_approvals")
    assert _check(result, "preflight_emits_no_claims")

    records = read_json(Path(result["outputRoot"]) / "decision-preflight-records.json")["decisionPreflightRecords"]
    assert all(record["status"] == "blocked_review_required" for record in records)
    assert all("source_lane_fields_incomplete" in record["blocking_reasons"] for record in records)
    assert all("legal_terms_fields_incomplete" in record["blocking_reasons"] for record in records)
    assert all("api_governance_fields_incomplete" in record["blocking_reasons"] for record in records)
    assert "authority_class" in records[0]["missing_source_lane_fields"]
    assert "source_specific_restrictions" in records[0]["missing_legal_terms_fields"]
    assert "retry_policy" in records[0]["missing_api_governance_fields"]

    templates = read_json(Path(result["outputRoot"]) / "decision-draft-templates.json")["decisionDraftTemplates"]
    assert all(template["decision_status"] == "draft_not_approved" for template in templates)
    assert all("draft_entries" in template for template in templates)
    assert read_json(Path(result["outputRoot"]) / "completed-approval-artifacts.json")["completedApprovalArtifacts"] == []


def test_catalog_approval_preflight_marks_complete_proposal_ready_without_approval(tmp_path: Path):
    input_path = _write_terms_proposals(tmp_path, [_complete_proposal("education")])

    result = compile_catalog_approval_preflight(
        CatalogApprovalPreflightOptions(
            terms_proposals_path=input_path,
            output_root=tmp_path / "approval-preflight",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["decisionReadyRecords"] == 1
    assert result["recordCounts"]["blockedDecisionRecords"] == 0
    assert result["recordCounts"]["completedApprovalArtifacts"] == 0
    records = read_json(Path(result["outputRoot"]) / "decision-preflight-records.json")["decisionPreflightRecords"]
    assert records[0]["status"] == "decision_ready_for_reviewer_completion"
    assert records[0]["missing_source_lane_fields"] == []
    assert records[0]["missing_legal_terms_fields"] == []
    assert records[0]["missing_api_governance_fields"] == []
    assert records[0]["required_reviewer_actions"] == ["reviewer may complete a decision artifact, but this preflight still does not approve it"]


def test_catalog_approval_preflight_rejects_private_input(tmp_path: Path):
    input_path = _write_terms_proposals(tmp_path, [_incomplete_proposal("education")])
    payload = read_json(input_path)
    payload["termsResolutionProposals"][0]["goal_text"] = "I need this for my private plan"
    write_json(input_path, payload)

    result = compile_catalog_approval_preflight(
        CatalogApprovalPreflightOptions(
            terms_proposals_path=input_path,
            output_root=tmp_path / "approval-preflight",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_approval_preflight_rejects_missing_proposals(tmp_path: Path):
    input_path = tmp_path / "empty.json"
    write_json(input_path, {"termsResolutionProposals": []})

    result = compile_catalog_approval_preflight(
        CatalogApprovalPreflightOptions(
            terms_proposals_path=input_path,
            output_root=tmp_path / "approval-preflight",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_schema_valid")
    assert any("must include terms-resolution proposals" in issue for issue in result["issues"])


def test_catalog_approval_preflight_stable_ordering_is_deterministic(tmp_path: Path):
    input_path = _write_terms_proposals(
        tmp_path,
        [
            _incomplete_proposal("z", domain="health_wellness_reference"),
            _incomplete_proposal("a", domain="education_credentialing"),
        ],
    )

    first = compile_catalog_approval_preflight(CatalogApprovalPreflightOptions(terms_proposals_path=input_path, output_root=tmp_path / "first", created_at=CREATED_AT))
    second = compile_catalog_approval_preflight(CatalogApprovalPreflightOptions(terms_proposals_path=input_path, output_root=tmp_path / "second", created_at=CREATED_AT))

    first_records = read_json(Path(first["outputRoot"]) / "decision-preflight-records.json")["decisionPreflightRecords"]
    second_records = read_json(Path(second["outputRoot"]) / "decision-preflight-records.json")["decisionPreflightRecords"]
    assert first_records == second_records
    assert first_records == sorted(first_records, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))


def _write_terms_proposals(tmp_path: Path, proposals: list[dict[str, object]]) -> Path:
    path = tmp_path / "terms-resolution-proposals.json"
    write_json(path, {"kind": "ambitions.sourceAtlas.catalogTermsResolutionProposals.v1", "createdAt": CREATED_AT, "termsResolutionProposals": proposals})
    return path


def _incomplete_proposal(suffix: str, *, domain: str = "education_credentialing") -> dict[str, object]:
    source_id = f"catalog.candidate.{suffix}"
    intake_id = f"catalog_governance_intake.{suffix}"
    return {
        "schema_version": "1.0.0",
        "proposal_id": f"catalog_terms_resolution.{suffix}",
        "request_id": f"catalog_registry_approval_request.{suffix}",
        "intake_id": intake_id,
        "candidate_id": f"catalog_candidate.{suffix}",
        "domain_guess": domain,
        "status": "terms_resolution_proposed",
        "source_id": source_id,
        "source_name": "Example Catalog Candidate",
        "resolved_approval_artifact_template": {
            "kind": "ambitions.sourceAtlas.catalogRegistryMutationApproval.v1",
            "approval_status": "draft_not_approved",
            "selected_intake_ids": [intake_id],
            "approved_entries": [
                {
                    "intake_id": intake_id,
                    "source_lane_entry": {
                        "source_id": source_id,
                        "source_name": "Example Catalog Candidate",
                        "source_class": "",
                        "authority_class": "",
                        "jurisdiction": "",
                        "review_status": "review_required",
                        "r2_pack_policy": "pack_blocked_unknown_terms",
                    },
                    "legal_terms_entry": {
                        "license_id": f"review_required.{source_id}",
                        "license_name": "Creative Commons Attribution 4.0 International",
                        "license_url": "https://creativecommons.org/licenses/by/4.0/legalcode.en",
                        "terms_url": "https://creativecommons.org/licenses/by/4.0/legalcode.en",
                        "rights_url": "https://creativecommons.org/licenses/by/4.0/",
                        "redistribution_allowed": False,
                        "pack_output_allowed": False,
                        "review_required": True,
                        "outside_legal_status": "not_claimed",
                        "review_owner": "",
                        "reviewed_at": "",
                    },
                    "api_policy_entry": {
                        "api_policy_id": f"review_required.{source_id}",
                        "source_id": source_id,
                        "api_mode": "review_required_before_live_harvest",
                        "missing_key_behavior": "",
                        "retry_policy": "",
                        "backoff_policy": "",
                        "circuit_breaker_policy": "",
                        "budget_owner": "",
                        "evidence_output_policy": "candidate_metadata_only_until_review",
                        "live_flag_required": True,
                        "execute_flag_required": True,
                        "secret_redaction_required": True,
                    },
                }
            ],
        },
        "blocking_reasons": [
            "source_lane_review_required",
            "legal_terms_review_required",
            "api_governance_review_required",
            "approval_artifact_still_required",
        ],
        "non_claims": ["terms resolution proposal only", "not an approval"],
    }


def _complete_proposal(suffix: str) -> dict[str, object]:
    source_id = f"approved.public.reference.{suffix}"
    license_id = f"{source_id}.terms"
    api_policy_id = f"api.{source_id}.v1"
    intake_id = f"catalog_governance_intake.{suffix}"
    proposal = _incomplete_proposal(suffix)
    proposal["source_id"] = source_id
    proposal["blocking_reasons"] = []
    proposal["resolved_approval_artifact_template"]["approved_entries"][0] = {
        "intake_id": intake_id,
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
            "forbidden_artifact_classes": ["private_goal_graph"],
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
    return proposal


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
