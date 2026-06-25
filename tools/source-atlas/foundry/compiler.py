"""Compile Source Atlas Foundry packs and bundle manifests."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, stable_id, utc_now, write_json
from .registry import PATHWAY_SEEDS, SOURCE_REGISTRY


def _source_records(source_ids: list[str]) -> list[dict[str, Any]]:
    lookup = {source["id"]: source for source in SOURCE_REGISTRY}
    return [lookup[source_id] for source_id in source_ids if source_id in lookup]


def _pack_for_pathway(pathway: dict[str, Any], version_id: str, created_at: str) -> dict[str, Any]:
    source_ids = pathway["sourceIDs"]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.foundryPack",
        "id": pathway["id"].replace("pathway.", "pack."),
        "versionID": version_id,
        "displayName": pathway["title"],
        "domains": sorted({pathway["domain"], *[domain for source in _source_records(source_ids) for domain in source["domains"]]}),
        "metadata": {
            "createdAt": created_at,
            "createdBy": "Source Atlas Foundry",
            "freshnessState": "candidate",
            "privacyBoundary": PRIVACY_BOUNDARY,
            "runtimeRole": "reference_enrichment_only",
            "localPersonalizationRequired": True,
            "sourceAtlasInvisibleByDefault": True,
            "lastKnownGood": None,
            "signatureStatus": "unsigned-local-foundry-v0",
        },
        "sources": _source_records(source_ids),
        "claims": pathway["claims"],
        "requirements": pathway["requirements"],
        "pathways": [
            {
                "id": pathway["id"],
                "title": pathway["title"],
                "domain": pathway["domain"],
                "milestones": pathway["milestones"],
                "sourceRequirementIDs": [item["id"] for item in pathway["requirements"]],
                "skillAtoms": pathway["skillAtoms"],
                "alternatePaths": pathway["alternatePaths"],
                "runtimeBehavior": {
                    "canEnrichLocalPath": True,
                    "mustJoinWithPrivateRuntimeLocally": True,
                    "mustNotUploadPrivateContext": True,
                    "inspectionVisibleOnlyWhenUseful": True,
                    "freshnessChangeMayTriggerReview": True,
                },
            }
        ],
        "transferGraph": {
            "skillAtoms": pathway["skillAtoms"],
            "alternatePaths": pathway["alternatePaths"],
            "note": "Shared skill atoms let Ambitions preserve useful progress when a user changes direction.",
        },
        "inspectionContract": {
            "defaultVisibility": "hidden",
            "showWhen": ["user_asks_why", "source_freshness_changes_path_behavior"],
            "mustInclude": ["source", "claim", "freshness", "uncertainty", "user_control"],
        },
        "nonClaims": NON_CLAIMS,
    }


def source_catalog_manifest(version_id: str, created_at: str) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.sourceRegistry",
        "versionID": version_id,
        "createdAt": created_at,
        "sources": SOURCE_REGISTRY,
        "automationLanes": [
            {
                "id": "static-law-watch",
                "purpose": "Track stable constitutional/statutory eligibility sources for change events.",
                "cadence": "weekly metadata check plus manual review for amendments or program updates",
            },
            {
                "id": "occupation-skill-graph",
                "purpose": "Compile O*NET occupation, skills, tasks, knowledge, abilities, and transfer data.",
                "cadence": "release watch and quarterly refresh",
            },
            {
                "id": "public-program-requirements",
                "purpose": "Track official program requirements such as NASA selection cycles.",
                "cadence": "daily during open application windows; weekly otherwise",
            },
            {
                "id": "education-program-index",
                "purpose": "Map credible education/training options from College Scorecard and related official datasets.",
                "cadence": "on dataset release and monthly metadata check",
            },
            {
                "id": "source-of-sources-discovery",
                "purpose": "Use Data.gov metadata to discover public datasets without treating metadata as claim truth.",
                "cadence": "weekly harvest diff",
            },
        ],
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }


def compile_bundle(output_root: Path, version_id: str, channel: str = "staging") -> dict[str, Any]:
    created_at = utc_now()
    bundle_root = output_root / version_id
    packs_dir = bundle_root / "packs"
    registries_dir = bundle_root / "registries"
    provenance_dir = bundle_root / "provenance"

    packs: list[dict[str, Any]] = []
    pack_entries: list[dict[str, Any]] = []
    for pathway in PATHWAY_SEEDS:
        pack = _pack_for_pathway(pathway, version_id, created_at)
        pack_path = packs_dir / f"{pack['id']}.json"
        write_json(pack_path, pack)
        pack_sha = file_sha256(pack_path)
        pack_entry = {
            "packID": pack["id"],
            "path": str(pack_path.relative_to(bundle_root)),
            "sha256": pack_sha,
            "bytes": pack_path.stat().st_size,
            "claimCount": len(pack["claims"]),
            "requirementCount": len(pack["requirements"]),
            "pathwayCount": len(pack["pathways"]),
            "freshnessState": pack["metadata"]["freshnessState"],
        }
        packs.append(pack)
        pack_entries.append(pack_entry)

    source_catalog = source_catalog_manifest(version_id, created_at)
    source_catalog_path = registries_dir / "source-registry.json"
    write_json(source_catalog_path, source_catalog)

    freshness_manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.freshnessManifest",
        "versionID": version_id,
        "publishedAt": created_at,
        "channel": channel,
        "claimStateBuckets": _claim_state_buckets(packs),
        "sourceFreshnessWatch": [
            {
                "sourceID": source["id"],
                "freshnessCadence": source["freshnessCadence"],
                "lastReviewed": source["lastReviewed"],
                "authorityTier": source["authorityTier"],
            }
            for source in SOURCE_REGISTRY
        ],
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    freshness_path = bundle_root / "freshness-manifest.json"
    write_json(freshness_path, freshness_manifest)

    release_manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.releaseManifest",
        "versionID": version_id,
        "channel": channel,
        "createdAt": created_at,
        "packIndex": pack_entries,
        "registryIndex": [
            {
                "id": "source-registry",
                "path": str(source_catalog_path.relative_to(bundle_root)),
                "sha256": file_sha256(source_catalog_path),
                "bytes": source_catalog_path.stat().st_size,
            }
        ],
        "freshnessManifest": {
            "path": str(freshness_path.relative_to(bundle_root)),
            "sha256": file_sha256(freshness_path),
            "bytes": freshness_path.stat().st_size,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    manifest_path = bundle_root / "manifest.json"
    write_json(manifest_path, release_manifest)

    receipt = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.foundryReceipt",
        "id": stable_id("receipt.source_atlas_foundry", {"versionID": version_id, "channel": channel, "packIndex": pack_entries}),
        "operation": "compile_bundle",
        "createdAt": created_at,
        "versionID": version_id,
        "channel": channel,
        "inputs": [
            {
                "id": "embedded.source_registry",
                "count": len(SOURCE_REGISTRY),
                "sha256": stable_id("source_registry", SOURCE_REGISTRY).split(".", 1)[1],
            },
            {
                "id": "embedded.pathway_seeds",
                "count": len(PATHWAY_SEEDS),
                "sha256": stable_id("pathway_seeds", PATHWAY_SEEDS).split(".", 1)[1],
            },
        ],
        "outputs": [
            *pack_entries,
            {
                "id": "manifest",
                "path": "manifest.json",
                "sha256": file_sha256(manifest_path),
                "bytes": manifest_path.stat().st_size,
            },
        ],
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    receipt_path = provenance_dir / f"{receipt['id']}.json"
    write_json(receipt_path, receipt)

    release_manifest["receipt"] = {
        "path": str(receipt_path.relative_to(bundle_root)),
        "sha256": file_sha256(receipt_path),
        "bytes": receipt_path.stat().st_size,
    }
    write_json(manifest_path, release_manifest)

    return {
        "bundleRoot": str(bundle_root),
        "versionID": version_id,
        "channel": channel,
        "packCount": len(pack_entries),
        "manifestPath": str(manifest_path),
        "manifestSHA256": file_sha256(manifest_path),
        "receiptPath": str(receipt_path),
    }


def _claim_state_buckets(packs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    buckets: dict[str, list[str]] = {}
    for pack in packs:
        for claim in pack["claims"]:
            buckets.setdefault(claim["freshness"], []).append(claim["id"])
    return [{"state": state, "claimIDs": sorted(ids)} for state, ids in sorted(buckets.items())]
