import Foundation

let objectStateContractSchemaVersion = "object_state_contract.native.v1"

enum ObjectStateFamily: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goalThread = "goal_thread"
    case lifeArea = "life_area"
    case step
    case capture
    case timeBlock = "time_block"
    case closure
    case proof
    case receipt
    case userSystem = "user_system"
    case appState = "app_state"
}

enum ObjectStateImplementationStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case contractDefined = "contract_defined"
    case swiftDataAdapterMigrated = "swiftdata_adapter_migrated"
}

enum ObjectStateSupersessionPolicy: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case appendOnlyRevision = "append_only_revision"
    case replaceCurrentSnapshot = "replace_current_snapshot"
    case canonicalReference = "canonical_reference"
}

enum ObjectStateMutationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case create
    case update
    case delete
    case replace
    case tombstone
}

enum ObjectStateContractError: Error, Sendable, Equatable {
    case missingObjectID(ObjectStateFamily)
    case familyMismatch(expected: ObjectStateFamily, actual: ObjectStateFamily)
    case missingCommand(ObjectStateFamily)
    case missingTransaction(ObjectStateFamily)
    case missingEvent(ObjectStateFamily)
    case missingProjection(ObjectStateFamily)
    case missingReceipt(ObjectStateFamily)
    case missingReplay(ObjectStateFamily)
    case missingRollback(ObjectStateFamily)
    case nonLocalMutation(ObjectStateFamily)
}

struct ObjectStateIdentity: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let family: ObjectStateFamily
    let localNamespace: String
    let lineageID: String

    init(
        family: ObjectStateFamily,
        rawID: String,
        localNamespace: String = "local"
    ) throws {
        let trimmedID = rawID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedID.isEmpty == false else {
            throw ObjectStateContractError.missingObjectID(family)
        }
        self.id = trimmedID
        self.family = family
        self.localNamespace = localNamespace.trimmingCharacters(in: .whitespacesAndNewlines).storageNilIfEmpty ?? "local"
        self.lineageID = "object_state.lineage.\(family.rawValue).\(self.localNamespace).\(trimmedID)"
    }
}

struct ObjectStateFamilyDescriptor: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: ObjectStateFamily
    let storeName: String
    let implementationStatus: ObjectStateImplementationStatus
    let privacyClass: AmbitionPrivacyClass
    let tombstoneEntityKind: EntityRevisionTombstoneEntityKind
    let runtimeTombstoneFamily: RuntimeTombstoneObjectFamily
    let supersessionPolicy: ObjectStateSupersessionPolicy
    let canonicalMutationAuthority: String
    let adapterOwner: String?
    let remainingDirectWriteDebt: String?

    init(
        id: ObjectStateFamily,
        storeName: String,
        implementationStatus: ObjectStateImplementationStatus,
        privacyClass: AmbitionPrivacyClass,
        tombstoneEntityKind: EntityRevisionTombstoneEntityKind,
        runtimeTombstoneFamily: RuntimeTombstoneObjectFamily,
        supersessionPolicy: ObjectStateSupersessionPolicy,
        canonicalMutationAuthority: String = "Core/LocalRuntimeOS/CommandSpine + TransactionKernel + EventJournal",
        adapterOwner: String? = nil,
        remainingDirectWriteDebt: String? = nil
    ) {
        self.id = id
        self.storeName = storeName
        self.implementationStatus = implementationStatus
        self.privacyClass = privacyClass
        self.tombstoneEntityKind = tombstoneEntityKind
        self.runtimeTombstoneFamily = runtimeTombstoneFamily
        self.supersessionPolicy = supersessionPolicy
        self.canonicalMutationAuthority = canonicalMutationAuthority
        self.adapterOwner = adapterOwner?.trimmingCharacters(in: .whitespacesAndNewlines).storageNilIfEmpty
        self.remainingDirectWriteDebt = remainingDirectWriteDebt?.trimmingCharacters(in: .whitespacesAndNewlines).storageNilIfEmpty
    }

    var isFullyMigratedForObjectState: Bool {
        implementationStatus == .swiftDataAdapterMigrated && remainingDirectWriteDebt == nil
    }
}

struct ObjectStateManifest: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let requiredFamilies: [ObjectStateFamily]
    let descriptors: [ObjectStateFamilyDescriptor]
    let commandEventProjectionReceiptReplayRequired: Bool
    let swiftDataIsMutationAuthority: Bool

    init(
        schemaVersion: String = objectStateContractSchemaVersion,
        descriptors: [ObjectStateFamilyDescriptor],
        commandEventProjectionReceiptReplayRequired: Bool = true,
        swiftDataIsMutationAuthority: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.requiredFamilies = ObjectStateFamily.allCases
        self.descriptors = descriptors.sorted { $0.id.rawValue < $1.id.rawValue }
        self.commandEventProjectionReceiptReplayRequired = commandEventProjectionReceiptReplayRequired
        self.swiftDataIsMutationAuthority = swiftDataIsMutationAuthority
    }

    var migratedFamilies: [ObjectStateFamily] {
        descriptors.filter { $0.implementationStatus == .swiftDataAdapterMigrated }.map(\.id).sorted { $0.rawValue < $1.rawValue }
    }

    var remainingTrackedFamilies: [ObjectStateFamily] {
        descriptors.filter { $0.implementationStatus != .swiftDataAdapterMigrated }.map(\.id).sorted { $0.rawValue < $1.rawValue }
    }

    func descriptor(for family: ObjectStateFamily) -> ObjectStateFamilyDescriptor? {
        descriptors.first { $0.id == family }
    }
}

enum ObjectStateRegistry {
    static let current = ObjectStateManifest(
        descriptors: [
            ObjectStateFamilyDescriptor(
                id: .goalThread,
                storeName: "GoalThreadStore",
                implementationStatus: .contractDefined,
                privacyClass: .privateUserText,
                tombstoneEntityKind: .goal,
                runtimeTombstoneFamily: .goalThread,
                supersessionPolicy: .appendOnlyRevision,
                remainingDirectWriteDebt: "Goal and step writes still route through GoalRepository/SwiftDataGoalRepository until a later ObjectState train moves the full goal family."
            ),
            ObjectStateFamilyDescriptor(
                id: .lifeArea,
                storeName: "LifeAreaStore",
                implementationStatus: .contractDefined,
                privacyClass: .systemOwned,
                tombstoneEntityKind: .unknown,
                runtimeTombstoneFamily: .lifeArea,
                supersessionPolicy: .canonicalReference,
                canonicalMutationAuthority: "Core/Domain/LifeArea canonical reference data; mutation disallowed unless future canon introduces custom areas.",
                remainingDirectWriteDebt: "Canonical life areas are read-only reference state in this slice."
            ),
            ObjectStateFamilyDescriptor(
                id: .step,
                storeName: "StepStore",
                implementationStatus: .contractDefined,
                privacyClass: .privateUserText,
                tombstoneEntityKind: .goal,
                runtimeTombstoneFamily: .step,
                supersessionPolicy: .appendOnlyRevision,
                remainingDirectWriteDebt: "Step writes remain embedded in goal plan persistence until PlanningEngine and TimeEngine move their object-state adapters."
            ),
            ObjectStateFamilyDescriptor(
                id: .capture,
                storeName: "CaptureStore",
                implementationStatus: .contractDefined,
                privacyClass: .privateUserText,
                tombstoneEntityKind: .capture,
                runtimeTombstoneFamily: .capture,
                supersessionPolicy: .appendOnlyRevision,
                remainingDirectWriteDebt: "Capture writes remain in CaptureRepository until CaptureRouteGraph installs durable intake and promotion transactions."
            ),
            ObjectStateFamilyDescriptor(
                id: .timeBlock,
                storeName: "TimeBlockStore",
                implementationStatus: .contractDefined,
                privacyClass: .privateConstraint,
                tombstoneEntityKind: .unknown,
                runtimeTombstoneFamily: .timeBlock,
                supersessionPolicy: .appendOnlyRevision,
                remainingDirectWriteDebt: "Time blocks are not yet a canonical object-state store; TimeEngine owns the next migration."
            ),
            ObjectStateFamilyDescriptor(
                id: .closure,
                storeName: "ClosureStore",
                implementationStatus: .contractDefined,
                privacyClass: .sharedReceipt,
                tombstoneEntityKind: .actionReceipt,
                runtimeTombstoneFamily: .closure,
                supersessionPolicy: .appendOnlyRevision,
                remainingDirectWriteDebt: "Closure ownership remains split between receipts, event ledger entries, and runtime services until TrustSystem moves the ledger stores."
            ),
            ObjectStateFamilyDescriptor(
                id: .proof,
                storeName: "ProofStore",
                implementationStatus: .contractDefined,
                privacyClass: .privateProof,
                tombstoneEntityKind: .progressEvidence,
                runtimeTombstoneFamily: .proof,
                supersessionPolicy: .appendOnlyRevision,
                remainingDirectWriteDebt: "Proof object-state writes remain in evidence/proof graph repositories until TrustSystem migration."
            ),
            ObjectStateFamilyDescriptor(
                id: .receipt,
                storeName: "ReceiptStore",
                implementationStatus: .contractDefined,
                privacyClass: .sharedReceipt,
                tombstoneEntityKind: .actionReceipt,
                runtimeTombstoneFamily: .receipt,
                supersessionPolicy: .appendOnlyRevision,
                remainingDirectWriteDebt: "Receipt writes remain in ActionReceiptHistoryRepository until TrustSystem migration."
            ),
            ObjectStateFamilyDescriptor(
                id: .userSystem,
                storeName: "UserSystemStore",
                implementationStatus: .contractDefined,
                privacyClass: .privateConstraint,
                tombstoneEntityKind: .unknown,
                runtimeTombstoneFamily: .userSystem,
                supersessionPolicy: .replaceCurrentSnapshot,
                remainingDirectWriteDebt: "User-system preferences and profile state remain split across AppState and You projections until PrivacySecurity and You object-state migration."
            ),
            ObjectStateFamilyDescriptor(
                id: .appState,
                storeName: "AppStateStore",
                implementationStatus: .swiftDataAdapterMigrated,
                privacyClass: .systemOwned,
                tombstoneEntityKind: .appState,
                runtimeTombstoneFamily: .appState,
                supersessionPolicy: .replaceCurrentSnapshot,
                adapterOwner: "SwiftDataAppStateStore"
            ),
        ]
    )
}

struct RuntimeObjectStateMutationContext: Codable, Sendable, Equatable, Hashable {
    let family: ObjectStateFamily
    let commandID: String
    let transactionID: String
    let eventID: String
    let projectionID: ProjectionID
    let receiptID: String
    let replayTraceID: String
    let actor: AmbitionsCommandActor
    let source: AmbitionsCommandSource
    let privacy: EventLedgerPrivacyClassification
    let occurredAt: String
    let localOnly: Bool
    let rollbackPlanID: String

    init(
        family: ObjectStateFamily,
        commandID: String,
        transactionID: String,
        eventID: String,
        projectionID: ProjectionID,
        receiptID: String,
        replayTraceID: String,
        actor: AmbitionsCommandActor,
        source: AmbitionsCommandSource,
        privacy: EventLedgerPrivacyClassification,
        occurredAt: String,
        localOnly: Bool = true,
        rollbackPlanID: String
    ) {
        self.family = family
        self.commandID = commandID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.transactionID = transactionID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.eventID = eventID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.projectionID = projectionID
        self.receiptID = receiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayTraceID = replayTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.actor = actor
        self.source = source
        self.privacy = privacy
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
        self.rollbackPlanID = rollbackPlanID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(
        family: ObjectStateFamily,
        command: AmbitionsCommand,
        transactionID: String,
        eventEnvelope: RuntimeEventEnvelope,
        projectionID: ProjectionID,
        receiptID: String,
        replayTraceID: String,
        rollbackPlanID: String
    ) {
        self.init(
            family: family,
            commandID: command.id,
            transactionID: transactionID,
            eventID: eventEnvelope.id,
            projectionID: projectionID,
            receiptID: receiptID,
            replayTraceID: replayTraceID,
            actor: command.actor,
            source: command.source,
            privacy: command.privacy,
            occurredAt: eventEnvelope.event.occurredAt,
            localOnly: command.localOnly && eventEnvelope.event.localOnly,
            rollbackPlanID: rollbackPlanID
        )
    }

    func validated(for expectedFamily: ObjectStateFamily) throws {
        guard family == expectedFamily else {
            throw ObjectStateContractError.familyMismatch(expected: expectedFamily, actual: family)
        }
        guard commandID.isEmpty == false else {
            throw ObjectStateContractError.missingCommand(expectedFamily)
        }
        guard transactionID.isEmpty == false else {
            throw ObjectStateContractError.missingTransaction(expectedFamily)
        }
        guard eventID.isEmpty == false else {
            throw ObjectStateContractError.missingEvent(expectedFamily)
        }
        guard receiptID.isEmpty == false else {
            throw ObjectStateContractError.missingReceipt(expectedFamily)
        }
        guard replayTraceID.isEmpty == false else {
            throw ObjectStateContractError.missingReplay(expectedFamily)
        }
        guard rollbackPlanID.isEmpty == false else {
            throw ObjectStateContractError.missingRollback(expectedFamily)
        }
        guard localOnly else {
            throw ObjectStateContractError.nonLocalMutation(expectedFamily)
        }
    }
}

struct ObjectStateWriteReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let identity: ObjectStateIdentity
    let mutationKind: ObjectStateMutationKind
    let commandID: String
    let transactionID: String
    let eventID: String
    let projectionID: ProjectionID
    let receiptID: String
    let replayTraceID: String
    let rollbackPlanID: String
    let privacy: EventLedgerPrivacyClassification
    let occurredAt: String
    let localOnly: Bool

    init(
        identity: ObjectStateIdentity,
        mutationKind: ObjectStateMutationKind,
        context: RuntimeObjectStateMutationContext
    ) throws {
        try context.validated(for: identity.family)
        self.id = "object_state.write.\(identity.family.rawValue).\(identity.id).\(context.eventID)"
        self.identity = identity
        self.mutationKind = mutationKind
        self.commandID = context.commandID
        self.transactionID = context.transactionID
        self.eventID = context.eventID
        self.projectionID = context.projectionID
        self.receiptID = context.receiptID
        self.replayTraceID = context.replayTraceID
        self.rollbackPlanID = context.rollbackPlanID
        self.privacy = context.privacy
        self.occurredAt = context.occurredAt
        self.localOnly = context.localOnly
    }
}
