import Foundation

struct CapacityShape: Codable, Sendable, Equatable, Hashable {
    let openMinutes: Int
    let protectedMinutes: Int
    let blockedMinutes: Int
    let flexibleMinutes: Int
    let scheduledAmbitionsMinutes: Int
    let calendarBusyMinutes: Int
    let pressureLevel: NowPressureLevel
    let summary: String

    var hasBreathingRoom: Bool {
        openMinutes > max(protectedMinutes + blockedMinutes, 0)
    }
}

struct CapacityEstimate: Codable, Sendable, Equatable, Hashable {
    let openMinutes: Int
    let totalOpenMinutes: Int
    let protectedMinutes: Int
    let vacationAwayMinutes: Int
    let blockedBusyMinutes: Int
    let blockedMinutes: Int
    let flexibleMinutes: Int
    let scheduledAmbitionsMinutes: Int
    let calendarBusyMinutes: Int
    let timeFitProofSummary: String
    let deadlineFitProofSummary: String
    let capacityLevel: NowPressureLevel
    let summary: String
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification

    var shape: CapacityShape {
        CapacityShape(
            openMinutes: openMinutes,
            protectedMinutes: protectedMinutes,
            blockedMinutes: blockedMinutes,
            flexibleMinutes: flexibleMinutes,
            scheduledAmbitionsMinutes: scheduledAmbitionsMinutes,
            calendarBusyMinutes: calendarBusyMinutes,
            pressureLevel: capacityLevel,
            summary: summary
        )
    }
}
