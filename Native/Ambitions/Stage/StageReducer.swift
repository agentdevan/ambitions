import Foundation

struct StageReduction {
    var reselectionAction: StageSurfaceReselectionAction?
    var consumedTodayEntryContext: TodayEntryContext?
    var consumedPendingTodayEntryContext: TodayEntryContext?
    var consumedContinuityReceipt: ShellContinuityReceipt?
    var effects: [StageEffect]

    static func none(effects: [StageEffect] = []) -> StageReduction {
        StageReduction(
            reselectionAction: nil,
            consumedTodayEntryContext: nil,
            consumedPendingTodayEntryContext: nil,
            consumedContinuityReceipt: nil,
            effects: effects
        )
    }
}

private struct StageCommandHistoryInput {
    let title: String
    let subtitle: String
    let source: ShellCommandEntrySource
    let presentationContext: ShellCommandPresentationContext
    let destinationLabel: String
    let recordedAt: Date
}

enum StageReducer {
    private static let surfaceReselectionRootThreshold: TimeInterval = 0.8

    static func reduce(_ action: StageAction, state: inout StageState, now: Date) -> StageReduction {
        switch action {
        case let .selectSurface(surface):
            selectSurface(surface, state: &state)
            return .none(effects: StageEffect.surfaceChanged(to: state.selectedSurface))
        case let .selectToday(entryContext):
            dismissOverlay(state: &state)
            resetFocusedRoutes(state: &state)
            state.selectedSurface = .today
            state.todayEntryContext = entryContext
            return .none(effects: StageEffect.surfaceChanged(to: .today))
        case let .selectRootSurfaceFromDock(surface, now):
            return selectRootSurfaceFromDock(surface, now: now, state: &state)
        case let .handleCurrentSurfaceReselection(now):
            return handleCurrentSurfaceReselection(now: now, state: &state)
        case let .openGoalDetail(target):
            guard target.hasAddressableContent else { return .none() }
            dismissOverlay(state: &state)
            state.selectedSurface = .goals
            state.goalsPath = [target]
            return .none(effects: StageEffect.surfaceChanged(to: .goals))
        case let .replaceNavigationPath(path):
            return replaceNavigationPath(path, state: &state)
        case .popFocusedRoute:
            return popFocusedRoute(state: &state)
        case .resetGoalsPath:
            state.goalsPath = []
            return .none(effects: [
                .visibleObjectMutation(
                    id: "surface.goals.root-restored",
                    affectedObjectIDs: ["surface.goals"],
                    consequence: "Goals root restored"
                )
            ])
        case let .openTimeRoute(target):
            dismissOverlay(state: &state)
            state.selectedSurface = .time
            state.timePath = [target]
            return .none(effects: StageEffect.surfaceChanged(to: .time))
        case .resetTimePath:
            state.timePath = []
            return .none(effects: [
                .visibleObjectMutation(
                    id: "surface.time.root-restored",
                    affectedObjectIDs: ["surface.time"],
                    consequence: "Time root restored"
                )
            ])
        case let .openYouRoute(target):
            dismissOverlay(state: &state)
            state.selectedSurface = .you
            state.youPath = [target]
            return .none(effects: StageEffect.surfaceChanged(to: .you))
        case .resetYouPath:
            state.youPath = []
            return .none(effects: [
                .visibleObjectMutation(
                    id: "surface.you.root-restored",
                    affectedObjectIDs: ["surface.you"],
                    consequence: "You root restored"
                )
            ])
        case let .presentOverlay(overlay):
            state.activeOverlay = overlay
            recordCommandHistory(
                StageCommandHistoryInput(
                    title: overlay.intent?.title ?? overlay.kind.id.replacingOccurrences(of: "-", with: " ").capitalized,
                    subtitle: overlay.presentationContext.historySubtitle,
                    source: overlay.entrySource,
                    presentationContext: overlay.presentationContext,
                    destinationLabel: ShellCommandDestination.overlay(overlay).displayLabel,
                    recordedAt: now
                ),
                state: &state
            )
            return .none(effects: StageEffect.overlayChanged(overlay))
        case let .presentCommandSheet(intent, source, presentationContext):
            let overlay = ShellOverlayState.commandSheet(
                intent: intent,
                entrySource: source,
                presentationContext: presentationContext
            )
            state.activeOverlay = overlay
            recordCommandHistory(
                StageCommandHistoryInput(
                    title: intent?.title ?? "Add something",
                    subtitle: presentationContext.historySubtitle,
                    source: source,
                    presentationContext: presentationContext,
                    destinationLabel: commandSheetDestinationLabel(
                        intent: intent,
                        source: source,
                        presentationContext: presentationContext
                    ),
                    recordedAt: now
                ),
                state: &state
            )
            return .none(effects: StageEffect.overlayChanged(overlay))
        case let .presentMemoryLens(intent, source, presentationContext, query, goalID, captureID):
            let overlay = ShellOverlayState.memoryLens(
                intent: intent,
                entrySource: source,
                presentationContext: presentationContext,
                query: query,
                goalID: goalID,
                captureID: captureID
            )
            state.activeOverlay = overlay
            recordCommandHistory(
                StageCommandHistoryInput(
                    title: intent?.title ?? "Search Ambitions",
                    subtitle: query.isEmpty ? presentationContext.historySubtitle : "Looked up \"\(query)\".",
                    source: source,
                    presentationContext: presentationContext,
                    destinationLabel: "Search Ambitions",
                    recordedAt: now
                ),
                state: &state
            )
            return .none(effects: StageEffect.overlayChanged(overlay))
        case let .presentCreateGoal(source, seedText, captureID):
            let overlay = ShellOverlayState.createGoal(entrySource: source, query: seedText, captureID: captureID)
            state.activeOverlay = overlay
            recordCommandHistory(
                StageCommandHistoryInput(
                    title: "New goal",
                    subtitle: seedText.isEmpty ? "Opened goal setup from \(source.displayTitle)." : "Started from saved context.",
                    source: source,
                    presentationContext: .createGoal,
                    destinationLabel: "Create Goal",
                    recordedAt: now
                ),
                state: &state
            )
            return .none(effects: StageEffect.overlayChanged(overlay))
        case let .queueTodaySelectionAfterOverlayDismiss(entryContext):
            state.pendingTodayEntryContext = entryContext
            return .none(effects: [
                .proofReference(
                    id: "stage.today.pending-entry-context",
                    affectedObjectIDs: ["surface.today"],
                    inspectionTarget: "surface.today.pending-entry-context"
                )
            ])
        case .dismissOverlay:
            dismissOverlay(state: &state)
            return .none(effects: StageEffect.overlayChanged(nil))
        case let .recordRoute(title, source, presentationContext, destination, receiptBody):
            recordCommandHistory(
                StageCommandHistoryInput(
                    title: title,
                    subtitle: presentationContext.historySubtitle,
                    source: source,
                    presentationContext: presentationContext,
                    destinationLabel: destination.displayLabel,
                    recordedAt: now
                ),
                state: &state
            )
            if let receiptBody {
                state.continuityReceipt = ShellContinuityReceipt(
                    title: "Context carried",
                    body: receiptBody,
                    source: source,
                    destinationLabel: destination.displayLabel
                )
            }
            return .none(effects: [
                .proofReference(
                    id: "stage.route.recorded",
                    affectedObjectIDs: ["stage.route"],
                    inspectionTarget: "stage.route.history"
                )
            ])
        case .fallbackExternalLanding:
            dismissOverlay(state: &state)
            state.selectedSurface = .today
            state.todayEntryContext = .standard
            return .none(effects: StageEffect.surfaceChanged(to: .today))
        case let .noteExternalRoute(route, source):
            state.lastExternalRoute = route
            state.lastExternalRouteSource = source
            return .none(effects: [
                .proofReference(
                    id: "stage.external-route.\(String(describing: source))",
                    affectedObjectIDs: ["stage.external-route"],
                    inspectionTarget: "stage.external-route.history"
                )
            ])
        case let .setContinuityReceipt(receipt):
            state.continuityReceipt = receipt
            return .none(effects: [
                .proofReference(
                    id: receipt == nil ? "stage.continuity-receipt.cleared" : "stage.continuity-receipt.set",
                    affectedObjectIDs: ["stage.continuity-receipt"],
                    inspectionTarget: "stage.continuity-receipt.history"
                )
            ])
        case .clearContinuityReceipt:
            let receipt = state.continuityReceipt
            state.continuityReceipt = nil
            return StageReduction(
                reselectionAction: nil,
                consumedTodayEntryContext: nil,
                consumedPendingTodayEntryContext: nil,
                consumedContinuityReceipt: receipt,
                effects: [
                    .visibleObjectMutation(
                        id: "continuity-receipt.dismissed",
                        affectedObjectIDs: ["stage.continuity-receipt"],
                        consequence: "Continuity receipt dismissed"
                    )
                ]
            )
        case .consumeTodayEntryContext:
            let context = state.todayEntryContext
            state.todayEntryContext = .standard
            return StageReduction(
                reselectionAction: nil,
                consumedTodayEntryContext: context,
                consumedPendingTodayEntryContext: nil,
                consumedContinuityReceipt: nil,
                effects: [
                    .proofReference(
                        id: "stage.today.entry-context.consumed",
                        affectedObjectIDs: ["surface.today"],
                        inspectionTarget: "surface.today.entry-context"
                    )
                ]
            )
        case .consumePendingTodayEntryContext:
            let context = state.pendingTodayEntryContext
            state.pendingTodayEntryContext = nil
            return StageReduction(
                reselectionAction: nil,
                consumedTodayEntryContext: nil,
                consumedPendingTodayEntryContext: context,
                consumedContinuityReceipt: nil,
                effects: [
                    .proofReference(
                        id: "stage.today.pending-entry-context.consumed",
                        affectedObjectIDs: ["surface.today"],
                        inspectionTarget: "surface.today.pending-entry-context"
                    )
                ]
            )
        }
    }

    private static func selectRootSurfaceFromDock(
        _ surface: AmbitionsSurface,
        now: Date,
        state: inout StageState
    ) -> StageReduction {
        let canonicalSurface = surface.canonicalTopLevelTab
        let hadOverlay = state.activeOverlay != nil
        if hadOverlay {
            dismissOverlay(state: &state)
        }

        guard state.selectedSurface == canonicalSurface else {
            selectSurface(canonicalSurface, state: &state)
            return .none(effects: StageEffect.surfaceChanged(to: canonicalSurface))
        }

        guard hadOverlay == false else {
            return .none(effects: StageEffect.overlayChanged(nil))
        }

        return handleCurrentSurfaceReselection(now: now, state: &state)
    }

    private static func handleCurrentSurfaceReselection(
        now: Date,
        state: inout StageState
    ) -> StageReduction {
        let surface = state.selectedSurface

        guard
            state.lastReselectedSurface == surface,
            let previousDate = state.lastSurfaceReselectionDate,
            now.timeIntervalSince(previousDate) <= surfaceReselectionRootThreshold
        else {
            state.lastReselectedSurface = surface
            state.lastSurfaceReselectionDate = now
            return StageReduction(
                reselectionAction: .scrollToTop,
                consumedTodayEntryContext: nil,
                consumedPendingTodayEntryContext: nil,
                consumedContinuityReceipt: nil,
                effects: [
                    .visibleObjectMutation(
                        id: "surface.\(surface.rawValue).scroll-to-top",
                        affectedObjectIDs: ["surface.\(surface.rawValue)"],
                        consequence: "\(surface.title) moved to the top"
                    )
                ]
            )
        }

        resetRoot(for: surface, state: &state)
        state.lastReselectedSurface = nil
        state.lastSurfaceReselectionDate = nil
        return StageReduction(
            reselectionAction: .returnToRoot,
            consumedTodayEntryContext: nil,
            consumedPendingTodayEntryContext: nil,
            consumedContinuityReceipt: nil,
            effects: [
                .visibleObjectMutation(
                    id: "surface.\(surface.rawValue).return-to-root",
                    affectedObjectIDs: ["surface.\(surface.rawValue)"],
                    consequence: "\(surface.title) root restored"
                )
            ]
        )
    }

    private static func selectSurface(_ surface: AmbitionsSurface, state: inout StageState) {
        dismissOverlay(state: &state)
        state.selectedSurface = surface.canonicalTopLevelTab
        if state.selectedSurface != .today {
            state.todayEntryContext = .standard
        }
    }

    private static func dismissOverlay(state: inout StageState) {
        state.activeOverlay = nil
    }

    private static func resetRoot(for surface: AmbitionsSurface, state: inout StageState) {
        switch surface {
        case .today:
            state.todayEntryContext = .standard
        case .goals:
            state.goalsPath = []
        case .time:
            state.timePath = []
        case .you:
            state.youPath = []
        }
    }

    private static func resetFocusedRoutes(state: inout StageState) {
        state.goalsPath = []
        state.timePath = []
        state.youPath = []
    }

    private static func replaceNavigationPath(
        _ path: StageNavigationPath,
        state: inout StageState
    ) -> StageReduction {
        let surface: AmbitionsSurface
        switch path {
        case let .goals(value):
            guard value != state.goalsPath else { return .none() }
            state.goalsPath = value
            surface = .goals
        case let .time(value):
            guard value != state.timePath else { return .none() }
            state.timePath = value
            surface = .time
        case let .you(value):
            guard value != state.youPath else { return .none() }
            state.youPath = value
            surface = .you
        }
        return .none(effects: StageEffect.routeChanged(on: surface))
    }

    private static func popFocusedRoute(state: inout StageState) -> StageReduction {
        let surface = state.selectedSurface
        switch surface {
        case .today:
            return .none()
        case .goals:
            guard state.goalsPath.popLast() != nil else { return .none() }
        case .time:
            guard state.timePath.popLast() != nil else { return .none() }
        case .you:
            guard state.youPath.popLast() != nil else { return .none() }
        }

        return .none(effects: StageEffect.routePopped(to: surface))
    }

    private static func recordCommandHistory(_ input: StageCommandHistoryInput, state: inout StageState) {
        let entry = ShellCommandHistoryEntry(
            title: input.title,
            subtitle: input.subtitle,
            source: input.source,
            presentationContext: input.presentationContext,
            destinationLabel: input.destinationLabel,
            recordedAt: ISO8601DateFormatter().string(from: input.recordedAt)
        )
        state.recentCommandHistory.removeAll {
            $0.title == entry.title && $0.source == entry.source && $0.destinationLabel == entry.destinationLabel
        }
        state.recentCommandHistory.insert(entry, at: 0)
        state.recentCommandHistory = Array(state.recentCommandHistory.prefix(4))
    }

    private static func commandSheetDestinationLabel(
        intent: ShellCommandIntent?,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext
    ) -> String {
        if source == .globalCaptureComposer {
            return "Add something"
        }
        if presentationContext == .quickCapture || intent == .quickCapture {
            return "Capture"
        }
        return "Add something"
    }
}
