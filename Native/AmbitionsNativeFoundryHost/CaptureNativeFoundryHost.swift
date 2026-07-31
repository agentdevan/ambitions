import AmbitionsNativeVisualFoundry
import SwiftUI

enum CaptureNativeFoundryVariant: String {
    case origin = "cnc-capture-origin-dark"
    case entryFocused = "cnc-capture-entry-focused-dark"
    case boundedMeaning = "cnc-capture-bounded-meaning-dark"
    case clarification = "cnc-capture-clarification-dark"
    case review = "cnc-capture-review-dark"
    case recovery = "cnc-capture-recovery-dark"
    case accessibilityReviewTop = "cnc-capture-review-accessibility-top-dark"
    case accessibilityReviewAction = "cnc-capture-review-accessibility-action-dark"

    static var fromProcessArguments: CaptureNativeFoundryVariant? {
        let arguments = ProcessInfo.processInfo.arguments
        for flag in ["-FoundryVariant", "-FoundryJourney"] {
            guard
                let flagIndex = arguments.firstIndex(of: flag),
                arguments.indices.contains(flagIndex + 1),
                let variant = CaptureNativeFoundryVariant(rawValue: arguments[flagIndex + 1])
            else {
                continue
            }
            return variant
        }
        return nil
    }

    var dynamicTypeSize: DynamicTypeSize {
        switch self {
        case .accessibilityReviewTop, .accessibilityReviewAction:
            .accessibility2
        default:
            .large
        }
    }
}

struct CaptureNativeFoundryHost: View {
    private let fixture = CaptureNativeCalibrationFixture.flagship
    @State private var state = CaptureNativeCalibrationJourneyState()
    @State private var didActivateVariant = false

    let variant: CaptureNativeFoundryVariant

    var body: some View {
        CaptureNativeCalibrationView(
            fixture: fixture,
            state: $state
        )
        .preferredColorScheme(.dark)
        .dynamicTypeSize(variant.dynamicTypeSize)
        .environment(\.locale, Locale(identifier: "en_US"))
        .environment(\.layoutDirection, LayoutDirection.leftToRight)
        .task {
            await activateVariantIfNeeded()
        }
    }

    @MainActor
    private func activateVariantIfNeeded() async {
        guard didActivateVariant == false else { return }
        didActivateVariant = true

        switch variant {
        case .origin:
            return
        case .entryFocused:
            _ = state.presentCapture()
        case .boundedMeaning:
            _ = state.presentCapture(
                expression: CaptureNativeCalibrationFixture.primaryExpression
            )
            _ = state.continueExpression(using: fixture)
        case .clarification:
            _ = state.presentCapture(
                expression: CaptureNativeCalibrationFixture.ambiguousExpression
            )
            _ = state.continueExpression(using: fixture)
            state.updateClarificationResponse(
                CaptureNativeCalibrationFixture.clarificationAnswer
            )
        case .review, .accessibilityReviewTop, .accessibilityReviewAction:
            _ = state.presentCapture(
                expression: CaptureNativeCalibrationFixture.primaryExpression
            )
            _ = state.continueExpression(using: fixture)
            await allowPresentationToSettle()
            _ = state.openReview(using: fixture)
        case .recovery:
            _ = state.presentCapture(
                expression: CaptureNativeCalibrationFixture.primaryExpression
            )
            _ = state.continueExpression(using: fixture)
            state.showRecovery()
        }
    }

    @MainActor
    private func allowPresentationToSettle() async {
        try? await Task.sleep(for: .milliseconds(500))
    }
}
