import Foundation
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
