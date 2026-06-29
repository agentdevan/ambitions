from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.governance_registry import (
    API_GOVERNANCE_REGISTRY_PATH,
    LEGAL_TERMS_REGISTRY_PATH,
    SOURCE_LANE_REGISTRY_PATH,
    validate_governance_registries,
)
from foundry.model import read_json, write_json


def test_governance_registries_validate_train_01_contract():
    result = validate_governance_registries()

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governance tooling"
    assert result["statusCeiling"] == "Yellow overall Source Atlas; governance tooling only"
    assert _check(result, "source_lane_registry_schema_exists")
    assert _check(result, "legal_terms_registry_schema_exists")
    assert _check(result, "api_governance_registry_schema_exists")
    assert _check(result, "wikidata_crosswalk_only")
    assert _check(result, "openalex_high_volume_gated")
    assert _check(result, "bls_v1_v2_modes_represented")
    assert _check(result, "usajobs_r2_pack_blocked")
    assert _check(result, "private_r2_key_validation")
    assert _check(result, "no_final_plan_schedule_step_output")
    assert "not full Source Atlas Green" in result["nonClaims"]
    assert "not production R2 readiness" in result["nonClaims"]


def test_missing_legal_terms_posture_blocks_pack_output(tmp_path: Path):
    source_lanes = _source_lanes()
    onet = _lane(source_lanes, "onet.database")
    onet["terms_url"] = ""

    source_path = tmp_path / "source-lanes.json"
    write_json(source_path, source_lanes)

    result = validate_governance_registries(source_lane_path=source_path)

    assert not result["valid"]
    assert any("onet.database: missing source lane field terms_url" in issue for issue in result["issues"])


def test_missing_api_policy_blocks_governed_source_lane(tmp_path: Path):
    source_lanes = _source_lanes()
    _lane(source_lanes, "bls.public.data.api")["api_policy_id"] = "api.missing_policy.v1"

    source_path = tmp_path / "source-lanes.json"
    write_json(source_path, source_lanes)

    result = validate_governance_registries(source_lane_path=source_path)

    assert not result["valid"]
    assert any("bls.public.data.api: missing API governance policy api.missing_policy.v1" in issue for issue in result["issues"])


def test_wikidata_cannot_become_regulated_requirement_authority(tmp_path: Path):
    source_lanes = _source_lanes()
    wikidata = _lane(source_lanes, "wikidata.crosswalk")
    wikidata["regulated_authority_allowed"] = True
    wikidata["claim_classes_allowed"].append("regulated_requirement_authority")

    source_path = tmp_path / "source-lanes.json"
    write_json(source_path, source_lanes)

    result = validate_governance_registries(source_lane_path=source_path)

    assert not result["valid"]
    assert any("Wikidata regulated authority use must be false" in issue for issue in result["issues"])
    assert any("Wikidata must stay crosswalk-only" in issue for issue in result["issues"])


def test_catalog_discovery_source_cannot_become_claim_authority(tmp_path: Path):
    source_lanes = _source_lanes()
    datagov = _lane(source_lanes, "data.gov.catalog")
    datagov["claim_classes_allowed"].append("public_requirement")
    datagov["r2_pack_policy"] = "pack_allowed"
    datagov["r2_object_key_prefix"] = "source-atlas/v1/stable/public-catalog"

    source_path = tmp_path / "source-lanes.json"
    write_json(source_path, source_lanes)

    result = validate_governance_registries(source_lane_path=source_path)

    assert not result["valid"]
    assert any("catalog/discovery source cannot become claim authority" in issue for issue in result["issues"])
    assert any("catalog/discovery source cannot be R2 pack allowed" in issue for issue in result["issues"])


def test_usajobs_restricted_data_stays_blocked_from_r2_pack_output(tmp_path: Path):
    source_lanes = _source_lanes()
    usajobs = _lane(source_lanes, "usajobs.search")
    usajobs["r2_pack_policy"] = "pack_allowed"
    usajobs["redistribution_policy"] = "redistributable"
    usajobs["r2_object_key_prefix"] = "source-atlas/v1/stable/federal-job-reference"

    source_path = tmp_path / "source-lanes.json"
    write_json(source_path, source_lanes)

    result = validate_governance_registries(source_lane_path=source_path)

    assert not result["valid"]
    assert any("USAJOBS must be blocked from R2-packable output" in issue for issue in result["issues"])
    assert any("USAJOBS redistribution_policy must be lookup_only" in issue for issue in result["issues"])


def test_private_looking_r2_object_key_fails_validation(tmp_path: Path):
    source_lanes = _source_lanes()
    _lane(source_lanes, "onet.database")["r2_object_key_prefix"] = "source-atlas/v1/stable/users/private-goal-pack"

    source_path = tmp_path / "source-lanes.json"
    write_json(source_path, source_lanes)

    result = validate_governance_registries(source_lane_path=source_path)

    assert not result["valid"]
    assert any("private_r2_object_key_segment" in issue for issue in result["issues"])


def test_openalex_high_volume_requires_key_budget_and_approval_artifact(tmp_path: Path):
    api_governance = _api_governance()
    openalex = _api_policy(api_governance, "api.openalex_api.v1")
    openalex["high_volume_policy"]["key_required_for_high_volume"] = False
    openalex["high_volume_policy"]["approval_artifact_required"] = False
    openalex["high_volume_policy"]["budget_policy_id"] = ""

    api_path = tmp_path / "api-governance.json"
    write_json(api_path, api_governance)

    result = validate_governance_registries(api_governance_path=api_path)

    assert not result["valid"]
    assert any("OpenAlex high-volume use must require API key" in issue for issue in result["issues"])
    assert any("OpenAlex high-volume use must require approval artifact" in issue for issue in result["issues"])
    assert any("OpenAlex high-volume use must declare budget policy" in issue for issue in result["issues"])


def test_bls_v1_no_key_and_v2_key_mode_are_required(tmp_path: Path):
    api_governance = _api_governance()
    bls = _api_policy(api_governance, "api.bls_public_data.v1")
    bls["v1_no_key_mode"]["allowed"] = False
    bls["v2_key_mode"]["env_var_name"] = "WRONG_KEY"

    api_path = tmp_path / "api-governance.json"
    write_json(api_path, api_governance)

    result = validate_governance_registries(api_governance_path=api_path)

    assert not result["valid"]
    assert any("BLS v1 no-key mode must be allowed" in issue for issue in result["issues"])
    assert any("BLS v2 key mode must be optional and gated by BLS_API_KEY" in issue for issue in result["issues"])


def _check(result: dict[str, object], name: str) -> bool:
    return next(check["passed"] for check in result["checks"] if check["name"] == name)


def _source_lanes() -> dict[str, object]:
    return copy.deepcopy(read_json(SOURCE_LANE_REGISTRY_PATH))


def _api_governance() -> dict[str, object]:
    return copy.deepcopy(read_json(API_GOVERNANCE_REGISTRY_PATH))


def _lane(registry: dict[str, object], source_id: str) -> dict[str, object]:
    return next(lane for lane in registry["source_lanes"] if lane["source_id"] == source_id)


def _api_policy(registry: dict[str, object], policy_id: str) -> dict[str, object]:
    return next(policy for policy in registry["api_policies"] if policy["api_policy_id"] == policy_id)
