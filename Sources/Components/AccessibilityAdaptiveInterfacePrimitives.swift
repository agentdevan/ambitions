#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionsAdaptiveAxis: String, CaseIterable, Identifiable, Sendable {
    case dynamicType
    case voiceOver
    case reduceMotion
    case nonColorMeaning
    case tapTarget
    case privacySafeExposure
    case cognitiveLoad

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .dynamicType: "Dynamic Type"
        case .voiceOver: "VoiceOver"
        case .reduceMotion: "Reduce Motion"
        case .nonColorMeaning: "Non-color meaning"
        case .tapTarget: "Tap target"
        case .privacySafeExposure: "Privacy-safe exposure"
        case .cognitiveLoad: "Cognitive load"
        }
    }
}

public enum AmbitionsAdaptiveReviewLane: String, CaseIterable, Identifiable, Sendable {
    case sourceReview
    case privacySensitive
    case professionalBoundary
    case crisisSupport
    case overloadedDay
    case recovery
    case emptyOrNoData

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .sourceReview: "Source review"
        case .privacySensitive: "Privacy-sensitive"
        case .professionalBoundary: "Professional boundary"
        case .crisisSupport: "Crisis support"
        case .overloadedDay: "Overloaded day"
        case .recovery: "Recovery"
        case .emptyOrNoData: "Empty or no data"
        }
    }

    public var loadingState: AmbitionsLoadingState {
        switch self {
        case .sourceReview: .sourceConflict
        case .privacySensitive: .privacySensitive
        case .professionalBoundary: .needsReview
        case .crisisSupport: .crisisSupport
        case .overloadedDay: .overwhelmingDay
        case .recovery: .recovery
        case .emptyOrNoData: .noDataYet
        }
    }

    public var statusRole: AmbitionsStatusSymbolRole {
        switch self {
        case .sourceReview: .sourceConflict
        case .privacySensitive: .privacySensitive
        case .professionalBoundary: .professionalBoundary
        case .crisisSupport: .crisisSupport
        case .overloadedDay: .pressureRising
        case .recovery: .recoveryAvailable
        case .emptyOrNoData: .noDataYet
        }
    }

    public var cognitiveLoadMode: AmbitionCognitiveLoadMode {
        switch self {
        case .sourceReview, .professionalBoundary, .privacySensitive:
            return .calm
        case .crisisSupport, .overloadedDay, .recovery:
            return .recovery
        case .emptyOrNoData:
            return .balanced
        }
    }

    public var isFutureLDIVisualHook: Bool {
        switch self {
        case .sourceReview, .privacySensitive, .professionalBoundary, .crisisSupport:
            return true
        case .overloadedDay, .recovery, .emptyOrNoData:
            return false
        }
    }
}

public struct AmbitionsAdaptiveRequirement: Identifiable, Hashable, Sendable {
    public let lane: AmbitionsAdaptiveReviewLane
    public let axis: AmbitionsAdaptiveAxis
    public let visibleFallback: String
    public let voiceOverSummary: String
    public let reduceMotionEquivalent: String
    public let manualProofStillRequired: String

    public var id: String { "\(lane.rawValue).\(axis.rawValue)" }

    public init(
        lane: AmbitionsAdaptiveReviewLane,
        axis: AmbitionsAdaptiveAxis,
        visibleFallback: String,
        voiceOverSummary: String,
        reduceMotionEquivalent: String,
        manualProofStillRequired: String
    ) {
        self.lane = lane
        self.axis = axis
        self.visibleFallback = visibleFallback
        self.voiceOverSummary = voiceOverSummary
        self.reduceMotionEquivalent = reduceMotionEquivalent
        self.manualProofStillRequired = manualProofStillRequired
    }

    public var statusRole: AmbitionsStatusSymbolRole { lane.statusRole }
    public var loadingState: AmbitionsLoadingState { lane.loadingState }
    public var cognitiveLoadMode: AmbitionCognitiveLoadMode { lane.cognitiveLoadMode }
    public var nonColorMeaningRequired: Bool { true }
    public var publicClaimAllowed: Bool { false }
    public var changesRuntimeBehavior: Bool { false }
    public var isFutureLDIVisualHook: Bool { lane.isFutureLDIVisualHook }
}

public enum SI15AccessibilityAdaptiveInterfaceReview {
    public static let ownerBatch = "SI15"
    public static let releaseClaimsAllowed = false
    public static let runtimeBehaviorChanged = false

    public static let sourceFiles: [String] = [
        "Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift",
        "Sources/Components/LoadingDegradedStatePrimitives.swift",
        "Sources/Components/IconographyStatusPrimitives.swift",
        "Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift",
        "Native/AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests.swift"
    ]

    public static let requirements: [AmbitionsAdaptiveRequirement] = {
        AmbitionsAdaptiveReviewLane.allCases.flatMap { lane in
            AmbitionsAdaptiveAxis.allCases.map { axis in
                AmbitionsAdaptiveRequirement(
                    lane: lane,
                    axis: axis,
                    visibleFallback: visibleFallback(for: axis, lane: lane),
                    voiceOverSummary: voiceOverSummary(for: axis, lane: lane),
                    reduceMotionEquivalent: lane.loadingState.reduceMotionEquivalent,
                    manualProofStillRequired: manualProof(for: axis)
                )
            }
        }
    }()

    public static func requirements(for lane: AmbitionsAdaptiveReviewLane) -> [AmbitionsAdaptiveRequirement] {
        requirements.filter { $0.lane == lane }
    }

    private static func visibleFallback(
        for axis: AmbitionsAdaptiveAxis,
        lane: AmbitionsAdaptiveReviewLane
    ) -> String {
        switch axis {
        case .dynamicType:
            return "\(lane.cognitiveLoadMode.title) density keeps the main decision visible at accessibility text sizes."
        case .voiceOver:
            return "\(lane.statusRole.title) is paired with a visible label and ordered before supporting detail."
        case .reduceMotion:
            return "Static status, label, and next action replace motion for \(lane.title)."
        case .nonColorMeaning:
            return "\(lane.statusRole.symbolName) and \(lane.statusRole.title) carry meaning without color."
        case .tapTarget:
            return "Primary review or recovery action remains a full-width native target."
        case .privacySafeExposure:
            return "Sensitive detail uses summary language before any private content is shown."
        case .cognitiveLoad:
            return "\(lane.cognitiveLoadMode.purposeLabel)"
        }
    }

    private static func voiceOverSummary(
        for axis: AmbitionsAdaptiveAxis,
        lane: AmbitionsAdaptiveReviewLane
    ) -> String {
        "\(ownerBatch). \(lane.title). \(axis.title). \(lane.statusRole.accessibilityLabel)"
    }

    private static func manualProof(for axis: AmbitionsAdaptiveAxis) -> String {
        switch axis {
        case .dynamicType:
            return "Rendered accessibility-size screenshots are still required before public claims."
        case .voiceOver:
            return "Manual VoiceOver traversal is still required before public claims."
        case .reduceMotion:
            return "A toggled Reduce Motion walkthrough is still required before public claims."
        case .nonColorMeaning:
            return "Human contrast and non-color review are still required before public claims."
        case .tapTarget:
            return "Manual tap-target and motor review are still required before public claims."
        case .privacySafeExposure:
            return "Human privacy review is still required before public claims."
        case .cognitiveLoad:
            return "Human cognitive-load review is still required before public claims."
        }
    }
}

public struct AmbitionsAdaptiveRequirementRow: View {
    @Environment(\.ambitionTheme) private var theme

    private let requirement: AmbitionsAdaptiveRequirement

    public init(_ requirement: AmbitionsAdaptiveRequirement) {
        self.requirement = requirement
    }

    public var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            AmbitionsStatusSymbol(requirement.statusRole, style: .inline)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(requirement.axis.title)
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(nil)

                Text(requirement.visibleFallback)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(nil)
            }

            Spacer(minLength: theme.spacing.sm)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.72))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(requirement.voiceOverSummary)
        .accessibilityValue("Manual proof required. \(requirement.manualProofStillRequired)")
        .accessibilityIdentifier("si15.adaptive.requirement.\(requirement.id)")
    }
}
#endif
