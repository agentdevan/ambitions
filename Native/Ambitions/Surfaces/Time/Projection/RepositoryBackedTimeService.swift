import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedTimeService: TimeServicing {
    let repositories: AppRepositories
    let calendarRealityService: (any CalendarRealityServicing)?
    let timeProjectionService: TimeProjectionService
    let calendarAvailabilityHorizon: String
    let clock: any AmbitionsClock
    let fixedCalendar: Calendar?
    let lifeCalendarStore: LifeCalendarStore?

    var calendar: Calendar {
        fixedCalendar ?? clock.calendar
    }

    init(
        repositories: AppRepositories,
        calendarRealityService: (any CalendarRealityServicing)? = nil,
        lifeCalendarStoreFileURL: URL? = nil,
        timeProjectionService: TimeProjectionService = .init(),
        calendarAvailabilityHorizon: String = "week",
        clock: any AmbitionsClock = SystemClock(),
        calendar: Calendar? = nil
    ) {
        self.repositories = repositories
        self.calendarRealityService = calendarRealityService
        self.timeProjectionService = timeProjectionService
        self.calendarAvailabilityHorizon = calendarAvailabilityHorizon
        self.clock = clock
        self.fixedCalendar = calendar
        self.lifeCalendarStore = lifeCalendarStoreFileURL.map { LifeCalendarStore(fileURL: $0) }
    }

    func loadTimeSurfaceState(now: Date) async throws -> TimeSurfaceState {
        let snapshot = try await loadSnapshot()
        let permission = await calendarRealityService?.calendarPermissionState() ?? .unavailable
        return try await timeProjectionService.makeTimeSurfaceState(
            from: self,
            now: now,
            permission: permission,
            openWindowCount: nil,
            snapshot: snapshot
        )
    }

    func loadTimeWeeklyReviewState(now: Date) async throws -> TimeWeeklyReviewState {
        return try await timeProjectionService.makeTimeWeeklyReviewState(from: self, now: now)
    }

    func makeTimeCalendarAware(now: Date) async throws -> TimeSurfaceState {
        let snapshot = try await loadSnapshot()
        guard let calendarRealityService else {
            return try await timeProjectionService.makeTimeSurfaceState(
                from: self,
                now: now,
                permission: .unavailable,
                openWindowCount: nil,
                snapshot: snapshot
            )
        }
        let result = await calendarRealityService.findOpenWindows(
            request: CalendarRealityReadRequest(
                horizon: availabilityHorizon(now: now, horizon: calendarAvailabilityHorizon),
                userInitiatedTimeAction: "Make Time calendar-aware",
                minimumWindowMinutes: 30
            )
        )
        let realitySnapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: availabilityHorizon(now: now, horizon: calendarAvailabilityHorizon),
                activeContextLens: .all,
                calendarBusyWindows: result.derivedBusyWindows,
                calendarContext: result.calendarContext,
                minimumWindowMinutes: 30
            )
        )
        let event = RealityIntegrationAdapter.calendarContextObservedEntry(
            snapshot: realitySnapshot,
            occurredAt: now,
            actionName: "Make Time calendar-aware"
        )
        try? await repositories.eventLedger.append(event)
        return try await timeProjectionService.makeTimeSurfaceState(
            from: self,
            now: now,
            permission: result.permissionState,
            openWindowCount: result.openWindowCandidates.count,
            snapshot: snapshot
        )
    }
}

extension RepositoryBackedTimeService: TimeProjectionSource {}
import AmbitionsTimeFoundation
