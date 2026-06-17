from __future__ import annotations

from collections import Counter
from functools import lru_cache
from pathlib import Path
import json
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
FRONTEND_ROOT = ROOT / "frontend" / "visual-encyclopedia"
REPORT_DIR = ROOT / "build" / "reports"
PACKET_DIR = REPORT_DIR / "frontend-authority-packets"
PREFLIGHT_DIR = REPORT_DIR / "frontend-authority-preflight"
PROMPT_DIR = ROOT / "prompts" / "generated" / "frontend"
RECEIPT_DIR = REPORT_DIR / "frontend-implementation-receipts"

BATCH_ID = "ENCYCLOPEDIA-TO-FRONTEND-OPERATING-SYSTEM-06"
ACTIVE_IA = ("Today", "Goals", "Time", "You")

SURFACE_UNIVERSE_PATH = FRONTEND_ROOT / "MATURE_APP_SURFACE_UNIVERSE.yaml"
PROVENANCE_PATH = FRONTEND_ROOT / "VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.yaml"
INVENTORY_PATH = FRONTEND_ROOT / "SURFACE_RECIPE_INVENTORY.yaml"
SOURCE_LINKS_PATH = FRONTEND_ROOT / "VISUAL_SOURCE_LINKS.yaml"
PREVIEW_MATRIX_PATH = FRONTEND_ROOT / "trace" / "PREVIEW_MATRIX.yaml"
SCENARIO_MATRIX_PATH = FRONTEND_ROOT / "trace" / "SURFACE_SCENARIO_COVERAGE_MATRIX.yaml"
SOURCE_PROOF_MATRIX_PATH = FRONTEND_ROOT / "trace" / "SOURCE_PROOF_RECEIPT_COVERAGE_MATRIX.yaml"
AUTHORITY_INDEX_PATH = FRONTEND_ROOT / "FRONTEND_AUTHORITY_INDEX.md"
ENCYCLOPEDIA_OS_DOC_PATH = FRONTEND_ROOT / "ENCYCLOPEDIA_TO_FRONTEND_OS.md"
RECEIPT_SCHEMA_PATH = FRONTEND_ROOT / "trace" / "FRONTEND_IMPLEMENTATION_RECEIPT_SCHEMA.yaml"
PROOF_CONTRACT_SCHEMA_PATH = FRONTEND_ROOT / "trace" / "FRONTEND_PROOF_CONTRACT_SCHEMA.yaml"
SOURCE_BINDINGS_PATH = FRONTEND_ROOT / "trace" / "FRONTEND_SOURCE_BINDINGS.yaml"

DESTINATION_BIBLE_PATHS = {
    "Today": FRONTEND_ROOT / "surfaces" / "TODAY_REALITY_MERIDIAN_BIBLE.md",
    "Goals": FRONTEND_ROOT / "surfaces" / "GOALS_CONSTELLATION_ATLAS_BIBLE.md",
    "Capture": FRONTEND_ROOT / "surfaces" / "CAPTURE_ATMOSPHERE_COMPOSER_BIBLE.md",
    "Time": FRONTEND_ROOT / "surfaces" / "TIME_LIFESHAPE_FIELD_BIBLE.md",
    "You": FRONTEND_ROOT / "surfaces" / "YOU_USER_SYSTEM_PROFILE_BIBLE.md",
    "Cross-surface": FRONTEND_ROOT / "surfaces" / "GLOBAL_SHELL_AND_CHROME_BIBLE.md",
}


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def write_json(path: Path, payload: Any) -> None:
    write_text(path, json.dumps(payload, indent=2, ensure_ascii=False, sort_keys=True) + "\n")


def write_json_like_yaml(path: Path, payload: Any) -> None:
    write_text(path, json.dumps(payload, indent=2, ensure_ascii=False, sort_keys=True) + "\n")


@lru_cache(maxsize=1)
def universe_payload() -> dict[str, Any]:
    return load_json(SURFACE_UNIVERSE_PATH)


@lru_cache(maxsize=1)
def provenance_payload() -> dict[str, Any]:
    return load_json(PROVENANCE_PATH)


@lru_cache(maxsize=1)
def inventory_payload() -> list[dict[str, Any]]:
    return [row for row in load_json(INVENTORY_PATH) if isinstance(row, dict)]


@lru_cache(maxsize=1)
def source_links_payload() -> dict[str, Any]:
    return load_json(SOURCE_LINKS_PATH)


@lru_cache(maxsize=1)
def scenario_payload() -> dict[str, Any]:
    return load_json(SCENARIO_MATRIX_PATH)


@lru_cache(maxsize=1)
def proof_receipt_payload() -> dict[str, Any]:
    return load_json(SOURCE_PROOF_MATRIX_PATH)


def universe_rows() -> list[dict[str, Any]]:
    return [row for row in universe_payload().get("surfaces", []) if isinstance(row, dict)]


def provenance_rows() -> list[dict[str, Any]]:
    return [row for row in provenance_payload().get("rows", []) if isinstance(row, dict)]


def source_link_rows() -> list[dict[str, Any]]:
    return [row for row in source_links_payload().get("recipes", []) if isinstance(row, dict)]


def universe_map() -> dict[str, dict[str, Any]]:
    return {str(row.get("surface_universe_id")): row for row in universe_rows() if row.get("surface_universe_id")}


def provenance_map() -> dict[str, dict[str, Any]]:
    return {str(row.get("entity_id")): row for row in provenance_rows() if row.get("entity_id")}


def inventory_map() -> dict[str, dict[str, Any]]:
    return {str(row.get("surface_id")): row for row in inventory_payload() if row.get("surface_id")}


def source_link_map() -> dict[str, dict[str, Any]]:
    return {str(row.get("recipe_id")): row for row in source_link_rows() if row.get("recipe_id")}


def dedupe(items: list[Any]) -> list[Any]:
    out: list[Any] = []
    seen: set[Any] = set()
    for item in items:
        key = json.dumps(item, sort_keys=True, ensure_ascii=False) if isinstance(item, dict) else item
        if key in seen or item in (None, "", [], {}):
            continue
        seen.add(key)
        out.append(item)
    return out


def surface_record(surface_id: str) -> dict[str, Any]:
    try:
        return universe_map()[surface_id]
    except KeyError as exc:
        raise KeyError(f"unknown surface id: {surface_id}") from exc


def provenance_record(surface_id: str) -> dict[str, Any] | None:
    return provenance_map().get(surface_id)


def inventory_record(surface_id: str) -> dict[str, Any] | None:
    return inventory_map().get(surface_id)


def source_link_record(surface_id: str) -> dict[str, Any] | None:
    return source_link_map().get(surface_id)


def surface_bible_path(destination: str) -> str | None:
    path = DESTINATION_BIBLE_PATHS.get(destination)
    return str(path.relative_to(ROOT)) if path else None


def destination_slug(destination: str) -> str:
    return destination.lower().replace(" ", "_").replace("-", "_")


def packet_paths(surface_id: str) -> tuple[Path, Path]:
    return PACKET_DIR / f"{surface_id}.md", PACKET_DIR / f"{surface_id}.json"


def preflight_paths(surface_id: str) -> tuple[Path, Path]:
    return PREFLIGHT_DIR / f"{surface_id}.md", PREFLIGHT_DIR / f"{surface_id}.json"


def prompt_paths(batch_id: str) -> tuple[Path, Path]:
    return PROMPT_DIR / f"{batch_id}.md", REPORT_DIR / "frontend-implementation-prompts" / f"{batch_id}.json"


def source_candidates_for(surface_id: str) -> list[str]:
    row = surface_record(surface_id)
    provenance = provenance_record(surface_id) or {}
    inventory = inventory_record(surface_id) or {}
    source_link = source_link_record(surface_id) or {}
    candidates: list[str] = []
    for key in ("source_file_candidates",):
        value = row.get(key)
        if isinstance(value, list):
            candidates.extend([item for item in value if isinstance(item, str)])
        value = provenance.get(key)
        if isinstance(value, list):
            candidates.extend([item for item in value if isinstance(item, str)])
        value = source_link.get(key)
        if isinstance(value, list):
            candidates.extend([item for item in value if isinstance(item, str)])
        value = inventory.get(key)
        if isinstance(value, list):
            candidates.extend([item for item in value if isinstance(item, str)])
    return dedupe(candidates)


def token_candidates(surface_id: str) -> list[str]:
    row = surface_record(surface_id)
    provenance = provenance_record(surface_id) or {}
    inventory = inventory_record(surface_id) or {}
    tokens: list[str] = []
    for key in ("design_token_relationship", "design_token_candidates"):
        value = row.get(key)
        if isinstance(value, list):
            tokens.extend([item for item in value if isinstance(item, str)])
        value = provenance.get(key)
        if isinstance(value, list):
            tokens.extend([item for item in value if isinstance(item, str)])
        value = inventory.get(key)
        if isinstance(value, list):
            tokens.extend([item for item in value if isinstance(item, str)])
    return dedupe(tokens)


def contract_candidates(surface_id: str) -> list[str]:
    row = surface_record(surface_id)
    provenance = provenance_record(surface_id) or {}
    contracts: list[str] = []
    for key in ("component_contract_relationship", "contract_candidates"):
        value = row.get(key)
        if isinstance(value, list):
            contracts.extend([item for item in value if isinstance(item, str)])
        value = provenance.get(key)
        if isinstance(value, list):
            contracts.extend([item for item in value if isinstance(item, str)])
    return dedupe(contracts)


def scenario_requirements(surface_id: str) -> list[dict[str, Any]]:
    payload = scenario_payload()
    rows = [row for row in payload.get("surfaces", []) if isinstance(row, dict) and row.get("surface_id") == surface_id]
    scenarios: list[dict[str, Any]] = []
    for row in rows:
        scenario_items = row.get("scenarios", {})
        if isinstance(scenario_items, dict):
            for key, value in scenario_items.items():
                if isinstance(value, dict):
                    scenarios.append(
                        {
                            "state": key,
                            "status": value.get("status"),
                            "definition": value.get("definition"),
                            "evidence": value.get("evidence"),
                        }
                    )
    return scenarios


def proof_requirements(surface_id: str) -> dict[str, Any]:
    row = surface_record(surface_id)
    bible = surface_bible_path(str(row.get("destination", "")))
    return {
        "implementation_proof_status": row.get("implementation_proof_status"),
        "proof_status": row.get("proof_status"),
        "proof_source_receipt_status": row.get("proof_source_receipt_status"),
        "preview_relationship": row.get("preview_matrix_relationship", []),
        "state_relationship": row.get("state_machine_relationship", []),
        "surface_bible": bible,
    }


def implementation_status(source_relationship: str, proof_status: str) -> str:
    if source_relationship == "implemented_source_present":
        return "proven" if proof_status == "proven" else "implemented_unproven"
    if source_relationship == "source_approximation_present":
        return "source_approximation_present"
    if source_relationship == "canon_only_pending_lock":
        return "canon_only_pending_lock"
    if source_relationship == "planned_source_target":
        return "planned"
    return "planned"


def proof_binding_status(proof_status: str) -> str:
    return {
        "no_proof_required": "not_in_scope",
        "not_in_scope": "not_in_scope",
        "proof_required": "required_missing",
        "proof_missing": "required_missing",
        "partial": "partial",
        "proven": "proven",
    }.get(str(proof_status), "not_in_scope")


def source_origin(source_link_confidence: str, canon_status: str) -> str:
    if source_link_confidence == "linked":
        return "live_repo_source"
    if source_link_confidence == "weak_link":
        return "compatibility_seam_source"
    if canon_status == "planned_canon":
        return "planned_future_surface"
    if source_link_confidence == "intended_only":
        return "control_plane_canon"
    return "source_unknown_needs_trace"


def source_relationship(source_link_confidence: str, canon_status: str) -> str:
    if source_link_confidence == "linked":
        return "implemented_source_present"
    if source_link_confidence == "weak_link":
        return "source_approximation_present"
    if canon_status == "planned_canon":
        return "planned_source_target"
    if source_link_confidence == "intended_only":
        return "canon_only_pending_lock"
    return "source_unknown_needs_trace"


def source_relationship_reason(source_link_confidence: str, canon_status: str, batch_id: str | None) -> str:
    if source_link_confidence == "linked":
        return "live source candidates are present in the repo and tied to the recipe."
    if source_link_confidence == "weak_link":
        return "source exists, but the seam is compatibility-bound rather than final-state matched."
    if canon_status == "planned_canon":
        return "planned canon is retained explicitly as a future surface target."
    if source_link_confidence == "intended_only" and batch_id:
        return f"canon is explicit, but implementation is still planned through {batch_id}."
    if source_link_confidence == "intended_only":
        return "canon is explicit, but no implementation batch could be extracted."
    return "source lineage is not fully discoverable from current repo evidence."


def destination_tokens(destination: str) -> list[str]:
    return {
        "Today": [
            "Sources/Theme/AmbitionObjectTokens.generated.swift",
            "Sources/Theme/AmbitionStateTokens.generated.swift",
            "frontend/visual-encyclopedia/primitives/RECEIPT_PRIMITIVES.md",
        ],
        "Goals": [
            "Sources/Theme/AmbitionObjectTokens.generated.swift",
            "frontend/visual-encyclopedia/contracts/DISCLOSURE_ROW_CONTRACT.md",
            "frontend/visual-encyclopedia/primitives/PROOF_PRIMITIVES.md",
        ],
        "Capture": [
            "Sources/Theme/AmbitionObjectTokens.generated.swift",
            "frontend/visual-encyclopedia/contracts/PRIMARY_CTA_CONTRACT.md",
            "frontend/visual-encyclopedia/primitives/RECEIPT_PRIMITIVES.md",
        ],
        "Time": [
            "Sources/Theme/AmbitionObjectTokens.generated.swift",
            "frontend/visual-encyclopedia/primitives/PRESSURE_AND_CAPACITY_PRIMITIVES.md",
            "frontend/visual-encyclopedia/contracts/REDUCE_MOTION_CONTRACT.md",
        ],
        "You": [
            "Sources/Theme/AmbitionObjectTokens.generated.swift",
            "frontend/visual-encyclopedia/contracts/TRUST_SEAM_CONTRACT.md",
            "frontend/visual-encyclopedia/primitives/LOCAL_RUNTIME_PRIMITIVES.md",
        ],
        "Cross-surface": [
            "Sources/Theme/AmbitionTokens.generated.swift",
            "frontend/visual-encyclopedia/primitives/COLOR_AND_STATE_TOKENS.md",
            "frontend/visual-encyclopedia/primitives/TRUST_SEAM.md",
        ],
        "Onboarding": [
            "Sources/Theme/AmbitionTokens.generated.swift",
            "frontend/visual-encyclopedia/primitives/EMPTY_STATE_COPY_AND_AFFORDANCES.md",
            "frontend/visual-encyclopedia/behavior/RECOVERY_MODE.md",
        ],
    }.get(destination, ["Sources/Theme/AmbitionTokens.generated.swift"])


def destination_contracts(destination: str) -> list[str]:
    return {
        "Today": [
            "frontend/visual-encyclopedia/contracts/PROOF_CHIP_CONTRACT.md",
            "frontend/visual-encyclopedia/contracts/RECEIPT_CONTRACT.md",
            "frontend/visual-encyclopedia/contracts/TRUST_SEAM_CONTRACT.md",
        ],
        "Goals": [
            "frontend/visual-encyclopedia/contracts/DISCLOSURE_ROW_CONTRACT.md",
            "frontend/visual-encyclopedia/contracts/RECEIPT_CONTRACT.md",
        ],
        "Capture": [
            "frontend/visual-encyclopedia/contracts/PRIMARY_CTA_CONTRACT.md",
            "frontend/visual-encyclopedia/contracts/RECEIPT_CONTRACT.md",
        ],
        "Time": [
            "frontend/visual-encyclopedia/contracts/REDUCE_MOTION_CONTRACT.md",
            "frontend/visual-encyclopedia/contracts/REDUCE_TRANSPARENCY_CONTRACT.md",
        ],
        "You": [
            "frontend/visual-encyclopedia/contracts/TRUST_SEAM_CONTRACT.md",
            "frontend/visual-encyclopedia/contracts/DYNAMIC_TYPE_CONTRACT.md",
        ],
        "Cross-surface": [
            "frontend/visual-encyclopedia/contracts/TRUST_SEAM_CONTRACT.md",
            "frontend/visual-encyclopedia/contracts/RECEIPT_CONTRACT.md",
        ],
        "Onboarding": [
            "frontend/visual-encyclopedia/contracts/ACCESSIBILITY_CONTRACT_INDEX.md",
            "frontend/visual-encyclopedia/contracts/PRIMARY_CTA_CONTRACT.md",
        ],
    }.get(destination, ["frontend/visual-encyclopedia/contracts/RECEIPT_CONTRACT.md"])


def combined_surface_payload(surface_id: str) -> dict[str, Any]:
    row = surface_record(surface_id)
    provenance = provenance_record(surface_id) or {}
    inventory = inventory_record(surface_id) or {}
    source_link = source_link_record(surface_id) or {}
    destination = str(row.get("destination", ""))
    canon_status = str(row.get("canon_status") or inventory.get("canon_status") or "")
    source_confidence = str(source_link.get("source_link_confidence") or provenance.get("source_origin") or row.get("source_origin") or "")
    planned_batch = row.get("planned_implementation_batch_id") or provenance.get("planned_implementation_batch_id")
    patch_batch = row.get("patch_target_batch_id") or provenance.get("patch_target_batch_id")
    source_candidates = source_candidates_for(surface_id)
    tokens = dedupe(token_candidates(surface_id) + destination_tokens(destination))
    contracts = dedupe(contract_candidates(surface_id) + destination_contracts(destination))
    bible = surface_bible_path(destination)
    source_relationship_value = provenance.get("source_relationship") or source_relationship(source_confidence, canon_status)
    proof_status = str(provenance.get("proof_status") or row.get("proof_status") or "no_proof_required")
    implementation_proof_status = str(
        provenance.get("implementation_proof_status")
        or row.get("implementation_proof_status")
        or "not_in_scope"
    )
    implementation = implementation_status(source_relationship_value, proof_binding_status(proof_status))
    return {
        "batch_id": BATCH_ID,
        "surface_id": surface_id,
        "surface_name": row.get("name"),
        "destination": destination,
        "primary_object": row.get("primary_object"),
        "maturity_tier": row.get("maturity_tier"),
        "surface_type": row.get("surface_type"),
        "recipe_path": row.get("recipe_file"),
        "surface_bible_path": bible,
        "universe_row": row,
        "provenance_row": provenance,
        "recipe_inventory_row": inventory,
        "source_link_row": source_link,
        "source_candidates": source_candidates,
        "planned_implementation_batch": planned_batch,
        "patch_target_batch": patch_batch,
        "source_relationship": source_relationship_value,
        "source_relationship_reason": provenance.get("source_relationship_reason")
        or source_relationship_reason(source_confidence, canon_status, str(planned_batch) if planned_batch else None),
        "source_origin": source_origin(source_confidence, canon_status),
        "implementation_status": implementation,
        "implementation_proof_status": implementation_proof_status,
        "proof_status": proof_status,
        "tokens": {
            "design_tokens": tokens,
            "surface_support_tokens": destination_tokens(destination),
        },
        "contracts": contracts,
        "state_scenario_requirements": {
            "visible_regions": inventory.get("visible_regions", []),
            "forbidden_patterns": inventory.get("forbidden_patterns", []),
            "state_machine_relationship": row.get("state_machine_relationship", []),
            "preview_matrix_relationship": row.get("preview_matrix_relationship", []),
            "state_coverage_status": row.get("state_coverage_status"),
            "scenarios": scenario_requirements(surface_id),
        },
        "interaction_grammar_requirements": {
            "surface_family": row.get("surface_family"),
            "surface_kind": row.get("surface_type"),
            "supporting_objects": inventory.get("supporting_objects", []),
            "user_perception": inventory.get("final_intended_role"),
            "forbidden_patterns": inventory.get("forbidden_patterns", []),
        },
        "accessibility_adhd_requirements": {
            "accessibility_status": row.get("accessibility_status"),
            "adhd_status": row.get("adhd_status"),
            "dynamic_type": "required",
            "voiceover": "required",
            "reduce_motion": "required",
            "contrast": "required",
            "tap_targets": "44pt minimum",
        },
        "privacy_local_first_requirements": {
            "privacy_local_first_status": row.get("privacy_local_first_status"),
            "local_first": "required",
            "source_freshness_visible": True,
            "hosted_backend": "forbidden",
        },
        "proof_source_receipt_requirements": {
            "proof_source_receipt_status": row.get("proof_source_receipt_status"),
            "proof_status": proof_status,
            "implementation_proof_status": implementation_proof_status,
            "receipt_expected_for_code_changes": True,
        },
        "performance_preview_requirements": {
            "performance_budget_status": row.get("performance_budget_status"),
            "preview_matrix_relationship": row.get("preview_matrix_relationship", []),
            "preview_targets": source_link.get("preview_targets", []) if isinstance(source_link.get("preview_targets"), list) else [],
            "no_release_claims": True,
        },
        "forbidden_drift": {
            "forbidden_patterns": inventory.get("forbidden_patterns", []),
            "hard_red": [
                "Plan as a top-level destination",
                "chatbot UI",
                "generic dashboard",
                "card-stack fallback",
                "task-list clone",
                "release/device/accessibility proof claims",
            ],
        },
        "allowed_scope": {
            "source_targets": source_candidates,
            "docs": [
                str(ENCYCLOPEDIA_OS_DOC_PATH.relative_to(ROOT)),
                str(AUTHORITY_INDEX_PATH.relative_to(ROOT)),
                str(RECEIPT_SCHEMA_PATH.relative_to(ROOT)),
                str(PROOF_CONTRACT_SCHEMA_PATH.relative_to(ROOT)),
            ],
            "generated_artifacts": [
                str((PACKET_DIR / f"{surface_id}.md").relative_to(ROOT)),
                str((PACKET_DIR / f"{surface_id}.json").relative_to(ROOT)),
            ],
        },
        "forbidden_scope": {
            "native_swiftui_ui": "forbidden",
            "routing_changes": "forbidden",
            "persistence_changes": "forbidden",
            "ui_claims": "forbidden",
            "release_claims": "forbidden",
        },
        "required_validation": [
            "git diff --check",
            "python3 -m py_compile scripts/ambitions_frontend_authority_common.py scripts/ambitions-frontend-authority-packet.py scripts/ambitions-frontend-authority-preflight.py scripts/ambitions-frontend-implementation-prompt.py scripts/ambitions-frontend-source-bindings.py scripts/ambitions-frontend-drift-check.py scripts/ambitions-frontend-implementation-dashboard.py scripts/ambitions-frontend-next-surface-queue.py scripts/ambitions-frontend-receipt-check.py scripts/ambitions-frontend-proof-contract-check.py scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py",
            "python3 scripts/ambitions-frontend-authority-packet.py --tier P0",
            f"python3 scripts/ambitions-frontend-authority-preflight.py --surface {surface_id}",
            f"python3 scripts/ambitions-frontend-implementation-prompt.py --surface {surface_id} --batch {planned_batch or BATCH_ID}",
            "python3 scripts/ambitions-frontend-source-bindings.py",
            "python3 scripts/ambitions-frontend-drift-check.py",
            "python3 scripts/ambitions-frontend-implementation-dashboard.py",
            "python3 scripts/ambitions-frontend-next-surface-queue.py",
            "python3 scripts/ambitions-frontend-receipt-check.py",
            "python3 scripts/ambitions-frontend-proof-contract-check.py",
            "python3 scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py",
        ],
        "required_proof": [
            "generated authority packets",
            "generated implementation prompt",
            "preflight report",
            "source bindings report",
            "drift check report",
            "implementation dashboard",
            "next-surface queue",
            "final gate report",
            "validation command log",
        ],
        "known_gaps": dedupe(
            [
                *([row.get("gap_reason")] if row.get("gap_reason") else []),
                implementation_proof_status,
                *([f"proof status is {proof_status}"] if proof_status and proof_status != "proven" else []),
            ]
        ),
        "receipt_requirements": [
            "batch_id",
            "surface_ids",
            "recipe_ids",
            "source_files_changed",
            "generated_packet_paths",
            "tokens_used",
            "contracts_used",
            "scenario_proof",
            "interaction_proof",
            "accessibility_proof",
            "dynamic_type_proof",
            "reduce_motion_proof",
            "visual_proof",
            "preview_targets",
            "screenshots",
            "tests_run",
            "drift_check_result",
            "known_gaps",
            "implementation_status",
            "proof_status",
            "rollback_notes",
        ],
        "implementation_claim_boundary": "implementation proof not claimed",
        "recipe_id": row.get("recipe_inventory_id") or row.get("surface_universe_id"),
    }


def root_surface_ids() -> list[str]:
    return [
        "today_root_reality_meridian",
        "goals_root_constellation_atlas",
        "capture_root_atmosphere_composer",
        "time_root_lifeshape_field",
        "you_root_user_system_profile",
    ]


def surface_counts_by(field: str) -> dict[str, int]:
    counts = Counter()
    for row in universe_rows():
        value = row.get(field)
        if isinstance(value, str) and value:
            counts[value] += 1
    return dict(sorted(counts.items()))
