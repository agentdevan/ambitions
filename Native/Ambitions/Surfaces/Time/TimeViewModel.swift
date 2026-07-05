import Foundation
import Observation

@MainActor
@Observable
final class TimeViewModel {
    var state: AsyncViewState<TimeSurfaceState>
    var visibleTimeMutation: UserVisibleMutation?
    var mutationErrorMessage: String?
    var protectedPlacementReview: ProtectedPlacementReviewState?
    var protectedPlacementReviewOutcome: ProtectedPlacementReviewOutcome?

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
            return "Time. LifeShape Field is loading."
        case let .loaded(timeState):
            return TimeAccessibility.rootSummary(for: timeState)
        case let .failed(message):
            return "Time. LifeShape Field failed. \(message)"
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
            protectedPlacementReview = nil
            protectedPlacementReviewOutcome = nil
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
            protectedPlacementReview = nil
            protectedPlacementReviewOutcome = nil
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
                now: now,
                explicitProtectedPlacementApproval: action != .placeStep
            )
            state = .loaded(result.updatedTimeState)
            lastTimeFieldMutation = result
            visibleTimeMutation = result.visibleMutation
            mutationErrorMessage = nil
            protectedPlacementReview = nil
            protectedPlacementReviewOutcome = nil
        } catch let error as TimeFieldMutationError {
            handleTimeFieldMutationError(error, action: action, selectedMark: selectedMark, timeState: timeState, now: now)
        } catch {
            mutationErrorMessage = "Time change was not applied: \(error)"
        }
    }

    func approveProtectedPlacementReview(now: Date) {
        guard let review = protectedPlacementReview,
              case let .loaded(timeState) = state else { return }
        do {
            let result = try TimeFieldMutationCoordinator().perform(
                review.action,
                in: timeState,
                selectedMark: review.selectedMark,
                now: now,
                actor: .user,
                explicitProtectedPlacementApproval: true
            )
            state = .loaded(result.updatedTimeState)
            lastTimeFieldMutation = result
            visibleTimeMutation = result.visibleMutation
            mutationErrorMessage = nil
            protectedPlacementReview = nil
            protectedPlacementReviewOutcome = .moved
        } catch {
            mutationErrorMessage = "Time change was not applied: \(error)"
        }
    }

    func keepProtectedPlacementReview() {
        protectedPlacementReview = nil
        protectedPlacementReviewOutcome = .kept
        mutationErrorMessage = nil
    }

    func updateProtectedPlacementPriority(_ priority: PlacementPriority) {
        guard let review = protectedPlacementReview else { return }
        let priorityDecision = PriorityPlacementPolicy().evaluate(
            input: PriorityPlacementInput(
                stepID: review.stepID,
                priority: priority,
                source: .userOverride,
                userOverride: priority
            ),
            protectedPlacementDecision: review.decision
        )
        protectedPlacementReview = review.updatingPriorityDecision(priorityDecision)
        protectedPlacementReviewOutcome = nil
        mutationErrorMessage = nil
    }

    func undoLastLifeShapeMutation(now: Date) {
        guard let lastTimeFieldMutation else { return }
        let undo = TimeFieldMutationCoordinator().undo(lastTimeFieldMutation, now: now)
        state = .loaded(undo.restoredTimeState)
        self.lastTimeFieldMutation = nil
        visibleTimeMutation = undo.visibleMutation
        mutationErrorMessage = nil
        protectedPlacementReview = nil
        protectedPlacementReviewOutcome = nil
    }

    private func handleTimeFieldMutationError(
        _ error: TimeFieldMutationError,
        action: TimeFieldMutationAction,
        selectedMark: LifeShapeSemanticMark?,
        timeState: TimeSurfaceState,
        now: Date
    ) {
        guard case let .protectedPlacementRequiresApproval(decision) = error,
              let review = makeProtectedPlacementReview(
                action: action,
                selectedMark: selectedMark,
                timeState: timeState,
                decision: decision,
                now: now
              ) else {
            mutationErrorMessage = "Time change was not applied: \(error)"
            return
        }

        protectedPlacementReview = review
        protectedPlacementReviewOutcome = nil
        mutationErrorMessage = nil
        visibleTimeMutation = nil
    }

    private func makeProtectedPlacementReview(
        action: TimeFieldMutationAction,
        selectedMark: LifeShapeSemanticMark?,
        timeState: TimeSurfaceState,
        decision: ProtectedStepPlacementDecision,
        now: Date
    ) -> ProtectedPlacementReviewState? {
        guard action == .placeStep,
              let placementCandidate = timeState.lifeSuite.field.placementCandidate,
              let visibleProjection = try? LifeShapeProjection.fromVisibleTimeField(
                timeState.lifeSuite.field,
                selectedMark: selectedMark,
                preferredLayer: action.targetLayer,
                placementCandidate: placementCandidate,
                now: now
              ),
              let targetBucket = visibleProjection.targetBucket(for: selectedMark, preferredLayer: action.targetLayer) else {
            return nil
        }

        return ProtectedPlacementReviewState(
            id: "protected-placement-review.\(placementCandidate.stepID).\(targetBucket.id)",
            action: action,
            selectedMark: selectedMark,
            stepID: placementCandidate.stepID,
            stepTitle: placementCandidate.title,
            currentPlacementLabel: "Current placement stays unchanged",
            proposedPlacementLabel: targetBucket.accessibilitySummary,
            reasonLabel: "This will move a Step inside the next seven days",
            decision: decision,
            priorityDecision: PriorityPlacementPolicy().evaluate(
                input: PriorityPlacementInput(
                    stepID: placementCandidate.stepID,
                    priority: .normal,
                    source: .defaulted
                ),
                protectedPlacementDecision: decision
            )
        )
    }
}
