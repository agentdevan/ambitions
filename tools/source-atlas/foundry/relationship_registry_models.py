from __future__ import annotations

import re
from dataclasses import dataclass
from math import isfinite
from pathlib import Path
from typing import Any, TypeVar

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import file_sha256, stable_hash


CONFIG_ROOT = Path(__file__).resolve().parents[1] / "config"
FLOATING_VERSIONS = {"latest", "current", "unknown", "unresolved", "*"}
STABLE_ID = re.compile(r"^[a-z0-9][a-z0-9._:-]{2,127}$")


class RelationshipAdapterError(ValueError):
    """Raised when public relationship source input cannot be preserved exactly."""


ErrorT = TypeVar("ErrorT", bound=RelationshipAdapterError)


@dataclass(frozen=True)
class RelationshipAdapterAuthority:
    mapping_set_id: str
    mapping_set_revision: str
    release_id: str
    subject_scheme_id: str
    subject_scheme_version: str
    object_scheme_id: str
    object_scheme_version: str
    rights_id: str
    rights_version: str
    rights_state: str

    def as_dict(self) -> dict[str, str]:
        return {
            "mappingSetId": self.mapping_set_id,
            "mappingSetRevision": self.mapping_set_revision,
            "releaseId": self.release_id,
            "subjectSchemeId": self.subject_scheme_id,
            "subjectSchemeVersion": self.subject_scheme_version,
            "objectSchemeId": self.object_scheme_id,
            "objectSchemeVersion": self.object_scheme_version,
            "rightsId": self.rights_id,
            "rightsVersion": self.rights_version,
            "rightsState": self.rights_state,
        }


AUTHORITY_FIELDS = frozenset(
    {
        "mappingSetId",
        "mappingSetRevision",
        "releaseId",
        "subjectSchemeId",
        "subjectSchemeVersion",
        "objectSchemeId",
        "objectSchemeVersion",
        "rightsId",
        "rightsVersion",
        "rightsState",
    }
)
CONCEPT_FIELDS = frozenset({"conceptId", "label", "locator"})
SOURCE_FIELD_FIELDS = frozenset({"name", "value"})
RELATIONSHIP_PRIVATE_SOURCE_FIELD_CANARIES = frozenset(
    {
        "userid",
        "deviceid",
        "ambition",
        "goal",
        "goalid",
        "capability",
        "proof",
        "educationhistory",
        "schedule",
        "location",
        "recommendation",
        "correction",
        "selection",
        "rejection",
    }
)
RELATIONSHIP_PRIVATE_SOURCE_FIELD_ID_BASES = frozenset(
    {
        "ambition",
        "goal",
        "capability",
        "proof",
        "educationhistory",
        "schedule",
        "location",
        "recommendation",
        "correction",
        "selection",
        "rejection",
    }
)
RELATIONSHIP_PUBLIC_SOURCE_FIELD_QUALIFIERS = frozenset(
    {"source", "mapping", "publisher", "standard"}
)
PROFILE_PREDICATES = {
    "cip-edition-migration-v1": frozenset(
        {
            "cip:unchanged",
            "cip:textChanged",
            "cip:new",
            "cip:deleted",
            "cip:movedFrom",
            "cip:movedTo",
            "cip:reportUnder",
            "cip:split",
            "cip:merge",
        }
    ),
    "cip-soc-relevance-v1": frozenset({"ambitions:educationOccupationRelevance"}),
    "onet-soc-overlay-v1": frozenset({"ambitions:sourceTaxonomyRelationship"}),
}
PROFILE_PREDICATE_ENDPOINT_STATES = {
    ("cip-edition-migration-v1", "cip:unchanged"): (
        frozenset({"current_for_mapping"}),
        frozenset({"current_for_mapping"}),
    ),
    ("cip-edition-migration-v1", "cip:textChanged"): (
        frozenset({"changed"}),
        frozenset({"current_for_mapping"}),
    ),
    ("cip-edition-migration-v1", "cip:movedFrom"): (
        frozenset({"current_for_mapping"}),
        frozenset({"current_for_mapping"}),
    ),
    ("cip-edition-migration-v1", "cip:movedTo"): (
        frozenset({"current_for_mapping"}),
        frozenset({"current_for_mapping"}),
    ),
    ("cip-edition-migration-v1", "cip:reportUnder"): (
        frozenset({"current_for_mapping"}),
        frozenset({"current_for_mapping"}),
    ),
    ("cip-edition-migration-v1", "cip:split"): (
        frozenset({"split"}),
        frozenset({"current_for_mapping"}),
    ),
    ("cip-edition-migration-v1", "cip:merge"): (
        frozenset({"merged"}),
        frozenset({"current_for_mapping"}),
    ),
    ("cip-soc-relevance-v1", "ambitions:educationOccupationRelevance"): (
        frozenset({"current_for_mapping"}),
        frozenset({"current_for_mapping"}),
    ),
    ("onet-soc-overlay-v1", "ambitions:sourceTaxonomyRelationship"): (
        frozenset({"current_for_mapping"}),
        frozenset({"current_for_mapping"}),
    ),
}


def require_exact_fields(
    value: object,
    expected: frozenset[str],
    location: str,
    error_type: type[ErrorT],
) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise error_type(f"OBJECT_REQUIRED:{location}")
    fields = set(value)
    if fields != expected:
        extras = ",".join(sorted(fields - expected)) or "none"
        missing = ",".join(sorted(expected - fields)) or "none"
        raise error_type(f"UNKNOWN_FIELDS:{location}:extras={extras}:missing={missing}")
    return value


def require_public_fixture(
    value: object,
    *,
    location: str,
    error_type: type[ErrorT],
) -> None:
    issues = boundary_issue_strings(boundary_issues_for_value(value, location))
    if issues:
        raise error_type(f"PRIVATE_BOUNDARY:{issues[0]}")


def parse_authority(
    value: object,
    *,
    expected_subject: tuple[str, str],
    expected_object: tuple[str, str],
    error_type: type[ErrorT],
) -> RelationshipAdapterAuthority:
    authority = require_exact_fields(
        value,
        AUTHORITY_FIELDS,
        "authority",
        error_type,
    )
    for field in AUTHORITY_FIELDS:
        if not isinstance(authority[field], str) or not authority[field]:
            raise error_type(f"STRING_REQUIRED:authority.{field}")
    for field in (
        "mappingSetId",
        "releaseId",
        "subjectSchemeId",
        "objectSchemeId",
        "rightsId",
    ):
        if not STABLE_ID.fullmatch(authority[field]):
            raise error_type(f"INVALID_STABLE_ID:authority.{field}")
    for field in (
        "mappingSetRevision",
        "subjectSchemeVersion",
        "objectSchemeVersion",
        "rightsVersion",
    ):
        if authority[field].lower() in FLOATING_VERSIONS:
            raise error_type(f"FLOATING_VERSION:authority.{field}")
    if (
        authority["subjectSchemeId"],
        authority["subjectSchemeVersion"],
    ) != expected_subject:
        raise error_type("SUBJECT_RELEASE_MISMATCH")
    if (
        authority["objectSchemeId"],
        authority["objectSchemeVersion"],
    ) != expected_object:
        raise error_type("OBJECT_RELEASE_MISMATCH")
    return RelationshipAdapterAuthority(
        mapping_set_id=authority["mappingSetId"],
        mapping_set_revision=authority["mappingSetRevision"],
        release_id=authority["releaseId"],
        subject_scheme_id=authority["subjectSchemeId"],
        subject_scheme_version=authority["subjectSchemeVersion"],
        object_scheme_id=authority["objectSchemeId"],
        object_scheme_version=authority["objectSchemeVersion"],
        rights_id=authority["rightsId"],
        rights_version=authority["rightsVersion"],
        rights_state=authority["rightsState"],
    )


def control_document(name: str) -> tuple[dict[str, Any], str]:
    path = CONFIG_ROOT / name
    from .model import read_json

    value = read_json(path)
    if not isinstance(value, dict):
        raise RelationshipAdapterError(f"CONTROL_DOCUMENT_INVALID:{name}")
    return value, file_sha256(path)


def controlled_profile(profile_id: str) -> dict[str, Any]:
    document, _ = control_document("relationship-registry-use-profiles-v1.json")
    profiles = [
        profile
        for profile in document["profiles"]
        if profile["profileId"] == profile_id
    ]
    if len(profiles) != 1:
        raise RelationshipAdapterError(f"PROFILE_NOT_UNIQUE:{profile_id}")
    return profiles[0]


def controlled_predicate(predicate_id: str) -> tuple[dict[str, Any], str]:
    document, digest = control_document("relationship-registry-predicates-v1.json")
    predicates = [
        predicate
        for predicate in document["predicates"]
        if predicate["predicateId"] == predicate_id
    ]
    if len(predicates) != 1:
        raise RelationshipAdapterError(f"PREDICATE_NOT_UNIQUE:{predicate_id}")
    return predicates[0], digest


def source_admission(mapping_set_class: str) -> dict[str, str]:
    document, _ = control_document("relationship-registry-sources-v1.json")
    sources = [
        source
        for source in document["sources"]
        if source["mappingSetClass"] == mapping_set_class
    ]
    if len(sources) != 1:
        raise RelationshipAdapterError(f"SOURCE_LOCK_NOT_UNIQUE:{mapping_set_class}")
    source = sources[0]
    return {
        "sourceId": source["sourceId"],
        "state": source["admissionState"],
        "reason": source["releaseAdmission"],
    }


def concept_ref(
    value: object,
    *,
    scheme_id: str,
    scheme_version: str,
    location: str,
    error_type: type[ErrorT],
) -> dict[str, Any]:
    concept = require_exact_fields(value, CONCEPT_FIELDS, location, error_type)
    concept_id = concept["conceptId"]
    label = concept["label"]
    locator = concept["locator"]
    if not isinstance(concept_id, str) or not concept_id:
        raise error_type(f"CONCEPT_ID_REQUIRED:{location}")
    if label is not None and not isinstance(label, str):
        raise error_type(f"LABEL_INVALID:{location}")
    if locator is not None and (
        not isinstance(locator, str) or not locator.startswith("https://")
    ):
        raise error_type(f"LOCATOR_INVALID:{location}")
    return {
        "schemeId": scheme_id,
        "schemeVersion": scheme_version,
        "conceptId": concept_id,
        "label": label,
        "locator": locator,
        "lifecycleState": "current_for_mapping",
    }


def source_specific_fields(
    value: object,
    *,
    location: str,
    error_type: type[ErrorT],
) -> list[dict[str, Any]]:
    if not isinstance(value, list):
        raise error_type(f"ARRAY_REQUIRED:{location}")
    fields: list[dict[str, Any]] = []
    names: set[str] = set()
    for index, item in enumerate(value):
        field = require_exact_fields(
            item,
            SOURCE_FIELD_FIELDS,
            f"{location}[{index}]",
            error_type,
        )
        name = field["name"]
        field_value = field["value"]
        if not isinstance(name, str) or not name or name in names:
            raise error_type(f"SOURCE_FIELD_NAME_INVALID:{location}[{index}]")
        separated_name = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", name)
        name_tokens = tuple(
            token.casefold()
            for token in re.split(r"[^A-Za-z0-9]+", separated_name)
            if token
        )
        normalized_name = "".join(name_tokens)
        private_reason: str | None = None
        if normalized_name in RELATIONSHIP_PRIVATE_SOURCE_FIELD_CANARIES:
            private_reason = "named_private_canary"
        elif "private" in name_tokens:
            private_reason = "private_qualified_field"
        elif "user" in name_tokens:
            private_reason = "user_qualified_field"
        elif "device" in name_tokens:
            private_reason = "device_qualified_field"
        elif (
            name_tokens[-1:] == ("id",)
            and not RELATIONSHIP_PUBLIC_SOURCE_FIELD_QUALIFIERS.intersection(
                name_tokens
            )
            and any(
                base in "".join(name_tokens[:-1])
                for base in RELATIONSHIP_PRIVATE_SOURCE_FIELD_ID_BASES
            )
        ):
            private_reason = "private_category_id_field"
        if private_reason is not None:
            raise error_type(
                f"PRIVATE_BOUNDARY:{location}[{index}].name:"
                f"relationship_private_field:{private_reason}"
            )
        if field_value is not None and not isinstance(
            field_value,
            (str, int, float, bool),
        ):
            raise error_type(f"SOURCE_FIELD_VALUE_INVALID:{location}[{index}]")
        if isinstance(field_value, float) and not isfinite(field_value):
            raise error_type(f"SOURCE_FIELD_VALUE_INVALID:{location}[{index}]")
        dynamic_issues = boundary_issue_strings(
            boundary_issues_for_value(
                {name: field_value},
                f"{location}[{index}]",
            )
        )
        if dynamic_issues:
            raise error_type(f"PRIVATE_BOUNDARY:{dynamic_issues[0]}")
        names.add(name)
        fields.append({"name": name, "value": field_value})
    return sorted(fields, key=lambda field: field["name"])


def build_edge(
    *,
    authority: RelationshipAdapterAuthority,
    profile_id: str,
    predicate_id: str,
    source_row: str,
    subject: dict[str, Any],
    object_: dict[str, Any],
    source_fields: list[dict[str, Any]],
    eligible_purposes: list[str] | None = None,
) -> dict[str, Any]:
    profile = controlled_profile(profile_id)
    predicate, predicate_hash = controlled_predicate(predicate_id)
    if authority.rights_state not in profile["allowedRightsStates"]:
        raise RelationshipAdapterError(
            f"RIGHTS_STATE_NOT_ALLOWED:{profile_id}:{authority.rights_state}"
        )
    endpoint_states = set(profile["requiredEndpointStates"])
    for endpoint_name, endpoint in (("subject", subject), ("object", object_)):
        lifecycle_state = endpoint.get("lifecycleState")
        if lifecycle_state not in endpoint_states:
            raise RelationshipAdapterError(
                f"ENDPOINT_STATE_NOT_ALLOWED:{profile_id}:"
                f"{endpoint_name}:{lifecycle_state}"
            )
    requested_purposes = (
        list(profile["allowedPurposes"])
        if eligible_purposes is None
        else eligible_purposes
    )
    purposes = (
        [
            purpose
            for purpose in requested_purposes
            if purpose in profile["inspectionOnlyPurposes"]
        ]
        if authority.rights_state == "inspection_only"
        else requested_purposes
    )
    if not purposes:
        raise RelationshipAdapterError(f"NO_PURPOSE_ALLOWED:{profile_id}")
    if not set(purposes) <= set(profile["allowedPurposes"]):
        raise RelationshipAdapterError(f"PURPOSE_NOT_ALLOWED:{profile_id}")
    allowed_predicates = PROFILE_PREDICATES.get(profile_id)
    if allowed_predicates is not None and predicate_id not in allowed_predicates:
        raise RelationshipAdapterError(
            f"PREDICATE_PROFILE_MISMATCH:{predicate_id}:{profile_id}"
        )
    exact_endpoint_states = PROFILE_PREDICATE_ENDPOINT_STATES.get(
        (profile_id, predicate_id)
    )
    if exact_endpoint_states is None:
        raise RelationshipAdapterError(
            f"PREDICATE_ENDPOINT_POLICY_MISSING:{profile_id}:{predicate_id}"
        )
    for endpoint_name, endpoint, allowed_states in (
        ("subject", subject, exact_endpoint_states[0]),
        ("object", object_, exact_endpoint_states[1]),
    ):
        lifecycle_state = endpoint["lifecycleState"]
        if lifecycle_state not in allowed_states:
            raise RelationshipAdapterError(
                f"PREDICATE_ENDPOINT_STATE_MISMATCH:{profile_id}:"
                f"{predicate_id}:{endpoint_name}:{lifecycle_state}"
            )
    edge_identity = {
        "mappingSetId": authority.mapping_set_id,
        "releaseId": authority.release_id,
        "sourceRow": source_row,
        "subject": {
            "schemeId": subject["schemeId"],
            "schemeVersion": subject["schemeVersion"],
            "conceptId": subject["conceptId"],
        },
        "predicateId": predicate_id,
        "direction": "subject_to_object",
        "object": {
            "schemeId": object_["schemeId"],
            "schemeVersion": object_["schemeVersion"],
            "conceptId": object_["conceptId"],
        },
    }
    digest = stable_hash(edge_identity)
    return {
        "schemaVersion": "relationship-edge-v1",
        "kind": "relationshipEdge",
        "edgeId": f"relationship.edge.{digest}",
        "revision": "1.0.0",
        "mappingSet": {
            "mappingSetId": authority.mapping_set_id,
            "revision": authority.mapping_set_revision,
            "releaseId": authority.release_id,
        },
        "subject": subject,
        "predicate": {
            "predicateId": predicate_id,
            "vocabularyVersion": predicate["vocabularyVersion"],
            "vocabularyHash": predicate_hash,
        },
        "direction": "subject_to_object",
        "object": object_,
        "sourceMetadata": {
            "sourceRow": source_row,
            "method": "source_published",
            "qaPartition": "source_published",
            "sourceSpecificFields": source_fields,
        },
        "review": {
            "provenanceClass": "official",
            "state": "source_published",
            "decisionBy": None,
            "decisionAt": None,
            "decisionReason": None,
        },
        "useProfileBinding": {
            "profileId": profile["profileId"],
            "revision": profile["revision"],
        },
        "eligiblePurposes": purposes,
        "forbiddenPropagation": list(profile["forbiddenPropagation"]),
        "nonClaims": list(profile["nonClaims"]),
        "rightsBinding": {
            "rightsId": authority.rights_id,
            "version": authority.rights_version,
            "state": authority.rights_state,
        },
        "freshness": "current",
        "conflictState": "none",
    }
