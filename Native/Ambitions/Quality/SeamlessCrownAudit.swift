import Foundation

enum SeamlessCrownAudit {
    static let owner = "Quality/SeamlessCrownAudit"
    static let rule = "Context Crown must be single-owner, functional, and integrated into the active surface."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        let corpus = files.map(\.contents).joined(separator: "\n")
        if corpus.contains("AppShellScaffold(") && corpus.contains("var contextCrown") {
            findings.append(LifeShapeAuditFinding(id: "seamless-crown.duplicate-owner", path: "Shell", detail: "Shell scaffold and surface/object source both appear to own a root crown."))
        }
        for file in files where file.path.contains("Header") || file.path.contains("Crown") || file.path.contains("Scaffold") {
            if file.contents.contains("divider") && file.contents.contains("header") {
                findings.append(LifeShapeAuditFinding(id: "seamless-crown.header-divider", path: file.path, detail: "Crown/header divider pattern must not visually split the root stage."))
            }
        }
        return LifeShapeAuditReport(findings: findings)
    }
}
