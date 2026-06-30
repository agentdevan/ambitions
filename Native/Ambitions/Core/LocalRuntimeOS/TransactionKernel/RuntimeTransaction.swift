import CryptoKit
import Foundation

let runtimeTransactionSchemaVersion = "runtime_transaction.native.v1"

enum RuntimeTransactionPhase: String, Sendable, Codable, Equatable, Hashable, CaseIterable {
    case prepared
    case committed
    case rejected
    case replayed
}

enum RuntimeTransactionError: Error, Sendable, Equatable {
    case blockedByValidation(commandID: String, reasons: [String])
    case mutationProofIncomplete(commandID: String)
    case conflictDetected(RuntimeConflictReport)
    case idempotencyKeyMalformed(String)
}

struct RuntimeTransaction: Sendable, Equatable, Identifiable {
    let id: String
    let commandID: String
    let idempotencyKey: LedgerIdempotencyKey
    let phase: RuntimeTransactionPhase
    let mutationPlan: RuntimeMutationPlan
    let readSet: RuntimeReadSet
    let writeSet: RuntimeWriteSet
    let rollbackPlan: RuntimeRollbackPlan
    let preparedAt: String
    let schemaVersion: String

    init(
        mutationPlan: RuntimeMutationPlan,
        rollbackPlan: RuntimeRollbackPlan,
        phase: RuntimeTransactionPhase = .prepared,
        schemaVersion: String = runtimeTransactionSchemaVersion
    ) throws {
        let key = LedgerIdempotencyKey(mutationPlan.command.id)
        guard key.isWellFormed else {
            throw RuntimeTransactionError.idempotencyKeyMalformed(mutationPlan.command.id)
        }
        self.id = "runtime.transaction.\(mutationPlan.command.id)"
        self.commandID = mutationPlan.command.id
        self.idempotencyKey = key
        self.phase = phase
        self.mutationPlan = mutationPlan
        self.readSet = mutationPlan.readSet
        self.writeSet = mutationPlan.writeSet
        self.rollbackPlan = rollbackPlan
        self.preparedAt = mutationPlan.plannedAt
        self.schemaVersion = schemaVersion
    }

    var isCommittable: Bool {
        phase == .prepared &&
            mutationPlan.isCommittable &&
            readSet.isComplete &&
            writeSet.isComplete &&
            rollbackPlan.isExecutable
    }

    func marked(_ nextPhase: RuntimeTransactionPhase) -> RuntimeTransaction {
        RuntimeTransaction(
            id: id,
            commandID: commandID,
            idempotencyKey: idempotencyKey,
            phase: nextPhase,
            mutationPlan: mutationPlan,
            readSet: readSet,
            writeSet: writeSet,
            rollbackPlan: rollbackPlan,
            preparedAt: preparedAt,
            schemaVersion: schemaVersion
        )
    }

    private init(
        id: String,
        commandID: String,
        idempotencyKey: LedgerIdempotencyKey,
        phase: RuntimeTransactionPhase,
        mutationPlan: RuntimeMutationPlan,
        readSet: RuntimeReadSet,
        writeSet: RuntimeWriteSet,
        rollbackPlan: RuntimeRollbackPlan,
        preparedAt: String,
        schemaVersion: String
    ) {
        self.id = id
        self.commandID = commandID
        self.idempotencyKey = idempotencyKey
        self.phase = phase
        self.mutationPlan = mutationPlan
        self.readSet = readSet
        self.writeSet = writeSet
        self.rollbackPlan = rollbackPlan
        self.preparedAt = preparedAt
        self.schemaVersion = schemaVersion
    }
}

enum RuntimeTransactionDigest {
    static func digest(_ components: [String]) -> String {
        let material = components.joined(separator: "\u{1F}")
        let digest = SHA256.hash(data: Data(material.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func digestMap(_ values: [String: String]) -> String {
        digest(values.keys.sorted().flatMap { key in [key, values[key] ?? ""] })
    }
}

enum RuntimeTransactionObjectFacts {
    static func affectedObjectIDs(command: AmbitionsCommand, mutation: RuntimeMutation? = nil) -> [String] {
        normalized([
            command.target.goalID,
            command.target.captureID,
            command.target.timeID,
            command.target.reviewID,
            command.target.stepID,
            command.target.deliverableID,
            command.target.scopeItemID,
            command.target.recommendationID,
            command.target.explanationID,
        ].compactMap { $0 } + (mutation?.stageMutation.affectedObjectIDs ?? []))
    }

    static func families(command: AmbitionsCommand, mutation: RuntimeMutation? = nil) -> [ObjectStateFamily] {
        var families: [ObjectStateFamily] = []
        if command.target.goalID != nil || command.target.deliverableID != nil || command.target.scopeItemID != nil {
            families.append(.goalThread)
        }
        if command.target.stepID != nil {
            families.append(.step)
        }
        if command.target.captureID != nil {
            families.append(.capture)
        }
        if command.target.timeID != nil || mutation?.timeMutation != nil {
            families.append(.timeBlock)
        }
        if command.target.reviewID != nil || command.target.explanationID != nil || command.target.recommendationID != nil {
            families.append(.userSystem)
        }

        switch command.kind {
        case .completeAction, .delayAction, .splitAction, .recoverAction, .markWaiting, .archiveItem:
            families.append(.closure)
            families.append(.receipt)
        case .prepareExport, .performExport, .forgetMemory:
            families.append(.userSystem)
        case .askWhy, .dismissRecommendation:
            families.append(.proof)
        default:
            break
        }

        return Array(Set(families)).sorted { $0.rawValue < $1.rawValue }
    }

    static func projections(command: AmbitionsCommand, mutation: RuntimeMutation? = nil) -> [ProjectionID] {
        var projections: [ProjectionID] = [.receipt, .privacy, .search]
        switch command.source {
        case .today:
            projections.append(.today)
        case .goals, .goalDetail:
            projections.append(.goals)
        case .time:
            projections.append(.time)
        case .you:
            projections.append(.you)
        case .widget, .liveActivity:
            projections.append(.widget)
        case .appIntent:
            projections.append(.appIntent)
        case .capture, .reviews, .notification, .deepLink, .system:
            break
        }

        switch mutation?.stageMutation.targetSurface {
        case .today:
            projections.append(.today)
        case .goals:
            projections.append(.goals)
        case .time:
            projections.append(.time)
        case .you:
            projections.append(.you)
        case nil:
            break
        }

        if mutation?.timeMutation != nil || command.target.timeID != nil {
            projections.append(.time)
            projections.append(.today)
        }
        if command.target.goalID != nil || command.target.stepID != nil {
            projections.append(.goals)
            projections.append(.today)
        }
        if command.target.captureID != nil || command.kind == .quickCapture {
            projections.append(.today)
            projections.append(.you)
        }

        return Array(Set(projections)).sorted { $0.rawValue < $1.rawValue }
    }

    static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
