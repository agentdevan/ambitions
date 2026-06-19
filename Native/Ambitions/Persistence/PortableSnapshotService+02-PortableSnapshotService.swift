import Foundation

extension PortableSnapshotService {
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
}
