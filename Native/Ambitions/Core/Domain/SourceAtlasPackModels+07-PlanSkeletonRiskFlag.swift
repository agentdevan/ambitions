import Foundation

struct PlanSkeletonRiskFlag: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let severity: Int
    let relatedNodeIDs: [String]
    let relatedRequirementIDs: [String]
}

struct PlanSkeleton: Codable, Sendable, Equatable, Hashable {
    let milestones: [PlanSkeletonMilestone]
    let phases: [PlanSkeletonPhase]
    let weeklyCadence: PlanSkeletonWeeklyCadence
    let proofMoments: [PlanSkeletonProofMoment]
    let reviewMoments: [PlanSkeletonReviewMoment]
    let recoveryWindows: [PlanSkeletonRecoveryWindow]
    let riskFlags: [PlanSkeletonRiskFlag]
    let feasibilityBand: PlanSkeletonFeasibilityBand
}

struct SourceAtlasPathCompositionExplanationProjection: Codable, Sendable, Equatable, Hashable {
    let summary: String
    let sourceLabels: [String]
    let whyThisChangesPlans: [String]
    let confidenceLabel: String
}

struct SourceAtlasPathTradeoff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let pathID: String
    let summary: String
    let advantages: [String]
    let drawbacks: [String]
}

struct SourceAtlasCapabilityPath: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let capabilityGraphID: String
    let selectedNodeIDs: [String]
    let selectedEdgeIDs: [String]
    let selectedPathOverlayIDs: [String]
    let selectedRoleOverlayIDs: [String]
    let traversalTrace: [String]
    let blockedNodes: [String]
    let staleNodes: [String]
    let missingSourceNodes: [String]
    let requirementProjection: SourceAtlasRequirementProjection
    let score: Double
    let pathSummary: String
    let planSkeleton: PlanSkeleton
}

struct PersonalPathComposition: Codable, Sendable, Equatable, Hashable {
    let goalID: String
    let userContextVersion: String
    let sourceAtlasProjectionID: String
    let pathInstances: [SourceAtlasCapabilityPath]
    let alternativePathSet: SourceAtlasAlternativePathSet?
    let selectedPath: SourceAtlasCapabilityPath
    let rejectedPaths: [SourceAtlasCapabilityPath]
    let pathTradeoffs: [SourceAtlasPathTradeoff]
    let explanationProjection: SourceAtlasPathCompositionExplanationProjection

    var planSkeleton: PlanSkeleton {
        selectedPath.planSkeleton
    }
}
