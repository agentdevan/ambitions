from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_candidate_review import CatalogCandidateReviewOptions, compile_catalog_candidate_review
from foundry.catalog_discovery import CatalogDiscoveryOptions, run_catalog_discovery
from foundry.catalog_governance_intake import CatalogGovernanceIntakeOptions, compile_catalog_governance_intake
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"
FIXTURE_ROOT = Path("tools/source-atlas/fixtures/catalog-discovery/train-53-catalogs")


def test_catalog_governance_intake_compiles_drafts_without_registry_mutation(tmp_path: Path):
    result = _run_intake(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for catalog governance intake draft tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; draft governance intake only"
    assert result["recordCounts"]["reviewPackets"] == 6
    assert result["recordCounts"]["draftGovernancePackets"] == 6
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["approvedSourceLanes"] == 0
    assert result["recordCounts"]["approvedLegalEntries"] == 0
    assert result["recordCounts"]["approvedApiPolicies"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "governance_intake_emits_no_claims")
    assert _check(result, "no_active_registry_mutations")
    assert _check(result, "input_privacy_scan_passed")
    assert _check(result, "privacy_scan_passed")


def test_catalog_governance_intake_drafts_remain_review_required_and_blocked(tmp_path: Path):
    result = _run_intake(tmp_path)
    drafts = read_json(Path(result["outputRoot"]) / "draft-governance-packets.json")["draftGovernancePackets"]
    mutations = read_json(Path(result["outputRoot"]) / "active-registry-mutations.json")["activeRegistryMutations"]

    assert drafts
    assert mutations == []
    assert all(draft["active_registry_mutation_allowed"] is False for draft in drafts)
    assert all(draft["review_status"] == "review_required" for draft in drafts)
    assert all(draft["source_lane_draft"]["claim_classes_allowed"] == [] for draft in drafts)
    assert all(draft["source_lane_draft"]["active_registry_entry"] is False for draft in drafts)
    assert all(draft["source_lane_draft"]["r2_pack_policy"].startswith("pack_blocked") for draft in drafts)
    assert all(draft["legal_terms_draft"]["redistribution_allowed"] is False for draft in drafts)
    assert all(draft["legal_terms_draft"]["outside_legal_status"] == "not_claimed" for draft in drafts)
    assert all(draft["api_governance_draft"]["live_harvest_allowed"] is False for draft in drafts)
    assert all("active_registry_mutation_blocked" in draft["blocking_reasons"] for draft in drafts)


def test_catalog_governance_intake_rejects_unblocked_review_packet(tmp_path: Path):
    input_path = tmp_path / "review-packets.json"
    write_json(
        input_path,
        {
            "reviewPackets": [
                {
                    "packet_id": "catalog_candidate_review_packet.bad",
                    "candidate_id": "catalog_candidate.bad",
                    "review_required": False,
                    "active_source_lane_emitted": True,
                    "claim_authority_allowed": True,
                    "pack_output_allowed": True,
                    "blocking_reasons": [],
                    "domain_guess": "education_credentialing",
                }
            ]
        },
    )

    result = compile_catalog_governance_intake(
        CatalogGovernanceIntakeOptions(
            input_path=input_path,
            output_root=tmp_path / "governance-intake",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("must remain review_required" in issue for issue in result["issues"])
    assert any("cannot emit active source lane" in issue for issue in result["issues"])
    assert any("cannot allow claim authority" in issue for issue in result["issues"])
    assert any("cannot allow pack output" in issue for issue in result["issues"])


def test_catalog_governance_intake_rejects_private_review_packet_payload(tmp_path: Path):
    input_path = tmp_path / "review-packets.json"
    write_json(
        input_path,
        {
            "reviewPackets": [
                {
                    "packet_id": "catalog_candidate_review_packet.private",
                    "candidate_id": "catalog_candidate.private",
                    "review_required": True,
                    "active_source_lane_emitted": False,
                    "claim_authority_allowed": False,
                    "pack_output_allowed": False,
                    "blocking_reasons": [
                        "catalog_metadata_not_claim_authority",
                        "source_lane_review_required",
                        "legal_terms_review_required",
                        "api_policy_review_required",
                        "pack_output_blocked_until_review",
                    ],
                    "goal_text": "I need this for my private plan",
                    "domain_guess": "unclassified_public_reference",
                }
            ]
        },
    )

    result = compile_catalog_governance_intake(
        CatalogGovernanceIntakeOptions(
            input_path=input_path,
            output_root=tmp_path / "governance-intake",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_governance_intake_stable_ordering_is_deterministic(tmp_path: Path):
    first = _run_intake(tmp_path / "first")
    second = _run_intake(tmp_path / "second")

    first_drafts = read_json(Path(first["outputRoot"]) / "draft-governance-packets.json")["draftGovernancePackets"]
    second_drafts = read_json(Path(second["outputRoot"]) / "draft-governance-packets.json")["draftGovernancePackets"]
    assert [draft["intake_id"] for draft in first_drafts] == [draft["intake_id"] for draft in second_drafts]
    assert first_drafts == sorted(first_drafts, key=lambda item: (item["domain_guess"], item["candidate_id"], item["intake_id"]))


def _run_intake(tmp_path: Path) -> dict[str, object]:
    discovery = run_catalog_discovery(
        CatalogDiscoveryOptions(
            input_root=FIXTURE_ROOT,
            output_root=tmp_path / "catalog-discovery",
            created_at=CREATED_AT,
        )
    )
    review = compile_catalog_candidate_review(
        CatalogCandidateReviewOptions(
            input_path=Path(discovery["outputRoot"]) / "candidate-sources.json",
            output_root=tmp_path / "candidate-review",
            created_at=CREATED_AT,
        )
    )
    return compile_catalog_governance_intake(
        CatalogGovernanceIntakeOptions(
            input_path=Path(review["outputRoot"]) / "review-packets.json",
            output_root=tmp_path / "governance-intake",
            created_at=CREATED_AT,
        )
    )


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
