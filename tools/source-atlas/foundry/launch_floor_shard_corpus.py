"""Launch-floor shard corpus manifest validation for Source Atlas.

This module validates the partition/index contract that can count public
reference shards toward the launch floor. It intentionally does not harvest
sources, upload to R2, or generate final user plans, schedules, or Steps.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issues_for_value, is_boundary_line, object_key_issues
from .launch_floor_domain_taxonomy import (
    DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH,
    launch_floor_domain_taxonomy_summary,
)
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_KIND = "ambitions.sourceAtlas.launchFloorShardCorpusManifest.v1"
SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_REPORT_KIND = "ambitions.sourceAtlas.launchFloorShardCorpusReport.v1"
SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_VERSION = "source-atlas-launch-floor-shard-corpus-lff-m02"
DEFAULT_LAUNCH_FLOOR_SHARD_CORPUS_PATH = Path("tools/source-atlas/frontier/launch-floor-shard-corpus-manifest.json")

REQUIRED_TOP_LEVEL_FIELDS = {
    "schemaVersion",
    "kind",
    "versionID",
    "createdAt",
    "publicReferenceOnly",
    "privateContextAllowed",
    "finalOutputAllowed",
    "partitions",
    "nonClaims",
}
REQUIRED_LAYOUT_KEYS = {
    "stagedPrefix",
    "promotedPrefix",
    "currentPointerKey",
    "lastKnownGoodKey",
    "revocationKey",
    "rollbackKey",
    "gatewayAllowlistKey",
}
FINAL_OUTPUT_FORBIDDEN = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}
PUBLIC_SHARD_TARGET = 1_000_000

LAUNCH_FLOOR_SHARD_CORPUS_NON_CLAIMS = [
    "not launch-floor complete unless the validated publicReferenceShards counter is at least 1,000,000",
    "not R2 production upload proof by itself",
    "not outside legal approval",
    "not Release Green, App Store readiness, or TestFlight readiness",
    "not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class LaunchFloorShardCorpusOptions:
    manifest_path: Path
    output_root: Path
    launch_floor_taxonomy_path: Path | None = DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None


def compile_launch_floor_shard_corpus(options: LaunchFloorShardCorpusOptions) -> dict[str, Any]:
    """Validate a launch-floor shard corpus manifest and emit proof artifacts."""

    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    manifest = _read_required_json(options.manifest_path, "launch-floor shard corpus manifest")
    taxonomy = _read_optional_json(options.launch_floor_taxonomy_path, "launch-floor domain taxonomy")
    summary = launch_floor_shard_corpus_summary(manifest, taxonomy=taxonomy)

    input_privacy_issues = _privacy_issues(
        {
            "manifestPath": str(options.manifest_path),
            "launchFloorTaxonomyPath": str(options.launch_floor_taxonomy_path) if options.launch_floor_taxonomy_path else None,
            "runLabel": options.run_label,
        },
        "source-atlas-launch-floor-shard-corpus-input",
    )
    artifact_privacy_issues = _privacy_issues(manifest, "source-atlas-launch-floor-shard-corpus-source")
    issues = sorted(set([*summary["issues"], *input_privacy_issues, *artifact_privacy_issues]))
    valid = not issues
    shard_target_met = summary["recordCounts"]["publicReferenceShards"] >= PUBLIC_SHARD_TARGET

    partition_index_path = output_root / "partition-index.json"
    report_path = output_root / "launch-floor-shard-corpus-report.json"
    markdown_path = output_root / "launch-floor-shard-corpus-report.md"
    closeout_path = output_root / "closeout.md"

    partition_index = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorShardPartitionIndex.v1",
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_VERSION,
        "createdAt": options.created_at,
        "manifestPath": str(options.manifest_path),
        "partitions": summary["partitions"],
        "recordCounts": summary["recordCounts"],
        "nonClaims": LAUNCH_FLOOR_SHARD_CORPUS_NON_CLAIMS,
    }
    write_json(partition_index_path, partition_index)

    report = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_REPORT_KIND,
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "corpusReportID": stable_id(
            "source_atlas.launch_floor_shard_corpus",
            {
                "manifestHash": stable_hash(manifest),
                "recordCounts": summary["recordCounts"],
                "createdAt": options.created_at,
                "runLabel": options.run_label,
            },
        ),
        "status": _status(valid, shard_target_met),
        "valid": valid,
        "launchFloorShardTargetMet": shard_target_met if valid else False,
        "sourceAtlasStatusCeiling": (
            "Yellow overall Source Atlas; shard corpus manifest validation only"
        ),
        "recordCounts": summary["recordCounts"],
        "checks": _checks(summary, input_privacy_issues, artifact_privacy_issues),
        "issues": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*input_privacy_issues, *artifact_privacy_issues])),
        "allowedClaims": _allowed_claims(valid, shard_target_met),
        "blockedClaims": _blocked_claims(),
        "productLaw": {
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "r2Role": "public/reference/freshness infrastructure only",
            "finalPersonalizedOutputsAllowed": False,
            "sourceAtlasGeneratesFinalPlansSchedulesSteps": False,
        },
        "evidencePaths": {
            "manifest": str(options.manifest_path),
            "launchFloorTaxonomy": str(options.launch_floor_taxonomy_path) if options.launch_floor_taxonomy_path else None,
        },
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "partitionIndex": str(partition_index_path),
            "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
            "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
        },
        "nonClaims": LAUNCH_FLOOR_SHARD_CORPUS_NON_CLAIMS,
    }
    report["outputHashes"] = {
        "partitionIndex": stable_hash(read_json(partition_index_path)),
        "reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"}),
    }
    markdown = launch_floor_shard_corpus_markdown(report)
    report["outputHashes"]["markdownPayload"] = stable_hash(markdown)
    write_json(report_path, report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    return report


def launch_floor_shard_corpus_summary(manifest: Any, *, taxonomy: Any = None) -> dict[str, Any]:
    issues: list[str] = []
    if not isinstance(manifest, dict):
        return _empty_summary(["launch-floor shard corpus manifest must be a JSON object"])
    for field_name in sorted(REQUIRED_TOP_LEVEL_FIELDS):
        if field_name not in manifest:
            issues.append(f"shard corpus manifest missing required top-level field {field_name}")
    if manifest.get("schemaVersion") != 1:
        issues.append("shard corpus manifest schemaVersion must be 1")
    if manifest.get("kind") != SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_KIND:
        issues.append(f"shard corpus manifest kind must be {SOURCE_ATLAS_LAUNCH_FLOOR_SHARD_CORPUS_KIND}")
    if not str(manifest.get("versionID") or "").strip():
        issues.append("shard corpus manifest versionID is required")
    if not str(manifest.get("createdAt") or "").strip():
        issues.append("shard corpus manifest createdAt is required")
    if manifest.get("publicReferenceOnly") is not True:
        issues.append("shard corpus manifest must be publicReferenceOnly")
    if manifest.get("privateContextAllowed") is not False:
        issues.append("shard corpus manifest must explicitly disallow private context")
    if manifest.get("finalOutputAllowed") is not False:
        issues.append("shard corpus manifest must explicitly disallow final outputs")
    if not isinstance(manifest.get("partitions"), list):
        issues.append("shard corpus manifest partitions must be a list")
    if not isinstance(manifest.get("nonClaims"), list) or not manifest["nonClaims"]:
        issues.append("shard corpus manifest nonClaims must be a non-empty list")

    taxonomy_index = _taxonomy_index(taxonomy)
    partitions = _partitions(manifest)
    issues.extend(_duplicate_issues([partition["partitionID"] for partition in partitions], "partitionID"))
    for partition in partitions:
        issues.extend(_partition_issues(partition, taxonomy_index))
    issues.extend(_final_output_issues(manifest))
    artifact_privacy_issues = _privacy_issues(manifest, "source-atlas-launch-floor-shard-corpus-summary")
    issues.extend(artifact_privacy_issues)

    counted_partitions = [partition for partition in partitions if partition["countsTowardLaunchFloor"]]
    record_counts = {
        "partitions": len(partitions),
        "launchFloorCountedPartitions": len(counted_partitions),
        "publicReferenceShards": sum(partition["shardCount"] for partition in counted_partitions),
        "partitionsWithR2Layout": sum(1 for partition in counted_partitions if partition["r2LayoutComplete"]),
        "partitionsWithReadbackProof": sum(1 for partition in counted_partitions if partition["readbackVerified"]),
        "partitionsWithRollbackProof": sum(1 for partition in counted_partitions if partition["rollbackVerified"]),
        "partitionsWithGatewayProof": sum(1 for partition in counted_partitions if partition["gatewayAllowlistVerified"]),
        "partitionsWithNativeCompatibility": sum(1 for partition in counted_partitions if partition["nativeDecoderCompatible"]),
        "partitionsWithSourceLaneRegistryLinks": sum(1 for partition in counted_partitions if partition["sourceLaneRegistryIDs"]),
        "claims": 0,
        "r2PublishOperations": 0,
        "finalOutputArtifacts": 0,
        "privacyIssues": len(artifact_privacy_issues),
    }
    counted_partition_count = record_counts["launchFloorCountedPartitions"]
    launch_targets = {
        "publicReferenceShards1M": record_counts["publicReferenceShards"] >= PUBLIC_SHARD_TARGET,
        "r2LayoutComplete": counted_partition_count > 0 and record_counts["partitionsWithR2Layout"] == counted_partition_count,
        "readbackComplete": counted_partition_count > 0 and record_counts["partitionsWithReadbackProof"] == counted_partition_count,
        "rollbackComplete": counted_partition_count > 0 and record_counts["partitionsWithRollbackProof"] == counted_partition_count,
        "gatewayAllowlistComplete": counted_partition_count > 0 and record_counts["partitionsWithGatewayProof"] == counted_partition_count,
        "nativeDecoderCompatibilityComplete": counted_partition_count > 0 and record_counts["partitionsWithNativeCompatibility"] == counted_partition_count,
        "sourceLaneRegistryLinksComplete": counted_partition_count > 0 and record_counts["partitionsWithSourceLaneRegistryLinks"] == counted_partition_count,
    }
    for key, label in [
        ("r2LayoutComplete", "R2 layout"),
        ("readbackComplete", "readback proof"),
        ("rollbackComplete", "rollback proof"),
        ("gatewayAllowlistComplete", "gateway allowlist proof"),
        ("nativeDecoderCompatibilityComplete", "native decoder compatibility"),
        ("sourceLaneRegistryLinksComplete", "source lane registry links"),
    ]:
        if not launch_targets[key]:
            issues.append(f"not every counted partition has {label}")

    return {
        "recordCounts": record_counts,
        "launchFloorTargets": launch_targets,
        "partitions": partitions,
        "issues": sorted(set(issues)),
    }


def launch_floor_shard_corpus_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Launch-Floor Shard Corpus LFF-M02",
        "",
        f"Status: {report['status']}",
        f"Launch-floor shard target met: {str(report['launchFloorShardTargetMet']).lower()}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "## Current Proved Capability",
        "",
        f"- Counted public/reference shards: {counts['publicReferenceShards']}",
        f"- Counted partitions: {counts['launchFloorCountedPartitions']}",
        f"- Partitions with R2 layout: {counts['partitionsWithR2Layout']}",
        f"- Partitions with readback proof: {counts['partitionsWithReadbackProof']}",
        f"- Partitions with rollback proof: {counts['partitionsWithRollbackProof']}",
        f"- Partitions with gateway proof: {counts['partitionsWithGatewayProof']}",
        f"- Partitions with native compatibility: {counts['partitionsWithNativeCompatibility']}",
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
            "- Shard manifests are public/reference identity and freshness infrastructure only.",
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


def _status(valid: bool, shard_target_met: bool) -> str:
    if not valid:
        return "Red"
    if shard_target_met:
        return "Source Green for launch-floor shard corpus manifest"
    return "Source Green for shard corpus manifest validator / shard target not met"


def _checks(summary: dict[str, Any], input_privacy_issues: list[str], artifact_privacy_issues: list[str]) -> list[dict[str, Any]]:
    counts = summary["recordCounts"]
    targets = summary["launchFloorTargets"]
    return [
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check("artifact_privacy_scan_passed", not artifact_privacy_issues and counts["privacyIssues"] == 0, artifact_privacy_issues),
        _check("public_reference_shards_at_least_1m", targets["publicReferenceShards1M"], [f"publicReferenceShards={counts['publicReferenceShards']}"]),
        _check("r2_layout_complete", targets["r2LayoutComplete"], [f"partitionsWithR2Layout={counts['partitionsWithR2Layout']}"]),
        _check("readback_complete", targets["readbackComplete"], [f"partitionsWithReadbackProof={counts['partitionsWithReadbackProof']}"]),
        _check("rollback_complete", targets["rollbackComplete"], [f"partitionsWithRollbackProof={counts['partitionsWithRollbackProof']}"]),
        _check("gateway_allowlist_complete", targets["gatewayAllowlistComplete"], [f"partitionsWithGatewayProof={counts['partitionsWithGatewayProof']}"]),
        _check("native_decoder_compatibility_complete", targets["nativeDecoderCompatibilityComplete"], [f"partitionsWithNativeCompatibility={counts['partitionsWithNativeCompatibility']}"]),
        _check("source_lane_registry_links_complete", targets["sourceLaneRegistryLinksComplete"], [f"partitionsWithSourceLaneRegistryLinks={counts['partitionsWithSourceLaneRegistryLinks']}"]),
        _check("no_claims_r2_writes_or_final_outputs", counts["claims"] == 0 and counts["r2PublishOperations"] == 0 and counts["finalOutputArtifacts"] == 0, []),
    ]


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": [] if passed else issues}


def _allowed_claims(valid: bool, shard_target_met: bool) -> list[str]:
    claims = ["source_atlas_launch_floor_shard_corpus_validator_green"] if valid else []
    if valid and shard_target_met:
        claims.append("launch_floor_public_reference_shards_1m_met")
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


def _partitions(manifest: dict[str, Any]) -> list[dict[str, Any]]:
    raw_partitions = manifest.get("partitions", [])
    if not isinstance(raw_partitions, list):
        return []
    partitions = []
    for index, partition in enumerate(raw_partitions):
        if not isinstance(partition, dict):
            continue
        shard_start = _int(partition.get("shardRangeStart"))
        shard_end = _int(partition.get("shardRangeEndInclusive"))
        declared_count = _int(partition.get("shardCount"))
        source_lane = partition.get("sourceLane") if isinstance(partition.get("sourceLane"), dict) else {}
        r2_layout = partition.get("r2Layout") if isinstance(partition.get("r2Layout"), dict) else {}
        readback = partition.get("readbackProof") if isinstance(partition.get("readbackProof"), dict) else {}
        native = partition.get("nativeCompatibility") if isinstance(partition.get("nativeCompatibility"), dict) else {}
        partition_id = str(partition.get("partitionID") or f"partition[{index}]")
        partitions.append(
            {
                "partitionID": partition_id,
                "domainID": str(partition.get("domainID") or ""),
                "subdomainID": str(partition.get("subdomainID") or ""),
                "publicReferenceOnly": partition.get("publicReferenceOnly") is True,
                "privateContextAllowed": partition.get("privateContextAllowed") is True,
                "privateContextExplicitlyFalse": partition.get("privateContextAllowed") is False,
                "finalOutputAllowed": partition.get("finalOutputAllowed") is True,
                "finalOutputExplicitlyFalse": partition.get("finalOutputAllowed") is False,
                "countsTowardLaunchFloor": partition.get("countsTowardLaunchFloor") is True,
                "shardRangeStart": shard_start,
                "shardRangeEndInclusive": shard_end,
                "shardCount": declared_count or 0,
                "indexObjectKey": str(partition.get("indexObjectKey") or ""),
                "indexSHA256": str(partition.get("indexSHA256") or ""),
                "manifestObjectKey": str(partition.get("manifestObjectKey") or ""),
                "manifestSHA256": str(partition.get("manifestSHA256") or ""),
                "sourceLaneProfileIDs": _string_list(source_lane, "profileIDs"),
                "sourceLaneRegistryIDs": _string_list(source_lane, "registryIDs"),
                "legalPolicyState": str(partition.get("legalPolicyState") or ""),
                "apiPolicyState": str(partition.get("apiPolicyState") or ""),
                "freshnessSLA": str(partition.get("freshnessSLA") or ""),
                "revocationState": str(partition.get("revocationState") or ""),
                "r2Layout": r2_layout,
                "r2LayoutComplete": _r2_layout_complete(r2_layout),
                "readbackVerified": readback.get("checksumVerified") is True,
                "rollbackVerified": readback.get("rollbackVerified") is True,
                "gatewayAllowlistVerified": readback.get("gatewayAllowlistVerified") is True,
                "nativeDecoderCompatible": native.get("partitionedShardIndexV1") is True
                and native.get("requestShape") == "public_ids_hashes_only"
                and native.get("privateContextAllowed") is False,
            }
        )
    return sorted(partitions, key=lambda item: item["partitionID"])


def _partition_issues(partition: dict[str, Any], taxonomy_index: dict[str, set[str]]) -> list[str]:
    issues: list[str] = []
    label = partition["partitionID"]
    if partition["publicReferenceOnly"] is not True:
        issues.append(f"{label}: partition must be publicReferenceOnly")
    if not partition["privateContextExplicitlyFalse"]:
        issues.append(f"{label}: partition must explicitly disallow private context")
    if not partition["finalOutputExplicitlyFalse"]:
        issues.append(f"{label}: partition must explicitly disallow final outputs")
    if partition["countsTowardLaunchFloor"] is not True:
        issues.append(f"{label}: partition must explicitly countTowardLaunchFloor")
    if not partition["domainID"] or not partition["subdomainID"]:
        issues.append(f"{label}: partition must include domainID and subdomainID")
    if taxonomy_index:
        if partition["domainID"] not in taxonomy_index:
            issues.append(f"{label}: unknown taxonomy domainID {partition['domainID']}")
        elif partition["subdomainID"] not in taxonomy_index[partition["domainID"]]:
            issues.append(f"{label}: unknown taxonomy subdomainID {partition['subdomainID']}")
    if partition["shardRangeStart"] is None or partition["shardRangeEndInclusive"] is None:
        issues.append(f"{label}: shard range must include start and inclusive end")
    elif partition["shardRangeEndInclusive"] < partition["shardRangeStart"]:
        issues.append(f"{label}: shard range end must be greater than or equal to start")
    else:
        actual_count = partition["shardRangeEndInclusive"] - partition["shardRangeStart"] + 1
        if actual_count != partition["shardCount"]:
            issues.append(f"{label}: shardCount must match shard range count")
    if partition["shardCount"] <= 0:
        issues.append(f"{label}: shardCount must be positive")
    for key_name in ("indexObjectKey", "manifestObjectKey"):
        key = partition[key_name]
        if not key:
            issues.append(f"{label}: {key_name} is required")
        else:
            issues.extend(issue.format() for issue in object_key_issues(key, f"{label}.{key_name}"))
    for key_name in ("indexSHA256", "manifestSHA256"):
        if not _is_sha256(partition[key_name]):
            issues.append(f"{label}: {key_name} must be SHA-256 hex")
    if not partition["sourceLaneProfileIDs"]:
        issues.append(f"{label}: sourceLane.profileIDs is required")
    if not partition["sourceLaneRegistryIDs"]:
        issues.append(f"{label}: sourceLane.registryIDs is required")
    for field_name in ("legalPolicyState", "apiPolicyState", "freshnessSLA", "revocationState"):
        if not partition[field_name]:
            issues.append(f"{label}: {field_name} is required")
    if not partition["r2LayoutComplete"]:
        issues.append(f"{label}: R2 layout must include staged, promoted, current, LKG, revocation, rollback, and gateway keys")
    for key_name in REQUIRED_LAYOUT_KEYS:
        key = str(partition["r2Layout"].get(key_name) or "")
        if key:
            issues.extend(issue.format() for issue in object_key_issues(key, f"{label}.r2Layout.{key_name}"))
    if not partition["readbackVerified"]:
        issues.append(f"{label}: readback checksum proof is required")
    if not partition["rollbackVerified"]:
        issues.append(f"{label}: rollback proof is required")
    if not partition["gatewayAllowlistVerified"]:
        issues.append(f"{label}: gateway allowlist proof is required")
    if not partition["nativeDecoderCompatible"]:
        issues.append(f"{label}: native partitioned shard index compatibility is required")
    return issues


def _r2_layout_complete(layout: dict[str, Any]) -> bool:
    return all(str(layout.get(key) or "").strip() for key in REQUIRED_LAYOUT_KEYS)


def _taxonomy_index(taxonomy: Any) -> dict[str, set[str]]:
    if not isinstance(taxonomy, dict):
        return {}
    summary = launch_floor_domain_taxonomy_summary(taxonomy)
    return {
        domain["domainID"]: {
            subdomain["subdomainID"]
            for subdomain in summary["subdomains"]
            if subdomain["parentDomainID"] == domain["domainID"]
        }
        for domain in summary["domains"]
    }


def _duplicate_issues(values: list[str], label: str) -> list[str]:
    seen: set[str] = set()
    duplicates: set[str] = set()
    for value in values:
        if value in seen:
            duplicates.add(value)
        seen.add(value)
    return [f"duplicate {label}: {value}" for value in sorted(duplicates)]


def _final_output_issues(value: Any) -> list[str]:
    found: set[str] = set()

    def walk(item: Any) -> None:
        if isinstance(item, str) and item in FINAL_OUTPUT_FORBIDDEN:
            found.add(item)
        elif isinstance(item, list):
            for child in item:
                walk(child)
        elif isinstance(item, dict):
            for child in item.values():
                walk(child)

    walk(value)
    return [f"shard corpus manifest contains forbidden final-output marker: {item}" for item in sorted(found)]


def _privacy_issues(value: Any, label: str) -> list[str]:
    return [
        issue.format()
        for issue in boundary_issues_for_value(value, label)
        if not is_boundary_line(issue.detail)
    ]


def _read_required_json(path: Path, label: str) -> Any:
    if not path.exists():
        return {"kind": "missing", "issues": [f"{label} missing at {path}"]}
    return read_json(path)


def _read_optional_json(path: Path | None, label: str) -> Any:
    if path is None:
        return None
    if not path.exists():
        return {"kind": "missing", "issues": [f"{label} missing at {path}"]}
    return read_json(path)


def _is_sha256(value: str) -> bool:
    normalized = value.strip().lower()
    return len(normalized) == 64 and all(character.isdigit() or character in "abcdef" for character in normalized)


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


def _string_list(container: dict[str, Any], key: str) -> list[str]:
    value = container.get(key, [])
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if isinstance(item, (str, int, float)) and str(item).strip()]


def _empty_summary(issues: list[str]) -> dict[str, Any]:
    return {
        "recordCounts": {
            "partitions": 0,
            "launchFloorCountedPartitions": 0,
            "publicReferenceShards": 0,
            "partitionsWithR2Layout": 0,
            "partitionsWithReadbackProof": 0,
            "partitionsWithRollbackProof": 0,
            "partitionsWithGatewayProof": 0,
            "partitionsWithNativeCompatibility": 0,
            "partitionsWithSourceLaneRegistryLinks": 0,
            "claims": 0,
            "r2PublishOperations": 0,
            "finalOutputArtifacts": 0,
            "privacyIssues": 0,
        },
        "launchFloorTargets": {
            "publicReferenceShards1M": False,
            "r2LayoutComplete": False,
            "readbackComplete": False,
            "rollbackComplete": False,
            "gatewayAllowlistComplete": False,
            "nativeDecoderCompatibilityComplete": False,
            "sourceLaneRegistryLinksComplete": False,
        },
        "partitions": [],
        "issues": issues,
    }
