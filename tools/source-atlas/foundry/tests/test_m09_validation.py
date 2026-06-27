from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.m09_validation import (
    KNOWN_ISSUE_IDS,
    validate_command_matrix,
    validate_golden_benchmark_matrix,
    validate_source_state_repair_fixtures,
    route_known_issues,
    generate_evidence_pack,
)
from foundry.model import read_json, write_json


REPO_ROOT = Path(__file__).resolve().parents[4]
MATRIX_PATH = REPO_ROOT / "docs" / "qa" / "source-atlas" / "2026-06-26-m09-validation-command-matrix.json"
GOLDEN_PATH = REPO_ROOT / "tools" / "source-atlas" / "fixtures" / "m09" / "golden-benchmark-matrix.json"
REPAIR_PATH = REPO_ROOT / "tools" / "source-atlas" / "fixtures" / "m09" / "source-state-repair-fixtures.json"


def test_m09_validation_command_matrix_references_real_or_explicitly_unavailable_commands(tmp_path: Path):
    result = validate_command_matrix(MATRIX_PATH, REPO_ROOT, tmp_path / "matrix-result.json")

    assert result["valid"], result["issues"]
    assert result["notAvailableCount"] == 1
    assert "production R2 upload".lower() in read_json(MATRIX_PATH)["commands"][-1]["notAvailableReason"].lower()


def test_m09_golden_benchmark_matrix_covers_17_scenarios_8_states_and_no_false_completion(tmp_path: Path):
    result = validate_golden_benchmark_matrix(GOLDEN_PATH, tmp_path / "golden-result.json")

    assert result["valid"], result["issues"]
    assert result["scenarioCount"] == 17
    assert result["variantCount"] == 8
    assert result["expandedCaseCount"] == 136
    assert result["noFalseCompletionAssertions"] == 136
    assert result["productionSourceAtlasTruthClaimed"] is False


def test_m09_golden_benchmark_rejects_false_completion_claim(tmp_path: Path):
    matrix = read_json(GOLDEN_PATH)
    bad_matrix = copy.deepcopy(matrix)
    bad_matrix["defaultSourceStateAssertions"]["revoked"]["completionClaimAllowed"] = True
    bad_path = tmp_path / "bad-golden.json"
    write_json(bad_path, bad_matrix)

    result = validate_golden_benchmark_matrix(bad_path)

    assert result["valid"] is False
    assert any("completion claim must be forbidden" in issue for issue in result["issues"])


def test_m09_source_state_repair_fixtures_block_unsafe_runtime_drive(tmp_path: Path):
    result = validate_source_state_repair_fixtures(REPAIR_PATH, tmp_path / "repair-result.json")

    assert result["valid"], result["issues"]
    assert result["fixtureCount"] == 7
    assert result["unsafeRuntimeDriveBlocked"] is True
    assert {"stale", "stale-critical", "unavailable", "conflicted", "revoked", "unsupported", "review-required"} == set(result["statesCovered"])


def test_m09_source_state_repair_rejects_silent_conflict_winner(tmp_path: Path):
    payload = read_json(REPAIR_PATH)
    bad_payload = copy.deepcopy(payload)
    for fixture in bad_payload["fixtures"]:
        if fixture["sourceState"] == "conflicted":
            fixture["silentWinnerSelectionAllowed"] = True
    bad_path = tmp_path / "bad-repair.json"
    write_json(bad_path, bad_payload)

    result = validate_source_state_repair_fixtures(bad_path)

    assert result["valid"] is False
    assert any("silentWinnerSelectionAllowed must be false" in issue for issue in result["issues"])


def test_m09_router_and_evidence_pack_do_not_close_known_issues_or_claim_release(tmp_path: Path):
    command_path = tmp_path / "matrix-result.json"
    golden_path = tmp_path / "golden-result.json"
    repair_path = tmp_path / "repair-result.json"
    known_path = tmp_path / "known-issue-router-result.json"

    validate_command_matrix(MATRIX_PATH, REPO_ROOT, command_path)
    validate_golden_benchmark_matrix(GOLDEN_PATH, golden_path)
    validate_source_state_repair_fixtures(REPAIR_PATH, repair_path)
    router = route_known_issues(command_path, golden_path, repair_path, known_path)
    pack = generate_evidence_pack(tmp_path, command_path, golden_path, repair_path, known_path, "docs/qa/source-atlas/ledger.md")

    assert {row["issueID"] for row in router["issues"]} == set(KNOWN_ISSUE_IDS)
    assert router["knownIssueClosureAttempted"] is False
    assert all(row["closeKnownIssue"] is False for row in router["issues"])
    assert pack["status"] == "Green"
    assert pack["releaseReadinessClaimed"] is False
    assert pack["productionR2UploadClaimed"] is False
    assert pack["knownIssueClosureAttempted"] is False
    assert (tmp_path / "m09-release-evidence-pack.json").exists()
    assert (tmp_path / "m09-release-evidence-pack.md").exists()
