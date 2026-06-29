from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.goal_domain_review_completion_intake import (
    GoalDomainReviewCompletionIntakeOptions,
    compile_goal_domain_review_completion_intake,
    write_goal_domain_review_completion_intake_report,
)
from foundry.model import read_json, write_json


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
REVIEW_TEMPLATES = SOURCE_ATLAS_ROOT / "generated" / "goal-domain-review-packets" / "train-92-fixture" / "review-packet-templates.json"
CREATED_AT = "2026-06-28T00:00:00Z"


def test_goal_domain_review_completion_intake_blocks_without_completion_evidence(tmp_path: Path):
    result = compile_goal_domain_review_completion_intake(
        GoalDomainReviewCompletionIntakeOptions(
            review_templates_path=REVIEW_TEMPLATES,
            output_root=tmp_path / "completion-intake",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for goal-domain review completion intake tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; review completion intake tooling only"
    assert result["recordCounts"]["reviewPacketTemplates"] == 8
    assert result["recordCounts"]["completionEvidenceRecords"] == 0
    assert result["recordCounts"]["completedReviewPackets"] == 0
    assert result["recordCounts"]["completedReviewBundles"] == 0
    assert result["recordCounts"]["blockedReviewCompletions"] == 8
    assert result["recordCounts"]["approvalArtifactsEmitted"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert _check(result, "missing_completion_evidence_blocks_without_approval")

    blocked = read_json(Path(result["outputPaths"]["blockedGoalDomainReviewCompletions"]))
    assert len(blocked["blockedReviewCompletions"]) == 8
    assert all(item["status"] == "blocked" for item in blocked["blockedReviewCompletions"])


def test_goal_domain_review_completion_intake_accepts_completed_fixture_evidence_without_outputs(tmp_path: Path):
    templates = read_json(REVIEW_TEMPLATES)["reviewPackets"]
    evidence_path = _write_completion_evidence(tmp_path, [_completion_record_for(template) for template in templates])

    result = compile_goal_domain_review_completion_intake(
        GoalDomainReviewCompletionIntakeOptions(
            review_templates_path=REVIEW_TEMPLATES,
            output_root=tmp_path / "completion-intake",
            completion_evidence_path=evidence_path,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["reviewPacketTemplates"] == 8
    assert result["recordCounts"]["completionEvidenceRecords"] == 8
    assert result["recordCounts"]["completedReviewPackets"] == 8
    assert result["recordCounts"]["completedReviewBundles"] == 2
    assert result["recordCounts"]["blockedReviewCompletions"] == 0
    assert result["recordCounts"]["approvalArtifactsEmitted"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0

    collection = read_json(Path(result["outputPaths"]["goalDomainReviewCompletions"]))
    assert collection["kind"] == "ambitions.sourceAtlas.goalDomainReviewCompletions.v1"
    assert len(collection["completedReviewPackets"]) == 8
    assert len(collection["reviewBundles"]) == 2
    assert all(bundle["registryMutationPlanningReady"] is True for bundle in collection["reviewBundles"])
    assert all(bundle["registryMutationAllowed"] is False for bundle in collection["reviewBundles"])
    assert all(packet["registryMutationAllowed"] is False for packet in collection["completedReviewPackets"])
    assert all(packet["claimOutputAllowed"] is False for packet in collection["completedReviewPackets"])
    assert all(packet["packOutputAllowed"] is False for packet in collection["completedReviewPackets"])
    assert all(packet["r2PublishAllowed"] is False for packet in collection["completedReviewPackets"])
    assert all(packet["nativeActivationAllowed"] is False for packet in collection["completedReviewPackets"])
    assert result["recordCounts"]["finalOutputArtifacts"] == 0
    assert "finalOutputArtifacts" not in json.dumps(collection)

    assert _check(result, "completed_review_packets_require_required_fields")
    assert _check(result, "completed_review_bundles_do_not_mutate_registries")
    assert _check(result, "review_completion_intake_emits_no_claims_packs_r2_or_native_activation")
    assert _check(result, "privacy_scan_passed")


def test_goal_domain_review_completion_intake_rejects_outside_legal_without_artifact(tmp_path: Path):
    templates = read_json(REVIEW_TEMPLATES)["reviewPackets"]
    evidence = [_completion_record_for(template) for template in templates]
    legal_record = next(item for item in evidence if item["reviewLane"] == "legal_terms_review")
    legal_record["reviewFields"]["outside_legal_required"] = True
    legal_record["reviewFields"]["outside_legal_status"] = "approved"
    legal_record["reviewFields"]["approval_artifact_path"] = ""
    evidence_path = _write_completion_evidence(tmp_path, evidence)

    result = compile_goal_domain_review_completion_intake(
        GoalDomainReviewCompletionIntakeOptions(
            review_templates_path=REVIEW_TEMPLATES,
            output_root=tmp_path / "completion-intake",
            completion_evidence_path=evidence_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("outside legal approval requires approval_artifact_path" in issue for issue in result["issues"])
    assert result["recordCounts"]["completedReviewPackets"] == 7
    assert result["recordCounts"]["blockedReviewCompletions"] == 1


def test_goal_domain_review_completion_intake_rejects_private_completion_evidence(tmp_path: Path):
    templates = read_json(REVIEW_TEMPLATES)["reviewPackets"]
    evidence = [_completion_record_for(templates[0])]
    evidence[0]["goal_text"] = "Use this for my private schedule"
    evidence_path = _write_completion_evidence(tmp_path, evidence)

    result = compile_goal_domain_review_completion_intake(
        GoalDomainReviewCompletionIntakeOptions(
            review_templates_path=REVIEW_TEMPLATES,
            output_root=tmp_path / "completion-intake",
            completion_evidence_path=evidence_path,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "completion_evidence_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_goal_domain_review_completion_intake_report_writer_emits_markdown_and_json(tmp_path: Path):
    markdown_path = tmp_path / "source-atlas-goal-domain-review-completion-intake-train-93.md"
    json_path = tmp_path / "source-atlas-goal-domain-review-completion-intake-train-93.json"

    result = write_goal_domain_review_completion_intake_report(
        markdown_path,
        json_path,
        review_templates_path=REVIEW_TEMPLATES,
        output_root=tmp_path / "completion-intake",
        created_at=CREATED_AT,
    )

    assert result["valid"], result["issues"]
    assert markdown_path.exists()
    assert json_path.exists()
    assert "Source Atlas Goal-Domain Review Completion Intake Train 93" in markdown_path.read_text(encoding="utf-8")
    persisted = read_json(json_path)
    assert persisted["recordCounts"]["reviewPacketTemplates"] == 8
    assert persisted["recordCounts"]["activeRegistryMutations"] == 0


def _write_completion_evidence(tmp_path: Path, records: list[dict[str, object]]) -> Path:
    path = tmp_path / "goal-domain-review-completion-evidence.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.goalDomainReviewCompletionEvidence.v1",
            "createdAt": CREATED_AT,
            "completionEvidenceRecords": records,
            "nonClaims": ["fixture evidence only", "not legal approval", "not registry mutation"],
        },
    )
    return path


def _completion_record_for(template: dict[str, object]) -> dict[str, object]:
    review_lane = str(template["reviewLane"])
    return {
        "completionEvidenceID": f"completion-evidence.{template['packetID']}",
        "packetID": template["packetID"],
        "orderID": template["orderID"],
        "requestID": template["requestID"],
        "reviewLane": review_lane,
        "completionStatus": "completed",
        "reviewOwner": "Ambitions owner technical review fixture",
        "reviewedAt": "2026-06-28",
        "reviewDecision": "completed_fixture_review",
        "reviewFields": _review_fields_for(review_lane),
        "nonClaims": ["fixture completion evidence only", "not source authority", "not legal approval"],
    }


def _review_fields_for(review_lane: str) -> dict[str, object]:
    if review_lane == "direct_source_authority_resolution":
        return {
            "publisher_identity": "Example Public Reference Publisher",
            "source_directness": "direct_official_publisher",
            "publisher_authority_class": "official_government",
            "jurisdiction": "US",
            "official_locator": "https://example.gov/public-reference",
            "authority_limitations": ["fixture review only"],
            "review_decision": "direct_source_resolved",
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-93-fixture-review.md",
        }
    if review_lane == "source_lane_governance":
        return {
            "source_id": "approved.public.reference.fixture",
            "source_class": "official_government",
            "authority_class": "official_government",
            "jurisdiction": "US",
            "claim_classes_allowed": ["public_reference_claim"],
            "claim_classes_forbidden": ["legal_advice", "personalized_plan"],
            "redistribution_policy": "redistributable_with_attribution",
            "r2_pack_policy": "pack_allowed_with_attribution",
            "allowed_artifact_classes": ["public_reference_claim", "public_provenance"],
            "forbidden_artifact_classes": ["private_goal_graph", "final_user_path", "final_schedule", "step_list", "personalized_plan"],
            "review_status": "reviewed_fixture_only",
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-93-fixture-review.md",
        }
    if review_lane == "legal_terms_review":
        return {
            "license_id": "approved.public.reference.fixture.terms",
            "license_url": "https://example.gov/license",
            "terms_url": "https://example.gov/terms",
            "rights_url": "https://example.gov/rights",
            "redistribution_allowed": True,
            "attribution_required": True,
            "pack_output_allowed": True,
            "outside_legal_required": False,
            "outside_legal_status": "not_claimed",
            "approval_artifact_path": "",
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-93-fixture-review.md",
        }
    if review_lane == "api_governance_review":
        return {
            "api_policy_id": "api.approved_public_reference_fixture.v1",
            "api_mode": "static_https_fixture_first",
            "key_required": False,
            "env_var_name": "",
            "missing_key_behavior": "no_key_required",
            "rate_limit_per_second": 1,
            "daily_budget_limit": 10,
            "max_records_per_run": 5,
            "live_flag_required": True,
            "execute_flag_required": True,
            "secret_redaction_required": True,
            "budget_owner": "source-atlas-foundry",
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-93-fixture-review.md",
        }
    raise AssertionError(f"unexpected review lane: {review_lane}")


def _check(result: dict[str, object], name: str) -> bool:
    return bool(next(check for check in result["checks"] if check["name"] == name)["passed"])
