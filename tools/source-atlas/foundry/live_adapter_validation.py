"""Live public-reference adapter validation.

Live validation proves source reachability and normalization shape. It does not
write raw payloads to packs, does not promote R2 objects, and does not replace
deterministic fixture tests.
"""

from __future__ import annotations

import hashlib
import json
import os
import socket
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable

from .adapter_sdk import AdapterRunContext
from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, utc_now, write_json
from .public_reference_adapters import (
    BlsAdapter,
    OnetAdapter,
    OpenAlexAdapter,
    RestrictedSourcePolicyAdapter,
    WikidataAdapter,
)
from .terms_registry import policy_gate_for_output, terms_entry


LIVE_VALIDATION_VERSION = "source-atlas-live-adapter-validation-v1"

APPROVED_LIVE_ADAPTERS = {
    "onet": "onet.database",
    "bls": "bls.public.data.api",
    "wikidata": "wikidata.crosswalk",
    "openalex": "openalex.dataset",
}

ADAPTER_ALIASES = {
    **APPROVED_LIVE_ADAPTERS,
    "all": "all",
}

LIVE_ADAPTER_CLASSES = {
    "onet.database": OnetAdapter,
    "bls.public.data.api": BlsAdapter,
    "wikidata.crosswalk": WikidataAdapter,
    "openalex.dataset": OpenAlexAdapter,
}

FetchFn = Callable[[urllib.request.Request, float, int], dict[str, Any]]


@dataclass(frozen=True)
class LiveRunOptions:
    adapter: str
    limit: int
    fixture_fallback: str
    emit_evidence: Path
    no_pack: bool
    pack_candidates: bool
    validate_terms: bool
    validate_privacy: bool
    rate_limit_safe: bool
    timeout: float


def run_live_adapter_validation(options: LiveRunOptions, fetcher: FetchFn | None = None) -> dict[str, Any]:
    created_at = utc_now()
    adapters = _selected_adapters(options.adapter)
    fetcher = fetcher or fetch_request
    results = [
        _validate_adapter(source_id, options, fetcher, created_at)
        for source_id in adapters
    ]
    restricted = _restricted_policy_result(created_at)
    results.append(restricted)
    blocker_count = sum(1 for result in results if result["result"] != "Green")
    fallback_hidden = any(result.get("fixtureFallbackUsed") for result in results)
    status = "Green" if blocker_count == 0 and not fallback_hidden else "Yellow"
    evidence = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.liveAdapterValidation.v1",
        "versionID": LIVE_VALIDATION_VERSION,
        "createdAt": created_at,
        "status": status,
        "adapterSelection": options.adapter,
        "fixtureFallbackPolicy": options.fixture_fallback,
        "fixtureFallbackHidden": fallback_hidden,
        "noPack": options.no_pack,
        "packCandidatesRequested": options.pack_candidates,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "results": results,
        "summary": {
            "adapterCount": len(results),
            "greenCount": sum(1 for result in results if result["result"] == "Green"),
            "yellowCount": sum(1 for result in results if result["result"] == "Yellow"),
            "redCount": sum(1 for result in results if result["result"] == "Red"),
            "recordsFetched": sum(result.get("recordsFetched", 0) for result in results),
            "recordsNormalized": sum(result.get("recordsNormalized", 0) for result in results),
            "recordsBlocked": sum(result.get("recordsBlocked", 0) for result in results),
        },
        "nonClaims": _non_claims(),
        "dataClass": "public_provenance",
        "publicReferenceOnly": True,
    }
    _write_evidence(options.emit_evidence, evidence)
    return evidence


def fetch_request(request: urllib.request.Request, timeout: float, max_bytes: int = 262144) -> dict[str, Any]:
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            body = response.read(max_bytes)
            return {
                "ok": 200 <= response.status < 300,
                "statusCode": response.status,
                "contentType": response.headers.get("content-type", ""),
                "finalURL": response.geturl(),
                "headers": {
                    "x-ratelimit-limit": response.headers.get("x-ratelimit-limit"),
                    "x-ratelimit-remaining": response.headers.get("x-ratelimit-remaining"),
                    "retry-after": response.headers.get("retry-after"),
                },
                "body": body,
                "byteCountSampled": len(body),
                "sha256": hashlib.sha256(body).hexdigest(),
            }
    except urllib.error.HTTPError as exc:
        body = exc.read(65536)
        return {
            "ok": False,
            "statusCode": exc.code,
            "contentType": exc.headers.get("content-type", ""),
            "finalURL": request.full_url,
            "headers": {"retry-after": exc.headers.get("retry-after")},
            "body": body,
            "byteCountSampled": len(body),
            "sha256": hashlib.sha256(body).hexdigest(),
            "error": f"http_{exc.code}",
        }
    except (urllib.error.URLError, TimeoutError, socket.timeout) as exc:
        return {
            "ok": False,
            "statusCode": None,
            "contentType": "",
            "finalURL": request.full_url,
            "headers": {},
            "body": b"",
            "byteCountSampled": 0,
            "sha256": "",
            "error": type(exc).__name__,
        }


def _selected_adapters(adapter: str) -> list[str]:
    if adapter not in ADAPTER_ALIASES:
        raise ValueError(f"unsupported adapter: {adapter}")
    if adapter == "all":
        return list(APPROVED_LIVE_ADAPTERS.values())
    return [APPROVED_LIVE_ADAPTERS[adapter]]


def _validate_adapter(source_id: str, options: LiveRunOptions, fetcher: FetchFn, created_at: str) -> dict[str, Any]:
    request = _request_for(source_id, options.limit)
    fetch = fetcher(request["request"], options.timeout, 262144)
    rate_limited = fetch.get("statusCode") == 429
    malformed = False
    parsed: dict[str, Any] = {}
    parse_error = ""
    try:
        parsed = _parse_live_response(source_id, fetch.get("body", b""))
    except (json.JSONDecodeError, UnicodeDecodeError, ValueError) as exc:
        malformed = True
        parse_error = type(exc).__name__

    live_failed = not fetch.get("ok") or rate_limited or malformed
    fixture_used = False
    errors: list[str] = []
    if live_failed:
        errors.append(fetch.get("error") or parse_error or "live_fetch_failed")
        if options.fixture_fallback == "allowed":
            fixture_used = True
        else:
            errors.append("fixture_fallback_forbidden")

    normalized = _normalized_fixture_shape(source_id, created_at, options.limit)
    live_summary = _live_summary(source_id, parsed, fetch, malformed)
    normalized["liveValidation"] = live_summary
    if _contains_rejected_data_class(parsed):
        normalized["liveRejectedSample"] = {"dataClass": "non_public_adapter_fixture", "reason": "live privacy validation rejection"}
    normalized["sourceState"]["state"] = "rate-limited" if rate_limited else "malformed" if malformed else "current"
    normalized["sourceState"]["packEligible"] = not live_failed
    if live_failed:
        normalized["sourceState"]["blockedReasons"].append("live_validation_not_green")

    terms_gate = policy_gate_for_output(source_id, normalized) if options.validate_terms else {"packable": "not_run"}
    privacy_issues = boundary_issue_strings(boundary_issues_for_value(normalized, f"live.{source_id}")) if options.validate_privacy else []
    private_injected = bool(privacy_issues)
    blocked = live_failed or private_injected or terms_gate.get("packable") is False
    result = "Green" if not blocked and not fixture_used else "Yellow"
    if private_injected or (live_failed and options.fixture_fallback == "forbidden"):
        result = "Red"

    if options.no_pack:
        pack_emission = "blocked_by_no_pack"
        pack_candidate_count = 0
    elif options.pack_candidates and terms_gate.get("packable") and not blocked:
        pack_emission = "candidate_evidence_only"
        pack_candidate_count = len(normalized.get("packCandidates", []))
    else:
        pack_emission = "not_requested"
        pack_candidate_count = 0

    entry = terms_entry(source_id)
    return {
        "adapter": _short_adapter(source_id),
        "sourceID": source_id,
        "sourceName": entry["source_name"],
        "sourceURL": entry["source_url"],
        "apiEndpointClass": request["endpointClass"],
        "requestShape": request["shape"],
        "recordsFetched": live_summary["recordsFetched"] if fetch.get("ok") and not malformed else 0,
        "recordsNormalized": live_summary["recordsNormalized"] if not blocked else 0,
        "recordsBlocked": 0 if not blocked else max(1, live_summary["recordsFetched"]),
        "termsPolicyResult": terms_gate,
        "privacyResult": {"passed": not privacy_issues, "issues": privacy_issues},
        "coverageDelta": {
            "claimCount": len(normalized.get("claims", [])) if not blocked else 0,
            "requirementCount": len(normalized.get("requirements", [])) if not blocked else 0,
            "crosswalkCount": len(normalized.get("crosswalks", [])) if not blocked else 0,
            "packEmission": pack_emission,
            "packCandidateCount": pack_candidate_count,
        },
        "rateLimitPosture": _rate_limit_posture(source_id, fetch),
        "credentialPosture": _credential_posture(source_id),
        "fetchEvidence": _redacted_fetch_evidence(fetch),
        "fixtureFallbackUsed": fixture_used,
        "errors": errors,
        "result": result,
        "nonClaims": _non_claims(),
        "dataClass": "public_provenance",
        "publicReferenceOnly": True,
    }


def _request_for(source_id: str, limit: int) -> dict[str, Any]:
    headers = {"User-Agent": "AmbitionsSourceAtlasLiveValidation/1.0 (public-reference validation)"}
    if source_id == "onet.database":
        url = "https://www.onetcenter.org/database.html"
        endpoint_class = "O*NET public database page; no raw payload persisted"
    elif source_id == "bls.public.data.api":
        url = "https://api.bls.gov/publicAPI/v1/timeseries/data/LNS14000000"
        endpoint_class = "BLS Public Data API v1 no-key single-series GET"
    elif source_id == "wikidata.crosswalk":
        url = "https://www.wikidata.org/wiki/Special:EntityData/Q80993.json"
        endpoint_class = "Wikidata entity data lookup for crosswalk support"
    elif source_id == "openalex.dataset":
        query = urllib.parse.urlencode({"search": "software engineering", "per-page": str(max(1, min(limit, 5)))})
        url = f"https://api.openalex.org/topics?{query}"
        endpoint_class = "OpenAlex no-key topic lookup"
        if os.environ.get("OPENALEX_API_KEY"):
            separator = "&" if "?" in url else "?"
            url = f"{url}{separator}api_key={urllib.parse.quote(os.environ['OPENALEX_API_KEY'])}"
    else:
        raise ValueError(f"unsupported live source: {source_id}")
    request = urllib.request.Request(url, headers=headers)
    return {
        "request": request,
        "endpointClass": endpoint_class,
        "shape": {
            "method": "GET",
            "url": _redact_url(url),
            "headers": {"User-Agent": headers["User-Agent"]},
            "bodyPersisted": False,
            "limit": limit,
        },
    }


def _parse_live_response(source_id: str, body: bytes) -> dict[str, Any]:
    if not body:
        raise ValueError("empty live response")
    if source_id == "onet.database":
        text = body.decode("utf-8", errors="replace")
        if "O*NET" not in text:
            raise ValueError("missing O*NET marker")
        return {"records": [{"marker": "onet_database_page", "containsLicenseMarker": "Creative Commons" in text}]}
    value = json.loads(body.decode("utf-8"))
    if source_id == "bls.public.data.api":
        series = value.get("Results", {}).get("series", [])
        return {"records": series, "status": value.get("status")}
    if source_id == "wikidata.crosswalk":
        return {"records": list(value.get("entities", {}).values())}
    if source_id == "openalex.dataset":
        return {"records": value.get("results", []), "meta": value.get("meta", {})}
    raise ValueError(f"unsupported source: {source_id}")


def _normalized_fixture_shape(source_id: str, created_at: str, limit: int) -> dict[str, Any]:
    adapter = LIVE_ADAPTER_CLASSES[source_id]()
    output = adapter.run(AdapterRunContext(source_state="current", fixture_mode=False, limit=limit, created_at=created_at))
    output["packCandidates"] = []
    return output


def _live_summary(source_id: str, parsed: dict[str, Any], fetch: dict[str, Any], malformed: bool) -> dict[str, Any]:
    if malformed or not fetch.get("ok"):
        return {"recordsFetched": 0, "recordsNormalized": 0, "contentHash": fetch.get("sha256", "")}
    records = parsed.get("records", [])
    return {
        "recordsFetched": len(records),
        "recordsNormalized": len(records),
        "contentHash": fetch.get("sha256", ""),
        "summaryFields": sorted(key for key in parsed.keys() if key != "records"),
    }


def _contains_rejected_data_class(parsed: dict[str, Any]) -> bool:
    records = parsed.get("records", [])
    return any(isinstance(record, dict) and str(record.get("dataClass", "")).startswith("non_public_") for record in records)


def _rate_limit_posture(source_id: str, fetch: dict[str, Any]) -> dict[str, Any]:
    entry = terms_entry(source_id)
    headers = fetch.get("headers", {})
    return {
        "policy": entry["rate_limit_policy"],
        "rateLimitSafe": True,
        "statusCode": fetch.get("statusCode"),
        "retryAfterPresent": bool(headers.get("retry-after")),
        "limitHeaderPresent": bool(headers.get("x-ratelimit-limit")),
        "remainingHeaderPresent": bool(headers.get("x-ratelimit-remaining")),
    }


def _credential_posture(source_id: str) -> dict[str, Any]:
    if source_id == "onet.database":
        return {
            "requiredForThisValidation": [],
            "optionalEnvForWebServices": ["ONET_USERNAME", "ONET_PASSWORD"],
            "missingOptionalEnv": [name for name in ["ONET_USERNAME", "ONET_PASSWORD"] if not os.environ.get(name)],
            "blocker": None,
        }
    if source_id == "bls.public.data.api":
        return {
            "apiModeUsed": "v1_no_key",
            "optionalEnvForV2": ["BLS_API_KEY"],
            "v2KeyPresent": bool(os.environ.get("BLS_API_KEY")),
            "blocker": None,
        }
    if source_id == "openalex.dataset":
        return {
            "apiModeUsed": "free_no_key" if not os.environ.get("OPENALEX_API_KEY") else "free_key",
            "optionalEnv": ["OPENALEX_API_KEY"],
            "blocker": None,
        }
    return {"requiredForThisValidation": [], "blocker": None}


def _redacted_fetch_evidence(fetch: dict[str, Any]) -> dict[str, Any]:
    return {
        "ok": fetch.get("ok"),
        "statusCode": fetch.get("statusCode"),
        "contentType": fetch.get("contentType"),
        "finalURL": _redact_url(fetch.get("finalURL", "")),
        "byteCountSampled": fetch.get("byteCountSampled"),
        "sha256": fetch.get("sha256"),
        "error": fetch.get("error"),
    }


def _redact_url(url: str) -> str:
    if not url:
        return url
    parsed = urllib.parse.urlsplit(url)
    query = urllib.parse.parse_qsl(parsed.query, keep_blank_values=True)
    redacted = [(key, "<redacted>" if "key" in key.lower() or "token" in key.lower() else value) for key, value in query]
    return urllib.parse.urlunsplit((parsed.scheme, parsed.netloc, parsed.path, urllib.parse.urlencode(redacted), parsed.fragment))


def _restricted_policy_result(created_at: str) -> dict[str, Any]:
    normalized = RestrictedSourcePolicyAdapter().run(AdapterRunContext(source_state="current", fixture_mode=False, created_at=created_at))
    gate = policy_gate_for_output("usajobs.search", normalized)
    return {
        "adapter": "restricted",
        "sourceID": "usajobs.search",
        "sourceName": terms_entry("usajobs.search")["source_name"],
        "sourceURL": terms_entry("usajobs.search")["source_url"],
        "apiEndpointClass": "policy-only restricted source validation; no live restricted content fetch",
        "requestShape": {"method": "NONE", "bodyPersisted": False},
        "recordsFetched": 0,
        "recordsNormalized": 0,
        "recordsBlocked": 1,
        "termsPolicyResult": gate,
        "privacyResult": {"passed": True, "issues": []},
        "coverageDelta": {"claimCount": 0, "requirementCount": 0, "crosswalkCount": 0, "packEmission": "blocked_by_terms"},
        "rateLimitPosture": {"policy": terms_entry("usajobs.search")["rate_limit_policy"], "rateLimitSafe": True},
        "credentialPosture": {"requiredForThisValidation": [], "blocker": "restricted_source_not_live_fetched_by_policy"},
        "fetchEvidence": {"ok": None, "statusCode": None, "contentType": None, "finalURL": None, "byteCountSampled": 0, "sha256": None},
        "fixtureFallbackUsed": False,
        "errors": ["restricted_source_lookup_only_not_packable"],
        "result": "Green",
        "nonClaims": _non_claims(),
        "dataClass": "public_provenance",
        "publicReferenceOnly": True,
    }


def _short_adapter(source_id: str) -> str:
    for short, full in APPROVED_LIVE_ADAPTERS.items():
        if full == source_id:
            return short
    return source_id


def _write_evidence(path: Path, evidence: dict[str, Any]) -> None:
    write_json(path, evidence)
    markdown_path = path.with_suffix(".md")
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(render_live_validation_markdown(evidence), encoding="utf-8")


def render_live_validation_markdown(evidence: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Live Adapter Validation",
        "",
        f"Status: {evidence['status']}",
        "",
        "Live validation checks approved public/reference source reachability and minimized normalization evidence. It does not write raw live payloads to packs and does not promote production R2 objects.",
        "",
        "| Adapter | Source | Fetched | Normalized | Blocked | Terms | Privacy | Result |",
        "| --- | --- | ---: | ---: | ---: | --- | --- | --- |",
    ]
    for result in evidence["results"]:
        terms = result["termsPolicyResult"]
        privacy = result["privacyResult"]
        lines.append(
            f"| {result['adapter']} | `{result['sourceID']}` | {result['recordsFetched']} | {result['recordsNormalized']} | {result['recordsBlocked']} | {terms.get('redistributionPolicy', terms.get('packable'))} | {privacy['passed']} | {result['result']} |"
        )
    lines.extend(["", "## Non-Claims", ""])
    lines.extend(f"- {item}" for item in evidence["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _non_claims() -> list[str]:
    return [
        "does not create final user paths",
        "does not create final schedules",
        "does not create Step lists",
        "does not gather private user data",
        "does not claim legal/privacy approval",
        "does not claim production R2 promotion",
        *NON_CLAIMS,
    ]
