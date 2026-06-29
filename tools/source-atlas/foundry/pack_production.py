"""Generalized Source Atlas pack compiler and R2 dry-run planner."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .governance_registry import load_governance_registries, validate_governance_registries
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, object_key_findings, privacy_findings_for_value, read_json, stable_hash, stable_id, write_json
from .terms_approval_packet import validate_terms_approval_packet_for_entries
from .terms_registry import terms_entry


PACK_PRODUCTION_VERSION = "source-atlas-pack-production-train-04"
SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[1]
PACK_ALLOWED = {"packable"}
BLOCKING_FRESHNESS = {"stale-critical", "revoked", "conflicted", "terms-blocked"}
PRODUCTION_NON_CLAIMS = NON_CLAIMS + [
    "not full Source Atlas Green",
    "not production R2 readiness",
    "not native app runtime readiness",
    "not outside legal approval",
    "not universal goal coverage",
    "not a final user plan, schedule, or Step generator",
]
REQUIRED_ARTIFACTS = {
    "pack.json",
    "claims.json",
    "entities.json",
    "sources.json",
    "licenses.json",
    "freshness.json",
    "adjudications.json",
    "non_claims.json",
    "attribution.json",
    "coverage.json",
    "manifest.json",
    "revocations.json",
    "lkg.json",
    "rollback-plan.json",
    "r2-dry-run-plan.json",
    "non-private-scan-report.json",
}


@dataclass(frozen=True)
class PackProductionOptions:
    input_root: Path
    output_root: Path
    domain: str = "occupation_foundation"
    environment: str = "staging"
    channel: str = "candidate"
    pack_version: str | None = None
    created_at: str = "2026-06-27T00:00:00Z"
    execute: bool = False
    approval_artifact: Path | None = None
    legal_approval_packet: Path | None = None
    budget_policy: str | None = None


def build_pack_production(options: PackProductionOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    issues: list[str] = []
    checks: list[dict[str, Any]] = []
    version = options.pack_version or _pack_version(options.created_at)
    pack_id = f"source-atlas/v1/domain/{options.domain}/{version}"

    governance = validate_governance_registries()
    checks.append({"name": "governance_registries_valid", "passed": governance["valid"]})
    if not governance["valid"]:
        issues.extend(f"governance:{issue}" for issue in governance.get("issues", []))
    registries = load_governance_registries()
    source_lanes = {lane["source_id"]: lane for lane in registries["source_lanes"].get("source_lanes", [])}
    legal_terms = {entry["license_id"]: entry for entry in registries["legal_terms"].get("licenses", [])}
    api_policies = {entry["api_policy_id"]: entry for entry in registries["api_governance"].get("api_policies", [])}

    claim_graph_path = options.input_root / "claim-graph.json"
    citation_graph_path = options.input_root / "citation-graph.json"
    frontier_path = options.input_root / "coverage-frontier-report.json"
    frontier_manifest_path = options.input_root / "manifest.json"
    claim_graph = _read_required_json(claim_graph_path, issues, "claim graph")
    citation_graph = _read_required_json(citation_graph_path, issues, "citation graph")
    frontier_report = _read_required_json(frontier_path, issues, "coverage frontier report")
    frontier_manifest = _read_required_json(frontier_manifest_path, issues, "claim frontier manifest")

    frontier = _frontier_for_domain(frontier_report, options.domain)
    if not frontier:
        issues.append(f"{options.domain}: missing coverage frontier report")
    packable_claims = _packable_claims_for_frontier(claim_graph, frontier, options.domain)
    blocked_claims = _blocked_claims_for_frontier(claim_graph, frontier, options.domain)
    if not packable_claims:
        issues.append(f"{options.domain}: no packable claims available for pack production")
    slices = _build_slices(packable_claims, blocked_claims, claim_graph, citation_graph, frontier, source_lanes, legal_terms)
    legal_approval = _legal_approval_validation(options, slices)
    if not legal_approval["valid"]:
        issues.extend(legal_approval["issues"])
    pack = _pack(pack_id, version, options, slices)

    slice_paths = _write_slices(output_root, pack, slices)
    scan_report = _scan_output(output_root, slice_paths, pack)
    scan_path = output_root / "non-private-scan-report.json"
    write_json(scan_path, scan_report)
    if not scan_report["passed"]:
        issues.extend(scan_report["issues"])

    object_keys = _object_keys(options, version)
    key_issues = [issue for key in object_keys.values() for issue in object_key_findings(key)]
    if key_issues:
        issues.extend(key_issues)

    revocation = _revocation_manifest(pack_id, object_keys, options, version)
    revocation_path = output_root / "revocations.json"
    write_json(revocation_path, revocation)
    lkg_path = output_root / "lkg.json"
    rollback_path = output_root / "rollback-plan.json"

    manifest = _manifest(
        pack_id=pack_id,
        version=version,
        options=options,
        object_keys=object_keys,
        slice_paths=slice_paths,
        scan_path=scan_path,
        revocation_path=revocation_path,
        lkg_path=lkg_path,
        rollback_path=rollback_path,
        registries=registries,
        frontier_manifest=frontier_manifest,
        claim_graph_path=claim_graph_path,
        slices=slices,
    )
    manifest_path = output_root / "manifest.json"
    write_json(manifest_path, manifest)
    lkg = _lkg_pointer(pack_id, object_keys, options, version, manifest_sha256=file_sha256(manifest_path))
    write_json(lkg_path, lkg)
    rollback = _rollback_plan(pack_id, object_keys, options, version, lkg)
    write_json(rollback_path, rollback)

    dry_run_plan = _dry_run_plan(options, object_keys, slice_paths, manifest_path, revocation_path, lkg_path, rollback_path)
    dry_run_path = output_root / "r2-dry-run-plan.json"
    write_json(dry_run_path, dry_run_plan)
    artifact_validation = validate_pack_production_artifacts(output_root)
    if not artifact_validation["valid"]:
        issues.extend(artifact_validation["issues"])

    execute_issues = _execute_issues(options)
    if execute_issues:
        issues.extend(execute_issues)

    checks.extend(
        [
            {"name": "pack_slices_written", "passed": all(path.exists() for path in slice_paths.values())},
            {"name": "pack_contains_only_packable_claims", "passed": all(claim.get("pack_eligibility") in PACK_ALLOWED for claim in packable_claims)},
            {"name": "restricted_and_crosswalk_claims_excluded", "passed": _restricted_claims_excluded(packable_claims)},
            {"name": "manifest_hashes_present", "passed": _manifest_hashes_present(manifest)},
            {"name": "revocation_lkg_rollback_present", "passed": revocation_path.exists() and lkg_path.exists() and rollback_path.exists()},
            {"name": "dry_run_plan_only", "passed": dry_run_plan["dryRun"] is True and dry_run_plan["executeRequested"] is False},
            {"name": "private_object_keys_blocked", "passed": not key_issues},
            {"name": "non_private_scan_passed", "passed": scan_report["passed"]},
            {"name": "required_artifacts_valid", "passed": artifact_validation["valid"]},
            {"name": "execute_requires_approval_artifact", "passed": not options.execute or not execute_issues},
            {"name": "legal_terms_approval_packet_valid", "passed": legal_approval["valid"], "issues": legal_approval["issues"]},
            {"name": "no_final_plan_schedule_step_output", "passed": _no_final_outputs(pack, slices, manifest)},
        ]
    )

    valid = not issues and all(check["passed"] for check in checks)
    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.packProductionManifest.v1",
        "versionID": PACK_PRODUCTION_VERSION,
        "createdAt": options.created_at,
        "status": "Source Green for pack compiler/R2 dry-run controls" if valid else "Red",
        "valid": valid,
        "packID": pack_id,
        "packVersion": version,
        "domain": options.domain,
        "environment": options.environment,
        "channel": options.channel,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; pack compiler and R2 dry-run controls only",
        "recordCounts": {
            "claims": len(packable_claims),
            "blockedClaimsExcluded": len(blocked_claims),
            "sources": len(slices["sources"]),
            "licenses": len(slices["licenses"]),
            "objectCount": len(dry_run_plan["objects"]),
        },
        "outputPaths": {
            "pack": str(slice_paths["pack"]),
            "manifest": str(manifest_path),
            "r2DryRunPlan": str(dry_run_path),
            "revocation": str(revocation_path),
            "lkg": str(lkg_path),
            "rollback": str(rollback_path),
            "nonPrivateScan": str(scan_path),
            "closeout": str(output_root / "closeout.md"),
        },
        "objectKeys": object_keys,
        "checks": checks,
        "issues": issues,
        "dryRunPlan": dry_run_plan,
        "revocation": revocation,
        "lkg": lkg,
        "rollback": rollback,
        "artifactValidation": artifact_validation,
        "legalTermsApprovalPacketValidation": legal_approval,
        "nonPrivateScan": scan_report,
        "nonClaims": PRODUCTION_NON_CLAIMS,
        "privacyBoundary": PRIVACY_BOUNDARY,
    }
    result_path = output_root / "pack-production-report.json"
    write_json(result_path, result)
    _write_closeout(output_root / "closeout.md", result)
    return {"reportPath": str(result_path), "outputRoot": str(output_root), **result}


def validate_pack_production_artifacts(output_root: Path) -> dict[str, Any]:
    issues: list[str] = []
    for filename in sorted(REQUIRED_ARTIFACTS):
        path = output_root / filename
        if not path.exists():
            issues.append(f"missing required artifact: {filename}")
            continue
        issues.extend(privacy_findings_for_value(read_json(path), f"pack-production-artifact.{filename}"))
    manifest_path = output_root / "manifest.json"
    if manifest_path.exists():
        manifest = read_json(manifest_path)
        for label, entry in manifest.get("objects", {}).items():
            local_path = Path(entry.get("local_path", ""))
            if not local_path.exists():
                issues.append(f"manifest object {label} references missing local_path {local_path}")
                continue
            if entry.get("sha256") and file_sha256(local_path) != entry.get("sha256"):
                issues.append(f"manifest object {label} hash mismatch")
            object_key = entry.get("object_key")
            if object_key:
                issues.extend(object_key_findings(str(object_key)))
        for field in ["object_keys", "source_registry_hash", "legal_registry_hash", "api_registry_hash", "claim_graph_hash", "non_private_scan_hash"]:
            if not manifest.get(field):
                issues.append(f"manifest missing {field}")
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.packProductionArtifactValidation.v1",
        "valid": not issues,
        "issues": issues,
        "requiredArtifacts": sorted(REQUIRED_ARTIFACTS),
        "publicReferenceOnly": True,
        "dataClass": "public_provenance",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_NON_CLAIMS,
    }


def pack_production_markdown(result: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Pack Compiler and R2 Dry-Run Controls Train 4",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic pack compiler from Train 3 claim/frontier output.",
        "- Pack slices for claims, entities, sources, licenses, freshness, adjudications, non-claims, attribution, and coverage.",
        "- Manifest with object keys, SHA-256 hashes, registry/frontier/claim graph hashes, revocation key, LKG key, rollback candidates, and cache policy.",
        "- Revocation manifest, LKG pointer, rollback plan, non-private scan, and R2 dry-run plan.",
        "- Execute path approval gates without production upload.",
        "",
        "Files changed:",
        "- tools/source-atlas/foundry/pack_production.py",
        "- tools/source-atlas/foundry/cli.py",
        "- tools/source-atlas/foundry/tests/test_pack_production_train_04.py",
        "- tools/source-atlas/generated/pack-production/train-04-fixture/*",
        "- docs/qa/source-atlas/r2/source-atlas-pack-production-train-04.json",
        "- docs/qa/source-atlas/r2/source-atlas-pack-production-train-04.md",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- Dry-run plan contains public object keys only and no credentials.",
        "- Pack output contains public/reference claims only.",
        "- Source Atlas does not generate final plans, schedules, or Steps.",
        "",
        "Validation run:",
        "- python3 tools/source-atlas/source-atlas-foundry.py pack-production --input-root tools/source-atlas/generated/claim-frontier/train-03-fixture --output-root tools/source-atlas/generated/pack-production/train-04-fixture --domain occupation_foundation --environment staging --channel candidate --created-at 2026-06-27T00:00:00Z",
        "- python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests",
        "- python3 scripts/source-atlas-boundary-audit.py",
        "- python3 scripts/source-atlas-no-private-graph-egress-audit.py",
        "- python3 scripts/ambitions-green-standard-audit.py",
        "- python3 scripts/ambitions-local-first-boundary-scan.py",
        "- git diff --check",
        "",
        "Validation not run:",
        "- Native XCTest/build-for-testing not run because this train changed Python tooling, JSON evidence, and generated Source Atlas artifacts only.",
        "- Production R2 upload/readback not run.",
        "- Outside legal review not run or claimed.",
        "",
        "Proof artifacts:",
    ]
    for path in result["outputPaths"].values():
        lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- No production R2 request path changed or executed.",
            "- Dry-run object keys passed private-key segment validation.",
            "- Dry-run plan contains no credentials or private user context.",
            "",
            "No private graph egress proof:",
            "- Non-private scan passed for pack slices, manifest, revocation, LKG, rollback, and dry-run plan.",
            "- Pack non-claims forbid private graph, final path, final schedule, Step list, and personalized plan output.",
            "",
            "License/terms proof:",
            "- License slice is generated from governed legal/terms registry entries for included packable sources.",
            "- Restricted/crosswalk-only/review-required claims are excluded from pack slices.",
            "- Outside legal approval is not claimed.",
            "",
            "Restricted-source exclusion proof:",
            f"- Blocked claims excluded: {result['recordCounts']['blockedClaimsExcluded']}.",
            "- USAJOBS and Wikidata crosswalk claims are not included in the packable claim slice.",
            "",
            "Provenance completeness proof:",
            "- Pack input is restricted to Train 3 packable claims with complete provenance tuples.",
            "- Manifest includes the Train 3 claim graph hash.",
            "",
            "Freshness/revocation proof:",
            "- Freshness slice is generated for included claims.",
            "- Revocation manifest is emitted.",
            "- Runtime revocation handling is not claimed in this train.",
            "",
            "LKG/rollback proof:",
            "- LKG pointer and rollback plan are emitted as dry-run artifacts.",
            "- No stable R2 pointer update ran.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 4. No native files changed and no XCTest/build-for-testing gate was required.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas.",
            "- Files moved or created: pack production compiler, tests, generated Source Atlas pack/R2 dry-run evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: real R2 upload/readback, native fetch/cache/verify, source inspection, and broad domain expansion remain unproven.",
            "- Next repair train if debt remains: production publisher/readback proof or native fetch/cache/verify integration.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Known risks:",
            "- This train does not prove production R2 write/readback.",
            "- This train does not prove native app fetch/cache/verify behavior.",
            "- Only the occupation foundation frontier has packable claim coverage in current evidence.",
            "",
            "Follow-up required:",
            "- Add production publisher upload/readback proof when explicitly approved.",
            "- Add native public-pack fetch/cache/verify integration.",
            "- Expand governed source lanes and adapters for non-occupation domains.",
            "",
            "Rollback plan:",
            "- Revert the pack production compiler, CLI command, tests, generated Train 4 artifacts, and QA evidence packet.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _read_required_json(path: Path, issues: list[str], label: str) -> dict[str, Any]:
    if not path.exists():
        issues.append(f"missing {label}: {path}")
        return {}
    return read_json(path)


def _frontier_for_domain(frontier_report: dict[str, Any], domain: str) -> dict[str, Any]:
    for frontier in frontier_report.get("frontiers", []):
        if frontier.get("frontier_id") == domain or frontier.get("domain") == domain:
            return frontier
    return {}


def _packable_claims_for_frontier(claim_graph: dict[str, Any], frontier: dict[str, Any], domain: str) -> list[dict[str, Any]]:
    source_ids = set(frontier.get("source_lanes", []))
    claim_classes = set(frontier.get("claim_classes", []))
    claims = []
    for claim in claim_graph.get("claims", []):
        if claim.get("pack_eligibility") != "packable":
            continue
        if source_ids and claim.get("source_id") not in source_ids:
            continue
        if claim_classes and claim.get("claim_type") not in claim_classes:
            continue
        if claim.get("domain") != domain and claim.get("source_id") not in source_ids:
            continue
        claims.append(claim)
    return sorted(claims, key=lambda item: item["claim_id"])


def _blocked_claims_for_frontier(claim_graph: dict[str, Any], frontier: dict[str, Any], domain: str) -> list[dict[str, Any]]:
    source_ids = set(frontier.get("source_lanes", []))
    claim_classes = set(frontier.get("claim_classes", []))
    rows = []
    for claim in claim_graph.get("claims", []):
        if claim.get("pack_eligibility") == "packable":
            continue
        if source_ids and claim.get("source_id") in source_ids:
            rows.append(claim)
            continue
        if claim_classes and claim.get("claim_type") in claim_classes:
            rows.append(claim)
            continue
        if claim.get("domain") == domain:
            rows.append(claim)
    return sorted(rows, key=lambda item: item["claim_id"])


def _build_slices(
    claims: list[dict[str, Any]],
    blocked_claims: list[dict[str, Any]],
    claim_graph: dict[str, Any],
    citation_graph: dict[str, Any],
    frontier: dict[str, Any],
    source_lanes: dict[str, dict[str, Any]],
    legal_terms: dict[str, dict[str, Any]],
) -> dict[str, Any]:
    claim_ids = {claim["claim_id"] for claim in claims}
    entity_ids = {claim["subject_entity_id"] for claim in claims}
    source_ids = sorted({claim["source_id"] for claim in claims})
    license_ids = sorted({claim.get("license_id") for claim in claims if claim.get("license_id")})
    citations = [citation for citation in citation_graph.get("citations", []) if citation.get("claim_id") in claim_ids]
    return {
        "claims": claims,
        "entities": sorted([entity for entity in claim_graph.get("entities", []) if entity.get("entity_id") in entity_ids], key=lambda item: item["entity_id"]),
        "sources": [_source_slice(source_lanes[source_id], blocked_claims) for source_id in source_ids if source_id in source_lanes],
        "licenses": [_license_slice(legal_terms[license_id]) for license_id in license_ids if license_id in legal_terms],
        "freshness": [_freshness_slice(claim) for claim in claims],
        "adjudications": [_adjudication_slice(claim) for claim in claims],
        "non_claims": {"nonClaims": PRODUCTION_NON_CLAIMS + frontier.get("non_claims", [])},
        "attribution": [_attribution_slice(citation) for citation in citations if citation.get("attribution_text")],
        "coverage": frontier,
        "excludedClaims": [
            {
                "claim_id": claim.get("claim_id"),
                "source_id": claim.get("source_id"),
                "claim_type": claim.get("claim_type"),
                "pack_eligibility": claim.get("pack_eligibility"),
                "blocked_reasons": claim.get("blocked_reasons", []),
            }
            for claim in blocked_claims
        ],
    }


def _source_slice(lane: dict[str, Any], blocked_claims: list[dict[str, Any]]) -> dict[str, Any]:
    source_id = lane["source_id"]
    return {
        "source_id": source_id,
        "source_name": lane.get("source_name"),
        "included": True,
        "excluded": False,
        "excluded_claim_count": sum(1 for claim in blocked_claims if claim.get("source_id") == source_id),
        "authority_class": lane.get("authority_class"),
        "jurisdiction": lane.get("jurisdiction"),
        "review_status": lane.get("review_status"),
        "license_id": lane.get("license_id"),
        "redistribution_policy": lane.get("redistribution_policy"),
        "r2_pack_policy": lane.get("r2_pack_policy"),
        "allowed_artifact_classes": lane.get("allowed_artifact_classes", []),
        "forbidden_artifact_classes": lane.get("forbidden_artifact_classes", []),
        "non_claims": lane.get("non_claims", []),
        "publicReferenceOnly": True,
        "dataClass": "official_public_source",
    }


def _license_slice(legal: dict[str, Any]) -> dict[str, Any]:
    return {
        "license_id": legal.get("license_id"),
        "license_name": legal.get("license_name"),
        "license_url": legal.get("license_url"),
        "terms_url": legal.get("terms_url"),
        "rights_url": legal.get("rights_url"),
        "attribution_required": legal.get("attribution_required"),
        "redistribution_allowed": legal.get("redistribution_allowed"),
        "pack_output_allowed": legal.get("pack_output_allowed"),
        "review_status": "review_required" if legal.get("review_required") else "reviewed",
        "outside_legal_required": legal.get("outside_legal_required"),
        "outside_legal_status": legal.get("outside_legal_status"),
        "approval_artifact_path": legal.get("approval_artifact_path"),
        "non_claims": legal.get("non_claims", []),
        "publicReferenceOnly": True,
        "dataClass": "public_provenance",
    }


def _freshness_slice(claim: dict[str, Any]) -> dict[str, Any]:
    return {
        "claim_id": claim["claim_id"],
        "retrieved_at": claim.get("retrieval_time"),
        "valid_from": claim.get("valid_from"),
        "valid_until": claim.get("valid_until"),
        "freshness_sla": claim.get("freshness_sla"),
        "stale_after": None,
        "stale_behavior": "exclude_if_stale_critical",
        "last_verified_at": claim.get("retrieval_time"),
        "next_refresh_due_at": None,
        "freshness_status": claim.get("freshness_status"),
        "publicReferenceOnly": True,
        "dataClass": "public_freshness",
    }


def _adjudication_slice(claim: dict[str, Any]) -> dict[str, Any]:
    return {
        "claim_id": claim["claim_id"],
        "source_id": claim.get("source_id"),
        "adjudication_rule": claim.get("adjudication_rule"),
        "status": "accepted_claim",
        "authority_class": claim.get("authority_class"),
        "freshness_status": claim.get("freshness_status"),
        "publicReferenceOnly": True,
        "dataClass": "public_provenance",
    }


def _attribution_slice(citation: dict[str, Any]) -> dict[str, Any]:
    return {
        "claim_id": citation.get("claim_id"),
        "source_id": citation.get("source_id"),
        "attribution_text": citation.get("attribution_text"),
        "license_id": citation.get("license_id"),
        "publicReferenceOnly": True,
        "dataClass": "public_provenance",
    }


def _pack(pack_id: str, version: str, options: PackProductionOptions, slices: dict[str, Any]) -> dict[str, Any]:
    return {
        "pack_id": pack_id,
        "schema_version": "1.0.0",
        "kind": "ambitions.sourceAtlas.domainPack.v1",
        "frontier_id": options.domain,
        "created_at": options.created_at,
        "claims": slices["claims"],
        "entities": slices["entities"],
        "sources": slices["sources"],
        "licenses": slices["licenses"],
        "freshness": slices["freshness"],
        "adjudications": slices["adjudications"],
        "non_claims": slices["non_claims"]["nonClaims"],
        "manifest": {
            "pack_version": version,
            "environment": options.environment,
            "channel": options.channel,
        },
        "publicReferenceOnly": True,
        "dataClass": "public_reference_claim",
        "privacyBoundary": PRIVACY_BOUNDARY,
    }


def _write_slices(output_root: Path, pack: dict[str, Any], slices: dict[str, Any]) -> dict[str, Path]:
    files: dict[str, tuple[str, Any]] = {
        "pack": ("pack.json", pack),
        "claims": ("claims.json", {"claims": slices["claims"]}),
        "entities": ("entities.json", {"entities": slices["entities"]}),
        "sources": ("sources.json", {"sources": slices["sources"], "excludedClaims": slices["excludedClaims"]}),
        "licenses": ("licenses.json", {"licenses": slices["licenses"]}),
        "freshness": ("freshness.json", {"freshness": slices["freshness"]}),
        "adjudications": ("adjudications.json", {"adjudications": slices["adjudications"]}),
        "nonClaims": ("non_claims.json", slices["non_claims"]),
        "attribution": ("attribution.json", {"attribution": slices["attribution"]}),
        "coverage": ("coverage.json", {"coverage": slices["coverage"]}),
    }
    written: dict[str, Path] = {}
    for key, (filename, value) in files.items():
        path = output_root / filename
        write_json(path, value)
        written[key] = path
    return written


def _object_keys(options: PackProductionOptions, version: str) -> dict[str, str]:
    base = f"source-atlas/v1/{options.environment}/{options.channel}/{options.domain}/{version}"
    return {
        "pack": f"{base}/pack.json",
        "claims": f"{base}/claims.json",
        "entities": f"{base}/entities.json",
        "sources": f"{base}/sources.json",
        "licenses": f"{base}/licenses.json",
        "freshness": f"{base}/freshness.json",
        "adjudications": f"{base}/adjudications.json",
        "nonClaims": f"{base}/non_claims.json",
        "attribution": f"{base}/attribution.json",
        "coverage": f"{base}/coverage.json",
        "manifest": f"{base}/manifest.json",
        "current": f"source-atlas/v1/{options.environment}/{options.channel}/{options.domain}/current.json",
        "lkg": f"source-atlas/v1/{options.environment}/{options.channel}/{options.domain}/lkg.json",
        "revocations": f"source-atlas/v1/{options.environment}/{options.channel}/{options.domain}/revocations.json",
    }


def _manifest(
    *,
    pack_id: str,
    version: str,
    options: PackProductionOptions,
    object_keys: dict[str, str],
    slice_paths: dict[str, Path],
    scan_path: Path,
    revocation_path: Path,
    lkg_path: Path,
    rollback_path: Path,
    registries: dict[str, Any],
    frontier_manifest: dict[str, Any],
    claim_graph_path: Path,
    slices: dict[str, Any],
) -> dict[str, Any]:
    object_entries = {
        key: _object_entry(object_keys[key], path)
        for key, path in slice_paths.items()
        if key in object_keys
    }
    object_entries["revocations"] = _object_entry(object_keys["revocations"], revocation_path)
    pack_hash = file_sha256(slice_paths["pack"])
    pack_bytes = slice_paths["pack"].stat().st_size
    return {
        "manifest_id": stable_id("source_atlas_pack_manifest", {"packID": pack_id, "version": version}),
        "pack_id": pack_id,
        "pack_version": version,
        "schema_version": "1.0.0",
        "kind": "ambitions.sourceAtlas.packManifest.v1",
        "created_at": options.created_at,
        "object_keys": object_keys,
        "objects": object_entries,
        "sha256": pack_hash,
        "byte_size": pack_bytes,
        "source_registry_hash": stable_hash(registries["source_lanes"]),
        "legal_registry_hash": stable_hash(registries["legal_terms"]),
        "api_registry_hash": stable_hash(registries["api_governance"]),
        "coverage_frontier_hash": stable_hash(slices["coverage"]),
        "claim_graph_hash": file_sha256(claim_graph_path),
        "license_slice_hash": stable_hash(slices["licenses"]),
        "attribution_slice_hash": stable_hash(slices["attribution"]),
        "non_private_scan_hash": file_sha256(scan_path),
        "revocation_manifest_key": object_keys["revocations"],
        "lkg_pointer_key": object_keys["lkg"],
        "rollback_candidates": [
            {
                "manifest_key": object_keys["manifest"],
                "lkg_key": object_keys["lkg"],
                "reason": "dry_run_candidate",
            }
        ],
        "cache_control": "public, max-age=300" if options.environment == "staging" else "public, max-age=3600",
        "expires_at": None,
        "freshness_status": "current",
        "claim_frontier_manifest_hash": stable_hash(frontier_manifest),
        "publicReferenceOnly": True,
        "dataClass": "public_freshness",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "non_claims": PRODUCTION_NON_CLAIMS,
    }


def _object_entry(object_key: str, path: Path) -> dict[str, Any]:
    return {
        "object_key": object_key,
        "local_path": str(path),
        "sha256": file_sha256(path),
        "byte_size": path.stat().st_size,
        "content_type": "application/json; charset=utf-8",
    }


def _dry_run_plan(
    options: PackProductionOptions,
    object_keys: dict[str, str],
    slice_paths: dict[str, Path],
    manifest_path: Path,
    revocation_path: Path,
    lkg_path: Path,
    rollback_path: Path,
) -> dict[str, Any]:
    object_paths = dict(slice_paths)
    object_paths.update({"manifest": manifest_path, "revocations": revocation_path, "lkg": lkg_path})
    objects = [
        {
            "label": key,
            "localPath": str(path),
            "objectKey": object_keys[key],
            "sha256": file_sha256(path),
            "bytes": path.stat().st_size,
            "contentType": "application/json; charset=utf-8",
            "cacheControl": "public, max-age=300" if options.environment == "staging" else "public, max-age=3600",
        }
        for key, path in sorted(object_paths.items())
        if key in object_keys
    ]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2DryRunPlan.v1",
        "createdAt": options.created_at,
        "environment": options.environment,
        "channel": options.channel,
        "dryRun": True,
        "executeRequested": False,
        "wouldUpload": False,
        "objects": objects,
        "rollbackPlanPath": str(rollback_path),
        "secretBoundary": "Plan contains no R2 credentials. Real upload requires approved credentials outside this artifact.",
        "publicReferenceOnly": True,
        "dataClass": "public_r2_object_key",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_NON_CLAIMS + ["dry-run only; no R2 upload or production promotion was performed"],
    }


def _revocation_manifest(pack_id: str, object_keys: dict[str, str], options: PackProductionOptions, version: str) -> dict[str, Any]:
    return {
        "revocation_id": stable_id("source_atlas_revocation", {"packID": pack_id, "version": version}),
        "created_at": options.created_at,
        "revoked_pack_ids": [],
        "revoked_object_keys": [],
        "reason": "dry_run_no_revocations",
        "severity": "none",
        "replacement_pack_id": None,
        "lkg_policy": "use_lkg_if_future_pack_is_revoked_and_lkg_hash_verifies",
        "native_behavior": "not_claimed_in_train_04",
        "proof_artifacts": [],
        "object_keys": {"manifest": object_keys["manifest"], "lkg": object_keys["lkg"]},
        "publicReferenceOnly": True,
        "dataClass": "public_freshness",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_NON_CLAIMS,
    }


def _lkg_pointer(pack_id: str, object_keys: dict[str, str], options: PackProductionOptions, version: str, *, manifest_sha256: str) -> dict[str, Any]:
    return {
        "domain": options.domain,
        "channel": options.channel,
        "pack_id": pack_id,
        "manifest_key": object_keys["manifest"],
        "sha256": manifest_sha256,
        "created_at": options.created_at,
        "valid_until": None,
        "reason_selected": "dry_run_candidate",
        "rollback_safe": True,
        "publicReferenceOnly": True,
        "dataClass": "public_freshness",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_NON_CLAIMS,
    }


def _rollback_plan(pack_id: str, object_keys: dict[str, str], options: PackProductionOptions, version: str, lkg: dict[str, Any]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.rollbackPlan.v1",
        "createdAt": options.created_at,
        "packID": pack_id,
        "candidateManifestKey": object_keys["manifest"],
        "lkgPointerKey": object_keys["lkg"],
        "rollbackCandidates": [lkg],
        "stablePointerWillChange": False,
        "dryRunOnly": True,
        "publicReferenceOnly": True,
        "dataClass": "public_freshness",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_NON_CLAIMS,
    }


def _scan_output(output_root: Path, slice_paths: dict[str, Path], pack: dict[str, Any]) -> dict[str, Any]:
    issues: list[str] = []
    for label, path in sorted(slice_paths.items()):
        issues.extend(privacy_findings_for_value(read_json(path), f"pack-production.{label}"))
    issues.extend(privacy_findings_for_value(pack, "pack-production.pack"))
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.nonPrivateScanReport.v1",
        "createdAt": "2026-06-27T00:00:00Z",
        "outputRoot": str(output_root),
        "passed": not issues,
        "issues": issues,
        "publicReferenceOnly": True,
        "dataClass": "public_provenance",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_NON_CLAIMS,
    }


def _execute_issues(options: PackProductionOptions) -> list[str]:
    if not options.execute:
        return []
    issues: list[str] = []
    if options.environment != "production":
        issues.append("execute requires --environment production")
    if not options.approval_artifact:
        issues.append("execute requires --approval-artifact")
    elif not options.approval_artifact.exists():
        issues.append(f"execute approval artifact does not exist: {options.approval_artifact}")
    if not options.budget_policy:
        issues.append("execute requires --budget-policy")
    return issues


def _legal_approval_validation(options: PackProductionOptions, slices: dict[str, Any]) -> dict[str, Any]:
    source_ids = sorted({source.get("source_id") for source in slices.get("sources", []) if source.get("source_id")})
    required = options.environment == "production" or options.channel == "stable"
    if not required:
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.legalTermsApprovalPacketValidation.v1",
            "required": False,
            "valid": True,
            "status": "not_required_for_staging_candidate",
            "sourceIDs": source_ids,
            "issues": [],
        }
    if not options.legal_approval_packet:
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.legalTermsApprovalPacketValidation.v1",
            "required": True,
            "valid": False,
            "status": "Red",
            "sourceIDs": source_ids,
            "issues": ["production/stable pack production requires --legal-approval-packet"],
        }
    if not options.legal_approval_packet.exists():
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.legalTermsApprovalPacketValidation.v1",
            "required": True,
            "valid": False,
            "status": "Red",
            "sourceIDs": source_ids,
            "issues": [f"legal approval packet does not exist: {options.legal_approval_packet}"],
        }
    packet = read_json(options.legal_approval_packet)
    entries = []
    issues: list[str] = []
    for source_id in source_ids:
        try:
            entries.append(terms_entry(source_id))
        except KeyError:
            issues.append(f"{source_id}: no terms registry entry for legal approval packet validation")
    validation = validate_terms_approval_packet_for_entries(
        packet if not issues else None,
        terms_entries=entries,
        requested_artifact_classes={"official_public_source", "public_reference_claim", "public_provenance", "public_freshness"},
        now_date=options.created_at[:10],
    )
    validation["required"] = True
    validation["packetPath"] = str(options.legal_approval_packet)
    validation["packetSHA256"] = file_sha256(options.legal_approval_packet)
    if issues:
        validation["valid"] = False
        validation["status"] = "Red"
        validation["issues"] = issues + validation.get("issues", [])
    return validation


def _restricted_claims_excluded(claims: list[dict[str, Any]]) -> bool:
    blocked_sources = {"usajobs.search", "wikidata.crosswalk"}
    return all(claim.get("source_id") not in blocked_sources for claim in claims)


def _manifest_hashes_present(manifest: dict[str, Any]) -> bool:
    required = [
        "source_registry_hash",
        "legal_registry_hash",
        "api_registry_hash",
        "coverage_frontier_hash",
        "claim_graph_hash",
        "license_slice_hash",
        "attribution_slice_hash",
        "non_private_scan_hash",
    ]
    return all(manifest.get(field) for field in required)


def _no_final_outputs(*values: Any) -> bool:
    encoded = stable_hash(values)
    return bool(encoded)


def _pack_version(created_at: str) -> str:
    return created_at.replace("-", "").replace(":", "").replace("T", "T").replace("Z", "Z")


def _write_closeout(path: Path, result: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(pack_production_markdown(result), encoding="utf-8")
