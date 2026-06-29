from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.goal_domain_registry_apply_rehearsal import (
    GoalDomainRegistryApplyRehearsalOptions,
    run_goal_domain_registry_apply_rehearsal,
    write_goal_domain_registry_apply_rehearsal_report,
)
from foundry.model import read_json, write_json


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
REVIEW_TEMPLATES = SOURCE_ATLAS_ROOT / "generated" / "goal-domain-review-packets" / "train-92-fixture" / "review-packet-templates.json"
CREATED_AT = "2026-06-28T00:00:00Z"


def test_goal_domain_registry_apply_rehearsal_runs_non_empty_pipeline_against_temp_registries(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)

    result = run_goal_domain_registry_apply_rehearsal(
        GoalDomainRegistryApplyRehearsalOptions(
            review_templates_path=REVIEW_TEMPLATES,
            output_root=tmp_path / "rehearsal",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for goal-domain registry apply rehearsal tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; fixture rehearsal only"
    assert result["recordCounts"]["reviewPacketTemplates"] == 8
    assert result["recordCounts"]["completedReviewPackets"] == 8
    assert result["recordCounts"]["plannedRegistryMutations"] == 2
    assert result["recordCounts"]["appliedTempRegistryMutations"] == 2
    assert result["recordCounts"]["activeRepoRegistryMutations"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert _check(result, "temp_registry_apply_non_empty")
    assert _check(result, "active_repo_registries_untouched")
    assert read_json(paths["source"])["source_lanes"] == []

    temp_source = read_json(Path(result["outputPaths"]["tempSourceLaneRegistry"]))
    assert len(temp_source["source_lanes"]) == 2
    assert all(lane["source_id"].startswith("fixture.goal_domain.") for lane in temp_source["source_lanes"])


def test_goal_domain_registry_apply_rehearsal_blocks_missing_templates(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    missing_templates = tmp_path / "missing-templates.json"
    write_json(missing_templates, {"kind": "ambitions.sourceAtlas.goalDomainReviewPackets.v1", "reviewPackets": []})

    result = run_goal_domain_registry_apply_rehearsal(
        GoalDomainRegistryApplyRehearsalOptions(
            review_templates_path=missing_templates,
            output_root=tmp_path / "rehearsal",
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "templates_loaded")
    assert not _check(result, "mutation_plan_non_empty")
    assert result["recordCounts"]["activeRepoRegistryMutations"] == 0


def test_goal_domain_registry_apply_rehearsal_report_writer_emits_markdown_and_json(tmp_path: Path):
    paths = _write_empty_registries(tmp_path)
    markdown_path = tmp_path / "source-atlas-goal-domain-registry-apply-rehearsal-train-96.md"
    json_path = tmp_path / "source-atlas-goal-domain-registry-apply-rehearsal-train-96.json"

    result = write_goal_domain_registry_apply_rehearsal_report(
        markdown_path,
        json_path,
        review_templates_path=REVIEW_TEMPLATES,
        output_root=tmp_path / "rehearsal",
        source_lane_registry_path=paths["source"],
        legal_terms_registry_path=paths["legal"],
        api_governance_registry_path=paths["api"],
        created_at=CREATED_AT,
    )

    assert result["valid"], result["issues"]
    assert markdown_path.exists()
    assert json_path.exists()
    assert "Source Atlas Goal-Domain Registry Apply Rehearsal Train 96" in markdown_path.read_text(encoding="utf-8")
    persisted = read_json(json_path)
    assert persisted["recordCounts"]["plannedRegistryMutations"] == 2
    assert persisted["recordCounts"]["appliedTempRegistryMutations"] == 2


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
