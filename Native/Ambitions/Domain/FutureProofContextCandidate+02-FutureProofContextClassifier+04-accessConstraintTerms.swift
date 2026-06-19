import Foundation

extension FutureProofContextClassifier {

    static let accessConstraintTerms = [
        "trail",
        "court",
        "ymca",
        "coach approval",
        "approval",
        "gate",
        "gym"
    ]

    static func isLearningRecurringContext(extraction: CaptureSemanticExtraction, normalized: String) -> Bool {
        extraction.activity == .learning || containsAny(normalized, [
            "guitar",
            "lesson",
            "study",
            "rehearsal",
            "practice",
            "run club"
        ])
    }
}
