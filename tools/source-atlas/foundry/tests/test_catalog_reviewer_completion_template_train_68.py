from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_reviewer_completion_intake import CatalogReviewerCompletionIntakeOptions, compile_catalog_reviewer_completion_intake
from foundry.catalog_reviewer_completion_template import CatalogReviewerCompletionTemplateOptions, compile_catalog_reviewer_completion_template
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_reviewer_completion_template_emits_blocked_templates(tmp_path: Path):
    inputs_path = _write_decision_inputs(tmp_path, [_decision_input_packet("education"), _decision_input_packet("health", domain="health_wellness_reference")])

    result = compile_catalog_reviewer_completion_template(
        CatalogReviewerCompletionTemplateOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "templates",
            reviewer="review queue",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog reviewer completion template tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; reviewer completion templates only"
    assert result["recordCounts"]["decisionInputPackets"] == 2
    assert result["recordCounts"]["sourceReviewCompletionPacketTemplates"] == 2
    assert result["recordCounts"]["completedReviewCompletions"] == 0
    assert result["recordCounts"]["completedDecisionArtifacts"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "templates_are_blocked_not_completed")

    collection = read_json(Path(result["outputRoot"]) / "source-review-completion-packets.json")
    assert collection["kind"] == "ambitions.sourceAtlas.catalogSourceReviewCompletionPackets.v1"
    assert all(packet["completion_status"] == "blocked_review_required" for packet in collection["sourceReviewCompletionPackets"])
    assert all(packet["source_lane_review"]["status"] == "review_required" for packet in collection["sourceReviewCompletionPackets"])


def test_catalog_reviewer_completion_template_feeds_intake_as_blocked_packets(tmp_path: Path):
    packet = _decision_input_packet("education")
    inputs_path = _write_decision_inputs(tmp_path, [packet])
    template = compile_catalog_reviewer_completion_template(
        CatalogReviewerCompletionTemplateOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "templates",
            created_at=CREATED_AT,
        )
    )

    intake = compile_catalog_reviewer_completion_intake(
        CatalogReviewerCompletionIntakeOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "intake",
            review_packets_path=Path(template["outputPaths"]["sourceReviewCompletionPackets"]),
            created_at=CREATED_AT,
        )
    )

    assert intake["valid"], intake["issues"]
    assert intake["recordCounts"]["reviewPackets"] == 1
    assert intake["recordCounts"]["completedReviewCompletions"] == 0
    assert intake["recordCounts"]["completedDecisionArtifacts"] == 0
    assert intake["recordCounts"]["blockedReviewCompletions"] == 1
    assert intake["reviewCompletionArtifactPath"] == ""


def test_catalog_reviewer_completion_template_rejects_private_decision_input(tmp_path: Path):
    packet = _decision_input_packet("education")
    packet["goal_text"] = "Use this for my private plan"
    inputs_path = _write_decision_inputs(tmp_path, [packet])

    result = compile_catalog_reviewer_completion_template(
        CatalogReviewerCompletionTemplateOptions(
            decision_inputs_path=inputs_path,
            output_root=tmp_path / "templates",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_reviewer_completion_template_stable_ordering(tmp_path: Path):
    inputs_path = _write_decision_inputs(
        tmp_path,
        [
            _decision_input_packet("z", domain="health_wellness_reference"),
            _decision_input_packet("a", domain="education_credentialing"),
        ],
    )

    first = compile_catalog_reviewer_completion_template(
        CatalogReviewerCompletionTemplateOptions(decision_inputs_path=inputs_path, output_root=tmp_path / "first", created_at=CREATED_AT)
    )
    second = compile_catalog_reviewer_completion_template(
        CatalogReviewerCompletionTemplateOptions(decision_inputs_path=inputs_path, output_root=tmp_path / "second", created_at=CREATED_AT)
    )

    first_templates = read_json(Path(first["outputRoot"]) / "source-review-completion-packets.json")["sourceReviewCompletionPackets"]
    second_templates = read_json(Path(second["outputRoot"]) / "source-review-completion-packets.json")["sourceReviewCompletionPackets"]
    assert first_templates == second_templates
    assert first_templates == sorted(first_templates, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))


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
        "required_reviewer_actions": [
            "complete source lane authority, jurisdiction, review, freshness, and artifact policy fields",
            "complete legal/terms redistribution, pack-output, restrictions, review, and expiry fields",
            "complete API governance key, budget, rate, retry, timeout, live/execute, and evidence policy fields",
        ],
        "non_claims": ["decision input packet only", "not approval"],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
