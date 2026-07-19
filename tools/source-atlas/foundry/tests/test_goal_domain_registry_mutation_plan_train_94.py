from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.goal_domain_registry_mutation_plan import (
    GoalDomainRegistryMutationPlanOptions,
    compile_goal_domain_registry_mutation_plan,
    write_goal_domain_registry_mutation_plan_report,
)
from foundry.goal_domain_review_completion_intake import GoalDomainReviewCompletionIntakeOptions, compile_goal_domain_review_completion_intake
from foundry.model import read_json, write_json


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
REVIEW_TEMPLATES = SOURCE_ATLAS_ROOT / "generated" / "goal-domain-review-packets" / "train-92-fixture" / "review-packet-templates.json"
BLOCKED_COMPLETIONS = SOURCE_ATLAS_ROOT / "generated" / "goal-domain-review-completion-intake" / "train-93-fixture" / "goal-domain-review-completions.json"
CREATED_AT = "2026-06-28T00:00:00Z"


def test_goal_domain_registry_mutation_plan_blocks_incomplete_review_bundles(tmp_path: Path):
    result = compile_goal_domain_registry_mutation_plan(
        GoalDomainRegistryMutationPlanOptions(
            review_completions_path=BLOCKED_COMPLETIONS,
            output_root=tmp_path / "registry-plan",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for goal-domain registry mutation planning"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; registry mutation planning only"
    assert result["recordCounts"]["reviewBundles"] == 2
    assert result["recordCounts"]["completedReviewPackets"] == 0
    assert result["recordCounts"]["plannedRegistryMutations"] == 0
    assert result["recordCounts"]["blockedRegistryMutations"] == 2
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert _check(result, "incomplete_bundles_block_without_mutation")
    assert _check(result, "no_active_registry_mutations_written")
    assert _check(result, "registry_mutation_plan_emits_no_claims_packs_r2_or_native_activation")

    blocked = read_json(Path(result["outputPaths"]["blockedRegistryMutations"]))["blockedRegistryMutations"]
    assert len(blocked) == 2
    assert all(item["status"] == "blocked" for item in blocked)
    assert read_json(Path(result["outputPaths"]["activeRegistryMutations"]))["activeRegistryMutations"] == []


def test_goal_domain_registry_mutation_plan_creates_dry_run_mutations_for_completed_bundles(tmp_path: Path):
    completions_path = _completed_review_completions_path(tmp_path)

    result = compile_goal_domain_registry_mutation_plan(
        GoalDomainRegistryMutationPlanOptions(
            review_completions_path=completions_path,
            output_root=tmp_path / "registry-plan",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["reviewBundles"] == 2
    assert result["recordCounts"]["completedReviewPackets"] == 8
    assert result["recordCounts"]["plannedRegistryMutations"] == 2
    assert result["recordCounts"]["blockedRegistryMutations"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["plannedSourceLaneEntries"] == 2
    assert result["recordCounts"]["plannedLegalTermsEntries"] == 2
    assert result["recordCounts"]["plannedApiPolicyEntries"] == 2
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0

    planned = read_json(Path(result["outputPaths"]["plannedRegistryMutations"]))["plannedRegistryMutations"]
    assert len(planned) == 2
    assert all(item["activeRegistryWritten"] is False for item in planned)
    assert all(item["status"] == "dry_run_ready_for_separate_registry_apply" for item in planned)
    assert all(item["sourceLaneEntry"]["source_id"] == "approved.public.reference.fixture" for item in planned)
    assert all(item["sourceLaneEntry"]["source_name"] == "Example Public Reference Publisher" for item in planned)
    assert all(item["legalTermsEntry"]["pack_output_allowed"] is True for item in planned)
    assert all(item["apiPolicyEntry"]["live_flag_required"] is True for item in planned)
    assert all(item["apiPolicyEntry"]["execute_flag_required"] is True for item in planned)
    assert read_json(Path(result["outputPaths"]["activeRegistryMutations"]))["activeRegistryMutations"] == []
    assert _check(result, "planned_mutations_are_dry_run_only")


def test_goal_domain_registry_mutation_plan_execute_requires_separate_apply_gate(tmp_path: Path):
    completions_path = _completed_review_completions_path(tmp_path)

    result = compile_goal_domain_registry_mutation_plan(
        GoalDomainRegistryMutationPlanOptions(
            review_completions_path=completions_path,
            output_root=tmp_path / "registry-plan",
            execute=True,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "execute_requires_separate_active_apply_gate")
    assert any("--execute requires --allow-active-registry-write" in issue for issue in result["issues"])
    assert result["recordCounts"]["activeRegistryMutations"] == 0


def test_goal_domain_registry_mutation_plan_rejects_malformed_completed_bundle(tmp_path: Path):
    completions_path = _completed_review_completions_path(tmp_path)
    payload = read_json(completions_path)
    source_packet = next(packet for packet in payload["completedReviewPackets"] if packet["reviewLane"] == "source_lane_governance")
    source_packet["reviewFields"]["source_id"] = ""
    malformed_path = tmp_path / "malformed-completions.json"
    write_json(malformed_path, payload)

    result = compile_goal_domain_registry_mutation_plan(
        GoalDomainRegistryMutationPlanOptions(
            review_completions_path=malformed_path,
            output_root=tmp_path / "registry-plan",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert result["recordCounts"]["plannedRegistryMutations"] == 1
    assert result["recordCounts"]["blockedRegistryMutations"] == 1
    assert any("source_lane_governance.source_id required" in issue for issue in result["issues"])


def test_goal_domain_registry_mutation_plan_rejects_private_completion_payload(tmp_path: Path):
    completions_path = _completed_review_completions_path(tmp_path)
    payload = read_json(completions_path)
    payload["goal_text"] = "Use this for my private schedule"
    private_path = tmp_path / "private-completions.json"
    write_json(private_path, payload)

    result = compile_goal_domain_registry_mutation_plan(
        GoalDomainRegistryMutationPlanOptions(
            review_completions_path=private_path,
            output_root=tmp_path / "registry-plan",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_goal_domain_registry_mutation_plan_report_writer_emits_markdown_and_json(tmp_path: Path):
    markdown_path = tmp_path / "source-atlas-goal-domain-registry-mutation-plan-train-94.md"
    json_path = tmp_path / "source-atlas-goal-domain-registry-mutation-plan-train-94.json"

    result = write_goal_domain_registry_mutation_plan_report(
        markdown_path,
        json_path,
        review_completions_path=BLOCKED_COMPLETIONS,
        output_root=tmp_path / "registry-plan",
        created_at=CREATED_AT,
    )

    assert result["valid"], result["issues"]
    assert markdown_path.exists()
    assert json_path.exists()
    assert "Source Atlas Goal-Domain Registry Mutation Plan Train 94" in markdown_path.read_text(encoding="utf-8")
    persisted = read_json(json_path)
    assert persisted["recordCounts"]["blockedRegistryMutations"] == 2
    assert persisted["recordCounts"]["activeRegistryMutations"] == 0


def _completed_review_completions_path(tmp_path: Path) -> Path:
    templates = read_json(REVIEW_TEMPLATES)["reviewPackets"]
    evidence_path = _write_completion_evidence(tmp_path, [_completion_record_for(template) for template in templates])
    intake = compile_goal_domain_review_completion_intake(
        GoalDomainReviewCompletionIntakeOptions(
            review_templates_path=REVIEW_TEMPLATES,
            output_root=tmp_path / "completion-intake",
            completion_evidence_path=evidence_path,
            created_at=CREATED_AT,
        )
    )
    assert intake["valid"], intake["issues"]
    return Path(intake["outputPaths"]["goalDomainReviewCompletions"])


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
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-94-fixture-review.md",
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
            "r2_object_key_prefix": "source-atlas/v1/stable/goal-domain-fixture",
            "allowed_artifact_classes": ["public_reference_claim", "public_provenance"],
            "forbidden_artifact_classes": ["private_goal_graph", "final_user_path", "final_schedule", "step_list", "personalized_plan"],
            "review_status": "reviewed",
            "next_review_due_at": "2026-12-28",
            "rate_policy_id": "rate.approved_public_reference_fixture.v1",
            "budget_policy_id": "budget.approved_public_reference_fixture.v1",
            "secret_policy_id": "secret.no_secret_static_page.v1",
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-94-fixture-review.md",
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
            "expires_at": "2026-12-28",
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-94-fixture-review.md",
        }
    if review_lane == "api_governance_review":
        return {
            "api_policy_id": "api.approved_public_reference_fixture.v1",
            "api_mode": "static_https_fixture_first",
            "key_required": False,
            "env_var_name": "",
            "missing_key_behavior": "no_key_required",
            "rate_limit_per_second": 1,
            "rate_limit_per_minute": 30,
            "daily_budget_limit": 10,
            "monthly_budget_limit": 300,
            "max_records_per_run": 5,
            "max_pages_per_run": 5,
            "timeout_seconds": 120,
            "retry_policy": "retry_429_500_502_503_504_only",
            "backoff_policy": "exponential_jitter",
            "circuit_breaker_policy": "stop_after_retry_budget",
            "live_flag_required": True,
            "execute_flag_required": True,
            "secret_redaction_required": True,
            "high_volume_review_required": False,
            "budget_owner": "source-atlas-foundry",
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-94-fixture-review.md",
        }
    raise AssertionError(f"unexpected review lane: {review_lane}")


def _check(result: dict[str, object], name: str) -> bool:
    return bool(next(check for check in result["checks"] if check["name"] == name)["passed"])
