#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
from typing import Any

from ambitions_frontend_authority_common import (
    BATCH_ID,
    PREFLIGHT_DIR,
    ACTIVE_IA,
    combined_surface_payload,
    packet_paths,
    PROOF_CONTRACT_SCHEMA_PATH,
    RECEIPT_SCHEMA_PATH,
    proof_binding_status,
    surface_record,
    write_json,
    write_text,
)


def build_report(surface_id: str, source_targets: list[str], batch_id: str | None, allow_extension_reason: str | None) -> dict[str, Any]:
    packet = combined_surface_payload(surface_id)
    row = surface_record(surface_id)
    issues: list[str] = []
    warnings: list[str] = []

    if not packet.get("recipe_path"):
        issues.append("surface is missing a recipe path")
    if not packet.get("source_relationship"):
        issues.append("surface relationship is not explicit")
    if not packet.get("source_candidates") and not row.get("gap_reason"):
        issues.append("surface has no source candidates and no explicit gap reason")
    if not packet.get("tokens", {}).get("design_tokens"):
        issues.append("surface has no token candidates")
    if not packet.get("contracts"):
        issues.append("surface has no contract candidates")
    if not packet.get("proof_status"):
        issues.append("surface has no proof status")
    if row.get("surface_universe_id") != surface_id:
        issues.append("surface lookup mismatch")
    if list(ACTIVE_IA) != ["Today", "Goals", "Capture", "Time", "You"]:
        issues.append("active IA is not the required Today / Goals / Capture / Time / You set")
    if "Plan" in ACTIVE_IA:
        issues.append("Plan is present in the active IA list")

    generated_packet_md, generated_packet_json = packet_paths(surface_id)
    if not generated_packet_md.exists() or not generated_packet_json.exists():
        warnings.append("surface packet was generated during preflight")

    allowed_sources = set(packet.get("source_candidates", []))
    disallowed_sources = [source for source in source_targets if source not in allowed_sources]
    if disallowed_sources and not allow_extension_reason:
        issues.append(f"source targets outside the declared scope: {', '.join(disallowed_sources)}")
    elif disallowed_sources:
        warnings.append(f"source extension accepted with reason: {allow_extension_reason}")

    proof_contract_ready = PROOF_CONTRACT_SCHEMA_PATH.exists() and RECEIPT_SCHEMA_PATH.exists()
    if not proof_contract_ready:
        issues.append("proof contract schema is not available")

    if str(row.get("lock_status")) not in {"locked", "intent_locked", "draft_locked", ""}:
        warnings.append(f"surface lock status is {row.get('lock_status')}")

    status = "green" if not issues else "red"
    return {
        "batch_id": batch_id or packet.get("planned_implementation_batch") or BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "surface_id": surface_id,
        "surface_name": packet.get("surface_name"),
        "destination": packet.get("destination"),
        "primary_object": packet.get("primary_object"),
        "recipe_path": packet.get("recipe_path"),
        "surface_bible_path": packet.get("surface_bible_path"),
        "source_targets": source_targets,
        "allowed_sources": packet.get("source_candidates", []),
        "issues": issues,
        "warnings": warnings,
        "checks": {
            "surface_exists": True,
            "recipe_exists": bool(packet.get("recipe_path")),
            "provenance_exists": True,
            "source_relationship_explicit": bool(packet.get("source_relationship")),
            "source_candidates_or_gap": bool(packet.get("source_candidates") or row.get("gap_reason")),
            "tokens_known": bool(packet.get("tokens", {}).get("design_tokens")),
            "contracts_known": bool(packet.get("contracts")),
            "proof_status_known": bool(packet.get("proof_status")),
            "active_ia_valid": list(ACTIVE_IA) == ["Today", "Goals", "Capture", "Time", "You"],
            "plan_not_active_top_level": "Plan" not in ACTIVE_IA,
            "source_targets_allowed_or_extensible": not disallowed_sources or bool(allow_extension_reason),
            "packet_exists_or_generated": generated_packet_md.exists() and generated_packet_json.exists(),
            "surface_not_obsolete": str(row.get("lock_status")) != "obsolete",
            "proof_contract_generatable": proof_contract_ready,
        },
        "status": status,
    }


def render_md(report: dict[str, Any]) -> str:
    source_targets = [f"- {item}" for item in report.get("source_targets", [])] or ["- None"]
    allowed_sources = [f"- {item}" for item in report.get("allowed_sources", [])] or ["- None"]
    issues = [f"- {item}" for item in report.get("issues", [])] or ["- None"]
    warnings = [f"- {item}" for item in report.get("warnings", [])] or ["- None"]
    lines = [
        f"# Frontend Authority Preflight: {report['surface_name']}",
        "",
        f"Batch: `{report['batch_id']}`",
        f"Surface: `{report['surface_id']}`",
        f"Status: `{report['status']}`",
        "",
        "## Checks",
    ]
    for key, value in report["checks"].items():
        lines.append(f"- {key}: {'pass' if value else 'fail'}")
    lines.extend(
        [
            "",
            "## Source Targets",
            *source_targets,
            "",
            "## Allowed Sources",
            *allowed_sources,
            "",
            "## Issues",
            *issues,
            "",
            "## Warnings",
            *warnings,
        ]
    )
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Run frontend authority preflight checks.")
    parser.add_argument("--surface", required=True)
    parser.add_argument("--source", action="append", default=[])
    parser.add_argument("--batch")
    parser.add_argument("--allow-extension-reason")
    args = parser.parse_args()

    report = build_report(args.surface, args.source, args.batch, args.allow_extension_reason)
    md_path, json_path = PREFLIGHT_DIR / f"{args.surface}.md", PREFLIGHT_DIR / f"{args.surface}.json"
    write_json(json_path, report)
    write_text(md_path, render_md(report))
    print(report["status"].upper())
    return 0 if report["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
