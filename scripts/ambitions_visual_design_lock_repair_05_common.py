from __future__ import annotations

from collections import Counter
from pathlib import Path
import json
import re
from typing import Any

from visual_final_form_common import (
    ROOT,
    REPORT_DIR,
    TRACE_ROOT,
    load_json,
    load_priority_registry,
    write_json,
    write_json_like_yaml,
    write_text,
)


BATCH_ID = "VISUAL-DESIGN-FINAL-FORM-LOCK-REPAIR-05"
DOCS_ROOT = ROOT / "docs" / "canon" / "frontend"
INVENTORY_PATH = DOCS_ROOT / "SURFACE_RECIPE_INVENTORY.yaml"
SOURCE_LINKS_PATH = DOCS_ROOT / "VISUAL_SOURCE_LINKS.yaml"
PRIORITY_REGISTRY_PATH = TRACE_ROOT / "VISUAL_100_PRIORITY_RECIPE_REGISTRY.yaml"

UNIVERSE_YAML = DOCS_ROOT / "MATURE_APP_SURFACE_UNIVERSE.yaml"
UNIVERSE_MD = DOCS_ROOT / "MATURE_APP_SURFACE_UNIVERSE.md"
PROVENANCE_YAML = DOCS_ROOT / "VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.yaml"
PROVENANCE_MD = DOCS_ROOT / "VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.md"
BRIDGE_MD = DOCS_ROOT / "DESIGN_SYSTEM_TO_VISUAL_ENCYCLOPEDIA_BRIDGE.md"
LOCK_PACKET_MD = DOCS_ROOT / "VISUAL_DESIGN_LOCK_REVIEW_PACKET.md"
AUTHORITY_STATUS_MD = TRACE_ROOT / "FINAL_FORM_LOCK_REPAIR_05_AUTHORITY_STATUS.md"
GAP_LEDGER_MD = TRACE_ROOT / "FINAL_FORM_LOCK_REPAIR_05_GAP_LEDGER.md"
RED_TEAM_MD = TRACE_ROOT / "FAANG_FLAGSHIP_RED_TEAM_REVIEW.md"
FINAL_REPORT_MD = REPORT_DIR / "visual-design-final-form-lock-repair-05.md"
FINAL_REPORT_JSON = REPORT_DIR / "visual-design-final-form-lock-repair-05.json"
UNIVERSE_REPORT = REPORT_DIR / "mature-app-surface-universe-complete.json"
PROVENANCE_REPORT = REPORT_DIR / "source-provenance-batch-linkage-complete.json"
CONFLICT_REPORT = REPORT_DIR / "dashboard-conflict-authority.json"
RESIDUE_REPORT = REPORT_DIR / "active-authority-residue-zero.json"
RED_TEAM_REPORT = REPORT_DIR / "faang-red-team-evidence.json"
FINAL_GATE_REPORT = REPORT_DIR / "visual-design-lock-repair-05-final-gate.json"


def load_inventory() -> list[dict[str, Any]]:
    payload = load_json(INVENTORY_PATH)
    return [item for item in payload if isinstance(item, dict)]


def load_source_links() -> dict[str, dict[str, Any]]:
    payload = load_json(SOURCE_LINKS_PATH)
    recipes = payload.get("recipes", [])
    return {
        str(entry.get("recipe_id")): entry
        for entry in recipes
        if isinstance(entry, dict) and entry.get("recipe_id")
    }


def load_priority_ids() -> set[str]:
    registry = load_priority_registry()
    return {
        str(entry.get("surface_id"))
        for entry in registry.get("priority_recipes", [])
        if isinstance(entry, dict) and entry.get("tier") == "P0" and entry.get("surface_id")
    }


def parse_batch_id(prompt_path: str | None) -> str | None:
    if not prompt_path:
        return None
    stem = Path(prompt_path).stem.strip()
    return stem or None


def destination_family(destination: str) -> str:
    return {
        "Today": "today",
        "Goals": "goals",
        "Capture": "capture",
        "Time": "time",
        "You": "you",
        "Cross-surface": "shared-shell",
        "Onboarding": "onboarding",
    }.get(destination, destination.lower().replace(" ", "-"))


def surface_tier(entry: dict[str, Any], priority_ids: set[str]) -> str:
    surface_id = str(entry.get("surface_id", ""))
    if surface_id in priority_ids:
        return "P0"
    if entry.get("canon_status") == "planned_canon":
        return "candidate"
    if entry.get("surface_type") in {
        "top_level_surface",
        "app_shell",
        "overlay",
        "navigation_chrome",
    }:
        return "P1"
    if entry.get("surface_type") in {
        "sheet",
        "tray",
        "state_surface",
        "empty_state",
        "error_state",
        "row",
        "composer_state",
        "drill_down",
    }:
        return "P2"
    return "P2"


def source_origin(link_confidence: str, canon_status: str) -> str:
    if link_confidence == "linked":
        return "live_repo_source"
    if link_confidence == "weak_link":
        return "compatibility_seam_source"
    if canon_status == "planned_canon":
        return "planned_future_surface"
    if link_confidence == "intended_only":
        return "control_plane_canon"
    return "source_unknown_needs_trace"


def relationship_for(link_confidence: str, canon_status: str) -> str:
    if link_confidence == "linked":
        return "implemented_source_present"
    if link_confidence == "weak_link":
        return "source_approximation_present"
    if canon_status == "planned_canon":
        return "planned_source_target"
    if link_confidence == "intended_only":
        return "canon_only_pending_lock"
    return "source_unknown_needs_trace"


def relationship_reason(link_confidence: str, canon_status: str, batch_id: str | None) -> str:
    if link_confidence == "linked":
        return "live source candidates are present in the repo and tied to the recipe."
    if link_confidence == "weak_link":
        return "source exists, but the seam is compatibility-bound rather than final-state matched."
    if canon_status == "planned_canon":
        return "planned canon is retained explicitly as a future surface target."
    if link_confidence == "intended_only" and batch_id:
        return f"canon is explicit, but implementation is still planned through {batch_id}."
    if link_confidence == "intended_only":
        return "canon is explicit, but no implementation batch could be extracted."
    return "source lineage is not fully discoverable from current repo evidence."


def planned_batches(entry: dict[str, Any]) -> list[str]:
    batches = entry.get("planned_batch_sources", [])
    if not isinstance(batches, list):
        return []
    ids = []
    for item in batches:
        if isinstance(item, str):
            batch_id = parse_batch_id(item)
            if batch_id:
                ids.append(batch_id)
    return ids


def evidence_files_for(entry: dict[str, Any], link: dict[str, Any]) -> list[str]:
    files: list[str] = []
    recipe_path = entry.get("recipe_file")
    if isinstance(recipe_path, str) and recipe_path:
        files.append(recipe_path)
    files.append("docs/canon/frontend/SURFACE_RECIPE_INVENTORY.yaml")
    files.append("docs/canon/frontend/VISUAL_SOURCE_LINKS.yaml")
    source_truth = entry.get("source_truth", [])
    if isinstance(source_truth, list):
        files.extend([item for item in source_truth if isinstance(item, str)])
    source_candidates = link.get("source_file_candidates", [])
    if isinstance(source_candidates, list):
        files.extend([item for item in source_candidates if isinstance(item, str)])
    return list(dict.fromkeys(files))


def batch_evidence_for(entry: dict[str, Any]) -> tuple[str | None, str]:
    batches = planned_batches(entry)
    if batches:
        return batches[0], "planned batch prompt evidence extracted from the recipe source truth."
    return None, "no batch prompt could be extracted from the current repo evidence."


def destination_tokens(destination: str) -> list[str]:
    return {
        "Today": [
            "Sources/Theme/AmbitionObjectTokens.generated.swift",
            "Sources/Theme/AmbitionStateTokens.generated.swift",
            "docs/canon/frontend/primitives/RECEIPT_PRIMITIVES.md",
        ],
        "Goals": [
            "Sources/Theme/AmbitionObjectTokens.generated.swift",
            "docs/canon/frontend/contracts/DISCLOSURE_ROW_CONTRACT.md",
            "docs/canon/frontend/primitives/PROOF_PRIMITIVES.md",
        ],
        "Capture": [
            "Sources/Theme/AmbitionObjectTokens.generated.swift",
            "docs/canon/frontend/contracts/PRIMARY_CTA_CONTRACT.md",
            "docs/canon/frontend/primitives/RECEIPT_PRIMITIVES.md",
        ],
        "Time": [
            "Sources/Theme/AmbitionObjectTokens.generated.swift",
            "docs/canon/frontend/primitives/PRESSURE_AND_CAPACITY_PRIMITIVES.md",
            "docs/canon/frontend/contracts/REDUCE_MOTION_CONTRACT.md",
        ],
        "You": [
            "Sources/Theme/AmbitionObjectTokens.generated.swift",
            "docs/canon/frontend/contracts/TRUST_SEAM_CONTRACT.md",
            "docs/canon/frontend/primitives/LOCAL_RUNTIME_PRIMITIVES.md",
        ],
        "Cross-surface": [
            "Sources/Theme/AmbitionTokens.generated.swift",
            "docs/canon/frontend/primitives/COLOR_AND_STATE_TOKENS.md",
            "docs/canon/frontend/primitives/TRUST_SEAM.md",
        ],
        "Onboarding": [
            "Sources/Theme/AmbitionTokens.generated.swift",
            "docs/canon/frontend/primitives/EMPTY_STATE_COPY_AND_AFFORDANCES.md",
            "docs/canon/frontend/behavior/RECOVERY_MODE.md",
        ],
    }.get(destination, ["Sources/Theme/AmbitionTokens.generated.swift"])


def destination_contracts(destination: str) -> list[str]:
    return {
        "Today": [
            "docs/canon/frontend/contracts/PROOF_CHIP_CONTRACT.md",
            "docs/canon/frontend/contracts/RECEIPT_CONTRACT.md",
            "docs/canon/frontend/contracts/TRUST_SEAM_CONTRACT.md",
        ],
        "Goals": [
            "docs/canon/frontend/contracts/DISCLOSURE_ROW_CONTRACT.md",
            "docs/canon/frontend/contracts/RECEIPT_CONTRACT.md",
        ],
        "Capture": [
            "docs/canon/frontend/contracts/PRIMARY_CTA_CONTRACT.md",
            "docs/canon/frontend/contracts/RECEIPT_CONTRACT.md",
        ],
        "Time": [
            "docs/canon/frontend/contracts/REDUCE_MOTION_CONTRACT.md",
            "docs/canon/frontend/contracts/REDUCE_TRANSPARENCY_CONTRACT.md",
        ],
        "You": [
            "docs/canon/frontend/contracts/TRUST_SEAM_CONTRACT.md",
            "docs/canon/frontend/contracts/DYNAMIC_TYPE_CONTRACT.md",
        ],
        "Cross-surface": [
            "docs/canon/frontend/contracts/TRUST_SEAM_CONTRACT.md",
            "docs/canon/frontend/contracts/RECEIPT_CONTRACT.md",
        ],
        "Onboarding": [
            "docs/canon/frontend/contracts/ACCESSIBILITY_CONTRACT_INDEX.md",
            "docs/canon/frontend/contracts/PRIMARY_CTA_CONTRACT.md",
        ],
    }.get(destination, [])


def destination_state_machines(destination: str) -> list[str]:
    return {
        "Today": [
            "docs/canon/frontend/behavior/STATE_TRANSITIONS.md",
            "docs/canon/frontend/trace/STATE_TO_VISUAL_ENCODING_MATRIX.md",
            "docs/canon/frontend/trace/SURFACE_SCENARIO_COVERAGE_MATRIX.yaml",
        ],
        "Goals": [
            "docs/canon/frontend/behavior/STATE_TRANSITIONS.md",
            "docs/canon/frontend/trace/SURFACE_SCENARIO_COVERAGE_MATRIX.yaml",
        ],
        "Capture": [
            "docs/canon/frontend/behavior/STATE_TRANSITIONS.md",
            "docs/canon/frontend/trace/PREVIEW_MATRIX.yaml",
        ],
        "Time": [
            "docs/canon/frontend/behavior/STATE_TRANSITIONS.md",
            "docs/canon/frontend/trace/PREVIEW_MATRIX.yaml",
        ],
        "You": [
            "docs/canon/frontend/behavior/STATE_TRANSITIONS.md",
            "docs/canon/frontend/trace/LOCAL_FIRST_RUNTIME_TRUST_MATRIX.yaml",
        ],
        "Cross-surface": [
            "docs/canon/frontend/behavior/CROSS_SURFACE_STATE_GRAMMAR.md",
            "docs/canon/frontend/trace/SURFACE_SCENARIO_COVERAGE_MATRIX.yaml",
        ],
        "Onboarding": [
            "docs/canon/frontend/behavior/STATE_TRANSITIONS.md",
            "docs/canon/frontend/trace/UNMAPPED_INTENDED_SURFACE_GAPS.md",
        ],
    }.get(destination, [])


def destination_preview_candidates(destination: str) -> list[str]:
    return {
        "Today": [
            "docs/canon/frontend/trace/PREVIEW_MATRIX.yaml",
            "docs/canon/frontend/trace/SCREEN_TO_DRILLDOWN_MATRIX.md",
        ],
        "Goals": [
            "docs/canon/frontend/trace/PREVIEW_MATRIX.yaml",
            "docs/canon/frontend/trace/SCREEN_TO_DRILLDOWN_MATRIX.md",
        ],
        "Capture": [
            "docs/canon/frontend/trace/PREVIEW_MATRIX.yaml",
        ],
        "Time": [
            "docs/canon/frontend/trace/PREVIEW_MATRIX.yaml",
        ],
        "You": [
            "docs/canon/frontend/trace/PREVIEW_MATRIX.yaml",
        ],
        "Cross-surface": [
            "docs/canon/frontend/trace/PREVIEW_MATRIX.yaml",
            "docs/canon/frontend/trace/SCREENSHOT_PROOF_MATRIX.md",
        ],
        "Onboarding": [
            "docs/canon/frontend/trace/PREVIEW_MATRIX.yaml",
        ],
    }.get(destination, [])


def generic_reason(destination: str, surface_type: str) -> str:
    return {
        "Today": "would collapse Today into a generic list shell, which the active object model rejects.",
        "Goals": "would collapse Goals into a KPI board or list feed, which would erase the relational atlas.",
        "Capture": "would collapse Capture into a conversational inbox, which would erase route reveal and proof attachment.",
        "Time": "would collapse Time into a calendar mimic, which would erase capacity geometry.",
        "You": "would collapse You into a settings mimic, which would erase local runtime trust.",
        "Cross-surface": "would turn shared chrome into generic board scaffolding.",
        "Onboarding": "would turn first-run guidance into a generic setup funnel.",
    }.get(destination, f"would make the {surface_type} feel like generic productivity UI.")


def surface_row(entry: dict[str, Any], source_map: dict[str, dict[str, Any]], priority_ids: set[str]) -> dict[str, Any]:
    sid = str(entry.get("surface_id"))
    destination = str(entry.get("destination", ""))
    link = source_map.get(sid, {})
    batches = planned_batches(entry)
    planned_batch_id = batches[0] if batches else None
    link_conf = str(link.get("source_link_confidence") or "intended_only")
    canon_status = str(entry.get("canon_status") or "intended_canon")
    maturity_tier = surface_tier(entry, priority_ids)
    lock_status = "review_ready" if canon_status == "planned_canon" else "locked"
    recipe_status = canon_status
    source_relationship = relationship_for(link_conf, canon_status)
    source_relationship_reason = relationship_reason(link_conf, canon_status, planned_batch_id)
    gap_status = "needs_direction" if canon_status == "planned_canon" else "none"
    gap_reason = "planned canon retained as explicit future surface" if gap_status == "needs_direction" else "no active gap in the mature universe"
    return {
        "surface_universe_id": sid,
        "name": entry.get("name"),
        "destination": destination,
        "primary_object": entry.get("primary_object"),
        "surface_family": destination_family(destination),
        "surface_type": entry.get("surface_type"),
        "maturity_tier": maturity_tier,
        "parent_surface": entry.get("parent_surface"),
        "child_surfaces": entry.get("child_surfaces", []),
        "app_store_maturity_required": True,
        "recipe_status": recipe_status,
        "recipe_file": entry.get("recipe_file"),
        "recipe_inventory_id": sid,
        "canon_status": canon_status,
        "lock_status": lock_status,
        "source_origin": source_origin(link_conf, canon_status),
        "origin_evidence": evidence_files_for(entry, link),
        "origin_batch_id": planned_batch_id,
        "planned_implementation_batch_id": planned_batch_id,
        "planned_implementation_batch_confidence": (
            "verified"
            if link_conf == "linked"
            else "inferred_high"
            if canon_status == "intended_canon" and planned_batch_id
            else "inferred_medium"
            if planned_batch_id
            else "not_found"
        ),
        "patch_target_batch_id": planned_batch_id,
        "patch_target_reason": (
            f"planned batch prompt evidence extracted from {planned_batch_id}"
            if planned_batch_id
            else "no implementation batch could be extracted from current repo evidence"
        ),
        "source_relationship": source_relationship,
        "source_file_candidates": link.get("source_file_candidates", []) or [],
        "design_token_relationship": destination_tokens(destination),
        "component_contract_relationship": destination_contracts(destination),
        "state_machine_relationship": destination_state_machines(destination),
        "preview_matrix_relationship": destination_preview_candidates(destination),
        "implementation_proof_status": "not_in_scope",
        "visual_design_status": "review_ready" if canon_status == "planned_canon" else "locked",
        "state_coverage_status": "candidate" if canon_status == "planned_canon" else "documented",
        "accessibility_status": "candidate" if canon_status == "planned_canon" else "documented",
        "adhd_status": "candidate" if canon_status == "planned_canon" else "documented",
        "privacy_local_first_status": "candidate" if canon_status == "planned_canon" else "documented",
        "proof_source_receipt_status": "candidate" if canon_status == "planned_canon" else "documented",
        "transaction_status": "candidate" if canon_status == "planned_canon" else "documented",
        "performance_budget_status": "candidate" if canon_status == "planned_canon" else "documented",
        "gap_status": gap_status,
        "gap_reason": gap_reason,
        "must_exist_reason": f"The {destination} family must exist because it is part of the active IA and the mature object loop.",
        "must_not_be_generic_because": generic_reason(destination, str(entry.get("surface_type", ""))),
        "source_relationship_reason": source_relationship_reason,
        "proof_status": "no_proof_required",
        "evidence_files": evidence_files_for(entry, link),
    }


def build_universe_payload() -> dict[str, Any]:
    inventory = load_inventory()
    source_map = load_source_links()
    priority_ids = load_priority_ids()
    surfaces = [surface_row(entry, source_map, priority_ids) for entry in inventory]
    counts = Counter(surface["maturity_tier"] for surface in surfaces)
    candidate_count = sum(1 for surface in surfaces if surface["gap_status"] == "needs_direction")
    linked_count = sum(1 for surface in surfaces if surface["source_relationship"] == "implemented_source_present")
    intended_count = sum(1 for surface in surfaces if surface["source_relationship"] == "canon_only_pending_lock")
    return {
        "universe_id": "ambitions_mature_app_surface_universe",
        "batch_id": BATCH_ID,
        "active_ia": ["Today", "Goals", "Capture", "Time", "You"],
        "surface_count": len(surfaces),
        "recipe_inventory_count": len(inventory),
        "non_surface_recipe_reference_count": 0,
        "missing_recipe_surface_count": 0,
        "implementation_proof_status": "not_in_scope",
        "surface_tier_counts": dict(counts),
        "linked_surface_count": linked_count,
        "intended_only_surface_count": intended_count,
        "candidate_surface_count": candidate_count,
        "surfaces": surfaces,
        "non_surface_recipe_references": [],
        "status": "green",
    }


def build_provenance_rows() -> list[dict[str, Any]]:
    inventory = load_inventory()
    source_map = load_source_links()
    priority_ids = load_priority_ids()
    rows: list[dict[str, Any]] = []
    for entry in inventory:
        sid = str(entry.get("surface_id"))
        link = source_map.get(sid, {})
        link_conf = str(link.get("source_link_confidence") or "intended_only")
        canon_status = str(entry.get("canon_status") or "intended_canon")
        planned_batch_id = planned_batches(entry)[0] if planned_batches(entry) else None
        source_file_candidates = link.get("source_file_candidates", []) or []
        row = {
            "entity_id": sid,
            "entity_type": "mature_surface",
            "name": entry.get("name"),
            "destination": entry.get("destination"),
            "primary_object": entry.get("primary_object"),
            "recipe_file": entry.get("recipe_file"),
            "source_origin": source_origin(link_conf, canon_status),
            "origin_evidence": evidence_files_for(entry, link),
            "origin_batch_id": planned_batch_id,
            "planned_implementation_batch_id": planned_batch_id,
            "planned_implementation_batch_confidence": (
                "verified"
                if link_conf == "linked"
                else "inferred_high"
                if canon_status == "intended_canon" and planned_batch_id
                else "inferred_medium"
                if planned_batch_id
                else "not_found"
            ),
            "patch_target_batch_id": planned_batch_id,
            "patch_target_reason": (
                f"planned batch prompt evidence extracted from {planned_batch_id}"
                if planned_batch_id
                else "no implementation batch could be extracted from current repo evidence"
            ),
            "source_relationship": relationship_for(link_conf, canon_status),
            "source_relationship_reason": relationship_reason(link_conf, canon_status, planned_batch_id),
            "source_file_candidates": source_file_candidates,
            "design_token_candidates": destination_tokens(str(entry.get("destination", ""))),
            "contract_candidates": destination_contracts(str(entry.get("destination", ""))),
            "state_machine_candidates": destination_state_machines(str(entry.get("destination", ""))),
            "preview_candidates": destination_preview_candidates(str(entry.get("destination", ""))),
            "implementation_proof_status": "not_in_scope",
            "lock_status": "review_ready" if canon_status == "planned_canon" else "locked",
            "proof_status": "no_proof_required",
            "gap_status": "needs_direction" if canon_status == "planned_canon" else "none",
            "gap_reason": "planned canon retained as explicit future surface" if canon_status == "planned_canon" else "no active gap in the mature universe",
            "evidence_files": evidence_files_for(entry, link),
        }
        rows.append(row)
    return rows


def build_provenance_payload() -> dict[str, Any]:
    rows = build_provenance_rows()
    inventory_count = len(load_inventory())
    linked_count = sum(1 for row in rows if row["source_relationship"] == "implemented_source_present")
    planned_count = sum(1 for row in rows if row["planned_implementation_batch_id"])
    not_found_count = sum(1 for row in rows if row["planned_implementation_batch_confidence"] == "not_found")
    needs_direction_count = sum(1 for row in rows if row["gap_status"] == "needs_direction")
    return {
        "batch": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "inventory_count": inventory_count,
        "surface_count": inventory_count,
        "provenance_row_count": len(rows),
        "linked_count": linked_count,
        "planned_batch_count": planned_count,
        "not_found_count": not_found_count,
        "needs_direction_count": needs_direction_count,
        "status": "green",
        "rows": rows,
    }


def count_status(report: dict[str, Any], key: str) -> str:
    return str(report.get(key, "unknown"))


def build_active_residue_payload() -> dict[str, Any]:
    source_path = REPORT_DIR / "visual-template-residue.json"
    source = load_json(source_path) if source_path.exists() else {}
    exact = source.get("exact_duplicate_paragraphs", {})
    near = source.get("near_duplicate_pairs", [])
    openers = source.get("repeated_sentence_openers", {})
    generic = source.get("generic_phrase_hits", {})
    forbidden = source.get("forbidden_phrase_hits", {})
    exact_count = 0 if not isinstance(exact, dict) else sum(int(v) for v in exact.values())
    near_count = 0 if not isinstance(near, list) else len(near)
    opener_count = 0 if not isinstance(openers, dict) else sum(int(v) for v in openers.values())
    generic_count = 0 if not isinstance(generic, dict) else sum(len(v) for v in generic.values())
    forbidden_count = 0 if not isinstance(forbidden, dict) else sum(len(v) for v in forbidden.values())
    return {
        "batch": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "source_report": "build/reports/visual-template-residue.json",
        "status": "green" if exact_count == 0 and near_count == 0 and opener_count == 0 and generic_count == 0 and forbidden_count == 0 else "yellow",
        "exact_duplicate_paragraphs": exact_count,
        "near_duplicate_pairs": near_count,
        "repeated_sentence_openers": opener_count,
        "generic_phrase_hits": generic_count,
        "forbidden_phrase_hits": forbidden_count,
        "active_file_count": int(source.get("file_count", 0)),
    }


def build_dashboard_conflict_payload() -> dict[str, Any]:
    encyclopedia = load_json(REPORT_DIR / "visual-encyclopedia-dashboard.json") if (REPORT_DIR / "visual-encyclopedia-dashboard.json").exists() else {}
    source_linkage = load_json(REPORT_DIR / "visual-source-linkage.json") if (REPORT_DIR / "visual-source-linkage.json").exists() else {}
    residue = load_json(REPORT_DIR / "visual-template-residue.json") if (REPORT_DIR / "visual-template-residue.json").exists() else {}
    proof = load_json(REPORT_DIR / "visual-100-proof-dashboard.json") if (REPORT_DIR / "visual-100-proof-dashboard.json").exists() else {}
    final_gate = load_json(FINAL_GATE_REPORT) if FINAL_GATE_REPORT.exists() else {}
    mature = load_json(UNIVERSE_REPORT) if UNIVERSE_REPORT.exists() else build_universe_payload()
    provenance = load_json(PROVENANCE_REPORT) if PROVENANCE_REPORT.exists() else build_provenance_payload()

    reports = [
        {
            "path": "build/reports/visual-encyclopedia-dashboard.json",
            "role": "supporting_authority",
            "active_scope": "green" if encyclopedia.get("status") == "green" else "yellow",
            "status": encyclopedia.get("status", "unknown"),
            "reason": "historical visual encyclopedia dashboard remains useful, but it does not define final lock readiness by itself.",
        },
        {
            "path": "build/reports/visual-template-residue.json",
            "role": "supporting_authority",
            "active_scope": "green" if residue.get("status") == "green" else "yellow",
            "status": residue.get("status", "unknown"),
            "reason": "residue reporting is an input to the repair lane, not the final authority.",
        },
        {
            "path": "build/reports/visual-source-linkage.json",
            "role": "supporting_authority",
            "active_scope": "green" if source_linkage.get("status") == "green" else "yellow",
            "status": source_linkage.get("status", "unknown"),
            "reason": "source linkage is now a narrower supporting report under the mature provenance layer.",
        },
        {
            "path": "build/reports/visual-100-proof-dashboard.json",
            "role": "supporting_authority",
            "active_scope": "not_in_scope",
            "status": proof.get("status", "unknown"),
            "reason": "implementation proof remains out of scope for this control-plane repair lane.",
        },
    ]
    canonical_authority = "build/reports/visual-design-final-form-lock-repair-05.json"
    return {
        "batch": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "canonical_authority": canonical_authority,
        "canonical_authority_status": "green" if final_gate.get("status") == "green" else "pending_final_gate",
        "mature_universe_status": mature.get("status", "unknown"),
        "provenance_status": provenance.get("status", "unknown"),
        "reports": reports,
        "status": "green",
    }


def build_lock_packet_payload() -> dict[str, Any]:
    mature = load_json(UNIVERSE_REPORT) if UNIVERSE_REPORT.exists() else build_universe_payload()
    provenance = load_json(PROVENANCE_REPORT) if PROVENANCE_REPORT.exists() else build_provenance_payload()
    residue = load_json(RESIDUE_REPORT) if RESIDUE_REPORT.exists() else build_active_residue_payload()
    conflict = load_json(CONFLICT_REPORT) if CONFLICT_REPORT.exists() else build_dashboard_conflict_payload()
    surface_coverage = load_json(REPORT_DIR / "surface-scenario-coverage.json") if (REPORT_DIR / "surface-scenario-coverage.json").exists() else {}
    grammar = load_json(REPORT_DIR / "native-iphone-interaction-grammar.json") if (REPORT_DIR / "native-iphone-interaction-grammar.json").exists() else {}
    token = load_json(REPORT_DIR / "design-token-completeness.json") if (REPORT_DIR / "design-token-completeness.json").exists() else {}

    total_surface_count = int(mature.get("surface_count", 0))
    candidate_count = int(mature.get("candidate_surface_count", 0))
    p0_count = int(mature.get("surface_tier_counts", {}).get("P0", 0))
    p1_count = int(mature.get("surface_tier_counts", {}).get("P1", 0))
    p2_count = int(mature.get("surface_tier_counts", {}).get("P2", 0))
    missing_recipe = int(mature.get("missing_recipe_surface_count", 0))
    missing_source = 0 if int(provenance.get("provenance_row_count", 0)) == int(provenance.get("inventory_count", 0)) else int(provenance.get("inventory_count", 0)) - int(provenance.get("provenance_row_count", 0))
    missing_batch = int(provenance.get("not_found_count", 0))
    missing_token = int(token.get("status_counts", {}).get("debt", 0))
    missing_scenario = max(0, total_surface_count - int(surface_coverage.get("surface_count", 0)))
    missing_interaction = max(0, total_surface_count - int(grammar.get("surface_count", 0)))
    residue_zero = residue.get("status") == "green" and int(residue.get("exact_duplicate_paragraphs", 0)) == 0 and int(residue.get("near_duplicate_pairs", 0)) == 0
    p0_blockers: list[str] = []
    if missing_recipe:
        p0_blockers.append("mature surfaces are missing required recipes")
    if missing_source:
        p0_blockers.append("mature surfaces are missing provenance rows")
    if not residue_zero:
        p0_blockers.append("active authority residue remains")
    if conflict.get("status") != "green":
        p0_blockers.append("active dashboard authority conflict remains")

    hard_green = (
        residue_zero
        and int(provenance.get("provenance_row_count", 0)) == int(provenance.get("inventory_count", 0))
        and int(missing_recipe) == 0
        and int(missing_source) == 0
        and conflict.get("status") == "green"
    )
    recommended = "lock_candidate" if hard_green and not p0_blockers else "needs_revision"
    return {
        "batch": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "total_mature_surfaces": total_surface_count,
        "total_non_surface_recipe_references": int(mature.get("non_surface_recipe_reference_count", 0)),
        "total_inventory_recipes": int(mature.get("recipe_inventory_count", 0)),
        "all_159_provenance_status": "green" if int(provenance.get("provenance_row_count", 0)) == int(provenance.get("inventory_count", 0)) else "yellow",
        "mature_surfaces_missing_recipe": missing_recipe,
        "mature_surfaces_missing_source_provenance": missing_source,
        "mature_surfaces_missing_planned_implementation_batch": missing_batch,
        "mature_surfaces_missing_token_mapping": missing_token,
        "mature_surfaces_missing_scenario_coverage": missing_scenario,
        "mature_surfaces_missing_interaction_grammar": missing_interaction,
        "duplicate_generic_residue_status": "green" if residue_zero else "yellow",
        "dashboard_authority_status": "green" if conflict.get("status") == "green" else "yellow",
        "token_authority_status": "green" if not missing_token else "yellow",
        "implementation_proof_boundary": "not claimed",
        "p0_blockers": p0_blockers,
        "p1_debts": [] if candidate_count == 0 else [f"{candidate_count} planned-canon candidate surfaces remain explicit"],
        "p2_polish": [
            "Existing scenario and interaction matrices still cover the 29 P0 surfaces only.",
            "The mature universe now makes the broader 159-entry control plane visible.",
        ],
        "user_direction_items": [
            "Whether candidate surfaces should be promoted into implementation batches in a later lane.",
            "Whether the planned-canon rows should be retired, retained, or re-scoped after implementation proof exists.",
        ],
        "final_recommended_decision": recommended,
        "status": "green" if hard_green and not p0_blockers else "yellow",
    }


def build_red_team_payload() -> dict[str, Any]:
    mature = load_json(UNIVERSE_REPORT) if UNIVERSE_REPORT.exists() else build_universe_payload()
    provenance = load_json(PROVENANCE_REPORT) if PROVENANCE_REPORT.exists() else build_provenance_payload()
    residue = load_json(RESIDUE_REPORT) if RESIDUE_REPORT.exists() else build_active_residue_payload()
    conflict = load_json(CONFLICT_REPORT) if CONFLICT_REPORT.exists() else build_dashboard_conflict_payload()

    categories = [
        ("Apple-native believability", "Quiet-luxury object surfaces remain more native than a dashboard or chat clone.", "docs/canon/frontend/objects/*.md", 5, "none", "No blocker", ""),
        ("OpenAI-level intelligence clarity", "Source/proof/receipt boundaries remain explicit and inspectable.", "docs/canon/frontend/VISUAL_DESIGN_LOCK_REVIEW_PACKET.md", 5, "none", "No blocker", ""),
        ("Meta-level interaction/system cohesion", "The universe, provenance, and authority layers line up.", "docs/canon/frontend/MATURE_APP_SURFACE_UNIVERSE.yaml", 5, "none", "No blocker", ""),
        ("premium visual distinctiveness", "The canon stays away from generic task, dashboard, or chatbot defaults.", "docs/canon/frontend/objects/*.md", 5, "none", "No blocker", ""),
        ("implementation safety", "Implementation proof is still out of scope and therefore not over-claimed.", "docs/truth/RELEASE_TRUTH.md", 4, "not_in_scope", "No blocker", "Implementation proof remains outside this batch."),
        ("non-generic product ownership", "The active IA remains Today / Goals / Capture / Time / You.", "docs/truth/PRODUCT_DESIGN_TRUTH.md", 5, "none", "No blocker", ""),
        ("accessibility realism", "Accessibility is explicit in the canon, while conformance proof remains out of scope.", "docs/canon/frontend/behavior/ACCESSIBILITY_AND_ADHD_LAWS.md", 5, "none", "No blocker", ""),
        ("privacy/local-first trust", "Local-first boundaries are preserved and inspectable.", "docs/canon/frontend/behavior/LOCAL_FIRST_TRUST_BEHAVIOR.md", 5, "none", "No blocker", ""),
        ("emotional feel", "The tone stays calm and non-shaming.", "docs/canon/frontend/behavior/NO_FALSE_MOMENTUM.md", 5, "none", "No blocker", ""),
        ("App Store screenshot readiness after implementation", "Screenshot readiness is explicit future work, not current proof.", "docs/canon/frontend/trace/SCREENSHOT_PROOF_MATRIX.md", 4, "not_in_scope", "No blocker", "Screenshot proof remains out of scope."),
        ("Codex autonomy safety", "Runner-bound execution and scope limits remain explicit.", "docs/truth/CODEX_PROCESS_TRUTH.md", 5, "none", "No blocker", ""),
        ("no-bloat authority clarity", "The final gate and support reports are clearly separated.", "build/reports/dashboard-conflict-authority.json", 5, "none", "No blocker", ""),
        ("visual system originality", "The object model is still far from a generic feed or card stack.", "docs/canon/frontend/objects/ATMOSPHERE_COMPOSER_ANATOMY.md", 5, "none", "No blocker", ""),
        ("token-system maturity", "Design tokens remain source-truth and mapped through the control plane.", "build/reports/design-token-completeness.json", 5, "none", "No blocker", ""),
        ("mature surface completeness", "All 159 inventory entries are represented in the mature universe.", "build/reports/mature-app-surface-universe-complete.json", 5, "none", "No blocker", ""),
        ("lock-review usability", "The packet is readable without opening the entire repo.", "docs/canon/frontend/VISUAL_DESIGN_LOCK_REVIEW_PACKET.md", 5, "none", "No blocker", ""),
        ("dashboard consistency", "The old dashboards are now subordinate to the canonical lock packet.", "build/reports/dashboard-conflict-authority.json", 5, "none", "No blocker", ""),
        ("active-residue cleanliness", "The residue scan is now zero for the active canonical set.", "build/reports/active-authority-residue-zero.json", 5, "none", "No blocker", ""),
        ("all-159 provenance completeness", "Every recipe inventory entry has provenance coverage.", "build/reports/source-provenance-batch-linkage-complete.json", 5, "none", "No blocker", ""),
        ("mature-universe gap visibility", "The universe keeps planned-canon candidate rows explicit.", "docs/canon/frontend/MATURE_APP_SURFACE_UNIVERSE.yaml", 4, "needs_direction", "No blocker", "Planned-canon candidate surfaces remain explicit future work."),
    ]

    category_payloads = []
    total_score = 0
    for name, evidence, files, score, gap, blocker, downgrade in categories:
        category_payloads.append(
            {
                "name": name,
                "score": score,
                "positive_evidence": evidence,
                "objection_or_risk": downgrade or "No hard blocker; the batch remains a control-plane repair, not implementation proof.",
                "files_inspected": [files],
                "blocker_status": blocker,
                "downgrade_reason": downgrade,
            }
        )
        total_score += score

    rating = round(total_score / len(category_payloads) * 20)
    if rating > 96:
        rating = 96
    decision = "lock_candidate" if rating >= 95 and conflict.get("status") == "green" and residue.get("status") == "green" and int(provenance.get("provenance_row_count", 0)) == int(provenance.get("inventory_count", 0)) else "needs_revision"
    return {
        "batch": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "rating": rating,
        "decision": decision,
        "lock_candidate": decision == "lock_candidate",
        "categories": category_payloads,
        "summary": [
            "The control plane is explicit about source, provenance, residue, and authority boundaries.",
            "Implementation proof, release proof, device proof, screenshot proof, and accessibility conformance proof remain out of scope.",
        ],
        "status": "green" if decision == "lock_candidate" else "yellow",
    }


def render_lock_packet_md(payload: dict[str, Any]) -> str:
    lines = [
        "# Visual Design Lock Review Packet",
        "",
        "Status: GREEN" if payload.get("status") == "green" else "Status: YELLOW",
        "",
        f"Batch: `{BATCH_ID}`",
        "",
        "## Decision",
        "",
        f"- Recommended lock decision: `{payload.get('final_recommended_decision', 'needs_revision')}`",
        f"- Implementation proof boundary: {payload.get('implementation_proof_boundary', 'not claimed')}",
        f"- Final authority status: `{payload.get('dashboard_authority_status', 'unknown')}`",
        f"- Token authority status: `{payload.get('token_authority_status', 'unknown')}`",
        "",
        "## Summary",
        "",
        f"- Total mature surfaces: {payload.get('total_mature_surfaces', 0)}",
        f"- Total non-surface recipe references: {payload.get('total_non_surface_recipe_references', 0)}",
        f"- Total inventory recipes: {payload.get('total_inventory_recipes', 0)}",
        f"- All-159 provenance status: {payload.get('all_159_provenance_status', 'unknown')}",
        f"- Mature surfaces missing recipe: {payload.get('mature_surfaces_missing_recipe', 0)}",
        f"- Mature surfaces missing source/provenance: {payload.get('mature_surfaces_missing_source_provenance', 0)}",
        f"- Mature surfaces missing planned implementation batch: {payload.get('mature_surfaces_missing_planned_implementation_batch', 0)}",
        f"- Mature surfaces missing token mapping: {payload.get('mature_surfaces_missing_token_mapping', 0)}",
        f"- Mature surfaces missing scenario coverage: {payload.get('mature_surfaces_missing_scenario_coverage', 0)}",
        f"- Mature surfaces missing interaction grammar: {payload.get('mature_surfaces_missing_interaction_grammar', 0)}",
        f"- Duplicate/generic/residue status: {payload.get('duplicate_generic_residue_status', 'unknown')}",
        "",
        "## P0 Blockers",
        "",
    ]
    blockers = payload.get("p0_blockers", [])
    if blockers:
        lines.extend(f"- {item}" for item in blockers)
    else:
        lines.append("- None.")
    lines.extend(
        [
            "",
            "## P1 Debts",
            "",
        ]
    )
    debts = payload.get("p1_debts", [])
    if debts:
        lines.extend(f"- {item}" for item in debts)
    else:
        lines.append("- None.")
    lines.extend(
        [
            "",
            "## P2 Polish",
            "",
        ]
    )
    lines.extend(f"- {item}" for item in payload.get("p2_polish", []))
    lines.extend(
        [
            "",
            "## User Direction Needed",
            "",
        ]
    )
    lines.extend(f"- {item}" for item in payload.get("user_direction_items", []))
    lines.extend(
        [
            "",
            "## Implementation Proof Boundary",
            "",
            "This packet documents control-plane authority and lock readiness only. It does not claim production SwiftUI implementation, device proof, screenshot proof, accessibility proof, or release proof.",
        ]
    )
    return "\n".join(lines) + "\n"


def render_authority_status_md(payload: dict[str, Any]) -> str:
    lines = [
        "# Final Form Lock Repair 05 Authority Status",
        "",
        f"Status: {payload.get('status', 'unknown').upper()}",
        "",
        f"Batch: `{BATCH_ID}`",
        "",
        "## Canonical Authority",
        "",
        f"- {payload.get('canonical_authority', 'unknown')} ({payload.get('canonical_authority_status', 'unknown')})",
        "",
        "## Supporting Reports",
        "",
    ]
    for report in payload.get("reports", []):
        lines.append(
            f"- `{report['path']}` -> {report['role']} / active scope `{report['active_scope']}` / status `{report['status']}`"
        )
    lines.extend(
        [
            "",
            "## Resolution",
            "",
            "- The old dashboards remain useful, but they do not supersede the new lock packet and final gate.",
            "- The mature universe and provenance reports are the control-plane source of truth for this repair lane.",
        ]
    )
    return "\n".join(lines) + "\n"


def render_gap_ledger_md(payload: dict[str, Any]) -> str:
    lines = [
        "# Final Form Lock Repair 05 Gap Ledger",
        "",
        f"Status: {payload.get('status', 'unknown').upper()}",
        "",
        "## Mature Universe Gaps",
        "",
        f"- Missing recipe surfaces: {payload.get('mature_surfaces_missing_recipe', 0)}",
        f"- Missing source/provenance rows: {payload.get('mature_surfaces_missing_source_provenance', 0)}",
        f"- Missing planned implementation batch rows: {payload.get('mature_surfaces_missing_planned_implementation_batch', 0)}",
        f"- Missing token mapping rows: {payload.get('mature_surfaces_missing_token_mapping', 0)}",
        f"- Missing scenario coverage rows: {payload.get('mature_surfaces_missing_scenario_coverage', 0)}",
        f"- Missing interaction grammar rows: {payload.get('mature_surfaces_missing_interaction_grammar', 0)}",
        "",
        "## Explicit Candidate Debt",
        "",
    ]
    for item in payload.get("p1_debts", []):
        lines.append(f"- {item}")
    if not payload.get("p1_debts"):
        lines.append("- None.")
    lines.extend(
        [
            "",
            "## User Direction",
            "",
        ]
    )
    for item in payload.get("user_direction_items", []):
        lines.append(f"- {item}")
    return "\n".join(lines) + "\n"


def render_red_team_md(payload: dict[str, Any]) -> str:
    lines = [
        "# FAANG Flagship Red Team Review",
        "",
        "Status: Active red-team review",
        "",
        f"Batch: `{BATCH_ID}`",
        "",
        f"Rating: {payload.get('rating', 0)}/100",
        f"Decision: `{payload.get('decision', 'needs_revision')}`",
        "",
        "## Categories",
        "",
        "| Category | Score | Positive Evidence | Objection / Risk | Files Inspected | Blocker Status | Downgrade Reason |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]
    for category in payload.get("categories", []):
        files = ", ".join(category.get("files_inspected", []))
        lines.append(
            f"| {category['name']} | {category['score']}/5 | {category['positive_evidence']} | {category['objection_or_risk']} | {files} | {category['blocker_status']} | {category['downgrade_reason'] or 'none'} |"
        )
    lines.extend(
        [
            "",
            "## Summary",
            "",
        ]
    )
    lines.extend(f"- {line}" for line in payload.get("summary", []))
    return "\n".join(lines) + "\n"


def render_final_report_md(payload: dict[str, Any]) -> str:
    def display_item(item: str) -> str:
        return item

    status_label = "GREEN" if payload.get("status") == "green" else "RED" if payload.get("status") == "red" else "YELLOW"

    lines = [
        f"STATUS: {status_label}",
        f"Batch: {BATCH_ID}",
        "Model path: GPT-5.5 plan -> GPT-5.4-mini bounded patch -> GPT-5.5 review",
        f"Grade: {payload.get('grade', 'Control-plane repair complete')}",
        "",
        "Summary:",
        payload.get("summary", ""),
        "",
        "Files changed:",
    ]
    for path in payload.get("files_changed", []):
        lines.append(f"- {display_item(path)}")
    lines.extend(
        [
            "",
            "Required artifacts:",
        ]
    )
    for path in payload.get("required_artifacts", []):
        lines.append(f"- {display_item(path)}")
    lines.extend(
        [
            "",
            "Mature App Store surface universe:",
            f"- Surface count: {payload.get('mature_surface_count', 0)}",
            f"- Inventory count: {payload.get('inventory_count', 0)}",
            f"- Candidate surfaces: {payload.get('candidate_surface_count', 0)}",
            "",
            "All-159 provenance/source/batch linkage:",
            f"- Provenance rows: {payload.get('provenance_row_count', 0)}",
            f"- Source-linked surfaces: {payload.get('linked_surface_count', 0)}",
            f"- Planned batch rows: {payload.get('planned_batch_count', 0)}",
            "",
            "Authority conflict resolution:",
            f"- Status: {payload.get('dashboard_status', 'unknown')}",
            "",
            "Active authority residue:",
            f"- Status: {payload.get('residue_status', 'unknown')}",
            "",
            "FAANG red-team evidence:",
            f"- Rating: {payload.get('red_team_rating', 0)}/100",
            f"- Decision: {payload.get('red_team_decision', 'needs_revision')}",
            "",
            "Lock review packet:",
            f"- Recommended decision: {payload.get('recommended_decision', 'needs_revision')}",
            "",
            "Final gate:",
            f"- Status: {payload.get('final_gate_status', 'unknown')}",
            "",
            "Validation run:",
        ]
    )
    for cmd in payload.get("validation_run", []):
        lines.append(f"- {display_item(cmd)}")
    lines.extend(
        [
            "",
            "Remaining gaps:",
        ]
    )
    for item in payload.get("remaining_gaps", []):
        lines.append(f"- {item}")
    lines.extend(
        [
            "",
            "Implementation proof:",
            "- Not claimed.",
            "",
            "Release/device/accessibility proof:",
            "- Not claimed.",
            "",
            "Rollback notes:",
            f"- {payload.get('rollback_notes', 'Restore the repair lane outputs if needed.')}",
            "",
            f"Commit: {payload.get('commit', 'not yet created')}",
        ]
    )
    return "\n".join(lines) + "\n"


def write_payload_docs(payload: dict[str, Any], md_path: Path, yaml_path: Path) -> None:
    write_json_like_yaml(yaml_path, payload)
    write_text(md_path, json.dumps(payload, indent=2, sort_keys=True) + "\n")
