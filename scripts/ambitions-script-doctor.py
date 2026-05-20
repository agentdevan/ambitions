#!/usr/bin/env python3
"""Validate the Ambitions script control plane.

This doctor is intentionally lightweight: it checks script-governance safety
without running app build/test validation.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
INVENTORY = ROOT / "docs/status/ambitions-script-inventory.md"

CANONICAL_ENTRYPOINTS = {
    "scripts/ambitions-codex-train.sh",
    "scripts/ambitions-xcode-validate.sh",
    "scripts/ambitions-codex-os-validate.py",
    "scripts/governance/ambitions-repo-doctor.py",
    "scripts/codex-forbidden-claim-scan.sh",
    "scripts/ios26-flagship-preflight.py",
    "scripts/ios26-flagship-proof-packet-check.py",
    "scripts/ios26-flagship-run-sequential.sh",
}

APPROVED_RAW_XCODE = {
    "scripts/ambitions-xcode-validate.sh",
    "scripts/ambitions-xcode-build-for-testing.sh",
    "scripts/ambitions-xcode-test-focused.sh",
    "scripts/ambitions-xcode-test-plan.sh",
    "scripts/build-local.sh",
    "scripts/setup_macos_ios_dev.sh",
    "scripts/ambitions-swift6-final-gate.sh",
}

APPROVED_RESET_HARD = {
    "scripts/ambitions-codex-train.sh",
}

SCRIPT_SUFFIXES = {
    ".sh",
    ".py",
    ".rb",
    ".pl",
    ".js",
    ".ts",
    ".swift",
    ".command",
}


def run(args: list[str]) -> str:
    return subprocess.check_output(args, cwd=ROOT, text=True, stderr=subprocess.DEVNULL)


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def script_paths() -> list[str]:
    paths: set[str] = set()
    scripts_dir = ROOT / "scripts"
    if scripts_dir.exists():
        for path in scripts_dir.rglob("*"):
            if path.is_file() and (path.suffix in SCRIPT_SUFFIXES or os.access(path, os.X_OK)):
                paths.add(rel(path))
    try:
        tracked = run(["git", "ls-files", "scripts"]).splitlines()
        for path in tracked:
            if Path(path).suffix in SCRIPT_SUFFIXES or Path(path).name == ".DS_Store":
                paths.add(path)
    except subprocess.CalledProcessError:
        pass
    return sorted(paths)


def deleted_script_paths() -> list[str]:
    deleted: list[str] = []
    try:
        status = run(["git", "status", "--short", "--", "scripts"]).splitlines()
    except subprocess.CalledProcessError:
        return deleted
    for line in status:
        if len(line) >= 4 and line[:2].strip() == "D":
            path = line[3:].strip()
            if path.startswith("scripts/"):
                deleted.append(path)
    return sorted(deleted)


def read_inventory_rows() -> dict[str, dict[str, str]]:
    if not INVENTORY.exists():
        return {}
    rows: dict[str, dict[str, str]] = {}
    headers: list[str] | None = None
    for raw in INVENTORY.read_text().splitlines():
        line = raw.strip()
        if not line.startswith("|") or "---" in line:
            continue
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if cells and cells[0] == "path":
            headers = cells
            continue
        if not headers or len(cells) != len(headers):
            continue
        row = dict(zip(headers, cells))
        path = row.get("path", "")
        if path.startswith("scripts/"):
            rows[path] = row
    return rows


def scan_forbidden_patterns(paths: list[str]) -> list[str]:
    failures: list[str] = []
    git_add_a = re.compile(r"(^|[;&|()\s])git\s+add\s+-A(\s|$)")
    git_add_dot = re.compile(r"(^|[;&|()\s])git\s+add\s+\.(\s|$)")
    reset_token = "reset"
    hard_token = "--hard"
    git_reset_hard = re.compile(rf"(^|[;&|()\s])git\s+{reset_token}\s+{hard_token}(\s|$)")
    raw_xcode = re.compile(r"(^|[;&|()\s])xcodebuild\s+(-project|test|build|build-for-testing|test-without-building)\b")

    for path in paths:
        full = ROOT / path
        if not full.exists() or full.name == ".DS_Store":
            continue
        try:
            text = full.read_text(errors="ignore")
        except OSError:
            continue
        for lineno, line in enumerate(text.splitlines(), start=1):
            if git_add_a.search(line) or git_add_dot.search(line):
                failures.append(f"{path}:{lineno}: broad git add is not approved")
            if git_reset_hard.search(line) and path not in APPROVED_RESET_HARD:
                failures.append(f"{path}:{lineno}: destructive git reset is not approved here")
            if raw_xcode.search(line) and path not in APPROVED_RAW_XCODE:
                failures.append(f"{path}:{lineno}: raw xcodebuild must route through approved wrapper internals")
    return failures


def summarize(paths: list[str], rows: dict[str, dict[str, str]]) -> str:
    shell_count = sum(1 for path in paths if path.endswith(".sh"))
    python_count = sum(1 for path in paths if path.endswith(".py"))
    executable_count = sum(1 for path in paths if (ROOT / path).exists() and os.access(ROOT / path, os.X_OK))
    classifications: dict[str, int] = {}
    for row in rows.values():
        classification = row.get("classification", "unindexed")
        classifications[classification] = classifications.get(classification, 0) + 1
    class_text = ", ".join(f"{key}={value}" for key, value in sorted(classifications.items())) or "none"
    return "\n".join(
        [
            f"scripts_total={len(paths)}",
            f"shell_scripts={shell_count}",
            f"python_scripts={python_count}",
            f"executable_scripts={executable_count}",
            f"inventory_rows={len(rows)}",
            f"classifications={class_text}",
        ]
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Ambitions script hygiene.")
    parser.add_argument("--summary-only", action="store_true", help="print inventory summary without failing scans")
    args = parser.parse_args()

    paths = script_paths()
    deleted = deleted_script_paths()
    rows = read_inventory_rows()

    print(summarize(paths, rows))
    if args.summary_only:
        return 0

    failures: list[str] = []

    if (ROOT / "scripts/.DS_Store").exists():
        failures.append("scripts/.DS_Store exists")

    for entrypoint in sorted(CANONICAL_ENTRYPOINTS):
        if not (ROOT / entrypoint).exists():
            failures.append(f"canonical entrypoint missing: {entrypoint}")

    for path in paths:
        if path not in rows:
            failures.append(f"inventory missing script row: {path}")

    for path in deleted:
        row = rows.get(path)
        if not row:
            failures.append(f"deleted script not listed in inventory: {path}")
        elif row.get("delete_safe", "").lower() != "true":
            failures.append(f"deleted script is not delete_safe: true in inventory: {path}")

    failures.extend(scan_forbidden_patterns(paths))

    if failures:
        print("ambitions_script_doctor=failed")
        for failure in failures:
            print(f"FAIL {failure}")
        return 1

    print("ambitions_script_doctor=passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
