#!/usr/bin/env python3
"""Check changed files against an Ambitions batch prompt's allowed/forbidden scope.

Read-only. The guard extracts path-like entries from `Allowed Scope` and
`Forbidden Scope` sections, then compares them with either current git diff
paths or an explicit file list. It is intentionally conservative: forbidden
matches are Red; allowed misses are Yellow unless --strict is used.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

SECTION_RE = re.compile(r"^#{1,3}\s+(Allowed Scope|Forbidden Scope)\s*$", re.IGNORECASE | re.MULTILINE)
PATH_RE = re.compile(r"`([^`]+)`|(?:^|\s)([A-Za-z0-9_./*-]+/[A-Za-z0-9_./*.-]+)")


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def section_body(text: str, name: str) -> str:
    matches = list(SECTION_RE.finditer(text))
    for index, match in enumerate(matches):
        if match.group(1).lower() != name.lower():
            continue
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        return text[start:end]
    return ""


def extract_paths(section: str) -> list[str]:
    paths: list[str] = []
    for raw_line in section.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        for match in PATH_RE.finditer(line):
            path = match.group(1) or match.group(2)
            if not path:
                continue
            if path in {"Do", "No", "Only"}:
                continue
            paths.append(path.strip().rstrip(".,;"))
    return sorted(set(paths))


def git_changed_paths(base_ref: str | None) -> list[str]:
    if base_ref:
        command = ["git", "diff", "--name-only", base_ref]
    else:
        command = ["git", "diff", "--name-only"]
    result = subprocess.run(command, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or f"git diff failed with exit {result.returncode}")
    staged = subprocess.run(["git", "diff", "--cached", "--name-only"], cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    paths = set(result.stdout.splitlines())
    if staged.returncode == 0:
        paths.update(staged.stdout.splitlines())
    return sorted(path for path in paths if path)


def path_matches(pattern: str, path: str) -> bool:
    pattern = pattern.strip()
    if not pattern:
        return False
    if pattern.endswith("/**"):
        return path.startswith(pattern[:-3])
    if pattern.endswith("/*"):
        return path.startswith(pattern[:-1])
    if "*" in pattern:
        regex = "^" + re.escape(pattern).replace("\\*", ".*") + "$"
        return re.match(regex, path) is not None
    if pattern.endswith("/"):
        return path.startswith(pattern)
    return path == pattern or path.startswith(pattern.rstrip("/") + "/")


def main() -> int:
    parser = argparse.ArgumentParser(description="Check changed files against batch prompt scope")
    parser.add_argument("prompt", help="Path to a batch prompt")
    parser.add_argument("--changed-file", action="append", default=[], help="Changed file path. May be passed multiple times. Defaults to git diff paths.")
    parser.add_argument("--base-ref", help="Optional git ref for diff name-only comparison")
    parser.add_argument("--strict", action="store_true", help="Return non-zero for Yellow allowed-scope misses as well as forbidden hits")
    parser.add_argument("--json", action="store_true", help="Emit JSON output")
    args = parser.parse_args()

    prompt_path = ROOT / args.prompt
    defects: list[str] = []
    warnings: list[str] = []

    if not prompt_path.exists():
        payload = {"status": "RED", "defects": [f"missing prompt: {args.prompt}"], "warnings": []}
        print(json.dumps(payload, indent=2) if args.json else f"STATUS: RED\n- missing prompt: {args.prompt}")
        return 1

    text = read_text(prompt_path)
    allowed = extract_paths(section_body(text, "Allowed Scope"))
    forbidden = extract_paths(section_body(text, "Forbidden Scope"))

    try:
        changed = sorted(set(args.changed_file or git_changed_paths(args.base_ref)))
    except RuntimeError as exc:
        payload = {"status": "RED", "defects": [str(exc)], "warnings": []}
        print(json.dumps(payload, indent=2) if args.json else f"STATUS: RED\n- {exc}")
        return 1

    for path in changed:
        forbidden_matches = [pattern for pattern in forbidden if path_matches(pattern, path)]
        if forbidden_matches:
            defects.append(f"{path}: matches forbidden scope {forbidden_matches}")
            continue
        if allowed and not any(path_matches(pattern, path) for pattern in allowed):
            warnings.append(f"{path}: not covered by allowed scope patterns")

    if defects:
        status = "RED"
    elif warnings:
        status = "YELLOW"
    else:
        status = "GREEN"

    payload = {
        "status": status,
        "prompt": args.prompt,
        "changed_paths": changed,
        "allowed_patterns": allowed,
        "forbidden_patterns": forbidden,
        "defects": defects,
        "warnings": warnings,
    }

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(f"STATUS: {status}")
        print("Changed paths:")
        for path in changed or ["none"]:
            print(f"- {path}")
        print("Defects:")
        for item in defects or ["none"]:
            print(f"- {item}")
        print("Warnings:")
        for item in warnings or ["none"]:
            print(f"- {item}")

    return 1 if defects or (args.strict and warnings) else 0


if __name__ == "__main__":
    raise SystemExit(main())
