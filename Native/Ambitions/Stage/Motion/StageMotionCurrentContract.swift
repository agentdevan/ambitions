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
        firstViewportStructure: "Stage Motion behavior with what changed, where to re-enter, what needs recovery, and inspectable proof relationships.",
        replacesFirstViewportStructures: [
            "rounded Motion Current field panel",
            "lane cards",
            "lane state row panels",
            "trace pills",
            "context/history/review panel"
        ],
        sourceTrustLineOrder: [
            "context",
            "history",
            "review",
            "re-entry action"
        ],
        accessibilityFallbacks: [
            "VoiceOver names Motion Current before proof, recovery, re-entry, context, history, and review relationships",
            "Dynamic Type keeps lane title, state, and trace values in order",
            "Reduce Motion uses static proof-thread marks",
            "Increase Contrast strengthens rules and left-thread markers rather than restoring panels",
            "Differentiate Without Color exposes source, proof, receipt, and re-entry as text"
        ],
        screenshotIdentifier: "StageMotionCurrent",
        firstViewportAvoidsAnalyticsReportCardDashboardOutput: true,
        reservesTabBarClearance: false
    )
}
