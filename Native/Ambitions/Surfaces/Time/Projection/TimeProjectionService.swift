import AmbitionsDesignSystem
import Foundation

protocol TimeProjectionSource {
    func loadSnapshot() async throws -> RepositoryBackedTimeService.Snapshot
    func makeTimeSurfaceState(snapshot: RepositoryBackedTimeService.Snapshot, now: Date, calendarAwareness: TimeCalendarAwarenessState) -> TimeSurfaceState
    func makeTimeWeeklyReviewState(snapshot: RepositoryBackedTimeService.Snapshot, now: Date) -> TimeWeeklyReviewState
    func makeCalendarAwarenessState(permission: CalendarPermissionState, openWindowCount: Int?) -> TimeCalendarAwarenessState
}

struct TimeProjectionService {
    func makeTimeSurfaceState(
        from source: any TimeProjectionSource,
        now: Date,
        permission: CalendarPermissionState,
        openWindowCount: Int? = nil,
        snapshot: RepositoryBackedTimeService.Snapshot? = nil
    ) async throws -> TimeSurfaceState {
        let resolvedSnapshot = try await {
            if let snapshot {
                return snapshot
            }
            return try await source.loadSnapshot()
        }()
        let calendarAwareness = source.makeCalendarAwarenessState(permission: permission, openWindowCount: openWindowCount)
        return source.makeTimeSurfaceState(
            snapshot: resolvedSnapshot,
            now: now,
            calendarAwareness: calendarAwareness
        )
    }

    func makeTimeWeeklyReviewState(from source: any TimeProjectionSource, now: Date) async throws -> TimeWeeklyReviewState {
        let snapshot = try await source.loadSnapshot()
        return source.makeTimeWeeklyReviewState(snapshot: snapshot, now: now)
    }
}
