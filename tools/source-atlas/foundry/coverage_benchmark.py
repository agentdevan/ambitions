"""Coverage diff and golden benchmark runner substrate for Foundry."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_id, write_json
from .validator import ALLOWED_CLAIM_STATES


GOLDEN_BENCHMARKS = [
    {
        "id": "golden.civic.us_president.source_backed_requirements",
        "requiredPackID": "pack.civic.us_president",
        "requiredClaimTypes": ["eligibility_rule"],
        "requiredSourceIDs": ["nara.constitution.presidency"],
        "critical": True,
    },
    {
        "id": "golden.career.nasa_astronaut.selection_cycle_claims",
        "requiredPackID": "pack.career.nasa_astronaut",
        "requiredClaimTypes": ["eligibility_rule", "credential_rule", "experience_rule", "medical_physical_rule", "selection_pipeline"],
        "requiredSourceIDs": ["nasa.astronaut.requirements", "nasa.astronaut.selection"],
        "critical": True,
    },
    {
        "id": "golden.occupation.transfer_graph_foundation",
        "requiredPackID": "pack.career.nasa_astronaut",
        "requiredSourceIDs": ["onet.database"],
        "requiredAtomLabels": ["systems_engineering", "technical_communication"],
        "critical": False,
    },
]


def coverage_manifest_from_records(
    packs: list[dict[str, Any]],
    shards: list[dict[str, Any]],
    version_id: str,
) -> dict[str, Any]:
    claim_records = [claim for pack in packs for claim in pack.get("claims", [])]
    source_ids = sorted({source["id"] for pack in packs for source in pack.get("sources", [])})
    domains = sorted({domain for pack in packs for domain in pack.get("domains", [])})
    atom_types = sorted({atom.get("atomType") for shard in shards for atom in shard.get("atoms", []) if atom.get("atomType")})
    edge_types = sorted({edge.get("relationship") for shard in shards for edge in shard.get("edges", []) if edge.get("relationship")})
    requirement_types = sorted({item.get("gateType") for pack in packs for item in pack.get("requirements", []) if item.get("gateType")})
    state_buckets: dict[str, list[str]] = {}
    freshness_buckets: dict[str, list[str]] = {}
    for claim in claim_records:
        state_buckets.setdefault(claim.get("state", "unknown"), []).append(claim.get("id", "<unknown>"))
        freshness_buckets.setdefault(claim.get("freshness", "unknown"), []).append(claim.get("id", "<unknown>"))
    stale_clusters = [
        {"state": state, "claimIDs": sorted(ids)}
        for state, ids in sorted(freshness_buckets.items())
        if state in {"stale_warning", "unknown"}
    ]
    blocked_lanes = [
        {
            "packID": pack.get("id"),
            "sourceID": source.get("id"),
            "blockedReasons": source.get("harvest", {}).get("blockedReasons", []),
        }
        for pack in packs
        for source in pack.get("sources", [])
        if source.get("harvest", {}).get("status") == "blocked"
    ]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.coverageManifest",
        "versionID": version_id,
        "dataClass": "public_provenance",
        "r2Allowed": True,
        "appCacheAllowed": True,
        "logAllowed": "metadata_only",
        "fixtureAllowed": "public_synthetic_only",
        "domains": domains,
        "sourceIDs": source_ids,
        "entityKinds": atom_types,
        "atomTypes": atom_types,
        "requirementTypes": requirement_types,
        "edgeTypes": edge_types,
        "claimStateBuckets": [{"state": state, "claimIDs": sorted(ids)} for state, ids in sorted(state_buckets.items())],
        "freshnessBuckets": [{"state": state, "claimIDs": sorted(ids)} for state, ids in sorted(freshness_buckets.items())],
        "staleClusters": stale_clusters,
        "blockedLanes": blocked_lanes,
        "highRiskReviewQueues": [
            {"queue": "stale_or_unknown_freshness", "claimIDs": sorted({claim_id for row in stale_clusters for claim_id in row["claimIDs"]})},
            {"queue": "blocked_source_lanes", "sourceIDs": sorted({row["sourceID"] for row in blocked_lanes})},
        ],
        "conflictCount": 0,
        "shardHealth": [
            {
                "shardID": shard.get("id"),
                "pathwayID": shard.get("pathwayID"),
                "claimCount": len(shard.get("claims", [])),
                "requirementCount": len(shard.get("requirements", [])),
                "provenanceCount": len(shard.get("provenance", [])),
                "atomCount": len(shard.get("atoms", [])),
                "edgeCount": len(shard.get("edges", [])),
                "latticeCount": len(shard.get("lattices", [])),
                "recipeCount": len(shard.get("recipes", [])),
            }
            for shard in shards
        ],
        "benchmarkReadiness": "candidate_only_not_production_coverage",
        "productionCoverageClaimed": False,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }


def coverage_diff(bundle_root: Path, previous_bundle_root: Path | None = None, output_path: Path | None = None) -> dict[str, Any]:
    manifest = read_json(bundle_root / "manifest.json")
    packs = _load_entries(bundle_root, manifest, "packIndex")
    shards = _load_entries(bundle_root, manifest, "shardIndex")
    previous_manifest = read_json(previous_bundle_root / "manifest.json") if previous_bundle_root else None
    previous_packs = _load_entries(previous_bundle_root, previous_manifest, "packIndex") if previous_bundle_root and previous_manifest else []
    previous_claim_ids = {claim["id"] for pack in previous_packs for claim in pack.get("claims", [])}

    claim_records = [claim for pack in packs for claim in pack.get("claims", [])]
    source_ids = {source["id"] for pack in packs for source in pack.get("sources", [])}
    claim_ids = {claim["id"] for claim in claim_records}
    stale_claims = [claim for claim in claim_records if claim.get("state") in {"stale", "revoked"} or claim.get("freshness") == "stale_warning"]
    unsupported_claims = [claim for claim in claim_records if claim.get("state") not in ALLOWED_CLAIM_STATES or claim.get("state") != "source_backed"]
    missing_sources = sorted(_referenced_source_ids(packs) - source_ids)
    weak_domains = _weak_domains(packs)
    new_claims = sorted(claim_ids - previous_claim_ids) if previous_bundle_root else []
    removed_claims = sorted(previous_claim_ids - claim_ids) if previous_bundle_root else []
    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.coverageDiff",
        "bundleRoot": str(bundle_root),
        "previousBundleRoot": str(previous_bundle_root) if previous_bundle_root else None,
        "packCount": len(packs),
        "claimCount": len(claim_records),
        "sourceCount": len(source_ids),
        "missingSources": missing_sources,
        "staleClaims": [_claim_summary(claim) for claim in stale_claims],
        "unsupportedClaims": [_claim_summary(claim) for claim in unsupported_claims],
        "weakDomains": weak_domains,
        "newClaimIDs": new_claims,
        "removedClaimIDs": removed_claims,
        "benchmarkReadiness": "candidate_only_not_production_coverage",
        "productionCoverageClaimed": False,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    result["valid"] = not missing_sources and not stale_claims and not unsupported_claims
    if output_path:
        write_json(output_path, result)
    return result


def run_golden_benchmarks(bundle_root: Path, output_path: Path | None = None) -> dict[str, Any]:
    manifest = read_json(bundle_root / "manifest.json")
    packs = {pack["id"]: pack for pack in _load_entries(bundle_root, manifest, "packIndex")}
    shards = _load_entries(bundle_root, manifest, "shardIndex")
    atom_labels_by_pack = _atom_labels_by_pack(shards)
    results: list[dict[str, Any]] = []
    for benchmark in GOLDEN_BENCHMARKS:
        pack = packs.get(benchmark["requiredPackID"])
        issues: list[str] = []
        if not pack:
            issues.append("missing_required_pack")
        else:
            claim_types = {claim.get("claimType") for claim in pack.get("claims", [])}
            source_ids = {source.get("id") for source in pack.get("sources", [])}
            missing_claim_types = sorted(set(benchmark.get("requiredClaimTypes", [])) - claim_types)
            missing_sources = sorted(set(benchmark.get("requiredSourceIDs", [])) - source_ids)
            missing_atoms = sorted(set(benchmark.get("requiredAtomLabels", [])) - atom_labels_by_pack.get(benchmark["requiredPackID"], set()))
            if missing_claim_types:
                issues.append(f"missing_claim_types:{','.join(missing_claim_types)}")
            if missing_sources:
                issues.append(f"missing_sources:{','.join(missing_sources)}")
            if missing_atoms:
                issues.append(f"missing_atom_labels:{','.join(missing_atoms)}")
            if any(claim.get("state") != "source_backed" for claim in pack.get("claims", [])):
                issues.append("non_source_backed_claim_present")
        results.append(
            {
                "id": benchmark["id"],
                "critical": benchmark["critical"],
                "passed": not issues,
                "issues": issues,
                "requiredPackID": benchmark["requiredPackID"],
            }
        )
    critical_failures = [item for item in results if item["critical"] and not item["passed"]]
    output = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goldenBenchmarkRun",
        "id": stable_id("benchmark.source_atlas", {"bundleRoot": str(bundle_root), "benchmarks": GOLDEN_BENCHMARKS}),
        "bundleRoot": str(bundle_root),
        "valid": not critical_failures,
        "benchmarkCount": len(results),
        "passedCount": sum(1 for item in results if item["passed"]),
        "criticalFailureCount": len(critical_failures),
        "results": results,
        "benchmarkReadiness": "candidate_only_not_production_coverage",
        "productionCoverageClaimed": False,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    if output_path:
        write_json(output_path, output)
    return output


def _load_entries(bundle_root: Path, manifest: dict[str, Any], key: str) -> list[dict[str, Any]]:
    return [read_json(bundle_root / entry["path"]) for entry in manifest.get(key, [])]


def _referenced_source_ids(packs: list[dict[str, Any]]) -> set[str]:
    ids: set[str] = set()
    for pack in packs:
        for claim in pack.get("claims", []):
            ids.update(claim.get("sourceIDs", []))
        for pathway in pack.get("pathways", []):
            ids.update(pathway.get("sourceIDs", []))
    return ids


def _weak_domains(packs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for pack in packs:
        source_count = len(pack.get("sources", []))
        claim_count = len(pack.get("claims", []))
        if source_count < 2 or claim_count < 3:
            rows.append(
                {
                    "packID": pack.get("id"),
                    "domains": pack.get("domains", []),
                    "sourceCount": source_count,
                    "claimCount": claim_count,
                    "reason": "low_source_or_claim_count",
                }
            )
    return rows


def _claim_summary(claim: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": claim.get("id"),
        "claimType": claim.get("claimType"),
        "state": claim.get("state"),
        "freshness": claim.get("freshness"),
        "sourceIDs": sorted(claim.get("sourceIDs", [])),
    }


def _atom_labels_by_pack(shards: list[dict[str, Any]]) -> dict[str, set[str]]:
    labels: dict[str, set[str]] = {}
    for shard in shards:
        pack_id = str(shard.get("pathwayID", "")).replace("pathway.", "pack.")
        labels.setdefault(pack_id, set()).update(atom.get("label") for atom in shard.get("atoms", []) if atom.get("label"))
    return labels
