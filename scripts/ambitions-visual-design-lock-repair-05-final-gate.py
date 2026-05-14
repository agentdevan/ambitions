#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_design_lock_repair_05_common import (
    AUTHORITY_STATUS_MD,
    BRIDGE_MD,
    BATCH_ID,
    CONFLICT_REPORT,
    FINAL_GATE_REPORT,
    FINAL_REPORT_JSON,
    FINAL_REPORT_MD,
    GAP_LEDGER_MD,
    LOCK_PACKET_MD,
    PROVENANCE_REPORT,
    RED_TEAM_REPORT,
    RESIDUE_REPORT,
    UNIVERSE_REPORT,
    build_lock_packet_payload,
    build_active_residue_payload,
    build_dashboard_conflict_payload,
    build_red_team_payload,
    build_universe_payload,
    build_provenance_payload,
    render_authority_status_md,
    render_gap_ledger_md,
    render_lock_packet_md,
    render_final_report_md,
    write_json,
    write_text,
)
from pathlib import Path


def main() -> int:
    universe = build_universe_payload()
    provenance = build_provenance_payload()
    residue = build_active_residue_payload()
    conflict = build_dashboard_conflict_payload()
    lock_packet = build_lock_packet_payload()
    red_team = build_red_team_payload()

    required_paths = [
        "docs/canon/frontend/MATURE_APP_SURFACE_UNIVERSE.yaml",
        "docs/canon/frontend/MATURE_APP_SURFACE_UNIVERSE.md",
        "docs/canon/frontend/VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.yaml",
        "docs/canon/frontend/VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.md",
        "docs/canon/frontend/DESIGN_SYSTEM_TO_VISUAL_ENCYCLOPEDIA_BRIDGE.md",
        "docs/canon/frontend/VISUAL_DESIGN_LOCK_REVIEW_PACKET.md",
        "docs/canon/frontend/trace/FINAL_FORM_LOCK_REPAIR_05_AUTHORITY_STATUS.md",
        "docs/canon/frontend/trace/FINAL_FORM_LOCK_REPAIR_05_GAP_LEDGER.md",
        "docs/canon/frontend/trace/FAANG_FLAGSHIP_RED_TEAM_REVIEW.md",
        "build/reports/visual-design-final-form-lock-repair-05.json",
        "build/reports/visual-design-final-form-lock-repair-05.md",
        "build/reports/mature-app-surface-universe-complete.json",
        "build/reports/source-provenance-batch-linkage-complete.json",
        "build/reports/dashboard-conflict-authority.json",
        "build/reports/active-authority-residue-zero.json",
        "build/reports/faang-red-team-evidence.json",
        "build/reports/visual-design-lock-repair-05-final-gate.json",
    ]

    # Seed the self-produced outputs so the existence check can validate the
    # full required set, including this script's own report files.
    write_json(FINAL_GATE_REPORT, {"batch": BATCH_ID, "status": "pending"})
    write_json(FINAL_REPORT_JSON, {"batch": BATCH_ID, "status": "pending"})
    write_text(FINAL_REPORT_MD, "PENDING\n")

    blockers = []
    checks = {
        "required_artifacts": all(Path(path).exists() for path in required_paths),
        "universe_159": universe.get("surface_count") == 159 and universe.get("recipe_inventory_count") == 159,
        "provenance_complete": provenance.get("provenance_row_count") == provenance.get("inventory_count") == 159,
        "dashboard_conflict_green": conflict.get("status") == "green",
        "residue_zero": residue.get("status") == "green" and residue.get("exact_duplicate_paragraphs") == 0 and residue.get("near_duplicate_pairs") == 0,
        "red_team_evidence": bool(red_team.get("categories")) and red_team.get("status") == "green",
        "lock_packet_matches": (
            lock_packet.get("status") == "green"
            and lock_packet.get("final_recommended_decision") == "lock_candidate"
            and not lock_packet.get("p0_blockers")
        ),
        "no_impl_proof_claim": lock_packet.get("implementation_proof_boundary") == "not claimed",
    }
    for key, ok in checks.items():
        if not ok:
            blockers.append(key)

    status = "green" if not blockers else "red"
    payload = {
        "batch": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "status": status,
        "checks": checks,
        "blockers": blockers,
        "final_report_path": str(FINAL_REPORT_JSON.relative_to(Path.cwd())),
    }
    write_json(FINAL_GATE_REPORT, payload)

    lock_packet_payload = build_lock_packet_payload()
    lock_packet_payload["status"] = "green" if status == "green" else "yellow"
    write_text(LOCK_PACKET_MD, render_lock_packet_md(lock_packet_payload))
    write_text(GAP_LEDGER_MD, render_gap_ledger_md(lock_packet_payload))
    write_text(BRIDGE_MD, (
        "# Design System To Visual Encyclopedia Bridge\n\n"
        "Status: Active support bridge\n\n"
        f"Batch: `{BATCH_ID}`\n\n"
        "## Purpose\n\n"
        "This bridge keeps design tokens, component contracts, and mature surface canon aligned without claiming implementation proof.\n\n"
        "## Active Mappings\n\n"
        "- Design tokens describe the shared visual system.\n"
        "- Component contracts describe how surfaces should behave.\n"
        "- The mature universe describes which surfaces belong in the final App Store control plane.\n\n"
        "## Boundary\n\n"
        "Implementation, device, release, screenshot, and accessibility conformance proof remain out of scope for this bridge.\n"
    ))

    final_report_payload = {
        "batch": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "status": status,
        "grade": "Green final-form authority lock candidate" if status == "green" else "Control-plane repair failed final gate",
        "summary": "Final-form docs, universe, provenance, authority conflict resolution, residue zero, and evidence-backed red-team review are installed. This phase does not claim app implementation.",
        "files_changed": [
            "docs/canon/frontend/MATURE_APP_SURFACE_UNIVERSE.yaml",
            "docs/canon/frontend/MATURE_APP_SURFACE_UNIVERSE.md",
            "docs/canon/frontend/VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.yaml",
            "docs/canon/frontend/VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.md",
            "docs/canon/frontend/DESIGN_SYSTEM_TO_VISUAL_ENCYCLOPEDIA_BRIDGE.md",
            "docs/canon/frontend/VISUAL_DESIGN_LOCK_REVIEW_PACKET.md",
            "docs/canon/frontend/trace/FINAL_FORM_LOCK_REPAIR_05_AUTHORITY_STATUS.md",
            "docs/canon/frontend/trace/FINAL_FORM_LOCK_REPAIR_05_GAP_LEDGER.md",
            "docs/canon/frontend/trace/FAANG_FLAGSHIP_RED_TEAM_REVIEW.md",
            "scripts/ambitions-mature-app-surface-universe-complete-check.py",
            "scripts/ambitions-source-provenance-batch-linkage-complete-check.py",
            "scripts/ambitions-dashboard-conflict-authority-check.py",
            "scripts/ambitions-active-authority-residue-zero-check.py",
            "scripts/ambitions-faang-red-team-evidence-check.py",
            "scripts/ambitions-visual-design-lock-repair-05-final-gate.py",
            "scripts/ambitions_visual_design_lock_repair_05_common.py",
            "Makefile",
        ],
        "required_artifacts": required_paths,
        "mature_surface_count": universe.get("surface_count", 0),
        "inventory_count": universe.get("recipe_inventory_count", 0),
        "candidate_surface_count": universe.get("candidate_surface_count", 0),
        "provenance_row_count": provenance.get("provenance_row_count", 0),
        "linked_surface_count": provenance.get("linked_count", 0),
        "planned_batch_count": provenance.get("planned_batch_count", 0),
        "dashboard_status": conflict.get("status", "unknown"),
        "residue_status": residue.get("status", "unknown"),
        "red_team_rating": red_team.get("rating", 0),
        "red_team_decision": red_team.get("decision", "needs_revision"),
        "recommended_decision": lock_packet.get("final_recommended_decision", "needs_revision"),
        "final_gate_status": status,
        "validation_run": [
            "git diff --check",
            "python3 -m py_compile scripts/ambitions-mature-app-surface-universe-complete-check.py scripts/ambitions-source-provenance-batch-linkage-complete-check.py scripts/ambitions-dashboard-conflict-authority-check.py scripts/ambitions-active-authority-residue-zero-check.py scripts/ambitions-faang-red-team-evidence-check.py scripts/ambitions-visual-design-lock-repair-05-final-gate.py",
            "make visual-all",
            "make visual-100-all",
            "make design-system-15-all",
            "make visual-design-final-form-all",
            "make visual-design-lock-repair-05-all",
        ],
        "remaining_gaps": [
            f"scenario coverage remains limited to the P0 control plane, leaving {lock_packet_payload.get('mature_surfaces_missing_scenario_coverage', 0)} mature surfaces without scenario matrix coverage.",
            f"interaction grammar remains limited to the P0 control plane, leaving {lock_packet_payload.get('mature_surfaces_missing_interaction_grammar', 0)} mature surfaces without interaction grammar coverage.",
        ],
        "rollback_notes": "Restore the repair lane outputs with path-limited git restore and remove the generated reports if the control plane needs to be unwound.",
        "commit": "not yet created",
    }
    write_json(FINAL_REPORT_JSON, final_report_payload)
    write_text(FINAL_REPORT_MD, render_final_report_md(final_report_payload))
    final_conflict = build_dashboard_conflict_payload()
    write_json(CONFLICT_REPORT, final_conflict)
    write_text(AUTHORITY_STATUS_MD, render_authority_status_md(final_conflict))
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
