import ActivityKit
import Foundation

protocol NextStepLiveActivityServicing: Sendable {
    func refresh(from snapshot: ExternalSurfaceSnapshot?, now: Date) async
}

actor NextStepLiveActivityService: NextStepLiveActivityServicing {
    func refresh(from snapshot: ExternalSurfaceSnapshot?, now: Date) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let decision = NextStepLiveActivityLifecycleDecision.evaluate(snapshot: snapshot, now: now)
        guard case let .requestOrUpdate(contentState) = decision else {
            await endAll()
            return
        }

        if let existing = Activity<NextStepActivityAttributes>.activities.first {
            await existing.update(ActivityContent(state: contentState, staleDate: staleDate(from: now)))
            return
        }

        let attributes = NextStepActivityAttributes(contextID: "next-step")
        _ = try? Activity<NextStepActivityAttributes>.request(
            attributes: attributes,
            content: ActivityContent(state: contentState, staleDate: staleDate(from: now))
        )
    }

    private func endAll() async {
        for activity in Activity<NextStepActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    private func staleDate(from now: Date) -> Date {
        now.addingTimeInterval(45 * 60)
    }
}

struct StubNextStepLiveActivityService: NextStepLiveActivityServicing {
    func refresh(from snapshot: ExternalSurfaceSnapshot?, now: Date) async {
        _ = snapshot
        _ = now
    }
}
