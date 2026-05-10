#!/usr/bin/env python3
"""Check Ambitions Source Atlas queue titles against the SA train manifest.

Read-only. Exits non-zero in --strict mode when generic SA11-SA32 labels remain
in machine-readable or Markdown queue references.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

EXPECTED_SA_TITLES = {
    "SA07": "Claim State Machine",
    "SA08": "Requirement Graph Implementation",
    "SA09": "Proof Map Implementation",
    "SA10": "Freshness And Risk Model Implementation",
    "SA10A": "Capability Graph / Level Ladder Implementation",
    "SA10B": "Goal Projection Engine Contract",
    "SA10C": "Projection Fixtures And No-Sprawl Validation",
    "SA11": "Source Atlas Store",
    "SA12": "Source Atlas Query Engine",
    "SA13": "Source Needed Mode",
    "SA14": "Local Impact Matcher",
    "SA15": "Offline Fallback Runtime",
    "SA16": "Source Container Model",
    "SA17": "URL Source Importer",
    "SA18": "Plain Text Importer",
    "SA19": "PDF Import Boundary",
    "SA20": "PDFKit Text Extraction",
    "SA21": "Vision OCR Fallback",
    "SA22": "Image / Screenshot Importer",
    "SA23": "Document Type Classifier",
    "SA24": "Claim Candidate Extractor",
    "SA25": "Source Review Sheet / Claim Review Drawer",
    "SA26": "User Mini-Pack Builder",
    "SA27": "Pack Factory Lite",
    "SA28": "Pack Diff / Changed Claim Tooling",
    "SA29": "Hash / Signature / Revocation Tooling",
    "SA30": "Freshness Broker Manifest Contract",
    "SA31": "Official Source Adapter Contracts",
    "SA32": "Source Atlas UI Primitives / QA / Handoff",
}

CHECKED_JSON_FILES = [
    "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json",
    "docs/codex/AMB_REMAINING_BATCH_REFERENCE.json",
]

CHECKED_MARKDOWN_FILES = [
    "docs/codex/AMB_REMAINING_BATCH_REFERENCE.md",
]


def read_text(path: str) -> str:
    file_path = ROOT / path
    if not file_path.exists():
        return ""
    return file_path.read_text(encoding="utf-8", errors="replace")


def load_json(path: str) -> dict[str, Any]:
    text = read_text(path)
    if not text:
        return {}
    try:
        return json.loads(text)
    except json.JSONDecodeError as exc:
        return {"__json_error__": str(exc)}


def json_title_defects(path: str) -> list[str]:
    data = load_json(path)
    if data.get("__json_error__"):
        return [f"{path}: invalid JSON: {data['__json_error__']}"]
    defects: list[str] = []
    for batch in data.get("batches", []):
        batch_id = str(batch.get("id", ""))
        title = str(batch.get("title", ""))
        expected = EXPECTED_SA_TITLES.get(batch_id)
        if not expected:
            continue
        if title == batch_id:
            defects.append(f"{path}: {batch_id} uses generic title '{title}', expected '{expected}'")
        elif title and title != expected:
            defects.append(f"{path}: {batch_id} title mismatch '{title}', expected '{expected}'")
    return defects


def markdown_title_defects(path: str) -> list[str]:
    text = read_text(path)
    if not text:
        return [f"{path}: missing"]
    defects: list[str] = []
    for batch_id, expected in EXPECTED_SA_TITLES.items():
        generic_row = re.compile(rf"\|\s*{re.escape(batch_id)}\s*\|\s*{re.escape(batch_id)}\s*\|")
        if generic_row.search(text):
            defects.append(f"{path}: {batch_id} Markdown row uses generic title, expected '{expected}'")
    return defects


def main() -> int:
    parser = argparse.ArgumentParser(description="Check Source Atlas queue titles")
    parser.add_argument("--strict", action="store_true", help="Exit 1 when defects are found")
    parser.add_argument("--json", action="store_true", help="Emit JSON output")
    args = parser.parse_args()

    defects: list[str] = []
    for path in CHECKED_JSON_FILES:
        defects.extend(json_title_defects(path))
    for path in CHECKED_MARKDOWN_FILES:
        defects.extend(markdown_title_defects(path))

    status = "RED" if defects else "GREEN"
    payload = {
        "status": status,
        "checked_json_files": CHECKED_JSON_FILES,
        "checked_markdown_files": CHECKED_MARKDOWN_FILES,
        "defects": defects,
        "expected_titles": EXPECTED_SA_TITLES,
    }

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(f"STATUS: {status}")
        print("Defects:")
        for defect in defects or ["none"]:
            print(f"- {defect}")

    return 1 if args.strict and defects else 0


if __name__ == "__main__":
    raise SystemExit(main())
