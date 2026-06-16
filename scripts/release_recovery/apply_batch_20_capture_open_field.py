#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, replace_all, require_markers, write, write_proof

SHELL = "Native/Ambitions/App/AppShellView.swift"
CAPTURE = "Native/Ambitions/Features/Capture/CaptureScreen.swift"
MODEL = "Native/Ambitions/Features/Capture/CapturePresentationModels.swift"

MODEL_SWIFT = r'''
import Foundation

/// Typed global Capture presentation contract.
///
/// Capture is global input and placement, not a root tab. Root shell code can use
/// this as the single route language for Open Field, placement, and clarification
/// flows without inventing a sixth destination.
enum CapturePresentation: Identifiable, Hashable, Sendable {
    case openField(seed: String?, source: CaptureEntrySource)
    case placement(heldObjectID: String)
    case clarification(heldObjectID: String)

    var id: String {
        switch self {
        case let .openField(seed, source):
            "open-field-\(source.rawValue)-\(seed ?? "empty")"
        case let .placement(heldObjectID):
            "placement-\(heldObjectID)"
        case let .clarification(heldObjectID):
            "clarification-\(heldObjectID)"
        }
    }
}

enum CaptureEntrySource: String, Sendable {
    case shellHeader
    case commandSheet
    case today
    case shortcut
    case url
}
'''


def main() -> int:
    write(MODEL, MODEL_SWIFT)

    shell = read(SHELL)
    shell = replace_all(shell, {
        "Capture Anything": "Open Field",
        "receipt before save": "saved before placement",
        "Route reveal": "Suggested path",
        "route reveal": "suggested path",
        "Local receipt": "Saved on this iPhone",
        "local receipt": "saved on this iPhone",
        "Use keyboard mic": "Use the keyboard microphone",
        "Mic": "Dictate",
    })
    write(SHELL, shell)

    capture = read(CAPTURE)
    capture = replace_all(capture, {
        "Capture Anything": "Open Field",
        "Capture anything": "Open Field",
        "Route reveal": "Suggested path",
        "route reveal": "suggested path",
        "Local receipt": "Saved on this iPhone",
        "local receipt": "saved on this iPhone",
        "Grow into Goal": "Open as Goal",
        "Grow into goal": "Open as goal",
        "Held for Review": "Hold for Later",
        "Held for review": "Hold for later",
    })
    write(CAPTURE, capture)

    require_markers(MODEL, ["CapturePresentation", "openField", "CaptureEntrySource", "shellHeader"])
    require_markers(SHELL, ["Open Field"])
    require_markers(CAPTURE, ["Open Field"])
    write_proof(
        "REPORT_BATCH_20_CAPTURE_OPEN_FIELD.md",
        """
# Batch 20 — Capture Open Field / Placement Field

Status: applied.

Scope:
- Added a typed CapturePresentation route contract for global Open Field / Placement / Clarification presentation.
- Preserved Capture as global input, not a root tab.
- Replaced first-pass capture copy toward Open Field, Suggested path, and saved-on-device language.
- Clarified dictation as keyboard microphone focus rather than Ambitions audio recording.

Atlas gates:
- Capture remains global action/layer.
- Capture is not a tab.
- Open Field is the primary global intake posture.
- Held Object placement is the route model for future deeper implementation.
""",
    )
    print("Applied Batch 20 Capture Open Field / Placement Field.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
