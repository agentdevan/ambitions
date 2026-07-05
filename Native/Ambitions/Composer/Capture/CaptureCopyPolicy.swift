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
}
