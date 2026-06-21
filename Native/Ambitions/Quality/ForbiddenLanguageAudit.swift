import Foundation

enum ForbiddenLanguageAudit {
    static func violation(in text: String) -> String? {
        SurfaceCopyPolicy.firstRootSurfaceViolation(in: text)
    }
}
