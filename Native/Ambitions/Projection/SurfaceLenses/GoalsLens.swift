import Foundation

struct GoalsObjectStagePrimitiveContract: Equatable, Sendable {
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
        firstViewportStructure: "Full-bleed Constellation Atlas object stage with life-area nodes, Orbital Lens focus, Today connection, and progressive trust inspection.",
        replacesFirstViewportStructures: [
            "rounded equal-weight area band",
            "rounded Direction Atlas container",
            "rounded Constellation Atlas container",
            "rounded relationship field shell",
            "rounded Orbital Lens container",
            "rounded Atlas lane blocks",
            "progressive trust disclosures"
        ],
        sourceTrustLineOrder: [
            "life area",
            "source",
            "proof",
            "receipt",
            "Today link"
        ],
        accessibilityFallbacks: [
            "VoiceOver names Your Direction before life area, Orbital Lens, life-area, thread, Today, and trust-disclosure relationships",
            "Dynamic Type preserves Constellation Atlas title, life area order, Orbital Lens order, and relationship lane order",
            "Reduce Motion keeps the Constellation Atlas relationship field static",
            "Increase Contrast strengthens object-stage rules and relationship markers",
            "Differentiate Without Color exposes life area, source, proof, receipt, and Today link as text"
        ],
        screenshotIdentifier: "GoalsObjectStage",
        avoidsGenericGoalRootOutput: true,
        reservesTabBarClearance: true
    )
}

enum GoalsLens {
    static let objectStageContract = GoalsObjectStagePrimitiveContract.current

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
