#!/usr/bin/env python3
from __future__ import annotations

import sys
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = [
    "docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md",
    "docs/design/targets/time/lifeshape_field_visual_target.md",
    "docs/design/targets/time/lifeshape_field_acceptance_rubric.md",
    "docs/design/red_fixtures/time/current_failed_lifeshape_field.png",
    "docs/design/red_fixtures/time/current_failed_lifeshape_field.md",
]

FORBIDDEN_CLOSEOUT_PHRASES = [
    "visual proof inspected",
]


def changed_paths() -> set[str]:
    result = subprocess.run(
        ["git", "diff", "--name-only", "HEAD", "--"],
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    paths = set(result.stdout.splitlines())
    status = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    for line in status.stdout.splitlines():
        if line:
            paths.add(line[3:].strip())
    return paths


def main() -> int:
    findings: list[str] = []
    changed = changed_paths()

    for relative in REQUIRED:
        if not (ROOT / relative).exists():
            findings.append(f"{relative}: required visual target/proof artifact is missing")

    for path in (ROOT / "docs").rglob("*.md"):
        relative = path.relative_to(ROOT).as_posix()
        if relative not in changed:
            continue
        if relative.startswith(("docs/truth/", "docs/design/")):
            continue
        text = path.read_text(encoding="utf-8", errors="replace").lower()
        for phrase in FORBIDDEN_CLOSEOUT_PHRASES:
            if phrase in text and "independent visual reviewer" not in text:
                findings.append(f"{relative}: '{phrase}' appears without independent visual reviewer")

    if findings:
        print("ambitions-visual-proof-gate RED")
        for finding in findings:
            print(f"- {finding}")
        return 1

    print("ambitions-visual-proof-gate GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
