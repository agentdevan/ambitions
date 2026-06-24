#!/usr/bin/env python3
"""SCG starter audit for senior-review infrastructure.

This script validates the SCG-001 install without claiming app senior-readiness.
It checks required governance files, parses JSON schemas, verifies the baseline
SHA is present, and rejects production behavior diffs for this infrastructure
slice.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BASELINE_SHA = "bab9994a855ab84bb39c30da7a789fe11ead4305"
BASELINE_FILE = ROOT / "docs" / "quality" / "senior-review" / "BASELINE.md"
OWNERSHIP_MAP = ROOT / "docs" / "quality" / "senior-review" / "OWNERSHIP_MAP.yaml"
SCHEMA_DIR = ROOT / "docs" / "quality" / "senior-review" / "schemas"

REQUIRED_FILES = [
    "docs/quality/senior-review/BASELINE.md",
    "docs/quality/senior-review/01_AMBITIONS_SENIOR_IOS_CODE_STANDARD.md",
    "docs/quality/senior-review/02_NON_SENIOR_FAILURE_TAXONOMY.md",
    "docs/quality/senior-review/03_FILE_BY_FILE_REVIEW_PROTOCOL.md",
    "docs/quality/senior-review/04_LAYER_OWNERSHIP_IMPORT_MATRIX.md",
    "docs/quality/senior-review/05_FAKE_SENIORITY_ANTI_GAMING_RULES.md",
    "docs/quality/senior-review/OWNERSHIP_MAP.yaml",
    "docs/quality/senior-review/schemas/senior-review-finding.schema.json",
    "docs/quality/senior-review/schemas/file-review.schema.json",
    "docs/quality/senior-review/schemas/senior-audit-report.schema.json",
    "docs/quality/senior-review/schemas/ownership-map.schema.json",
    "scripts/ambitions-senior-code-audit.py",
]

REQUIRED_OWNERS = [
    "App",
    "Stage",
    "Core",
    "Projection",
    "Language",
    "Trust",
    "Interaction",
    "Rendering",
    "DesignSystem",
    "Surfaces",
    "Composer",
    "Scenarios",
    "Diagnostics",
    "Quality",
]

PRODUCTION_PATTERNS = [
    re.compile(r"^Native/"),
    re.compile(r"^Sources/"),
    re.compile(r"^Packages/"),
    re.compile(r"^AppUI/"),
    re.compile(r"^project\.yml$"),
    re.compile(r"^Package\.swift$"),
    re.compile(r"^Package\.resolved$"),
    re.compile(r".*\.xcodeproj(/|$)"),
    re.compile(r".*\.xcworkspace(/|$)"),
    re.compile(r".*\.xcprivacy$"),
]

ALLOWED_CHANGED_PREFIXES = (
    "docs/quality/senior-review/",
    "scripts/ambitions-senior-code-audit.py",
)

ALLOWED_CHANGED_FILES = {
    "docs/qa/KNOWN_ISSUES.md",
}


@dataclass(frozen=True)
class Check:
    name: str
    status: str
    detail: str


def run_git(args: list[str]) -> tuple[int, str, str]:
    proc = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    return proc.returncode, proc.stdout.strip(), proc.stderr.strip()


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def is_production_path(path: str) -> bool:
    return any(pattern.search(path) for pattern in PRODUCTION_PATTERNS)


def required_file_check() -> Check:
    missing = [path for path in REQUIRED_FILES if not (ROOT / path).is_file()]
    if missing:
        return Check("required_files", "RED", "missing: " + ", ".join(missing))
    return Check("required_files", "GREEN", f"{len(REQUIRED_FILES)} required files present")


def baseline_check() -> Check:
    if not BASELINE_FILE.is_file():
        return Check("baseline_sha", "RED", "BASELINE.md missing")
    text = BASELINE_FILE.read_text(encoding="utf-8")
    if BASELINE_SHA not in text:
        return Check("baseline_sha", "RED", f"baseline SHA {BASELINE_SHA} missing")
    code, _, err = run_git(["cat-file", "-e", f"{BASELINE_SHA}^{{commit}}"])
    if code != 0:
        return Check("baseline_sha", "RED", f"baseline commit not present: {err}")
    return Check("baseline_sha", "GREEN", BASELINE_SHA)


def schema_check() -> Check:
    if not SCHEMA_DIR.is_dir():
        return Check("schemas", "RED", "schema directory missing")
    schemas = sorted(SCHEMA_DIR.glob("*.schema.json"))
    if not schemas:
        return Check("schemas", "RED", "no schema files found")
    failures: list[str] = []
    for schema in schemas:
        try:
            parsed = json.loads(schema.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            failures.append(f"{relative(schema)}: {exc}")
            continue
        for key in ("$schema", "title", "type"):
            if key not in parsed:
                failures.append(f"{relative(schema)}: missing {key}")
    if failures:
        return Check("schemas", "RED", "; ".join(failures))
    return Check("schemas", "GREEN", ", ".join(relative(path) for path in schemas))


def ownership_map_check() -> Check:
    if not OWNERSHIP_MAP.is_file():
        return Check("ownership_map", "RED", "OWNERSHIP_MAP.yaml missing")
    text = OWNERSHIP_MAP.read_text(encoding="utf-8")
    failures = [owner for owner in REQUIRED_OWNERS if f"  {owner}:" not in text]
    if BASELINE_SHA not in text:
        failures.append("baseline_sha")
    if "schema: docs/quality/senior-review/schemas/ownership-map.schema.json" not in text:
        failures.append("schema reference")
    if failures:
        return Check("ownership_map", "RED", "missing: " + ", ".join(failures))
    return Check("ownership_map", "GREEN", f"{len(REQUIRED_OWNERS)} canonical owners mapped")


def git_diff_names(args: list[str]) -> list[str]:
    code, out, err = run_git(args)
    if code != 0:
        raise RuntimeError(err or "git diff failed")
    return [line for line in out.splitlines() if line]


def changed_files_since_baseline() -> list[str]:
    committed = git_diff_names(["diff", "--name-only", f"{BASELINE_SHA}...HEAD"])
    unstaged = git_diff_names(["diff", "--name-only"])
    staged = git_diff_names(["diff", "--cached", "--name-only"])
    untracked_code, untracked_out, untracked_err = run_git(["ls-files", "--others", "--exclude-standard"])
    if untracked_code != 0:
        raise RuntimeError(untracked_err or "git ls-files failed")
    untracked = [line for line in untracked_out.splitlines() if line]
    return sorted(set(committed + unstaged + staged + untracked))


def production_diff_check() -> Check:
    try:
        changed = changed_files_since_baseline()
    except RuntimeError as exc:
        return Check("production_diff", "RED", str(exc))

    forbidden = [path for path in changed if is_production_path(path)]
    if forbidden:
        return Check("production_diff", "RED", "forbidden production paths: " + ", ".join(forbidden))

    unexpected = [
        path
        for path in changed
        if path
        and not path.startswith(ALLOWED_CHANGED_PREFIXES)
        and path not in ALLOWED_CHANGED_FILES
        and path not in REQUIRED_FILES
    ]
    if unexpected:
        return Check("scope_diff", "RED", "unexpected non-production paths: " + ", ".join(unexpected))

    return Check("production_diff", "GREEN", "no production behavior paths changed")


def git_state() -> dict[str, str]:
    _, branch, _ = run_git(["branch", "--show-current"])
    _, head, _ = run_git(["rev-parse", "HEAD"])
    _, status, _ = run_git(["status", "--short", "--branch"])
    return {"branch": branch, "head": head, "status": status}


def run_checks() -> list[Check]:
    return [
        required_file_check(),
        baseline_check(),
        schema_check(),
        ownership_map_check(),
        production_diff_check(),
    ]


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Validate SCG senior-review infrastructure install.")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON output.")
    args = parser.parse_args(argv)

    checks = run_checks()
    overall = "GREEN" if all(check.status == "GREEN" for check in checks) else "RED"
    payload = {
        "status": overall,
        "claim": "Source Green for SCG-001 infrastructure installation only" if overall == "GREEN" else "SCG-001 infrastructure install has blocking gaps",
        "non_claims": [
            "app senior-readiness",
            "build success",
            "runtime readiness",
            "visual readiness",
            "accessibility readiness",
            "privacy approval",
            "performance readiness",
            "TestFlight readiness",
            "App Store readiness",
            "release readiness",
        ],
        "baseline_sha": BASELINE_SHA,
        "git": git_state(),
        "checks": [asdict(check) for check in checks],
    }

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(f"{overall}: {payload['claim']}")
        print(f"baseline_sha: {BASELINE_SHA}")
        for check in checks:
            print(f"{check.status}: {check.name}: {check.detail}")
        print("non-claims: " + ", ".join(payload["non_claims"]))

    return 0 if overall == "GREEN" else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
