import Foundation

enum ForbiddenTopLevelTerms {
    static let terms: [String] = [
        "Plan tab",
        "Plan screen",
        "Profile tab",
        "Capture tab",
        "Motion tab",
        "Captures tab",
        "next best move",
        "best next move",
        "Begin Focus",
        "AI confidence",
        "productivity score",
        "debug console"
    ]

    static func firstViolation(in text: String) -> String? {
        let lowercased = text.lowercased()
        return terms.first { lowercased.contains($0.lowercased()) }
    }
}

