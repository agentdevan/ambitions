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
            "Verify error, denied-permission, empty, failed, and degraded states include a clear next step or safe escape."
        case .cognitiveLoad:
            "Verify top-level screens preserve one dominant decision and move audit, history, and explanation density behind disclosure."
        case .oneHandedUsability:
            "Verify frequent Today, Capture, Plan, and recovery actions remain reachable without precision stretching."
        case .plainLanguageLabels:
            "Verify user-visible and assistive labels avoid internal model terms and describe the useful outcome plainly."
        case .noShameOrGuiltStates:
            "Verify missed, delayed, reduced, stuck, and recovery states use calm adult language without blame or streak pressure."
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

public enum AccessibilityNutritionChecklist {
    public static let items: [AccessibilityNutritionItem] = AccessibilityNutritionCategory.allCases.map {
        AccessibilityNutritionItem(category: $0)
    }

    public static func item(for category: AccessibilityNutritionCategory) -> AccessibilityNutritionItem? {
        items.first { $0.category == category }
    }

    public static func screenAuditDescriptor(
        id: String,
        screenName: String,
        route: String,
        owner: String
    ) -> AccessibilityNutritionAuditDescriptor {
        AccessibilityNutritionAuditDescriptor(
            id: id,
            screenName: screenName,
            route: route,
            owner: owner,
            checklist: items
        )
    }

    public static func unverifiedUserSummary() -> [AccessibilityNutritionSummaryItem] {
        items.map {
            AccessibilityNutritionSummaryItem(
                category: $0.category,
                status: $0.defaultStatus,
                detail: "Not yet verified for user-facing Accessibility Nutrition Facts."
            )
        }
    }
}
