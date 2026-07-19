from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.launch_floor_r2_layout_proof import (  # noqa: E402
    LaunchFloorR2LayoutProofOptions,
    run_launch_floor_r2_layout_proof,
)
from foundry.launch_floor_shard_corpus_compiler import (  # noqa: E402
    LaunchFloorShardCorpusCompilerOptions,
    compile_launch_floor_shard_corpus_bulk,
)
from foundry.model import read_json, write_json  # noqa: E402


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
PRODUCTION_LEDGER = SOURCE_ATLAS_ROOT / "generated" / "production-target-ledger" / "train-131-tetradeca-current" / "production-target-ledger.json"
SOURCE_LANE_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "source-lane-registry.json"
LEGAL_TERMS_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "legal-terms-registry.json"
API_GOVERNANCE_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "api-governance-registry.json"
LAUNCH_FLOOR_TAXONOMY = SOURCE_ATLAS_ROOT / "frontier" / "launch-floor-domain-taxonomy.json"
CURRENT_MANIFEST = (
    SOURCE_ATLAS_ROOT
    / "generated"
    / "source-atlas-launch-floor-shard-corpus-compiler"
    / "lff-m02-l02-current"
    / "launch-floor-shard-corpus-manifest.json"
)


def test_current_corpus_proves_bounded_r2_layout_without_1m_claim(tmp_path: Path):
    report = run_launch_floor_r2_layout_proof(_options(tmp_path / "current"))

    assert report["valid"] is True, report["issues"]
    assert report["launchFloorShardTargetMet"] is False
    assert report["launchFloorR2LayoutProofMet"] is True
    assert report["recordCounts"]["publicReferenceShards"] == 71
    assert report["recordCounts"]["launchFloorCountedPartitions"] == 14
    assert report["recordCounts"]["layoutObjects"] == 126
    assert report["recordCounts"]["readbackObjectsChecked"] == 126
    assert report["recordCounts"]["readbackChecksumMismatches"] == 0
    assert report["recordCounts"]["rollbackTransitionsTested"] == 14
    assert report["recordCounts"]["gatewayLoadProbes"] == 70
    assert report["recordCounts"]["r2LiveWrites"] == 0
    assert "source_atlas_launch_floor_r2_layout_proof_green" in report["allowedClaims"]
    assert "launch_floor_r2_layout_launch_scale_validated" not in report["allowedClaims"]
    assert "live_r2_production_write_completed" in report["blockedClaims"]


def test_launch_scale_corpus_proves_sampled_layout_contract(tmp_path: Path):
    source_units_path = tmp_path / "source-units.json"
    write_json(source_units_path, _source_units(source_record_count=1_000_000))
    compiler_report = compile_launch_floor_shard_corpus_bulk(
        _compiler_options(
            tmp_path / "compiler",
            source_units_path=source_units_path,
            max_partition_shards=250_000,
        )
    )

    report = run_launch_floor_r2_layout_proof(
        _options(
            tmp_path / "r2-launch-scale",
            manifest_path=Path(compiler_report["outputPaths"]["manifest"]),
            readback_mode="sampled",
            sample_stride=5,
        )
    )

    assert report["valid"] is True, report["issues"]
    assert report["launchFloorShardTargetMet"] is True
    assert report["launchFloorR2LayoutProofMet"] is True
    assert report["recordCounts"]["publicReferenceShards"] == 1_000_000
    assert report["recordCounts"]["launchFloorCountedPartitions"] == 4
    assert report["recordCounts"]["layoutObjects"] == 36
    assert 0 < report["recordCounts"]["readbackObjectsChecked"] < 36
    assert "launch_floor_r2_layout_launch_scale_validated" in report["allowedClaims"]


def test_private_object_key_fails_closed(tmp_path: Path):
    manifest = copy.deepcopy(read_json(CURRENT_MANIFEST))
    manifest["partitions"][0]["r2Layout"]["currentPointerKey"] = "source-atlas/private/users/current-pointer-v1.json"
    manifest_path = tmp_path / "private-key-manifest.json"
    write_json(manifest_path, manifest)

    report = run_launch_floor_r2_layout_proof(_options(tmp_path / "private-key", manifest_path=manifest_path))

    assert report["valid"] is False
    assert report["allowedClaims"] == []
    assert any("private_r2_object_key_segment" in issue for issue in report["issues"])


def test_readback_mismatch_fails_closed(tmp_path: Path):
    manifest = read_json(CURRENT_MANIFEST)
    mismatch_key = manifest["partitions"][0]["indexObjectKey"]

    report = run_launch_floor_r2_layout_proof(
        _options(
            tmp_path / "readback-mismatch",
            simulate_readback_mismatch_object_key=mismatch_key,
        )
    )

    assert report["valid"] is False
    assert report["allowedClaims"] == []
    assert any("readback checksum mismatch" in issue for issue in report["issues"])


def test_missing_rollback_role_fails_closed(tmp_path: Path):
    manifest = copy.deepcopy(read_json(CURRENT_MANIFEST))
    manifest["partitions"][0]["r2Layout"]["rollbackKey"] = ""
    manifest_path = tmp_path / "missing-rollback-manifest.json"
    write_json(manifest_path, manifest)

    report = run_launch_floor_r2_layout_proof(_options(tmp_path / "missing-rollback", manifest_path=manifest_path))

    assert report["valid"] is False
    assert report["allowedClaims"] == []
    assert any("rollback missing roles" in issue for issue in report["issues"])


def _options(
    output_root: Path,
    *,
    manifest_path: Path = CURRENT_MANIFEST,
    readback_mode: str = "full",
    sample_stride: int = 97,
    simulate_readback_mismatch_object_key: str | None = None,
) -> LaunchFloorR2LayoutProofOptions:
    return LaunchFloorR2LayoutProofOptions(
        shard_corpus_manifest_path=manifest_path,
        launch_floor_taxonomy_path=LAUNCH_FLOOR_TAXONOMY,
        output_root=output_root,
        created_at="2026-07-01T00:00:00Z",
        run_label="lff-m02-test",
        readback_mode=readback_mode,
        sample_stride=sample_stride,
        gateway_load_probe_count=1000,
        simulate_readback_mismatch_object_key=simulate_readback_mismatch_object_key,
    )


def _compiler_options(
    output_root: Path,
    *,
    source_units_path: Path,
    max_partition_shards: int,
) -> LaunchFloorShardCorpusCompilerOptions:
    return LaunchFloorShardCorpusCompilerOptions(
        production_target_ledger_path=PRODUCTION_LEDGER,
        source_lane_registry_path=SOURCE_LANE_REGISTRY,
        legal_terms_registry_path=LEGAL_TERMS_REGISTRY,
        api_governance_registry_path=API_GOVERNANCE_REGISTRY,
        launch_floor_taxonomy_path=LAUNCH_FLOOR_TAXONOMY,
        source_units_path=source_units_path,
        max_partition_shards=max_partition_shards,
        output_root=output_root,
        created_at="2026-07-01T00:00:00Z",
        run_label="lff-m02-test",
    )


def _source_units(*, source_record_count: int) -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorShardSourceUnits.v1",
        "versionID": "test-launch-floor-shard-source-units",
        "createdAt": "2026-07-01T00:00:00Z",
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "sourceUnits": [
            {
                "sourceUnitID": "public-reference-business-launch-scale",
                "domainID": "business_entrepreneurship",
                "subdomainID": "business_entrepreneurship__costs_fees_and_funding",
                "publicReferenceOnly": True,
                "privateContextAllowed": False,
                "finalOutputAllowed": False,
                "reviewedPublicReferenceSource": True,
                "sourceReviewState": "reviewed_public_reference",
                "sourceIDs": ["sba.business_guide.start_business"],
                "sourceLane": {
                    "profileIDs": ["official_government_public_reference"],
                    "registryIDs": ["sba.business_guide.start_business"],
                },
                "legalPolicyIDs": ["sba_public_web"],
                "apiPolicyIDs": ["api.static_public_page.v1"],
                "sourceRecordCount": source_record_count,
                "shardClasses": ["public_reference_claim"],
                "recordEvidenceSHA256": "a" * 64,
                "provenanceRefs": [
                    {
                        "sourceID": "sba.business_guide.start_business",
                        "artifactPath": "tools/source-atlas/generated/pack-production/train-43-business-production-stable/pack-production-report.json",
                        "artifactSHA256": "b" * 64,
                        "retrievedAt": "2026-07-01T00:00:00Z",
                    }
                ],
                "verificationProof": {
                    "r2LayoutPrepared": True,
                    "checksumVerified": True,
                    "rollbackVerified": True,
                    "gatewayAllowlistVerified": True,
                    "nativePartitionedShardIndexV1": True,
                },
            }
        ],
        "nonClaims": [
            "test fixture only",
            "not R2 production upload proof",
            "not final user plans, schedules, or Steps",
        ],
    }
