import Foundation

enum TestStrengthAudit {
    static let owner = "Quality/TestStrengthAudit"
    static let rule = "Source-string tests cannot be the highest proof for visual or SwiftUI work."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []

        for file in files where file.path.hasSuffix("Tests.swift") {
            let contents = file.contents
            let hasSourceStringProof = contents.contains(".contains(") || contents.contains("source(")
            let hasRenderedProof = contents.contains("XCUIApplication") ||
                contents.contains("frame") ||
                contents.contains("screenshot") ||
                contents.contains("ImageAttachment") ||
                contents.contains("XCUIScreenshot")

            if hasSourceStringProof,
               hasRenderedProof == false,
               visualTestName(file.path, contents: contents) {
                findings.append(LifeShapeAuditFinding(
                    id: "test-strength.source-only-visual-proof",
                    path: file.path,
                    detail: "Visual/surface test relies on source strings without rendered UI, frame, or screenshot proof."
                ))
            }
        }

        return LifeShapeAuditReport(findings: findings)
    }

    private static func visualTestName(_ path: String, contents: String) -> Bool {
        let lowercased = "\(path)\n\(contents)".lowercased()
        return lowercased.contains("visual") ||
            lowercased.contains("swiftui") ||
            lowercased.contains("surface") ||
            lowercased.contains("lifeshapefieldview") ||
            lowercased.contains("reconstruction")
    }
}
