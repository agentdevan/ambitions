#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter
from pathlib import Path
from typing import Any

from ambitions_frontend_authority_common import (
    ACTIVE_IA,
    BATCH_ID,
    REPORT_DIR,
    combined_surface_payload,
    load_json,
    surface_counts_by,
    universe_rows,
    write_json,
    write_text,
)


def build_report() -> dict[str, Any]:
    bindings_path = REPORT_DIR / "frontend-source-bindings.json"
    bindings_payload = load_json(bindings_path) if bindings_path.exists() else {"bindings": []}
    bindings = [row for row in bindings_payload.get("bindings", []) if isinstance(row, dict)]
    if not bindings:
        bindings = [combined_surface_payload(row["surface_universe_id"]) for row in universe_rows()]
    drift_path = REPORT_DIR / "frontend-drift-check.json"
    drift = load_json(drift_path) if drift_path.exists() else {}
    destination_counts = surface_counts_by("destination")
    tier_counts = surface_counts_by("maturity_tier")
    implementation_counts = dict(sorted(Counter(binding.get("implementation_status") for binding in bindings).items()))
    proof_counts = dict(sorted(Counter(binding.get("proof_status") for binding in bindings).items()))
    source_linked = [binding["surface_id"] for binding in bindings if binding.get("source_relationship") == "implemented_source_present"]
    canon_only_pending_lock = [binding["surface_id"] for binding in bindings if binding.get("implementation_status") == "canon_only_pending_lock"]
    source_approximation = [binding["surface_id"] for binding in bindings if binding.get("implementation_status") == "source_approximation_present"]
    implemented_unproven = [binding["surface_id"] for binding in bindings if binding.get("implementation_status") == "implemented_unproven"]
    proven = [binding["surface_id"] for binding in bindings if binding.get("implementation_status") == "proven"]
    with_receipts = [binding["surface_id"] for binding in bindings if binding.get("last_receipt")]
    missing_receipts = [binding["surface_id"] for binding in bindings if not binding.get("last_receipt")]
    p0_ready = [binding["surface_id"] for binding in bindings if binding.get("maturity_tier") == "P0" and binding.get("source_relationship") == "implemented_source_present"]
    p0_blocked = [binding["surface_id"] for binding in bindings if binding.get("maturity_tier") == "P0" and binding.get("source_relationship") != "implemented_source_present"]
    next_recommended = [binding["surface_id"] for binding in bindings if binding.get("source_relationship") == "implemented_source_present"][:10]
    proof_gaps = sorted({gap for binding in bindings for gap in binding.get("known_gaps", []) if gap})
    status = "green" if not drift.get("violations") else "yellow"
    return {
        "batch_id": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "status": status,
        "total_mature_surfaces": len(bindings),
        "destination_counts": destination_counts,
        "tier_counts": tier_counts,
        "implementation_status_counts": implementation_counts,
        "proof_status_counts": proof_counts,
        "source_linked_surfaces": source_linked,
        "canon_only_pending_lock_surfaces": canon_only_pending_lock,
        "source_approximation_surfaces": source_approximation,
        "implemented_unproven_surfaces": implemented_unproven,
        "proven_surfaces": proven,
        "surfaces_with_receipts": with_receipts,
        "surfaces_missing_receipts": missing_receipts,
        "p0_surfaces_ready_for_implementation": p0_ready,
        "p0_surfaces_blocked_by_missing_source_binding": p0_blocked,
        "top_drift_findings": drift.get("violations", [])[:10],
        "next_recommended_surfaces": next_recommended,
        "proof_gaps": proof_gaps[:20],
        "active_ia_status": "green" if list(ACTIVE_IA) == ["Today", "Goals", "Capture", "Time", "You"] else "red",
        "drift_report_path": str(drift_path.relative_to(Path.cwd())) if drift_path.exists() else None,
    }


def render_md(report: dict[str, Any]) -> str:
    lines = [
        "# Frontend Implementation Dashboard",
        "",
        f"Batch: `{report['batch_id']}`",
        f"Status: `{report['status']}`",
        "",
        "## Counts",
        f"- total mature surfaces: {report['total_mature_surfaces']}",
        f"- destinations: {report['destination_counts']}",
        f"- tiers: {report['tier_counts']}",
        f"- implementation statuses: {report['implementation_status_counts']}",
        f"- proof statuses: {report['proof_status_counts']}",
        "",
        "## Readiness",
        f"- source-linked surfaces: {len(report['source_linked_surfaces'])}",
        f"- canon-only pending lock surfaces: {len(report['canon_only_pending_lock_surfaces'])}",
        f"- source-approximation surfaces: {len(report['source_approximation_surfaces'])}",
        f"- implemented-unproven surfaces: {len(report['implemented_unproven_surfaces'])}",
        f"- proven surfaces: {len(report['proven_surfaces'])}",
        f"- surfaces with receipts: {len(report['surfaces_with_receipts'])}",
        f"- surfaces missing receipts: {len(report['surfaces_missing_receipts'])}",
        f"- P0 ready: {len(report['p0_surfaces_ready_for_implementation'])}",
        f"- P0 blocked: {len(report['p0_surfaces_blocked_by_missing_source_binding'])}",
        "",
        "## Next Recommended Surfaces",
    ]
    lines.extend(f"- `{item}`" for item in report["next_recommended_surfaces"] or ["None"])
    lines.extend(["", "## Top Drift Findings"])
    lines.extend(f"- {item}" for item in report["top_drift_findings"] or ["None"])
    lines.extend(["", "## Proof Gaps"])
    lines.extend(f"- {item}" for item in report["proof_gaps"] or ["None"])
    lines.extend(["", f"## Active IA Status\n- {report['active_ia_status']}"])
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    report = build_report()
    write_json(REPORT_DIR / "frontend-implementation-dashboard.json", report)
    write_text(REPORT_DIR / "frontend-implementation-dashboard.md", render_md(report))
    print(report["status"].upper())
    return 0 if report["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
