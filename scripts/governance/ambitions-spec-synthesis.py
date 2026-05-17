#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
from datetime import datetime, timezone

OUT = Path("docs/governance/generated/mature_spec_synthesis.md")
ROOTS = [Path("docs/canon"), Path("docs/governance")]

KEYS = [
    "Today", "Goals", "Capture", "Time", "You",
    "Reality Meridian", "Constellation Atlas", "Atmosphere Composer", "LifeShape Field",
    "Start Here", "local-first", "on-device"
]


def main() -> int:
    sections = {k: [] for k in KEYS}

    for root in ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*.md"):
            text = path.read_text(encoding="utf-8", errors="replace")
            for key in KEYS:
                if key in text:
                    sections[key].append(path.as_posix())

    lines = ["# Mature Spec Synthesis", "", f"Generated: {datetime.now(timezone.utc).isoformat()}", ""]

    for key, refs in sections.items():
        lines += [f"## {key}", ""]
        if refs:
            lines += [f"- Source: {r}" for r in sorted(set(refs))[:40]]
        else:
            lines.append("- No source references detected")
        lines.append("")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
