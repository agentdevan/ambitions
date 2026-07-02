from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.governance_registry import (
    API_GOVERNANCE_REGISTRY_PATH,
    LEGAL_TERMS_REGISTRY_PATH,
    SOURCE_LANE_REGISTRY_PATH,
)
from foundry.launch_floor_domain_taxonomy import DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH
from foundry.launch_floor_shard_corpus_compiler import DEFAULT_PRODUCTION_TARGET_LEDGER_PATH
from foundry.launch_floor_governance_renewal import (
    LaunchFloorGovernanceRenewalOptions,
    compile_launch_floor_governance_renewal,
)
from foundry.model import read_json, write_json


CREATED_AT = "2026-07-01T00:00:00Z"


def test_launch_floor_governance_renewal_validates_source_legal_api_coverage(tmp_path: Path):
    result = compile_launch_floor_governance_renewal(_options(tmp_path))

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for launch-floor governance renewal tooling"
    assert result["launchFloorGovernanceRenewalMet"] is True
    assert result["recordCounts"]["launchSourceLanes"] == 15
    assert result["recordCounts"]["coveredLaunchDomains"] == 500
    assert result["recordCounts"]["coveredLaunchSubdomains"] == 5000
    assert result["recordCounts"]["apiPoliciesWithRenewalMetadata"] == result["recordCounts"]["apiPolicies"]
    assert result["recordCounts"]["outsideApprovalClaimsWithoutArtifacts"] == 0
    assert _check(result, "launch_domains_have_source_lane_coverage")
    assert _check(result, "launch_subdomains_have_source_lane_coverage")
    assert _check(result, "source_lane_legal_api_renewal_complete")
    assert "outside_legal_approval" in result["blockedClaims"]
    assert "source_atlas_launch_floor_ready" in result["blockedClaims"]

    coverage = read_json(Path(result["outputPaths"]["coverageMap"]))
    first = coverage["coverageRecords"][0]
    assert first["coveredDomainIDs"]
    assert first["coveredSubdomainIDs"]
    assert first["sourceRenewal"]["reviewOwner"]
    assert first["legalRenewal"]["reviewOwner"]
    assert first["apiRenewal"]["reviewOwner"]
    assert first["apiRenewal"]["nextReviewDueAt"]


def test_expired_source_lane_renewal_blocks_launch_governance_coverage(tmp_path: Path):
    source = copy.deepcopy(read_json(SOURCE_LANE_REGISTRY_PATH))
    lane = _source_lane(source, "bls.public.data.api")
    lane["next_review_due_at"] = "2026-06-01"
    source_path = tmp_path / "source-lane-registry.json"
    write_json(source_path, source)

    result = compile_launch_floor_governance_renewal(_options(tmp_path, source_lane_registry_path=source_path))

    assert not result["valid"]
    assert any("bls.public.data.api: expired source next_review_due_at 2026-06-01" in issue for issue in result["issues"])
    assert not _check(result, "source_lane_legal_api_renewal_complete")


def test_missing_api_renewal_metadata_blocks_launch_governance_coverage(tmp_path: Path):
    api = copy.deepcopy(read_json(API_GOVERNANCE_REGISTRY_PATH))
    policy = _api_policy(api, "api.bls_public_data.v1")
    del policy["next_review_due_at"]
    api_path = tmp_path / "api-governance-registry.json"
    write_json(api_path, api)

    result = compile_launch_floor_governance_renewal(_options(tmp_path, api_governance_registry_path=api_path))

    assert not result["valid"]
    assert any("api.bls_public_data.v1: missing API governance field next_review_due_at" in issue for issue in result["issues"])
    assert not _check(result, "governance_registries_valid")


def test_outside_legal_approval_requires_real_artifact(tmp_path: Path):
    legal = copy.deepcopy(read_json(LEGAL_TERMS_REGISTRY_PATH))
    entry = _legal_entry(legal, "bls_public_terms")
    entry["outside_legal_required"] = True
    entry["outside_legal_status"] = "approved"
    entry["approval_artifact_path"] = ""
    legal_path = tmp_path / "legal-terms-registry.json"
    write_json(legal_path, legal)

    result = compile_launch_floor_governance_renewal(_options(tmp_path, legal_terms_registry_path=legal_path))

    assert not result["valid"]
    assert any("outside legal approval claimed without artifact" in issue for issue in result["issues"])
    assert not _check(result, "governance_registries_valid")


def _options(
    tmp_path: Path,
    *,
    source_lane_registry_path: Path = SOURCE_LANE_REGISTRY_PATH,
    legal_terms_registry_path: Path = LEGAL_TERMS_REGISTRY_PATH,
    api_governance_registry_path: Path = API_GOVERNANCE_REGISTRY_PATH,
) -> LaunchFloorGovernanceRenewalOptions:
    return LaunchFloorGovernanceRenewalOptions(
        source_lane_registry_path=source_lane_registry_path,
        legal_terms_registry_path=legal_terms_registry_path,
        api_governance_registry_path=api_governance_registry_path,
        launch_floor_taxonomy_path=DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH,
        production_target_ledger_path=DEFAULT_PRODUCTION_TARGET_LEDGER_PATH,
        output_root=tmp_path / "governance-renewal",
        created_at=CREATED_AT,
        run_label="test",
    )


def _check(result: dict[str, object], name: str) -> bool:
    return next(check["passed"] for check in result["checks"] if check["name"] == name)


def _source_lane(registry: dict[str, object], source_id: str) -> dict[str, object]:
    return next(lane for lane in registry["source_lanes"] if lane["source_id"] == source_id)


def _legal_entry(registry: dict[str, object], license_id: str) -> dict[str, object]:
    return next(entry for entry in registry["licenses"] if entry["license_id"] == license_id)


def _api_policy(registry: dict[str, object], policy_id: str) -> dict[str, object]:
    return next(policy for policy in registry["api_policies"] if policy["api_policy_id"] == policy_id)
