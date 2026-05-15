import Foundation

public enum LivingPlanMutationImpactLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case destructive = "destructive"
}

public struct LivingPlanMutationPermission: Codable, Sendable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let explanation: String
    public let impactLevel: LivingPlanMutationImpactLevel
    public let requiresExplicitConfirmation: Bool
    public let rollbackAvailable: Bool
    public let affectedGoalIDs: [String]
    
    public init(
        id: String,
        title: String,
        explanation: String,
        impactLevel: LivingPlanMutationImpactLevel,
        requiresExplicitConfirmation: Bool,
        rollbackAvailable: Bool,
        affectedGoalIDs: [String] = []
    ) {
        self.id = id
        self.title = title
        self.explanation = explanation
        self.impactLevel = impactLevel
        self.requiresExplicitConfirmation = requiresExplicitConfirmation
        self.rollbackAvailable = rollbackAvailable
        self.affectedGoalIDs = affectedGoalIDs
    }
}
