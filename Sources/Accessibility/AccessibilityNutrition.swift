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

public enum EB28PlainLanguageExplanationEvidence {
    public static let ownerBatch = "EB28"

    public static let sourceTruth: [String] = [
        "docs/canon/Ambitions_4_0_Accessibility_And_Cognitive_Load_Kernel.md",
        "docs/canon/PXOS_Copy_Language_And_Explanation_System.md",
        "docs/canon/Ambitions_3_0_Product_Language_System.md",
        "docs/codex/batches/EB28_Plain_Language_Anxiety_Safe_Copy_And_Explain_This_Screen_Prompt.md"
    ]

    public static let requirements: [AccessibilityPlainLanguageRequirement] = [
        AccessibilityPlainLanguageRequirement(
            axis: .plainLanguageCopy,
            ownerFile: "docs/canon/PXOS_Copy_Language_And_Explanation_System.md",
            automatedProofTarget: "Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift",
            requiredPattern: "Use Start here, Recommended step, Adjust plan, Why this?, and Based on... labels.",
            forbiddenPattern: "No model jargon, confidence scores, generic dashboards, hustle copy, or fake certainty."
        ),
        AccessibilityPlainLanguageRequirement(
            axis: .anxietySafeRecovery,
            ownerFile: "docs/canon/PXOS_Accessibility_Cognitive_Load_And_Emotional_Safety.md",
            automatedProofTarget: "Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift",
            requiredPattern: "Treat disrupted plans as recoverable reality states with a clear next action.",
            forbiddenPattern: "No guilt, shame, streak pressure, blame, or character judgment."
        ),
        AccessibilityPlainLanguageRequirement(
            axis: .screenExplanation,
            ownerFile: "Native/Ambitions/Domain/ScreenContractModels.swift",
            automatedProofTarget: "Native/AmbitionsTests/App/ScreenContractRegistryTests.swift",
            requiredPattern: "Explain purpose, source, state, consequence, and user control without a defensive essay.",
            forbiddenPattern: "No hidden automation, no AI-performance display, and no unsupported implementation claim."
        )
    ]

    public static var changesUserFacingBehavior: Bool {
        requirements.contains(where: \.userFacingBehaviorChanged)
    }

    public static var releaseClaimsAllowed: Bool {
        requirements.allSatisfy(\.releaseClaimAllowed)
    }
}

public enum AccessibilityInputAlternativeAxis: String, CaseIterable, Identifiable, Sendable {
    case voiceFirstCapture
    case motorAlternative
    case gestureAlternative

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .voiceFirstCapture: "Voice-first capture"
        case .motorAlternative: "Motor alternative"
        case .gestureAlternative: "Gesture alternative"
        }
    }
}

public struct AccessibilityInputAlternativeRequirement: Identifiable, Hashable, Sendable {
    public let axis: AccessibilityInputAlternativeAxis
    public let ownerFile: String
    public let automatedProofTarget: String
    public let requiredAlternative: String
    public let privacyBoundary: String
    public let requiresVisibleControl: Bool
    public let changesCaptureBehavior: Bool
    public let releaseClaimAllowed: Bool

    public var id: AccessibilityInputAlternativeAxis { axis }

    public init(
        axis: AccessibilityInputAlternativeAxis,
        ownerFile: String,
        automatedProofTarget: String,
        requiredAlternative: String,
        privacyBoundary: String,
        requiresVisibleControl: Bool = true,
        changesCaptureBehavior: Bool = false,
        releaseClaimAllowed: Bool = false
    ) {
        self.axis = axis
        self.ownerFile = ownerFile
        self.automatedProofTarget = automatedProofTarget
        self.requiredAlternative = requiredAlternative
        self.privacyBoundary = privacyBoundary
        self.requiresVisibleControl = requiresVisibleControl
        self.changesCaptureBehavior = changesCaptureBehavior
        self.releaseClaimAllowed = releaseClaimAllowed
    }
}

public enum EB29InputAlternativeEvidence {
    public static let ownerBatch = "EB29"

    public static let sourceTruth: [String] = [
        "docs/canon/Ambitions_4_0_Accessibility_And_Cognitive_Load_Kernel.md",
        "docs/codex/batches/EB29_Voice_First_Operation_And_Motor_Accessibility_Prompt.md",
        "docs/canon/PXOS_Accessibility_Cognitive_Load_And_Emotional_Safety.md",
        "Native/Ambitions/Features/Captures/CapturesScreen.swift"
    ]

    public static let requirements: [AccessibilityInputAlternativeRequirement] = [
        AccessibilityInputAlternativeRequirement(
            axis: .voiceFirstCapture,
            ownerFile: "Native/Ambitions/Features/Captures/CapturesScreen.swift",
            automatedProofTarget: "Native/AmbitionsTests/Captures/CapturesViewModelTests.swift",
            requiredAlternative: "Voice capture must have visible review, edit, place, and cancel controls before any routing or memory effect.",
            privacyBoundary: "No transcript, recording, or sensitive capture is stored or routed without user-visible review."
        ),
        AccessibilityInputAlternativeRequirement(
            axis: .motorAlternative,
            ownerFile: "Sources/Accessibility/AccessibilityNutrition.swift",
            automatedProofTarget: "Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift",
            requiredAlternative: "Every precision, drag, swipe, or long-press path needs a button, menu, or row alternative.",
            privacyBoundary: "Motor alternatives must not expose extra private context or create hidden automation."
        ),
        AccessibilityInputAlternativeRequirement(
            axis: .gestureAlternative,
            ownerFile: "Sources/Components/GroupedNavigationList.swift",
            automatedProofTarget: "Native/AmbitionsTests/App/GroupedNavigationListDesignSystemTests.swift",
            requiredAlternative: "Disclosure and navigation rows need stable labels, hit areas, and non-gesture activation.",
            privacyBoundary: "Navigation alternatives must preserve the same destination and privacy-safe label."
        )
    ]

    public static var changesCaptureBehavior: Bool {
        requirements.contains(where: \.changesCaptureBehavior)
    }

    public static var releaseClaimsAllowed: Bool {
        requirements.allSatisfy(\.releaseClaimAllowed)
    }
}

public enum AccessibilityOverloadAdaptationAxis: String, CaseIterable, Identifiable, Sendable {
    case overloadedToday
    case overloadedPlan
    case lowLoadRecovery

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .overloadedToday: "Overloaded Today"
        case .overloadedPlan: "Overloaded Plan"
        case .lowLoadRecovery: "Low-load recovery"
        }
    }
}

public struct AccessibilityOverloadAdaptationRequirement: Identifiable, Hashable, Sendable {
    public let axis: AccessibilityOverloadAdaptationAxis
    public let ownerFile: String
    public let automatedProofTarget: String
    public let requiredAdaptation: String
    public let forbiddenAdaptation: String
    public let requiresUserControl: Bool
    public let changesTodayOrPlanBehavior: Bool
    public let releaseClaimAllowed: Bool

    public var id: AccessibilityOverloadAdaptationAxis { axis }

    public init(
        axis: AccessibilityOverloadAdaptationAxis,
        ownerFile: String,
        automatedProofTarget: String,
        requiredAdaptation: String,
        forbiddenAdaptation: String,
        requiresUserControl: Bool = true,
        changesTodayOrPlanBehavior: Bool = false,
        releaseClaimAllowed: Bool = false
    ) {
        self.axis = axis
        self.ownerFile = ownerFile
        self.automatedProofTarget = automatedProofTarget
        self.requiredAdaptation = requiredAdaptation
        self.forbiddenAdaptation = forbiddenAdaptation
        self.requiresUserControl = requiresUserControl
        self.changesTodayOrPlanBehavior = changesTodayOrPlanBehavior
        self.releaseClaimAllowed = releaseClaimAllowed
    }
}

public enum EB30OverloadAdaptationEvidence {
    public static let ownerBatch = "EB30"

    public static let sourceTruth: [String] = [
        "docs/canon/Ambitions_4_0_Accessibility_And_Cognitive_Load_Kernel.md",
        "docs/codex/batches/EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt.md",
        "Sources/Theme/PanelDensitySize.swift",
        "Native/Ambitions/Features/Today/TodayScreen.swift",
        "Native/Ambitions/Features/Plan/PlanScreen.swift"
    ]

    public static let requirements: [AccessibilityOverloadAdaptationRequirement] = [
        AccessibilityOverloadAdaptationRequirement(
            axis: .overloadedToday,
            ownerFile: "Native/Ambitions/Features/Today/TodayScreen.swift",
            automatedProofTarget: "Native/AmbitionsTests/Today/TodayViewModelTests.swift",
            requiredAdaptation: "Overloaded Today must reduce visible choices to one clear next action plus visible lighten, move, or recover controls.",
            forbiddenAdaptation: "No shame copy, red backlog pileup, hidden rescheduling, or dashboard-style overload stack."
        ),
        AccessibilityOverloadAdaptationRequirement(
            axis: .overloadedPlan,
            ownerFile: "Native/Ambitions/Features/Plan/PlanScreen.swift",
            automatedProofTarget: "Native/AmbitionsTests/Plan/PlanFeatureServiceTests.swift",
            requiredAdaptation: "Overloaded Plan must explain pressure in plain language and preserve user-approved adjustment paths.",
            forbiddenAdaptation: "No automatic calendar mutation, impossible-week optimism, or guilt framing."
        ),
        AccessibilityOverloadAdaptationRequirement(
            axis: .lowLoadRecovery,
            ownerFile: "Sources/Theme/PanelDensitySize.swift",
            automatedProofTarget: "Native/AmbitionsTests/App/PanelDensitySizeDesignSystemTests.swift",
            requiredAdaptation: "Low-load recovery uses larger panels, lower density, non-color meaning, and optional detail collapsed by default.",
            forbiddenAdaptation: "No motion-only state, color-only severity, or dense explanation wall."
        )
    ]

    public static var changesTodayOrPlanBehavior: Bool {
        requirements.contains(where: \.changesTodayOrPlanBehavior)
    }

    public static var releaseClaimsAllowed: Bool {
        requirements.allSatisfy(\.releaseClaimAllowed)
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
