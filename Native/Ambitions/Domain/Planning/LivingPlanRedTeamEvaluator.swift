import Foundation

/// Dashboard models for Living Dream Intelligence, as per LDI21 manifest.
struct LivingDreamDashboardState: Codable, Sendable, Equatable {
    /// Trust indicator from 0.0 to 1.0 based on source freshness and proof density.
    let trustIndicator: Double
    /// Count of goals requiring a plan recompile due to source updates.
    let recompileNeededCount: Int
    /// Current synchronization state label (e.g., "Synced", "Local Only", "Sync Paused").
    let syncState: String
    /// Count of active red-team structural issues.
    let redTeamIssueCount: Int
    
    init(
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

struct LivingPlanRedTeamIssue: Sendable, Equatable, Identifiable {
    let id: String
    let goalID: String
    let title: String
    let summary: String
    let impactLevel: LivingPlanMutationImpactLevel
    
    init(id: String = UUID().uuidString, goalID: String, title: String, summary: String, impactLevel: LivingPlanMutationImpactLevel) {
        self.id = id
        self.goalID = goalID
        self.title = title
        self.summary = summary
        self.impactLevel = impactLevel
    }
}

struct LivingPlanRedTeamEvaluator: Sendable, Equatable {
    init() {}
    
    func evaluate(goalIDs: [String]) -> [LivingPlanRedTeamIssue] {
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
    
    func generateDashboardState(
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
