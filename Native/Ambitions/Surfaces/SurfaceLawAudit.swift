import Foundation

enum SurfaceLawAudit {
    static func audit(contracts: [AmbitionsSurfaceContract]) -> [String] {
        var issues = SurfaceLaw.rootSurfaceIssues(for: contracts)

        let duplicateObjects = Dictionary(grouping: contracts, by: \.primaryObjectTitle)
            .filter { $0.value.count > 1 }
            .keys
        for duplicate in duplicateObjects.sorted() {
            issues.append("Primary object \(duplicate) is assigned to multiple top-level surfaces.")
        }

        for contract in contracts where Set(contract.runtimeInspectionRequirements) != Set(AmbitionsSurfaceContractRegistry.runtimeInspectionRequirements) {
            issues.append("\(contract.title) must preserve runtime inspection requirements.")
        }

        return issues
    }
}
