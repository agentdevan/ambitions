import Foundation

struct CapacityEngine: Sendable, Equatable {
    func capacityShape(from nowState: CanonicalNowState) -> CapacityShape {
        let pressureRank = rank(nowState.priorityPressure.capacity)
        let busyMinutes = nowState.schedulePressure.itemCount * 30
        let blockedMinutes = nowState.blockersWaiting.blockedCount * 30
        let protectedMinutes = protectedMinutes(for: nowState.recoveryState)
        let totalPlanningWindow = 240
        let openMinutes = max(0, totalPlanningWindow - busyMinutes - protectedMinutes)
        let flexibleMinutes = max(0, openMinutes - blockedMinutes)
        let pressureLevel = maxPressure([
            nowState.schedulePressure.level,
            nowState.priorityPressure.capacity,
            nowState.deadlinePressure.level
        ])

        return CapacityShape(
            openMinutes: openMinutes,
            protectedMinutes: protectedMinutes,
            blockedMinutes: blockedMinutes,
            flexibleMinutes: flexibleMinutes,
            scheduledAmbitionsMinutes: busyMinutes,
            calendarBusyMinutes: 0,
            pressureLevel: pressureLevel,
            summary: pressureRank >= rank(.elevated)
                ? "Capacity is tight; protect recovery and avoid overfilling today."
                : "Capacity can hold a focused step while keeping recovery visible."
        )
    }

    private func protectedMinutes(for recovery: NowRecoveryState) -> Int {
        switch recovery {
        case .stable:
            return 0
        case .watch:
            return 20
        case .needsRecovery, .recovering:
            return 45
        case .blocked:
            return 60
        }
    }

    private func maxPressure(_ levels: [NowPressureLevel]) -> NowPressureLevel {
        levels.max { rank($0) < rank($1) } ?? .none
    }

    private func rank(_ level: NowPressureLevel) -> Int {
        switch level {
        case .none:
            return 0
        case .low:
            return 1
        case .moderate:
            return 2
        case .elevated:
            return 3
        case .high:
            return 4
        case .critical:
            return 5
        }
    }
}
