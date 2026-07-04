import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedInsightsService {
    func timelineItems(snapshot: Snapshot, now: Date) -> [InsightsTimelineItem] {
        let goalsByStep = Dictionary(uniqueKeysWithValues: snapshot.goals.flatMap { goal in
            (goal.plan?.sections.flatMap(\.steps) ?? []).map { ($0.id, goal) }
        })

        let evidenceActivities = snapshot.evidence.compactMap { evidence -> DatedActivity? in
            guard let date = parseDate(evidence.capturedAt) else { return nil }
            let target = GoalRouteTarget(goalID: evidence.goalID)
            return DatedActivity(
                date: date,
                summary: InsightsTimelineItem(
                    id: evidence.id,
                    title: evidenceTitle(for: evidence),
                    subtitle: goalTitle(for: evidence.goalID, goals: snapshot.goals),
                    timestamp: relativeTimestamp(for: evidence.capturedAt, now: now),
                    icon: evidenceIcon(for: evidence),
                    badge: evidenceBadge(for: evidence),
                    visualState: evidenceState(for: evidence),
                    goalTarget: target.goalID == nil ? nil : target,
                    timeRoute: nil
                )
            )
        }

        let feedbackActivities = snapshot.feedback.compactMap { event -> DatedActivity? in
            guard let date = parseDate(event.base.occurredAt) else { return nil }
            let goal = goalsByStep[event.stepID]
            let target = goal.map { GoalRouteTarget(goalID: $0.id) }
            return DatedActivity(
                date: date,
                summary: InsightsTimelineItem(
                    id: event.base.id,
                    title: feedbackTitle(for: event),
                    subtitle: stepTitle(for: event.stepID, goals: snapshot.goals),
                    timestamp: relativeTimestamp(for: event.base.occurredAt, now: now),
                    icon: feedbackIcon(for: event),
                    badge: feedbackBadge(for: event),
                    visualState: feedbackState(for: event),
                    goalTarget: target,
                    timeRoute: isFriction(event) ? .weeklyReview : nil
                )
            )
        }

        return (evidenceActivities + feedbackActivities)
            .sorted { lhs, rhs in
                if lhs.date == rhs.date {
                    return lhs.summary.id > rhs.summary.id
                }
                return lhs.date > rhs.date
            }
            .prefix(8)
            .map(\.summary)
    }
}
