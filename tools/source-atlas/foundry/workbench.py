"""Entity resolution and claim adjudication workbench for Source Atlas."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_id, write_json


PROMOTABLE_STATES = {"source_backed"}
REVIEW_STATES = {"candidate", "source_needed", "stale", "contradicted", "revoked", "disputed"}


def build_workbench(bundle_root: Path, output_path: Path | None = None) -> dict[str, Any]:
    manifest_path = bundle_root / "manifest.json"
    manifest = read_json(manifest_path)
    shards = _load_manifest_entries(bundle_root, manifest, "shardIndex")
    packs = _load_manifest_entries(bundle_root, manifest, "packIndex")

    entities: dict[str, dict[str, Any]] = {}
    extracted_claims: list[dict[str, Any]] = []
    for shard in shards:
        provenance_by_id = {item["id"]: item for item in shard.get("provenance", [])}
        for atom in shard.get("atoms", []):
            entity = _entity_from_atom(atom)
            entities[entity["id"]] = entity
        for claim in shard.get("claims", []):
            extracted_claims.append(_claim_record(claim, shard, provenance_by_id))

    adjudications = _adjudicate_claims(extracted_claims)
    unsupported = [claim for claim in extracted_claims if claim["state"] not in PROMOTABLE_STATES or not claim["provenanceIDs"]]
    conflicts = [item for item in adjudications if item["disposition"] == "requires_review_conflict"]
    source_states = _source_states(packs, extracted_claims)
    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.resolutionWorkbench",
        "bundleRoot": str(bundle_root),
        "entityCount": len(entities),
        "claimCount": len(extracted_claims),
        "unsupportedClaimCount": len(unsupported),
        "conflictCount": len(conflicts),
        "entities": sorted(entities.values(), key=lambda item: item["id"]),
        "extractedClaims": sorted(extracted_claims, key=lambda item: item["claimID"]),
        "adjudications": adjudications,
        "unsupportedClaims": unsupported,
        "sourceStates": source_states,
        "promotionBoundary": {
            "silentWinnerSelectionAllowed": False,
            "conflictedClaimsRequireReview": True,
            "candidateClaimsRequireSourceBeforePromotion": True,
            "revokedOrStaleClaimsDoNotPromote": True,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    issues = boundary_issue_strings(boundary_issues_for_value(result, "resolution-workbench"))
    result["valid"] = not issues
    result["issues"] = issues
    if output_path:
        write_json(output_path, result)
    return result


def entity_registry_from_shards(shards: list[dict[str, Any]], version_id: str) -> dict[str, Any]:
    entities: dict[str, dict[str, Any]] = {}
    for shard in shards:
        for atom in shard.get("atoms", []):
            entity = _entity_from_atom(atom)
            entity["versionID"] = version_id
            entity["pathwayID"] = shard.get("pathwayID")
            entities[entity["id"]] = entity
    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.entityRegistry",
        "versionID": version_id,
        "dataClass": "public_ontology",
        "r2Allowed": True,
        "appCacheAllowed": True,
        "logAllowed": "metadata_only",
        "fixtureAllowed": "public_synthetic_only",
        "entityCount": len(entities),
        "entities": sorted(entities.values(), key=lambda item: item["id"]),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    result["issues"] = boundary_issue_strings(boundary_issues_for_value(result, "entity-registry"))
    result["valid"] = not result["issues"]
    return result


def _load_manifest_entries(bundle_root: Path, manifest: dict[str, Any], key: str) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for entry in manifest.get(key, []):
        records.append(read_json(bundle_root / entry["path"]))
    return records


def _entity_from_atom(atom: dict[str, Any]) -> dict[str, Any]:
    payload = {
        "label": atom.get("label"),
        "atomType": atom.get("atomType"),
        "sourceIDs": sorted(atom.get("sourceIDs", [])),
    }
    return {
        "id": stable_id("entity.source_atlas", payload),
        "label": atom.get("label"),
        "entityType": atom.get("atomType"),
        "atomID": atom.get("id"),
        "sourceIDs": sorted(atom.get("sourceIDs", [])),
        "provenanceIDs": sorted(atom.get("provenanceIDs", [])),
        "resolutionState": "resolved_public_reference_atom",
        "ambiguity": [],
    }


def _claim_record(claim: dict[str, Any], shard: dict[str, Any], provenance_by_id: dict[str, dict[str, Any]]) -> dict[str, Any]:
    provenance_ids = sorted(claim.get("provenanceIDs", []))
    missing_provenance = [item for item in provenance_ids if item not in provenance_by_id]
    ambiguity: list[str] = []
    if claim.get("state") in REVIEW_STATES:
        ambiguity.append(f"claim_state:{claim.get('state')}")
    if missing_provenance:
        ambiguity.append("missing_provenance")
    if not claim.get("sourceIDs"):
        ambiguity.append("missing_sources")
    return {
        "claimID": claim.get("id"),
        "text": claim.get("text"),
        "claimType": claim.get("claimType"),
        "state": claim.get("state"),
        "freshness": claim.get("freshness"),
        "sourceIDs": sorted(claim.get("sourceIDs", [])),
        "provenanceIDs": provenance_ids,
        "missingProvenanceIDs": missing_provenance,
        "pathwayID": shard.get("pathwayID"),
        "sourceState": _source_state_for_claim(claim),
        "ambiguity": ambiguity,
        "nonClaimBoundary": "claim is public/reference only and is not final user eligibility, schedule, Step list, or runtime recommendation proof",
    }


def _source_state_for_claim(claim: dict[str, Any]) -> str:
    if claim.get("state") == "source_backed" and claim.get("sourceIDs") and claim.get("provenanceIDs"):
        return "source_backed_with_provenance"
    if claim.get("state") == "source_backed":
        return "source_backed_missing_provenance"
    return f"review_required_{claim.get('state', 'unknown')}"


def _adjudicate_claims(claims: list[dict[str, Any]]) -> list[dict[str, Any]]:
    groups: dict[str, list[dict[str, Any]]] = {}
    for claim in claims:
        key = _adjudication_key(claim)
        groups.setdefault(key, []).append(claim)
    adjudications: list[dict[str, Any]] = []
    for key, group in sorted(groups.items()):
        states = sorted({claim["state"] for claim in group})
        texts = sorted({claim["text"] for claim in group})
        source_sets = [tuple(claim["sourceIDs"]) for claim in group]
        has_conflict = len(states) > 1 or any(state in {"contradicted", "disputed", "revoked"} for state in states)
        if has_conflict:
            disposition = "requires_review_conflict"
            selected_claim_id = None
        elif all(claim["state"] in PROMOTABLE_STATES and claim["provenanceIDs"] for claim in group):
            disposition = "source_backed_no_conflict"
            selected_claim_id = group[0]["claimID"]
        else:
            disposition = "requires_source_or_freshness_review"
            selected_claim_id = None
        adjudications.append(
            {
                "id": stable_id("adjudication.source_atlas", {"key": key, "claimIDs": [claim["claimID"] for claim in group]}),
                "claimIDs": [claim["claimID"] for claim in group],
                "claimTexts": texts,
                "states": states,
                "sourceIDSets": [list(item) for item in source_sets],
                "disposition": disposition,
                "selectedClaimID": selected_claim_id,
                "silentWinnerSelectionAllowed": False,
            }
        )
    return adjudications


def _adjudication_key(claim: dict[str, Any]) -> str:
    text = re.sub(r"[^a-z0-9]+", " ", str(claim.get("text", "")).lower()).strip()
    return f"{claim.get('claimType')}::{text}"


def _source_states(packs: list[dict[str, Any]], claims: list[dict[str, Any]]) -> list[dict[str, Any]]:
    claim_source_ids = {source_id for claim in claims for source_id in claim.get("sourceIDs", [])}
    states: list[dict[str, Any]] = []
    for pack in packs:
        for source in pack.get("sources", []):
            status = source.get("harvest", {}).get("status") or "registry_only"
            states.append(
                {
                    "sourceID": source.get("id"),
                    "authorityTier": source.get("authorityTier"),
                    "freshnessCadence": source.get("freshnessCadence"),
                    "harvestStatus": status,
                    "usedByClaims": source.get("id") in claim_source_ids,
                    "blockedReasons": source.get("harvest", {}).get("blockedReasons", []),
                }
            )
    return sorted(states, key=lambda item: item["sourceID"] or "")
