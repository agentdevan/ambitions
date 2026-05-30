#!/usr/bin/env python3
"""Static harness gates for Slice 1 support tooling.

The gates verify support files, runner metadata, and forbidden path drift.
They do not prove app behavior, build success, test success, or release readiness.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REPORT_ROOT = ROOT / "build/reports/harness"
DEFAULT_BATCH = "IOS26-HARNESS-T02-B01-artifact-proof-wrapper-static-gates"
RUNNER_HEADER = (
    "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
    "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
    "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
)
REQUIRED_FILES = [
    "docs/codex/HARNESS_README.md",
    "docs/codex/HARNESS_PLAN.md",
    "docs/codex/HARNESS_ARTIFACT_SCHEMA.md",
    "docs/codex/HARNESS_LINEAR.md",
    "docs/codex/HARNESS_RUNS.md",
    "docs/codex/HARNESS_SCORECARD.md",
    "scripts/harness/ambitions-artifact-helper.py",
    "scripts/harness/ambitions-proof-wrapper.sh",
    "scripts/harness/ambitions-static-gates.py",
    "prompts/batches/IOS26-HARNESS-T02-B01-artifact-proof-wrapper-static-gates.md",
    "prompts/batches/IOS26-HARNESS-T02-B02-first-proof-wrapper-run.md",
]
FORBIDDEN_ROOTS = (
    "Native/",
    "Sources/",
    "AppUI/",
    "docs/truth/",
    "project.yml",
    "Package.swift",
    "Package.resolved",
    "Ambitions.xcodeproj/",
    ".codex/runs/",
)
ALLOWED_DRIFT_PREFIXES = (
    "docs/codex/HARNESS_",
    "scripts/harness/",
    "scripts/ambitions-slice1-",
    "prompts/batches/HARNESS",
    "prompts/batches/IOS26-HARNESS",
    "build/reports/harness/",
    "build/reports/parallel-implementation-guard/IOS26-HARNESS",
)


def run_git(args: list[str]) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or f"git {' '.join(args)} failed")
    return result.stdout


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def has_runner_header(text: str) -> bool:
    lines = [line.strip() for line in text.splitlines()[:3]]
    return all(expected in lines for expected in RUNNER_HEADER)


def changed_files() -> list[str]:
    rows = [line.strip() for line in run_git(["status", "--short"]).splitlines() if line.strip()]
    paths: list[str] = []
    for row in rows:
        path = row[3:] if len(row) > 3 and row[1:3] == "  " else row[3:]
        if row.startswith("?? "):
            path = row[3:]
        elif len(row) >= 4 and row[0] in " MADRCU?" and row[1] in " MADRCU?":
            path = row[3:]
        paths.append(path)
    return paths


def classify_drift(path: str) -> str:
    if any(path.startswith(prefix) for prefix in ALLOWED_DRIFT_PREFIXES):
        return "allowed"
    if any(path.startswith(prefix) for prefix in FORBIDDEN_ROOTS):
        return "forbidden"
    return "supporting"


def write_reports(batch_id: str, status: str, payload: dict[str, object]) -> tuple[Path, Path]:
    REPORT_ROOT.mkdir(parents=True, exist_ok=True)
    safe_batch = re.sub(r"[^A-Za-z0-9._-]+", "-", batch_id)
    json_path = REPORT_ROOT / f"{safe_batch}-static-gates.json"
    md_path = REPORT_ROOT / f"{safe_batch}-static-gates.md"
    payload["status"] = status
    payload["json_report"] = str(json_path.relative_to(ROOT))
    payload["markdown_report"] = str(md_path.relative_to(ROOT))
    json_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    lines = [
        "# Harness Static Gates",
        "",
        f"Status: {status}",
        f"Batch: {batch_id}",
        "",
        "## Required Files",
    ]
    for item in payload.get("required_files", []):
        lines.append(f"- {item}")
    lines.extend([
        "",
        "## Runner Header Issues",
    ])
    runner_issues = payload.get("runner_header_issues", [])
    lines.extend(f"- {item}" for item in runner_issues or ["none"])
    lines.extend([
        "",
        "## Forbidden Drift",
    ])
    forbidden = payload.get("forbidden_drift", [])
    lines.extend(f"- {item}" for item in forbidden or ["none"])
    lines.extend([
        "",
        "## Claims Not Made",
    ])
    for item in payload.get("claims_not_made", []):
        lines.append(f"- {item}")
    lines.append("")
    md_path.write_text("\n".join(lines), encoding="utf-8")
    return json_path, md_path


def main() -> int:
    parser = argparse.ArgumentParser(description="Run static gates for the harness support slice.")
    parser.add_argument("--batch", default=DEFAULT_BATCH)
    args = parser.parse_args()

    missing_files = [path for path in REQUIRED_FILES if not (ROOT / path).exists()]
    runner_issues: list[str] = []
    for path in [p for p in REQUIRED_FILES if p.startswith("prompts/batches/")]:
        text = read(ROOT / path)
        if not has_runner_header(text):
            runner_issues.append(path)

    drift_rows = []
    for path in changed_files():
        if classify_drift(path) == "forbidden":
            drift_rows.append(path)

    schema_text = read(ROOT / "docs/codex/HARNESS_ARTIFACT_SCHEMA.md")
    schema_ok = "build/reports/harness/" in schema_text

    status = "Green"
    if missing_files or runner_issues or drift_rows or not schema_ok:
        status = "Red"

    payload: dict[str, object] = {
        "schema_version": "1.0",
        "batch_id": args.batch,
        "required_files": REQUIRED_FILES,
        "missing_files": missing_files,
        "runner_header_issues": runner_issues,
        "forbidden_drift": drift_rows,
        "schema_output_root_verified": schema_ok,
        "claims_not_made": [
            "No app build claim.",
            "No app test claim.",
            "No simulator claim.",
            "No accessibility claim.",
            "No performance claim.",
            "No device claim.",
            "No TestFlight claim.",
            "No App Store claim.",
            "No release readiness claim.",
        ],
        "notes": [
            "Static gates only verify harness support files and worktree drift.",
            "They do not prove app behavior or release readiness.",
        ],
    }

    json_path, md_path = write_reports(args.batch, status, payload)
    payload["artifacts"] = [
        str(json_path.relative_to(ROOT)),
        str(md_path.relative_to(ROOT)),
    ]
    json_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    if status == "Red":
        print(f"RED: static gates failed for {args.batch}")
        if missing_files:
            print("Missing files:")
            for item in missing_files:
                print(f"- {item}")
        if runner_issues:
            print("Runner header issues:")
            for item in runner_issues:
                print(f"- {item}")
        if drift_rows:
            print("Forbidden drift:")
            for item in drift_rows:
                print(f"- {item}")
        if not schema_ok:
            print("Schema output root is not aligned with build/reports/harness/")
        print(f"Reports: {json_path.relative_to(ROOT)} {md_path.relative_to(ROOT)}")
        return 1

    print(f"GREEN: static gates passed for {args.batch}")
    print(f"Reports: {json_path.relative_to(ROOT)} {md_path.relative_to(ROOT)}")
    print(f"Required files checked: {len(REQUIRED_FILES)}")
    print(f"Runner headers checked: {len([p for p in REQUIRED_FILES if p.startswith('prompts/batches/')])}")
    print(f"Forbidden drift entries: {len(drift_rows)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
