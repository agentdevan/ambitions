"""R2 manifest, freshness, LKG, and promotion-gate contracts."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value, object_key_issues
from .certification import certify_registry
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, read_json, stable_id, utc_now, write_json
from .validator import validate_bundle


ALLOWED_PROMOTION_CHANNELS = {"staging", "stable"}
REVOCATION_STATES = {"active", "revoked", "quarantined"}


def object_layout(prefix: str = "source-atlas/v1") -> dict[str, Any]:
    clean = prefix.strip("/")
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2ObjectLayout",
        "prefix": clean,
        "dataClass": "public_r2_object_key",
        "publicReferenceOnly": True,
        "objects": [
            f"{clean}/releases/<version>/manifest.json",
            f"{clean}/releases/<version>/packs/<pack>.json",
            f"{clean}/releases/<version>/schemas/<schema>.json",
            f"{clean}/releases/<version>/shards/<shard>.json",
            f"{clean}/releases/<version>/registries/<registry>.json",
            f"{clean}/releases/<version>/provenance/<receipt>.json",
            f"{clean}/releases/<version>/freshness-manifest.json",
            f"{clean}/channels/staging/manifest.json",
            f"{clean}/channels/stable/manifest.json",
            f"{clean}/revocations/<version>.json",
            f"{clean}/last-known-good/<channel>.json",
        ],
        "forbiddenSegments": [
            "account",
            "user",
            "goal",
            "capture",
            "schedule",
            "life-capital",
            "proof",
            "receipt-payload",
            "private",
            "personalization",
        ],
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }


def release_manifest_schema() -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.releaseManifestSchema",
        "dataClass": "public_ontology",
        "requiredFields": [
            "schemaVersion",
            "kind",
            "versionID",
            "channel",
            "packIndex",
            "schemaIndex",
            "shardIndex",
            "registryIndex",
            "freshnessManifest",
            "receipt",
            "privacyBoundary",
            "nonClaims",
        ],
        "requiredIndexedFields": ["path", "sha256", "bytes"],
        "promotionRequiredChecks": [
            "bundle_validation",
            "privacy_boundary",
            "object_key_shape",
            "checksums",
            "provenance_receipt",
            "source_certification",
            "freshness_no_stale_critical",
            "revocation_no_active_revoked_artifact",
            "unsupported_source_no_promotion",
        ],
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }


def freshness_manifest_schema() -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.freshnessManifestSchema",
        "dataClass": "public_ontology",
        "requiredFields": [
            "schemaVersion",
            "kind",
            "versionID",
            "channel",
            "claimStateBuckets",
            "sourceFreshnessWatch",
            "privacyBoundary",
            "nonClaims",
        ],
        "mustTrack": [
            "source cadence",
            "claim freshness",
            "changed claims",
            "impacted requirements",
            "impacted lattices",
            "quarantine state",
            "runtime review triggers",
        ],
        "blockingStates": ["stale critical claim", "revoked claim", "contradicted current-use claim"],
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }


def revocation_manifest_schema() -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.revocationManifestSchema",
        "dataClass": "public_ontology",
        "requiredFields": ["schemaVersion", "kind", "id", "versionID", "createdAt", "entries", "privacyBoundary", "nonClaims"],
        "revocableArtifactKinds": ["pack", "shard", "source", "claim", "requirement", "recipe", "receipt"],
        "entryRequiredFields": ["artifactID", "path", "sha256", "state"],
        "allowedStates": sorted(REVOCATION_STATES),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }


def last_known_good_schema() -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.lastKnownGoodSchema",
        "dataClass": "public_ontology",
        "requiredFields": ["schemaVersion", "kind", "id", "channel", "versionID", "manifest", "state", "privacyBoundary", "nonClaims"],
        "manifestRequiredFields": ["path", "sha256", "bytes"],
        "allowedChannels": sorted(ALLOWED_PROMOTION_CHANNELS),
        "state": "last_known_good_candidate",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }


def write_manifest_contracts(output_root: Path, prefix: str = "source-atlas/v1") -> dict[str, Any]:
    output_root.mkdir(parents=True, exist_ok=True)
    artifacts = {
        "r2-object-layout.json": object_layout(prefix),
        "release-manifest-schema.json": release_manifest_schema(),
        "freshness-manifest-schema.json": freshness_manifest_schema(),
        "revocation-manifest-schema.json": revocation_manifest_schema(),
        "last-known-good-schema.json": last_known_good_schema(),
    }
    entries: list[dict[str, Any]] = []
    for name, payload in artifacts.items():
        path = output_root / name
        write_json(path, payload)
        entries.append({"path": str(path), "sha256": file_sha256(path), "bytes": path.stat().st_size})
    return {"artifacts": entries}


def build_revocation_manifest(
    bundle_root: Path,
    revoked_artifact_ids: list[str] | None = None,
    reason: str = "dry-run contract",
    output_path: Path | None = None,
) -> dict[str, Any]:
    manifest = read_json(bundle_root / "manifest.json")
    revoked = set(revoked_artifact_ids or [])
    entries: list[dict[str, Any]] = []
    for item in _artifact_entries(manifest):
        artifact_id = item.get("id") or item.get("packID") or item.get("path")
        state = "revoked" if artifact_id in revoked or item.get("path") in revoked else "active"
        entries.append(
            {
                "artifactID": artifact_id,
                "path": item.get("path"),
                "sha256": item.get("sha256"),
                "state": state,
                "reason": reason if state == "revoked" else None,
            }
        )
    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.revocationManifest",
        "id": stable_id("revocation.source_atlas", {"versionID": manifest.get("versionID"), "revoked": sorted(revoked)}),
        "versionID": manifest.get("versionID"),
        "createdAt": utc_now(),
        "dataClass": "public_freshness",
        "entries": entries,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    issues = _revocation_issues(result)
    result["valid"] = not issues
    result["issues"] = issues
    if output_path:
        write_json(output_path, result)
    return result


def build_last_known_good_manifest(
    bundle_root: Path,
    channel: str,
    output_path: Path | None = None,
) -> dict[str, Any]:
    manifest_path = bundle_root / "manifest.json"
    manifest = read_json(manifest_path)
    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.lastKnownGoodManifest",
        "id": stable_id("lkg.source_atlas", {"channel": channel, "manifest": file_sha256(manifest_path)}),
        "channel": channel,
        "versionID": manifest.get("versionID"),
        "manifest": {
            "path": "manifest.json",
            "sha256": file_sha256(manifest_path),
            "bytes": manifest_path.stat().st_size,
        },
        "state": "last_known_good_candidate",
        "dataClass": "public_freshness",
        "createdAt": utc_now(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    issues = boundary_issue_strings(boundary_issues_for_value(result, "last-known-good"))
    result["valid"] = channel in ALLOWED_PROMOTION_CHANNELS and not issues
    result["issues"] = ([] if channel in ALLOWED_PROMOTION_CHANNELS else [f"unsupported channel {channel}"]) + issues
    if output_path:
        write_json(output_path, result)
    return result


def validate_promotion_gate(
    bundle_root: Path,
    r2_plan_path: Path,
    revocation_path: Path | None = None,
    channel: str = "staging",
    output_path: Path | None = None,
) -> dict[str, Any]:
    bundle_validation = validate_bundle(bundle_root)
    plan = read_json(r2_plan_path)
    manifest = read_json(bundle_root / "manifest.json")
    revocations = read_json(revocation_path) if revocation_path else None
    issues: list[str] = []
    checks: list[dict[str, Any]] = []

    _record(checks, "bundle_validation", bundle_validation.get("valid", False), bundle_validation.get("issues", []))
    if not bundle_validation.get("valid", False):
        issues.extend(f"bundle_validation:{issue}" for issue in bundle_validation.get("issues", []))

    privacy_issues = boundary_issue_strings(boundary_issues_for_value(plan, "r2-plan"))
    _record(checks, "private_egress", not privacy_issues, privacy_issues)
    issues.extend(f"private_egress:{issue}" for issue in privacy_issues)

    key_issues = []
    for obj in plan.get("objects", []):
        key_issues.extend(issue.format() for issue in object_key_issues(obj.get("objectKey", ""), obj.get("objectKey", "objectKey")))
    _record(checks, "object_key_shape", not key_issues, key_issues)
    issues.extend(f"object_key_shape:{issue}" for issue in key_issues)

    checksum_issues = _checksum_issues(plan)
    _record(checks, "checksums", not checksum_issues, checksum_issues)
    issues.extend(f"checksums:{issue}" for issue in checksum_issues)

    provenance_issues = _provenance_issues(bundle_root, manifest)
    _record(checks, "provenance", not provenance_issues, provenance_issues)
    issues.extend(f"provenance:{issue}" for issue in provenance_issues)

    certification = certify_registry()
    _record(checks, "source_certification", certification["valid"], certification["issues"])
    issues.extend(f"source_certification:{issue}" for issue in certification["issues"])

    stale_critical = _stale_critical_issues(bundle_root, manifest)
    _record(checks, "freshness_no_stale_critical", not stale_critical, stale_critical)
    issues.extend(f"freshness_no_stale_critical:{issue}" for issue in stale_critical)

    revoked_issues = _revoked_use_issues(manifest, revocations)
    _record(checks, "revocation_no_active_revoked_artifact", not revoked_issues, revoked_issues)
    issues.extend(f"revocation_no_active_revoked_artifact:{issue}" for issue in revoked_issues)

    unsupported_issues = _unsupported_source_issues(bundle_root, manifest)
    _record(checks, "unsupported_source_promotion", not unsupported_issues, unsupported_issues)
    issues.extend(f"unsupported_source_promotion:{issue}" for issue in unsupported_issues)

    if channel not in ALLOWED_PROMOTION_CHANNELS:
        issues.append(f"unsupported_channel:{channel}")

    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.promotionGateDryRun",
        "id": stable_id("promotion.source_atlas", {"bundleRoot": str(bundle_root), "plan": str(r2_plan_path), "channel": channel}),
        "createdAt": utc_now(),
        "channel": channel,
        "dryRunOnly": True,
        "wouldUpload": False,
        "validForPromotion": not issues,
        "checks": checks,
        "issues": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS + ["dry-run only; no R2 upload or production promotion was performed"],
    }
    if output_path:
        write_json(output_path, result)
    return result


def _record(checks: list[dict[str, Any]], name: str, passed: bool, issues: list[str]) -> None:
    checks.append({"name": name, "passed": passed, "issues": issues})


def _artifact_entries(manifest: dict[str, Any]) -> list[dict[str, Any]]:
    if manifest.get("kind") == "ambitions.sourceAtlas.packManifest.v1":
        entries: list[dict[str, Any]] = []
        for label, item in sorted((manifest.get("objects") or {}).items()):
            if not isinstance(item, dict):
                continue
            path = Path(str(item.get("local_path") or item.get("localPath") or item.get("path") or "")).name
            entries.append(
                {
                    "id": label,
                    "path": path,
                    "sha256": item.get("sha256"),
                    "object_key": item.get("object_key") or item.get("objectKey"),
                }
            )
        return entries
    entries: list[dict[str, Any]] = []
    for key in ["packIndex", "schemaIndex", "shardIndex", "registryIndex"]:
        entries.extend(manifest.get(key, []))
    for key in ["freshnessManifest", "receipt"]:
        if manifest.get(key):
            entries.append({"id": key, **manifest[key]})
    return entries


def _revocation_issues(manifest: dict[str, Any]) -> list[str]:
    issues = boundary_issue_strings(boundary_issues_for_value(manifest, "revocation"))
    for entry in manifest.get("entries", []):
        if entry.get("state") not in REVOCATION_STATES:
            issues.append(f"{entry.get('artifactID')}: unsupported revocation state {entry.get('state')}")
        if not entry.get("sha256"):
            issues.append(f"{entry.get('artifactID')}: missing checksum")
    return issues


def _checksum_issues(plan: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for obj in plan.get("objects", []):
        path = Path(obj.get("localPath", ""))
        if not path.exists():
            issues.append(f"{obj.get('objectKey')}: missing localPath")
            continue
        actual = file_sha256(path)
        if actual != obj.get("sha256"):
            issues.append(f"{obj.get('objectKey')}: checksum mismatch")
        if not obj.get("bytes"):
            issues.append(f"{obj.get('objectKey')}: missing byte count")
    return issues


def _provenance_issues(bundle_root: Path, manifest: dict[str, Any]) -> list[str]:
    if manifest.get("kind") == "ambitions.sourceAtlas.packManifest.v1":
        return _pack_manifest_provenance_issues(bundle_root, manifest)
    issues: list[str] = []
    receipt = manifest.get("receipt")
    if not receipt:
        issues.append("missing receipt index")
    elif not (bundle_root / receipt.get("path", "")).exists():
        issues.append(f"missing receipt file {receipt.get('path')}")
    for shard_entry in manifest.get("shardIndex", []):
        shard = read_json(bundle_root / shard_entry["path"])
        for claim in shard.get("claims", []):
            if claim.get("state") == "source_backed" and (not claim.get("sourceIDs") or not claim.get("provenanceIDs")):
                issues.append(f"{claim.get('id')}: source_backed claim missing source/provenance")
    return issues


def _pack_manifest_provenance_issues(bundle_root: Path, manifest: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    if not manifest.get("claim_graph_hash"):
        issues.append("missing claim_graph_hash")
    if not manifest.get("source_registry_hash"):
        issues.append("missing source_registry_hash")
    if not manifest.get("legal_registry_hash"):
        issues.append("missing legal_registry_hash")
    claims_path = _pack_manifest_local_path(bundle_root, manifest, "claims", fallback="claims.json")
    if not claims_path.exists():
        issues.append("missing claims slice")
        return issues
    claims_entry = (manifest.get("objects") or {}).get("claims", {})
    if isinstance(claims_entry, dict) and claims_entry.get("sha256") and file_sha256(claims_path) != claims_entry.get("sha256"):
        issues.append("claims slice hash mismatch")
    claims = read_json(claims_path).get("claims", [])
    if not claims:
        issues.append("claims slice is empty")
    required_fields = ["source_lane", "locator", "retrieval_time", "evidence_hash", "adjudication_rule", "license_id"]
    for claim in claims:
        if claim.get("pack_eligibility") != "packable":
            issues.append(f"{claim.get('claim_id')}: non-packable claim present in pack claims slice")
        if claim.get("provenance_tuple_complete") is not True:
            issues.append(f"{claim.get('claim_id')}: provenance tuple not marked complete")
        for field in required_fields:
            if not claim.get(field):
                issues.append(f"{claim.get('claim_id')}: missing provenance field {field}")
    return issues


def _stale_critical_issues(bundle_root: Path, manifest: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    critical_types = {"eligibility_rule", "credential_rule", "medical_physical_rule", "experience_rule"}
    if manifest.get("kind") == "ambitions.sourceAtlas.packManifest.v1":
        claims_path = _pack_manifest_local_path(bundle_root, manifest, "claims", fallback="claims.json")
        if not claims_path.exists():
            return ["missing claims slice for stale-critical check"]
        for claim in read_json(claims_path).get("claims", []):
            if claim.get("claim_type") in critical_types and (claim.get("freshness_status") == "stale-critical" or claim.get("state") == "stale"):
                issues.append(f"{claim.get('claim_id')}: stale critical claim")
        return issues
    for pack_entry in manifest.get("packIndex", []):
        pack = read_json(bundle_root / pack_entry["path"])
        for claim in pack.get("claims", []):
            if claim.get("claimType") in critical_types and (claim.get("state") == "stale" or claim.get("freshness") == "stale_warning"):
                issues.append(f"{claim.get('id')}: stale critical claim")
    return issues


def _revoked_use_issues(manifest: dict[str, Any], revocations: dict[str, Any] | None) -> list[str]:
    if not revocations:
        return []
    revoked_paths = {entry.get("path") for entry in revocations.get("entries", []) if entry.get("state") == "revoked"}
    issues: list[str] = []
    for entry in _artifact_entries(manifest):
        if entry.get("path") in revoked_paths:
            issues.append(f"{entry.get('path')}: revoked artifact referenced by release manifest")
    return issues


def _unsupported_source_issues(bundle_root: Path, manifest: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    if manifest.get("kind") == "ambitions.sourceAtlas.packManifest.v1":
        sources_path = _pack_manifest_local_path(bundle_root, manifest, "sources", fallback="sources.json")
        if not sources_path.exists():
            return ["missing sources slice for unsupported-source check"]
        blocked_policies = {
            "r2_blocked",
            "r2_review_required",
            "pack_blocked_lookup_only",
            "pack_blocked_crosswalk_only",
            "pack_blocked_restricted",
            "pack_blocked_unknown_terms",
        }
        for source in read_json(sources_path).get("sources", []):
            if source.get("included") is not True:
                continue
            if source.get("r2_pack_policy") in blocked_policies:
                issues.append(f"{source.get('source_id')}: blocked source cannot promote")
            if source.get("review_status") not in {"reviewed", "approved"}:
                issues.append(f"{source.get('source_id')}: source review status is not approved for promotion")
        return issues
    for pack_entry in manifest.get("packIndex", []):
        pack = read_json(bundle_root / pack_entry["path"])
        for source in pack.get("sources", []):
            harvest = source.get("harvest")
            if harvest and harvest.get("status") == "blocked":
                issues.append(f"{pack.get('id')}: blocked source {source.get('id')} cannot promote")
            if source.get("authorityTier") == "source_of_sources_metadata":
                claim_ids = [claim.get("id") for claim in pack.get("claims", []) if source.get("id") in claim.get("sourceIDs", [])]
                if claim_ids:
                    issues.append(f"{source.get('id')}: source-discovery metadata used as claim truth {claim_ids}")
    return issues


def _pack_manifest_local_path(bundle_root: Path, manifest: dict[str, Any], label: str, *, fallback: str) -> Path:
    entry = (manifest.get("objects") or {}).get(label, {})
    if isinstance(entry, dict):
        raw_path = str(entry.get("local_path") or entry.get("localPath") or "")
        if raw_path:
            path = Path(raw_path)
            if path.exists():
                return path
            if not path.is_absolute():
                candidate = bundle_root / path
                if candidate.exists():
                    return candidate
                candidate = bundle_root / path.name
                if candidate.exists():
                    return candidate
    return bundle_root / fallback
