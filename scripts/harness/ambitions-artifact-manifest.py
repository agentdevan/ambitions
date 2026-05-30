#!/usr/bin/env python3
"""Emit a machine-readable harness artifact manifest.

This support tool records harness metadata only. It does not build the app,
run tests, or claim release readiness.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import subprocess
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT_ROOT = ROOT / "build/reports/harness"
DEFAULT_CLAIMS_NOT_MADE = [
    "No app build claim.",
    "No app test claim.",
    "No simulator claim.",
    "No accessibility claim.",
    "No performance claim.",
    "No device claim.",
    "No TestFlight claim.",
    "No App Store claim.",
    "No release readiness claim.",
]
VALID_STATUSES = {"green": "Green", "yellow": "Yellow", "red": "Red"}


@dataclass(frozen=True)
class GitInfo:
    branch: str
    commit_sha: str
    status_short: str
    head_detached: bool

    @property
    def dirty(self) -> bool:
        return bool(self.status_short.strip())


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def format_utc(value: datetime) -> str:
    return value.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def parse_utc(value: str | None) -> str:
    return value or format_utc(utc_now())


def safe_batch_id(batch_id: str) -> str:
    cleaned = [ch if ch.isalnum() or ch in "._-" else "-" for ch in batch_id]
    return "".join(cleaned).strip("-") or "harness-artifact-manifest"


def display_path(path: Path) -> str:
    resolved = path.resolve()
    try:
        return str(resolved.relative_to(ROOT))
    except ValueError:
        return str(resolved)


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
    return result.stdout.strip()


def collect_git_info() -> GitInfo:
    branch = run_git(["branch", "--show-current"])
    head_detached = False
    if not branch:
        branch = run_git(["rev-parse", "--abbrev-ref", "HEAD"])
        head_detached = branch == "HEAD"
    commit_sha = run_git(["rev-parse", "HEAD"])
    status_short = run_git(["status", "--short"])
    return GitInfo(
        branch=branch or "unknown",
        commit_sha=commit_sha,
        status_short=status_short,
        head_detached=head_detached,
    )


def collect_environment() -> dict[str, str]:
    return {
        "machine": platform.node() or "unknown",
        "platform": platform.system() or "unknown",
        "release": platform.release() or "unknown",
        "machine_arch": platform.machine() or "unknown",
        "python_version": platform.python_version(),
        "shell": os.environ.get("SHELL", "unknown"),
    }


def normalize_status(value: str | None) -> str | None:
    if value is None:
        return None
    key = value.strip().lower()
    if key not in VALID_STATUSES:
        raise argparse.ArgumentTypeError("status must be Green, Yellow, or Red")
    return VALID_STATUSES[key]


def infer_status(git_info: GitInfo, commands: list[dict[str, object]]) -> str:
    if any(command["exit_code"] != 0 for command in commands):
        return "Red"
    if git_info.dirty:
        return "Yellow"
    return "Green"


def clamp_text(value: str, limit: int) -> tuple[str, bool]:
    if limit < 0:
        return value, False
    if len(value) <= limit:
        return value, False
    return value[:limit], True


def run_command(command: str, capture_limit_bytes: int) -> dict[str, object]:
    started = utc_now()
    monotonic_start = time.perf_counter()
    result = subprocess.run(
        command,
        cwd=ROOT,
        text=True,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    finished = utc_now()
    elapsed_ms = int(round((time.perf_counter() - monotonic_start) * 1000))
    stdout, stdout_truncated = clamp_text(result.stdout or "", capture_limit_bytes)
    stderr, stderr_truncated = clamp_text(result.stderr or "", capture_limit_bytes)
    return {
        "command": command,
        "exit_code": result.returncode,
        "status": "pass" if result.returncode == 0 else "fail",
        "started_at_utc": format_utc(started),
        "finished_at_utc": format_utc(finished),
        "duration_ms": elapsed_ms,
        "stdout": stdout,
        "stderr": stderr,
        "stdout_truncated": stdout_truncated,
        "stderr_truncated": stderr_truncated,
        "stdout_line_count": len((result.stdout or "").splitlines()),
        "stderr_line_count": len((result.stderr or "").splitlines()),
    }


def default_claims_not_made() -> list[str]:
    return list(DEFAULT_CLAIMS_NOT_MADE)


def main() -> int:
    parser = argparse.ArgumentParser(description="Emit a harness artifact manifest.")
    parser.add_argument("--batch", required=True)
    parser.add_argument("--mode", default="inventory-only")
    parser.add_argument("--status", type=normalize_status)
    parser.add_argument("--timestamp-utc")
    parser.add_argument("--started-at-utc")
    parser.add_argument("--finished-at-utc")
    parser.add_argument("--output-dir")
    parser.add_argument("--output-file")
    parser.add_argument("--capture-limit-bytes", type=int, default=4096)
    parser.add_argument("--command", action="append", default=[])
    parser.add_argument("--artifact", action="append", default=[])
    parser.add_argument("--risk", action="append", default=[])
    parser.add_argument("--claim-made", "--claims-made", action="append", dest="claims_made", default=[])
    parser.add_argument(
        "--claim-not-made",
        "--claims-not-made",
        action="append",
        dest="claims_not_made",
        default=[],
    )
    parser.add_argument("--non-claim", "--non-claims", action="append", dest="non_claims", default=[])
    parser.add_argument("--note", action="append", default=[])
    args = parser.parse_args()

    created_at_utc = parse_utc(args.timestamp_utc)
    started_at_utc = args.started_at_utc or created_at_utc
    finished_at_utc = args.finished_at_utc or created_at_utc

    if args.output_file:
        output_file = Path(args.output_file)
        output_dir = output_file.parent
    else:
        output_dir = (
            Path(args.output_dir)
            if args.output_dir
            else DEFAULT_OUTPUT_ROOT / safe_batch_id(args.batch) / created_at_utc
        )
        output_file = output_dir / "artifact-manifest.json"

    git_info = collect_git_info()
    command_records = [run_command(command, args.capture_limit_bytes) for command in args.command]
    status = args.status or infer_status(git_info, command_records)

    claims_not_made = list(args.claims_not_made or default_claims_not_made())
    non_claims = list(args.non_claims or claims_not_made)

    manifest: dict[str, object] = {
        "schema_version": "artifact-manifest.v1",
        "batch_id": args.batch,
        "mode": args.mode,
        "status": status,
        "created_at_utc": created_at_utc,
        "started_at_utc": started_at_utc,
        "finished_at_utc": finished_at_utc,
        "git": {
            "branch": git_info.branch,
            "commit_sha": git_info.commit_sha,
            "status_short": git_info.status_short,
            "dirty": git_info.dirty,
            "head_detached": git_info.head_detached,
        },
        "environment": collect_environment(),
        "commands": command_records,
        "artifacts": [
            {
                "path": display_path(output_file),
                "kind": "manifest",
                "classification": "evidence",
                "production_use": False,
            },
            *[
                {
                    "path": artifact,
                    "kind": "other",
                    "classification": "evidence",
                    "production_use": False,
                }
                for artifact in args.artifact
            ],
        ],
        "risks": list(args.risk)
        + (
            ["Worktree is dirty; manifest reflects live repo state rather than a clean baseline."]
            if git_info.dirty
            else []
        ),
        "claims_made": list(args.claims_made),
        "claims_not_made": claims_not_made,
        "non_claims": non_claims,
        "notes": list(args.note),
    }

    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    json.dump(manifest, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
