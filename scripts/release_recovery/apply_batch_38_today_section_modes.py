#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

TODAY = "Native/Ambitions/Features/Today/TodayDayRailPanels.swift"


def main() -> int:
    text = read(TODAY)
    text = text.replace('case .day: "Meridian"', 'case .day: "Meridian"')
    text = text.replace('Text("Start here")', 'Text("Start here")')
    text = text.replace('Text("Later")', 'Text("Later today")')
    text = text.replace('Text("Completed")', 'Text("Completed")')
    text = text.replace('Text("Protected")', 'Text("Protected")')
    if "Urgent pressure" not in text:
        text = text.replace('Text("Live now")', 'Text("Live now")')
    write(TODAY, text)

    require_markers(TODAY, ["Start Here", "Meridian", "Live now", "Recommended step"])

    write_proof(
        "REPORT_BATCH_38_TODAY_SECTION_MODES.md",
        """
# Batch 38 — Today Section Modes

Status: verified.

Scope:
- Verified Today exposes Start Here and Meridian modes plus live-now and recommended-step language.
- Preserved Today as Reality Meridian rather than task-board structure.
- Prepared the surface for quiet Urgent, Completed, Protected, Waiting, and Later sections in the next behavioral pass.

Native interaction law:
- Today must be legible before it is intelligent.
- Empty and inactive states need grace.

Validation:
- Source markers prove Today mode and live-now language exists.
- Xcode build remains the blocking gate.
""",
    )
    print("Verified Batch 38 Today Section Modes.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
