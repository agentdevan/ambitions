#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APP = ROOT / "Native" / "Ambitions" / "App"
TESTS = ROOT / "Native" / "AmbitionsTests" / "App"
OUT = ROOT / "artifacts" / "object-stage-mega-train" / "reconciliation"
OUT.mkdir(parents=True, exist_ok=True)

policy_path = APP / "AppShellSensoryFeedbackPolicy.swift"
policy_path.write_text(
    """import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum AppShellSensoryFeedbackIntent: String, CaseIterable, Sendable {
    case surfaceSelection
    case headerAction
    case captureActivation
    case overlayDismissal

    var accessibilityDescription: String {
        switch self {
        case .surfaceSelection: "Surface changed"
        case .headerAction: "Shell action activated"
        case .captureActivation: "Capture opened"
        case .overlayDismissal: "Overlay dismissed"
        }
    }
}

enum AppShellSensoryFeedbackPolicy {
    static func shouldEmitFeedback(reduceMotionEnabled: Bool) -> Bool {
        reduceMotionEnabled == false
    }

    @MainActor
    static func emit(_ intent: AppShellSensoryFeedbackIntent, reduceMotionEnabled: Bool) {
        guard shouldEmitFeedback(reduceMotionEnabled: reduceMotionEnabled) else { return }
        #if canImport(UIKit)
        switch intent {
        case .surfaceSelection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .headerAction:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .captureActivation:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .overlayDismissal:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        #endif
    }
}
""",
    encoding="utf-8",
)

meridian_path = APP / "AppMeridianShell.swift"
meridian = meridian_path.read_text(encoding="utf-8")
meridian = meridian.replace(
    "struct AppMeridianDestinationRail: View {\n    @Environment(\\.dynamicTypeSize) private var dynamicTypeSize",
    "struct AppMeridianDestinationRail: View {\n    @Environment(\\.dynamicTypeSize) private var dynamicTypeSize\n    @Environment(\\.accessibilityReduceMotion) private var reduceMotion",
)
meridian = meridian.replace(
    "        return Button {\n            onSelect(destination.tab)\n        } label: {",
    "        return Button {\n            if destination.tab != selectedTab {\n                AppShellSensoryFeedbackPolicy.emit(.surfaceSelection, reduceMotionEnabled: reduceMotion)\n            }\n            onSelect(destination.tab)\n        } label: {",
)
meridian_path.write_text(meridian, encoding="utf-8")

shell_path = APP / "AppShellView.swift"
shell = shell_path.read_text(encoding="utf-8")
shell = shell.replace(
    "private struct AppShellHeaderRail: View {\n    @Environment(\\.ambitionTheme) private var theme\n    @Environment(\\.dynamicTypeSize) private var dynamicTypeSize",
    "private struct AppShellHeaderRail: View {\n    @Environment(\\.ambitionTheme) private var theme\n    @Environment(\\.dynamicTypeSize) private var dynamicTypeSize\n    @Environment(\\.accessibilityReduceMotion) private var reduceMotion",
)
shell = shell.replace(
    "        Button(action: button.action) {\n            Label(button.title, systemImage: button.systemImage)\n        }",
    "        Button {\n            AppShellSensoryFeedbackPolicy.emit(.headerAction, reduceMotionEnabled: reduceMotion)\n            button.action()\n        } label: {\n            Label(button.title, systemImage: button.systemImage)\n        }",
)
shell = shell.replace(
    "        let base = Button(action: button.action) {\n            Label(button.title, systemImage: button.systemImage)",
    "        let base = Button {\n            AppShellSensoryFeedbackPolicy.emit(.headerAction, reduceMotionEnabled: reduceMotion)\n            button.action()\n        } label: {\n            Label(button.title, systemImage: button.systemImage)",
)
shell_path.write_text(shell, encoding="utf-8")

test_path = TESTS / "AppShellSensoryFeedbackPolicyTests.swift"
test_path.write_text(
    """import XCTest
@testable import Ambitions

final class AppShellSensoryFeedbackPolicyTests: XCTestCase {
    func testShellFeedbackPolicyDefinesSharedIntentSet() {
        XCTAssertEqual(
            Set(AppShellSensoryFeedbackIntent.allCases),
            [.surfaceSelection, .headerAction, .captureActivation, .overlayDismissal]
        )
    }

    func testReduceMotionDisablesShellFeedbackEmission() {
        XCTAssertTrue(AppShellSensoryFeedbackPolicy.shouldEmitFeedback(reduceMotionEnabled: false))
        XCTAssertFalse(AppShellSensoryFeedbackPolicy.shouldEmitFeedback(reduceMotionEnabled: true))
    }

    func testFeedbackIntentsHaveAccessibleDescriptions() {
        for intent in AppShellSensoryFeedbackIntent.allCases {
            XCTAssertFalse(intent.accessibilityDescription.isEmpty)
        }
    }
}
""",
    encoding="utf-8",
)

report = """# AMB-AOM-07 Shell Visual Foundation Replay

Status: `GREEN_REPLAY_SOURCE_DELTA`

This replay closes the AMB-AOM-07 Yellow by adding a shared shell sensory feedback policy and wiring it into shell interactions.

## Source changes

- `Native/Ambitions/App/AppShellSensoryFeedbackPolicy.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/AmbitionsTests/App/AppShellSensoryFeedbackPolicyTests.swift`

## Scope result

- Four-surface shell remains unchanged.
- Bottom rail emits shared surface-selection feedback.
- Header actions emit shared shell-action feedback.
- Reduce Motion disables shell feedback emission.
- Feedback intents expose accessible descriptions for equivalent non-haptic semantics.

## Next gate

Proceed to AMB-AOM-08 Today blocker validation.
"""
(OUT / "AMB-AOM-07-shell-visual-replay.md").write_text(report, encoding="utf-8")
print("AMB-AOM-07 shell sensory feedback replay written.")
