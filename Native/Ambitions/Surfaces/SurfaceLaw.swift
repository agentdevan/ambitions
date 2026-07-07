import Foundation

enum SurfaceLaw {
    static let rootSurfaces: [AmbitionsSurface] = [.today, .goals, .time, .you]
    static let blockedRootRawValues: Set<String> = [
        "capture",
        "captures",
        "motion",
        "plan",
        "profile",
        "source",
        "proof",
        "privacy",
        "history",
        "receipts"
    ]

    static func rootSurfaceIssues(for contracts: [AmbitionsSurfaceContract]) -> [String] {
        var issues: [String] = []
        if contracts.map(\.tab) != rootSurfaces {
            issues.append("Surface contracts must follow Today, Goals, Time, You.")
        }
        for contract in contracts {
            if blockedRootRawValues.contains(contract.tab.rawValue) {
                issues.append("\(contract.title) is not allowed as a persistent root surface.")
            }
            if contract.primaryObject != SurfacePrimaryObject.primary(for: contract.tab) {
                issues.append("\(contract.title) must own \(SurfacePrimaryObject.primary(for: contract.tab).rawValue), not \(contract.primaryObjectTitle).")
            }
            if contract.actionContract.isComplete == false {
                issues.append("\(contract.title) must route primary action through mutation, announcement, and proof.")
            }
            if contract.disclosureContract.satisfiesRootLaw == false {
                issues.append("\(contract.title) must keep trust detail inspectable without overloading the root.")
            }
        }
        return issues
    }
}
