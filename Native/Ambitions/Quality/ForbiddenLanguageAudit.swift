import Foundation

enum ForbiddenLanguageAudit {
    static func violation(in text: String) -> String? {
        SurfaceCopyPolicy.firstRootSurfaceViolation(in: text)
    }

    static func rootTimeViolation(in text: String) -> String? {
        LifeShapeFakePrecisionAudit.forbiddenRootTerms.first { term in
            text.localizedCaseInsensitiveContains(term)
        }
    }
}
