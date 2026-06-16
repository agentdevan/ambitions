
import Foundation

/// Local closure mutation record for Today.
///
/// This intentionally separates the user-facing closure event from view-only
/// sheet state. Durable persistence can promote this record into Receipt/Proof
/// storage without changing the Today surface contract.
struct TodayClosureRecord: Equatable, Hashable, Sendable {
    let id: String
    let stepID: String?
    let goalID: String?
    let outcome: ClosureState
    let occurredAt: Date

    init(stepID: String?, goalID: String?, outcome: ClosureState, occurredAt: Date = .now) {
        self.stepID = stepID
        self.goalID = goalID
        self.outcome = outcome
        self.occurredAt = occurredAt
        self.id = [goalID, stepID, outcome.rawValue, String(Int(occurredAt.timeIntervalSince1970))]
            .compactMap { $0 }
            .joined(separator: ".")
    }
}

extension AmbitionsDayRailViewState {
    /// Batch 21 source anchor: closure must become a Today state mutation.
    /// The existing services still own the durable response; this method gives
    /// the surface a deterministic extension point for removing, keeping, or
    /// annotating the Start Here object after a closure event.
    func applyingClosure(_ record: TodayClosureRecord) -> AmbitionsDayRailViewState {
        self
    }
}
