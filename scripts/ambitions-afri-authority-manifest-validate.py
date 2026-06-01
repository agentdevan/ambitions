#!/usr/bin/env python3
"""Validate the AFRI authority automation manifest."""

from __future__ import annotations

from pathlib import Path
import json
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs" / "codex" / "AFRI_ACTIVE_AUTHORITY_MANIFEST.json"

EXPECTED_AUTHORITY_PREFIX = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
]

REQUIRED_MANIFEST_KEYS = {
    "schema_version",
    "status",
    "owner_issue",
    "owner_batch",
    "authority_order",
    "supporting_not_authority",
    "active_batch_manifest",
    "validation_commands",
    "proof_reporting",
    "rollback_behavior",
    "claim_boundaries",
}

REQUIRED_VALIDATION_COMMANDS = {
    "authority_lint",
    "stale_doc_scan",
    "manifest_validation",
    "diff_check",
    "post_guard",
}

REQUIRED_PROOF_STATES = {"green", "yellow", "red"}


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def load_manifest(errors: list[str]) -> dict:
    if not MANIFEST.exists():
        errors.append(f"missing manifest: {rel(MANIFEST)}")
        return {}
    try:
        return json.loads(MANIFEST.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        errors.append(f"manifest JSON parse failure: {exc}")
        return {}


def run_stale_detector(errors: list[str]) -> None:
    result = subprocess.run(
        ["python3", "scripts/ambitions-afri-stale-doc-detector.py"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if result.returncode != 0:
        errors.append("stale-doc detector returned Red:\n" + result.stdout.strip())


def main() -> int:
    errors: list[str] = []
    manifest = load_manifest(errors)

    missing_keys = sorted(REQUIRED_MANIFEST_KEYS - set(manifest))
    for key in missing_keys:
        errors.append(f"manifest missing key: {key}")

    if manifest.get("status") != "active":
        errors.append("manifest status must be active")
    if manifest.get("owner_issue") != "AMB-391":
        errors.append("manifest owner_issue must be AMB-391")
    if manifest.get("owner_batch") != "AFRI-039":
        errors.append("manifest owner_batch must be AFRI-039")

    authority_order = manifest.get("authority_order", [])
    if authority_order[: len(EXPECTED_AUTHORITY_PREFIX)] != EXPECTED_AUTHORITY_PREFIX:
        errors.append("authority_order must start with the docs/truth read order")

    for path_string in authority_order:
        path = ROOT / path_string
        if not path.exists():
            errors.append(f"authority_order path missing: {path_string}")

    batch_manifest = manifest.get("active_batch_manifest", {})
    if not batch_manifest.get("runner_required"):
        errors.append("active_batch_manifest.runner_required must be true")
    if batch_manifest.get("runner_command") != "scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>":
        errors.append("runner_command does not match canonical runner")
    prompt_header = batch_manifest.get("prompt_header_required", [])
    if len(prompt_header) != 3:
        errors.append("prompt_header_required must include the three runner header lines")
    for required_path in batch_manifest.get("local_sequence_evidence", []):
        if not (ROOT / required_path).exists():
            errors.append(f"local sequence evidence path missing: {required_path}")

    validation_commands = manifest.get("validation_commands", {})
    missing_commands = sorted(REQUIRED_VALIDATION_COMMANDS - set(validation_commands))
    for command in missing_commands:
        errors.append(f"validation_commands missing key: {command}")

    proof_reporting = manifest.get("proof_reporting", {})
    missing_states = sorted(REQUIRED_PROOF_STATES - set(proof_reporting))
    for state in missing_states:
        errors.append(f"proof_reporting missing state: {state}")

    hierarchy = ROOT / "docs" / "governance" / "AUTHORITY_HIERARCHY.md"
    if hierarchy.exists():
        text = hierarchy.read_text(encoding="utf-8")
        if "Primary location:\n\n- docs/canon/" in text or "# Tier 1 — Canon Truth" in text:
            errors.append("docs/governance/AUTHORITY_HIERARCHY.md still promotes docs/canon as Tier 1")
        if "`docs/truth/`" not in text:
            errors.append("docs/governance/AUTHORITY_HIERARCHY.md must route Tier 1 to docs/truth")

    active_map = ROOT / ".codex" / "os" / "ACTIVE_AUTHORITY_MAP.md"
    if active_map.exists():
        text = active_map.read_text(encoding="utf-8")
        if "docs/truth/PRODUCT_MOAT_TRUTH.md" not in text:
            errors.append(".codex/os/ACTIVE_AUTHORITY_MAP.md missing PRODUCT_MOAT_TRUTH")
        if "AFRI_ACTIVE_AUTHORITY_MANIFEST.json" not in text:
            errors.append(".codex/os/ACTIVE_AUTHORITY_MAP.md missing AFRI manifest route")

    run_stale_detector(errors)

    print("# AFRI Authority Manifest Validate")
    if errors:
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1

    print("GREEN: AFRI authority manifest, stale-doc detector, proof states, runner instructions, and rollback routing validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
