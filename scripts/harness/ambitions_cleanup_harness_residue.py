#!/usr/bin/env python3
"""Clean generated harness residue and fix the AMB-295 runner header typo.

Main-only repo hygiene tool.
Intended changes:
- remove tracked/generated build/reports/harness files
- remove untracked generated build/reports/harness files
- replace 'byppasses' with 'bypasses' in the AMB-295 prompt/header sources
- commit the cleanup locally

Non-claims: this does not prove app behavior, build success, test success,
release readiness, accessibility, device validation, privacy/legal approval,
TestFlight readiness, or App Store readiness.
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
COMMIT_MESSAGE = "Clean harness residue and AMB-295 prompt typo"
ALLOWED_PREFIXES = (
    "build/reports/harness/",
    "prompts/batches/HARNESS-T02-B02-proof-wrapper-scripts.md",
    "scripts/harness/ambitions-finish-pre-app-source-harness.sh",
)
FORBIDDEN_PREFIXES = (
    "Native/",
    "Sources/",
    "AppUI/",
    "Ambitions.xcodeproj/",
    "docs/truth/",
)
FORBIDDEN_EXACT = {"Package.swift", "project.yml"}


def run(args: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    proc = subprocess.run(
        args,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if check and proc.returncode != 0:
        sys.stderr.write(proc.stdout)
        sys.stderr.write(proc.stderr)
        raise SystemExit(proc.returncode)
    return proc


def git_stdout(args: list[str]) -> str:
    return run(["git", *args]).stdout.strip()


def require_main() -> None:
    branch = git_stdout(["branch", "--show-current"])
    if branch != "main":
        raise SystemExit(f"Expected main-only cleanup. Current branch: {branch}")


def status_paths() -> list[str]:
    out = git_stdout(["status", "--porcelain"])
    paths: list[str] = []
    for line in out.splitlines():
        if not line:
            continue
        path = line[3:]
        if " -> " in path:
            path = path.split(" -> ", 1)[0]
        paths.append(path)
    return paths


def require_only_allowed_dirty() -> None:
    bad = [p for p in status_paths() if not p.startswith("build/reports/harness/")]
    if bad:
        run(["git", "status", "--short"], check=False)
        raise SystemExit("Non-harness dirty worktree paths exist. Commit/stash them before cleanup:\n" + "\n".join(bad))


def tracked_harness_files() -> list[str]:
    out = git_stdout(["ls-files", "build/reports/harness/*"])
    return [line for line in out.splitlines() if line]


def remove_file(path: Path) -> None:
    try:
        if path.is_file() or path.is_symlink():
            path.unlink()
    except FileNotFoundError:
        pass


def remove_empty_dirs(root: Path) -> None:
    if not root.exists():
        return
    for current, dirs, files in os.walk(root, topdown=False):
        p = Path(current)
        try:
            p.rmdir()
        except OSError:
            pass


def clean_harness_reports() -> None:
    for rel in tracked_harness_files():
        remove_file(ROOT / rel)

    report_root = ROOT / "build" / "reports" / "harness"
    if report_root.exists():
        for p in sorted(report_root.rglob("*"), key=lambda x: len(x.parts), reverse=True):
            if p.is_file() or p.is_symlink():
                remove_file(p)
            elif p.is_dir():
                try:
                    p.rmdir()
                except OSError:
                    pass
        remove_empty_dirs(report_root)


def fix_typo() -> None:
    paths = [
        ROOT / "prompts" / "batches" / "HARNESS-T02-B02-proof-wrapper-scripts.md",
        ROOT / "scripts" / "harness" / "ambitions-finish-pre-app-source-harness.sh",
    ]
    for path in paths:
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        new = text.replace("byppasses", "bypasses")
        if new != text:
            path.write_text(new, encoding="utf-8")
            print(f"fixed typo in {path.relative_to(ROOT)}")


def stage_intended_paths() -> None:
    run(["git", "add", "-u", "build/reports/harness"], check=False)
    for rel in ALLOWED_PREFIXES[1:]:
        if (ROOT / rel).exists():
            run(["git", "add", rel], check=False)


def staged_paths() -> list[str]:
    out = git_stdout(["diff", "--cached", "--name-only"])
    return [line for line in out.splitlines() if line]


def validate_staged(paths: list[str]) -> None:
    for path in paths:
        if path in FORBIDDEN_EXACT or any(path.startswith(prefix) for prefix in FORBIDDEN_PREFIXES):
            raise SystemExit(f"Forbidden staged path: {path}")
        if not any(path == prefix or path.startswith(prefix) for prefix in ALLOWED_PREFIXES):
            raise SystemExit(f"Unexpected staged path: {path}")


def commit_if_needed() -> None:
    paths = staged_paths()
    if not paths:
        print("No cleanup changes were needed.")
        return
    validate_staged(paths)
    print("Staged cleanup paths:")
    for path in paths:
        print(f"- {path}")
    run(["git", "commit", "-m", COMMIT_MESSAGE])
    print("\nCleanup commit created:")
    print(git_stdout(["log", "-1", "--oneline"]))


def main() -> int:
    require_main()
    require_only_allowed_dirty()
    clean_harness_reports()
    fix_typo()
    stage_intended_paths()
    commit_if_needed()
    print("\nPush command:\n  git push origin main")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
