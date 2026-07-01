from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.launch_floor_domain_taxonomy import (  # noqa: E402
    DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH,
    LaunchFloorDomainTaxonomyOptions,
    compile_launch_floor_domain_taxonomy,
    launch_floor_domain_taxonomy_summary,
)
from foundry.model import read_json, write_json  # noqa: E402


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = Path(__file__).resolve().parents[4]
SOURCE_LANE_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "source-lane-registry.json"
PRODUCTION_TARGET_LEDGER = SOURCE_ATLAS_ROOT / "generated" / "production-target-ledger" / "train-131-tetradeca-current" / "production-target-ledger.json"
CREATED_AT = "2026-07-01T00:00:00Z"


def test_launch_floor_domain_taxonomy_current_repo_proves_500_domains_and_5000_subdomains(tmp_path: Path):
    result = compile_launch_floor_domain_taxonomy(
        LaunchFloorDomainTaxonomyOptions(
            taxonomy_path=DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH,
            source_lane_registry_path=SOURCE_LANE_REGISTRY,
            production_target_ledger_path=PRODUCTION_TARGET_LEDGER,
            output_root=tmp_path / "taxonomy",
            created_at=CREATED_AT,
            run_label="test",
        )
    )

    assert result["valid"], result["issues"]
    counts = result["recordCounts"]
    assert counts["acceptedGoalDomains"] == 500
    assert counts["acceptedSubdomains"] == 5000
    assert counts["configuredReadyDomains"] == 14
    assert counts["productionReadyDomainsBackedByLedger"] == 14
    assert counts["configuredNotReadyDomains"] == 486
    assert counts["sourceLaneProfilesMappedToRegistry"] == 5
    assert counts["sourceLaneRegistryLinks"] >= 5
    assert counts["domainsWithSourceLaneCoverage"] == 500
    assert counts["subdomainsWithSourceLaneCoverage"] == 5000
    assert counts["candidateOnlyBacklogItems"] == 3
    assert counts["staleCandidateOnlyBacklogItems"] == 0
    assert counts["claims"] == 0
    assert counts["packableClaims"] == 0
    assert counts["r2PublishOperations"] == 0
    assert counts["nativeActivationOperations"] == 0
    assert result["launchFloorTargetStatus"]["goalDomains500"] is True
    assert result["launchFloorTargetStatus"]["subdomains5000"] is True
    assert "source_atlas_launch_floor_ready" in result["blockedClaims"]
    assert "final_user_plans_schedules_steps_from_source_atlas_or_r2" in result["blockedClaims"]


def test_launch_floor_domain_taxonomy_rejects_candidate_backlog_counting_as_coverage(tmp_path: Path):
    taxonomy = copy.deepcopy(read_json(DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH))
    taxonomy["candidateOnlyBacklog"][0]["countsTowardLaunchFloorCovered"] = True
    taxonomy["candidateOnlyBacklog"][0]["reviewDueAt"] = "2026-06-01T00:00:00Z"
    taxonomy_path = tmp_path / "taxonomy.json"
    write_json(taxonomy_path, taxonomy)

    result = compile_launch_floor_domain_taxonomy(
        LaunchFloorDomainTaxonomyOptions(
            taxonomy_path=taxonomy_path,
            source_lane_registry_path=SOURCE_LANE_REGISTRY,
            production_target_ledger_path=PRODUCTION_TARGET_LEDGER,
            output_root=tmp_path / "taxonomy-report",
            created_at=CREATED_AT,
            run_label="candidate-backlog-negative",
        )
    )

    assert result["valid"] is False
    assert result["recordCounts"]["staleCandidateOnlyBacklogItems"] == 1
    assert any("cannot count toward launch-floor coverage" in issue for issue in result["issues"])
    assert any("reviewDueAt is stale" in issue for issue in result["issues"])
    assert result["allowedClaims"] == []


def test_launch_floor_domain_taxonomy_summary_fails_closed_when_source_lane_coverage_missing(tmp_path: Path):
    taxonomy = copy.deepcopy(read_json(DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH))
    taxonomy["domainFamilies"][0]["domainRecords"][1]["sourceLaneCoverage"]["profileIDs"] = []

    summary = launch_floor_domain_taxonomy_summary(
        taxonomy,
        created_at=CREATED_AT,
        source_lane_registry=read_json(SOURCE_LANE_REGISTRY),
        production_target_ledger=read_json(PRODUCTION_TARGET_LEDGER),
    )

    assert summary["launchFloorTargets"]["goalDomains500"] is True
    assert summary["launchFloorTargets"]["subdomains5000"] is True
    assert summary["launchFloorTargets"]["sourceLaneCoverageComplete"] is False
    assert any("accepted domain must list sourceLaneCoverage.profileIDs" in issue for issue in summary["issues"])


def test_launch_floor_domain_taxonomy_rejects_unknown_source_lane_registry_links():
    taxonomy = copy.deepcopy(read_json(DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH))
    taxonomy["sourceLaneProfiles"][0]["sourceLaneRegistryIDs"] = ["missing.registry.source"]

    summary = launch_floor_domain_taxonomy_summary(
        taxonomy,
        created_at=CREATED_AT,
        source_lane_registry=read_json(SOURCE_LANE_REGISTRY),
        production_target_ledger=read_json(PRODUCTION_TARGET_LEDGER),
    )

    assert any("unknown sourceLaneRegistryID missing.registry.source" in issue for issue in summary["issues"])
