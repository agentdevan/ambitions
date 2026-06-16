#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

TODAY = "Native/Ambitions/Features/Today/TodayDayRailPanels.swift"


def replace_once(text: str, before: str, after: str, label: str) -> str:
    if before not in text:
        raise RuntimeError(f"Missing marker for {label}")
    return text.replace(before, after, 1)


def main() -> int:
    text = read(TODAY)
    if "var title: String" not in text.split("/// The Reality Meridian", 1)[0]:
        text = replace_once(
            text,
            "private enum TodayMeridianZoom: String, CaseIterable {\n    case window\n    case day\n}\n",
            "private enum TodayMeridianZoom: String, CaseIterable {\n    case window\n    case day\n\n    var title: String {\n        switch self {\n        case .window: \"Start Here\"\n        case .day: \"Meridian\"\n        }\n    }\n}\n",
            "TodayMeridianZoom title",
        )
    if "todayModeSelector" not in text:
        text = replace_once(
            text,
            "                    if dynamicTypeSize.isAccessibilitySize {\n                        accessibilityContextCrown\n                    }\n\n                    HStack(alignment: .top, spacing: theme.spacing.lg) {",
            "                    if dynamicTypeSize.isAccessibilitySize {\n                        accessibilityContextCrown\n                    } else {\n                        todayModeSelector\n                            .padding(.bottom, theme.spacing.md)\n                    }\n\n                    HStack(alignment: .top, spacing: theme.spacing.lg) {",
            "Today mode selector insertion",
        )
        text = replace_once(
            text,
            "    private var timeSpine: some View {\n",
            "    private var todayModeSelector: some View {\n        Picker(\"Today mode\", selection: $meridianZoom) {\n            ForEach(TodayMeridianZoom.allCases, id: \\.self) { zoom in\n                Text(zoom.title).tag(zoom)\n            }\n        }\n        .pickerStyle(.segmented)\n        .accessibilityIdentifier(\"TodayRealityMeridianModeSelector\")\n        .accessibilityLabel(\"Today mode\")\n        .accessibilityHint(\"Switches between the recommended step and the day meridian.\")\n    }\n\n    private var timeSpine: some View {\n",
            "Today mode selector helper",
        )
    text = text.replace('Text("Now")', 'Text("Live now")')
    text = text.replace('Text(dynamicTypeSize.isAccessibilitySize ? "Recommended step" : metaLine(for: heroStep))', 'Text(dynamicTypeSize.isAccessibilitySize ? "Recommended step" : liveMeridianMetaLine(for: heroStep))')
    if "liveMeridianMetaLine" not in text:
        text = replace_once(
            text,
            "    private func primaryActionButton(for heroStep: DayRailHeroStepState) -> some View {\n",
            "    private func liveMeridianMetaLine(for heroStep: DayRailHeroStepState) -> String {\n        \"Now-aware fit · \\(metaLine(for: heroStep))\"\n    }\n\n    private func primaryActionButton(for heroStep: DayRailHeroStepState) -> some View {\n",
            "Today live meta helper",
        )
    write(TODAY, text)

    require_markers(TODAY, ["TimelineView(.periodic", "TodayRealityMeridianModeSelector", "Live now", "liveMeridianMetaLine", "Now-aware fit"])

    write_proof(
        "REPORT_BATCH_32_TODAY_LIVE_MERIDIAN_RECONSTRUCTION.md",
        """
# Batch 32 — Today Live Meridian Reconstruction

Status: applied.

Scope:
- Added a visible Today mode selector for Start Here vs Meridian.
- Promoted the existing TimelineView now-node into a clearer `Live now` marker.
- Added a now-aware fit line before the recommended step explanation.
- Preserved Start Here as the default, not a task board.

Native interaction law:
- Time must be legible before it is intelligent.
- Today must orient the user around live current reality before explaining runtime fit.

Validation:
- Source markers prove the live now marker, mode selector, and now-aware fit text exist.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 32 Today Live Meridian Reconstruction.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
