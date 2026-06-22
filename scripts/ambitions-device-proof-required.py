#!/usr/bin/env python3
from __future__ import annotations

import sys
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
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
        if relative.startswith(("docs/truth/", "docs/design/")):
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        if VISUAL_RELEASE_GREEN_STATUS.search(text) is None:
            continue
        lowercased = text.lower()
        has_device = "physical device" in lowercased and "iphone" in lowercased and "build sha" in lowercased
        if not has_device:
            findings.append(f"{relative}: Visual/Release Green claim lacks physical iPhone proof with build SHA")

    if findings:
        print("ambitions-device-proof-required RED")
        for finding in findings:
            print(f"- {finding}")
        return 1

    print("ambitions-device-proof-required GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
