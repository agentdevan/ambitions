#!/usr/bin/env python3
from __future__ import annotations

import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
TRAIN_DIR = ROOT / "prompts" / "object-stage-mega-train"
RUNNER = ROOT / "scripts" / "codex" / "run-object-stage-mega-train.sh"

REQUIRED_PROMPTS = [
    "AMB-AOM-00.md",
    "AMB-AOM-01.md",
    "AMB-AOM-02.md",
    "AMB-AOM-03.md",
    "AMB-AOM-04.md",
    "AMB-AOM-05.md",
    "AMB-AOM-06.md",
    "AMB-AOM-07.md",
    "AMB-AOM-08.md",
    "AMB-AOM-09.md",
    "AMB-AOM-10.md",
    "AMB-AOM-11.md",
    "AMB-AOM-12.md",
]


def main() -> int:
    missing = [name for name in REQUIRED_PROMPTS if not (TRAIN_DIR / name).exists()]
    if missing:
        raise RuntimeError(f"Missing object-stage mega-train prompts: {missing}")
    if not RUNNER.exists():
        raise RuntimeError(f"Missing object-stage mega-train runner: {RUNNER}")

    env = os.environ.copy()
    env.setdefault("START_BATCH", "auto")
    env.setdefault("END_BATCH", "auto")
    env.setdefault("ACCESS_MODE", "full")
    env.setdefault("AUTO_PUSH", "1")
    env.setdefault("MAX_REPAIR_PASSES", "2")
    env.setdefault("KEEP_GOING_ON_YELLOW", "0")
    env.setdefault("ALLOW_YELLOW_COMMIT", "0")

    return subprocess.run(["bash", str(RUNNER)], cwd=ROOT, env=env, check=False).returncode


if __name__ == "__main__":
    raise SystemExit(main())
