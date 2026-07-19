import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedInsightsService {
    func dailyTrendPoints(from evidence: [ProgressEvidence], feedback: [GoalFeedbackEvent], start: Date) -> [TrendPoint] {
        weightedPoints(from: evidence, feedback: feedback, start: start, positiveKinds: [.stepCompleted, .ritualCompletion, .ritualMinimumVersion], frictionWeight: 0.55)
    }

    enum PointMode {
        case standard
        case drift
        case adaptation
    }

    enum PositiveKind: Hashable {
        case stepCompleted
        case ritualCompletion
        case ritualMinimumVersion
        case askedWhyThisMattersProxy
    }

    func weightedPoints(
        from evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        start: Date,
        positiveKinds: [PositiveKind],
        frictionWeight: Double,
        mode: PointMode = .standard
    ) -> [TrendPoint] {
        (0..<7).compactMap { offset -> TrendPoint? in
            guard let day = Calendar.current.date(byAdding: .day, value: offset, to: start) else { return nil }
            let dayEvidence = evidence.filter { parseDate($0.capturedAt).map { Calendar.current.isDate($0, inSameDayAs: day) } ?? false }
            let dayFeedback = feedback.filter { parseDate($0.base.occurredAt).map { Calendar.current.isDate($0, inSameDayAs: day) } ?? false }

            let positive = dayEvidence.reduce(0.0) { partial, item in
                partial + evidenceWeight(item.evidenceKind, matching: positiveKinds, mode: mode)
            } + dayFeedback.reduce(0.0) { partial, event in
                partial + feedbackPositiveWeight(event, mode: mode)
            }

            let friction = dayFeedback.reduce(0.0) { partial, event in
                partial + (isFriction(event) ? frictionWeight : 0.0)
            }

            let normalized: Double
            switch mode {
            case .drift:
                normalized = max(0.08, min(1, (1.2 + friction - positive) / 2.4))
            case .adaptation:
                normalized = max(0.08, min(1, (0.9 + positive - (friction * 0.35)) / 1.8))
            case .standard:
                normalized = max(0.08, min(1, (1.2 + positive - friction) / 2.4))
            }

            return TrendPoint(
                id: "\(mode)-trend-\(offset)",
                label: dayLabel(for: day),
                value: normalized
            )
        }
    }

    func evidenceWeight(_ kind: ProgressEvidenceKind, matching positiveKinds: [PositiveKind], mode: PointMode) -> Double {
        let requested = Set(positiveKinds)
        switch kind {
        case .stepCompleted:
            return requested.contains(.stepCompleted) ? 1.0 : 0
        case .ritualCompletion:
            return requested.contains(.ritualCompletion) ? 0.95 : 0
        case .ritualMinimumVersion:
            return requested.contains(.ritualMinimumVersion) ? (mode == .adaptation ? 1.0 : 0.7) : 0
        case .ritualQuickLog, .sessionLogged:
            return mode == .standard ? 0.35 : 0.15
        case .reflectionLogged, .delegatedUpdate, .observationLogged, .milestoneReached:
            return mode == .adaptation ? 0.35 : 0.2
        }
    }

    func feedbackPositiveWeight(_ event: GoalFeedbackEvent, mode: PointMode) -> Double {
        switch mode {
        case .adaptation:
            switch event {
            case .delayed, .askedForSmallerVersion, .tooBig, .askedWhyThisMatters:
                return 0.55
            case .edited, .notRelevant:
                return 0.35
            default:
                return 0
            }
        case .drift:
            switch event {
            case .completed:
                return 0.2
            default:
                return 0
            }
        case .standard:
            switch event {
            case .completed:
                return 0.25
            default:
                return 0
            }
        }
    }
}
