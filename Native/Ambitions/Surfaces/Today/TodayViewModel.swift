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
        runtimeClient: RuntimeCommandClient? = nil,
        userDisplayName: String,
        now: Date,
        calendar: Calendar,
        entryContext: TodayEntryContext = .standard,
        timeZone: TimeZone? = nil
    ) async {
        do {
            let response: TodayActionResponse
            guard RepositoryBackedTodayService.durableGoalStepActionKinds.contains(action.kind) else {
                throw TodayDurableActionError.unavailable
            }
            guard let runtimeClient,
                  let preparer = service as? any TodayDurableGoalStepActionPreparing else {
                throw TodayDurableActionError.unavailable
            }
            let prepared = try await preparer.prepareDurableGoalStepAction(action, now: now)
            let result = await runtimeClient.execute(prepared.command, prepared.context)
            guard result.status == .succeeded,
                  result.metadata["runtimeReceiptID"] != nil,
                  result.metadata["runtimeProjectionStoreStatus"] == "saved",
                  result.metadata["todayActionMaterialization"] == "saved_post_authority",
                  await Self.hasMatchingTodayProjection(result, client: runtimeClient) else {
                throw TodayDurableActionError.needsRecovery
            }
            response = TodayActionResponse(message: Self.message(for: action.kind))
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

    private static func message(for kind: TodayActionKind) -> TodayInlineMessage {
        switch kind {
        case .complete:
            TodayInlineMessage(title: "Completion recorded", body: "This Step now reflects the committed result.", state: .success)
        case .defer:
            TodayInlineMessage(title: "Pressure softened", body: "The Step stays in play for a calmer window.", state: .selected)
        case .reschedule:
            TodayInlineMessage(title: "What changed?", body: "Move it without blame. The Step stays active for the next believable window.", state: .warning)
        case .markNotRelevant:
            TodayInlineMessage(title: "Relevance captured", body: "That Step is no longer active.", state: .warning)
        case .split:
            TodayInlineMessage(title: "Smaller version ready", body: "A smaller Step is ready.", state: .selected)
        case .askForHelp:
            TodayInlineMessage(title: "A calmer next step is ready", body: "Ambitions kept the Step visible and made the ask smaller.", state: .selected)
        case .quickLog:
            TodayInlineMessage(title: "Signal saved", body: "Today recorded a quick bit of evidence without creating fake urgency.", state: .success)
        default:
            TodayInlineMessage(title: "Action saved", body: "The change is committed.", state: .selected)
        }
    }

    private static func hasMatchingTodayProjection(
        _ result: AmbitionsCommandExecutionResult,
        client: RuntimeCommandClient
    ) async -> Bool {
        guard let projection = try? await client.projection(.today) else { return false }
        let usesMaterializedCursor = result.metadata["runtimeMaterializedProjectionCursorIDs"]?.isEmpty == false
        let cursorPrefix = usesMaterializedCursor ? "runtimeMaterializedProjectionCursor" : "runtimeProjectionCursor"
        let ids = result.metadata["\(cursorPrefix)IDs"]?.split(separator: ",").map(String.init) ?? []
        let sequences = result.metadata["\(cursorPrefix)Sequences"]?.split(separator: ",").compactMap { Int64($0) } ?? []
        let checksums = result.metadata["\(cursorPrefix)Checksums"]?.split(separator: ",").map(String.init) ?? []
        guard ids.count == sequences.count, ids.count == checksums.count,
              let index = ids.firstIndex(of: ProjectionID.today.rawValue) else { return false }
        return projection.projectionID == ProjectionID.today.rawValue &&
            projection.eventSequence == sequences[index] &&
            projection.cursorChecksum == checksums[index]
    }

    func confirmActionClosure(
        _ closure: TodayActionClosureSheetState,
        outcome: TodayActionClosureOutcomeState,
        using receiptCommands: any TodayReceiptCommanding,
        refreshService: any TodayServicing,
        userDisplayName: String,
        now: Date,
        calendar: Calendar,
        entryContext: TodayEntryContext = .standard,
        timeZone: TimeZone? = nil
    ) async {
        do {
            let response = try await receiptCommands.recordActionClosure(closure, outcome: outcome, now: now)
            transientMessage = response.message
            await refresh(using: refreshService, userDisplayName: userDisplayName, now: now, calendar: calendar, entryContext: entryContext, timeZone: timeZone)
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

}
import AmbitionsTimeFoundation
