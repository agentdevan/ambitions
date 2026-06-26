"""R2 staging-plan and optional upload helpers for Source Atlas Foundry."""

from __future__ import annotations

import subprocess
from pathlib import Path
from typing import Any

from .model import file_sha256, read_json, utc_now, write_json
from .validator import validate_bundle, validate_r2_object_keys


CONTENT_TYPES = {
    ".json": "application/json; charset=utf-8",
    ".jsonl": "application/x-ndjson; charset=utf-8",
    ".md": "text/markdown; charset=utf-8",
}


def _artifact_entries(bundle_root: Path) -> list[Path]:
    manifest_path = bundle_root / "manifest.json"
    manifest = read_json(manifest_path)
    paths = {manifest_path}
    for key in ["packIndex", "schemaIndex", "shardIndex", "registryIndex"]:
        for entry in manifest.get(key, []):
            paths.add(bundle_root / entry["path"])
    for key in ["freshnessManifest", "receipt"]:
        if manifest.get(key):
            paths.add(bundle_root / manifest[key]["path"])
    return sorted(path for path in paths if path.exists() and path.suffix in CONTENT_TYPES)


def build_r2_plan(bundle_root: Path, bucket: str, prefix: str, channel: str = "staging") -> dict[str, Any]:
    validation = validate_bundle(bundle_root)
    clean_prefix = prefix.strip("/")
    version_id = bundle_root.name
    entries: list[dict[str, Any]] = []
    for path in _artifact_entries(bundle_root):
        relative = path.relative_to(bundle_root).as_posix()
        if relative == "manifest.json":
            object_key = f"{clean_prefix}/releases/{version_id}/manifest.json"
        else:
            object_key = f"{clean_prefix}/releases/{version_id}/{relative}"
        entries.append(
            {
                "localPath": str(path),
                "relativePath": relative,
                "bucket": bucket,
                "objectKey": object_key,
                "contentType": CONTENT_TYPES[path.suffix],
                "cacheControl": "public, max-age=300" if channel == "staging" else "public, max-age=3600",
                "sha256": file_sha256(path),
                "bytes": path.stat().st_size,
                "wranglerArgs": [
                    "wrangler",
                    "r2",
                    "object",
                    "put",
                    f"{bucket}/{object_key}",
                    "--remote",
                    "--file",
                    str(path),
                    "--content-type",
                    CONTENT_TYPES[path.suffix],
                    "--cache-control",
                    "public, max-age=300" if channel == "staging" else "public, max-age=3600",
                ],
            }
        )

    channel_manifest = bundle_root / "manifest.json"
    channel_key = f"{clean_prefix}/channels/{channel}/manifest.json"
    entries.append(
        {
            "localPath": str(channel_manifest),
            "relativePath": "manifest.json",
            "bucket": bucket,
            "objectKey": channel_key,
            "contentType": CONTENT_TYPES[".json"],
            "cacheControl": "public, max-age=120",
            "sha256": file_sha256(channel_manifest),
            "bytes": channel_manifest.stat().st_size,
            "wranglerArgs": [
                "wrangler",
                "r2",
                "object",
                "put",
                f"{bucket}/{channel_key}",
                "--remote",
                "--file",
                str(channel_manifest),
                "--content-type",
                CONTENT_TYPES[".json"],
                "--cache-control",
                "public, max-age=120",
            ],
        }
    )

    key_issues = validate_r2_object_keys([entry["objectKey"] for entry in entries])
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2StagingPlan",
        "createdAt": utc_now(),
        "bundleRoot": str(bundle_root),
        "bucket": bucket,
        "prefix": clean_prefix,
        "channel": channel,
        "validForUpload": validation["valid"] and not key_issues,
        "validation": validation,
        "objectKeyIssues": key_issues,
        "objects": entries,
        "secretBoundary": "Plan contains no R2 credentials. Upload requires an approved shell with scoped R2 write credentials.",
    }


def write_r2_plan(bundle_root: Path, bucket: str, prefix: str, channel: str, output_path: Path) -> dict[str, Any]:
    plan = build_r2_plan(bundle_root, bucket, prefix, channel)
    write_json(output_path, plan)
    return plan


def execute_r2_plan(plan: dict[str, Any], execute: bool, confirm_public_reference_only: bool) -> dict[str, Any]:
    if not confirm_public_reference_only:
        return {"success": False, "error": "upload blocked until public/reference-only confirmation is provided"}
    if not plan.get("validForUpload"):
        return {"success": False, "error": "upload blocked because plan is not validForUpload", "validation": plan.get("validation")}
    if not execute:
        return {"success": True, "dryRun": True, "objectCount": len(plan.get("objects", []))}

    results = []
    success = True
    for obj in plan.get("objects", []):
        try:
            completed = subprocess.run(obj["wranglerArgs"], capture_output=True, text=True, check=True)
            results.append({"objectKey": obj["objectKey"], "status": "uploaded", "stdout": completed.stdout})
        except (subprocess.CalledProcessError, FileNotFoundError) as exc:
            success = False
            stderr = getattr(exc, "stderr", "") or str(exc)
            results.append({"objectKey": obj["objectKey"], "status": "failed", "stderr": stderr})
    return {"success": success, "dryRun": False, "results": results}
