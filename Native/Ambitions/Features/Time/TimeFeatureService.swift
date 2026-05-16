import AmbitionsDesignSystem
import Foundation

protocol TimeFeatureProjectionSource {
    func loadSnapshot() async throws -> RepositoryBackedTimeService.Snapshot
    func makeDashboard(snapshot: RepositoryBackedTimeService.Snapshot, now: Date, calendarAwareness: TimeCalendarAwarenessState) -> TimeDashboard
    func makeWeeklyReviewDashboard(snapshot: RepositoryBackedTimeService.Snapshot, now: Date) -> WeeklyReviewDashboard
    func makeCalendarAwarenessState(permission: CalendarPermissionState, openWindowCount: Int?) -> TimeCalendarAwarenessState
}

struct TimeFeatureService {
    func makeDashboard(
        from source: any TimeFeatureProjectionSource,
        now: Date,
        permission: CalendarPermissionState,
        openWindowCount: Int? = nil,
        snapshot: RepositoryBackedTimeService.Snapshot? = nil
    ) async throws -> TimeDashboard {
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

    func makeWeeklyReviewDashboard(from source: any TimeFeatureProjectionSource, now: Date) async throws -> WeeklyReviewDashboard {
        let snapshot = try await source.loadSnapshot()
        return source.makeWeeklyReviewDashboard(snapshot: snapshot, now: now)
    }
}
