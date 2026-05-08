#!/usr/bin/env python3
"""ACX Impact: non-mutating changed-file impact planner for Ambitions Codex OS."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Sequence
import fnmatch

ROOT = Path(__file__).resolve().parents[2]
IMPACT_MAP = ROOT / ".codex" / "manifests" / "changed-file-impact-map.yml"


def parse_manifest() -> list[dict[str, object]]:
    if not IMPACT_MAP.exists():
        return []
    rules: list[dict[str, object]] = []
    current: dict[str, object] | None = None
    current_key: str | None = None
    for raw in IMPACT_MAP.read_text(encoding="utf-8").splitlines():
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if stripped.startswith("- name:"):
            if current:
                rules.append(current)
            current = {"name": stripped.split(":", 1)[1].strip().strip('"')}
            current_key = None
            continue
        if current is None:
            continue
        if stripped.endswith(":") and not stripped.startswith("-"):
            current_key = stripped[:-1]
            current.setdefault(current_key, [])
            continue
        if stripped.startswith("-") and current_key:
            current.setdefault(current_key, []).append(stripped[1:].strip().strip('"'))
        elif ":" in stripped:
            key, value = stripped.split(":", 1)
            current[key.strip()] = value.strip().strip('"')
            current_key = None
    if current:
        rules.append(current)
    return rules


def changed_paths_from_file(path: Path) -> list[str]:
    if not path.exists():
        return []
    paths: list[str] = []
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if not line or line.startswith("##"):
            continue
        body = line[3:] if len(line) > 3 else line
        body = body.split(" -> ")[-1].strip()
        if body:
            paths.append(body)
    return paths


def match_any(path: str, patterns: list[str]) -> bool:
    for pattern in patterns:
        if fnmatch.fnmatch(path, pattern) or fnmatch.fnmatch(path, pattern.replace("**", "*")):
            return True
        if pattern.endswith("/**") and path.startswith(pattern[:-3]):
            return True
    return False


def plan(paths: list[str]) -> tuple[list[dict[str, object]], dict[str, object]]:
    rules = parse_manifest()
    matched: list[dict[str, object]] = []
    for rule in rules:
        patterns = rule.get("match", [])
        if isinstance(patterns, list) and any(match_any(path, patterns) for path in paths):
            matched.append(rule)
    fallback = {"name": "fallback", "route": "Repo Hygiene", "bundles": ["quick"], "gates": ["scope", "report"]}
    return matched, fallback


def print_plan(paths: list[str]) -> int:
    matched, fallback = plan(paths)
    print("# ACX Impact Plan")
    print("\n## Changed paths")
    if paths:
        for path in paths:
            print(f"- {path}")
    else:
        print("- No changed paths supplied or discovered from status text.")
    print("\n## Matched rules")
    selected = matched or [fallback]
    for rule in selected:
        print(f"- {rule.get('name', 'unnamed')}")
        print(f"  - route: {rule.get('route', 'unknown')}")
        for key in ["bundles", "gates", "extra_validation"]:
            values = rule.get(key, [])
            if values:
                print(f"  - {key}:")
                for value in values if isinstance(values, list) else [values]:
                    print(f"    - {value}")
    print("\n## Suggested first command")
    first = selected[0]
    bundles = first.get("bundles", [])
    if isinstance(bundles, list) and bundles:
        print(f"python3 scripts/ai/acx_local.py bundle {bundles[0]}")
    else:
        print("python3 scripts/ai/acx_local.py bundle quick")
    return 0


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Plan validation routes from changed files without mutating the repo.")
    parser.add_argument("paths", nargs="*", help="Changed file paths. If omitted, use --from-status when supplied.")
    parser.add_argument("--from-status", help="Path to saved git status --short text.")
    args = parser.parse_args(argv)
    paths = list(args.paths)
    if args.from_status:
        paths.extend(changed_paths_from_file((ROOT / args.from_status).resolve()))
    return print_plan(paths)


if __name__ == "__main__":
    raise SystemExit(main())
