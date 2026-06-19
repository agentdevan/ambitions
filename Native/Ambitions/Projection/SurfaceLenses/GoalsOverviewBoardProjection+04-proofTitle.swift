import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func proofTitle(for evidence: ProgressEvidence) -> String {
        if let note = evidence.note?.trimmingCharacters(in: .whitespacesAndNewlines),
           note.isEmpty == false {
            return note
        }

        return switch evidence.evidenceKind {
        case .stepCompleted: "Completed step"
        case .habitCompletion: "Ritual completion"
        case .habitMinimumVersion: "Minimum version"
        case .habitQuickLog: "Quick log"
        case .sessionLogged: "Session logged"
        case .reflectionLogged: "Reflection"
        case .delegatedUpdate: "Delegated update"
        case .observationLogged: "Observation"
        case .milestoneReached: "Milestone reached"
        }
    }


    func atlasPriorityDescriptor(lhs: GoalsAtlasSurfaceState, rhs: GoalsAtlasSurfaceState) -> Bool {
        if lhs.posture != rhs.posture {
            let order: [GoalsAtlasPosture] = [.atRisk, .crowded, .stalled, .active, .lowerPriority, .achieved]
            return (order.firstIndex(of: lhs.posture) ?? order.count) < (order.firstIndex(of: rhs.posture) ?? order.count)
        }

        if lhs.manualPriorityRank != rhs.manualPriorityRank {
            return lhs.manualPriorityRank < rhs.manualPriorityRank
        }

        return lhs.progressValue > rhs.progressValue
    }


    func recentMovementDescriptor(lhs: GoalsAtlasSurfaceState, rhs: GoalsAtlasSurfaceState) -> Bool {
        if lhs.progressValue == rhs.progressValue {
            return lhs.manualPriorityRank < rhs.manualPriorityRank
        }

        return lhs.progressValue > rhs.progressValue
    }


    func boardPriorityDescriptor(lhs: GoalsBoardCardState, rhs: GoalsBoardCardState) -> Bool {
        atlasPriorityDescriptor(lhs: lhs, rhs: rhs)
    }
}
