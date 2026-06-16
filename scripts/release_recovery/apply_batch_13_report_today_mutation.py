#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TODAY = ROOT / "Native/Ambitions/Features/Today/TodayScreen.swift"
RAIL = ROOT / "Native/Ambitions/Features/Today/TodayDayRailPanels.swift"

SNIPPET = '''
            if let message = viewModel.transientMessage {
                TodayInlineFallbackState(
                    title: message.title,
                    message: message.body,
                    systemImage: "checkmark.circle.fill"
                )
                .padding(.top, theme.spacing.md)
                .accessibilityIdentifier("today.post-closure-feedback")
            }
'''


def main() -> int:
    text = TODAY.read_text(encoding="utf-8")
    if "today.post-closure-feedback" not in text:
        anchor = "            .transition(.opacity)\n"
        if anchor not in text:
            raise RuntimeError("Today loaded-state anchor missing")
        text = text.replace(anchor, anchor + SNIPPET, 1)
    text = text.replace("This step is still here. Nothing changes until you close the loop.", "This step stays here until you choose an outcome.")
    text = text.replace("Step Session ended without changing proof or plan.", "Step Session ended. Today is ready for the next step.")
    TODAY.write_text(text, encoding="utf-8")

    today_text = TODAY.read_text(encoding="utf-8")
    for marker in ["today.post-closure-feedback", "TodayInlineFallbackState", "This step stays here until you choose an outcome."]:
        if marker not in today_text:
            raise RuntimeError(f"Today mutation marker missing: {marker}")
    rail_text = RAIL.read_text(encoding="utf-8")
    if "10:05" in rail_text:
        raise RuntimeError("hardcoded Today time remains")
    print("Applied Batch 13 report Today mutation repair.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
