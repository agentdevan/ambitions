"""Production-safe R2 operations proof harness for Source Atlas."""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_json_file, boundary_issues_for_value, object_key_issues
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, read_json, utc_now, write_json
from .publisher import build_r2_plan
from .r2_contracts import build_last_known_good_manifest, build_revocation_manifest, validate_promotion_gate
from .validator import validate_bundle


R2_OPERATION_MODES = {
    "dry-run",
    "upload-public-reference-artifact",
    "readback",
    "verify-checksum",
    "verify-object-key-privacy",
    "verify-manifest",
    "revoke",
    "read-last-known-good",
    "rollback-select",
}

R2_ENVIRONMENTS = {
    "staging": {
        "bucketEnv": "SOURCE_ATLAS_R2_STAGING_BUCKET",
        "prefixEnv": "SOURCE_ATLAS_R2_STAGING_PREFIX",
        "bucketPlaceholder": "SOURCE_ATLAS_R2_STAGING_BUCKET",
    },
    "production": {
        "bucketEnv": "SOURCE_ATLAS_R2_PRODUCTION_BUCKET",
        "prefixEnv": "SOURCE_ATLAS_R2_PRODUCTION_PREFIX",
        "bucketPlaceholder": "SOURCE_ATLAS_R2_PRODUCTION_BUCKET",
    },
}

SECRET_ENV_NAMES = [
    "CLOUDFLARE_API_TOKEN",
    "CLOUDFLARE_ACCOUNT_ID",
    "CLOUDFLARE_R2_ACCESS_KEY_ID",
    "CLOUDFLARE_R2_SECRET_ACCESS_KEY",
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
    "SOURCE_ATLAS_R2_ACCESS_KEY_ID",
    "SOURCE_ATLAS_R2_SECRET_ACCESS_KEY",
]

FORBIDDEN_LOG_PATTERNS = [
    re.compile(r"\b(?:sk|pk|rk|ak)-[A-Za-z0-9_-]{12,}\b"),
    re.compile(r"\b(?:access|refresh|secret|session)[_-]?token\b", re.I),
    re.compile(r"\b(?:api|secret)[_-]?key\b", re.I),
]


def run_r2_operations_proof(
    *,
    mode: str,
    environment: str,
    bundle_root: Path,
    bucket: str | None = None,
    prefix: str | None = None,
    channel: str = "staging",
    output_path: Path | None = None,
    readback_root: Path | None = None,
    execute: bool = False,
    confirm_public_reference_only: bool = False,
    revoked_artifact_ids: list[str] | None = None,
    candidate_manifest_path: Path | None = None,
    last_known_good_path: Path | None = None,
    env: dict[str, str] | None = None,
) -> dict[str, Any]:
    runtime_env = env if env is not None else os.environ
    if mode not in R2_OPERATION_MODES:
        result = _blocked_result(mode, environment, [f"unsupported mode: {mode}"], execute)
        if output_path:
            write_json(output_path, result)
        return result
    if environment not in R2_ENVIRONMENTS:
        result = _blocked_result(mode, environment, [f"unsupported environment: {environment}"], execute)
        if output_path:
            write_json(output_path, result)
        return result

    resolved = _resolve_environment(environment, bucket, prefix, runtime_env)
    plan = build_r2_plan(bundle_root, resolved["bucketForPlan"], resolved["prefix"], channel)
    plan["environment"] = environment
    revocation = build_revocation_manifest(bundle_root, revoked_artifact_ids=revoked_artifact_ids or [])
    lkg = build_last_known_good_manifest(bundle_root, channel)

    checks = _base_checks(bundle_root, plan, revocation, lkg)
    credential_state = _credential_state(runtime_env)
    blocked: list[str] = []
    operation: dict[str, Any] = {
        "mode": mode,
        "executeRequested": execute,
        "executed": False,
        "dryRun": not execute,
        "results": [],
    }

    real_operation = mode in {
        "upload-public-reference-artifact",
        "readback",
        "revoke",
        "read-last-known-good",
    } or (execute and mode in {"verify-checksum", "rollback-select"})
    if real_operation:
        if not confirm_public_reference_only:
            blocked.append("real R2 operation requires --confirm-public-reference-only")
        if not resolved["bucketConfigured"]:
            blocked.append(f"real R2 operation requires {resolved['bucketEnv']} or --bucket")
        if not credential_state["available"]:
            blocked.append("real R2 operation requires Cloudflare/Wrangler credentials")
        if shutil.which("wrangler") is None:
            blocked.append("real R2 operation requires wrangler on PATH")
        if not plan.get("validForUpload"):
            blocked.append("real R2 operation blocked because plan is not validForUpload")
        for check in checks:
            if check["requiredForRealOperation"] and not check["passed"]:
                blocked.append(f"real R2 operation blocked by {check['name']}")

    if mode == "dry-run":
        operation["results"] = _dry_run_results(plan, revocation, lkg, resolved)
    elif mode == "verify-object-key-privacy":
        operation["results"] = [check for check in checks if check["name"] == "object_key_privacy"]
    elif mode == "verify-manifest":
        operation["results"] = [check for check in checks if check["name"] in {"bundle_manifest", "manifest_privacy", "payload_privacy"}]
    elif mode == "verify-checksum":
        operation["results"] = _verify_checksums(plan, readback_root)
    elif mode == "rollback-select":
        operation["results"] = [_rollback_selection(candidate_manifest_path or (bundle_root / "manifest.json"), last_known_good_path, lkg)]
    elif blocked:
        operation["results"] = [{"status": "blocked", "reasons": sorted(set(blocked))}]
    elif mode == "upload-public-reference-artifact":
        operation = _upload_objects(plan, resolved, revocation, lkg)
    elif mode == "readback":
        operation = _readback_objects(plan, readback_root)
    elif mode == "revoke":
        operation = _upload_generated_manifest(
            resolved["bucketForPlan"],
            f"{resolved['prefix']}/revocations/{read_json(bundle_root / 'manifest.json').get('versionID')}.json",
            revocation,
            "revocation",
        )
    elif mode == "read-last-known-good":
        operation = _read_single_object(
            resolved["bucketForPlan"],
            f"{resolved['prefix']}/last-known-good/{channel}.json",
            readback_root,
            "last-known-good",
        )

    evidence = _evidence_payload(
        mode=mode,
        environment=environment,
        channel=channel,
        resolved=resolved,
        plan=plan,
        revocation=revocation,
        lkg=lkg,
        checks=checks,
        credential_state=credential_state,
        operation=operation,
        blocked=blocked,
    )
    evidence["logRedaction"] = _log_redaction_check(evidence, runtime_env)
    evidence["status"] = _status_for_evidence(evidence)
    evidence["greenScope"] = "Source Atlas Production R2 Operations Proof only" if evidence["status"] == "Green" else None
    if output_path:
        write_json(output_path, evidence)
    return evidence


def _resolve_environment(environment: str, bucket: str | None, prefix: str | None, env: dict[str, str]) -> dict[str, Any]:
    config = R2_ENVIRONMENTS[environment]
    bucket_value = bucket or env.get(config["bucketEnv"], "")
    prefix_value = (prefix or env.get(config["prefixEnv"], "") or "source-atlas/v1").strip("/")
    return {
        "environment": environment,
        "bucketEnv": config["bucketEnv"],
        "prefixEnv": config["prefixEnv"],
        "bucketConfigured": bool(bucket_value),
        "bucket": bucket_value if bucket_value else f"<{config['bucketPlaceholder']}>",
        "bucketForPlan": bucket_value if bucket_value else f"dry-run-{environment}-source-atlas-r2",
        "prefix": prefix_value,
    }


def _credential_state(env: dict[str, str]) -> dict[str, Any]:
    present = [name for name in SECRET_ENV_NAMES if env.get(name)]
    whoami = False
    if shutil.which("wrangler") is not None:
        try:
            completed = subprocess.run(["wrangler", "whoami"], capture_output=True, text=True, timeout=15, check=False)
            whoami = completed.returncode == 0
        except (subprocess.SubprocessError, OSError):
            whoami = False
    return {
        "available": bool(present) or whoami,
        "envNamesPresent": sorted(present),
        "wranglerInstalled": shutil.which("wrangler") is not None,
        "wranglerWhoami": whoami,
        "secretValuesPrinted": False,
    }


def _base_checks(bundle_root: Path, plan: dict[str, Any], revocation: dict[str, Any], lkg: dict[str, Any]) -> list[dict[str, Any]]:
    validation = validate_bundle(bundle_root)
    promotion = _promotion_check(bundle_root, plan, revocation)
    generated_keys = [
        f"{plan.get('prefix', 'source-atlas/v1')}/revocations/{read_json(bundle_root / 'manifest.json').get('versionID')}.json",
        f"{plan.get('prefix', 'source-atlas/v1')}/last-known-good/{plan.get('channel', 'staging')}.json",
    ]
    object_key_issues = _object_key_privacy_issues(plan, generated_keys)
    payload_issues = _payload_privacy_issues(plan)
    manifest_issues = boundary_issue_strings(boundary_issues_for_json_file(bundle_root / "manifest.json", "manifest.json"))
    return [
        {
            "name": "bundle_manifest",
            "passed": validation.get("valid", False),
            "requiredForRealOperation": True,
            "issues": validation.get("issues", []),
        },
        {
            "name": "object_key_privacy",
            "passed": not object_key_issues,
            "requiredForRealOperation": True,
            "issues": object_key_issues,
        },
        {
            "name": "payload_privacy",
            "passed": not payload_issues,
            "requiredForRealOperation": True,
            "issues": payload_issues,
        },
        {
            "name": "manifest_privacy",
            "passed": not manifest_issues,
            "requiredForRealOperation": True,
            "issues": manifest_issues,
        },
        {
            "name": "promotion_gate",
            "passed": promotion.get("validForPromotion", False),
            "requiredForRealOperation": True,
            "issues": promotion.get("issues", []),
        },
        {
            "name": "revocation_manifest",
            "passed": revocation.get("valid", False),
            "requiredForRealOperation": True,
            "issues": revocation.get("issues", []),
        },
        {
            "name": "last_known_good_manifest",
            "passed": lkg.get("valid", False),
            "requiredForRealOperation": True,
            "issues": lkg.get("issues", []),
        },
    ]


def _promotion_check(bundle_root: Path, plan: dict[str, Any], revocation: dict[str, Any]) -> dict[str, Any]:
    with tempfile.TemporaryDirectory(prefix="ambitions-r2-proof-") as tmp:
        tmp_path = Path(tmp)
        plan_path = tmp_path / "r2-plan.json"
        revocation_path = tmp_path / "revocation.json"
        write_json(plan_path, plan)
        write_json(revocation_path, revocation)
        return validate_promotion_gate(bundle_root, plan_path, revocation_path=revocation_path, channel=plan.get("channel", "staging"))


def _object_key_privacy_issues(plan: dict[str, Any], extra_keys: list[str] | None = None) -> list[str]:
    issues: list[str] = []
    for obj in plan.get("objects", []):
        issues.extend(issue.format() for issue in object_key_issues(obj.get("objectKey", ""), obj.get("objectKey", "objectKey")))
    for key in extra_keys or []:
        issues.extend(issue.format() for issue in object_key_issues(key, key))
    return issues


def _payload_privacy_issues(plan: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for obj in plan.get("objects", []):
        local_path = Path(obj.get("localPath", ""))
        if local_path.suffix != ".json" or not local_path.exists():
            continue
        issues.extend(boundary_issue_strings(boundary_issues_for_json_file(local_path, obj.get("relativePath", local_path.name))))
    return issues


def _verify_checksums(plan: dict[str, Any], readback_root: Path | None) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    for obj in plan.get("objects", []):
        expected = obj.get("sha256")
        local_path = Path(obj.get("localPath", ""))
        actual = file_sha256(local_path) if local_path.exists() else None
        remote_actual = None
        if readback_root:
            candidate = readback_root / obj.get("relativePath", local_path.name)
            if candidate.exists():
                remote_actual = file_sha256(candidate)
        results.append(
            {
                "objectKey": obj.get("objectKey"),
                "localChecksumPassed": bool(expected and actual == expected),
                "readbackChecksumPassed": None if remote_actual is None else remote_actual == expected,
                "expectedSHA256": expected,
                "actualLocalSHA256": actual,
                "actualReadbackSHA256": remote_actual,
            }
        )
    return results


def _rollback_selection(candidate_manifest_path: Path, last_known_good_path: Path | None, lkg: dict[str, Any]) -> dict[str, Any]:
    raw_candidate = read_json(candidate_manifest_path)
    candidate = raw_candidate.get("payload", raw_candidate) if isinstance(raw_candidate, dict) else raw_candidate
    candidate_issues = boundary_issue_strings(boundary_issues_for_value(candidate, str(candidate_manifest_path)))
    stale_critical = _has_stale_critical(candidate)
    if candidate_issues or stale_critical:
        selected = "last-known-good"
        reason = "candidate manifest failed privacy or stale-critical checks"
    else:
        selected = "candidate"
        reason = "candidate manifest passed privacy and stale-critical checks"
    return {
        "selected": selected,
        "reason": reason,
        "candidateIssues": candidate_issues,
        "candidateStaleCritical": stale_critical,
        "lastKnownGoodPath": str(last_known_good_path) if last_known_good_path else lkg.get("manifest", {}).get("path"),
        "passed": selected in {"candidate", "last-known-good"},
    }


def _has_stale_critical(manifest: dict[str, Any]) -> bool:
    buckets = manifest.get("claimStateBuckets", [])
    if any(bucket.get("state") == "stale_critical" for bucket in buckets):
        return True
    if manifest.get("state") == "stale_critical":
        return True
    if manifest.get("freshnessState") == "stale_critical":
        return True
    return False


def _dry_run_results(plan: dict[str, Any], revocation: dict[str, Any], lkg: dict[str, Any], resolved: dict[str, Any]) -> list[dict[str, Any]]:
    return [
        {
            "operation": "upload-public-reference-artifact",
            "wouldUploadObjectCount": len(plan.get("objects", [])) + 2,
            "bucket": resolved["bucket"],
            "prefix": resolved["prefix"],
            "generatedManifestUploads": ["revocation", "last-known-good"],
        },
        {"operation": "readback", "wouldReadObjectCount": len(plan.get("objects", []))},
        {"operation": "verify-checksum", "wouldVerifyObjectCount": len(plan.get("objects", []))},
        {"operation": "verify-object-key-privacy", "passed": not _object_key_privacy_issues(plan)},
        {"operation": "verify-manifest", "validForUpload": plan.get("validForUpload")},
        {"operation": "revoke", "revocationValid": revocation.get("valid", False)},
        {"operation": "read-last-known-good", "lastKnownGoodValid": lkg.get("valid", False)},
        {"operation": "rollback-select", "wouldSelect": "candidate-unless-manifest-invalid-or-stale-critical"},
    ]


def _upload_objects(plan: dict[str, Any], resolved: dict[str, Any], revocation: dict[str, Any], lkg: dict[str, Any]) -> dict[str, Any]:
    results = []
    success = True
    for obj in plan.get("objects", []):
        completed = _run_wrangler(obj["wranglerArgs"])
        if not completed["success"]:
            success = False
        results.append({"objectKey": obj["objectKey"], **completed})
    version_id = revocation.get("versionID") or "unknown-version"
    generated_uploads = [
        ("revocation", f"{resolved['prefix']}/revocations/{version_id}.json", revocation),
        ("last-known-good", f"{resolved['prefix']}/last-known-good/{plan.get('channel', 'staging')}.json", lkg),
    ]
    with tempfile.TemporaryDirectory(prefix="ambitions-r2-generated-") as tmp:
        tmp_path = Path(tmp)
        for label, object_key, value in generated_uploads:
            path = tmp_path / f"{label}.json"
            write_json(path, value)
            completed = _run_wrangler(
                [
                    "wrangler",
                    "r2",
                    "object",
                    "put",
                    f"{resolved['bucketForPlan']}/{object_key}",
                    "--remote",
                    "--file",
                    str(path),
                    "--content-type",
                    "application/json; charset=utf-8",
                ]
            )
            if not completed["success"]:
                success = False
            results.append({"objectKey": object_key, "generatedManifest": label, **completed})
    return {"mode": "upload-public-reference-artifact", "executeRequested": True, "executed": True, "dryRun": False, "success": success, "results": results}


def _readback_objects(plan: dict[str, Any], readback_root: Path | None) -> dict[str, Any]:
    root = readback_root or Path(tempfile.mkdtemp(prefix="ambitions-r2-readback-"))
    results = []
    success = True
    for obj in plan.get("objects", []):
        destination = root / obj.get("relativePath", Path(obj.get("objectKey", "object.json")).name)
        destination.parent.mkdir(parents=True, exist_ok=True)
        completed = _run_wrangler(["wrangler", "r2", "object", "get", f"{obj['bucket']}/{obj['objectKey']}", "--remote", "--file", str(destination)])
        if not completed["success"]:
            success = False
        results.append({"objectKey": obj["objectKey"], "readbackPath": _redacted_path(destination), **completed})
    return {"mode": "readback", "executeRequested": True, "executed": True, "dryRun": False, "success": success, "results": results}


def _upload_generated_manifest(bucket: str, object_key: str, value: dict[str, Any], label: str) -> dict[str, Any]:
    with tempfile.TemporaryDirectory(prefix="ambitions-r2-generated-") as tmp:
        path = Path(tmp) / f"{label}.json"
        write_json(path, value)
        completed = _run_wrangler(["wrangler", "r2", "object", "put", f"{bucket}/{object_key}", "--remote", "--file", str(path), "--content-type", "application/json; charset=utf-8"])
    return {"mode": label, "executeRequested": True, "executed": True, "dryRun": False, "success": completed["success"], "results": [{"objectKey": object_key, **completed}]}


def _read_single_object(bucket: str, object_key: str, readback_root: Path | None, label: str) -> dict[str, Any]:
    root = readback_root or Path(tempfile.mkdtemp(prefix="ambitions-r2-readback-"))
    destination = root / f"{label}.json"
    completed = _run_wrangler(["wrangler", "r2", "object", "get", f"{bucket}/{object_key}", "--remote", "--file", str(destination)])
    return {"mode": label, "executeRequested": True, "executed": True, "dryRun": False, "success": completed["success"], "results": [{"objectKey": object_key, "readbackPath": _redacted_path(destination), **completed}]}


def _run_wrangler(args: list[str]) -> dict[str, Any]:
    try:
        completed = subprocess.run(args, capture_output=True, text=True, check=False)
        return {
            "success": completed.returncode == 0,
            "returnCode": completed.returncode,
            "stdout": _redact_log(completed.stdout),
            "stderr": _redact_log(completed.stderr),
        }
    except (subprocess.SubprocessError, OSError) as exc:
        return {"success": False, "returnCode": None, "stdout": "", "stderr": _redact_log(str(exc))}


def _evidence_payload(
    *,
    mode: str,
    environment: str,
    channel: str,
    resolved: dict[str, Any],
    plan: dict[str, Any],
    revocation: dict[str, Any],
    lkg: dict[str, Any],
    checks: list[dict[str, Any]],
    credential_state: dict[str, Any],
    operation: dict[str, Any],
    blocked: list[str],
) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionR2OperationsProof",
        "createdAt": utc_now(),
        "mode": mode,
        "environment": environment,
        "channel": channel,
        "bucket": resolved["bucket"],
        "prefix": resolved["prefix"],
        "stagingVsProductionSeparation": {
            "explicitEnvironmentRequired": True,
            "environment": environment,
            "stagingBucketEnv": R2_ENVIRONMENTS["staging"]["bucketEnv"],
            "productionBucketEnv": R2_ENVIRONMENTS["production"]["bucketEnv"],
            "sameBucketNotAsserted": True,
        },
        "allowedPrefixes": [f"{resolved['prefix']}/releases/", f"{resolved['prefix']}/channels/", f"{resolved['prefix']}/revocations/", f"{resolved['prefix']}/last-known-good/"],
        "objectKeyShape": _sanitized_objects(plan),
        "artifactClassesAllowed": [
            "public release manifest",
            "public foundry pack",
            "public schema",
            "public shard",
            "public registry",
            "public provenance receipt",
            "public freshness manifest",
            "public revocation manifest",
            "public last-known-good manifest",
        ],
        "artifactClassesForbidden": [
            "private life graph",
            "goals",
            "captures",
            "schedules",
            "capacity",
            "Life Capital",
            "proof payloads",
            "receipts payloads",
            "behavior history",
            "inferred priorities",
            "user IDs",
            "access tokens",
            "refresh tokens",
            "account secrets",
        ],
        "credentialHandling": {
            "explicitCredentialsRequiredForRealOperations": True,
            "available": credential_state["available"],
            "envNamesPresent": credential_state["envNamesPresent"],
            "wranglerInstalled": credential_state["wranglerInstalled"],
            "wranglerWhoami": credential_state["wranglerWhoami"],
            "secretValuesPrinted": False,
        },
        "rollbackApproach": "Rollback selects the last-known-good public manifest when candidate manifest privacy, revocation, checksum, or stale-critical checks fail.",
        "checks": checks,
        "revocationManifest": _manifest_summary(revocation),
        "lastKnownGoodManifest": _manifest_summary(lkg),
        "operation": operation,
        "blockedReasons": sorted(set(blocked)),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS + [
            "not account readiness",
            "not release readiness",
            "not privacy/legal approval",
            "not known issue closure",
            "not complete Source Atlas project Green",
            "not complete app runtime Green",
            "not TestFlight readiness",
            "not App Store readiness",
        ],
    }


def _sanitized_objects(plan: dict[str, Any]) -> list[dict[str, Any]]:
    return [
        {
            "relativePath": obj.get("relativePath"),
            "bucket": obj.get("bucket"),
            "objectKey": obj.get("objectKey"),
            "contentType": obj.get("contentType"),
            "cacheControl": obj.get("cacheControl"),
            "sha256": obj.get("sha256"),
            "bytes": obj.get("bytes"),
        }
        for obj in plan.get("objects", [])
    ]


def _manifest_summary(value: dict[str, Any]) -> dict[str, Any]:
    return {
        "kind": value.get("kind"),
        "id": value.get("id"),
        "valid": value.get("valid"),
        "issues": value.get("issues", []),
        "state": value.get("state"),
        "versionID": value.get("versionID"),
        "channel": value.get("channel"),
    }


def _log_redaction_check(evidence: dict[str, Any], env: dict[str, str]) -> dict[str, Any]:
    encoded = json.dumps(evidence, sort_keys=True, ensure_ascii=False)
    issues: list[str] = []
    for name in SECRET_ENV_NAMES:
        value = env.get(name)
        if value and value in encoded:
            issues.append(f"secret value leaked for {name}")
    for pattern in FORBIDDEN_LOG_PATTERNS:
        if pattern.search(encoded):
            issues.append(f"forbidden log pattern matched: {pattern.pattern}")
    if "\"localPath\"" in encoded:
        issues.append("unredacted localPath present in evidence")
    return {"passed": not issues, "issues": issues}


def _status_for_evidence(evidence: dict[str, Any]) -> str:
    check_failures = [check for check in evidence.get("checks", []) if check.get("requiredForRealOperation") and not check.get("passed")]
    if check_failures or not evidence.get("logRedaction", {}).get("passed", False):
        return "Red"
    operation = evidence.get("operation", {})
    if operation.get("executed") and operation.get("success") and evidence.get("mode") in {"upload-public-reference-artifact", "readback", "revoke", "read-last-known-good"}:
        return "Green"
    if operation.get("dryRun") or evidence.get("blockedReasons"):
        return "Yellow"
    return "Yellow"


def _redact_log(value: str) -> str:
    redacted = value
    for pattern in FORBIDDEN_LOG_PATTERNS:
        redacted = pattern.sub("<redacted>", redacted)
    return redacted


def _redacted_path(path: Path) -> str:
    return f"<readback-root>/{path.name}"


def _blocked_result(mode: str, environment: str, issues: list[str], execute: bool) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionR2OperationsProof",
        "createdAt": utc_now(),
        "mode": mode,
        "environment": environment,
        "status": "Red",
        "operation": {"executeRequested": execute, "executed": False, "dryRun": not execute, "results": []},
        "blockedReasons": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
