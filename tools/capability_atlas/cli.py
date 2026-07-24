"""Command-line interface for the non-normative Capability Atlas program."""

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path
from typing import Sequence

from tools.capability_atlas import __version__
from tools.capability_atlas.classification_pipeline import (
    output_drift,
    render_outputs,
    write_outputs,
)
from tools.capability_atlas.discover import compile_discovery
from tools.capability_atlas.model import CapabilityDiscoveryError
from tools.capability_atlas.taxonomy import (
    TAXONOMY_PATH,
    TAXONOMY_VALIDATION_PATH,
    validate_taxonomy,
)


SUPPORTED_COMMANDS = frozenset({"version", "build", "check"})


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="ambitions-capabilities",
        description=(
            "Harvest, classify, and validate non-normative Ambitions capability artifacts with stable provenance."
        ),
    )
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("version", help="print Capability Atlas tool version")
    subparsers.add_parser(
        "build",
        help="write deterministic discovery, classification, and available taxonomy artifacts",
    )
    subparsers.add_parser(
        "check",
        help="reject invalid or drifted Capability Atlas program artifacts",
    )
    return parser


def _summary(
    compilation: object,
    elapsed_ms: int,
    *,
    taxonomy_validated: bool,
) -> str:
    candidates = getattr(compilation, "candidates")
    source_files = getattr(compilation, "source_files")
    coverage = getattr(compilation, "coverage")
    blocked = sum(item.status == "blocked" for item in coverage)
    taxonomy = ", taxonomy validated" if taxonomy_validated else ""
    return (
        f"{len(candidates)} candidates, {len(source_files)} source files, "
        f"{len(coverage)} source families, {blocked} blocked{taxonomy} "
        f"({elapsed_ms} ms)"
    )


def main(argv: Sequence[str] | None = None, *, root: Path | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    repository_root = (root or Path(__file__).resolve().parents[2]).resolve()
    if args.command == "version":
        print(__version__)
        return 0

    started = time.monotonic()
    try:
        compilation = compile_discovery(repository_root)
        outputs = render_outputs(compilation)
        taxonomy_validated = False
        if (repository_root / TAXONOMY_PATH).exists():
            validation = validate_taxonomy(repository_root, compilation)
            validation.require_valid()
            outputs[TAXONOMY_VALIDATION_PATH] = validation.render()
            taxonomy_validated = True

        if args.command == "check":
            drift = output_drift(repository_root, outputs)
            if drift:
                for path in drift:
                    print(f"CAPABILITY_DISCOVERY_DRIFT {path}", file=sys.stderr)
                print(
                    "Run: python3 scripts/ambitions-capabilities.py build",
                    file=sys.stderr,
                )
                return 1
        else:
            write_outputs(repository_root, outputs)
        elapsed_ms = round((time.monotonic() - started) * 1000)
        verb = "checked" if args.command == "check" else "built"
        print(
            f"Capability Atlas artifacts {verb}: "
            f"{_summary(compilation, elapsed_ms, taxonomy_validated=taxonomy_validated)}."
        )
        return 0
    except CapabilityDiscoveryError as exc:
        print(f"CAPABILITY_DISCOVERY_ERROR {exc}", file=sys.stderr)
        return 1
