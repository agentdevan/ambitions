#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

OUT = Path("docs/governance/generated/supersession_rewrite_plan.md")
ROOTS = [Path("docs"), Path("prompts")]
KEYWORDS = ["superseded", "historical", "archive-candidate", "obsolete", "deprecated"]


def main() -> int:
    findings = []
    for root in ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*.md"):
            body = path.read_text(encoding="utf-8", errors="replace").lower()
            if any(k in body for k in KEYWORDS):
                findings.append(path.as_posix())

    lines = ["# Supersession Rewrite Plan", ""]
    for item in sorted(findings):
        lines.append(f"- classify/archive/rewrite: {item}")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
