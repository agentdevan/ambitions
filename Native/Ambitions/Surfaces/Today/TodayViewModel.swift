import Foundation
import Observation

@MainActor
@Observable
final class TodayViewModel {
    var state: AsyncViewState<TodayExperience>
    var transientMessage: TodayInlineMessage?

    private var hasLoaded = false
    private let dayBoundaryRefreshPolicy = TodayDayBoundaryRefreshPolicy()
    private(set) var lastLoadedDayStart: Date?
    private(set) var lastLoadedClockContext: TodayDayBoundaryRefreshPolicy.LoadedClockContext?

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(experience):
            return "loaded:\(experience.mode.rawValue)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    init(
        state: AsyncViewState<TodayExperience> = .loading,
        transientMessage: TodayInlineMessage? = nil
    ) {
        self.state = state
        self.transientMessage = transientMessage
    }

    func activate(
        using service: any TodayServicing,
        userDisplayName: String,
        now: Date,
        calendar: Calendar,
        entryContext: TodayEntryContext = .standard,
        timeZone: TimeZone? = nil
    ) async {
        if hasLoaded {
            await refresh(using: service, userDisplayName: userDisplayName, now: now, calendar: calendar, entryContext: entryContext, timeZone: timeZone)
        } else {
            await load(using: service, userDisplayName: userDisplayName, now: now, calendar: calendar, entryContext: entryContext, timeZone: timeZone)
        }
    }

    func load(
        using service: any TodayServicing,
        userDisplayName: String,
        now: Date,
        calendar: Calendar,
        entryContext: TodayEntryContext = .standard,
        timeZone: TimeZone? = nil
    ) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, userDisplayName: userDisplayName, now: now, calendar: calendar, entryContext: entryContext, timeZone: timeZone)
    }

    func refresh(
        using service: any TodayServicing,
        userDisplayName: String,
        now: Date,
        calendar: Calendar,
        entryContext: TodayEntryContext = .standard,
        timeZone: TimeZone? = nil
    ) async {
        do {
            state = .loaded(try await service.loadTodayExperience(userDisplayName: userDisplayName, now: now, entryContext: entryContext))
            lastLoadedDayStart = dayBoundaryRefreshPolicy.loadedDayStart(for: now, calendar: calendar)
            lastLoadedClockContext = dayBoundaryRefreshPolicy.loadedClockContext(
                for: now,
                calendar: calendar,
                timeZone: timeZone ?? calendar.timeZone
            )
        } catch {
            state = .failed("Unable to load Today: \(error.localizedDescription)")
        }
    }

    func handle(
        _ action: TodayInlineAction,
        using service: any TodayServicing,
        userDisplayName: String,
        now: Date,
        calendar: Calendar,
        entryContext: TodayEntryContext = .standard,
        timeZone: TimeZone? = nil
    ) async {
        do {
            let response = try await service.performAction(action, now: now)
            transientMessage = response.message
            await refresh(using: service, userDisplayName: userDisplayName, now: now, calendar: calendar, entryContext: entryContext, timeZone: timeZone)
        } catch {
            transientMessage = TodayInlineMessage(
                title: "Action could not finish",
                body: error.localizedDescription,
                state: .warning
            )
        }
    }

    func confirmActionClosure(
        _ closure: TodayActionClosureSheetState,
        outcome: TodayActionClosureOutcomeState,
        using service: any TodayServicing,
        userDisplayName: String,
        now: Date,
        calendar: Calendar,
        entryContext: TodayEntryContext = .standard,
        timeZone: TimeZone? = nil
    ) async {
        do {
            let response = try await service.recordActionClosure(closure, outcome: outcome, now: now)
            transientMessage = response.message
            await refresh(using: service, userDisplayName: userDisplayName, now: now, calendar: calendar, entryContext: entryContext, timeZone: timeZone)
            if let stageMutation = response.stageMutation {
                applyClosureStageMutation(stageMutation)
            }
        } catch {
            transientMessage = TodayInlineMessage(
                title: "Closure could not be saved",
                body: error.localizedDescription,
                state: .warning
            )
        }
    }

    func shouldRefreshForDayBoundary(now: Date, calendar: Calendar) -> Bool {
        dayBoundaryRefreshPolicy.shouldRefresh(lastLoadedDayStart: lastLoadedDayStart, now: now, calendar: calendar)
    }

    func shouldRefreshForClockChange(now: Date, calendar: Calendar, timeZone: TimeZone) -> Bool {
        dayBoundaryRefreshPolicy.shouldRefresh(
            lastLoadedClockContext: lastLoadedClockContext,
            now: now,
            calendar: calendar,
            timeZone: timeZone
        )
    }

    private func applyClosureStageMutation(_ mutation: TodayClosureStageMutation) {
        guard case let .loaded(experience) = state else { return }
        state = .loaded(experience.applyingClosure(mutation))
    }
}
