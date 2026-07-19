"""Gated cleanup for Red Source Atlas objects in the production R2 bucket."""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import object_key_issues
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, read_json, stable_id, write_json
from .r2_live_inventory import R2S3Client, _environment_resolution, _runtime_env


R2_HYGIENE_CLEANUP_KIND = "ambitions.sourceAtlas.r2ProductionHygieneCleanup.v1"
R2_HYGIENE_CLEANUP_VERSION = "source-atlas-r2-hygiene-cleanup-train-136"


@dataclass(frozen=True)
class R2HygieneCleanupOptions:
    inventory_path: Path
    output_root: Path
    bucket: str = "ambitions-source-atlas-prod"
    prefix: str = "source-atlas/"
    env_file_paths: tuple[Path, ...] | None = None
    account_id: str | None = None
    created_at: str = "2026-06-29T00:00:00Z"
    execute: bool = False


def run_r2_hygiene_cleanup(options: R2HygieneCleanupOptions) -> dict[str, Any]:
    inventory = read_json(options.inventory_path)
    output_root = options.output_root
    backup_root = output_root / "backup"
    output_root.mkdir(parents=True, exist_ok=True)

    runtime_env, loaded_env_files = _runtime_env(options.env_file_paths)
    env_resolution = _environment_resolution(_inventory_options_adapter(options), runtime_env, loaded_env_files)
    targets = _red_hygiene_targets(inventory)
    expected_keys = {item["objectKey"] for item in inventory.get("expectedObjects", [])}
    target_issues = _target_issues(targets, expected_keys, options, inventory)
    env_issues = env_resolution["issues"] if not env_resolution["valid"] else []
    issues = target_issues + env_issues

    backups: list[dict[str, Any]] = []
    deletes: list[dict[str, Any]] = []
    post_delete_present: list[str] = []
    live_before_count = 0
    live_after_count = 0

    if env_resolution["valid"]:
        client = R2S3Client(
            account_id=env_resolution["_accountIDValue"],
            access_key_id=env_resolution["_accessKeyIDValue"],
            secret_access_key=env_resolution["_secretAccessKeyValue"],
            bucket=options.bucket,
        )
        try:
            live_before = client.list_objects(prefix=options.prefix)
            live_before_count = len(live_before)
        except Exception as exc:  # pragma: no cover - exact urllib exception varies.
            issues.append(f"cleanup preflight list failed: {type(exc).__name__}: {exc}")
            live_before = []
        live_before_keys = {item["objectKey"] for item in live_before}
        missing_before = sorted(item["objectKey"] for item in targets if item["objectKey"] not in live_before_keys)
        issues.extend(f"cleanup target already absent before delete: {key}" for key in missing_before)

        if options.execute and not issues:
            for target in targets:
                key = target["objectKey"]
                try:
                    payload = client.get_object_bytes(key)
                    backup = _write_backup(backup_root, target, payload)
                    backups.append(backup)
                    client.delete_object(key)
                    deletes.append(
                        {
                            "objectKey": key,
                            "classification": target["classification"],
                            "severity": target["severity"],
                            "deleted": True,
                            "backupSHA256": backup["sha256"],
                            "backupBytes": backup["bytes"],
                        }
                    )
                except Exception as exc:  # pragma: no cover - exact urllib exception varies.
                    issue = f"cleanup delete failed for {key}: {type(exc).__name__}: {exc}"
                    issues.append(issue)
                    deletes.append(
                        {
                            "objectKey": key,
                            "classification": target["classification"],
                            "severity": target["severity"],
                            "deleted": False,
                            "issue": issue,
                        }
                    )
        elif not options.execute:
            deletes = [
                {
                    "objectKey": item["objectKey"],
                    "classification": item["classification"],
                    "severity": item["severity"],
                    "deleted": False,
                    "wouldDelete": True,
                }
                for item in targets
            ]

        if options.execute and not any(delete.get("deleted") is False for delete in deletes):
            try:
                live_after = client.list_objects(prefix=options.prefix)
                live_after_count = len(live_after)
                live_after_keys = {item["objectKey"] for item in live_after}
                post_delete_present = sorted(item["objectKey"] for item in targets if item["objectKey"] in live_after_keys)
                issues.extend(f"cleanup target still present after delete: {key}" for key in post_delete_present)
            except Exception as exc:  # pragma: no cover - exact urllib exception varies.
                issues.append(f"cleanup post-delete list failed: {type(exc).__name__}: {exc}")

    checks = [
        _check("inventory_has_red_hygiene_targets", bool(targets), ["no Red hygiene targets found"] if not targets else []),
        _check("targets_are_hygiene_red_only", not target_issues, target_issues),
        _check("r2_environment_resolved_without_secret_values", env_resolution["valid"], env_issues),
        _check("cleanup_execute_requested", options.execute, ["dry-run only; no R2 object was deleted"] if not options.execute else []),
        _check(
            "backup_readback_sha256_recorded",
            (not options.execute) or len(backups) == len(targets),
            [] if (not options.execute) or len(backups) == len(targets) else ["not every target has backup readback evidence"],
        ),
        _check("red_targets_deleted", (not options.execute) or all(item.get("deleted") for item in deletes), [item.get("issue", item["objectKey"]) for item in deletes if not item.get("deleted")]),
        _check("deleted_targets_absent_after_readback", (not options.execute) or not post_delete_present, post_delete_present),
    ]
    valid = options.execute and all(check["passed"] for check in checks)
    status = "Source Green for R2 production bucket hygiene cleanup" if valid else "Red for R2 production bucket hygiene cleanup"
    if not options.execute and not issues:
        status = "Yellow dry-run for R2 production bucket hygiene cleanup"
    report = {
        "schemaVersion": 1,
        "kind": R2_HYGIENE_CLEANUP_KIND,
        "versionID": R2_HYGIENE_CLEANUP_VERSION,
        "cleanupID": stable_id(
            "source-atlas/r2-hygiene-cleanup",
            {
                "inventory": str(options.inventory_path),
                "bucket": options.bucket,
                "prefix": options.prefix,
                "createdAt": options.created_at,
                "targetCount": len(targets),
                "execute": options.execute,
            },
        ),
        "createdAt": options.created_at,
        "status": status,
        "valid": valid,
        "bucket": options.bucket,
        "prefix": options.prefix,
        "inventoryPath": str(options.inventory_path),
        "inventorySHA256": file_sha256(options.inventory_path),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "environment": _redacted_environment(env_resolution),
        "checks": checks,
        "issues": sorted(set(issues)),
        "recordCounts": {
            "redTargets": len(targets),
            "backupReadbacks": len(backups),
            "deletedObjects": sum(1 for item in deletes if item.get("deleted") is True),
            "deleteFailures": sum(1 for item in deletes if item.get("deleted") is False and not item.get("wouldDelete")),
            "dryRunWouldDelete": sum(1 for item in deletes if item.get("wouldDelete") is True),
            "stillPresentAfterDelete": len(post_delete_present),
            "liveObjectsBefore": live_before_count,
            "liveObjectsAfter": live_after_count,
            "expectedCurrentObjectsProtected": len(expected_keys),
        },
        "targets": targets,
        "backups": backups,
        "deletes": deletes,
        "postDeletePresentTargets": post_delete_present,
        "nonClaims": NON_CLAIMS + [
            "not R2 release readiness",
            "not Source Atlas universal coverage",
            "not app runtime R2 fetch/cache proof",
            "not entitlement-gated access proof",
            "not legal/privacy release approval",
        ],
    }
    report_path = output_root / "r2-hygiene-cleanup-report.json"
    markdown_path = output_root / "r2-hygiene-cleanup-report.md"
    closeout_path = output_root / "closeout.md"
    report["outputPaths"] = {
        "report": str(report_path),
        "markdown": str(markdown_path),
        "closeout": str(closeout_path),
        "backupManifest": str(backup_root / "backup-manifest.json"),
    }
    write_json(report_path, report)
    markdown = r2_hygiene_cleanup_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    if backups:
        write_json(backup_root / "backup-manifest.json", {"createdAt": options.created_at, "bucket": options.bucket, "backups": backups})
    return report


def r2_hygiene_cleanup_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas R2 Hygiene Cleanup",
        "",
        f"Status: {report['status']}",
        f"Bucket: `{report['bucket']}`",
        f"Prefix: `{report['prefix']}`",
        f"Inventory: `{report['inventoryPath']}`",
        f"Inventory SHA-256: `{report['inventorySHA256']}`",
        "",
        "Counts:",
        f"- Red targets: {counts['redTargets']}",
        f"- Backup readbacks: {counts['backupReadbacks']}",
        f"- Deleted objects: {counts['deletedObjects']}",
        f"- Delete failures: {counts['deleteFailures']}",
        f"- Still present after delete: {counts['stillPresentAfterDelete']}",
        f"- Live objects before: {counts['liveObjectsBefore']}",
        f"- Live objects after: {counts['liveObjectsAfter']}",
        f"- Expected current objects protected: {counts['expectedCurrentObjectsProtected']}",
        "",
        "Boundaries:",
        "- Deletes only Red hygiene objects from the referenced strict inventory.",
        "- Refuses to target objects enumerated by the current production target ledger.",
        "- Backs up every deleted payload locally and records SHA-256/byte evidence before deletion.",
        "- Does not publish, harvest, update current pointers, or alter user/private data.",
        "",
        "Checks:",
    ]
    lines.extend(f"- {check['name']}: {'pass' if check['passed'] else 'fail'}" for check in report.get("checks", []))
    lines.extend(["", "Non-claims:"])
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.append("")
    return "\n".join(lines)


def _red_hygiene_targets(inventory: dict[str, Any]) -> list[dict[str, Any]]:
    targets = [
        item for item in inventory.get("hygiene", {}).get("classifiedUnexpectedObjects", [])
        if item.get("severity") == "Red"
    ]
    return sorted(targets, key=lambda item: item["objectKey"])


def _target_issues(targets: list[dict[str, Any]], expected_keys: set[str], options: R2HygieneCleanupOptions, inventory: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    if inventory.get("bucket") and inventory["bucket"] != options.bucket:
        issues.append(f"inventory bucket {inventory['bucket']} does not match cleanup bucket {options.bucket}")
    if inventory.get("prefix") and inventory["prefix"] != options.prefix:
        issues.append(f"inventory prefix {inventory['prefix']} does not match cleanup prefix {options.prefix}")
    for item in targets:
        key = item.get("objectKey", "")
        if key in expected_keys:
            issues.append(f"cleanup target is a current expected production object: {key}")
        if not key.startswith(options.prefix):
            issues.append(f"cleanup target is outside inventory prefix: {key}")
        if item.get("severity") != "Red":
            issues.append(f"cleanup target is not Red: {key}")
        issues.extend(issue.format() for issue in object_key_issues(key, "r2-hygiene-cleanup-target"))
    return sorted(set(issues))


def _write_backup(backup_root: Path, target: dict[str, Any], payload: bytes) -> dict[str, Any]:
    sha256 = hashlib.sha256(payload).hexdigest()
    object_dir = backup_root / "objects"
    object_dir.mkdir(parents=True, exist_ok=True)
    payload_path = object_dir / f"{sha256}.payload"
    payload_path.write_bytes(payload)
    return {
        "objectKey": target["objectKey"],
        "classification": target["classification"],
        "severity": target["severity"],
        "bytes": len(payload),
        "sha256": sha256,
        "backupPath": str(payload_path),
    }


def _inventory_options_adapter(options: R2HygieneCleanupOptions) -> Any:
    return type(
        "R2InventoryOptionsAdapter",
        (),
        {
            "env_file_paths": options.env_file_paths,
            "account_id": options.account_id,
            "bucket": options.bucket,
            "prefix": options.prefix,
        },
    )()


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": issues}


def _redacted_environment(environment: dict[str, Any]) -> dict[str, Any]:
    return {key: value for key, value in environment.items() if not key.startswith("_")}
