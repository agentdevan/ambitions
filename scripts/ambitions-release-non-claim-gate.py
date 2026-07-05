#!/usr/bin/env python3
"""Require proof metadata for changed release-facing architecture packets."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

PACKET_PREFIXES = (
    "docs/linear/reconciliation/",
    "docs/qa/evidence/",
    "docs/validation/",
)

PACKET_FILES = {
    "docs/native-build-and-release.md",
}

TEXT_EXTENSIONS = {".md", ".json", ".yml", ".yaml", ".txt"}

RELEASE_FACING_PATTERNS = [
    re.compile(pattern, re.I)
    for pattern in [
        r"\bTestFlight\b",
        r"\bApp Store\b",
        r"\bRelease Green\b",
        r"\brelease[- ]ready\b",
        r"\brelease readiness\b",
        r"\brelease-facing\b",
        r"\bRelease Candidate\b",
        r"\bRC checklist\b",
        r"\bdevice proof\b",
        r"\bdevice readiness\b",
        r"\bprivacy/legal\b",
        r"\bbuild success\b",
        r"\btest success\b",
    ]
]

REQUIRED_METADATA = {
    "validation run": re.compile(r"\bValidation run\b|\bCommands/procedures\b", re.I),
    "validation not run": re.compile(r"\bValidation not run\b", re.I),
    "non-claims": re.compile(r"\bNon-Claims\b|\bNon-claims\b|\bClaims not supported\b", re.I),
    "branch": re.compile(r"\bBranch\b", re.I),
    "commit": re.compile(r"\bCommit SHA\b|\bCommit\b|\bBaseline main SHA\b", re.I),
    "environment": re.compile(r"\bEnvironment\b", re.I),
    "xcode version": re.compile(r"\bXcode version\b", re.I),
    "simulator or device": re.compile(r"\bSimulator\b|\bDevice\b|\bDestination\b", re.I),
    "exit code": re.compile(r"\bExit code\b", re.I),
    "artifact paths": re.compile(r"\bArtifact paths\b|\bProof artifacts\b|\bEvidence paths\b", re.I),
}


def run_git(args: list[str]) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return result.stdout


def changed_paths() -> set[str]:
    paths = set(run_git(["diff", "--name-only", "HEAD", "--"]).splitlines())
    for line in run_git(["status", "--porcelain"]).splitlines():
        if not line:
            continue
        paths.add(line[3:].strip())
    return paths


def candidate_paths(args: list[str]) -> list[Path]:
    raw_paths = args if args else sorted(changed_paths())
    paths: list[Path] = []
    for raw in raw_paths:
        path = (ROOT / raw).resolve()
        if not path.is_file() or path.suffix not in TEXT_EXTENSIONS:
            continue
        try:
            relative = path.relative_to(ROOT).as_posix()
        except ValueError:
            continue
        if relative in PACKET_FILES or relative.startswith(PACKET_PREFIXES):
            paths.append(path)
    return paths


def is_release_facing(text: str) -> bool:
    return any(pattern.search(text) for pattern in RELEASE_FACING_PATTERNS)


def missing_metadata(text: str) -> list[str]:
    return [
        label
        for label, pattern in REQUIRED_METADATA.items()
        if pattern.search(text) is None
    ]


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Require proof metadata for changed release-facing packets."
    )
    parser.add_argument("paths", nargs="*", help="Optional paths to scan.")
    args = parser.parse_args(argv)

    failures: list[str] = []
    scanned_release_facing = 0

    for path in candidate_paths(args.paths):
        text = path.read_text(encoding="utf-8", errors="replace")
        if not is_release_facing(text):
            continue
        scanned_release_facing += 1
        missing = missing_metadata(text)
        if missing:
            relative = path.relative_to(ROOT).as_posix()
            failures.append(f"{relative}: missing {', '.join(missing)}")

    if failures:
        print("ambitions-release-non-claim-gate RED")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("ambitions-release-non-claim-gate GREEN")
    print(f"release_facing_packets_checked={scanned_release_facing}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
