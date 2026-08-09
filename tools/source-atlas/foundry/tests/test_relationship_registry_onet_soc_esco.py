from __future__ import annotations

import json
import sys
from copy import deepcopy
from pathlib import Path

import pytest
from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "tools/source-atlas"))

from foundry.relationship_registry_onet_esco import (  # noqa: E402
    ONETESCOAdapterError,
    adapt_onet_esco_document,
)
from foundry.relationship_registry_onet_soc import (  # noqa: E402
    ONETSOCAdapterError,
    adapt_onet_soc_document,
)


FIXTURES = ROOT / "tools/source-atlas/fixtures/relationship-registry"
ONET_SOC_FIXTURE = FIXTURES / "onet-soc-v1.json"
ONET_ESCO_FIXTURE = FIXTURES / "onet-esco-gated-v1.json"
EDGE_SCHEMA = (
    ROOT / "tools/source-atlas/foundry/contracts/relationship-edge-v1.schema.json"
)


def _load(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    assert isinstance(value, dict)
    return value


def _onet_soc_result(document: dict | None = None) -> dict:
    return adapt_onet_soc_document(document or _load(ONET_SOC_FIXTURE))


def _onet_esco_result(document: dict | None = None) -> dict:
    return adapt_onet_esco_document(document or _load(ONET_ESCO_FIXTURE))


def test_onet_soc_preserves_only_exact_explicit_granularity_without_siblings() -> None:
    result = _onet_soc_result()
    edges = result["edges"]

    assert [
        (edge["subject"]["conceptId"], edge["object"]["conceptId"]) for edge in edges
    ] == [
        ("15-1252.00", "15-1252"),
        ("15-1252.01", "15-1252"),
        ("15-1252.02", "15-1252"),
        ("29-1141.00", "29-1141"),
    ]

    one_explicit_sibling = _load(ONET_SOC_FIXTURE)
    one_explicit_sibling["rows"] = [
        row for row in one_explicit_sibling["rows"] if row["sourceRow"] == "onetsoc-002"
    ]
    one_edge = _onet_soc_result(one_explicit_sibling)["edges"]
    assert len(one_edge) == 1
    assert one_edge[0]["subject"]["conceptId"] == "15-1252.01"
    assert one_edge[0]["object"]["conceptId"] == "15-1252"


def test_onet_soc_edges_are_schema_valid_overlay_only_and_preserve_non_claims() -> None:
    schema = _load(EDGE_SCHEMA)
    validator = Draft202012Validator(
        schema,
        format_checker=Draft202012Validator.FORMAT_CHECKER,
    )
    for edge in _onet_soc_result()["edges"]:
        validator.validate(edge)
        assert edge["predicate"]["predicateId"] == (
            "ambitions:sourceTaxonomyRelationship"
        )
        assert edge["direction"] == "subject_to_object"
        assert edge["eligiblePurposes"] == [
            "inspection",
            "search_expansion",
            "source_overlay_join",
        ]
        assert edge["nonClaims"] == [
            "not identity across detailed, aggregate, or title-only records",
            "no sibling inheritance",
            "not the user's current job",
        ]
        assert "sibling_inheritance" in edge["forbiddenPropagation"]


@pytest.mark.parametrize(
    ("onet_code", "soc_code", "error"),
    [
        ("15-1252", "15-1252", "ONET_SOC_CODE_INVALID"),
        ("15-1252.01", "15-1250", "SOC_GRANULARITY_MISMATCH"),
        ("15-1252.01", "15-1252.01", "SOC_CODE_INVALID"),
        ("15-1252.001", "15-1252", "ONET_SOC_CODE_INVALID"),
    ],
)
def test_onet_soc_rejects_malformed_or_non_exact_granularity(
    onet_code: str,
    soc_code: str,
    error: str,
) -> None:
    document = _load(ONET_SOC_FIXTURE)
    document["rows"][0]["onetConcept"]["conceptId"] = onet_code
    document["rows"][0]["socConcept"]["conceptId"] = soc_code

    with pytest.raises(ONETSOCAdapterError, match=error):
        adapt_onet_soc_document(document)


def test_onet_soc_fails_closed_for_unknown_fields_releases_rights_and_private_data() -> (
    None
):
    unknown = _load(ONET_SOC_FIXTURE)
    unknown["rows"][0]["inheritSiblings"] = True
    with pytest.raises(ONETSOCAdapterError, match="UNKNOWN_FIELDS"):
        adapt_onet_soc_document(unknown)

    floating = _load(ONET_SOC_FIXTURE)
    floating["authority"]["subjectSchemeVersion"] = "latest"
    with pytest.raises(ONETSOCAdapterError, match="FLOATING_VERSION"):
        adapt_onet_soc_document(floating)

    wrong_release = _load(ONET_SOC_FIXTURE)
    wrong_release["authority"]["objectSchemeVersion"] = "2020"
    with pytest.raises(ONETSOCAdapterError, match="OBJECT_RELEASE_MISMATCH"):
        adapt_onet_soc_document(wrong_release)

    arbitrary_rights = _load(ONET_SOC_FIXTURE)
    arbitrary_rights["authority"]["rightsId"] = "arbitrary.synthetic.rights"
    with pytest.raises(ONETSOCAdapterError, match="SYNTHETIC_AUTHORITY_MISMATCH"):
        adapt_onet_soc_document(arbitrary_rights)

    private_canary = _load(ONET_SOC_FIXTURE)
    private_canary["rows"][0]["sourceSpecificFields"].append(
        {"name": "privateGoalId", "value": "private-canary"}
    )
    with pytest.raises(ONETSOCAdapterError, match="PRIVATE_BOUNDARY"):
        adapt_onet_soc_document(private_canary)


def test_onet_soc_output_is_deterministic_and_inspection_rights_do_not_enable_overlay() -> (
    None
):
    document = _load(ONET_SOC_FIXTURE)
    shuffled = deepcopy(document)
    shuffled["rows"] = list(reversed(shuffled["rows"]))
    assert _onet_soc_result(document) == _onet_soc_result(shuffled)

    inspection_only = _load(ONET_SOC_FIXTURE)
    inspection_only["authority"]["rightsState"] = "inspection_only"
    assert all(
        edge["eligiblePurposes"] == ["inspection"]
        for edge in _onet_soc_result(inspection_only)["edges"]
    )
    assert _onet_soc_result()["productionAdmission"] == {
        "sourceId": "onet-soc-2019-soc-2018-crosswalk",
        "state": "unavailable",
        "reason": "blocked_pending_exact_bytes_hash_schema_and_rights",
    }


def test_onet_esco_preserves_predicates_and_qa_but_emits_no_consumer_edges() -> None:
    result = _onet_esco_result()
    mappings = {item["predicateId"]: item for item in result["mappings"]}

    assert set(mappings) == {
        "skos:exactMatch",
        "skos:closeMatch",
        "skos:broadMatch",
        "skos:narrowMatch",
        "skos:relatedMatch",
    }
    assert "edges" not in result
    assert result["availability"] == {
        "state": "unavailable",
        "profileId": "onet-esco-blocked-v1",
        "profileRevision": "1.0.0",
        "exactEndpointReleasesPassed": False,
        "mappingBytesPassed": False,
        "rightsPassed": False,
        "reason": (
            "blocked_pending_exact_endpoint_releases_mapping_bytes_hash_qa_and_rights"
        ),
    }
    assert all(
        item["eligiblePurposes"] == ["unavailable"] for item in mappings.values()
    )
    assert all(item["reviewState"] == "restricted" for item in mappings.values())
    assert mappings["skos:relatedMatch"]["qaPartition"] == "lower_qa_related"
    assert all(
        item["qaPartition"] == "human_validated"
        for predicate, item in mappings.items()
        if predicate != "skos:relatedMatch"
    )
    assert "related-match lower-QA rows remain restricted" in result["nonClaims"]


@pytest.mark.parametrize(
    ("predicate", "qa_partition"),
    [
        ("skos:relatedMatch", "human_validated"),
        ("skos:exactMatch", "lower_qa_related"),
        ("skos:unknownMatch", "human_validated"),
    ],
)
def test_onet_esco_predicate_and_qa_mismatches_fail_closed(
    predicate: str,
    qa_partition: str,
) -> None:
    document = _load(ONET_ESCO_FIXTURE)
    document["rows"][0]["predicateId"] = predicate
    document["rows"][0]["qaPartition"] = qa_partition
    with pytest.raises(ONETESCOAdapterError):
        adapt_onet_esco_document(document)


def test_onet_esco_rights_release_unknown_and_private_mismatches_fail_closed() -> None:
    approved_without_production_evidence = _load(ONET_ESCO_FIXTURE)
    approved_without_production_evidence["authority"]["rightsState"] = "approved"
    with pytest.raises(ONETESCOAdapterError, match="SYNTHETIC_AUTHORITY_MISMATCH"):
        adapt_onet_esco_document(approved_without_production_evidence)

    floating = _load(ONET_ESCO_FIXTURE)
    floating["authority"]["objectSchemeVersion"] = "current"
    with pytest.raises(ONETESCOAdapterError, match="FLOATING_VERSION"):
        adapt_onet_esco_document(floating)

    mismatched_release = _load(ONET_ESCO_FIXTURE)
    mismatched_release["authority"]["objectSchemeVersion"] = "fixture-esco-1.2"
    with pytest.raises(ONETESCOAdapterError, match="OBJECT_RELEASE_MISMATCH"):
        adapt_onet_esco_document(mismatched_release)

    unknown = _load(ONET_ESCO_FIXTURE)
    unknown["rows"][0]["acceptedForQualification"] = True
    with pytest.raises(ONETESCOAdapterError, match="UNKNOWN_FIELDS"):
        adapt_onet_esco_document(unknown)

    private_canary = _load(ONET_ESCO_FIXTURE)
    private_canary["rows"][0]["sourceSpecificFields"].append(
        {"name": "privateGoalId", "value": "private-canary"}
    )
    with pytest.raises(ONETESCOAdapterError, match="PRIVATE_BOUNDARY"):
        adapt_onet_esco_document(private_canary)


def test_onet_esco_output_is_deterministic_synthetic_and_production_blocked() -> None:
    document = _load(ONET_ESCO_FIXTURE)
    shuffled = deepcopy(document)
    shuffled["rows"] = list(reversed(shuffled["rows"]))

    assert _onet_esco_result(document) == _onet_esco_result(shuffled)
    result = _onet_esco_result(document)
    assert result["fixtureClass"] == "synthetic_contract"
    assert result["authority"]["mappingSetId"].endswith("synthetic-reservation")
    assert all(
        mapping[endpoint]["locator"] is None
        for mapping in result["mappings"]
        for endpoint in ("subject", "object")
    )
    assert result["productionAdmission"] == {
        "sourceId": "official-onet-esco-crosswalk",
        "state": "unavailable",
        "reason": (
            "blocked_pending_exact_endpoint_releases_mapping_bytes_hash_qa_and_rights"
        ),
    }
