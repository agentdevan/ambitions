"""Validation for Source Atlas Foundry bundles."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .boundary import ALLOWED_DATA_CLASSES, boundary_issue_strings, boundary_issues_for_value
from .model import file_sha256, object_key_findings, privacy_findings_for_value, read_json
from .schemas import SCHEMA_KINDS

ALLOWED_CLAIM_STATES = {"source_backed", "candidate", "source_needed", "stale", "contradicted", "revoked", "disputed"}
ALLOWED_FRESHNESS_STATES = {"current", "unknown", "stable_law_watch", "selection_cycle_watch", "release_watch", "stale_warning"}
ALLOWED_PACK_FRESHNESS_STATES = {"candidate", "harvested_candidate", "partial_harvest_candidate", "blocked_harvest_candidate"}
REQUIRED_PUBLIC_FLAGS = {
    "r2Allowed": True,
    "appCacheAllowed": True,
}


def validate_pack(pack: dict[str, Any], label: str) -> list[str]:
    issues: list[str] = []
    required = ["schemaVersion", "kind", "id", "versionID", "metadata", "sources", "claims", "requirements", "pathways", "nonClaims"]
    for field in required:
        if field not in pack:
            issues.append(f"{label}: missing {field}")
    if pack.get("kind") != "ambitions.sourceAtlas.foundryPack":
        issues.append(f"{label}: wrong kind")
    issues.extend(validate_boundary_contract(pack, label))
    metadata = pack.get("metadata", {})
    if metadata.get("runtimeRole") != "reference_enrichment_only":
        issues.append(f"{label}: runtimeRole must be reference_enrichment_only")
    if metadata.get("localPersonalizationRequired") is not True:
        issues.append(f"{label}: localPersonalizationRequired must be true")
    if metadata.get("sourceAtlasInvisibleByDefault") is not True:
        issues.append(f"{label}: sourceAtlasInvisibleByDefault must be true")
    if metadata.get("freshnessState") not in ALLOWED_PACK_FRESHNESS_STATES:
        issues.append(f"{label}: unsupported pack freshnessState {metadata.get('freshnessState')}")

    source_ids = {source.get("id") for source in pack.get("sources", [])}
    claim_ids = {claim.get("id") for claim in pack.get("claims", [])}
    requirement_ids = {item.get("id") for item in pack.get("requirements", [])}

    for source in pack.get("sources", []):
        for field in ["id", "title", "publisher", "url", "authorityTier", "freshnessCadence", "license"]:
            if not source.get(field):
                issues.append(f"{label}: source missing {field}: {source.get('id', '<unknown>')}")
    for claim in pack.get("claims", []):
        if claim.get("state") not in ALLOWED_CLAIM_STATES:
            issues.append(f"{label}: claim {claim.get('id')} has unsupported state {claim.get('state')}")
        if claim.get("freshness") not in ALLOWED_FRESHNESS_STATES:
            issues.append(f"{label}: claim {claim.get('id')} has unsupported freshness {claim.get('freshness')}")
        missing_sources = [source_id for source_id in claim.get("sourceIDs", []) if source_id not in source_ids]
        if missing_sources:
            issues.append(f"{label}: claim {claim.get('id')} references missing sources {missing_sources}")
    for requirement in pack.get("requirements", []):
        if requirement.get("claimID") not in claim_ids:
            issues.append(f"{label}: requirement {requirement.get('id')} references missing claim {requirement.get('claimID')}")
        if not requirement.get("structuredRule"):
            issues.append(f"{label}: requirement {requirement.get('id')} missing structuredRule")
    for pathway in pack.get("pathways", []):
        behavior = pathway.get("runtimeBehavior", {})
        if behavior.get("mustJoinWithPrivateRuntimeLocally") is not True:
            issues.append(f"{label}: pathway {pathway.get('id')} must join with Private Life Runtime locally")
        if behavior.get("mustNotUploadPrivateContext") is not True:
            issues.append(f"{label}: pathway {pathway.get('id')} must forbid private-context upload")
        missing_requirements = [item for item in pathway.get("sourceRequirementIDs", []) if item not in requirement_ids]
        if missing_requirements:
            issues.append(f"{label}: pathway {pathway.get('id')} references missing requirements {missing_requirements}")

    issues.extend(privacy_findings_for_value(pack, label))
    return issues


def validate_boundary_contract(value: dict[str, Any], label: str) -> list[str]:
    issues: list[str] = []
    data_class = value.get("dataClass") or value.get("dataClassification") or value.get("classification")
    if data_class not in ALLOWED_DATA_CLASSES:
        issues.append(f"{label}: missing or unsupported dataClass {data_class}")
    for field, expected in REQUIRED_PUBLIC_FLAGS.items():
        if field in value and value.get(field) is not expected:
            issues.append(f"{label}: {field} must be {expected}")
    if value.get("logAllowed") not in {None, "metadata_only"}:
        issues.append(f"{label}: logAllowed must be metadata_only when present")
    if value.get("fixtureAllowed") not in {None, "public_synthetic_only"}:
        issues.append(f"{label}: fixtureAllowed must be public_synthetic_only when present")
    issues.extend(boundary_issue_strings(boundary_issues_for_value(value, label)))
    return issues


def validate_schema_index(value: dict[str, Any], label: str) -> list[str]:
    issues = validate_boundary_contract(value, label)
    if value.get("kind") not in {"ambitions.sourceAtlas.ontology.v1", "ambitions.sourceAtlas.schemaDescriptorIndex.v1"}:
        issues.append(f"{label}: unsupported schema index kind {value.get('kind')}")
    if value.get("kind") == "ambitions.sourceAtlas.schemaDescriptorIndex.v1":
        for descriptor in value.get("schemas", []):
            descriptor_label = f"{label}:{descriptor.get('id', '<schema>')}"
            issues.extend(validate_boundary_contract(descriptor, descriptor_label))
            if not descriptor.get("validationReady"):
                issues.append(f"{descriptor_label}: validationReady must be true")
            forbidden = set(descriptor.get("forbiddenFields", []))
            for field in ["goalText", "captureText", "privateLifeGraph", "receiptPayload"]:
                if field not in forbidden:
                    issues.append(f"{descriptor_label}: missing forbidden field {field}")
    return issues


def validate_schema_shard(shard: dict[str, Any], label: str) -> list[str]:
    issues = validate_boundary_contract(shard, label)
    if shard.get("kind") != SCHEMA_KINDS["shard"]:
        issues.append(f"{label}: unsupported shard kind {shard.get('kind')}")
    source_ids = {record.get("sourceID") for record in shard.get("provenance", [])}
    provenance_ids = {record.get("id") for record in shard.get("provenance", [])}
    claim_ids = {record.get("id") for record in shard.get("claims", [])}
    requirement_ids = {record.get("id") for record in shard.get("requirements", [])}
    atom_ids = {record.get("id") for record in shard.get("atoms", [])}
    edge_ids = {record.get("id") for record in shard.get("edges", [])}
    recipe_ids = {record.get("id") for record in shard.get("recipes", [])}

    for collection_name in ["claims", "requirements", "provenance", "atoms", "edges", "lattices", "recipes"]:
        for record in shard.get(collection_name, []):
            record_label = f"{label}:{collection_name}:{record.get('id', '<record>')}"
            issues.extend(validate_boundary_contract(record, record_label))
            if record.get("schemaVersion") != 1:
                issues.append(f"{record_label}: schemaVersion must be 1")
            if record.get("publicReferenceOnly") is not True:
                issues.append(f"{record_label}: publicReferenceOnly must be true")

    for claim in shard.get("claims", []):
        missing_sources = [source_id for source_id in claim.get("sourceIDs", []) if source_id not in source_ids]
        missing_provenance = [provenance_id for provenance_id in claim.get("provenanceIDs", []) if provenance_id not in provenance_ids]
        if missing_sources:
            issues.append(f"{label}: claim {claim.get('id')} references missing sources {missing_sources}")
        if missing_provenance:
            issues.append(f"{label}: claim {claim.get('id')} references missing provenance {missing_provenance}")
        if claim.get("state") == "source_backed" and (not claim.get("sourceIDs") or not claim.get("provenanceIDs")):
            issues.append(f"{label}: source_backed claim {claim.get('id')} requires sourceIDs and provenanceIDs")
    for requirement in shard.get("requirements", []):
        if requirement.get("claimID") not in claim_ids:
            issues.append(f"{label}: requirement {requirement.get('id')} references missing claim {requirement.get('claimID')}")
        if not requirement.get("structuredRule"):
            issues.append(f"{label}: requirement {requirement.get('id')} missing structuredRule")
    for edge in shard.get("edges", []):
        if edge.get("fromAtomID") not in atom_ids or edge.get("toAtomID") not in atom_ids:
            issues.append(f"{label}: edge {edge.get('id')} references missing atom")
    for lattice in shard.get("lattices", []):
        missing_atoms = [atom_id for atom_id in lattice.get("atomIDs", []) if atom_id not in atom_ids]
        missing_edges = [edge_id for edge_id in lattice.get("edgeIDs", []) if edge_id not in edge_ids]
        missing_recipes = [recipe_id for recipe_id in lattice.get("recipeIDs", []) if recipe_id not in recipe_ids]
        if missing_atoms or missing_edges or missing_recipes:
            issues.append(f"{label}: lattice {lattice.get('id')} references missing atoms/edges/recipes")
    for recipe in shard.get("recipes", []):
        if recipe.get("doesNotStoreFinalUserPath") is not True:
            issues.append(f"{label}: recipe {recipe.get('id')} must not store final user path")
        if recipe.get("doesNotCreateFinalSchedule") is not True:
            issues.append(f"{label}: recipe {recipe.get('id')} must not create final schedule")
        missing_requirements = [requirement_id for requirement_id in recipe.get("requirementIDs", []) if requirement_id not in requirement_ids]
        if missing_requirements:
            issues.append(f"{label}: recipe {recipe.get('id')} references missing requirements {missing_requirements}")
    return issues


def validate_bundle(bundle_root: Path) -> dict[str, Any]:
    issues: list[str] = []
    manifest_path = bundle_root / "manifest.json"
    if not manifest_path.exists():
        return {"valid": False, "issues": [f"missing manifest: {manifest_path}"], "packCount": 0}

    manifest = read_json(manifest_path)
    issues.extend(privacy_findings_for_value(manifest, "manifest.json"))
    issues.extend(validate_boundary_contract(manifest, "manifest.json"))
    pack_count = 0
    for entry in manifest.get("packIndex", []):
        pack_path = bundle_root / entry.get("path", "")
        if not pack_path.exists():
            issues.append(f"manifest references missing pack {entry.get('path')}")
            continue
        actual_sha = file_sha256(pack_path)
        if actual_sha != entry.get("sha256"):
            issues.append(f"{entry.get('path')}: hash mismatch")
        pack = read_json(pack_path)
        issues.extend(validate_pack(pack, entry.get("path", "<pack>")))
        pack_count += 1

    for schema_entry in manifest.get("schemaIndex", []):
        path = bundle_root / schema_entry.get("path", "")
        if not path.exists():
            issues.append(f"manifest references missing schema {schema_entry.get('path')}")
            continue
        if file_sha256(path) != schema_entry.get("sha256"):
            issues.append(f"{schema_entry.get('path')}: hash mismatch")
        issues.extend(validate_schema_index(read_json(path), schema_entry.get("path", "<schema>")))

    for shard_entry in manifest.get("shardIndex", []):
        path = bundle_root / shard_entry.get("path", "")
        if not path.exists():
            issues.append(f"manifest references missing shard {shard_entry.get('path')}")
            continue
        if file_sha256(path) != shard_entry.get("sha256"):
            issues.append(f"{shard_entry.get('path')}: hash mismatch")
        issues.extend(validate_schema_shard(read_json(path), shard_entry.get("path", "<shard>")))

    for registry_entry in manifest.get("registryIndex", []):
        path = bundle_root / registry_entry.get("path", "")
        if not path.exists():
            issues.append(f"manifest references missing registry {registry_entry.get('path')}")
        elif file_sha256(path) != registry_entry.get("sha256"):
            issues.append(f"{registry_entry.get('path')}: hash mismatch")

    freshness = manifest.get("freshnessManifest", {})
    if freshness:
        path = bundle_root / freshness.get("path", "")
        if not path.exists():
            issues.append(f"missing freshness manifest {freshness.get('path')}")
        elif file_sha256(path) != freshness.get("sha256"):
            issues.append(f"{freshness.get('path')}: hash mismatch")

    receipt = manifest.get("receipt", {})
    if receipt:
        path = bundle_root / receipt.get("path", "")
        if not path.exists():
            issues.append(f"missing receipt {receipt.get('path')}")
        elif file_sha256(path) != receipt.get("sha256"):
            issues.append(f"{receipt.get('path')}: hash mismatch")

    return {
        "valid": not issues,
        "issues": issues,
        "packCount": pack_count,
        "manifestSHA256": file_sha256(manifest_path),
    }


def validate_r2_object_keys(keys: list[str]) -> list[str]:
    issues: list[str] = []
    for key in keys:
        issues.extend([f"{key}: {finding}" for finding in object_key_findings(key)])
    return issues
