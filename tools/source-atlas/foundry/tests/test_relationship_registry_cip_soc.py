from __future__ import annotations

import json
import sys
from copy import deepcopy
from pathlib import Path

import pytest
from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "tools/source-atlas"))

from foundry.relationship_registry_cip_soc import (  # noqa: E402
    CIPSOCAdapterError,
    adapt_cip_soc_document,
)


FIXTURE = ROOT / "tools/source-atlas/fixtures/relationship-registry/cip-soc-v1.json"
EDGE_SCHEMA = (
    ROOT / "tools/source-atlas/foundry/contracts/relationship-edge-v1.schema.json"
)


def _load(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    assert isinstance(value, dict)
    return value


def _result(document: dict | None = None) -> dict:
    return adapt_cip_soc_document(document or _load(FIXTURE))


def test_cip_soc_preserves_exact_many_to_many_source_relevance() -> None:
    result = _result()
    edges = result["edges"]

    assert len(edges) == 4
    assert {
        (edge["subject"]["conceptId"], edge["object"]["conceptId"]) for edge in edges
    } == {
        ("11.0101", "15-1252"),
        ("11.0101", "15-1299"),
        ("11.0701", "15-1252"),
        ("30.7101", "15-1299"),
    }
    assert (
        len([edge for edge in edges if edge["subject"]["conceptId"] == "11.0101"]) == 2
    )
    assert (
        len([edge for edge in edges if edge["object"]["conceptId"] == "15-1252"]) == 2
    )
    assert not any(edge["subject"]["conceptId"] == "11.01" for edge in edges)
    assert not any(edge["object"]["conceptId"] == "15-1250" for edge in edges)
    assert not any(edge["review"]["state"] == "explicit_no_match" for edge in edges)


def test_cip_soc_edges_are_schema_valid_directional_and_preserve_non_claims() -> None:
    schema = _load(EDGE_SCHEMA)
    validator = Draft202012Validator(
        schema,
        format_checker=Draft202012Validator.FORMAT_CHECKER,
    )
    for edge in _result()["edges"]:
        validator.validate(edge)
        assert edge["predicate"]["predicateId"] == (
            "ambitions:educationOccupationRelevance"
        )
        assert edge["direction"] == "subject_to_object"
        assert edge["eligiblePurposes"] == [
            "inspection",
            "search_expansion",
            "destination_discovery",
            "explanation",
        ]
        assert edge["nonClaims"] == [
            "not a degree requirement",
            "not qualification",
            "not licensure",
            "not employment",
            "not a unique route",
            "not an individual outcome",
        ]
        encoded = json.dumps(edge, sort_keys=True).lower()
        assert '"equivalent"' not in encoded
        assert '"qualified"' not in encoded


def test_cip_soc_adapter_rejects_unknown_fields_empty_targets_and_floating_versions() -> (
    None
):
    unknown = _load(FIXTURE)
    unknown["rows"][0]["degreeRequirement"] = True
    with pytest.raises(CIPSOCAdapterError, match="UNKNOWN_FIELDS"):
        adapt_cip_soc_document(unknown)

    empty = _load(FIXTURE)
    empty["rows"][0]["socConcepts"] = []
    with pytest.raises(CIPSOCAdapterError, match="SOC_TARGETS_REQUIRED"):
        adapt_cip_soc_document(empty)

    floating = _load(FIXTURE)
    floating["authority"]["subjectSchemeVersion"] = "current"
    with pytest.raises(CIPSOCAdapterError, match="FLOATING_VERSION"):
        adapt_cip_soc_document(floating)

    duplicate = _load(FIXTURE)
    duplicate["rows"][0]["socConcepts"].append(duplicate["rows"][0]["socConcepts"][0])
    with pytest.raises(CIPSOCAdapterError, match="DUPLICATE_SOC_TARGET"):
        adapt_cip_soc_document(duplicate)

    invalid_rights = _load(FIXTURE)
    invalid_rights["authority"]["rightsState"] = "review_required"
    with pytest.raises(CIPSOCAdapterError, match="RIGHTS_STATE_NOT_ALLOWED"):
        adapt_cip_soc_document(invalid_rights)

    arbitrary_rights = _load(FIXTURE)
    arbitrary_rights["authority"]["rightsId"] = "arbitrary.synthetic.rights"
    with pytest.raises(CIPSOCAdapterError, match="SYNTHETIC_AUTHORITY_MISMATCH"):
        adapt_cip_soc_document(arbitrary_rights)

    private_canary = _load(FIXTURE)
    private_canary["rows"][0]["privateGoalId"] = "private-goal-canary"
    with pytest.raises(CIPSOCAdapterError, match="PRIVATE_BOUNDARY"):
        adapt_cip_soc_document(private_canary)

    nested_private_canary = _load(FIXTURE)
    nested_private_canary["rows"][0]["sourceSpecificFields"].append(
        {"name": "privateGoalId", "value": "private-goal-canary"}
    )
    with pytest.raises(CIPSOCAdapterError, match="PRIVATE_BOUNDARY"):
        adapt_cip_soc_document(nested_private_canary)


def test_cip_soc_output_is_deterministic_and_preserves_rows_without_inferred_inverse() -> (
    None
):
    document = _load(FIXTURE)
    shuffled = deepcopy(document)
    shuffled["rows"] = list(reversed(shuffled["rows"]))

    assert _result(document) == _result(shuffled)
    result = _result(document)
    first = next(
        edge
        for edge in result["edges"]
        if edge["sourceMetadata"]["sourceRow"] == "cipsoc-001"
        and edge["object"]["conceptId"] == "15-1252"
    )
    assert first["sourceMetadata"]["sourceSpecificFields"] == [
        {
            "name": "relationshipBasis",
            "value": "Synthetic source-description relevance",
        }
    ]
    assert all(edge["direction"] != "object_to_subject" for edge in result["edges"])
    assert result["productionAdmission"] == {
        "sourceId": "nces-bls-cip-2020-soc-2018-crosswalk",
        "state": "unavailable",
        "reason": "blocked_pending_exact_bytes_hash_schema_and_rights",
    }


def test_cip_soc_duplicate_pair_claims_coexist_without_deduplication_or_voting() -> (
    None
):
    document = _load(FIXTURE)
    document["rows"][1]["cipConcept"] = deepcopy(document["rows"][0]["cipConcept"])
    document["rows"][1]["socConcepts"] = [
        deepcopy(document["rows"][0]["socConcepts"][0])
    ]

    duplicate_claims = [
        edge
        for edge in _result(document)["edges"]
        if edge["subject"]["conceptId"] == "11.0101"
        and edge["object"]["conceptId"] == "15-1252"
    ]
    assert len(duplicate_claims) == 2
    assert len({edge["edgeId"] for edge in duplicate_claims}) == 2
    assert {edge["sourceMetadata"]["sourceRow"] for edge in duplicate_claims} == {
        "cipsoc-001",
        "cipsoc-002",
    }


def test_cip_soc_inspection_only_rights_cannot_enable_discovery_or_explanation() -> (
    None
):
    document = _load(FIXTURE)
    document["authority"]["rightsState"] = "inspection_only"

    assert all(
        edge["eligiblePurposes"] == ["inspection"]
        for edge in _result(document)["edges"]
    )
