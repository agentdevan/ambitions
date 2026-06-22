import Foundation

enum GlobalShellCompletionAudit {
    static let owner = "Quality/GlobalShellCompletionAudit"
    static let rule = "Global shell completion requires every manifest route to be implemented and evidenced."

    static let requiredRoutes: [String] = [
        "today.root",
        "today.step_detail",
        "goals.root",
        "goals.goal_detail",
        "time.root",
        "time.bucket_detail",
        "you.root",
        "you.settings_detail",
        "capture.keyboard",
        "search.overlay",
        "closure.overlay",
        "inspection.proof"
    ]

    static func validationIssues(manifestText: String, artifactText: String) -> [String] {
        var issues: [String] = []
        for route in requiredRoutes {
            if manifestText.contains(route) == false {
                issues.append("Missing global shell manifest route: \(route).")
            }
            if artifactText.contains(route) == false {
                issues.append("Missing global shell artifact route: \(route).")
            }
        }
        return issues
    }
}
