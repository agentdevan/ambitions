#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCOPED_GREEN = re.compile(r"\b(Source|Runtime|Interaction|Visual|Release) Green\b")
UNQUALIFIED_GREEN = re.compile(r"\bStatus:\s*Green\b|\bGREEN\b")
VISUAL_RELEASE_GREEN_STATUS = re.compile(r"\bStatus:\s*(Visual|Release) Green\b")


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

    for path in (ROOT / "docs").rglob("*.md"):
        relative = path.relative_to(ROOT).as_posix()
        if relative not in changed:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        if relative.startswith(("docs/truth/", "docs/design/")):
            continue
        if UNQUALIFIED_GREEN.search(text) and not SCOPED_GREEN.search(text):
            findings.append(f"{relative}: unqualified Green appears without split status")
        if VISUAL_RELEASE_GREEN_STATUS.search(text) and "Independent visual reviewer:" not in text:
            findings.append(f"{relative}: Visual/Release Green lacks Independent visual reviewer")

    if findings:
        print("ambitions-linear-green-claim-audit RED")
        for finding in findings:
            print(f"- {finding}")
        return 1

    print("ambitions-linear-green-claim-audit GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
