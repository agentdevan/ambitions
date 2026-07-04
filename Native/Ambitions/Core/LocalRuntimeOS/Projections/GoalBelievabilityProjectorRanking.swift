import Foundation

extension GoalBelievabilityProjector {

    func rank(_ level: NowPressureLevel) -> Int {
        switch level {
        case .none: return 0
        case .low: return 1
        case .moderate: return 2
        case .elevated: return 3
        case .high: return 4
        case .critical: return 5
        }
    }


    func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}
