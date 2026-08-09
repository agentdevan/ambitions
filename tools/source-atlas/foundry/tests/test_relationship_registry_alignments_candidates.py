from __future__ import annotations

import json
import sys
from copy import deepcopy
from pathlib import Path

import pytest
from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "tools/source-atlas"))

from foundry.relationship_registry_candidates import (  # noqa: E402
    RelationshipCandidateAdapterError,
    _candidate_edge_id,
    adapt_candidate_document,
)
from foundry.relationship_registry_publisher_alignments import (  # noqa: E402
    PublisherAlignmentAdapterError,
    adapt_publisher_alignment_document,
)

FIXTURES = ROOT / "tools/source-atlas/fixtures/relationship-registry"
ALIGNMENTS_FIXTURE = FIXTURES / "publisher-alignments-v1.json"
CANDIDATES_FIXTURE = FIXTURES / "mapping-candidates-v1.json"
EDGE_SCHEMA = (
    ROOT / "tools/source-atlas/foundry/contracts/relationship-edge-v1.schema.json"
)
PRIVATE_SOURCE_FIELD_CANARIES = (
    "userId",
    "privateGoalId",
    "deviceLocation",
    "capabilityId",
    "educationHistoryId",
    "recommendationId",
)


def _load(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    assert isinstance(value, dict)
    return value


def _alignment_result(document: dict | None = None) -> dict:
    return adapt_publisher_alignment_document(document or _load(ALIGNMENTS_FIXTURE))


def _candidate_result(document: dict | None = None) -> dict:
    return adapt_candidate_document(document or _load(CANDIDATES_FIXTURE))


def test_ctdl_and_case_rows_preserve_source_predicate_and_publisher_authority() -> None:
    result = _alignment_result()
    alignments = {item["alignmentStandard"]: item for item in result["alignments"]}

    assert set(alignments) == {"ctdl", "case"}
    assert alignments["ctdl"]["predicateId"] == "ctdl:alignment"
    assert alignments["case"]["predicateId"] == "case:association"
    assert alignments["ctdl"]["sourceAuthority"] == {
        "publisherId": "synthetic.publisher.provider-alpha",
        "publisherName": "Synthetic Provider Alpha",
    }
    assert alignments["case"]["sourceAuthority"] == {
        "publisherId": "synthetic.publisher.framework-beta",
        "publisherName": "Synthetic Framework Beta",
    }
    assert alignments["ctdl"]["mappingSet"]["objectSchemeId"] == "ctdl-framework"
    assert alignments["case"]["mappingSet"]["objectSchemeId"] == "case-framework"
    assert all(item["direction"] == "subject_to_object" for item in alignments.values())


def test_publisher_source_state_and_ambitions_review_state_are_distinct_and_blocked() -> (
    None
):
    result = _alignment_result()

    assert "edges" not in result
    assert result["availability"] == {
        "state": "unavailable",
        "profileId": "publisher-alignment-blocked-v1",
        "profileRevision": "1.0.0",
        "publisherSourceVersionPassed": False,
        "rightsPassed": False,
        "reason": "blocked_pending_publisher_specific_source_version_and_rights",
    }
    assert result["productionAdmission"] == {
        "sourceId": "publisher-ctdl-case-alignments",
        "state": "unavailable",
        "reason": "blocked_pending_publisher_specific_source_version_and_rights",
    }
    for alignment in result["alignments"]:
        assert alignment["sourceState"] == "publisher_claim"
        assert alignment["reviewState"] == "restricted"
        assert alignment["eligiblePurposes"] == ["unavailable"]
        assert alignment["sourceState"] != alignment["reviewState"]
    assert "not independent verification" in result["nonClaims"]
    assert "not mastery" in result["nonClaims"]
    assert "qualification" in result["forbiddenPropagation"]
    assert "user_capability" in result["forbiddenPropagation"]


def test_publisher_alignment_output_is_deterministic_and_preserves_source_fields() -> (
    None
):
    document = _load(ALIGNMENTS_FIXTURE)
    shuffled = deepcopy(document)
    shuffled["rows"] = list(reversed(shuffled["rows"]))

    assert _alignment_result(document) == _alignment_result(shuffled)
    ctdl = next(
        item
        for item in _alignment_result(document)["alignments"]
        if item["alignmentStandard"] == "ctdl"
    )
    assert ctdl["sourceSpecificFields"] == [
        {"name": "alignmentType", "value": "synthetic-target-node"},
        {"name": "alignmentWeight", "value": 0.75},
    ]
    assert ctdl["subject"]["label"] == "Synthetic learning opportunity"
    assert ctdl["object"]["label"] == "Synthetic CTDL framework node"


def test_publisher_mapping_set_preserves_multiple_explicit_rows() -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    second_ctdl_row = deepcopy(document["rows"][0])
    second_ctdl_row["sourceRow"] = "publisher-ctdl-002"
    second_ctdl_row["subjectConcept"]["conceptId"] = (
        "synthetic-learning-opportunity-002"
    )
    second_ctdl_row["objectConcept"]["conceptId"] = "synthetic-ctdl-node-002"
    document["rows"].append(second_ctdl_row)

    ctdl_rows = [
        item
        for item in _alignment_result(document)["alignments"]
        if item["alignmentStandard"] == "ctdl"
    ]
    assert [item["sourceRow"] for item in ctdl_rows] == [
        "publisher-ctdl-001",
        "publisher-ctdl-002",
    ]


def test_publisher_source_fields_are_deterministic_when_input_order_changes() -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    reordered = deepcopy(document)
    for row in reordered["rows"]:
        row["sourceSpecificFields"] = list(reversed(row["sourceSpecificFields"]))

    assert _alignment_result(document) == _alignment_result(reordered)


@pytest.mark.parametrize(
    "payload",
    [
        "quali\u0456fies the learner for the role",
        "right to practice in this jurisdiction",
        "may practice in this jurisdiction",
        "certified to practice in this jurisdiction",
        "recognized by the receiving authority",
    ],
)
def test_publisher_source_field_schema_rejects_reviewer_prose_bypasses(
    payload: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": "statusNote", "value": payload}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError, match="SOURCE_FIELDS_NOT_ALLOWED"
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    "field_name",
    ["statusNote", "accreditationcredits", "accreditorcredit"],
)
def test_publisher_source_field_schema_rejects_unexpected_names(
    field_name: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": field_name, "value": "synthetic public value"}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError, match="SOURCE_FIELDS_NOT_ALLOWED"
    ):
        adapt_publisher_alignment_document(document)


def test_publisher_source_field_schema_rejects_duplicate_and_missing_fields() -> None:
    duplicate = _load(ALIGNMENTS_FIXTURE)
    duplicate["rows"][0]["sourceSpecificFields"].append(
        deepcopy(duplicate["rows"][0]["sourceSpecificFields"][0])
    )
    with pytest.raises(
        PublisherAlignmentAdapterError, match="SOURCE_FIELD_NAME_INVALID"
    ):
        adapt_publisher_alignment_document(duplicate)

    missing = _load(ALIGNMENTS_FIXTURE)
    missing["rows"][0]["sourceSpecificFields"].pop()
    with pytest.raises(
        PublisherAlignmentAdapterError, match="SOURCE_FIELDS_NOT_ALLOWED"
    ):
        adapt_publisher_alignment_document(missing)


@pytest.mark.parametrize(
    ("row_index", "field_name", "invalid_value"),
    [
        (0, "alignmentType", "accepted-for-qualification"),
        (0, "alignmentType", "x" * 129),
        (0, "alignmentWeight", True),
        (0, "alignmentWeight", "0.75"),
        (0, "alignmentWeight", -0.01),
        (0, "alignmentWeight", 1.01),
        (1, "associationType", "recognized-by-authority"),
        (1, "sequenceNumber", True),
        (1, "sequenceNumber", 1.5),
        (1, "sequenceNumber", 0),
        (1, "sequenceNumber", 2_147_483_648),
    ],
)
def test_publisher_source_field_schema_rejects_invalid_bounded_values(
    row_index: int,
    field_name: str,
    invalid_value,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    field = next(
        item
        for item in document["rows"][row_index]["sourceSpecificFields"]
        if item["name"] == field_name
    )
    field["value"] = invalid_value

    with pytest.raises(
        PublisherAlignmentAdapterError, match="SOURCE_FIELD_VALUE_NOT_ALLOWED"
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    ("mutation", "error"),
    [
        (
            lambda document: document["rows"][0].__setitem__(
                "predicateId", "skos:exactMatch"
            ),
            "PREDICATE_STANDARD_MISMATCH",
        ),
        (
            lambda document: document["rows"][0].__setitem__(
                "predicateId", "unknown:alignment"
            ),
            "PREDICATE_STANDARD_MISMATCH",
        ),
        (
            lambda document: document["rows"][0].__setitem__(
                "alignmentStandard", "unknown"
            ),
            "UNKNOWN_ALIGNMENT_STANDARD",
        ),
        (
            lambda document: document["rows"][0].__setitem__(
                "sourceState", "source_published"
            ),
            "SOURCE_STATE_NOT_ALLOWED",
        ),
        (
            lambda document: document["rows"][0].__setitem__("reviewState", "approved"),
            "REVIEW_STATE_NOT_ALLOWED",
        ),
        (
            lambda document: document["rows"][0]["authority"].__setitem__(
                "objectSchemeVersion", "latest"
            ),
            "FLOATING_VERSION",
        ),
        (
            lambda document: document["rows"][0]["authority"].__setitem__(
                "rightsState", "approved"
            ),
            "SYNTHETIC_AUTHORITY_MISMATCH",
        ),
        (
            lambda document: document["rows"][0].__setitem__(
                "acceptedForQualification", True
            ),
            "UNKNOWN_FIELDS",
        ),
        (
            lambda document: document["rows"][0]["sourceSpecificFields"].append(
                {"name": "acceptedForQualification", "value": True}
            ),
            "SOURCE_FIELDS_NOT_ALLOWED",
        ),
    ],
)
def test_publisher_alignments_fail_closed_for_unknown_authority_and_state(
    mutation,
    error: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    mutation(document)

    with pytest.raises(PublisherAlignmentAdapterError, match=error):
        adapt_publisher_alignment_document(document)


def test_publisher_alignments_reject_claim_authority_in_neutral_field_values() -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": "statusNote", "value": "accepted for qualification and credit"}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError,
        match="SOURCE_FIELDS_NOT_ALLOWED.*statusNote",
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    ("field_name", "field_value"),
    [
        ("statusNote", "accepts this alignment and qualifies"),
        ("review_status", "mastered outcomes and is capable"),
        ("publisher-note", "licensed through synthetic licensure"),
    ],
)
def test_publisher_alignments_reject_semantic_authority_bypass_phrases(
    field_name: str,
    field_value: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": field_name, "value": field_value}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError,
        match="SOURCE_FIELDS_NOT_ALLOWED",
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    "field_value",
    [
        "acceptable for transfer",
        "authority licenses this use",
        "mastering outcomes",
    ],
)
def test_publisher_alignments_reject_reviewer_authority_value_cases(
    field_value: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": "statusNote", "value": field_value}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError,
        match="SOURCE_FIELDS_NOT_ALLOWED",
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    "field_value",
    [
        "approved by the receiving authority",
        "eligible to practice in this jurisdiction",
        "quali\u200bfies the learner for the role",
        "appro\u2060ved by the receiving authority",
        "elig\u0301ible to practice in this jurisdiction",
        "authority licen\x00ses this use",
        "authority to practice",
        "authorized to practice in this jurisdiction",
    ],
)
def test_publisher_alignments_reject_obfuscated_authority_value_claims(
    field_value: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": "statusNote", "value": field_value}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError,
        match="SOURCE_FIELDS_NOT_ALLOWED",
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    "field_value",
    [
        "best practice guidance for this jurisdiction",
        "synthetic practical skills exercise",
        "approximate public alignment",
    ],
)
def test_publisher_closed_schema_rejects_unexpected_near_miss_prose(
    field_value: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": "sourceNote", "value": field_value}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError, match="SOURCE_FIELDS_NOT_ALLOWED"
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    "field_name",
    ["acceptanceStatus", "qualification_status", "credit-status"],
)
def test_publisher_alignments_reject_semantic_authority_field_name_tokens(
    field_name: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": field_name, "value": "synthetic public note"}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError,
        match="SOURCE_FIELDS_NOT_ALLOWED",
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    "field_name",
    [
        "qualificationstatus",
        "sourceacceptancestatus",
        "publishercreditstatus",
        "statuscapabilitynote",
        "sourceequivalencestatus",
        "sourceequatingstatus",
    ],
)
def test_publisher_alignments_reject_concatenated_authority_field_names(
    field_name: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": field_name, "value": "synthetic public note"}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError,
        match="SOURCE_FIELDS_NOT_ALLOWED",
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    "semantic_form",
    [
        "accept",
        "accepts",
        "accepted",
        "accepting",
        "acceptance",
        "qualify",
        "qualifies",
        "qualified",
        "qualifying",
        "qualification",
        "qualifications",
        "credit",
        "credits",
        "credited",
        "crediting",
        "mastery",
        "mastered",
        "capability",
        "capabilities",
        "capable",
        "equivalent",
        "equivalents",
        "equivalence",
        "equivalences",
        "equate",
        "equates",
        "equated",
        "equating",
        "license",
        "licensed",
        "licensing",
        "licensure",
    ],
)
def test_publisher_alignments_reject_each_semantic_authority_form(
    semantic_form: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": "statusNote", "value": f"synthetic {semantic_form} statement"}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError,
        match="SOURCE_FIELDS_NOT_ALLOWED",
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize("word", ["accredited", "accreditation"])
def test_publisher_closed_schema_rejects_unexpected_accreditation_prose(
    word: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {
            "name": "agencyStatusNote",
            "value": f"{word} by a synthetic public agency",
        }
    )

    with pytest.raises(
        PublisherAlignmentAdapterError, match="SOURCE_FIELDS_NOT_ALLOWED"
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    "field_name",
    [
        "accreditedStatus",
        "accreditation_status",
        "accreditorId",
        "accreditingAgency",
    ],
)
def test_publisher_closed_schema_rejects_unexpected_accreditation_fields(
    field_name: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": field_name, "value": "synthetic public agency"}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError, match="SOURCE_FIELDS_NOT_ALLOWED"
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    ("field_name", "field_value"),
    [
        ("accreditorCreditStatus", "synthetic public note"),
        ("accreditingAgencyCredits", "synthetic public note"),
        ("agencyStatusNote", "synthetic accreditor awards credits"),
    ],
)
def test_publisher_alignments_reject_credit_claims_near_accreditation_metadata(
    field_name: str,
    field_value: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": field_name, "value": field_value}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError,
        match="SOURCE_FIELDS_NOT_ALLOWED",
    ):
        adapt_publisher_alignment_document(document)


def test_publisher_closed_schema_rejects_unexpected_master_source_prose() -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": "sourceConceptNote", "value": "synthetic master source concept"}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError, match="SOURCE_FIELDS_NOT_ALLOWED"
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize(
    ("field_name", "field_value"),
    [
        ("equationType", "synthetic equation"),
        ("sourceEquationNote", "equation for a synthetic public source"),
        ("equivocalStatus", "equivocal synthetic public text"),
    ],
)
def test_publisher_closed_schema_rejects_unexpected_non_equivalence_fields(
    field_name: str,
    field_value: str,
) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": field_name, "value": field_value}
    )

    with pytest.raises(
        PublisherAlignmentAdapterError, match="SOURCE_FIELDS_NOT_ALLOWED"
    ):
        adapt_publisher_alignment_document(document)


@pytest.mark.parametrize("canary", PRIVATE_SOURCE_FIELD_CANARIES)
def test_publisher_alignments_reject_private_source_fields(canary: str) -> None:
    document = _load(ALIGNMENTS_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": canary, "value": "private-canary"}
    )

    with pytest.raises(PublisherAlignmentAdapterError, match="PRIVATE_BOUNDARY"):
        adapt_publisher_alignment_document(document)


def test_wikidata_lexical_and_model_candidates_are_separate_review_records() -> None:
    result = _candidate_result()
    candidates = {item["candidateKind"]: item for item in result["candidates"]}

    assert set(candidates) == {"wikidata", "lexical", "model"}
    assert "edges" not in result
    assert candidates["wikidata"]["proposedPredicateId"] == "skos:closeMatch"
    assert candidates["lexical"]["proposedPredicateId"] == "skos:exactMatch"
    assert candidates["model"]["proposedPredicateId"] == "skos:relatedMatch"
    assert candidates["wikidata"]["edge"]["sourceMetadata"]["method"] == (
        "community_submitted"
    )
    assert candidates["lexical"]["edge"]["sourceMetadata"]["method"] == "lexical"
    assert candidates["model"]["edge"]["sourceMetadata"]["method"] == (
        "model_generated"
    )
    for candidate in candidates.values():
        assert candidate["sourceState"] == "candidate"
        assert candidate["reviewState"] == "restricted"
        assert candidate["reviewDecision"] == "pending_review"
        assert candidate["sourceState"] != candidate["reviewState"]


def test_candidate_records_are_schema_valid_and_never_claim_proposed_authority() -> (
    None
):
    schema = _load(EDGE_SCHEMA)
    validator = Draft202012Validator(
        schema,
        format_checker=Draft202012Validator.FORMAT_CHECKER,
    )

    for candidate in _candidate_result()["candidates"]:
        edge = candidate["edge"]
        validator.validate(edge)
        assert edge["predicate"]["predicateId"] == ("ambitions:candidateRelationship")
        assert edge["review"]["state"] == "restricted"
        assert edge["review"]["provenanceClass"] in {
            "community",
            "lexical_model",
        }
        assert edge["sourceMetadata"]["qaPartition"] == "candidate"
        assert edge["useProfileBinding"] == {
            "profileId": "mapping-candidate-review-v1",
            "revision": "1.0.0",
        }
        source_fields = {
            field["name"]: field["value"]
            for field in edge["sourceMetadata"]["sourceSpecificFields"]
        }
        assert source_fields["proposedPredicateId"] == candidate["proposedPredicateId"]
        assert source_fields["candidateId"] == candidate["candidateId"]


def test_candidate_confidence_never_enables_product_or_consumer_use() -> None:
    result = _candidate_result()

    assert result["reviewPolicy"] == {
        "profileId": "mapping-candidate-review-v1",
        "profileRevision": "1.0.0",
        "sourcePredicateGrantsEligibility": False,
        "confidenceGrantsEligibility": False,
        "consumerUseEnabled": False,
    }
    for candidate in result["candidates"]:
        assert candidate["confidence"] >= 0.99
        assert candidate["consumerUseEnabled"] is False
        assert candidate["edge"]["eligiblePurposes"] == ["review_only"]
        assert "inspection" not in candidate["edge"]["eligiblePurposes"]
        assert "search_expansion" not in candidate["edge"]["eligiblePurposes"]
        assert "destination_discovery" not in candidate["edge"]["eligiblePurposes"]
        assert "explanation" not in candidate["edge"]["eligiblePurposes"]
        assert "not a consumer fact" in candidate["edge"]["nonClaims"]


def test_missing_candidate_scores_and_evidence_remain_missing_and_review_only() -> None:
    document = _load(CANDIDATES_FIXTURE)
    document["rows"][0]["confidence"] = None
    document["rows"][0]["evidence"] = []

    candidate = next(
        item
        for item in _candidate_result(document)["candidates"]
        if item["candidateKind"] == "wikidata"
    )
    assert candidate["confidence"] is None
    assert candidate["edge"]["sourceMetadata"]["evidence"] == []
    assert "confidence" not in candidate["edge"]["sourceMetadata"]
    assert candidate["edge"]["eligiblePurposes"] == ["review_only"]


def test_candidate_output_is_deterministic_and_production_remains_unavailable() -> None:
    document = _load(CANDIDATES_FIXTURE)
    shuffled = deepcopy(document)
    shuffled["rows"] = list(reversed(shuffled["rows"]))

    assert _candidate_result(document) == _candidate_result(shuffled)
    assert _candidate_result()["productionAdmission"] == {
        "sourceId": "relationship-mapping-candidates",
        "state": "unavailable",
        "reason": "review_artifact_only_exact_public_inputs_and_rights_required",
    }
    assert _candidate_result()["authority"]["rightsState"] == "inspection_only"


def test_candidate_id_is_part_of_stable_edge_identity() -> None:
    original = _load(CANDIDATES_FIXTURE)
    changed = deepcopy(original)
    changed["rows"][0]["candidateId"] = "candidate.wikidata.002"

    original_edge = _candidate_result(original)["candidates"][2]["edge"]
    changed_edge = _candidate_result(changed)["candidates"][2]["edge"]

    assert original_edge["edgeId"] != changed_edge["edgeId"]


def test_candidate_edge_identity_is_namespaced_by_mapping_set() -> None:
    candidate_id = "candidate.shared.001"

    first = _candidate_edge_id(
        mapping_set_id="ambitions.mapping-candidates.synthetic",
        candidate_id=candidate_id,
    )
    second = _candidate_edge_id(
        mapping_set_id="ambitions.mapping-candidates.other-synthetic",
        candidate_id=candidate_id,
    )

    assert first != second
    assert first == _candidate_edge_id(
        mapping_set_id="ambitions.mapping-candidates.synthetic",
        candidate_id=candidate_id,
    )


@pytest.mark.parametrize(
    "mutation",
    [
        lambda row: row.__setitem__(
            "evidence", ["synthetic:model:evaluation-case:changed"]
        ),
        lambda row: row["method"].__setitem__("configHash", "d" * 64),
        lambda row: row["method"].__setitem__("seed", 19),
        lambda row: row.__setitem__("confidence", 0.875),
    ],
)
def test_candidate_review_authority_changes_revision_but_not_edge_identity(
    mutation,
) -> None:
    original = _load(CANDIDATES_FIXTURE)
    changed = deepcopy(original)
    mutation(changed["rows"][2])

    original_edge = _candidate_result(original)["candidates"][1]["edge"]
    changed_edge = _candidate_result(changed)["candidates"][1]["edge"]

    assert original_edge["edgeId"] == changed_edge["edgeId"]
    assert original_edge["revision"] != changed_edge["revision"]


def test_candidate_edge_identity_and_revision_are_deterministic_for_exact_bytes() -> (
    None
):
    document = _load(CANDIDATES_FIXTURE)

    first = _candidate_result(document)["candidates"][1]["edge"]
    second = _candidate_result(deepcopy(document))["candidates"][1]["edge"]

    assert first["edgeId"] == second["edgeId"]
    assert first["revision"] == second["revision"]


@pytest.mark.parametrize(
    ("floating_model", "error"),
    [
        ("latest", "FLOATING_VERSION"),
        ("CURRENT", "FLOATING_VERSION"),
        ("Unknown", "FLOATING_VERSION"),
        ("unRESOLVED", "FLOATING_VERSION"),
        ("*", "PINNED_IDENTITY_INVALID"),
        (" latest ", "PINNED_IDENTITY_INVALID"),
        ("\tCURRENT\n", "PINNED_IDENTITY_INVALID"),
    ],
)
def test_model_candidates_reject_floating_model_identity(
    floating_model: str,
    error: str,
) -> None:
    document = _load(CANDIDATES_FIXTURE)
    document["rows"][2]["method"]["model"] = floating_model

    with pytest.raises(RelationshipCandidateAdapterError, match=error):
        adapt_candidate_document(document)


@pytest.mark.parametrize("invalid_model", ["", " ", "\t\n"])
def test_model_candidates_reject_empty_or_whitespace_model_identity(
    invalid_model: str,
) -> None:
    document = _load(CANDIDATES_FIXTURE)
    document["rows"][2]["method"]["model"] = invalid_model

    with pytest.raises(RelationshipCandidateAdapterError):
        adapt_candidate_document(document)


def test_model_candidates_accept_exact_pinned_model_identity() -> None:
    document = _load(CANDIDATES_FIXTURE)

    model = _candidate_result(document)["candidates"][1]["edge"]["sourceMetadata"][
        "mappingModel"
    ]
    assert model == "synthetic-embedding-model-v1"


@pytest.mark.parametrize(
    ("field", "invalid_identity"),
    [
        ("model", " latest "),
        ("model", "\tCURRENT\n"),
        ("model", "latest\u200b"),
        ("model", "\u200blatest"),
        ("model", " "),
        ("toolVersion", " latest "),
        ("toolVersion", "\tCURRENT\n"),
        ("toolVersion", "1.0.0\u200b"),
        ("toolVersion", "\u200b1.0.0"),
        ("toolVersion", " "),
    ],
)
def test_model_candidate_method_identities_reject_normalization_bypasses(
    field: str,
    invalid_identity: str,
) -> None:
    document = _load(CANDIDATES_FIXTURE)
    document["rows"][2]["method"][field] = invalid_identity

    with pytest.raises(RelationshipCandidateAdapterError, match="IDENTITY_INVALID"):
        adapt_candidate_document(document)


@pytest.mark.parametrize(
    "forbidden_character", ["\x00", "\u00a0", "\u2028", "\u2029", "\u2060"]
)
@pytest.mark.parametrize("field", ["model", "toolVersion"])
def test_model_candidate_method_identities_reject_unicode_control_and_separators(
    field: str,
    forbidden_character: str,
) -> None:
    document = _load(CANDIDATES_FIXTURE)
    document["rows"][2]["method"][field] = f"pinned{forbidden_character}identity"

    with pytest.raises(RelationshipCandidateAdapterError, match="IDENTITY_INVALID"):
        adapt_candidate_document(document)


def test_model_candidate_method_identity_length_is_bounded() -> None:
    document = _load(CANDIDATES_FIXTURE)
    document["rows"][2]["method"]["model"] = "m" * 129

    with pytest.raises(RelationshipCandidateAdapterError, match="IDENTITY_INVALID"):
        adapt_candidate_document(document)


@pytest.mark.parametrize(
    ("mutation", "error"),
    [
        (
            lambda document: document["rows"][0].__setitem__(
                "proposedPredicateId", "unknown:predicate"
            ),
            "PROPOSED_PREDICATE_NOT_ALLOWED",
        ),
        (
            lambda document: document["rows"][0].__setitem__("reviewState", "approved"),
            "REVIEW_STATE_NOT_ALLOWED",
        ),
        (
            lambda document: document["rows"][0].__setitem__(
                "reviewDecision", "approved"
            ),
            "REVIEW_DECISION_NOT_ALLOWED",
        ),
        (
            lambda document: document["rows"][0].__setitem__(
                "sourceState", "source_published"
            ),
            "SOURCE_STATE_NOT_ALLOWED",
        ),
        (
            lambda document: document["rows"][0].__setitem__(
                "direction", "object_to_subject"
            ),
            "DIRECTION_NOT_ALLOWED",
        ),
        (
            lambda document: document["rows"][0].__setitem__(
                "candidateKind", "embedding"
            ),
            "CANDIDATE_KIND_NOT_ALLOWED",
        ),
        (
            lambda document: document["rows"][0]["method"].__setitem__(
                "methodClass", "lexical"
            ),
            "METHOD_KIND_MISMATCH",
        ),
        (
            lambda document: document["authority"].__setitem__(
                "subjectSchemeVersion", "latest"
            ),
            "FLOATING_VERSION",
        ),
        (
            lambda document: document["authority"].__setitem__(
                "rightsState", "approved"
            ),
            "SYNTHETIC_AUTHORITY_MISMATCH",
        ),
        (
            lambda document: document["rows"][0].__setitem__("consumerEligible", True),
            "UNKNOWN_FIELDS",
        ),
    ],
)
def test_candidates_fail_closed_for_unknown_predicates_states_rights_and_releases(
    mutation,
    error: str,
) -> None:
    document = _load(CANDIDATES_FIXTURE)
    mutation(document)

    with pytest.raises(RelationshipCandidateAdapterError, match=error):
        adapt_candidate_document(document)


@pytest.mark.parametrize("score", [-0.01, 1.01, True, "1.0", float("inf")])
def test_candidate_confidence_must_be_a_finite_unit_interval_number(score) -> None:
    document = _load(CANDIDATES_FIXTURE)
    document["rows"][0]["confidence"] = score

    with pytest.raises(RelationshipCandidateAdapterError, match="CONFIDENCE_INVALID"):
        adapt_candidate_document(document)


def test_candidate_similarity_must_be_finite_when_present() -> None:
    document = _load(CANDIDATES_FIXTURE)
    document["rows"][1]["similarity"] = float("nan")

    with pytest.raises(RelationshipCandidateAdapterError, match="SIMILARITY_INVALID"):
        adapt_candidate_document(document)


def test_candidate_ids_and_source_rows_must_be_unique() -> None:
    duplicate_id = _load(CANDIDATES_FIXTURE)
    duplicate_id["rows"][1]["candidateId"] = duplicate_id["rows"][0]["candidateId"]
    with pytest.raises(RelationshipCandidateAdapterError, match="DUPLICATE_CANDIDATE"):
        adapt_candidate_document(duplicate_id)

    duplicate_row = _load(CANDIDATES_FIXTURE)
    duplicate_row["rows"][1]["sourceRow"] = duplicate_row["rows"][0]["sourceRow"]
    with pytest.raises(RelationshipCandidateAdapterError, match="DUPLICATE_SOURCE_ROW"):
        adapt_candidate_document(duplicate_row)


@pytest.mark.parametrize("canary", PRIVATE_SOURCE_FIELD_CANARIES)
def test_candidates_reject_private_source_fields(canary: str) -> None:
    document = _load(CANDIDATES_FIXTURE)
    document["rows"][0]["sourceSpecificFields"].append(
        {"name": canary, "value": "private-canary"}
    )

    with pytest.raises(RelationshipCandidateAdapterError, match="PRIVATE_BOUNDARY"):
        adapt_candidate_document(document)
