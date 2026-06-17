#!/usr/bin/env python3
"""Compatibility launcher for the resilient release recovery autopilot.

This launcher patches the v2 commit step so generated proof files are staged only
when they exist and green batches survive a normal fast-forward race on main.
It never force-pushes; merge conflicts still fail closed for artifact review.
"""

from __future__ import annotations

import subprocess
import sys

import autopilot_v2 as engine


def run_git(args: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(["git", *args], cwd=engine.ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=check)


def stage_recovery_paths() -> None:
    add_paths = ["Native", "Sources", "scripts", ".github", "artifacts/object-stage-mega-train"]
    if engine.STATE_PATH.exists():
        add_paths.append(engine.rel(engine.STATE_PATH))
    if engine.LATEST_PATH.exists():
        add_paths.append(engine.rel(engine.LATEST_PATH))
    run_git(["add", *add_paths])


def push_with_fast_forward_retry() -> None:
    first_push = run_git(["push", "origin", "HEAD:main"], check=False)
    if first_push.returncode == 0:
        print(first_push.stdout)
        return

    print(first_push.stdout, file=sys.stderr)
    run_git(["fetch", "origin", "main"])
    rebase = run_git(["rebase", "origin/main"], check=False)
    if rebase.returncode != 0:
        print(rebase.stdout, file=sys.stderr)
        run_git(["rebase", "--abort"], check=False)
        raise subprocess.CalledProcessError(rebase.returncode, ["git", "rebase", "origin/main"], output=rebase.stdout)

    second_push = run_git(["push", "origin", "HEAD:main"], check=False)
    if second_push.returncode != 0:
        print(second_push.stdout, file=sys.stderr)
        raise subprocess.CalledProcessError(second_push.returncode, ["git", "push", "origin", "HEAD:main"], output=second_push.stdout)
    print(second_push.stdout)


def safe_commit_green_batch(batch: str) -> str | None:
    if not engine.git_diff_exists():
        print("No diff to commit.")
        return None

    run_git(["config", "user.name", "ambitions-recovery-runner"])
    run_git(["config", "user.email", "actions@users.noreply.github.com"])
    stage_recovery_paths()
    if run_git(["diff", "--cached", "--quiet"], check=False).returncode == 0:
        print("No staged diff to commit.")
        return None

    run_git(["commit", "-m", f"Apply Ambitions release recovery {batch}"])
    push_with_fast_forward_retry()
    return engine.current_sha()


if __name__ == "__main__":
    engine.commit_green_batch = safe_commit_green_batch
    raise SystemExit(engine.main(sys.argv[1:]))
