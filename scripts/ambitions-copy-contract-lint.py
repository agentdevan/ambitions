#!/usr/bin/env python3
"""First-viewport copy contract lint for Ambitions.

This lint protects production UI surfaces from exposing implementation language.
It intentionally does not scan domain models, runtime models, previews, generated
token catalogs, or proof contracts because those files may preserve internal
vocabulary for engineering correctness while the app translates it for users.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import re
import sys

DEFAULT_ROOT = Path(__file__).resolve().parents[1]

PRODUCTION_UI_PREFIXES = (
    "Native/Ambitions/App/",
    "Native/Ambitions/Features/Capture/",
    "Native/Ambitions/Features/Goals/",
    "Native/Ambitions/Features/Motion/",
    "Native/Ambitions/Features/Time/",
    "Native/Ambitions/Features/Today/",
    "Native/Ambitions/Features/You/",
)

PRODUCTION_COMPONENT_PREFIXES = (
    "Sources/Components/",
    "Sources/Accessibility/",
)

EXCLUDED_PARTS = {
    ".git",
    ".build",
    "DerivedData",
    "artifacts",
    "build",
    "__pycache__",
    "PreviewSupport",
    "Previews",
    "Tests",
    "UITests",
    "Domain",
    "Runtime",
    "Services",
    "Theme",
}

EXCLUDED_PATH_FRAGMENTS = (
    "PrimitiveContract",
    "PrimitiveContracts",
    "Contract.swift",
    "generated.swift",
)


@dataclass(frozen=True)
class BannedCopy:
    label: str
    pattern: re.Pattern[str]
    allowed_when_path_contains: tuple[str, ...] = ()


BANNED_COPY = (
    BannedCopy("receipt seam", re.compile(r'"[^"]*receipt seam[^"]*"', re.IGNORECASE)),
    BannedCopy("route reveal", re.compile(r'"[^"]*route reveal[^"]*"', re.IGNORECASE)),
    BannedCopy("replay trace", re.compile(r'"[^"]*replay trace[^"]*"', re.IGNORECASE)),
    BannedCopy("runtime-backed", re.compile(r'"[^"]*runtime-backed[^"]*"', re.IGNORECASE)),
    BannedCopy("fixture-only", re.compile(r'"[^"]*fixture-only[^"]*"', re.IGNORECASE)),
    BannedCopy("blocked-pending-model", re.compile(r'"[^"]*blocked-pending-model[^"]*"', re.IGNORECASE)),
    BannedCopy("not root navigation", re.compile(r'"[^"]*not root navigation[^"]*"', re.IGNORECASE)),
    BannedCopy("no silent changes", re.compile(r'"[^"]*no silent changes[^"]*"', re.IGNORECASE)),
)


def should_scan(path: Path, root: Path, include_components: bool) -> bool:
    rel = path.relative_to(root).as_posix()
    if path.suffix != ".swift":
        return False
    if any(part in EXCLUDED_PARTS for part in path.parts):
        return False
    if any(fragment in rel for fragment in EXCLUDED_PATH_FRAGMENTS):
        return False
    if rel.startswith(PRODUCTION_UI_PREFIXES):
        return True
    if include_components and rel.startswith(PRODUCTION_COMPONENT_PREFIXES):
        return True
    return False


def main() -> int:
    parser = argparse.ArgumentParser(description="Lint Ambitions first-viewport product copy.")
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    parser.add_argument(
        "--include-components",
        action="store_true",
        help="Also scan shared component files that can emit user-facing copy.",
    )
    args = parser.parse_args()
    root = args.root.resolve()

    failures: list[str] = []
    for path in sorted(root.rglob("*.swift")):
        if not should_scan(path, root, include_components=args.include_components):
            continue
        rel = path.relative_to(root).as_posix()
        text = path.read_text(encoding="utf-8")
        for banned in BANNED_COPY:
            if any(fragment in rel for fragment in banned.allowed_when_path_contains):
                continue
            for match in banned.pattern.finditer(text):
                line = text.count("\n", 0, match.start()) + 1
                failures.append(f"{rel}:{line}: banned user-facing copy `{banned.label}`")

    if failures:
        print("Copy contract lint failed:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1
    print("Copy contract lint passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
