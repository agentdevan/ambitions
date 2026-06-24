import Foundation

enum CopyExposureLevel: Int, CaseIterable, Comparable {
    case primary
    case contextual
    case inspectionOnly
    case `internal`

    static func < (lhs: CopyExposureLevel, rhs: CopyExposureLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum ForbiddenTopLevelTerms {
    struct Rule: Equatable {
        let term: String
        let minimumAllowedExposure: CopyExposureLevel
    }

    static let rules: [Rule] = [
        Rule(term: "Plan tab", minimumAllowedExposure: .internal),
        Rule(term: "Plan screen", minimumAllowedExposure: .internal),
        Rule(term: "top-level Plan", minimumAllowedExposure: .internal),
        Rule(term: "Profile tab", minimumAllowedExposure: .internal),
        Rule(term: "Capture tab", minimumAllowedExposure: .internal),
        Rule(term: "Motion tab", minimumAllowedExposure: .internal),
        Rule(term: "Captures tab", minimumAllowedExposure: .internal),
        Rule(term: "next best move", minimumAllowedExposure: .internal),
        Rule(term: "best next move", minimumAllowedExposure: .internal),
        Rule(term: "Begin Focus", minimumAllowedExposure: .internal),
        Rule(term: "AI confidence", minimumAllowedExposure: .internal),
        Rule(term: "productivity score", minimumAllowedExposure: .internal),
        Rule(term: "debug console", minimumAllowedExposure: .internal),
        Rule(term: "runtime-backed", minimumAllowedExposure: .internal),
        Rule(term: "fixture-only", minimumAllowedExposure: .internal),
        Rule(term: "route reveal", minimumAllowedExposure: .internal),
        Rule(term: "receipt before save", minimumAllowedExposure: .internal),
        Rule(term: "proof seam", minimumAllowedExposure: .internal),
        Rule(term: "open seam", minimumAllowedExposure: .internal),
        Rule(term: "local projection", minimumAllowedExposure: .internal),
        Rule(term: "mutation pipeline", minimumAllowedExposure: .internal),
        Rule(term: "source unavailable", minimumAllowedExposure: .inspectionOnly),
        Rule(term: "review before reflow", minimumAllowedExposure: .internal),
        Rule(term: "ready before change", minimumAllowedExposure: .internal),
        Rule(term: "blocked-pending-model", minimumAllowedExposure: .internal),
        Rule(term: "correction-shaped ledger", minimumAllowedExposure: .internal),
        Rule(term: "Motion Current", minimumAllowedExposure: .internal),
        Rule(term: "Capture Anything", minimumAllowedExposure: .internal),
        Rule(term: "Close Today", minimumAllowedExposure: .internal)
    ]

    static var terms: [String] {
        rules.map(\.term)
    }

    static func firstViolation(
        in text: String,
        exposure: CopyExposureLevel = .primary
    ) -> String? {
        let lowercased = text.lowercased()
        return rules.first { rule in
            exposure < rule.minimumAllowedExposure &&
            lowercased.contains(rule.term.lowercased())
        }?.term
    }
}
