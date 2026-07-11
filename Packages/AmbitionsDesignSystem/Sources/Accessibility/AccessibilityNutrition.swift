import Foundation

public enum AccessibilityNutritionCategory: String, CaseIterable, Identifiable, Sendable {
    case dynamicType
    case voiceOver
    case reduceMotion
    case contrast
    case colorNotOnlyMeaning
    case tapTargetSize
    case gestureAlternatives
    case keyboardAndFocusSupport
    case errorRecovery
    case cognitiveLoad
    case oneHandedUsability
    case plainLanguageLabels
    case noShameOrGuiltStates
    case privacyTrustClarity
    case verifiedUserFacingClaims

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .dynamicType: "Dynamic Type"
        case .voiceOver: "VoiceOver"
        case .reduceMotion: "Reduce Motion"
        case .contrast: "Contrast"
        case .colorNotOnlyMeaning: "Color-not-only meaning"
        case .tapTargetSize: "Tap target size"
        case .gestureAlternatives: "Gesture alternatives"
        case .keyboardAndFocusSupport: "Keyboard and focus support"
        case .errorRecovery: "Error recovery"
        case .cognitiveLoad: "Cognitive load"
        case .oneHandedUsability: "One-handed usability"
        case .plainLanguageLabels: "Plain-language labels"
        case .noShameOrGuiltStates: "No shame or guilt states"
        case .privacyTrustClarity: "Privacy and trust clarity"
        case .verifiedUserFacingClaims: "Verified user-facing claims"
        }
    }

    public var verificationGuidance: String {
        switch self {
        case .dynamicType:
            "Verify large accessibility text sizes do not clip content, hide primary actions, or collapse the main decision hierarchy."
        case .voiceOver:
            "Verify labels, values, hints, grouping, and reading order communicate each panel's purpose, state, and primary action."
        case .reduceMotion:
            "Verify state changes, route transitions, completion, and recovery remain understandable when Reduce Motion is enabled."
        case .contrast:
            "Verify dark and light mode text, borders, disabled states, and semantic states meet contrast expectations."
        case .colorNotOnlyMeaning:
            "Verify every status uses text, icon, shape, position, or pattern in addition to color."
        case .tapTargetSize:
            "Verify primary and repeated controls meet comfortable iPhone hit-area expectations and avoid cramped destructive adjacency."
        case .gestureAlternatives:
            "Verify every swipe, drag, long press, scrub, or precision gesture has a visible button or menu alternative."
        case .keyboardAndFocusSupport:
            "Verify text entry, forms, sheets, and any hardware-keyboard-relevant controls preserve logical focus order and visible focus."
        case .errorRecovery:
            "Verify error, denied-permission, empty, unresolved, and degraded states include a clear next step or safe escape."
        case .cognitiveLoad:
            "Verify top-level screens preserve one dominant decision and keep audit, history, and explanation density behind disclosure."
        case .oneHandedUsability:
            "Verify frequent Today, Capture, Time, and recovery actions remain reachable without precision stretching."
        case .plainLanguageLabels:
            "Verify user-visible and assistive labels avoid internal model terms and describe the useful outcome plainly."
        case .noShameOrGuiltStates:
            "Verify disrupted, delayed, reduced, stuck, and recovery states use calm adult language without blame or streak pressure."
        case .privacyTrustClarity:
            "Verify intelligent recommendations, calendar-derived context, memory, sync, and export/import copy name their data basis and limits."
        case .verifiedUserFacingClaims:
            "Verify any user-facing accessibility statement names the tested scope, date or version, limitations, and evidence status."
        }
    }

    public var requiresNonColorSupport: Bool {
        switch self {
        case .colorNotOnlyMeaning, .contrast, .errorRecovery, .privacyTrustClarity, .verifiedUserFacingClaims:
            true
        case .dynamicType, .voiceOver, .reduceMotion, .tapTargetSize, .gestureAlternatives, .keyboardAndFocusSupport, .cognitiveLoad, .oneHandedUsability, .plainLanguageLabels, .noShameOrGuiltStates:
            true
        }
    }
}

public enum AccessibilityNutritionVerificationStatus: String, CaseIterable, Identifiable, Sendable {
    case verified
    case partiallySupported
    case unverified
    case notApplicable

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .verified: "Verified"
        case .partiallySupported: "Partially supported"
        case .unverified: "Unverified"
        case .notApplicable: "Not applicable"
        }
    }

    public var isUserFacingClaimAllowed: Bool {
        self == .verified
    }
}

public struct AccessibilityNutritionItem: Identifiable, Hashable, Sendable {
    public let category: AccessibilityNutritionCategory
    public let defaultStatus: AccessibilityNutritionVerificationStatus
    public let verificationGuidance: String
    public let requiresNonColorSupport: Bool

    public var id: AccessibilityNutritionCategory { category }
    public var label: String { category.label }

    public init(
        category: AccessibilityNutritionCategory,
        defaultStatus: AccessibilityNutritionVerificationStatus = .unverified,
        verificationGuidance: String? = nil,
        requiresNonColorSupport: Bool? = nil
    ) {
        self.category = category
        self.defaultStatus = defaultStatus
        self.verificationGuidance = verificationGuidance ?? category.verificationGuidance
        self.requiresNonColorSupport = requiresNonColorSupport ?? category.requiresNonColorSupport
    }
}

public struct AccessibilityNutritionAuditDescriptor: Identifiable, Hashable, Sendable {
    public let id: String
    public let screenName: String
    public let route: String
    public let owner: String
    public let checklist: [AccessibilityNutritionItem]

    public init(
        id: String,
        screenName: String,
        route: String,
        owner: String,
        checklist: [AccessibilityNutritionItem] = AccessibilityNutritionChecklist.items
    ) {
        self.id = id
        self.screenName = screenName
        self.route = route
        self.owner = owner
        self.checklist = checklist
    }
}

public struct AccessibilityNutritionSummaryItem: Identifiable, Hashable, Sendable {
    public let category: AccessibilityNutritionCategory
    public let status: AccessibilityNutritionVerificationStatus
    public let detail: String

    public var id: AccessibilityNutritionCategory { category }
    public var label: String { category.label }
    public var canPublishAsUserFacingClaim: Bool { status.isUserFacingClaimAllowed }

    public init(
        category: AccessibilityNutritionCategory,
        status: AccessibilityNutritionVerificationStatus,
        detail: String
    ) {
        self.category = category
        self.status = status
        self.detail = detail
    }
}

public enum AccessibilityNutritionEvidenceKind: String, CaseIterable, Identifiable, Sendable {
    case designCanon
    case sourceInspection
    case automatedTest
    case manualVerificationRequired

    public var id: String { rawValue }
}

public struct AccessibilityNutritionEvidenceAnchor: Identifiable, Hashable, Sendable {
    public let kind: AccessibilityNutritionEvidenceKind
    public let path: String
    public let note: String

    public var id: String { "\(kind.rawValue):\(path):\(note)" }

    public init(kind: AccessibilityNutritionEvidenceKind, path: String, note: String) {
        self.kind = kind
        self.path = path
        self.note = note
    }
}

public enum AccessibilityAdjustmentAxis: String, CaseIterable, Identifiable, Sendable {
    case dynamicTypeLayout
    case voiceOverOrder
    case reduceMotionEquivalent

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .dynamicTypeLayout: "Dynamic Type layout"
        case .voiceOverOrder: "VoiceOver order"
        case .reduceMotionEquivalent: "Reduce Motion equivalent"
        }
    }

    public var claimBoundary: String {
        switch self {
        case .dynamicTypeLayout:
            "Source and automated evidence only; no screenshot/no-clipping claim."
        case .voiceOverOrder:
            "Source and automated evidence only; no manual VoiceOver traversal claim."
        case .reduceMotionEquivalent:
            "Source and automated evidence only; no toggled walkthrough claim."
        }
    }
}

public struct AccessibilityAdjustmentEvidenceRequirement: Identifiable, Hashable, Sendable {
    public let axis: AccessibilityAdjustmentAxis
    public let ownerFile: String
    public let automatedProofTarget: String
    public let requiredFallback: String
    public let manualProofStillRequired: String
    public let nonColorMeaningRequired: Bool
    public let userFacingClaimAllowed: Bool

    public var id: AccessibilityAdjustmentAxis { axis }

    public init(
        axis: AccessibilityAdjustmentAxis,
        ownerFile: String,
        automatedProofTarget: String,
        requiredFallback: String,
        manualProofStillRequired: String,
        nonColorMeaningRequired: Bool = true,
        userFacingClaimAllowed: Bool = false
    ) {
        self.axis = axis
        self.ownerFile = ownerFile
        self.automatedProofTarget = automatedProofTarget
        self.requiredFallback = requiredFallback
        self.manualProofStillRequired = manualProofStillRequired
        self.nonColorMeaningRequired = nonColorMeaningRequired
        self.userFacingClaimAllowed = userFacingClaimAllowed
    }
}

public enum EB27AccessibilityAdjustmentEvidence {
    public static let ownerBatch = "EB27"

    public static let sourceTruth: [String] = [
        "docs/canon/Ambitions_4_0_Accessibility_And_Cognitive_Load_Kernel.md",
        "docs/codex/batches/EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt.md",
        "Packages/AmbitionsDesignSystem/Sources/Accessibility/AccessibilityNutrition.swift",
        "Packages/AmbitionsDesignSystem/Sources/Theme/PanelDensitySize.swift",
        "Packages/AmbitionsDesignSystem/Sources/Components/DynamicAdaptiveVisualPrimitives.swift"
    ]

    public static let requirements: [AccessibilityAdjustmentEvidenceRequirement] = [
        AccessibilityAdjustmentEvidenceRequirement(
            axis: .dynamicTypeLayout,
            ownerFile: "Packages/AmbitionsDesignSystem/Sources/Theme/PanelDensitySize.swift",
            automatedProofTarget: "Native/AmbitionsTests/App/PanelDensitySizeDesignSystemTests.swift",
            requiredFallback: "Accessibility text sizes force lower density and keep the primary decision visible.",
            manualProofStillRequired: "Accessibility-size screenshots and no-clipping review remain required before public claims."
        ),
        AccessibilityAdjustmentEvidenceRequirement(
            axis: .voiceOverOrder,
            ownerFile: "Packages/AmbitionsDesignSystem/Sources/Accessibility/AccessibilityNutrition.swift",
            automatedProofTarget: "Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift",
            requiredFallback: "Every screen evidence record must name purpose, state, primary action, and manual traversal need.",
            manualProofStillRequired: "Manual VoiceOver traversal across top-level and detail surfaces remains required before public claims."
        ),
        AccessibilityAdjustmentEvidenceRequirement(
            axis: .reduceMotionEquivalent,
            ownerFile: "Packages/AmbitionsDesignSystem/Sources/Components/DynamicAdaptiveVisualPrimitives.swift",
            automatedProofTarget: "Native/AmbitionsTests/App/PanelDensitySizeDesignSystemTests.swift",
            requiredFallback: "Reduced Motion must preserve meaning through static state, text, icon, disclosure, or opacity fallback.",
            manualProofStillRequired: "A toggled Reduce Motion walkthrough remains required before public claims."
        )
    ]

    public static var userFacingClaimsAllowed: Bool {
        requirements.allSatisfy(\.userFacingClaimAllowed)
    }
}

public enum AccessibilityPlainLanguageAxis: String, CaseIterable, Identifiable, Sendable {
    case plainLanguageCopy
    case anxietySafeRecovery
    case screenExplanation

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .plainLanguageCopy: "Plain-language copy"
        case .anxietySafeRecovery: "Anxiety-safe recovery"
        case .screenExplanation: "Explain this screen"
        }
    }
}

public struct AccessibilityPlainLanguageRequirement: Identifiable, Hashable, Sendable {
    public let axis: AccessibilityPlainLanguageAxis
    public let ownerFile: String
    public let automatedProofTarget: String
    public let requiredPattern: String
    public let forbiddenPattern: String
    public let userFacingBehaviorChanged: Bool
    public let releaseClaimAllowed: Bool

    public var id: AccessibilityPlainLanguageAxis { axis }

    public init(
        axis: AccessibilityPlainLanguageAxis,
        ownerFile: String,
        automatedProofTarget: String,
        requiredPattern: String,
        forbiddenPattern: String,
        userFacingBehaviorChanged: Bool = false,
        releaseClaimAllowed: Bool = false
    ) {
        self.axis = axis
        self.ownerFile = ownerFile
        self.automatedProofTarget = automatedProofTarget
        self.requiredPattern = requiredPattern
        self.forbiddenPattern = forbiddenPattern
        self.userFacingBehaviorChanged = userFacingBehaviorChanged
        self.releaseClaimAllowed = releaseClaimAllowed
    }
}
