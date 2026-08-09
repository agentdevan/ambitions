from __future__ import annotations

from typing import Any

from .relationship_registry_models import (
    RelationshipAdapterError,
    build_edge,
    concept_ref,
    controlled_profile,
    parse_authority,
    require_exact_fields,
    require_public_fixture,
    source_admission,
    source_specific_fields,
)


class CIPSOCAdapterError(RelationshipAdapterError):
    pass


DOCUMENT_FIELDS = frozenset(
    {"schemaVersion", "kind", "fixtureClass", "authority", "rows"}
)
ROW_FIELDS = frozenset(
    {"sourceRow", "cipConcept", "socConcepts", "sourceSpecificFields"}
)
EXPECTED_SYNTHETIC_AUTHORITY = {
    "mappingSetId": "nces-bls.cip-2020-soc-2018.synthetic",
    "mappingSetRevision": "1.0.0",
    "releaseId": "nces-bls.cip-2020-soc-2018.synthetic-v1",
    "subjectSchemeId": "cip",
    "subjectSchemeVersion": "2020",
    "objectSchemeId": "soc",
    "objectSchemeVersion": "2018",
    "rightsId": "ambitions.synthetic.relationship-rights",
    "rightsVersion": "1.0.0",
}


def adapt_cip_soc_document(document: object) -> dict[str, Any]:
    value = require_exact_fields(
        document,
        DOCUMENT_FIELDS,
        "document",
        CIPSOCAdapterError,
    )
    if value["schemaVersion"] != "relationship-registry-cip-soc-fixture-v1":
        raise CIPSOCAdapterError("SCHEMA_VERSION_UNSUPPORTED")
    if value["kind"] != "relationshipRegistryCIPSOCFixture":
        raise CIPSOCAdapterError("KIND_UNSUPPORTED")
    if value["fixtureClass"] != "synthetic_contract":
        raise CIPSOCAdapterError("FIXTURE_CLASS_UNSUPPORTED")
    require_public_fixture(
        value,
        location="relationship-registry-cip-soc-fixture",
        error_type=CIPSOCAdapterError,
    )
    authority = parse_authority(
        value["authority"],
        expected_subject=("cip", "2020"),
        expected_object=("soc", "2018"),
        error_type=CIPSOCAdapterError,
    )
    profile = controlled_profile("cip-soc-relevance-v1")
    actual_authority = authority.as_dict()
    if any(
        actual_authority[field] != expected
        for field, expected in EXPECTED_SYNTHETIC_AUTHORITY.items()
    ):
        raise CIPSOCAdapterError("SYNTHETIC_AUTHORITY_MISMATCH")
    if authority.rights_state not in profile["allowedRightsStates"]:
        raise CIPSOCAdapterError(f"RIGHTS_STATE_NOT_ALLOWED:{authority.rights_state}")
    if not isinstance(value["rows"], list) or not value["rows"]:
        raise CIPSOCAdapterError("ROWS_REQUIRED")

    edges: list[dict[str, Any]] = []
    source_rows: set[str] = set()
    for index, raw_row in enumerate(value["rows"]):
        row = require_exact_fields(
            raw_row,
            ROW_FIELDS,
            f"rows[{index}]",
            CIPSOCAdapterError,
        )
        source_row = row["sourceRow"]
        if not isinstance(source_row, str) or not source_row:
            raise CIPSOCAdapterError(f"SOURCE_ROW_REQUIRED:rows[{index}]")
        if source_row in source_rows:
            raise CIPSOCAdapterError(f"DUPLICATE_SOURCE_ROW:{source_row}")
        source_rows.add(source_row)
        subject = concept_ref(
            row["cipConcept"],
            scheme_id=authority.subject_scheme_id,
            scheme_version=authority.subject_scheme_version,
            location=f"rows[{index}].cipConcept",
            error_type=CIPSOCAdapterError,
        )
        if not isinstance(row["socConcepts"], list) or not row["socConcepts"]:
            raise CIPSOCAdapterError(f"SOC_TARGETS_REQUIRED:rows[{index}]")
        objects = [
            concept_ref(
                item,
                scheme_id=authority.object_scheme_id,
                scheme_version=authority.object_scheme_version,
                location=f"rows[{index}].socConcepts[{object_index}]",
                error_type=CIPSOCAdapterError,
            )
            for object_index, item in enumerate(row["socConcepts"])
        ]
        object_ids = [object_["conceptId"] for object_ in objects]
        if len(object_ids) != len(set(object_ids)):
            raise CIPSOCAdapterError(f"DUPLICATE_SOC_TARGET:rows[{index}]")
        fields = source_specific_fields(
            row["sourceSpecificFields"],
            location=f"rows[{index}].sourceSpecificFields",
            error_type=CIPSOCAdapterError,
        )
        for object_ in sorted(objects, key=lambda concept: concept["conceptId"]):
            edges.append(
                build_edge(
                    authority=authority,
                    profile_id=profile["profileId"],
                    predicate_id="ambitions:educationOccupationRelevance",
                    source_row=source_row,
                    subject=subject,
                    object_=object_,
                    source_fields=fields,
                )
            )

    return {
        "schemaVersion": "relationship-registry-cip-soc-adapter-result-v1",
        "kind": "relationshipRegistryCIPSOCAdapterResult",
        "fixtureClass": "synthetic_contract",
        "authority": authority.as_dict(),
        "productionAdmission": source_admission("cip_soc_relevance"),
        "edges": sorted(
            edges,
            key=lambda edge: (
                edge["subject"]["conceptId"],
                edge["object"]["conceptId"],
                edge["sourceMetadata"]["sourceRow"],
            ),
        ),
    }
