#!/usr/bin/env python3
"""Show post-PK batch bundles for faster sequential execution."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
QUEUE = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"

BUNDLES = [
    ("pk-tail", ["PK34", "PK35", "PK36", "PK37", "PK38", "PK39", "PK40", "PK41"]),
    ("source-atlas-core", ["SA07", "SA08", "SA09", "SA10", "SA10A", "SA10B", "SA10C"]),
    ("source-atlas-runtime", ["SA11", "SA12", "SA13", "SA14", "SA15", "SA16"]),
    ("source-atlas-importers", ["SA17", "SA18", "SA19", "SA20", "SA21", "SA22", "SA23", "SA24"]),
    ("source-atlas-review-pack", ["SA25", "SA26", "SA27", "SA28", "SA29", "SA30", "SA31", "SA32"]),
    ("ldi-tail", ["LDI17", "LDI18", "LDI19", "LDI20", "LDI21", "LDI22"]),
    ("aos-tail", ["AOS24", "AOS25", "AOS26", "AOS27", "AOS28", "AOS29", "AOS30"]),
    ("fcp-closeout", ["FCP27", "FCP28", "FCP29", "FCP30"]),
    ("pfc-closeout", ["PFC31", "PFC32", "PFC33", "PFC34", "PFC35", "PFC36", "PFC37", "PFC38", "PFC39", "PFC40"]),
    ("repo-hygiene", ["RHC01", "RHC02", "RHC03", "RHC04", "RHC05", "RHC06"]),
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="List post-PK batch bundles.")
    parser.add_argument("--bundle", help="Bundle name")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--next", action="store_true", help="Show bundle containing executable_now")
    return parser.parse_args()


def load_queue() -> dict[str, dict[str, Any]]:
    data = json.loads(QUEUE.read_text(encoding="utf-8"))
    return {entry.get("id", ""): entry for entry in data.get("batches", [])}


def bundle_rows(queue: dict[str, dict[str, Any]], name: str, ids: list[str]) -> list[dict[str, str]]:
    rows = []
    for batch_id in ids:
        entry = queue.get(batch_id, {})
        rows.append({
            "id": batch_id,
            "title": entry.get("title", "missing from queue"),
            "classification": entry.get("classification", "missing"),
        })
    return rows


def executable_now(queue: dict[str, dict[str, Any]]) -> str:
    matches = [batch_id for batch_id, entry in queue.items() if entry.get("classification") == "executable_now"]
    return matches[0] if len(matches) == 1 else ""


def main() -> int:
    args = parse_args()
    queue = load_queue()
    selected = BUNDLES
    if args.next:
        current = executable_now(queue)
        selected = [(name, ids) for name, ids in BUNDLES if current in ids]
    elif args.bundle:
        selected = [(name, ids) for name, ids in BUNDLES if name == args.bundle]
        if not selected:
            raise SystemExit(f"ERROR: unknown bundle {args.bundle}")

    result = [{"bundle": name, "batches": bundle_rows(queue, name, ids)} for name, ids in selected]
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        for bundle in result:
            print(f"## {bundle['bundle']}")
            for row in bundle["batches"]:
                print(f"- {row['id']} | {row['classification']} | {row['title']}")
            print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
