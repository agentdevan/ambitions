import Foundation

enum SurfaceCopyPolicy {
    enum Violation: Equatable {
        case forbiddenTerm(String)
        case titleTooLong(Int)
        case detailTooLong(Int)
        case unknownRootSurface(String)
    }

    static func firstRootSurfaceViolation(in text: String) -> String? {
        ForbiddenTopLevelTerms.firstViolation(in: text)
    }

    static func validateRootSurfaceCopy(
        surfaceName: String,
        title: String,
        detail: String
    ) -> [Violation] {
        var violations: [Violation] = []
        if RuntimeVocabulary.canonicalRootSurfaceSet.contains(surfaceName) == false {
            violations.append(.unknownRootSurface(surfaceName))
        }
        if let term = firstRootSurfaceViolation(in: [surfaceName, title, detail].joined(separator: " ")) {
            violations.append(.forbiddenTerm(term))
        }
        if CopyBudget.title.isExceeded(by: title) {
            violations.append(.titleTooLong(title.count))
        }
        if CopyBudget.detail.isExceeded(by: detail) {
            violations.append(.detailTooLong(detail.count))
        }
        return violations
    }
}
