from __future__ import annotations

import re
from typing import Any

from .relationship_registry_models import (
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


class ONETESCOAdapterError(RelationshipAdapterError):
    pass


DOCUMENT_FIELDS = frozenset(
    {"schemaVersion", "kind", "fixtureClass", "authority", "rows"}
)
ROW_FIELDS = frozenset(
    {
        "sourceRow",
        "predicateId",
        "qaPartition",
        "onetConcept",
        "escoConcept",
        "sourceSpecificFields",
    }
)
ONET_SOC_CODE = re.compile(r"^[0-9]{2}-[0-9]{4}\.[0-9]{2}$")
SKOS_PREDICATES = frozenset(
    {
        "skos:exactMatch",
        "skos:closeMatch",
        "skos:broadMatch",
        "skos:narrowMatch",
        "skos:relatedMatch",
    }
)
EXPECTED_SYNTHETIC_AUTHORITY = {
    "mappingSetId": "official.onet-esco.synthetic-reservation",
    "mappingSetRevision": "1.0.0",
    "releaseId": "official.onet-esco.synthetic-reservation-v1",
    "subjectSchemeId": "onet-soc",
    "subjectSchemeVersion": "fixture-onet-2022",
    "objectSchemeId": "esco",
    "objectSchemeVersion": "fixture-esco-1.1.1",
    "rightsId": "ambitions.synthetic.relationship-rights",
    "rightsVersion": "1.0.0",
    "rightsState": "review_required",
}


def _validate_qa_partition(predicate_id: str, qa_partition: object) -> str:
    if predicate_id == "skos:relatedMatch":
        expected = "lower_qa_related"
    else:
        expected = "human_validated"
    if qa_partition != expected:
        raise ONETESCOAdapterError(
            f"QA_PARTITION_MISMATCH:{predicate_id}:{qa_partition}:{expected}"
        )
    return expected


def adapt_onet_esco_document(document: object) -> dict[str, Any]:
    value = require_exact_fields(
        document,
        DOCUMENT_FIELDS,
        "document",
        ONETESCOAdapterError,
    )
    if value["schemaVersion"] != "relationship-registry-onet-esco-gated-fixture-v1":
        raise ONETESCOAdapterError("SCHEMA_VERSION_UNSUPPORTED")
    if value["kind"] != "relationshipRegistryONETESCOGatedFixture":
        raise ONETESCOAdapterError("KIND_UNSUPPORTED")
    if value["fixtureClass"] != "synthetic_contract":
        raise ONETESCOAdapterError("FIXTURE_CLASS_UNSUPPORTED")
    require_public_fixture(
        value,
        location="relationship-registry-onet-esco-gated-fixture",
        error_type=ONETESCOAdapterError,
    )
    authority = parse_authority(
        value["authority"],
        expected_subject=("onet-soc", "fixture-onet-2022"),
        expected_object=("esco", "fixture-esco-1.1.1"),
        error_type=ONETESCOAdapterError,
    )
    actual_authority = authority.as_dict()
    if any(
        actual_authority[field] != expected
        for field, expected in EXPECTED_SYNTHETIC_AUTHORITY.items()
    ):
        raise ONETESCOAdapterError("SYNTHETIC_AUTHORITY_MISMATCH")

    profile = controlled_profile("onet-esco-blocked-v1")
    if (
        profile["allowedPurposes"] != ["unavailable"]
        or profile["allowedDirections"]
        or profile["allowedRightsStates"]
    ):
        raise ONETESCOAdapterError("BLOCKED_PROFILE_WIDENED")
    admission = source_admission("onet_esco_mapping")
    if admission["state"] != "unavailable":
        raise ONETESCOAdapterError("PRODUCTION_ADMISSION_WIDENED")
    if not isinstance(value["rows"], list) or not value["rows"]:
        raise ONETESCOAdapterError("ROWS_REQUIRED")

    mappings: list[dict[str, Any]] = []
    source_rows: set[str] = set()
    for index, raw_row in enumerate(value["rows"]):
        row = require_exact_fields(
            raw_row,
            ROW_FIELDS,
            f"rows[{index}]",
            ONETESCOAdapterError,
        )
        source_row = row["sourceRow"]
        if not isinstance(source_row, str) or not source_row:
            raise ONETESCOAdapterError(f"SOURCE_ROW_REQUIRED:rows[{index}]")
        if source_row in source_rows:
            raise ONETESCOAdapterError(f"DUPLICATE_SOURCE_ROW:{source_row}")
        source_rows.add(source_row)

        predicate_id = row["predicateId"]
        if not isinstance(predicate_id, str) or predicate_id not in SKOS_PREDICATES:
            raise ONETESCOAdapterError(f"PREDICATE_NOT_ALLOWED:{predicate_id}")
        predicate, vocabulary_hash = controlled_predicate(predicate_id)
        qa_partition = _validate_qa_partition(predicate_id, row["qaPartition"])
        subject = concept_ref(
            row["onetConcept"],
            scheme_id=authority.subject_scheme_id,
            scheme_version=authority.subject_scheme_version,
            location=f"rows[{index}].onetConcept",
            error_type=ONETESCOAdapterError,
        )
        if not ONET_SOC_CODE.fullmatch(subject["conceptId"]):
            raise ONETESCOAdapterError(f"ONET_SOC_CODE_INVALID:{subject['conceptId']}")
        object_ = concept_ref(
            row["escoConcept"],
            scheme_id=authority.object_scheme_id,
            scheme_version=authority.object_scheme_version,
            location=f"rows[{index}].escoConcept",
            error_type=ONETESCOAdapterError,
        )
        fields = source_specific_fields(
            row["sourceSpecificFields"],
            location=f"rows[{index}].sourceSpecificFields",
            error_type=ONETESCOAdapterError,
        )
        mappings.append(
            {
                "sourceRow": source_row,
                "subject": subject,
                "predicateId": predicate_id,
                "predicateVocabularyVersion": predicate["vocabularyVersion"],
                "predicateVocabularyHash": vocabulary_hash,
                "direction": "subject_to_object",
                "object": object_,
                "qaPartition": qa_partition,
                "reviewState": "restricted",
                "eligiblePurposes": ["unavailable"],
                "sourceSpecificFields": fields,
            }
        )

    return {
        "schemaVersion": "relationship-registry-onet-esco-gated-result-v1",
        "kind": "relationshipRegistryONETESCOGatedResult",
        "fixtureClass": "synthetic_contract",
        "authority": authority.as_dict(),
        "productionAdmission": admission,
        "availability": {
            "state": "unavailable",
            "profileId": profile["profileId"],
            "profileRevision": profile["revision"],
            "exactEndpointReleasesPassed": False,
            "mappingBytesPassed": False,
            "rightsPassed": False,
            "reason": admission["reason"],
        },
        "forbiddenPropagation": list(profile["forbiddenPropagation"]),
        "nonClaims": list(profile["nonClaims"]),
        "mappings": sorted(mappings, key=lambda item: item["sourceRow"]),
    }
