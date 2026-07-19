struct MotionObjectStagePrimitiveContract: Equatable {
    let primitiveID: String
    let ownerSurface: String
    let productObject: String
    let firstViewportStructure: String
    let replacesFirstViewportStructures: [String]
    let sourceTrustLineOrder: [String]
    let accessibilityFallbacks: [String]
    let screenshotIdentifier: String
    let firstViewportAvoidsAnalyticsReportCardDashboardOutput: Bool
    let reservesTabBarClearance: Bool

    static let current = MotionObjectStagePrimitiveContract(
        primitiveID: "stage-motion-current",
        ownerSurface: "Stage Motion",
        productObject: "Stage Motion",
        firstViewportStructure: "Stage Motion behavior with changed object, change state, return point, recovery, and undo.",
        replacesFirstViewportStructures: [
            "rounded standalone movement panel",
            "path cards",
            "path state row panels",
            "history pills",
            "object review panel",
        ],
        sourceTrustLineOrder: [
            "changed object",
            "change state",
            "return point",
            "available action",
        ],
        accessibilityFallbacks: [
            "VoiceOver names the changed object before recovery, return, and available action",
            "Dynamic Type keeps changed object, state, and return point in order",
            "Reduce Motion uses static movement marks",
            "Increase Contrast strengthens rules and left-thread markers rather than restoring panels",
            "Differentiate Without Color exposes changed object, change state, return point, and action as text",
        ],
        screenshotIdentifier: "StageMotionCurrent",
        firstViewportAvoidsAnalyticsReportCardDashboardOutput: true,
        reservesTabBarClearance: false
    )
}
