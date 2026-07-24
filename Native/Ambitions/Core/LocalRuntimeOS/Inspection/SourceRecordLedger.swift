import Foundation

let sourceRecordLedgerSchemaVersion = "source_record_ledger.native.v1"

enum SourceRecordLedgerKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case commandRecord = "command_record"
    case runtimeEvent = "runtime_event"
    case actionReceipt = "action_receipt"
    case proofReference = "proof_reference"
    case publicSourceAtlasReference = "public_source_atlas_reference"
}

enum SourceRecordLedgerBoundary: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case privateLifeGraph = "private_life_graph"
    case publicReference = "public_reference"
    case localSystem = "local_system"
}

struct SourceRecordLedgerRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: SourceRecordLedgerKind
    let boundary: SourceRecordLedgerBoundary
    let sourceID: String
    let sourceSummary: String
    let occurredAt: String
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let allowsNetworkRefresh: Bool
    let containsPrivateLifeGraph: Bool
    let receiptIDs: [String]
    let proofReferenceIDs: [String]
    let eventLedgerEntryIDs: [String]
    let commandIDs: [String]
    let runtimeTransactionID: String?
    let runtimeEventID: String?
    let runtimeReceiptID: String?
    let runtimeReplayTraceID: String?
    let schemaVersion: String

    init(
        id: String,
        kind: SourceRecordLedgerKind,
        boundary: SourceRecordLedgerBoundary,
        sourceID: String,
        sourceSummary: String,
        occurredAt: String,
        privacy: EventLedgerPrivacyClassification,
        localOnly: Bool = true,
        allowsNetworkRefresh: Bool = false,
        containsPrivateLifeGraph: Bool,
        receiptIDs: [String] = [],
        proofReferenceIDs: [String] = [],
        eventLedgerEntryIDs: [String] = [],
        commandIDs: [String] = [],
        runtimeTransactionID: String? = nil,
        runtimeEventID: String? = nil,
        runtimeReceiptID: String? = nil,
        runtimeReplayTraceID: String? = nil,
        schemaVersion: String = sourceRecordLedgerSchemaVersion
    ) {
        self.id = Self.normalized(id, fallback: "\(kind.rawValue).\(sourceID)")
        self.kind = kind
        self.boundary = boundary
        self.sourceID = Self.normalized(sourceID, fallback: id)
        self.sourceSummary = Self.normalized(sourceSummary, fallback: kind.rawValue)
        self.occurredAt = Self.normalized(occurredAt, fallback: "unknown")
        self.privacy = privacy
        self.localOnly = localOnly
        self.allowsNetworkRefresh = allowsNetworkRefresh
        self.containsPrivateLifeGraph = containsPrivateLifeGraph
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.proofReferenceIDs = Self.orderedUnique(proofReferenceIDs)
        self.eventLedgerEntryIDs = Self.orderedUnique(eventLedgerEntryIDs)
        self.commandIDs = Self.orderedUnique(commandIDs)
        self.runtimeTransactionID = Self.normalizedOptional(runtimeTransactionID)
        self.runtimeEventID = Self.normalizedOptional(runtimeEventID)
        self.runtimeReceiptID = Self.normalizedOptional(runtimeReceiptID)
        self.runtimeReplayTraceID = Self.normalizedOptional(runtimeReplayTraceID)
        self.schemaVersion = schemaVersion
    }

    static func command(_ commandRecord: AmbitionsCommandExecutionRecord) -> SourceRecordLedgerRecord {
        SourceRecordLedgerRecord(
            id: "source.command.\(commandRecord.commandID)",
            kind: .commandRecord,
            boundary: .privateLifeGraph,
            sourceID: commandRecord.id,
            sourceSummary: "Command \(commandRecord.command.operation.rawValue) recorded locally.",
            occurredAt: commandRecord.recordedAt,
            privacy: commandRecord.privacy,
            containsPrivateLifeGraph: true,
            commandIDs: [commandRecord.commandID],
            runtimeTransactionID: RuntimeTrustLineage.eventMetadataLineage(commandRecord.result.metadata)?.runtimeTransactionID,
            runtimeEventID: RuntimeTrustLineage.eventMetadataLineage(commandRecord.result.metadata)?.runtimeEventID,
            runtimeReceiptID: RuntimeTrustLineage.eventMetadataLineage(commandRecord.result.metadata)?.runtimeReceiptID,
            runtimeReplayTraceID: RuntimeTrustLineage.eventMetadataLineage(commandRecord.result.metadata)?.runtimeReplayTraceID
        )
    }

    static func runtimeEvent(
        _ eventLedgerEntry: EventLedgerEntry,
        commandID: String?,
        runtimeLineage: RuntimeTrustLineage?
    ) -> SourceRecordLedgerRecord {
        SourceRecordLedgerRecord(
            id: "source.event.\(eventLedgerEntry.id)",
            kind: .runtimeEvent,
            boundary: .privateLifeGraph,
            sourceID: eventLedgerEntry.id,
            sourceSummary: eventLedgerEntry.title,
            occurredAt: eventLedgerEntry.occurredAt,
            privacy: eventLedgerEntry.privacy,
            localOnly: eventLedgerEntry.localOnly,
            containsPrivateLifeGraph: true,
            eventLedgerEntryIDs: [eventLedgerEntry.id],
            commandIDs: [commandID].compactMap { $0 },
            runtimeTransactionID: runtimeLineage?.runtimeTransactionID,
            runtimeEventID: runtimeLineage?.runtimeEventID,
            runtimeReceiptID: runtimeLineage?.runtimeReceiptID,
            runtimeReplayTraceID: runtimeLineage?.runtimeReplayTraceID
        )
    }

    static func actionReceipt(_ receiptRecord: ActionReceiptHistoryRecord) -> SourceRecordLedgerRecord {
        SourceRecordLedgerRecord(
            id: "source.receipt.\(receiptRecord.id)",
            kind: .actionReceipt,
            boundary: .privateLifeGraph,
            sourceID: receiptRecord.id,
            sourceSummary: receiptRecord.receipt.title,
            occurredAt: receiptRecord.receipt.occurredAt,
            privacy: receiptRecord.privacyLevel.eventLedgerPrivacy,
            localOnly: receiptRecord.localOnly,
            containsPrivateLifeGraph: true,
            receiptIDs: [receiptRecord.id],
            proofReferenceIDs: receiptRecord.proofReferenceIDs,
            runtimeTransactionID: receiptRecord.runtimeLineage?.runtimeTransactionID,
            runtimeEventID: receiptRecord.runtimeLineage?.runtimeEventID,
            runtimeReceiptID: receiptRecord.runtimeLineage?.runtimeReceiptID,
            runtimeReplayTraceID: receiptRecord.runtimeLineage?.runtimeReplayTraceID
        )
    }

    static func proofReference(
        _ proofReference: ProofReference,
        receiptRecord: ActionReceiptHistoryRecord
    ) -> SourceRecordLedgerRecord {
        SourceRecordLedgerRecord(
            id: "source.proof.\(proofReference.id)",
            kind: .proofReference,
            boundary: .privateLifeGraph,
            sourceID: proofReference.id,
            sourceSummary: proofReference.title,
            occurredAt: proofReference.occurredAt ?? receiptRecord.receipt.occurredAt,
            privacy: .sensitive,
            localOnly: true,
            containsPrivateLifeGraph: true,
            receiptIDs: [receiptRecord.id],
            proofReferenceIDs: [proofReference.id],
            runtimeTransactionID: receiptRecord.runtimeLineage?.runtimeTransactionID,
            runtimeEventID: receiptRecord.runtimeLineage?.runtimeEventID,
            runtimeReceiptID: receiptRecord.runtimeLineage?.runtimeReceiptID,
            runtimeReplayTraceID: receiptRecord.runtimeLineage?.runtimeReplayTraceID
        )
    }

    static func publicSourceAtlasReference(
        packID: String,
        manifestID: String?,
        summary: String,
        observedAt: String,
        linkedReceiptIDs: [String] = []
    ) -> SourceRecordLedgerRecord {
        let normalizedPackID = normalized(packID, fallback: "source-atlas-pack")
        return SourceRecordLedgerRecord(
            id: "source.public-source-atlas.\(normalizedPackID)",
            kind: .publicSourceAtlasReference,
            boundary: .publicReference,
            sourceID: manifestID.map { "\(normalizedPackID).\($0)" } ?? normalizedPackID,
            sourceSummary: summary,
            occurredAt: observedAt,
            privacy: .standard,
            localOnly: true,
            allowsNetworkRefresh: true,
            containsPrivateLifeGraph: false,
            receiptIDs: linkedReceiptIDs
        )
    }

    var isPublicReferenceOnly: Bool {
        boundary == .publicReference &&
            kind == .publicSourceAtlasReference &&
            containsPrivateLifeGraph == false &&
            privacy == .standard &&
            runtimeTransactionID == nil &&
            runtimeEventID == nil &&
            runtimeReceiptID == nil &&
            runtimeReplayTraceID == nil
    }

    var hasPrivateRuntimeLineage: Bool {
        runtimeTransactionID != nil &&
            runtimeEventID != nil &&
            runtimeReceiptID != nil &&
            runtimeReplayTraceID != nil
    }

    private static func normalized(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
    }
}

struct SourceRecordLedgerSeparationReport: Codable, Sendable, Equatable, Hashable {
    let publicReferenceRecordIDs: [String]
    let privateLifeGraphRecordIDs: [String]
    let blockedPublicRecordIDs: [String]
    let localOnlyPrivateRecords: Bool

    var isSeparated: Bool {
        blockedPublicRecordIDs.isEmpty && localOnlyPrivateRecords
    }
}

struct SourceRecordLedger: Codable, Sendable, Equatable, Hashable {
    let records: [SourceRecordLedgerRecord]

    init(records: [SourceRecordLedgerRecord] = []) {
        self.records = Self.orderedUnique(records)
    }

    var publicSourceAtlasRecords: [SourceRecordLedgerRecord] {
        records.filter { $0.kind == .publicSourceAtlasReference }
    }

    var privateLifeGraphRecords: [SourceRecordLedgerRecord] {
        records.filter { $0.boundary == .privateLifeGraph }
    }

    var separationReport: SourceRecordLedgerSeparationReport {
        SourceRecordLedgerSeparationReport(
            publicReferenceRecordIDs: publicSourceAtlasRecords.map(\.id),
            privateLifeGraphRecordIDs: privateLifeGraphRecords.map(\.id),
            blockedPublicRecordIDs: publicSourceAtlasRecords
                .filter { $0.isPublicReferenceOnly == false }
                .map(\.id),
            localOnlyPrivateRecords: privateLifeGraphRecords.allSatisfy { $0.localOnly && $0.allowsNetworkRefresh == false }
        )
    }

    func appending(_ record: SourceRecordLedgerRecord) -> SourceRecordLedger {
        SourceRecordLedger(records: records + [record])
    }

    static func orderedUnique(_ records: [SourceRecordLedgerRecord]) -> [SourceRecordLedgerRecord] {
        var seen = Set<String>()
        return records
            .filter { $0.id.isEmpty == false && $0.sourceID.isEmpty == false }
            .filter { seen.insert($0.id).inserted }
            .sorted {
                if $0.occurredAt != $1.occurredAt {
                    return $0.occurredAt < $1.occurredAt
                }
                return $0.id < $1.id
            }
    }
}

extension ActionReceiptPrivacyLevel {
    var eventLedgerPrivacy: EventLedgerPrivacyClassification {
        switch self {
        case .safeToShow:
            return .standard
        case .privateItem:
            return .privateUserText
        case .sensitive:
            return .sensitive
        case .redacted:
            return .sensitive
        case .unavailable:
            return .privateUserText
        }
    }
}
