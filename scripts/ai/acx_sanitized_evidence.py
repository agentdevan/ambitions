#!/usr/bin/env python3
"""Generate sanitized validation evidence from ACX proof cache without committing raw logs."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Sequence

ROOT = Path(__file__).resolve().parents[2]
PROOF_CACHE = ROOT / ".codex" / "state" / "proof-cache.json"


def load_entries() -> list[dict[str, object]]:
    if not PROOF_CACHE.exists():
        return []
    try:
        data = json.loads(PROOF_CACHE.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return []
    entries = data.get("entries", [])
    return entries if isinstance(entries, list) else []


def packet(limit: int) -> str:
    entries = load_entries()[-limit:]
    lines = [
        "# Sanitized ACX Evidence Packet",
        "",
        "Status: Sanitized mirror. Raw logs remain local under `.codex/logs/` and are gitignored.",
        "",
        "| Timestamp | Commit | Profile | Exit | Raw log | SHA256 |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    if entries:
        for item in entries:
            lines.append(
                f"| {item.get('timestamp', '')} | `{item.get('commit', '')}` | `{item.get('profile', '')}` | `{item.get('exit', '')}` | `{item.get('raw_log', '')}` | `{item.get('raw_log_sha256', '')}` |"
            )
    else:
        lines.append("| none | none | none | none | none | none |")
    lines.extend([
        "",
        "## Claims not made",
        "- This packet does not expose raw local logs.",
        "- This packet does not prove build/test/device/accessibility/release/legal/privacy readiness unless the cited profiles and owner docs support those claims.",
    ])
    return "\n".join(lines) + "\n"


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Generate sanitized evidence from ACX proof cache.")
    parser.add_argument("--limit", type=int, default=40)
    parser.add_argument("--write", help="Optional output file inside repo.")
    args = parser.parse_args(argv)
    text = packet(args.limit)
    if args.write:
        target = (ROOT / args.write).resolve()
        try:
            target.relative_to(ROOT)
        except ValueError:
            print("Red: refusing to write outside repo root.")
            return 2
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text, encoding="utf-8")
        print(f"Wrote {target.relative_to(ROOT)}")
    else:
        print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
