#!/usr/bin/env python3
"""Batch 08: wire Today to the flagship Reality Meridian adapter."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ADAPTER = ROOT / "Native" / "Ambitions" / "Features" / "Today" / "TodayRealityMeridianFlagshipAdapter.swift"
SCREEN = ROOT / "Native" / "Ambitions" / "Features" / "Today" / "TodayScreen.swift"


def require(path: Path, needles: list[str]) -> None:
    text = path.read_text(encoding="utf-8")
    missing = [needle for needle in needles if needle not in text]
    if missing:
        raise RuntimeError(f"{path.relative_to(ROOT)} missing: {', '.join(missing)}")


def main() -> int:
    screen = SCREEN.read_text(encoding="utf-8")
    if "TodayRealityMeridianFlagshipAdapter(" not in screen:
        screen = screen.replace("RealityMeridianView(", "TodayRealityMeridianFlagshipAdapter(", 1)
        SCREEN.write_text(screen, encoding="utf-8")
    require(ADAPTER, ["FlagshipRuntimeStage(", "dynamicTypeSize", "accessibilityReduceMotion", "today.flagship.reality-meridian", "VoiceOver"])
    require(SCREEN, ["TodayRealityMeridianFlagshipAdapter("])
    print("Applied Batch 08 Today flagship adapter wiring.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
