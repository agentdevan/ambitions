from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.live_adapter_validation import ADAPTER_ALIASES, LiveRunOptions, run_live_adapter_validation
from foundry.model import read_json


SOURCE_ID = "official.statcan.table.13100974"


def test_statcan_live_transport_is_approved_and_no_pack_by_default(tmp_path: Path):
    def fetcher(request, _timeout, _max_bytes):
        body = b"<html>Shared Health Priorities - Electronic health information - Table 13-10-0974-01</html>"
        return {
            "ok": True,
            "statusCode": 200,
            "contentType": "text/html; charset=utf-8",
            "finalURL": request.full_url,
            "headers": {},
            "body": body,
            "byteCountSampled": len(body),
            "sha256": "statcan-live-fixture-hash",
        }

    evidence = run_live_adapter_validation(
        LiveRunOptions(
            adapter="statcan_table_13100974",
            limit=1,
            fixture_fallback="forbidden",
            emit_evidence=tmp_path / "statcan-live.json",
            no_pack=True,
            pack_candidates=False,
            validate_terms=True,
            validate_privacy=True,
            rate_limit_safe=True,
            timeout=1,
        ),
        fetcher=fetcher,
    )

    assert ADAPTER_ALIASES["statcan_table_13100974"] == SOURCE_ID
    assert evidence["status"] == "Green", evidence
    result = next(row for row in evidence["results"] if row["sourceID"] == SOURCE_ID)
    assert result["result"] == "Green"
    assert result["apiEndpointClass"] == "Statistics Canada public table HTML validation; no raw payload persisted"
    assert result["requestShape"]["bodyPersisted"] is False
    assert result["recordsFetched"] == 1
    assert result["recordsNormalized"] == 1
    assert result["coverageDelta"]["packEmission"] == "blocked_by_no_pack"
    assert result["coverageDelta"]["packCandidateCount"] == 0
    assert result["privacyResult"]["passed"]
    assert result["termsPolicyResult"]["packable"] is True
    assert "api_key" not in result["requestShape"]

    persisted = read_json(tmp_path / "statcan-live.json")
    assert persisted["summary"]["greenCount"] >= 2
    assert "does not claim production R2 promotion" in persisted["nonClaims"]


def test_statcan_live_transport_forbids_fixture_fallback(tmp_path: Path):
    def failing_fetcher(request, _timeout, _max_bytes):
        return {
            "ok": False,
            "statusCode": 503,
            "contentType": "text/html",
            "finalURL": request.full_url,
            "headers": {},
            "body": b"",
            "byteCountSampled": 0,
            "sha256": "",
            "error": "http_503",
        }

    evidence = run_live_adapter_validation(
        LiveRunOptions(
            adapter="statcan_table_13100974",
            limit=1,
            fixture_fallback="forbidden",
            emit_evidence=tmp_path / "statcan-live-failed.json",
            no_pack=True,
            pack_candidates=False,
            validate_terms=True,
            validate_privacy=True,
            rate_limit_safe=True,
            timeout=1,
        ),
        fetcher=failing_fetcher,
    )

    result = next(row for row in evidence["results"] if row["sourceID"] == SOURCE_ID)
    assert result["result"] == "Red"
    assert result["fixtureFallbackUsed"] is False
    assert "fixture_fallback_forbidden" in result["errors"]
