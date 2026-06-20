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

enum StageReducer {
    private static let surfaceReselectionRootThreshold: TimeInterval = 0.8

    static func reduce(_ action: StageAction, state: inout StageState) -> StageReduction {
        switch action {
        case let .selectSurface(surface):
            selectSurface(surface, state: &state)
            return .none(effects: StageEffect.surfaceChanged(to: state.selectedSurface))
        case let .selectToday(entryContext):
            dismissOverlay(state: &state)
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
        case .resetGoalsPath:
            state.goalsPath = []
            return .none(effects: [.visibleStageMutation("goals.root")])
        case let .openTimeRoute(target):
            dismissOverlay(state: &state)
            state.selectedSurface = .time
            state.timePath = [target]
            return .none(effects: StageEffect.surfaceChanged(to: .time))
        case .resetTimePath:
            state.timePath = []
            return .none(effects: [.visibleStageMutation("time.root")])
        case let .openYouRoute(target):
            dismissOverlay(state: &state)
            state.selectedSurface = .you
            state.youPath = [target]
            return .none(effects: StageEffect.surfaceChanged(to: .you))
        case .resetYouPath:
            state.youPath = []
            return .none(effects: [.visibleStageMutation("you.root")])
        case let .presentOverlay(overlay):
            state.activeOverlay = overlay
            recordCommandHistory(
                title: overlay.intent?.title ?? overlay.kind.id.replacingOccurrences(of: "-", with: " ").capitalized,
                subtitle: overlay.presentationContext.historySubtitle,
                source: overlay.entrySource,
                presentationContext: overlay.presentationContext,
                destinationLabel: ShellCommandDestination.overlay(overlay).displayLabel,
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
                title: intent?.title ?? "Add something",
                subtitle: presentationContext.historySubtitle,
                source: source,
                presentationContext: presentationContext,
                destinationLabel: commandSheetDestinationLabel(
                    intent: intent,
                    source: source,
                    presentationContext: presentationContext
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
                title: intent?.title ?? "Search Ambitions",
                subtitle: query.isEmpty ? presentationContext.historySubtitle : "Looked up \"\(query)\".",
                source: source,
                presentationContext: presentationContext,
                destinationLabel: "Search Ambitions",
                state: &state
            )
            return .none(effects: StageEffect.overlayChanged(overlay))
        case let .presentCreateGoal(source, seedText, captureID):
            let overlay = ShellOverlayState.createGoal(entrySource: source, query: seedText, captureID: captureID)
            state.activeOverlay = overlay
            recordCommandHistory(
                title: "New goal",
                subtitle: seedText.isEmpty ? "Opened goal setup from \(source.displayTitle)." : "Started from saved context.",
                source: source,
                presentationContext: .createGoal,
                destinationLabel: "Create Goal",
                state: &state
            )
            return .none(effects: StageEffect.overlayChanged(overlay))
        case let .queueTodaySelectionAfterOverlayDismiss(entryContext):
            state.pendingTodayEntryContext = entryContext
            return .none(effects: [.proofArtifact("stage.today.pending-entry-context")])
        case .dismissOverlay:
            dismissOverlay(state: &state)
            return .none(effects: StageEffect.overlayChanged(nil))
        case let .recordRoute(title, source, presentationContext, destination, receiptBody):
            recordCommandHistory(
                title: title,
                subtitle: presentationContext.historySubtitle,
                source: source,
                presentationContext: presentationContext,
                destinationLabel: destination.displayLabel,
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
            return .none(effects: [.proofArtifact("stage.route.recorded")])
        case .fallbackExternalLanding:
            dismissOverlay(state: &state)
            state.selectedSurface = .today
            state.todayEntryContext = .standard
            return .none(effects: StageEffect.surfaceChanged(to: .today))
        case let .noteExternalRoute(route, source):
            state.lastExternalRoute = route
            state.lastExternalRouteSource = source
            return .none(effects: [.proofArtifact("stage.external-route.\(String(describing: source))")])
        case .clearContinuityReceipt:
            let receipt = state.continuityReceipt
            state.continuityReceipt = nil
            return StageReduction(
                reselectionAction: nil,
                consumedTodayEntryContext: nil,
                consumedPendingTodayEntryContext: nil,
                consumedContinuityReceipt: receipt,
                effects: [.visibleStageMutation("continuity-receipt.dismissed")]
            )
        case .consumeTodayEntryContext:
            let context = state.todayEntryContext
            state.todayEntryContext = .standard
            return StageReduction(
                reselectionAction: nil,
                consumedTodayEntryContext: context,
                consumedPendingTodayEntryContext: nil,
                consumedContinuityReceipt: nil,
                effects: [.proofArtifact("stage.today.entry-context.consumed")]
            )
        case .consumePendingTodayEntryContext:
            let context = state.pendingTodayEntryContext
            state.pendingTodayEntryContext = nil
            return StageReduction(
                reselectionAction: nil,
                consumedTodayEntryContext: nil,
                consumedPendingTodayEntryContext: context,
                consumedContinuityReceipt: nil,
                effects: [.proofArtifact("stage.today.pending-entry-context.consumed")]
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
                effects: [.visibleStageMutation("surface.\(surface.rawValue).scroll-to-top")]
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
            effects: [.visibleStageMutation("surface.\(surface.rawValue).return-to-root")]
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

    private static func recordCommandHistory(
        title: String,
        subtitle: String,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext,
        destinationLabel: String,
        state: inout StageState
    ) {
        let entry = ShellCommandHistoryEntry(
            title: title,
            subtitle: subtitle,
            source: source,
            presentationContext: presentationContext,
            destinationLabel: destinationLabel,
            recordedAt: ISO8601DateFormatter().string(from: Date())
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
