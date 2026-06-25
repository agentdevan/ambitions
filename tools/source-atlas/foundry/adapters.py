"""Official-source harvest adapters for Source Atlas Foundry."""

from __future__ import annotations

import csv
import html
import io
import json
import os
import re
import urllib.error
import urllib.parse
import urllib.request
import zipfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable, Optional

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, privacy_findings_for_value, utc_now, write_json
from .registry import PATHWAY_SEEDS, SOURCE_REGISTRY


ADAPTER_VERSION = "source-atlas-foundry-adapters-v1"
DEFAULT_USER_AGENT = "AmbitionsSourceAtlasFoundry/1.0 public-reference-only"
DEFAULT_TIMEOUT_SECONDS = int(os.environ.get("SOURCE_ATLAS_FETCH_TIMEOUT_SECONDS", "120"))
DEFAULT_MAX_BYTES = 8 * 1024 * 1024
ONET_MAX_BYTES = 80 * 1024 * 1024

Fetcher = Callable[[str, Optional[dict[str, str]], int], "FetchResult"]


@dataclass(frozen=True)
class FetchResult:
    url: str
    status: int
    content_type: str
    body: bytes


def default_fetch(url: str, headers: dict[str, str] | None = None, max_bytes: int = DEFAULT_MAX_BYTES) -> FetchResult:
    request_headers = {"User-Agent": os.environ.get("SOURCE_ATLAS_USER_AGENT", DEFAULT_USER_AGENT)}
    if headers:
        request_headers.update(headers)
    request = urllib.request.Request(url, headers=request_headers)
    with urllib.request.urlopen(request, timeout=DEFAULT_TIMEOUT_SECONDS) as response:
        chunks: list[bytes] = []
        total = 0
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            total += len(chunk)
            if total > max_bytes:
                raise ValueError(f"response exceeds max byte budget for {url}: {max_bytes}")
            chunks.append(chunk)
        body = b"".join(chunks)
        content_length = response.headers.get("content-length")
        if content_length and content_length.isdigit() and int(content_length) != len(body):
            raise ValueError(f"incomplete response for {url}: expected {content_length} bytes, got {len(body)}")
        if len(body) > max_bytes:
            raise ValueError(f"response exceeds max byte budget for {url}: {max_bytes}")
        return FetchResult(
            url=response.geturl(),
            status=getattr(response, "status", 200),
            content_type=response.headers.get("content-type", "application/octet-stream"),
            body=body,
        )


def harvest_sources(
    output_root: Path,
    run_id: str,
    source_ids: list[str] | None = None,
    limit: int = 25,
    fetcher: Fetcher = default_fetch,
    env: dict[str, str] | None = None,
) -> dict[str, Any]:
    env = env or os.environ
    selected = _selected_sources(source_ids)
    created_at = utc_now()
    run_root = output_root / run_id
    raw_dir = run_root / "snapshots"
    normalized_dir = run_root / "normalized"
    manifest_entries: list[dict[str, Any]] = []
    blocked_sources: list[dict[str, Any]] = []

    for source in selected:
        record = _harvest_source(source, run_root, raw_dir, limit, fetcher, env)
        normalized_path = normalized_dir / f"{source['id']}.json"
        write_json(normalized_path, record)
        entry = {
            "sourceID": source["id"],
            "title": source["title"],
            "adapter": record["adapterID"],
            "status": record["status"],
            "normalizedPath": str(normalized_path.relative_to(run_root)),
            "normalizedSHA256": file_sha256(normalized_path),
            "claimCount": len(record.get("claims", [])),
            "recordCount": len(record.get("records", [])),
            "rawArtifacts": [
                {
                    "path": artifact["path"],
                    "sha256": artifact["sha256"],
                    "bytes": artifact["bytes"],
                    "contentType": artifact["contentType"],
                    "url": artifact["url"],
                }
                for artifact in record.get("rawArtifacts", [])
            ],
        }
        if record["status"] == "blocked":
            entry["blockedReasons"] = record.get("blockedReasons", [])
            entry["missingEnv"] = record.get("missingEnv", [])
            blocked_sources.append({"sourceID": source["id"], "blockedReasons": record.get("blockedReasons", [])})
        manifest_entries.append(entry)

    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.harvestManifest",
        "runID": run_id,
        "createdAt": created_at,
        "adapterVersion": ADAPTER_VERSION,
        "sourceCount": len(selected),
        "harvestedCount": sum(1 for entry in manifest_entries if entry["status"] == "harvested"),
        "blockedCount": sum(1 for entry in manifest_entries if entry["status"] == "blocked"),
        "entries": manifest_entries,
        "blockedSources": blocked_sources,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    issues = privacy_findings_for_value(manifest, "harvest-manifest")
    manifest["privacyScan"] = {"passed": not issues, "issues": issues}
    manifest_path = run_root / "manifest.json"
    write_json(manifest_path, manifest)
    return {
        "runRoot": str(run_root),
        "manifestPath": str(manifest_path),
        "runID": run_id,
        "sourceCount": manifest["sourceCount"],
        "harvestedCount": manifest["harvestedCount"],
        "blockedCount": manifest["blockedCount"],
        "privacyScan": manifest["privacyScan"],
    }


def _selected_sources(source_ids: list[str] | None) -> list[dict[str, Any]]:
    if not source_ids:
        return SOURCE_REGISTRY
    lookup = {source["id"]: source for source in SOURCE_REGISTRY}
    unknown = [source_id for source_id in source_ids if source_id not in lookup]
    if unknown:
        raise ValueError(f"unknown Source Atlas source IDs: {', '.join(unknown)}")
    return [lookup[source_id] for source_id in source_ids]


def _harvest_source(
    source: dict[str, Any],
    run_root: Path,
    raw_dir: Path,
    limit: int,
    fetcher: Fetcher,
    env: dict[str, str],
) -> dict[str, Any]:
    source_id = source["id"]
    try:
        if source_id in {"nara.constitution.presidency", "nasa.astronaut.requirements", "nasa.astronaut.selection"}:
            return _harvest_static_page(source, run_root, raw_dir, fetcher)
        if source_id == "onet.database":
            return _harvest_onet(source, run_root, raw_dir, limit, fetcher)
        if source_id == "bls.public.data.api":
            return _harvest_bls(source, run_root, raw_dir, fetcher)
        if source_id == "usajobs.search":
            return _harvest_usajobs(source, run_root, raw_dir, limit, fetcher, env)
        if source_id == "data.gov.catalog":
            return _harvest_datagov(source, run_root, raw_dir, limit, fetcher, env)
        if source_id == "college-scorecard.api":
            return _harvest_college_scorecard(source, run_root, raw_dir, limit, fetcher, env)
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError, ValueError, json.JSONDecodeError, zipfile.BadZipFile) as exc:
        return _blocked_record(source, f"adapter_fetch_or_parse_failed: {type(exc).__name__}: {exc}")
    return _blocked_record(source, "no_adapter_implemented_for_source")


def _base_record(source: dict[str, Any], status: str, adapter_id: str) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.harvestRecord",
        "sourceID": source["id"],
        "source": source,
        "status": status,
        "adapterID": adapter_id,
        "adapterVersion": ADAPTER_VERSION,
        "fetchedAt": utc_now(),
        "rawArtifacts": [],
        "records": [],
        "claims": [],
        "requirements": [],
        "freshnessSignals": {},
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }


def _blocked_record(source: dict[str, Any], reason: str, missing_env: list[str] | None = None) -> dict[str, Any]:
    record = _base_record(source, "blocked", source["adapter"])
    record["blockedReasons"] = [reason]
    if missing_env:
        record["missingEnv"] = missing_env
    return record


def _write_raw(run_root: Path, path: Path, result: FetchResult) -> dict[str, Any]:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(result.body)
    return {
        "path": str(path.relative_to(run_root)),
        "url": _redact_url(result.url),
        "status": result.status,
        "contentType": result.content_type,
        "sha256": file_sha256(path),
        "bytes": path.stat().st_size,
    }


def _redact_url(url: str) -> str:
    parsed = urllib.parse.urlsplit(url)
    query = [
        (key, "[redacted]" if key.lower() in {"api_key", "key", "token"} else value)
        for key, value in urllib.parse.parse_qsl(parsed.query, keep_blank_values=True)
    ]
    return urllib.parse.urlunsplit((parsed.scheme, parsed.netloc, parsed.path, urllib.parse.urlencode(query), parsed.fragment))


def _harvest_static_page(source: dict[str, Any], run_root: Path, raw_dir: Path, fetcher: Fetcher) -> dict[str, Any]:
    result = fetcher(source["url"], None, DEFAULT_MAX_BYTES)
    record = _base_record(source, "harvested", "official_static_page")
    record["rawArtifacts"].append(_write_raw(run_root, raw_dir / source["id"] / "source.html", result))
    text = _html_to_text(result.body.decode("utf-8", errors="replace"))
    record["claims"] = _claims_for_source(source["id"])
    record["requirements"] = _requirements_for_source(source["id"])
    record["records"] = [
        {
            "recordType": "official_page_markers",
            "sourceID": source["id"],
            "detectedMarkers": _detect_source_markers(source["id"], text),
            "claimIDs": [claim["id"] for claim in record["claims"]],
        }
    ]
    record["freshnessSignals"] = {
        "authorityTier": source["authorityTier"],
        "cadence": source["freshnessCadence"],
        "fetchedURL": result.url,
        "lastReviewed": source["lastReviewed"],
    }
    return record


def _claims_for_source(source_id: str) -> list[dict[str, Any]]:
    claims: list[dict[str, Any]] = []
    for pathway in PATHWAY_SEEDS:
        claims.extend([claim for claim in pathway.get("claims", []) if source_id in claim.get("sourceIDs", [])])
    return claims


def _requirements_for_source(source_id: str) -> list[dict[str, Any]]:
    claim_ids = {claim["id"] for claim in _claims_for_source(source_id)}
    requirements: list[dict[str, Any]] = []
    for pathway in PATHWAY_SEEDS:
        requirements.extend([item for item in pathway.get("requirements", []) if item.get("claimID") in claim_ids])
    return requirements


def _html_to_text(value: str) -> str:
    value = re.sub(r"(?is)<script.*?</script>|<style.*?</style>", " ", value)
    value = re.sub(r"(?s)<[^>]+>", " ", value)
    return re.sub(r"\s+", " ", html.unescape(value)).strip()


def _detect_source_markers(source_id: str, text: str) -> list[dict[str, Any]]:
    markers = {
        "nara.constitution.presidency": ["thirty five", "natural born", "fourteen years"],
        "nasa.astronaut.requirements": ["u.s. citizen", "master", "two years", "1,000", "physical"],
        "nasa.astronaut.selection": ["candidate", "training", "selection", "interview"],
    }.get(source_id, [])
    lowered = text.lower()
    return [{"marker": marker, "present": marker in lowered} for marker in markers]


def _harvest_onet(source: dict[str, Any], run_root: Path, raw_dir: Path, limit: int, fetcher: Fetcher) -> dict[str, Any]:
    page = fetcher(source["url"], None, DEFAULT_MAX_BYTES)
    page_text = page.body.decode("utf-8", errors="replace")
    href = _find_onet_text_zip_href(page_text)
    if not href:
        return _blocked_record(source, "onet_text_zip_not_found_on_database_page")
    zip_url = urllib.parse.urljoin(source["url"], href)
    archive = fetcher(zip_url, None, ONET_MAX_BYTES)

    record = _base_record(source, "harvested", "official_onet_text_database")
    record["rawArtifacts"].append(_write_raw(run_root, raw_dir / source["id"] / "database.html", page))
    record["rawArtifacts"].append(_write_raw(run_root, raw_dir / source["id"] / "database-text.zip", archive))
    record["records"] = _normalize_onet_zip(archive.body, limit)
    record["freshnessSignals"] = {
        "databasePageURL": page.url,
        "textZipURL": archive.url,
        "detectedRelease": _detect_onet_release(page_text),
        "cadence": source["freshnessCadence"],
        "license": source["license"],
    }
    return record


def _find_onet_text_zip_href(page_text: str) -> str | None:
    candidates = re.findall(r"href=[\"']([^\"']*db_[^\"']*_text\.zip)[\"']", page_text, re.I)
    return html.unescape(candidates[0]) if candidates else None


def _detect_onet_release(page_text: str) -> str | None:
    match = re.search(r"O\*NET\s+([0-9]+(?:\.[0-9]+)?)\s+Database", page_text)
    return f"O*NET {match.group(1)}" if match else None


def _normalize_onet_zip(body: bytes, limit: int) -> list[dict[str, Any]]:
    selected_files = [
        "Occupation Data.txt",
        "Skills.txt",
        "Knowledge.txt",
        "Abilities.txt",
        "Task Statements.txt",
        "Tasks to DWAs.txt",
        "Related Occupations.txt",
        "Job Titles.txt",
    ]
    records: list[dict[str, Any]] = []
    with zipfile.ZipFile(io.BytesIO(body)) as archive:
        names = archive.namelist()
        for target in selected_files:
            name = next((item for item in names if item.lower().endswith(target.lower())), None)
            if not name:
                records.append({"recordType": "onet_file_missing", "file": target})
                continue
            text = archive.read(name).decode("utf-8-sig", errors="replace")
            reader = csv.DictReader(io.StringIO(text), delimiter="\t")
            row_count, samples = _sample_onet_rows(reader, limit)
            records.append(
                {
                    "recordType": "onet_table_summary",
                    "file": target,
                    "zipMember": name,
                    "rowCount": row_count,
                    "columns": reader.fieldnames or [],
                    "samples": samples,
                }
            )
    return records


def _sample_onet_rows(reader: csv.DictReader[str], limit: int) -> tuple[int, list[dict[str, str]]]:
    first_rows: list[dict[str, str]] = []
    matched_rows: list[dict[str, str]] = []
    sample_limit = max(1, min(limit, 10))
    row_count = 0
    for row in reader:
        row_count += 1
        sanitized = _sanitize_row(row)
        if len(first_rows) < sample_limit:
            first_rows.append(sanitized)
        if _row_matches_goal(row) and len(matched_rows) < sample_limit:
            matched_rows.append(sanitized)
    return row_count, matched_rows or first_rows


def _row_matches_goal(row: dict[str, str]) -> bool:
    keywords = ["astronaut", "aerospace", "engineer", "pilot", "scientist", "leadership", "public"]
    return any(keyword in " ".join(row.values()).lower() for keyword in keywords)


def _sanitize_row(row: dict[str, Any]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for index, (key, value) in enumerate(row.items()):
        if index >= 14:
            break
        if value is None:
            result[key] = None
        else:
            result[key] = str(value).replace("\r", " ").replace("\n", " ")[:300]
    return result


def _harvest_bls(source: dict[str, Any], run_root: Path, raw_dir: Path, fetcher: Fetcher) -> dict[str, Any]:
    series = [
        {
            "seriesID": "OEUN000000000000000000001",
            "label": "National employment baseline across occupations",
        }
    ]
    record = _base_record(source, "harvested", "official_bls_public_api")
    normalized_records = []
    for item in series:
        url = f"https://api.bls.gov/publicAPI/v2/timeseries/data/{urllib.parse.quote(item['seriesID'])}"
        result = fetcher(url, None, DEFAULT_MAX_BYTES)
        record["rawArtifacts"].append(_write_raw(run_root, raw_dir / source["id"] / f"{item['seriesID']}.json", result))
        data = json.loads(result.body.decode("utf-8", errors="replace"))
        series_data = data.get("Results", {}).get("series", [])
        normalized_records.append(
            {
                "recordType": "bls_time_series",
                "seriesID": item["seriesID"],
                "label": item["label"],
                "status": data.get("status"),
                "message": data.get("message", []),
                "latestData": series_data[0].get("data", [])[:3] if series_data else [],
            }
        )
    record["records"] = normalized_records
    record["freshnessSignals"] = {
        "cadence": source["freshnessCadence"],
        "api": "BLS Public Data API v2",
        "seriesIDs": [item["seriesID"] for item in series],
    }
    return record


def _harvest_usajobs(
    source: dict[str, Any],
    run_root: Path,
    raw_dir: Path,
    limit: int,
    fetcher: Fetcher,
    env: dict[str, str],
) -> dict[str, Any]:
    missing = [name for name in ["USAJOBS_USER_AGENT", "USAJOBS_AUTHORIZATION_KEY"] if not env.get(name)]
    if missing:
        return _blocked_record(source, "usajobs_search_requires_registered_api_headers", missing)
    query = urllib.parse.urlencode({"Keyword": "astronaut NASA", "ResultsPerPage": str(max(1, min(limit, 25)))})
    url = f"https://data.usajobs.gov/api/search?{query}"
    headers = {
        "Host": "data.usajobs.gov",
        "User-Agent": env["USAJOBS_USER_AGENT"],
        "Authorization-Key": env["USAJOBS_AUTHORIZATION_KEY"],
    }
    result = fetcher(url, headers, DEFAULT_MAX_BYTES)
    record = _base_record(source, "harvested", "official_usajobs_authenticated_search")
    record["rawArtifacts"].append(_write_raw(run_root, raw_dir / source["id"] / "search.json", result))
    data = json.loads(result.body.decode("utf-8", errors="replace"))
    items = data.get("SearchResult", {}).get("SearchResultItems", [])
    record["records"] = [
        {
            "recordType": "usajobs_public_announcement",
            "positionID": descriptor.get("PositionID"),
            "positionTitle": descriptor.get("PositionTitle"),
            "organizationName": descriptor.get("OrganizationName"),
            "departmentName": descriptor.get("DepartmentName"),
            "positionLocationDisplay": descriptor.get("PositionLocationDisplay"),
            "applicationCloseDate": descriptor.get("ApplicationCloseDate"),
            "positionURI": descriptor.get("PositionURI"),
            "qualificationSummaryLength": len(descriptor.get("QualificationSummary", "")),
        }
        for descriptor in [item.get("MatchedObjectDescriptor", {}) for item in items[:limit]]
    ]
    record["freshnessSignals"] = {
        "cadence": source["freshnessCadence"],
        "api": "USAJOBS Search API",
        "query": "astronaut NASA",
    }
    return record


def _harvest_datagov(
    source: dict[str, Any],
    run_root: Path,
    raw_dir: Path,
    limit: int,
    fetcher: Fetcher,
    env: dict[str, str],
) -> dict[str, Any]:
    api_key = env.get("DATAGOV_API_KEY", "DEMO_KEY")
    queries = ["astronaut", "occupational requirements", "education program"]
    record = _base_record(source, "harvested", "official_datagov_v4_search")
    records: list[dict[str, Any]] = []
    try:
        for query in queries:
            result, mode = _fetch_datagov_query(query, api_key, fetcher)
            artifact_name = f"{re.sub(r'[^a-z0-9]+', '-', query.lower()).strip('-')}-{mode}.json"
            record["rawArtifacts"].append(_write_raw(run_root, raw_dir / source["id"] / artifact_name, result))
            data = json.loads(result.body.decode("utf-8", errors="replace"))
            records.extend(_normalize_datagov_records(data, query, mode, limit))
    except urllib.error.HTTPError as exc:
        if exc.code == 429 and not env.get("DATAGOV_API_KEY"):
            return _blocked_record(source, "datagov_demo_key_rate_limited; set DATAGOV_API_KEY", ["DATAGOV_API_KEY"])
        raise
    record["records"] = records
    record["freshnessSignals"] = {
        "cadence": source["freshnessCadence"],
        "api": "Data.gov API v4 search with v3 package_search fallback",
        "queries": queries,
        "apiKeyMode": "env:DATAGOV_API_KEY" if env.get("DATAGOV_API_KEY") else "DEMO_KEY",
    }
    return record


def _fetch_datagov_query(query: str, api_key: str, fetcher: Fetcher) -> tuple[FetchResult, str]:
    v4_params = urllib.parse.urlencode({"api_key": api_key, "q": query})
    try:
        return fetcher(f"https://api.gsa.gov/technology/datagov/v4/search?{v4_params}", None, DEFAULT_MAX_BYTES), "v4"
    except urllib.error.HTTPError as exc:
        if exc.code not in {403, 404, 429, 500, 502, 503, 504}:
            raise
    v3_params = urllib.parse.urlencode({"api_key": api_key, "q": query, "rows": "10"})
    return fetcher(f"https://api.gsa.gov/technology/datagov/v3/action/package_search?{v3_params}", None, DEFAULT_MAX_BYTES), "v3"


def _normalize_datagov_records(data: dict[str, Any], query: str, mode: str, limit: int) -> list[dict[str, Any]]:
    if mode == "v4":
        records = []
        for item in data.get("results", [])[:limit]:
            dcat = item.get("dcat", {})
            records.append(
                {
                    "recordType": "datagov_dataset_metadata",
                    "apiMode": mode,
                    "query": query,
                    "identifier": dcat.get("identifier"),
                    "title": dcat.get("title"),
                    "accessLevel": dcat.get("accessLevel"),
                    "publisher": _publisher_name(dcat),
                    "modified": dcat.get("modified"),
                    "landingPage": dcat.get("landingPage"),
                    "describedBy": dcat.get("describedBy"),
                    "distributionURLs": _distribution_urls(dcat)[:5],
                }
            )
        return records

    records = []
    for item in data.get("result", {}).get("results", [])[:limit]:
        resources = item.get("resources", []) if isinstance(item.get("resources"), list) else []
        records.append(
            {
                "recordType": "datagov_dataset_metadata",
                "apiMode": mode,
                "query": query,
                "identifier": item.get("id") or item.get("name"),
                "title": item.get("title"),
                "accessLevel": item.get("access_level"),
                "publisher": item.get("organization", {}).get("title") if isinstance(item.get("organization"), dict) else None,
                "modified": item.get("metadata_modified"),
                "landingPage": item.get("url"),
                "descriptionLength": len(item.get("notes", "")) if isinstance(item.get("notes"), str) else 0,
                "distributionURLs": [
                    resource.get("url")
                    for resource in resources
                    if isinstance(resource, dict) and isinstance(resource.get("url"), str)
                ][:5],
            }
        )
    return records


def _publisher_name(dcat: dict[str, Any]) -> str | None:
    publisher = dcat.get("publisher")
    if isinstance(publisher, dict):
        return publisher.get("name")
    return publisher if isinstance(publisher, str) else None


def _distribution_urls(dcat: dict[str, Any]) -> list[str]:
    distribution = dcat.get("distribution", [])
    if not isinstance(distribution, list):
        return []
    urls = []
    for item in distribution:
        if isinstance(item, dict):
            url = item.get("downloadURL") or item.get("accessURL")
            if isinstance(url, str):
                urls.append(url)
    return urls


def _harvest_college_scorecard(
    source: dict[str, Any],
    run_root: Path,
    raw_dir: Path,
    limit: int,
    fetcher: Fetcher,
    env: dict[str, str],
) -> dict[str, Any]:
    api_key = env.get("COLLEGE_SCORECARD_API_KEY") or env.get("DATAGOV_API_KEY") or "DEMO_KEY"
    schools = ["Massachusetts Institute of Technology", "Purdue University", "Georgia Institute of Technology"]
    fields = ",".join(
        [
            "id",
            "school.name",
            "school.state",
            "school.ownership",
            "latest.cost.tuition.in_state",
            "latest.completion.rate_suppressed.overall",
        ]
    )
    record = _base_record(source, "harvested", "official_college_scorecard_api")
    records: list[dict[str, Any]] = []
    try:
        for school in schools[: max(1, min(limit, len(schools)))]:
            params = urllib.parse.urlencode({"api_key": api_key, "school.name": school, "fields": fields, "per_page": "3"})
            result = fetcher(f"https://api.data.gov/ed/collegescorecard/v1/schools?{params}", None, DEFAULT_MAX_BYTES)
            artifact_name = re.sub(r"[^a-z0-9]+", "-", school.lower()).strip("-") + ".json"
            record["rawArtifacts"].append(_write_raw(run_root, raw_dir / source["id"] / artifact_name, result))
            data = json.loads(result.body.decode("utf-8", errors="replace"))
            for item in data.get("results", []):
                records.append({"recordType": "college_scorecard_school", **item})
    except urllib.error.HTTPError as exc:
        if exc.code == 429 and not env.get("COLLEGE_SCORECARD_API_KEY") and not env.get("DATAGOV_API_KEY"):
            return _blocked_record(
                source,
                "college_scorecard_demo_key_rate_limited; set COLLEGE_SCORECARD_API_KEY or DATAGOV_API_KEY",
                ["COLLEGE_SCORECARD_API_KEY", "DATAGOV_API_KEY"],
            )
        raise
    record["records"] = records
    record["freshnessSignals"] = {
        "cadence": source["freshnessCadence"],
        "api": "College Scorecard API",
        "apiKeyMode": "env:COLLEGE_SCORECARD_API_KEY" if env.get("COLLEGE_SCORECARD_API_KEY") else "DEMO_KEY",
    }
    return record
