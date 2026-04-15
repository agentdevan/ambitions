import Foundation

struct PersistedGoalDraft: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let draft: GoalDraft
    let classification: ClassificationResult?
    let clarification: GoalOrchestrationClarification?
    let stagedPlan: GoalPlan?
    let assumptions: [PlanAssumption]
    let blockers: [GoalPlanningBlocker]
    let metadata: GoalOrchestrationMetadata?
    let plannedGoalID: String?
    let latestResultKind: GoalOrchestrationResultKind?
}

struct AppStateSnapshot: Identifiable, Codable, Sendable, Equatable {
    let id: String
    var preferredTab: AppTab
    var userDisplayName: String
    var appearancePreference: AppAppearancePreference
    var reviewCadenceDays: Int
    var localOnlyModeEnabled: Bool
    var hasCompletedBootstrap: Bool
    var lastBootstrapSource: AppSession.BootstrapSource?
    var lastBootstrapAt: String?
    var lastSeedVersion: String?
    var lastSeededAt: String?
    var lastImportSummary: LegacyImportSummary?
    var lastOpenedGoalID: String?
    var goalPriorityOrder: [String]

    static let `default` = AppStateSnapshot(
        id: "app_state.default",
        preferredTab: .today,
        userDisplayName: "",
        appearancePreference: .system,
        reviewCadenceDays: 7,
        localOnlyModeEnabled: true,
        hasCompletedBootstrap: false,
        lastBootstrapSource: nil,
        lastBootstrapAt: nil,
        lastSeedVersion: nil,
        lastSeededAt: nil,
        lastImportSummary: nil,
        lastOpenedGoalID: nil,
        goalPriorityOrder: []
    )

    var preferences: AppPreferences {
        AppPreferences(
            preferredTab: preferredTab,
            userDisplayName: userDisplayName,
            appearancePreference: appearancePreference
        )
    }
}

enum LegacyGoalType: String, Codable, Sendable {
    case outcome
    case project
    case system
    case habit
}

enum LegacyGoalStatus: String, Codable, Sendable {
    case draft
    case active
    case paused
    case completed
    case archived
}

enum LegacyTaskStatus: String, Codable, Sendable {
    case inbox
    case ready
    case scheduled
    case inProgress = "in_progress"
    case completed
    case cancelled
    case skipped
    case deferred
    case missed
}

struct LegacyGoalRecord: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let title: String
    let summary: String?
    let goalType: LegacyGoalType
    let goalStatus: LegacyGoalStatus
    let parentGoalID: String?
    let startDate: String?
    let targetDate: String?
    let tags: [String]
    let metadata: [String: String]
}

struct LegacyTaskRecord: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let goalID: String
    let parentTaskID: String?
    let title: String
    let summary: String?
    let status: LegacyTaskStatus
    let targetDate: String?
    let scheduledDate: String?
    let earliestStartAt: String?
    let latestFinishAt: String?
    let completedAt: String?
    let isRecurringTemplate: Bool
}

struct LegacyMilestoneRecord: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let goalID: String
    let title: String
    let summary: String?
    let targetDate: String?
    let completedAt: String?
}

struct LegacyPrototypeSnapshot: Codable, Sendable, Equatable {
    let goals: [LegacyGoalRecord]
    let tasks: [LegacyTaskRecord]
    let milestones: [LegacyMilestoneRecord]
    let appState: AppStateSnapshot?
}

struct LegacyImportSummary: Codable, Sendable, Equatable {
    let importedGoalCount: Int
    let importedDraftCount: Int
    let importedPlanCount: Int
    let importedStepCount: Int
    let reusableData: [String]
    let referenceOnlyData: [String]
    let lossyMappings: [String]
}

struct LegacyImportReport: Codable, Sendable, Equatable {
    let importedGoalIDs: [String]
    let importedDraftIDs: [String]
    let summary: LegacyImportSummary
}

protocol GoalRepository: Sendable {
    func listGoals() async throws -> [Goal]
    func listHabitGoals() async throws -> [Goal]
    func goal(id: String) async throws -> Goal?
    func saveGoals(_ goals: [Goal]) async throws
    func deleteGoal(id: String) async throws
    func listActionableSteps() async throws -> [Step]
    func listSteps(goalID: String) async throws -> [Step]
}

protocol GoalDraftRepository: Sendable {
    func listDrafts() async throws -> [PersistedGoalDraft]
    func draft(id: String) async throws -> PersistedGoalDraft?
    func saveDrafts(_ drafts: [PersistedGoalDraft]) async throws
    func deleteDraft(id: String) async throws
}

protocol ProgressEvidenceRepository: Sendable {
    func listEvidence(goalID: String?) async throws -> [ProgressEvidence]
    func saveEvidence(_ evidence: [ProgressEvidence]) async throws
}

protocol FeedbackEventRepository: Sendable {
    func listEvents(goalID: String?) async throws -> [GoalFeedbackEvent]
    func saveEvents(_ events: [GoalFeedbackEvent], goalID: String) async throws
}

protocol CaptureRepository: Sendable {
    func listCaptures() async throws -> [Capture]
    func capture(id: String) async throws -> Capture?
    func saveCaptures(_ captures: [Capture]) async throws
}

protocol AppStateRepository: Sendable {
    func loadState() async throws -> AppStateSnapshot
    func saveState(_ state: AppStateSnapshot) async throws
}

protocol LegacyImportServicing: Sendable {
    func importSnapshot(_ snapshot: LegacyPrototypeSnapshot) async throws -> LegacyImportReport
}

struct AppRepositories: Sendable {
    let goals: any GoalRepository
    let drafts: any GoalDraftRepository
    let evidence: any ProgressEvidenceRepository
    let feedback: any FeedbackEventRepository
    let captures: any CaptureRepository
    let appState: any AppStateRepository
}
