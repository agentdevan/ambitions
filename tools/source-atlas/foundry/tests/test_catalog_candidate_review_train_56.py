from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_candidate_review import CatalogCandidateReviewOptions, compile_catalog_candidate_review
from foundry.catalog_discovery import CatalogDiscoveryOptions, run_catalog_discovery
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"
FIXTURE_ROOT = Path("tools/source-atlas/fixtures/catalog-discovery/train-53-catalogs")


def test_catalog_candidate_review_compiles_review_packets_without_claims(tmp_path: Path):
    result = _run_review(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governed catalog candidate review-packet tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; catalog candidates remain review-required and pack-blocked"
    assert result["recordCounts"]["candidateSources"] == 6
    assert result["recordCounts"]["reviewPackets"] == 6
    assert result["recordCounts"]["blockedPromotions"] == 6
    assert result["recordCounts"]["activeSourceLanes"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "candidate_review_emits_no_claims")
    assert _check(result, "no_active_source_lanes_emitted")
    assert _check(result, "input_privacy_scan_passed")
    assert _check(result, "privacy_scan_passed")


def test_catalog_candidate_review_packets_are_review_required_and_pack_blocked(tmp_path: Path):
    result = _run_review(tmp_path)
    packets = read_json(Path(result["outputRoot"]) / "review-packets.json")["reviewPackets"]
    blocked = read_json(Path(result["outputRoot"]) / "blocked-promotions.json")["blockedPromotions"]

    assert packets
    assert all(packet["review_required"] is True for packet in packets)
    assert all(packet["active_source_lane_emitted"] is False for packet in packets)
    assert all(packet["claim_authority_allowed"] is False for packet in packets)
    assert all(packet["pack_output_allowed"] is False for packet in packets)
    assert all(packet["redistribution_policy"] == "review_required" for packet in packets)
    assert all(packet["legal_review"]["redistribution_approval"] == "not_approved" for packet in packets)
    assert all(packet["api_review"]["api_policy_required_before_live_harvest"] is True for packet in packets)
    assert all("catalog_metadata_not_claim_authority" in packet["blocking_reasons"] for packet in packets)
    assert all("candidate_score_cannot_override_review" in packet["blocking_reasons"] for packet in packets)
    assert all(item["promotion_decision"] == "blocked_until_review" for item in blocked)


def test_catalog_candidate_review_rejects_candidate_promotion_attempt(tmp_path: Path):
    input_path = tmp_path / "candidate-sources.json"
    write_json(
        input_path,
        {
            "candidateSourceRecords": [
                {
                    "candidate_id": "catalog_candidate.bad-promotion",
                    "review_required": False,
                    "claim_authority_allowed": True,
                    "pack_output_allowed": True,
                    "source_class_guess": "official_government",
                    "blocking_reasons": [],
                    "publisher_name": "Example Agency",
                    "domain_guess": "education_credentialing",
                    "candidate_score": 100,
                }
            ]
        },
    )

    result = compile_catalog_candidate_review(
        CatalogCandidateReviewOptions(
            input_path=input_path,
            output_root=tmp_path / "candidate-review",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("must remain review_required" in issue for issue in result["issues"])
    assert any("cannot allow claim authority" in issue for issue in result["issues"])
    assert any("cannot allow pack output" in issue for issue in result["issues"])
    assert any("source_class_guess must remain public_catalog" in issue for issue in result["issues"])


def test_catalog_candidate_review_rejects_private_candidate_payload(tmp_path: Path):
    input_path = tmp_path / "candidate-sources.json"
    write_json(
        input_path,
        {
            "candidateSourceRecords": [
                {
                    "candidate_id": "catalog_candidate.private-context",
                    "review_required": True,
                    "claim_authority_allowed": False,
                    "pack_output_allowed": False,
                    "source_class_guess": "public_catalog",
                    "blocking_reasons": [
                        "catalog_metadata_not_claim_authority",
                        "source_lane_review_required",
                        "legal_terms_review_required",
                        "pack_output_blocked_until_review",
                        "candidate_score_cannot_override_review",
                    ],
                    "goal_text": "I need this for my private life plan",
                    "domain_guess": "unclassified_public_reference",
                }
            ]
        },
    )

    result = compile_catalog_candidate_review(
        CatalogCandidateReviewOptions(
            input_path=input_path,
            output_root=tmp_path / "candidate-review",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_catalog_candidate_review_stable_ordering_is_deterministic(tmp_path: Path):
    first = _run_review(tmp_path / "first")
    second = _run_review(tmp_path / "second")

    first_packets = read_json(Path(first["outputRoot"]) / "review-packets.json")["reviewPackets"]
    second_packets = read_json(Path(second["outputRoot"]) / "review-packets.json")["reviewPackets"]
    assert [packet["packet_id"] for packet in first_packets] == [packet["packet_id"] for packet in second_packets]
    assert first_packets == sorted(first_packets, key=lambda item: (item["domain_guess"], item["candidate_id"], item["packet_id"]))


def _run_review(tmp_path: Path) -> dict[str, object]:
    discovery = run_catalog_discovery(
        CatalogDiscoveryOptions(
            input_root=FIXTURE_ROOT,
            output_root=tmp_path / "catalog-discovery",
            created_at=CREATED_AT,
        )
    )
    return compile_catalog_candidate_review(
        CatalogCandidateReviewOptions(
            input_path=Path(discovery["outputRoot"]) / "candidate-sources.json",
            output_root=tmp_path / "candidate-review",
            created_at=CREATED_AT,
        )
    )


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
