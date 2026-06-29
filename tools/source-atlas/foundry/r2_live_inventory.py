"""Live Cloudflare R2 inventory reconciliation for Source Atlas production."""

from __future__ import annotations

import datetime as dt
import hashlib
import hmac
import json
import os
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import object_key_issues
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_id, write_json


R2_LIVE_INVENTORY_VERSION = "source-atlas-r2-live-inventory-train-134"
R2_LIST_KIND = "ambitions.sourceAtlas.r2LiveInventory.v1"
S3_SERVICE = "s3"
R2_REGION = "auto"
EMPTY_PAYLOAD_HASH = hashlib.sha256(b"").hexdigest()
SECRET_ENV_NAMES = {
    "CLOUDFLARE_API_TOKEN",
    "CLOUDFLARE_R2_ACCESS_KEY_ID",
    "CLOUDFLARE_R2_SECRET_ACCESS_KEY",
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
    "SOURCE_ATLAS_R2_ACCESS_KEY_ID",
    "SOURCE_ATLAS_R2_SECRET_ACCESS_KEY",
}


@dataclass(frozen=True)
class R2LiveInventoryOptions:
    production_target_ledger_path: Path
    output_root: Path
    hygiene_policy_path: Path | None = None
    bucket: str = "ambitions-source-atlas-prod"
    prefix: str = "source-atlas/"
    env_file_paths: tuple[Path, ...] | None = None
    account_id: str | None = None
    created_at: str = "2026-06-29T00:00:00Z"
    verify_known_checksums: bool = False
    max_checksum_reads: int | None = None


def run_r2_live_inventory(options: R2LiveInventoryOptions) -> dict[str, Any]:
    runtime_env, loaded_env_files = _runtime_env(options.env_file_paths)
    env_resolution = _environment_resolution(options, runtime_env, loaded_env_files)
    expected = expected_objects_from_ledger(options.production_target_ledger_path)
    live: list[dict[str, Any]] = []
    issues: list[str] = []
    checksum_results: list[dict[str, Any]] = []

    if env_resolution["valid"]:
        client = R2S3Client(
            account_id=env_resolution["_accountIDValue"],
            access_key_id=env_resolution["_accessKeyIDValue"],
            secret_access_key=env_resolution["_secretAccessKeyValue"],
            bucket=options.bucket,
        )
        try:
            live = client.list_objects(prefix=options.prefix)
        except Exception as exc:  # pragma: no cover - exact urllib exception varies.
            issues.append(f"live R2 list failed: {type(exc).__name__}: {exc}")
        if options.verify_known_checksums and live and not issues:
            checksum_results = _verify_known_checksums(
                client,
                expected,
                max_reads=options.max_checksum_reads,
            )
            issues.extend(result["issue"] for result in checksum_results if result.get("issue"))
    else:
        issues.extend(env_resolution["issues"])

    comparison = compare_live_to_expected(live, expected, checksum_results)
    issues.extend(comparison["issues"])
    privacy_issues = _privacy_issues_for_inventory(live, expected)
    hygiene_policy = _hygiene_policy(options.hygiene_policy_path)
    hygiene = _hygiene_classification(comparison["unexpectedLiveObjects"], hygiene_policy, options.created_at)
    issues.extend(violation["issue"] for violation in hygiene["violations"])
    checks = [
        _check("r2_environment_resolved_without_secret_values", env_resolution["valid"], env_resolution["issues"]),
        _check("live_r2_inventory_listed", bool(live) and not any(issue.startswith("live R2 list failed") for issue in issues), [issue for issue in issues if issue.startswith("live R2 list failed")]),
        _check("expected_current_objects_present", not comparison["missingExpectedObjects"], [item["objectKey"] for item in comparison["missingExpectedObjects"]]),
        _check("live_expected_object_sizes_match", not comparison["sizeMismatches"], [item["objectKey"] for item in comparison["sizeMismatches"]]),
        _check("known_checksums_match" if options.verify_known_checksums else "known_checksums_not_requested", not comparison["checksumMismatches"], [item["objectKey"] for item in comparison["checksumMismatches"]]),
        _check("object_keys_public_reference_only", not privacy_issues, privacy_issues),
        _check("production_bucket_hygiene_policy", not hygiene["violations"], [item["issue"] for item in hygiene["violations"]]),
    ]
    valid = all(check["passed"] for check in checks)
    unexpected_count = len(comparison["unexpectedLiveObjects"])
    status = "Source Green for live R2 inventory reconciliation" if valid and unexpected_count == 0 else "Yellow for live R2 inventory reconciliation"
    if not valid:
        status = "Red for live R2 inventory reconciliation"
    report = {
        "schemaVersion": 1,
        "kind": R2_LIST_KIND,
        "versionID": R2_LIVE_INVENTORY_VERSION,
        "inventoryID": stable_id("source-atlas/r2-live-inventory", {
            "bucket": options.bucket,
            "prefix": options.prefix,
            "createdAt": options.created_at,
            "expectedCount": len(expected),
            "liveCount": len(live),
        }),
        "createdAt": options.created_at,
        "bucket": options.bucket,
        "prefix": options.prefix,
        "status": status,
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; live R2 inventory reconciliation only",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "environment": _redacted_environment(env_resolution),
        "checks": checks,
        "issues": sorted(set(issues)),
        "privacyIssues": privacy_issues,
        "recordCounts": {
            "configuredDomains": len({item["domainID"] for item in expected}),
            "expectedCurrentObjects": len(expected),
            "expectedPayloadObjects": sum(1 for item in expected if item["objectRole"] == "payload"),
            "expectedCurrentPointerObjects": sum(1 for item in expected if item["objectRole"] == "current_pointer"),
            "expectedBytes": sum(item.get("expectedBytes") or 0 for item in expected),
            "liveObjects": len(live),
            "liveBytes": sum(item.get("size") or 0 for item in live),
            "expectedPresent": len(comparison["presentExpectedObjects"]),
            "expectedMissing": len(comparison["missingExpectedObjects"]),
            "unexpectedLiveObjects": unexpected_count,
            "sizeMismatches": len(comparison["sizeMismatches"]),
            "checksumReads": len(checksum_results),
            "checksumMismatches": len(comparison["checksumMismatches"]),
            "privacyIssues": len(privacy_issues),
            "hygieneViolations": len(hygiene["violations"]),
            "hygieneRedObjects": sum(1 for item in hygiene["classifiedUnexpectedObjects"] if item["severity"] == "Red"),
            "hygieneYellowObjects": sum(1 for item in hygiene["classifiedUnexpectedObjects"] if item["severity"] == "Yellow"),
            "approvedNonCurrentObjects": sum(1 for item in hygiene["classifiedUnexpectedObjects"] if item["classification"] == "approved_noncurrent_retained"),
        },
        "coverageByDomain": _coverage_by_domain(expected, live, comparison),
        "hygienePolicy": hygiene_policy,
        "hygiene": hygiene,
        "expectedObjects": expected,
        "liveObjects": live,
        "comparison": comparison,
        "checksumReadback": checksum_results,
        "nonClaims": NON_CLAIMS + [
            "not a private user-data backend",
            "not private life graph storage",
            "not full Source Atlas Green",
            "not literal universal coverage",
            "not a production writer",
            "not a deletion or rollback command",
        ],
    }
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    report_path = output_root / "r2-live-inventory-report.json"
    markdown_path = output_root / "r2-live-inventory-report.md"
    write_json(report_path, report)
    markdown_path.write_text(r2_live_inventory_markdown(report), encoding="utf-8")
    report["outputPaths"] = {
        "report": str(report_path),
        "markdown": str(markdown_path),
        "closeout": str(output_root / "closeout.md"),
    }
    write_json(report_path, report)
    (output_root / "closeout.md").write_text(r2_live_inventory_markdown(report), encoding="utf-8")
    return report


def expected_objects_from_ledger(ledger_path: Path) -> list[dict[str, Any]]:
    ledger = read_json(ledger_path)
    expected: list[dict[str, Any]] = []
    for domain in ledger.get("domains", []):
        domain_id = domain["domainID"]
        pack_path = Path(domain["packProductionPath"])
        publisher_path = Path(domain["r2PublisherPath"])
        pack = read_json(pack_path)
        publisher = read_json(publisher_path)
        for obj in pack.get("dryRunPlan", {}).get("objects", []):
            expected.append(
                {
                    "domainID": domain_id,
                    "objectRole": "payload",
                    "label": obj.get("label"),
                    "objectKey": obj.get("objectKey"),
                    "expectedBytes": obj.get("bytes"),
                    "expectedSHA256": obj.get("sha256"),
                    "sourceArtifact": str(pack_path),
                }
            )
        pointer = publisher.get("operation", {}).get("currentPointer", {})
        pointer_key = pointer.get("key")
        if pointer_key:
            expected.append(
                {
                    "domainID": domain_id,
                    "objectRole": "current_pointer",
                    "label": "current",
                    "objectKey": pointer_key,
                    "expectedBytes": None,
                    "expectedSHA256": pointer.get("expectedSHA256") or pointer.get("actualSHA256") or pointer.get("sha256"),
                    "sourceArtifact": str(publisher_path),
                }
            )
    return sorted(expected, key=lambda item: item["objectKey"])


def compare_live_to_expected(
    live_objects: list[dict[str, Any]],
    expected_objects: list[dict[str, Any]],
    checksum_results: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    live_by_key = {item["objectKey"]: item for item in live_objects}
    expected_by_key = {item["objectKey"]: item for item in expected_objects}
    present: list[dict[str, Any]] = []
    missing: list[dict[str, Any]] = []
    size_mismatches: list[dict[str, Any]] = []
    for expected in expected_objects:
        live = live_by_key.get(expected["objectKey"])
        if not live:
            missing.append(expected)
            continue
        present.append({**expected, "liveSize": live.get("size"), "lastModified": live.get("lastModified")})
        expected_bytes = expected.get("expectedBytes")
        if expected_bytes is not None and live.get("size") != expected_bytes:
            size_mismatches.append({**expected, "liveSize": live.get("size")})
    unexpected = [
        item for item in live_objects
        if item["objectKey"] not in expected_by_key
    ]
    checksum_mismatches = [
        item for item in (checksum_results or [])
        if item.get("expectedSHA256") and item.get("actualSHA256") != item.get("expectedSHA256")
    ]
    issues: list[str] = []
    issues.extend(f"missing expected R2 object: {item['objectKey']}" for item in missing)
    issues.extend(f"size mismatch for R2 object: {item['objectKey']}" for item in size_mismatches)
    issues.extend(f"checksum mismatch for R2 object: {item['objectKey']}" for item in checksum_mismatches)
    return {
        "presentExpectedObjects": present,
        "missingExpectedObjects": missing,
        "unexpectedLiveObjects": unexpected,
        "sizeMismatches": size_mismatches,
        "checksumMismatches": checksum_mismatches,
        "issues": issues,
    }


def r2_live_inventory_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Live R2 Inventory",
        "",
        f"Status: {report['status']}",
        f"Bucket: `{report['bucket']}`",
        f"Prefix: `{report['prefix']}`",
        "",
        "Counts:",
        f"- Live objects: {counts['liveObjects']}",
        f"- Live bytes: {counts['liveBytes']}",
        f"- Expected current objects: {counts['expectedCurrentObjects']}",
        f"- Expected current bytes: {counts['expectedBytes']}",
        f"- Expected present: {counts['expectedPresent']}",
        f"- Expected missing: {counts['expectedMissing']}",
        f"- Unexpected live objects: {counts['unexpectedLiveObjects']}",
        f"- Size mismatches: {counts['sizeMismatches']}",
        f"- Checksum reads: {counts['checksumReads']}",
        f"- Checksum mismatches: {counts['checksumMismatches']}",
        f"- Privacy issues: {counts['privacyIssues']}",
        f"- Hygiene violations: {counts['hygieneViolations']}",
        f"- Hygiene Red objects: {counts['hygieneRedObjects']}",
        f"- Hygiene Yellow objects: {counts['hygieneYellowObjects']}",
        f"- Approved non-current retained objects: {counts['approvedNonCurrentObjects']}",
        "",
        "Domain coverage:",
        "| Domain | Expected | Present | Missing | Unexpected under domain | Expected bytes | Live expected bytes |",
        "| --- | ---: | ---: | ---: | ---: | ---: | ---: |",
    ]
    for row in report["coverageByDomain"]:
        lines.append(
            f"| {row['domainID']} | {row['expectedObjects']} | {row['presentExpectedObjects']} | "
            f"{row['missingExpectedObjects']} | {row['unexpectedLiveObjects']} | {row['expectedBytes']} | {row['liveExpectedBytes']} |"
        )
    lines.extend(
        [
            "",
            "Boundaries:",
            "- Read-only inventory and optional readback only.",
            "- No writes, deletes, current-pointer changes, harvests, or production promotions.",
            "- Secret values are not printed or stored in the report.",
            "- R2 remains public/reference/freshness infrastructure only.",
            "",
            "Hygiene semantics:",
            "- Current configured production objects are the only Green production objects.",
            "- Non-current production, staging, validation, and legacy stable objects in the production bucket are Red unless an explicit retention approval matches them.",
            "- Retention approvals must be prefix-bound, reasoned, and dated in the hygiene policy.",
            "",
            "Hygiene findings:",
            "| Classification | Severity | Count | Bytes |",
            "| --- | --- | ---: | ---: |",
        ]
    )
    for row in report.get("hygiene", {}).get("summaryByClassification", []):
        lines.append(f"| {row['classification']} | {row['severity']} | {row['count']} | {row['bytes']} |")
    lines.extend(
        [
            "",
            "Non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.append("")
    return "\n".join(lines)


class R2S3Client:
    def __init__(self, *, account_id: str, access_key_id: str, secret_access_key: str, bucket: str) -> None:
        self.account_id = account_id
        self.access_key_id = access_key_id
        self.secret_access_key = secret_access_key
        self.bucket = bucket
        self.host = f"{account_id}.r2.cloudflarestorage.com"

    def list_objects(self, *, prefix: str) -> list[dict[str, Any]]:
        objects: list[dict[str, Any]] = []
        token: str | None = None
        while True:
            query = {"list-type": "2", "max-keys": "1000", "prefix": prefix}
            if token:
                query["continuation-token"] = token
            body = self._request("GET", f"/{self.bucket}", query=query)
            parsed = _parse_list_objects(body)
            objects.extend(parsed["objects"])
            if not parsed["isTruncated"]:
                return objects
            token = parsed.get("nextContinuationToken")
            if not token:
                raise RuntimeError("R2 list response was truncated without a continuation token")

    def get_object_bytes(self, object_key: str) -> bytes:
        return self._request("GET", f"/{self.bucket}/{_quote_path(object_key)}", query={})

    def _request(self, method: str, path: str, *, query: dict[str, str]) -> bytes:
        now = dt.datetime.now(dt.timezone.utc)
        amz_date = now.strftime("%Y%m%dT%H%M%SZ")
        date_stamp = now.strftime("%Y%m%d")
        query_string = _canonical_query(query)
        canonical_uri = path
        signed_headers = "host;x-amz-content-sha256;x-amz-date"
        headers = {
            "host": self.host,
            "x-amz-content-sha256": EMPTY_PAYLOAD_HASH,
            "x-amz-date": amz_date,
        }
        canonical_headers = "".join(f"{name}:{headers[name]}\n" for name in signed_headers.split(";"))
        canonical_request = "\n".join([
            method,
            canonical_uri,
            query_string,
            canonical_headers,
            signed_headers,
            EMPTY_PAYLOAD_HASH,
        ])
        credential_scope = f"{date_stamp}/{R2_REGION}/{S3_SERVICE}/aws4_request"
        string_to_sign = "\n".join([
            "AWS4-HMAC-SHA256",
            amz_date,
            credential_scope,
            hashlib.sha256(canonical_request.encode("utf-8")).hexdigest(),
        ])
        signature = hmac.new(
            _signing_key(self.secret_access_key, date_stamp),
            string_to_sign.encode("utf-8"),
            hashlib.sha256,
        ).hexdigest()
        authorization = (
            f"AWS4-HMAC-SHA256 Credential={self.access_key_id}/{credential_scope}, "
            f"SignedHeaders={signed_headers}, Signature={signature}"
        )
        url = f"https://{self.host}{path}"
        if query_string:
            url = f"{url}?{query_string}"
        request = urllib.request.Request(
            url,
            method=method,
            headers={
                "Authorization": authorization,
                "x-amz-content-sha256": EMPTY_PAYLOAD_HASH,
                "x-amz-date": amz_date,
                "Host": self.host,
            },
        )
        with urllib.request.urlopen(request, timeout=30) as response:
            return response.read()


def _verify_known_checksums(
    client: R2S3Client,
    expected: list[dict[str, Any]],
    *,
    max_reads: int | None,
) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    reads = 0
    for item in expected:
        expected_sha = item.get("expectedSHA256")
        if not expected_sha:
            continue
        if max_reads is not None and reads >= max_reads:
            break
        reads += 1
        try:
            payload = client.get_object_bytes(item["objectKey"])
            actual = hashlib.sha256(payload).hexdigest()
            results.append({
                "objectKey": item["objectKey"],
                "domainID": item["domainID"],
                "objectRole": item["objectRole"],
                "bytes": len(payload),
                "expectedSHA256": expected_sha,
                "actualSHA256": actual,
                "passed": actual == expected_sha,
            })
        except Exception as exc:  # pragma: no cover - exact urllib exception varies.
            results.append({
                "objectKey": item["objectKey"],
                "domainID": item["domainID"],
                "objectRole": item["objectRole"],
                "expectedSHA256": expected_sha,
                "actualSHA256": None,
                "passed": False,
                "issue": f"checksum read failed for {item['objectKey']}: {type(exc).__name__}: {exc}",
            })
    return results


def _coverage_by_domain(expected: list[dict[str, Any]], live: list[dict[str, Any]], comparison: dict[str, Any]) -> list[dict[str, Any]]:
    live_by_key = {item["objectKey"]: item for item in live}
    unexpected = comparison["unexpectedLiveObjects"]
    domains = sorted({item["domainID"] for item in expected})
    rows: list[dict[str, Any]] = []
    for domain in domains:
        domain_expected = [item for item in expected if item["domainID"] == domain]
        domain_prefix = f"source-atlas/v1/production/stable/{domain}/"
        present = [item for item in domain_expected if item["objectKey"] in live_by_key]
        missing = [item for item in domain_expected if item["objectKey"] not in live_by_key]
        rows.append({
            "domainID": domain,
            "expectedObjects": len(domain_expected),
            "presentExpectedObjects": len(present),
            "missingExpectedObjects": len(missing),
            "unexpectedLiveObjects": sum(1 for item in unexpected if item["objectKey"].startswith(domain_prefix)),
            "expectedBytes": sum(item.get("expectedBytes") or 0 for item in domain_expected),
            "liveExpectedBytes": sum(live_by_key[item["objectKey"]].get("size") or 0 for item in present),
        })
    return rows


def _hygiene_policy(path: Path | None) -> dict[str, Any]:
    if path and path.exists():
        return read_json(path)
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2ProductionHygienePolicy.v1",
        "policyID": "source-atlas/r2-production-hygiene/default-strict",
        "status": "strict_default",
        "bucket": "ambitions-source-atlas-prod",
        "inventoryPrefix": "source-atlas/",
        "currentConfiguredProductionRule": "Only objects enumerated by the current production target ledger are Green production objects.",
        "unexpectedObjectDefaultSeverity": "Red",
        "retentionApprovals": [],
        "classificationRules": [
            {
                "classification": "production_stable_noncurrent",
                "prefix": "source-atlas/v1/production/stable/",
                "severity": "Red",
                "reason": "Production stable objects outside the current target ledger are non-current production objects.",
            },
            {
                "classification": "staging_candidate_in_production_bucket",
                "prefix": "source-atlas/v1/staging/",
                "severity": "Red",
                "reason": "Staging/candidate namespace must not remain in the production bucket without explicit retention approval.",
            },
            {
                "classification": "validation_in_production_bucket",
                "prefix": "source-atlas/v1/validation/",
                "severity": "Red",
                "reason": "Validation namespace must not remain in the production bucket without explicit retention approval.",
            },
            {
                "classification": "legacy_stable_noncurrent",
                "prefix": "source-atlas/v1/stable/",
                "severity": "Red",
                "reason": "Legacy stable namespace is not the current configured production namespace.",
            },
        ],
    }


def _hygiene_classification(unexpected: list[dict[str, Any]], policy: dict[str, Any], created_at: str) -> dict[str, Any]:
    classified: list[dict[str, Any]] = []
    for obj in unexpected:
        approval = _matching_retention_approval(obj["objectKey"], policy, created_at)
        if approval:
            classified.append(
                {
                    **obj,
                    "classification": "approved_noncurrent_retained",
                    "severity": approval.get("severity", "Yellow"),
                    "retentionApprovalID": approval.get("approvalID"),
                    "retentionReason": approval.get("reason"),
                }
            )
            continue
        rule = _matching_classification_rule(obj["objectKey"], policy)
        classification = rule.get("classification", "unexpected_unclassified_object")
        severity = rule.get("severity", policy.get("unexpectedObjectDefaultSeverity", "Red"))
        classified.append(
            {
                **obj,
                "classification": classification,
                "severity": severity,
                "hygieneReason": rule.get("reason", "Unexpected live object is not in the current configured production set."),
            }
        )
    violations = [
        {
            "objectKey": item["objectKey"],
            "classification": item["classification"],
            "severity": item["severity"],
            "issue": f"{item['severity']} R2 hygiene object: {item['classification']}: {item['objectKey']}",
        }
        for item in classified
        if item["severity"] == "Red"
    ]
    summary: dict[tuple[str, str], dict[str, Any]] = {}
    for item in classified:
        key = (item["classification"], item["severity"])
        summary.setdefault(
            key,
            {
                "classification": item["classification"],
                "severity": item["severity"],
                "count": 0,
                "bytes": 0,
            },
        )
        summary[key]["count"] += 1
        summary[key]["bytes"] += item.get("size") or 0
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2ProductionHygieneClassification.v1",
        "classifiedUnexpectedObjects": classified,
        "summaryByClassification": sorted(summary.values(), key=lambda item: (item["severity"], item["classification"])),
        "violations": violations,
    }


def _matching_retention_approval(object_key: str, policy: dict[str, Any], created_at: str) -> dict[str, Any] | None:
    for approval in policy.get("retentionApprovals", []):
        prefix = approval.get("prefix")
        if not prefix or not object_key.startswith(prefix):
            continue
        expires_at = approval.get("expiresAt")
        if expires_at and expires_at < created_at:
            continue
        return approval
    return None


def _matching_classification_rule(object_key: str, policy: dict[str, Any]) -> dict[str, Any]:
    rules = sorted(policy.get("classificationRules", []), key=lambda item: len(item.get("prefix", "")), reverse=True)
    for rule in rules:
        prefix = rule.get("prefix")
        if prefix and object_key.startswith(prefix):
            return rule
    return {
        "classification": "unexpected_unclassified_object",
        "severity": policy.get("unexpectedObjectDefaultSeverity", "Red"),
        "reason": "Unexpected live object is not in the current configured production set.",
    }


def _privacy_issues_for_inventory(live: list[dict[str, Any]], expected: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    for item in live:
        issues.extend(issue.format() for issue in object_key_issues(item["objectKey"], "live-r2-object-key"))
    for item in expected:
        issues.extend(issue.format() for issue in object_key_issues(item["objectKey"], "expected-r2-object-key"))
    return sorted(set(issues))


def _environment_resolution(options: R2LiveInventoryOptions, runtime_env: dict[str, str], loaded_env_files: list[str]) -> dict[str, Any]:
    issues: list[str] = []
    token = runtime_env.get("CLOUDFLARE_API_TOKEN", "")
    account_id = options.account_id or runtime_env.get("CLOUDFLARE_ACCOUNT_ID", "")
    access_key = runtime_env.get("CLOUDFLARE_R2_ACCESS_KEY_ID") or runtime_env.get("AWS_ACCESS_KEY_ID") or runtime_env.get("SOURCE_ATLAS_R2_ACCESS_KEY_ID") or ""
    secret_key = runtime_env.get("CLOUDFLARE_R2_SECRET_ACCESS_KEY") or runtime_env.get("AWS_SECRET_ACCESS_KEY") or runtime_env.get("SOURCE_ATLAS_R2_SECRET_ACCESS_KEY") or ""
    account_source = "argument" if options.account_id else ("env" if account_id else "api_discovery")
    if not account_id:
        if not token:
            issues.append("CLOUDFLARE_API_TOKEN or CLOUDFLARE_ACCOUNT_ID is required for R2 account discovery")
        else:
            discovered = _discover_account_id(token)
            if discovered["valid"]:
                account_id = discovered["accountID"]
            else:
                issues.extend(discovered["issues"])
    if not access_key:
        issues.append("R2 access key is missing")
    if not secret_key:
        issues.append("R2 secret access key is missing")
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2InventoryEnvironmentResolution.v1",
        "valid": not issues,
        "issues": issues,
        "accountID": "<redacted>" if account_id else None,
        "_accountIDValue": account_id,
        "accountIDResolved": bool(account_id),
        "accountIDSource": account_source,
        "bucket": options.bucket,
        "prefix": options.prefix,
        "envFilesLoaded": loaded_env_files,
        "credentialEnvNamesPresent": sorted(name for name in SECRET_ENV_NAMES if runtime_env.get(name)),
        "_accessKeyIDValue": access_key,
        "_secretAccessKeyValue": secret_key,
        "secretValuesPrinted": False,
    }


def _discover_account_id(token: str) -> dict[str, Any]:
    request = urllib.request.Request(
        "https://api.cloudflare.com/client/v4/accounts",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(request, timeout=20) as response:
            payload = json.loads(response.read())
    except urllib.error.HTTPError as exc:
        return {"valid": False, "issues": [f"Cloudflare account discovery failed: HTTP {exc.code}"]}
    except Exception as exc:  # pragma: no cover - exact urllib exception varies.
        return {"valid": False, "issues": [f"Cloudflare account discovery failed: {type(exc).__name__}: {exc}"]}
    accounts = payload.get("result") or []
    if not payload.get("success"):
        return {"valid": False, "issues": ["Cloudflare account discovery returned success=false"]}
    if len(accounts) != 1:
        return {"valid": False, "issues": [f"Cloudflare account discovery expected exactly one account, found {len(accounts)}; pass --account-id"]}
    return {"valid": True, "accountID": accounts[0]["id"], "issues": []}


def _runtime_env(env_file_paths: tuple[Path, ...] | None) -> tuple[dict[str, str], list[str]]:
    runtime_env = dict(os.environ)
    loaded: list[str] = []
    for path in env_file_paths or _default_env_files():
        if _load_env_file(path, runtime_env):
            loaded.append(_safe_env_file_path(path))
    return runtime_env, loaded


def _default_env_files() -> list[Path]:
    foundry_root = Path(__file__).resolve().parent
    source_atlas_root = foundry_root.parents[0]
    repo_root = foundry_root.parents[2]
    return [repo_root / ".env", source_atlas_root / ".env", foundry_root / ".env"]


def _load_env_file(path: Path, target: dict[str, str]) -> bool:
    if not path.exists():
        return False
    parsed = False
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        name, value = line.split("=", 1)
        name = name.strip()
        if not name:
            continue
        parsed = True
        if name not in target:
            target[name] = _clean_env_value(value.strip())
    return parsed


def _clean_env_value(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        return value[1:-1]
    return value


def _safe_env_file_path(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(Path.cwd().resolve()))
    except ValueError:
        return path.name


def _parse_list_objects(payload: bytes) -> dict[str, Any]:
    root = ET.fromstring(payload)
    namespace = ""
    if root.tag.startswith("{"):
        namespace = root.tag.split("}", 1)[0] + "}"
    objects: list[dict[str, Any]] = []
    for contents in root.findall(f"{namespace}Contents"):
        key = contents.findtext(f"{namespace}Key") or ""
        size_text = contents.findtext(f"{namespace}Size") or "0"
        objects.append({
            "objectKey": key,
            "size": int(size_text),
            "etag": (contents.findtext(f"{namespace}ETag") or "").strip('"'),
            "lastModified": contents.findtext(f"{namespace}LastModified"),
            "storageClass": contents.findtext(f"{namespace}StorageClass"),
        })
    return {
        "objects": objects,
        "isTruncated": (root.findtext(f"{namespace}IsTruncated") or "false").lower() == "true",
        "nextContinuationToken": root.findtext(f"{namespace}NextContinuationToken"),
    }


def _canonical_query(query: dict[str, str]) -> str:
    pairs = []
    for key, value in sorted(query.items()):
        pairs.append(f"{urllib.parse.quote(key, safe='-_.~')}={urllib.parse.quote(str(value), safe='-_.~')}")
    return "&".join(pairs)


def _quote_path(path: str) -> str:
    return "/".join(urllib.parse.quote(part, safe="-_.~") for part in path.split("/"))


def _signing_key(secret: str, date_stamp: str) -> bytes:
    key_date = hmac.new(("AWS4" + secret).encode("utf-8"), date_stamp.encode("utf-8"), hashlib.sha256).digest()
    key_region = hmac.new(key_date, R2_REGION.encode("utf-8"), hashlib.sha256).digest()
    key_service = hmac.new(key_region, S3_SERVICE.encode("utf-8"), hashlib.sha256).digest()
    return hmac.new(key_service, b"aws4_request", hashlib.sha256).digest()


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": issues}


def _redacted_environment(environment: dict[str, Any]) -> dict[str, Any]:
    return {
        key: value
        for key, value in environment.items()
        if not key.startswith("_")
    }
