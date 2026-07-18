import Foundation

public struct AccessibilityAutomatedNutritionGateRequirement: Identifiable, Hashable, Sendable {
    public let axis: AccessibilityAdjustmentAxis
    public let category: AccessibilityNutritionCategory
    public let ownerFile: String
    public let automatedProofTarget: String
    public let automatedEvidenceScope: String
    public let requiredFallback: String
    public let manualProofStillRequired: String
    public let deviceProofStillRequired: String
    public let verificationStatus: AccessibilityNutritionVerificationStatus
    public let publicAccessibilityClaimAllowed: Bool

    public var id: AccessibilityAdjustmentAxis { axis }

    public init(
        axis: AccessibilityAdjustmentAxis,
        category: AccessibilityNutritionCategory,
        ownerFile: String,
        automatedProofTarget: String,
        automatedEvidenceScope: String,
        requiredFallback: String,
        manualProofStillRequired: String,
        deviceProofStillRequired: String,
        verificationStatus: AccessibilityNutritionVerificationStatus = .partiallySupported,
        publicAccessibilityClaimAllowed: Bool = false
    ) {
        self.axis = axis
        self.category = category
        self.ownerFile = ownerFile
        self.automatedProofTarget = automatedProofTarget
        self.automatedEvidenceScope = automatedEvidenceScope
        self.requiredFallback = requiredFallback
        self.manualProofStillRequired = manualProofStillRequired
        self.deviceProofStillRequired = deviceProofStillRequired
        self.verificationStatus = verificationStatus
        self.publicAccessibilityClaimAllowed = publicAccessibilityClaimAllowed
    }
}

public struct AccessibilityAutomatedNutritionGate: Identifiable, Hashable, Sendable {
    public let id: String
    public let issueID: String
    public let owner: String
    public let title: String
    public let sourceTruth: [String]
    public let requirements: [AccessibilityAutomatedNutritionGateRequirement]
    public let limitations: [String]

    public init(
        id: String,
        issueID: String,
        owner: String,
        title: String,
        sourceTruth: [String],
        requirements: [AccessibilityAutomatedNutritionGateRequirement],
        limitations: [String]
    ) {
        self.id = id
        self.issueID = issueID
        self.owner = owner
        self.title = title
        self.sourceTruth = sourceTruth
        self.requirements = requirements
        self.limitations = limitations
    }

    public var coveredCategories: [AccessibilityNutritionCategory] {
        requirements.map(\.category)
    }

    public var coveredAxes: [AccessibilityAdjustmentAxis] {
        requirements.map(\.axis)
    }

    public var userFacingClaimsAllowed: Bool {
        requirements.allSatisfy(\.publicAccessibilityClaimAllowed)
    }

    public var releaseClaimsAllowed: Bool {
        userFacingClaimsAllowed && limitations.isEmpty
    }
}

public enum AMB1814AutomatedNutritionGate {
    public static let issueID = "AMB-1814"

    public static let gate = AccessibilityAutomatedNutritionGate(
        id: "amb-1814-automated-accessibility-nutrition-gate",
        issueID: issueID,
        owner: "Accessibility",
        title: "Automated accessibility nutrition gate",
        sourceTruth: [
            "docs/canon/migration/legacy-semantic-migration.json",
            "docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md",
            "Packages/AmbitionsDesignSystem/Sources/Accessibility/AccessibilityAutomatedNutritionGate.swift",
            "Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift",
            "docs/qa/accessibility/amb-1814-automated-nutrition-gate.md"
        ],
        requirements: [
            AccessibilityAutomatedNutritionGateRequirement(
                axis: .voiceOverOrder,
                category: .voiceOver,
                ownerFile: "Packages/AmbitionsDesignSystem/Sources/Accessibility/AccessibilityNutrition.swift",
                automatedProofTarget: "Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift",
                automatedEvidenceScope: "Static XCTest gate asserts labels, values, hints, grouping, reading-order ownership, and the manual traversal proof boundary.",
                requiredFallback: "Every nutrition record must name purpose, state, primary action, and manual traversal need before claim review.",
                manualProofStillRequired: "Manual VoiceOver traversal across Today, Goals, Time, You, Capture, and detail flows remains required.",
                deviceProofStillRequired: "Physical-device VoiceOver proof remains required before public accessibility claims."
            ),
            AccessibilityAutomatedNutritionGateRequirement(
                axis: .dynamicTypeLayout,
                category: .dynamicType,
                ownerFile: "Packages/AmbitionsDesignSystem/Sources/Theme/PanelDensitySize.swift",
                automatedProofTarget: "Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift",
                automatedEvidenceScope: "Static XCTest gate asserts large-text fallback ownership and the screenshot/no-clipping proof boundary.",
                requiredFallback: "Large text must preserve the primary object, state, source, and primary action before supporting detail.",
                manualProofStillRequired: "Accessibility-size screenshot and no-clipping review remains required across device bands.",
                deviceProofStillRequired: "Physical-device Dynamic Type proof remains required before public accessibility claims."
            ),
            AccessibilityAutomatedNutritionGateRequirement(
                axis: .reduceMotionEquivalent,
                category: .reduceMotion,
                ownerFile: "Packages/AmbitionsDesignSystem/Sources/Components/DynamicAdaptiveVisualPrimitives.swift",
                automatedProofTarget: "Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift",
                automatedEvidenceScope: "Static XCTest gate asserts static fallback ownership and the toggled Reduce Motion walkthrough proof boundary.",
                requiredFallback: "State changes, route transitions, completion, recovery, and reflow must preserve meaning without motion.",
                manualProofStillRequired: "A toggled Reduce Motion walkthrough remains required across top-level and motion-sensitive flows.",
                deviceProofStillRequired: "Physical-device Reduce Motion proof remains required before public accessibility claims."
            )
        ],
        limitations: [
            "AMB-1814 installs source-backed automated nutrition coverage only.",
            "No XCTest execution, UI traversal, screenshot review, or device accessibility pass is encoded by this source record.",
            "No public accessibility conformance, Visual Green, Release Green, or App Store claim is allowed from this gate."
        ]
    )

    public static var requirements: [AccessibilityAutomatedNutritionGateRequirement] {
        gate.requirements
    }

    public static var userFacingClaimsAllowed: Bool {
        gate.userFacingClaimsAllowed
    }

    public static var releaseClaimsAllowed: Bool {
        gate.releaseClaimsAllowed
    }
}
