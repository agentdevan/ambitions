#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
from typing import Any

from ambitions_frontend_authority_common import (
    PACKET_DIR,
    REPORT_DIR,
    load_json,
    root_surface_ids,
    universe_rows,
    write_json,
    write_text,
)
from ambitions_signature_visual_instruments import (
    DESTINATION_INSTRUMENTS,
    DOCTRINE_PATH,
    MATRIX_PATH,
    enrich_packet_with_instrument,
    missing_top_level_instruments,
)


ROOT_PROMPT = Path("prompts/generated/frontend/TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01.md")
DASHBOARD = REPORT_DIR / "frontend-implementation-dashboard.json"
QUEUE = REPORT_DIR / "frontend-next-surface-queue.json"
DRIFT = REPORT_DIR / "frontend-drift-check.json"
SOURCE_BINDINGS = Path("frontend/visual-encyclopedia/trace/FRONTEND_SOURCE_BINDINGS.yaml")


def _safe_load(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    try:
        return load_json(path)
    except Exception:
        return {}


def _root_packets_have_instruments() -> tuple[bool, list[str]]:
    missing: list[str] = []
    for surface_id in root_surface_ids():
        json_path = PACKET_DIR / f"{surface_id}.json"
        md_path = PACKET_DIR / f"{surface_id}.md"
        if not json_path.exists() or not md_path.exists():
            missing.append(f"{surface_id}: missing packet files")
            continue
        payload = _safe_load(json_path)
        instrument = payload.get("signature_visual_instrument") if isinstance(payload, dict) else None
        md_text = md_path.read_text(encoding="utf-8")
        if not isinstance(instrument, dict) or not instrument.get("signature_instrument_id"):
            missing.append(f"{surface_id}: missing signature_visual_instrument JSON")
        if "## Signature Visual Instrument" not in md_text:
            missing.append(f"{surface_id}: missing Signature Visual Instrument MD section")
    return (not missing, missing)


def _source_bindings_have_instruments() -> tuple[bool, list[str]]:
    missing: list[str] = []
    payload = _safe_load(SOURCE_BINDINGS)
    rows = payload.get("bindings", []) if isinstance(payload, dict) else []
    by_surface = {row.get("surface_id"): row for row in rows if isinstance(row, dict)}
    for surface_id in root_surface_ids():
        row = by_surface.get(surface_id)
        if not row:
            missing.append(f"{surface_id}: missing binding")
            continue
        if not row.get("signature_instrument_id"):
            missing.append(f"{surface_id}: missing signature_instrument_id")
        if "instrument_implementation_status" not in row:
            missing.append(f"{surface_id}: missing instrument_implementation_status")
    return (not missing, missing)


def _prompt_has_instrument_requirements() -> tuple[bool, list[str]]:
    if not ROOT_PROMPT.exists():
        return False, [f"missing prompt: {ROOT_PROMPT}"]
    text = ROOT_PROMPT.read_text(encoding="utf-8")
    required = [
        "Signature Visual Instrument Requirements",
        "Instrument Implementation Rules",
        "dedicated SwiftUI visual-object",
        "generic card stack",
        "signature_instrument_id",
    ]
    missing = [item for item in required if item not in text]
    return (not missing, missing)


def _dashboard_has_instrument_status() -> tuple[bool, list[str]]:
    payload = _safe_load(DASHBOARD)
    missing: list[str] = []
    for key in [
        "signature_instrument_counts",
        "instrument_implementation_status_counts",
        "top_level_surfaces_missing_instrument",
        "next_recommended_instrument_implementation",
    ]:
        if key not in payload:
            missing.append(key)
    return (not missing, missing)


def _queue_has_no_duplicates_and_instruments() -> tuple[bool, list[str]]:
    payload = _safe_load(QUEUE)
    ranked = payload.get("ranked_surfaces", []) if isinstance(payload, dict) else []
    ids = [row.get("surface_id") for row in ranked if isinstance(row, dict)]
    duplicates = sorted({item for item in ids if ids.count(item) > 1})
    missing_instrument_fields = [row.get("surface_id") for row in ranked if isinstance(row, dict) and "signature_instrument_id" not in row]
    blockers: list[str] = []
    if duplicates:
        blockers.append("duplicate surface IDs: " + ", ".join(duplicates))
    if missing_instrument_fields:
        blockers.append("rows missing signature_instrument_id: " + ", ".join(str(item) for item in missing_instrument_fields[:10]))
    return (not blockers, blockers)


def _drift_check_clean() -> tuple[bool, list[str]]:
    payload = _safe_load(DRIFT)
    if not payload:
        return False, ["missing drift report"]
    violations = payload.get("violations", []) or []
    # Warnings are allowed; forbidden-rule declarations should not be violations.
    return (not violations, [str(item) for item in violations])


def build_report() -> dict[str, Any]:
    surfaces = [enrich_packet_with_instrument({"surface_id": row.get("surface_universe_id"), "surface_name": row.get("name"), "destination": row.get("destination")}) for row in universe_rows()]
    top_missing = missing_top_level_instruments(surfaces)
    checks = {
        "doctrine_exists": DOCTRINE_PATH.exists(),
        "matrix_exists": MATRIX_PATH.exists(),
        "top_level_destination_instruments_declared": set(DESTINATION_INSTRUMENTS) == {"Today", "Goals", "Capture", "Time", "You"},
        "root_packets_have_instruments": _root_packets_have_instruments()[0],
        "source_bindings_have_instruments": _source_bindings_have_instruments()[0],
        "generated_prompt_has_instrument_requirements": _prompt_has_instrument_requirements()[0],
        "dashboard_has_instrument_status": _dashboard_has_instrument_status()[0],
        "queue_has_no_duplicates_and_instrument_fields": _queue_has_no_duplicates_and_instruments()[0],
        "drift_check_has_no_instrument_violations": _drift_check_clean()[0],
        "computed_top_level_missing_instruments": not top_missing,
    }
    detail = {
        "root_packet_blockers": _root_packets_have_instruments()[1],
        "source_binding_blockers": _source_bindings_have_instruments()[1],
        "prompt_blockers": _prompt_has_instrument_requirements()[1],
        "dashboard_blockers": _dashboard_has_instrument_status()[1],
        "queue_blockers": _queue_has_no_duplicates_and_instruments()[1],
        "drift_blockers": _drift_check_clean()[1],
        "computed_top_level_missing_instruments": top_missing,
    }
    blockers = [key for key, value in checks.items() if not value]
    return {
        "status": "green" if not blockers else "red",
        "batch_id": "SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07",
        "checks": checks,
        "blockers": blockers,
        "detail": detail,
        "proof_boundary": "visual encyclopedia and frontend OS control-plane validation only; not production UI implementation proof",
    }


def render_md(report: dict[str, Any]) -> str:
    lines = [
        "# Signature Visual Instruments Check",
        "",
        f"Status: `{report['status']}`",
        f"Batch: `{report['batch_id']}`",
        "",
        "## Checks",
    ]
    for key, value in report["checks"].items():
        lines.append(f"- {key}: {'pass' if value else 'fail'}")
    lines.extend(["", "## Blockers"])
    lines.extend(f"- {item}" for item in report["blockers"] or ["None"])
    lines.extend(["", "## Detail"])
    for key, value in report["detail"].items():
        lines.append(f"- {key}: {value}")
    lines.extend(["", f"Proof boundary: {report['proof_boundary']}"])
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    report = build_report()
    write_json(REPORT_DIR / "signature-visual-instruments-check.json", report)
    write_text(REPORT_DIR / "signature-visual-instruments-check.md", render_md(report))
    print(report["status"].upper())
    return 0 if report["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
