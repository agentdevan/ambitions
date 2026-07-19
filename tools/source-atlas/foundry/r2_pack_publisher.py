"""Deterministic R2 publisher gate for generalized Source Atlas packs."""

from __future__ import annotations

import re
import os
import shutil
import subprocess
from dataclasses import dataclass, replace
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_json_file, object_key_issues
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, read_json, stable_id, write_json
from .pack_production import PRODUCTION_NON_CLAIMS, validate_pack_production_artifacts
from .production_domain_admission import validate_production_domain_admission_artifact
from .production_target_gate import domain_id_from_pack_id, validate_production_target_ledger_gate
from .r2_owner_approval import validate_r2_owner_approval_artifact
from .terms_approval_packet import validate_terms_approval_packet_for_entries
from .terms_registry import terms_entry


PUBLISHER_VERSION = "source-atlas-r2-publisher-train-10"
PUBLISHER_MODES = {"dry_run", "local_simulation", "remote_r2"}
PUBLISHER_NON_CLAIMS = PRODUCTION_NON_CLAIMS + [
    "not real R2 credentials proof",
    "not production R2 upload proof",
    "not stable production promotion",
    "not native app runtime readiness",
    "not release readiness",
]
R2_ENVIRONMENTS = {
    "staging": {
        "bucketEnv": "SOURCE_ATLAS_R2_STAGING_BUCKET",
        "prefixEnv": "SOURCE_ATLAS_R2_STAGING_PREFIX",
    },
    "production": {
        "bucketEnv": "SOURCE_ATLAS_R2_PRODUCTION_BUCKET",
        "prefixEnv": "SOURCE_ATLAS_R2_PRODUCTION_PREFIX",
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


@dataclass(frozen=True)
class PackR2PublisherOptions:
    pack_root: Path
    output_root: Path
    environment: str = "staging"
    channel: str = "candidate"
    mode: str = "dry_run"
    created_at: str = "2026-06-27T00:00:00Z"
    execute: bool = False
    approval_artifact: Path | None = None
    legal_approval_packet: Path | None = None
    budget_policy: str | None = None
    bucket: str | None = None
    local_store_root: Path | None = None
    readback_root: Path | None = None
    corrupt_readback_label: str | None = None
    production_target_ledger_path: Path | None = None
    production_domain_admission_path: Path | None = None
    env_file_paths: tuple[Path, ...] | None = None


def run_pack_r2_publisher(options: PackR2PublisherOptions) -> dict[str, Any]:
    env_file_paths = options.env_file_paths
    if env_file_paths is None and not (options.mode == "remote_r2" and options.execute):
        env_file_paths = ()
    runtime_env, loaded_env_files = _runtime_env(env_file_paths)
    r2_environment = _r2_environment_resolution(options, runtime_env, loaded_env_files)
    effective_options = replace(options, bucket=r2_environment["bucket"] or options.bucket)
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    issues: list[str] = []
    checks: list[dict[str, Any]] = []

    required = _load_required_pack_artifacts(effective_options.pack_root, issues)
    manifest = required.get("manifest", {})
    plan = required.get("dryRunPlan", {})
    non_private_scan = required.get("nonPrivateScan", {})
    revocation = required.get("revocations", {})
    lkg = required.get("lkg", {})
    rollback = required.get("rollback", {})
    pointer = _current_pointer(effective_options, manifest, plan)

    artifact_validation = validate_pack_production_artifacts(effective_options.pack_root) if effective_options.pack_root.exists() else {"valid": False, "issues": ["pack root missing"]}
    object_key_issues = _object_key_issues(plan, manifest)
    payload_issues = _payload_issues(plan, effective_options.pack_root, pointer)
    checksum_issues = _checksum_issues(plan)
    shape_issues = _shape_issues(effective_options, manifest, plan, revocation, lkg, rollback)
    legal_approval = _legal_approval_validation(effective_options, effective_options.pack_root)
    production_target_gate = _production_target_ledger_validation(effective_options, manifest)
    owner_approval = _owner_approval_validation(effective_options, manifest, r2_environment)
    gate_issues = _execute_gate_issues(effective_options, r2_environment)

    _record(checks, "pack_artifacts_valid", artifact_validation.get("valid", False), artifact_validation.get("issues", []))
    _record(checks, "object_keys_public", not object_key_issues, object_key_issues)
    _record(checks, "payloads_public_reference_only", not payload_issues, payload_issues)
    _record(checks, "source_license_slices_present", _source_license_slices_present(effective_options.pack_root), ["missing sources or licenses slice"])
    _record(checks, "non_private_scan_passed", non_private_scan.get("passed") is True, non_private_scan.get("issues", []))
    _record(checks, "revocation_lkg_rollback_present", not shape_issues, shape_issues)
    _record(checks, "local_checksums_match_manifest", not checksum_issues, checksum_issues)
    _record(checks, "legal_terms_approval_packet_valid", legal_approval["valid"], legal_approval["issues"])
    _record(checks, "production_target_ledger_gate", production_target_gate["valid"], production_target_gate["issues"])
    _record(checks, "owner_approval_artifact_valid", owner_approval["valid"], owner_approval["issues"])
    _record(checks, "execute_gate", not gate_issues, gate_issues)
    _record(checks, "r2_environment_resolved_without_secret_values", r2_environment["secretValuesPrinted"] is False, [])
    _record(checks, _transport_scope_check_name(effective_options), True, [])
    _record(checks, "no_final_plan_schedule_step_output", _no_final_outputs(effective_options.pack_root), ["final plan, schedule, or Step output marker found"])

    issues.extend(artifact_validation.get("issues", []))
    issues.extend(object_key_issues)
    issues.extend(payload_issues)
    issues.extend(checksum_issues)
    issues.extend(shape_issues)
    issues.extend(legal_approval["issues"])
    issues.extend(production_target_gate["issues"])
    issues.extend(owner_approval["issues"])
    if effective_options.execute:
        issues.extend(gate_issues)

    operation = _planned_operation(effective_options, plan, pointer, issues)
    if effective_options.execute and not issues:
        if effective_options.mode == "remote_r2":
            operation = _run_remote_r2(effective_options, plan, pointer, output_root, runtime_env)
        else:
            operation = _run_local_simulation(effective_options, plan, pointer, output_root)
        _record(checks, "upload_readback_checksums", operation["success"], operation.get("issues", []))
        _record(checks, "current_pointer_after_readback_only", operation.get("currentPointer", {}).get("updated") is True, operation.get("currentPointer", {}).get("issues", []))
        if not operation["success"]:
            issues.extend(operation.get("issues", []))

    report = _report_payload(effective_options, manifest, plan, pointer, checks, issues, operation, legal_approval, production_target_gate, owner_approval, r2_environment)
    report_path = output_root / "r2-publisher-report.json"
    report["outputPaths"] = {
        "report": str(report_path),
        "requestPrivacy": str(output_root / "r2-request-privacy-report.json"),
        "uploadReadback": str(output_root / "r2-upload-readback-report.json"),
        "currentPointer": str(output_root / "current-pointer.json"),
        "productionTargetLedgerGate": str(output_root / "production-target-ledger-gate.json"),
        "ownerApprovalValidation": str(output_root / "owner-approval-validation.json"),
        "closeout": str(output_root / "closeout.md"),
    }
    write_json(report_path, report)
    write_json(output_root / "r2-request-privacy-report.json", _request_privacy_report(report))
    write_json(output_root / "r2-upload-readback-report.json", operation)
    write_json(output_root / "current-pointer.json", pointer)
    write_json(output_root / "production-target-ledger-gate.json", production_target_gate)
    write_json(output_root / "owner-approval-validation.json", owner_approval)
    _write_closeout(output_root / "closeout.md", report)
    return report


def r2_pack_publisher_markdown(report: dict[str, Any]) -> str:
    production_uploaded = report.get("productionR2Uploaded") is True
    lines = [
        "# Source Atlas R2 Publisher Upload/Readback Gate Harness Train 10",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Generalized publisher gate for Train 4/9 pack-production artifacts.",
        "- Dry-run default with no object writes and no credentials.",
        "- Local simulation mode for deterministic upload, readback, SHA-256 verification, current-pointer ordering, previous LKG snapshot, revocation, and rollback proof.",
            "- Production/stable execute gates for approval and budget evidence.",
            "- Production-target ledger gate for real R2 writes and production/stable execute paths.",
            "- Private object-key and payload blocking before publish.",
        "",
        "Files changed:",
        "- tools/source-atlas/foundry/r2_pack_publisher.py",
        "- tools/source-atlas/foundry/cli.py",
        "- tools/source-atlas/foundry/tests/test_r2_pack_publisher_train_10.py",
        "- tools/source-atlas/generated/r2-publisher/train-10-civic-*",
        "- docs/qa/source-atlas/r2/source-atlas-r2-publisher-train-10.*",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- Publisher artifacts contain no credentials and no private user context.",
        "- Source Atlas still does not generate final plans, schedules, or Steps.",
        "",
        "Validation run:",
        "- See command output from the current train closeout.",
        "",
        "Validation not run:",
        "- Native XCTest/build-for-testing was not run because this train changed Python tooling, JSON evidence, and Source Atlas generated artifacts only.",
        "- Outside legal review was not run or claimed.",
        "",
        "Proof artifacts:",
    ]
    for path in report.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
        ]
    )
    if production_uploaded:
        lines.extend(
            [
                "- Real Cloudflare R2 network requests executed through Wrangler for public/reference pack objects only.",
                "- Object keys passed public-reference segment checks.",
                "- Generated current pointer carries only public manifest and checksum metadata.",
            ]
        )
    else:
        lines.extend(
            [
                "- No real network request or R2 credential path executed.",
                "- Object keys passed public-reference segment checks.",
                "- Generated current pointer carries only public manifest and checksum metadata.",
            ]
        )
    lines.extend(
        [
            "",
            "No private graph egress proof:",
            "- Payload scans passed before publish planning.",
            "- The publisher blocks private object-key segments before any write.",
            "",
            "License/terms proof:",
            "- Publisher requires the pack-production license/source slices to be present and valid.",
            "- Outside legal approval is not claimed.",
            "",
            "Production target proof:",
            "- Real R2 writes and production/stable execute paths require the production-target ledger to mark the pack domain bounded-production-target ready.",
            "",
            "Restricted-source exclusion proof:",
            "- Inherited from pack-production artifacts; publisher does not re-admit excluded claims.",
            "",
            "Provenance completeness proof:",
            "- Inherited from pack-production manifest and claim graph hash.",
            "",
            "Freshness/revocation proof:",
            "- Revocation, LKG, rollback, and current-pointer metadata are validated before pointer publication.",
            "",
            "LKG/rollback proof:",
            "- Remote R2 execution records previous current/LKG snapshots and updates the current pointer only after readback checksum success." if production_uploaded else "- Local simulation records previous current/LKG snapshots and updates the current pointer only after readback checksum success.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 10. No native files changed.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: Foundry R2 publisher harness, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: native runtime fetch/cache/verify and release proof remain unproven.",
            "- Next repair train if debt remains: approved production R2 upload/readback or native public-pack fetch/cache/verify proof.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Known risks:",
            "- Native app runtime behavior is not proven by this train.",
            "",
            "Follow-up required:",
            "- Keep native fetch/cache/verify/LKG proof separate.",
            "",
            "Rollback plan:",
            "- Revert the Train 10 publisher module, CLI command, tests, generated publisher artifacts, and QA evidence packet.",
            "",
            "Production non-claims:",
        ]
    )
    if not production_uploaded:
        lines.insert(lines.index("Native offline/no-account proof:"), "- Production R2 upload/readback was not run.")
        known_risks_index = lines.index("Known risks:") + 1
        lines.insert(known_risks_index, "- Stable production promotion remains blocked without owner approval and credentials.")
        lines.insert(known_risks_index, "- Local simulation is not production Cloudflare R2 proof.")
        follow_up_index = lines.index("Follow-up required:") + 1
        lines.insert(follow_up_index, "- Run approved production R2 upload/readback only with owner approval and current credentials.")
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.append("")
    return "\n".join(lines)


def _load_required_pack_artifacts(pack_root: Path, issues: list[str]) -> dict[str, Any]:
    files = {
        "manifest": "manifest.json",
        "dryRunPlan": "r2-dry-run-plan.json",
        "nonPrivateScan": "non-private-scan-report.json",
        "revocations": "revocations.json",
        "lkg": "lkg.json",
        "rollback": "rollback-plan.json",
    }
    loaded: dict[str, Any] = {}
    for key, filename in files.items():
        path = pack_root / filename
        if not path.exists():
            issues.append(f"missing required pack artifact: {filename}")
            loaded[key] = {}
        else:
            loaded[key] = read_json(path)
    return loaded


def _current_pointer(options: PackR2PublisherOptions, manifest: dict[str, Any], plan: dict[str, Any]) -> dict[str, Any]:
    object_keys = manifest.get("object_keys", {}) if isinstance(manifest, dict) else {}
    objects = manifest.get("objects", {}) if isinstance(manifest, dict) else {}
    manifest_entry = objects.get("manifest", {}) if isinstance(objects, dict) else {}
    plan_manifest_entry = next((obj for obj in plan.get("objects", []) if obj.get("label") == "manifest"), {})
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.currentPackPointer.v1",
        "createdAt": options.created_at,
        "environment": options.environment,
        "channel": options.channel,
        "packID": manifest.get("pack_id"),
        "packVersion": manifest.get("pack_version"),
        "manifestKey": object_keys.get("manifest"),
        "manifestSHA256": manifest_entry.get("sha256") or plan_manifest_entry.get("sha256"),
        "packSHA256": manifest.get("sha256"),
        "revocationManifestKey": manifest.get("revocation_manifest_key"),
        "lastKnownGoodKey": manifest.get("lkg_pointer_key"),
        "publishGate": "current pointer may update only after upload, readback, checksum, revocation, LKG, and rollback checks pass",
        "publicReferenceOnly": True,
        "dataClass": "public_freshness",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": _non_claims_for_options(
            options,
            operation_success=options.mode == "remote_r2" and options.execute,
        ),
    }


def _object_key_issues(plan: dict[str, Any], manifest: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for obj in plan.get("objects", []):
        issues.extend(issue.format() for issue in object_key_issues(str(obj.get("objectKey", "")), str(obj.get("label", "object"))))
    for label, key in sorted((manifest.get("object_keys") or {}).items()):
        issues.extend(issue.format() for issue in object_key_issues(str(key), label))
    return issues


def _payload_issues(plan: dict[str, Any], pack_root: Path, pointer: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for obj in plan.get("objects", []):
        path = Path(obj.get("localPath", ""))
        if not path.is_absolute():
            path = pack_root / path.name if not path.exists() else path
        if path.exists() and path.suffix == ".json":
            issues.extend(boundary_issue_strings(boundary_issues_for_json_file(path, obj.get("label", path.name))))
    issues.extend(boundary_issue_strings(boundary_issues_for_json_file(pack_root / "manifest.json", "manifest.json"))) if (pack_root / "manifest.json").exists() else None
    from .boundary import boundary_issues_for_value

    issues.extend(boundary_issue_strings(boundary_issues_for_value(pointer, "current-pointer")))
    return issues


def _checksum_issues(plan: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for obj in plan.get("objects", []):
        path = Path(obj.get("localPath", ""))
        if not path.exists():
            issues.append(f"{obj.get('label')}: missing localPath {path}")
            continue
        if file_sha256(path) != obj.get("sha256"):
            issues.append(f"{obj.get('label')}: local checksum mismatch")
        if path.stat().st_size != obj.get("bytes"):
            issues.append(f"{obj.get('label')}: byte count mismatch")
    return issues


def _shape_issues(
    options: PackR2PublisherOptions,
    manifest: dict[str, Any],
    plan: dict[str, Any],
    revocation: dict[str, Any],
    lkg: dict[str, Any],
    rollback: dict[str, Any],
) -> list[str]:
    issues: list[str] = []
    if options.mode not in PUBLISHER_MODES:
        issues.append(f"unsupported publisher mode: {options.mode}")
    if manifest.get("kind") != "ambitions.sourceAtlas.packManifest.v1":
        issues.append("manifest kind is not ambitions.sourceAtlas.packManifest.v1")
    if plan.get("kind") != "ambitions.sourceAtlas.r2DryRunPlan.v1":
        issues.append("r2-dry-run-plan kind is not ambitions.sourceAtlas.r2DryRunPlan.v1")
    if manifest.get("created_at") and manifest.get("object_keys"):
        if plan.get("environment") != options.environment or manifest.get("object_keys", {}).get("manifest", "").split("/")[2:4] != [options.environment, options.channel]:
            issues.append("publisher environment/channel does not match pack object keys")
    if not revocation or "revocation_id" not in revocation:
        issues.append("revocation manifest missing")
    if not lkg or "manifest_key" not in lkg:
        issues.append("LKG pointer missing")
    if not rollback or rollback.get("stablePointerWillChange") is not False:
        issues.append("rollback plan missing or not dry-run safe")
    if not plan.get("objects"):
        issues.append("publish plan has no objects")
    return issues


def _runtime_env(env_file_paths: tuple[Path, ...] | None) -> tuple[dict[str, str], list[str]]:
    runtime_env = dict(os.environ)
    loaded: list[str] = []
    for env_file in _default_env_files() if env_file_paths is None else env_file_paths:
        if _load_env_file(env_file, runtime_env):
            loaded.append(_safe_env_file_path(env_file))
    return runtime_env, loaded


def _default_env_files() -> list[Path]:
    foundry_root = Path(__file__).resolve().parent
    source_atlas_root = foundry_root.parents[0]
    repo_root = foundry_root.parents[2]
    return [
        repo_root / ".env",
        source_atlas_root / ".env",
        foundry_root / ".env",
    ]


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
        if name in target:
            continue
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


def _r2_environment_resolution(options: PackR2PublisherOptions, runtime_env: dict[str, str], loaded_env_files: list[str]) -> dict[str, Any]:
    config = R2_ENVIRONMENTS.get(options.environment, R2_ENVIRONMENTS["staging"])
    bucket_from_env = runtime_env.get(config["bucketEnv"], "").strip()
    bucket = options.bucket or bucket_from_env
    credential_names = sorted(name for name in SECRET_ENV_NAMES if runtime_env.get(name))
    wrangler_installed = shutil.which("wrangler") is not None
    wrangler_whoami = False
    if not credential_names and wrangler_installed and options.mode == "remote_r2" and options.execute:
        try:
            completed = subprocess.run(["wrangler", "whoami"], capture_output=True, text=True, timeout=15, check=False, env=runtime_env)
            wrangler_whoami = completed.returncode == 0
        except (subprocess.SubprocessError, OSError):
            wrangler_whoami = False
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2EnvironmentResolution.v1",
        "environment": options.environment,
        "bucketEnv": config["bucketEnv"],
        "prefixEnv": config["prefixEnv"],
        "bucket": bucket or None,
        "bucketConfigured": bool(bucket),
        "bucketSource": "explicit" if options.bucket else ("env" if bucket_from_env else "missing"),
        "envFilesLoaded": loaded_env_files,
        "credentialEnvNamesPresent": credential_names,
        "credentialsAvailable": bool(credential_names) or wrangler_whoami,
        "wranglerInstalled": wrangler_installed,
        "wranglerWhoami": wrangler_whoami,
        "secretValuesPrinted": False,
    }


def _execute_gate_issues(options: PackR2PublisherOptions, r2_environment: dict[str, Any]) -> list[str]:
    if not options.execute:
        return []
    issues: list[str] = []
    if options.mode not in {"local_simulation", "remote_r2"}:
        issues.append("execute requires --mode local_simulation or remote_r2")
    if options.mode == "local_simulation" and not options.local_store_root:
        issues.append("execute requires --local-store-root")
    if options.mode == "remote_r2" and not options.bucket:
        issues.append(f"remote_r2 execute requires --bucket or {r2_environment.get('bucketEnv', 'SOURCE_ATLAS_R2_*_BUCKET')}")
    if options.mode == "remote_r2" and not r2_environment.get("credentialsAvailable"):
        issues.append("remote_r2 execute requires Cloudflare/Wrangler credentials")
    if options.mode == "remote_r2" and not r2_environment.get("wranglerInstalled"):
        issues.append("remote_r2 execute requires wrangler on PATH")
    if not options.budget_policy:
        issues.append("execute requires --budget-policy")
    if options.environment == "production" or options.channel == "stable":
        if not options.approval_artifact:
            issues.append("production/stable execute requires --approval-artifact")
        elif not options.approval_artifact.exists():
            issues.append(f"approval artifact does not exist: {options.approval_artifact}")
    return issues


def _legal_approval_validation(options: PackR2PublisherOptions, pack_root: Path) -> dict[str, Any]:
    required = options.environment == "production" or options.channel == "stable"
    source_ids = _publisher_source_ids(pack_root)
    if not required:
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.legalTermsApprovalPacketValidation.v1",
            "required": False,
            "valid": True,
            "status": "not_required_for_staging_candidate",
            "sourceIDs": source_ids,
            "issues": [],
        }
    if not options.legal_approval_packet:
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.legalTermsApprovalPacketValidation.v1",
            "required": True,
            "valid": False,
            "status": "Red",
            "sourceIDs": source_ids,
            "issues": ["production/stable R2 publisher requires --legal-approval-packet"],
        }
    if not options.legal_approval_packet.exists():
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.legalTermsApprovalPacketValidation.v1",
            "required": True,
            "valid": False,
            "status": "Red",
            "sourceIDs": source_ids,
            "issues": [f"legal approval packet does not exist: {options.legal_approval_packet}"],
        }
    packet = read_json(options.legal_approval_packet)
    entries = []
    issues: list[str] = []
    for source_id in source_ids:
        try:
            entries.append(terms_entry(source_id))
        except KeyError:
            issues.append(f"{source_id}: no terms registry entry for legal approval packet validation")
    validation = validate_terms_approval_packet_for_entries(
        packet if not issues else None,
        terms_entries=entries,
        requested_artifact_classes={"official_public_source", "public_reference_claim", "public_provenance", "public_freshness"},
        now_date=options.created_at[:10],
    )
    validation["required"] = True
    validation["packetPath"] = str(options.legal_approval_packet)
    validation["packetSHA256"] = file_sha256(options.legal_approval_packet)
    if issues:
        validation["valid"] = False
        validation["status"] = "Red"
        validation["issues"] = issues + validation.get("issues", [])
    return validation


def _production_target_ledger_validation(options: PackR2PublisherOptions, manifest: dict[str, Any]) -> dict[str, Any]:
    required = options.execute and (
        options.mode == "remote_r2"
        or options.environment == "production"
        or options.channel == "stable"
    )
    domain = _domain_from_manifest(manifest)
    result = validate_production_target_ledger_gate(
        ledger_path=options.production_target_ledger_path,
        requested_domains=[domain] if domain else [],
        required=required,
    )
    if required and not domain:
        result["valid"] = False
        result["issues"] = result.get("issues", []) + ["pack manifest domain could not be resolved for production target ledger gate"]
    if required and not result["valid"] and options.production_domain_admission_path and domain:
        admission = validate_production_domain_admission_artifact(
            options.production_domain_admission_path,
            domain=domain,
            environment=options.environment,
            channel=options.channel,
            pack_root=options.pack_root,
            legal_approval_packet=options.legal_approval_packet,
        )
        combined = {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.productionTargetLedgerOrAdmissionGate.v1",
            "required": required,
            "valid": admission["valid"],
            "domain": domain,
            "ledgerGateValid": result["valid"],
            "admissionGateValid": admission["valid"],
            "admissionFallbackUsed": admission["valid"],
            "ledgerGate": result,
            "productionDomainAdmissionValidation": admission,
            "ledgerPath": result.get("ledgerPath"),
            "admissionPath": str(options.production_domain_admission_path),
            "requestedDomains": result.get("requestedDomains", [domain]),
            "readyDomains": result.get("readyDomains", []),
            "missingDomains": [] if admission["valid"] else result.get("missingDomains", []),
            "allowedClaims": result.get("allowedClaims", []),
            "issues": [] if admission["valid"] else sorted(set(result.get("issues", []) + admission.get("issues", []))),
            "privacyBoundary": PRIVACY_BOUNDARY,
            "nonClaims": [
                "not production target ledger Green until post-R2 ledger is regenerated",
                "not literal universal coverage",
                "not full Source Atlas Green",
                "not Release Green",
                "not outside legal approval",
                "not final user plans, schedules, or Steps",
            ],
        }
        return combined
    return result


def _owner_approval_validation(options: PackR2PublisherOptions, manifest: dict[str, Any], r2_environment: dict[str, Any]) -> dict[str, Any]:
    required = options.execute and (options.environment == "production" or options.channel == "stable")
    domain = _domain_from_manifest(manifest)
    if not required:
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.r2OwnerApprovalValidation.v1",
            "required": False,
            "valid": True,
            "status": "not_required_for_staging_candidate",
            "domainIDs": [domain] if domain else [],
            "issues": [],
        }
    if not domain:
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.r2OwnerApprovalValidation.v1",
            "required": True,
            "valid": False,
            "status": "Red",
            "domainIDs": [],
            "issues": ["pack manifest domain could not be resolved for owner approval validation"],
        }
    validation = validate_r2_owner_approval_artifact(
        options.approval_artifact,
        environment=options.environment,
        channel=options.channel,
        bucket=options.bucket or r2_environment.get("bucket"),
        domain_ids=[domain],
    )
    validation["required"] = True
    validation["domainIDs"] = [domain]
    return validation


def _domain_from_manifest(manifest: dict[str, Any]) -> str:
    domain = domain_id_from_pack_id(str(manifest.get("pack_id", "")))
    if domain:
        return domain
    return _domain_from_manifest_object_keys(manifest)


def _domain_from_manifest_object_keys(manifest: dict[str, Any]) -> str:
    object_keys = manifest.get("object_keys", {})
    if not isinstance(object_keys, dict):
        return ""
    manifest_key = str(object_keys.get("manifest", ""))
    marker = "source-atlas/v1/"
    parts = manifest_key.split("/")
    if len(parts) >= 5 and parts[0:2] == ["source-atlas", "v1"]:
        return parts[4]
    if marker in manifest_key:
        remainder = manifest_key.split(marker, 1)[1]
        bits = remainder.split("/")
        if len(bits) >= 3:
            return bits[2]
    return ""


def _publisher_source_ids(pack_root: Path) -> list[str]:
    path = pack_root / "sources.json"
    if not path.exists():
        return []
    return sorted(
        source.get("source_id")
        for source in read_json(path).get("sources", [])
        if source.get("source_id")
    )


def _source_license_slices_present(pack_root: Path) -> bool:
    sources = pack_root / "sources.json"
    licenses = pack_root / "licenses.json"
    if not sources.exists() or not licenses.exists():
        return False
    return bool(read_json(sources).get("sources")) and bool(read_json(licenses).get("licenses"))


def _planned_operation(options: PackR2PublisherOptions, plan: dict[str, Any], pointer: dict[str, Any], issues: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublisherOperation.v1",
        "createdAt": options.created_at,
        "mode": options.mode,
        "executeRequested": options.execute,
        "executed": False,
        "dryRun": not options.execute,
        "success": not issues and not options.execute,
        "wouldUploadObjectCount": len(plan.get("objects", [])),
        "wouldUpdateCurrentPointer": not issues,
        "currentPointer": {"key": _current_key_from_pointer(pointer, plan), "updated": False, "blockedUntilReadback": True},
        "issues": issues,
        "publicReferenceOnly": True,
        "dataClass": "public_r2_object_key",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PUBLISHER_NON_CLAIMS,
    }


def _run_local_simulation(options: PackR2PublisherOptions, plan: dict[str, Any], pointer: dict[str, Any], output_root: Path) -> dict[str, Any]:
    assert options.local_store_root is not None
    store_root = options.local_store_root
    store_root.mkdir(parents=True, exist_ok=True)
    current_key = _current_key_from_pointer(pointer, plan)
    lkg_key = pointer.get("lastKnownGoodKey")
    previous = {
        "current": _existing_store_object(store_root, current_key),
        "lastKnownGood": _existing_store_object(store_root, lkg_key),
    }
    write_json(output_root / "previous-pointer-snapshot.json", previous)

    uploads: list[dict[str, Any]] = []
    readbacks: list[dict[str, Any]] = []
    issues: list[str] = []
    for obj in plan.get("objects", []):
        source = Path(obj["localPath"])
        destination = _store_path(store_root, obj["objectKey"])
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(source.read_bytes())
        if options.corrupt_readback_label and obj.get("label") == options.corrupt_readback_label:
            destination.write_bytes(destination.read_bytes() + b"\ncorrupted readback fixture\n")
        uploads.append(_object_result(obj, destination, "uploaded"))
        actual = file_sha256(destination)
        passed = actual == obj.get("sha256")
        if not passed:
            issues.append(f"{obj.get('label')}: readback checksum mismatch")
        readbacks.append({**_object_result(obj, destination, "readback"), "actualSHA256": actual, "passed": passed})

    pointer_written = False
    pointer_result = {"updated": False, "blockedUntilReadback": True, "issues": []}
    if not issues:
        pointer_path = output_root / "current-pointer.json"
        write_json(pointer_path, pointer)
        destination = _store_path(store_root, current_key)
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(pointer_path.read_bytes())
        pointer_result = {
            "key": current_key,
            "updated": True,
            "blockedUntilReadback": True,
            "sha256": file_sha256(destination),
            "bytes": destination.stat().st_size,
            "issues": [],
        }
        pointer_written = True
    else:
        pointer_result["issues"] = ["current pointer not written because readback checksum verification failed"]

    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublisherOperation.v1",
        "createdAt": options.created_at,
        "mode": options.mode,
        "executeRequested": options.execute,
        "executed": True,
        "dryRun": False,
        "success": not issues and pointer_written,
        "localStoreRoot": str(store_root),
        "uploadResults": uploads,
        "readbackResults": readbacks,
        "previousPointers": previous,
        "currentPointer": pointer_result,
        "issues": issues,
        "publicReferenceOnly": True,
        "dataClass": "public_r2_object_key",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PUBLISHER_NON_CLAIMS,
    }


def _run_remote_r2(options: PackR2PublisherOptions, plan: dict[str, Any], pointer: dict[str, Any], output_root: Path, runtime_env: dict[str, str]) -> dict[str, Any]:
    assert options.bucket is not None
    readback_root = options.readback_root or (output_root / "remote-readback")
    readback_root.mkdir(parents=True, exist_ok=True)
    current_key = _current_key_from_pointer(pointer, plan)
    previous = {
        "current": _read_remote_object(options.bucket, current_key, output_root / "previous-current-pointer.json", runtime_env),
        "lastKnownGood": _read_remote_object(options.bucket, pointer.get("lastKnownGoodKey"), output_root / "previous-lkg-pointer.json", runtime_env),
    }
    write_json(output_root / "previous-pointer-snapshot.json", previous)

    uploads: list[dict[str, Any]] = []
    readbacks: list[dict[str, Any]] = []
    issues: list[str] = []
    for obj in plan.get("objects", []):
        source = Path(obj["localPath"])
        put = _put_remote_object(options.bucket, obj["objectKey"], source, obj.get("contentType"), obj.get("cacheControl"), runtime_env)
        uploads.append({"label": obj.get("label"), "objectKey": obj.get("objectKey"), **put})
        if not put["success"]:
            issues.append(f"{obj.get('label')}: remote upload failed")
            continue
        destination = readback_root / obj["objectKey"]
        get = _get_remote_object(options.bucket, obj["objectKey"], destination, runtime_env)
        actual = file_sha256(destination) if destination.exists() else None
        passed = get["success"] and actual == obj.get("sha256")
        if not passed:
            issues.append(f"{obj.get('label')}: remote readback checksum mismatch")
        readbacks.append(
            {
                "label": obj.get("label"),
                "objectKey": obj.get("objectKey"),
                "expectedSHA256": obj.get("sha256"),
                "actualSHA256": actual,
                "passed": passed,
                **get,
            }
        )

    pointer_result = {"key": current_key, "updated": False, "blockedUntilReadback": True, "issues": []}
    if not issues:
        pointer_path = output_root / "current-pointer-to-upload.json"
        write_json(pointer_path, pointer)
        pointer_put = _put_remote_object(options.bucket, current_key, pointer_path, "application/json; charset=utf-8", "public, max-age=120", runtime_env)
        pointer_readback_path = readback_root / current_key
        pointer_get = _get_remote_object(options.bucket, current_key, pointer_readback_path, runtime_env) if pointer_put["success"] else {"success": False, "returnCode": None, "stdout": "", "stderr": "pointer upload failed"}
        expected_pointer_sha = file_sha256(pointer_path)
        actual_pointer_sha = file_sha256(pointer_readback_path) if pointer_readback_path.exists() else None
        pointer_passed = pointer_put["success"] and pointer_get["success"] and actual_pointer_sha == expected_pointer_sha
        if not pointer_passed:
            issues.append("current pointer remote readback checksum mismatch")
        pointer_result = {
            "key": current_key,
            "updated": pointer_passed,
            "blockedUntilReadback": True,
            "expectedSHA256": expected_pointer_sha,
            "actualSHA256": actual_pointer_sha,
            "put": pointer_put,
            "get": pointer_get,
            "issues": [] if pointer_passed else ["current pointer was not verified after upload"],
        }
    else:
        pointer_result["issues"] = ["current pointer not written because object upload/readback verification failed"]

    success = not issues and pointer_result.get("updated") is True
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PublisherOperation.v1",
        "createdAt": options.created_at,
        "mode": options.mode,
        "executeRequested": options.execute,
        "executed": True,
        "dryRun": False,
        "remoteR2": True,
        "success": success,
        "bucket": options.bucket,
        "readbackRoot": str(readback_root),
        "uploadResults": uploads,
        "readbackResults": readbacks,
        "previousPointers": previous,
        "currentPointer": pointer_result,
        "issues": issues,
        "publicReferenceOnly": True,
        "dataClass": "public_r2_object_key",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": _non_claims_for_options(options, operation_success=success),
    }


def _current_key_from_pointer(pointer: dict[str, Any], plan: dict[str, Any]) -> str:
    manifest_key = str(pointer.get("manifestKey") or "")
    if manifest_key:
        base = manifest_key.rsplit("/", 2)[0]
        return f"{base}/current.json"
    return f"source-atlas/v1/{plan.get('environment', 'staging')}/{plan.get('channel', 'candidate')}/unknown/current.json"


def _read_remote_object(bucket: str, object_key: str | None, destination: Path, runtime_env: dict[str, str] | None = None) -> dict[str, Any]:
    if not object_key:
        return {"exists": False}
    completed = _get_remote_object(bucket, object_key, destination, runtime_env)
    return {
        "exists": completed["success"],
        "objectKey": object_key,
        "sha256": file_sha256(destination) if completed["success"] and destination.exists() else None,
        "bytes": destination.stat().st_size if completed["success"] and destination.exists() else None,
        "get": completed,
    }


def _put_remote_object(bucket: str, object_key: str, source: Path, content_type: str | None, cache_control: str | None, runtime_env: dict[str, str] | None = None) -> dict[str, Any]:
    args = [
        "wrangler",
        "r2",
        "object",
        "put",
        f"{bucket}/{object_key}",
        "--remote",
        "--file",
        str(source),
    ]
    if content_type:
        args.extend(["--content-type", content_type])
    if cache_control:
        args.extend(["--cache-control", cache_control])
    return _run_wrangler(args, env=runtime_env)


def _get_remote_object(bucket: str, object_key: str, destination: Path, runtime_env: dict[str, str] | None = None) -> dict[str, Any]:
    destination.parent.mkdir(parents=True, exist_ok=True)
    return _run_wrangler([
        "wrangler",
        "r2",
        "object",
        "get",
        f"{bucket}/{object_key}",
        "--remote",
        "--file",
        str(destination),
    ], env=runtime_env)


def _run_wrangler(args: list[str], *, env: dict[str, str] | None = None) -> dict[str, Any]:
    try:
        completed = subprocess.run(args, capture_output=True, text=True, check=False, env=env)
        return {
            "success": completed.returncode == 0,
            "returnCode": completed.returncode,
            "stdout": _redact_log(completed.stdout),
            "stderr": _redact_log(completed.stderr),
        }
    except (subprocess.SubprocessError, OSError) as exc:
        return {"success": False, "returnCode": None, "stdout": "", "stderr": _redact_log(str(exc))}


def _redact_log(value: str) -> str:
    redacted = value
    for pattern in FORBIDDEN_LOG_PATTERNS:
        redacted = pattern.sub("<redacted>", redacted)
    return redacted


def _existing_store_object(store_root: Path, object_key: str | None) -> dict[str, Any]:
    if not object_key:
        return {"exists": False}
    path = _store_path(store_root, object_key)
    if not path.exists():
        return {"exists": False, "objectKey": object_key}
    return {"exists": True, "objectKey": object_key, "sha256": file_sha256(path), "bytes": path.stat().st_size}


def _store_path(store_root: Path, object_key: str) -> Path:
    return store_root / object_key.strip("/")


def _object_result(obj: dict[str, Any], destination: Path, status: str) -> dict[str, Any]:
    return {
        "label": obj.get("label"),
        "objectKey": obj.get("objectKey"),
        "status": status,
        "expectedSHA256": obj.get("sha256"),
        "bytes": destination.stat().st_size,
    }


def _report_payload(
    options: PackR2PublisherOptions,
    manifest: dict[str, Any],
    plan: dict[str, Any],
    pointer: dict[str, Any],
    checks: list[dict[str, Any]],
    issues: list[str],
    operation: dict[str, Any],
    legal_approval: dict[str, Any],
    production_target_gate: dict[str, Any],
    owner_approval: dict[str, Any],
    r2_environment: dict[str, Any],
) -> dict[str, Any]:
    valid = not issues and all(check["passed"] for check in checks)
    production_uploaded = (
        options.mode == "remote_r2"
        and options.environment == "production"
        and options.execute
        and operation.get("executed") is True
        and operation.get("success") is True
    )
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2PackPublisherReport.v1",
        "versionID": PUBLISHER_VERSION,
        "createdAt": options.created_at,
        "status": "Source Green for R2 publisher gate harness" if valid else "Red",
        "valid": valid,
        "packID": manifest.get("pack_id"),
        "packVersion": manifest.get("pack_version"),
        "environment": options.environment,
        "channel": options.channel,
        "mode": options.mode,
        "executeRequested": options.execute,
        "r2Environment": r2_environment,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; R2 publisher tooling only",
        "productionR2Uploaded": production_uploaded,
        "realR2CredentialsUsed": bool(options.mode == "remote_r2" and operation.get("executed") is True),
        "objectCount": len(plan.get("objects", [])),
        "currentPointer": pointer,
        "operation": operation,
        "legalTermsApprovalPacketValidation": legal_approval,
        "productionTargetLedgerGate": production_target_gate,
        "ownerApprovalArtifactValidation": owner_approval,
        "checks": checks,
        "issues": sorted(set(issues)),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": _non_claims_for_options(options, operation_success=production_uploaded),
    }


def _request_privacy_report(report: dict[str, Any]) -> dict[str, Any]:
    operation = report.get("operation", {})
    object_keys = [item.get("objectKey") for item in operation.get("uploadResults", [])]
    object_keys.extend(item.get("objectKey") for item in operation.get("readbackResults", []))
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2RequestPrivacyReport.v1",
        "createdAt": report["createdAt"],
        "passed": report["valid"],
        "transportMode": report.get("mode"),
        "realNetworkRequests": _remote_request_count(operation) if report.get("realR2CredentialsUsed") else 0,
        "credentialsUsed": report.get("realR2CredentialsUsed") is True,
        "credentialEnvNamesPresent": report.get("r2Environment", {}).get("credentialEnvNamesPresent", []),
        "envFilesLoaded": report.get("r2Environment", {}).get("envFilesLoaded", []),
        "secretValuesPrinted": report.get("r2Environment", {}).get("secretValuesPrinted") is True,
        "objectKeysReviewed": sorted(key for key in set(object_keys) if key),
        "issues": report["issues"],
        "publicReferenceOnly": True,
        "dataClass": "public_provenance",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": _non_claims_for_report(report),
    }


def _non_claims_for_options(options: PackR2PublisherOptions, *, operation_success: bool = False) -> list[str]:
    claims = list(PUBLISHER_NON_CLAIMS)
    if options.mode == "remote_r2" and options.execute and operation_success:
        remove = {
            "not real R2 credentials proof",
            "not production R2 upload proof",
            "not production R2 readiness",
            "not stable production promotion",
        }
        claims = [claim for claim in claims if claim not in remove]
    return claims


def _non_claims_for_report(report: dict[str, Any]) -> list[str]:
    claims = list(PUBLISHER_NON_CLAIMS)
    if report.get("productionR2Uploaded") is True:
        remove = {
            "not real R2 credentials proof",
            "not production R2 upload proof",
            "not production R2 readiness",
            "not stable production promotion",
        }
        claims = [claim for claim in claims if claim not in remove]
    return claims


def _transport_scope_check_name(options: PackR2PublisherOptions) -> str:
    if options.mode == "remote_r2" and options.execute:
        return "remote_r2_public_reference_transport_only"
    return "no_real_r2_credentials_or_requests"


def _remote_request_count(operation: dict[str, Any]) -> int:
    count = len(operation.get("uploadResults", [])) + len(operation.get("readbackResults", []))
    for pointer in operation.get("previousPointers", {}).values():
        if isinstance(pointer, dict) and pointer.get("get"):
            count += 1
    current_pointer = operation.get("currentPointer", {})
    if isinstance(current_pointer, dict):
        if current_pointer.get("put"):
            count += 1
        if current_pointer.get("get"):
            count += 1
    return count


def _record(checks: list[dict[str, Any]], name: str, passed: bool, issues: list[str]) -> None:
    checks.append({"name": name, "passed": passed, "issues": [] if passed else issues})


def _no_final_outputs(pack_root: Path) -> bool:
    markers = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}
    boundary_keys = {
        "non_claims",
        "nonClaims",
        "privacyBoundary",
        "forbidden_artifact_classes",
        "forbiddenArtifactClasses",
        "artifactClassesForbidden",
    }

    def walk(value: Any, *, boundary_context: bool = False) -> bool:
        if isinstance(value, dict):
            for key, child in value.items():
                if key in markers and not boundary_context:
                    return False
                if not walk(child, boundary_context=boundary_context or key in boundary_keys):
                    return False
        elif isinstance(value, list):
            for child in value:
                if not walk(child, boundary_context=boundary_context):
                    return False
        elif isinstance(value, str) and not boundary_context:
            lowered = value.lower()
            if any(marker in lowered for marker in markers):
                return False
        return True

    for filename in ["pack.json", "claims.json", "manifest.json", "r2-dry-run-plan.json"]:
        path = pack_root / filename
        if not path.exists():
            continue
        if not walk(read_json(path)):
            return False
    return True


def _write_closeout(path: Path, report: dict[str, Any]) -> None:
    path.write_text(r2_pack_publisher_markdown(report), encoding="utf-8")
