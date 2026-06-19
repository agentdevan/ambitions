import Foundation

enum ForbiddenLanguageAudit {
    static func violation(in text: String) -> String? {
        ForbiddenTopLevelTerms.firstViolation(in: text)
    }
}

