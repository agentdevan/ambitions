from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_terms_resolution import CatalogTermsResolutionOptions, compile_catalog_terms_resolution
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_terms_resolution_proposes_known_license_urls_without_approval(tmp_path: Path):
    input_path = _write_requests(tmp_path, [_request("cc-by"), _request("ca-ogl-lgo", intake_id="catalog_governance_intake.ca")])

    result = compile_catalog_terms_resolution(
        CatalogTermsResolutionOptions(
            input_path=input_path,
            output_root=tmp_path / "terms-resolution",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog terms-resolution proposal tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; advisory terms-resolution proposals only"
    assert result["recordCounts"]["approvalRequests"] == 2
    assert result["recordCounts"]["termsResolutionProposals"] == 2
    assert result["recordCounts"]["blockedTermsResolutions"] == 0
    assert result["recordCounts"]["completedApprovalArtifacts"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "resolution_templates_are_not_approvals")
    assert _check(result, "terms_resolution_emits_no_claims")

    proposals = read_json(Path(result["outputRoot"]) / "terms-resolution-proposals.json")["termsResolutionProposals"]
    by_alias = {proposal["detected_license_alias"]: proposal for proposal in proposals}
    assert by_alias["cc-by"]["terms_resolution"]["terms_url"] == "https://creativecommons.org/licenses/by/4.0/legalcode.en"
    assert by_alias["ca-ogl-lgo"]["terms_resolution"]["terms_url"] == "https://open.canada.ca/en/open-government-licence-canada"
    for proposal in proposals:
        template = proposal["resolved_approval_artifact_template"]
        legal = template["approved_entries"][0]["legal_terms_entry"]
        assert template["approval_status"] == "draft_not_approved"
        assert template["source_lane_review_complete"] is False
        assert template["legal_terms_review_complete"] is False
        assert template["api_governance_review_complete"] is False
        assert legal["terms_url"].startswith("https://")
        assert legal["pack_output_allowed"] is False
        assert legal["redistribution_allowed"] is False
        assert legal["review_required"] is True


def test_catalog_terms_resolution_blocks_unknown_license_alias_as_valid_classification(tmp_path: Path):
    input_path = _write_requests(tmp_path, [_request("custom-unknown-license")])

    result = compile_catalog_terms_resolution(
        CatalogTermsResolutionOptions(
            input_path=input_path,
            output_root=tmp_path / "terms-resolution",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["termsResolutionProposals"] == 0
    assert result["recordCounts"]["blockedTermsResolutions"] == 1
    assert _check(result, "known_aliases_resolved_or_blocked")
    blocked = read_json(Path(result["outputRoot"]) / "blocked-terms-resolutions.json")["blockedTermsResolutions"]
    assert blocked[0]["status"] == "blocked"
    assert "unresolved_license_alias" in blocked[0]["blocking_reasons"]
    assert read_json(Path(result["outputRoot"]) / "completed-approval-artifacts.json")["completedApprovalArtifacts"] == []


def test_catalog_terms_resolution_rejects_private_input(tmp_path: Path):
    input_path = _write_requests(tmp_path, [_request("cc-by")])
    payload = read_json(input_path)
    payload["approvalRequests"][0]["goal_text"] = "I need this for my private plan"
    write_json(input_path, payload)

    result = compile_catalog_terms_resolution(
        CatalogTermsResolutionOptions(
            input_path=input_path,
            output_root=tmp_path / "terms-resolution",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_terms_resolution_rejects_missing_approval_requests(tmp_path: Path):
    input_path = tmp_path / "empty.json"
    write_json(input_path, {"approvalRequests": []})

    result = compile_catalog_terms_resolution(
        CatalogTermsResolutionOptions(
            input_path=input_path,
            output_root=tmp_path / "terms-resolution",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_schema_valid")
    assert any("must include approval requests" in issue for issue in result["issues"])


def test_catalog_terms_resolution_stable_ordering_is_deterministic(tmp_path: Path):
    input_path = _write_requests(
        tmp_path,
        [
            _request("ca-ogl-lgo", intake_id="catalog_governance_intake.z", domain="health_wellness_reference"),
            _request("cc-by", intake_id="catalog_governance_intake.a", domain="education_credentialing"),
        ],
    )

    first = compile_catalog_terms_resolution(CatalogTermsResolutionOptions(input_path=input_path, output_root=tmp_path / "first", created_at=CREATED_AT))
    second = compile_catalog_terms_resolution(CatalogTermsResolutionOptions(input_path=input_path, output_root=tmp_path / "second", created_at=CREATED_AT))

    first_proposals = read_json(Path(first["outputRoot"]) / "terms-resolution-proposals.json")["termsResolutionProposals"]
    second_proposals = read_json(Path(second["outputRoot"]) / "terms-resolution-proposals.json")["termsResolutionProposals"]
    assert first_proposals == second_proposals
    assert first_proposals == sorted(first_proposals, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))


def _write_requests(tmp_path: Path, requests: list[dict[str, object]]) -> Path:
    path = tmp_path / "approval-requests.json"
    write_json(path, {"kind": "ambitions.sourceAtlas.catalogRegistryApprovalRequests.v1", "createdAt": CREATED_AT, "approvalRequests": requests})
    return path


def _request(alias: str, *, intake_id: str = "catalog_governance_intake.example", domain: str = "education_credentialing") -> dict[str, object]:
    source_id = "catalog.candidate.example"
    return {
        "schema_version": "1.0.0",
        "request_id": f"catalog_registry_approval_request.{intake_id.rsplit('.', 1)[-1]}",
        "intake_id": intake_id,
        "candidate_id": f"catalog_candidate.{intake_id.rsplit('.', 1)[-1]}",
        "domain_guess": domain,
        "status": "review_required",
        "approval_artifact_template": {
            "kind": "ambitions.sourceAtlas.catalogRegistryMutationApproval.v1",
            "approval_artifact_id": "",
            "approval_status": "draft_not_approved",
            "review_owner": "",
            "reviewed_at": "",
            "source_lane_review_complete": False,
            "legal_terms_review_complete": False,
            "api_governance_review_complete": False,
            "outside_legal_status": "not_claimed",
            "outside_legal_approval_artifact": "",
            "selected_intake_ids": [intake_id],
            "approved_entries": [
                {
                    "intake_id": intake_id,
                    "source_lane_entry": {
                        "source_id": source_id,
                        "source_name": "Example Public Catalog Candidate",
                        "source_class": "",
                        "authority_class": "",
                        "jurisdiction": "",
                        "review_status": "review_required",
                        "r2_pack_policy": "pack_blocked_unknown_terms",
                    },
                    "legal_terms_entry": {
                        "license_id": f"review_required.{source_id}",
                        "license_name": "",
                        "license_url": alias,
                        "terms_url": "",
                        "rights_url": "",
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
                        "live_flag_required": True,
                        "execute_flag_required": True,
                        "secret_redaction_required": True,
                        "evidence_output_policy": "candidate_metadata_only_until_review",
                    },
                }
            ],
        },
        "non_claims": [
            "approval request only",
            "template is not approval",
            "not active registry mutation",
            "not legal approval",
            "not API approval",
            "not source authority",
        ],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
