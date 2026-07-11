"""Command-line entrypoint for the Ambitions canon compiler."""

from __future__ import annotations

import argparse
import sys
from collections.abc import Sequence

from tools.ambitions_canon import __version__
from tools.ambitions_canon.model import CanonError


def ensure_supported_python(version: tuple[int, int]) -> None:
    if version < (3, 11):
        raise CanonError(
            "PYTHON_VERSION_UNSUPPORTED",
            "requires Python 3.11+",
        )


def main(argv: Sequence[str] | None = None) -> int:
    ensure_supported_python((sys.version_info.major, sys.version_info.minor))

    parser = argparse.ArgumentParser(prog="ambitions-canon")
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("version", help="print the compiler version")
    arguments = parser.parse_args(argv)

    if arguments.command == "version":
        print(f"ambitions-canon {__version__}")
        return 0

    raise AssertionError(f"unhandled command: {arguments.command}")
