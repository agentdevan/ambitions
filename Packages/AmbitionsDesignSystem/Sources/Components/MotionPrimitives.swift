#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionMotionPattern: CaseIterable, Sendable {
    case completion
    case correction
    case reschedule
    case routeChange
    case panelEntry
}

public enum AmbitionInteractionPurpose: String, CaseIterable, Sendable {
    case orientation
    case confirmation
    case uncertaintyReduction

    public var title: String {
        switch self {
        case .orientation:
            return "Orientation"
        case .confirmation:
            return "Confirmation"
        case .uncertaintyReduction:
            return "Uncertainty reduction"
        }
    }
}

public enum AmbitionHapticPolicy: Equatable, Sendable {
    case none
    case userInitiated(AmbitionTheme.HapticIntent)

    public var intent: AmbitionTheme.HapticIntent? {
        switch self {
        case .none:
            return nil
        case .userInitiated(let intent):
            return intent
        }
    }
}

public enum AmbitionInteractionToken: String, CaseIterable, Sendable {
    case routeOrientation
    case panelReveal
    case selectionConfirm
    case proofConfirm
    case correctionNeeded
    case sourceCheck
    case reviewRequired
    case privacyBoundary
    case unsafeRedirect
    case recompilePending
    case localOnlySettle

    public var purpose: AmbitionInteractionPurpose {
        switch self {
        case .routeOrientation, .panelReveal, .recompilePending:
            return .orientation
        case .selectionConfirm, .proofConfirm:
            return .confirmation
        case .correctionNeeded, .sourceCheck, .reviewRequired, .privacyBoundary, .unsafeRedirect, .localOnlySettle:
            return .uncertaintyReduction
        }
    }

    public var motionPattern: AmbitionMotionPattern {
        switch self {
        case .routeOrientation:
            return .routeChange
        case .panelReveal, .privacyBoundary:
            return .panelEntry
        case .selectionConfirm, .proofConfirm:
            return .completion
        case .correctionNeeded, .reviewRequired, .unsafeRedirect:
            return .correction
        case .sourceCheck, .recompilePending:
            return .reschedule
        case .localOnlySettle:
            return .panelEntry
        }
    }

    public var davMotionPreset: DAVMotionPreset {
        switch self {
        case .routeOrientation:
            return .railProgress
        case .panelReveal, .privacyBoundary:
            return .softReveal
        case .selectionConfirm, .localOnlySettle:
            return .stateSettle
        case .proofConfirm:
            return .receiptConfirmation
        case .correctionNeeded, .sourceCheck, .reviewRequired, .unsafeRedirect, .recompilePending:
            return .stateSettle
        }
    }

    public var hapticPolicy: AmbitionHapticPolicy {
        switch self {
        case .selectionConfirm:
            return .userInitiated(.selection)
        case .proofConfirm:
            return .userInitiated(.completion)
        case .routeOrientation:
            return .userInitiated(.routeChange)
        case .correctionNeeded:
            return .userInitiated(.correction)
        case .panelReveal, .sourceCheck, .reviewRequired, .privacyBoundary, .unsafeRedirect, .recompilePending, .localOnlySettle:
            return .none
        }
    }

    public var title: String {
        switch self {
        case .routeOrientation:
            return "Route orientation"
        case .panelReveal:
            return "Panel reveal"
        case .selectionConfirm:
            return "Selection confirmed"
        case .proofConfirm:
            return "Proof confirmed"
        case .correctionNeeded:
            return "Correction needed"
        case .sourceCheck:
            return "Source check"
        case .reviewRequired:
            return "Review required"
        case .privacyBoundary:
            return "Privacy boundary"
        case .unsafeRedirect:
            return "Unsafe redirect"
        case .recompilePending:
            return "Recompile pending"
        case .localOnlySettle:
            return "Local-only settle"
        }
    }

    public var reduceMotionEquivalent: String {
        switch self {
        case .routeOrientation:
            return "Immediate destination title, preserved back path, and selected row label."
        case .panelReveal:
            return "Instant panel reveal with unchanged hierarchy and status text."
        case .selectionConfirm:
            return "Static selected label, symbol, and VoiceOver value."
        case .proofConfirm:
            return "Static receipt/proof label with source and undo or correction text."
        case .correctionNeeded:
            return "Static correction label and next action without shake or reward motion."
        case .sourceCheck:
            return "Static source-state label before any commitment can move."
        case .reviewRequired:
            return "Static review label and explicit user-review affordance."
        case .privacyBoundary:
            return "Static privacy label with no private-detail reveal."
        case .unsafeRedirect:
            return "Static safety redirect label and professional-boundary copy."
        case .recompilePending:
            return "Static impact label that says review is needed before changes apply."
        case .localOnlySettle:
            return "Static local-only label and unchanged data-boundary text."
        }
    }

    public var hapticBoundary: String {
        switch self {
        case .routeOrientation:
            return "Route haptics stay user initiated and only follow an explicit orientation change."
        case .panelReveal:
            return "Panel reveal stays silent and does not use reward-style haptics."
        case .selectionConfirm:
            return "Selection haptics stay user initiated and only follow a deliberate choice."
        case .proofConfirm:
            return "Proof haptics stay user initiated and only follow a user-recorded closure or save."
        case .correctionNeeded:
            return "Correction haptics stay user initiated and never imply praise or penalty."
        case .sourceCheck:
            return "Source state stays quiet while review or freshness copy carries the meaning."
        case .reviewRequired:
            return "Review state stays quiet while the review affordance carries the meaning."
        case .privacyBoundary:
            return "Privacy boundaries stay quiet and never use haptics to disclose private content."
        case .unsafeRedirect:
            return "Unsafe redirects stay quiet and use clear boundary copy instead of feedback haptics."
        case .recompilePending:
            return "Pending changes stay quiet and wait for user review before any feedback appears."
        case .localOnlySettle:
            return "Local-only settle stays quiet and keeps the data boundary explicit in text."
        }
    }

    public var accessibilitySummary: String {
        "\(title). \(purpose.title). Reduce Motion: \(reduceMotionEquivalent) Haptics: \(hapticBoundary)"
    }

    public var allowsAutomaticHaptics: Bool {
        hapticPolicy.intent != nil
    }
}

public enum AmbitionSemanticTypographyRole: String, CaseIterable, Sendable {
    case heroDisplay
    case title
    case titleCompact
    case sectionTitle
    case bodyPrimary
    case bodyEmphasized
    case bodySecondary
    case caption
    case micro
    case numeric

    public var tokenName: String {
        rawValue
    }

    public func font(theme: AmbitionTheme) -> Font {
        switch self {
        case .heroDisplay:
            return theme.typography.heroDisplay
        case .title:
            return theme.typography.title
        case .titleCompact:
            return theme.typography.titleCompact
        case .sectionTitle:
            return theme.typography.sectionTitle
        case .bodyPrimary:
            return theme.typography.bodyPrimary
        case .bodyEmphasized:
            return theme.typography.bodyEmphasized
        case .bodySecondary:
            return theme.typography.bodySecondary
        case .caption:
            return theme.typography.caption
        case .micro:
            return theme.typography.micro
        case .numeric:
            return theme.typography.numeric
        }
    }
}

public enum AmbitionSemanticMaterialRole: String, CaseIterable, Sendable {
    case hero
    case band
    case widget
    case overlay
    case elevated
    case canvas
    case success
    case warning
    case celebration
    case quietGlass
    case graphiteRecess
    case luminousTrace

    public var tokenName: String {
        rawValue
    }
}

public struct AmbitionSemanticCausalityContext: Equatable, Sendable {
    public let sourceRecordSeamID: String
    public let receiptSeamID: String
    public let replayTraceSeamID: String
    public let whatAmbitionsKnowsSeamID: String
    public let sourceRecordLabel: String
    public let receiptLabel: String
    public let replayTraceLabel: String
    public let inspectionSurfaceLabel: String

    public init(
        sourceRecordSeamID: String,
        receiptSeamID: String,
        replayTraceSeamID: String,
        whatAmbitionsKnowsSeamID: String,
        sourceRecordLabel: String,
        receiptLabel: String,
        replayTraceLabel: String,
        inspectionSurfaceLabel: String
    ) {
        self.sourceRecordSeamID = sourceRecordSeamID
        self.receiptSeamID = receiptSeamID
        self.replayTraceSeamID = replayTraceSeamID
        self.whatAmbitionsKnowsSeamID = whatAmbitionsKnowsSeamID
        self.sourceRecordLabel = sourceRecordLabel
        self.receiptLabel = receiptLabel
        self.replayTraceLabel = replayTraceLabel
        self.inspectionSurfaceLabel = inspectionSurfaceLabel
    }

    public static let runtimeProvenanceInspection = AmbitionSemanticCausalityContext(
        sourceRecordSeamID: "SourceRecord",
        receiptSeamID: "Receipt",
        replayTraceSeamID: "ReplayTrace",
        whatAmbitionsKnowsSeamID: "Search Ambitions",
        sourceRecordLabel: "Source",
        receiptLabel: "Receipt",
        replayTraceLabel: "Reason",
        inspectionSurfaceLabel: "Search Ambitions"
    )

    public var inspectionSummary: String {
        "You / \(inspectionSurfaceLabel) can inspect \(sourceRecordLabel), \(receiptLabel), and \(replayTraceLabel)."
    }
}

public enum AmbitionSemanticCompilerInput: String, CaseIterable, Sendable {
    case startHereRecommendation
    case routeOrientation
    case proofReceipt
    case sourceFreshness
    case captureDraft
    case lifeShapeReview
    case recoveryClosure
    case privacyBoundary
    case unsafeRedirect
    case localOnlySettle
}
#endif
