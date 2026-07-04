import Foundation

extension StepImpactSimulation {

    static func feasibilityBand(
        sourceStepIsExecutable: Bool,
        deadlineDaysRemaining: Int?,
        estimatedMinutes: Int,
        goalContribution: Double,
        deadlineContribution: Double,
        futurePressureImpact: Double,
        opportunityCost: Double,
        openCapacityWindowCount: Int,
        protectedCapacityWindowCount: Int,
        rejectionHistoryCount: Int,
        protectedTimeThreat: Bool,
        requiresDeadlineReview: Bool,
        requiresScopeReview: Bool
    ) -> FeasibilityBand {
        guard sourceStepIsExecutable else {
            return .impossibleUnderCurrentConstraints
        }

        let capacitySupport = Double(max(0, openCapacityWindowCount)) * 0.08
        let protectedPenalty = protectedCapacityWindowCount > 0 && openCapacityWindowCount == 0 ? 0.22 : 0
        let rejectionPenalty = min(0.16, Double(rejectionHistoryCount) * 0.04)
        let deadlineUrgencyPenalty: Double
        switch deadlineDaysRemaining {
        case .some(let days) where days <= 1:
            deadlineUrgencyPenalty = 0.16
        case .some(let days) where days <= 3:
            deadlineUrgencyPenalty = 0.1
        case .some(let days) where days <= 7:
            deadlineUrgencyPenalty = 0.05
        default:
            deadlineUrgencyPenalty = 0
        }

        let durationLoad: Double = (Double(estimatedMinutes) / 45.0) * 0.34
        let goalLoad: Double = (1 - goalContribution) * 0.18
        let deadlineLoad: Double = (1 - deadlineContribution) * 0.18
        let pressureLoad: Double = (1 - futurePressureImpact) * 0.17
        let opportunityLoad: Double = opportunityCost * 0.12
        let penaltyLoad: Double = rejectionPenalty + protectedPenalty + deadlineUrgencyPenalty
        let supportLoad: Double = capacitySupport
        let loadScore = Self.clamp(durationLoad + goalLoad + deadlineLoad + pressureLoad + opportunityLoad + penaltyLoad - supportLoad)

        if protectedTimeThreat {
            if deadlineDaysRemaining.map({ $0 <= 1 }) == true || loadScore >= 0.9 {
                return .impossibleUnderCurrentConstraints
            }
            return .atRisk
        }

        if requiresScopeReview && loadScore >= 0.78 {
            return .unrealisticWithoutChangingScopeTimeCapacity
        }

        if requiresDeadlineReview && loadScore >= 0.72 {
            return .atRisk
        }

        if loadScore >= 0.9 {
            return .impossibleUnderCurrentConstraints
        }
        if loadScore >= 0.78 {
            return .unrealisticWithoutChangingScopeTimeCapacity
        }
        if loadScore >= 0.62 {
            return .atRisk
        }
        if loadScore >= 0.38 {
            return .tightButPossible
        }
        if goalContribution >= 0.9 && deadlineContribution >= 0.82 && futurePressureImpact >= 0.72 {
            return .comfortablyOnTrack
        }
        return .onTrack
    }


    static func deadlinePressureDelta(
        kind: StepCandidateKind,
        feasibilityBand: FeasibilityBand,
        sourceStepIsExecutable: Bool,
        protectedTimeThreat: Bool,
        requiresDeadlineReview: Bool,
        requiresScopeReview: Bool,
        futurePressureImpact: Double,
        deadlineContribution: Double,
        estimatedMinutes: Int
    ) -> DeadlinePressureDelta {
        if feasibilityBand == .impossibleUnderCurrentConstraints || sourceStepIsExecutable == false {
            return .impossible
        }
        if protectedTimeThreat {
            return .threatensProtectedTime
        }
        if requiresScopeReview && feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity {
            return .requiresScopeReview
        }
        if requiresDeadlineReview {
            return .requiresDeadlineReview
        }
        if kind == .lighter || kind == .shorter || kind == .lowerEnergy {
            if futurePressureImpact < 0.7 || deadlineContribution < 0.72 || estimatedMinutes >= 20 {
                return .compressed
            }
        }
        if feasibilityBand == .atRisk || feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity {
            return .delayed
        }
        return .preserved
    }


    static func estimatedDelayDays(
        deadlineDaysRemaining: Int?,
        feasibilityBand: FeasibilityBand,
        deadlinePressureDelta: DeadlinePressureDelta
    ) -> Int? {
        guard deadlinePressureDelta == .delayed || feasibilityBand == .atRisk || feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity || feasibilityBand == .impossibleUnderCurrentConstraints else {
            return nil
        }
        if let deadlineDaysRemaining {
            return max(1, min(7, deadlineDaysRemaining / 2 + 1))
        }
        return deadlinePressureDelta == .impossible ? nil : 2
    }


    static func estimatedMinutesSaved(
        kind: StepCandidateKind,
        estimatedMinutes: Int,
        deadlinePressureDelta: DeadlinePressureDelta
    ) -> Int? {
        guard deadlinePressureDelta == .compressed else {
            return nil
        }
        switch kind {
        case .lighter:
            return max(1, estimatedMinutes / 4)
        case .shorter:
            return max(1, estimatedMinutes / 2)
        case .lowerEnergy:
            return max(1, estimatedMinutes / 5)
        default:
            return max(1, estimatedMinutes / 6)
        }
    }


    static func deadlineDays(from generatedAt: Date, to deadlineDate: Date) -> Int {
        let interval = deadlineDate.timeIntervalSince(generatedAt)
        return Int((interval / 86_400).rounded(.down))
    }
}
