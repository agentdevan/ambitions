from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.frontier_intake import FrontierIntakeOptions, compile_frontier_intake
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"
FIXTURE_PATH = Path("tools/source-atlas/fixtures/frontier-intake/train-52-arbitrary-domain-proposals.json")


def test_frontier_intake_emits_candidate_only_artifacts_without_claims(tmp_path: Path):
    result = _compile_fixture(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governed frontier intake tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; candidate-only arbitrary-domain frontier intake only"
    assert result["recordCounts"]["proposals"] == 2
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "candidate_intake_emits_no_claims")
    assert _check(result, "all_frontiers_candidate_only")
    assert _check(result, "all_sources_review_required")
    assert _check(result, "no_source_claim_authority_asserted")
    assert _check(result, "pack_output_blocked")
    assert _check(result, "input_privacy_scan_passed")
    assert _check(result, "privacy_scan_passed")


def test_proposed_frontiers_cannot_claim_pack_or_source_authority(tmp_path: Path):
    result = _compile_fixture(tmp_path)

    frontiers = read_json(Path(result["outputRoot"]) / "proposed-frontiers.json")["proposedFrontiers"]
    assert frontiers
    assert all(frontier["status_ceiling"] == "candidate_only" for frontier in frontiers)
    assert all(frontier["review_required"] is True for frontier in frontiers)
    assert all(frontier["pack_output_allowed"] is False for frontier in frontiers)
    assert all(frontier["claim_output_allowed"] is False for frontier in frontiers)
    assert all(frontier["source_ids"] == [] for frontier in frontiers)
    assert all(frontier["candidate_source_ids"] for frontier in frontiers)
    assert all("candidate_only_not_claim_authority" in frontier["blocking_reasons"] for frontier in frontiers)
    assert all("r2_pack_blocked_until_all_gates_pass" in frontier["blocking_reasons"] for frontier in frontiers)


def test_candidate_sources_remain_review_required_and_pack_blocked(tmp_path: Path):
    result = _compile_fixture(tmp_path)

    candidates = read_json(Path(result["outputRoot"]) / "candidate-sources.json")["candidateSourceRecords"]
    assert candidates
    assert all(candidate["review_required"] is True for candidate in candidates)
    assert all(candidate["claim_authority_allowed"] is False for candidate in candidates)
    assert all(candidate["pack_output_allowed"] is False for candidate in candidates)
    assert all(candidate["evidence_hash"] for candidate in candidates)
    assert all("candidate_score_cannot_override_review" in candidate["blocking_reasons"] for candidate in candidates)
    assert any("missing_declared_license" in candidate["blocking_reasons"] for candidate in candidates)


def test_source_of_sources_and_open_knowledge_graphs_cannot_be_authority(tmp_path: Path):
    result = _compile_fixture(tmp_path)
    candidates = read_json(Path(result["outputRoot"]) / "candidate-sources.json")["candidateSourceRecords"]

    catalogs = [candidate for candidate in candidates if candidate["source_class_guess"] == "public_catalog"]
    crosswalks = [candidate for candidate in candidates if candidate["authority_class_guess"] == "open_knowledge_graph"]
    assert catalogs
    assert crosswalks
    assert all("source_of_sources_not_claim_authority" in candidate["blocking_reasons"] for candidate in catalogs)
    assert all("crosswalk_only_not_regulated_authority" in candidate["blocking_reasons"] for candidate in crosswalks)
    assert all(candidate["claim_authority_allowed"] is False for candidate in catalogs + crosswalks)


def test_high_stakes_frontier_requires_official_or_regulated_authority(tmp_path: Path):
    input_path = tmp_path / "high-stakes-catalog-only.json"
    write_json(
        input_path,
        {
            "domainProposals": [
                {
                    "proposal_id": "catalog-only-legal-requirements",
                    "domain": "catalog_only_legal_requirements",
                    "claim_classes": ["legal_requirement"],
                    "jurisdictions": ["US"],
                    "source_classes_required": ["public_catalog"],
                    "minimum_authority_classes": ["public_catalog"],
                    "candidate_sources": [
                        {
                            "publisher_name": "Data.gov catalog",
                            "publisher_url": "https://catalog.data.gov/",
                            "source_class_guess": "public_catalog",
                            "authority_class_guess": "public_catalog",
                            "redistribution_guess": "unclear",
                            "terms_url": "https://www.data.gov/privacy-policy/",
                            "declared_license": "catalog metadata only",
                        }
                    ],
                }
            ]
        },
    )

    result = compile_frontier_intake(
        FrontierIntakeOptions(
            input_path=input_path,
            output_root=tmp_path / "frontier-intake",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("high-stakes claim classes require official/regulated authority review" in issue for issue in result["issues"])
    frontier = read_json(Path(result["outputRoot"]) / "proposed-frontiers.json")["proposedFrontiers"][0]
    assert frontier["pack_output_allowed"] is False
    assert frontier["claim_output_allowed"] is False


def test_private_proposal_input_fails_privacy_scan(tmp_path: Path):
    input_path = tmp_path / "private-context.json"
    write_json(
        input_path,
        {
            "domainProposals": [
                {
                    "proposal_id": "private-context",
                    "domain": "private_context_reference",
                    "goal_text": "I need a private plan",
                    "claim_classes": ["learning_resource_reference"],
                    "jurisdictions": ["US"],
                    "minimum_authority_classes": ["official_institution"],
                    "candidate_sources": [],
                }
            ]
        },
    )

    result = compile_frontier_intake(
        FrontierIntakeOptions(
            input_path=input_path,
            output_root=tmp_path / "frontier-intake",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_frontier_intake_stable_ordering_is_deterministic(tmp_path: Path):
    first = _compile_fixture(tmp_path / "first")
    second = _compile_fixture(tmp_path / "second")

    first_candidates = read_json(Path(first["outputRoot"]) / "candidate-sources.json")["candidateSourceRecords"]
    second_candidates = read_json(Path(second["outputRoot"]) / "candidate-sources.json")["candidateSourceRecords"]
    assert [candidate["candidate_id"] for candidate in first_candidates] == [
        candidate["candidate_id"] for candidate in second_candidates
    ]
    assert first_candidates == sorted(first_candidates, key=lambda item: (item["domain_guess"], -item["candidate_score"], item["candidate_id"]))


def _compile_fixture(tmp_path: Path) -> dict[str, object]:
    return compile_frontier_intake(
        FrontierIntakeOptions(
            input_path=FIXTURE_PATH,
            output_root=tmp_path / "frontier-intake",
            created_at=CREATED_AT,
        )
    )


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
