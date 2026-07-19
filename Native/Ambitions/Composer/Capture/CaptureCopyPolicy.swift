import Foundation

enum CaptureCopyPolicy {
    static let forbiddenTerms = [
        "ticket",
        "workflow",
        "AI",
        "assistant",
        "guilt",
        "shame",
        "streak",
        "score",
    ]

    static func violations(in copy: String) -> [String] {
        forbiddenTerms.filter { term in
            copy.range(of: term, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }

    static func primaryDisplayLabel(_ rawValue: String) -> String {
        rawValue
            .replacingOccurrences(of: "Needs a Place", with: "Review first")
            .replacingOccurrences(of: "Needs placement", with: "Needs review")
            .replacingOccurrences(of: "Unplaced capture", with: "Capture draft")
            .replacingOccurrences(of: "Unplaced item", with: "Not tied yet")
            .replacingOccurrences(of: "Unresolved start", with: "Time not set")
            .replacingOccurrences(of: "No safe destination yet", with: "No destination has been chosen yet")
            .replacingOccurrences(of: "Held in Review first", with: "Held for review")
            .replacingOccurrences(of: "Saved to Review first", with: "Saved for review")
            .replacingOccurrences(of: "Save to Review first", with: "Save for review")
            .replacingOccurrences(of: "route", with: "placement")
    }
}
