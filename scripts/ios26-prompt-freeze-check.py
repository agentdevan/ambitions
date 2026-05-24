#!/usr/bin/env python3
"""Verify IOS26 frozen prompt hashes."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HASH_FILE = ROOT / "docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json"
PROMPT_DIR = ROOT / "prompts/batches"
REPORT = ROOT / "build/reports/ios26-planning/prompt-freeze-check.md"
BATCH_RE = re.compile(r"(IOS26-T\d{2}[A-Z]?-B\d{2})")


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def train_id_for(batch_id: str) -> str:
    match = re.match(r"IOS26-T(\d{2}[A-Z]?)-B\d{2}", batch_id)
    return f"TRAIN_{match.group(1)}" if match else "NON_MANIFEST_IOS26_PROMPT"


def current_entries() -> list[dict[str, str]]:
    generated_at = utc_now()
    entries: list[dict[str, str]] = []
    for path in sorted(PROMPT_DIR.glob("IOS26-*.md")):
        match = BATCH_RE.search(path.name)
        batch_id = match.group(1) if match else path.stem
        entries.append(
            {
                "batch_id": batch_id,
                "prompt_path": rel(path),
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                "train_id": train_id_for(batch_id),
                "generated_at": generated_at,
            }
        )
    return entries


def write_hashes() -> None:
    HASH_FILE.parent.mkdir(parents=True, exist_ok=True)
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    entries = current_entries()
    data = {
        "generated_at": utc_now(),
        "hash_algorithm": "sha256",
        "replan_escape_hatch": "IOS26_REPLAN_ALLOWED=1",
        "entries": entries,
    }
    HASH_FILE.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    REPORT.write_text(f"# IOS26 Prompt Freeze Check\n\nStatus: GREEN\nEntries: {len(entries)}\n", encoding="utf-8")


def load_hashes() -> dict[str, object]:
    return json.loads(HASH_FILE.read_text(encoding="utf-8"))


def check(batch: str | None = None, prompt: str | None = None) -> int:
    if not HASH_FILE.exists():
        print(f"RED: missing {rel(HASH_FILE)}")
        return 1
    data = load_hashes()
    entries: list[dict[str, str]] = data.get("entries", [])  # type: ignore[assignment]
    issues: list[str] = []
    selected = entries
    if batch:
        selected = [entry for entry in entries if entry.get("batch_id") == batch]
    if prompt:
        selected = [entry for entry in selected if entry.get("prompt_path") == prompt or str(ROOT / entry.get("prompt_path", "")) == prompt]
    if not selected:
        issues.append(f"no frozen hash entry for batch={batch or '*'} prompt={prompt or '*'}")
    for entry in selected:
        path = ROOT / entry["prompt_path"]
        if not path.exists():
            issues.append(f"missing prompt: {entry['prompt_path']}")
            continue
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual != entry["sha256"]:
            issues.append(f"hash mismatch: {entry['prompt_path']} batch={entry['batch_id']}")
    if issues:
        for issue in issues:
            print(f"RED: {issue}")
        return 1
    print(f"GREEN: IOS26 prompt freeze check passed entries={len(selected)}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Write current prompt hashes.")
    parser.add_argument("--check", action="store_true", help="Check current prompt hashes.")
    parser.add_argument("--batch", help="Optional batch id.")
    parser.add_argument("--prompt", help="Optional prompt path.")
    args = parser.parse_args()
    if args.write:
        write_hashes()
        print("GREEN: IOS26 prompt freeze hashes written")
        return 0
    return check(args.batch, args.prompt)


if __name__ == "__main__":
    sys.exit(main())
