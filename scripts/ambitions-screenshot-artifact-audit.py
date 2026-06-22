#!/usr/bin/env python3
from __future__ import annotations

import sys
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


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
        if ".codex/xcode-summaries" in text or ".codex/xcode-results" in text:
            if "local working evidence" not in text.lower() and "not visual acceptance" not in text.lower():
                findings.append(f"{relative}: local .codex screenshot/result path used without non-acceptance disclaimer")
        if "Rendered actual:" in text and "Rendered target:" in text:
            if ".png" not in text and ".jpg" not in text and "attachment" not in text.lower():
                findings.append(f"{relative}: rendered proof section lacks image attachment/reference")

    if findings:
        print("ambitions-screenshot-artifact-audit RED")
        for finding in findings:
            print(f"- {finding}")
        return 1

    print("ambitions-screenshot-artifact-audit GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
