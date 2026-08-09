from __future__ import annotations

import json
from copy import deepcopy
from pathlib import Path

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[4]
CONTRACTS = ROOT / "tools/source-atlas/foundry/contracts"
CONFIG = ROOT / "tools/source-atlas/config"

SCHEMA_FILES = (
    "relationship-registry-release-v1.schema.json",
    "relationship-mapping-set-v1.schema.json",
    "relationship-edge-v1.schema.json",
    "relationship-use-profile-v1.schema.json",
    "relationship-coverage-v1.schema.json",
)

FAMILIES = {
    "within_scheme_relation",
    "scheme_version_migration",
    "official_cross_scheme_mapping",
    "publisher_authored_alignment",
    "current_authority_reference",
    "unapproved_candidate",
}
PURPOSES = {
    "inspection",
    "search_expansion",
    "destination_discovery",
    "explanation",
    "source_overlay_join",
    "version_migration",
    "review_only",
    "unavailable",
}
RIGHTS_STATES = {
    "approved",
    "attribution_required",
    "transformation_restricted",
    "inspection_only",
    "review_required",
    "withdrawn",
}
RIGHTS_OPERATIONS = {"package", "transform", "display", "retain", "derive"}
SKOS_PREDICATES = {
    "skos:exactMatch",
    "skos:closeMatch",
    "skos:broadMatch",
    "skos:narrowMatch",
    "skos:relatedMatch",
}
MANDATORY_FORBIDDEN_PROPAGATION = {
    "chain_inference",
    "inverse_inference",
    "claim_transfer",
    "unrelated_claim_families",
    "qualification",
    "credit",
    "acceptance",
    "user_capability",
}


def _load(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    assert isinstance(value, dict)
    return value


def _schema(name: str) -> dict:
    return _load(CONTRACTS / name)


def _config(name: str) -> dict:
    return _load(CONFIG / name)


def _validator(schema: dict) -> Draft202012Validator:
    Draft202012Validator.check_schema(schema)
    return Draft202012Validator(
        schema,
        format_checker=Draft202012Validator.FORMAT_CHECKER,
    )


def _definition_schema(schema: dict, name: str) -> dict:
    return {
        "$schema": schema["$schema"],
        "$ref": f"#/$defs/{name}",
        "$defs": schema["$defs"],
    }


def _assert_invalid(schema: dict, instance: object) -> None:
    assert list(_validator(schema).iter_errors(instance))


def _complete_edge(profile: dict) -> dict:
    concept = {
        "schemeId": "example.scheme",
        "schemeVersion": "1.0.0",
        "conceptId": "example-concept",
        "label": None,
        "locator": None,
        "lifecycleState": profile["requiredEndpointStates"][0],
    }
    return {
        "schemaVersion": "relationship-edge-v1",
        "kind": "relationshipEdge",
        "edgeId": "relationship.edge",
        "revision": "1.0.0",
        "mappingSet": {
            "mappingSetId": "relationship.mapping",
            "revision": "1.0.0",
            "releaseId": "relationship.mapping.release",
        },
        "subject": concept,
        "predicate": {
            "predicateId": "cip:unchanged",
            "vocabularyVersion": "1.0.0",
            "vocabularyHash": "a" * 64,
        },
        "direction": profile["allowedDirections"][0],
        "object": {**concept, "conceptId": "example-object"},
        "sourceMetadata": {"sourceRow": "row-1"},
        "review": {
            "provenanceClass": "official",
            "state": profile["requiredReviewStates"][0],
            "decisionBy": None,
            "decisionAt": None,
            "decisionReason": None,
        },
        "useProfileBinding": {
            "profileId": profile["profileId"],
            "revision": profile["revision"],
        },
        "eligiblePurposes": [profile["allowedPurposes"][0]],
        "forbiddenPropagation": profile["forbiddenPropagation"],
        "nonClaims": profile["nonClaims"],
        "rightsBinding": {
            "rightsId": "relationship.rights",
            "version": "1.0.0",
            "state": profile["allowedRightsStates"][0],
        },
        "freshness": "current",
        "conflictState": "none",
    }


def test_all_t1_schemas_are_closed_versioned_json_schema_contracts() -> None:
    for name in SCHEMA_FILES:
        schema = _schema(name)
        _validator(schema)
        assert schema["$schema"] == "https://json-schema.org/draft/2020-12/schema"
        assert schema["$id"].endswith(name)
        assert schema["type"] == "object"
        assert schema["additionalProperties"] is False
        assert "schemaVersion" in schema["required"]
        assert "const" in schema["properties"]["schemaVersion"]


def test_nested_authority_objects_reject_unknown_metadata() -> None:
    for name in SCHEMA_FILES:
        pending = [_schema(name)]
        while pending:
            value = pending.pop()
            if isinstance(value, dict):
                if value.get("type") == "object" and "properties" in value:
                    assert value.get("additionalProperties") is False, (name, value)
                pending.extend(value.values())
            elif isinstance(value, list):
                pending.extend(value)


def test_edge_contract_freezes_families_predicates_and_purpose_boundaries() -> None:
    schema = _schema("relationship-edge-v1.schema.json")
    defs = schema["$defs"]

    assert set(defs["family"]["enum"]) == FAMILIES
    assert SKOS_PREDICATES < set(defs["predicate"]["enum"])
    assert "ambitions:preparation" in defs["predicate"]["enum"]
    assert set(defs["purpose"]["enum"]) == PURPOSES
    assert MANDATORY_FORBIDDEN_PROPAGATION < set(defs["forbidden"]["enum"])
    assert "equivalent" not in json.dumps(schema).lower()

    metadata = schema["properties"]["sourceMetadata"]
    assert metadata["additionalProperties"] is False
    assert metadata["required"] == ["sourceRow"]
    assert "sourceSpecificFields" in metadata["properties"]
    assert "review" in schema["required"]
    assert "sourceMetadata" in schema["required"]
    predicate_binding = schema["properties"]["predicate"]
    assert set(predicate_binding["required"]) == {
        "predicateId",
        "vocabularyVersion",
        "vocabularyHash",
    }
    assert "family" not in predicate_binding["properties"]
    assert set(
        schema["properties"]["useProfileBinding"]["properties"]["profileId"]["enum"]
    ) == {
        "cip-edition-migration-v1",
        "cip-soc-relevance-v1",
        "onet-soc-overlay-v1",
        "onet-esco-blocked-v1",
        "publisher-alignment-blocked-v1",
        "mapping-candidate-review-v1",
    }


def test_mapping_set_contract_binds_family_rights_and_exact_endpoint_releases() -> None:
    schema = _schema("relationship-mapping-set-v1.schema.json")
    assert "relationshipFamily" in schema["required"]
    assert set(schema["properties"]["relationshipFamily"]["enum"]) == FAMILIES
    assert "rightsBinding" in schema["required"]
    endpoints = schema["properties"]["endpointSchemes"]
    assert endpoints["required"] == ["subject", "object"]
    endpoint = schema["$defs"]["endpointScheme"]
    assert {
        "schemeId",
        "releaseId",
        "version",
        "manifestHash",
        "contentHash",
        "rightsBinding",
    } <= set(endpoint["required"])
    assert "latest" in schema["$defs"]["nonFloatingVersion"]["not"]["enum"]


def test_registry_release_binds_every_contract_and_policy_revision() -> None:
    schema = _schema("relationship-registry-release-v1.schema.json")
    assert {
        "registrySchema",
        "profileVocabulary",
        "predicateVocabulary",
        "sssomCompatibilityProfile",
        "forbiddenPropagationPolicy",
        "rightsPolicy",
    } <= set(schema["required"])
    for name in (
        "registrySchema",
        "profileVocabulary",
        "predicateVocabulary",
        "sssomCompatibilityProfile",
        "forbiddenPropagationPolicy",
        "rightsPolicy",
    ):
        assert schema["properties"][name] == {"$ref": "#/$defs/versionedHash"}


def test_use_profile_contract_is_closed_and_forbids_product_inference() -> None:
    schema = _schema("relationship-use-profile-v1.schema.json")
    assert set(schema["$defs"]["purpose"]["enum"]) == PURPOSES
    assert (
        set(schema["properties"]["allowedRightsStates"]["items"]["enum"])
        < RIGHTS_STATES
    )
    inference = schema["properties"]["inferencePolicy"]["properties"]
    assert inference["chain"]["const"] == "forbidden"
    assert inference["transitive"]["const"] == "forbidden"
    assert inference["claimPropagation"]["const"] == "forbidden"
    assert len(schema["enum"]) == 6


def test_predicate_config_preserves_source_semantics_without_product_inference() -> (
    None
):
    config = _config("relationship-registry-predicates-v1.json")
    predicates = {item["predicateId"]: item for item in config["predicates"]}

    assert config["unknownPredicatePolicy"] == "reject"
    assert SKOS_PREDICATES < set(predicates)
    assert "ambitions:preparation" in predicates
    assert predicates["skos:exactMatch"]["sourceTransitive"] is True
    assert config["productInferenceDefaults"] == {
        "chain": "forbidden",
        "transitive": "forbidden",
        "inverse": "stored_edge_only",
        "symmetric": "stored_edge_only",
        "claimPropagation": "forbidden",
    }
    for predicate in predicates.values():
        assert predicate["family"] in FAMILIES
        assert predicate["vocabularyVersion"] == "1.0.0"
        assert predicate["sourceMeaning"]
        assert predicate["productExplanation"]


def test_profiles_are_revision_bound_and_never_enable_inference() -> None:
    config = _config("relationship-registry-use-profiles-v1.json")
    assert config["unknownProfilePolicy"] == "reject"
    assert config["sourcePredicateGrantsEligibility"] is False

    for profile in config["profiles"]:
        expected_revision = (
            "1.1.0" if profile["profileId"] == "cip-edition-migration-v1" else "1.0.0"
        )
        assert profile["revision"] == expected_revision
        assert set(profile["allowedPurposes"]) <= PURPOSES
        assert profile["forbiddenPropagation"]
        assert MANDATORY_FORBIDDEN_PROPAGATION <= set(profile["forbiddenPropagation"])
        assert profile["nonClaims"]
        assert profile["inferencePolicy"] == {
            "chain": "forbidden",
            "transitive": "forbidden",
            "inverse": "stored_edge_only",
            "symmetric": "stored_edge_only",
            "claimPropagation": "forbidden",
        }

    profiles = {profile["profileId"]: profile for profile in config["profiles"]}
    for profile_id in ("onet-esco-blocked-v1", "publisher-alignment-blocked-v1"):
        profile = profiles[profile_id]
        assert profile["allowedPurposes"] == ["unavailable"]
        assert profile["allowedDirections"] == []
        assert profile["allowedRightsStates"] == []


def test_sources_fail_closed_until_exact_release_and_rights_locks_exist() -> None:
    config = _config("relationship-registry-sources-v1.json")
    assert config["publicOnly"] is True
    assert config["requestPolicy"] == {
        "fixedReleaseIdsOnly": True,
        "allowUserContext": False,
        "allowArbitraryLocator": False,
        "allowQueryDerivedAcquisition": False,
    }
    assert {source["mappingSetClass"] for source in config["sources"]} == {
        "cip_edition_migration",
        "cip_soc_relevance",
        "onet_soc_relationship",
        "onet_esco_mapping",
        "publisher_alignment",
        "mapping_candidate",
    }
    for source in config["sources"]:
        assert source["admissionState"] == "unavailable"
        assert source["releaseAdmission"].startswith(
            ("blocked_", "review_artifact_only_")
        )
        assert len(source["requiredEndpointSchemes"]) == 2

    sources = {source["mappingSetClass"]: source for source in config["sources"]}
    assert sources["publisher_alignment"]["publisher"] is None
    assert all(
        endpoint["schemeId"] is None and endpoint["requiredVersion"] is None
        for endpoint in sources["publisher_alignment"]["requiredEndpointSchemes"]
    )
    assert all(
        endpoint["schemeId"] is None and endpoint["requiredVersion"] is None
        for endpoint in sources["mapping_candidate"]["requiredEndpointSchemes"]
    )


def test_rights_are_versioned_operation_specific_and_unknowns_deny_all() -> None:
    config = _config("relationship-registry-rights-v1.json")
    assert config["unknownRightsPolicy"] == "deny_all_and_quarantine"
    assert config["schemaLicenseNeverAuthorizesSourceContent"] is True
    assert set(config["operationVocabulary"]) == RIGHTS_OPERATIONS
    for rights in config["rights"]:
        assert rights["version"] == "1.0.0"
        assert rights["state"] in RIGHTS_STATES
        assert set(rights["allowedOperations"]) <= RIGHTS_OPERATIONS
        assert rights["admissionState"] == "unavailable"


def test_controlled_contracts_contain_no_floating_or_generic_authority_tokens() -> None:
    encoded = (
        "\n".join(
            (CONTRACTS / name).read_text(encoding="utf-8") for name in SCHEMA_FILES
        )
        + "\n"
        + "\n".join(
            path.read_text(encoding="utf-8")
            for path in sorted(CONFIG.glob("relationship-registry-*.json"))
        )
    )
    lowered = encoded.lower()
    for forbidden in (
        '"equivalent"',
        '"generic_equivalence"',
        '"bidirectional"',
        '"truth"',
    ):
        assert forbidden not in lowered


def test_controlled_configuration_documents_are_machine_validated_fail_closed() -> None:
    edge_schema = _schema("relationship-edge-v1.schema.json")
    profile_schema = _schema("relationship-use-profile-v1.schema.json")
    mapping_schema = _schema("relationship-mapping-set-v1.schema.json")
    bindings = (
        (
            _definition_schema(edge_schema, "predicateVocabularyDocument"),
            _config("relationship-registry-predicates-v1.json"),
        ),
        (
            _definition_schema(profile_schema, "profileVocabularyDocument"),
            _config("relationship-registry-use-profiles-v1.json"),
        ),
        (
            _definition_schema(mapping_schema, "sourceLockDocument"),
            _config("relationship-registry-sources-v1.json"),
        ),
        (
            _definition_schema(mapping_schema, "rightsPolicyDocument"),
            _config("relationship-registry-rights-v1.json"),
        ),
    )
    for schema, document in bindings:
        _validator(schema).validate(document)
        unknown = deepcopy(document)
        unknown["unexpectedAuthority"] = True
        _assert_invalid(schema, unknown)

    predicate_schema, predicates = bindings[0]
    contradictory = deepcopy(predicates)
    exact_match = next(
        item
        for item in contradictory["predicates"]
        if item["predicateId"] == "skos:exactMatch"
    )
    exact_match["family"] = "unapproved_candidate"
    exact_match["sourceTransitive"] = False
    exact_match["inversePredicateId"] = None
    _assert_invalid(predicate_schema, contradictory)

    profile_document_schema, profiles = bindings[1]
    broadened = deepcopy(profiles)
    blocked = next(
        item
        for item in broadened["profiles"]
        if item["profileId"] == "onet-esco-blocked-v1"
    )
    blocked["allowedPurposes"] = ["search_expansion"]
    blocked["allowedDirections"] = ["subject_to_object"]
    blocked["allowedRightsStates"] = ["inspection_only"]
    _assert_invalid(profile_document_schema, broadened)

    missing_boundary = deepcopy(profiles)
    missing_boundary["profiles"][0]["forbiddenPropagation"].remove("claim_transfer")
    _assert_invalid(profile_document_schema, missing_boundary)

    rights_schema, rights = bindings[3]
    escalated_rights = deepcopy(rights)
    escalated_rights["rights"][0]["state"] = "approved"
    escalated_rights["rights"][0]["allowedOperations"] = ["package"]
    escalated_rights["rights"][0]["admissionState"] = "available"
    _assert_invalid(rights_schema, escalated_rights)


def test_complete_edges_cannot_override_bound_profile_authority() -> None:
    schema = _schema("relationship-edge-v1.schema.json")
    validator = _validator(schema)
    profile_document = _config("relationship-registry-use-profiles-v1.json")
    profiles = {
        profile["profileId"]: profile for profile in profile_document["profiles"]
    }
    executable = [
        profile for profile in profiles.values() if profile["allowedDirections"]
    ]
    blocked = [
        profile for profile in profiles.values() if not profile["allowedDirections"]
    ]

    for profile in executable:
        edge = _complete_edge(profile)
        validator.validate(edge)

        disallowed_purpose = next(
            purpose for purpose in PURPOSES if purpose not in profile["allowedPurposes"]
        )
        widened_purpose = deepcopy(edge)
        widened_purpose["eligiblePurposes"] = [disallowed_purpose]
        _assert_invalid(schema, widened_purpose)

        reversed_edge = deepcopy(edge)
        reversed_edge["direction"] = "object_to_subject"
        _assert_invalid(schema, reversed_edge)

        wrong_review = deepcopy(edge)
        wrong_review["review"]["state"] = (
            "restricted"
            if "restricted" not in profile["requiredReviewStates"]
            else "approved"
        )
        _assert_invalid(schema, wrong_review)

        stale_endpoint = deepcopy(edge)
        stale_endpoint["subject"]["lifecycleState"] = "changed"
        _assert_invalid(schema, stale_endpoint)

        broadened_rights = deepcopy(edge)
        broadened_rights["rightsBinding"]["state"] = "review_required"
        _assert_invalid(schema, broadened_rights)

        weakened_boundary = deepcopy(edge)
        weakened_boundary["forbiddenPropagation"] = profile["forbiddenPropagation"][1:]
        _assert_invalid(schema, weakened_boundary)

        rewritten_non_claims = deepcopy(edge)
        rewritten_non_claims["nonClaims"] = ["broader authority"]
        _assert_invalid(schema, rewritten_non_claims)

        if "inspection_only" in profile["allowedRightsStates"]:
            inspection_only = deepcopy(edge)
            inspection_only["rightsBinding"]["state"] = "inspection_only"
            inspection_only["eligiblePurposes"] = profile["inspectionOnlyPurposes"]
            validator.validate(inspection_only)

            executable_with_inspection_rights = [
                purpose
                for purpose in profile["allowedPurposes"]
                if purpose not in profile["inspectionOnlyPurposes"]
            ]
            if executable_with_inspection_rights:
                inspection_escalation = deepcopy(inspection_only)
                inspection_escalation["eligiblePurposes"] = [
                    executable_with_inspection_rights[0]
                ]
                _assert_invalid(schema, inspection_escalation)

    template = _complete_edge(executable[0])
    for profile in blocked:
        unavailable_edge = deepcopy(template)
        unavailable_edge["useProfileBinding"]["profileId"] = profile["profileId"]
        unavailable_edge["eligiblePurposes"] = ["unavailable"]
        unavailable_edge["review"]["state"] = "restricted"
        unavailable_edge["rightsBinding"]["state"] = "inspection_only"
        _assert_invalid(schema, unavailable_edge)


def test_registry_release_rejects_role_confusion_and_floating_bindings() -> None:
    schema = _schema("relationship-registry-release-v1.schema.json")
    digest = "a" * 64
    binding = {"id": "contract.binding", "version": "1.0.0", "contentHash": digest}
    release = {
        "schemaVersion": "relationship-registry-release-v1",
        "kind": "relationshipRegistryRelease",
        "registryId": "relationship.registry",
        "releaseId": "relationship.registry.release",
        "revision": "1.0.0",
        "createdAt": "2026-08-08T00:00:00Z",
        "registrySchema": binding,
        "profileVocabulary": binding,
        "predicateVocabulary": binding,
        "sssomCompatibilityProfile": binding,
        "forbiddenPropagationPolicy": binding,
        "rightsPolicy": binding,
        "mappingSets": {
            "cip.mapping": {
                "revision": "1.0.0",
                "releaseId": "cip.mapping.release",
                "manifestHash": digest,
                "endpointSchemeBindings": {
                    "subject": {
                        "id": "cip.subject",
                        "version": "2020",
                        "contentHash": digest,
                    },
                    "object": {
                        "id": "soc.object",
                        "version": "2018",
                        "contentHash": digest,
                    },
                },
                "releaseState": "unavailable",
            }
        },
        "shards": {},
        "coverageBinding": binding,
        "evaluationBinding": binding,
        "dependencyIndexBinding": binding,
        "lifecycleState": "unavailable",
        "pointerGeneration": 0,
    }
    _validator(schema).validate(release)

    missing_role = deepcopy(release)
    del missing_role["mappingSets"]["cip.mapping"]["endpointSchemeBindings"]["object"]
    _assert_invalid(schema, missing_role)
    invented_role = deepcopy(release)
    invented_role["mappingSets"]["cip.mapping"]["endpointSchemeBindings"]["source"] = (
        binding
    )
    _assert_invalid(schema, invented_role)
    floating = deepcopy(release)
    floating["registrySchema"] = {**binding, "version": "latest"}
    _assert_invalid(schema, floating)


def test_coverage_rejects_unknown_dimensions_and_invalid_counts() -> None:
    schema = _schema("relationship-coverage-v1.schema.json")
    totals = {
        name: 0
        for name in (
            "mappingSets",
            "edges",
            "subjectEndpoints",
            "objectEndpoints",
            "reviewedSubjects",
            "conflicts",
            "unmapped",
            "explicitNoMatch",
            "stale",
            "rightsBlocked",
        )
    }
    gate_names = schema["properties"]["hardGateResults"]["required"]
    coverage = {
        "schemaVersion": "relationship-coverage-v1",
        "kind": "relationshipCoverage",
        "coverageId": "coverage.snapshot",
        "registrySnapshotId": "registry.snapshot",
        "releaseId": "registry.release",
        "generatedAt": "2026-08-08T00:00:00Z",
        "mappingSetCounts": {"cip.mapping": 0},
        "totals": totals,
        "countsByPredicate": {"skos:exactMatch": 0},
        "countsByFamily": {"official_cross_scheme_mapping": 0},
        "countsByMethod": {"source_published": 0},
        "countsByQaPartition": {"source_published": 0},
        "countsByReviewState": {"restricted": 0},
        "countsByPurpose": {"inspection": 0},
        "countsByConflictState": {"none": 0},
        "countsByFreshness": {"unknown": 0},
        "countsByRightsState": {"review_required": 0},
        "endpointCounts": {},
        "evaluationBinding": {
            "evaluationId": "evaluation.snapshot",
            "revision": "1.0.0",
            "contentHash": "b" * 64,
        },
        "hardGateResults": {name: "not_run" for name in gate_names},
    }
    _validator(schema).validate(coverage)

    unknown_predicate = deepcopy(coverage)
    unknown_predicate["countsByPredicate"]["unknown:predicate"] = 1
    _assert_invalid(schema, unknown_predicate)
    unknown_dimension = deepcopy(coverage)
    unknown_dimension["countsByPurpose"]["consumer_magic"] = 1
    _assert_invalid(schema, unknown_dimension)
    negative = deepcopy(coverage)
    negative["countsByFamily"]["official_cross_scheme_mapping"] = -1
    _assert_invalid(schema, negative)
