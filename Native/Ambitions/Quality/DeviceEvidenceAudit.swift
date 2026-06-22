import Foundation

enum DeviceEvidenceAudit {
    static let owner = "Quality/DeviceEvidenceAudit"
    static let rule = "Visual Green requires physical-device evidence."

    static func auditCloseout(_ file: LifeShapeSourceFile) -> LifeShapeAuditReport {
        let lowercased = file.contents.lowercased()
        guard lowercased.contains("visual green") || lowercased.contains("release green") else {
            return LifeShapeAuditReport(findings: [])
        }

        let hasDeviceProof = lowercased.contains("physical device") &&
            lowercased.contains("iphone") &&
            lowercased.contains("build sha")

        if hasDeviceProof {
            return LifeShapeAuditReport(findings: [])
        }

        return LifeShapeAuditReport(findings: [
            LifeShapeAuditFinding(
                id: "device-evidence.missing-for-green",
                path: file.path,
                detail: "Visual Green or Release Green claimed without physical iPhone evidence and build SHA."
            )
        ])
    }
}
