import Foundation
import Observation

@MainActor
@Observable
final class TimeViewModel {
    var state: AsyncViewState<TimeSurfaceState>
    var visibleTimeMutation: UserVisibleMutation?
    var mutationErrorMessage: String?

    private var hasLoaded = false
    private var lastTimeFieldMutation: TimeFieldMutationResult?
    private let dayBoundaryScheduler = DayBoundaryScheduler()
    private(set) var lastLoadedDayStart: Date?
    private(set) var lastLoadedClockContext: DayBoundaryScheduler.LoadedClockContext?

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(timeState):
            let changeID = visibleTimeMutation?.stageMutation.runtimeMutationID ?? "none"
            return "loaded:\(timeState.mode):\(timeState.weekDays.count):\(timeState.goalShapingItems.count):\(timeState.shapingActions.count):\(changeID)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    var accessibilitySummary: String {
        switch state {
        case .loading:
            return "Time. Life Calendar is loading."
        case let .loaded(timeState):
            return TimeAccessibility.rootSummary(for: timeState)
        case let .failed(message):
            return "Time. Life Calendar failed. \(message)"
        }
    }

    init(state: AsyncViewState<TimeSurfaceState> = .loading) {
        self.state = state
    }

    func load(using service: any TimeServicing, now: Date, calendar: Calendar, timeZone: TimeZone? = nil) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, now: now, calendar: calendar, timeZone: timeZone)
    }

    func refresh(using service: any TimeServicing, now: Date, calendar: Calendar, timeZone: TimeZone? = nil) async {
        do {
            state = .loaded(try await service.loadTimeSurfaceState(now: now))
            lastLoadedDayStart = dayBoundaryScheduler.loadedDayStart(for: now, calendar: calendar)
            lastLoadedClockContext = dayBoundaryScheduler.loadedClockContext(
                for: now,
                calendar: calendar,
                timeZone: timeZone ?? calendar.timeZone
            )
        } catch {
            state = .failed("Unable to load Time: \(error.localizedDescription)")
        }
    }

    func makeCalendarAware(using service: any TimeServicing, now: Date, calendar: Calendar, timeZone: TimeZone? = nil) async {
        do {
            state = .loaded(try await service.makeTimeCalendarAware(now: now))
            lastLoadedDayStart = dayBoundaryScheduler.loadedDayStart(for: now, calendar: calendar)
            lastLoadedClockContext = dayBoundaryScheduler.loadedClockContext(
                for: now,
                calendar: calendar,
                timeZone: timeZone ?? calendar.timeZone
            )
        } catch {
            state = .failed("Unable to make Time calendar-aware: \(error.localizedDescription)")
        }
    }

    func shouldRefreshForDayBoundary(now: Date, calendar: Calendar) -> Bool {
        dayBoundaryScheduler.shouldRefresh(lastLoadedDayStart: lastLoadedDayStart, now: now, calendar: calendar)
    }

    func shouldRefreshForClockChange(now: Date, calendar: Calendar, timeZone: TimeZone) -> Bool {
        dayBoundaryScheduler.shouldRefresh(
            lastLoadedClockContext: lastLoadedClockContext,
            now: now,
            calendar: calendar,
            timeZone: timeZone
        )
    }

    func performLifeShapeMutation(
        _ action: TimeFieldMutationAction,
        selectedMark: LifeShapeSemanticMark?,
        now: Date
    ) {
        guard case let .loaded(timeState) = state else { return }
        do {
            let result = try TimeFieldMutationCoordinator().perform(
                action,
                in: timeState,
                selectedMark: selectedMark,
                now: now
            )
            state = .loaded(result.updatedTimeState)
            lastTimeFieldMutation = result
            visibleTimeMutation = result.visibleMutation
            mutationErrorMessage = nil
        } catch {
            mutationErrorMessage = "Time change was not applied: \(error)"
        }
    }

    func undoLastLifeShapeMutation(now: Date) {
        guard let lastTimeFieldMutation else { return }
        let undo = TimeFieldMutationCoordinator().undo(lastTimeFieldMutation, now: now)
        state = .loaded(undo.restoredTimeState)
        self.lastTimeFieldMutation = nil
        visibleTimeMutation = undo.visibleMutation
        mutationErrorMessage = nil
    }
}
