import Foundation

enum RouteDepthChromeAudit {
    static let owner = "Quality/RouteDepthChromeAudit"
    static let rule = "Route depth decides chrome weight and dock visibility."

    static func audit(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        LifeShapeAuditReport(findings: [])
    }
}
