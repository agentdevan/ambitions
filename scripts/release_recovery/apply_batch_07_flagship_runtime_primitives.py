#!/usr/bin/env python3
"""Batch 07: prove typed flagship runtime primitives exist."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PRIMITIVE = ROOT / "Sources" / "Components" / "FlagshipRuntimeStagePrimitives.swift"
PROOF = ROOT / "artifacts" / "release-recovery" / "FLAGSHIP_UI_TRAIN_02.md"
REQUIRED = [
    "struct FlagshipRuntimeStage",
    "struct FlagshipRuntimeMetric",
    "struct FlagshipRuntimeProofHook",
    "dynamicTypeSize",
    "accessibilityReduceMotion",
    "accessibilityIdentifier(screenshotIdentifier)",
]


def require(path: Path, needles: list[str]) -> None:
    text = path.read_text(encoding="utf-8")
    missing = [needle for needle in needles if needle not in text]
    if missing:
        raise RuntimeError(f"{path.relative_to(ROOT)} missing: {', '.join(missing)}")


def main() -> int:
    require(PRIMITIVE, REQUIRED)
    PROOF.parent.mkdir(parents=True, exist_ok=True)
    PROOF.write_text(
        "# Flagship UI Train 02\n\n"
        "Status: primitives installed.\n\n"
        "Strict promotion requires typed SwiftUI primitives, compile-safe adapters, screenshot proof hooks, VoiceOver, Dynamic Type, and Reduce Motion coverage before final Green.\n",
        encoding="utf-8",
    )
    print("Applied Batch 07 flagship runtime primitive proof.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
