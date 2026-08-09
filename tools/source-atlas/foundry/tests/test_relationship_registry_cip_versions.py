from __future__ import annotations

import json
import sys
from copy import deepcopy
from pathlib import Path

import pytest
from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "tools/source-atlas"))

from foundry.relationship_registry_cip_versions import (  # noqa: E402
    CIPVersionAdapterError,
    adapt_cip_version_document,
)
from foundry import relationship_registry_models  # noqa: E402
from foundry.relationship_registry_models import controlled_profile  # noqa: E402


FIXTURE = (
    ROOT
    / "tools/source-atlas/fixtures/relationship-registry/cip-version-actions-v1.json"
)
EDGE_SCHEMA = (
    ROOT / "tools/source-atlas/foundry/contracts/relationship-edge-v1.schema.json"
)


def _load(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    assert isinstance(value, dict)
    return value


def _result(document: dict | None = None) -> dict:
    return adapt_cip_version_document(document or _load(FIXTURE))


def test_all_cip_version_actions_survive_with_exact_cardinality_and_disposition() -> (
    None
):
    result = _result()
    actions = {item["sourceRow"]: item for item in result["actions"]}

    assert [item["sourceAction"] for item in result["actions"]] == [
        "deleted",
        "merge",
        "moved from",
        "moved to",
        "new",
        "report under",
        "split",
        "text changed",
        "unchanged",
    ]
    assert actions["cipv-moved-to"]["migrationDisposition"] == (
        "deterministic_candidate"
    )
    assert actions["cipv-unchanged"]["migrationDisposition"] == (
        "deterministic_candidate"
    )
    assert actions["cipv-new"]["migrationDisposition"] == "no_predecessor"
    assert actions["cipv-deleted"]["migrationDisposition"] == "no_target"
    for source_row in (
        "cipv-merge",
        "cipv-moved-from",
        "cipv-report-under",
        "cipv-split",
        "cipv-text-changed",
    ):
        assert actions[source_row]["migrationDisposition"] == "review_required"

    assert len(actions["cipv-split"]["fromConcepts"]) == 1
    assert len(actions["cipv-split"]["toConcepts"]) == 2
    assert len(actions["cipv-merge"]["fromConcepts"]) == 2
    assert len(actions["cipv-merge"]["toConcepts"]) == 1
    assert actions["cipv-new"]["fromConcepts"] == []
    assert actions["cipv-deleted"]["toConcepts"] == []
    assert actions["cipv-deleted"]["fromConcepts"][0]["lifecycleState"] == ("deleted")
    assert (
        actions["cipv-text-changed"]["fromConcepts"][0]["lifecycleState"] == "changed"
    )
    assert actions["cipv-split"]["fromConcepts"][0]["lifecycleState"] == "split"
    assert all(
        concept["lifecycleState"] == "merged"
        for concept in actions["cipv-merge"]["fromConcepts"]
    )


def test_cip_version_edges_are_schema_valid_and_ambiguous_actions_are_inspection_only() -> (
    None
):
    result = _result()
    schema = _load(EDGE_SCHEMA)
    validator = Draft202012Validator(
        schema,
        format_checker=Draft202012Validator.FORMAT_CHECKER,
    )
    edges_by_row: dict[str, list[dict]] = {}
    for edge in result["edges"]:
        validator.validate(edge)
        edges_by_row.setdefault(edge["sourceMetadata"]["sourceRow"], []).append(edge)
        assert edge["nonClaims"] == [
            "not generic identity",
            "not program availability",
            "not competency",
            "not credit",
        ]

    assert {edge["predicate"]["predicateId"] for edge in result["edges"]} == {
        "cip:merge",
        "cip:movedFrom",
        "cip:movedTo",
        "cip:reportUnder",
        "cip:split",
        "cip:textChanged",
        "cip:unchanged",
    }
    assert all(
        edge["eligiblePurposes"] == ["inspection"]
        for source_row in (
            "cipv-merge",
            "cipv-moved-from",
            "cipv-report-under",
            "cipv-split",
            "cipv-text-changed",
        )
        for edge in edges_by_row[source_row]
    )
    assert edges_by_row["cipv-moved-to"][0]["eligiblePurposes"] == [
        "inspection",
        "version_migration",
    ]
    assert edges_by_row["cipv-unchanged"][0]["eligiblePurposes"] == [
        "inspection",
        "version_migration",
    ]
    assert "cipv-new" not in edges_by_row
    assert "cipv-deleted" not in edges_by_row
    assert {
        edge["subject"]["lifecycleState"] for edge in edges_by_row["cipv-text-changed"]
    } == {"changed"}
    assert {
        edge["subject"]["lifecycleState"] for edge in edges_by_row["cipv-split"]
    } == {"split"}
    assert {
        edge["subject"]["lifecycleState"] for edge in edges_by_row["cipv-merge"]
    } == {"merged"}
    assert all(
        edge["object"]["lifecycleState"] == "current_for_mapping"
        for edge in result["edges"]
    )
    allowed_endpoint_states = set(
        controlled_profile("cip-edition-migration-v1")["requiredEndpointStates"]
    )
    assert all(
        edge[endpoint]["lifecycleState"] in allowed_endpoint_states
        for edge in result["edges"]
        for endpoint in ("subject", "object")
    )


@pytest.mark.parametrize(
    ("source_row", "mutation"),
    [
        (
            "cipv-unchanged",
            lambda row: row["toConcepts"].append(
                {"conceptId": "01.0001", "label": None, "locator": None}
            ),
        ),
        ("cipv-new", lambda row: row["fromConcepts"].append(row["toConcepts"][0])),
        ("cipv-deleted", lambda row: row["toConcepts"].append(row["fromConcepts"][0])),
        (
            "cipv-split",
            lambda row: row.__setitem__("toConcepts", row["toConcepts"][:1]),
        ),
        (
            "cipv-merge",
            lambda row: row.__setitem__("fromConcepts", row["fromConcepts"][:1]),
        ),
    ],
)
def test_cip_version_action_cardinality_fails_closed(
    source_row: str,
    mutation,
) -> None:
    document = _load(FIXTURE)
    row = next(item for item in document["rows"] if item["sourceRow"] == source_row)
    mutation(row)

    with pytest.raises(CIPVersionAdapterError, match="CARDINALITY"):
        adapt_cip_version_document(document)


def test_cip_version_report_under_preserves_one_to_many_review_paths() -> None:
    report_edges = [
        edge
        for edge in _result()["edges"]
        if edge["sourceMetadata"]["sourceRow"] == "cipv-report-under"
    ]

    assert [edge["object"]["conceptId"] for edge in report_edges] == [
        "07.0001",
        "07.0002",
    ]
    assert all(edge["eligiblePurposes"] == ["inspection"] for edge in report_edges)


def test_cip_version_adapter_rejects_unknown_actions_fields_and_floating_authority() -> (
    None
):
    unknown_action = _load(FIXTURE)
    unknown_action["rows"][0]["action"] = "approximately equivalent"
    with pytest.raises(CIPVersionAdapterError, match="UNKNOWN_ACTION"):
        adapt_cip_version_document(unknown_action)

    case_normalized_guess = _load(FIXTURE)
    case_normalized_guess["rows"][0]["action"] = "Unchanged"
    with pytest.raises(CIPVersionAdapterError, match="UNKNOWN_ACTION"):
        adapt_cip_version_document(case_normalized_guess)

    non_string_action = _load(FIXTURE)
    non_string_action["rows"][0]["action"] = {"value": "unchanged"}
    with pytest.raises(CIPVersionAdapterError, match="UNKNOWN_ACTION"):
        adapt_cip_version_document(non_string_action)

    unknown_field = _load(FIXTURE)
    unknown_field["rows"][0]["qualification"] = True
    with pytest.raises(CIPVersionAdapterError, match="UNKNOWN_FIELDS"):
        adapt_cip_version_document(unknown_field)

    floating = _load(FIXTURE)
    floating["authority"]["objectSchemeVersion"] = "latest"
    with pytest.raises(CIPVersionAdapterError, match="FLOATING_VERSION"):
        adapt_cip_version_document(floating)

    production_spoof = _load(FIXTURE)
    production_spoof["authority"]["mappingSetId"] = "nces.cip-2010-2020"
    with pytest.raises(CIPVersionAdapterError, match="SYNTHETIC_AUTHORITY_MISMATCH"):
        adapt_cip_version_document(production_spoof)

    arbitrary_rights = _load(FIXTURE)
    arbitrary_rights["authority"]["rightsId"] = "arbitrary.synthetic.rights"
    with pytest.raises(CIPVersionAdapterError, match="SYNTHETIC_AUTHORITY_MISMATCH"):
        adapt_cip_version_document(arbitrary_rights)

    duplicate_row = _load(FIXTURE)
    duplicate_row["rows"][1]["sourceRow"] = duplicate_row["rows"][0]["sourceRow"]
    with pytest.raises(CIPVersionAdapterError, match="DUPLICATE_SOURCE_ROW"):
        adapt_cip_version_document(duplicate_row)


def test_cip_version_output_is_deterministic_and_preserves_source_specific_fields() -> (
    None
):
    document = _load(FIXTURE)
    shuffled = deepcopy(document)
    shuffled["rows"] = list(reversed(shuffled["rows"]))

    assert _result(document) == _result(shuffled)
    moved = next(
        edge
        for edge in _result(document)["edges"]
        if edge["sourceMetadata"]["sourceRow"] == "cipv-moved-to"
    )
    assert moved["subject"]["label"] == "Synthetic legacy program"
    assert moved["object"]["label"] == "Synthetic current program"
    assert moved["sourceMetadata"]["sourceSpecificFields"] == [
        {"name": "publisherNote", "value": "Synthetic moved-to fixture"}
    ]
    assert _result(document)["productionAdmission"] == {
        "sourceId": "nces-cip-2010-2020-crosswalk",
        "state": "unavailable",
        "reason": "blocked_pending_exact_bytes_hash_schema_and_rights",
    }


def test_cip_version_edge_identity_ignores_inspection_only_labels_and_locators() -> (
    None
):
    original = _result()
    changed = _load(FIXTURE)
    changed["rows"][0]["fromConcepts"][0]["label"] = "Revised source label"
    changed["rows"][0]["fromConcepts"][0]["locator"] = (
        "https://example.invalid/cip/source"
    )
    changed["rows"][0]["toConcepts"][0]["label"] = "Revised target label"
    changed["rows"][0]["toConcepts"][0]["locator"] = (
        "https://example.invalid/cip/target"
    )

    original_edge = next(
        edge
        for edge in original["edges"]
        if edge["sourceMetadata"]["sourceRow"] == "cipv-unchanged"
    )
    changed_edge = next(
        edge
        for edge in _result(changed)["edges"]
        if edge["sourceMetadata"]["sourceRow"] == "cipv-unchanged"
    )
    assert changed_edge["edgeId"] == original_edge["edgeId"]
    assert changed_edge["subject"]["label"] == "Revised source label"
    assert changed_edge["object"]["label"] == "Revised target label"


def test_cip_version_inspection_only_rights_cannot_enable_migration() -> None:
    document = _load(FIXTURE)
    document["authority"]["rightsState"] = "inspection_only"

    assert all(
        edge["eligiblePurposes"] == ["inspection"]
        for edge in _result(document)["edges"]
    )
    assert all(
        action["eligiblePurposes"] == ["inspection"]
        for action in _result(document)["actions"]
    )


def test_cip_version_unary_only_fixture_still_rejects_unapproved_rights() -> None:
    document = _load(FIXTURE)
    document["rows"] = [
        row for row in document["rows"] if row["action"] in {"new", "deleted"}
    ]
    document["authority"]["rightsState"] = "review_required"

    with pytest.raises(CIPVersionAdapterError, match="RIGHTS_STATE_NOT_ALLOWED"):
        adapt_cip_version_document(document)


def test_edge_builder_enforces_bound_profile_endpoint_states(monkeypatch) -> None:
    controlled = controlled_profile("cip-edition-migration-v1")
    current_only = {**controlled, "requiredEndpointStates": ["current_for_mapping"]}

    monkeypatch.setattr(
        relationship_registry_models,
        "controlled_profile",
        lambda profile_id: current_only,
    )

    with pytest.raises(
        relationship_registry_models.RelationshipAdapterError,
        match="ENDPOINT_STATE_NOT_ALLOWED:cip-edition-migration-v1:subject:changed",
    ):
        _result()


def test_edge_builder_enforces_predicate_specific_endpoint_states() -> None:
    document = _load(FIXTURE)
    original = next(
        edge
        for edge in _result(document)["edges"]
        if edge["sourceMetadata"]["sourceRow"] == "cipv-unchanged"
    )
    authority = relationship_registry_models.parse_authority(
        document["authority"],
        expected_subject=("cip", "2010"),
        expected_object=("cip", "2020"),
        error_type=CIPVersionAdapterError,
    )

    with pytest.raises(
        relationship_registry_models.RelationshipAdapterError,
        match=(
            "PREDICATE_ENDPOINT_STATE_MISMATCH:cip-edition-migration-v1:"
            "cip:unchanged:subject:changed"
        ),
    ):
        relationship_registry_models.build_edge(
            authority=authority,
            profile_id="cip-edition-migration-v1",
            predicate_id="cip:unchanged",
            source_row="adversarial-endpoint-state",
            subject={**original["subject"], "lifecycleState": "changed"},
            object_=original["object"],
            source_fields=[],
        )
