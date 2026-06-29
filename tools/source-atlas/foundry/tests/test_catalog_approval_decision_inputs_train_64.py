from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_approval_decision_inputs import CatalogApprovalDecisionInputsOptions, compile_catalog_approval_decision_inputs
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"


def test_catalog_approval_decision_inputs_compile_blocked_preflight_records_without_approvals(tmp_path: Path):
    input_path = _write_preflight_records(tmp_path, [_blocked_preflight_record("education"), _blocked_preflight_record("health", domain="health_wellness_reference")])

    result = compile_catalog_approval_decision_inputs(
        CatalogApprovalDecisionInputsOptions(
            preflight_records_path=input_path,
            output_root=tmp_path / "decision-inputs",
            created_at=CREATED_AT,
            decision_owner="Ambitions source review",
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog approval decision input tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; decision input tooling only"
    assert result["recordCounts"]["preflightRecords"] == 2
    assert result["recordCounts"]["decisionInputPackets"] == 2
    assert result["recordCounts"]["decisionInputReadyForCompletion"] == 0
    assert result["recordCounts"]["blockedDecisionInputs"] == 2
    assert result["recordCounts"]["completedApprovalArtifacts"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "decision_input_packets_are_not_approvals")
    assert _check(result, "decision_inputs_emit_no_claims")

    packets = read_json(Path(result["outputRoot"]) / "decision-input-packets.json")["decisionInputPackets"]
    assert all(packet["packet_status"] == "blocked_review_required" for packet in packets)
    assert all(packet["legal_approval_status"] == "not_approved" for packet in packets)
    assert all(packet["source_authority_status"] == "reviewer_input_only" for packet in packets)
    assert all(packet["registry_mutation_status"] == "not_active" for packet in packets)
    assert all(packet["draft_decision_artifact"]["decision_status"] == "draft_not_approved" for packet in packets)
    assert all("approved_entries" not in packet["draft_decision_artifact"] for packet in packets)
    assert "authority_class" in packets[0]["source_lane_decision"]["missing_fields"]
    assert "review_owner" in packets[0]["legal_terms_decision"]["missing_fields"]
    assert "retry_policy" in packets[0]["api_governance_decision"]["missing_fields"]
    assert read_json(Path(result["outputRoot"]) / "completed-approval-artifacts.json")["completedApprovalArtifacts"] == []


def test_catalog_approval_decision_inputs_marks_complete_preflight_ready_but_still_draft(tmp_path: Path):
    input_path = _write_preflight_records(tmp_path, [_ready_preflight_record("education")])

    result = compile_catalog_approval_decision_inputs(
        CatalogApprovalDecisionInputsOptions(
            preflight_records_path=input_path,
            output_root=tmp_path / "decision-inputs",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["decisionInputReadyForCompletion"] == 1
    assert result["recordCounts"]["blockedDecisionInputs"] == 0
    assert result["recordCounts"]["completedApprovalArtifacts"] == 0
    packets = read_json(Path(result["outputRoot"]) / "decision-input-packets.json")["decisionInputPackets"]
    assert packets[0]["packet_status"] == "decision_input_ready_for_reviewer_completion"
    assert packets[0]["draft_decision_artifact"]["decision_status"] == "draft_not_approved"
    assert "approved_entries" not in packets[0]["draft_decision_artifact"]


def test_catalog_approval_decision_inputs_rejects_private_preflight_input(tmp_path: Path):
    input_path = _write_preflight_records(tmp_path, [_blocked_preflight_record("education")])
    payload = read_json(input_path)
    payload["decisionPreflightRecords"][0]["goal_text"] = "I need this for my private plan"
    write_json(input_path, payload)

    result = compile_catalog_approval_decision_inputs(
        CatalogApprovalDecisionInputsOptions(
            preflight_records_path=input_path,
            output_root=tmp_path / "decision-inputs",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_approval_decision_inputs_rejects_missing_preflight_records(tmp_path: Path):
    input_path = tmp_path / "empty.json"
    write_json(input_path, {"decisionPreflightRecords": []})

    result = compile_catalog_approval_decision_inputs(
        CatalogApprovalDecisionInputsOptions(
            preflight_records_path=input_path,
            output_root=tmp_path / "decision-inputs",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_schema_valid")
    assert any("must include decision preflight records" in issue for issue in result["issues"])


def test_catalog_approval_decision_inputs_stable_ordering_is_deterministic(tmp_path: Path):
    input_path = _write_preflight_records(
        tmp_path,
        [
            _blocked_preflight_record("z", domain="health_wellness_reference"),
            _blocked_preflight_record("a", domain="education_credentialing"),
        ],
    )

    first = compile_catalog_approval_decision_inputs(
        CatalogApprovalDecisionInputsOptions(preflight_records_path=input_path, output_root=tmp_path / "first", created_at=CREATED_AT)
    )
    second = compile_catalog_approval_decision_inputs(
        CatalogApprovalDecisionInputsOptions(preflight_records_path=input_path, output_root=tmp_path / "second", created_at=CREATED_AT)
    )

    first_packets = read_json(Path(first["outputRoot"]) / "decision-input-packets.json")["decisionInputPackets"]
    second_packets = read_json(Path(second["outputRoot"]) / "decision-input-packets.json")["decisionInputPackets"]
    assert first_packets == second_packets
    assert first_packets == sorted(first_packets, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"], item["decision_input_id"]))


def _write_preflight_records(tmp_path: Path, records: list[dict[str, object]]) -> Path:
    path = tmp_path / "decision-preflight-records.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.catalogApprovalDecisionPreflightRecords.v1",
            "createdAt": CREATED_AT,
            "decisionPreflightRecords": records,
        },
    )
    return path


def _blocked_preflight_record(suffix: str, *, domain: str = "education_credentialing") -> dict[str, object]:
    source_id = f"catalog.candidate.{suffix}"
    return {
        "schema_version": "1.0.0",
        "preflight_id": f"catalog_approval_preflight.{suffix}",
        "proposal_id": f"catalog_terms_resolution.{suffix}",
        "request_id": f"catalog_registry_approval_request.{suffix}",
        "intake_id": f"catalog_governance_intake.{suffix}",
        "candidate_id": f"catalog_candidate.{suffix}",
        "domain_guess": domain,
        "source_id": source_id,
        "source_name": "Example Catalog Candidate",
        "created_at": CREATED_AT,
        "status": "blocked_review_required",
        "missing_source_lane_fields": ["authority_class", "jurisdiction", "source_class"],
        "missing_legal_terms_fields": ["review_owner", "reviewed_at", "source_specific_restrictions"],
        "missing_api_governance_fields": ["retry_policy", "timeout_seconds", "budget_owner"],
        "blocking_reasons": [
            "source_lane_fields_incomplete",
            "legal_terms_fields_incomplete",
            "api_governance_fields_incomplete",
            "approval_artifact_still_required",
        ],
        "required_reviewer_actions": [
            "complete source lane authority, jurisdiction, review, freshness, and artifact policy fields",
            "complete legal/terms redistribution, pack-output, restrictions, review, and expiry fields",
            "complete API governance key, budget, rate, retry, timeout, live/execute, and evidence policy fields",
        ],
        "draft_entry": {
            "intake_id": f"catalog_governance_intake.{suffix}",
            "source_lane_entry": {
                "source_id": source_id,
                "source_name": "Example Catalog Candidate",
                "authority_class": "",
                "jurisdiction": "",
                "source_class": "",
                "review_status": "review_required",
                "r2_pack_policy": "pack_blocked_unknown_terms",
            },
            "legal_terms_entry": {
                "license_id": f"review_required.{source_id}",
                "license_name": "Review Required",
                "redistribution_allowed": False,
                "pack_output_allowed": False,
                "review_required": True,
            },
            "api_policy_entry": {
                "api_policy_id": f"review_required.{source_id}",
                "source_id": source_id,
                "api_mode": "review_required_before_live_harvest",
                "live_flag_required": True,
                "execute_flag_required": True,
                "secret_redaction_required": True,
            },
        },
        "non_claims": ["preflight record only", "not approval"],
    }


def _ready_preflight_record(suffix: str) -> dict[str, object]:
    record = _blocked_preflight_record(suffix)
    record["status"] = "decision_ready_for_reviewer_completion"
    record["missing_source_lane_fields"] = []
    record["missing_legal_terms_fields"] = []
    record["missing_api_governance_fields"] = []
    record["blocking_reasons"] = []
    record["required_reviewer_actions"] = ["reviewer may complete a decision artifact, but this input still does not approve it"]
    return record


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
