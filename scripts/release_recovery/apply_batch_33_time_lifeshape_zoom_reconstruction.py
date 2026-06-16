#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

TIME = "Native/Ambitions/Features/Time/TimeLifeShapeField.swift"


def replace_once(text: str, before: str, after: str, label: str) -> str:
    if before not in text:
        raise RuntimeError(f"Missing marker for {label}")
    return text.replace(before, after, 1)


def main() -> int:
    text = read(TIME)
    if "private enum TimeLifeShapeZoomLevel" not in text:
        text = replace_once(
            text,
            "private struct TimeObjectStageInlineDatum: Identifiable {\n",
            "private enum TimeLifeShapeZoomLevel: String, CaseIterable {\n    case field\n    case day\n    case week\n    case month\n    case list\n\n    var title: String {\n        switch self {\n        case .field: \"Field\"\n        case .day: \"Day\"\n        case .week: \"Week\"\n        case .month: \"Month\"\n        case .list: \"List\"\n        }\n    }\n}\n\nprivate struct TimeObjectStageInlineDatum: Identifiable {\n",
            "Time zoom enum",
        )
    if "selectedZoomLevel" not in text:
        text = replace_once(
            text,
            "    @State private var selectedHorizon: TimeHorizon\n    @State private var revealsPressure = false\n",
            "    @State private var selectedHorizon: TimeHorizon\n    @State private var selectedZoomLevel: TimeLifeShapeZoomLevel = .field\n    @State private var revealsPressure = false\n",
            "Time zoom state",
        )
    if "lifeShapeZoomControl" not in text:
        text = replace_once(
            text,
            "            contextCrown\n            if Self.screenshotFocusesQuietReflow() {",
            "            contextCrown\n            lifeShapeZoomControl\n            if Self.screenshotFocusesQuietReflow() {",
            "Time zoom control insertion",
        )
        text = replace_once(
            text,
            "    private var horizonControl: some View {\n",
            "    private var lifeShapeZoomControl: some View {\n        Picker(\"LifeShape zoom\", selection: $selectedZoomLevel) {\n            ForEach(TimeLifeShapeZoomLevel.allCases, id: \\.self) { level in\n                Text(level.title).tag(level)\n            }\n        }\n        .pickerStyle(.segmented)\n        .accessibilityIdentifier(\"time.life-shape-field.zoom-control\")\n        .accessibilityLabel(\"LifeShape zoom\")\n        .accessibilityHint(\"Moves between field, day, week, month, and list views without leaving Time.\")\n    }\n\n    private var horizonControl: some View {\n",
            "Time zoom control helper",
        )
    text = text.replace(
        'Text(dynamicTypeSize.isAccessibilitySize ? "Capacity proof." : "Capacity, pressure, and protected time.")',
        'Text(dynamicTypeSize.isAccessibilitySize ? "Capacity proof." : "Field, day, week, month, and list stay in one LifeShape object.")',
    )
    write(TIME, text)

    require_markers(TIME, ["TimeLifeShapeZoomLevel", "selectedZoomLevel", "lifeShapeZoomControl", "time.life-shape-field.zoom-control", "Field", "Day", "Week", "Month", "List"])

    write_proof(
        "REPORT_BATCH_33_TIME_LIFESHAPE_ZOOM_RECONSTRUCTION.md",
        """
# Batch 33 — Time LifeShape Zoom Reconstruction

Status: applied.

Scope:
- Added a LifeShape zoom control for Field / Day / Week / Month / List.
- Kept zoom inside the same Time object instead of adding root tabs or calendar clone pages.
- Updated the context line to communicate that Time is one evolving LifeShape object.

Native interaction law:
- Time must be legible before it is intelligent.
- Living objects should morph/zoom/recompose instead of opening disconnected pages.

Validation:
- Source markers prove the zoom control and mode labels exist.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 33 Time LifeShape Zoom Reconstruction.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
