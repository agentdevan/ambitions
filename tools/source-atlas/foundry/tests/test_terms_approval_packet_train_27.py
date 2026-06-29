from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.terms_approval_packet import build_terms_approval_packet, validate_terms_approval_packet
from foundry.terms_registry import policy_gate_for_output, terms_entry


CREATED_AT = "2026-06-28T00:00:00Z"


def test_terms_approval_packet_approves_bounded_internal_pack_use(tmp_path: Path):
    packet = build_terms_approval_packet(
        [terms_entry("onet.database"), terms_entry("bls.public.data.api")],
        output_path=tmp_path / "terms-approval.json",
        created_at=CREATED_AT,
    )

    assert (tmp_path / "terms-approval.json").exists()
    assert (tmp_path / "terms-approval.md").exists()
    assert packet["status"] == "Green"
    assert packet["outsideLegalApprovalClaimed"] is False
    assert "not outside legal approval" in packet["nonClaims"]

    validation = validate_terms_approval_packet(
        packet,
        terms_entry=terms_entry("onet.database"),
        requested_artifact_classes={"public_reference_claim"},
        now_date="2026-06-28",
    )

    assert validation["valid"], validation["issues"]
    assert validation["status"] == "Green"


def test_policy_gate_can_require_approval_packet_for_pack_output():
    onet_output = {
        "sourceID": "onet.database",
        "dataClass": "official_public_source",
        "claims": [{"dataClass": "public_reference_claim"}],
    }
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)

    missing_gate = policy_gate_for_output("onet.database", onet_output, require_approval_packet=True)
    assert not missing_gate["packable"]
    assert any("missing legal/terms approval packet" in issue for issue in missing_gate["issues"])

    approved_gate = policy_gate_for_output(
        "onet.database",
        onet_output,
        review_evidence=packet,
        require_approval_packet=True,
    )
    assert approved_gate["packable"], approved_gate["issues"]
    assert approved_gate["approvalPacketValidation"]["valid"]


def test_approval_packet_must_match_source():
    packet = build_terms_approval_packet([terms_entry("bls.public.data.api")], created_at=CREATED_AT)

    validation = validate_terms_approval_packet(
        packet,
        terms_entry=terms_entry("onet.database"),
        requested_artifact_classes={"public_reference_claim"},
        now_date="2026-06-28",
    )

    assert not validation["valid"]
    assert any("does not include source approval" in issue for issue in validation["issues"])


def test_approval_packet_must_allow_requested_artifact_class():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)

    validation = validate_terms_approval_packet(
        packet,
        terms_entry=terms_entry("onet.database"),
        requested_artifact_classes={"private_goal_graph"},
        now_date="2026-06-28",
    )

    assert not validation["valid"]
    assert any("does not allow artifact classes" in issue for issue in validation["issues"])


def test_private_looking_approval_metadata_is_rejected():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)
    packet["sourceApprovals"][0]["goalText"] = "I need this private goal packed."

    validation = validate_terms_approval_packet(
        packet,
        terms_entry=terms_entry("onet.database"),
        requested_artifact_classes={"public_reference_claim"},
        now_date="2026-06-28",
    )

    assert not validation["valid"]
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in validation["issues"])


def test_outside_legal_approval_claim_requires_artifact_and_hash():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)
    packet["outsideLegalApprovalClaimed"] = True
    packet["sourceApprovals"][0]["outsideLegalStatus"] = "approved"

    validation = validate_terms_approval_packet(
        packet,
        terms_entry=terms_entry("onet.database"),
        requested_artifact_classes={"public_reference_claim"},
        require_outside_legal=True,
        now_date="2026-06-28",
    )

    assert not validation["valid"]
    assert any("outside legal approval claimed without artifact" in issue for issue in validation["issues"])
    assert any("outside legal approval required but not proven" in issue for issue in validation["issues"])


def test_expired_approval_packet_is_rejected():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)

    validation = validate_terms_approval_packet(
        packet,
        terms_entry=terms_entry("onet.database"),
        requested_artifact_classes={"public_reference_claim"},
        now_date="2027-01-01",
    )

    assert not validation["valid"]
    assert any("approval packet expired" in issue for issue in validation["issues"])


def test_restricted_usajobs_packet_remains_blocked_from_pack_output():
    packet = build_terms_approval_packet([terms_entry("usajobs.search")], created_at=CREATED_AT)
    approval = packet["sourceApprovals"][0]

    assert packet["status"] == "Yellow"
    assert approval["reviewStatus"] == "blocked_from_pack_output"
    assert approval["packOutputAllowed"] is False

    validation = validate_terms_approval_packet(
        packet,
        terms_entry=terms_entry("usajobs.search"),
        requested_artifact_classes={"public_provenance"},
        now_date="2026-06-28",
    )

    assert not validation["valid"]
    assert any("does not allow pack output" in issue for issue in validation["issues"])
    assert any("blocks redistributable pack output" in issue for issue in validation["issues"])


def test_source_mismatched_policy_fields_are_rejected():
    packet = build_terms_approval_packet([terms_entry("onet.database")], created_at=CREATED_AT)
    mutated = copy.deepcopy(packet)
    mutated["sourceApprovals"][0]["termsURL"] = "https://example.com/wrong-terms"

    validation = validate_terms_approval_packet(
        mutated,
        terms_entry=terms_entry("onet.database"),
        requested_artifact_classes={"public_reference_claim"},
        now_date="2026-06-28",
    )

    assert not validation["valid"]
    assert any("termsURL does not match" in issue for issue in validation["issues"])
