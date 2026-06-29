from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_candidate_review import CatalogCandidateReviewOptions, compile_catalog_candidate_review
from foundry.catalog_discovery import CatalogDiscoveryOptions, run_catalog_discovery
from foundry.catalog_governance_intake import CatalogGovernanceIntakeOptions, compile_catalog_governance_intake
from foundry.catalog_registry_approval_request import CatalogRegistryApprovalRequestOptions, compile_catalog_registry_approval_request
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"
FIXTURE_ROOT = Path("tools/source-atlas/fixtures/catalog-discovery/train-53-catalogs")


def test_catalog_registry_approval_request_templates_are_not_approvals(tmp_path: Path):
    intake = _run_intake(tmp_path)
    result = compile_catalog_registry_approval_request(
        CatalogRegistryApprovalRequestOptions(
            input_path=Path(intake["outputRoot"]) / "draft-governance-packets.json",
            output_root=tmp_path / "approval-request",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog registry approval request template tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; approval request templates only"
    assert result["recordCounts"]["draftGovernancePackets"] == 6
    assert result["recordCounts"]["approvalRequests"] == 6
    assert result["recordCounts"]["completedApprovalArtifacts"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "templates_are_not_approvals")
    assert _check(result, "approval_requests_emit_no_claims")
    assert _check(result, "no_active_registry_mutations")

    requests = read_json(Path(result["outputRoot"]) / "approval-requests.json")["approvalRequests"]
    assert all(request["approval_artifact_template"]["approval_status"] == "draft_not_approved" for request in requests)
    assert all(request["approval_artifact_template"]["source_lane_review_complete"] is False for request in requests)
    assert all(request["approval_artifact_template"]["legal_terms_review_complete"] is False for request in requests)
    assert all(request["approval_artifact_template"]["api_governance_review_complete"] is False for request in requests)
    assert read_json(Path(result["outputRoot"]) / "completed-approval-artifacts.json")["completedApprovalArtifacts"] == []


def test_catalog_registry_approval_request_can_select_single_intake(tmp_path: Path):
    intake = _run_intake(tmp_path)
    drafts = read_json(Path(intake["outputRoot"]) / "draft-governance-packets.json")["draftGovernancePackets"]
    selected_id = drafts[0]["intake_id"]
    result = compile_catalog_registry_approval_request(
        CatalogRegistryApprovalRequestOptions(
            input_path=Path(intake["outputRoot"]) / "draft-governance-packets.json",
            output_root=tmp_path / "approval-request",
            intake_ids=(selected_id,),
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["approvalRequests"] == 1
    requests = read_json(Path(result["outputRoot"]) / "approval-requests.json")["approvalRequests"]
    assert requests[0]["intake_id"] == selected_id
    assert requests[0]["approval_artifact_template"]["selected_intake_ids"] == [selected_id]


def test_catalog_registry_approval_request_rejects_unknown_selection(tmp_path: Path):
    intake = _run_intake(tmp_path)
    result = compile_catalog_registry_approval_request(
        CatalogRegistryApprovalRequestOptions(
            input_path=Path(intake["outputRoot"]) / "draft-governance-packets.json",
            output_root=tmp_path / "approval-request",
            intake_ids=("catalog_governance_intake.missing",),
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "selection_valid")
    assert any("selected intake id not found" in issue for issue in result["issues"])


def test_catalog_registry_approval_request_rejects_private_input(tmp_path: Path):
    input_path = tmp_path / "drafts.json"
    write_json(
        input_path,
        {
            "draftGovernancePackets": [
                {
                    "intake_id": "catalog_governance_intake.private",
                    "candidate_id": "catalog_candidate.private",
                    "domain_guess": "unclassified_public_reference",
                    "goal_text": "I need this for my private plan",
                    "source_lane_draft": {},
                    "legal_terms_draft": {},
                    "api_governance_draft": {},
                }
            ]
        },
    )

    result = compile_catalog_registry_approval_request(
        CatalogRegistryApprovalRequestOptions(
            input_path=input_path,
            output_root=tmp_path / "approval-request",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_registry_approval_request_stable_ordering_is_deterministic(tmp_path: Path):
    first_intake = _run_intake(tmp_path / "first")
    second_intake = _run_intake(tmp_path / "second")
    first = compile_catalog_registry_approval_request(
        CatalogRegistryApprovalRequestOptions(
            input_path=Path(first_intake["outputRoot"]) / "draft-governance-packets.json",
            output_root=tmp_path / "first-request",
            created_at=CREATED_AT,
        )
    )
    second = compile_catalog_registry_approval_request(
        CatalogRegistryApprovalRequestOptions(
            input_path=Path(second_intake["outputRoot"]) / "draft-governance-packets.json",
            output_root=tmp_path / "second-request",
            created_at=CREATED_AT,
        )
    )

    first_requests = read_json(Path(first["outputRoot"]) / "approval-requests.json")["approvalRequests"]
    second_requests = read_json(Path(second["outputRoot"]) / "approval-requests.json")["approvalRequests"]
    assert [request["request_id"] for request in first_requests] == [request["request_id"] for request in second_requests]
    assert first_requests == sorted(first_requests, key=lambda item: (item["domain_guess"], item["intake_id"], item["request_id"]))


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


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
