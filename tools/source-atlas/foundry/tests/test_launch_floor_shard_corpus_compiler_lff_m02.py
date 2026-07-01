from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.launch_floor_shard_corpus_compiler import (  # noqa: E402
    LaunchFloorShardCorpusCompilerOptions,
    compile_launch_floor_shard_corpus_bulk,
)
from foundry.model import write_json  # noqa: E402


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
PRODUCTION_LEDGER = SOURCE_ATLAS_ROOT / "generated" / "production-target-ledger" / "train-131-tetradeca-current" / "production-target-ledger.json"
SOURCE_LANE_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "source-lane-registry.json"
LEGAL_TERMS_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "legal-terms-registry.json"
API_GOVERNANCE_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "api-governance-registry.json"
LAUNCH_FLOOR_TAXONOMY = SOURCE_ATLAS_ROOT / "frontier" / "launch-floor-domain-taxonomy.json"


def test_current_production_target_ledger_compiles_bounded_valid_corpus_without_1m_claim(tmp_path: Path):
    report = compile_launch_floor_shard_corpus_bulk(_options(tmp_path / "current"))

    assert report["valid"] is True, report["issues"]
    assert report["launchFloorShardTargetMet"] is False
    assert report["recordCounts"]["sourceUnits"] == 14
    assert report["recordCounts"]["reviewedSourceUnits"] == 14
    assert report["recordCounts"]["publicReferenceShards"] == 71
    assert report["compiledManifest"]["targetStatus"]["publicReferenceShards1M"] is False
    assert "source_atlas_launch_floor_shard_corpus_compiler_green" in report["allowedClaims"]
    assert "launch_floor_public_reference_shards_1m_compiled_and_validated" not in report["allowedClaims"]
    assert "source_atlas_launch_floor_ready" in report["blockedClaims"]


def test_reviewed_launch_scale_source_units_compile_to_partitioned_manifest(tmp_path: Path):
    source_units_path = tmp_path / "source-units.json"
    write_json(source_units_path, _source_units(source_record_count=1_000_000))

    report = compile_launch_floor_shard_corpus_bulk(
        _options(
            tmp_path / "launch-scale",
            source_units_path=source_units_path,
            max_partition_shards=250_000,
        )
    )

    assert report["valid"] is True, report["issues"]
    assert report["launchFloorShardTargetMet"] is True
    assert report["recordCounts"]["publicReferenceShards"] == 1_000_000
    assert report["recordCounts"]["launchFloorCountedPartitions"] == 4
    assert report["compiledManifest"]["targetStatus"]["publicReferenceShards1M"] is True
    assert "launch_floor_public_reference_shards_1m_compiled_and_validated" in report["allowedClaims"]


def test_missing_legal_or_api_posture_fails_closed(tmp_path: Path):
    source_units = _source_units(source_record_count=1_000)
    source_units["sourceUnits"][0]["legalPolicyIDs"] = []
    source_units["sourceUnits"][0]["apiPolicyIDs"] = []
    source_units_path = tmp_path / "source-units-missing-policy.json"
    write_json(source_units_path, source_units)

    report = compile_launch_floor_shard_corpus_bulk(
        _options(tmp_path / "missing-policy", source_units_path=source_units_path)
    )

    assert report["valid"] is False
    assert any("legalPolicyIDs are required" in issue for issue in report["issues"])
    assert any("apiPolicyIDs are required" in issue for issue in report["issues"])
    assert report["allowedClaims"] == []


def test_missing_verification_proof_fails_closed(tmp_path: Path):
    source_units = _source_units(source_record_count=1_000)
    source_units["sourceUnits"][0]["verificationProof"]["checksumVerified"] = False
    source_units["sourceUnits"][0]["verificationProof"]["gatewayAllowlistVerified"] = False
    source_units_path = tmp_path / "source-units-missing-proof.json"
    write_json(source_units_path, source_units)

    report = compile_launch_floor_shard_corpus_bulk(
        _options(tmp_path / "missing-proof", source_units_path=source_units_path)
    )

    assert report["valid"] is False
    assert any("checksum proof is required" in issue for issue in report["issues"])
    assert any("gateway allowlist proof is required" in issue for issue in report["issues"])
    assert report["recordCounts"]["publicReferenceShards"] == 1_000
    assert report["allowedClaims"] == []


def test_private_context_source_unit_fails_closed(tmp_path: Path):
    source_units = _source_units(source_record_count=1_000)
    source_units["sourceUnits"][0]["privateContextAllowed"] = True
    source_units_path = tmp_path / "source-units-private.json"
    write_json(source_units_path, source_units)

    report = compile_launch_floor_shard_corpus_bulk(
        _options(tmp_path / "private-context", source_units_path=source_units_path)
    )

    assert report["valid"] is False
    assert any("source unit must explicitly disallow private context" in issue for issue in report["issues"])
    assert report["allowedClaims"] == []


def _options(
    output_root: Path,
    *,
    source_units_path: Path | None = None,
    max_partition_shards: int = 100_000,
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
