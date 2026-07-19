from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.harvest_runner import GovernedHarvestOptions, run_governed_harvest
from foundry.model import read_json


def test_governed_harvest_fixture_mode_writes_deterministic_public_evidence(tmp_path: Path):
    result = run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path,
            run_id="fixture",
            mode="fixture",
            source_ids=["onet.database", "bls.public.data.api", "wikidata.crosswalk", "usajobs.search"],
            limit=3,
            created_at="2026-06-27T00:00:00Z",
        ),
        env={},
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governed harvest runner"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; governed harvest runner only"
    assert result["recordCounts"]["sourcesHarvested"] == 4
    assert result["recordCounts"]["packCandidates"] > 0
    assert result["privacyScan"]["passed"]
    assert any(item["sourceID"] == "usajobs.search" for item in result["restrictedExclusions"])
    assert all(item["sha256"] for item in result["evidenceHashes"])

    manifest = read_json(Path(result["manifestPath"]))
    assert manifest["runMode"] == "fixture"
    assert manifest["finishedAt"] == "2026-06-27T00:00:00Z"
    assert "not production R2 readiness" in manifest["nonClaims"]
    assert "private" not in json.dumps(manifest["outputPaths"]).lower()
    wikidata = read_json(Path(result["runRoot"]) / "normalized" / "wikidata.crosswalk.json")
    usajobs = read_json(Path(result["runRoot"]) / "normalized" / "usajobs.search.json")
    assert wikidata["packCandidates"] == []
    assert usajobs["packCandidates"] == []


def test_governed_harvest_live_modes_fail_closed_without_live_flag(tmp_path: Path):
    result = run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path,
            run_id="live-without-flag",
            mode="live_harvest",
            source_ids=["bls.public.data.api"],
            limit=1,
            live=False,
            created_at="2026-06-27T00:00:00Z",
        ),
        env={},
    )

    assert not result["valid"]
    assert result["status"] == "Red"
    assert any("live_harvest: live mode requires --live" in issue for issue in result["issues"])
    assert not next(check for check in result["checks"] if check["name"] == "live_modes_require_live_flag")["passed"]


def test_governed_harvest_execute_modes_fail_closed_without_execute_flag(tmp_path: Path):
    result = run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path,
            run_id="publish-without-execute",
            mode="production_publish",
            source_ids=["onet.database"],
            limit=1,
            execute=False,
            created_at="2026-06-27T00:00:00Z",
        ),
        env={},
    )

    assert not result["valid"]
    assert any("production_publish: write/publish mode requires --execute" in issue for issue in result["issues"])
    assert not next(check for check in result["checks"] if check["name"] == "execute_modes_require_execute_flag")["passed"]


def test_governed_harvest_enforces_api_max_record_budget(tmp_path: Path):
    result = run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path,
            run_id="budget-overflow",
            mode="fixture",
            source_ids=["wikidata.crosswalk"],
            limit=101,
            created_at="2026-06-27T00:00:00Z",
        ),
        env={},
    )

    assert not result["valid"]
    assert any("wikidata.crosswalk: requested limit 101 exceeds max_records_per_run 100" in issue for issue in result["issues"])


def test_governed_harvest_missing_required_key_uses_safe_diagnostic(tmp_path: Path):
    result = run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path,
            run_id="missing-key",
            mode="live_harvest",
            source_ids=["usajobs.search"],
            limit=1,
            live=True,
            created_at="2026-06-27T00:00:00Z",
        ),
        env={"UNRELATED_SECRET": "super-secret-value"},
    )

    encoded = json.dumps(result)
    assert not result["valid"]
    assert "super-secret-value" not in encoded
    assert any("missing required environment variable USAJOBS_AUTHORIZATION_KEY" in issue for issue in result["issues"])
    assert any(item["sourceID"] == "usajobs.search" for item in result["restrictedExclusions"])
