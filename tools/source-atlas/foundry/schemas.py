"""Source Atlas ontology and schema contract builders."""

from __future__ import annotations

from typing import Any

from .boundary import ALLOWED_DATA_CLASSES
from .model import PRIVACY_BOUNDARY, stable_id, utc_now


SCHEMA_VERSION = 1
ONTOLOGY_ID = "ontology.source_atlas.v1"
NAMESPACE_PREFIXES = {
    "ontology": "ontology.source_atlas",
    "source": "source",
    "claim": "claim",
    "requirement": "requirement",
    "provenance": "provenance",
    "atom": "atom",
    "edge": "edge",
    "lattice": "lattice",
    "recipe": "recipe",
    "pack": "pack",
}

SCHEMA_KINDS = {
    "ontology": "ambitions.sourceAtlas.ontology.v1",
    "claim": "ambitions.sourceAtlas.claim.v1",
    "requirement": "ambitions.sourceAtlas.requirement.v1",
    "provenance": "ambitions.sourceAtlas.provenance.v1",
    "atom": "ambitions.sourceAtlas.atom.v1",
    "edge": "ambitions.sourceAtlas.edge.v1",
    "lattice": "ambitions.sourceAtlas.lattice.v1",
    "recipe": "ambitions.sourceAtlas.recipe.v1",
    "shard": "ambitions.sourceAtlas.schemaShard.v1",
}


def ontology_v1(created_at: str | None = None) -> dict[str, Any]:
    created_at = created_at or utc_now()
    return {
        "schemaVersion": SCHEMA_VERSION,
        "kind": SCHEMA_KINDS["ontology"],
        "id": ONTOLOGY_ID,
        "versionID": "source-atlas-ontology-v1",
        "createdAt": created_at,
        "dataClass": "public_ontology",
        "namespacePrefixes": NAMESPACE_PREFIXES,
        "publicReferenceOnly": True,
        "sourceBound": True,
        "versioned": True,
        "validationReady": True,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "allowedDataClasses": sorted(ALLOWED_DATA_CLASSES),
        "forbiddenPrivateClasses": [
            "goal_text",
            "capture_text",
            "schedule_or_capacity",
            "life_capital",
            "proof_payload",
            "receipt_payload",
            "account_secret",
            "user_identifier",
            "private_life_graph",
            "private_user_context",
        ],
        "objects": [
            "source",
            "claim",
            "requirement",
            "provenance",
            "atom",
            "edge",
            "lattice",
            "recipe",
            "pack",
        ],
    }


def schema_descriptors(created_at: str | None = None) -> list[dict[str, Any]]:
    created_at = created_at or utc_now()
    descriptors: list[dict[str, Any]] = []
    for name in ["claim", "requirement", "provenance", "atom", "edge", "lattice", "recipe"]:
        descriptors.append(
            {
                "schemaVersion": SCHEMA_VERSION,
                "kind": f"ambitions.sourceAtlas.{name}Schema.v1",
                "id": f"schema.source_atlas.{name}.v1",
                "objectKind": SCHEMA_KINDS[name],
                "versionID": "source-atlas-schema-v1",
                "createdAt": created_at,
                "dataClass": "public_ontology",
                "publicReferenceOnly": True,
                "sourceBound": name not in {"atom", "edge", "lattice", "recipe"} or True,
                "validationReady": True,
                "requiredFields": _required_fields(name),
                "forbiddenFields": [
                    "goalText",
                    "captureText",
                    "schedule",
                    "capacity",
                    "lifeCapital",
                    "proofPayload",
                    "receiptPayload",
                    "accountSecret",
                    "userID",
                    "privateLifeGraph",
                    "personalization",
                    "behaviorHistory",
                ],
                "privacyBoundary": PRIVACY_BOUNDARY,
            }
        )
    return descriptors


def _required_fields(name: str) -> list[str]:
    fields = {
        "claim": ["schemaVersion", "kind", "id", "versionID", "text", "claimType", "state", "freshness", "sourceIDs", "provenanceIDs", "dataClass"],
        "requirement": ["schemaVersion", "kind", "id", "versionID", "claimID", "gateType", "structuredRule", "sourceIDs", "provenanceIDs", "dataClass"],
        "provenance": ["schemaVersion", "kind", "id", "versionID", "sourceID", "locator", "retrievedAt", "contentHash", "dataClass"],
        "atom": ["schemaVersion", "kind", "id", "versionID", "label", "atomType", "sourceIDs", "provenanceIDs", "dataClass"],
        "edge": ["schemaVersion", "kind", "id", "versionID", "fromAtomID", "toAtomID", "relationship", "sourceIDs", "provenanceIDs", "dataClass"],
        "lattice": ["schemaVersion", "kind", "id", "versionID", "atomIDs", "edgeIDs", "recipeIDs", "dataClass"],
        "recipe": ["schemaVersion", "kind", "id", "versionID", "title", "inputAtomIDs", "outputAtomIDs", "requirementIDs", "sourceIDs", "provenanceIDs", "dataClass"],
    }
    return fields[name]


def provenance_for_source(source: dict[str, Any], version_id: str, created_at: str) -> dict[str, Any]:
    content_basis = {
        "sourceID": source["id"],
        "url": source["url"],
        "publisher": source["publisher"],
        "lastReviewed": source.get("lastReviewed"),
        "harvest": source.get("harvest"),
    }
    return {
        "schemaVersion": SCHEMA_VERSION,
        "kind": SCHEMA_KINDS["provenance"],
        "id": stable_id("provenance", content_basis),
        "versionID": version_id,
        "sourceID": source["id"],
        "locator": source["url"],
        "publisher": source["publisher"],
        "retrievedAt": source.get("harvest", {}).get("fetchedAt") or created_at,
        "contentHash": stable_id("source.content", content_basis).split(".", 1)[1],
        "freshnessCadence": source["freshnessCadence"],
        "license": source["license"],
        "dataClass": "public_provenance",
        "publicReferenceOnly": True,
        "privacyBoundary": PRIVACY_BOUNDARY,
    }


def schema_claim(claim: dict[str, Any], version_id: str, provenance_ids: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": SCHEMA_VERSION,
        "kind": SCHEMA_KINDS["claim"],
        "id": claim["id"],
        "versionID": version_id,
        "text": claim["text"],
        "claimType": claim["claimType"],
        "state": claim["state"],
        "freshness": claim["freshness"],
        "sourceIDs": sorted(claim.get("sourceIDs", [])),
        "provenanceIDs": sorted(provenance_ids),
        "dataClass": "public_reference_claim",
        "publicReferenceOnly": True,
        "sourceBound": True,
    }


def schema_requirement(requirement: dict[str, Any], version_id: str, provenance_ids: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": SCHEMA_VERSION,
        "kind": SCHEMA_KINDS["requirement"],
        "id": requirement["id"],
        "versionID": version_id,
        "claimID": requirement["claimID"],
        "gateType": requirement["gateType"],
        "structuredRule": requirement["structuredRule"],
        "sourceIDs": sorted(requirement.get("sourceIDs", [])),
        "provenanceIDs": sorted(provenance_ids),
        "dataClass": "public_requirement",
        "publicReferenceOnly": True,
        "sourceBound": True,
    }


def atom_records(pathway: dict[str, Any], version_id: str, provenance_ids: list[str]) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for label in pathway.get("skillAtoms", []):
        records.append(
            {
                "schemaVersion": SCHEMA_VERSION,
                "kind": SCHEMA_KINDS["atom"],
                "id": stable_id("atom", {"pathwayID": pathway["id"], "label": label}),
                "versionID": version_id,
                "label": label,
                "atomType": "skill",
                "sourceIDs": sorted(pathway.get("sourceIDs", [])),
                "provenanceIDs": sorted(provenance_ids),
                "dataClass": "public_atom_edge_lattice",
                "publicReferenceOnly": True,
            }
        )
    for requirement in pathway.get("requirements", []):
        records.append(
            {
                "schemaVersion": SCHEMA_VERSION,
                "kind": SCHEMA_KINDS["atom"],
                "id": stable_id("atom", {"pathwayID": pathway["id"], "requirementID": requirement["id"]}),
                "versionID": version_id,
                "label": requirement["id"],
                "atomType": "requirement",
                "sourceIDs": sorted(pathway.get("sourceIDs", [])),
                "provenanceIDs": sorted(provenance_ids),
                "dataClass": "public_atom_edge_lattice",
                "publicReferenceOnly": True,
            }
        )
    return records


def edge_records(atoms: list[dict[str, Any]], pathway: dict[str, Any], version_id: str, provenance_ids: list[str]) -> list[dict[str, Any]]:
    edges: list[dict[str, Any]] = []
    requirement_atoms = [atom for atom in atoms if atom["atomType"] == "requirement"]
    skill_atoms = [atom for atom in atoms if atom["atomType"] == "skill"]
    for requirement_atom in requirement_atoms:
        for skill_atom in skill_atoms[:3]:
            edges.append(
                {
                    "schemaVersion": SCHEMA_VERSION,
                    "kind": SCHEMA_KINDS["edge"],
                    "id": stable_id("edge", {"from": requirement_atom["id"], "to": skill_atom["id"], "pathwayID": pathway["id"]}),
                    "versionID": version_id,
                    "fromAtomID": requirement_atom["id"],
                    "toAtomID": skill_atom["id"],
                    "relationship": "supports_preparation",
                    "sourceIDs": sorted(pathway.get("sourceIDs", [])),
                    "provenanceIDs": sorted(provenance_ids),
                    "dataClass": "public_atom_edge_lattice",
                    "publicReferenceOnly": True,
                }
            )
    return edges


def recipe_records(pathway: dict[str, Any], atoms: list[dict[str, Any]], version_id: str, provenance_ids: list[str]) -> list[dict[str, Any]]:
    skill_atom_ids = [atom["id"] for atom in atoms if atom["atomType"] == "skill"]
    requirement_atom_ids = [atom["id"] for atom in atoms if atom["atomType"] == "requirement"]
    return [
        {
            "schemaVersion": SCHEMA_VERSION,
            "kind": SCHEMA_KINDS["recipe"],
            "id": stable_id("recipe", {"pathwayID": pathway["id"], "title": pathway["title"]}),
            "versionID": version_id,
            "title": pathway["title"],
            "inputAtomIDs": requirement_atom_ids,
            "outputAtomIDs": skill_atom_ids,
            "requirementIDs": [item["id"] for item in pathway.get("requirements", [])],
            "sourceIDs": sorted(pathway.get("sourceIDs", [])),
            "provenanceIDs": sorted(provenance_ids),
            "dataClass": "public_recipe",
            "publicReferenceOnly": True,
            "doesNotStoreFinalUserPath": True,
            "doesNotCreateFinalSchedule": True,
            "localRuntimeJoinRequired": True,
        }
    ]


def lattice_record(pathway: dict[str, Any], atoms: list[dict[str, Any]], edges: list[dict[str, Any]], recipes: list[dict[str, Any]], version_id: str) -> dict[str, Any]:
    return {
        "schemaVersion": SCHEMA_VERSION,
        "kind": SCHEMA_KINDS["lattice"],
        "id": stable_id("lattice", {"pathwayID": pathway["id"], "versionID": version_id}),
        "versionID": version_id,
        "pathwayID": pathway["id"],
        "atomIDs": [atom["id"] for atom in atoms],
        "edgeIDs": [edge["id"] for edge in edges],
        "recipeIDs": [recipe["id"] for recipe in recipes],
        "dataClass": "public_atom_edge_lattice",
        "publicReferenceOnly": True,
        "privacyBoundary": PRIVACY_BOUNDARY,
    }


def shard_for_pathway(pathway: dict[str, Any], sources: list[dict[str, Any]], version_id: str, created_at: str) -> dict[str, Any]:
    provenance = [provenance_for_source(source, version_id, created_at) for source in sources]
    provenance_by_source = {record["sourceID"]: record["id"] for record in provenance}
    claim_records = [
        schema_claim(
            claim,
            version_id,
            [provenance_by_source[source_id] for source_id in claim.get("sourceIDs", []) if source_id in provenance_by_source],
        )
        for claim in pathway.get("claims", [])
    ]
    requirement_records = [
        schema_requirement(
            {**requirement, "sourceIDs": pathway.get("sourceIDs", [])},
            version_id,
            [provenance_by_source[source_id] for source_id in pathway.get("sourceIDs", []) if source_id in provenance_by_source],
        )
        for requirement in pathway.get("requirements", [])
    ]
    provenance_ids = [record["id"] for record in provenance]
    atoms = atom_records(pathway, version_id, provenance_ids)
    edges = edge_records(atoms, pathway, version_id, provenance_ids)
    recipes = recipe_records(pathway, atoms, version_id, provenance_ids)
    lattice = lattice_record(pathway, atoms, edges, recipes, version_id)
    return {
        "schemaVersion": SCHEMA_VERSION,
        "kind": SCHEMA_KINDS["shard"],
        "id": stable_id("shard.source_atlas", {"pathwayID": pathway["id"], "versionID": version_id}),
        "versionID": version_id,
        "pathwayID": pathway["id"],
        "dataClass": "public_reference_claim",
        "claims": claim_records,
        "requirements": requirement_records,
        "provenance": provenance,
        "atoms": atoms,
        "edges": edges,
        "lattices": [lattice],
        "recipes": recipes,
        "privacyBoundary": PRIVACY_BOUNDARY,
    }
