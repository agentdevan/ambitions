#!/usr/bin/env python3
"""Validate IOS26 core replacement proof packet shape after later execution.

This does not prove implementation.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED_SECTIONS = [
    "Status",
    "Files changed",
    "User jobs covered",
    "Replacement P0 gates",
    "Tests run",
    "Validation not run",
    "Accessibility status",
    "Privacy/local-first status",
    "Performance status",
    "Claims allowed",
    "Claims forbidden",
    "Yellow/Red items",
]
BLOCKED_CLAIMS = [
    "release-ready",
    "App Store-ready",
    "TestFlight-ready",
    "fully accessible",
    "performance validated",
    "privacy approved",
]


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def in_forbidden_context(text: str, index: int) -> bool:
    prefix = text[:index]
    headings = [m for m in re.finditer(r"^#+\s+(.+)$", prefix, flags=re.MULTILINE)]
    if not headings:
        return False
    heading = headings[-1].group(1).lower()
    return "claims forbidden" in heading or "forbidden" in heading


def infer_artifact(train: str | None, batch: str | None) -> Path | None:
    roots = {
        "TRAIN_04E": "build/reports/core-replacement-contracts",
        "TRAIN_04F": "build/reports/time-operations",
        "TRAIN_04G": "build/reports/reminder-operations",
        "TRAIN_04H": "build/reports/project-step-operations",
        "TRAIN_04I": "build/reports/life-knowledge-operations",
        "TRAIN_04J": "build/reports/life-command-search",
        "TRAIN_04K": "build/reports/private-life-runtime-integration",
    }
    if train and not batch:
        return ROOT / roots.get(train, "") / f"{train}_CLOSEOUT.md"
    if batch:
        match = re.search(r"IOS26-T(04[A-Z])-B(\d{2})", batch)
        if match:
            train_id = "TRAIN_" + match.group(1)
            return ROOT / roots.get(train_id, "") / f"{batch}.md"
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--train")
    parser.add_argument("--batch")
    parser.add_argument("--require-scenarios", type=int, default=0)
    parser.add_argument("--require-existing", action="store_true")
    parser.add_argument("--artifact", help="Explicit proof artifact path.")
    args = parser.parse_args()

    issues: list[str] = []
    artifact = ROOT / args.artifact if args.artifact else infer_artifact(args.train, args.batch)
    if artifact is None:
        issues.append("could not infer proof artifact; pass --artifact")
    elif not artifact.exists():
        if args.require_existing:
            issues.append(f"missing proof artifact: {rel(artifact)}")
        else:
            print(f"YELLOW: proof artifact not present yet: {rel(artifact)}")
    else:
        text = artifact.read_text(encoding="utf-8")
        for section in REQUIRED_SECTIONS:
            if section not in text:
                issues.append(f"{rel(artifact)}: missing `{section}`")
        if args.require_scenarios:
            match = re.search(r"scenario count\s*:?\s*(\d+)", text, flags=re.IGNORECASE)
            if not match:
                issues.append(f"{rel(artifact)}: missing scenario count line")
            elif int(match.group(1)) < args.require_scenarios:
                issues.append(f"{rel(artifact)}: scenario count {match.group(1)} below required {args.require_scenarios}")
        for claim in BLOCKED_CLAIMS:
            for match in re.finditer(re.escape(claim), text):
                if not in_forbidden_context(text, match.start()):
                    issues.append(f"{rel(artifact)}: blocked claim `{claim}` outside forbidden section")
    if issues:
        for issue in issues:
            print(f"RED: {issue}")
        return 1
    print("GREEN: IOS26 core replacement proof shape check passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
