from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.catalog_transport import CatalogFetchResult, CatalogTransportOptions, run_catalog_transport
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"
PLAN_PATH = Path("tools/source-atlas/fixtures/catalog-transport/train-54-catalog-transport-plan.json")


def test_catalog_transport_fixture_mode_snapshots_and_discovers_candidates(tmp_path: Path):
    result = _run_fixture(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for live-gated catalog transport tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; live-gated public catalog transport tooling only"
    assert result["mode"] == "fixture"
    assert result["recordCounts"]["endpoints"] == 3
    assert result["recordCounts"]["snapshots"] == 3
    assert result["recordCounts"]["catalogs"] == 3
    assert result["recordCounts"]["candidateSources"] == 6
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "transport_emits_no_claims")
    assert _check(result, "snapshots_hash_verified")
    assert _check(result, "catalog_discovery_candidate_only")
    assert _check(result, "plan_privacy_scan_passed")
    assert _check(result, "request_privacy_scan_passed")
    assert result["discoveryManifestPath"]

    transport = read_json(Path(result["outputRoot"]) / "catalog-transport.json")
    entries = transport["transportEntries"]
    assert all(entry["status"] == "fetched" for entry in entries)
    assert all(entry["retrieval_method"] == "fixture_snapshot" for entry in entries)
    assert all(entry["sha256"] for entry in entries)
    assert all(entry["claim_authority_allowed"] is False for entry in entries)
    assert all(entry["pack_output_allowed"] is False for entry in entries)


def test_catalog_transport_dry_run_does_not_snapshot_or_discover(tmp_path: Path):
    result = run_catalog_transport(
        CatalogTransportOptions(
            plan_path=PLAN_PATH,
            output_root=tmp_path / "catalog-transport",
            mode="dry_run",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["snapshots"] == 0
    assert result["recordCounts"]["candidateSources"] == 0
    assert result["discoveryManifestPath"] is None
    transport = read_json(Path(result["outputRoot"]) / "catalog-transport.json")
    assert all(entry["status"] == "planned" for entry in transport["transportEntries"])


def test_catalog_transport_live_mode_requires_live_and_execute_flags(tmp_path: Path):
    result = run_catalog_transport(
        CatalogTransportOptions(
            plan_path=PLAN_PATH,
            output_root=tmp_path / "catalog-transport",
            mode="live",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "live_mode_requires_live_flag")
    assert not _check(result, "live_mode_requires_execute_flag")
    assert any("requires --live" in issue for issue in result["issues"])
    assert any("requires --execute" in issue for issue in result["issues"])


def test_catalog_transport_live_mode_can_fetch_with_injected_transport(tmp_path: Path):
    input_plan = tmp_path / "live-plan.json"
    write_json(
        input_plan,
        {
            "catalogEndpoints": [
                {
                    "endpoint_id": "injected-live-data-json",
                    "url": "https://catalog.example.gov/data.json",
                    "enabled": True,
                    "timeout_seconds": 5,
                    "max_bytes": 2000000,
                }
            ]
        },
    )
    payload_text = Path("tools/source-atlas/fixtures/catalog-discovery/train-53-catalogs/data-json-catalog.json").read_text(encoding="utf-8")

    result = run_catalog_transport(
        CatalogTransportOptions(
            plan_path=input_plan,
            output_root=tmp_path / "catalog-transport",
            mode="live",
            live=True,
            execute=True,
            created_at=CREATED_AT,
        ),
        fetcher=lambda _endpoint: CatalogFetchResult(
            status_code=200,
            content_type="application/json",
            body=payload_text,
            byte_size=len(payload_text.encode("utf-8")),
        ),
    )

    assert result["valid"], result["issues"]
    assert result["liveRequested"] is True
    assert result["executeRequested"] is True
    assert result["recordCounts"]["snapshots"] == 1
    assert result["recordCounts"]["catalogs"] == 1
    assert result["recordCounts"]["candidateSources"] == 2
    transport = read_json(Path(result["outputRoot"]) / "catalog-transport.json")
    assert transport["transportEntries"][0]["retrieval_method"] == "live_http_get"
    assert transport["transportEntries"][0]["sha256"]


def test_catalog_transport_redacts_public_contact_email_before_discovery(tmp_path: Path):
    input_plan = tmp_path / "live-plan.json"
    write_json(
        input_plan,
        {
            "catalogEndpoints": [
                {
                    "endpoint_id": "contact-redaction-live-data-json",
                    "url": "https://catalog.example.gov/data.json",
                    "enabled": True,
                    "timeout_seconds": 5,
                    "max_bytes": 2000000,
                }
            ]
        },
    )
    payload_text = """
    {
      "dataset": [
        {
          "title": "Public education metadata",
          "keyword": ["education"],
          "publisher": {"name": "Example Public Agency", "url": "https://example.gov/"},
          "landingPage": "https://example.gov/public-education-metadata",
          "license": "public domain",
          "terms_url": "https://example.gov/terms",
          "rights": "https://example.gov/terms",
          "maintainer_email": "public.contact@example.gov",
          "contact_point": "catalog.contact@example.gov",
          "creator_user_id": "12345678-private-looking-catalog-id",
          "distribution": [
            {
              "accessURL": "https://example.gov/table?pid=1310097401"
            }
          ]
        }
      ]
    }
    """

    result = run_catalog_transport(
        CatalogTransportOptions(
            plan_path=input_plan,
            output_root=tmp_path / "catalog-transport",
            mode="live",
            live=True,
            execute=True,
            created_at=CREATED_AT,
        ),
        fetcher=lambda _endpoint: CatalogFetchResult(
            status_code=200,
            content_type="application/json",
            body=payload_text,
            byte_size=len(payload_text.encode("utf-8")),
        ),
    )

    assert result["valid"], result["issues"]
    transport = read_json(Path(result["outputRoot"]) / "catalog-transport.json")
    entry = transport["transportEntries"][0]
    assert entry["public_contact_redaction_count"] == 4
    snapshot = read_json(Path(entry["snapshot_path"]))
    assert snapshot["dataset"][0]["maintainer_email"] == "[redacted-public-catalog-contact]"
    assert snapshot["dataset"][0]["contact_point"] == "[redacted-public-catalog-contact]"
    assert "creator_user_id" not in snapshot["dataset"][0]
    assert snapshot["dataset"][0]["redacted_public_catalog_identifier_3"] == "[redacted-public-catalog-identifier]"
    assert snapshot["dataset"][0]["distribution"][0]["accessURL"] == "https://example.gov/table?pid=redacted-public-id"


def test_catalog_transport_live_failure_reports_blocker_without_crashing(tmp_path: Path):
    input_plan = tmp_path / "live-plan.json"
    write_json(
        input_plan,
        {
            "catalogEndpoints": [
                {
                    "endpoint_id": "failing-live-data-json",
                    "url": "https://catalog.example.gov/data.json",
                    "enabled": True,
                    "timeout_seconds": 5,
                    "max_bytes": 2000000,
                }
            ]
        },
    )

    result = run_catalog_transport(
        CatalogTransportOptions(
            plan_path=input_plan,
            output_root=tmp_path / "catalog-transport",
            mode="live",
            live=True,
            execute=True,
            created_at=CREATED_AT,
        ),
        fetcher=lambda _endpoint: CatalogFetchResult(
            status_code=503,
            content_type="application/json",
            body='{"error":"unavailable"}',
            byte_size=len('{"error":"unavailable"}'),
        ),
    )

    assert not result["valid"]
    assert any("live fetch HTTP 503" in issue for issue in result["issues"])
    transport = read_json(Path(result["outputRoot"]) / "catalog-transport.json")
    assert transport["transportEntries"][0]["status"] == "blocked"
    assert "live fetch HTTP 503" in transport["transportEntries"][0]["blocking_reasons"]
    assert result["recordCounts"]["snapshots"] == 0


def test_catalog_transport_rejects_private_request_shape(tmp_path: Path):
    input_plan = tmp_path / "private-request-plan.json"
    write_json(
        input_plan,
        {
            "catalogEndpoints": [
                {
                    "endpoint_id": "private-request",
                    "url": "https://catalog.example.gov/data.json?goal_text=private",
                    "fixture_path": "tools/source-atlas/fixtures/catalog-discovery/train-53-catalogs/data-json-catalog.json",
                    "enabled": True,
                }
            ]
        },
    )

    result = run_catalog_transport(
        CatalogTransportOptions(
            plan_path=input_plan,
            output_root=tmp_path / "catalog-transport",
            mode="fixture",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "request_privacy_scan_passed")
    assert any("goal_text" in issue for issue in result["issues"])
    assert result["recordCounts"]["snapshots"] == 0


def test_catalog_transport_stable_fixture_ordering(tmp_path: Path):
    first = _run_fixture(tmp_path / "first")
    second = _run_fixture(tmp_path / "second")

    first_entries = read_json(Path(first["outputRoot"]) / "catalog-transport.json")["transportEntries"]
    second_entries = read_json(Path(second["outputRoot"]) / "catalog-transport.json")["transportEntries"]
    assert [entry["endpoint_id"] for entry in first_entries] == [entry["endpoint_id"] for entry in second_entries]
    assert [entry["sha256"] for entry in first_entries] == [entry["sha256"] for entry in second_entries]


def _run_fixture(tmp_path: Path) -> dict[str, object]:
    return run_catalog_transport(
        CatalogTransportOptions(
            plan_path=PLAN_PATH,
            output_root=tmp_path / "catalog-transport",
            mode="fixture",
            created_at=CREATED_AT,
        )
    )


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
