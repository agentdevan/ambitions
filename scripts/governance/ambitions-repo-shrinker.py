#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

OUT = Path("docs/governance/generated/repo_shrink_plan.md")
ROOTS = [Path("docs"), Path("prompts"), Path(".codex")]
KEYWORDS = ["historical", "superseded", "archive-candidate", "obsolete"]


def main() -> int:
    candidates = []
    for root in ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*.md"):
            body = path.read_text(encoding="utf-8", errors="replace").lower()
            if any(k in body for k in KEYWORDS):
                candidates.append(path.as_posix())

    lines = ["# Repo Shrink Plan", "", "Potential operational shrink targets:", ""]
    for item in sorted(candidates):
        lines.append(f"- {item}")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
