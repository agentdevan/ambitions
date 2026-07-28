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

struct ObjectInspectionRuntimeQueryClient: Sendable {
    private let read: @Sendable (RuntimeObjectInspectionQuery) async -> RuntimeQueryTruth<RuntimeObjectInspectionSnapshot>
    init(read: @escaping @Sendable (RuntimeObjectInspectionQuery) async -> RuntimeQueryTruth<RuntimeObjectInspectionSnapshot>) {
        self.read = read
    }
    func query(_ request: RuntimeObjectInspectionQuery) async -> RuntimeQueryTruth<RuntimeObjectInspectionSnapshot> {
        await read(request)
    }
}
