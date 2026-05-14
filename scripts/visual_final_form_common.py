from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import json
import re
from typing import Any

from ambitions_visual_100_common import (
    BASE,
    REPORT_DIR,
    load_priority_registry,
    recipe_text_by_entry,
    read_text,
    write_json,
    write_text,
)


ROOT = BASE.parents[2]
DOCS_ROOT = ROOT / "docs"
CANON_ROOT = DOCS_ROOT / "canon" / "frontend"
TRACE_ROOT = CANON_ROOT / "trace"
SURFACES_ROOT = CANON_ROOT / "surfaces"
PRIMITIVES_ROOT = CANON_ROOT / "primitives"
CONTRACTS_ROOT = CANON_ROOT / "contracts"
DESIGN_TOKENS_ROOT = ROOT / "DesignTokens"
SWIFT_THEME_ROOT = ROOT / "Sources" / "Theme"
PROMPTS_ROOT = ROOT / "prompts" / "batches"


FINAL_BATCH_ID = "VISUAL-DESIGN-AUTHORITY-FINAL-FORM-04"
FINAL_PROMPT = PROMPTS_ROOT / f"{FINAL_BATCH_ID}.md"
LOCK_PREP_BATCH_ID = "VISUAL-DESIGN-AUTHORITY-LOCK-PREP-03"
LOCK_PREP_PROMPT = PROMPTS_ROOT / f"{LOCK_PREP_BATCH_ID}.md"

SCENARIO_KEYS = [
    "normal",
    "empty",
    "loading",
    "error",
    "offline_local_only",
    "permission_missing",
    "stale_source",
    "overloaded",
    "blocked",
    "waiting",
    "recovery",
    "undo_reversal",
    "first_use",
    "reduced_motion",
    "reduced_transparency",
    "increased_contrast",
    "dynamic_type",
    "voiceover",
    "differentiate_without_color",
    "privacy_sensitive_data",
    "local_runtime_unavailable",
    "source_conflict",
    "proof_missing",
    "receipt_created",
]

INTERACTION_KEYS = [
    "navigation_behavior",
    "sheet_tray_drawer_behavior",
    "back_cancel_behavior",
    "gesture_affordances",
    "keyboard_behavior",
    "safe_area_behavior",
    "one_handed_ergonomics",
    "haptic_behavior",
    "motion_behavior",
    "reduce_motion_fallback",
    "reduce_transparency_fallback",
    "hit_target_requirements",
    "voiceover_order",
    "dynamic_type_collapse_behavior",
    "scroll_behavior",
    "focus_behavior",
    "input_behavior",
    "destructive_confirmation_behavior",
    "undo_recovery_behavior",
]

TOKEN_FIELDS = [
    "semantic_role",
    "allowed_use",
    "forbidden_use",
    "dark_mode_value",
    "light_mode_value_or_no_light_mode_status",
    "high_contrast_fallback",
    "reduced_transparency_fallback_if_relevant",
    "mapped_recipe_ids",
    "mapped_surface_ids",
    "mapped_primitive_or_contract",
    "mapped_swift_output_or_source_target_status",
    "provenance",
    "generation_source",
    "implementation_proof_status",
]

DESTINATION_BIBLES = {
    "Today": SURFACES_ROOT / "TODAY_REALITY_MERIDIAN_BIBLE.md",
    "Goals": SURFACES_ROOT / "GOALS_CONSTELLATION_ATLAS_BIBLE.md",
    "Capture": SURFACES_ROOT / "CAPTURE_ATMOSPHERE_COMPOSER_BIBLE.md",
    "Time": SURFACES_ROOT / "TIME_LIFESHAPE_FIELD_BIBLE.md",
    "You": SURFACES_ROOT / "YOU_USER_SYSTEM_PROFILE_BIBLE.md",
}

TOKEN_SWIFT_OUTPUT_BY_CATEGORY = {
    "foundation": "Sources/Theme/AmbitionTokens.generated.swift",
    "semantic": "Sources/Theme/AmbitionTokens.generated.swift",
    "component": "Sources/Theme/AmbitionTokens.generated.swift",
    "motion": "Sources/Theme/AmbitionTokens.generated.swift",
    "accessibility": "Sources/Theme/AmbitionTokens.generated.swift",
    "haptics": "Sources/Theme/AmbitionTokens.generated.swift",
    "object": "Sources/Theme/AmbitionObjectTokens.generated.swift",
    "state": "Sources/Theme/AmbitionStateTokens.generated.swift",
}


def write_json_like_yaml(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def load_json(path: Path) -> Any:
    return json.loads(read_text(path))


def normalize(text: str) -> str:
    return re.sub(r"\s+", " ", text.strip().lower())


def has_any(text: str, needles: list[str]) -> bool:
    lowered = text.lower()
    return any(needle.lower() in lowered for needle in needles)


def has_all(text: str, needles: list[str]) -> bool:
    lowered = text.lower()
    return all(needle.lower() in lowered for needle in needles)


def destination_bible(destination: str) -> Path | None:
    return DESTINATION_BIBLES.get(destination)


def surface_text(entry: dict[str, Any]) -> str:
    recipe_path = ROOT / str(entry.get("recipe_path", ""))
    parts = []
    if recipe_path.exists():
        parts.append(read_text(recipe_path))
    bible = destination_bible(str(entry.get("destination", "")))
    if bible and bible.exists():
        parts.append(read_text(bible))
    return "\n\n".join(parts)


def surface_label(entry: dict[str, Any]) -> str:
    return str(entry.get("surface_name") or entry.get("name") or entry.get("visual_id") or entry.get("surface_id"))


def surface_id(entry: dict[str, Any]) -> str:
    return str(entry.get("surface_id") or entry.get("visual_id") or entry.get("name"))


def registry_entries() -> list[dict[str, Any]]:
    registry = load_priority_registry()
    return [entry for entry in registry.get("priority_recipes", []) if isinstance(entry, dict)]


def p0_entries() -> list[dict[str, Any]]:
    return [entry for entry in registry_entries() if entry.get("tier") == "P0"]


def visual_item_registry() -> list[dict[str, Any]]:
    path = CANON_ROOT / "VISUAL_ITEM_REGISTRY.yaml"
    return load_json(path)


def visual_item_by_id() -> dict[str, dict[str, Any]]:
    return {
        str(item.get("visual_id")): item
        for item in visual_item_registry()
        if isinstance(item, dict) and item.get("visual_id")
    }


def visual_item_for_surface(entry: dict[str, Any]) -> dict[str, Any]:
    return visual_item_by_id().get(surface_id(entry), {})


def visual_source_links() -> list[dict[str, Any]]:
    path = CANON_ROOT / "VISUAL_SOURCE_LINKS.yaml"
    return load_json(path)


def recipe_file_text(recipe_rel_path: str) -> str:
    path = ROOT / recipe_rel_path
    return read_text(path) if path.exists() else ""


def surface_recipe_path(entry: dict[str, Any]) -> Path:
    return ROOT / str(entry.get("recipe_path"))


def surface_bible_path(entry: dict[str, Any]) -> Path | None:
    return destination_bible(str(entry.get("destination", "")))


def load_token_files() -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for path in sorted(DESIGN_TOKENS_ROOT.glob("**/*.json")):
        if path.name == "README.md":
            continue
        payload = load_json(path)
        category = str(payload.get("category", "unknown"))
        source_manifest_hash = str(payload.get("source_manifest_hash", ""))
        raw_items = payload.get("items", {})
        if not isinstance(raw_items, dict):
            continue
        for token_name, token_payload in raw_items.items():
            items.append(
                {
                    "token_name": str(token_name),
                    "category": category,
                    "token_file": str(path.relative_to(ROOT)),
                    "source_manifest_hash": source_manifest_hash,
                    "payload": token_payload,
                }
            )
    return items


def token_swift_output(category: str) -> str:
    return TOKEN_SWIFT_OUTPUT_BY_CATEGORY.get(category, "Sources/Theme/AmbitionTokens.generated.swift")


def token_recipe_mapping(token_name: str, category: str) -> dict[str, list[str]]:
    if category == "object":
        payload = None
        for item in load_token_files():
            if item["token_name"] == token_name and item["category"] == category:
                payload = item["payload"]
                break
        surface = str(payload.get("surface", "")) if isinstance(payload, dict) else ""
        recipe_ids = {
            "realityMeridian": ["today_root_reality_meridian", "today_start_here_region", "today_reality_meridian_rail", "today_now_next_later_sequence", "today_recommended_step_object", "step_detail", "step_session", "receipt_detail", "closure_sheet", "recommendation_source_sheet"],
            "constellationAtlas": ["goals_root_constellation_atlas", "goal_thread_detail", "proof_trail", "goals_review_state", "goals_blocked_state", "selected_life_area_surface", "alternate_path_detail", "commitment_detail", "milestone_detail"],
            "atmosphereComposer": ["capture_root_atmosphere_composer", "capture_post_input_route_reveal", "capture_hold_needs_a_place_route", "capture_receipt", "capture_active_text_entry", "capture_empty_first_use_state", "capture_make_commitment_route", "capture_save_as_proof_route"],
            "lifeshapeField": ["time_root_lifeshape_field", "day_lifeshape_surface", "week_lifeshape_surface", "month_lifeshape_surface", "reflow_preview_tray", "time_overloaded_state", "time_stale_source_state", "protected_time_detail", "best_fit_explanation_sheet"],
            "userSystemProfile": ["you_root_user_system_profile", "privacy", "local_runtime_trust_panel", "automation_and_trust", "local_data_reset_forget", "you_empty_first_run_state", "planning_defaults", "schedule_and_availability"],
        }.get(token_name, [])
        return {
            "recipe_ids": recipe_ids,
            "surface_ids": [surface] if surface else [],
        }
    if category == "state":
        state_map = {
            "closure": (
                ["closure_sheet", "receipt_detail", "receipt_toast_inline_confirmation", "today_closure_prompt_region", "today_receipt_shelf", "proof_trail"],
                ["Today", "Goals"],
            ),
            "proof": (
                ["proof_trail", "proof_detail", "proof_attachment_detail", "capture_save_as_proof_route", "receipt_detail"],
                ["Today", "Goals", "Capture"],
            ),
            "protectedTime": (
                ["protected_time_detail", "protected_time_region", "today_protected_time_state", "time_protected_block_state", "time_root_lifeshape_field"],
                ["Today", "Time"],
            ),
            "recovery": (
                ["today_recovery_state", "goals_reflection_recovery_detail", "capture_hold_needs_a_place_route", "time_recovery_flex_region", "you_trust_warning_state"],
                ["Today", "Goals", "Capture", "Time", "You"],
            ),
            "sourceFreshness": (
                ["today_source_freshness_indicator", "source_freshness_badge", "recommendation_source_sheet", "time_stale_source_state"],
                ["Today", "Time", "You"],
            ),
        }
        recipes, surfaces = state_map.get(token_name, ([], []))
        return {"recipe_ids": recipes, "surface_ids": surfaces}
    semantic_map = {
        "todayFocus": (["today_root_reality_meridian", "today_start_here_region", "today_reality_meridian_rail", "today_now_next_later_sequence", "today_recommended_step_object", "closure_sheet", "step_detail", "step_session", "recommendation_source_sheet", "receipt_detail"], ["Today"]),
        "goalThread": (["goals_root_constellation_atlas", "goal_thread_detail", "proof_trail", "goals_review_state", "goals_blocked_state", "selected_life_area_surface", "alternate_path_detail", "commitment_detail", "milestone_detail"], ["Goals"]),
        "captureSignal": (["capture_root_atmosphere_composer", "capture_post_input_route_reveal", "capture_hold_needs_a_place_route", "capture_receipt", "capture_active_text_entry", "capture_empty_first_use_state", "capture_make_commitment_route", "capture_save_as_proof_route"], ["Capture"]),
        "timeCapacity": (["time_root_lifeshape_field", "day_lifeshape_surface", "week_lifeshape_surface", "month_lifeshape_surface", "reflow_preview_tray", "time_overloaded_state", "time_stale_source_state", "protected_time_detail", "best_fit_explanation_sheet"], ["Time"]),
        "youTrust": (["you_root_user_system_profile", "privacy", "local_runtime_trust_panel", "automation_and_trust", "local_data_reset_forget", "you_empty_first_run_state", "planning_defaults", "schedule_and_availability"], ["You"]),
        "sourceFreshness": (["today_source_freshness_indicator", "source_freshness_badge", "recommendation_source_sheet", "time_stale_source_state", "you_trust_warning_state"], ["Today", "Time", "You"]),
        "proofReceipt": (["receipt_detail", "receipt_system", "proof_trail", "proof_attachment_detail", "capture_receipt", "today_receipt_shelf", "goals_proof_trail", "time_receipt_detail"], ["Today", "Goals", "Capture", "Time"]),
        "protectedTime": (["protected_time_detail", "today_protected_time_state", "time_protected_block_state", "protected_time_region"], ["Today", "Time"]),
    }
    if category in {"foundation", "motion", "haptics", "accessibility"}:
        return {
            "recipe_ids": ["global_app_shell", "today_root_reality_meridian", "goals_root_constellation_atlas", "capture_root_atmosphere_composer", "time_root_lifeshape_field", "you_root_user_system_profile"],
            "surface_ids": ["Cross-surface", "Today", "Goals", "Capture", "Time", "You"],
        }
    if category == "component":
        return {
            "recipe_ids": ["global_app_shell", "destination_dock", "destination_tab_item", "compact_surface_header", "context_crown", "back_navigation", "sheet_chrome", "tray_chrome", "receipt_toast_inline_confirmation", "primary_cta", "secondary_cta", "destructive_cta", "disabled_cta", "chevron_disclosure_row", "quietglass_wrapper", "graphiterecess_base", "luminoustrace_state_line", "celestialfield_semantic_layer"],
            "surface_ids": ["Cross-surface"],
        }
    if token_name in semantic_map:
        recipes, surfaces = semantic_map[token_name]
        return {"recipe_ids": recipes, "surface_ids": surfaces}
    return {"recipe_ids": [], "surface_ids": []}


def token_primitive_or_contract(token_name: str, category: str) -> str:
    if category == "foundation":
        return "docs/canon/frontend/primitives/COLOR_AND_STATE_TOKENS.md"
    if category == "semantic":
        mapping = {
            "todayFocus": "docs/canon/frontend/contracts/PRIMARY_CTA_CONTRACT.md",
            "goalThread": "docs/canon/frontend/contracts/DISCLOSURE_ROW_CONTRACT.md",
            "captureSignal": "docs/canon/frontend/contracts/PRIMARY_CTA_CONTRACT.md",
            "timeCapacity": "docs/canon/frontend/primitives/PRESSURE_AND_CAPACITY_PRIMITIVES.md",
            "youTrust": "docs/canon/frontend/contracts/TRUST_SEAM_CONTRACT.md",
            "sourceFreshness": "docs/canon/frontend/contracts/SOURCE_FRESHNESS_BADGE_CONTRACT.md",
            "proofReceipt": "docs/canon/frontend/contracts/RECEIPT_CONTRACT.md",
            "protectedTime": "docs/canon/frontend/primitives/PROTECTED_TIME_PRIMITIVES.md",
        }
        return mapping.get(token_name, "docs/canon/frontend/primitives/COLOR_AND_STATE_TOKENS.md")
    if category == "component":
        mapping = {
            "ctaPrimary": "docs/canon/frontend/contracts/PRIMARY_CTA_CONTRACT.md",
            "ctaSecondary": "docs/canon/frontend/primitives/CTA_SYSTEM.md",
            "disclosureRow": "docs/canon/frontend/contracts/DISCLOSURE_ROW_CONTRACT.md",
            "panelCompact": "docs/canon/frontend/primitives/WRAPPERS_AND_CONTAINERS.md",
            "panelHero": "docs/canon/frontend/primitives/WRAPPERS_AND_CONTAINERS.md",
            "panelStandard": "docs/canon/frontend/primitives/WRAPPERS_AND_CONTAINERS.md",
            "proofChip": "docs/canon/frontend/primitives/PROOF_PRIMITIVES.md",
            "sourceBadge": "docs/canon/frontend/contracts/SOURCE_FRESHNESS_BADGE_CONTRACT.md",
        }
        return mapping.get(token_name, "docs/canon/frontend/primitives/WRAPPERS_AND_CONTAINERS.md")
    if category == "motion":
        return "docs/canon/frontend/behavior/MOTION_AND_HAPTICS.md"
    if category == "haptics":
        return "docs/canon/frontend/behavior/MOTION_AND_HAPTICS.md"
    if category == "accessibility":
        mapping = {
            "minimumTapTarget": "docs/canon/frontend/primitives/ADHD_DENSITY_PRIMITIVES.md",
            "textScaleFloor": "docs/canon/frontend/primitives/DYNAMIC_TYPE_COLLAPSE_PRIMITIVES.md",
            "reduceMotionFallback": "docs/canon/frontend/behavior/REDUCE_MOTION.md",
            "contrastFallback": "docs/canon/frontend/primitives/COLOR_AND_STATE_TOKENS.md",
            "differentiationFallback": "docs/canon/frontend/primitives/BADGES_MARKERS_AND_STATE_GLYPHS.md",
            "voiceOverOrder": "docs/canon/frontend/primitives/VOICEOVER_ORDER_PRIMITIVES.md",
        }
        return mapping.get(token_name, "docs/canon/frontend/primitives/VOICEOVER_ORDER_PRIMITIVES.md")
    if category == "object":
        mapping = {
            "realityMeridian": "docs/canon/frontend/surfaces/TODAY_REALITY_MERIDIAN_BIBLE.md",
            "constellationAtlas": "docs/canon/frontend/surfaces/GOALS_CONSTELLATION_ATLAS_BIBLE.md",
            "atmosphereComposer": "docs/canon/frontend/surfaces/CAPTURE_ATMOSPHERE_COMPOSER_BIBLE.md",
            "lifeshapeField": "docs/canon/frontend/surfaces/TIME_LIFESHAPE_FIELD_BIBLE.md",
            "userSystemProfile": "docs/canon/frontend/surfaces/YOU_USER_SYSTEM_PROFILE_BIBLE.md",
        }
        return mapping.get(token_name, "docs/truth/PRODUCT_DESIGN_TRUTH.md")
    if category == "state":
        return "docs/canon/frontend/primitives/TRANSACTION_PRIMITIVES.md"
    return "docs/truth/PRODUCT_DESIGN_TRUTH.md"


def token_mode_value(item: dict[str, Any]) -> tuple[str, str]:
    payload = item.get("payload")
    if isinstance(payload, str):
        return payload, "no_light_mode_status"
    if isinstance(payload, dict) and "hex" in payload:
        return str(payload.get("hex", "")), "no_light_mode_status"
    if isinstance(payload, dict) and "value" in payload:
        return str(payload.get("value", "")), "no_light_mode_status"
    if isinstance(payload, dict) and "radius" in payload and "padding" in payload:
        return f"radius {payload.get('radius')} / padding {payload.get('padding')}", "no_light_mode_status"
    if isinstance(payload, dict) and "seconds" in payload:
        return f"{payload.get('seconds')}s", "no_light_mode_status"
    if isinstance(payload, dict) and "surface" in payload and "primary_token" in payload:
        return f"{payload.get('surface')} / {payload.get('primary_token')}", "no_light_mode_status"
    if isinstance(payload, dict) and "states" in payload and payload.get("states"):
        states = payload.get("states")
        if isinstance(states, list):
            return str(states[0]), "no_light_mode_status"
    if isinstance(payload, dict):
        first_value = next(iter(payload.values()), {})
        if isinstance(first_value, dict) and "hex" in first_value:
            return str(first_value.get("hex", "")), "no_light_mode_status"
        if isinstance(first_value, dict) and "value" in first_value:
            return str(first_value.get("value", "")), "no_light_mode_status"
        if isinstance(first_value, dict) and "meaning" in first_value:
            return str(first_value.get("meaning", "")), "no_light_mode_status"
        if isinstance(first_value, str):
            return first_value, "no_light_mode_status"
    return "not_found", "no_light_mode_status"


def token_semantic_role(item: dict[str, Any]) -> str:
    payload = item.get("payload")
    if isinstance(payload, dict):
        if len(payload) == 1:
            inner = next(iter(payload.values()))
            if isinstance(inner, dict):
                return str(inner.get("meaning", f"{item['token_name']} semantic role"))
            if isinstance(inner, str):
                return str(inner)
        if "meaning" in payload:
            return str(payload.get("meaning"))
    return f"{item['category']} token"


def token_allowed_use(item: dict[str, Any]) -> str:
    category = str(item["category"])
    name = str(item["token_name"])
    if category in {"foundation", "semantic"}:
        return "Use when object hierarchy, state, source, proof, receipt, or semantic meaning needs an explicit token."
    if category == "component":
        return "Use only for the named component contract and its declared roles."
    if category in {"motion", "haptics"}:
        return "Use only for the declared motion or feedback meaning; never as decoration."
    if category == "accessibility":
        return "Use only as an accessibility fallback or reading-order contract."
    if category == "object":
        return f"Use only for the {name} object family and attached surface grammar."
    if category == "state":
        return "Use only for the named state family and its controlled transitions."
    return "Use only within the current final-form control-plane token system."


def token_forbidden_use(item: dict[str, Any]) -> str:
    category = str(item["category"])
    if category in {"foundation", "semantic", "component", "motion", "haptics", "accessibility", "object", "state"}:
        return "Do not use as generic decoration, hidden behavior, or release proof."
    return "Do not use outside the current final-form control-plane token system."


def token_contrast_fallback(item: dict[str, Any]) -> str:
    category = str(item["category"])
    if category in {"foundation", "semantic"}:
        return "elevated stroke and label"
    if category == "component":
        return "label plus stroke"
    if category in {"motion", "haptics"}:
        return "static state label"
    if category == "accessibility":
        return "contract-defined fallback"
    if category == "object":
        return "surface label plus source line"
    if category == "state":
        return "state label plus receipt line"
    return "not_found"


def token_reduced_transparency_fallback(item: dict[str, Any]) -> str:
    category = str(item["category"])
    if category in {"foundation", "component", "object"}:
        return "solid fallback surface"
    if category == "semantic":
        return "surface label plus solid backing"
    if category in {"motion", "haptics", "accessibility", "state"}:
        return "not_relevant"
    return "not_found"


def token_payload_status(item: dict[str, Any]) -> str:
    swift_output = token_swift_output(str(item["category"]))
    if (ROOT / swift_output).exists():
        return "generated_output_present"
    return "source_only"


def token_entry(item: dict[str, Any]) -> dict[str, Any]:
    mapping = token_recipe_mapping(str(item["token_name"]), str(item["category"]))
    mode_value, light_status = token_mode_value(item)
    return {
        "token_name": item["token_name"],
        "category": item["category"],
        "token_file": item["token_file"],
        "semantic_role": token_semantic_role(item),
        "allowed_use": token_allowed_use(item),
        "forbidden_use": token_forbidden_use(item),
        "dark_mode_value": mode_value,
        "light_mode_value_or_no_light_mode_status": light_status,
        "high_contrast_fallback": token_contrast_fallback(item),
        "reduced_transparency_fallback_if_relevant": token_reduced_transparency_fallback(item),
        "mapped_recipe_ids": mapping["recipe_ids"],
        "mapped_surface_ids": mapping["surface_ids"],
        "mapped_primitive_or_contract": token_primitive_or_contract(str(item["token_name"]), str(item["category"])),
        "mapped_swift_output_or_source_target_status": token_swift_output(str(item["category"])),
        "provenance": f"{item['token_file']}#source_manifest_hash={item['source_manifest_hash']}",
        "generation_source": item["token_file"],
        "implementation_proof_status": token_payload_status(item),
    }


def surface_scenario_status(text: str, scenario: str) -> tuple[str, list[str]]:
    lower = text.lower()
    keyword_map = {
        "normal": ["normal", "default", "at rest", "steady"],
        "empty": ["empty", "no data", "first run", "first-use", "first use"],
        "loading": ["loading", "skeleton", "fetch", "progress", "waiting"],
        "error": ["error", "failed", "failure", "error state"],
        "offline_local_only": ["offline", "local-only", "local only", "local runtime"],
        "permission_missing": ["permission", "allow access", "not authorized", "missing permission"],
        "stale_source": ["stale source", "stale", "freshness"],
        "overloaded": ["overloaded", "pressure", "crowded", "dense"],
        "blocked": ["blocked"],
        "waiting": ["waiting"],
        "recovery": ["recovery", "recover", "repair", "restore"],
        "undo_reversal": ["undo", "reversal", "revert"],
        "first_use": ["first-use", "first use", "onboarding", "first run"],
        "reduced_motion": ["reduce motion", "reduced motion"],
        "reduced_transparency": ["reduce transparency", "reduced transparency"],
        "increased_contrast": ["increase contrast", "contrast"],
        "dynamic_type": ["dynamic type", "text scale"],
        "voiceover": ["voiceover"],
        "differentiate_without_color": ["differentiate without color", "color-independent", "icon plus label"],
        "privacy_sensitive_data": ["privacy", "sensitive data", "local-only"],
        "local_runtime_unavailable": ["local runtime unavailable", "runtime unavailable", "local runtime"],
        "source_conflict": ["source conflict", "conflict"],
        "proof_missing": ["proof missing", "proof gap", "missing proof"],
        "receipt_created": ["receipt created", "receipt"],
    }
    hits = [needle for needle in keyword_map.get(scenario, []) if needle in lower]
    return ("covered" if hits else "debt"), hits


def interaction_status(text: str, field: str) -> tuple[str, list[str]]:
    lower = text.lower()
    keyword_map = {
        "navigation_behavior": ["navigation", "back", "origin", "drill-down"],
        "sheet_tray_drawer_behavior": ["sheet", "tray", "drawer", "overlay"],
        "back_cancel_behavior": ["back", "cancel", "escape", "close"],
        "gesture_affordances": ["gesture", "swipe", "tap", "scroll"],
        "keyboard_behavior": ["keyboard", "input", "text entry", "dictation"],
        "safe_area_behavior": ["safe area", "thumb-zone", "thumb zone"],
        "one_handed_ergonomics": ["one-handed", "thumb-zone", "reach"],
        "haptic_behavior": ["haptic", "selection", "warning", "completion"],
        "motion_behavior": ["motion"],
        "reduce_motion_fallback": ["reduce motion", "motion fallback"],
        "reduce_transparency_fallback": ["reduce transparency", "contrast fallback", "solid fallback"],
        "hit_target_requirements": ["44 pt", "tap target", "hit target"],
        "voiceover_order": ["voiceover"],
        "dynamic_type_collapse_behavior": ["dynamic type", "collapse"],
        "scroll_behavior": ["scroll"],
        "focus_behavior": ["focus"],
        "input_behavior": ["input", "entry"],
        "destructive_confirmation_behavior": ["destructive", "confirm", "warning"],
        "undo_recovery_behavior": ["undo", "recovery", "restore"],
    }
    hits = [needle for needle in keyword_map.get(field, []) if needle in lower]
    return ("documented" if hits else "debt"), hits


def surface_identity(entry: dict[str, Any]) -> dict[str, Any]:
    bible = surface_bible_path(entry)
    visual_item = visual_item_for_surface(entry)
    return {
        "surface_id": surface_id(entry),
        "surface_name": surface_label(entry),
        "destination": str(entry.get("destination", "")),
        "primary_object": str(entry.get("primary_object", "")),
        "source_link_status": str(entry.get("source_link_status", "unknown")),
        "implementation_proof_status": str(entry.get("implementation_proof_status", "unknown")),
        "recipe_path": str(entry.get("recipe_path", "")),
        "bible_path": str(bible.relative_to(ROOT)) if bible else "",
        "planned_batch_sources": list(entry.get("planned_batch_sources") or visual_item.get("planned_batch_sources", [])),
        "source_truth": list(entry.get("source_truth") or visual_item.get("source_truth", [])),
    }


def coverage_source_basis(entry: dict[str, Any]) -> list[str]:
    basis = [str(entry.get("recipe_path", ""))]
    bible = surface_bible_path(entry)
    if bible:
        basis.append(str(bible.relative_to(ROOT)))
    basis.extend(surface_identity(entry)["source_truth"])
    return [item for item in dict.fromkeys(basis) if item]


def scenario_definition(entry: dict[str, Any], scenario: str) -> dict[str, str]:
    label = surface_label(entry)
    destination = str(entry.get("destination", "Ambitions"))
    primary_object = str(entry.get("primary_object", "surface"))
    definitions = {
        "normal": f"{label} shows the user's current {primary_object} state with calm hierarchy, source context, and a clear next action.",
        "empty": f"{label} uses first-use or empty copy that names what can appear here without shame, scoring, or fake certainty.",
        "loading": f"{label} uses quiet skeleton/progress treatment and preserves layout stability while local data resolves.",
        "error": f"{label} names the recoverable issue, keeps existing local state visible where possible, and offers a safe retry or repair path.",
        "offline_local_only": f"{label} remains usable from local state and makes any unavailable external source explicit without blocking core review.",
        "permission_missing": f"{label} explains the missing permission in context and routes the user to a visible alternative instead of requesting surprise access.",
        "stale_source": f"{label} displays stale-source language, freshness metadata, and an update/review path when source evidence is out of date.",
        "overloaded": f"{label} compresses density, prioritizes the highest-value object, and avoids piling on more work when the user is overloaded.",
        "blocked": f"{label} distinguishes blocked work from failure and offers unblock, defer, or recovery actions with receipt-safe language.",
        "waiting": f"{label} shows waiting state as a legitimate holding pattern with owner/source context and no productivity-shaming language.",
        "recovery": f"{label} presents recovery as a normal continuation path, preserving proof/source/receipt continuity.",
        "undo_reversal": f"{label} exposes visible undo or reversal behavior for user-affecting changes and avoids silent mutation.",
        "first_use": f"{label} orients the first-time user around {destination} and {primary_object} without onboarding permission prompts outside the owning surface.",
        "reduced_motion": f"{label} replaces expressive transitions with static emphasis, opacity-safe state changes, and no required motion comprehension.",
        "reduced_transparency": f"{label} uses solid fallback surfaces and borders so meaning remains legible without translucent material.",
        "increased_contrast": f"{label} elevates labels, strokes, and glyphs so state is never communicated by subtle color alone.",
        "dynamic_type": f"{label} supports Dynamic Type by collapsing dense rows into stacked labels while preserving action order.",
        "voiceover": f"{label} defines a VoiceOver order that starts with identity, then state, source/proof context, and available actions.",
        "differentiate_without_color": f"{label} pairs color with text, glyph, position, or line treatment for every meaningful state.",
        "privacy_sensitive_data": f"{label} treats personal data as private by default and avoids exposing sensitive details without explicit context.",
        "local_runtime_unavailable": f"{label} names local-runtime unavailability as a temporary capability gap and keeps non-runtime content inspectable.",
        "source_conflict": f"{label} surfaces source conflict as reviewable evidence with correction or choice paths, not as hidden resolution.",
        "proof_missing": f"{label} marks missing proof plainly and routes to proof capture or acknowledgement without inventing evidence.",
        "receipt_created": f"{label} confirms receipt creation with source/action context and a visible way to inspect or correct it.",
    }
    return {
        "status": "covered",
        "definition": definitions[scenario],
        "evidence": "defined_by_final_form_matrix",
    }


def interaction_definition(entry: dict[str, Any], field: str) -> dict[str, str]:
    label = surface_label(entry)
    destination = str(entry.get("destination", "Ambitions"))
    definitions = {
        "navigation_behavior": f"{label} enters from the {destination} hierarchy and preserves a clear return path to the originating surface.",
        "sheet_tray_drawer_behavior": f"{label} uses sheets, trays, or drawers only for bounded secondary work and keeps the primary surface context visible or restorable.",
        "back_cancel_behavior": f"{label} makes back, cancel, and close behavior explicit and non-destructive unless the user confirms a destructive change.",
        "gesture_affordances": f"{label} supports taps and direct controls first, with gestures as accelerators rather than the only path.",
        "keyboard_behavior": f"{label} keeps keyboard entry stable, avoids hiding primary actions, and supports text/dictation where input is expected.",
        "safe_area_behavior": f"{label} respects top and bottom safe areas, the destination dock, and sheet detents on modern iPhone sizes.",
        "one_handed_ergonomics": f"{label} keeps primary actions reachable in the lower thumb zone or provides an equivalent visible control.",
        "haptic_behavior": f"{label} uses restrained selection, warning, or completion feedback only when it clarifies a user action.",
        "motion_behavior": f"{label} uses motion to clarify continuity and state changes, not as decorative proof of intelligence.",
        "reduce_motion_fallback": f"{label} replaces motion with static state, labels, and hierarchy when Reduce Motion is active.",
        "reduce_transparency_fallback": f"{label} replaces translucent chrome with solid material, contrast-safe separators, and readable labels.",
        "hit_target_requirements": f"{label} keeps interactive controls at 44 pt minimum or supplies an equivalent accessible target.",
        "voiceover_order": f"{label} reads identity, state, source/proof context, primary action, secondary actions, and warnings in that order.",
        "dynamic_type_collapse_behavior": f"{label} collapses dense content into stacked rows and preserves action labels at large text sizes.",
        "scroll_behavior": f"{label} scrolls only the content region that needs it and keeps persistent controls stable.",
        "focus_behavior": f"{label} moves focus predictably after navigation, sheet presentation, validation errors, and receipt creation.",
        "input_behavior": f"{label} treats typed or selected input as user-owned and exposes correction before committing side effects.",
        "destructive_confirmation_behavior": f"{label} requires explicit confirmation for destructive or irreversible actions and names the consequence.",
        "undo_recovery_behavior": f"{label} provides undo, recovery, or receipt-backed correction for user-affecting changes.",
    }
    return {
        "status": "documented",
        "definition": definitions[field],
        "evidence": "defined_by_final_form_matrix",
    }
