import Foundation

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
            requiredPattern: "Use Start here, Recommended step, Adjust shape, Why this?, and Based on... labels.",
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
        "Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift"
    ]

    public static let requirements: [AccessibilityInputAlternativeRequirement] = [
        AccessibilityInputAlternativeRequirement(
            axis: .voiceFirstCapture,
            ownerFile: "Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift",
            automatedProofTarget: "Native/AmbitionsTests/Capture/CaptureViewModelTests.swift",
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
    case overloadedTimeShape
    case lowLoadRecovery

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .overloadedToday: "Overloaded Today"
        case .overloadedTimeShape: "Overloaded Time"
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
    public let changesTodayOrTimeBehavior: Bool
    public let releaseClaimAllowed: Bool

    public var id: AccessibilityOverloadAdaptationAxis { axis }

    public init(
        axis: AccessibilityOverloadAdaptationAxis,
        ownerFile: String,
        automatedProofTarget: String,
        requiredAdaptation: String,
        forbiddenAdaptation: String,
        requiresUserControl: Bool = true,
        changesTodayOrTimeBehavior: Bool = false,
        releaseClaimAllowed: Bool = false
    ) {
        self.axis = axis
        self.ownerFile = ownerFile
        self.automatedProofTarget = automatedProofTarget
        self.requiredAdaptation = requiredAdaptation
        self.forbiddenAdaptation = forbiddenAdaptation
        self.requiresUserControl = requiresUserControl
        self.changesTodayOrTimeBehavior = changesTodayOrTimeBehavior
        self.releaseClaimAllowed = releaseClaimAllowed
    }
}

public enum EB30OverloadAdaptationEvidence {
    public static let ownerBatch = "EB30"

    public static let sourceTruth: [String] = [
        "docs/canon/Ambitions_4_0_Accessibility_And_Cognitive_Load_Kernel.md",
        "docs/codex/batches/EB30_Overloaded_Day_Adaptation_And_Low_Cognitive_Load_Flows_Prompt.md",
        "Sources/Theme/PanelDensitySize.swift",
        "Native/Ambitions/Surfaces/Today/TodaySurface.swift",
        "Native/Ambitions/Surfaces/Time/TimeSurface.swift"
    ]

    public static let requirements: [AccessibilityOverloadAdaptationRequirement] = [
        AccessibilityOverloadAdaptationRequirement(
            axis: .overloadedToday,
            ownerFile: "Native/Ambitions/Surfaces/Today/TodaySurface.swift",
            automatedProofTarget: "Native/AmbitionsTests/Today/TodayViewModelTests.swift",
            requiredAdaptation: "Overloaded Today must reduce visible choices to one clear next action plus visible lighten, move, or recover controls.",
            forbiddenAdaptation: "No shame copy, red backlog pileup, hidden rescheduling, or dashboard-style overload stack."
        ),
        AccessibilityOverloadAdaptationRequirement(
            axis: .overloadedTimeShape,
            ownerFile: "Native/Ambitions/Surfaces/Time/TimeSurface.swift",
            automatedProofTarget: "Native/AmbitionsTests/Time/TimeProjectionServiceTests.swift",
            requiredAdaptation: "Overloaded Time must explain pressure in plain language and preserve user-approved adjustment paths.",
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

    public static var changesTodayOrTimeBehavior: Bool {
        requirements.contains(where: \.changesTodayOrTimeBehavior)
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
            screenAudit("today", "Today", "tab.today", "Today", source: "Native/Ambitions/Surfaces/Today/TodaySurface.swift", tests: "Native/AmbitionsTests/Today"),
            screenAudit("reviews-archive", "Reviews / Archive", "you.reviews", "You", source: "Native/Ambitions/Services/ReviewsV1Projector.swift", tests: "Native/AmbitionsTests/Services/ReviewsV1ProjectorTests.swift"),
            screenAudit("rich-panels", "Rich Panels", "component.rich-panels", "Design System", source: "Sources/Components/RichPanelPrimitives.swift", tests: "Native/AmbitionsTests/App/RichPanelDesignSystemTests.swift"),
            screenAudit("you", "You", "tab.you", "You", source: "Native/Ambitions/Surfaces/You/YouScreen.swift", tests: "Native/AmbitionsTests/You"),
            screenAudit("grouped-navigation-list", "GroupedNavigationList", "component.grouped-navigation-list", "Design System", source: "Sources/Components/GroupedNavigationList.swift", tests: "Native/AmbitionsTests/App/GroupedNavigationListDesignSystemTests.swift"),
            screenAudit("goal-detail", "Goal Detail", "goals.detail", "Goals", source: "Native/Ambitions/Surfaces/Goals/GoalDetailScreen.swift", tests: "Native/AmbitionsTests/Goals"),
            screenAudit("capture", "Capture Composer", "overlay.capture-composer", "Composer / Capture", source: "Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift", tests: "Native/AmbitionsTests/Capture"),
            screenAudit("time", "Time", "tab.time", "Time", source: "Native/Ambitions/Surfaces/Time/TimeSurface.swift", tests: "Native/AmbitionsTests/Time"),
            screenAudit("trust-center-what-ambitions-knows", "Trust Center / What Ambitions Knows", "you.trust.memory", "You", source: "Native/Ambitions/Surfaces/You/YouScreen.swift", tests: "Native/AmbitionsTests/You/YouFeatureServiceTests.swift"),
            screenAudit("quiet-command-sheet-smart-attachment", "Quiet Command Sheet / Smart Attachment", "shell.command-sheet", "Shell / Capture", source: "Native/Ambitions/App/AppShellView.swift", tests: "Native/AmbitionsUITests/AmbitionsUITests.swift"),
            screenAudit("goals", "Goals", "tab.goals", "Goals", source: "Native/Ambitions/Surfaces/Goals/GoalsScreen.swift", tests: "Native/AmbitionsTests/Goals"),
            screenAudit("life-areas-north-stars", "Life Areas / North Stars", "goals.life-areas", "Goals", source: "Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureModels.swift", tests: "Native/AmbitionsTests/Goals"),
            screenAudit("external-surfaces", "External surfaces", "external.surfaces", "External Surfaces", source: "Native/Ambitions/ExternalSnapshots", tests: "Native/AmbitionsTests/App")
        ]
    }

    static func screenAudit(
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

    static func d21InternalSummary(screenName: String) -> [AccessibilityNutritionSummaryItem] {
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
