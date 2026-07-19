#!/usr/bin/env python3
"""Minimal prompt repair helper for OBS scope prompts."""
from __future__ import annotations

import argparse
from pathlib import Path

REQUIRED_HEADERS = [
    "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
    "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
    "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
]


def repair(text: str) -> tuple[str, bool]:
    changed = False
    lines = text.splitlines()
    header_index = next(
        (i for i, line in enumerate(lines) if line.strip().startswith("# Batch ID")),
        len(lines),
    )
    present = set(line.strip() for line in lines[:header_index] if line.strip().startswith("<!--"))

    insert_at = 0
    while insert_at < header_index and lines[insert_at].strip() == "":
        insert_at += 1

    for header in REQUIRED_HEADERS:
        if header not in present:
            lines.insert(insert_at, header)
            insert_at += 1
            header_index += 1
            changed = True
    return "\n".join(lines) + ("\n" if text.endswith("\n") else ""), changed


def main() -> int:
    parser = argparse.ArgumentParser(description="Repair OBS batch prompt metadata")
    parser.add_argument("prompt")
    parser.add_argument("--output", default=None)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    path = Path(args.prompt)
    if not path.exists():
        print(f"Missing prompt file: {path}")
        return 1

    text = path.read_text(encoding="utf-8")
    repaired, changed = repair(text)
    if args.dry_run:
        print("DRY RUN: would add missing headers" if changed else "DRY RUN: no repair needed")
        return 0

    output = Path(args.output) if args.output else path
    output.write_text(repaired, encoding="utf-8")
    print(f"REPAIRED={path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
