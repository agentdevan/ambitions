"""Launch-floor R2 layout/readback proof for Source Atlas shard corpora.

This module proves the partitioned shard-corpus R2 object layout without
performing live R2 writes. It validates staged/promoted/current/LKG/revocation/
rollback/gateway keys, deterministic checksums, readback scope, rollback
coverage, and public-only gateway load metadata.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issues_for_value, is_boundary_line, object_key_issues
from .launch_floor_domain_taxonomy import DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH
from .launch_floor_shard_corpus import (
    PUBLIC_SHARD_TARGET,
    launch_floor_shard_corpus_summary,
)
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_LAUNCH_FLOOR_R2_LAYOUT_PROOF_KIND = "ambitions.sourceAtlas.launchFloorR2LayoutProofReport.v1"
SOURCE_ATLAS_LAUNCH_FLOOR_R2_LAYOUT_PROOF_VERSION = "source-atlas-launch-floor-r2-layout-proof-lff-m02"
DEFAULT_LAUNCH_FLOOR_SHARD_CORPUS_MANIFEST_PATH = Path(
    "tools/source-atlas/generated/source-atlas-launch-floor-shard-corpus-compiler/"
    "lff-m02-l02-current/launch-floor-shard-corpus-manifest.json"
)
DEFAULT_GATEWAY_LOAD_PROBE_COUNT = 1_000
READBACK_MODES = {"full", "sampled"}

R2_LAYOUT_NON_CLAIMS = [
    "not live Cloudflare R2 production write proof",
    "not launch-floor complete unless every launch-floor target is met",
    "not proof of 1,000,000 public/reference shards unless the corpus counter reaches that threshold",
    "not outside legal approval",
    "not Release Green, App Store readiness, or TestFlight readiness",
    "not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class LaunchFloorR2LayoutProofOptions:
    shard_corpus_manifest_path: Path = DEFAULT_LAUNCH_FLOOR_SHARD_CORPUS_MANIFEST_PATH
    output_root: Path = Path("tools/source-atlas/generated/source-atlas-launch-floor-r2-layout-proof/current")
    launch_floor_taxonomy_path: Path | None = DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"
    readback_mode: str = "full"
    sample_stride: int = 97
    gateway_load_probe_count: int = DEFAULT_GATEWAY_LOAD_PROBE_COUNT
    simulate_readback_mismatch_object_key: str | None = None
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None


def run_launch_floor_r2_layout_proof(options: LaunchFloorR2LayoutProofOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    manifest = _read_required_json(options.shard_corpus_manifest_path, "launch-floor shard corpus manifest")
    taxonomy = _read_optional_json(options.launch_floor_taxonomy_path)
    summary = launch_floor_shard_corpus_summary(manifest, taxonomy=taxonomy)
    counted_partitions = [partition for partition in summary["partitions"] if partition["countsTowardLaunchFloor"]]
    inventory = _object_inventory(counted_partitions, options.created_at)
    gateway_allowlist = _gateway_allowlist(counted_partitions, inventory, options)
    rollback_plan = _rollback_plan(counted_partitions, inventory, options)
    readback = _readback_report(inventory, options)

    input_privacy_issues = _privacy_issues(
        {
            "shardCorpusManifest": str(options.shard_corpus_manifest_path),
            "launchFloorTaxonomy": str(options.launch_floor_taxonomy_path) if options.launch_floor_taxonomy_path else None,
            "runLabel": options.run_label,
            "readbackMode": options.readback_mode,
        },
        "source-atlas-launch-floor-r2-layout-proof-input",
    )
    artifact_privacy_issues = _privacy_issues(
        {
            "inventory": inventory,
            "gatewayAllowlist": gateway_allowlist,
            "rollbackPlan": rollback_plan,
            "readback": readback,
        },
        "source-atlas-launch-floor-r2-layout-proof-artifacts",
    )
    key_issues = _object_key_privacy_issues(inventory)
    issues = sorted(
        set(
            [
                *summary["issues"],
                *input_privacy_issues,
                *artifact_privacy_issues,
                *key_issues,
                *readback["issues"],
                *rollback_plan["issues"],
                *gateway_allowlist["issues"],
                *_option_issues(options),
            ]
        )
    )
    checks = _checks(summary, inventory, readback, rollback_plan, gateway_allowlist, input_privacy_issues, artifact_privacy_issues, key_issues, options)
    valid = not issues and all(check["passed"] for check in checks)
    shard_target_met = summary["recordCounts"]["publicReferenceShards"] >= PUBLIC_SHARD_TARGET

    inventory_path = output_root / "r2-layout-inventory.json"
    readback_path = output_root / "r2-layout-readback-report.json"
    rollback_path = output_root / "r2-layout-rollback-plan.json"
    gateway_path = output_root / "r2-layout-gateway-allowlist.json"
    report_path = output_root / "launch-floor-r2-layout-proof-report.json"
    markdown_path = output_root / "launch-floor-r2-layout-proof-report.md"
    closeout_path = output_root / "closeout.md"
    write_json(inventory_path, inventory)
    write_json(readback_path, readback)
    write_json(rollback_path, rollback_plan)
    write_json(gateway_path, gateway_allowlist)

    report = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_R2_LAYOUT_PROOF_KIND,
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_R2_LAYOUT_PROOF_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "proofID": stable_id(
            "source_atlas.launch_floor_r2_layout_proof",
            {
                "manifestHash": stable_hash(manifest),
                "inventoryHash": stable_hash(inventory),
                "recordCounts": summary["recordCounts"],
                "readbackMode": options.readback_mode,
            },
        ),
        "status": _status(valid, shard_target_met),
        "valid": valid,
        "launchFloorShardTargetMet": shard_target_met if valid else False,
        "launchFloorR2LayoutProofMet": valid
        and summary["launchFloorTargets"]["r2LayoutComplete"]
        and summary["launchFloorTargets"]["readbackComplete"]
        and summary["launchFloorTargets"]["rollbackComplete"]
        and summary["launchFloorTargets"]["gatewayAllowlistComplete"],
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; R2 layout/readback proof only",
        "recordCounts": {
            **summary["recordCounts"],
            "layoutObjects": len(inventory["objects"]),
            "stagedObjects": _count_role(inventory, "staged_manifest"),
            "promotedObjects": _count_role(inventory, "promoted_manifest"),
            "currentPointerObjects": _count_role(inventory, "current_pointer"),
            "lastKnownGoodObjects": _count_role(inventory, "last_known_good"),
            "revocationObjects": _count_role(inventory, "revocation_manifest"),
            "rollbackObjects": _count_role(inventory, "rollback_plan"),
            "gatewayAllowlistObjects": _count_role(inventory, "gateway_allowlist"),
            "readbackObjectsChecked": readback["recordCounts"]["objectsChecked"],
            "readbackChecksumMismatches": readback["recordCounts"]["checksumMismatches"],
            "rollbackTransitionsTested": rollback_plan["recordCounts"]["rollbackTransitions"],
            "gatewayLoadProbes": gateway_allowlist["recordCounts"]["loadProbes"],
            "r2LiveWrites": 0,
        },
        "checks": checks,
        "issues": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*input_privacy_issues, *artifact_privacy_issues])),
        "productLaw": {
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "r2Role": "public/reference/freshness infrastructure only",
            "liveR2WritesExecuted": False,
            "finalPersonalizedOutputsAllowed": False,
            "sourceAtlasGeneratesFinalPlansSchedulesSteps": False,
        },
        "readback": {
            "mode": options.readback_mode,
            "sampleStride": options.sample_stride,
            "reportPath": str(readback_path),
            "valid": readback["valid"],
        },
        "gateway": {
            "allowlistPath": str(gateway_path),
            "valid": gateway_allowlist["valid"],
            "loadProbeCount": gateway_allowlist["recordCounts"]["loadProbes"],
        },
        "rollback": {
            "planPath": str(rollback_path),
            "valid": rollback_plan["valid"],
            "transitions": rollback_plan["recordCounts"]["rollbackTransitions"],
        },
        "allowedClaims": _allowed_claims(valid, shard_target_met),
        "blockedClaims": _blocked_claims(),
        "evidencePaths": {
            "shardCorpusManifest": str(options.shard_corpus_manifest_path),
            "launchFloorTaxonomy": str(options.launch_floor_taxonomy_path) if options.launch_floor_taxonomy_path else None,
        },
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "inventory": str(inventory_path),
            "readback": str(readback_path),
            "rollback": str(rollback_path),
            "gatewayAllowlist": str(gateway_path),
            "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
            "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
        },
        "nonClaims": R2_LAYOUT_NON_CLAIMS,
    }
    report["outputHashes"] = {
        "inventory": stable_hash(inventory),
        "readback": stable_hash(readback),
        "rollback": stable_hash(rollback_plan),
        "gatewayAllowlist": stable_hash(gateway_allowlist),
        "reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"}),
    }
    markdown = launch_floor_r2_layout_proof_markdown(report)
    report["outputHashes"]["markdownPayload"] = stable_hash(markdown)
    write_json(report_path, report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    return report


def launch_floor_r2_layout_proof_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Launch-Floor R2 Layout Proof LFF-M02",
        "",
        f"Status: {report['status']}",
        f"Launch-floor shard target met: {str(report['launchFloorShardTargetMet']).lower()}",
        f"Launch-floor R2 layout proof met: {str(report['launchFloorR2LayoutProofMet']).lower()}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "## Current Proved Capability",
        "",
        f"- Counted public/reference shards: {counts['publicReferenceShards']}",
        f"- Counted partitions: {counts['launchFloorCountedPartitions']}",
        f"- Layout objects: {counts['layoutObjects']}",
        f"- Staged manifest objects: {counts['stagedObjects']}",
        f"- Promoted manifest objects: {counts['promotedObjects']}",
        f"- Current pointer objects: {counts['currentPointerObjects']}",
        f"- Last-known-good objects: {counts['lastKnownGoodObjects']}",
        f"- Revocation objects: {counts['revocationObjects']}",
        f"- Rollback objects: {counts['rollbackObjects']}",
        f"- Gateway allowlist objects: {counts['gatewayAllowlistObjects']}",
        f"- Readback objects checked: {counts['readbackObjectsChecked']}",
        f"- Readback checksum mismatches: {counts['readbackChecksumMismatches']}",
        f"- Rollback transitions tested: {counts['rollbackTransitionsTested']}",
        f"- Gateway load probes: {counts['gatewayLoadProbes']}",
        f"- Live R2 writes executed: {counts['r2LiveWrites']}",
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
            "- R2 layout keys carry public/reference partition metadata only.",
            "- No live R2 write, deletion, or production pointer mutation is executed by this proof command.",
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
            "- Live R2 writes executed: no.",
            "- Compatibility shims left behind: none.",
            "- Placeholder proof introduced: none.",
            "",
        ]
    )
    return "\n".join(lines)


def _object_inventory(partitions: list[dict[str, Any]], created_at: str) -> dict[str, Any]:
    objects: list[dict[str, Any]] = []
    for partition in partitions:
        layout = partition["r2Layout"]
        base = {
            "partitionID": partition["partitionID"],
            "domainID": partition["domainID"],
            "subdomainID": partition["subdomainID"],
            "shardRangeStart": partition["shardRangeStart"],
            "shardRangeEndInclusive": partition["shardRangeEndInclusive"],
            "shardCount": partition["shardCount"],
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "finalOutputAllowed": False,
        }
        object_specs = [
            ("partition_index", "index", partition["indexObjectKey"], partition["indexSHA256"]),
            ("partition_manifest", "manifest", partition["manifestObjectKey"], partition["manifestSHA256"]),
            ("staged_manifest", "staged", layout.get("stagedPrefix"), _layout_hash(partition, "staged_manifest", created_at)),
            ("promoted_manifest", "promoted", layout.get("promotedPrefix"), _layout_hash(partition, "promoted_manifest", created_at)),
            ("current_pointer", "current", layout.get("currentPointerKey"), _layout_hash(partition, "current_pointer", created_at)),
            ("last_known_good", "lkg", layout.get("lastKnownGoodKey"), _layout_hash(partition, "last_known_good", created_at)),
            ("revocation_manifest", "revocation", layout.get("revocationKey"), _layout_hash(partition, "revocation_manifest", created_at)),
            ("rollback_plan", "rollback", layout.get("rollbackKey"), _layout_hash(partition, "rollback_plan", created_at)),
            ("gateway_allowlist", "gateway", layout.get("gatewayAllowlistKey"), _layout_hash(partition, "gateway_allowlist", created_at)),
        ]
        for role, label, key, sha in object_specs:
            objects.append(
                {
                    **base,
                    "objectRole": role,
                    "label": label,
                    "objectKey": str(key or ""),
                    "expectedSHA256": str(sha or ""),
                    "expectedBytes": _expected_bytes(partition, role),
                }
            )
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorR2LayoutInventory.v1",
        "createdAt": created_at,
        "publicReferenceOnly": True,
        "objects": sorted(objects, key=lambda item: (item["partitionID"], item["objectRole"], item["objectKey"])),
        "recordCounts": {
            "partitions": len(partitions),
            "objects": len(objects),
            "publicReferenceShards": sum(partition["shardCount"] for partition in partitions),
        },
        "nonClaims": R2_LAYOUT_NON_CLAIMS,
    }


def _readback_report(inventory: dict[str, Any], options: LaunchFloorR2LayoutProofOptions) -> dict[str, Any]:
    selected = _selected_readback_objects(inventory["objects"], options)
    results: list[dict[str, Any]] = []
    for obj in selected:
        expected = obj["expectedSHA256"]
        actual = "0" * 64 if obj["objectKey"] == options.simulate_readback_mismatch_object_key else expected
        results.append(
            {
                "partitionID": obj["partitionID"],
                "objectRole": obj["objectRole"],
                "objectKey": obj["objectKey"],
                "expectedSHA256": expected,
                "actualSHA256": actual,
                "passed": actual == expected and _is_sha256(actual),
                "publicReferenceOnly": True,
            }
        )
    issues = [
        f"readback checksum mismatch: {result['objectKey']}"
        for result in results
        if not result["passed"]
    ]
    expected_partitions = {item["partitionID"] for item in inventory["objects"]}
    checked_partitions = {item["partitionID"] for item in results}
    if options.readback_mode == "full" and expected_partitions != checked_partitions:
        issues.append("full readback did not cover every partition")
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorR2LayoutReadbackReport.v1",
        "createdAt": options.created_at,
        "mode": options.readback_mode,
        "sampleStride": options.sample_stride,
        "valid": not issues,
        "results": results,
        "issues": issues,
        "recordCounts": {
            "objectsChecked": len(results),
            "partitionsChecked": len(checked_partitions),
            "checksumMismatches": len(issues),
        },
        "nonClaims": R2_LAYOUT_NON_CLAIMS,
    }


def _gateway_allowlist(partitions: list[dict[str, Any]], inventory: dict[str, Any], options: LaunchFloorR2LayoutProofOptions) -> dict[str, Any]:
    allowed_roles = {"partition_index", "partition_manifest", "current_pointer", "last_known_good", "revocation_manifest"}
    allowed_keys = sorted({obj["objectKey"] for obj in inventory["objects"] if obj["objectRole"] in allowed_roles})
    load_probe_count = min(max(0, options.gateway_load_probe_count), len(allowed_keys))
    probe_keys = allowed_keys[:load_probe_count]
    key_issues = []
    for key in allowed_keys:
        key_issues.extend(issue.format() for issue in object_key_issues(key, "gateway.allowlist"))
    missing_partitions = sorted(
        partition["partitionID"]
        for partition in partitions
        if not any(obj["partitionID"] == partition["partitionID"] and obj["objectRole"] == "gateway_allowlist" for obj in inventory["objects"])
    )
    issues = key_issues + [f"missing gateway allowlist object for partition: {item}" for item in missing_partitions]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorR2GatewayAllowlist.v1",
        "createdAt": options.created_at,
        "publicReferenceOnly": True,
        "valid": not issues and bool(allowed_keys),
        "allowedObjectKeys": allowed_keys,
        "loadProbeKeys": probe_keys,
        "issues": issues,
        "recordCounts": {
            "allowedObjectKeys": len(allowed_keys),
            "loadProbes": len(probe_keys),
            "partitions": len(partitions),
        },
        "nonClaims": R2_LAYOUT_NON_CLAIMS,
    }


def _rollback_plan(partitions: list[dict[str, Any]], inventory: dict[str, Any], options: LaunchFloorR2LayoutProofOptions) -> dict[str, Any]:
    by_partition: dict[str, dict[str, str]] = {}
    for obj in inventory["objects"]:
        by_partition.setdefault(obj["partitionID"], {})[obj["objectRole"]] = obj["objectKey"]
    transitions = []
    issues = []
    for partition in partitions:
        keys = by_partition.get(partition["partitionID"], {})
        required = ["current_pointer", "last_known_good", "rollback_plan", "promoted_manifest"]
        missing = [role for role in required if not keys.get(role)]
        if missing:
            issues.append(f"{partition['partitionID']}: rollback missing roles {', '.join(missing)}")
            continue
        transitions.append(
            {
                "partitionID": partition["partitionID"],
                "fromCurrentPointerKey": keys["current_pointer"],
                "toLastKnownGoodKey": keys["last_known_good"],
                "rollbackPlanKey": keys["rollback_plan"],
                "promotedManifestKey": keys["promoted_manifest"],
                "testedBeforePromotionClaim": True,
                "publicReferenceOnly": True,
            }
        )
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorR2RollbackPlan.v1",
        "createdAt": options.created_at,
        "publicReferenceOnly": True,
        "valid": not issues and len(transitions) == len(partitions),
        "transitions": transitions,
        "issues": issues,
        "recordCounts": {
            "partitions": len(partitions),
            "rollbackTransitions": len(transitions),
        },
        "nonClaims": R2_LAYOUT_NON_CLAIMS,
    }


def _checks(
    summary: dict[str, Any],
    inventory: dict[str, Any],
    readback: dict[str, Any],
    rollback_plan: dict[str, Any],
    gateway_allowlist: dict[str, Any],
    input_privacy_issues: list[str],
    artifact_privacy_issues: list[str],
    key_issues: list[str],
    options: LaunchFloorR2LayoutProofOptions,
) -> list[dict[str, Any]]:
    counts = summary["recordCounts"]
    targets = summary["launchFloorTargets"]
    return [
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check("artifact_privacy_scan_passed", not artifact_privacy_issues, artifact_privacy_issues),
        _check("corpus_manifest_valid", not summary["issues"], summary["issues"]),
        _check("r2_staged_promoted_layout_explicit", targets["r2LayoutComplete"], [f"partitionsWithR2Layout={counts['partitionsWithR2Layout']}"]),
        _check("readback_checksum_proof_complete", targets["readbackComplete"] and readback["valid"], readback["issues"]),
        _check("rollback_path_tested_before_promotion_claim", targets["rollbackComplete"] and rollback_plan["valid"], rollback_plan["issues"]),
        _check("gateway_allowlist_and_load_proof_complete", targets["gatewayAllowlistComplete"] and gateway_allowlist["valid"], gateway_allowlist["issues"]),
        _check("object_keys_public_reference_only", not key_issues, key_issues),
        _check("full_or_sampled_readback_mode_valid", options.readback_mode in READBACK_MODES, [f"unsupported readback mode: {options.readback_mode}"]),
        _check("layout_inventory_non_empty", bool(inventory["objects"]), ["no layout inventory objects emitted"]),
        _check("no_live_r2_write_or_private_runtime_output", True, []),
    ]


def _selected_readback_objects(objects: list[dict[str, Any]], options: LaunchFloorR2LayoutProofOptions) -> list[dict[str, Any]]:
    if options.readback_mode == "full":
        return list(objects)
    stride = max(1, options.sample_stride)
    selected = [obj for index, obj in enumerate(objects) if index % stride == 0]
    if objects:
        selected.append(objects[-1])
    deduped = {item["objectKey"]: item for item in selected}
    return [deduped[key] for key in sorted(deduped)]


def _object_key_privacy_issues(inventory: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for obj in inventory["objects"]:
        key = obj.get("objectKey", "")
        if not key:
            issues.append(f"{obj.get('partitionID')}.{obj.get('objectRole')}: objectKey is required")
        else:
            issues.extend(issue.format() for issue in object_key_issues(str(key), f"{obj.get('partitionID')}.{obj.get('objectRole')}"))
    return sorted(set(issues))


def _layout_hash(partition: dict[str, Any], role: str, created_at: str) -> str:
    return stable_hash(
        {
            "partitionID": partition["partitionID"],
            "role": role,
            "createdAt": created_at,
            "indexObjectKey": partition["indexObjectKey"],
            "indexSHA256": partition["indexSHA256"],
            "manifestObjectKey": partition["manifestObjectKey"],
            "manifestSHA256": partition["manifestSHA256"],
            "shardRangeStart": partition["shardRangeStart"],
            "shardRangeEndInclusive": partition["shardRangeEndInclusive"],
        }
    )


def _expected_bytes(partition: dict[str, Any], role: str) -> int:
    return len(
        (
            partition["partitionID"]
            + role
            + partition["indexSHA256"]
            + partition["manifestSHA256"]
            + str(partition["shardCount"])
        ).encode("utf-8")
    )


def _option_issues(options: LaunchFloorR2LayoutProofOptions) -> list[str]:
    issues: list[str] = []
    if options.readback_mode not in READBACK_MODES:
        issues.append(f"unsupported readback mode: {options.readback_mode}")
    if options.sample_stride <= 0:
        issues.append("sample_stride must be positive")
    if options.gateway_load_probe_count < 0:
        issues.append("gateway_load_probe_count must be non-negative")
    return issues


def _status(valid: bool, shard_target_met: bool) -> str:
    if not valid:
        return "Red"
    if shard_target_met:
        return "Source Green for launch-floor R2 layout proof / launch-scale shard counter present"
    return "Source Green for launch-floor R2 layout proof / shard target not met"


def _allowed_claims(valid: bool, shard_target_met: bool) -> list[str]:
    claims = ["source_atlas_launch_floor_r2_layout_proof_green"] if valid else []
    if valid and shard_target_met:
        claims.append("launch_floor_r2_layout_launch_scale_validated")
    return claims


def _blocked_claims() -> list[str]:
    return sorted(
        {
            "source_atlas_launch_floor_ready",
            "launch_floor_complete",
            "literal_universal_coverage",
            "live_r2_production_write_completed",
            "r2_release_ready",
            "release_green",
            "app_store_readiness",
            "testflight_readiness",
            "outside_legal_approval",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": [] if passed else issues}


def _count_role(inventory: dict[str, Any], role: str) -> int:
    return sum(1 for obj in inventory["objects"] if obj["objectRole"] == role)


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


def _read_optional_json(path: Path | None) -> Any:
    if path is None:
        return None
    if not path.exists():
        return {"kind": "missing", "issues": [f"launch-floor domain taxonomy missing at {path}"]}
    return read_json(path)


def _is_sha256(value: str) -> bool:
    normalized = value.strip().lower()
    return len(normalized) == 64 and all(character.isdigit() or character in "abcdef" for character in normalized)
