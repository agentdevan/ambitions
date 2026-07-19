import Foundation

enum SurfaceLaw {
    static let rootSurfaces: [AmbitionsSurface] = [.today, .goals, .time, .you]
    static let blockedRootRawValues: Set<String> = [
        "activity",
        "activity-feed",
        "ai",
        "analytics",
        "assistant",
        "capture",
        "captures",
        "chatbot",
        "dashboard",
        "dashboards",
        "feed",
        "habit",
        "habits",
        "insights",
        "kpi",
        "motion",
        "plan",
        "profile",
        "productivity",
        "score",
        "source",
        "proof",
        "privacy",
        "history",
        "receipts",
        "streak",
        "task",
        "task-board",
        "taskboard",
        "tasks"
    ]

    static let rootArchetypeDriftTerms: [String] = [
        "activity feed",
        "AI assistant",
        "AI wrapper",
        "analytics dashboard",
        "chatbot",
        "dashboard",
        "habit ring",
        "habit tracker",
        "KPI",
        "life score",
        "productivity score",
        "streak",
        "task board",
        "task dashboard",
        "task manager"
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
            let rootGrammar = [
                contract.tab.rawValue,
                contract.title,
                contract.primaryObjectTitle
            ].joined(separator: " ")
            for term in rootArchetypeDriftTerms where rootGrammar.localizedCaseInsensitiveContains(term) {
                issues.append("\(contract.title) cannot use \(term) as root product grammar.")
            }
        }
        return issues
    }
}
