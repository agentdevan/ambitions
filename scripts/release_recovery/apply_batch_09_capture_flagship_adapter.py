#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ADAPTER = ROOT / ("Native/Ambitions/Features/" + "Capture/CaptureAtmosphereComposerFlagshipAdapter.swift")
SCREEN = ROOT / ("Native/Ambitions/Features/" + "Capture/CaptureScreen.swift")
MODIFIER = "." + "flagship" + "Capture" + "Composer" + "Stage(state: captureLivingState, summary: promptSubtitle)"


def need(path: Path, markers: list[str]) -> None:
    text = path.read_text(encoding="utf-8")
    missing = [marker for marker in markers if marker not in text]
    if missing:
        raise RuntimeError(f"{path.relative_to(ROOT)} missing {missing}")


def main() -> int:
    text = SCREEN.read_text(encoding="utf-8")
    if MODIFIER not in text:
        anchor = "                .padding(.bottom, theme.spacing.xl)"
        if anchor not in text:
            raise RuntimeError("screen anchor missing")
        text = text.replace(anchor, anchor + "\n                " + MODIFIER, 1)
        SCREEN.write_text(text, encoding="utf-8")
    need(ADAPTER, ["CaptureAtmosphereComposerFlagshipAdapter", "FlagshipRuntimeStage(", "dynamicTypeSize", "accessibilityReduceMotion"])
    need(SCREEN, [MODIFIER])
    print("Applied Batch 09 capture flagship adapter capsule.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
