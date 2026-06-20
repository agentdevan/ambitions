import Foundation

extension LearningAnticipationService {
    func isPositiveEvidence(_ evidence: ProgressEvidence) -> Bool {
        switch evidence.evidenceKind {
        case .stepCompleted, .ritualCompletion, .ritualMinimumVersion:
            return true
        case .ritualQuickLog, .sessionLogged, .reflectionLogged, .delegatedUpdate, .observationLogged, .milestoneReached:
            return false
        }
    }

    func isFriction(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .skipped, .delayed, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
            return true
        case .completed, .edited, .tooEasy, .askedWhyThisMatters:
            return false
        }
    }

    func bucket(forTimestamp value: String) -> FocusWindowBucket? {
        guard let date = parseDate(value) else { return nil }
        return bucket(for: date)
    }

    func bucket(for date: Date) -> FocusWindowBucket {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<12:
            return .morning
        case 12..<18:
            return .afternoon
        default:
            return .evening
        }
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return DomainTimestamp.date(from: value)
    }

    func roundToTwoDecimals(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }
}
