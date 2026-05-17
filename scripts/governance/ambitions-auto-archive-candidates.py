#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

ROOTS = [Path("docs"), Path("prompts")]
KEYWORDS = ["superseded", "historical", "archive-candidate", "obsolete"]


def main() -> int:
    findings = []

    for root in ROOTS:
        if not root.exists():
            continue

        for path in root.rglob("*.md"):
            text = path.read_text(encoding="utf-8", errors="replace")[:6000].lower()
            if any(k in text for k in KEYWORDS):
                findings.append(path.as_posix())

    out = Path("docs/governance/generated/archive_candidates.md")
    out.parent.mkdir(parents=True, exist_ok=True)

    lines = ["# Archive Candidates", ""]
    for item in sorted(findings):
        lines.append(f"- {item}")

    out.write_text("\n".join(lines) + "\n")

    print(f"Detected {len(findings)} archive candidates")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
