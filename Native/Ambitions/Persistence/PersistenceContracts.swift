import AmbitionsDesignSystem
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
    var accentFamily: AmbitionAccentFamily
    var reviewCadenceDays: Int
    var localOnlyModeEnabled: Bool
    var hasCompletedBootstrap: Bool
    var hasCompletedOnboarding: Bool
    var onboardingVersion: Int
    var onboardingCompletedAt: String?
    var onboardingEntryChoice: OnboardingEntryChoice?
    var lastBootstrapSource: AppSession.BootstrapSource?
    var lastBootstrapAt: String?
    var lastSeedVersion: String?
    var lastSeededAt: String?
    var lastImportSummary: LegacyImportSummary?
    var lastOpenedGoalID: String?
    var goalPriorityOrder: [String]

    private enum CodingKeys: String, CodingKey {
        case id
        case preferredTab
        case userDisplayName
        case appearancePreference
        case accentFamily
        case reviewCadenceDays
        case localOnlyModeEnabled
        case hasCompletedBootstrap
        case hasCompletedOnboarding
        case onboardingVersion
        case onboardingCompletedAt
        case onboardingEntryChoice
        case lastBootstrapSource
        case lastBootstrapAt
        case lastSeedVersion
        case lastSeededAt
        case lastImportSummary
        case lastOpenedGoalID
        case goalPriorityOrder
    }

    static let `default` = AppStateSnapshot(
        id: "app_state.default",
        preferredTab: .today,
        userDisplayName: "",
        appearancePreference: .system,
        accentFamily: .sage,
        reviewCadenceDays: 7,
        localOnlyModeEnabled: true,
        hasCompletedBootstrap: false,
        hasCompletedOnboarding: false,
        onboardingVersion: 1,
        onboardingCompletedAt: nil,
        onboardingEntryChoice: nil,
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
            preferredTab: preferredTab.canonicalTopLevelTab,
            userDisplayName: userDisplayName,
            appearancePreference: appearancePreference,
            accentFamily: accentFamily
        )
    }

    init(
        id: String,
        preferredTab: AppTab,
        userDisplayName: String,
        appearancePreference: AppAppearancePreference,
        accentFamily: AmbitionAccentFamily,
        reviewCadenceDays: Int,
        localOnlyModeEnabled: Bool,
        hasCompletedBootstrap: Bool,
        hasCompletedOnboarding: Bool,
        onboardingVersion: Int,
        onboardingCompletedAt: String?,
        onboardingEntryChoice: OnboardingEntryChoice?,
        lastBootstrapSource: AppSession.BootstrapSource?,
        lastBootstrapAt: String?,
        lastSeedVersion: String?,
        lastSeededAt: String?,
        lastImportSummary: LegacyImportSummary?,
        lastOpenedGoalID: String?,
        goalPriorityOrder: [String]
    ) {
        self.id = id
        self.preferredTab = preferredTab
        self.userDisplayName = userDisplayName
        self.appearancePreference = appearancePreference
        self.accentFamily = accentFamily
        self.reviewCadenceDays = reviewCadenceDays
        self.localOnlyModeEnabled = localOnlyModeEnabled
        self.hasCompletedBootstrap = hasCompletedBootstrap
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.onboardingVersion = onboardingVersion
        self.onboardingCompletedAt = onboardingCompletedAt
        self.onboardingEntryChoice = onboardingEntryChoice
        self.lastBootstrapSource = lastBootstrapSource
        self.lastBootstrapAt = lastBootstrapAt
        self.lastSeedVersion = lastSeedVersion
        self.lastSeededAt = lastSeededAt
        self.lastImportSummary = lastImportSummary
        self.lastOpenedGoalID = lastOpenedGoalID
        self.goalPriorityOrder = goalPriorityOrder
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        preferredTab = try container.decode(AppTab.self, forKey: .preferredTab)
        userDisplayName = try container.decode(String.self, forKey: .userDisplayName)
        appearancePreference = try container.decode(AppAppearancePreference.self, forKey: .appearancePreference)
        accentFamily = try container.decodeIfPresent(AmbitionAccentFamily.self, forKey: .accentFamily) ?? .sage
        reviewCadenceDays = try container.decode(Int.self, forKey: .reviewCadenceDays)
        localOnlyModeEnabled = try container.decode(Bool.self, forKey: .localOnlyModeEnabled)
        hasCompletedBootstrap = try container.decode(Bool.self, forKey: .hasCompletedBootstrap)
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? hasCompletedBootstrap
        onboardingVersion = try container.decodeIfPresent(Int.self, forKey: .onboardingVersion) ?? 1
        onboardingCompletedAt = try container.decodeIfPresent(String.self, forKey: .onboardingCompletedAt)
        onboardingEntryChoice = try container.decodeIfPresent(OnboardingEntryChoice.self, forKey: .onboardingEntryChoice)
        lastBootstrapSource = try container.decodeIfPresent(AppSession.BootstrapSource.self, forKey: .lastBootstrapSource)
        lastBootstrapAt = try container.decodeIfPresent(String.self, forKey: .lastBootstrapAt)
        lastSeedVersion = try container.decodeIfPresent(String.self, forKey: .lastSeedVersion)
        lastSeededAt = try container.decodeIfPresent(String.self, forKey: .lastSeededAt)
        lastImportSummary = try container.decodeIfPresent(LegacyImportSummary.self, forKey: .lastImportSummary)
        lastOpenedGoalID = try container.decodeIfPresent(String.self, forKey: .lastOpenedGoalID)
        goalPriorityOrder = try container.decodeIfPresent([String].self, forKey: .goalPriorityOrder) ?? []
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(preferredTab, forKey: .preferredTab)
        try container.encode(userDisplayName, forKey: .userDisplayName)
        try container.encode(appearancePreference, forKey: .appearancePreference)
        try container.encode(accentFamily, forKey: .accentFamily)
        try container.encode(reviewCadenceDays, forKey: .reviewCadenceDays)
        try container.encode(localOnlyModeEnabled, forKey: .localOnlyModeEnabled)
        try container.encode(hasCompletedBootstrap, forKey: .hasCompletedBootstrap)
        try container.encode(hasCompletedOnboarding, forKey: .hasCompletedOnboarding)
        try container.encode(onboardingVersion, forKey: .onboardingVersion)
        try container.encodeIfPresent(onboardingCompletedAt, forKey: .onboardingCompletedAt)
        try container.encodeIfPresent(onboardingEntryChoice, forKey: .onboardingEntryChoice)
        try container.encodeIfPresent(lastBootstrapSource, forKey: .lastBootstrapSource)
        try container.encodeIfPresent(lastBootstrapAt, forKey: .lastBootstrapAt)
        try container.encodeIfPresent(lastSeedVersion, forKey: .lastSeedVersion)
        try container.encodeIfPresent(lastSeededAt, forKey: .lastSeededAt)
        try container.encodeIfPresent(lastImportSummary, forKey: .lastImportSummary)
        try container.encodeIfPresent(lastOpenedGoalID, forKey: .lastOpenedGoalID)
        try container.encode(goalPriorityOrder, forKey: .goalPriorityOrder)
    }
}

enum OnboardingEntryChoice: String, Codable, Sendable, Equatable {
    case createFirstGoal = "create_first_goal"
    case captureFirst = "capture_first"
    case enterToday = "enter_today"
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

protocol ActionReceiptHistoryRepository: Sendable {
    func save(_ records: [ActionReceiptHistoryRecord]) async throws
    func fetch(_ query: ActionReceiptSearchQuery) async throws -> ActionReceiptSearchProjection
}

enum TrustHistoryQueryItemKind: String, Sendable, Codable, Equatable {
    case actionReceipt = "action_receipt"
    case eventLedger = "event_ledger"
}

struct TrustHistoryQuery: Sendable, Equatable {
    let startDate: String?
    let endDate: String?
    let receiptSourceDomains: Set<ActionReceiptSourceDomain>
    let receiptPrivacyLevels: Set<ActionReceiptPrivacyLevel>
    let receiptProofRelevance: Set<ActionReceiptProofRelevance>
    let receiptTrustStatuses: Set<ActionReceiptTrustStatus>
    let eventSources: Set<EventLedgerSource>
    let eventPrivacyLevels: Set<EventLedgerPrivacyClassification>
    let requiresReview: Bool?
    let userConfirmed: Bool?
    let proofReferenceKinds: Set<EventLedgerEvidenceKind>
    let requiresProofReferences: Bool?
    let includeReceiptHistory: Bool
    let includeEventLedger: Bool
    let limit: Int?

    init(
        startDate: String? = nil,
        endDate: String? = nil,
        receiptSourceDomains: Set<ActionReceiptSourceDomain> = [],
        receiptPrivacyLevels: Set<ActionReceiptPrivacyLevel> = [],
        receiptProofRelevance: Set<ActionReceiptProofRelevance> = [],
        receiptTrustStatuses: Set<ActionReceiptTrustStatus> = [],
        eventSources: Set<EventLedgerSource> = [],
        eventPrivacyLevels: Set<EventLedgerPrivacyClassification> = [],
        requiresReview: Bool? = nil,
        userConfirmed: Bool? = nil,
        proofReferenceKinds: Set<EventLedgerEvidenceKind> = [],
        requiresProofReferences: Bool? = nil,
        includeReceiptHistory: Bool = true,
        includeEventLedger: Bool = true,
        limit: Int? = nil
    ) {
        self.startDate = startDate?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.endDate = endDate?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.receiptSourceDomains = receiptSourceDomains
        self.receiptPrivacyLevels = receiptPrivacyLevels
        self.receiptProofRelevance = receiptProofRelevance
        self.receiptTrustStatuses = receiptTrustStatuses
        self.eventSources = eventSources
        self.eventPrivacyLevels = eventPrivacyLevels
        self.requiresReview = requiresReview
        self.userConfirmed = userConfirmed
        self.proofReferenceKinds = proofReferenceKinds
        self.requiresProofReferences = requiresProofReferences
        self.includeReceiptHistory = includeReceiptHistory
        self.includeEventLedger = includeEventLedger
        self.limit = limit
    }
}

struct TrustHistoryQueryResult: Sendable, Equatable, Identifiable {
    let id: String
    let kind: TrustHistoryQueryItemKind
    let source: String
    let occurredAt: String
    let privacy: String
    let proofRelevance: ActionReceiptProofRelevance?
    let trustStatus: ActionReceiptTrustStatus?
    let requiresReview: Bool?
    let userConfirmed: Bool?
    let proofReferenceKinds: [EventLedgerEvidenceKind]
    let localOnly: Bool
    let title: String
    let summary: String
}

struct TrustHistoryQueryProjection: Sendable, Equatable {
    let query: TrustHistoryQuery
    let results: [TrustHistoryQueryResult]
    let totalMatchCount: Int
    let emptyTitle: String
    let emptyDetail: String
    let localOnly: Bool

    var isEmpty: Bool {
        results.isEmpty
    }
}

protocol TrustHistoryQueryRepository: Sendable {
    func fetch(_ query: TrustHistoryQuery) async throws -> TrustHistoryQueryProjection
}

protocol CaptureRepository: Sendable {
    func listCaptures() async throws -> [Capture]
    func capture(id: String) async throws -> Capture?
    func saveCaptures(_ captures: [Capture]) async throws
}

protocol GoalTeachingSignalRepository: Sendable {
    func listSignals(goalID: String?) async throws -> [GoalTeachingSignal]
    func saveSignals(_ signals: [GoalTeachingSignal]) async throws
}

protocol EventLedgerRepository: Sendable {
    func append(_ event: EventLedgerEntry) async throws
    func fetchRecent(limit: Int) async throws -> [EventLedgerEntry]
    func fetchEvents(goalID: String) async throws -> [EventLedgerEntry]
    func fetchEvents(captureID: String) async throws -> [EventLedgerEntry]
    func fetchEvents(kind: EventLedgerKind) async throws -> [EventLedgerEntry]
    func fetchEvents(from start: String, through end: String) async throws -> [EventLedgerEntry]
    func redactEvent(id: String, at timestamp: String) async throws
    func deleteEvent(id: String) async throws
}

protocol EntityRevisionTombstoneRepository: Sendable {
    func append(_ tombstone: EntityRevisionTombstone) async throws
    func fetchRecent(limit: Int) async throws -> [EntityRevisionTombstone]
    func fetch(for entityID: String) async throws -> [EntityRevisionTombstone]
}

protocol AmbitionsCommandExecutionRecordRepository: Sendable {
    func append(_ record: AmbitionsCommandExecutionRecord) async throws
    func fetchRecent(limit: Int) async throws -> [AmbitionsCommandExecutionRecord]
    func fetchRecord(commandID: String) async throws -> AmbitionsCommandExecutionRecord?
}

protocol AppStateRepository: Sendable {
    func loadState() async throws -> AppStateSnapshot
    func saveState(_ state: AppStateSnapshot) async throws
}

enum AppUnitOfWorkWriteScope: String, Sendable, Codable, Equatable {
    case localSwiftDataSingleContext = "local_swiftdata_single_context"
}

struct AppUnitOfWorkReceipt: Sendable, Codable, Equatable {
    let id: String
    let startedAt: String
    let completedAt: String
    let writeScope: AppUnitOfWorkWriteScope
    let didCommitChanges: Bool
    let rollbackBehavior: String
    let sideEffectPolicy: String

    static let rollbackOnThrownError = "rollback_on_thrown_error_before_save"
    static let noExternalSideEffects = "no_external_side_effects_inside_unit_of_work"
}

struct AppUnitOfWorkResult<Value: Sendable>: Sendable {
    let value: Value
    let receipt: AppUnitOfWorkReceipt
}

struct GoalCreationUnitOfWorkPayload: Sendable {
    let goal: Goal?
    let draft: PersistedGoalDraft
}

struct GoalCreationUnitOfWorkCommit: Sendable, Equatable {
    let goalID: String?
    let draftID: String
    let resultKind: GoalOrchestrationResultKind?
}

protocol GoalCreationUnitOfWorking: Sendable {
    func saveGoalCreation(
        _ payload: GoalCreationUnitOfWorkPayload,
        id: String,
        timestampProvider: @Sendable () -> String
    ) async throws -> AppUnitOfWorkResult<GoalCreationUnitOfWorkCommit>
}

struct CapturePromotionUnitOfWorkPayload: Sendable {
    let goal: Goal
    let draft: PersistedGoalDraft
    let capture: Capture
}

struct CapturePromotionUnitOfWorkCommit: Sendable, Equatable {
    let goalID: String
    let draftID: String
    let captureID: String
    let resultKind: GoalOrchestrationResultKind?
}

protocol CapturePromotionUnitOfWorking: Sendable {
    func saveCapturePromotion(
        _ payload: CapturePromotionUnitOfWorkPayload,
        id: String,
        timestampProvider: @Sendable () -> String
    ) async throws -> AppUnitOfWorkResult<CapturePromotionUnitOfWorkCommit>
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
    let teaching: any GoalTeachingSignalRepository
    let eventLedger: any EventLedgerRepository
    let sideEffectLedger: (any SideEffectLedgerRepository)?
    let actionReceiptHistory: (any ActionReceiptHistoryRepository)?
    let entityRevisionTombstones: (any EntityRevisionTombstoneRepository)?
    let commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?
    let goalCreationUnitOfWork: (any GoalCreationUnitOfWorking)?
    let capturePromotionUnitOfWork: (any CapturePromotionUnitOfWorking)?
    let appState: any AppStateRepository

    init(
        goals: any GoalRepository,
        drafts: any GoalDraftRepository,
        evidence: any ProgressEvidenceRepository,
        feedback: any FeedbackEventRepository,
        captures: any CaptureRepository,
        teaching: any GoalTeachingSignalRepository = InMemoryGoalTeachingSignalRepository(),
        eventLedger: any EventLedgerRepository = InMemoryEventLedgerRepository(),
        sideEffectLedger: (any SideEffectLedgerRepository)? = nil,
        actionReceiptHistory: (any ActionReceiptHistoryRepository)? = nil,
        entityRevisionTombstones: (any EntityRevisionTombstoneRepository)? = nil,
        commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)? = nil,
        goalCreationUnitOfWork: (any GoalCreationUnitOfWorking)? = nil,
        capturePromotionUnitOfWork: (any CapturePromotionUnitOfWorking)? = nil,
        appState: any AppStateRepository
    ) {
        self.goals = goals
        self.drafts = drafts
        self.evidence = evidence
        self.feedback = feedback
        self.captures = captures
        self.teaching = teaching
        self.eventLedger = eventLedger
        self.sideEffectLedger = sideEffectLedger
        self.actionReceiptHistory = actionReceiptHistory
        self.entityRevisionTombstones = entityRevisionTombstones
        self.commandExecutionRecords = commandExecutionRecords
        self.goalCreationUnitOfWork = goalCreationUnitOfWork
        self.capturePromotionUnitOfWork = capturePromotionUnitOfWork
        self.appState = appState
    }
}
