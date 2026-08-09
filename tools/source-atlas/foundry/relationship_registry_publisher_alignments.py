from __future__ import annotations

from math import isfinite
from typing import Any

from .relationship_registry_models import (
    STABLE_ID,
    RelationshipAdapterError,
    concept_ref,
    controlled_predicate,
    controlled_profile,
    parse_authority,
    require_exact_fields,
    require_public_fixture,
    source_admission,
    source_specific_fields,
)


class PublisherAlignmentAdapterError(RelationshipAdapterError):
    pass


DOCUMENT_FIELDS = frozenset({"schemaVersion", "kind", "fixtureClass", "rows"})
ROW_FIELDS = frozenset(
    {
        "sourceRow",
        "alignmentStandard",
        "authority",
        "publisher",
        "predicateId",
        "sourceState",
        "reviewState",
        "subjectConcept",
        "objectConcept",
        "sourceSpecificFields",
    }
)
PUBLISHER_FIELDS = frozenset({"publisherId", "publisherName"})
STANDARD_POLICIES = {
    "ctdl": {
        "predicateId": "ctdl:alignment",
        "subject": ("synthetic-provider-catalog", "fixture-1.0.0"),
        "object": ("ctdl-framework", "fixture-1.0.0"),
        "authority": {
            "mappingSetId": "synthetic.publisher.ctdl-alignment",
            "mappingSetRevision": "1.0.0",
            "releaseId": "synthetic.publisher.ctdl-alignment-v1",
            "subjectSchemeId": "synthetic-provider-catalog",
            "subjectSchemeVersion": "fixture-1.0.0",
            "objectSchemeId": "ctdl-framework",
            "objectSchemeVersion": "fixture-1.0.0",
            "rightsId": "ambitions.synthetic.relationship-rights",
            "rightsVersion": "1.0.0",
            "rightsState": "review_required",
        },
        "publisher": {
            "publisherId": "synthetic.publisher.provider-alpha",
            "publisherName": "Synthetic Provider Alpha",
        },
        "sourceFields": {
            "alignmentType": {
                "kind": "enum",
                "values": frozenset({"synthetic-target-node"}),
            },
            "alignmentWeight": {"kind": "unit_number"},
        },
    },
    "case": {
        "predicateId": "case:association",
        "subject": ("case-framework", "fixture-1.1.0"),
        "object": ("case-framework", "fixture-1.1.0"),
        "authority": {
            "mappingSetId": "synthetic.publisher.case-association",
            "mappingSetRevision": "1.0.0",
            "releaseId": "synthetic.publisher.case-association-v1",
            "subjectSchemeId": "case-framework",
            "subjectSchemeVersion": "fixture-1.1.0",
            "objectSchemeId": "case-framework",
            "objectSchemeVersion": "fixture-1.1.0",
            "rightsId": "ambitions.synthetic.relationship-rights",
            "rightsVersion": "1.0.0",
            "rightsState": "review_required",
        },
        "publisher": {
            "publisherId": "synthetic.publisher.framework-beta",
            "publisherName": "Synthetic Framework Beta",
        },
        "sourceFields": {
            "associationType": {
                "kind": "enum",
                "values": frozenset({"synthetic-is-child-of"}),
            },
            "sequenceNumber": {
                "kind": "bounded_integer",
                "minimum": 1,
                "maximum": 2_147_483_647,
            },
        },
    },
}


def _publisher(value: object, *, location: str) -> dict[str, str]:
    publisher = require_exact_fields(
        value,
        PUBLISHER_FIELDS,
        location,
        PublisherAlignmentAdapterError,
    )
    publisher_id = publisher["publisherId"]
    publisher_name = publisher["publisherName"]
    if not isinstance(publisher_id, str) or not STABLE_ID.fullmatch(publisher_id):
        raise PublisherAlignmentAdapterError(f"PUBLISHER_ID_INVALID:{location}")
    if not isinstance(publisher_name, str) or not publisher_name:
        raise PublisherAlignmentAdapterError(f"PUBLISHER_NAME_INVALID:{location}")
    return {"publisherId": publisher_id, "publisherName": publisher_name}


def _publisher_source_fields(
    fields: list[dict[str, Any]],
    *,
    standard: str,
    location: str,
) -> list[dict[str, Any]]:
    policy = STANDARD_POLICIES[standard]["sourceFields"]
    actual_names = {field["name"] for field in fields}
    expected_names = set(policy)
    if actual_names != expected_names:
        extras = ",".join(sorted(actual_names - expected_names)) or "none"
        missing = ",".join(sorted(expected_names - actual_names)) or "none"
        raise PublisherAlignmentAdapterError(
            f"SOURCE_FIELDS_NOT_ALLOWED:{location}:extras={extras}:missing={missing}"
        )
    for field in fields:
        name = field["name"]
        field_value = field["value"]
        field_policy = policy[name]
        kind = field_policy["kind"]
        value_allowed = False
        if kind == "enum":
            value_allowed = (
                isinstance(field_value, str) and field_value in field_policy["values"]
            )
        elif kind == "unit_number":
            value_allowed = (
                not isinstance(field_value, bool)
                and isinstance(field_value, (int, float))
                and isfinite(field_value)
                and 0 <= field_value <= 1
            )
        elif kind == "bounded_integer":
            value_allowed = (
                not isinstance(field_value, bool)
                and isinstance(field_value, int)
                and field_policy["minimum"] <= field_value <= field_policy["maximum"]
            )
        if not value_allowed:
            raise PublisherAlignmentAdapterError(
                f"SOURCE_FIELD_VALUE_NOT_ALLOWED:{location}.{name}"
            )
    return fields


def adapt_publisher_alignment_document(document: object) -> dict[str, Any]:
    value = require_exact_fields(
        document,
        DOCUMENT_FIELDS,
        "document",
        PublisherAlignmentAdapterError,
    )
    if (
        value["schemaVersion"]
        != "relationship-registry-publisher-alignments-fixture-v1"
    ):
        raise PublisherAlignmentAdapterError("SCHEMA_VERSION_UNSUPPORTED")
    if value["kind"] != "relationshipRegistryPublisherAlignmentsFixture":
        raise PublisherAlignmentAdapterError("KIND_UNSUPPORTED")
    if value["fixtureClass"] != "synthetic_contract":
        raise PublisherAlignmentAdapterError("FIXTURE_CLASS_UNSUPPORTED")
    require_public_fixture(
        value,
        location="relationship-registry-publisher-alignments-fixture",
        error_type=PublisherAlignmentAdapterError,
    )

    profile = controlled_profile("publisher-alignment-blocked-v1")
    if (
        profile["allowedPurposes"] != ["unavailable"]
        or profile["allowedDirections"]
        or profile["allowedRightsStates"]
        or profile["requiredReviewStates"] != ["restricted"]
    ):
        raise PublisherAlignmentAdapterError("BLOCKED_PROFILE_WIDENED")
    admission = source_admission("publisher_alignment")
    if admission["state"] != "unavailable":
        raise PublisherAlignmentAdapterError("PRODUCTION_ADMISSION_WIDENED")
    if not isinstance(value["rows"], list) or not value["rows"]:
        raise PublisherAlignmentAdapterError("ROWS_REQUIRED")

    alignments: list[dict[str, Any]] = []
    source_rows: set[str] = set()
    for index, raw_row in enumerate(value["rows"]):
        row = require_exact_fields(
            raw_row,
            ROW_FIELDS,
            f"rows[{index}]",
            PublisherAlignmentAdapterError,
        )
        source_row = row["sourceRow"]
        if not isinstance(source_row, str) or not source_row:
            raise PublisherAlignmentAdapterError(f"SOURCE_ROW_REQUIRED:rows[{index}]")
        if source_row in source_rows:
            raise PublisherAlignmentAdapterError(f"DUPLICATE_SOURCE_ROW:{source_row}")
        source_rows.add(source_row)

        standard = row["alignmentStandard"]
        if not isinstance(standard, str) or standard not in STANDARD_POLICIES:
            raise PublisherAlignmentAdapterError(
                f"UNKNOWN_ALIGNMENT_STANDARD:{standard}"
            )
        policy = STANDARD_POLICIES[standard]
        predicate_id = row["predicateId"]
        if predicate_id != policy["predicateId"]:
            raise PublisherAlignmentAdapterError(
                f"PREDICATE_STANDARD_MISMATCH:{standard}:{predicate_id}"
            )
        predicate, vocabulary_hash = controlled_predicate(predicate_id)
        if predicate["family"] != "publisher_authored_alignment":
            raise PublisherAlignmentAdapterError(
                f"PREDICATE_FAMILY_MISMATCH:{predicate_id}"
            )

        authority = parse_authority(
            row["authority"],
            expected_subject=policy["subject"],
            expected_object=policy["object"],
            error_type=PublisherAlignmentAdapterError,
        )
        actual_authority = authority.as_dict()
        if actual_authority != policy["authority"]:
            raise PublisherAlignmentAdapterError("SYNTHETIC_AUTHORITY_MISMATCH")

        publisher = _publisher(row["publisher"], location=f"rows[{index}].publisher")
        if publisher != policy["publisher"]:
            raise PublisherAlignmentAdapterError("SYNTHETIC_PUBLISHER_MISMATCH")
        if row["sourceState"] != "publisher_claim":
            raise PublisherAlignmentAdapterError(
                f"SOURCE_STATE_NOT_ALLOWED:{row['sourceState']}"
            )
        if row["reviewState"] != "restricted":
            raise PublisherAlignmentAdapterError(
                f"REVIEW_STATE_NOT_ALLOWED:{row['reviewState']}"
            )

        subject = concept_ref(
            row["subjectConcept"],
            scheme_id=authority.subject_scheme_id,
            scheme_version=authority.subject_scheme_version,
            location=f"rows[{index}].subjectConcept",
            error_type=PublisherAlignmentAdapterError,
        )
        object_ = concept_ref(
            row["objectConcept"],
            scheme_id=authority.object_scheme_id,
            scheme_version=authority.object_scheme_version,
            location=f"rows[{index}].objectConcept",
            error_type=PublisherAlignmentAdapterError,
        )
        fields = source_specific_fields(
            row["sourceSpecificFields"],
            location=f"rows[{index}].sourceSpecificFields",
            error_type=PublisherAlignmentAdapterError,
        )
        fields = _publisher_source_fields(
            fields,
            standard=standard,
            location=f"rows[{index}].sourceSpecificFields",
        )
        alignments.append(
            {
                "sourceRow": source_row,
                "alignmentStandard": standard,
                "mappingSet": actual_authority,
                "sourceAuthority": publisher,
                "sourceState": "publisher_claim",
                "predicateId": predicate_id,
                "predicateVocabularyVersion": predicate["vocabularyVersion"],
                "predicateVocabularyHash": vocabulary_hash,
                "direction": "subject_to_object",
                "subject": subject,
                "object": object_,
                "reviewState": "restricted",
                "eligiblePurposes": ["unavailable"],
                "sourceSpecificFields": fields,
            }
        )

    return {
        "schemaVersion": "relationship-registry-publisher-alignments-result-v1",
        "kind": "relationshipRegistryPublisherAlignmentsResult",
        "fixtureClass": "synthetic_contract",
        "productionAdmission": admission,
        "availability": {
            "state": "unavailable",
            "profileId": profile["profileId"],
            "profileRevision": profile["revision"],
            "publisherSourceVersionPassed": False,
            "rightsPassed": False,
            "reason": admission["reason"],
        },
        "forbiddenPropagation": list(profile["forbiddenPropagation"]),
        "nonClaims": list(profile["nonClaims"]),
        "alignments": sorted(
            alignments,
            key=lambda item: (item["alignmentStandard"], item["sourceRow"]),
        ),
    }
