"""Compile Source Atlas Foundry packs and bundle manifests."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .certification import certify_registry
from .coverage_benchmark import coverage_manifest_from_records
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, read_json, stable_id, utc_now, write_json
from .registry import PATHWAY_SEEDS, SOURCE_REGISTRY
from .schemas import ontology_v1, schema_descriptors, shard_for_pathway
from .workbench import entity_registry_from_shards


def _source_records(source_ids: list[str], harvest_context: dict[str, Any] | None = None) -> list[dict[str, Any]]:
    lookup = {source["id"]: source for source in SOURCE_REGISTRY}
    records: list[dict[str, Any]] = []
    harvest_records = harvest_context.get("records", {}) if harvest_context else {}
    for source_id in source_ids:
        if source_id not in lookup:
            continue
        source = dict(lookup[source_id])
        harvest_record = harvest_records.get(source_id)
        if harvest_record:
            source["harvest"] = {
                "status": harvest_record["status"],
                "adapterID": harvest_record["adapterID"],
                "adapterVersion": harvest_record["adapterVersion"],
                "fetchedAt": harvest_record["fetchedAt"],
                "recordCount": len(harvest_record.get("records", [])),
                "claimCount": len(harvest_record.get("claims", [])),
                "rawArtifactCount": len(harvest_record.get("rawArtifacts", [])),
                "rawArtifactHashes": [
                    {
                        "url": artifact["url"],
                        "sha256": artifact["sha256"],
                        "bytes": artifact["bytes"],
                        "contentType": artifact["contentType"],
                    }
                    for artifact in harvest_record.get("rawArtifacts", [])
                ],
                "blockedReasons": harvest_record.get("blockedReasons", []),
                "missingEnv": harvest_record.get("missingEnv", []),
                "freshnessSignals": harvest_record.get("freshnessSignals", {}),
            }
        records.append(source)
    return records


def _pack_for_pathway(pathway: dict[str, Any], version_id: str, created_at: str, harvest_context: dict[str, Any] | None = None) -> dict[str, Any]:
    source_ids = pathway["sourceIDs"]
    sources = _source_records(source_ids, harvest_context)
    freshness_state = _pack_freshness_state(source_ids, harvest_context)
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.foundryPack",
        "id": pathway["id"].replace("pathway.", "pack."),
        "versionID": version_id,
        "dataClass": "public_reference_claim",
        "r2Allowed": True,
        "appCacheAllowed": True,
        "logAllowed": "metadata_only",
        "fixtureAllowed": "public_synthetic_only",
        "displayName": pathway["title"],
        "domains": sorted({pathway["domain"], *[domain for source in sources for domain in source["domains"]]}),
        "metadata": {
            "createdAt": created_at,
            "createdBy": "Source Atlas Foundry",
            "freshnessState": freshness_state,
            "privacyBoundary": PRIVACY_BOUNDARY,
            "runtimeRole": "reference_enrichment_only",
            "localPersonalizationRequired": True,
            "sourceAtlasInvisibleByDefault": True,
            "lastKnownGood": None,
            "signatureStatus": "unsigned-local-foundry-v0",
            "harvestRunID": harvest_context["manifest"]["runID"] if harvest_context else None,
        },
        "sources": sources,
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


def source_catalog_manifest(version_id: str, created_at: str, harvest_context: dict[str, Any] | None = None) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.sourceRegistry",
        "versionID": version_id,
        "dataClass": "official_public_source",
        "r2Allowed": True,
        "appCacheAllowed": True,
        "logAllowed": "metadata_only",
        "fixtureAllowed": "public_synthetic_only",
        "createdAt": created_at,
        "sources": _source_records([source["id"] for source in SOURCE_REGISTRY], harvest_context),
        "harvestRun": _harvest_manifest_summary(harvest_context),
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


def compile_bundle(output_root: Path, version_id: str, channel: str = "staging", harvest_root: Path | None = None) -> dict[str, Any]:
    created_at = utc_now()
    harvest_context = _load_harvest_context(harvest_root) if harvest_root else None
    bundle_root = output_root / version_id
    packs_dir = bundle_root / "packs"
    registries_dir = bundle_root / "registries"
    provenance_dir = bundle_root / "provenance"
    schemas_dir = bundle_root / "schemas"
    shards_dir = bundle_root / "shards"

    packs: list[dict[str, Any]] = []
    pack_entries: list[dict[str, Any]] = []
    shard_entries: list[dict[str, Any]] = []
    for pathway in PATHWAY_SEEDS:
        sources = _source_records(pathway["sourceIDs"], harvest_context)
        pack = _pack_for_pathway(pathway, version_id, created_at, harvest_context)
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

        shard = shard_for_pathway(pathway, sources, version_id, created_at)
        shard_path = shards_dir / f"{shard['id']}.json"
        write_json(shard_path, shard)
        shard_entries.append(
            {
                "id": shard["id"],
                "path": str(shard_path.relative_to(bundle_root)),
                "sha256": file_sha256(shard_path),
                "bytes": shard_path.stat().st_size,
                "claimCount": len(shard["claims"]),
                "requirementCount": len(shard["requirements"]),
                "provenanceCount": len(shard["provenance"]),
                "atomCount": len(shard["atoms"]),
                "edgeCount": len(shard["edges"]),
                "latticeCount": len(shard["lattices"]),
                "recipeCount": len(shard["recipes"]),
            }
        )

    ontology = ontology_v1(created_at)
    ontology_path = schemas_dir / "ontology-v1.json"
    write_json(ontology_path, ontology)
    schema_descriptor_path = schemas_dir / "schema-descriptors-v1.json"
    schema_descriptor_doc = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.schemaDescriptorIndex.v1",
        "versionID": version_id,
        "dataClass": "public_ontology",
        "r2Allowed": True,
        "appCacheAllowed": True,
        "logAllowed": "metadata_only",
        "fixtureAllowed": "public_synthetic_only",
        "createdAt": created_at,
        "schemas": schema_descriptors(created_at),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    write_json(schema_descriptor_path, schema_descriptor_doc)
    schema_entries = [
        {
            "id": "ontology-v1",
            "path": str(ontology_path.relative_to(bundle_root)),
            "sha256": file_sha256(ontology_path),
            "bytes": ontology_path.stat().st_size,
        },
        {
            "id": "schema-descriptors-v1",
            "path": str(schema_descriptor_path.relative_to(bundle_root)),
            "sha256": file_sha256(schema_descriptor_path),
            "bytes": schema_descriptor_path.stat().st_size,
        },
    ]

    source_catalog = source_catalog_manifest(version_id, created_at, harvest_context)
    source_catalog_path = registries_dir / "source-registry.json"
    write_json(source_catalog_path, source_catalog)
    registry_entries = [
        {
            "id": "source-registry",
            "path": str(source_catalog_path.relative_to(bundle_root)),
            "sha256": file_sha256(source_catalog_path),
            "bytes": source_catalog_path.stat().st_size,
        }
    ]

    source_certification = certify_registry()
    source_certification["versionID"] = version_id
    source_certification["createdAt"] = created_at
    source_certification_path = registries_dir / "source-certification.json"
    write_json(source_certification_path, source_certification)
    registry_entries.append(
        {
            "id": "source-certification",
            "path": str(source_certification_path.relative_to(bundle_root)),
            "sha256": file_sha256(source_certification_path),
            "bytes": source_certification_path.stat().st_size,
        }
    )

    shard_docs = [read_json(shards_dir / entry["path"].split("/", 1)[1]) if entry["path"].startswith("shards/") else read_json(bundle_root / entry["path"]) for entry in shard_entries]
    entity_registry = entity_registry_from_shards(shard_docs, version_id)
    entity_registry_path = registries_dir / "entity-registry.json"
    write_json(entity_registry_path, entity_registry)
    registry_entries.append(
        {
            "id": "entity-registry",
            "path": str(entity_registry_path.relative_to(bundle_root)),
            "sha256": file_sha256(entity_registry_path),
            "bytes": entity_registry_path.stat().st_size,
        }
    )

    coverage_manifest = coverage_manifest_from_records(packs, shard_docs, version_id)
    coverage_manifest_path = registries_dir / "coverage-manifest.json"
    write_json(coverage_manifest_path, coverage_manifest)
    registry_entries.append(
        {
            "id": "coverage-manifest",
            "path": str(coverage_manifest_path.relative_to(bundle_root)),
            "sha256": file_sha256(coverage_manifest_path),
            "bytes": coverage_manifest_path.stat().st_size,
        }
    )

    harvest_summary_path: Path | None = None
    if harvest_context:
        harvest_summary = _harvest_bundle_summary(harvest_context)
        harvest_summary_path = registries_dir / "harvest-summary.json"
        write_json(harvest_summary_path, harvest_summary)
        registry_entries.append(
            {
                "id": "harvest-summary",
                "path": str(harvest_summary_path.relative_to(bundle_root)),
                "sha256": file_sha256(harvest_summary_path),
                "bytes": harvest_summary_path.stat().st_size,
            }
        )

    freshness_manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.freshnessManifest",
        "versionID": version_id,
        "dataClass": "public_freshness",
        "r2Allowed": True,
        "appCacheAllowed": True,
        "logAllowed": "metadata_only",
        "fixtureAllowed": "public_synthetic_only",
        "publishedAt": created_at,
        "channel": channel,
        "claimStateBuckets": _claim_state_buckets(packs),
        "sourceFreshnessWatch": [
            {
                "sourceID": source["id"],
                "freshnessCadence": source["freshnessCadence"],
                "lastReviewed": source["lastReviewed"],
                "authorityTier": source["authorityTier"],
                "harvest": source.get("harvest"),
            }
            for source in _source_records([source["id"] for source in SOURCE_REGISTRY], harvest_context)
        ],
        "harvestRun": _harvest_manifest_summary(harvest_context),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    freshness_path = bundle_root / "freshness-manifest.json"
    write_json(freshness_path, freshness_manifest)

    release_manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.releaseManifest",
        "versionID": version_id,
        "dataClass": "public_freshness",
        "r2Allowed": True,
        "appCacheAllowed": True,
        "logAllowed": "metadata_only",
        "fixtureAllowed": "public_synthetic_only",
        "channel": channel,
        "createdAt": created_at,
        "packIndex": pack_entries,
        "schemaIndex": schema_entries,
        "shardIndex": shard_entries,
        "registryIndex": registry_entries,
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
        "dataClass": "public_provenance",
        "r2Allowed": True,
        "appCacheAllowed": True,
        "logAllowed": "metadata_only",
        "fixtureAllowed": "public_synthetic_only",
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
            *(
                [
                    {
                        "id": f"harvest.{harvest_context['manifest']['runID']}",
                        "count": harvest_context["manifest"]["sourceCount"],
                        "sha256": file_sha256(harvest_context["manifestPath"]),
                    }
                ]
                if harvest_context
                else []
            ),
        ],
        "outputs": [
            *pack_entries,
            *schema_entries,
            *shard_entries,
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
        "harvestRunID": harvest_context["manifest"]["runID"] if harvest_context else None,
    }


def _claim_state_buckets(packs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    buckets: dict[str, list[str]] = {}
    for pack in packs:
        for claim in pack["claims"]:
            buckets.setdefault(claim["freshness"], []).append(claim["id"])
    return [{"state": state, "claimIDs": sorted(ids)} for state, ids in sorted(buckets.items())]


def _load_harvest_context(harvest_root: Path) -> dict[str, Any]:
    manifest_path = harvest_root / "manifest.json"
    if not manifest_path.exists():
        raise FileNotFoundError(f"missing harvest manifest: {manifest_path}")
    manifest = read_json(manifest_path)
    records: dict[str, Any] = {}
    for entry in manifest.get("entries", []):
        normalized_path = harvest_root / entry.get("normalizedPath", "")
        if normalized_path.exists():
            records[entry["sourceID"]] = read_json(normalized_path)
    return {
        "root": harvest_root,
        "manifestPath": manifest_path,
        "manifest": manifest,
        "records": records,
    }


def _pack_freshness_state(source_ids: list[str], harvest_context: dict[str, Any] | None) -> str:
    if not harvest_context:
        return "candidate"
    records = harvest_context.get("records", {})
    statuses = [records.get(source_id, {}).get("status") for source_id in source_ids]
    if statuses and all(status == "harvested" for status in statuses):
        return "harvested_candidate"
    if any(status == "harvested" for status in statuses) and any(status in {None, "blocked"} for status in statuses):
        return "partial_harvest_candidate"
    if any(status == "blocked" for status in statuses):
        return "blocked_harvest_candidate"
    return "candidate"


def _harvest_manifest_summary(harvest_context: dict[str, Any] | None) -> dict[str, Any] | None:
    if not harvest_context:
        return None
    manifest = harvest_context["manifest"]
    return {
        "runID": manifest["runID"],
        "createdAt": manifest["createdAt"],
        "adapterVersion": manifest["adapterVersion"],
        "sourceCount": manifest["sourceCount"],
        "harvestedCount": manifest["harvestedCount"],
        "blockedCount": manifest["blockedCount"],
        "privacyScan": manifest.get("privacyScan"),
    }


def _harvest_bundle_summary(harvest_context: dict[str, Any]) -> dict[str, Any]:
    manifest = harvest_context["manifest"]
    records = harvest_context["records"]
    entries: list[dict[str, Any]] = []
    for entry in manifest.get("entries", []):
        record = records.get(entry["sourceID"], {})
        entries.append(
            {
                "sourceID": entry["sourceID"],
                "status": entry["status"],
                "adapterID": record.get("adapterID"),
                "adapterVersion": record.get("adapterVersion"),
                "fetchedAt": record.get("fetchedAt"),
                "recordCount": entry.get("recordCount", 0),
                "claimCount": entry.get("claimCount", 0),
                "normalizedSHA256": entry.get("normalizedSHA256"),
                "rawArtifactHashes": [
                    {
                        "url": artifact["url"],
                        "sha256": artifact["sha256"],
                        "bytes": artifact["bytes"],
                        "contentType": artifact["contentType"],
                    }
                    for artifact in record.get("rawArtifacts", [])
                ],
                "blockedReasons": record.get("blockedReasons", []),
                "missingEnv": record.get("missingEnv", []),
                "freshnessSignals": record.get("freshnessSignals", {}),
            }
        )
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.harvestSummary",
        "runID": manifest["runID"],
        "dataClass": "public_provenance",
        "r2Allowed": True,
        "appCacheAllowed": True,
        "logAllowed": "metadata_only",
        "fixtureAllowed": "public_synthetic_only",
        "createdAt": manifest["createdAt"],
        "adapterVersion": manifest["adapterVersion"],
        "entries": entries,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
