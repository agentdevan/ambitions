import Foundation

enum TodayAccessibility {
    static func rootSummary(
        startHereTitle: String,
        meridianState: String,
        recoveryState: String,
        proofState: String
    ) -> String {
        [
            "Today",
            "Start here: \(startHereTitle)",
            "Reality Meridian: \(meridianState)",
            "Recovery: \(recoveryState)",
            "Proof: \(proofState)"
        ].filter { $0.isEmpty == false }.joined(separator: ". ")
    }
}
