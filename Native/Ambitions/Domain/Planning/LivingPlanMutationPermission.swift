import Foundation

/// Impact levels for plan mutations, strictly mapped to the manifest 0-5 hierarchy.
public enum LivingPlanMutationImpactLevel: Int, Codable, Sendable, Equatable, Hashable, CaseIterable {
    /// Level 0: No-op or purely visual/transient state update.
    case level0 = 0
    /// Level 1: Minor metadata or label update; non-functional.
    case level1 = 1
    /// Level 2: Additive change; new optional steps or context hints.
    case level2 = 2
    /// Level 3: Structural change; rescheduling, reordering, or parallel path addition.
    case level3 = 3
    /// Level 4: Destructive change; removal of user-created steps or significant reflow.
    case level4 = 4
    /// Level 5: Critical change; goal abandonment, privacy boundary crossing, or irrevocable deletion.
    case level5 = 5
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
