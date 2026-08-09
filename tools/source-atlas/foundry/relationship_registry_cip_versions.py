from __future__ import annotations

from itertools import product
from typing import Any

from .relationship_registry_models import (
    RelationshipAdapterError,
    build_edge,
    concept_ref,
    controlled_predicate,
    controlled_profile,
    parse_authority,
    require_exact_fields,
    require_public_fixture,
    source_admission,
    source_specific_fields,
)


class CIPVersionAdapterError(RelationshipAdapterError):
    pass


DOCUMENT_FIELDS = frozenset(
    {"schemaVersion", "kind", "fixtureClass", "authority", "rows"}
)
ROW_FIELDS = frozenset(
    {"sourceRow", "action", "fromConcepts", "toConcepts", "sourceSpecificFields"}
)
ACTION_DISPOSITIONS = {
    "unchanged": "deterministic_candidate",
    "text changed": "review_required",
    "new": "no_predecessor",
    "deleted": "no_target",
    "moved from": "review_required",
    "moved to": "deterministic_candidate",
    "report under": "review_required",
    "split": "review_required",
    "merge": "review_required",
}
ACTION_PREDICATES = {
    "unchanged": "cip:unchanged",
    "text changed": "cip:textChanged",
    "new": "cip:new",
    "deleted": "cip:deleted",
    "moved from": "cip:movedFrom",
    "moved to": "cip:movedTo",
    "report under": "cip:reportUnder",
    "split": "cip:split",
    "merge": "cip:merge",
}
ACTION_LIFECYCLE = {
    "text changed": "changed",
    "deleted": "deleted",
    "split": "split",
    "merge": "merged",
}
EXPECTED_SYNTHETIC_AUTHORITY = {
    "mappingSetId": "nces.cip-2010-2020.synthetic",
    "mappingSetRevision": "1.0.0",
    "releaseId": "nces.cip-2010-2020.synthetic-v1",
    "subjectSchemeId": "cip",
    "subjectSchemeVersion": "2010",
    "objectSchemeId": "cip",
    "objectSchemeVersion": "2020",
    "rightsId": "ambitions.synthetic.relationship-rights",
    "rightsVersion": "1.0.0",
}


def _concepts(
    value: object,
    *,
    scheme_id: str,
    scheme_version: str,
    location: str,
) -> list[dict[str, Any]]:
    if not isinstance(value, list):
        raise CIPVersionAdapterError(f"ARRAY_REQUIRED:{location}")
    concepts = [
        concept_ref(
            item,
            scheme_id=scheme_id,
            scheme_version=scheme_version,
            location=f"{location}[{index}]",
            error_type=CIPVersionAdapterError,
        )
        for index, item in enumerate(value)
    ]
    ids = [concept["conceptId"] for concept in concepts]
    if len(ids) != len(set(ids)):
        raise CIPVersionAdapterError(f"DUPLICATE_CONCEPT:{location}")
    return sorted(concepts, key=lambda concept: concept["conceptId"])


def _validate_cardinality(
    action: str,
    from_concepts: list[dict[str, Any]],
    to_concepts: list[dict[str, Any]],
) -> None:
    cardinality = (len(from_concepts), len(to_concepts))
    valid = {
        "unchanged": cardinality == (1, 1),
        "text changed": cardinality == (1, 1),
        "new": cardinality == (0, 1),
        "deleted": cardinality == (1, 0),
        "moved from": cardinality == (1, 1),
        "moved to": cardinality == (1, 1),
        "report under": cardinality[0] == 1 and cardinality[1] >= 1,
        "split": cardinality[0] == 1 and cardinality[1] >= 2,
        "merge": cardinality[0] >= 2 and cardinality[1] == 1,
    }[action]
    if not valid:
        raise CIPVersionAdapterError(
            f"CARDINALITY:{action}:{cardinality[0]}:{cardinality[1]}"
        )


def _action_concepts(
    concepts: list[dict[str, Any]],
    action: str,
) -> list[dict[str, Any]]:
    lifecycle = ACTION_LIFECYCLE.get(action)
    if lifecycle is None:
        return [dict(concept) for concept in concepts]
    return [{**concept, "lifecycleState": lifecycle} for concept in concepts]


def adapt_cip_version_document(document: object) -> dict[str, Any]:
    value = require_exact_fields(
        document,
        DOCUMENT_FIELDS,
        "document",
        CIPVersionAdapterError,
    )
    if value["schemaVersion"] != "relationship-registry-cip-version-fixture-v1":
        raise CIPVersionAdapterError("SCHEMA_VERSION_UNSUPPORTED")
    if value["kind"] != "relationshipRegistryCIPVersionFixture":
        raise CIPVersionAdapterError("KIND_UNSUPPORTED")
    if value["fixtureClass"] != "synthetic_contract":
        raise CIPVersionAdapterError("FIXTURE_CLASS_UNSUPPORTED")
    require_public_fixture(
        value,
        location="relationship-registry-cip-version-fixture",
        error_type=CIPVersionAdapterError,
    )
    authority = parse_authority(
        value["authority"],
        expected_subject=("cip", "2010"),
        expected_object=("cip", "2020"),
        error_type=CIPVersionAdapterError,
    )
    profile = controlled_profile("cip-edition-migration-v1")
    actual_authority = authority.as_dict()
    if any(
        actual_authority[field] != expected
        for field, expected in EXPECTED_SYNTHETIC_AUTHORITY.items()
    ):
        raise CIPVersionAdapterError("SYNTHETIC_AUTHORITY_MISMATCH")
    if authority.rights_state not in profile["allowedRightsStates"]:
        raise CIPVersionAdapterError(
            f"RIGHTS_STATE_NOT_ALLOWED:{authority.rights_state}"
        )
    if not isinstance(value["rows"], list) or not value["rows"]:
        raise CIPVersionAdapterError("ROWS_REQUIRED")

    actions: list[dict[str, Any]] = []
    edges: list[dict[str, Any]] = []
    source_rows: set[str] = set()
    for index, raw_row in enumerate(value["rows"]):
        row = require_exact_fields(
            raw_row,
            ROW_FIELDS,
            f"rows[{index}]",
            CIPVersionAdapterError,
        )
        source_row = row["sourceRow"]
        if not isinstance(source_row, str) or not source_row:
            raise CIPVersionAdapterError(f"SOURCE_ROW_REQUIRED:rows[{index}]")
        if source_row in source_rows:
            raise CIPVersionAdapterError(f"DUPLICATE_SOURCE_ROW:{source_row}")
        source_rows.add(source_row)
        action = row["action"]
        if not isinstance(action, str) or action not in ACTION_DISPOSITIONS:
            raise CIPVersionAdapterError(f"UNKNOWN_ACTION:{action}")
        predicate_id = ACTION_PREDICATES[action]
        predicate, _ = controlled_predicate(predicate_id)
        if predicate["sourceCode"] != action:
            raise CIPVersionAdapterError(
                f"PREDICATE_SOURCE_CODE_MISMATCH:{predicate_id}:{action}"
            )
        from_concepts = _concepts(
            row["fromConcepts"],
            scheme_id=authority.subject_scheme_id,
            scheme_version=authority.subject_scheme_version,
            location=f"rows[{index}].fromConcepts",
        )
        to_concepts = _concepts(
            row["toConcepts"],
            scheme_id=authority.object_scheme_id,
            scheme_version=authority.object_scheme_version,
            location=f"rows[{index}].toConcepts",
        )
        _validate_cardinality(action, from_concepts, to_concepts)
        fields = source_specific_fields(
            row["sourceSpecificFields"],
            location=f"rows[{index}].sourceSpecificFields",
            error_type=CIPVersionAdapterError,
        )
        disposition = ACTION_DISPOSITIONS[action]
        purposes = (
            ["inspection"]
            if authority.rights_state == "inspection_only"
            or disposition != "deterministic_candidate"
            else list(profile["allowedPurposes"])
        )
        actions.append(
            {
                "sourceRow": source_row,
                "sourceAction": action,
                "predicateId": predicate_id,
                "fromConcepts": _action_concepts(from_concepts, action),
                "toConcepts": to_concepts,
                "migrationDisposition": disposition,
                "eligiblePurposes": purposes,
                "nonClaims": list(profile["nonClaims"]),
                "sourceSpecificFields": fields,
            }
        )
        for subject, object_ in product(from_concepts, to_concepts):
            edge_subject = _action_concepts([subject], action)[0]
            edges.append(
                build_edge(
                    authority=authority,
                    profile_id=profile["profileId"],
                    predicate_id=predicate_id,
                    source_row=source_row,
                    subject=edge_subject,
                    object_=object_,
                    source_fields=fields,
                    eligible_purposes=purposes,
                )
            )

    return {
        "schemaVersion": "relationship-registry-cip-version-adapter-result-v1",
        "kind": "relationshipRegistryCIPVersionAdapterResult",
        "fixtureClass": "synthetic_contract",
        "authority": authority.as_dict(),
        "productionAdmission": source_admission("cip_edition_migration"),
        "actions": sorted(
            actions,
            key=lambda item: (item["sourceAction"], item["sourceRow"]),
        ),
        "edges": sorted(
            edges,
            key=lambda edge: (
                edge["sourceMetadata"]["sourceRow"],
                edge["subject"]["conceptId"],
                edge["object"]["conceptId"],
            ),
        ),
    }
