"""Command-line interface for non-normative capability discovery."""

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path
from typing import Sequence

from tools.capability_atlas import __version__
from tools.capability_atlas.discover import (
    compile_discovery,
    output_drift,
    render_outputs,
    write_outputs,
)
from tools.capability_atlas.model import CapabilityDiscoveryError


SUPPORTED_COMMANDS = frozenset({"version", "build", "check"})


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="ambitions-capabilities",
        description=(
            "Harvest non-normative Ambitions capability candidates with stable provenance."
        ),
    )
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("version", help="print discovery tool version")
    subparsers.add_parser(
        "build",
        help="scan configured repository sources and write deterministic discovery artifacts",
    )
    subparsers.add_parser(
        "check",
        help="scan configured repository sources and reject checked-in discovery drift",
    )
    return parser


def _summary(compilation: object, elapsed_ms: int) -> str:
    candidates = getattr(compilation, "candidates")
    source_files = getattr(compilation, "source_files")
    coverage = getattr(compilation, "coverage")
    blocked = sum(item.status == "blocked" for item in coverage)
    return (
        f"{len(candidates)} candidates, {len(source_files)} source files, "
        f"{len(coverage)} source families, {blocked} blocked ({elapsed_ms} ms)"
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
        print(f"Capability discovery {verb}: {_summary(compilation, elapsed_ms)}.")
        return 0
    except CapabilityDiscoveryError as exc:
        print(f"CAPABILITY_DISCOVERY_ERROR {exc}", file=sys.stderr)
        return 1
