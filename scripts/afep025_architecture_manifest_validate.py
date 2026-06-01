#!/usr/bin/env python3
"""Validate the AFEP-025 executable architecture manifest and its drift fixtures."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "docs" / "codex" / "AFEP_EXECUTABLE_ARCHITECTURE_MANIFEST.json"
DEFAULT_FIXTURES = ROOT / "fixtures" / "afep025"

EXPECTED_AUTHORITY_PREFIX = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
]

EXPECTED_CANONICAL_IA = ["Today", "Goals", "Capture", "Time", "You"]
EXPECTED_PRIMARY_OBJECTS = {
    "Today": "Reality Meridian / Start Here",
    "Goals": "Constellation Atlas",
    "Capture": "Atmosphere Composer",
    "Time": "LifeShape Field",
    "You": "User System Profile",
}
EXPECTED_ARTIFACT_CLASSES = {
    "active",
    "supporting",
    "deprecated",
    "archived",
    "historical",
    "generated",
    "local-only",
    "proof-only",
}
EXPECTED_PROVENANCE_CONCEPTS = {
    "SourceRecord",
    "Receipt",
    "ReplayTrace",
    "You / What Ambitions knows",
}
EXPECTED_REQUIRED_KEYWORDS = {
    "docs/truth/*",
    "live source",
    "current proof evidence",
}
EXPECTED_PRIVACY_BOUNDARY = {
    "user_data_stays_local_first": True,
    "silent_sync_forbidden": True,
    "privacy_manifest_honesty_required": True,
    "user_control_required": True,
}


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def as_dict(value: Any, label: str, errors: list[str]) -> dict[str, Any]:
    if not isinstance(value, dict):
        errors.append(f"{label} must be a JSON object")
        return {}
    return value


def as_list(value: Any, label: str, errors: list[str]) -> list[Any]:
    if not isinstance(value, list):
        errors.append(f"{label} must be a JSON array")
        return []
    return value


def check_value(errors: list[str], ok: bool, message: str) -> None:
    if not ok:
        errors.append(message)


def validate_manifest(manifest: dict[str, Any], *, label: str) -> list[str]:
    errors: list[str] = []

    required_keys = {
        "schema_version",
        "status",
        "batch_id",
        "owner_issue",
        "purpose",
        "authority_order",
        "supporting_not_authority",
        "authority_statement",
        "source_truth_precedence",
        "canonical_ia",
        "primary_objects",
        "object_grammar",
        "local_first_authority",
        "core_llm",
        "hosted_backend",
        "telemetry",
        "privacy_boundary",
        "release_proof",
        "release_readiness",
        "artifact_classification",
        "provenance_concepts",
        "hard_red_drift_conditions",
        "validation_boundaries",
        "rollback_governance",
        "claim_boundaries",
    }

    for key in sorted(required_keys - set(manifest)):
        errors.append(f"{label} missing key: {key}")

    check_value(errors, manifest.get("schema_version") == 1, f"{label} schema_version must be 1")
    check_value(errors, manifest.get("status") == "active", f"{label} status must be active")
    check_value(errors, manifest.get("batch_id") == "AFEP-025", f"{label} batch_id must be AFEP-025")
    check_value(errors, manifest.get("owner_issue") == "AMB-419", f"{label} owner_issue must be AMB-419")

    authority_order = as_list(manifest.get("authority_order"), f"{label}.authority_order", errors)
    if authority_order[: len(EXPECTED_AUTHORITY_PREFIX)] != EXPECTED_AUTHORITY_PREFIX:
        errors.append(f"{label} authority_order must start with the docs/truth authority order")
    for path_text in authority_order:
        if not isinstance(path_text, str):
            errors.append(f"{label} authority_order entries must be strings")
            continue
        if not (ROOT / path_text).exists():
            errors.append(f"{label} authority_order path missing: {path_text}")

    authority_statement = str(manifest.get("authority_statement", ""))
    for keyword in EXPECTED_REQUIRED_KEYWORDS:
        check_value(errors, keyword in authority_statement, f"{label} authority_statement must mention {keyword}")
    check_value(
        errors,
        "subordinate" in authority_statement.lower() and "may not override" in authority_statement.lower(),
        f"{label} authority_statement must say the manifest is subordinate and cannot override higher authority",
    )

    source_truth_precedence = as_list(manifest.get("source_truth_precedence"), f"{label}.source_truth_precedence", errors)
    check_value(
        errors,
        source_truth_precedence == ["docs/truth/*", "live source", "current proof evidence", "this manifest"],
        f"{label} source_truth_precedence must be docs/truth/*, live source, current proof evidence, then this manifest",
    )

    canonical_ia = as_list(manifest.get("canonical_ia"), f"{label}.canonical_ia", errors)
    check_value(errors, canonical_ia == EXPECTED_CANONICAL_IA, f"{label} canonical_ia must be Today / Goals / Capture / Time / You")

    primary_objects = as_dict(manifest.get("primary_objects"), f"{label}.primary_objects", errors)
    for surface, expected in EXPECTED_PRIMARY_OBJECTS.items():
        check_value(errors, primary_objects.get(surface) == expected, f"{label} primary_objects[{surface}] must be {expected}")
    check_value(errors, "Plan" not in primary_objects, f"{label} primary_objects must not include Plan")

    object_grammar = as_dict(manifest.get("object_grammar"), f"{label}.object_grammar", errors)
    for surface in EXPECTED_PRIMARY_OBJECTS:
        check_value(errors, surface in object_grammar, f"{label} object_grammar must describe {surface}")

    local_first_authority = as_dict(manifest.get("local_first_authority"), f"{label}.local_first_authority", errors)
    check_value(errors, local_first_authority.get("core_runtime") == "local-first and deterministic", f"{label} core_runtime must be local-first and deterministic")
    check_value(errors, local_first_authority.get("source_of_truth") == "local repo source plus current proof evidence", f"{label} source_of_truth must stay local repo source plus current proof evidence")
    check_value(errors, local_first_authority.get("cloud_ai") == "optional user-controlled extension only", f"{label} cloud_ai must be optional user-controlled extension only")
    check_value(errors, local_first_authority.get("cloudkit_continuity") == "optional continuity only, never the source of truth", f"{label} cloudkit_continuity must stay optional continuity only and not source of truth")
    check_value(errors, local_first_authority.get("hosted_backend_launch") == "not required", f"{label} hosted_backend_launch must be not required")

    core_llm = as_dict(manifest.get("core_llm"), f"{label}.core_llm", errors)
    check_value(errors, core_llm.get("required_for_core_behavior") is False, f"{label} core_llm.required_for_core_behavior must be false")
    check_value(errors, "not part of core architecture" in str(core_llm.get("rule", "")).lower(), f"{label} core_llm.rule must reject core cloud LLM dependency")

    hosted_backend = as_dict(manifest.get("hosted_backend"), f"{label}.hosted_backend", errors)
    check_value(errors, hosted_backend.get("required_for_launch") is False, f"{label} hosted_backend.required_for_launch must be false")
    check_value(errors, "not required for launch" in str(hosted_backend.get("rule", "")).lower(), f"{label} hosted_backend.rule must reject launch-time backend requirement")

    telemetry = as_dict(manifest.get("telemetry"), f"{label}.telemetry", errors)
    check_value(errors, telemetry.get("approval_required_for_sdk") is True, f"{label} telemetry.approval_required_for_sdk must be true")
    check_value(errors, "without explicit approval" in str(telemetry.get("rule", "")).lower(), f"{label} telemetry.rule must require explicit approval")

    privacy_boundary = as_dict(manifest.get("privacy_boundary"), f"{label}.privacy_boundary", errors)
    for key, expected in EXPECTED_PRIVACY_BOUNDARY.items():
        check_value(errors, privacy_boundary.get(key) is expected, f"{label} privacy_boundary.{key} must be {expected}")

    release_proof = as_dict(manifest.get("release_proof"), f"{label}.release_proof", errors)
    check_value(errors, release_proof.get("local_validation_is_not_release_proof") is True, f"{label} release_proof.local_validation_is_not_release_proof must be true")
    check_value(errors, release_proof.get("device_proof_required_for_device_claims") is True, f"{label} release_proof.device_proof_required_for_device_claims must be true")
    check_value(errors, release_proof.get("accessibility_proof_required_for_accessibility_claims") is True, f"{label} release_proof.accessibility_proof_required_for_accessibility_claims must be true")
    check_value(errors, release_proof.get("privacy_proof_required_for_privacy_claims") is True, f"{label} release_proof.privacy_proof_required_for_privacy_claims must be true")
    check_value(errors, release_proof.get("ci_proof_required_for_ci_claims") is True, f"{label} release_proof.ci_proof_required_for_ci_claims must be true")
    check_value(errors, release_proof.get("production_proof_required_for_production_claims") is True, f"{label} release_proof.production_proof_required_for_production_claims must be true")

    release_readiness = as_dict(manifest.get("release_readiness"), f"{label}.release_readiness", errors)
    check_value(errors, release_readiness.get("claimed") is False, f"{label} release_readiness.claimed must be false")
    check_value(errors, release_readiness.get("proof_required") is True, f"{label} release_readiness.proof_required must be true")
    check_value(errors, "proof" in str(release_readiness.get("rule", "")).lower(), f"{label} release_readiness.rule must require proof")

    artifact_classification = set(as_list(manifest.get("artifact_classification"), f"{label}.artifact_classification", errors))
    check_value(errors, artifact_classification == EXPECTED_ARTIFACT_CLASSES, f"{label} artifact_classification must match the required lifecycle classes")

    provenance_concepts = set(as_list(manifest.get("provenance_concepts"), f"{label}.provenance_concepts", errors))
    check_value(errors, provenance_concepts == EXPECTED_PROVENANCE_CONCEPTS, f"{label} provenance_concepts must match the required provenance references")

    hard_red_drift_conditions = set(as_list(manifest.get("hard_red_drift_conditions"), f"{label}.hard_red_drift_conditions", errors))
    for required in {
        "top-level Plan reintroduction",
        "required cloud or core LLM dependency",
        "hosted backend launch requirement",
        "analytics or telemetry SDK without explicit approval",
        "CloudKit treated as source of truth",
        "release or readiness claims without proof",
        "privacy boundary drift",
    }:
        check_value(errors, required in hard_red_drift_conditions, f"{label} hard_red_drift_conditions must include: {required}")

    validation_boundaries = set(as_list(manifest.get("validation_boundaries"), f"{label}.validation_boundaries", errors))
    for required in {
        "local validation is not release proof",
        "local validation is not device proof",
        "local validation is not accessibility proof",
        "local validation is not privacy proof",
        "local validation is not CI proof",
        "local validation is not production proof",
    }:
        check_value(errors, required in validation_boundaries, f"{label} validation_boundaries must include: {required}")

    rollback_governance = as_dict(manifest.get("rollback_governance"), f"{label}.rollback_governance", errors)
    check_value(errors, rollback_governance.get("mode") == "return to narrative governance", f"{label} rollback_governance.mode must return to narrative governance")
    rollback_steps = as_list(rollback_governance.get("steps"), f"{label}.rollback_governance.steps", errors)
    check_value(errors, len(rollback_steps) >= 3, f"{label} rollback_governance.steps must include the exact removal and rescan steps")

    claim_boundaries = set(as_list(manifest.get("claim_boundaries"), f"{label}.claim_boundaries", errors))
    for required in {
        "This manifest is not release proof.",
        "This manifest is not runtime behavior.",
        "This manifest is not production readiness.",
        "This manifest is not accessibility proof.",
        "This manifest is not privacy/legal approval.",
        "This manifest is not CI proof.",
    }:
        check_value(errors, required in claim_boundaries, f"{label} claim_boundaries must include: {required}")

    check_value(errors, "Plan" not in manifest.get("claim_boundaries", []), f"{label} claim_boundaries must not normalize Plan into active IA")
    return errors


def load_fixture(path: Path) -> tuple[dict[str, Any], list[str], str]:
    raw = load_json(path)
    data = as_dict(raw, path.name, [])
    manifest = as_dict(data.get("manifest"), f"{path.name}.manifest", [])
    expected_status = str(data.get("expected_status", "Red"))
    expected_errors = as_list(data.get("expected_error_substrings", []), f"{path.name}.expected_error_substrings", [])
    return manifest, [str(item) for item in expected_errors], expected_status


def validate_fixture_file(path: Path) -> list[str]:
    fixture_raw = load_json(path)
    fixture = as_dict(fixture_raw, path.name, [])
    errors: list[str] = []
    manifest = as_dict(fixture.get("manifest"), f"{path.name}.manifest", errors)
    expected_status = str(fixture.get("expected_status", "Red"))
    expected_errors = [str(item) for item in as_list(fixture.get("expected_error_substrings", []), f"{path.name}.expected_error_substrings", errors)]

    manifest_errors = validate_manifest(manifest, label=path.name)
    if expected_status == "Green":
        if manifest_errors:
            errors.append(f"{path.name} expected Green but got errors: {manifest_errors}")
    else:
        if not manifest_errors:
            errors.append(f"{path.name} expected Red but validation passed")
        for needle in expected_errors:
            if not any(needle in item for item in manifest_errors):
                errors.append(f"{path.name} missing expected error substring: {needle}")
    return errors


def validate_fixture_dir(fixtures_dir: Path) -> list[str]:
    errors: list[str] = []
    if not fixtures_dir.exists():
        return [f"missing fixture directory: {fixtures_dir.relative_to(ROOT)}"]
    fixture_paths = sorted(path for path in fixtures_dir.glob("*.json") if path.is_file())
    if not fixture_paths:
        return [f"no fixture json files found in {fixtures_dir.relative_to(ROOT)}"]
    for path in fixture_paths:
        errors.extend(validate_fixture_file(path))
    return errors


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", default=str(DEFAULT_MANIFEST), help="Path to the AFEP-025 manifest JSON")
    parser.add_argument("--fixtures", default=str(DEFAULT_FIXTURES), help="Directory containing AFEP-025 drift fixtures")
    parser.add_argument("--self-test", action="store_true", help="Validate the default manifest and bundled fixtures")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    manifest_path = Path(args.manifest)
    fixtures_dir = Path(args.fixtures)

    errors: list[str] = []
    if not manifest_path.exists():
        errors.append(f"missing manifest: {manifest_path.relative_to(ROOT)}")
    else:
        manifest = as_dict(load_json(manifest_path), manifest_path.name, errors)
        errors.extend(validate_manifest(manifest, label=manifest_path.name))

    errors.extend(validate_fixture_dir(fixtures_dir))

    if errors:
        print("# AFEP-025 Architecture Manifest Validate")
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1

    print("# AFEP-025 Architecture Manifest Validate")
    print("GREEN: AFEP-025 manifest and drift fixtures validated without elevating authority beyond docs/truth/*, live source, or current proof evidence")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
