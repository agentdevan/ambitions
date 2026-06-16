#!/usr/bin/env python3
"""Compatibility launcher for the resilient release recovery autopilot.

This launcher patches the v2 commit step so generated proof files are staged only
when they exist. It prevents green batches from failing after validation because
a summary artifact is written later in the run lifecycle.
"""

from __future__ import annotations

import subprocess
import sys

import autopilot_v2 as engine


def safe_commit_green_batch(batch: str) -> str | None:
    if not engine.git_diff_exists():
        print("No diff to commit.")
        return None

    subprocess.run(["git", "config", "user.name", "ambitions-recovery-runner"], cwd=engine.ROOT, check=True)
    subprocess.run(["git", "config", "user.email", "actions@users.noreply.github.com"], cwd=engine.ROOT, check=True)

    add_paths = ["Native", "Sources", "scripts", ".github"]
    if engine.STATE_PATH.exists():
        add_paths.append(engine.rel(engine.STATE_PATH))
    if engine.LATEST_PATH.exists():
        add_paths.append(engine.rel(engine.LATEST_PATH))

    subprocess.run(["git", "add", *add_paths], cwd=engine.ROOT, check=True)
    if subprocess.run(["git", "diff", "--cached", "--quiet"], cwd=engine.ROOT, check=False).returncode == 0:
        print("No staged diff to commit.")
        return None

    subprocess.run(["git", "commit", "-m", f"Apply Ambitions release recovery {batch}"], cwd=engine.ROOT, check=True)
    subprocess.run(["git", "push", "origin", "HEAD:main"], cwd=engine.ROOT, check=True)
    return engine.current_sha()


if __name__ == "__main__":
    engine.commit_green_batch = safe_commit_green_batch
    raise SystemExit(engine.main(sys.argv[1:]))
