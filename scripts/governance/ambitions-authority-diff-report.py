#!/usr/bin/env python3
from __future__ import annotations

import subprocess
from pathlib import Path

OUT = Path("docs/governance/generated/authority_diff_report.md")


def git(args: list[str]) -> str:
    return subprocess.run(["git", *args], text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout


def main() -> int:
    diff = git(["diff", "--name-only", "HEAD~1", "HEAD"])

    active = []
    historical = []
    generated = []

    for line in diff.splitlines():
        if not line.strip():
            continue
        if "/archive/" in line or "/history/" in line:
            historical.append(line)
        elif "/generated/" in line:
            generated.append(line)
        else:
            active.append(line)

    lines = [
        "# Authority Diff Report",
        "",
        "## Active Changes",
        "",
    ]

    for item in active:
        lines.append(f"- {item}")

    lines += ["", "## Historical / Archive Changes", ""]
    for item in historical:
        lines.append(f"- {item}")

    lines += ["", "## Generated Changes", ""]
    for item in generated:
        lines.append(f"- {item}")

    while lines and lines[-1] == "":
        lines.pop()

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n")

    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
