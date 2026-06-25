import Foundation

struct GoalsObjectStagePrimitiveContract: Equatable {
    let primitiveID: String
    let ownerSurface: String
    let productObject: String
    let stageName: String
    let firstViewportStructure: String
    let replacesFirstViewportStructures: [String]
    let sourceTrustLineOrder: [String]
    let accessibilityFallbacks: [String]
    let screenshotIdentifier: String
    let avoidsGenericGoalRootOutput: Bool
    let reservesTabBarClearance: Bool

    static let current = GoalsObjectStagePrimitiveContract(
        primitiveID: "goals-object-stage",
        ownerSurface: "Goals",
        productObject: "Constellation Atlas + Orbital Lens",
        stageName: "Constellation Atlas",
        firstViewportStructure: "Full-bleed Constellation Atlas object stage with life-area nodes, thread focus, step chain, Today connection, and review held inside the object.",
        replacesFirstViewportStructures: [
            "rounded equal-weight area band",
            "rounded Direction Atlas container",
            "rounded Constellation Atlas container",
            "rounded relationship field shell",
            "rounded Orbital Lens container",
            "rounded Atlas lane blocks",
            "separate review disclosure strip",
        ],
        sourceTrustLineOrder: [
            "life area",
            "goal thread",
            "step chain",
            "Today link",
        ],
        accessibilityFallbacks: [
            "VoiceOver names Your Direction before life area, thread, step chain, Today, and review controls",
            "Dynamic Type preserves Constellation Atlas title, life area order, thread order, and Today link order",
            "Reduce Motion keeps the Constellation Atlas relationship field static",
            "Increase Contrast strengthens object-stage rules and relationship markers",
            "Differentiate Without Color exposes life area, goal thread, step chain, Today link, and review as text",
        ],
        screenshotIdentifier: "GoalsObjectStage",
        avoidsGenericGoalRootOutput: true,
        reservesTabBarClearance: true
    )
}

enum GoalsLens: SurfaceLens {
    static let contract = SurfaceLensContract(
        surface: .goals,
        surfaceTitle: "Goals",
        primaryObjectTitle: "Constellation Atlas",
        primaryActionTitle: "Open step",
        runtimeInputs: [
            "life areas",
            "goal threads",
            "active step chains",
            "pinned goals",
            "milestones",
            "Today relationships",
        ],
        firstViewportContract: "Constellation Atlas owns goal threads, life areas, Today links, reason, and history as a native goal field.",
        accessibilityContract: objectStageContract.accessibilityFallbacks,
        trustInspectionRequirements: ["source", "proof", "receipt", "Today link"],
        failureStateRequirements: ["empty goals", "missing context", "blocked thread", "recovery review"]
    )

    static let objectStageContract = GoalsObjectStagePrimitiveContract.current

    static func project(_ overview: GoalsOverview) -> GoalsStageScene {
        makeStageScene(for: overview)
    }

    static func makeStageScene(for overview: GoalsOverview) -> GoalsStageScene {
        GoalsStageScene(
            surface: .goals,
            productObject: objectStageContract.productObject,
            stageName: objectStageContract.stageName,
            firstViewportStructure: objectStageContract.firstViewportStructure,
            sourceTrustLineOrder: objectStageContract.sourceTrustLineOrder,
            todayRelationshipSummary: overview.constellationAtlasYouSummaryForProjection,
            inspectionSummary: overview.constellationAtlasFirstViewportTrustSummary,
            accessibilityFallbacks: objectStageContract.accessibilityFallbacks
        )
    }
}
