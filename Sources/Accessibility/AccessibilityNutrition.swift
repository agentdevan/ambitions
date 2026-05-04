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
            "Verify frequent Today, Capture, Plan, and recovery actions remain reachable without precision stretching."
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
        "Sources/Accessibility/AccessibilityNutrition.swift",
        "Sources/Theme/PanelDensitySize.swift",
        "Sources/Components/DynamicAdaptiveVisualPrimitives.swift"
    ]

    public static let requirements: [AccessibilityAdjustmentEvidenceRequirement] = [
        AccessibilityAdjustmentEvidenceRequirement(
            axis: .dynamicTypeLayout,
            ownerFile: "Sources/Theme/PanelDensitySize.swift",
            automatedProofTarget: "Native/AmbitionsTests/App/PanelDensitySizeDesignSystemTests.swift",
            requiredFallback: "Accessibility text sizes force lower density and keep the primary decision visible.",
            manualProofStillRequired: "Accessibility-size screenshots and no-clipping review remain required before public claims."
        ),
        AccessibilityAdjustmentEvidenceRequirement(
            axis: .voiceOverOrder,
            ownerFile: "Sources/Accessibility/AccessibilityNutrition.swift",
            automatedProofTarget: "Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift",
            requiredFallback: "Every screen evidence record must name purpose, state, primary action, and manual traversal need.",
            manualProofStillRequired: "Manual VoiceOver traversal across top-level and detail surfaces remains required before public claims."
        ),
        AccessibilityAdjustmentEvidenceRequirement(
            axis: .reduceMotionEquivalent,
            ownerFile: "Sources/Components/DynamicAdaptiveVisualPrimitives.swift",
            automatedProofTarget: "Native/AmbitionsTests/App/PanelDensitySizeDesignSystemTests.swift",
            requiredFallback: "Reduced Motion must preserve meaning through static state, text, icon, disclosure, or opacity fallback.",
            manualProofStillRequired: "A toggled Reduce Motion walkthrough remains required before public claims."
        )
    ]

    public static var userFacingClaimsAllowed: Bool {
        requirements.allSatisfy(\.userFacingClaimAllowed)
    }
}

public struct AccessibilityNutritionScreenAudit: Identifiable, Hashable, Sendable {
    public let id: String
    public let screenName: String
    public let route: String
    public let owner: String
    public let summary: [AccessibilityNutritionSummaryItem]
    public let evidenceAnchors: [AccessibilityNutritionEvidenceAnchor]
    public let limitations: [String]

    public var hasUserFacingClaim: Bool {
        summary.contains { $0.canPublishAsUserFacingClaim }
    }

    public init(
        id: String,
        screenName: String,
        route: String,
        owner: String,
        summary: [AccessibilityNutritionSummaryItem],
        evidenceAnchors: [AccessibilityNutritionEvidenceAnchor],
        limitations: [String]
    ) {
        self.id = id
        self.screenName = screenName
        self.route = route
        self.owner = owner
        self.summary = summary
        self.evidenceAnchors = evidenceAnchors
        self.limitations = limitations
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
                detail: "Claims locked until manual verification evidence is recorded."
            )
        }
    }

    public static func d21InternalEvidenceAudits() -> [AccessibilityNutritionScreenAudit] {
        [
            screenAudit("today", "Today", "tab.today", "Today", source: "Native/Ambitions/Features/Today/TodayScreen.swift", tests: "Native/AmbitionsTests/Today"),
            screenAudit("goals", "Goals", "tab.goals", "Goals", source: "Native/Ambitions/Features/Goals/GoalsScreen.swift", tests: "Native/AmbitionsTests/Goals"),
            screenAudit("goal-detail", "Goal Detail", "goals.detail", "Goals", source: "Native/Ambitions/Features/Goals/GoalDetailScreen.swift", tests: "Native/AmbitionsTests/Goals"),
            screenAudit("capture", "Capture", "tab.capture", "Capture", source: "Native/Ambitions/Features/Captures/CapturesScreen.swift", tests: "Native/AmbitionsTests/Captures"),
            screenAudit("plan", "Plan", "tab.plan", "Plan", source: "Native/Ambitions/Features/Plan/PlanScreen.swift", tests: "Native/AmbitionsTests/Plan"),
            screenAudit("you", "You", "tab.you", "You", source: "Native/Ambitions/Features/Profile/ProfileScreen.swift", tests: "Native/AmbitionsTests/Profile"),
            screenAudit("life-areas-north-stars", "Life Areas / North Stars", "goals.life-areas", "Goals", source: "Native/Ambitions/Features/Goals/GoalsFeatureModels.swift", tests: "Native/AmbitionsTests/Goals"),
            screenAudit("reviews-archive", "Reviews / Archive", "you.reviews", "You", source: "Native/Ambitions/Services/ReviewsV1Projector.swift", tests: "Native/AmbitionsTests/Services/ReviewsV1ProjectorTests.swift"),
            screenAudit("trust-center-what-ambitions-knows", "Trust Center / What Ambitions Knows", "you.trust.memory", "You", source: "Native/Ambitions/Features/Profile/ProfileScreen.swift", tests: "Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift"),
            screenAudit("rich-panels", "Rich Panels", "component.rich-panels", "Design System", source: "Sources/Components/RichPanelPrimitives.swift", tests: "Native/AmbitionsTests/App/RichPanelDesignSystemTests.swift"),
            screenAudit("grouped-navigation-list", "GroupedNavigationList", "component.grouped-navigation-list", "Design System", source: "Sources/Components/GroupedNavigationList.swift", tests: "Native/AmbitionsTests/App/GroupedNavigationListDesignSystemTests.swift"),
            screenAudit("quiet-command-sheet-smart-attachment", "Quiet Command Sheet / Smart Attachment", "shell.command-sheet", "Shell / Capture", source: "Native/Ambitions/App/AppShellView.swift", tests: "Native/AmbitionsUITests/AmbitionsUITests.swift"),
            screenAudit("external-surfaces", "External surfaces", "external.surfaces", "External Surfaces", source: "Native/Ambitions/ExternalSnapshots", tests: "Native/AmbitionsTests/App")
        ]
    }

    private static func screenAudit(
        _ id: String,
        _ screenName: String,
        _ route: String,
        _ owner: String,
        source: String,
        tests: String
    ) -> AccessibilityNutritionScreenAudit {
        AccessibilityNutritionScreenAudit(
            id: id,
            screenName: screenName,
            route: route,
            owner: owner,
            summary: d21InternalSummary(screenName: screenName),
            evidenceAnchors: [
                AccessibilityNutritionEvidenceAnchor(kind: .designCanon, path: "docs/canon/design/accessibility-nutrition-screen-matrix.md", note: "D21 screen/component requirement row"),
                AccessibilityNutritionEvidenceAnchor(kind: .sourceInspection, path: source, note: "D21 implementation source anchor"),
                AccessibilityNutritionEvidenceAnchor(kind: .automatedTest, path: tests, note: "D21 automated coverage anchor"),
                AccessibilityNutritionEvidenceAnchor(kind: .manualVerificationRequired, path: "docs/canon/Ambitions_2_0_Accessibility_Nutrition.md", note: "VoiceOver, Dynamic Type, Reduce Motion, contrast, and device-band proof remain required before publication")
            ],
            limitations: [
                "Internal D21 evidence only; no public Accessibility Nutrition claim is allowed from this record.",
                "Manual VoiceOver, Dynamic Type screenshot, Reduce Motion, contrast, and real-device audit evidence remain required for R01 or release publication.",
                "External surface evidence is contract-level until D22-D25 platform alignment and verification complete."
            ]
        )
    }

    private static func d21InternalSummary(screenName: String) -> [AccessibilityNutritionSummaryItem] {
        items.map { item in
            let status: AccessibilityNutritionVerificationStatus = item.category == .verifiedUserFacingClaims ? .unverified : .partiallySupported
            let detail: String
            if item.category == .verifiedUserFacingClaims {
                detail = "\(screenName) has D21 internal evidence, but user-facing accessibility claims remain locked until manual verification and R01."
            } else {
                detail = "\(screenName) has D21 internal source, design, and automated-test evidence; manual device-band verification is still required before a public claim."
            }

            return AccessibilityNutritionSummaryItem(
                category: item.category,
                status: status,
                detail: detail
            )
        }
    }
}
