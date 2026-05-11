#!/usr/bin/env python3
"""Reject generic Source Atlas titles when canonical queue titles are available."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
QUEUE = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
BLUEPRINT = ROOT / "docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json"

GENERIC = {
    "source 1",
    "source 2",
    "doc",
    "document",
    "reference",
    "untitled",
    "generic source",
    "placeholder source",
    "sa item",
    "source tbd",
}


def load_batches(path: Path) -> list[dict]:
    data = json.loads(path.read_text())
    if isinstance(data, dict) and isinstance(data.get("batches"), list):
        return data["batches"]
    if isinstance(data, list):
        return data
    raise ValueError(f"{path} does not contain a batch list")


def is_source_atlas(record: dict) -> bool:
    batch_id = str(record.get("id", ""))
    train = str(record.get("train", ""))
    owner = str(record.get("owner_scope", ""))
    return batch_id.startswith("SA") or train == "SA" or "Source Atlas" in owner


def is_generic_title(batch_id: str, title: str) -> bool:
    normalized = re.sub(r"\s+", " ", title.strip().lower())
    if normalized in GENERIC:
        return True
    if re.fullmatch(r"sa\d+[a-z]?", title.strip(), flags=re.IGNORECASE):
        return True
    return False


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--queue", default=str(QUEUE))
    parser.add_argument("--blueprint", default=str(BLUEPRINT))
    args = parser.parse_args()

    errors: list[str] = []
    checked = 0
    for path in [Path(args.queue), Path(args.blueprint)]:
        if not path.exists():
            if args.strict:
                errors.append(f"missing file: {path}")
            continue
        for record in load_batches(path):
            if not is_source_atlas(record):
                continue
            checked += 1
            batch_id = str(record.get("id", ""))
            title = str(record.get("title", ""))
            if is_generic_title(batch_id, title):
                errors.append(f"{path}: {batch_id} has generic title {title!r}")

    print("# Source Atlas Title Check")
    print(f"source_atlas_records_checked: {checked}")
    if errors:
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1
    print("GREEN: no generic Source Atlas titles found where canonical queue titles exist")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
