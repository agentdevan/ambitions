#!/usr/bin/env python3
"""Validate the AFEP-026 archive and tombstone lifecycle policy manifest."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "docs" / "codex" / "AFEP_ARCHIVE_TOMBSTONE_LIFECYCLE_POLICY.json"
DEFAULT_FIXTURES = ROOT / "fixtures" / "afep026"

EXPECTED_AUTHORITY_PREFIX = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
]

EXPECTED_STATE_PRECEDENCE = [
    "active",
    "supporting",
    "deprecated",
    "archived",
    "historical",
    "tombstoned",
    "delete-candidate",
    "generated",
    "local-only",
    "proof-only",
]

EXPECTED_ARCHIVE_METADATA = [
    "original_path",
    "archived_date",
    "reason",
    "replacement_authority",
    "useful_content_extracted_to",
    "active_authority",
    "expiration_review_policy",
]

EXPECTED_TOMBSTONE_METADATA = [
    "provenance",
    "recoverability",
    "finalization",
    "export_safe_view",
    "extraction_evidence",
    "rollback",
]

EXPECTED_DELETE_CANDIDATE_METADATA = [
    "provenance",
    "recoverability",
    "finalization",
    "export_safe_view",
    "extraction_evidence",
    "rollback",
    "extract_then_delete_evidence",
]

EXPECTED_NON_AUTHORITY_STATES = {
    "supporting",
    "deprecated",
    "archived",
    "historical",
    "tombstoned",
    "delete-candidate",
    "generated",
    "local-only",
    "proof-only",
}

EXPECTED_REQUIRED_RULES = {
    "historical material never overrides active truth",
    "supporting material never overrides active truth",
    "archived material remains traceable but non-authoritative",
    "tombstoned material must describe a recoverable finalization path",
    "delete-candidate material must document extract-then-delete evidence and rollback",
    "generated, local-only, and proof-only material are never authority by default",
    "proof-only material cannot become release readiness without current proof evidence",
    "historical authority drift is rejected",
}

EXPECTED_BOUNDARIES = {
    "local validation is not release proof",
    "local validation is not device proof",
    "local validation is not accessibility proof",
    "local validation is not privacy proof",
    "local validation is not CI proof",
    "local validation is not production proof",
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


def check(errors: list[str], ok: bool, message: str) -> None:
    if not ok:
        errors.append(message)


def expect_exact_list(errors: list[str], actual: list[Any], expected: list[str], label: str) -> None:
    check(errors, actual == expected, f"{label} must be exactly {expected}")


def validate_state(
    *,
    errors: list[str],
    state_name: str,
    state_value: dict[str, Any],
) -> None:
    check(errors, state_value.get("classification") == state_name, f"{state_name}.classification must be {state_name}")
    check(errors, state_value.get("must_defer_to_docs_truth") is True, f"{state_name} must defer to docs/truth/*")
    check(errors, state_value.get("may_override_active_truth") is False, f"{state_name} may not override active truth")
    check(errors, state_value.get("traceability_required") is True, f"{state_name} must require traceability")
    check(errors, state_value.get("release_authority_by_default") is False, f"{state_name} release_authority_by_default must be false")

    if state_name == "active":
        check(errors, state_value.get("authority_role") == "authoritative", "active authority_role must be authoritative")
        check(errors, state_value.get("current_proof_required") is True, "active current_proof_required must be true")
    else:
        check(errors, state_value.get("authority_role") == "non-authority", f"{state_name} authority_role must be non-authority")
        check(errors, state_value.get("current_proof_required") is False or state_name == "proof-only", f"{state_name} current_proof_required must be false unless proof-only")

    if state_name in EXPECTED_NON_AUTHORITY_STATES:
        check(errors, state_value.get("authority_role") == "non-authority", f"{state_name} must be non-authority by default")

    if state_name == "archived":
        expect_exact_list(
            errors,
            as_list(state_value.get("required_metadata"), "archived.required_metadata", errors),
            EXPECTED_ARCHIVE_METADATA,
            "archived.required_metadata",
        )
    if state_name == "historical":
        check(errors, state_value.get("never_overrides_active_truth") is True, "historical never_overrides_active_truth must be true")
        check(errors, state_value.get("requires_active_truth_reference") is True, "historical requires_active_truth_reference must be true")
    if state_name == "tombstoned":
        expect_exact_list(
            errors,
            as_list(state_value.get("required_metadata"), "tombstoned.required_metadata", errors),
            EXPECTED_TOMBSTONE_METADATA,
            "tombstoned.required_metadata",
        )
        recoverability = as_dict(state_value.get("recoverability"), "tombstoned.recoverability", errors)
        check(errors, recoverability.get("required") is True, "tombstoned.recoverability.required must be true")
        check(errors, recoverability.get("finalized") is True, "tombstoned.recoverability.finalized must be true")
        check(errors, recoverability.get("restorable_from_export_safe_view") is True, "tombstoned.recoverability.restorable_from_export_safe_view must be true")
        export_safe_view = as_dict(state_value.get("export_safe_view"), "tombstoned.export_safe_view", errors)
        check(errors, export_safe_view.get("required") is True, "tombstoned.export_safe_view.required must be true")
        check(errors, "trace-only" in str(export_safe_view.get("description", "")).lower(), "tombstoned.export_safe_view.description must describe a trace-only view")
        extraction_evidence = as_dict(state_value.get("extraction_evidence"), "tombstoned.extraction_evidence", errors)
        check(errors, extraction_evidence.get("required") is True, "tombstoned.extraction_evidence.required must be true")
        rollback = as_dict(state_value.get("rollback"), "tombstoned.rollback", errors)
        check(errors, rollback.get("required") is True, "tombstoned.rollback.required must be true")
    if state_name == "delete-candidate":
        expect_exact_list(
            errors,
            as_list(state_value.get("required_metadata"), "delete-candidate.required_metadata", errors),
            EXPECTED_DELETE_CANDIDATE_METADATA,
            "delete-candidate.required_metadata",
        )
        recoverability = as_dict(state_value.get("recoverability"), "delete-candidate.recoverability", errors)
        check(errors, recoverability.get("required") is True, "delete-candidate.recoverability.required must be true")
        check(errors, recoverability.get("finalized") is True, "delete-candidate.recoverability.finalized must be true")
        check(errors, recoverability.get("restorable_from_export_safe_view") is False, "delete-candidate.recoverability.restorable_from_export_safe_view must be false")
        export_safe_view = as_dict(state_value.get("export_safe_view"), "delete-candidate.export_safe_view", errors)
        check(errors, export_safe_view.get("required") is True, "delete-candidate.export_safe_view.required must be true")
        extraction_evidence = as_dict(state_value.get("extraction_evidence"), "delete-candidate.extraction_evidence", errors)
        check(errors, extraction_evidence.get("required") is True, "delete-candidate.extraction_evidence.required must be true")
        rollback = as_dict(state_value.get("rollback"), "delete-candidate.rollback", errors)
        check(errors, rollback.get("required") is True, "delete-candidate.rollback.required must be true")
        extract_then_delete_evidence = as_dict(state_value.get("extract_then_delete_evidence"), "delete-candidate.extract_then_delete_evidence", errors)
        check(errors, extract_then_delete_evidence.get("required") is True, "delete-candidate.extract_then_delete_evidence.required must be true")
    if state_name in {"generated", "local-only", "proof-only"}:
        check(errors, state_value.get("proof_authority_by_default") is False, f"{state_name} proof_authority_by_default must be false")
    if state_name == "proof-only":
        check(errors, state_value.get("current_proof_required") is True, "proof-only current_proof_required must be true")
        check(errors, state_value.get("proof_authority_by_default") is False, "proof-only proof_authority_by_default must be false")


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
        "state_precedence",
        "lifecycle_states",
        "archive_traceability_requirements",
        "tombstone_requirements",
        "delete_candidate_requirements",
        "authority_protection_rules",
        "proof_and_claim_boundaries",
        "rollback_governance",
        "claim_boundaries",
    }

    for key in sorted(required_keys - set(manifest)):
        errors.append(f"{label} missing key: {key}")

    check(errors, manifest.get("schema_version") == 1, f"{label} schema_version must be 1")
    check(errors, manifest.get("status") == "active", f"{label} status must be active")
    check(errors, manifest.get("batch_id") == "AFEP-026", f"{label} batch_id must be AFEP-026")
    check(errors, manifest.get("owner_issue") == "AMB-420", f"{label} owner_issue must be AMB-420")

    authority_order = as_list(manifest.get("authority_order"), f"{label}.authority_order", errors)
    check(errors, authority_order[: len(EXPECTED_AUTHORITY_PREFIX)] == EXPECTED_AUTHORITY_PREFIX, f"{label} authority_order must start with the docs/truth authority order")
    for path_text in authority_order:
        if not isinstance(path_text, str):
            errors.append(f"{label} authority_order entries must be strings")
            continue
        check(errors, (ROOT / path_text).exists(), f"{label} authority_order path missing: {path_text}")

    authority_statement = str(manifest.get("authority_statement", ""))
    check(errors, "subordinate" in authority_statement.lower(), f"{label} authority_statement must say the manifest is subordinate")
    check(errors, "may not override" in authority_statement.lower(), f"{label} authority_statement must say it may not override higher authority")
    check(errors, "docs/truth/*" in authority_statement, f"{label} authority_statement must mention docs/truth/*")
    check(errors, "current proof evidence" in authority_statement, f"{label} authority_statement must mention current proof evidence")

    source_truth_precedence = as_list(manifest.get("source_truth_precedence"), f"{label}.source_truth_precedence", errors)
    expect_exact_list(errors, source_truth_precedence, ["docs/truth/*", "live source", "current proof evidence", "this manifest"], f"{label}.source_truth_precedence")

    state_precedence = as_list(manifest.get("state_precedence"), f"{label}.state_precedence", errors)
    expect_exact_list(errors, state_precedence, EXPECTED_STATE_PRECEDENCE, f"{label}.state_precedence")

    lifecycle_states = as_dict(manifest.get("lifecycle_states"), f"{label}.lifecycle_states", errors)
    check(errors, set(lifecycle_states) == set(EXPECTED_STATE_PRECEDENCE), f"{label} lifecycle_states must define every required state")
    for state_name in EXPECTED_STATE_PRECEDENCE:
        state_value = as_dict(lifecycle_states.get(state_name), f"{label}.lifecycle_states[{state_name}]", errors)
        validate_state(errors=errors, state_name=state_name, state_value=state_value)

    expect_exact_list(
        errors,
        as_list(manifest.get("archive_traceability_requirements"), f"{label}.archive_traceability_requirements", errors),
        EXPECTED_ARCHIVE_METADATA,
        f"{label}.archive_traceability_requirements",
    )
    expect_exact_list(
        errors,
        as_list(manifest.get("tombstone_requirements"), f"{label}.tombstone_requirements", errors),
        EXPECTED_TOMBSTONE_METADATA,
        f"{label}.tombstone_requirements",
    )
    expect_exact_list(
        errors,
        as_list(manifest.get("delete_candidate_requirements"), f"{label}.delete_candidate_requirements", errors),
        EXPECTED_DELETE_CANDIDATE_METADATA,
        f"{label}.delete_candidate_requirements",
    )

    authority_rules = set(as_list(manifest.get("authority_protection_rules"), f"{label}.authority_protection_rules", errors))
    for required in EXPECTED_REQUIRED_RULES:
        check(errors, required in authority_rules, f"{label} authority_protection_rules must include: {required}")

    boundary_rules = set(as_list(manifest.get("proof_and_claim_boundaries"), f"{label}.proof_and_claim_boundaries", errors))
    for required in EXPECTED_BOUNDARIES:
        check(errors, required in boundary_rules, f"{label} proof_and_claim_boundaries must include: {required}")

    rollback_governance = as_dict(manifest.get("rollback_governance"), f"{label}.rollback_governance", errors)
    check(errors, rollback_governance.get("mode") == "return to narrative historical policy", f"{label} rollback_governance.mode must return to narrative historical policy")
    rollback_steps = as_list(rollback_governance.get("steps"), f"{label}.rollback_governance.steps", errors)
    check(errors, len(rollback_steps) >= 3, f"{label} rollback_governance.steps must include the removal and rescan steps")

    claim_boundaries = set(as_list(manifest.get("claim_boundaries"), f"{label}.claim_boundaries", errors))
    for required in {
        "This manifest is not release proof.",
        "This manifest is not runtime behavior.",
        "This manifest is not production readiness.",
        "This manifest is not accessibility proof.",
        "This manifest is not privacy/legal approval.",
        "This manifest is not CI proof.",
    }:
        check(errors, required in claim_boundaries, f"{label} claim_boundaries must include: {required}")

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
    parser.add_argument("--manifest", default=str(DEFAULT_MANIFEST), help="Path to the AFEP-026 manifest JSON")
    parser.add_argument("--fixtures", default=str(DEFAULT_FIXTURES), help="Directory containing AFEP-026 lifecycle fixtures")
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
        print("# AFEP-026 Archive Tombstone Lifecycle Validate")
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1

    print("# AFEP-026 Archive Tombstone Lifecycle Validate")
    print("GREEN: AFEP-026 lifecycle policy and fixtures validated without elevating historical, archived, tombstoned, delete-candidate, generated, local-only, or proof-only material above docs/truth/*, live source, or current proof evidence")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
