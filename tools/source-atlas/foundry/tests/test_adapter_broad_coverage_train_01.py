from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

import foundry.broad_occupational_foundation as broad_pack
from foundry.adapter_sdk import SOURCE_STATES, AdapterRunContext, SourceAdapter
from foundry.broad_occupational_foundation import build_broad_occupational_foundation, promote_broad_occupation_pack_proof
from foundry.green_reconciliation import build_green_reconciliation
from foundry.live_adapter_validation import LiveRunOptions, run_live_adapter_validation
from foundry.boundary import boundary_issues_for_value
from foundry.model import read_json
from foundry.public_reference_adapters import (
    BlsAdapter,
    OnetAdapter,
    OpenAlexAdapter,
    RestrictedSourcePolicyAdapter,
    WikidataAdapter,
    adapter_instances,
    emit_all_adapter_fixtures,
    run_all_adapters,
)
from foundry.terms_registry import policy_gate_for_output, terms_entry, validate_terms_registry


def test_adapter_sdk_contract_has_required_methods():
    required = [
        "discover",
        "fetch",
        "parse",
        "normalize",
        "validate_terms",
        "emit_provenance",
        "emit_coverage",
        "emit_fixtures",
        "emit_pack_candidates",
    ]
    for adapter in adapter_instances():
        assert isinstance(adapter, SourceAdapter)
        for method in required:
            assert callable(getattr(adapter, method))


def test_terms_registry_validation_and_distribution_policy_gate():
    result = validate_terms_registry()
    assert result["valid"], result["issues"]

    onet = OnetAdapter().run(AdapterRunContext(source_state="current", created_at="2026-06-27T00:00:00Z"))
    gate = policy_gate_for_output("onet.database", onet)
    assert gate["packable"], gate["issues"]
    assert gate["r2Ready"]

    restricted = RestrictedSourcePolicyAdapter().run(AdapterRunContext(source_state="current", created_at="2026-06-27T00:00:00Z"))
    restricted_gate = policy_gate_for_output("usajobs.search", restricted)
    assert not restricted_gate["packable"]
    assert "lookup_only_not_packable" in json.dumps(restricted_gate)


def test_onet_bls_wikidata_openalex_normalization_fixture_mode():
    adapters = [OnetAdapter(), BlsAdapter(), WikidataAdapter(), OpenAlexAdapter()]
    for adapter in adapters:
        output = adapter.run(AdapterRunContext(source_state="current", created_at="2026-06-27T00:00:00Z"))
        assert output["sourceID"] == adapter.source_id
        assert output["claims"]
        assert output["provenance"]
        assert output["coverage"]["claimCount"] == len(output["claims"])
        assert all(claim["sourceID"] == adapter.source_id for claim in output["claims"])
        assert all(claim["sourceURL"] and claim["publisher"] and claim["licenseTermsReference"] for claim in output["claims"])
        assert all(claim["authorityTier"] in {terms_entry(adapter.source_id)["authority_tier"]} for claim in output["claims"])
        assert output["termsValidation"]["packable"], output["termsValidation"]


def test_bls_distinguishes_v1_no_key_from_v2_key_required_without_secrets():
    output = BlsAdapter().run(AdapterRunContext(source_state="current", created_at="2026-06-27T00:00:00Z"))
    assert output["apiLanes"]["v1"] == "no_key_public_requests"
    assert output["apiLanes"]["v2"] == "registration_key_required_for_higher_limits"
    assert output["apiLanes"]["fixtureTestsRequireCredentials"] is False
    assert "SECRET" not in json.dumps(output).upper()


def test_wikidata_crosswalk_preserves_ambiguity_and_routes_conflicts_to_review():
    output = WikidataAdapter().run(AdapterRunContext(source_state="conflicted", created_at="2026-06-27T00:00:00Z"))
    conflicted = [item for item in output["crosswalks"] if item["confidence"] == "conflicted"]
    assert conflicted
    assert all(item["ambiguityPreserved"] for item in output["crosswalks"])
    assert all(item["silentWinnerSelectionAllowed"] is False for item in output["crosswalks"])
    assert all(item["reviewRequired"] for item in conflicted)


def test_openalex_snapshot_route_is_offline_and_api_key_optional():
    output = OpenAlexAdapter().run(AdapterRunContext(source_state="current", created_at="2026-06-27T00:00:00Z"))
    assert output["offlineBulkOption"]["represented"] is True
    assert output["offlineBulkOption"]["fixtureTestsRequireCredentials"] is False


def test_source_state_fixtures_cover_safe_failure(tmp_path: Path):
    manifest = emit_all_adapter_fixtures(tmp_path)
    assert manifest["fixtureCount"] == len(adapter_instances()) * len(SOURCE_STATES)
    for adapter in adapter_instances():
        for state in SOURCE_STATES:
            fixture = read_json(tmp_path / adapter.source_id / f"{state}.json")
            payload = fixture["payload"]
            assert payload["sourceState"]["state"] == state
            if state in {"revoked", "stale-critical", "conflicted", "terms-blocked", "missing-provenance"}:
                assert payload["packCandidates"] == []
            if state == "private-field-injected":
                assert fixture["expectedValid"] is False
                assert fixture["expectedIssueCodes"] == ["unsupported_data_class"]
                assert boundary_issues_for_value(payload, "payload")


def test_broad_occupational_foundation_pack_generation(tmp_path: Path):
    output_root = tmp_path / "generated"
    docs_root = tmp_path / "docs"
    result = build_broad_occupational_foundation(output_root, docs_root)
    assert result["valid"], result

    manifest = read_json(Path(result["manifestPath"]))
    normalized = read_json(Path(result["packRoot"]) / "normalized-records.json")
    review = read_json(docs_root / "source-atlas-review-queue.json")
    evidence = read_json(docs_root / "adapter-broad-coverage-train-01.json")

    assert manifest["productionR2Uploaded"] is False
    assert "occupation taxonomy" in normalized["domains"]
    assert normalized["claims"]
    assert normalized["requirements"]
    assert normalized["crosswalks"]
    assert not any(
        record.get("sourceID") == "usajobs.search"
        for collection in ["claims", "requirements", "provenance", "atoms", "edges", "crosswalks", "packCandidates"]
        for record in normalized.get(collection, [])
        if isinstance(record, dict)
    )
    terms = read_json(Path(result["packRoot"]) / "license-terms-slice.json")
    assert "usajobs.search" not in {source["source_id"] for source in terms["sources"]}
    assert review["itemCount"] > 0
    assert evidence["crosswalkCounts"] == len(normalized["crosswalks"])


def test_no_false_completion_and_no_private_graph_in_outputs(tmp_path: Path):
    outputs = run_all_adapters("current", created_at="2026-06-27T00:00:00Z")
    encoded = json.dumps(outputs)
    forbidden_terms = ["Synthetic private regression marker", "non_public_personal_payload"]
    for term in forbidden_terms:
        assert term not in encoded
    assert all(candidate["doesNotStoreFinalUserPath"] for output in outputs for candidate in output.get("packCandidates", []))
    assert all(candidate["doesNotCreateFinalSchedule"] for output in outputs for candidate in output.get("packCandidates", []))

    stale = OnetAdapter().run(AdapterRunContext(source_state="stale-critical", created_at="2026-06-27T00:00:00Z"))
    revoked = OnetAdapter().run(AdapterRunContext(source_state="revoked", created_at="2026-06-27T00:00:00Z"))
    missing_provenance = OnetAdapter().run(AdapterRunContext(source_state="missing-provenance", created_at="2026-06-27T00:00:00Z"))
    assert stale["packCandidates"] == []
    assert revoked["packCandidates"] == []
    assert missing_provenance["packCandidates"] == []
    assert stale["coverage"]["staleCriticalClaims"] >= 0

    result = build_broad_occupational_foundation(tmp_path / "generated", tmp_path / "docs")
    manifest_text = Path(result["manifestPath"]).read_text(encoding="utf-8")
    assert "Synthetic private regression marker" not in manifest_text
    assert "non_public_personal_payload" not in manifest_text


def test_live_adapter_validation_forbids_silent_fixture_fallback(tmp_path: Path):
    def failing_fetcher(_request, _timeout, _max_bytes):
        return {
            "ok": False,
            "statusCode": None,
            "contentType": "",
            "finalURL": "https://api.bls.gov/publicAPI/v1/timeseries/data/LNS14000000",
            "headers": {},
            "body": b"",
            "byteCountSampled": 0,
            "sha256": "",
            "error": "network_unavailable",
        }

    evidence = run_live_adapter_validation(
        LiveRunOptions(
            adapter="bls",
            limit=1,
            fixture_fallback="forbidden",
            emit_evidence=tmp_path / "live.json",
            no_pack=True,
            pack_candidates=False,
            validate_terms=True,
            validate_privacy=True,
            rate_limit_safe=True,
            timeout=1,
        ),
        fetcher=failing_fetcher,
    )
    bls = next(result for result in evidence["results"] if result["sourceID"] == "bls.public.data.api")
    assert bls["result"] == "Red"
    assert bls["fixtureFallbackUsed"] is False
    assert "fixture_fallback_forbidden" in bls["errors"]


def test_live_adapter_validation_normalizes_mocked_public_sources(tmp_path: Path):
    bodies = {
        "www.onetcenter.org": b"<html>O*NET Database Creative Commons</html>",
        "api.bls.gov": json.dumps({"status": "REQUEST_SUCCEEDED", "Results": {"series": [{"seriesID": "LNS14000000"}]}}).encode(),
        "www.wikidata.org": json.dumps({"entities": {"Q80993": {"id": "Q80993", "labels": {"en": {"value": "software engineer"}}}}}).encode(),
        "api.openalex.org": json.dumps({"meta": {"count": 1}, "results": [{"id": "https://openalex.org/T10860", "display_name": "Software engineering"}]}).encode(),
    }

    def fetcher(request, _timeout, _max_bytes):
        host = request.host
        body = bodies[host]
        return {
            "ok": True,
            "statusCode": 200,
            "contentType": "application/json",
            "finalURL": request.full_url,
            "headers": {},
            "body": body,
            "byteCountSampled": len(body),
            "sha256": "fixture-hash",
        }

    evidence = run_live_adapter_validation(
        LiveRunOptions(
            adapter="all",
            limit=1,
            fixture_fallback="forbidden",
            emit_evidence=tmp_path / "live.json",
            no_pack=True,
            pack_candidates=False,
            validate_terms=True,
            validate_privacy=True,
            rate_limit_safe=True,
            timeout=1,
        ),
        fetcher=fetcher,
    )
    assert evidence["status"] == "Green", evidence
    assert evidence["summary"]["recordsFetched"] >= 4
    assert all(not result["fixtureFallbackUsed"] for result in evidence["results"])


def test_live_adapter_validation_handles_malformed_rate_limited_and_rejected_data_class(tmp_path: Path):
    def malformed_fetcher(request, _timeout, _max_bytes):
        return {
            "ok": True,
            "statusCode": 200,
            "contentType": "application/json",
            "finalURL": request.full_url,
            "headers": {},
            "body": b"{not-json",
            "byteCountSampled": 9,
            "sha256": "bad",
        }

    malformed = run_live_adapter_validation(
        LiveRunOptions("bls", 1, "forbidden", tmp_path / "malformed.json", True, False, True, True, True, 1),
        fetcher=malformed_fetcher,
    )
    assert next(result for result in malformed["results"] if result["adapter"] == "bls")["result"] == "Red"

    def limited_fetcher(request, _timeout, _max_bytes):
        return {
            "ok": False,
            "statusCode": 429,
            "contentType": "application/json",
            "finalURL": request.full_url,
            "headers": {"retry-after": "60"},
            "body": b"{}",
            "byteCountSampled": 2,
            "sha256": "limited",
            "error": "http_429",
        }

    limited = run_live_adapter_validation(
        LiveRunOptions("openalex", 1, "forbidden", tmp_path / "limited.json", True, False, True, True, True, 1),
        fetcher=limited_fetcher,
    )
    assert next(result for result in limited["results"] if result["adapter"] == "openalex")["result"] == "Red"

    def rejected_fetcher(request, _timeout, _max_bytes):
        body = json.dumps({"status": "REQUEST_SUCCEEDED", "Results": {"series": [{"dataClass": "non_public_adapter_fixture"}]}}).encode()
        return {
            "ok": True,
            "statusCode": 200,
            "contentType": "application/json",
            "finalURL": request.full_url,
            "headers": {},
            "body": body,
            "byteCountSampled": len(body),
            "sha256": "reject",
        }

    rejected = run_live_adapter_validation(
        LiveRunOptions("bls", 1, "forbidden", tmp_path / "rejected.json", True, False, True, True, True, 1),
        fetcher=rejected_fetcher,
    )
    result = next(row for row in rejected["results"] if row["adapter"] == "bls")
    assert result["result"] == "Red"
    assert result["privacyResult"]["issues"]


def test_broad_pack_promotion_proof_dry_run_and_terms_refusal(tmp_path: Path):
    generated = tmp_path / "generated"
    docs = tmp_path / "docs"
    result = build_broad_occupational_foundation(generated, docs)
    proof = promote_broad_occupation_pack_proof(
        Path(result["packRoot"]),
        dry_run=True,
        r2_validation_prefix="source-atlas/v1/validation/adapter-train-01",
        require_terms_green=True,
        require_privacy_green=True,
        require_checksums=True,
        require_revocation=True,
        require_lkg=True,
        emit_evidence=docs / "promotion.json",
    )
    assert proof["status"] == "Green", proof["issues"]
    assert proof["gates"]["productionR2Uploaded"] is False

    normalized_path = Path(result["packRoot"]) / "normalized-records.json"
    normalized = read_json(normalized_path)
    normalized["packCandidates"].append({"sourceID": "usajobs.search", "termsGate": {"packable": False, "r2Ready": False}})
    normalized_path.write_text(json.dumps(normalized, indent=2), encoding="utf-8")
    blocked = promote_broad_occupation_pack_proof(
        Path(result["packRoot"]),
        dry_run=True,
        r2_validation_prefix="source-atlas/v1/validation/adapter-train-01",
        require_terms_green=True,
        require_privacy_green=True,
        require_checksums=True,
        require_revocation=True,
        require_lkg=True,
        emit_evidence=docs / "blocked-promotion.json",
    )
    assert blocked["status"] == "Red"
    assert any("USAJOBS" in issue or "restricted" in issue for issue in blocked["issues"])


def test_broad_pack_promotion_proof_upload_requires_explicit_confirmation_and_verifies_readback(tmp_path: Path, monkeypatch):
    result = build_broad_occupational_foundation(tmp_path / "generated", tmp_path / "docs")
    blocked = promote_broad_occupation_pack_proof(
        Path(result["packRoot"]),
        dry_run=False,
        r2_validation_prefix="source-atlas/v1/validation/amb-1430",
        require_terms_green=True,
        require_privacy_green=True,
        require_checksums=True,
        require_revocation=True,
        require_lkg=True,
        emit_evidence=tmp_path / "docs" / "blocked-upload.json",
        execute=True,
        bucket="ambitions-source-atlas-prod",
        channel="validation",
        confirm_public_reference_only=False,
    )
    assert blocked["status"] == "Red"
    assert "production upload requires --confirm-public-reference-only" in blocked["issues"]

    uploaded: dict[str, bytes] = {}

    def fake_run_wrangler(args):
        command = args[:4]
        object_ref = args[4]
        if command == ["wrangler", "r2", "object", "put"]:
            path = Path(args[args.index("--file") + 1])
            uploaded[object_ref] = path.read_bytes()
            return {"success": True, "returnCode": 0, "stdout": "Upload complete.", "stderr": ""}
        if command == ["wrangler", "r2", "object", "get"]:
            destination = Path(args[args.index("--file") + 1])
            destination.write_bytes(uploaded[object_ref])
            return {"success": True, "returnCode": 0, "stdout": "Download complete.", "stderr": ""}
        return {"success": False, "returnCode": 1, "stdout": "", "stderr": "unexpected command"}

    monkeypatch.setattr(broad_pack, "_run_wrangler", fake_run_wrangler)
    proof = promote_broad_occupation_pack_proof(
        Path(result["packRoot"]),
        dry_run=False,
        r2_validation_prefix="source-atlas/v1/validation/amb-1430",
        require_terms_green=True,
        require_privacy_green=True,
        require_checksums=True,
        require_revocation=True,
        require_lkg=True,
        emit_evidence=tmp_path / "docs" / "upload.json",
        execute=True,
        bucket="ambitions-source-atlas-prod",
        channel="validation",
        readback_root=tmp_path / "readback",
        confirm_public_reference_only=True,
    )
    assert proof["status"] == "Green", proof["issues"]
    assert proof["gates"]["productionR2Uploaded"] is True
    assert proof["readbackChecksumResult"]["success"] is True
    assert proof["rollbackSelectResult"]["selected"] == "candidate"


def test_coverage_ledger_scenario_gaps_are_not_completion_ready(tmp_path: Path):
    result = build_broad_occupational_foundation(tmp_path / "generated", tmp_path / "docs")
    coverage = read_json(Path(result["packRoot"]) / "coverage-report.json")
    scenarios = coverage["scenarioOverlay"]
    assert scenarios
    assert all(row["completionReady"] is False for row in scenarios)
    regulated = {row["scenario"]: row for row in scenarios if row["reviewRequired"]}
    assert "nurse" in regulated
    assert "FAA" in next(row for row in scenarios if row["scenario"] == "pilot")["officialSourceGap"]


def test_green_reconciliation_stays_yellow_without_owner_review_or_upload(tmp_path: Path):
    generated = tmp_path / "generated"
    docs = tmp_path / "docs"
    result = build_broad_occupational_foundation(generated, docs)
    live = {
        "status": "Green",
        "summary": {"recordsFetched": 4, "recordsNormalized": 4},
        "fixtureFallbackHidden": False,
        "results": [],
    }
    promotion = {"status": "Green", "r2ProofResult": "dry_run_only_no_upload", "issues": []}
    terms = {"status": "Yellow", "ownerReviewComplete": False, "blockedSources": ["usajobs.search"]}
    production = {"status": "Green", "greenScope": "Source Atlas Production R2 Operations Proof only"}
    (docs / "live.json").write_text(json.dumps(live), encoding="utf-8")
    (docs / "promotion.json").write_text(json.dumps(promotion), encoding="utf-8")
    (docs / "terms.json").write_text(json.dumps(terms), encoding="utf-8")
    (docs / "production.json").write_text(json.dumps(production), encoding="utf-8")
    ledger = {
        "broadOccupationalFoundation": {
            "scenario_coverage": read_json(Path(result["packRoot"]) / "coverage-report.json")["scenarioOverlay"]
        }
    }
    (docs / "ledger.json").write_text(json.dumps(ledger), encoding="utf-8")
    reconciliation = build_green_reconciliation(
        docs / "reconciliation.json",
        live_evidence_path=docs / "live.json",
        terms_review_path=docs / "terms.json",
        coverage_ledger_path=docs / "ledger.json",
        promotion_proof_path=docs / "promotion.json",
        production_r2_proof_path=docs / "production.json",
    )
    assert reconciliation["status"] == "Yellow"
    assert any(row["yellowCause"] == "Terms not owner-reviewed" and row["result"] == "Yellow" for row in reconciliation["yellowCauseRows"])
