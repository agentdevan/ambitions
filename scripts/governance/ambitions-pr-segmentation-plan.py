#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

OUT = Path("docs/governance/generated/pr_segmentation_plan.md")

SEGMENTS = {
    "governance": ["docs/governance", "scripts/governance"],
    "canon": ["docs/canon", "docs/truth"],
    "frontend": ["Sources", "Native", "DesignTokens"],
    "prompts": ["prompts"],
}


def main() -> int:
    lines = ["# PR Segmentation Plan", ""]

    for segment, roots in SEGMENTS.items():
        lines += [f"## {segment}", ""]
        for root in roots:
            lines.append(f"- {root}")
        lines.append("")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
