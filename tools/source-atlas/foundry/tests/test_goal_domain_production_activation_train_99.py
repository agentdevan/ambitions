from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from foundry.goal_domain_production_activation import (  # noqa: E402
    GoalDomainProductionActivationOptions,
    compile_goal_domain_production_activation,
    write_goal_domain_production_activation_report,
)
from foundry.model import read_json, write_json  # noqa: E402
from test_goal_domain_source_specific_apply_packet_train_98 import _write_source_specific_input  # noqa: E402


CREATED_AT = "2026-06-28T00:00:00Z"


def test_production_activation_dry_run_validates_candidate_registries_without_active_writes(tmp_path: Path):
    input_path = _write_source_specific_input(tmp_path, "activationdry")

    result = compile_goal_domain_production_activation(
        GoalDomainProductionActivationOptions(
            input_path=input_path,
            output_root=tmp_path / "activation-output",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for goal-domain production activation orchestration tooling"
    assert result["activationComplete"] is False
    assert result["activationDecision"] == "dry_run_candidate_registries_validated_no_active_registry_write"
    assert result["recordCounts"]["candidateRegistryMutations"] == 1
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert _check(result, "source_specific_packet_valid")
    assert _check(result, "post_apply_governance_validation_passed")


def test_production_activation_executes_temp_registry_apply_when_ready(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    input_path = _write_source_specific_input(tmp_path, "activationexec")

    result = compile_goal_domain_production_activation(
        GoalDomainProductionActivationOptions(
            input_path=input_path,
            output_root=tmp_path / "activation-output",
            target_source_lane_registry_path=paths["source"],
            target_legal_terms_registry_path=paths["legal"],
            target_api_governance_registry_path=paths["api"],
            execute_active_registry=True,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["activationComplete"] is True
    assert result["activationDecision"] == "registry_apply_executed_and_governance_validated"
    assert result["recordCounts"]["activeRegistryMutations"] == 1
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert read_json(paths["source"])["source_lanes"][0]["source_id"] == "approved.source_specific.train98_activationexec"
    assert read_json(paths["legal"])["licenses"][0]["license_id"] == "approved_source_specific_train98_activationexec_terms"
    assert read_json(paths["api"])["api_policies"][0]["api_policy_id"] == "api.approved_source_specific_train98_activationexec.v1"
    assert _check(result, "post_apply_governance_validation_passed")


def test_production_activation_blocks_fixture_or_rehearsal_input(tmp_path: Path):
    input_path = _write_source_specific_input(tmp_path, "activationmarker")
    payload = read_json(input_path)
    payload["plannedRegistryMutations"][0]["sourceLaneEntry"]["license_url"] = "https://example.gov/license"
    write_json(input_path, payload)

    result = compile_goal_domain_production_activation(
        GoalDomainProductionActivationOptions(
            input_path=input_path,
            output_root=tmp_path / "activation-output",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert result["activationComplete"] is False
    assert result["activationDecision"] == "blocked_source_specific_packet_invalid"
    assert any("fixture/rehearsal marker" in issue for issue in result["issues"])
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0


def test_production_activation_rejects_private_input_without_registry_writes(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    input_path = _write_source_specific_input(tmp_path, "activationprivate")
    payload = read_json(input_path)
    payload["capture_text"] = "Captured from my private schedule"
    write_json(input_path, payload)

    result = compile_goal_domain_production_activation(
        GoalDomainProductionActivationOptions(
            input_path=input_path,
            output_root=tmp_path / "activation-output",
            target_source_lane_registry_path=paths["source"],
            target_legal_terms_registry_path=paths["legal"],
            target_api_governance_registry_path=paths["api"],
            execute_active_registry=True,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert result["activationComplete"] is False
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert read_json(paths["source"])["source_lanes"] == []
    assert read_json(paths["legal"])["licenses"] == []
    assert read_json(paths["api"])["api_policies"] == []


def test_production_activation_report_writer_emits_markdown_and_json(tmp_path: Path):
    input_path = _write_source_specific_input(tmp_path, "activationwriter")
    markdown_path = tmp_path / "source-atlas-goal-domain-production-activation-train-99.md"
    json_path = tmp_path / "source-atlas-goal-domain-production-activation-train-99.json"

    result = write_goal_domain_production_activation_report(
        markdown_path,
        json_path,
        input_path=input_path,
        output_root=tmp_path / "activation-output",
        created_at=CREATED_AT,
    )

    assert result["valid"], result["issues"]
    assert markdown_path.exists()
    assert json_path.exists()
    assert "Source Atlas Goal-Domain Production Activation Train 99" in markdown_path.read_text(encoding="utf-8")
    persisted = read_json(json_path)
    assert persisted["activationDecision"] == "dry_run_candidate_registries_validated_no_active_registry_write"
    assert persisted["recordCounts"]["r2PublishOperations"] == 0


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


def _check(result: dict[str, object], name: str) -> bool:
    return bool(next(check for check in result["checks"] if check["name"] == name)["passed"])
