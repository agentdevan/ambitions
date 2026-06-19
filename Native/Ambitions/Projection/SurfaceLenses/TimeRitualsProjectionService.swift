import Foundation

struct RepositoryBackedTimeRitualsService: HabitsServicing {
    let repositories: AppRepositories

    func loadDashboard(now: Date) async throws -> HabitsDashboard {
        let snapshot = try await loadSnapshot()
        return makeDashboard(snapshot: snapshot, now: now)
    }

    func performAction(_ request: HabitActionRequest, now: Date) async throws -> HabitActionResponse {
        guard var goal = try await repositories.goals.goal(id: request.target.goalID),
              let step = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == request.target.stepID }) else {
            return HabitActionResponse(
                message: HabitInlineMessage(
                    title: "Ritual moved",
                    body: "That routine is no longer available in the current native snapshot.",
                    state: .warning
                )
            )
        }

        let cadenceDays = HabitGoalSemantics.cadenceDays(goal: goal, step: step)
        var feedback = try await repositories.feedback.listEvents(goalID: goal.id)
        let timestamp = Self.iso.string(from: now)
        let base = GoalFeedbackEventBase(
            id: "habit-\(request.kind.rawValue)-\(UUID().uuidString)",
            stepID: step.id,
            occurredAt: timestamp,
            note: note(for: request.kind, step: step)
        )

        let message: HabitInlineMessage
        var proofArtifactID: String?

        switch request.kind {
        case .complete:
            feedback.append(.completed(base: base, actualDuration: stepMinutes(for: goal.mode), effortLevel: .low, confidenceDelta: 0.06))
            try await repositories.feedback.saveEvents(feedback, goalID: goal.id)
            let evidenceID = "habit-evidence-\(UUID().uuidString)"
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: evidenceID,
                    goalID: goal.id,
                    stepID: step.id,
                    evidenceKind: .habitCompletion,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.16,
                    confidenceDelta: 0.06,
                    minutesInvested: stepMinutes(for: goal.mode),
                    note: Self.completeNote
                )
            ])
            proofArtifactID = evidenceID
            goal = advance(goal: goal, step: step, now: now, cadenceDays: cadenceDays)
            try await repositories.goals.saveGoals([goal])
            message = HabitInlineMessage(
                title: "Ritual logged",
                body: "Today's full version is recorded. The rhythm stays active without pretending the loop is finished forever.",
                state: .success
            )
        case .minimumVersion:
            let evidenceID = "habit-evidence-\(UUID().uuidString)"
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: evidenceID,
                    goalID: goal.id,
                    stepID: step.id,
                    evidenceKind: .habitMinimumVersion,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.08,
                    confidenceDelta: 0.03,
                    minutesInvested: 5,
                    note: "\(Self.minimumNotePrefix)\(step.actionability.fallbackMicroStep)"
                )
            ])
            proofArtifactID = evidenceID
            goal = advance(goal: goal, step: step, now: now, cadenceDays: cadenceDays)
            try await repositories.goals.saveGoals([goal])
            message = HabitInlineMessage(title: "Minimum version counts", body: step.actionability.fallbackMicroStep, state: .success)
        case .quickLog:
            let evidenceID = "habit-evidence-\(UUID().uuidString)"
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: evidenceID,
                    goalID: goal.id,
                    stepID: step.id,
                    evidenceKind: .habitQuickLog,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.05,
                    confidenceDelta: 0.02,
                    minutesInvested: 10,
                    note: Self.quickLogNote
                )
            ])
            proofArtifactID = evidenceID
            message = HabitInlineMessage(title: "Signal captured", body: "Progress was logged without forcing a full completion label.", state: .selected)
        case .delay:
            feedback.append(.delayed(base: base, timingAdjustment: .laterToday, date: nil))
            try await repositories.feedback.saveEvents(feedback, goalID: goal.id)
            proofArtifactID = base.id
            goal = update(goal: goal, stepID: step.id) { current in
                stepCopy(from: current, timing: shiftedTiming(current.timing, now: now, adjustment: .laterToday))
            }
            try await repositories.goals.saveGoals([goal])
            message = HabitInlineMessage(title: "Delayed without drama", body: "The routine stays live, but the system is no longer treating it like it had to happen right now.", state: .selected)
        case .skip:
            feedback.append(.skipped(base: base, reasonCode: .notNow))
            try await repositories.feedback.saveEvents(feedback, goalID: goal.id)
            proofArtifactID = base.id
            goal = update(goal: goal, stepID: step.id) { current in
                stepCopy(from: current, timing: HabitGoalSemantics.advancedTiming(from: current.timing, now: now, cadenceDays: cadenceDays))
            }
            try await repositories.goals.saveGoals([goal])
            message = HabitInlineMessage(title: "Skipped, still okay", body: "Today's window was intentionally let go. The next cadence point is already in place.", state: .warning)
        case .needsEasierVersion:
            feedback.append(.askedForSmallerVersion(base: base))
            try await repositories.feedback.saveEvents(feedback, goalID: goal.id)
            proofArtifactID = base.id
            message = HabitInlineMessage(title: "Easier version noted", body: "Use this minimum version next: \(step.actionability.fallbackMicroStep)", state: .selected)
        case .markNotRelevant:
            feedback.append(.notRelevant(base: base))
            try await repositories.feedback.saveEvents(feedback, goalID: goal.id)
            proofArtifactID = base.id
            goal = Goal(schemaVersion: goal.schemaVersion, id: goal.id, revision: goal.revision + 1, createdAt: goal.createdAt, updatedAt: timestamp, state: .paused, title: goal.title, summary: goal.summary, mode: goal.mode, relationshipKind: goal.relationshipKind, actor: goal.actor, parentGoalID: goal.parentGoalID, childGoalIDs: goal.childGoalIDs, supportGoalIDs: goal.supportGoalIDs, tags: goal.tags, timing: goal.timing, planningStrategy: goal.planningStrategy, progressStrategy: goal.progressStrategy, plan: goal.plan, lifeGraph: goal.lifeGraph)
            try await repositories.goals.saveGoals([goal])
            message = HabitInlineMessage(title: "Routine flagged for review", body: "This routine has been softened out of the active loop until the ritual plan is corrected.", state: .warning)
        case .openDetail:
            message = HabitInlineMessage(title: "Opening ritual context", body: "This ritual is linked back to the full goal context so cadence, support language, and replanning all stay aligned.", state: .selected)
        }

        return HabitActionResponse(message: message, proofArtifactID: proofArtifactID)
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listHabitGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let appState = repositories.appState.loadState()

        return try await Snapshot(goals: goals, drafts: drafts, evidence: evidence, feedback: feedback, appState: appState)
    }
}
