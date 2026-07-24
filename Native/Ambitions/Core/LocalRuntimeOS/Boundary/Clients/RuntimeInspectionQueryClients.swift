import Foundation

struct RuntimeObjectInspectionQuery: Sendable, Equatable {
    let objectID: RuntimeDomainObjectID
    let requestedAt: String
}

struct RuntimeObjectInspectionSnapshot: Equatable {
    let objectID: RuntimeDomainObjectID
    let receipts: [ReceiptProjectionEntry]
    let cursor: ProjectionCursor?
}

struct RuntimeHistoryQuery: Sendable, Equatable {
    let target: AmbitionsCommandTarget?
    let limit: Int
    let requestedAt: String
}

struct RuntimeHistorySnapshot: Equatable {
    let receipts: [ReceiptProjectionEntry]
    let cursor: ProjectionCursor?
}

struct RuntimeRecoveryQuery: Sendable, Equatable {
    let receiptID: RuntimeReceiptID
    let requestedAt: String
}

struct RuntimeRecoverySnapshot: Equatable {
    let receipt: ReceiptProjectionEntry
    let recovery: RuntimeRecovery
    let cursor: ProjectionCursor?
}

struct ObjectInspectionRuntimeQueryClient: Sendable {
    private let read: @Sendable (RuntimeObjectInspectionQuery) async -> RuntimeQueryTruth<RuntimeObjectInspectionSnapshot>
    init(read: @escaping @Sendable (RuntimeObjectInspectionQuery) async -> RuntimeQueryTruth<RuntimeObjectInspectionSnapshot>) {
        self.read = read
    }
    func query(_ request: RuntimeObjectInspectionQuery) async -> RuntimeQueryTruth<RuntimeObjectInspectionSnapshot> {
        await read(request)
    }
}

struct HistoryRuntimeQueryClient: Sendable {
    private let read: @Sendable (RuntimeHistoryQuery) async -> RuntimeQueryTruth<RuntimeHistorySnapshot>
    init(read: @escaping @Sendable (RuntimeHistoryQuery) async -> RuntimeQueryTruth<RuntimeHistorySnapshot>) {
        self.read = read
    }
    func query(_ request: RuntimeHistoryQuery) async -> RuntimeQueryTruth<RuntimeHistorySnapshot> {
        await read(request)
    }
}

struct RecoveryRuntimeQueryClient: Sendable {
    private let read: @Sendable (RuntimeRecoveryQuery) async -> RuntimeQueryTruth<RuntimeRecoverySnapshot>
    init(read: @escaping @Sendable (RuntimeRecoveryQuery) async -> RuntimeQueryTruth<RuntimeRecoverySnapshot>) {
        self.read = read
    }
    func query(_ request: RuntimeRecoveryQuery) async -> RuntimeQueryTruth<RuntimeRecoverySnapshot> {
        await read(request)
    }
}
