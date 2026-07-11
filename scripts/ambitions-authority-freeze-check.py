#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path, PurePosixPath, PureWindowsPath
from typing import Iterable


ROOT = Path(__file__).resolve().parents[1]
BASELINE = ROOT / "docs/canon/migration/authority-freeze-baseline.json"
AUTHORITY_WORD_RE = re.compile(
    r"(truth|canon|constitution|doctrine|authority)",
    re.IGNORECASE,
)
ALLOWED_PREFIXES = (
    "docs/canon/",
    "docs/superpowers/specs/",
    "docs/superpowers/plans/",
    "tools/ambitions_canon/",
    "tests/canon/",
)
ALLOWED_FILES = {
    "scripts/ambitions-canon.py",
    ".github/workflows/ambitions-canon-shadow-audit.yml",
}


class InputValidationError(ValueError):
    def __init__(self, reason: str):
        super().__init__(reason)
        self.reason = reason


def canonical_repository_path(path: object) -> str:
    if not isinstance(path, str):
        raise InputValidationError("path-not-string")
    if not path:
        raise InputValidationError("path-empty")
    windows_path = PureWindowsPath(path)
    if PurePosixPath(path).is_absolute() or windows_path.drive:
        raise InputValidationError("path-absolute")
    parts = path.split("/")
    if (
        "\\" in path
        or any(part in {"", ".", ".."} for part in parts)
        or PurePosixPath(path).as_posix() != path
    ):
        raise InputValidationError("noncanonical-path")
    return path


def authority_candidates(paths: Iterable[str]) -> tuple[str, ...]:
    candidates = set()
    for path in paths:
        canonical_path = canonical_repository_path(path)
        if canonical_path in ALLOWED_FILES or canonical_path.startswith(ALLOWED_PREFIXES):
            continue
        if any(AUTHORITY_WORD_RE.search(part) for part in canonical_path.split("/")):
            candidates.add(canonical_path)
    return tuple(sorted(candidates))


def new_authority_paths(paths: Iterable[str], baseline: set[str]) -> tuple[str, ...]:
    return tuple(path for path in authority_candidates(paths) if path not in baseline)


def tracked_paths() -> tuple[str, ...]:
    output = subprocess.check_output(
        ["git", "ls-files"], cwd=ROOT, text=True
    )
    return tuple(line for line in output.splitlines() if line)


def load_baseline(path: Path) -> set[str]:
    try:
        serialized = path.read_text(encoding="utf-8")
    except FileNotFoundError as error:
        raise InputValidationError("missing") from error
    except (OSError, UnicodeError) as error:
        raise InputValidationError("read-error") from error

    try:
        payload = json.loads(serialized)
    except json.JSONDecodeError as error:
        raise InputValidationError("malformed-json") from error

    if not isinstance(payload, dict):
        raise InputValidationError("root-not-object")
    if type(payload.get("schema_version")) is not int or payload["schema_version"] != 1:
        raise InputValidationError("schema-version")
    paths = payload.get("paths")
    if not isinstance(paths, list):
        raise InputValidationError("paths-not-list")
    return {canonical_repository_path(path) for path in paths}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseline", type=Path, default=BASELINE)
    args = parser.parse_args()
    try:
        baseline = load_baseline(args.baseline)
    except InputValidationError as error:
        print(
            "RED AUTHORITY_FREEZE_INVALID_INPUT "
            f"reason={error.reason} baseline={args.baseline}",
            file=sys.stderr,
        )
        return 2
    findings = new_authority_paths(tracked_paths(), baseline)
    if findings:
        for finding in findings:
            print(f"RED AUTHORITY_FREEZE_NEW_PATH {finding}", file=sys.stderr)
        return 1
    print(f"GREEN authority freeze baseline_paths={len(baseline)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
