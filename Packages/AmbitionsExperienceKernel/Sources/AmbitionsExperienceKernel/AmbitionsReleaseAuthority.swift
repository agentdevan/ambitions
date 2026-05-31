import Foundation

public struct AmbitionsReleaseEvidence: Equatable, Sendable, Codable {
    public let packageLintPassed: Bool
    public let repoTruthAuditPassed: Bool
    public let xcodeBuildPassed: Bool
    public let xcodeTestsPassed: Bool
    public let screenshotMatrixCount: Int
    public let accessibilityReviewed: Bool
    public let performanceReviewed: Bool
    public let rollbackDocumented: Bool

    public init(packageLintPassed: Bool, repoTruthAuditPassed: Bool, xcodeBuildPassed: Bool, xcodeTestsPassed: Bool, screenshotMatrixCount: Int, accessibilityReviewed: Bool, performanceReviewed: Bool, rollbackDocumented: Bool) {
        self.packageLintPassed = packageLintPassed
        self.repoTruthAuditPassed = repoTruthAuditPassed
        self.xcodeBuildPassed = xcodeBuildPassed
        self.xcodeTestsPassed = xcodeTestsPassed
        self.screenshotMatrixCount = screenshotMatrixCount
        self.accessibilityReviewed = accessibilityReviewed
        self.performanceReviewed = performanceReviewed
        self.rollbackDocumented = rollbackDocumented
    }
}

public enum AmbitionsReleaseAuthority {
    public static func evaluate(_ evidence: AmbitionsReleaseEvidence) -> AmbitionsReadinessReport {
        var findings: [AmbitionsReadinessFinding] = []
        require(evidence.packageLintPassed, title: "Package lint", findings: &findings)
        require(evidence.repoTruthAuditPassed, title: "Repo truth audit", findings: &findings)
        require(evidence.xcodeBuildPassed, title: "Xcode build", findings: &findings)
        require(evidence.xcodeTestsPassed, title: "Xcode tests", findings: &findings)
        require(evidence.screenshotMatrixCount >= AmbitionsSnapshotMatrix.required.count, title: "Screenshot matrix", findings: &findings)
        require(evidence.accessibilityReviewed, title: "Accessibility review", findings: &findings)
        require(evidence.performanceReviewed, title: "Performance review", findings: &findings)
        require(evidence.rollbackDocumented, title: "Rollback documentation", findings: &findings)
        let color: AmbitionsReadinessColor = findings.isEmpty ? .green : .red
        return .init(color: color, findings: findings)
    }

    private static func require(_ condition: Bool, title: String, findings: inout [AmbitionsReadinessFinding]) {
        if !condition {
            findings.append(.init(color: .red, title: title, detail: "Required release evidence missing."))
        }
    }
}
