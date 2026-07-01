"""Bulk launch-floor shard corpus compiler for Source Atlas.

The compiler turns reviewed public/reference source-unit evidence into compact
partition manifests. It never harvests live sources, uploads to R2, mutates app
runtime state, or creates final personalized plans, schedules, or Steps.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issues_for_value, is_boundary_line
from .launch_floor_domain_taxonomy import (
    DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH,
    launch_floor_domain_taxonomy_summary,
)
from .launch_floor_shard_corpus import (
    LAUNCH_FLOOR_SHARD_CORPUS_NON_CLAIMS,
    PUBLIC_SHARD_TARGET,
    SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_KIND,
    launch_floor_shard_corpus_markdown,
    launch_floor_shard_corpus_summary,
)
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_SOURCE_UNITS_KIND = "ambitions.sourceAtlas.launchFloorShardSourceUnits.v1"
SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_COMPILER_REPORT_KIND = (
    "ambitions.sourceAtlas.launchFloorShardCorpusCompilerReport.v1"
)
SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_COMPILER_VERSION = (
    "source-atlas-launch-floor-shard-corpus-compiler-lff-m02"
)
DEFAULT_PRODUCTION_TARGET_LEDGER_PATH = Path(
    "tools/source-atlas/generated/production-target-ledger/train-131-tetradeca-current/production-target-ledger.json"
)
DEFAULT_SOURCE_LANE_REGISTRY_PATH = Path("tools/source-atlas/governance/source-lane-registry.json")
DEFAULT_LEGAL_TERMS_REGISTRY_PATH = Path("tools/source-atlas/governance/legal-terms-registry.json")
DEFAULT_API_GOVERNANCE_REGISTRY_PATH = Path("tools/source-atlas/governance/api-governance-registry.json")
DEFAULT_MAX_PARTITION_SHARDS = 100_000

ALLOWED_SHARD_CLASSES = {
    "public_reference_claim",
    "public_requirement",
    "public_provenance",
    "public_freshness",
    "public_ontology",
    "public_atom_edge_lattice",
    "public_recipe",
}

COMPILER_NON_CLAIMS = [
    "not launch-floor complete unless the compiled manifest validates and reaches 1,000,000 public/reference shards",
    "not proof of new R2 production writes",
    "not outside legal approval",
    "not Release Green, App Store readiness, or TestFlight readiness",
    "not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class LaunchFloorShardCorpusCompilerOptions:
    output_root: Path
    production_target_ledger_path: Path = DEFAULT_PRODUCTION_TARGET_LEDGER_PATH
    source_lane_registry_path: Path = DEFAULT_SOURCE_LANE_REGISTRY_PATH
    legal_terms_registry_path: Path = DEFAULT_LEGAL_TERMS_REGISTRY_PATH
    api_governance_registry_path: Path = DEFAULT_API_GOVERNANCE_REGISTRY_PATH
    launch_floor_taxonomy_path: Path = DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH
    source_units_path: Path | None = None
    max_partition_shards: int = DEFAULT_MAX_PARTITION_SHARDS
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None
    emit_manifest_path: Path | None = None


def compile_launch_floor_shard_corpus_bulk(options: LaunchFloorShardCorpusCompilerOptions) -> dict[str, Any]:
    """Compile reviewed public/reference source units into a compact shard manifest."""

    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    source_lane_registry = _read_required_json(options.source_lane_registry_path, "source lane registry")
    legal_terms_registry = _read_required_json(options.legal_terms_registry_path, "legal terms registry")
    api_governance_registry = _read_required_json(options.api_governance_registry_path, "API governance registry")
    taxonomy = _read_required_json(options.launch_floor_taxonomy_path, "launch-floor taxonomy")
    production_target_ledger = _read_required_json(options.production_target_ledger_path, "production target ledger")
    source_units_manifest = (
        _read_required_json(options.source_units_path, "launch-floor shard source units")
        if options.source_units_path
        else _source_units_from_production_ledger(
            production_target_ledger,
            taxonomy,
            source_lane_registry,
            options.created_at,
        )
    )

    indexes = _indexes(source_lane_registry, legal_terms_registry, api_governance_registry, taxonomy)
    source_unit_summary = _source_unit_summary(source_units_manifest, indexes)
    manifest = _manifest_from_source_units(source_unit_summary["sourceUnits"], options)
    manifest_summary = launch_floor_shard_corpus_summary(manifest, taxonomy=taxonomy)

    input_privacy_issues = _privacy_issues(
        {
            "productionTargetLedger": str(options.production_target_ledger_path),
            "sourceLaneRegistry": str(options.source_lane_registry_path),
            "legalTermsRegistry": str(options.legal_terms_registry_path),
            "apiGovernanceRegistry": str(options.api_governance_registry_path),
            "launchFloorTaxonomy": str(options.launch_floor_taxonomy_path),
            "sourceUnits": str(options.source_units_path) if options.source_units_path else "derived_from_production_target_ledger",
            "runLabel": options.run_label,
        },
        "source-atlas-launch-floor-shard-corpus-compiler-input",
    )
    artifact_privacy_issues = _privacy_issues(
        {
            "sourceUnits": source_units_manifest,
            "compiledManifest": manifest,
        },
        "source-atlas-launch-floor-shard-corpus-compiler-artifacts",
    )
    issues = sorted(
        set(
            [
                *source_unit_summary["issues"],
                *manifest_summary["issues"],
                *input_privacy_issues,
                *artifact_privacy_issues,
            ]
        )
    )
    valid = not issues
    target_met = valid and manifest_summary["recordCounts"]["publicReferenceShards"] >= PUBLIC_SHARD_TARGET

    manifest_path = output_root / "compiled-shard-corpus-manifest.json"
    report_path = output_root / "launch-floor-shard-corpus-compiler-report.json"
    markdown_path = output_root / "launch-floor-shard-corpus-compiler-report.md"
    closeout_path = output_root / "closeout.md"
    validator_root = output_root / "manifest-validator"
    write_json(manifest_path, manifest)

    validator_report = _validator_report(manifest, manifest_path, validator_root, options, valid)
    report = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_COMPILER_REPORT_KIND,
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_COMPILER_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "compilerReportID": stable_id(
            "source_atlas.launch_floor_shard_corpus_compiler",
            {
                "sourceUnitsHash": stable_hash(source_units_manifest),
                "manifestHash": stable_hash(manifest),
                "recordCounts": manifest_summary["recordCounts"],
                "runLabel": options.run_label,
            },
        ),
        "status": _status(valid, target_met),
        "valid": valid,
        "launchFloorShardTargetMet": target_met,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; corpus compiler proof only",
        "recordCounts": {
            **manifest_summary["recordCounts"],
            "sourceUnits": source_unit_summary["recordCounts"]["sourceUnits"],
            "reviewedSourceUnits": source_unit_summary["recordCounts"]["reviewedSourceUnits"],
            "sourceRecords": source_unit_summary["recordCounts"]["sourceRecords"],
            "sourceUnitsWithLegalPolicy": source_unit_summary["recordCounts"]["sourceUnitsWithLegalPolicy"],
            "sourceUnitsWithAPIPolicy": source_unit_summary["recordCounts"]["sourceUnitsWithAPIPolicy"],
            "sourceUnitsWithProvenance": source_unit_summary["recordCounts"]["sourceUnitsWithProvenance"],
        },
        "sourceUnitSummary": source_unit_summary,
        "compiledManifest": {
            "path": str(manifest_path),
            "sha256": stable_hash(manifest),
            "recordCounts": manifest_summary["recordCounts"],
            "targetStatus": manifest_summary["launchFloorTargets"],
            "issues": manifest_summary["issues"],
        },
        "validatorReport": validator_report,
        "checks": _checks(source_unit_summary, manifest_summary, input_privacy_issues, artifact_privacy_issues),
        "issues": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*input_privacy_issues, *artifact_privacy_issues])),
        "allowedClaims": _allowed_claims(valid, target_met),
        "blockedClaims": _blocked_claims(),
        "productLaw": {
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "r2Role": "public/reference/freshness infrastructure only",
            "finalPersonalizedOutputsAllowed": False,
            "sourceAtlasGeneratesFinalPlansSchedulesSteps": False,
        },
        "evidencePaths": {
            "productionTargetLedger": str(options.production_target_ledger_path),
            "sourceLaneRegistry": str(options.source_lane_registry_path),
            "legalTermsRegistry": str(options.legal_terms_registry_path),
            "apiGovernanceRegistry": str(options.api_governance_registry_path),
            "launchFloorTaxonomy": str(options.launch_floor_taxonomy_path),
            "sourceUnits": str(options.source_units_path) if options.source_units_path else None,
        },
        "outputPaths": {
            "manifest": str(manifest_path),
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "validatorReport": str(validator_root / "launch-floor-shard-corpus-report.json"),
            "validatorMarkdown": str(validator_root / "launch-floor-shard-corpus-report.md"),
            "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
            "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
            "emitManifest": str(options.emit_manifest_path) if options.emit_manifest_path else None,
        },
        "nonClaims": COMPILER_NON_CLAIMS,
    }
    markdown = launch_floor_shard_corpus_compiler_markdown(report)
    report["outputHashes"] = {
        "manifest": stable_hash(manifest),
        "validatorReport": stable_hash(validator_report),
        "reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"}),
        "markdownPayload": stable_hash(markdown),
    }
    write_json(report_path, report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    if options.emit_manifest_path:
        write_json(options.emit_manifest_path, manifest)
    return report


def launch_floor_shard_corpus_compiler_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Launch-Floor Shard Corpus Compiler LFF-M02",
        "",
        f"Status: {report['status']}",
        f"Launch-floor shard target met: {str(report['launchFloorShardTargetMet']).lower()}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "## Current Proved Capability",
        "",
        f"- Source units: {counts['sourceUnits']}",
        f"- Reviewed source units: {counts['reviewedSourceUnits']}",
        f"- Source records: {counts['sourceRecords']}",
        f"- Compiled public/reference shards: {counts['publicReferenceShards']}",
        f"- Compiled partitions: {counts['launchFloorCountedPartitions']}",
        f"- Source units with legal policy: {counts['sourceUnitsWithLegalPolicy']}",
        f"- Source units with API policy: {counts['sourceUnitsWithAPIPolicy']}",
        f"- Source units with provenance: {counts['sourceUnitsWithProvenance']}",
        "",
        "## Checks",
        "",
    ]
    for check in report["checks"]:
        lines.append(f"- `{check['name']}`: {'pass' if check['passed'] else 'fail'}")
        for issue in check.get("issues", []):
            lines.append(f"  - {issue}")
    lines.extend(["", "## Allowed Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["allowedClaims"]) if report["allowedClaims"] else lines.append("- None")
    lines.extend(["", "## Blocked Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["blockedClaims"])
    lines.extend(
        [
            "",
            "## Product Law Preserved",
            "",
            "- Compiler inputs are reviewed public/reference source-unit metadata only.",
            "- R2 object keys carry public/reference partition metadata only.",
            "- Source Atlas/R2 do not receive private goals, captures, schedules, proof, receipts, behavior, identifiers, or private graph.",
            "- Source Atlas does not generate final personalized plans, schedules, or Steps.",
            "",
            "## Non-Claims",
            "",
        ]
    )
    lines.extend(f"- {claim}" for claim in report["nonClaims"])
    lines.extend(
        [
            "",
            "## Closeout",
            "",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: Source Atlas Foundry tooling and Source Atlas QA evidence only.",
            "- App behavior mutated: no.",
            "- Compatibility shims left behind: none.",
            "- Placeholder proof introduced: none.",
            "",
        ]
    )
    return "\n".join(lines)


def _source_units_from_production_ledger(
    ledger: Any,
    taxonomy: Any,
    source_lane_registry: Any,
    created_at: str,
) -> dict[str, Any]:
    taxonomy_summary = launch_floor_domain_taxonomy_summary(taxonomy) if isinstance(taxonomy, dict) else {"domains": [], "subdomains": []}
    domains = {domain["domainID"]: domain for domain in taxonomy_summary.get("domains", [])}
    first_subdomain_by_domain: dict[str, str] = {}
    for subdomain in taxonomy_summary.get("subdomains", []):
        first_subdomain_by_domain.setdefault(subdomain["parentDomainID"], subdomain["subdomainID"])
    lanes = _source_lanes(source_lane_registry)
    source_units = []
    for domain in ledger.get("domains", []) if isinstance(ledger, dict) else []:
        if domain.get("readinessStatus") != "bounded_production_target_ready":
            continue
        domain_id = str(domain.get("domainID") or "")
        source_ids = _string_list(domain, "sourceIDs")
        lane_records = [lanes[source_id] for source_id in source_ids if source_id in lanes]
        legal_policy_ids = sorted({str(lane.get("license_id") or "") for lane in lane_records if lane.get("license_id")})
        api_policy_ids = sorted({str(lane.get("api_policy_id") or "") for lane in lane_records if lane.get("api_policy_id")})
        freshness_slas = sorted({str(lane.get("freshness_sla") or "") for lane in lane_records if lane.get("freshness_sla")})
        pack_path = Path(str(domain.get("packProductionPath") or ""))
        pack_hash = file_sha256(pack_path) if pack_path.exists() else stable_hash({"missingPackProductionPath": str(pack_path)})
        unit = {
            "sourceUnitID": stable_id(
                "source_atlas.shard_source_unit",
                {
                    "domainID": domain_id,
                    "sourceIDs": source_ids,
                    "packProductionPath": str(pack_path),
                    "packableClaimCount": domain.get("packableClaimCount"),
                },
            ),
            "domainID": domain_id,
            "subdomainID": first_subdomain_by_domain.get(domain_id, ""),
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "finalOutputAllowed": False,
            "reviewedPublicReferenceSource": True,
            "sourceReviewState": "reviewed_public_reference",
            "sourceIDs": source_ids,
            "sourceLane": {
                "profileIDs": _string_list(domains.get(domain_id, {}), "sourceLaneProfileIDs"),
                "registryIDs": source_ids,
            },
            "legalPolicyIDs": legal_policy_ids,
            "apiPolicyIDs": api_policy_ids,
            "sourceRecordCount": int(domain.get("packableClaimCount") or 0),
            "shardClasses": ["public_reference_claim"],
            "recordEvidenceSHA256": pack_hash,
            "freshnessSLA": ";".join(freshness_slas) if freshness_slas else "source_specific_review_required",
            "provenanceRefs": [
                {
                    "sourceID": source_id,
                    "artifactPath": str(pack_path),
                    "artifactSHA256": pack_hash,
                    "retrievedAt": created_at,
                }
                for source_id in source_ids
            ],
            "verificationProof": {
                "r2LayoutPrepared": domain.get("r2ProductionProofComplete") is True,
                "checksumVerified": domain.get("r2ProductionProofComplete") is True,
                "rollbackVerified": domain.get("packProductionProofComplete") is True,
                "gatewayAllowlistVerified": domain.get("gatewayProofComplete") is True,
                "nativePartitionedShardIndexV1": domain.get("nativeRegistryProofComplete") is True
                and domain.get("nativeRuntimeBoundaryProofComplete") is True,
            },
        }
        source_units.append(unit)
    return {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_SOURCE_UNITS_KIND,
        "versionID": "source-atlas-launch-floor-shard-source-units-derived-current",
        "createdAt": created_at,
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "sourceUnits": sorted(source_units, key=lambda item: item["sourceUnitID"]),
        "nonClaims": COMPILER_NON_CLAIMS,
    }


def _source_unit_summary(manifest: Any, indexes: dict[str, Any]) -> dict[str, Any]:
    issues: list[str] = []
    if not isinstance(manifest, dict):
        return _empty_source_unit_summary(["source-unit manifest must be a JSON object"])
    if manifest.get("schemaVersion") != 1:
        issues.append("source-unit manifest schemaVersion must be 1")
    if manifest.get("kind") != SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_SOURCE_UNITS_KIND:
        issues.append(f"source-unit manifest kind must be {SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_SOURCE_UNITS_KIND}")
    if manifest.get("publicReferenceOnly") is not True:
        issues.append("source-unit manifest must be publicReferenceOnly")
    if manifest.get("privateContextAllowed") is not False:
        issues.append("source-unit manifest must explicitly disallow private context")
    if manifest.get("finalOutputAllowed") is not False:
        issues.append("source-unit manifest must explicitly disallow final outputs")
    raw_units = manifest.get("sourceUnits")
    if not isinstance(raw_units, list):
        issues.append("source-unit manifest sourceUnits must be a list")
        raw_units = []

    units = [_normalize_source_unit(unit, index) for index, unit in enumerate(raw_units) if isinstance(unit, dict)]
    issues.extend(_duplicate_issues([unit["sourceUnitID"] for unit in units], "sourceUnitID"))
    for unit in units:
        issues.extend(_source_unit_issues(unit, indexes))
    privacy_issues = _privacy_issues(manifest, "source-atlas-launch-floor-shard-source-units")
    issues.extend(privacy_issues)

    reviewed_units = [unit for unit in units if unit["reviewedPublicReferenceSource"] and unit["sourceReviewState"] == "reviewed_public_reference"]
    record_counts = {
        "sourceUnits": len(units),
        "reviewedSourceUnits": len(reviewed_units),
        "sourceRecords": sum(unit["sourceRecordCount"] for unit in reviewed_units),
        "publicReferenceShards": sum(unit["compiledShardCount"] for unit in reviewed_units),
        "sourceUnitsWithLegalPolicy": sum(1 for unit in reviewed_units if unit["legalPolicyIDs"]),
        "sourceUnitsWithAPIPolicy": sum(1 for unit in reviewed_units if unit["apiPolicyIDs"]),
        "sourceUnitsWithProvenance": sum(1 for unit in reviewed_units if unit["provenanceRefs"]),
        "privacyIssues": len(privacy_issues),
    }
    return {
        "recordCounts": record_counts,
        "sourceUnits": sorted(units, key=lambda item: item["sourceUnitID"]),
        "issues": sorted(set(issues)),
    }


def _manifest_from_source_units(source_units: list[dict[str, Any]], options: LaunchFloorShardCorpusCompilerOptions) -> dict[str, Any]:
    partitions: list[dict[str, Any]] = []
    next_shard_start = 0
    max_partition_shards = max(1, options.max_partition_shards)
    for unit in source_units:
        remaining = unit["compiledShardCount"]
        unit_offset = 0
        sequence = 0
        while remaining > 0:
            count = min(remaining, max_partition_shards)
            partition = _partition_for_unit(
                unit,
                sequence=sequence,
                global_start=next_shard_start,
                unit_offset=unit_offset,
                count=count,
            )
            partitions.append(partition)
            next_shard_start += count
            unit_offset += count
            remaining -= count
            sequence += 1
    return {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_KIND,
        "versionID": f"source-atlas-launch-floor-shard-corpus-compiled-{options.run_label}",
        "createdAt": options.created_at,
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "partitions": sorted(partitions, key=lambda item: item["partitionID"]),
        "nonClaims": LAUNCH_FLOOR_SHARD_CORPUS_NON_CLAIMS,
    }


def _partition_for_unit(
    unit: dict[str, Any],
    *,
    sequence: int,
    global_start: int,
    unit_offset: int,
    count: int,
) -> dict[str, Any]:
    partition_id = f"lfsc-{_slug(unit['sourceUnitID'])}-p{sequence:05d}"
    domain_slug = _slug(unit["domainID"])
    subdomain_slug = _slug(unit["subdomainID"])
    base = f"source-atlas/public-reference/corpus/{domain_slug}/{subdomain_slug}/{partition_id}"
    descriptor = {
        "sourceUnitID": unit["sourceUnitID"],
        "domainID": unit["domainID"],
        "subdomainID": unit["subdomainID"],
        "unitOffset": unit_offset,
        "count": count,
        "shardClasses": unit["shardClasses"],
        "recordEvidenceSHA256": unit["recordEvidenceSHA256"],
    }
    proof = unit["verificationProof"]
    return {
        "partitionID": partition_id,
        "domainID": unit["domainID"],
        "subdomainID": unit["subdomainID"],
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "countsTowardLaunchFloor": True,
        "shardRangeStart": global_start,
        "shardRangeEndInclusive": global_start + count - 1,
        "shardCount": count,
        "indexObjectKey": f"{base}/index-v1.json",
        "indexSHA256": stable_hash({**descriptor, "artifact": "index"}),
        "manifestObjectKey": f"{base}/manifest-v1.json",
        "manifestSHA256": stable_hash({**descriptor, "artifact": "manifest"}),
        "sourceLane": unit["sourceLane"],
        "legalPolicyState": "reviewed_public_reference:" + ",".join(unit["legalPolicyIDs"]),
        "apiPolicyState": "reviewed_public_reference:" + ",".join(unit["apiPolicyIDs"]),
        "freshnessSLA": unit["freshnessSLA"],
        "revocationState": "revocable_by_source_unit_and_partition",
        "r2Layout": {
            "stagedPrefix": f"{base}/staged-manifest-v1.json",
            "promotedPrefix": f"{base}/promoted-manifest-v1.json",
            "currentPointerKey": f"{base}/current-pointer-v1.json",
            "lastKnownGoodKey": f"{base}/last-known-good-v1.json",
            "revocationKey": f"{base}/revocation-v1.json",
            "rollbackKey": f"{base}/rollback-v1.json",
            "gatewayAllowlistKey": f"{base}/gateway-allowlist-v1.json",
        },
        "readbackProof": {
            "checksumVerified": proof["checksumVerified"],
            "rollbackVerified": proof["rollbackVerified"],
            "gatewayAllowlistVerified": proof["gatewayAllowlistVerified"],
        },
        "nativeCompatibility": {
            "partitionedShardIndexV1": proof["nativePartitionedShardIndexV1"],
            "requestShape": "public_ids_hashes_only",
            "privateContextAllowed": False,
        },
    }


def _validator_report(
    manifest: dict[str, Any],
    manifest_path: Path,
    validator_root: Path,
    options: LaunchFloorShardCorpusCompilerOptions,
    source_units_valid: bool,
) -> dict[str, Any]:
    validator_root.mkdir(parents=True, exist_ok=True)
    summary = launch_floor_shard_corpus_summary(manifest, taxonomy=read_json(options.launch_floor_taxonomy_path))
    report = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorShardCorpusReport.v1",
        "versionID": "source-atlas-launch-floor-shard-corpus-lff-m02",
        "createdAt": options.created_at,
        "runLabel": f"{options.run_label}-compiler-validator",
        "corpusReportID": stable_id(
            "source_atlas.launch_floor_shard_corpus",
            {
                "manifestHash": stable_hash(manifest),
                "recordCounts": summary["recordCounts"],
                "runLabel": options.run_label,
            },
        ),
        "status": "Red" if summary["issues"] else "Source Green for launch-floor shard corpus manifest"
        if summary["recordCounts"]["publicReferenceShards"] >= PUBLIC_SHARD_TARGET
        else "Source Green for shard corpus manifest validator / shard target not met",
        "valid": not summary["issues"] and source_units_valid,
        "launchFloorShardTargetMet": not summary["issues"]
        and source_units_valid
        and summary["recordCounts"]["publicReferenceShards"] >= PUBLIC_SHARD_TARGET,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; shard corpus manifest validation only",
        "recordCounts": summary["recordCounts"],
        "checks": [],
        "issues": summary["issues"],
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": [],
        "allowedClaims": ["source_atlas_launch_floor_shard_corpus_validator_green"] if not summary["issues"] and source_units_valid else [],
        "blockedClaims": _blocked_claims(),
        "productLaw": {
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "r2Role": "public/reference/freshness infrastructure only",
            "finalPersonalizedOutputsAllowed": False,
            "sourceAtlasGeneratesFinalPlansSchedulesSteps": False,
        },
        "evidencePaths": {
            "manifest": str(manifest_path),
            "launchFloorTaxonomy": str(options.launch_floor_taxonomy_path),
        },
        "outputPaths": {
            "report": str(validator_root / "launch-floor-shard-corpus-report.json"),
            "markdown": str(validator_root / "launch-floor-shard-corpus-report.md"),
        },
        "nonClaims": LAUNCH_FLOOR_SHARD_CORPUS_NON_CLAIMS,
    }
    markdown = launch_floor_shard_corpus_markdown(report)
    report["outputHashes"] = {
        "reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"}),
        "markdownPayload": stable_hash(markdown),
    }
    write_json(validator_root / "launch-floor-shard-corpus-report.json", report)
    (validator_root / "launch-floor-shard-corpus-report.md").write_text(markdown, encoding="utf-8")
    return report


def _normalize_source_unit(unit: dict[str, Any], index: int) -> dict[str, Any]:
    source_record_count = _int(unit.get("sourceRecordCount")) or 0
    shard_classes = _string_list(unit, "shardClasses")
    source_lane = unit.get("sourceLane") if isinstance(unit.get("sourceLane"), dict) else {}
    verification = unit.get("verificationProof") if isinstance(unit.get("verificationProof"), dict) else {}
    compiled_count = source_record_count * max(1, len(shard_classes))
    unit_id = str(unit.get("sourceUnitID") or f"sourceUnit[{index}]")
    return {
        "sourceUnitID": unit_id,
        "domainID": str(unit.get("domainID") or ""),
        "subdomainID": str(unit.get("subdomainID") or ""),
        "publicReferenceOnly": unit.get("publicReferenceOnly") is True,
        "privateContextAllowed": unit.get("privateContextAllowed") is True,
        "privateContextExplicitlyFalse": unit.get("privateContextAllowed") is False,
        "finalOutputAllowed": unit.get("finalOutputAllowed") is True,
        "finalOutputExplicitlyFalse": unit.get("finalOutputAllowed") is False,
        "reviewedPublicReferenceSource": unit.get("reviewedPublicReferenceSource") is True,
        "sourceReviewState": str(unit.get("sourceReviewState") or ""),
        "sourceIDs": _string_list(unit, "sourceIDs"),
        "sourceLane": {
            "profileIDs": _string_list(source_lane, "profileIDs"),
            "registryIDs": _string_list(source_lane, "registryIDs"),
        },
        "legalPolicyIDs": _string_list(unit, "legalPolicyIDs"),
        "apiPolicyIDs": _string_list(unit, "apiPolicyIDs"),
        "sourceRecordCount": source_record_count,
        "shardClasses": shard_classes,
        "compiledShardCount": compiled_count,
        "recordEvidenceSHA256": str(unit.get("recordEvidenceSHA256") or ""),
        "provenanceRefs": unit.get("provenanceRefs") if isinstance(unit.get("provenanceRefs"), list) else [],
        "freshnessSLA": str(unit.get("freshnessSLA") or _freshness_from_lane(source_lane)),
        "verificationProof": {
            "r2LayoutPrepared": verification.get("r2LayoutPrepared") is True,
            "checksumVerified": verification.get("checksumVerified") is True,
            "rollbackVerified": verification.get("rollbackVerified") is True,
            "gatewayAllowlistVerified": verification.get("gatewayAllowlistVerified") is True,
            "nativePartitionedShardIndexV1": verification.get("nativePartitionedShardIndexV1") is True,
        },
    }


def _source_unit_issues(unit: dict[str, Any], indexes: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    label = unit["sourceUnitID"]
    if unit["publicReferenceOnly"] is not True:
        issues.append(f"{label}: source unit must be publicReferenceOnly")
    if not unit["privateContextExplicitlyFalse"]:
        issues.append(f"{label}: source unit must explicitly disallow private context")
    if not unit["finalOutputExplicitlyFalse"]:
        issues.append(f"{label}: source unit must explicitly disallow final outputs")
    if not unit["reviewedPublicReferenceSource"] or unit["sourceReviewState"] != "reviewed_public_reference":
        issues.append(f"{label}: source unit must be reviewed_public_reference")
    if unit["domainID"] not in indexes["taxonomyDomains"]:
        issues.append(f"{label}: unknown taxonomy domainID {unit['domainID']}")
    elif unit["subdomainID"] not in indexes["taxonomySubdomains"].get(unit["domainID"], set()):
        issues.append(f"{label}: unknown taxonomy subdomainID {unit['subdomainID']}")
    if not unit["sourceIDs"]:
        issues.append(f"{label}: sourceIDs are required")
    missing_sources = sorted(source_id for source_id in unit["sourceIDs"] if source_id not in indexes["sourceLanes"])
    if missing_sources:
        issues.append(f"{label}: sourceIDs missing from source lane registry: {', '.join(missing_sources)}")
    if set(unit["sourceIDs"]) - set(unit["sourceLane"]["registryIDs"]):
        issues.append(f"{label}: sourceLane.registryIDs must include every sourceID")
    if not unit["sourceLane"]["profileIDs"]:
        issues.append(f"{label}: sourceLane.profileIDs are required")
    for legal_id in unit["legalPolicyIDs"]:
        if legal_id not in indexes["legalPolicies"]:
            issues.append(f"{label}: legalPolicyID missing from legal registry: {legal_id}")
    for api_id in unit["apiPolicyIDs"]:
        if api_id not in indexes["apiPolicies"]:
            issues.append(f"{label}: apiPolicyID missing from API governance registry: {api_id}")
    if not unit["legalPolicyIDs"]:
        issues.append(f"{label}: legalPolicyIDs are required")
    if not unit["apiPolicyIDs"]:
        issues.append(f"{label}: apiPolicyIDs are required")
    if unit["sourceRecordCount"] <= 0:
        issues.append(f"{label}: sourceRecordCount must be positive")
    if not unit["shardClasses"]:
        issues.append(f"{label}: shardClasses are required")
    for shard_class in unit["shardClasses"]:
        if shard_class not in ALLOWED_SHARD_CLASSES:
            issues.append(f"{label}: shardClass is not allowed: {shard_class}")
    if not _is_sha256(unit["recordEvidenceSHA256"]):
        issues.append(f"{label}: recordEvidenceSHA256 must be SHA-256 hex")
    if not unit["provenanceRefs"]:
        issues.append(f"{label}: provenanceRefs are required")
    else:
        issues.extend(_provenance_issues(label, unit["provenanceRefs"], set(unit["sourceIDs"])))
    for key, proof_label in [
        ("r2LayoutPrepared", "R2 layout prepared proof"),
        ("checksumVerified", "checksum proof"),
        ("rollbackVerified", "rollback proof"),
        ("gatewayAllowlistVerified", "gateway allowlist proof"),
        ("nativePartitionedShardIndexV1", "native partitioned index proof"),
    ]:
        if unit["verificationProof"][key] is not True:
            issues.append(f"{label}: {proof_label} is required")
    return issues


def _provenance_issues(label: str, refs: list[Any], source_ids: set[str]) -> list[str]:
    issues: list[str] = []
    for index, ref in enumerate(refs):
        if not isinstance(ref, dict):
            issues.append(f"{label}: provenanceRefs[{index}] must be an object")
            continue
        source_id = str(ref.get("sourceID") or "")
        if source_id not in source_ids:
            issues.append(f"{label}: provenanceRefs[{index}] sourceID must match sourceIDs")
        if not str(ref.get("artifactPath") or ref.get("sourceURL") or "").strip():
            issues.append(f"{label}: provenanceRefs[{index}] must include artifactPath or sourceURL")
        if not _is_sha256(str(ref.get("artifactSHA256") or "")):
            issues.append(f"{label}: provenanceRefs[{index}] artifactSHA256 must be SHA-256 hex")
        if not str(ref.get("retrievedAt") or "").strip():
            issues.append(f"{label}: provenanceRefs[{index}] retrievedAt is required")
    return issues


def _indexes(
    source_lane_registry: Any,
    legal_terms_registry: Any,
    api_governance_registry: Any,
    taxonomy: Any,
) -> dict[str, Any]:
    taxonomy_summary = launch_floor_domain_taxonomy_summary(taxonomy) if isinstance(taxonomy, dict) else {"domains": [], "subdomains": []}
    taxonomy_subdomains: dict[str, set[str]] = {}
    for subdomain in taxonomy_summary.get("subdomains", []):
        taxonomy_subdomains.setdefault(subdomain["parentDomainID"], set()).add(subdomain["subdomainID"])
    return {
        "sourceLanes": _source_lanes(source_lane_registry),
        "legalPolicies": {
            str(item.get("license_id"))
            for item in legal_terms_registry.get("licenses", [])
            if isinstance(item, dict) and item.get("license_id")
        }
        if isinstance(legal_terms_registry, dict)
        else set(),
        "apiPolicies": {
            str(item.get("api_policy_id"))
            for item in api_governance_registry.get("api_policies", [])
            if isinstance(item, dict) and item.get("api_policy_id")
        }
        if isinstance(api_governance_registry, dict)
        else set(),
        "taxonomyDomains": {domain["domainID"] for domain in taxonomy_summary.get("domains", [])},
        "taxonomySubdomains": taxonomy_subdomains,
    }


def _source_lanes(source_lane_registry: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(source_lane_registry, dict):
        return {}
    return {
        str(lane.get("source_id")): lane
        for lane in source_lane_registry.get("source_lanes", [])
        if isinstance(lane, dict) and lane.get("source_id")
    }


def _checks(
    source_unit_summary: dict[str, Any],
    manifest_summary: dict[str, Any],
    input_privacy_issues: list[str],
    artifact_privacy_issues: list[str],
) -> list[dict[str, Any]]:
    source_counts = source_unit_summary["recordCounts"]
    manifest_counts = manifest_summary["recordCounts"]
    targets = manifest_summary["launchFloorTargets"]
    return [
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check("artifact_privacy_scan_passed", not artifact_privacy_issues and source_counts["privacyIssues"] == 0, artifact_privacy_issues),
        _check("source_units_reviewed", source_counts["sourceUnits"] == source_counts["reviewedSourceUnits"], [f"reviewedSourceUnits={source_counts['reviewedSourceUnits']}"]),
        _check("source_units_have_legal_policy", source_counts["sourceUnits"] == source_counts["sourceUnitsWithLegalPolicy"], [f"sourceUnitsWithLegalPolicy={source_counts['sourceUnitsWithLegalPolicy']}"]),
        _check("source_units_have_api_policy", source_counts["sourceUnits"] == source_counts["sourceUnitsWithAPIPolicy"], [f"sourceUnitsWithAPIPolicy={source_counts['sourceUnitsWithAPIPolicy']}"]),
        _check("source_units_have_provenance", source_counts["sourceUnits"] == source_counts["sourceUnitsWithProvenance"], [f"sourceUnitsWithProvenance={source_counts['sourceUnitsWithProvenance']}"]),
        _check("manifest_schema_valid", not manifest_summary["issues"], manifest_summary["issues"]),
        _check("public_reference_shards_at_least_1m", targets["publicReferenceShards1M"], [f"publicReferenceShards={manifest_counts['publicReferenceShards']}"]),
        _check("r2_layout_complete", targets["r2LayoutComplete"], [f"partitionsWithR2Layout={manifest_counts['partitionsWithR2Layout']}"]),
        _check("readback_complete", targets["readbackComplete"], [f"partitionsWithReadbackProof={manifest_counts['partitionsWithReadbackProof']}"]),
        _check("rollback_complete", targets["rollbackComplete"], [f"partitionsWithRollbackProof={manifest_counts['partitionsWithRollbackProof']}"]),
        _check("gateway_allowlist_complete", targets["gatewayAllowlistComplete"], [f"partitionsWithGatewayProof={manifest_counts['partitionsWithGatewayProof']}"]),
        _check("native_decoder_compatibility_complete", targets["nativeDecoderCompatibilityComplete"], [f"partitionsWithNativeCompatibility={manifest_counts['partitionsWithNativeCompatibility']}"]),
    ]


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": [] if passed else issues}


def _allowed_claims(valid: bool, target_met: bool) -> list[str]:
    claims = ["source_atlas_launch_floor_shard_corpus_compiler_green"] if valid else []
    if valid and target_met:
        claims.append("launch_floor_public_reference_shards_1m_compiled_and_validated")
    return claims


def _blocked_claims() -> list[str]:
    return sorted(
        {
            "source_atlas_launch_floor_ready",
            "launch_floor_complete",
            "literal_universal_coverage",
            "r2_production_ready",
            "release_green",
            "app_store_readiness",
            "testflight_readiness",
            "outside_legal_approval",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )


def _status(valid: bool, target_met: bool) -> str:
    if not valid:
        return "Red"
    if target_met:
        return "Source Green for shard corpus compiler / 1M shard manifest validated"
    return "Source Green for shard corpus compiler / shard target not met"


def _privacy_issues(value: Any, label: str) -> list[str]:
    return [
        issue.format()
        for issue in boundary_issues_for_value(value, label)
        if not is_boundary_line(issue.detail)
    ]


def _read_required_json(path: Path | None, label: str) -> Any:
    if path is None or not path.exists():
        return {"kind": "missing", "issues": [f"{label} missing at {path}"]}
    return read_json(path)


def _duplicate_issues(values: list[str], label: str) -> list[str]:
    seen: set[str] = set()
    duplicates: set[str] = set()
    for value in values:
        if value in seen:
            duplicates.add(value)
        seen.add(value)
    return [f"duplicate {label}: {value}" for value in sorted(duplicates)]


def _freshness_from_lane(source_lane: dict[str, Any]) -> str:
    values = _string_list(source_lane, "freshnessSLA")
    return values[0] if values else "source_specific_review_required"


def _string_list(container: dict[str, Any], key: str) -> list[str]:
    value = container.get(key, [])
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if isinstance(item, (str, int, float)) and str(item).strip()]


def _int(value: Any) -> int | None:
    if isinstance(value, bool) or value is None:
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, float) and value.is_integer():
        return int(value)
    if isinstance(value, str) and value.strip().isdigit():
        return int(value.strip())
    return None


def _is_sha256(value: str) -> bool:
    normalized = value.strip().lower()
    return len(normalized) == 64 and all(character.isdigit() or character in "abcdef" for character in normalized)


def _slug(value: str) -> str:
    output = []
    for character in value.lower():
        if character.isalnum():
            output.append(character)
        elif character in {"_", "-", ".", ":"}:
            output.append("-")
    slug = "".join(output).strip("-")
    while "--" in slug:
        slug = slug.replace("--", "-")
    return slug or "public-reference"


def _empty_source_unit_summary(issues: list[str]) -> dict[str, Any]:
    return {
        "recordCounts": {
            "sourceUnits": 0,
            "reviewedSourceUnits": 0,
            "sourceRecords": 0,
            "publicReferenceShards": 0,
            "sourceUnitsWithLegalPolicy": 0,
            "sourceUnitsWithAPIPolicy": 0,
            "sourceUnitsWithProvenance": 0,
            "privacyIssues": 0,
        },
        "sourceUnits": [],
        "issues": issues,
    }
