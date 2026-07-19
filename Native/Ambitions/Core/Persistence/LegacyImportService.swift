import Foundation

struct LegacyImportService: LegacyImportServicing {
    let goals: any GoalRepository
    let drafts: any GoalDraftRepository
    let appState: any AppStateRepository

    func importSnapshot(_ snapshot: LegacyPrototypeSnapshot) async throws -> LegacyImportReport {
        let importedGoals = try snapshot.goals.map { goalRecord -> Goal in
            let draft = migrateDraft(from: goalRecord)
            let plan = try migratePlan(for: goalRecord, milestones: snapshot.milestones, tasks: snapshot.tasks, draft: draft)
            return Goal(
                schemaVersion: draft.schemaVersion,
                id: goalRecord.id,
                revision: 1,
                createdAt: goalRecord.createdAt,
                updatedAt: goalRecord.updatedAt,
                state: mapLifecycle(goalRecord.goalStatus),
                title: draft.title,
                summary: draft.summary,
                mode: draft.mode,
                relationshipKind: draft.relationshipKind,
                actor: draft.actor,
                parentGoalID: draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: draft.tags,
                timing: draft.timing,
                planningStrategy: draft.planningStrategy,
                progressStrategy: draft.progressStrategy,
                plan: plan,
                lifeGraph: draft.lifeGraph
            )
        }

        let importedDrafts = try snapshot.goals.map { goalRecord in
            let draft = migrateDraft(from: goalRecord)
            let plan = try migratePlan(for: goalRecord, milestones: snapshot.milestones, tasks: snapshot.tasks, draft: draft)
            return PersistedGoalDraft(
                id: "imported-draft-\(goalRecord.id)",
                createdAt: goalRecord.createdAt,
                updatedAt: goalRecord.updatedAt,
                draft: draft,
                classification: nil,
                clarification: nil,
                stagedPlan: plan,
                assumptions: [],
                blockers: [],
                metadata: nil,
                plannedGoalID: plan == nil ? nil : goalRecord.id,
                latestResultKind: plan == nil ? .blocked : .planned
            )
        }

        try await goals.saveGoals(importedGoals)
        try await drafts.saveDrafts(importedDrafts)

        var state = try await appState.loadState()
        if let importedState = snapshot.appState {
            state.preferredTab = importedState.preferredTab
            state.userDisplayName = importedState.userDisplayName
        }

        let summary = LegacyImportSummary(
            importedGoalCount: importedGoals.count,
            importedDraftCount: importedDrafts.count,
            importedPlanCount: importedGoals.filter { $0.plan != nil }.count,
            importedStepCount: importedGoals.flatMap { $0.plan?.sections ?? [] }.flatMap(\.steps).count,
            reusableData: [
                "Historical goals: title, summary, parent linkage, tags, dates, actor metadata, and goal type.",
                "Historical tasks and milestones: dates, status, recurrence hints, and sequencing hints.",
            ],
            referenceOnlyData: [
                "Historical React navigation state and screen-local UI flags.",
                "Expo-specific account/session transport and notification plumbing.",
            ],
            lossyMappings: [
                "Historical recurrence templates collapse to weekly repeat cadence until native recurrence rules land.",
                "Historical milestones import as overview steps rather than a separate milestone entity graph.",
                "Unstructured historical metadata stays reference-only unless it maps to mode, ownership, relationship, or timing.",
            ]
        )

        state.lastImportSummary = summary
        try await appState.saveState(state)

        return LegacyImportReport(
            importedGoalIDs: importedGoals.map(\.id),
            importedDraftIDs: importedDrafts.map(\.id),
            summary: summary
        )
    }
}

private extension LegacyImportService {
    func migrateDraft(from goal: LegacyGoalRecord) -> GoalDraft {
        let mode = inferMode(goal)
        let actor = inferActor(goal)
        let relationship = inferRelationship(goal, actor: actor, mode: mode)
        let timing = inferTiming(goal, mode: mode)

        return GoalDraft(
            schemaVersion: goalEngineSchemaVersion,
            source: .migration,
            title: goal.title,
            summary: goal.summary,
            mode: mode,
            relationshipKind: relationship,
            actor: actor,
            parentGoalID: goal.parentGoalID,
            tags: goal.tags,
            timing: timing,
            planningStrategy: defaultPlanningStrategy(for: mode),
            progressStrategy: defaultProgressStrategy(for: mode, tempo: timing.tempo),
            lifeGraph: inferLifeGraph(goal)
        )
    }

    func migratePlan(for goal: LegacyGoalRecord, milestones: [LegacyMilestoneRecord], tasks: [LegacyTaskRecord], draft: GoalDraft) throws -> GoalPlan? {
        let goalMilestones = milestones.filter { $0.goalID == goal.id }
        let goalTasks = tasks.filter { $0.goalID == goal.id }
        var sections: [PlanSection] = []

        if !goalMilestones.isEmpty {
            let steps = goalMilestones.enumerated().map { index, milestone in
                Step(
                    id: "migrated-step-\(milestone.id)",
                    sectionID: "plan-overview-\(goal.id)",
                    title: milestone.title,
                    summary: milestone.summary,
                    type: draft.mode == .learning ? .learningCheckpoint : .actionUnit,
                    state: milestone.completedAt == nil ? .planned : .completed,
                    owner: draft.actor,
                    timing: GoalTiming(
                        tempo: milestone.targetDate == nil ? .untimed : .targetWindow,
                        timingType: milestone.targetDate == nil ? .logWhenDone : .targetBy,
                        startsOn: goal.startDate,
                        dueAt: nil,
                        targetBy: milestone.targetDate,
                        windowStart: nil,
                        windowEnd: nil,
                        suggestedNextAt: nil,
                        repeatEveryDays: nil,
                        progressReviewCadenceDays: 7
                    ),
                    dependencyStepIDs: [],
                    isOptional: false,
                    isRepeatable: false,
                    evidenceRequired: true,
                    successSignals: [milestone.summary ?? "\(milestone.title) is complete."],
                    actionability: StepActionability(
                        action: milestone.title,
                        completionDefinition: milestone.summary ?? "\(milestone.title) is complete.",
                        evidenceOfCompletion: [milestone.summary ?? "\(milestone.title) is complete."],
                        fallbackMicroStep: "Capture the next visible sign of progress for \(milestone.title.lowercased()).",
                        contextRequirements: []
                    )
                )
            }
            sections.append(PlanSection(id: "plan-overview-\(goal.id)", goalID: goal.id, title: "Milestones", summary: "Imported from historical milestone structure.", kind: .overview, orderIndex: 0, steps: steps))
        }

        let activeTasks = goalTasks.filter { [.ready, .scheduled, .inProgress].contains($0.status) }
        if !activeTasks.isEmpty {
            let steps = activeTasks.enumerated().map { index, task in
                migratedStep(task: task, goal: goal, draft: draft, sectionID: "plan-active-\(goal.id)")
            }
            sections.append(PlanSection(id: "plan-active-\(goal.id)", goalID: goal.id, title: "Current Steps", summary: "Imported active work from the historical task model.", kind: .activeSteps, orderIndex: sections.count, steps: steps))
        }

        let completedTasks = goalTasks.filter { $0.status == .completed }
        if !completedTasks.isEmpty {
            let steps = completedTasks.map { migratedStep(task: $0, goal: goal, draft: draft, sectionID: "plan-completed-\(goal.id)") }
            sections.append(PlanSection(id: "plan-completed-\(goal.id)", goalID: goal.id, title: "Completed", summary: "Preserved for continuity and insights reconstruction.", kind: .completed, orderIndex: sections.count, steps: steps))
        }

        guard !sections.isEmpty else { return nil }
        let plan = GoalPlan(
            id: "migrated-plan-\(goal.id)",
            goalID: goal.id,
            version: goalEnginePlanVersion,
            generatedAt: goal.updatedAt,
            summary: "Auto-generated from historical goal, task, and milestone records.",
            strategy: draft.planningStrategy,
            sections: sections,
            assumptions: [],
            lint: PlanLintResult(goalID: goal.id, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        )
        return plan
    }

    func migratedStep(task: LegacyTaskRecord, goal: LegacyGoalRecord, draft: GoalDraft, sectionID: String) -> Step {
        let timing = stepTiming(task: task, baseTiming: draft.timing, startDate: goal.startDate)
        return Step(
            id: "migrated-step-\(task.id)",
            sectionID: sectionID,
            title: task.title,
            summary: task.summary,
            type: stepType(for: draft.mode, title: task.title),
            state: stepState(task.status),
            owner: draft.actor,
            timing: timing,
            dependencyStepIDs: task.parentTaskID.map { ["migrated-step-\($0)"] } ?? [],
            isOptional: task.status == .skipped,
            isRepeatable: task.isRecurringTemplate,
            evidenceRequired: task.status != .cancelled,
            successSignals: [task.summary ?? "\(task.title) is complete."],
            actionability: StepActionability(
                action: task.title,
                completionDefinition: task.summary ?? "\(task.title) is complete.",
                evidenceOfCompletion: [task.summary ?? "\(task.title) is complete."],
                fallbackMicroStep: "Do the smallest visible part of \(task.title.lowercased()).",
                contextRequirements: []
            )
        )
    }

    func inferMode(_ goal: LegacyGoalRecord) -> GoalMode {
        let tags = Set(goal.tags.map { $0.lowercased() })
        if tags.contains("learning") { return .learning }
        if tags.contains("exploration") || tags.contains("research") { return .exploration }
        if tags.contains("recovery") { return .recovery }
        if tags.contains("support") || tags.contains("delegated") { return .delegatedSupport }
        if tags.contains("maintenance") { return .maintenance }

        switch goal.goalType {
        case .habit:
            return .habit
        case .system:
            return .maintenance
        case .project:
            return .project
        case .outcome:
            return .achievement
        }
    }

    func inferLifeGraph(_ goal: LegacyGoalRecord) -> LifeGraphContext? {
        let tags = Set(goal.tags.map { $0.lowercased() })
        let metadata = goal.metadata
        var domains: [LifeDomainAssignment] = []
        var roles: [LifeRole] = []
        var path: LifePathDescriptor?

        if tags.contains("career") || tags.contains("work") || metadata["lifeDomain"] == "career" {
            domains.append(LifeDomainAssignment(domain: .career))
        }
        if tags.contains("learning") || tags.contains("education") || metadata["lifeDomain"] == "education" {
            domains.append(LifeDomainAssignment(domain: .education))
        }
        if tags.contains("health") || tags.contains("fitness") || tags.contains("recovery") || metadata["lifeDomain"] == "health" {
            domains.append(LifeDomainAssignment(domain: .health))
        }
        if tags.contains("finance") || tags.contains("money") || metadata["lifeDomain"] == "finance" {
            domains.append(LifeDomainAssignment(domain: .finance))
        }

        if let role = metadata["lifeRole"], role.isEmpty == false {
            roles.append(LifeRole(kind: .responsibility, title: role))
        }
        if let pathTitle = metadata["pathTitle"], pathTitle.isEmpty == false {
            path = LifePathDescriptor(kind: domains.first?.domain == .education ? .educationTrack : .careerTrack, title: pathTitle)
        }

        guard domains.isEmpty == false || roles.isEmpty == false || path != nil else {
            return nil
        }
        return LifeGraphContext(domains: domains, roles: roles, path: path, milestones: [])
    }

    func inferActor(_ goal: LegacyGoalRecord) -> GoalActor {
        let ownership = ExecutionOwnership(rawValue: goal.metadata["executionOwnership"] ?? "") ?? .self
        let displayName = goal.metadata["actorDisplayName"] ?? (ownership == .child ? "Child" : "You")
        return GoalActor(
            actorID: ownership.rawValue,
            displayName: displayName,
            ownership: ownership,
            roleLabel: ownership == .self ? "Primary owner" : "Supported owner",
            isPrimary: true
        )
    }

    func inferRelationship(_ goal: LegacyGoalRecord, actor: GoalActor, mode: GoalMode) -> GoalRelationshipKind {
        if mode == .delegatedSupport { return .support }
        if goal.parentGoalID != nil { return actor.ownership == .self ? .child : .delegated }
        return .independent
    }

    func inferTiming(_ goal: LegacyGoalRecord, mode: GoalMode) -> GoalTiming {
        if let targetDate = goal.targetDate {
            return GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: goal.startDate, dueAt: "\(targetDate)T23:59:59Z", targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7)
        }

        if [.habit, .maintenance, .recovery, .delegatedSupport].contains(mode) {
            return GoalTiming(tempo: .ongoing, timingType: .repeatWithinWindow, startsOn: goal.startDate, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: 7, progressReviewCadenceDays: 7)
        }

        return GoalTiming(tempo: .untimed, timingType: .logWhenDone, startsOn: goal.startDate, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: mode == .exploration ? 5 : 7)
    }

    func stepTiming(task: LegacyTaskRecord, baseTiming: GoalTiming, startDate: String?) -> GoalTiming {
        if let latestFinishAt = task.latestFinishAt {
            return GoalTiming(tempo: baseTiming.tempo, timingType: .dueAt, startsOn: task.scheduledDate ?? startDate, dueAt: latestFinishAt, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: baseTiming.progressReviewCadenceDays)
        }
        if let targetDate = task.targetDate {
            return GoalTiming(tempo: baseTiming.tempo == .untimed ? .targetWindow : baseTiming.tempo, timingType: .targetBy, startsOn: task.scheduledDate ?? startDate, dueAt: nil, targetBy: targetDate, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: baseTiming.progressReviewCadenceDays)
        }
        if task.isRecurringTemplate {
            return GoalTiming(tempo: .ongoing, timingType: .repeatWithinWindow, startsOn: task.scheduledDate ?? startDate, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: 7, progressReviewCadenceDays: 7)
        }
        return GoalTiming(tempo: baseTiming.tempo, timingType: baseTiming.tempo == .untimed ? .logWhenDone : .suggestedNext, startsOn: task.scheduledDate ?? startDate, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: task.earliestStartAt, repeatEveryDays: nil, progressReviewCadenceDays: baseTiming.progressReviewCadenceDays)
    }

    func stepType(for mode: GoalMode, title: String) -> StepType {
        switch mode {
        case .habit, .maintenance:
            return .recurringRoutine
        case .learning:
            return title.lowercased().contains("reflect") ? .reflectionPrompt : .learningCheckpoint
        case .exploration:
            return .explorationExperiment
        case .delegatedSupport:
            return .supportAction
        case .recovery:
            return title.lowercased().contains("log") ? .observationPrompt : .actionUnit
        case .achievement, .project:
            return .actionUnit
        }
    }

    func stepState(_ status: LegacyTaskStatus) -> StepLifecycleState {
        switch status {
        case .inProgress:
            return .active
        case .completed:
            return .completed
        case .cancelled:
            return .cancelled
        case .missed, .deferred:
            return .blocked
        default:
            return .planned
        }
    }

    func mapLifecycle(_ status: LegacyGoalStatus) -> GoalLifecycleState {
        switch status {
        case .draft:
            return .draft
        case .active:
            return .active
        case .paused:
            return .paused
        case .completed:
            return .completed
        case .archived:
            return .archived
        }
    }

    func defaultPlanningStrategy(for mode: GoalMode) -> PlanningStrategy {
        switch mode {
        case .habit, .maintenance:
            return PlanningStrategy(strategyKind: .cadence, allowParallelSteps: true, maxActiveSteps: 3, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .recurringRoutine, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .learning:
            return PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: true, maxActiveSteps: 4, preferredSectionOrder: [.overview, .activeSteps, .resources, .review], defaultStepType: .learningCheckpoint, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .exploration:
            return PlanningStrategy(strategyKind: .exploratory, allowParallelSteps: true, maxActiveSteps: 5, preferredSectionOrder: [.overview, .activeSteps, .supportingWork, .review], defaultStepType: .explorationExperiment, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 5)
        case .delegatedSupport:
            return PlanningStrategy(strategyKind: .supportive, allowParallelSteps: true, maxActiveSteps: 4, preferredSectionOrder: [.overview, .supportingWork, .review], defaultStepType: .supportAction, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .recovery:
            return PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: false, maxActiveSteps: 2, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .actionUnit, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 3)
        case .achievement, .project:
            return PlanningStrategy(strategyKind: .sequential, allowParallelSteps: mode == .project, maxActiveSteps: mode == .project ? 4 : 3, preferredSectionOrder: [.overview, .activeSteps, .upcoming], defaultStepType: .actionUnit, autoGenerateReviewSection: false, preferShortSteps: false, revisitCadenceDays: 7)
        }
    }

    func defaultProgressStrategy(for mode: GoalMode, tempo: GoalTempo) -> ProgressStrategy {
        switch mode {
        case .habit, .maintenance:
            return ProgressStrategy(metricKind: .ritualRhythm, rollupMethod: .rhythmLength, targetStepCount: nil, targetEvidenceCount: 5, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .learning:
            return ProgressStrategy(metricKind: .evidenceCount, rollupMethod: .weightedRatio, targetStepCount: 4, targetEvidenceCount: 8, targetMinutes: 240, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .exploration:
            return ProgressStrategy(metricKind: .observationLog, rollupMethod: .sum, targetStepCount: 5, targetEvidenceCount: 5, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .delegatedSupport:
            return ProgressStrategy(metricKind: .evidenceCount, rollupMethod: .latest, targetStepCount: 3, targetEvidenceCount: 4, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: true, countsSupportGoals: true)
        case .recovery:
            return ProgressStrategy(metricKind: .confidenceGain, rollupMethod: .latest, targetStepCount: 3, targetEvidenceCount: 6, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: true)
        case .achievement, .project:
            return ProgressStrategy(metricKind: tempo == .deadlineBased ? .stepCompletion : .timeInvested, rollupMethod: .ratio, targetStepCount: mode == .project ? 6 : 4, targetEvidenceCount: nil, targetMinutes: tempo == .untimed ? nil : 360, supportsUntimedProgress: tempo == .untimed, countsChildGoals: true, countsSupportGoals: true)
        }
    }
}
