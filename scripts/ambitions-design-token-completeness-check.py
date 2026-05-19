#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter, defaultdict

from visual_final_form_common import (
    FINAL_BATCH_ID,
    REPORT_DIR,
    TRACE_ROOT,
    load_token_files,
    token_entry,
    token_payload_status,
    write_json,
    write_json_like_yaml,
)


REPORT_JSON = REPORT_DIR / "design-token-completeness.json"
DOC_PATH = TRACE_ROOT / "DESIGN_TOKEN_COMPLETENESS_MATRIX.yaml"


def main() -> int:
    entries: list[dict[str, object]] = []
    category_counts: Counter[str] = Counter()
    status_counts: Counter[str] = Counter()
    debt_tokens = []
    missing_tokens = []

    for item in load_token_files():
        entry = token_entry(item)
        category_counts[str(entry["category"])] += 1
        field_names = [
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
        missing_fields = [
            field
            for field in field_names
            if entry[field] in ("", None, "not_found") or entry[field] == []
        ]
        token_status = "complete"
        if missing_fields:
            token_status = "debt"
            debt_tokens.append({"token_name": entry["token_name"], "missing_fields": missing_fields})
        if token_payload_status(item) == "source_only":
            token_status = "debt"
        status_counts[token_status] += 1
        entries.append(
            {
                **entry,
                "status": token_status,
                "missing_fields": missing_fields,
            }
        )

    overall_status = "green" if not debt_tokens and status_counts["complete"] == len(entries) else "yellow"
    if not entries:
        missing_tokens.append("no token entries loaded")
        overall_status = "red"

    payload = {
        "batch": FINAL_BATCH_ID,
        "generated_from_batch": FINAL_BATCH_ID,
        "token_count": len(entries),
        "category_counts": dict(category_counts),
        "status_counts": dict(status_counts),
        "debt_tokens": debt_tokens,
        "missing_tokens": missing_tokens,
        "status": overall_status,
        "architecture_notes": [
            "Surface, material, typography, spacing, and geometry are expressed through the existing foundation/component/theme seams rather than a second token root.",
            "Motion, haptics, accessibility, proof, source freshness, closure, and recovery remain explicit control-plane meanings in the current token buckets.",
            "Start Here, Reality Meridian, Quiet Glass, and Graphite Recess are represented as named Ambitions concepts, not generic theme knobs.",
        ],
        "tokens": entries,
    }
    write_json(REPORT_JSON, payload)
    write_json_like_yaml(DOC_PATH, payload)
    print("PASS" if overall_status != "red" else "FAIL")
    return 0 if overall_status != "red" else 1


if __name__ == "__main__":
    raise SystemExit(main())
