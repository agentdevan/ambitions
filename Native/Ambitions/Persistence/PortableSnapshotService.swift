import Foundation

protocol PortableSnapshotServicing: Sendable {
    func exportSnapshot() async throws -> PortableAppSnapshot
    func exportSnapshot(selection: PortableExportSelection) async throws -> PortableAppSnapshot
    func manualMergePlan(for snapshot: PortableAppSnapshot) async throws -> PortableManualMergePlan
    func dryRunImportSnapshot(_ snapshot: PortableAppSnapshot, mode: PortableImportMode) async throws -> PortableImportDryRunReport
    func importSnapshot(_ snapshot: PortableAppSnapshot, mode: PortableImportMode) async throws -> PortableImportReport
}

struct PortableSnapshotService: PortableSnapshotServicing {
    let repositories: AppRepositories
    let resetStore: @Sendable () async throws -> Void
    let conflictPolicyEngine = LocalConflictPolicyEngine()

    init(
        repositories: AppRepositories,
        resetStore: @escaping @Sendable () async throws -> Void
    ) {
        self.repositories = repositories
        self.resetStore = resetStore
    }

    func exportSnapshot() async throws -> PortableAppSnapshot {
        try await exportSnapshot(selection: .all)
    }

    func exportSnapshot(selection: PortableExportSelection) async throws -> PortableAppSnapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let captures = repositories.captures.listCaptures()
        async let teachingSignals = repositories.teaching.listSignals(goalID: nil)
        async let appState = repositories.appState.loadState()

        let loadedGoals = try await goals
        let loadedDrafts = try await drafts
        let loadedEvidence = try await evidence
        let loadedFeedback = try await feedback
        let loadedActionReceiptHistory = try await loadActionReceiptHistory()
        let loadedEntityRevisionTombstones = try await loadEntityRevisionTombstones()
        let loadedEntityRevisionLineageViews = loadedEntityRevisionTombstones.map(\.exportSafeLineageView)
        let loadedCaptures = try await captures
        let loadedTeachingSignals = try await teachingSignals
        let loadedAppState = try await appState

        let exportedGoals = selection.includes(.goalsAndPlans) ? loadedGoals : []
        let exportedDrafts = selection.includes(.goalsAndPlans) ? loadedDrafts : []
        let exportedEvidence = selection.includes(.proof) ? loadedEvidence : []
        let exportedFeedback = selection.includes(.receipts) ? loadedFeedback : []
        let exportedActionReceiptHistory = selection.includes(.receipts) ? loadedActionReceiptHistory : []
        let exportedEntityRevisionTombstones = selection.includes(.receipts) ? loadedEntityRevisionTombstones.map(\.exportSafeTombstone) : []
        let exportedEntityRevisionLineageViews = selection.includes(.receipts) ? loadedEntityRevisionLineageViews : []
        let exportedCaptures = selection.includes(.captures) ? loadedCaptures : []
        let exportedTeachingSignals = selection.includes(.memory) ? loadedTeachingSignals : []
        let exportedAppState = selection.includes(.settings) ? loadedAppState : .default

        return PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: .v1,
                exportedAt: DomainTimestamp.string(from: .now),
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: exportedGoals,
            drafts: exportedDrafts,
            evidence: exportedEvidence,
            feedback: exportedFeedback,
            actionReceiptHistory: exportedActionReceiptHistory.map(PortableStoredActionReceiptHistoryRecord.init),
            entityRevisionTombstones: exportedEntityRevisionTombstones,
            entityRevisionLineageViews: exportedEntityRevisionLineageViews,
            captures: exportedCaptures,
            teachingSignals: exportedTeachingSignals,
            appState: exportedAppState,
            manifest: PortableExportManifest.make(
                selection: selection,
                goals: exportedGoals,
                drafts: exportedDrafts,
                evidence: exportedEvidence,
                feedback: exportedFeedback,
                actionReceiptHistory: exportedActionReceiptHistory.map(PortableStoredActionReceiptHistoryRecord.init),
                entityRevisionTombstones: exportedEntityRevisionTombstones,
                entityRevisionLineageViews: exportedEntityRevisionLineageViews,
                captures: exportedCaptures,
                teachingSignals: exportedTeachingSignals,
                appState: exportedAppState
            )
        )
    }

    func dryRunImportSnapshot(_ snapshot: PortableAppSnapshot, mode: PortableImportMode) async throws -> PortableImportDryRunReport {
        let warnings = try validate(snapshot)

        switch mode {
        case .replaceLocalStore:
            return PortableImportDryRunReport(
                mode: .replaceLocalStore,
                wouldResetLocalStore: true,
                wouldImportGoalCount: snapshot.goals.count,
                wouldImportDraftCount: snapshot.drafts.count,
                wouldImportEvidenceCount: snapshot.evidence.count,
                wouldImportFeedbackCount: snapshot.feedback.count,
                wouldImportActionReceiptHistoryCount: snapshot.actionReceiptHistory.count,
                wouldImportEntityRevisionTombstoneCount: snapshot.entityRevisionTombstones.count,
                wouldImportCaptureCount: snapshot.captures.count,
                wouldImportTeachingSignalCount: snapshot.teachingSignals.count,
                wouldImportAppStateCount: 1,
                conflicts: [],
                warnings: warnings
            )
        case .mergeWithConflictReport:
            return try await dryRunMergeWithConflictReport(snapshot, warnings: warnings)
        }
    }

    func manualMergePlan(for snapshot: PortableAppSnapshot) async throws -> PortableManualMergePlan {
        let dryRun = try await dryRunImportSnapshot(snapshot, mode: .mergeWithConflictReport)
        return PortableManualMergePlan(dryRunReport: dryRun)
    }

    func importSnapshot(_ snapshot: PortableAppSnapshot, mode: PortableImportMode) async throws -> PortableImportReport {
        let warnings = try validate(snapshot)

        switch mode {
        case .replaceLocalStore:
            return try await replaceLocalStore(with: snapshot, warnings: warnings)
        case .mergeWithConflictReport:
            return try await mergeWithConflictReport(snapshot, warnings: warnings)
        }
    }
}
