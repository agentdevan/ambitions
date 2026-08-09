from __future__ import annotations

import re
from math import isfinite
from typing import Any

from .model import stable_hash
from .relationship_registry_models import (
    FLOATING_VERSIONS,
    STABLE_ID,
    RelationshipAdapterError,
    concept_ref,
    control_document,
    controlled_predicate,
    controlled_profile,
    parse_authority,
    require_exact_fields,
    require_public_fixture,
    source_admission,
    source_specific_fields,
)


class RelationshipCandidateAdapterError(RelationshipAdapterError):
    pass


DOCUMENT_FIELDS = frozenset(
    {"schemaVersion", "kind", "fixtureClass", "authority", "rows"}
)
ROW_FIELDS = frozenset(
    {
        "sourceRow",
        "candidateId",
        "candidateKind",
        "sourceState",
        "reviewState",
        "reviewDecision",
        "proposedPredicateId",
        "direction",
        "subjectConcept",
        "objectConcept",
        "mappingJustification",
        "evidence",
        "confidence",
        "similarity",
        "method",
        "sourceSpecificFields",
    }
)
METHOD_FIELDS = frozenset(
    {"methodClass", "tool", "toolVersion", "model", "configHash", "seed"}
)
PROPOSED_PREDICATES = frozenset(
    {
        "skos:exactMatch",
        "skos:closeMatch",
        "skos:broadMatch",
        "skos:narrowMatch",
        "skos:relatedMatch",
    }
)
CANDIDATE_METHODS = {
    "wikidata": {
        "methodClass": "community_submitted",
        "provenanceClass": "community",
        "modelRequired": False,
        "seedRequired": False,
    },
    "lexical": {
        "methodClass": "lexical",
        "provenanceClass": "lexical_model",
        "modelRequired": False,
        "seedRequired": False,
    },
    "model": {
        "methodClass": "model_generated",
        "provenanceClass": "lexical_model",
        "modelRequired": True,
        "seedRequired": True,
    },
}
EXPECTED_SYNTHETIC_AUTHORITY = {
    "mappingSetId": "ambitions.mapping-candidates.synthetic",
    "mappingSetRevision": "1.0.0",
    "releaseId": "ambitions.mapping-candidates.synthetic-v1",
    "subjectSchemeId": "synthetic-source-taxonomy",
    "subjectSchemeVersion": "fixture-1.0.0",
    "objectSchemeId": "synthetic-target-taxonomy",
    "objectSchemeVersion": "fixture-1.0.0",
    "rightsId": "ambitions.synthetic.relationship-rights",
    "rightsVersion": "1.0.0",
    "rightsState": "inspection_only",
}
SHA256 = re.compile(r"^[a-f0-9]{64}$")
PINNED_IDENTITY = re.compile(r"[A-Za-z0-9][A-Za-z0-9._:+-]{0,127}")


def _score(value: object, *, field: str) -> float | None:
    if value is None:
        return None
    if (
        isinstance(value, bool)
        or not isinstance(value, (int, float))
        or not isfinite(value)
        or value < 0
        or value > 1
    ):
        raise RelationshipCandidateAdapterError(f"{field.upper()}_INVALID")
    return float(value)


def _candidate_edge_id(*, mapping_set_id: str, candidate_id: str) -> str:
    return f"relationship.edge.{stable_hash({'mappingSetId': mapping_set_id, 'candidateId': candidate_id})}"


def _pinned_identity(value: object, *, location: str) -> str:
    if not isinstance(value, str) or not PINNED_IDENTITY.fullmatch(value):
        raise RelationshipCandidateAdapterError(f"PINNED_IDENTITY_INVALID:{location}")
    if value.casefold() in FLOATING_VERSIONS:
        raise RelationshipCandidateAdapterError(f"FLOATING_VERSION:{location}")
    return value


def _method(
    value: object,
    *,
    candidate_kind: str,
    location: str,
) -> dict[str, Any]:
    method = require_exact_fields(
        value,
        METHOD_FIELDS,
        location,
        RelationshipCandidateAdapterError,
    )
    policy = CANDIDATE_METHODS[candidate_kind]
    if method["methodClass"] != policy["methodClass"]:
        raise RelationshipCandidateAdapterError(
            f"METHOD_KIND_MISMATCH:{candidate_kind}:{method['methodClass']}"
        )
    tool = method["tool"]
    if not isinstance(tool, str) or not tool:
        raise RelationshipCandidateAdapterError(f"METHOD_FIELD_INVALID:{location}.tool")
    tool_version = _pinned_identity(
        method["toolVersion"],
        location=f"{location}.toolVersion",
    )
    model = method["model"]
    if policy["modelRequired"]:
        model = _pinned_identity(model, location=f"{location}.model")
    elif model is not None:
        raise RelationshipCandidateAdapterError(f"MODEL_NOT_ALLOWED:{candidate_kind}")
    config_hash = method["configHash"]
    if not isinstance(config_hash, str) or not SHA256.fullmatch(config_hash):
        raise RelationshipCandidateAdapterError(f"CONFIG_HASH_INVALID:{candidate_kind}")
    seed = method["seed"]
    if policy["seedRequired"]:
        if isinstance(seed, bool) or not isinstance(seed, int) or seed < 0:
            raise RelationshipCandidateAdapterError(f"SEED_REQUIRED:{candidate_kind}")
    elif seed is not None:
        raise RelationshipCandidateAdapterError(f"SEED_NOT_ALLOWED:{candidate_kind}")
    return {
        "methodClass": method["methodClass"],
        "tool": tool,
        "toolVersion": tool_version,
        "model": model,
        "configHash": config_hash,
        "seed": seed,
    }


def _candidate_edge(
    *,
    authority,
    profile: dict[str, Any],
    candidate_id: str,
    candidate_kind: str,
    source_row: str,
    source_state: str,
    review_state: str,
    review_decision: str,
    proposed_predicate_id: str,
    proposed_direction: str,
    subject: dict[str, Any],
    object_: dict[str, Any],
    source_fields: list[dict[str, Any]],
    method: dict[str, Any],
    provenance_class: str,
    mapping_justification: str,
    evidence: list[str],
    confidence: float | None,
    similarity: float | None,
) -> dict[str, Any]:
    predicate, predicate_hash = controlled_predicate("ambitions:candidateRelationship")
    if predicate["family"] != "unapproved_candidate":
        raise RelationshipCandidateAdapterError("CANDIDATE_PREDICATE_WIDENED")
    revision_authority = {
        "candidateId": candidate_id,
        "candidateKind": candidate_kind,
        "mappingSet": authority.as_dict(),
        "sourceRow": source_row,
        "sourceState": source_state,
        "reviewState": review_state,
        "reviewDecision": review_decision,
        "subject": subject,
        "proposedPredicateId": proposed_predicate_id,
        "proposedDirection": proposed_direction,
        "object": object_,
        "method": method,
        "evidence": evidence,
        "mappingJustification": mapping_justification,
        "confidence": confidence,
        "similarity": similarity,
        "sourceSpecificFields": source_fields,
    }
    source_metadata: dict[str, Any] = {
        "sourceRow": source_row,
        "mappingJustification": mapping_justification,
        "evidence": evidence,
        "method": method["methodClass"],
        "confidence": confidence,
        "similarity": similarity,
        "mappingTool": method["tool"],
        "mappingToolVersion": method["toolVersion"],
        "mappingModel": method["model"],
        "qaPartition": "candidate",
        "sourceSpecificFields": source_fields,
    }
    source_metadata = {
        key: value for key, value in source_metadata.items() if value is not None
    }
    return {
        "schemaVersion": "relationship-edge-v1",
        "kind": "relationshipEdge",
        "edgeId": _candidate_edge_id(
            mapping_set_id=authority.mapping_set_id,
            candidate_id=candidate_id,
        ),
        "revision": f"sha256:{stable_hash(revision_authority)}",
        "mappingSet": {
            "mappingSetId": authority.mapping_set_id,
            "revision": authority.mapping_set_revision,
            "releaseId": authority.release_id,
        },
        "subject": subject,
        "predicate": {
            "predicateId": "ambitions:candidateRelationship",
            "vocabularyVersion": predicate["vocabularyVersion"],
            "vocabularyHash": predicate_hash,
        },
        "direction": "subject_to_object",
        "object": object_,
        "sourceMetadata": source_metadata,
        "review": {
            "provenanceClass": provenance_class,
            "state": "restricted",
            "decisionBy": None,
            "decisionAt": None,
            "decisionReason": (
                "Candidate remains restricted pending independent review."
            ),
        },
        "useProfileBinding": {
            "profileId": profile["profileId"],
            "revision": profile["revision"],
        },
        "eligiblePurposes": ["review_only"],
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


def adapt_candidate_document(document: object) -> dict[str, Any]:
    value = require_exact_fields(
        document,
        DOCUMENT_FIELDS,
        "document",
        RelationshipCandidateAdapterError,
    )
    if value["schemaVersion"] != "relationship-registry-mapping-candidates-fixture-v1":
        raise RelationshipCandidateAdapterError("SCHEMA_VERSION_UNSUPPORTED")
    if value["kind"] != "relationshipRegistryMappingCandidatesFixture":
        raise RelationshipCandidateAdapterError("KIND_UNSUPPORTED")
    if value["fixtureClass"] != "synthetic_contract":
        raise RelationshipCandidateAdapterError("FIXTURE_CLASS_UNSUPPORTED")
    require_public_fixture(
        value,
        location="relationship-registry-mapping-candidates-fixture",
        error_type=RelationshipCandidateAdapterError,
    )
    authority = parse_authority(
        value["authority"],
        expected_subject=("synthetic-source-taxonomy", "fixture-1.0.0"),
        expected_object=("synthetic-target-taxonomy", "fixture-1.0.0"),
        error_type=RelationshipCandidateAdapterError,
    )
    if authority.as_dict() != EXPECTED_SYNTHETIC_AUTHORITY:
        raise RelationshipCandidateAdapterError("SYNTHETIC_AUTHORITY_MISMATCH")

    profile = controlled_profile("mapping-candidate-review-v1")
    profile_document, _ = control_document("relationship-registry-use-profiles-v1.json")
    if (
        profile_document["sourcePredicateGrantsEligibility"] is not False
        or profile["allowedPurposes"] != ["review_only"]
        or profile["allowedDirections"] != ["subject_to_object"]
        or profile["requiredReviewStates"] != ["restricted"]
        or profile["allowedRightsStates"] != ["inspection_only"]
        or profile["inspectionOnlyPurposes"] != ["review_only"]
    ):
        raise RelationshipCandidateAdapterError("REVIEW_PROFILE_WIDENED")
    admission = source_admission("mapping_candidate")
    if admission["state"] != "unavailable":
        raise RelationshipCandidateAdapterError("PRODUCTION_ADMISSION_WIDENED")
    if not isinstance(value["rows"], list) or not value["rows"]:
        raise RelationshipCandidateAdapterError("ROWS_REQUIRED")

    candidates: list[dict[str, Any]] = []
    source_rows: set[str] = set()
    candidate_ids: set[str] = set()
    for index, raw_row in enumerate(value["rows"]):
        row = require_exact_fields(
            raw_row,
            ROW_FIELDS,
            f"rows[{index}]",
            RelationshipCandidateAdapterError,
        )
        source_row = row["sourceRow"]
        if not isinstance(source_row, str) or not source_row:
            raise RelationshipCandidateAdapterError(
                f"SOURCE_ROW_REQUIRED:rows[{index}]"
            )
        if source_row in source_rows:
            raise RelationshipCandidateAdapterError(
                f"DUPLICATE_SOURCE_ROW:{source_row}"
            )
        source_rows.add(source_row)

        candidate_id = row["candidateId"]
        if not isinstance(candidate_id, str) or not STABLE_ID.fullmatch(candidate_id):
            raise RelationshipCandidateAdapterError(
                f"CANDIDATE_ID_INVALID:rows[{index}]"
            )
        if candidate_id in candidate_ids:
            raise RelationshipCandidateAdapterError(
                f"DUPLICATE_CANDIDATE:{candidate_id}"
            )
        candidate_ids.add(candidate_id)

        candidate_kind = row["candidateKind"]
        if (
            not isinstance(candidate_kind, str)
            or candidate_kind not in CANDIDATE_METHODS
        ):
            raise RelationshipCandidateAdapterError(
                f"CANDIDATE_KIND_NOT_ALLOWED:{candidate_kind}"
            )
        if row["sourceState"] != "candidate":
            raise RelationshipCandidateAdapterError(
                f"SOURCE_STATE_NOT_ALLOWED:{row['sourceState']}"
            )
        if row["reviewState"] != "restricted":
            raise RelationshipCandidateAdapterError(
                f"REVIEW_STATE_NOT_ALLOWED:{row['reviewState']}"
            )
        if row["reviewDecision"] != "pending_review":
            raise RelationshipCandidateAdapterError(
                f"REVIEW_DECISION_NOT_ALLOWED:{row['reviewDecision']}"
            )
        if row["direction"] != "subject_to_object":
            raise RelationshipCandidateAdapterError(
                f"DIRECTION_NOT_ALLOWED:{row['direction']}"
            )

        proposed_predicate_id = row["proposedPredicateId"]
        if (
            not isinstance(proposed_predicate_id, str)
            or proposed_predicate_id not in PROPOSED_PREDICATES
        ):
            raise RelationshipCandidateAdapterError(
                f"PROPOSED_PREDICATE_NOT_ALLOWED:{proposed_predicate_id}"
            )
        proposed_predicate, proposed_predicate_hash = controlled_predicate(
            proposed_predicate_id
        )
        if proposed_predicate["family"] != "official_cross_scheme_mapping":
            raise RelationshipCandidateAdapterError(
                f"PROPOSED_PREDICATE_FAMILY_MISMATCH:{proposed_predicate_id}"
            )

        subject = concept_ref(
            row["subjectConcept"],
            scheme_id=authority.subject_scheme_id,
            scheme_version=authority.subject_scheme_version,
            location=f"rows[{index}].subjectConcept",
            error_type=RelationshipCandidateAdapterError,
        )
        object_ = concept_ref(
            row["objectConcept"],
            scheme_id=authority.object_scheme_id,
            scheme_version=authority.object_scheme_version,
            location=f"rows[{index}].objectConcept",
            error_type=RelationshipCandidateAdapterError,
        )
        mapping_justification = row["mappingJustification"]
        if not isinstance(mapping_justification, str) or not mapping_justification:
            raise RelationshipCandidateAdapterError("MAPPING_JUSTIFICATION_INVALID")
        evidence = row["evidence"]
        if (
            not isinstance(evidence, list)
            or not all(isinstance(item, str) and item for item in evidence)
            or len(evidence) != len(set(evidence))
        ):
            raise RelationshipCandidateAdapterError("EVIDENCE_INVALID")
        confidence = _score(row["confidence"], field="confidence")
        similarity = _score(row["similarity"], field="similarity")
        method = _method(
            row["method"],
            candidate_kind=candidate_kind,
            location=f"rows[{index}].method",
        )

        derived_fields: list[dict[str, Any]] = [
            {"name": "candidateId", "value": candidate_id},
            {"name": "candidateKind", "value": candidate_kind},
            {"name": "methodConfigHash", "value": method["configHash"]},
            {"name": "proposedDirection", "value": "subject_to_object"},
            {"name": "proposedPredicateId", "value": proposed_predicate_id},
            {"name": "reviewDecision", "value": "pending_review"},
            {"name": "sourceState", "value": "candidate"},
        ]
        if method["seed"] is not None:
            derived_fields.append({"name": "methodSeed", "value": method["seed"]})
        fields = source_specific_fields(
            [*row["sourceSpecificFields"], *derived_fields]
            if isinstance(row["sourceSpecificFields"], list)
            else row["sourceSpecificFields"],
            location=f"rows[{index}].sourceSpecificFields",
            error_type=RelationshipCandidateAdapterError,
        )
        edge = _candidate_edge(
            authority=authority,
            profile=profile,
            candidate_id=candidate_id,
            candidate_kind=candidate_kind,
            source_row=source_row,
            source_state=row["sourceState"],
            review_state=row["reviewState"],
            review_decision=row["reviewDecision"],
            proposed_predicate_id=proposed_predicate_id,
            proposed_direction=row["direction"],
            subject=subject,
            object_=object_,
            source_fields=fields,
            method=method,
            provenance_class=CANDIDATE_METHODS[candidate_kind]["provenanceClass"],
            mapping_justification=mapping_justification,
            evidence=list(evidence),
            confidence=confidence,
            similarity=similarity,
        )

        candidates.append(
            {
                "candidateId": candidate_id,
                "candidateKind": candidate_kind,
                "sourceState": "candidate",
                "reviewState": "restricted",
                "reviewDecision": "pending_review",
                "proposedPredicateId": proposed_predicate_id,
                "proposedPredicateVocabularyVersion": proposed_predicate[
                    "vocabularyVersion"
                ],
                "proposedPredicateVocabularyHash": proposed_predicate_hash,
                "proposedDirection": "subject_to_object",
                "confidence": confidence,
                "similarity": similarity,
                "consumerUseEnabled": False,
                "edge": edge,
            }
        )

    return {
        "schemaVersion": "relationship-registry-mapping-candidates-result-v1",
        "kind": "relationshipRegistryMappingCandidatesResult",
        "fixtureClass": "synthetic_contract",
        "authority": authority.as_dict(),
        "productionAdmission": admission,
        "reviewPolicy": {
            "profileId": profile["profileId"],
            "profileRevision": profile["revision"],
            "sourcePredicateGrantsEligibility": False,
            "confidenceGrantsEligibility": False,
            "consumerUseEnabled": False,
        },
        "candidates": sorted(candidates, key=lambda item: item["candidateId"]),
    }
