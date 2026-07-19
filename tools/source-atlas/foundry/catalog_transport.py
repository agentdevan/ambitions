"""Live-gated public catalog transport for Source Atlas.

Transport is the layer before catalog discovery. It can copy deterministic
fixtures or fetch public catalog JSON when explicitly invoked with live/write
gates. It never emits claim authority, packable output, or R2-ready artifacts.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable
from urllib.parse import parse_qsl, urlparse
from urllib.request import Request, urlopen

from .boundary import request_shape_issues
from .catalog_discovery import CatalogDiscoveryOptions, run_catalog_discovery
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, privacy_findings_for_value, read_json, stable_hash, utc_now, write_json


CATALOG_TRANSPORT_VERSION = "source-atlas-catalog-transport-train-54"
CATALOG_TRANSPORT_KIND = "ambitions.sourceAtlas.catalogTransport.v1"
CATALOG_TRANSPORT_MODES = {"fixture", "dry_run", "live"}
TRANSPORT_NON_CLAIMS = [
    "not source authority",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not legal approval",
    "not outside legal approval",
    "not universal coverage",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class CatalogTransportOptions:
    plan_path: Path
    output_root: Path
    mode: str = "fixture"
    live: bool = False
    execute: bool = False
    created_at: str | None = None


@dataclass(frozen=True)
class CatalogFetchResult:
    status_code: int
    content_type: str
    body: str
    byte_size: int
    truncated: bool = False


CatalogFetcher = Callable[[dict[str, Any]], CatalogFetchResult]


def run_catalog_transport(options: CatalogTransportOptions, fetcher: CatalogFetcher | None = None) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    snapshot_root = output_root / "snapshots"
    output_root.mkdir(parents=True, exist_ok=True)
    snapshot_root.mkdir(parents=True, exist_ok=True)
    plan = read_json(options.plan_path)
    endpoints = _endpoint_list(plan)
    issues = _plan_issues(plan, endpoints, options)
    input_privacy_issues = privacy_findings_for_value(plan, "catalog-transport-plan")
    request_privacy_issues = _request_privacy_issues(endpoints)

    transport_entries: list[dict[str, Any]] = []
    snapshot_paths: list[str] = []
    fetcher = fetcher or _default_fetcher

    if not issues and not input_privacy_issues and not request_privacy_issues:
        for endpoint in endpoints:
            if endpoint.get("enabled", True) is False:
                transport_entries.append(_transport_entry(endpoint, created_at, status="skipped", blocked_reasons=["endpoint_disabled"]))
                continue
            if options.mode == "dry_run":
                transport_entries.append(_transport_entry(endpoint, created_at, status="planned", blocked_reasons=[]))
                continue
            if options.mode == "fixture":
                entry, snapshot_path = _fixture_snapshot(endpoint, snapshot_root, created_at)
            else:
                entry, snapshot_path = _live_snapshot(endpoint, snapshot_root, created_at, fetcher)
            transport_entries.append(entry)
            if entry["status"] == "blocked":
                issues.extend(entry["blocking_reasons"])
            if snapshot_path:
                snapshot_paths.append(str(snapshot_path))

    discovery_result: dict[str, Any] | None = None
    if snapshot_paths and not issues and not input_privacy_issues and not request_privacy_issues:
        discovery_result = run_catalog_discovery(
            CatalogDiscoveryOptions(
                input_root=snapshot_root,
                output_root=output_root / "catalog-discovery",
                created_at=created_at,
            )
        )
        if not discovery_result["valid"]:
            issues.extend(f"catalog discovery: {issue}" for issue in discovery_result["issues"])

    record_counts = {
        "endpoints": len(endpoints),
        "snapshots": len(snapshot_paths),
        "catalogs": discovery_result["recordCounts"]["catalogs"] if discovery_result else 0,
        "candidateSources": discovery_result["recordCounts"]["candidateSources"] if discovery_result else 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
    }
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_TRANSPORT_KIND,
        "versionID": CATALOG_TRANSPORT_VERSION,
        "createdAt": created_at,
        "mode": options.mode,
        "liveRequested": options.live,
        "executeRequested": options.execute,
        "planPath": str(options.plan_path),
        "snapshotRoot": str(snapshot_root),
        "transportEntries": transport_entries,
        "discoveryManifestPath": discovery_result.get("manifestPath") if discovery_result else None,
        "recordCounts": record_counts,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": TRANSPORT_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-transport")
    checks = [
        {"name": "mode_supported", "passed": options.mode in CATALOG_TRANSPORT_MODES, "issues": []},
        {"name": "live_mode_requires_live_flag", "passed": not (options.mode == "live" and not options.live), "issues": []},
        {"name": "live_mode_requires_execute_flag", "passed": not (options.mode == "live" and not options.execute), "issues": []},
        {"name": "plan_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {"name": "request_privacy_scan_passed", "passed": not request_privacy_issues, "issues": request_privacy_issues},
        {
            "name": "transport_emits_no_claims",
            "passed": record_counts["claims"] == 0 and record_counts["packableClaims"] == 0 and record_counts["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "snapshots_hash_verified",
            "passed": all(entry.get("sha256") for entry in transport_entries if entry["status"] == "fetched") or options.mode == "dry_run",
            "issues": [],
        },
        {
            "name": "catalog_discovery_candidate_only",
            "passed": discovery_result is None
            or (
                discovery_result["recordCounts"]["claims"] == 0
                and discovery_result["recordCounts"]["packableClaims"] == 0
                and discovery_result["recordCounts"]["r2PackableArtifacts"] == 0
            ),
            "issues": [],
        },
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues, "issues": artifact_privacy_issues},
    ]
    all_issues = list(issues)
    all_issues.extend(input_privacy_issues)
    all_issues.extend(request_privacy_issues)
    all_issues.extend(artifact_privacy_issues)
    for check in checks:
        if not check["passed"]:
            all_issues.extend(check.get("issues") or [f"failed check: {check['name']}"])
    valid = not all_issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogTransportManifest.v1",
        "versionID": CATALOG_TRANSPORT_VERSION,
        "createdAt": created_at,
        "status": "Source Green for live-gated catalog transport tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; live-gated public catalog transport tooling only",
        "mode": options.mode,
        "liveRequested": options.live,
        "executeRequested": options.execute,
        "planPath": str(options.plan_path),
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(all_issues)),
        "outputPaths": {
            "catalogTransport": str(output_root / "catalog-transport.json"),
            "manifest": str(output_root / "manifest.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "discoveryManifestPath": discovery_result.get("manifestPath") if discovery_result else None,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": TRANSPORT_NON_CLAIMS,
    }

    write_json(output_root / "catalog-transport.json", artifact)
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogTransport": file_sha256(output_root / "catalog-transport.json"),
        "manifest": file_sha256(output_root / "manifest.json"),
    }
    if discovery_result:
        manifest["outputHashes"]["catalogDiscovery"] = stable_hash(discovery_result)
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_transport_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_transport_report(
    markdown_path: Path,
    json_path: Path,
    *,
    plan_path: Path,
    output_root: Path,
    mode: str = "fixture",
    live: bool = False,
    execute: bool = False,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = run_catalog_transport(
        CatalogTransportOptions(
            plan_path=plan_path,
            output_root=output_root,
            mode=mode,
            live=live,
            execute=execute,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_transport_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_transport_markdown(result: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Catalog Transport Train 54",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Mode: {result['mode']}",
        "",
        "Scope completed:",
        "- Live-gated public catalog transport path for catalog discovery inputs.",
        "- Fixture and dry-run modes that require no network.",
        "- Live mode blocked unless both live and execute gates are explicit.",
        "- Snapshot SHA-256 proof before catalog candidate discovery.",
        "",
        "Product law preserved:",
        "- Catalog transport emits public/reference snapshots only.",
        "- No private context, claims, packs, R2 objects, final plans, schedules, or Steps are emitted.",
        "",
        "Validation run:",
        "- See current train closeout for exact commands.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    if result.get("discoveryManifestPath"):
        lines.append(f"- {result['discoveryManifestPath']}")
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _endpoint_list(plan: Any) -> list[dict[str, Any]]:
    if not isinstance(plan, dict):
        return []
    endpoints = plan.get("catalogEndpoints", [])
    return [endpoint for endpoint in endpoints if isinstance(endpoint, dict)]


def _plan_issues(plan: Any, endpoints: list[dict[str, Any]], options: CatalogTransportOptions) -> list[str]:
    issues: list[str] = []
    if options.mode not in CATALOG_TRANSPORT_MODES:
        issues.append(f"unsupported mode: {options.mode}")
    if options.mode == "live" and not options.live:
        issues.append("live catalog transport requires --live")
    if options.mode == "live" and not options.execute:
        issues.append("live catalog transport writes snapshots and requires --execute")
    if not isinstance(plan, dict):
        issues.append("transport plan must be an object")
    if not endpoints:
        issues.append("catalogEndpoints must be a non-empty list")
    seen_ids: set[str] = set()
    for index, endpoint in enumerate(endpoints):
        endpoint_id = str(endpoint.get("endpoint_id") or "")
        if not endpoint_id:
            issues.append(f"endpoint[{index}]: endpoint_id required")
        if endpoint_id in seen_ids:
            issues.append(f"endpoint[{index}]: duplicate endpoint_id {endpoint_id}")
        seen_ids.add(endpoint_id)
        url = str(endpoint.get("url") or "")
        if not url:
            issues.append(f"{endpoint_id or index}: url required")
        parsed = urlparse(url)
        if parsed.scheme not in {"http", "https"}:
            issues.append(f"{endpoint_id or index}: url must be http or https")
        if options.mode == "fixture" and not endpoint.get("fixture_path"):
            issues.append(f"{endpoint_id or index}: fixture_path required in fixture mode")
        max_bytes = int(endpoint.get("max_bytes", 2_000_000))
        if max_bytes <= 0:
            issues.append(f"{endpoint_id or index}: max_bytes must be positive")
    return issues


def _request_privacy_issues(endpoints: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    for endpoint in endpoints:
        endpoint_id = str(endpoint.get("endpoint_id") or "endpoint")
        url = str(endpoint.get("url") or "")
        parsed = urlparse(url)
        request = {
            "method": "GET",
            "url": url,
            "headers": {"Accept": "application/json"},
            "query": dict(parse_qsl(parsed.query, keep_blank_values=True)),
        }
        issues.extend(issue.format() for issue in request_shape_issues(request, f"catalog-transport-request:{endpoint_id}"))
    return issues


def _fixture_snapshot(endpoint: dict[str, Any], snapshot_root: Path, created_at: str) -> tuple[dict[str, Any], Path | None]:
    fixture_path = Path(str(endpoint.get("fixture_path")))
    endpoint_id = str(endpoint.get("endpoint_id"))
    if not fixture_path.exists():
        return _transport_entry(endpoint, created_at, status="blocked", blocked_reasons=[f"fixture missing: {fixture_path}"]), None
    payload, redaction_count = _redacted_public_catalog_payload(read_json(fixture_path))
    snapshot_path = snapshot_root / f"{_safe_filename(endpoint_id)}.json"
    write_json(snapshot_path, payload)
    return _fetched_entry(endpoint, snapshot_path, created_at, retrieval_method="fixture_snapshot", status_code=200, content_type="application/json", truncated=False, redaction_count=redaction_count), snapshot_path


def _live_snapshot(endpoint: dict[str, Any], snapshot_root: Path, created_at: str, fetcher: CatalogFetcher) -> tuple[dict[str, Any], Path | None]:
    endpoint_id = str(endpoint.get("endpoint_id"))
    try:
        response = fetcher(endpoint)
    except Exception as exc:  # pragma: no cover - exact transport exception type is environment-dependent.
        return _transport_entry(endpoint, created_at, status="blocked", blocked_reasons=[f"live fetch failed: {type(exc).__name__}: {exc}"]), None
    if response.status_code >= 400:
        return _transport_entry(endpoint, created_at, status="blocked", blocked_reasons=[f"live fetch HTTP {response.status_code}"]), None
    try:
        payload = json.loads(response.body)
    except json.JSONDecodeError as exc:
        return _transport_entry(endpoint, created_at, status="blocked", blocked_reasons=[f"live fetch returned invalid JSON: {exc}"]), None
    payload, redaction_count = _redacted_public_catalog_payload(payload)
    snapshot_path = snapshot_root / f"{_safe_filename(endpoint_id)}.json"
    write_json(snapshot_path, payload)
    return _fetched_entry(
        endpoint,
        snapshot_path,
        created_at,
        retrieval_method="live_http_get",
        status_code=response.status_code,
        content_type=response.content_type,
        truncated=response.truncated,
        redaction_count=redaction_count,
    ), snapshot_path


def _transport_entry(endpoint: dict[str, Any], created_at: str, *, status: str, blocked_reasons: list[str]) -> dict[str, Any]:
    return {
        "endpoint_id": str(endpoint.get("endpoint_id") or ""),
        "url": str(endpoint.get("url") or ""),
        "mode": "transport",
        "retrieved_at": created_at,
        "status": status,
        "review_required": True,
        "claim_authority_allowed": False,
        "pack_output_allowed": False,
        "blocking_reasons": sorted(blocked_reasons),
        "non_claims": [
            "catalog transport metadata only",
            "not claim authority",
            "not redistribution approval",
            "not pack output",
        ],
    }


def _fetched_entry(
    endpoint: dict[str, Any],
    snapshot_path: Path,
    created_at: str,
    *,
    retrieval_method: str,
    status_code: int,
    content_type: str,
    truncated: bool,
    redaction_count: int,
) -> dict[str, Any]:
    entry = _transport_entry(endpoint, created_at, status="fetched", blocked_reasons=[])
    entry.update(
        {
            "retrieval_method": retrieval_method,
            "http_status": status_code,
            "content_type": content_type,
            "snapshot_path": str(snapshot_path),
            "sha256": file_sha256(snapshot_path),
            "truncated": truncated,
            "public_contact_redaction_count": redaction_count,
            "evidence_hash": stable_hash(read_json(snapshot_path)),
        }
    )
    return entry


def _redacted_public_catalog_payload(value: Any) -> tuple[Any, int]:
    redaction_count = 0

    def redact(item: Any, path: str) -> Any:
        nonlocal redaction_count
        if isinstance(item, dict):
            output: dict[str, Any] = {}
            for key, child in item.items():
                key_path = f"{path}.{key}"
                if _is_public_catalog_identifier_key(key):
                    redaction_count += 1
                    output[f"redacted_public_catalog_identifier_{redaction_count}"] = "[redacted-public-catalog-identifier]"
                elif _is_public_contact_email_key(key) and isinstance(child, str) and "@" in child:
                    redaction_count += 1
                    output[key] = "[redacted-public-catalog-contact]"
                else:
                    output[key] = redact(child, key_path)
            return output
        if isinstance(item, list):
            return [redact(child, f"{path}[{index}]") for index, child in enumerate(item)]
        if isinstance(item, str) and item.startswith(("http://", "https://")):
            redacted = re.sub(r"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b", "redacted-public-id", item)
            if redacted != item:
                redaction_count += 1
            return redacted
        return item

    return redact(value, "$"), redaction_count


def _is_public_contact_email_key(key: str) -> bool:
    lowered = key.lower()
    return lowered.endswith("email") or lowered.endswith("_email") or lowered in {"mbox", "contact_email", "contact_point"}


def _is_public_catalog_identifier_key(key: str) -> bool:
    lowered = key.lower()
    return lowered in {"creator_user_id", "revision_id", "owner_org"} or lowered.endswith("_user_id")


def _default_fetcher(endpoint: dict[str, Any]) -> CatalogFetchResult:
    url = str(endpoint["url"])
    timeout = float(endpoint.get("timeout_seconds", 20))
    max_bytes = int(endpoint.get("max_bytes", 2_000_000))
    request = Request(
        url,
        headers={
            "Accept": "application/json, application/ld+json;q=0.9, */*;q=0.1",
            "User-Agent": "Ambitions-Source-Atlas/1.0 public-reference-catalog-transport",
        },
    )
    with urlopen(request, timeout=timeout) as response:
        data = response.read(max_bytes + 1)
        truncated = len(data) > max_bytes
        if truncated:
            data = data[:max_bytes]
        content_type = response.headers.get("content-type", "")
        return CatalogFetchResult(
            status_code=int(response.getcode() or 0),
            content_type=content_type,
            body=data.decode("utf-8", errors="replace"),
            byte_size=len(data),
            truncated=truncated,
        )


def _safe_filename(value: str) -> str:
    normalized = re.sub(r"[^a-zA-Z0-9._-]+", "-", value).strip("-._")
    return normalized or "catalog-endpoint"
