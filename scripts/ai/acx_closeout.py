#!/usr/bin/env python3
"""ACX Closeout: generate compact Codex OS closeout packets."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Sequence

ROOT = Path(__file__).resolve().parents[2]
PROOF_CACHE = ROOT / ".codex" / "state" / "proof-cache.json"
RECENT_VALIDATION = ROOT / ".codex" / "state" / "recent-validation.md"
ACTIVE_BATCH = ROOT / ".codex" / "state" / "active-batch.yml"
YELLOW_LEDGER = ROOT / ".codex" / "state" / "yellow-ledger.md"
HARD_RED_LEDGER = ROOT / ".codex" / "state" / "hard-red-ledger.md"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def proof_entries(limit: int) -> list[dict[str, object]]:
    try:
        data = json.loads(read(PROOF_CACHE)) if PROOF_CACHE.exists() else {}
        entries = data.get("entries", [])
        return entries[-limit:] if isinstance(entries, list) else []
    except json.JSONDecodeError:
        return []


def generate(limit: int) -> str:
    entries = proof_entries(limit)
    lines = [
        "# ACX Closeout Packet",
        "",
        "Result: Suggested Yellow until the responsible Codex session confirms scope, evidence, and claims-not-made.",
        "",
        "## Proof cache entries",
    ]
    if entries:
        for item in entries:
            lines.append(f"- `{item.get('profile')}` exit `{item.get('exit')}` commit `{item.get('commit')}` raw `{item.get('raw_log')}` sha `{item.get('raw_log_sha256')}`")
    else:
        lines.append("- No proof-cache entries found.")
    lines.extend([
        "",
        "## Recent validation mirror",
        read(RECENT_VALIDATION).strip()[:4000] or "No recent-validation mirror found.",
        "",
        "## Active batch mirror",
        read(ACTIVE_BATCH).strip()[:2000] or "No active-batch mirror found.",
        "",
        "## Yellow / hard Red mirrors",
        "### Yellow",
        read(YELLOW_LEDGER).strip()[:2000] or "No Yellow ledger found.",
        "",
        "### Hard Red",
        read(HARD_RED_LEDGER).strip()[:2000] or "No hard Red ledger found.",
        "",
        "## Claims not made by this packet",
        "- Build pass unless a build profile/raw log is present and cited.",
        "- Test pass unless a test profile/raw log is present and cited.",
        "- Device proof, public accessibility conformance, legal/privacy compliance, App Store/TestFlight/release readiness, or production readiness.",
    ])
    return "\n".join(lines) + "\n"


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Generate Codex OS closeout packet from local mirrors and proof cache.")
    parser.add_argument("--limit", type=int, default=20)
    parser.add_argument("--write", help="Optional output path inside repo.")
    args = parser.parse_args(argv)
    packet = generate(args.limit)
    if args.write:
        target = (ROOT / args.write).resolve()
        try:
            target.relative_to(ROOT)
        except ValueError:
            print("Red: refusing to write outside repo root.")
            return 2
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(packet, encoding="utf-8")
        print(f"Wrote {target.relative_to(ROOT)}")
    else:
        print(packet)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
