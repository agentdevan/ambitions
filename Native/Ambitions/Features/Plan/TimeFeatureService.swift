import AmbitionsDesignSystem
import Foundation

struct TimeFeatureService {
    func makeDashboard(
        from source: RepositoryBackedPlanService,
        now: Date,
        permission: CalendarPermissionState,
        openWindowCount: Int? = nil,
        snapshot: RepositoryBackedPlanService.Snapshot? = nil
    ) async throws -> PlanDashboard {
        let resolvedSnapshot = try await {
            if let snapshot {
                return snapshot
            }
            return try await source.loadSnapshot()
        }()
        let calendarAwareness = source.makeCalendarAwarenessState(permission: permission, openWindowCount: openWindowCount)
        return source.makeDashboard(
            snapshot: resolvedSnapshot,
            now: now,
            calendarAwareness: calendarAwareness
        )
    }

    func makeWeeklyReviewDashboard(from source: RepositoryBackedPlanService, now: Date) async throws -> WeeklyReviewDashboard {
        let snapshot = try await source.loadSnapshot()
        return source.makeWeeklyReviewDashboard(snapshot: snapshot, now: now)
    }
}
