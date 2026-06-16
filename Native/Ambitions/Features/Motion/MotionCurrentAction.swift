
import Foundation

/// Typed Motion action contract.
///
/// Motion is proof/progress/inspection, not analytics and not a passive ledger.
/// Root shell routing can map these actions to Today, Goals, Time, Trust, receipt,
/// or proof-detail destinations without adding a sixth tab.
enum MotionCurrentAction: Equatable, Hashable, Sendable {
    case inspectProof(String?)
    case openReceipt(String?)
    case openThread(String?)
    case openToday
    case openGoals
    case openTime
    case openTrust
}
