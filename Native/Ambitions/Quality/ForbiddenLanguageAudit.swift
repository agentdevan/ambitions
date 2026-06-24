import Foundation

enum ForbiddenLanguageAudit {
    static func violation(
        in text: String,
        exposure: CopyExposureLevel = .primary
    ) -> String? {
        SurfaceCopyPolicy.firstRootSurfaceViolation(in: text, exposure: exposure)
    }

    static func rootTimeViolation(in text: String) -> String? {
        LifeShapeFakePrecisionAudit.forbiddenRootTerms.first { term in
            text.localizedCaseInsensitiveContains(term)
        }
    }
}
