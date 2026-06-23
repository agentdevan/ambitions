import AmbitionsDesignSystem
import SwiftUI

enum CaptureComposerPresentationMode: Equatable, Sendable {
    case timeSupport
    case globalComposer
}

struct CaptureObjectStagePrimitiveContract: Equatable {
    let primitiveID: String
    let ownerSurface: String
    let productObject: String
    let stageName: String
    let screenshotIdentifier: String
    let sourceRouteOrder: [String]
    let replacesStructures: [String]
    let forbiddenRootPatterns: [String]
    let accessibilityFallbacks: [String]
    let keepsCaptureGlobalAction: Bool

    static let current = CaptureObjectStagePrimitiveContract(
        primitiveID: "capture-route-ribbon",
        ownerSurface: "Global Capture",
        productObject: "Atmosphere Composer",
        stageName: "Capture Object Stage",
        screenshotIdentifier: "CaptureObjectStage",
        sourceRouteOrder: [
            "field-first input",
            "suggested path",
            "placement shelf",
            "placement review",
            "continuity lines"
        ],
        replacesStructures: [
            "composer panels",
            "draft-route local containers",
            "capture item cards",
            "category-like capture buckets",
            "first-run card shell"
        ],
        forbiddenRootPatterns: [
            "floating action button",
            "message-first shell",
            "raw activity stream",
            "intake matrix",
            "top-level tab"
        ],
        accessibilityFallbacks: [
            "VoiceOver reads input, suggested route, consequence, privacy, receipt, and correction choices in stage order.",
            "Dynamic Type stacks route controls before supporting route evidence.",
            "Reduce Motion uses static route-reveal state rather than motion-only meaning.",
            "Increase Contrast and Differentiate Without Color use line, symbol, and text labels in addition to accent color."
        ],
        keepsCaptureGlobalAction: true
    )
}

struct CaptureStageGroup<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    let state: LivingVisualState
    let accessibilityIdentifier: String
    let content: Content

    init(
        state: LivingVisualState,
        accessibilityIdentifier: String,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accessibilityIdentifier = accessibilityIdentifier
        self.content = content()
    }

    var body: some View {
        let accent = state == .empty ? LivingTabContext.capture.accent(in: theme) : theme.stateStyle(for: state.ambitionState).accent

        VStack(alignment: .leading, spacing: theme.spacing.md) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, theme.spacing.sm)
        .padding(.leading, theme.spacing.sm)
        .background(alignment: .leading) {
            Rectangle()
                .fill(accent.opacity(0.32))
                .frame(width: 2)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.72))
                .frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.42))
                .frame(height: 1)
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

extension CaptureComposerPresentationMode {
    var eyebrow: String {
        switch self {
        case .timeSupport: "Time support"
        case .globalComposer: "Global composer"
        }
    }

    var title: String {
        switch self {
        case .timeSupport: "Capture"
        case .globalComposer: "Capture"
        }
    }

    var subtitle: String {
        switch self {
        case .timeSupport:
            "Absorb raw inputs into the current week without turning Capture into a holding bin, raw activity stream, or classification board."
        case .globalComposer:
            "The field stays calm until a thought is ready to place, grow into a goal, or stay in Needs placement."
        }
    }
}
