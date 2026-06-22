import Foundation

enum SingleOwnerAudit {
    static let owner = "Quality/SingleOwnerAudit"
    static let rule = "Visible shell concepts must have one owner."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []
        let corpus = files.map(\.contents).joined(separator: "\n")

        if corpus.contains("AppShellScaffold("),
           corpus.contains("title: \"Time\""),
           corpus.contains("subtitle: \"LifeShape Field\""),
           corpus.contains("var contextCrown") {
            findings.append(LifeShapeAuditFinding(
                id: "single-owner.duplicate-time-crown",
                path: "Time",
                detail: "Time shell crown and LifeShapeFieldView.contextCrown both own root context."
            ))
        }

        let captureOwnerCount = [
            corpus.contains("time.context-crown.capture"),
            corpus.contains("shell.header.capture"),
            corpus.contains("CaptureAccessPoint")
        ].filter { $0 }.count
        if captureOwnerCount > 1 {
            findings.append(LifeShapeAuditFinding(
                id: "single-owner.duplicate-capture-access",
                path: "Time",
                detail: "Capture access appears in more than one first-viewport ownership path."
            ))
        }

        let searchOwnerCount = [
            corpus.contains("time.context-crown.search"),
            corpus.contains("shell.header.search"),
            corpus.contains("SearchAccessPoint")
        ].filter { $0 }.count
        if searchOwnerCount > 1 {
            findings.append(LifeShapeAuditFinding(
                id: "single-owner.duplicate-search-access",
                path: "Time",
                detail: "Search access appears in more than one first-viewport ownership path."
            ))
        }

        return LifeShapeAuditReport(findings: findings)
    }
}
