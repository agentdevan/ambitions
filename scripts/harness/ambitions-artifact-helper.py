#!/usr/bin/env python3
"""Create a deterministic harness artifact inventory packet.

This helper is support tooling only. It does not build the app, run tests,
or claim release readiness.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT_ROOT = ROOT / "build/reports/harness"


@dataclass(frozen=True)
class GitInfo:
    branch: str
    commit_sha: str
    status_short: str

    @property
    def dirty(self) -> bool:
        return bool(self.status_short.strip())


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


def maybe_run(command: list[str]) -> str:
    result = subprocess.run(
        command,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        return "not available"
    return result.stdout.strip() or "available"


def timestamp_utc(value: str | None) -> str:
    if value:
        return value
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def safe_batch_id(batch_id: str) -> str:
    cleaned = [ch if ch.isalnum() or ch in "._-" else "-" for ch in batch_id]
    return "".join(cleaned).strip("-") or "harness-inventory"


def collect_git_info() -> GitInfo:
    branch = run_git(["branch", "--show-current"]) or run_git(["rev-parse", "--abbrev-ref", "HEAD"])
    commit_sha = run_git(["rev-parse", "--short", "HEAD"])
    status_short = run_git(["status", "--short"])
    return GitInfo(branch=branch, commit_sha=commit_sha, status_short=status_short)


def collect_environment() -> dict[str, str]:
    return {
        "machine": platform.node() or "unknown",
        "platform": platform.system() or "unknown",
        "release": platform.release() or "unknown",
        "machine_arch": platform.machine() or "unknown",
        "python_version": platform.python_version(),
        "shell": os.environ.get("SHELL", "unknown"),
        "macos_version": maybe_run(["sw_vers", "-productVersion"]),
        "xcode_version": "not_checked",
        "xcodegen_version": maybe_run(["xcodegen", "--version"]),
    }


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def build_summary(manifest: dict[str, object]) -> str:
    lines = [
        "# Harness Artifact Inventory",
        "",
        f"Status: {manifest['status']}",
        f"Batch ID: {manifest['batch_id']}",
        f"Mode: {manifest['mode']}",
        f"Timestamp UTC: {manifest['finished_at_utc']}",
        f"Git branch: {manifest['git']['branch']}",
        f"Git SHA: {manifest['git']['commit_sha']}",
        f"Dirty worktree: {str(manifest['git']['dirty']).lower()}",
        "",
        "## Commands",
    ]
    commands = manifest.get("commands", [])
    lines.extend(f"- {command}" for command in commands or ["none"])
    lines.extend([
        "",
        "## Artifacts",
    ])
    lines.extend(f"- {artifact}" for artifact in manifest.get("artifacts", []) or ["none"])
    lines.extend([
        "",
        "## Risks",
    ])
    lines.extend(f"- {risk}" for risk in manifest.get("risks", []) or ["none"])
    lines.extend([
        "",
        "## Claims Not Made",
    ])
    lines.extend(f"- {claim}" for claim in manifest.get("claims_not_made", []) or ["none"])
    lines.extend([
        "",
        "## Next Recommended Step",
        str(manifest.get("next_recommended_step") or "none"),
        "",
    ])
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Create a harness artifact inventory packet.")
    parser.add_argument("--batch", required=True)
    parser.add_argument("--output-dir")
    parser.add_argument("--timestamp-utc")
    parser.add_argument("--mode", default="inventory-only")
    parser.add_argument("--command", action="append", default=[])
    parser.add_argument("--risk", action="append", default=[])
    parser.add_argument("--claim-not-made", action="append", default=[])
    parser.add_argument("--next-recommended-step")
    args = parser.parse_args()

    finished_at_utc = timestamp_utc(args.timestamp_utc)
    output_dir = Path(args.output_dir) if args.output_dir else DEFAULT_OUTPUT_ROOT / safe_batch_id(args.batch) / finished_at_utc
    output_dir = output_dir.resolve()

    git = collect_git_info()
    environment = collect_environment()
    commands = args.command or [f"scripts/harness/ambitions-proof-wrapper.sh --inventory-only --batch {args.batch}"]
    artifacts = [
        str((output_dir / "artifact-manifest.json").relative_to(ROOT)),
        str((output_dir / "artifact-summary.md").relative_to(ROOT)),
    ]
    risks = args.risk or []
    if git.dirty:
        risks.append("Worktree is dirty; inventory reflects live repo state rather than a clean baseline.")
    claims_not_made = args.claim_not_made or [
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
    status = "Yellow" if git.dirty else "Green"
    manifest: dict[str, object] = {
        "schema_version": "1.0",
        "batch_id": args.batch,
        "mode": args.mode,
        "status": status,
        "started_at_utc": finished_at_utc,
        "finished_at_utc": finished_at_utc,
        "git": {
            "branch": git.branch,
            "commit_sha": git.commit_sha,
            "status_short": git.status_short,
            "dirty": git.dirty,
        },
        "environment": environment,
        "commands": commands,
        "artifacts": artifacts,
        "risks": risks,
        "claims_not_made": claims_not_made,
        "next_recommended_step": args.next_recommended_step or "Run the static gates against the installed harness support files.",
    }

    output_dir.mkdir(parents=True, exist_ok=True)
    manifest_path = output_dir / "artifact-manifest.json"
    summary_path = output_dir / "artifact-summary.md"
    write_text(manifest_path, json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    write_text(summary_path, build_summary(manifest))

    print(str(manifest_path.relative_to(ROOT)))
    print(str(summary_path.relative_to(ROOT)))
    print(f"STATUS: {status}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
