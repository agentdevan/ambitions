import AmbitionsDesignSystem
import Foundation

struct UnavailableReminderRepository: ReminderRepository {
    func listReminders() async throws -> [ReminderTrigger] {
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "ReminderRepository")
    }

    func reminder(id: String) async throws -> ReminderTrigger? {
        _ = id
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "ReminderRepository")
    }

    func saveReminders(_ reminders: [ReminderTrigger]) async throws {
        _ = reminders
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "ReminderRepository")
    }

    func deleteReminder(id: String, at timestamp: String) async throws {
        _ = id
        _ = timestamp
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "ReminderRepository")
    }

    func deleteReminders(attachedTo objectID: String) async throws {
        _ = objectID
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "ReminderRepository")
    }

    func exportReminders() async throws -> ReminderRepositoryExport {
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "ReminderRepository")
    }

    func importReminders(_ export: ReminderRepositoryExport) async throws {
        _ = export
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "ReminderRepository")
    }
}

struct UnavailableRuntimeSnapshotLedgerRepository: RuntimeSnapshotLedgerRepository {
    func append(_ envelope: RuntimeSnapshotLedgerEnvelope) async throws {
        _ = envelope
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "RuntimeSnapshotLedgerRepository")
    }

    func fetchRecent(limit: Int) async throws -> [RuntimeSnapshotLedgerEnvelope] {
        _ = limit
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "RuntimeSnapshotLedgerRepository")
    }

    func fetchEnvelope(id: String) async throws -> RuntimeSnapshotLedgerEnvelope? {
        _ = id
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "RuntimeSnapshotLedgerRepository")
    }

    func fetchEnvelopes(containing reference: RuntimeSnapshotLedgerArtifactReference) async throws -> [RuntimeSnapshotLedgerEnvelope] {
        _ = reference
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "RuntimeSnapshotLedgerRepository")
    }

    func validate(reference: RuntimeSnapshotLedgerArtifactReference) async throws -> RuntimeSnapshotLedgerReplayValidationReport {
        _ = reference
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "RuntimeSnapshotLedgerRepository")
    }

    func validateReceipt(referenceID: String, envelopeID: String?, checksum: String?) async throws -> RuntimeSnapshotLedgerReplayValidationReport {
        _ = referenceID
        _ = envelopeID
        _ = checksum
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "RuntimeSnapshotLedgerRepository")
    }

    func validateProof(referenceID: String, envelopeID: String?, checksum: String?) async throws -> RuntimeSnapshotLedgerReplayValidationReport {
        _ = referenceID
        _ = envelopeID
        _ = checksum
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "RuntimeSnapshotLedgerRepository")
    }

    func validateReplayTrace(referenceID: String, envelopeID: String?, checksum: String?) async throws -> RuntimeSnapshotLedgerReplayValidationReport {
        _ = referenceID
        _ = envelopeID
        _ = checksum
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "RuntimeSnapshotLedgerRepository")
    }
}

struct UnavailableAmbitionsCommandExecutionRecordRepository: AmbitionsCommandExecutionRecordRepository {
    func append(_ record: AmbitionsCommandExecutionRecord) async throws {
        _ = record
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "AmbitionsCommandExecutionRecordRepository")
    }

    func fetchRecent(limit: Int) async throws -> [AmbitionsCommandExecutionRecord] {
        _ = limit
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "AmbitionsCommandExecutionRecordRepository")
    }

    func fetchRecord(commandID: String) async throws -> AmbitionsCommandExecutionRecord? {
        _ = commandID
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "AmbitionsCommandExecutionRecordRepository")
    }
}

struct UnavailableAmbitionGraphOperationalRecordRepository: AmbitionGraphOperationalRecordRepository {
    func save(_ records: [AmbitionGraphOperationalRecord]) async throws {
        _ = records
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "AmbitionGraphOperationalRecordRepository")
    }

    func fetchRecords(surface: AmbitionGraphProjectionSurface?, snapshotID: String?, limit: Int?) async throws -> [AmbitionGraphOperationalRecord] {
        _ = surface
        _ = snapshotID
        _ = limit
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "AmbitionGraphOperationalRecordRepository")
    }
}

struct UnavailableAmbitionGraphProofRecordRepository: AmbitionGraphProofRecordRepository {
    func append(_ record: AmbitionGraphProofRecord) async throws {
        _ = record
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "AmbitionGraphProofRecordRepository")
    }

    func fetchRecords(proofID: String?, limit: Int?) async throws -> [AmbitionGraphProofRecord] {
        _ = proofID
        _ = limit
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "AmbitionGraphProofRecordRepository")
    }
}

struct UnavailableAmbitionGraphProjectionRecordRepository: AmbitionGraphProjectionRecordRepository {
    func save(_ records: [AmbitionGraphProjectionRecord]) async throws {
        _ = records
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "AmbitionGraphProjectionRecordRepository")
    }

    func fetchRecords(surface: AmbitionGraphProjectionSurface?, snapshotID: String?, limit: Int?) async throws -> [AmbitionGraphProjectionRecord] {
        _ = surface
        _ = snapshotID
        _ = limit
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "AmbitionGraphProjectionRecordRepository")
    }
}

struct AppRepositories: Sendable {
    let goals: any GoalRepository
    let drafts: any GoalDraftRepository
    let evidence: any ProgressEvidenceRepository
    let feedback: any FeedbackEventRepository
    let captures: any CaptureRepository
    let reminders: (any ReminderRepository)?
    let teaching: any GoalTeachingSignalRepository
    let eventLedger: any EventLedgerRepository
    let sideEffectLedger: (any SideEffectLedgerRepository)?
    let actionReceiptHistory: (any ActionReceiptHistoryRepository)?
    let entityRevisionTombstones: (any EntityRevisionTombstoneRepository)?
    let runtimeSnapshotLedger: (any RuntimeSnapshotLedgerRepository)?
    let commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?
    let runtimeEvents: (any RuntimeEventStore)?
    let projectionStore: ProjectionStoreSQLite?
    let appGroupSnapshotStore: AppGroupSnapshotStore?
    let searchIndex: FTSIndex?
    let commandJournal: any CommandJournal
    let executionLedgerReplayInspection: (any ExecutionLedgerReplayInspectionRepository)?
    let graphOperationalRecords: (any AmbitionGraphOperationalRecordRepository)?
    let graphProofRecords: (any AmbitionGraphProofRecordRepository)?
    let graphProjectionRecords: (any AmbitionGraphProjectionRecordRepository)?
    let lifeContext: (any LifeContextRepository)?
    let goalCreationUnitOfWork: (any GoalCreationUnitOfWorking)?
    let capturePromotionUnitOfWork: (any CapturePromotionUnitOfWorking)?
    let appState: any AppStateRepository

    init(
        goals: any GoalRepository,
        drafts: any GoalDraftRepository,
        evidence: any ProgressEvidenceRepository,
        feedback: any FeedbackEventRepository,
        captures: any CaptureRepository,
        reminders: (any ReminderRepository)? = nil,
        teaching: any GoalTeachingSignalRepository = InMemoryGoalTeachingSignalRepository(),
        eventLedger: any EventLedgerRepository = InMemoryEventLedgerRepository(),
        sideEffectLedger: (any SideEffectLedgerRepository)? = nil,
        actionReceiptHistory: (any ActionReceiptHistoryRepository)? = nil,
        entityRevisionTombstones: (any EntityRevisionTombstoneRepository)? = nil,
        runtimeSnapshotLedger: (any RuntimeSnapshotLedgerRepository)? = nil,
        commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)? = nil,
        runtimeEvents: (any RuntimeEventStore)? = nil,
        projectionStore: ProjectionStoreSQLite? = nil,
        appGroupSnapshotStore: AppGroupSnapshotStore? = nil,
        searchIndex: FTSIndex? = nil,
        commandJournal: any CommandJournal = InMemoryCommandJournal(),
        executionLedgerReplayInspection: (any ExecutionLedgerReplayInspectionRepository)? = nil,
        graphOperationalRecords: (any AmbitionGraphOperationalRecordRepository)? = nil,
        graphProofRecords: (any AmbitionGraphProofRecordRepository)? = nil,
        graphProjectionRecords: (any AmbitionGraphProjectionRecordRepository)? = nil,
        lifeContext: (any LifeContextRepository)? = nil,
        goalCreationUnitOfWork: (any GoalCreationUnitOfWorking)? = nil,
        capturePromotionUnitOfWork: (any CapturePromotionUnitOfWorking)? = nil,
        appState: any AppStateRepository
    ) {
        self.goals = goals
        self.drafts = drafts
        self.evidence = evidence
        self.feedback = feedback
        self.captures = captures
        self.reminders = reminders
        self.teaching = teaching
        self.eventLedger = eventLedger
        self.sideEffectLedger = sideEffectLedger
        self.actionReceiptHistory = actionReceiptHistory
        self.entityRevisionTombstones = entityRevisionTombstones
        self.runtimeSnapshotLedger = runtimeSnapshotLedger
        self.commandExecutionRecords = commandExecutionRecords
        self.runtimeEvents = runtimeEvents
        self.projectionStore = projectionStore
        self.appGroupSnapshotStore = appGroupSnapshotStore
        self.searchIndex = searchIndex
        self.commandJournal = commandJournal
        self.executionLedgerReplayInspection = executionLedgerReplayInspection
        self.graphOperationalRecords = graphOperationalRecords
        self.graphProofRecords = graphProofRecords
        self.graphProjectionRecords = graphProjectionRecords
        self.lifeContext = lifeContext
        self.goalCreationUnitOfWork = goalCreationUnitOfWork
        self.capturePromotionUnitOfWork = capturePromotionUnitOfWork
        self.appState = appState
    }
}
