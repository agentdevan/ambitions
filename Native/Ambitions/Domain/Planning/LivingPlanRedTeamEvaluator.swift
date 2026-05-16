import Foundation

/// Dashboard models for Living Dream Intelligence, as per LDI21 manifest.
public struct LivingDreamDashboardState: Codable, Sendable, Equatable {
    /// Trust indicator from 0.0 to 1.0 based on source freshness and proof density.
    public let trustIndicator: Double
    /// Count of goals requiring a plan recompile due to source updates.
    public let recompileNeededCount: Int
    /// Current synchronization state label (e.g., "Synced", "Local Only", "Sync Paused").
    public let syncState: String
    /// Count of active red-team structural issues.
    public let redTeamIssueCount: Int
    
    public init(
        trustIndicator: Double,
        recompileNeededCount: Int,
        syncState: String,
        redTeamIssueCount: Int
    ) {
        self.trustIndicator = trustIndicator
        self.recompileNeededCount = recompileNeededCount
        self.syncState = syncState
        self.redTeamIssueCount = redTeamIssueCount
    }
}

public struct LivingPlanRedTeamIssue: Sendable, Equatable, Identifiable {
    public let id: String
    public let goalID: String
    public let title: String
    public let summary: String
    public let impactLevel: LivingPlanMutationImpactLevel
    
    public init(id: String = UUID().uuidString, goalID: String, title: String, summary: String, impactLevel: LivingPlanMutationImpactLevel) {
        self.id = id
        self.goalID = goalID
        self.title = title
        self.summary = summary
        self.impactLevel = impactLevel
    }
}

public struct LivingPlanRedTeamEvaluator: Sendable, Equatable {
    public init() {}
    
    public func evaluate(goalIDs: [String]) -> [LivingPlanRedTeamIssue] {
        guard !goalIDs.isEmpty else { return [] }
        
        return goalIDs.map { goalID in
            LivingPlanRedTeamIssue(
                goalID: goalID,
                title: "Vague Scope",
                summary: "Goal lacks explicitly defined completion boundaries.",
                impactLevel: .level3
            )
        }
    }
    
    public func generateDashboardState(
        recompileCount: Int,
        syncState: String,
        issues: [LivingPlanRedTeamIssue]
    ) -> LivingDreamDashboardState {
        // Calculate trust indicator based on issues and recompile needs
        let baseTrust = 1.0
        let penaltyPerIssue = 0.1
        let penaltyPerRecompile = 0.05
        let calculatedTrust = max(0.0, baseTrust - (Double(issues.count) * penaltyPerIssue) - (Double(recompileCount) * penaltyPerRecompile))
        
        return LivingDreamDashboardState(
            trustIndicator: calculatedTrust,
            recompileNeededCount: recompileCount,
            syncState: syncState,
            redTeamIssueCount: issues.count
        )
    }
}
