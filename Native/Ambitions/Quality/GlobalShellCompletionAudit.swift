import Foundation

enum GlobalShellCompletionAudit {
    static let owner = "Quality/GlobalShellCompletionAudit"
    static let rule = "Global shell completion requires manifest, reviewable artifacts, and route evidence."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        let corpus = files.map { "\($0.path)\n\($0.contents)" }.joined(separator: "\n")
        for required in [
            "docs/implementation/global_shell_full_bleed_manifest.yml",
            "docs/validation/global_shell_artifacts.json",
            "today.root",
            "goals.root",
            "time.root",
            "you.root",
            "capture.keyboard",
            "search.overlay",
            "closure.overlay",
            "inspection.proof"
        ] where corpus.contains(required) == false {
            findings.append(LifeShapeAuditFinding(
                id: "global-shell-completion.missing-\(required)",
                path: "GlobalShell",
                detail: "Global shell completion evidence is missing \(required)."
            ))
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
