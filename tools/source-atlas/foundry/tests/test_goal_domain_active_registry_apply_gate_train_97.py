from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.goal_domain_active_registry_apply_gate import (
    GoalDomainActiveRegistryApplyGateOptions,
    compile_goal_domain_active_registry_apply_gate,
    write_goal_domain_active_registry_apply_gate_report,
)
from foundry.governance_registry import API_GOVERNANCE_REGISTRY_PATH, LEGAL_TERMS_REGISTRY_PATH, SOURCE_LANE_REGISTRY_PATH
from foundry.model import read_json, stable_hash, write_json


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
TRAIN_96_PLAN = (
    SOURCE_ATLAS_ROOT
    / "generated"
    / "goal-domain-registry-apply-rehearsal"
    / "train-96-fixture"
    / "mutation-plan"
    / "planned-registry-mutations.json"
)
TRAIN_96_REVIEW_EVIDENCE = (
    SOURCE_ATLAS_ROOT
    / "generated"
    / "goal-domain-registry-apply-rehearsal"
    / "train-96-fixture"
    / "fixture-completion-evidence.json"
)
CREATED_AT = "2026-06-28T00:00:00Z"


def test_active_registry_apply_gate_blocks_train_96_fixture_rehearsal_from_active_registry_apply(tmp_path: Path):
    result = compile_goal_domain_active_registry_apply_gate(
        GoalDomainActiveRegistryApplyGateOptions(
            plan_path=TRAIN_96_PLAN,
            review_evidence_path=TRAIN_96_REVIEW_EVIDENCE,
            output_root=tmp_path / "gate",
            source_lane_registry_path=SOURCE_LANE_REGISTRY_PATH,
            legal_terms_registry_path=LEGAL_TERMS_REGISTRY_PATH,
            api_governance_registry_path=API_GOVERNANCE_REGISTRY_PATH,
            approval_artifact=_write_source_specific_approval(tmp_path),
            execute=True,
            allow_active_registry_write=True,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["evaluationIssues"]
    assert result["status"] == "Source Green for goal-domain active registry apply gate tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; active registry apply readiness gate only"
    assert result["evidenceClass"] == "fixture_only_rehearsal"
    assert result["activeRegistryApplyDecision"] == "blocked_fixture_or_rehearsal_evidence"
    assert result["activeRegistryApplyAllowed"] is False
    assert any("review_evidence_class_fixture_only_rehearsal" in reason for reason in result["blockingReasons"])
    assert _check(result, "fixture_or_rehearsal_evidence_blocks_active_apply")
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0


def test_active_registry_apply_gate_missing_approval_blocks_source_specific_review(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    plan_path = _write_goal_domain_plan(tmp_path, [_source_specific_mutation()])
    review_path = _write_source_specific_review_evidence(tmp_path)

    result = compile_goal_domain_active_registry_apply_gate(
        GoalDomainActiveRegistryApplyGateOptions(
            plan_path=plan_path,
            review_evidence_path=review_path,
            output_root=tmp_path / "gate",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            execute=True,
            allow_active_registry_write=True,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["evaluationIssues"]
    assert result["evidenceClass"] == "source_specific_review"
    assert result["activeRegistryApplyAllowed"] is False
    assert any("approval artifact is required" in reason for reason in result["blockingReasons"])
    assert read_json(paths["source"])["source_lanes"] == []


def test_active_registry_apply_gate_requires_explicit_active_registry_targets(tmp_path: Path):
    plan_path = _write_goal_domain_plan(tmp_path, [_source_specific_mutation()])
    review_path = _write_source_specific_review_evidence(tmp_path)
    approval_path = _write_source_specific_approval(tmp_path)

    result = compile_goal_domain_active_registry_apply_gate(
        GoalDomainActiveRegistryApplyGateOptions(
            plan_path=plan_path,
            review_evidence_path=review_path,
            output_root=tmp_path / "gate",
            approval_artifact=approval_path,
            execute=True,
            allow_active_registry_write=True,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["evaluationIssues"]
    assert result["targetClass"] == "implicit_default_registries"
    assert result["activeRegistryApplyAllowed"] is False
    assert any("explicit active repo registry target paths are required" in reason for reason in result["blockingReasons"])


def test_active_registry_apply_gate_rejects_private_approval_artifact(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    plan_path = _write_goal_domain_plan(tmp_path, [_source_specific_mutation()])
    review_path = _write_source_specific_review_evidence(tmp_path)
    approval_path = _write_source_specific_approval(tmp_path, extra={"goal_text": "I want this tied to my private schedule"})

    result = compile_goal_domain_active_registry_apply_gate(
        GoalDomainActiveRegistryApplyGateOptions(
            plan_path=plan_path,
            review_evidence_path=review_path,
            output_root=tmp_path / "gate",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            approval_artifact=approval_path,
            execute=True,
            allow_active_registry_write=True,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert result["activeRegistryApplyAllowed"] is False
    assert read_json(paths["source"])["source_lanes"] == []


def test_active_registry_apply_gate_allows_source_specific_active_readiness_without_writing_registries(tmp_path: Path):
    plan_path = _write_goal_domain_plan(tmp_path, [_source_specific_mutation()])
    review_path = _write_source_specific_review_evidence(tmp_path)
    approval_path = _write_source_specific_approval(tmp_path)
    before_hashes = {
        "source": stable_hash(read_json(SOURCE_LANE_REGISTRY_PATH)),
        "legal": stable_hash(read_json(LEGAL_TERMS_REGISTRY_PATH)),
        "api": stable_hash(read_json(API_GOVERNANCE_REGISTRY_PATH)),
    }

    result = compile_goal_domain_active_registry_apply_gate(
        GoalDomainActiveRegistryApplyGateOptions(
            plan_path=plan_path,
            review_evidence_path=review_path,
            output_root=tmp_path / "gate",
            source_lane_registry_path=SOURCE_LANE_REGISTRY_PATH,
            legal_terms_registry_path=LEGAL_TERMS_REGISTRY_PATH,
            api_governance_registry_path=API_GOVERNANCE_REGISTRY_PATH,
            approval_artifact=approval_path,
            execute=True,
            allow_active_registry_write=True,
            created_at=CREATED_AT,
        )
    )

    after_hashes = {
        "source": stable_hash(read_json(SOURCE_LANE_REGISTRY_PATH)),
        "legal": stable_hash(read_json(LEGAL_TERMS_REGISTRY_PATH)),
        "api": stable_hash(read_json(API_GOVERNANCE_REGISTRY_PATH)),
    }
    assert result["valid"], result["evaluationIssues"]
    assert result["evidenceClass"] == "source_specific_review"
    assert result["targetClass"] == "active_repo_registries"
    assert result["activeRegistryApplyDecision"] == "ready_for_active_registry_apply"
    assert result["activeRegistryApplyAllowed"] is True
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert before_hashes == after_hashes


def test_active_registry_apply_gate_report_writer_emits_markdown_and_json(tmp_path: Path):
    plan_path = _write_goal_domain_plan(tmp_path, [_source_specific_mutation("writer")])
    review_path = _write_source_specific_review_evidence(tmp_path, suffix="writer")
    approval_path = _write_source_specific_approval(tmp_path, suffix="writer")
    markdown_path = tmp_path / "source-atlas-goal-domain-active-registry-apply-gate-train-97.md"
    json_path = tmp_path / "source-atlas-goal-domain-active-registry-apply-gate-train-97.json"

    result = write_goal_domain_active_registry_apply_gate_report(
        markdown_path,
        json_path,
        plan_path=plan_path,
        output_root=tmp_path / "gate",
        review_evidence_path=review_path,
        source_lane_registry_path=SOURCE_LANE_REGISTRY_PATH,
        legal_terms_registry_path=LEGAL_TERMS_REGISTRY_PATH,
        api_governance_registry_path=API_GOVERNANCE_REGISTRY_PATH,
        approval_artifact=approval_path,
        execute=True,
        allow_active_registry_write=True,
        created_at=CREATED_AT,
    )

    assert result["valid"], result["evaluationIssues"]
    assert markdown_path.exists()
    assert json_path.exists()
    assert "Source Atlas Goal-Domain Active Registry Apply Gate Train 97" in markdown_path.read_text(encoding="utf-8")
    persisted = read_json(json_path)
    assert persisted["activeRegistryApplyDecision"] == "ready_for_active_registry_apply"
    assert persisted["recordCounts"]["activeRegistryMutations"] == 0


def _write_empty_registries(tmp_path: Path) -> dict[str, Path]:
    source = tmp_path / "source-lane-registry.json"
    legal = tmp_path / "legal-terms-registry.json"
    api = tmp_path / "api-governance-registry.json"
    write_json(
        source,
        {
            "kind": "ambitions.sourceAtlas.sourceLaneRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "source_lanes": [],
        },
    )
    write_json(
        legal,
        {
            "kind": "ambitions.sourceAtlas.legalTermsRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "licenses": [],
        },
    )
    write_json(
        api,
        {
            "kind": "ambitions.sourceAtlas.apiGovernanceRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "api_policies": [],
        },
    )
    return {"source": source, "legal": legal, "api": api}


def _write_goal_domain_plan(tmp_path: Path, mutations: list[dict[str, object]]) -> Path:
    path = tmp_path / "goal-domain-planned-registry-mutations.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.goalDomainPlannedRegistryMutations.v1",
            "reviewEvidenceClass": "source_specific_review",
            "createdAt": CREATED_AT,
            "plannedRegistryMutations": mutations,
            "nonClaims": ["planned registry activation review only", "not active registry mutation", "not R2 publish"],
        },
    )
    return path


def _write_source_specific_review_evidence(tmp_path: Path, suffix: str = "education") -> Path:
    source_id = f"approved.source_specific.{suffix}"
    path = tmp_path / f"source-specific-review-evidence-{suffix}.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.goalDomainSourceSpecificReviewEvidence.v1",
            "reviewEvidenceClass": "source_specific_review",
            "reviewScope": "source_lane_legal_api_registry_activation",
            "sourceIDs": [source_id],
            "reviewedAt": "2026-06-28",
            "reviewedBy": "Ambitions owner source review",
            "sourceAuthorityDecision": "direct official public reference source reviewed",
            "termsDecision": "public reference metadata redistribution posture reviewed",
            "apiDecision": "static public reference access governed",
            "nonClaims": ["not outside legal approval", "not claim output", "not R2 publish"],
        },
    )
    return path


def _write_source_specific_approval(tmp_path: Path, suffix: str = "education", extra: dict[str, object] | None = None) -> Path:
    path = tmp_path / f"active-registry-apply-approval-{suffix}.json"
    payload: dict[str, object] = {
        "kind": "ambitions.sourceAtlas.goalDomainActiveRegistryApplyApproval.v1",
        "approvalStatus": "approved_for_active_registry_apply",
        "approvedAt": CREATED_AT,
        "approvedBy": "Ambitions owner source registry approval",
        "approvalScope": "active source lane, legal terms, and API governance registry metadata",
        "nonClaims": ["not outside legal approval", "not claim output", "not R2 publish"],
    }
    if extra:
        payload.update(extra)
    write_json(path, payload)
    return path


def _source_specific_mutation(suffix: str = "education") -> dict[str, object]:
    source_id = f"approved.source_specific.{suffix}"
    license_id = f"approved_source_specific_{suffix}_terms"
    api_policy_id = f"api.approved_source_specific_{suffix}.v1"
    rate_policy_id = f"rate.approved_source_specific_{suffix}.v1"
    budget_policy_id = f"budget.approved_source_specific_{suffix}.v1"
    return {
        "mutationID": f"goal-domain-registry-mutation.{suffix}",
        "bundleID": f"goal-domain-review-bundle.{suffix}",
        "requestID": f"goal-domain-request.{suffix}",
        "reviewEvidenceClass": "source_specific_review",
        "requestedDomain": "education_credentialing",
        "matchedDomainID": "education_credentialing",
        "createdAt": CREATED_AT,
        "completionStatus": "completed_review_ready_for_registry_apply_planning",
        "status": "dry_run_ready_for_separate_registry_apply",
        "activeRegistryWritten": False,
        "sourceLaneEntry": {
            "source_id": source_id,
            "source_name": f"Approved Source Specific {suffix.title()} Reference",
            "source_class": "official_government",
            "authority_class": "official_government",
            "jurisdiction": "US",
            "domain_scope": ["education_credentialing"],
            "claim_classes_allowed": ["public_reference_claim"],
            "claim_classes_forbidden": ["legal_advice", "personalized_plan"],
            "license_id": license_id,
            "license_url": f"https://agency.gov/source-atlas/{suffix}/license",
            "terms_url": f"https://agency.gov/source-atlas/{suffix}/terms",
            "rights_url": f"https://agency.gov/source-atlas/{suffix}/rights",
            "attribution_required": True,
            "redistribution_policy": "redistributable_with_attribution",
            "r2_pack_policy": "pack_allowed_with_attribution",
            "lookup_policy": "lookup_allowed_public_reference_only",
            "crosswalk_policy": "not_crosswalk_source",
            "review_status": "reviewed",
            "review_owner": "Ambitions owner source review",
            "last_reviewed_at": "2026-06-28",
            "next_review_due_at": "2026-12-28",
            "freshness_sla": "quarterly_public_reference_recheck",
            "api_mode": "static_https_public_reference",
            "api_policy_id": api_policy_id,
            "rate_policy_id": rate_policy_id,
            "budget_policy_id": budget_policy_id,
            "secret_policy_id": "secret.no_secret_static_page.v1",
            "allowed_artifact_classes": [
                "official_public_source",
                "public_reference_claim",
                "public_requirement",
                "public_provenance",
            ],
            "forbidden_artifact_classes": [
                "final_user_path",
                "final_schedule",
                "step_list",
                "personalized_plan",
                "private_goal_graph",
            ],
            "non_claims": ["not legal advice", "not a personalized education plan", "not outside legal approval"],
            "schema_version": "1.0.0",
            "r2_object_key_prefix": f"source-atlas/v1/stable/goal-domain-source-specific/{suffix}",
        },
        "legalTermsEntry": {
            "license_id": license_id,
            "license_name": f"Approved Source Specific {suffix.title()} Terms",
            "license_url": f"https://agency.gov/source-atlas/{suffix}/license",
            "terms_url": f"https://agency.gov/source-atlas/{suffix}/terms",
            "rights_url": f"https://agency.gov/source-atlas/{suffix}/rights",
            "redistribution_allowed": True,
            "modification_allowed": False,
            "commercial_use_allowed": False,
            "attribution_required": True,
            "share_alike_required": False,
            "source_specific_restrictions": ["cite source URL"],
            "pack_output_allowed": True,
            "lookup_output_allowed": True,
            "review_required": False,
            "outside_legal_required": False,
            "outside_legal_status": "not_claimed",
            "approval_artifact_path": "",
            "effective_date": "2026-06-28",
            "reviewed_at": "2026-06-28",
            "review_owner": "Ambitions owner source review",
            "expires_at": "2026-12-28",
            "non_claims": ["not outside legal approval", "not legal advice"],
            "schema_version": "1.0.0",
        },
        "apiPolicyEntry": {
            "api_policy_id": api_policy_id,
            "source_id": source_id,
            "api_mode": "static_https_public_reference",
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
            "evidence_output_policy": "public_reference_metadata_only",
            "schema_version": "1.0.0",
        },
        "blockingReasons": ["planner_does_not_write_active_registries", "separate_registry_apply_required"],
        "claimOutputAllowed": False,
        "packOutputAllowed": False,
        "r2PublishAllowed": False,
        "nativeActivationAllowed": False,
        "publicReferenceOnly": True,
        "nonClaims": ["planned registry mutation only", "not active registry mutation", "not claim output", "not R2 publish"],
    }


def _check(result: dict[str, object], name: str) -> bool:
    return bool(next(check for check in result["checks"] if check["name"] == name)["passed"])
