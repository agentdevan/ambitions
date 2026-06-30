import Foundation

enum CapturePromotionDestination: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case step
    case goal
    case proof
    case time
}

enum CapturePromotionTransactionError: Error, Equatable {
    case missingDurableIntake(String)
    case missingTargetObject(CapturePromotionDestination)
}

struct CapturePromotionTransactionRequest: Sendable, Equatable {
    let intakeReceipt: CaptureIntakeJournalReceipt
    let captureID: String
    let destination: CapturePromotionDestination
    let targetObjectIDs: [String]
    let occurredAt: String
    let summary: String
    let privacy: EventLedgerPrivacyClassification

    init(
        intakeReceipt: CaptureIntakeJournalReceipt,
        captureID: String,
        destination: CapturePromotionDestination,
        targetObjectIDs: [String],
        occurredAt: String,
        summary: String,
        privacy: EventLedgerPrivacyClassification = .privateUserText
    ) {
        self.intakeReceipt = intakeReceipt
        self.captureID = CaptureRouteGraphStableID.required(captureID)
        self.destination = destination
        self.targetObjectIDs = CaptureRouteGraphStableID.unique(targetObjectIDs)
        self.occurredAt = CaptureRouteGraphStableID.required(occurredAt)
        self.summary = CaptureRouteGraphStableID.required(summary)
        self.privacy = privacy
    }
}

struct CapturePromotionTransactionReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let captureID: String
    let intakeRecordID: String
    let destination: CapturePromotionDestination
    let targetObjectIDs: [String]
    let occurredAt: String
    let summary: String
    let writeAuthority: String
    let sideEffectPolicy: String
    let requiresUnitOfWork: Bool
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let runtimeTrace: CaptureRouteGraphRuntimeTrace
    let checksum: String

    init(request: CapturePromotionTransactionRequest) throws {
        guard request.intakeReceipt.canClassify else {
            throw CapturePromotionTransactionError.missingDurableIntake(request.intakeReceipt.journalRecordID)
        }
        guard request.targetObjectIDs.isEmpty == false else {
            throw CapturePromotionTransactionError.missingTargetObject(request.destination)
        }
        captureID = request.captureID
        intakeRecordID = request.intakeReceipt.journalRecordID
        destination = request.destination
        targetObjectIDs = request.targetObjectIDs
        occurredAt = request.occurredAt
        summary = request.summary
        writeAuthority = "Core/LocalRuntimeOS/CaptureRouteGraph + TransactionKernel"
        sideEffectPolicy = AppUnitOfWorkReceipt.noExternalSideEffects
        requiresUnitOfWork = true
        localOnly = true
        privacy = request.privacy
        id = CaptureRouteGraphStableID.make(
            prefix: "capture-promotion.receipt",
            components: [captureID, intakeRecordID, destination.rawValue, targetObjectIDs.joined(separator: ",")]
        )
        runtimeTrace = CaptureRouteGraphRuntimeTrace.make(owner: "CapturePromotionTransaction", sourceID: id)
        checksum = CaptureRouteGraphStableID.checksum(
            prefix: "capture-promotion.receipt",
            components: [
                id,
                captureID,
                intakeRecordID,
                destination.rawValue,
                targetObjectIDs.joined(separator: ","),
                occurredAt,
                summary,
                writeAuthority,
                sideEffectPolicy,
                "requires-uow",
                "local",
                privacy.rawValue,
                runtimeTrace.checksum
            ]
        )
    }

    var satisfiesRuntimeSpine: Bool {
        localOnly &&
            requiresUnitOfWork &&
            sideEffectPolicy == AppUnitOfWorkReceipt.noExternalSideEffects &&
            writeAuthority == "Core/LocalRuntimeOS/CaptureRouteGraph + TransactionKernel" &&
            runtimeTrace.satisfiesRuntimeSpine
    }
}

actor CapturePromotionTransaction {
    private var receiptsCache: [CapturePromotionTransactionReceipt]?
    private let fileStore: CaptureRouteGraphJSONFileStore<[CapturePromotionTransactionReceipt]>?

    init(fileURL: URL? = nil) {
        fileStore = fileURL.map { CaptureRouteGraphJSONFileStore(fileURL: $0, emptyValue: []) }
    }

    static func fileBacked(rootDirectory: URL) -> CapturePromotionTransaction {
        CapturePromotionTransaction(
            fileURL: CaptureRouteGraphJSONFileStore<[CapturePromotionTransactionReceipt]>.fileURL(
                rootDirectory: rootDirectory,
                fileName: "CapturePromotionTransaction.json"
            )
        )
    }

    @discardableResult
    func prepare(_ request: CapturePromotionTransactionRequest) async throws -> CapturePromotionTransactionReceipt {
        var receipts = try await loadReceipts()
        let receipt = try CapturePromotionTransactionReceipt(request: request)
        receipts.removeAll { $0.id == receipt.id }
        receipts.append(receipt)
        receipts.sort { $0.occurredAt < $1.occurredAt }
        try await persist(receipts)
        return receipt
    }

    func receipts(captureID: String? = nil) async throws -> [CapturePromotionTransactionReceipt] {
        let receipts = try await loadReceipts()
        guard let captureID = CaptureRouteGraphStableID.optional(captureID) else {
            return receipts
        }
        return receipts.filter { $0.captureID == captureID }
    }

    private func loadReceipts() async throws -> [CapturePromotionTransactionReceipt] {
        if let receiptsCache {
            return receiptsCache
        }
        let loaded = try await fileStore?.load() ?? []
        receiptsCache = loaded.sorted { $0.occurredAt < $1.occurredAt }
        return receiptsCache ?? []
    }

    private func persist(_ receipts: [CapturePromotionTransactionReceipt]) async throws {
        receiptsCache = receipts
        try await fileStore?.save(receipts)
    }
}
