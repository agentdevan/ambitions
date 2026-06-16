#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PROOF = ROOT / "artifacts/release-recovery/FLAGSHIP_UI_TRAIN_02.md"
CHECKS = [
    ("Sources/Components/FlagshipRuntimeStagePrimitives.swift", "FlagshipRuntimeStage"),
    ("Native/Ambitions/Features/Today/TodayScreen.swift", "TodayRealityMeridianFlagshipAdapter"),
    ("Native/Ambitions/Features/Capture/CaptureScreen.swift", "flagshipCaptureComposerStage"),
    ("Native/Ambitions/App/AppShellView.swift", "shell.flagship.chrome.header"),
]


def main() -> int:
    if not PROOF.exists():
        raise RuntimeError("proof artifact missing")
    proof = PROOF.read_text(encoding="utf-8")
    for marker in ["typed SwiftUI", "adapter layers", "screenshot hooks", "motion-reduction"]:
        if marker not in proof:
            raise RuntimeError(f"proof marker missing: {marker}")
    for rel, marker in CHECKS:
        if marker not in (ROOT / rel).read_text(encoding="utf-8"):
            raise RuntimeError(f"source marker missing: {rel}")
    print("Applied Batch 11 flagship proof check.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
