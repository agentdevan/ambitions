#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter
from pathlib import Path
from typing import Any

from ambitions_frontend_authority_common import (
    BATCH_ID,
    REPORT_DIR,
    combined_surface_payload,
    universe_rows,
    write_json,
    write_text,
)


def score_surface(payload: dict[str, Any]) -> tuple[int, int, int, int, int]:
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
    child_count = len(payload.get("universe_row", {}).get("child_surfaces", []))
    shell_bonus = 0 if payload.get("destination") in {"Today", "Goals", "Capture", "Time", "You"} else 10
    return (tier_weight + relationship_weight + proof_weight + shell_bonus - child_count, tier_weight, relationship_weight, proof_weight, -child_count)


def build_report() -> dict[str, Any]:
    surfaces = [combined_surface_payload(row["surface_universe_id"]) for row in universe_rows()]
    ranked = sorted(
        (
            {
                "surface_id": item["surface_id"],
                "surface_name": item["surface_name"],
                "destination": item["destination"],
                "maturity_tier": item["maturity_tier"],
                "source_relationship": item["source_relationship"],
                "proof_status": item["proof_status"],
                "child_surfaces": item.get("universe_row", {}).get("child_surfaces", []),
                "score": score_surface(item)[0],
                "why": item.get("source_relationship_reason"),
            }
            for item in surfaces
        ),
        key=lambda item: (item["score"], item["destination"], item["surface_name"]),
    )
    return {
        "batch_id": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "status": "green",
        "surface_count": len(ranked),
        "ranked_surfaces": ranked,
        "top_20": ranked[:20],
    }


def render_md(report: dict[str, Any]) -> str:
    lines = [
        "# Frontend Next Surface Queue",
        "",
        f"Batch: `{report['batch_id']}`",
        f"Surface count: `{report['surface_count']}`",
        "",
        "## Top 20",
    ]
    for item in report["top_20"]:
        lines.append(
            f"- `{item['surface_id']}` - {item['surface_name']} - {item['destination']} - {item['maturity_tier']} - {item['source_relationship']} - score `{item['score']}`"
        )
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    report = build_report()
    write_json(REPORT_DIR / "frontend-next-surface-queue.json", report)
    write_text(REPORT_DIR / "frontend-next-surface-queue.md", render_md(report))
    print("GREEN")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
