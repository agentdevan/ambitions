from __future__ import annotations

import re
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


class ONETSOCAdapterError(RelationshipAdapterError):
    pass


DOCUMENT_FIELDS = frozenset(
    {"schemaVersion", "kind", "fixtureClass", "authority", "rows"}
)
ROW_FIELDS = frozenset(
    {"sourceRow", "onetConcept", "socConcept", "sourceSpecificFields"}
)
ONET_SOC_CODE = re.compile(r"^[0-9]{2}-[0-9]{4}\.[0-9]{2}$")
SOC_CODE = re.compile(r"^[0-9]{2}-[0-9]{4}$")
EXPECTED_SYNTHETIC_AUTHORITY = {
    "mappingSetId": "onet.onet-soc-2019-soc-2018.synthetic",
    "mappingSetRevision": "1.0.0",
    "releaseId": "onet.onet-soc-2019-soc-2018.synthetic-v1",
    "subjectSchemeId": "onet-soc",
    "subjectSchemeVersion": "2019",
    "objectSchemeId": "soc",
    "objectSchemeVersion": "2018",
    "rightsId": "ambitions.synthetic.relationship-rights",
    "rightsVersion": "1.0.0",
}


def adapt_onet_soc_document(document: object) -> dict[str, Any]:
    value = require_exact_fields(
        document,
        DOCUMENT_FIELDS,
        "document",
        ONETSOCAdapterError,
    )
    if value["schemaVersion"] != "relationship-registry-onet-soc-fixture-v1":
        raise ONETSOCAdapterError("SCHEMA_VERSION_UNSUPPORTED")
    if value["kind"] != "relationshipRegistryONETSOCFixture":
        raise ONETSOCAdapterError("KIND_UNSUPPORTED")
    if value["fixtureClass"] != "synthetic_contract":
        raise ONETSOCAdapterError("FIXTURE_CLASS_UNSUPPORTED")
    require_public_fixture(
        value,
        location="relationship-registry-onet-soc-fixture",
        error_type=ONETSOCAdapterError,
    )
    authority = parse_authority(
        value["authority"],
        expected_subject=("onet-soc", "2019"),
        expected_object=("soc", "2018"),
        error_type=ONETSOCAdapterError,
    )
    profile = controlled_profile("onet-soc-overlay-v1")
    actual_authority = authority.as_dict()
    if any(
        actual_authority[field] != expected
        for field, expected in EXPECTED_SYNTHETIC_AUTHORITY.items()
    ):
        raise ONETSOCAdapterError("SYNTHETIC_AUTHORITY_MISMATCH")
    if authority.rights_state not in profile["allowedRightsStates"]:
        raise ONETSOCAdapterError(f"RIGHTS_STATE_NOT_ALLOWED:{authority.rights_state}")
    if not isinstance(value["rows"], list) or not value["rows"]:
        raise ONETSOCAdapterError("ROWS_REQUIRED")

    edges: list[dict[str, Any]] = []
    source_rows: set[str] = set()
    for index, raw_row in enumerate(value["rows"]):
        row = require_exact_fields(
            raw_row,
            ROW_FIELDS,
            f"rows[{index}]",
            ONETSOCAdapterError,
        )
        source_row = row["sourceRow"]
        if not isinstance(source_row, str) or not source_row:
            raise ONETSOCAdapterError(f"SOURCE_ROW_REQUIRED:rows[{index}]")
        if source_row in source_rows:
            raise ONETSOCAdapterError(f"DUPLICATE_SOURCE_ROW:{source_row}")
        source_rows.add(source_row)

        subject = concept_ref(
            row["onetConcept"],
            scheme_id=authority.subject_scheme_id,
            scheme_version=authority.subject_scheme_version,
            location=f"rows[{index}].onetConcept",
            error_type=ONETSOCAdapterError,
        )
        object_ = concept_ref(
            row["socConcept"],
            scheme_id=authority.object_scheme_id,
            scheme_version=authority.object_scheme_version,
            location=f"rows[{index}].socConcept",
            error_type=ONETSOCAdapterError,
        )
        onet_code = subject["conceptId"]
        soc_code = object_["conceptId"]
        if not ONET_SOC_CODE.fullmatch(onet_code):
            raise ONETSOCAdapterError(f"ONET_SOC_CODE_INVALID:{onet_code}")
        if not SOC_CODE.fullmatch(soc_code):
            raise ONETSOCAdapterError(f"SOC_CODE_INVALID:{soc_code}")
        if onet_code.rsplit(".", 1)[0] != soc_code:
            raise ONETSOCAdapterError(
                f"SOC_GRANULARITY_MISMATCH:{onet_code}:{soc_code}"
            )
        fields = source_specific_fields(
            row["sourceSpecificFields"],
            location=f"rows[{index}].sourceSpecificFields",
            error_type=ONETSOCAdapterError,
        )
        edges.append(
            build_edge(
                authority=authority,
                profile_id=profile["profileId"],
                predicate_id="ambitions:sourceTaxonomyRelationship",
                source_row=source_row,
                subject=subject,
                object_=object_,
                source_fields=fields,
            )
        )

    return {
        "schemaVersion": "relationship-registry-onet-soc-adapter-result-v1",
        "kind": "relationshipRegistryONETSOCAdapterResult",
        "fixtureClass": "synthetic_contract",
        "authority": authority.as_dict(),
        "productionAdmission": source_admission("onet_soc_relationship"),
        "edges": sorted(
            edges,
            key=lambda edge: (
                edge["subject"]["conceptId"],
                edge["object"]["conceptId"],
                edge["sourceMetadata"]["sourceRow"],
            ),
        ),
    }
