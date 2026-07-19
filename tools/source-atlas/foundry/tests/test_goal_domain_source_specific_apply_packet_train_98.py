from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.goal_domain_source_specific_apply_packet import (  # noqa: E402
    GOAL_DOMAIN_SOURCE_SPECIFIC_APPLY_PACKET_INPUT_KIND,
    GoalDomainSourceSpecificApplyPacketOptions,
    compile_goal_domain_source_specific_apply_packet,
    write_goal_domain_source_specific_apply_packet_report,
)
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-28T00:00:00Z"


def test_source_specific_apply_packet_emits_readiness_artifacts_without_active_writes(tmp_path: Path):
    input_path = _write_source_specific_input(tmp_path, "packet")

    result = compile_goal_domain_source_specific_apply_packet(
        GoalDomainSourceSpecificApplyPacketOptions(
            input_path=input_path,
            output_root=tmp_path / "packet-output",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for goal-domain source-specific apply packet tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; source-specific apply packet tooling only"
    assert result["recordCounts"]["plannedRegistryMutations"] == 1
    assert result["recordCounts"]["activeRegistryReadinessAllowed"] == 1
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["activeApplyGate"]["activeRegistryApplyAllowed"] is True
    assert Path(result["outputPaths"]["plannedRegistryMutations"]).exists()
    assert Path(result["outputPaths"]["sourceSpecificReviewEvidence"]).exists()
    assert Path(result["outputPaths"]["approvalArtifact"]).exists()


def test_source_specific_apply_packet_blocks_fixture_or_rehearsal_markers(tmp_path: Path):
    input_path = _write_source_specific_input(tmp_path, "marker")
    payload = read_json(input_path)
    payload["plannedRegistryMutations"][0]["sourceLaneEntry"]["terms_url"] = "https://example.gov/terms"
    write_json(input_path, payload)

    result = compile_goal_domain_source_specific_apply_packet(
        GoalDomainSourceSpecificApplyPacketOptions(
            input_path=input_path,
            output_root=tmp_path / "packet-output",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("fixture/rehearsal marker" in issue for issue in result["issues"])
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0


def test_source_specific_apply_packet_rejects_private_input(tmp_path: Path):
    input_path = _write_source_specific_input(tmp_path, "private")
    payload = read_json(input_path)
    payload["goal_text"] = "Use this for my private schedule"
    write_json(input_path, payload)

    result = compile_goal_domain_source_specific_apply_packet(
        GoalDomainSourceSpecificApplyPacketOptions(
            input_path=input_path,
            output_root=tmp_path / "packet-output",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0


def test_source_specific_apply_packet_report_writer_emits_markdown_and_json(tmp_path: Path):
    input_path = _write_source_specific_input(tmp_path, "writer")
    markdown_path = tmp_path / "source-atlas-goal-domain-source-specific-apply-packet-train-98.md"
    json_path = tmp_path / "source-atlas-goal-domain-source-specific-apply-packet-train-98.json"

    result = write_goal_domain_source_specific_apply_packet_report(
        markdown_path,
        json_path,
        input_path=input_path,
        output_root=tmp_path / "packet-output",
        created_at=CREATED_AT,
    )

    assert result["valid"], result["issues"]
    assert markdown_path.exists()
    assert json_path.exists()
    assert "Source Atlas Goal-Domain Source-Specific Apply Packet Train 98" in markdown_path.read_text(encoding="utf-8")
    persisted = read_json(json_path)
    assert persisted["recordCounts"]["activeRegistryMutations"] == 0
    assert persisted["activeApplyGate"]["activeRegistryApplyAllowed"] is True


def _write_source_specific_input(tmp_path: Path, suffix: str) -> Path:
    path = tmp_path / f"source-specific-apply-packet-input-{suffix}.json"
    write_json(
        path,
        {
            "kind": GOAL_DOMAIN_SOURCE_SPECIFIC_APPLY_PACKET_INPUT_KIND,
            "reviewEvidenceClass": "source_specific_review",
            "sourceSpecificReviewID": f"source-specific-review.{suffix}",
            "reviewOwner": "Ambitions owner source review",
            "reviewedAt": "2026-06-28",
            "approvedAt": CREATED_AT,
            "approvedBy": "Ambitions owner source registry approval",
            "plannedRegistryMutations": [_source_specific_mutation(suffix)],
            "nonClaims": ["not outside legal approval", "not claim output", "not R2 publish"],
        },
    )
    return path


def _source_specific_mutation(suffix: str) -> dict[str, object]:
    source_id = f"approved.source_specific.train98_{suffix}"
    license_id = f"approved_source_specific_train98_{suffix}_terms"
    api_policy_id = f"api.approved_source_specific_train98_{suffix}.v1"
    rate_policy_id = f"rate.approved_source_specific_train98_{suffix}.v1"
    budget_policy_id = f"budget.approved_source_specific_train98_{suffix}.v1"
    return {
        "mutationID": f"source-specific-registry-mutation.{suffix}",
        "bundleID": f"source-specific-review-bundle.{suffix}",
        "requestID": f"public-reference-request.{suffix}",
        "reviewEvidenceClass": "source_specific_review",
        "requestedDomain": "education_credentialing",
        "matchedDomainID": "education_credentialing",
        "createdAt": CREATED_AT,
        "completionStatus": "completed_review_ready_for_registry_apply_planning",
        "status": "dry_run_ready_for_separate_registry_apply",
        "activeRegistryWritten": False,
        "sourceLaneEntry": {
            "source_id": source_id,
            "source_name": f"Approved Source Specific Train 98 {suffix.title()} Reference",
            "source_class": "official_government",
            "authority_class": "official_government",
            "jurisdiction": "US",
            "domain_scope": ["education_credentialing"],
            "claim_classes_allowed": ["public_reference_claim"],
            "claim_classes_forbidden": ["legal_advice", "personalized_plan"],
            "license_id": license_id,
            "license_url": f"https://agency.gov/source-atlas/train98/{suffix}/license",
            "terms_url": f"https://agency.gov/source-atlas/train98/{suffix}/terms",
            "rights_url": f"https://agency.gov/source-atlas/train98/{suffix}/rights",
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
            "r2_object_key_prefix": f"source-atlas/v1/stable/source-specific-train98/{suffix}",
        },
        "legalTermsEntry": {
            "license_id": license_id,
            "license_name": f"Approved Source Specific Train 98 {suffix.title()} Terms",
            "license_url": f"https://agency.gov/source-atlas/train98/{suffix}/license",
            "terms_url": f"https://agency.gov/source-atlas/train98/{suffix}/terms",
            "rights_url": f"https://agency.gov/source-atlas/train98/{suffix}/rights",
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
