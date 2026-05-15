#!/usr/bin/env python3
from __future__ import annotations

import argparse
from collections import Counter
from pathlib import Path
import json
from typing import Any

from ambitions_frontend_authority_common import (
    BATCH_ID,
    PACKET_DIR,
    ROOT,
    combined_surface_payload,
    dedupe,
    load_json,
    surface_record,
    write_json,
    write_text,
)


def render_packet_md(packet: dict[str, Any]) -> str:
    def bullets(items: list[Any]) -> str:
        if not items:
            return "- None"
        return "\n".join(f"- {item}" for item in items)

    def section(title: str, value: Any) -> str:
        if isinstance(value, dict):
            lines = [f"## {title}"]
            for key, item in value.items():
                if isinstance(item, list):
                    lines.append(f"- {key}:")
                    lines.extend(f"  - {entry}" for entry in item) if item else lines.append("  - None")
                else:
                    lines.append(f"- {key}: {item}")
            return "\n".join(lines)
        if isinstance(value, list):
            return f"## {title}\n{bullets(value)}"
        return f"## {title}\n{value}"

    parts = [
        f"# Frontend Authority Packet: {packet['surface_name']}",
        "",
        f"Batch: `{BATCH_ID}`",
        f"Surface ID: `{packet['surface_id']}`",
        f"Destination: `{packet['destination']}`",
        f"Primary object: `{packet['primary_object']}`",
        f"Maturity tier: `{packet['maturity_tier']}`",
        f"Recipe path: `{packet['recipe_path']}`",
        f"Surface bible: `{packet['surface_bible_path']}`" if packet.get("surface_bible_path") else "Surface bible: `not available`",
        f"Source relationship: `{packet['source_relationship']}`",
        f"Implementation status: `{packet['implementation_status']}`",
        f"Proof status: `{packet['proof_status']}`",
        "",
        "## Source Candidates",
        bullets(packet.get("source_candidates", [])),
        "",
        "## Tokens",
        bullets(packet.get("tokens", {}).get("design_tokens", [])),
        "",
        "## Contracts",
        bullets(packet.get("contracts", [])),
        "",
        section("State and Scenario Requirements", packet.get("state_scenario_requirements", {})),
        "",
        section("Interaction Grammar Requirements", packet.get("interaction_grammar_requirements", {})),
        "",
        section("Accessibility and ADHD Requirements", packet.get("accessibility_adhd_requirements", {})),
        "",
        section("Privacy and Local-First Requirements", packet.get("privacy_local_first_requirements", {})),
        "",
        section("Proof, Source, and Receipt Requirements", packet.get("proof_source_receipt_requirements", {})),
        "",
        section("Performance and Preview Requirements", packet.get("performance_preview_requirements", {})),
        "",
        section("Forbidden Drift", packet.get("forbidden_drift", {})),
        "",
        section("Allowed Scope", packet.get("allowed_scope", {})),
        "",
        section("Forbidden Scope", packet.get("forbidden_scope", {})),
        "",
        "## Required Validation",
        bullets(packet.get("required_validation", [])),
        "",
        "## Required Proof",
        bullets(packet.get("required_proof", [])),
        "",
        "## Known Gaps",
        bullets(packet.get("known_gaps", [])),
        "",
        "## Receipt Requirements",
        bullets(packet.get("receipt_requirements", [])),
    ]
    return "\n".join(parts).rstrip() + "\n"


def packet_sort_key(surface_id: str) -> tuple[Any, ...]:
    row = surface_record(surface_id)
    return (
        {"P0": 0, "P1": 1, "P2": 2, "candidate": 3}.get(str(row.get("maturity_tier")), 9),
        str(row.get("destination", "")),
        str(row.get("name", "")),
    )


def build_index(packets: list[dict[str, Any]]) -> dict[str, Any]:
    destination_counts = Counter(packet["destination"] for packet in packets)
    tier_counts = Counter(packet["maturity_tier"] for packet in packets)
    relationship_counts = Counter(packet["source_relationship"] for packet in packets)
    return {
        "batch_id": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "surface_count": len(packets),
        "destination_counts": dict(sorted(destination_counts.items())),
        "tier_counts": dict(sorted(tier_counts.items())),
        "source_relationship_counts": dict(sorted(relationship_counts.items())),
        "packets": [
            {
                "surface_id": packet["surface_id"],
                "surface_name": packet["surface_name"],
                "destination": packet["destination"],
                "maturity_tier": packet["maturity_tier"],
                "source_relationship": packet["source_relationship"],
                "packet_md": str((PACKET_DIR / f"{packet['surface_id']}.md").relative_to(ROOT)),
                "packet_json": str((PACKET_DIR / f"{packet['surface_id']}.json").relative_to(ROOT)),
            }
            for packet in packets
        ],
    }


def render_index_md(index: dict[str, Any]) -> str:
    lines = [
        "# Frontend Authority Packet Index",
        "",
        f"Batch: `{index['batch_id']}`",
        f"Surface count: `{index['surface_count']}`",
        "",
        "## Counts",
        f"- Destinations: {index['destination_counts']}",
        f"- Tiers: {index['tier_counts']}",
        f"- Source relationships: {index['source_relationship_counts']}",
        "",
        "## Packets",
    ]
    for packet in index["packets"]:
        lines.append(
            f"- `{packet['surface_id']}` - {packet['surface_name']} - {packet['destination']} - {packet['maturity_tier']} - {packet['source_relationship']}"
        )
        lines.append(f"  - md: `{packet['packet_md']}`")
        lines.append(f"  - json: `{packet['packet_json']}`")
    return "\n".join(lines).rstrip() + "\n"


def generate_packet(surface_id: str) -> dict[str, Any]:
    packet = combined_surface_payload(surface_id)
    md_path, json_path = (
        PACKET_DIR / f"{surface_id}.md",
        PACKET_DIR / f"{surface_id}.json",
    )
    write_json(json_path, packet)
    write_text(md_path, render_packet_md(packet))
    return packet


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate frontend authority packets.")
    parser.add_argument("--surface")
    parser.add_argument("--format", choices=("md", "json"), default="md")
    parser.add_argument("--tier", choices=("P0", "P1", "P2", "candidate"))
    parser.add_argument("--all", action="store_true")
    args = parser.parse_args()

    universe = load_json(Path(ROOT) / "frontend" / "visual-encyclopedia" / "MATURE_APP_SURFACE_UNIVERSE.yaml")
    surface_ids = [row["surface_universe_id"] for row in universe.get("surfaces", [])]
    if args.all:
        selected = surface_ids
    elif args.tier:
        selected = [row_id for row_id in surface_ids if surface_record(row_id).get("maturity_tier") == args.tier]
    elif args.surface:
        selected = [args.surface]
    else:
        raise SystemExit("one of --surface, --tier, or --all is required")

    selected = sorted(selected, key=packet_sort_key)
    packets = [generate_packet(surface_id) for surface_id in selected]
    index = build_index([combined_surface_payload(surface_id) for surface_id in surface_ids])
    write_json(PACKET_DIR / "index.json", index)
    write_text(PACKET_DIR / "index.md", render_index_md(index))
    if args.surface and args.format == "json":
        print(json.dumps(packets[0], indent=2, ensure_ascii=False, sort_keys=True))
    else:
        print(f"generated {len(packets)} packet(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
