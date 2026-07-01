"""Native compatibility proof for launch-floor partitioned shard indexes."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value, object_key_issues
from .launch_floor_r2_layout_proof import DEFAULT_LAUNCH_FLOOR_SHARD_CORPUS_MANIFEST_PATH
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_LAUNCH_FLOOR_NATIVE_SHARD_INDEX_PROOF_KIND = "ambitions.sourceAtlas.launchFloorNativeShardIndexProof.v1"
SOURCE_ATLAS_LAUNCH_FLOOR_NATIVE_SHARD_INDEX_PROOF_VERSION = "source-atlas-launch-floor-native-shard-index-proof-lff-m02"
DEFAULT_R2_LAYOUT_INVENTORY_PATH = Path(
    "tools/source-atlas/generated/source-atlas-launch-floor-r2-layout-proof/"
    "lff-m02-l03-current/r2-layout-inventory.json"
)

REQUIRED_NATIVE_SOURCE_FILES = (
    "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasLaunchFloorShardIndexModels.swift",
    "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublishedPackSchemaDecoder.swift",
    "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/PublicPackRequestCompiler.swift",
    "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/R2GatewayClient.swift",
    "Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasLaunchFloorShardIndexCompatibilityTests.swift",
)
REQUIRED_NATIVE_SOURCE_TOKENS = (
    "SourceAtlasLaunchFloorShardCorpusManifest",
    "SourceAtlasLaunchFloorR2LayoutInventory",
    "compileLaunchFloorShardIndexRequests",
    "SourceAtlasLaunchFloorShardObjectRequest",
    "partitionIndex",
)
REQUIRED_NATIVE_TEST_SUITES = {
    "SourceAtlasLaunchFloorShardIndexCompatibilityTests",
}

NATIVE_SHARD_INDEX_NON_CLAIMS = [
    "native decoder/request compatibility proof only",
    "not launch-floor complete",
    "not proof of 1,000,000 public/reference shards unless the corpus counter reaches that threshold",
    "not live Cloudflare R2 production write proof",
    "not R2 release readiness",
    "not outside legal approval",
    "not Release Green, App Store readiness, or TestFlight readiness",
    "not native physical-device proof",
    "not independent accessibility proof",
    "not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class LaunchFloorNativeShardIndexProofOptions:
    shard_corpus_manifest_path: Path = DEFAULT_LAUNCH_FLOOR_SHARD_CORPUS_MANIFEST_PATH
    r2_layout_inventory_path: Path = DEFAULT_R2_LAYOUT_INVENTORY_PATH
    output_root: Path = Path("tools/source-atlas/generated/source-atlas-launch-floor-native-shard-index-proof/current")
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"
    xcode_result: str = "NOT_RUN"
    xcode_passed: int = 0
    xcode_failed: int = 0
    xcode_skipped: int = 0
    xcode_duration_ms: int | None = None
    xcode_log_path: str | None = None
    xcode_profile: str | None = None
    branch: str | None = None
    commit_sha: str | None = None
    worktree_dirty_entry_count: int | None = None
    test_suites: tuple[str, ...] = ()
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None


def run_launch_floor_native_shard_index_proof(options: LaunchFloorNativeShardIndexProofOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    manifest = _read_required_json(options.shard_corpus_manifest_path, "launch-floor shard corpus manifest", issues)
    inventory = _read_required_json(options.r2_layout_inventory_path, "launch-floor R2 layout inventory", issues)
    partitions = [item for item in manifest.get("partitions", []) if item.get("countsTowardLaunchFloor") is True] if isinstance(manifest, dict) else []
    inventory_objects = inventory.get("objects", []) if isinstance(inventory, dict) else []
    native_source = _native_source_proof()
    xcode_proof = _xcode_proof(options)
    request_shape = _request_shape_proof(partitions, inventory_objects)
    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "manifestPath": str(options.shard_corpus_manifest_path),
                "inventoryPath": str(options.r2_layout_inventory_path),
                "requestShape": request_shape,
                "xcodeProof": _privacy_xcode_view(xcode_proof),
            },
            "source-atlas-launch-floor-native-shard-index-proof",
        )
    )

    issues.extend(_manifest_issues(manifest, partitions))
    issues.extend(_inventory_issues(inventory, inventory_objects))
    issues.extend(native_source["issues"])
    issues.extend(_xcode_issues(xcode_proof))
    issues.extend(request_shape["issues"])
    issues.extend(privacy_issues)

    record_counts = {
        "partitions": len(partitions),
        "publicReferenceShards": sum(int(partition.get("shardCount", 0)) for partition in partitions),
        "layoutObjects": len(inventory_objects),
        "nativeCompatiblePartitions": sum(1 for partition in partitions if _partition_native_compatible(partition)),
        "partitionsWithR2Layout": sum(1 for partition in partitions if _partition_has_r2_layout(partition)),
        "partitionsWithReadbackProof": sum(1 for partition in partitions if _partition_has_readback(partition)),
        "requestShapeObjectKeysChecked": request_shape["objectKeysChecked"],
        "requestShapePrivateIssues": len(request_shape["issues"]),
        "nativeSourceFilesPresent": native_source["filesPresent"],
        "xcodePassed": xcode_proof["passed"],
        "xcodeFailed": xcode_proof["failed"],
        "xcodeSkipped": xcode_proof["skipped"],
        "privacyIssues": len(privacy_issues),
    }
    checks = [
        _check("shard_corpus_manifest_valid", not _manifest_issues(manifest, partitions), _manifest_issues(manifest, partitions)),
        _check("r2_layout_inventory_valid", not _inventory_issues(inventory, inventory_objects), _inventory_issues(inventory, inventory_objects)),
        _check("native_source_files_present", not native_source["issues"], native_source["issues"]),
        _check("focused_native_tests_passed", not _xcode_issues(xcode_proof), _xcode_issues(xcode_proof)),
        _check("request_shape_public_ids_hashes_only", not request_shape["issues"], request_shape["issues"]),
        _check("privacy_boundary", not privacy_issues, privacy_issues),
    ]
    valid = not issues and all(check["passed"] for check in checks)
    shard_target_met = record_counts["publicReferenceShards"] >= 1_000_000

    report_path = output_root / "native-shard-index-proof-report.json"
    markdown_path = output_root / "native-shard-index-proof-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_NATIVE_SHARD_INDEX_PROOF_KIND,
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_NATIVE_SHARD_INDEX_PROOF_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "proofID": stable_id(
            "source_atlas.launch_floor_native_shard_index_proof",
            {
                "manifestHash": stable_hash(manifest),
                "inventoryHash": stable_hash(inventory),
                "xcode": xcode_proof,
                "nativeSource": native_source["files"],
            },
        ),
        "status": _status(valid, shard_target_met),
        "valid": valid,
        "launchFloorShardTargetMet": shard_target_met if valid else False,
        "nativeShardIndexCompatibilityProofMet": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; native partitioned shard-index compatibility proof only",
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "nativeSourceProof": native_source,
        "requestShapeProof": request_shape,
        "xcodeProof": xcode_proof,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "productLaw": {
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "sourceAtlasGeneratesFinalPlansSchedulesSteps": False,
            "r2Role": "public/reference/freshness infrastructure only",
        },
        "allowedClaims": _allowed_claims(valid),
        "blockedClaims": _blocked_claims(),
        "nonClaims": NATIVE_SHARD_INDEX_NON_CLAIMS,
        "evidencePaths": {
            "shardCorpusManifest": str(options.shard_corpus_manifest_path),
            "r2LayoutInventory": str(options.r2_layout_inventory_path),
            "xcodeLog": options.xcode_log_path,
        },
        "branch": options.branch,
        "commitSHA": options.commit_sha,
        "worktreeDirtyEntryCountAtProof": options.worktree_dirty_entry_count,
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
            "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
        },
    }
    report["outputHashes"] = {
        "reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"})
    }
    markdown = launch_floor_native_shard_index_proof_markdown(report)
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


def launch_floor_native_shard_index_proof_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Launch-Floor Native Shard Index Proof LFF-M02",
        "",
        f"Status: {report['status']}",
        f"Native shard-index compatibility proof met: {str(report['nativeShardIndexCompatibilityProofMet']).lower()}",
        f"Launch-floor shard target met: {str(report['launchFloorShardTargetMet']).lower()}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "## Current Proved Capability",
        "",
        f"- Counted public/reference shards: {counts['publicReferenceShards']}",
        f"- Counted partitions: {counts['partitions']}",
        f"- R2 layout objects consumed: {counts['layoutObjects']}",
        f"- Native-compatible partitions: {counts['nativeCompatiblePartitions']}",
        f"- Request object keys checked: {counts['requestShapeObjectKeysChecked']}",
        f"- Focused native tests passed/failed/skipped: {counts['xcodePassed']}/{counts['xcodeFailed']}/{counts['xcodeSkipped']}",
        "",
        "## Checks",
        "",
        "| Check | Passed | Issues |",
        "| --- | --- | --- |",
    ]
    for check in report["checks"]:
        lines.append(
            f"| {check['name']} | {str(check['passed']).lower()} | {'; '.join(check['issues']) if check['issues'] else 'none'} |"
        )
    lines.extend(
        [
            "",
            "## Non-Claims",
            "",
            *[f"- {item}" for item in report["nonClaims"]],
            "",
            "## Blocked Claims",
            "",
            *[f"- {item}" for item in report["blockedClaims"]],
            "",
            "Rollback plan:",
            "- Revert the native shard-index model/request/gateway files, focused tests, and this generated proof bundle.",
            "",
        ]
    )
    return "\n".join(lines)


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - defensive CLI guard
        issues.append(f"{label} missing or unreadable: {path}: {exc}")
        return {}


def _manifest_issues(manifest: Any, partitions: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(manifest, dict):
        return ["launch-floor shard corpus manifest is not an object"]
    if manifest.get("kind") != "ambitions.sourceAtlas.launchFloorShardCorpusManifest.v1":
        issues.append("unsupported shard corpus manifest kind")
    if manifest.get("schemaVersion") != 1:
        issues.append("unsupported shard corpus manifest schema")
    if manifest.get("publicReferenceOnly") is not True:
        issues.append("shard corpus manifest is not public/reference only")
    if manifest.get("privateContextAllowed") is not False:
        issues.append("shard corpus manifest allows private context")
    if manifest.get("finalOutputAllowed") is not False:
        issues.append("shard corpus manifest allows final output")
    if not partitions:
        issues.append("no launch-floor counted partitions")
    for partition in partitions:
        issues.extend(_partition_issues(partition))
    return sorted(set(issues))


def _partition_issues(partition: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    if not partition.get("partitionID") or not partition.get("domainID") or not partition.get("subdomainID"):
        issues.append("partition identity missing")
    if partition.get("publicReferenceOnly") is not True:
        issues.append(f"{partition.get('partitionID')}: partition not public/reference only")
    if partition.get("privateContextAllowed") is not False:
        issues.append(f"{partition.get('partitionID')}: private context allowed")
    if partition.get("finalOutputAllowed") is not False:
        issues.append(f"{partition.get('partitionID')}: final output allowed")
    shard_count = int(partition.get("shardCount", 0))
    start = int(partition.get("shardRangeStart", 0))
    end = int(partition.get("shardRangeEndInclusive", -1))
    if shard_count <= 0 or end < start or end - start + 1 != shard_count:
        issues.append(f"{partition.get('partitionID')}: invalid shard range")
    for field in ("indexSHA256", "manifestSHA256"):
        if not _is_sha256(str(partition.get(field, ""))):
            issues.append(f"{partition.get('partitionID')}: invalid {field}")
    if not _partition_native_compatible(partition):
        issues.append(f"{partition.get('partitionID')}: native compatibility missing")
    if not _partition_has_r2_layout(partition):
        issues.append(f"{partition.get('partitionID')}: R2 layout incomplete")
    if not _partition_has_readback(partition):
        issues.append(f"{partition.get('partitionID')}: readback/rollback/gateway proof incomplete")
    for key in _partition_object_keys(partition):
        issues.extend(issue.format() for issue in object_key_issues(str(key), f"{partition.get('partitionID')}.objectKey"))
    return issues


def _inventory_issues(inventory: Any, objects: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(inventory, dict):
        return ["R2 layout inventory is not an object"]
    if inventory.get("kind") != "ambitions.sourceAtlas.launchFloorR2LayoutInventory.v1":
        issues.append("unsupported R2 layout inventory kind")
    if inventory.get("schemaVersion") != 1:
        issues.append("unsupported R2 layout inventory schema")
    if inventory.get("publicReferenceOnly") is not True:
        issues.append("R2 layout inventory is not public/reference only")
    if not objects:
        issues.append("R2 layout inventory has no objects")
    for obj in objects:
        if obj.get("publicReferenceOnly") is not True:
            issues.append(f"{obj.get('partitionID')}.{obj.get('objectRole')}: object not public/reference only")
        if obj.get("privateContextAllowed") is not False:
            issues.append(f"{obj.get('partitionID')}.{obj.get('objectRole')}: object allows private context")
        if obj.get("finalOutputAllowed") is not False:
            issues.append(f"{obj.get('partitionID')}.{obj.get('objectRole')}: object allows final output")
        if not _is_sha256(str(obj.get("expectedSHA256", ""))):
            issues.append(f"{obj.get('partitionID')}.{obj.get('objectRole')}: expected SHA invalid")
        issues.extend(issue.format() for issue in object_key_issues(str(obj.get("objectKey", "")), f"{obj.get('partitionID')}.{obj.get('objectRole')}"))
    return sorted(set(issues))


def _native_source_proof() -> dict[str, Any]:
    files: list[dict[str, Any]] = []
    issues: list[str] = []
    for path_text in REQUIRED_NATIVE_SOURCE_FILES:
        path = Path(path_text)
        exists = path.exists()
        text = path.read_text(encoding="utf-8") if exists else ""
        files.append(
            {
                "path": path_text,
                "exists": exists,
                "sha256": stable_hash(text) if exists else None,
            }
        )
        if not exists:
            issues.append(f"native source file missing: {path_text}")
    combined = "\n".join(Path(path).read_text(encoding="utf-8") for path in REQUIRED_NATIVE_SOURCE_FILES if Path(path).exists())
    for token in REQUIRED_NATIVE_SOURCE_TOKENS:
        if token not in combined:
            issues.append(f"native source token missing: {token}")
    return {
        "files": files,
        "filesPresent": sum(1 for item in files if item["exists"]),
        "requiredTokens": list(REQUIRED_NATIVE_SOURCE_TOKENS),
        "issues": sorted(set(issues)),
    }


def _xcode_proof(options: LaunchFloorNativeShardIndexProofOptions) -> dict[str, Any]:
    return {
        "result": options.xcode_result,
        "passed": options.xcode_passed,
        "failed": options.xcode_failed,
        "skipped": options.xcode_skipped,
        "durationMS": options.xcode_duration_ms,
        "logPath": options.xcode_log_path,
        "profile": options.xcode_profile,
        "testSuites": sorted(set(options.test_suites)),
    }


def _xcode_issues(proof: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    if str(proof.get("result", "")).upper() not in {"PASSED", "PASS"}:
        issues.append("focused native shard-index tests did not pass")
    if int(proof.get("failed", 0)) != 0:
        issues.append("focused native shard-index tests have failures")
    if int(proof.get("passed", 0)) <= 0:
        issues.append("focused native shard-index tests have no passed tests")
    missing = REQUIRED_NATIVE_TEST_SUITES.difference(set(proof.get("testSuites", [])))
    for suite in sorted(missing):
        issues.append(f"required native test suite missing: {suite}")
    return issues


def _request_shape_proof(partitions: list[dict[str, Any]], inventory_objects: list[dict[str, Any]]) -> dict[str, Any]:
    object_keys = [key for partition in partitions for key in _partition_object_keys(partition)]
    object_keys.extend(str(obj.get("objectKey", "")) for obj in inventory_objects)
    issues = sorted(set(issue.format() for key in object_keys for issue in object_key_issues(str(key), "native-shard-index-request-key")))
    return {
        "requestShape": "public_ids_hashes_object_keys_only",
        "objectKeysChecked": len(object_keys),
        "queryFieldsAllowed": [
            "domain_id",
            "subdomain_id",
            "partition_id",
            "object_role",
            "object_key",
            "expected_sha256",
            "shard_range_start",
            "shard_range_end",
            "shard_count",
        ],
        "forbiddenPrivateFields": [
            "goal_text",
            "capture_text",
            "schedule",
            "proof",
            "receipt",
            "account_id",
            "device_id",
            "private_life_graph",
            "behavior_history",
            "inferred_priority",
        ],
        "issues": issues,
    }


def _privacy_xcode_view(proof: dict[str, Any]) -> dict[str, Any]:
    return {
        "result": proof.get("result"),
        "passed": proof.get("passed"),
        "failed": proof.get("failed"),
        "skipped": proof.get("skipped"),
        "testSuites": proof.get("testSuites"),
    }


def _partition_native_compatible(partition: dict[str, Any]) -> bool:
    native = partition.get("nativeCompatibility", {})
    return (
        native.get("partitionedShardIndexV1") is True
        and native.get("privateContextAllowed") is False
        and native.get("requestShape") == "public_ids_hashes_only"
    )


def _partition_has_r2_layout(partition: dict[str, Any]) -> bool:
    layout = partition.get("r2Layout", {})
    required = [
        "currentPointerKey",
        "gatewayAllowlistKey",
        "lastKnownGoodKey",
        "promotedPrefix",
        "revocationKey",
        "rollbackKey",
        "stagedPrefix",
    ]
    return bool(partition.get("indexObjectKey")) and bool(partition.get("manifestObjectKey")) and all(layout.get(key) for key in required)


def _partition_has_readback(partition: dict[str, Any]) -> bool:
    proof = partition.get("readbackProof", {})
    return (
        proof.get("checksumVerified") is True
        and proof.get("gatewayAllowlistVerified") is True
        and proof.get("rollbackVerified") is True
    )


def _partition_object_keys(partition: dict[str, Any]) -> list[str]:
    layout = partition.get("r2Layout", {})
    return [
        str(partition.get("indexObjectKey", "")),
        str(partition.get("manifestObjectKey", "")),
        str(layout.get("currentPointerKey", "")),
        str(layout.get("gatewayAllowlistKey", "")),
        str(layout.get("lastKnownGoodKey", "")),
        str(layout.get("promotedPrefix", "")),
        str(layout.get("revocationKey", "")),
        str(layout.get("rollbackKey", "")),
        str(layout.get("stagedPrefix", "")),
    ]


def _is_sha256(value: str) -> bool:
    return len(value) == 64 and all(char in "0123456789abcdef" for char in value.lower())


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {
        "name": name,
        "passed": bool(passed),
        "issues": sorted(set(issues)),
    }


def _status(valid: bool, shard_target_met: bool) -> str:
    if not valid:
        return "Red"
    if shard_target_met:
        return "Source Green for native launch-floor shard-index compatibility / launch-scale shard counter present"
    return "Source Green for native launch-floor shard-index compatibility / shard target not met"


def _allowed_claims(valid: bool) -> list[str]:
    return ["source_atlas_native_partitioned_shard_index_compatibility_green"] if valid else []


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
            "native_physical_device_green",
            "independent_accessibility_green",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )
