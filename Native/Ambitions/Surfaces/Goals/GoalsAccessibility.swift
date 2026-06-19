import Foundation

enum GoalsAccessibility {
    static func rootSummary(
        atlasState: String,
        selectedThread: String?,
        todayRelationship: String,
        proofState: String
    ) -> String {
        [
            "Goals",
            "Constellation Atlas: \(atlasState)",
            selectedThread.map { "Selected thread: \($0)" },
            "Today relationship: \(todayRelationship)",
            "Proof: \(proofState)"
        ].compactMap { $0 }.filter { $0.isEmpty == false }.joined(separator: ". ")
    }
}
