#!/usr/bin/env python3
from __future__ import annotations

from typing import Any

from ambitions_frontend_authority_common import (
    BATCH_ID,
    REPORT_DIR,
    combined_surface_payload,
    universe_rows,
    write_json,
    write_text,
)
from ambitions_signature_visual_instruments import enrich_packet_with_instrument


ROOT_INSTRUMENT_SURFACE_IDS = {
    "today_root_reality_meridian",
    "goals_root_constellation_atlas",
    "capture_root_atmosphere_composer",
    "time_root_lifeshape_field",
    "you_root_user_system_profile",
}

SHARED_PRIMITIVE_UNLOCKERS = {
    "global_app_shell",
    "destination_dock",
    "quietglass_wrapper",
    "graphiterecess_base",
    "luminoustrace_divider",
    "trust_seam",
    "source_chip",
    "proof_chip",
    "receipt_chip",
}


def score_surface(payload: dict[str, Any]) -> tuple[int, int, int, int, int, int]:
    tier_weight = {"P0": 0, "P1": 100, "P2": 200, "candidate": 300}.get(str(payload.get("maturity_tier")), 400)
    relationship_weight = {
        "implemented_source_present": 0,
        "source_approximation_present": 20,
        "planned_source_target": 60,
        "canon_only_pending_lock": 90,
        "source_unknown_needs_trace": 120,
    }.get(str(payload.get("source_relationship")), 120)
    proof_weight = {
        "no_proof_required": 0,
        "not_in_scope": 0,
        "partial": 25,
        "required_missing": 50,
        "proven": 0,
    }.get(str(payload.get("proof_status")), 30)
    surface_id = str(payload.get("surface_id"))
    instrument = payload.get("signature_visual_instrument") if isinstance(payload.get("signature_visual_instrument"), dict) else {}
    instrument_id = instrument.get("signature_instrument_id")
    shared_primitives = instrument.get("shared_instrument_primitives", []) or []
    instrument_weight = -45 if surface_id in ROOT_INSTRUMENT_SURFACE_IDS else (-24 if instrument_id else 0)
    primitive_weight = -30 if surface_id in SHARED_PRIMITIVE_UNLOCKERS else (-8 if shared_primitives else 0)
    child_count = len(payload.get("universe_row", {}).get("child_surfaces", []))
    shell_bonus = 0 if payload.get("destination") in {"Today", "Goals", "Capture", "Time", "You"} else 10
    score = tier_weight + relationship_weight + proof_weight + shell_bonus + instrument_weight + primitive_weight - child_count
    return (score, tier_weight, relationship_weight, proof_weight, instrument_weight, -child_count)


def build_report() -> dict[str, Any]:
    surfaces = [enrich_packet_with_instrument(combined_surface_payload(row["surface_universe_id"])) for row in universe_rows()]
    seen: set[str] = set()
    ranked_items: list[dict[str, Any]] = []
    for item in surfaces:
        surface_id = str(item["surface_id"])
        if surface_id in seen:
            continue
        seen.add(surface_id)
        instrument = item.get("signature_visual_instrument", {}) if isinstance(item.get("signature_visual_instrument"), dict) else {}
        ranked_items.append(
            {
                "surface_id": surface_id,
                "surface_name": item["surface_name"],
                "destination": item["destination"],
                "maturity_tier": item["maturity_tier"],
                "source_relationship": item["source_relationship"],
                "proof_status": item["proof_status"],
                "signature_instrument_id": instrument.get("signature_instrument_id"),
                "shared_instrument_primitives": instrument.get("shared_instrument_primitives", []),
                "instrument_implementation_status": instrument.get("instrument_implementation_status"),
                "child_surfaces": item.get("universe_row", {}).get("child_surfaces", []),
                "score": score_surface(item)[0],
                "why": item.get("source_relationship_reason"),
            }
        )
    ranked = sorted(ranked_items, key=lambda item: (item["score"], item["destination"], item["surface_name"]))
    duplicate_count = len(ranked_items) - len({item["surface_id"] for item in ranked_items})
    return {
        "batch_id": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "status": "green" if duplicate_count == 0 else "red",
        "surface_count": len(ranked),
        "duplicate_surface_id_count": duplicate_count,
        "ranked_surfaces": ranked,
        "top_20": ranked[:20],
        "top_instrument_implementations": [item for item in ranked if item.get("signature_instrument_id")][:20],
        "shared_primitive_unlockers": [item for item in ranked if item.get("shared_instrument_primitives")][:20],
    }


def render_md(report: dict[str, Any]) -> str:
    lines = [
        "# Frontend Next Surface Queue",
        "",
        f"Batch: `{report['batch_id']}`",
        f"Status: `{report['status']}`",
        f"Surface count: `{report['surface_count']}`",
        f"Duplicate surface IDs: `{report['duplicate_surface_id_count']}`",
        "",
        "## Top Instrument Implementations",
    ]
    for item in report["top_instrument_implementations"][:10]:
        lines.append(
            f"- `{item['surface_id']}` - {item['surface_name']} - instrument `{item.get('signature_instrument_id')}` - score `{item['score']}`"
        )
    lines.extend(["", "## Top 20"])
    for item in report["top_20"]:
        lines.append(
            f"- `{item['surface_id']}` - {item['surface_name']} - {item['destination']} - {item['maturity_tier']} - {item['source_relationship']} - instrument `{item.get('signature_instrument_id') or 'shared_or_none'}` - score `{item['score']}`"
        )
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    report = build_report()
    write_json(REPORT_DIR / "frontend-next-surface-queue.json", report)
    write_text(REPORT_DIR / "frontend-next-surface-queue.md", render_md(report))
    print(report["status"].upper())
    return 0 if report["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
