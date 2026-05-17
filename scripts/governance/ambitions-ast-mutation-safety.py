#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re

OUT = Path("docs/governance/generated/ast_mutation_safety_report.md")
ROOTS = [Path("Sources"), Path("Native"), Path("App")]
DANGEROUS = [
    re.compile(r"enum\s+.*:\s*String"),
    re.compile(r"@Model"),
    re.compile(r"rawValue"),
    re.compile(r"CaseIterable"),
]


def main() -> int:
    findings = []
    for root in ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*.swift"):
            body = path.read_text(encoding="utf-8", errors="replace")
            for rx in DANGEROUS:
                if rx.search(body):
                    findings.append(path.as_posix())
                    break

    lines = ["# AST Mutation Safety Report", "", "Potentially dangerous mutation surfaces:", ""]
    for item in sorted(set(findings)):
        lines.append(f"- {item}")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
