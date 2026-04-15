import ActivityKit
import Foundation

protocol NextStepLiveActivityServicing: Sendable {
    func refresh(from snapshot: ExternalSurfaceSnapshot?, now: Date) async
}

actor NextStepLiveActivityService: NextStepLiveActivityServicing {
    func refresh(from snapshot: ExternalSurfaceSnapshot?, now: Date) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        guard let nextAction = snapshot?.nextAction else {
            await endAll()
            return
        }

        let contentState = NextStepActivityAttributes.ContentState(
            goalID: nextAction.goalID,
            stepID: nextAction.stepID,
            urgency: nextAction.display.urgency,
            timing: nextAction.display.timing,
            updatedAt: ISO8601DateFormatter().string(from: now)
        )

        if let existing = Activity<NextStepActivityAttributes>.activities.first {
            await existing.update(ActivityContent(state: contentState, staleDate: nil))
            return
        }

        let attributes = NextStepActivityAttributes(contextID: "next-step")
        _ = try? Activity<NextStepActivityAttributes>.request(
            attributes: attributes,
            content: ActivityContent(state: contentState, staleDate: nil)
        )
    }

    private func endAll() async {
        for activity in Activity<NextStepActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}

struct StubNextStepLiveActivityService: NextStepLiveActivityServicing {
    func refresh(from snapshot: ExternalSurfaceSnapshot?, now: Date) async {
        _ = snapshot
        _ = now
    }
}
