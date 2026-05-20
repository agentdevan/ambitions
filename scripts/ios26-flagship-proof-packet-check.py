#!/usr/bin/env python3
"""Validate IOS26 proof packet shape without claiming proof contents pass."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml"
RUNBOOK = ROOT / "docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md"
BLOCKED_CLAIMS = [
    "release-ready",
    "App Store-ready",
    "TestFlight-ready",
    "device-verified",
    "fully accessible",
    "VoiceOver verified",
    "Dynamic Type verified",
    "performance validated",
    "privacy approved",
    "legally approved",
]


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def parse_proof_roots() -> list[Path]:
    roots: list[Path] = []
    in_roots = False
    for line in MANIFEST.read_text(encoding="utf-8").splitlines():
        if line.strip() == "proof_artifact_roots:":
            in_roots = True
            continue
        if in_roots and line and not line.startswith("  - "):
            break
        if in_roots and line.startswith("  - "):
            roots.append(ROOT / line.removeprefix("  - ").strip())
    return roots


def scan_claims(paths: list[Path]) -> list[str]:
    issues: list[str] = []
    for path in paths:
        if path.is_file():
            candidates = [path]
        elif path.is_dir():
            candidates = [p for p in path.rglob("*") if p.is_file() and p.suffix in {".md", ".txt", ".json", ".yml", ".yaml"}]
        else:
            continue
        for candidate in candidates:
            try:
                text = candidate.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
            for claim in BLOCKED_CLAIMS:
                if claim in text:
                    issues.append(f"{rel(candidate)}: blocked claim text `{claim}`")
    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--batch", help="Optional IOS26 batch id for report labeling.")
    parser.add_argument("--require-existing", action="store_true", help="Fail when proof roots do not exist yet.")
    args = parser.parse_args()

    issues: list[str] = []
    if not MANIFEST.exists():
        issues.append(f"missing {rel(MANIFEST)}")
    if not RUNBOOK.exists():
        issues.append(f"missing {rel(RUNBOOK)}")
    if issues:
        for issue in issues:
            print(f"RED: {issue}")
        return 1

    roots = parse_proof_roots()
    if len(roots) < 10:
        issues.append(f"expected IOS26 proof roots in manifest, found {len(roots)}")

    missing_roots = [root for root in roots if not root.exists()]
    if args.require_existing and missing_roots:
        issues.extend(f"missing proof root: {rel(root)}" for root in missing_roots)

    existing = [root for root in roots if root.exists()]
    issues.extend(scan_claims(existing + [RUNBOOK, MANIFEST]))

    if issues:
        for issue in issues:
            print(f"RED: {issue}")
        return 1

    label = f" batch={args.batch}" if args.batch else ""
    print(f"GREEN: IOS26 proof packet shape passed{label}")
    print(f"proof_roots_declared={len(roots)}")
    print(f"proof_roots_existing={len(existing)}")
    if missing_roots and not args.require_existing:
        print(f"missing_roots_yellow={len(missing_roots)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
