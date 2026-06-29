from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_review_work_queue import CatalogReviewWorkQueueOptions, compile_catalog_review_work_queue
from foundry.catalog_reviewer_completion_template import CatalogReviewerCompletionTemplateOptions, compile_catalog_reviewer_completion_template
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_review_work_queue_emits_explicit_blocked_lanes(tmp_path: Path):
    inputs_path = _write_decision_inputs(tmp_path, [_decision_input_packet("education"), _decision_input_packet("health", domain="health_wellness_reference")])

    result = compile_catalog_review_work_queue(
        CatalogReviewWorkQueueOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "queue",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog review work queue tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; review work queue tooling only"
    assert result["recordCounts"]["decisionInputPackets"] == 2
    assert result["recordCounts"]["reviewPackets"] == 0
    assert result["recordCounts"]["reviewWorkItems"] == 2
    assert result["recordCounts"]["directSourceResolutionTasks"] == 2
    assert result["recordCounts"]["sourceLaneReviewTasks"] == 2
    assert result["recordCounts"]["legalTermsReviewTasks"] == 2
    assert result["recordCounts"]["apiGovernanceReviewTasks"] == 2
    assert result["recordCounts"]["packabilityDecisionTasks"] == 2
    assert result["recordCounts"]["readyForReviewerCompletionIntake"] == 0
    assert result["recordCounts"]["blockedFromCompletion"] == 2
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "catalog_source_candidates_remain_blocked")

    work_items = read_json(Path(result["outputRoot"]) / "review-work-items.json")["reviewWorkItems"]
    assert all("direct_source_authority_resolution" in item["work_lanes"] for item in work_items)
    assert all("source_review_completion_packet_not_provided" in item["blocking_reasons"] for item in work_items)


def test_catalog_review_work_queue_consumes_blocked_templates_without_approval(tmp_path: Path):
    packet = _decision_input_packet("education")
    inputs_path = _write_decision_inputs(tmp_path, [packet])
    template = compile_catalog_reviewer_completion_template(
        CatalogReviewerCompletionTemplateOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "templates",
            created_at=CREATED_AT,
        )
    )

    result = compile_catalog_review_work_queue(
        CatalogReviewWorkQueueOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "queue",
            review_packets_path=Path(template["outputPaths"]["sourceReviewCompletionPackets"]),
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["reviewPackets"] == 1
    assert result["recordCounts"]["reviewWorkItems"] == 1
    assert result["recordCounts"]["readyForReviewerCompletionIntake"] == 0
    assert result["recordCounts"]["blockedFromCompletion"] == 1
    assert result["recordCounts"]["completedReviewerCompletions"] == 0
    assert result["recordCounts"]["completedDecisionArtifacts"] == 0
    assert _check(result, "no_completed_review_or_approval_artifacts")

    work_item = read_json(Path(result["outputRoot"]) / "review-work-items.json")["reviewWorkItems"][0]
    assert work_item["review_packet_status"] == "blocked_review_required"
    assert "source_review_completion_packet_blocked_review_required" in work_item["blocking_reasons"]


def test_catalog_review_work_queue_rejects_private_input(tmp_path: Path):
    packet = _decision_input_packet("education")
    packet["goal_text"] = "Use this for my private plan"
    inputs_path = _write_decision_inputs(tmp_path, [packet])

    result = compile_catalog_review_work_queue(
        CatalogReviewWorkQueueOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "queue",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_review_work_queue_stable_ordering(tmp_path: Path):
    inputs_path = _write_decision_inputs(
        tmp_path,
        [
            _decision_input_packet("z", domain="health_wellness_reference"),
            _decision_input_packet("a", domain="education_credentialing"),
        ],
    )

    first = compile_catalog_review_work_queue(
        CatalogReviewWorkQueueOptions(decision_inputs_path=inputs_path, output_root=tmp_path / "first", created_at=CREATED_AT)
    )
    second = compile_catalog_review_work_queue(
        CatalogReviewWorkQueueOptions(decision_inputs_path=inputs_path, output_root=tmp_path / "second", created_at=CREATED_AT)
    )

    first_items = read_json(Path(first["outputRoot"]) / "review-work-items.json")["reviewWorkItems"]
    second_items = read_json(Path(second["outputRoot"]) / "review-work-items.json")["reviewWorkItems"]
    assert first_items == second_items
    assert first_items == sorted(first_items, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))


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
        "source_authority_status": "reviewer_input_only",
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
        "completion_checklist": [
            {
                "section": "source_lane",
                "status": "blocked",
                "required_action": "complete source lane authority, jurisdiction, review, freshness, and artifact policy fields",
                "missing_fields": ["authority_class", "jurisdiction"],
            }
        ],
        "required_reviewer_actions": [
            "complete source lane authority, jurisdiction, review, freshness, and artifact policy fields",
            "complete legal/terms redistribution, pack-output, restrictions, review, and expiry fields",
            "complete API governance key, budget, rate, retry, timeout, live/execute, and evidence policy fields",
        ],
        "non_claims": ["decision input packet only", "not approval"],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
