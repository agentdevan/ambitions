import AmbitionsDesignSystem
import Foundation

/// A production-grade implementation of `YouServicing` that aggregates and orchestrates settings,
/// system preferences, trust parameters, and external service permissions.
///
/// `RepositoryBackedYouService` is responsible for querying local repositories concurrently to load active database state,
/// resolving on-device security policies, and compiling them into a thread-safe `YouDashboard`.
struct RepositoryBackedYouService: YouServicing {
    let repositories: AppRepositories
    let syncCapability: any SyncCapability
    let notificationService: any NotificationServicing
    let calendarRemindersService: any CalendarRemindersServicing

    /// Initializes the service with designated repositories and integration dependencies.
    ///
    /// - Parameters:
    ///   - repositories: The container holding references to all on-device data repositories.
    ///   - syncCapability: The sync capability engine, defaulting to local-only sync.
    ///   - notificationService: The system-level notification coordinator, defaulting to a stub implementation.
    ///   - calendarRemindersService: The coordination agent for EventKit boundaries, defaulting to a stub implementation.
    init(
        repositories: AppRepositories,
        syncCapability: any SyncCapability = LocalOnlySyncCapability(),
        notificationService: any NotificationServicing = StubNotificationService(),
        calendarRemindersService: any CalendarRemindersServicing = StubCalendarRemindersService()
    ) {
        self.repositories = repositories
        self.syncCapability = syncCapability
        self.notificationService = notificationService
        self.calendarRemindersService = calendarRemindersService
    }

    /// Compiles a thread-safe dashboard representation by reading user data models and authorization parameters concurrently.
    ///
    /// - Returns: A `YouDashboard` projection suited for rendering in visual and non-visual surfaces.
    /// - Throws: An error if loading data snapshot fails.
    func loadYouDashboard() async throws -> YouDashboard {
        async let snapshot = loadSnapshot()
        async let syncStatus = syncCapability.status()
        async let notificationAuthorization = notificationService.currentAuthorizationState()
        async let remindersAuthorization = calendarRemindersService.authorizationState(for: .reminders)
        async let calendarAuthorization = calendarRemindersService.authorizationState(for: .calendarEvents)
        
        return try await makeDashboard(
            snapshot: snapshot,
            syncStatus: syncStatus,
            notificationAuthorization: notificationAuthorization,
            remindersAuthorization: remindersAuthorization,
            calendarAuthorization: calendarAuthorization
        )
    }

    /// Persists visual accent and functional preference updates to on-device storage.
    /// Enforces programmatic preconditions and strict local-only privacy invariants.
    ///
    /// - Parameter preferences: The preference patch containing requested changes.
    /// - Returns: The updated, thread-safe dashboard representation.
    /// - Throws: An error if persistence fails.
    func saveYouPreferences(_ preferences: YouPreferencesUpdate) async throws -> YouDashboard {
        // Assert thread-safety and input range integrity under Swift 6 rules
        precondition(preferences.reviewCadenceDays >= 0, "Review cadence days cannot be negative.")
        
        var state = try await repositories.appState.loadState()
        state.preferredTab = preferences.preferredTab.canonicalTopLevelTab
        state.appearancePreference = preferences.appearancePreference
        state.accentFamily = preferences.accentFamily
        state.reviewCadenceDays = max(1, preferences.reviewCadenceDays)
        
        // Enforce the core local-first privacy boundary
        state.localOnlyModeEnabled = true
        
        try await repositories.appState.saveState(state)
        return try await loadYouDashboard()
    }
}
extension RepositoryBackedYouService {
    func makePersonalRuntimeLearningSignalInspectionItems(
        _ signals: [PersonalRuntimeLearningSignal]
    ) -> [YouRuntimeInspectionItem] {
        signals.map { signal in
            let state: AmbitionVisualState
            switch signal.confidenceState {
            case .active:
                state = .success
            case .reviewRequired:
                state = .warning
            case .disabled, .reset, .deleted:
                state = .default
            }

            return YouRuntimeInspectionItem(
                id: "runtime-inspection-personal-\(signal.signalType.rawValue)-\(signal.id)",
                kind: .learned,
                title: "What Personal system learned from momentum reflow",
                summary: signal.personalRuntimeInspectableSummary,
                sourceLabel: signal.sourceRecordLabel,
                controlLabel: signal.isExcludedFromFutureRanking
                    ? "Reset, disable, delete, or export in Search Ambitions"
                    : "Inspect in Search Ambitions",
                privacyLabel: signal.personalRuntimeInspectionLabel,
                state: state,
                accessibilityLabel: "Momentum reflow learning signal",
                accessibilityValue: signal.personalRuntimeInspectableSummary,
                accessibilityHint: "Shows the source-tied momentum reflow learning signal, its review boundary, and the local controls available in Search Ambitions."
            )
        }
    }

    func makePersonalRuntimeLearningSignalControls(
        _ signals: [PersonalRuntimeLearningSignal]
    ) -> [YouLocalLearningControl] {
        signals.flatMap { signal in
            let sourceLabel = signal.sourceRecordLabel
            let availabilityLabel = signal.requiresSensitiveReview
                ? "Review required"
                : (signal.isExcludedFromFutureRanking ? "Excluded from future ranking" : "Available in Search Ambitions")
            let boundaryLabel = signal.medicalAdviceBoundarySummary

            return [
                YouLocalLearningControl(
                    id: "personal-runtime-reset-\(signal.id)",
                    title: "Reset momentum reflow learning",
                    summary: signal.resetting().personalRuntimeInspectableSummary,
                    sourceLabel: sourceLabel,
                    availabilityLabel: availabilityLabel,
                    receiptLabel: signal.exportSelection(includingRelatedSource: true).summary,
                    boundaryLabel: boundaryLabel,
                    state: signal.isExcludedFromFutureRanking ? .warning : .default,
                    accessibilityLabel: "Reset momentum reflow learning",
                    accessibilityValue: availabilityLabel,
                    accessibilityHint: "Resets the momentum reflow learning signal while preserving the local receipt and replay boundary."
                ),
                YouLocalLearningControl(
                    id: "personal-runtime-disable-\(signal.id)",
                    title: "Disable momentum reflow learning",
                    summary: signal.disabling().personalRuntimeInspectableSummary,
                    sourceLabel: sourceLabel,
                    availabilityLabel: availabilityLabel,
                    receiptLabel: signal.deleteSelection(includingRelatedSource: false).summary,
                    boundaryLabel: boundaryLabel,
                    state: signal.isExcludedFromFutureRanking ? .warning : .default,
                    accessibilityLabel: "Disable momentum reflow learning",
                    accessibilityValue: availabilityLabel,
                    accessibilityHint: "Disables reuse of the momentum reflow learning signal without silently mutating the source record."
                ),
                YouLocalLearningControl(
                    id: "personal-runtime-delete-\(signal.id)",
                    title: "Delete momentum reflow learning",
                    summary: signal.deleting().personalRuntimeInspectableSummary,
                    sourceLabel: sourceLabel,
                    availabilityLabel: "Needs confirmation",
                    receiptLabel: signal.deleteSelection(includingRelatedSource: true).summary,
                    boundaryLabel: boundaryLabel,
                    state: .warning,
                    accessibilityLabel: "Delete momentum reflow learning",
                    accessibilityValue: "Needs confirmation",
                    accessibilityHint: "Deletes or tombstones the momentum reflow learning signal according to the selected choice."
                ),
                YouLocalLearningControl(
                    id: "personal-runtime-export-\(signal.id)",
                    title: "Export momentum reflow learning",
                    summary: signal.exportSelection(includingRelatedSource: true).summary,
                    sourceLabel: sourceLabel,
                    availabilityLabel: "Summary plus related source",
                    receiptLabel: signal.exportSelection(includingRelatedSource: true).summary,
                    boundaryLabel: boundaryLabel,
                    state: .success,
                    accessibilityLabel: "Export momentum reflow learning",
                    accessibilityValue: "Summary plus related source",
                    accessibilityHint: "Exports the momentum reflow signal and related source when selected."
                )
            ]
        }
    }
}
