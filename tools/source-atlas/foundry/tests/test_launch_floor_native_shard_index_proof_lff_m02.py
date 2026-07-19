from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.launch_floor_native_shard_index_proof import (  # noqa: E402
    LaunchFloorNativeShardIndexProofOptions,
    run_launch_floor_native_shard_index_proof,
)
from foundry.model import read_json, write_json  # noqa: E402


REPO_ROOT = Path(__file__).resolve().parents[4]
SOURCE_ATLAS_ROOT = REPO_ROOT / "tools" / "source-atlas"
CURRENT_MANIFEST = (
    SOURCE_ATLAS_ROOT
    / "generated"
    / "source-atlas-launch-floor-shard-corpus-compiler"
    / "lff-m02-l02-current"
    / "launch-floor-shard-corpus-manifest.json"
)
CURRENT_INVENTORY = (
    SOURCE_ATLAS_ROOT
    / "generated"
    / "source-atlas-launch-floor-r2-layout-proof"
    / "lff-m02-l03-current"
    / "r2-layout-inventory.json"
)


def test_current_repo_native_shard_index_proof_passes_with_focused_native_result(tmp_path: Path):
    report = run_launch_floor_native_shard_index_proof(_options(tmp_path / "current"))

    assert report["valid"] is True, report["issues"]
    assert report["nativeShardIndexCompatibilityProofMet"] is True
    assert report["launchFloorShardTargetMet"] is False
    assert report["recordCounts"]["partitions"] == 14
    assert report["recordCounts"]["publicReferenceShards"] == 71
    assert report["recordCounts"]["layoutObjects"] == 126
    assert report["recordCounts"]["nativeCompatiblePartitions"] == 14
    assert report["recordCounts"]["requestShapePrivateIssues"] == 0
    assert "source_atlas_native_partitioned_shard_index_compatibility_green" in report["allowedClaims"]
    assert "launch_floor_complete" in report["blockedClaims"]


def test_private_partition_object_key_fails_closed(tmp_path: Path):
    manifest = copy.deepcopy(read_json(CURRENT_MANIFEST))
    manifest["partitions"][0]["indexObjectKey"] = "source-atlas/public-reference/corpus/users/private/index-v1.json"
    manifest_path = tmp_path / "private-manifest.json"
    write_json(manifest_path, manifest)

    report = run_launch_floor_native_shard_index_proof(
        _options(tmp_path / "private-key", manifest_path=manifest_path)
    )

    assert report["valid"] is False
    assert report["allowedClaims"] == []
    assert any("private_r2_object_key_segment" in issue for issue in report["issues"])


def test_missing_native_test_result_blocks_proof(tmp_path: Path):
    report = run_launch_floor_native_shard_index_proof(
        LaunchFloorNativeShardIndexProofOptions(
            shard_corpus_manifest_path=CURRENT_MANIFEST,
            r2_layout_inventory_path=CURRENT_INVENTORY,
            output_root=tmp_path / "missing-native-result",
            xcode_result="NOT_RUN",
            xcode_passed=0,
            xcode_failed=0,
            xcode_skipped=0,
        )
    )

    assert report["valid"] is False
    assert report["allowedClaims"] == []
    assert "focused native shard-index tests did not pass" in report["issues"]
    assert "required native test suite missing: SourceAtlasLaunchFloorShardIndexCompatibilityTests" in report["issues"]


def _options(
    output_root: Path,
    *,
    manifest_path: Path = CURRENT_MANIFEST,
    inventory_path: Path = CURRENT_INVENTORY,
) -> LaunchFloorNativeShardIndexProofOptions:
    return LaunchFloorNativeShardIndexProofOptions(
        shard_corpus_manifest_path=manifest_path,
        r2_layout_inventory_path=inventory_path,
        output_root=output_root,
        created_at="2026-07-01T00:00:00Z",
        run_label="lff-m02-test",
        xcode_result="PASSED",
        xcode_passed=4,
        xcode_failed=0,
        xcode_skipped=0,
        xcode_duration_ms=1000,
        xcode_log_path="local-xcode-focused.log",
        xcode_profile="focused",
        branch="main",
        commit_sha="test",
        worktree_dirty_entry_count=0,
        test_suites=("SourceAtlasLaunchFloorShardIndexCompatibilityTests",),
    )
