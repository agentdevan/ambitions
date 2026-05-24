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
    private let conflictPolicyEngine = LocalConflictPolicyEngine()

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
        let loadedCaptures = try await captures
        let loadedTeachingSignals = try await teachingSignals
        let loadedAppState = try await appState

        let exportedGoals = selection.includes(.goalsAndPlans) ? loadedGoals : []
        let exportedDrafts = selection.includes(.goalsAndPlans) ? loadedDrafts : []
        let exportedEvidence = selection.includes(.proof) ? loadedEvidence : []
        let exportedFeedback = selection.includes(.receipts) ? loadedFeedback : []
        let exportedActionReceiptHistory = selection.includes(.receipts) ? loadedActionReceiptHistory : []
        let exportedEntityRevisionTombstones = selection.includes(.receipts) ? loadedEntityRevisionTombstones : []
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

private extension PortableSnapshotService {
    func validate(_ snapshot: PortableAppSnapshot) throws -> [PortableImportWarning] {
        guard snapshot.metadata.schemaVersion == .v1 else {
            throw PortableSnapshotError.unsupportedSchemaVersion(snapshot.metadata.schemaVersion.rawValue)
        }

        return validationWarnings(for: snapshot)
    }

    func replaceLocalStore(with snapshot: PortableAppSnapshot, warnings: [PortableImportWarning]) async throws -> PortableImportReport {
        try await resetStore()
        try await repositories.goals.saveGoals(snapshot.goals)
        try await repositories.drafts.saveDrafts(snapshot.drafts)
        try await repositories.evidence.saveEvidence(snapshot.evidence)

        let feedbackByGoal = Dictionary(grouping: snapshot.feedback, by: \.base.stepID)
        let stepToGoal = Dictionary(
            uniqueKeysWithValues: snapshot.goals.flatMap { goal in
                goal.plan?.sections.flatMap { section in
                    section.steps.map { ($0.id, goal.id) }
                } ?? []
            }
        )
        let groupedByGoal = Dictionary(grouping: snapshot.feedback) { event in
            stepToGoal[event.base.stepID] ?? event.base.stepID
        }
        for (goalID, events) in groupedByGoal {
            try await repositories.feedback.saveEvents(events, goalID: goalID)
        }
        if groupedByGoal.isEmpty && !feedbackByGoal.isEmpty {
            for (goalID, events) in feedbackByGoal {
                try await repositories.feedback.saveEvents(events, goalID: goalID)
            }
        }
        try await saveActionReceiptHistory(snapshot.actionReceiptHistory.map(\.record))
        try await saveEntityRevisionTombstones(snapshot.entityRevisionTombstones)

        try await repositories.captures.saveCaptures(snapshot.captures)
        try await repositories.teaching.saveSignals(snapshot.teachingSignals)
        try await repositories.appState.saveState(snapshot.appState)

        return PortableImportReport(
            mode: .replaceLocalStore,
            importedGoalCount: snapshot.goals.count,
            importedDraftCount: snapshot.drafts.count,
            importedEvidenceCount: snapshot.evidence.count,
            importedFeedbackCount: snapshot.feedback.count,
            importedActionReceiptHistoryCount: snapshot.actionReceiptHistory.count,
            importedEntityRevisionTombstoneCount: snapshot.entityRevisionTombstones.count,
            importedCaptureCount: snapshot.captures.count,
            importedTeachingSignalCount: snapshot.teachingSignals.count,
            importedAppStateCount: 1,
            conflicts: [],
            warnings: warnings
        )
    }

    func mergeWithConflictReport(_ snapshot: PortableAppSnapshot, warnings: [PortableImportWarning]) async throws -> PortableImportReport {
        async let localGoals = repositories.goals.listGoals()
        async let localDrafts = repositories.drafts.listDrafts()
        async let localEvidence = repositories.evidence.listEvidence(goalID: nil)
        async let localFeedback = repositories.feedback.listEvents(goalID: nil)
        async let localCaptures = repositories.captures.listCaptures()
        async let localTeaching = repositories.teaching.listSignals(goalID: nil)
        async let localAppState = repositories.appState.loadState()

        let goalResult = compareGoals(incoming: snapshot.goals, local: try await localGoals)
        let draftResult = compareDrafts(incoming: snapshot.drafts, local: try await localDrafts)
        let evidenceResult = compareEvidence(incoming: snapshot.evidence, local: try await localEvidence)
        let feedbackResult = compareFeedback(incoming: snapshot.feedback, local: try await localFeedback)
        let captureResult = compareCaptures(incoming: snapshot.captures, local: try await localCaptures)
        let teachingResult = compareTeachingSignals(incoming: snapshot.teachingSignals, local: try await localTeaching)
        let appStateResult = compareAppState(incoming: snapshot.appState, local: try await localAppState)

        if !goalResult.accepted.isEmpty {
            try await repositories.goals.saveGoals(goalResult.accepted)
        }
        if !draftResult.accepted.isEmpty {
            try await repositories.drafts.saveDrafts(draftResult.accepted)
        }
        if !evidenceResult.accepted.isEmpty {
            try await repositories.evidence.saveEvidence(evidenceResult.accepted)
        }
        if !feedbackResult.accepted.isEmpty {
            let stepToGoal = Dictionary(
                uniqueKeysWithValues: (try await repositories.goals.listGoals()).flatMap { goal in
                    goal.plan?.sections.flatMap { section in
                        section.steps.map { ($0.id, goal.id) }
                    } ?? []
                }
            )
            let feedbackByGoal = Dictionary(grouping: feedbackResult.accepted) { event in
                stepToGoal[event.base.stepID] ?? event.base.stepID
            }
            for (goalID, events) in feedbackByGoal {
                let existingEvents = try await repositories.feedback.listEvents(goalID: goalID)
                try await repositories.feedback.saveEvents(existingEvents + events, goalID: goalID)
            }
        }
        try await saveActionReceiptHistory(snapshot.actionReceiptHistory.map(\.record))
        try await saveEntityRevisionTombstones(snapshot.entityRevisionTombstones)
        if !captureResult.accepted.isEmpty {
            try await repositories.captures.saveCaptures(captureResult.accepted)
        }
        if !teachingResult.accepted.isEmpty {
            let existing = try await repositories.teaching.listSignals(goalID: nil)
            try await repositories.teaching.saveSignals(existing + teachingResult.accepted)
        }
        if appStateResult.accepted {
            try await repositories.appState.saveState(snapshot.appState)
        }

        return PortableImportReport(
            mode: .mergeWithConflictReport,
            importedGoalCount: goalResult.accepted.count,
            importedDraftCount: draftResult.accepted.count,
            importedEvidenceCount: evidenceResult.accepted.count,
            importedFeedbackCount: feedbackResult.accepted.count,
            importedActionReceiptHistoryCount: snapshot.actionReceiptHistory.count,
            importedEntityRevisionTombstoneCount: snapshot.entityRevisionTombstones.count,
            importedCaptureCount: captureResult.accepted.count,
            importedTeachingSignalCount: teachingResult.accepted.count,
            importedAppStateCount: appStateResult.accepted ? 1 : 0,
            conflicts: goalResult.conflicts + draftResult.conflicts + evidenceResult.conflicts + feedbackResult.conflicts + captureResult.conflicts + teachingResult.conflicts + appStateResult.conflicts,
            warnings: warnings
        )
    }

    func dryRunMergeWithConflictReport(_ snapshot: PortableAppSnapshot, warnings: [PortableImportWarning]) async throws -> PortableImportDryRunReport {
        async let localGoals = repositories.goals.listGoals()
        async let localDrafts = repositories.drafts.listDrafts()
        async let localEvidence = repositories.evidence.listEvidence(goalID: nil)
        async let localFeedback = repositories.feedback.listEvents(goalID: nil)
        async let localCaptures = repositories.captures.listCaptures()
        async let localTeaching = repositories.teaching.listSignals(goalID: nil)
        async let localAppState = repositories.appState.loadState()

        let goalResult = compareGoals(incoming: snapshot.goals, local: try await localGoals)
        let draftResult = compareDrafts(incoming: snapshot.drafts, local: try await localDrafts)
        let evidenceResult = compareEvidence(incoming: snapshot.evidence, local: try await localEvidence)
        let feedbackResult = compareFeedback(incoming: snapshot.feedback, local: try await localFeedback)
        let captureResult = compareCaptures(incoming: snapshot.captures, local: try await localCaptures)
        let teachingResult = compareTeachingSignals(incoming: snapshot.teachingSignals, local: try await localTeaching)
        let appStateResult = compareAppState(incoming: snapshot.appState, local: try await localAppState)

        return PortableImportDryRunReport(
            mode: .mergeWithConflictReport,
            wouldResetLocalStore: false,
            wouldImportGoalCount: goalResult.accepted.count,
            wouldImportDraftCount: draftResult.accepted.count,
            wouldImportEvidenceCount: evidenceResult.accepted.count,
            wouldImportFeedbackCount: feedbackResult.accepted.count,
            wouldImportActionReceiptHistoryCount: snapshot.actionReceiptHistory.count,
            wouldImportEntityRevisionTombstoneCount: snapshot.entityRevisionTombstones.count,
            wouldImportCaptureCount: captureResult.accepted.count,
            wouldImportTeachingSignalCount: teachingResult.accepted.count,
            wouldImportAppStateCount: appStateResult.accepted ? 1 : 0,
            conflicts: goalResult.conflicts + draftResult.conflicts + evidenceResult.conflicts + feedbackResult.conflicts + captureResult.conflicts + teachingResult.conflicts + appStateResult.conflicts,
            warnings: warnings
        )
    }

    func loadActionReceiptHistory() async throws -> [ActionReceiptHistoryRecord] {
        guard let repository = repositories.actionReceiptHistory else {
            return []
        }
        return try await repository.listRecords()
    }

    func loadEntityRevisionTombstones() async throws -> [EntityRevisionTombstone] {
        guard let repository = repositories.entityRevisionTombstones else {
            return []
        }
        return try await repository.fetchRecent(limit: .max)
    }

    func saveActionReceiptHistory(_ records: [ActionReceiptHistoryRecord]) async throws {
        guard let repository = repositories.actionReceiptHistory, records.isEmpty == false else {
            return
        }
        try await repository.save(records)
    }

    func saveEntityRevisionTombstones(_ tombstones: [EntityRevisionTombstone]) async throws {
        guard let repository = repositories.entityRevisionTombstones, tombstones.isEmpty == false else {
            return
        }
        for tombstone in tombstones {
            try await repository.append(tombstone)
        }
    }

    func validationWarnings(for snapshot: PortableAppSnapshot) -> [PortableImportWarning] {
        manifestWarnings(for: snapshot) + referenceWarnings(for: snapshot)
    }

    func manifestWarnings(for snapshot: PortableAppSnapshot) -> [PortableImportWarning] {
        let expectedCounts: [PortableExportCategory: Int] = [
            .goalsAndPlans: snapshot.goals.count + snapshot.drafts.count,
            .captures: snapshot.captures.count,
            .proof: snapshot.evidence.count,
            .receipts: snapshot.feedback.count + snapshot.actionReceiptHistory.count + snapshot.entityRevisionTombstones.count,
            .memory: snapshot.teachingSignals.count,
            .settings: snapshot.appState == .default ? 0 : 1
        ]

        return PortableExportCategory.allCases.compactMap { category in
            guard let summary = snapshot.manifest.summary(for: category) else {
                return PortableImportWarning(
                    id: "manifest.missing.\(category.rawValue)",
                    message: "\(category.title) is missing from the package manifest. Review this package before import."
                )
            }
            guard summary.itemCount != expectedCounts[category] else { return nil }
            return PortableImportWarning(
                id: "manifest.count.\(category.rawValue)",
                message: "\(category.title) count does not match the package contents. Review this package before import."
            )
        }
    }

    func referenceWarnings(for snapshot: PortableAppSnapshot) -> [PortableImportWarning] {
        let goalIDs = Set(snapshot.goals.map(\.id))
        let stepIDs = Set(
            snapshot.goals.flatMap { goal in
                goal.plan?.sections.flatMap { section in
                    section.steps.map(\.id)
                } ?? []
            }
        )
        var warnings: [PortableImportWarning] = []

        warnings += snapshot.drafts
            .compactMap { draft -> PortableImportWarning? in
                guard let goalID = draft.plannedGoalID, goalIDs.contains(goalID) == false else {
                    return nil
                }
                return PortableImportWarning(
                    id: "reference.draft.\(draft.id).planned_goal",
                    message: "A draft in this package points to a goal that is not included. Review placement before trusting the restore."
                )
            }

        warnings += snapshot.evidence
            .filter { goalIDs.contains($0.goalID) == false }
            .map {
                PortableImportWarning(
                    id: "reference.evidence.\($0.id).goal",
                    message: "A proof item in this package points to a goal that is not included. It will not be silently discarded, but it needs review."
                )
            }

        warnings += snapshot.feedback
            .filter { stepIDs.contains($0.base.stepID) == false }
            .map {
                PortableImportWarning(
                    id: "reference.feedback.\($0.base.id).step",
                    message: "A receipt in this package points to a Step that is not included. It will not be silently discarded, but it needs review."
                )
            }

        warnings += snapshot.captures
            .compactMap { capture -> PortableImportWarning? in
                guard let goalID = capture.linkedGoalID, goalIDs.contains(goalID) == false else {
                    return nil
                }
                return PortableImportWarning(
                    id: "reference.capture.\(capture.id).goal",
                    message: "A capture in this package points to a goal that is not included. Review its destination after import."
                )
            }

        warnings += snapshot.teachingSignals
            .filter { goalIDs.contains($0.goalID) == false }
            .map {
                PortableImportWarning(
                    id: "reference.memory.\($0.id).goal",
                    message: "A memory correction in this package points to a goal that is not included. Review before applying it broadly."
                )
            }

        if let lastOpenedGoalID = snapshot.appState.lastOpenedGoalID, goalIDs.contains(lastOpenedGoalID) == false {
            warnings.append(
                PortableImportWarning(
                    id: "reference.app_state.last_opened_goal",
                    message: "The package remembers a last-opened goal that is not included. Navigation can fall back safely."
                )
            )
        }

        return warnings
    }

    func compareGoals(incoming: [Goal], local: [Goal]) -> (accepted: [Goal], conflicts: [PortableConflict]) {
        let localByID = Dictionary(uniqueKeysWithValues: local.map { ($0.id, $0) })
        var accepted: [Goal] = []
        var conflicts: [PortableConflict] = []

        for item in incoming {
            guard let localItem = localByID[item.id] else {
                accepted.append(item)
                continue
            }

            let decision = conflictPolicyEngine.decide(
                ConflictPolicyCandidate(
                    entityKind: PortableConflictEntityKind.goal.rawValue,
                    localRevision: localItem.revision,
                    incomingRevision: item.revision,
                    localUpdatedAt: localItem.updatedAt,
                    incomingUpdatedAt: item.updatedAt,
                    valuesAreEqual: item == localItem
                )
            )
            switch decision.signal {
            case .noConflict:
                continue
            case .acceptIncoming:
                accepted.append(item)
            case .keepLocal, .requiresUserDecision:
                conflicts.append(makeConflict(kind: .goal, entityID: item.id, decision: decision))
            }
        }

        return (accepted, conflicts)
    }

    func compareDrafts(incoming: [PersistedGoalDraft], local: [PersistedGoalDraft]) -> (accepted: [PersistedGoalDraft], conflicts: [PortableConflict]) {
        compareByUpdatedAt(
            kind: .draft,
            incoming: incoming,
            local: local,
            id: \.id,
            updatedAt: \.updatedAt
        )
    }

    func compareEvidence(incoming: [ProgressEvidence], local: [ProgressEvidence]) -> (accepted: [ProgressEvidence], conflicts: [PortableConflict]) {
        compareByUpdatedAt(
            kind: .evidence,
            incoming: incoming,
            local: local,
            id: \.id,
            updatedAt: \.capturedAt
        )
    }

    func compareFeedback(incoming: [GoalFeedbackEvent], local: [GoalFeedbackEvent]) -> (accepted: [GoalFeedbackEvent], conflicts: [PortableConflict]) {
        compareByUpdatedAt(
            kind: .feedback,
            incoming: incoming,
            local: local,
            id: \.base.id,
            updatedAt: \.base.occurredAt
        )
    }

    func compareCaptures(incoming: [Capture], local: [Capture]) -> (accepted: [Capture], conflicts: [PortableConflict]) {
        compareByUpdatedAt(
            kind: .capture,
            incoming: incoming,
            local: local,
            id: \.id,
            updatedAt: \.updatedAt
        )
    }

    func compareTeachingSignals(incoming: [GoalTeachingSignal], local: [GoalTeachingSignal]) -> (accepted: [GoalTeachingSignal], conflicts: [PortableConflict]) {
        compareByUpdatedAt(
            kind: .teachingSignal,
            incoming: incoming,
            local: local,
            id: \.id,
            updatedAt: \.updatedAt
        )
    }

    func compareAppState(incoming: AppStateSnapshot, local: AppStateSnapshot) -> (accepted: Bool, conflicts: [PortableConflict]) {
        if local == .default {
            return (true, [])
        }
        let decision = conflictPolicyEngine.decide(
            ConflictPolicyCandidate(
                entityKind: PortableConflictEntityKind.appState.rawValue,
                localUpdatedAt: appStateMarker(local),
                incomingUpdatedAt: appStateMarker(incoming),
                valuesAreEqual: incoming == local,
                safeAutomaticMergeAllowed: false
            )
        )
        guard decision.signal != .noConflict else {
            return (false, [])
        }
        return (false, [makeConflict(kind: .appState, entityID: local.id, decision: decision)])
    }

    func compareByUpdatedAt<Item: Equatable>(
        kind: PortableConflictEntityKind,
        incoming: [Item],
        local: [Item],
        id: KeyPath<Item, String>,
        updatedAt: KeyPath<Item, String>
    ) -> (accepted: [Item], conflicts: [PortableConflict]) {
        let localByID = Dictionary(uniqueKeysWithValues: local.map { ($0[keyPath: id], $0) })
        var accepted: [Item] = []
        var conflicts: [PortableConflict] = []

        for item in incoming {
            let itemID = item[keyPath: id]
            guard let localItem = localByID[itemID] else {
                accepted.append(item)
                continue
            }

            let decision = conflictPolicyEngine.decide(
                ConflictPolicyCandidate(
                    entityKind: kind.rawValue,
                    localUpdatedAt: localItem[keyPath: updatedAt],
                    incomingUpdatedAt: item[keyPath: updatedAt],
                    valuesAreEqual: item == localItem
                )
            )
            switch decision.signal {
            case .noConflict:
                continue
            case .acceptIncoming:
                accepted.append(item)
            case .keepLocal, .requiresUserDecision:
                conflicts.append(makeConflict(kind: kind, entityID: itemID, decision: decision))
            }
        }

        return (accepted, conflicts)
    }

    func makeConflict(
        kind: PortableConflictEntityKind,
        entityID: String,
        decision: ConflictPolicyDecision
    ) -> PortableConflict {
        let recommendation: PortableConflictResolutionRecommendation
        switch decision.signal {
        case .acceptIncoming:
            recommendation = .acceptIncoming
        case .keepLocal:
            recommendation = .keepLocal
        case .requiresUserDecision, .noConflict:
            recommendation = .requiresUserDecision
        }
        return makeConflict(
            kind: kind,
            entityID: entityID,
            localMarker: decision.localMarker,
            incomingMarker: decision.incomingMarker,
            recommendation: recommendation,
            reason: decision.reason
        )
    }

    func makeConflict(
        kind: PortableConflictEntityKind,
        entityID: String,
        localMarker: String?,
        incomingMarker: String?,
        recommendation: PortableConflictResolutionRecommendation,
        reason: String
    ) -> PortableConflict {
        PortableConflict(
            id: "\(kind.rawValue):\(entityID)",
            entityKind: kind,
            entityID: entityID,
            localRevisionMarker: localMarker,
            incomingRevisionMarker: incomingMarker,
            recommendation: recommendation,
            reason: reason
        )
    }

    func appStateMarker(_ state: AppStateSnapshot) -> String {
        [
            state.lastBootstrapAt,
            state.lastSeededAt,
            state.lastOpenedGoalID,
            state.userDisplayName,
            state.preferredTab.rawValue
        ]
        .compactMap { $0 }
        .joined(separator: "|")
    }

}
