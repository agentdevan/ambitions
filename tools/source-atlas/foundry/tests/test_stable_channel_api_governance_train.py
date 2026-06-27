from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.adapters import FetchResult, harvest_sources
from foundry.api_governance import DEFAULT_CONFIG_PATH, load_api_governance_config, validate_api_governance
from foundry.broad_occupational_foundation import (
    BROAD_OCCUPATIONAL_FOUNDATION_PATHWAY,
    run_stable_promote_proof,
)
from foundry.legal_readiness import write_legal_review_packet
from foundry.model import read_json, write_json
from foundry import r2_operations_proof
from foundry.registry import SOURCE_REGISTRY


def test_legal_review_packet_marks_outside_legal_approval_as_non_claim(tmp_path: Path):
    packet = write_legal_review_packet(tmp_path / "legal.md", tmp_path / "legal.json")

    assert (tmp_path / "legal.md").exists()
    assert (tmp_path / "legal.json").exists()
    assert packet["outsideLegalApprovalClaimed"] is False
    assert packet["outsideLegalApprovalStatus"] == "outside legal approval not claimed"
    assert "Owner-completed technical legal-readiness review; outside legal approval not claimed." == packet["status"]
    assert packet["ownerLegalReadinessReviewStatus"] == "completed_owner_acceptance"
    assert packet["illegalFindingsFound"] is False
    assert packet["illegalFindingsReconciled"] is True


def test_stable_promotion_refuses_execution_without_owner_approval(tmp_path: Path, monkeypatch):
    _disable_wrangler(monkeypatch)

    result = _stable_proof(tmp_path, dry_run=False, execute=True, env={})

    assert result["status"] == "Red"
    assert result["executed"] is False
    assert any("owner approval" in issue for issue in result["issues"])


def test_stable_promotion_refuses_restricted_review_required_records(tmp_path: Path, monkeypatch):
    _disable_wrangler(monkeypatch)

    def mutate(bundle_root: Path) -> None:
        manifest_path = bundle_root / "manifest.json"
        manifest = read_json(manifest_path)
        manifest["reviewStatus"] = "review-required"
        write_json(manifest_path, manifest)

    result = _stable_proof(tmp_path, post_build_mutator=mutate)

    assert result["status"] == "Red"
    assert any(check["name"] == "restricted_review_required_absent" and not check["passed"] for check in result["checks"])


def test_stable_promotion_refuses_usajobs_records(tmp_path: Path, monkeypatch):
    _disable_wrangler(monkeypatch)
    registry = _source_registry(["onet.database", "bls.public.data.api", "usajobs.search"])
    pathway = copy.deepcopy(BROAD_OCCUPATIONAL_FOUNDATION_PATHWAY)
    pathway["sourceIDs"] = ["onet.database", "bls.public.data.api", "usajobs.search"]

    result = _stable_proof(tmp_path, source_registry=registry, pathway=pathway)

    assert result["status"] == "Red"
    assert any(check["name"] == "usajobs_absent" and not check["passed"] for check in result["checks"])
    assert any(check["name"] == "terms_green" and not check["passed"] for check in result["checks"])


def test_stable_promotion_verifies_checksums_and_records_rollback_boundary(tmp_path: Path, monkeypatch):
    _disable_wrangler(monkeypatch)

    result = _stable_proof(tmp_path)

    assert result["status"] == "Yellow"
    assert any(check["name"] == "checksums" and check["passed"] for check in result["checks"])
    assert result["existingStableChannelPolicy"]["rollbackBoundaryPassed"] is True


def test_stable_promotion_fails_on_private_object_key(tmp_path: Path, monkeypatch):
    _disable_wrangler(monkeypatch)

    result = _stable_proof(tmp_path, stable_prefix="source-atlas/v1/private/users/broad-occupational-foundation")

    assert result["status"] == "Red"
    assert any(check["name"] == "object_key_privacy" and not check["passed"] for check in result["checks"])


def test_stable_promotion_fails_on_private_payload_manifest(tmp_path: Path, monkeypatch):
    _disable_wrangler(monkeypatch)

    def mutate(bundle_root: Path) -> None:
        manifest_path = bundle_root / "manifest.json"
        manifest = read_json(manifest_path)
        manifest["privateLifeGraph"] = {"goalText": "Private synthetic goal"}
        write_json(manifest_path, manifest)

    result = _stable_proof(tmp_path, post_build_mutator=mutate)

    assert result["status"] == "Red"
    assert any(check["name"] == "payload_manifest_privacy" and not check["passed"] for check in result["checks"])


def test_api_governance_rejects_missing_budget_config(tmp_path: Path):
    config = load_api_governance_config(DEFAULT_CONFIG_PATH)
    del config["adapters"]["official_openalex_api"]["requestBudget"]
    path = tmp_path / "bad-governance.json"
    write_json(path, config)

    result = validate_api_governance(path, env={})

    assert result["valid"] is False
    assert any("requestBudget" in issue for issue in result["issues"])


def test_api_governance_redacts_secret_values(tmp_path: Path):
    result = validate_api_governance(
        DEFAULT_CONFIG_PATH,
        env={"OPENALEX_API_KEY": "openalex-secret-value-12345", "DATAGOV_API_KEY": "data-gov-secret-value-12345"},
    )

    encoded = json.dumps(result)
    assert result["redaction"]["passed"], result["redaction"]
    assert "openalex-secret-value-12345" not in encoded
    assert "data-gov-secret-value-12345" not in encoded


def test_openalex_high_volume_run_requires_explicit_approval():
    result = validate_api_governance(DEFAULT_CONFIG_PATH, env={"SOURCE_ATLAS_OPENALEX_HIGH_VOLUME_REQUESTED": "true"})

    assert result["valid"] is False
    assert any("high-volume production run requested without explicit approval" in issue for issue in result["issues"])


def test_bls_v2_key_missing_does_not_block_v1_no_key_mode(tmp_path: Path):
    calls: list[str] = []

    def fetch(url: str, headers: dict[str, str] | None, max_bytes: int) -> FetchResult:
        calls.append(url)
        return fake_fetch(url, headers, max_bytes)

    governance = validate_api_governance(DEFAULT_CONFIG_PATH, env={})
    result = harvest_sources(tmp_path, "bls-no-key", source_ids=["bls.public.data.api"], fetcher=fetch, env={})

    assert governance["valid"], governance["issues"]
    assert result["harvestedCount"] == 1
    assert any("/publicAPI/v1/" in url for url in calls)


def test_wikidata_cannot_become_regulated_requirement_authority(tmp_path: Path):
    config = load_api_governance_config(DEFAULT_CONFIG_PATH)
    config["adapters"]["official_wikidata_entity_crosswalk"]["regulatedAuthorityAllowed"] = True
    path = tmp_path / "bad-wikidata.json"
    write_json(path, config)

    result = validate_api_governance(path, env={})

    assert result["valid"] is False
    assert any("regulated authority use must be false" in issue for issue in result["issues"])


def test_usajobs_remains_blocked_from_pack_and_r2_output():
    result = validate_api_governance(DEFAULT_CONFIG_PATH, env={})
    row = next(item for item in result["modeEvidence"] if item["adapterID"] == "official_usajobs_authenticated_search")

    assert result["valid"], result["issues"]
    assert row["packModeAllowed"] is False
    assert row["r2ModeAllowed"] is False


def test_wikidata_adapter_normalizes_crosswalk_only_records(tmp_path: Path):
    result = harvest_sources(
        tmp_path,
        "wikidata-live-shape",
        source_ids=["wikidata.structured_crosswalk"],
        limit=2,
        fetcher=fake_fetch,
        env={},
    )
    record = read_json(Path(result["runRoot"]) / "normalized" / "wikidata.structured_crosswalk.json")

    assert result["harvestedCount"] == 1
    assert record["freshnessSignals"]["regulatedAuthorityAllowed"] is False
    assert all(item["crosswalkOnly"] is True for item in record["records"])
    assert all(item["regulatedAuthorityAllowed"] is False for item in record["records"])


def test_openalex_adapter_records_rate_headers_and_redacts_key(tmp_path: Path):
    result = harvest_sources(
        tmp_path,
        "openalex-live-shape",
        source_ids=["openalex.works"],
        limit=2,
        fetcher=fake_fetch,
        env={"OPENALEX_API_KEY": "openalex-secret-value-12345", "OPENALEX_MAILTO": "source-atlas@example.org"},
    )
    record = read_json(Path(result["runRoot"]) / "normalized" / "openalex.works.json")
    encoded = json.dumps(record)

    assert result["harvestedCount"] == 1
    assert record["freshnessSignals"]["rateLimitHeaders"][0]["ratelimit-limit"] == "100"
    assert record["records"][0]["recordType"] == "openalex_work_metadata"
    assert "openalex-secret-value-12345" not in encoded
    assert "source-atlas@example.org" not in encoded
    assert "redacted" in encoded


def _stable_proof(
    tmp_path: Path,
    *,
    dry_run: bool = True,
    execute: bool = False,
    stable_prefix: str = "source-atlas/v1/stable/broad-occupational-foundation",
    env: dict[str, str] | None = None,
    source_registry: list[dict[str, object]] | None = None,
    pathway: dict[str, object] | None = None,
    post_build_mutator=None,
) -> dict[str, object]:
    return run_stable_promote_proof(
        dry_run=dry_run,
        execute=execute,
        bucket="ambitions-source-atlas-prod",
        source_prefix="source-atlas/v1/validation/amb-1430",
        stable_prefix=stable_prefix,
        require_owner_approval=True,
        require_terms_green=True,
        require_privacy_green=True,
        require_checksums=True,
        require_revocation=True,
        require_lkg=True,
        require_rollback=True,
        emit_evidence=tmp_path / "stable-promotion.json",
        env={} if env is None else env,
        source_registry=source_registry,
        pathway=pathway,
        post_build_mutator=post_build_mutator,
    )


def _source_registry(source_ids: list[str]) -> list[dict[str, object]]:
    lookup = {source["id"]: source for source in SOURCE_REGISTRY}
    return [lookup[source_id] for source_id in source_ids]


def _disable_wrangler(monkeypatch) -> None:
    monkeypatch.setattr(r2_operations_proof.shutil, "which", lambda _: None)


def fake_fetch(url: str, headers: dict[str, str] | None, max_bytes: int) -> FetchResult:
    del headers, max_bytes
    if "bls.gov" in url:
        return FetchResult(
            url,
            200,
            "application/json",
            b'{"status":"REQUEST_SUCCEEDED","message":[],"Results":{"series":[{"seriesID":"OEUN000000000000000000001","data":[{"year":"2025","period":"A01","value":"155495730"}]}]}}',
        )
    if "wikidata.org/w/api.php" in url:
        return FetchResult(
            url,
            200,
            "application/json",
            json.dumps(
                {
                    "search": [
                        {
                            "id": "Q12737077",
                            "label": "occupation",
                            "description": "profession or principal work role",
                        },
                        {
                            "id": "Q205961",
                            "label": "skill",
                            "description": "learned ability",
                        },
                    ]
                }
            ).encode("utf-8"),
        )
    if "api.openalex.org/works" in url:
        return FetchResult(
            url,
            200,
            "application/json",
            json.dumps(
                {
                    "results": [
                        {
                            "id": "https://openalex.org/W123",
                            "display_name": "Occupational skill requirements in public metadata",
                            "publication_year": 2025,
                            "type": "article",
                            "cited_by_count": 3,
                            "ids": {"doi": "https://doi.org/10.0000/example"},
                            "primary_location": {"source": {"display_name": "Example Journal"}},
                            "open_access": {"is_oa": True},
                        }
                    ]
                }
            ).encode("utf-8"),
            headers={
                "ratelimit-limit": "100",
                "ratelimit-remaining": "99",
                "ratelimit-reset": "60",
            },
        )
    raise AssertionError(f"unexpected fake fetch URL: {url}")
