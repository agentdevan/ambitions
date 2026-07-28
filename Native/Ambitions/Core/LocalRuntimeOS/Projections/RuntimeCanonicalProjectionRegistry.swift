import Foundation

enum RuntimeCanonicalProjectionID: String, Codable, Sendable, Equatable, Hashable, CaseIterable, Comparable {
    case aggregateState = "runtime.aggregate_state"
    case search = "runtime.search"

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

enum RuntimeCanonicalProjectionRegistry {
    static let allEventTypeIDs = Set(RuntimeSemanticEventTypeID.allCases)

    static func projectionIDs(for typeID: RuntimeSemanticEventTypeID) -> [RuntimeCanonicalProjectionID] {
        let owned: Set<RuntimeCanonicalProjectionID> = [.aggregateState, .search]
        return owned.sorted()
    }

    static func validateExhaustiveOwnership() -> Bool {
        Set(RuntimeSemanticEventTypeID.allCases.filter { projectionIDs(for: $0).isEmpty == false }) == allEventTypeIDs
    }
}
