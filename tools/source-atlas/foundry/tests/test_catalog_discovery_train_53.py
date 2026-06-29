from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_discovery import CatalogDiscoveryOptions, run_catalog_discovery
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"
FIXTURE_ROOT = Path("tools/source-atlas/fixtures/catalog-discovery/train-53-catalogs")


def test_catalog_discovery_parses_common_catalog_shapes_without_claims(tmp_path: Path):
    result = _run_fixture(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for fixture-backed catalog discovery tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; catalog/source discovery candidates only"
    assert result["recordCounts"]["catalogs"] == 3
    assert result["recordCounts"]["candidateSources"] == 6
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "input_catalogs_valid")
    assert _check(result, "catalog_discovery_emits_no_claims")
    assert _check(result, "input_privacy_scan_passed")
    assert _check(result, "privacy_scan_passed")

    catalogs = read_json(Path(result["outputRoot"]) / "catalogs.json")["catalogRecords"]
    assert {catalog["catalog_kind"] for catalog in catalogs} == {
        "ckan_package_search",
        "dcat_data_json",
        "schema_org",
    }


def test_catalog_candidates_are_review_required_and_pack_blocked(tmp_path: Path):
    result = _run_fixture(tmp_path)
    candidates = read_json(Path(result["outputRoot"]) / "candidate-sources.json")["candidateSourceRecords"]

    assert candidates
    assert all(candidate["review_required"] is True for candidate in candidates)
    assert all(candidate["claim_authority_allowed"] is False for candidate in candidates)
    assert all(candidate["pack_output_allowed"] is False for candidate in candidates)
    assert all(candidate["source_class_guess"] == "public_catalog" for candidate in candidates)
    assert all("catalog_metadata_not_claim_authority" in candidate["blocking_reasons"] for candidate in candidates)
    assert all("candidate_score_cannot_override_review" in candidate["blocking_reasons"] for candidate in candidates)
    assert any("missing_declared_license" in candidate["blocking_reasons"] for candidate in candidates)
    assert any("missing_terms_url" in candidate["blocking_reasons"] for candidate in candidates)


def test_catalog_discovery_keeps_source_of_sources_from_becoming_authority(tmp_path: Path):
    result = _run_fixture(tmp_path)

    assert _check(result, "catalogs_are_source_of_sources_only")
    assert _check(result, "no_candidate_claim_authority")
    assert _check(result, "pack_output_blocked")
    candidates = read_json(Path(result["outputRoot"]) / "candidate-sources.json")["candidateSourceRecords"]
    by_method = {candidate["discovery_method"] for candidate in candidates}
    assert by_method == {"ckan_package_search", "dcat_data_json", "schema_org"}
    assert all(candidate["claim_authority_allowed"] is False for candidate in candidates)


def test_catalog_discovery_rejects_private_catalog_payload(tmp_path: Path):
    input_root = tmp_path / "private-catalog"
    input_root.mkdir()
    write_json(
        input_root / "private-catalog.json",
        {
            "dataset": [
                {
                    "title": "Private context fixture",
                    "goal_text": "I need a private plan",
                    "publisher": {
                        "name": "Example Publisher"
                    },
                }
            ]
        },
    )

    result = run_catalog_discovery(
        CatalogDiscoveryOptions(
            input_root=input_root,
            output_root=tmp_path / "catalog-discovery",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_discovery_stable_ordering_is_deterministic(tmp_path: Path):
    first = _run_fixture(tmp_path / "first")
    second = _run_fixture(tmp_path / "second")

    first_candidates = read_json(Path(first["outputRoot"]) / "candidate-sources.json")["candidateSourceRecords"]
    second_candidates = read_json(Path(second["outputRoot"]) / "candidate-sources.json")["candidateSourceRecords"]
    assert [candidate["candidate_id"] for candidate in first_candidates] == [
        candidate["candidate_id"] for candidate in second_candidates
    ]
    assert first_candidates == sorted(first_candidates, key=lambda item: (item["domain_guess"], -item["candidate_score"], item["candidate_id"]))


def _run_fixture(tmp_path: Path) -> dict[str, object]:
    return run_catalog_discovery(
        CatalogDiscoveryOptions(
            input_root=FIXTURE_ROOT,
            output_root=tmp_path / "catalog-discovery",
            created_at=CREATED_AT,
        )
    )


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
