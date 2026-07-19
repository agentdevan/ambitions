from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.launch_floor_shard_corpus import (  # noqa: E402
    LaunchFloorShardCorpusOptions,
    compile_launch_floor_shard_corpus,
    launch_floor_shard_corpus_summary,
)
from foundry.model import write_json  # noqa: E402


def test_valid_compact_partition_manifest_counts_one_million_public_reference_shards(tmp_path: Path):
    manifest = _manifest()
    summary = launch_floor_shard_corpus_summary(manifest)

    assert summary["issues"] == []
    assert summary["recordCounts"]["publicReferenceShards"] == 1_000_000
    assert summary["recordCounts"]["launchFloorCountedPartitions"] == 2
    assert summary["launchFloorTargets"]["publicReferenceShards1M"] is True
    assert summary["launchFloorTargets"]["r2LayoutComplete"] is True
    assert summary["launchFloorTargets"]["readbackComplete"] is True
    assert summary["launchFloorTargets"]["rollbackComplete"] is True
    assert summary["launchFloorTargets"]["gatewayAllowlistComplete"] is True
    assert summary["launchFloorTargets"]["nativeDecoderCompatibilityComplete"] is True

    manifest_path = tmp_path / "launch-floor-shard-corpus.json"
    write_json(manifest_path, manifest)
    report = compile_launch_floor_shard_corpus(
        LaunchFloorShardCorpusOptions(
            manifest_path=manifest_path,
            launch_floor_taxonomy_path=None,
            output_root=tmp_path / "proof",
            created_at="2026-07-01T00:00:00Z",
            run_label="lff-m02-test",
        )
    )

    assert report["valid"] is True
    assert report["launchFloorShardTargetMet"] is True
    assert "launch_floor_public_reference_shards_1m_met" in report["allowedClaims"]
    assert "final_user_plans_schedules_steps_from_source_atlas_or_r2" in report["blockedClaims"]


def test_raw_record_count_manifest_is_rejected_fail_closed():
    summary = launch_floor_shard_corpus_summary(
        {
            "kind": "ambitions.sourceAtlas.shardCorpusManifest.v1",
            "recordCounts": {"publicReferenceShards": 1_000_000},
        }
    )

    assert summary["recordCounts"]["publicReferenceShards"] == 0
    assert summary["launchFloorTargets"]["publicReferenceShards1M"] is False
    assert any(
        "shard corpus manifest kind must be ambitions.sourceAtlas.launchFloorShardCorpusManifest.v1" in issue
        for issue in summary["issues"]
    )


def test_missing_registry_and_verification_proofs_are_rejected():
    manifest = _manifest()
    partition = manifest["partitions"][0]
    partition["sourceLane"]["registryIDs"] = []
    partition["readbackProof"]["rollbackVerified"] = False
    partition["readbackProof"]["gatewayAllowlistVerified"] = False
    partition["nativeCompatibility"]["requestShape"] = "full_payload"

    summary = launch_floor_shard_corpus_summary(manifest)

    assert summary["launchFloorTargets"]["sourceLaneRegistryLinksComplete"] is False
    assert summary["launchFloorTargets"]["rollbackComplete"] is False
    assert summary["launchFloorTargets"]["gatewayAllowlistComplete"] is False
    assert summary["launchFloorTargets"]["nativeDecoderCompatibilityComplete"] is False
    assert any("sourceLane.registryIDs is required" in issue for issue in summary["issues"])
    assert any("rollback proof is required" in issue for issue in summary["issues"])
    assert any("gateway allowlist proof is required" in issue for issue in summary["issues"])
    assert any("native partitioned shard index compatibility is required" in issue for issue in summary["issues"])


def test_private_object_key_segments_are_rejected():
    manifest = _manifest()
    manifest["partitions"][0]["indexObjectKey"] = "source-atlas/private/user/index-v1.json"

    summary = launch_floor_shard_corpus_summary(manifest)

    assert any("private_r2_object_key_segment: private" in issue for issue in summary["issues"])
    assert any("private_r2_object_key_segment: user" in issue for issue in summary["issues"])


def _manifest() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorShardCorpusManifest.v1",
        "versionID": "test-launch-floor-shard-corpus-1m",
        "createdAt": "2026-07-01T00:00:00Z",
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "partitions": [
            _partition("public-reference-accessibility-costs-p000", 0, 500_000, "a"),
            _partition("public-reference-accessibility-costs-p001", 500_000, 500_000, "b"),
        ],
        "nonClaims": [
            "test fixture only",
            "not R2 production upload proof",
            "not final user plans, schedules, or Steps",
        ],
    }


def _partition(partition_id: str, start: int, count: int, sha_seed: str) -> dict:
    domain_id = "accessibility_disability_reference"
    subdomain_id = "accessibility_disability_reference__costs_fees_and_funding"
    base = f"source-atlas/public-reference/corpus/{domain_id.replace('_', '-')}/{subdomain_id.replace('_', '-')}/{partition_id}"
    return {
        "partitionID": partition_id,
        "domainID": domain_id,
        "subdomainID": subdomain_id,
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "countsTowardLaunchFloor": True,
        "shardRangeStart": start,
        "shardRangeEndInclusive": start + count - 1,
        "shardCount": count,
        "indexObjectKey": f"{base}/index-v1.json",
        "indexSHA256": sha_seed * 64,
        "manifestObjectKey": f"{base}/manifest-v1.json",
        "manifestSHA256": sha_seed * 64,
        "sourceLane": {
            "profileIDs": ["official_government_public_reference"],
            "registryIDs": ["synthetic.public"],
        },
        "legalPolicyState": "approved_public_reference_fixture",
        "apiPolicyState": "approved_public_reference_fixture",
        "freshnessSLA": "30d",
        "revocationState": "revocable_by_partition",
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
            "checksumVerified": True,
            "rollbackVerified": True,
            "gatewayAllowlistVerified": True,
        },
        "nativeCompatibility": {
            "partitionedShardIndexV1": True,
            "requestShape": "public_ids_hashes_only",
            "privateContextAllowed": False,
        },
    }
