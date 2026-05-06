#!/usr/bin/env python3
"""Validate Ambitions gate result manifests.

This is intentionally lightweight and dependency-free. It validates the required
machine-readable closeout schema without turning all advisory gates into hard CI
policy.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

SCHEMA_VERSION = "gate-result-manifest.v1"
BATCH_RESULTS = {"green", "accepted_yellow", "recoverable_red", "hard_red"}
GATE_STATUSES = {"pass", "accepted_yellow", "recoverable_red", "hard_red", "not_applicable", "not_run"}
GATE_MODES = {"strict", "advisory", "manual"}
VALIDATION_STATUSES = {"pass", "fail", "not_run"}
SCRIPT_STATUSES = {"pass", "advisory_warning", "failed", "not_run"}
ARTIFACT_KINDS = {"report", "fixture", "manifest", "rendered_proof", "source_seed", "other"}
ARTIFACT_CLASSES = {"evidence", "research_seed", "production", "docs_only"}

REQUIRED_TOP_LEVEL = {
    "schema_version",
    "manifest_id",
    "created_at",
    "batch",
    "git",
    "mode",
    "skills_invoked",
    "scripts_invoked",
    "gates",
    "validation_commands",
    "artifacts",
    "yellow_items",
    "red_items",
    "no_claim_boundaries",
    "release_claims",
}

REQUIRED_BATCH = {"id", "name", "train", "result", "active_before", "next_eligible"}
REQUIRED_GIT = {
    "branch",
    "base_sha",
    "head_sha",
    "remote_main_sha",
    "commit_sha",
    "commit_author",
    "commit_timestamp",
    "working_tree_clean",
}
REQUIRED_MODE = {"strict", "advisory", "reason"}
REQUIRED_RELEASE = {
    "testflight_ready",
    "app_store_ready",
    "legal_compliance_claimed",
    "production_source_truth_claimed",
}


def fail(errors: list[str], path: Path, message: str) -> None:
    errors.append(f"{path}: {message}")


def require_keys(errors: list[str], path: Path, obj: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(obj.keys()))
    if missing:
        fail(errors, path, f"missing {label} keys: {', '.join(missing)}")


def validate_manifest(path: Path) -> list[str]:
    errors: list[str] = []
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:  # noqa: BLE001 - report parse errors clearly
        return [f"{path}: invalid JSON: {exc}"]

    if not isinstance(data, dict):
        return [f"{path}: manifest must be a JSON object"]

    require_keys(errors, path, data, REQUIRED_TOP_LEVEL, "top-level")
    if data.get("schema_version") != SCHEMA_VERSION:
        fail(errors, path, f"schema_version must be {SCHEMA_VERSION!r}")

    batch = data.get("batch", {})
    if isinstance(batch, dict):
        require_keys(errors, path, batch, REQUIRED_BATCH, "batch")
        if batch.get("result") not in BATCH_RESULTS:
            fail(errors, path, f"batch.result must be one of {sorted(BATCH_RESULTS)}")
    else:
        fail(errors, path, "batch must be an object")

    git = data.get("git", {})
    if isinstance(git, dict):
        require_keys(errors, path, git, REQUIRED_GIT, "git")
        if not isinstance(git.get("working_tree_clean"), bool):
            fail(errors, path, "git.working_tree_clean must be boolean")
        if batch.get("result") == "green" and git.get("working_tree_clean") is not True:
            fail(errors, path, "green result requires git.working_tree_clean=true")
    else:
        fail(errors, path, "git must be an object")

    mode = data.get("mode", {})
    if isinstance(mode, dict):
        require_keys(errors, path, mode, REQUIRED_MODE, "mode")
        if not isinstance(mode.get("strict"), bool):
            fail(errors, path, "mode.strict must be boolean")
        if not isinstance(mode.get("advisory"), bool):
            fail(errors, path, "mode.advisory must be boolean")
    else:
        fail(errors, path, "mode must be an object")

    gates = data.get("gates", [])
    if not isinstance(gates, list):
        fail(errors, path, "gates must be a list")
    else:
        for idx, gate in enumerate(gates):
            if not isinstance(gate, dict):
                fail(errors, path, f"gates[{idx}] must be an object")
                continue
            for key in ["gate_id", "gate_name", "family", "status", "mode", "evidence", "notes", "owner"]:
                if key not in gate:
                    fail(errors, path, f"gates[{idx}] missing {key}")
            if gate.get("status") not in GATE_STATUSES:
                fail(errors, path, f"gates[{idx}].status invalid: {gate.get('status')!r}")
            if gate.get("mode") not in GATE_MODES:
                fail(errors, path, f"gates[{idx}].mode invalid: {gate.get('mode')!r}")
            if not isinstance(gate.get("evidence", []), list):
                fail(errors, path, f"gates[{idx}].evidence must be a list")

    scripts = data.get("scripts_invoked", [])
    if not isinstance(scripts, list):
        fail(errors, path, "scripts_invoked must be a list")
    else:
        for idx, script in enumerate(scripts):
            if not isinstance(script, dict):
                fail(errors, path, f"scripts_invoked[{idx}] must be an object")
                continue
            for key in ["script", "command", "status", "exit_code", "strict_mode", "summary"]:
                if key not in script:
                    fail(errors, path, f"scripts_invoked[{idx}] missing {key}")
            if script.get("status") not in SCRIPT_STATUSES:
                fail(errors, path, f"scripts_invoked[{idx}].status invalid")

    validations = data.get("validation_commands", [])
    if not isinstance(validations, list):
        fail(errors, path, "validation_commands must be a list")
    else:
        for idx, command in enumerate(validations):
            if not isinstance(command, dict):
                fail(errors, path, f"validation_commands[{idx}] must be an object")
                continue
            for key in ["command", "status", "summary"]:
                if key not in command:
                    fail(errors, path, f"validation_commands[{idx}] missing {key}")
            if command.get("status") not in VALIDATION_STATUSES:
                fail(errors, path, f"validation_commands[{idx}].status invalid")

    artifacts = data.get("artifacts", [])
    if not isinstance(artifacts, list):
        fail(errors, path, "artifacts must be a list")
    else:
        for idx, artifact in enumerate(artifacts):
            if not isinstance(artifact, dict):
                fail(errors, path, f"artifacts[{idx}] must be an object")
                continue
            for key in ["path", "kind", "classification", "production_use"]:
                if key not in artifact:
                    fail(errors, path, f"artifacts[{idx}] missing {key}")
            if artifact.get("kind") not in ARTIFACT_KINDS:
                fail(errors, path, f"artifacts[{idx}].kind invalid")
            if artifact.get("classification") not in ARTIFACT_CLASSES:
                fail(errors, path, f"artifacts[{idx}].classification invalid")
            if not isinstance(artifact.get("production_use"), bool):
                fail(errors, path, f"artifacts[{idx}].production_use must be boolean")

    release = data.get("release_claims", {})
    if isinstance(release, dict):
        require_keys(errors, path, release, REQUIRED_RELEASE, "release_claims")
        for key in REQUIRED_RELEASE:
            if not isinstance(release.get(key), bool):
                fail(errors, path, f"release_claims.{key} must be boolean")
        if release.get("production_source_truth_claimed"):
            for artifact in artifacts if isinstance(artifacts, list) else []:
                if artifact.get("classification") == "research_seed" and artifact.get("production_use") is False:
                    fail(errors, path, "production_source_truth_claimed cannot rely on research_seed artifacts")
    else:
        fail(errors, path, "release_claims must be an object")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Ambitions gate result manifests")
    parser.add_argument("paths", nargs="*", help="Manifest files or directories. Defaults to docs/audits/gate-results")
    args = parser.parse_args()

    inputs = [Path(p) for p in args.paths] if args.paths else [Path("docs/audits/gate-results")]
    files: list[Path] = []
    for item in inputs:
        if item.is_dir():
            files.extend(sorted(item.glob("*.json")))
        elif item.is_file():
            files.append(item)
        else:
            print(f"Gate manifest path not found: {item}", file=sys.stderr)
            return 1

    if not files:
        print("No gate result manifests found.")
        return 0

    all_errors: list[str] = []
    for file in files:
        all_errors.extend(validate_manifest(file))

    if all_errors:
        print("Gate result manifest validation failed:", file=sys.stderr)
        for error in all_errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(f"Validated {len(files)} gate result manifest(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
