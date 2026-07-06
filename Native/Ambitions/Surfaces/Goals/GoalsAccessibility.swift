import Foundation

enum GoalsAccessibility {
    static func rootSummary(regions: [GoalsLifeAreaAtlasRegion]) -> String {
        let active = regions.filter(\.hasActivity).map(\.title)
        let defaultAreas = regions.filter { $0.isOpenField == false }.map(\.title).joined(separator: ", ")
        let activeSummary = active.isEmpty ? "No active area yet." : "Active areas: \(active.joined(separator: ", "))."
        return "Goals. Life Areas: \(defaultAreas). \(activeSummary) Open Field is available."
    }

    static func rootSummary(
        atlasState: String,
        selectedThread: String?,
        todayRelationship: String,
        proofState: String
    ) -> String {
        [
            "Goals",
            "Life Area Atlas: \(atlasState)",
            selectedThread.map { "Selected thread: \($0)" },
            "Today relationship: \(todayRelationship)",
            "Proof: \(proofState)"
        ].compactMap { $0 }.filter { $0.isEmpty == false }.joined(separator: ". ")
    }
}
