import AmbitionsDesignSystem
import Foundation

enum AFEPQueryBudgetCatalog {
    static let majorSurfaceReadBudgets: [AFEPQueryBudgetDescriptor] = [
        AFEPQueryBudgetDescriptor(
            scope: .today,
            maximumReads: 8,
            notes: "Today / Reality Meridian stays within a small local read ceiling before recommendations are materialized."
        ),
        AFEPQueryBudgetDescriptor(
            scope: .goals,
            maximumReads: 12,
            notes: "Goals / Constellation Atlas can fan out across goal threads, receipts, and proof records without claiming measured performance."
        ),
        AFEPQueryBudgetDescriptor(
            scope: .capture,
            maximumReads: 6,
            notes: "Capture / Atmosphere Composer keeps intake reads intentionally narrow."
        ),
        AFEPQueryBudgetDescriptor(
            scope: .time,
            maximumReads: 10,
            notes: "Time / LifeShape Field can include availability, schedule, and recovery reads inside one contract ceiling."
        ),
        AFEPQueryBudgetDescriptor(
            scope: .you,
            maximumReads: 8,
            notes: "You / User System Profile reads stay bounded and review-oriented."
        )
    ]

    static let projectionReadBudgets: [AFEPQueryBudgetDescriptor] = [
        AFEPQueryBudgetDescriptor(
            scope: .runtimeSnapshotLedger,
            maximumReads: 4,
            notes: "Runtime snapshot envelope and reference validation remain small, local-only, and inspectable."
        ),
        AFEPQueryBudgetDescriptor(
            scope: .operationalProjection,
            maximumReads: 6,
            notes: "Operational graph projection reads remain contract-bounded for source-backed Today/Goals/Capture/Time/You surfaces."
        ),
        AFEPQueryBudgetDescriptor(
            scope: .proofProjection,
            maximumReads: 6,
            notes: "Proof projection reads remain contract-bounded and local-first."
        ),
        AFEPQueryBudgetDescriptor(
            scope: .portableExport,
            maximumReads: 6,
            notes: "Portable export review reads remain bounded and conservative while export policy stays explicit."
        )
    ]

    static let all = majorSurfaceReadBudgets + projectionReadBudgets
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

protocol ReminderRepository: Sendable {
    func listReminders() async throws -> [ReminderTrigger]
    func reminder(id: String) async throws -> ReminderTrigger?
    func saveReminders(_ reminders: [ReminderTrigger]) async throws
    func deleteReminder(id: String, at timestamp: String) async throws
    func deleteReminders(attachedTo objectID: String) async throws
    func exportReminders() async throws -> ReminderRepositoryExport
    func importReminders(_ export: ReminderRepositoryExport) async throws
}

protocol GoalTeachingSignalRepository: Sendable {
    func listSignals(goalID: String?) async throws -> [GoalTeachingSignal]
    func saveSignals(_ signals: [GoalTeachingSignal]) async throws
}

protocol RuntimeSnapshotLedgerRepository: Sendable {
    func append(_ envelope: RuntimeSnapshotLedgerEnvelope) async throws
    func fetchRecent(limit: Int) async throws -> [RuntimeSnapshotLedgerEnvelope]
    func fetchEnvelope(id: String) async throws -> RuntimeSnapshotLedgerEnvelope?
    func fetchEnvelopes(containing reference: RuntimeSnapshotLedgerArtifactReference) async throws -> [RuntimeSnapshotLedgerEnvelope]
    func validate(reference: RuntimeSnapshotLedgerArtifactReference) async throws -> RuntimeSnapshotLedgerReplayValidationReport
    func validateReceipt(referenceID: String, envelopeID: String?, checksum: String?) async throws -> RuntimeSnapshotLedgerReplayValidationReport
    func validateProof(referenceID: String, envelopeID: String?, checksum: String?) async throws -> RuntimeSnapshotLedgerReplayValidationReport
    func validateReplayTrace(referenceID: String, envelopeID: String?, checksum: String?) async throws -> RuntimeSnapshotLedgerReplayValidationReport
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

protocol LifeContextRepository: Sendable {
    func listBundles() async throws -> [LifeContextBundle]
    func bundle(id: String) async throws -> LifeContextBundle?
    func saveBundles(_ bundles: [LifeContextBundle]) async throws
    func deleteBundle(id: String, at timestamp: String) async throws
    func projectRuntime(for bundleID: String, asOf now: Date) async throws -> LifeContextRuntimeProjection?
}

protocol AmbitionGraphOperationalRecordRepository: Sendable {
    func save(_ records: [AmbitionGraphOperationalRecord]) async throws
    func fetchRecords(
        surface: AmbitionGraphProjectionSurface?,
        snapshotID: String?,
        limit: Int?
    ) async throws -> [AmbitionGraphOperationalRecord]
}

protocol AmbitionGraphProofRecordRepository: Sendable {
    func append(_ record: AmbitionGraphProofRecord) async throws
    func fetchRecords(
        proofID: String?,
        limit: Int?
    ) async throws -> [AmbitionGraphProofRecord]
}

protocol AmbitionGraphProjectionRecordRepository: Sendable {
    func save(_ records: [AmbitionGraphProjectionRecord]) async throws
    func fetchRecords(
        surface: AmbitionGraphProjectionSurface?,
        snapshotID: String?,
        limit: Int?
    ) async throws -> [AmbitionGraphProjectionRecord]
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

enum UnavailableRepositoryError: LocalizedError, Sendable, Equatable {
    case intentionallyOutOfScope(repository: String)

    var errorDescription: String? {
        switch self {
        case let .intentionallyOutOfScope(repository):
            return "\(repository) is intentionally unavailable in this local runtime context."
        }
    }
}
