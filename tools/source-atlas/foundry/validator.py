"""Validation for Source Atlas Foundry bundles."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .model import file_sha256, object_key_findings, privacy_findings_for_value, read_json

ALLOWED_CLAIM_STATES = {"source_backed", "candidate", "source_needed", "stale", "contradicted", "revoked", "disputed"}
ALLOWED_FRESHNESS_STATES = {"current", "unknown", "stable_law_watch", "selection_cycle_watch", "release_watch", "stale_warning"}


def validate_pack(pack: dict[str, Any], label: str) -> list[str]:
    issues: list[str] = []
    required = ["schemaVersion", "kind", "id", "versionID", "metadata", "sources", "claims", "requirements", "pathways", "nonClaims"]
    for field in required:
        if field not in pack:
            issues.append(f"{label}: missing {field}")
    if pack.get("kind") != "ambitions.sourceAtlas.foundryPack":
        issues.append(f"{label}: wrong kind")
    metadata = pack.get("metadata", {})
    if metadata.get("runtimeRole") != "reference_enrichment_only":
        issues.append(f"{label}: runtimeRole must be reference_enrichment_only")
    if metadata.get("localPersonalizationRequired") is not True:
        issues.append(f"{label}: localPersonalizationRequired must be true")
    if metadata.get("sourceAtlasInvisibleByDefault") is not True:
        issues.append(f"{label}: sourceAtlasInvisibleByDefault must be true")

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


def validate_bundle(bundle_root: Path) -> dict[str, Any]:
    issues: list[str] = []
    manifest_path = bundle_root / "manifest.json"
    if not manifest_path.exists():
        return {"valid": False, "issues": [f"missing manifest: {manifest_path}"], "packCount": 0}

    manifest = read_json(manifest_path)
    issues.extend(privacy_findings_for_value(manifest, "manifest.json"))
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
