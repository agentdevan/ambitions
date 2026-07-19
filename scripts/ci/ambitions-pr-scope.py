#!/usr/bin/env python3
"""Classify changed PR paths into explicit, deterministic CI scopes."""

from __future__ import annotations

import argparse
import sys
from pathlib import PurePosixPath


SCOPES = (
    "active-law",
    "source-atlas",
    "xcode-runtime",
    "shell",
    "markdown",
    "yaml",
)

ACTIVE_LAW_EXACT = frozenset(
    {
        "AGENTS.md",
        "project.yml",
        "scripts/ambitions-green-standard-audit.py",
        "scripts/ambitions-local-runtime-proof.py",
        "scripts/ci/ambitions-no-weak-implementation-scan.py",
        "scripts/privacy-boundary-scan.sh",
        "scripts/release-claim-safety-scan.sh",
    }
)
ACTIVE_LAW_PREFIXES = ("Native/", "Packages/", "docs/constitution/", "docs/truth/")

SOURCE_ATLAS_EXACT = frozenset(
    {
        ".semgrep/ambitions-source-atlas.yml",
        "requirements-ci.txt",
        "scripts/source-atlas-boundary-audit.py",
        "scripts/source-atlas-no-private-graph-egress-audit.py",
    }
)
SOURCE_ATLAS_PREFIXES = ("source-atlas/", "tools/source-atlas/")

XCODE_RUNTIME_EXACT = frozenset(
    {
        "docs/qa/evidence/2026-07-05-needs-repair-proof-trigger.md",
        "project.yml",
        "scripts/ambitions-accepted-yellow-misuse-audit.py",
        "scripts/ambitions-architecture-path-normalization-check.py",
        "scripts/ambitions-architecture-inventory.py",
        "scripts/ambitions-bounded-xcodebuild.sh",
        "scripts/ambitions-device-proof-required.py",
        "scripts/ambitions-flagship-ios-standards-check.py",
        "scripts/ambitions-green-standard-audit.py",
        "scripts/ambitions-legacy-runtime-production-use-guard.py",
        "scripts/ambitions-linear-green-claim-audit.py",
        "scripts/ambitions-local-first-boundary-scan.py",
        "scripts/ambitions-master-sequencing-check.py",
        "scripts/ambitions-quality-gate.py",
        "scripts/ambitions-quality-gate.sh",
        "scripts/ambitions-release-non-claim-gate.py",
        "scripts/ambitions-remediation-governance-check.py",
        "scripts/ambitions-run-deterministic-screenshot-lane.sh",
        "scripts/ambitions-run-ui-screenshot-matrix.sh",
        "scripts/ambitions-runtime-direct-write-audit.py",
        "scripts/ambitions-screenshot-artifact-audit.py",
        "scripts/ambitions-test-strength-audit.py",
        "scripts/ambitions-visual-proof-gate.py",
        "scripts/ambitions-vocabulary-drift-scan.py",
        "scripts/lifeshape-linear-control-plane-check.py",
        "scripts/source-atlas-boundary-audit.py",
        "scripts/source-atlas-no-private-graph-egress-audit.py",
    }
)
XCODE_RUNTIME_PREFIXES = (
    "Ambitions.xcodeproj/",
    "Native/",
    "Packages/AmbitionsDesignSystem/",
    "scripts/ambitions-xcode",
)

YAML_EXACT = frozenset({".markdownlint-cli2.yaml", ".yamllint.yml"})
YAML_PREFIXES = (".github/", ".semgrep/")


def _is_safe_relative(path: str) -> bool:
    candidate = PurePosixPath(path)
    return bool(path) and not candidate.is_absolute() and ".." not in candidate.parts


def _matches(scope: str, path: str) -> bool:
    if scope == "active-law":
        return path in ACTIVE_LAW_EXACT or path.startswith(ACTIVE_LAW_PREFIXES)
    if scope == "source-atlas":
        return (
            path in SOURCE_ATLAS_EXACT
            or path.startswith(SOURCE_ATLAS_PREFIXES)
            or (path.startswith("Native/") and "SourceAtlas" in PurePosixPath(path).parts)
            or (path.startswith("Native/") and "SourceAtlas" in PurePosixPath(path).name)
        )
    if scope == "xcode-runtime":
        return path in XCODE_RUNTIME_EXACT or path.startswith(XCODE_RUNTIME_PREFIXES)
    if scope == "shell":
        return path.endswith(".sh")
    if scope == "markdown":
        return path.endswith(".md")
    if scope == "yaml":
        return (
            path in YAML_EXACT
            or (
                path.startswith(YAML_PREFIXES)
                and path.endswith((".yml", ".yaml"))
            )
        )
    raise AssertionError(f"unhandled scope: {scope}")


def classify(scope: str, paths: list[str]) -> tuple[str, ...]:
    """Return sorted unique safe paths applicable to one closed scope."""

    return tuple(
        sorted(
            {
                path
                for raw in paths
                if (path := raw.strip())
                and _is_safe_relative(path)
                and _matches(scope, path)
            }
        )
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("scope", choices=SCOPES)
    parser.add_argument("--format", choices=("summary", "paths"), default="summary")
    args = parser.parse_args(argv)
    matches = classify(args.scope, sys.stdin.read().splitlines())
    if not matches:
        if args.format == "summary":
            print(
                f"scope={args.scope} applicable=false "
                "reason=no-matching-changed-paths"
            )
        return 1
    if args.format == "paths":
        print("\n".join(matches))
    else:
        print(f"scope={args.scope} applicable=true matched={matches[0]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
