@testable import Ambitions
import AmbitionsDesignSystem
import Foundation
import XCTest

class TodayViewModelTestCase: XCTestCase {}

extension TodayViewModelTestCase {
    func f02VisibleRailCopy(_ rail: AmbitionsDayRailViewState) -> String {
        var copy = [
            rail.dateTitle,
            rail.contextSummary,
            rail.contextLabels.map(\.label).joined(separator: " "),
            rail.heroStep == nil ? "Start here Nothing needs you right now." : "Start here",
            rail.heroStep?.title,
            rail.heroStep?.subtitle,
            rail.heroStep?.duration.label,
            rail.heroStep?.fitLabel,
            rail.heroStep?.sourceQualityLabel,
            rail.heroStep?.becauseLine,
            rail.heroStep?.receiptLabel,
            rail.heroStep?.proofLabel,
            rail.heroStep?.sourceRecordLabel,
            rail.heroStep?.replayTraceLabel,
            rail.heroStep?.replayInspectionLabel,
            rail.heroStep?.contextEdge.title,
            rail.heroStep?.contextEdge.summary,
            rail.heroStep?.timeFitProof.title,
            rail.heroStep?.timeFitProof.detail,
            rail.heroStep?.goalThread.title,
            rail.heroStep?.goalThread.summary,
            rail.heroStep?.receiptItem.accessibilitySummary,
            rail.heroStep?.primaryAction.title,
            rail.heroStep?.secondaryAction?.title,
            "Now",
            "Next",
            "Later",
            rail.rows.map { "\($0.slot.rawValue) \($0.title) \($0.subtitle) \($0.duration.label)" }.joined(separator: " "),
            rail.continuity.title,
            rail.continuity.summary,
            rail.continuity.markers.map { "\($0.title) \($0.summary) \($0.detail)" }.joined(separator: " "),
            rail.continuity.pressureLabel,
            rail.continuity.noSilentChangesLabel,
            f02RenderedReservationCopy(rail)
        ].compactMap { $0 }

        if rail.privacyProjection.isSensitiveProjection {
            copy.append(rail.privacyProjection.sourceLabel)
        }

        return copy.joined(separator: " ")
    }

    func f02RenderedReservationCopy(_ rail: AmbitionsDayRailViewState) -> String {
        (rail.continuity.markers.map { "\($0.title) \($0.summary) \($0.detail)" } + [
            rail.continuity.noSilentChangesLabel
        ]).joined(separator: " ")
    }

    func makeRealityMeridianContinuityProjection(
        from execution: TodayExecutionViewState,
        recoveryLabel: String? = nil
    ) -> RealityMeridianContinuityProjectionState {
        RealityMeridianContinuityProjectionState.make(
            dayRail: execution.dayRail,
            heroStep: execution.dayRail.heroStep,
            recommendedStep: execution.recommendedStep,
            todayTimeLayer: execution.todayTimeLayer,
            dayState: execution.dayState,
            recoveryLabel: recoveryLabel ?? execution.dayRail.continuity.pressureLabel
        )
    }

    func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            actionReceiptHistory: SwiftDataActionReceiptHistoryRepository(store: store),
            commandExecutionRecords: InMemoryAmbitionsCommandExecutionRecordRepository(),
            runtimeEvents: InMemoryRuntimeEventStore(),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func makeGoal(
        id: String,
        stepID: String,
        stepTitle: String,
        dueAt: String,
        state: GoalLifecycleState = .active,
        mode: GoalMode = .project,
        domain: LifeDomainKey? = nil,
        stepState: StepLifecycleState = .planned,
        dependencyStepIDs: [String] = []
    ) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: dueAt, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7)
        let strategy = PlanningStrategy(strategyKind: .sequential, allowParallelSteps: false, maxActiveSteps: 3, preferredSectionOrder: [.activeSteps], defaultStepType: .actionUnit, autoGenerateReviewSection: false, preferShortSteps: true, revisitCadenceDays: 7)
        let progress = ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: nil, targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        let step = Step(id: stepID, sectionID: "section-\(id)", title: stepTitle, summary: nil, type: .actionUnit, state: stepState, owner: actor, timing: timing, dependencyStepIDs: dependencyStepIDs, isOptional: false, isRepeatable: false, evidenceRequired: true, successSignals: ["Done"], actionability: StepActionability(action: "Do it", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start", contextRequirements: []))
        let plan = GoalPlan(id: "plan-\(id)", goalID: id, version: goalEnginePlanVersion, generatedAt: "2026-04-15T12:00:00Z", summary: nil, strategy: strategy, sections: [PlanSection(id: "section-\(id)", goalID: id, title: "Active", summary: nil, kind: .activeSteps, orderIndex: 0, steps: [step])], assumptions: [], lint: PlanLintResult(goalID: id, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: []))
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: "2026-04-15T12:00:00Z",
            updatedAt: "2026-04-15T12:00:00Z",
            state: state,
            title: id,
            summary: nil,
            mode: mode,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan,
            lifeGraph: domain.map { LifeGraphContext(domains: [LifeDomainAssignment(domain: $0)]) }
        )
    }
}

func forbiddenCopyTerm(_ parts: String...) -> String {
    parts.joined(separator: " ")
}

actor TodayViewModelServiceRecorder: TodayServicing {
    let experience: TodayExperience
    let actionResponse: TodayActionResponse
    private(set) var performedActions: [TodayInlineAction] = []
    private(set) var recordedClosures: [(TodayActionClosureSheetState, TodayActionClosureOutcomeState)] = []

    init(experience: TodayExperience, actionResponse: TodayActionResponse) {
        self.experience = experience
        self.actionResponse = actionResponse
    }

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        _ = entryContext
        return experience
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = now
        performedActions.append(action)
        return actionResponse
    }

    func recordActionClosure(_ closure: TodayActionClosureSheetState, outcome: TodayActionClosureOutcomeState, now: Date) async throws -> TodayActionResponse {
        _ = now
        recordedClosures.append((closure, outcome))
        return actionResponse
    }

    func performedActionCount() -> Int {
        performedActions.count
    }
}

actor TodayViewModelReceiptCommandRecorder: TodayReceiptCommanding {
    let actionResponse: TodayActionResponse
    private(set) var recordedClosures: [(TodayActionClosureSheetState, TodayActionClosureOutcomeState)] = []
    private(set) var recordedRejections: [TodayRecommendationRejectionInput] = []

    init(actionResponse: TodayActionResponse) {
        self.actionResponse = actionResponse
    }

    func recordRecommendationRejection(_ input: TodayRecommendationRejectionInput) async throws -> TodayActionResponse {
        recordedRejections.append(input)
        return actionResponse
    }

    func recordActionClosure(
        _ closure: TodayActionClosureSheetState,
        outcome: TodayActionClosureOutcomeState,
        now: Date
    ) async throws -> TodayActionResponse {
        _ = now
        recordedClosures.append((closure, outcome))
        return actionResponse
    }
}

struct TodayViewModelFailingService: TodayServicing {
    struct Failure: LocalizedError {
        var errorDescription: String? {
            "Today failed on purpose."
        }
    }

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        _ = entryContext
        throw Failure()
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = action
        _ = now
        throw Failure()
    }
}
