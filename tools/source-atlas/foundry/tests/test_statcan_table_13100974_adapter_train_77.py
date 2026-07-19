from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.claim_frontier import ClaimFrontierOptions, compile_claim_frontier
from foundry.harvest_runner import GovernedHarvestOptions, run_governed_harvest
from foundry.model import read_json, write_json
from foundry.pack_production import PackProductionOptions, build_pack_production
from foundry.public_reference_adapters import ADAPTER_IDS, adapter_instances
from foundry.terms_registry import terms_entry, validate_terms_registry


CREATED_AT = "2026-06-28T00:00:00Z"
SOURCE_ID = "official.statcan.table.13100974"
DOMAIN = "health_wellness_reference_ca_statistics"


def test_statcan_table_13100974_fixture_adapter_is_governed_and_pack_candidate_ready(tmp_path: Path):
    result = _harvest_statcan(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governed harvest runner"
    assert result["recordCounts"]["sourcesHarvested"] == 1
    assert result["recordCounts"]["claims"] == 2
    assert result["recordCounts"]["packCandidates"] == 1
    assert result["restrictedExclusions"] == []
    assert result["privacyScan"]["passed"]

    normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{SOURCE_ID}.json")
    assert normalized["sourceID"] == SOURCE_ID
    assert normalized["adapterID"] == ADAPTER_IDS[SOURCE_ID]
    assert normalized["termsValidation"]["packable"] is True
    assert normalized["termsValidation"]["r2Ready"] is True
    assert normalized["termsValidation"]["r2PackPolicy"] == "r2_pack_allowed"
    assert {claim["claimType"] for claim in normalized["claims"]} == {
        "public_statistical_reference",
        "public_health_statistical_context",
    }
    assert all(claim["reviewRequirement"] is False for claim in normalized["claims"])
    assert normalized["packCandidates"]
    assert normalized["apiLanes"]["fixtureMode"] == "no_network_static_statcan_table_reference"


def test_statcan_table_13100974_claim_frontier_and_pack_dry_run_with_custom_frontier(tmp_path: Path):
    harvest = _harvest_statcan(tmp_path)
    frontier = compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=Path(harvest["runRoot"]),
            output_root=tmp_path / "claim-frontier",
            frontier_config_path=_statcan_frontier_config(tmp_path),
            created_at=CREATED_AT,
        )
    )

    assert frontier["valid"], frontier["issues"]
    assert frontier["recordCounts"]["claims"] == 2
    assert frontier["recordCounts"]["packableClaims"] == 2
    assert frontier["provenanceCompleteness"]["packablePercent"] == 1.0

    statcan_frontier = next(report for report in frontier["frontierReports"] if report["frontier_id"] == DOMAIN)
    assert statcan_frontier["status"] == "claim_graph_ready"
    assert statcan_frontier["status_ceiling"] == "pack_staging_ready"
    assert statcan_frontier["packable_claim_count"] == 2
    assert statcan_frontier["missing_claim_classes"] == []
    assert statcan_frontier["gold_set_status"] == "not_required"

    result = build_pack_production(
        PackProductionOptions(
            input_root=Path(frontier["outputRoot"]),
            output_root=tmp_path / "pack-production",
            domain=DOMAIN,
            environment="staging",
            channel="candidate",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for pack compiler/R2 dry-run controls"
    assert result["recordCounts"]["claims"] == 2
    assert result["dryRunPlan"]["dryRun"] is True
    assert result["dryRunPlan"]["wouldUpload"] is False
    assert result["nonPrivateScan"]["passed"]
    assert all(f"/{DOMAIN}/" in key for key in result["objectKeys"].values())

    claims = read_json(Path(result["outputRoot"]) / "claims.json")["claims"]
    licenses = read_json(Path(result["outputRoot"]) / "licenses.json")["licenses"]
    attribution = read_json(Path(result["outputRoot"]) / "attribution.json")["attribution"]
    assert {claim["source_id"] for claim in claims} == {SOURCE_ID}
    assert {claim["claim_type"] for claim in claims} == {"public_statistical_reference", "public_health_statistical_context"}
    assert licenses and licenses[0]["license_id"] == "statcan.open-licence.2026-06-28"
    assert attribution


def test_statcan_table_13100974_adapter_outputs_no_private_or_final_user_artifacts(tmp_path: Path):
    result = _harvest_statcan(tmp_path)
    normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{SOURCE_ID}.json")
    encoded = json.dumps(normalized, sort_keys=True)

    assert result["privacyScan"]["passed"]
    assert "final_user_path" not in encoded
    assert "final_schedule" not in encoded
    assert "step_list" not in encoded
    assert "personalized_plan" not in encoded
    assert "private_goal_graph" not in encoded
    lower_claims = " ".join(claim["text"].lower() for claim in normalized["claims"])
    assert "medical advice" in lower_claims
    assert "diagnosis" in lower_claims
    assert "treatment planning" in lower_claims


def test_statcan_table_13100974_adapter_and_terms_registry_are_registered_once():
    matching = [adapter for adapter in adapter_instances() if adapter.source_id == SOURCE_ID]

    assert len(matching) == 1
    assert matching[0].adapter_id == "statcan_table_13100974_health_provider_ehi_adapter"
    assert terms_entry(SOURCE_ID)["jurisdiction"] == "CA"
    assert validate_terms_registry()["valid"]


def _harvest_statcan(tmp_path: Path) -> dict[str, object]:
    return run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="statcan-table-13100974-fixture",
            mode="fixture",
            source_ids=[SOURCE_ID],
            limit=6,
            created_at=CREATED_AT,
        ),
        env={},
    )


def _statcan_frontier_config(tmp_path: Path) -> Path:
    path = tmp_path / "statcan-frontier.json"
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.coverageFrontierConfig.v1",
            "createdAt": CREATED_AT,
            "frontiers": [
                {
                    "schema_version": "1.0.0",
                    "frontier_id": DOMAIN,
                    "domain": DOMAIN,
                    "goal_intent_classes": ["health_statistics_reference"],
                    "claim_classes": ["public_statistical_reference", "public_health_statistical_context"],
                    "jurisdictions": ["CA"],
                    "source_classes_required": ["official_government"],
                    "minimum_authority_classes": ["official_government"],
                    "freshness_slas": ["quarterly_source_and_terms_review"],
                    "legal_posture_required": "pack_output_allowed",
                    "gold_set_required": False,
                    "source_ids": [SOURCE_ID],
                    "excluded_sources": [],
                    "non_claims": [
                        "not medical advice",
                        "not diagnosis",
                        "not treatment planning",
                        "not personal health recommendation",
                        "not universal coverage",
                    ],
                    "status_ceiling": "pack_staging_ready",
                }
            ],
        },
    )
    return path
