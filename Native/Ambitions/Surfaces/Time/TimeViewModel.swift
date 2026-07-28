import Foundation
import Observation

struct TimeFeatureMutationResult: Sendable {
    let projection: TimeSurfaceState
    let receiptID: String
    let projectionVersion: Int64
    let canUndo: Bool
}

@MainActor
@Observable
final class TimeViewModel {
    var state: AsyncViewState<TimeSurfaceState>
    var visibleTimeMutation: UserVisibleMutation?
    var mutationErrorMessage: String?
    var protectedPlacementReview: ProtectedPlacementReviewState?
    var protectedPlacementReviewOutcome: ProtectedPlacementReviewOutcome?

    private var hasLoaded = false
    private var lastCommittedTimeCommand: AmbitionsCommand?
    private var lastTimeReceiptID: String?
    private var lastTimeProjectionVersion: Int64?
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
        now: Date,
        runtimeClient: RuntimeCommandClient,
        service: any TimeServicing,
        calendar: Calendar,
        timeZone: TimeZone
    ) async {
        guard case let .loaded(timeState) = state else { return }
        do {
            let command = try TimeFieldMutationCoordinator.prepareCommand(
                action,
                in: timeState,
                selectedMark: selectedMark,
                now: now,
                explicitProtectedPlacementApproval: action != .placeStep
            )
            _ = try await executeTimeCommand(
                command,
                now: now,
                runtimeClient: runtimeClient,
                service: service,
                calendar: calendar,
                timeZone: timeZone
            )
        } catch let error as TimeFieldMutationError {
            handleTimeFieldMutationError(error, action: action, selectedMark: selectedMark, timeState: timeState, now: now)
        } catch {
            mutationErrorMessage = "Time change was not applied: \(error)"
        }
    }

    func approveProtectedPlacementReview(
        now: Date,
        runtimeClient: RuntimeCommandClient,
        service: any TimeServicing,
        calendar: Calendar,
        timeZone: TimeZone
    ) async {
        guard let review = protectedPlacementReview,
              case let .loaded(timeState) = state else { return }
        do {
            let command = try TimeFieldMutationCoordinator.prepareCommand(
                review.action,
                in: timeState,
                selectedMark: review.selectedMark,
                now: now,
                actor: .user,
                explicitProtectedPlacementApproval: true
            )
            _ = try await executeTimeCommand(
                command,
                now: now,
                runtimeClient: runtimeClient,
                service: service,
                calendar: calendar,
                timeZone: timeZone
            )
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

    func undoLastLifeShapeMutation(
        now: Date,
        runtimeClient: RuntimeCommandClient,
        service: any TimeServicing,
        calendar: Calendar,
        timeZone: TimeZone
    ) async {
        guard let original = lastCommittedTimeCommand,
              let receiptID = lastTimeReceiptID,
              let projectionVersion = lastTimeProjectionVersion,
              let timeID = original.target.timeID else { return }
        guard let typedReceiptID = RuntimeCommandReceiptID(rawValue: receiptID) else { return }
        let target = AmbitionsCommandTarget(timeID: timeID, stepID: original.target.stepID)
        let content = AmbitionsCommandPayload(title: "Undo")
        let undo = AmbitionsCommand(
            id: "command.time.undo.\(original.id).\(ISO8601DateFormatter().string(from: now))",
            source: .time,
            typedPayload: .schedule(ScheduleCommand(
                action: .undo(CommandUndoIntent(
                    originalReceiptID: typedReceiptID,
                    expectedProjectionVersion: projectionVersion
                )),
                target: target,
                content: RuntimeCommandContent(content)
            )),
            createdAt: ISO8601DateFormatter().string(from: now),
            actor: .user,
            sourceSurface: "Time"
        )
        do {
            _ = try await executeTimeCommand(
                undo,
                now: now,
                runtimeClient: runtimeClient,
                service: service,
                calendar: calendar,
                timeZone: timeZone
            )
            lastCommittedTimeCommand = nil
            lastTimeReceiptID = nil
            lastTimeProjectionVersion = nil
        } catch {
            mutationErrorMessage = "Undo was not applied: \(error)"
        }
    }

    @discardableResult
    private func executeTimeCommand(
        _ command: AmbitionsCommand,
        now: Date,
        runtimeClient: RuntimeCommandClient,
        service: any TimeServicing,
        calendar: Calendar,
        timeZone: TimeZone
    ) async throws -> TimeFeatureMutationResult {
        let commit: TimeRuntimeMutationCommit
        do {
            commit = try await TimeRuntimeMutationAdapter(runtimeClient: runtimeClient).execute(
                command,
                now: now
            )
        } catch let error as TimeRuntimeMutationAdapterError {
            throw TimeFieldMutationError.runtimeRejected(String(describing: error))
        }
        let result = commit.result
        let receiptID = commit.receiptID
        let committedProjection = commit.projection
        let reloaded = try await service.loadTimeSurfaceState(now: now)
        state = .loaded(reloaded)
        visibleTimeMutation = Self.committedVisibleMutation(
            command: command,
            receiptID: receiptID,
            projection: committedProjection
        )
        mutationErrorMessage = nil
        protectedPlacementReview = nil
        protectedPlacementReviewOutcome = nil
        lastCommittedTimeCommand = command
        lastTimeReceiptID = receiptID
        lastTimeProjectionVersion = committedProjection.eventSequence
        lastLoadedDayStart = dayBoundaryScheduler.loadedDayStart(for: now, calendar: calendar)
        lastLoadedClockContext = dayBoundaryScheduler.loadedClockContext(
            for: now,
            calendar: calendar,
            timeZone: timeZone
        )
        return TimeFeatureMutationResult(
            projection: reloaded,
            receiptID: receiptID,
            projectionVersion: committedProjection.eventSequence,
            canUndo: command.commandUndoIntent == nil
        )
    }

    private static func committedVisibleMutation(
        command: AmbitionsCommand,
        receiptID: String,
        projection: RuntimeProjectionSnapshot
    ) -> UserVisibleMutation {
        let affectedIDs = Array(Set([
            command.target.timeID,
            command.target.stepID,
            command.target.goalID,
        ].compactMap { $0 })).sorted()
        let stableAffectedIDs = affectedIDs.isEmpty ? [command.id] : affectedIDs
        let action = MutationActionReference(
            commandID: command.id,
            commandPayload: command.typedPayload,
            source: command.source,
            targetObjectIDs: stableAffectedIDs
        )
        let before = MutationSnapshotReference(
            id: "snapshot.before.\(receiptID)",
            surface: .time,
            summary: "Time before committed projection version \(max(projection.eventSequence - 1, 0))."
        )
        let after = MutationSnapshotReference(
            id: "snapshot.after.\(receiptID)",
            surface: .time,
            summary: "Time projection version \(projection.eventSequence), checksum \(projection.payloadChecksum)."
        )
        let proof = MutationProof(
            artifactID: "runtime.proof.\(receiptID)",
            label: "Committed Time projection",
            localOnly: true,
            beforeSnapshot: before,
            action: action,
            afterSnapshot: after
        )
        let isUndo = command.commandUndoIntent != nil
        let headline: String
        if case let .schedule(value) = command.typedPayload {
            switch value.action {
            case .placeStep: headline = "Step placed"
            case .protectWindow: headline = "Window protected"
            case .undo: headline = "Undo applied"
            case .correctWindow: headline = "Time corrected"
            case .createItem, .schedule, .ritual, .calendarWrite: headline = "Time updated"
            }
        } else {
            headline = "Time updated"
        }
        let runtimeMutationID = "runtime.mutation.\(receiptID)"
        let stage = StageMutation(
            runtimeMutationID: runtimeMutationID,
            beforeSnapshot: before,
            afterSnapshot: after,
            targetSurface: .time,
            affectedObjectIDs: stableAffectedIDs,
            visibleUserFacingChange: headline,
            typedMotionEvent: MutationMotionEvent(
                id: isUndo ? "stage.motion.time.mutation_undone" : "stage.motion.\(command.typedPayload.diagnosticFamily).\(command.typedPayload.diagnosticCase)",
                kind: isUndo ? .undo : .stageAction,
                sourceMutationID: runtimeMutationID,
                affectedObjectIDs: stableAffectedIDs
            ),
            accessibilityAnnouncement: MutationAccessibilityAnnouncement(
                message: "\(headline). Saved locally with proof available.",
                reasonIfSilent: nil
            ),
            hapticIntent: isUndo ? "selection" : "confirmation",
            undoAvailability: isUndo
                ? .unavailable(label: "Undo used", reason: "This receipt already restores the prior Time shape.")
                : MutationUndo(isAvailable: true, label: "Undo", restoresSnapshot: before, sourceReceiptID: receiptID),
            proofArtifact: proof,
            receipt: MutationReceipt(
                receiptID: receiptID,
                saved: true,
                inspectionLabel: "Receipt",
                proofArtifactID: proof.artifactID,
                action: action
            ),
            safeFallback: "Reload Time from the committed local projection."
        )
        return UserVisibleMutation(
            stageMutation: stage,
            headline: headline,
            detail: "Saved locally in Life Calendar."
        )
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
import AmbitionsTimeFoundation
