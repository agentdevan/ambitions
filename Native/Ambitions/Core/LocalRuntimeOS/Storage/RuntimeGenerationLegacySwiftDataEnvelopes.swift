import Foundation

/// Version of the lossless SwiftData source-envelope format. These envelopes
/// are discovery evidence only: decoding one never authorizes materialization.
enum RuntimeLegacySwiftDataEnvelopeVersion: Int, Codable, Sendable, Equatable, Hashable {
    case v1 = 1
}

enum RuntimeLegacySwiftDataSourceModelType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goal = "GoalRecord"
    case goalDraft = "GoalDraftRecord"
    case goalPlan = "GoalPlanRecord"
    case planSection = "PlanSectionRecord"
    case step = "StepRecord"
    case progressEvidence = "ProgressEvidenceRecord"
    case feedbackEvent = "FeedbackEventRecord"
    case capture = "CaptureRecord"
    case reminder = "ReminderRecord"
    case teachingSignal = "TeachingSignalRecord"
    case eventLedger = "EventLedgerRecord"
    case commandExecution = "CommandExecutionRecord"
    case sideEffectLedger = "SideEffectLedgerStorageRecord"
    case entityRevisionTombstone = "EntityRevisionTombstoneRecord"
    case appState = "AppStateRecord"
    case actionReceipt = "ActionReceiptHistoryRecordModel"
    case runtimeSnapshot = "RuntimeSnapshotLedgerRecord"
    case lifeContext = "LifeContextBundleRecord"
    case graphOperational = "AmbitionGraphOperationalRecordModel"
    case graphProof = "AmbitionGraphProofRecordModel"
    case graphProjection = "AmbitionGraphProjectionRecordModel"

    var orderingOrdinal: Int {
        switch self {
        case .goal: 0
        case .goalDraft: 1
        case .goalPlan: 2
        case .planSection: 3
        case .step: 4
        case .progressEvidence: 5
        case .feedbackEvent: 6
        case .capture: 7
        case .reminder: 8
        case .teachingSignal: 9
        case .eventLedger: 10
        case .commandExecution: 11
        case .sideEffectLedger: 12
        case .entityRevisionTombstone: 13
        case .appState: 14
        case .actionReceipt: 15
        case .runtimeSnapshot: 16
        case .lifeContext: 17
        case .graphOperational: 18
        case .graphProof: 19
        case .graphProjection: 20
        }
    }

    var sourceDisposition: RuntimeLegacySwiftDataSourceDisposition {
        switch self {
        case .goal, .goalDraft, .progressEvidence, .feedbackEvent, .capture,
             .teachingSignal, .lifeContext:
            .authorityCandidate
        case .goalPlan:
            .compositeRootCandidate
        case .planSection, .step:
            .compositeChildCandidate
        case .reminder:
            .externalReconciliationCandidate
        case .eventLedger, .commandExecution, .sideEffectLedger, .actionReceipt,
             .graphProof:
            .evidenceOnly
        case .entityRevisionTombstone:
            .tombstoneCandidate
        case .appState:
            .splitAuthorityAndRestoration
        case .runtimeSnapshot, .graphOperational, .graphProjection:
            .derivedRebuildOnly
        }
    }
}

/// Model-owned, lossless keyset cursor. The codec validates the exact component
/// arity and optional-value tags before a cursor can participate in paging.
/// This keeps SwiftData sort descriptors and exported semantic ordering under
/// one production authority that is also directly inspectable through
/// `@testable import`.
struct RuntimeLegacySwiftDataModelCursor: Sendable, Equatable, Hashable {
    let modelType: RuntimeLegacySwiftDataSourceModelType
    let components: [String]

    init(
        modelType: RuntimeLegacySwiftDataSourceModelType,
        components: [String]
    ) throws {
        try modelType.validateCursorComponents(components)
        self.modelType = modelType
        self.components = components
    }

    var count: Int { components.count }

    subscript(index: Int) -> String { components[index] }

    func isStrictlyAfter(_ prior: Self) -> Bool {
        modelType == prior.modelType &&
            prior.components.lexicographicallyPrecedes(components)
    }
}

extension RuntimeLegacySwiftDataSourceModelType {
    var cursorArity: Int {
        switch self {
        case .goal, .goalPlan, .actionReceipt, .graphOperational, .graphProjection: 3
        case .goalDraft, .capture, .teachingSignal, .eventLedger,
             .commandExecution, .sideEffectLedger, .runtimeSnapshot, .lifeContext: 2
        case .planSection, .feedbackEvent, .reminder, .graphProof: 4
        case .step, .progressEvidence, .entityRevisionTombstone: 5
        case .appState: 1
        }
    }

    func validateCursorComponents(_ components: [String]) throws {
        guard components.count == cursorArity,
              components.last?.isEmpty == false else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        switch self {
        case .progressEvidence:
            try Self.validateOptionalCursorTag(
                components[2], value: components[3]
            )
        case .reminder:
            try Self.validateOptionalCursorTag(
                components[0], value: components[1]
            )
        default:
            break
        }
        switch self {
        case .goal, .goalPlan:
            try Self.validateFixedWidthNonnegativeInteger(components[1])
        case .planSection:
            try Self.validateFixedWidthNonnegativeInteger(components[2])
        case .step:
            try Self.validateFixedWidthNonnegativeInteger(components[3])
        case .graphProof:
            try Self.validateFixedWidthNonnegativeInteger(components[1])
        default:
            break
        }
    }

    private static func validateOptionalCursorTag(
        _ tag: String,
        value: String
    ) throws {
        guard tag == "1" || (tag == "0" && value.isEmpty) else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
    }

    private static func validateFixedWidthNonnegativeInteger(
        _ value: String
    ) throws {
        guard value.utf8.count == 20,
              value.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }) else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
    }
}

/// Source semantics used by review. No case is an activation or write grant.
enum RuntimeLegacySwiftDataSourceDisposition: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case authorityCandidate = "authority_candidate"
    case compositeRootCandidate = "composite_root_candidate"
    case compositeChildCandidate = "composite_child_candidate"
    case externalReconciliationCandidate = "external_reconciliation_candidate"
    case evidenceOnly = "evidence_only"
    case tombstoneCandidate = "tombstone_candidate"
    case splitAuthorityAndRestoration = "split_authority_and_restoration"
    case derivedRebuildOnly = "derived_rebuild_only"

    var isReviewableDiscovery: Bool { true }
    var isMaterializable: Bool { false }
}

enum RuntimeLegacySwiftDataEncodedColumnEncoding: String, Codable, Sendable, Equatable, Hashable {
    case canonicalJSON = "canonical_json"
    case runtimeCommandCodec = "runtime_command_codec"
}

/// Lossless bytes plus their schema-owned decoded type. The type name is a
/// validation binding, not a claim that the bytes have already been accepted.
struct RuntimeLegacySwiftDataEncodedColumn: Codable, Sendable, Equatable, Hashable {
    let columnName: String
    let encodedTypeName: String
    let encoding: RuntimeLegacySwiftDataEncodedColumnEncoding
    let bytes: Data
    let byteCount: Int
    let bytesDigest: String

    static func make(
        columnName: String,
        encodedTypeName: String,
        encoding: RuntimeLegacySwiftDataEncodedColumnEncoding = .canonicalJSON,
        bytes: Data
    ) throws -> Self {
        let value = Self(
            columnName: columnName,
            encodedTypeName: encodedTypeName,
            encoding: encoding,
            bytes: bytes,
            byteCount: bytes.count,
            bytesDigest: LocalRuntimeStorageChecksum.sha256Hex(for: bytes)
        )
        try value.validate()
        return value
    }

    func validate() throws {
        try RuntimeLegacySwiftDataEnvelopeValidation.requireNonempty(columnName, field: "encoded_column_name")
        try RuntimeLegacySwiftDataEnvelopeValidation.requireNonempty(encodedTypeName, field: "encoded_type_name")
        guard byteCount >= 0, byteCount == bytes.count else {
            throw RuntimeGenerationControlError.malformed(field: "encoded_column_byte_count")
        }
        try RuntimeLegacySwiftDataEnvelopeValidation.requireDigest(bytesDigest, field: "encoded_column_digest")
        guard bytesDigest == LocalRuntimeStorageChecksum.sha256Hex(for: bytes) else {
            throw RuntimeGenerationControlError.malformed(field: "encoded_column_digest")
        }
    }
}

/// Ambiguity-free key encoding. Each UTF-8 component is preceded by an
/// unsigned 64-bit big-endian byte length.
struct RuntimeLegacySwiftDataCompositeOrderingKey: Codable, Sendable, Equatable, Hashable, Comparable {
    let modelOrdinal: Int
    let components: [String]
    let lengthPrefixedBytes: Data

    static func make(
        modelType: RuntimeLegacySwiftDataSourceModelType,
        orderingComponents: [String],
        stableRecordID: String
    ) throws -> Self {
        try RuntimeLegacySwiftDataEnvelopeValidation.requireNonempty(stableRecordID, field: "source_stable_record_id")
        guard orderingComponents.isEmpty == false,
              orderingComponents.last == stableRecordID else {
            throw RuntimeGenerationControlError.malformed(
                field: "source_ordering_components"
            )
        }
        let components = [modelType.rawValue] + orderingComponents
        return Self(
            modelOrdinal: modelType.orderingOrdinal,
            components: components,
            lengthPrefixedBytes: encode(components)
        )
    }

    func validate(
        modelType: RuntimeLegacySwiftDataSourceModelType,
        orderingComponents: [String],
        stableRecordID: String
    ) throws {
        guard modelOrdinal == modelType.orderingOrdinal,
              orderingComponents.isEmpty == false,
              orderingComponents.last == stableRecordID,
              components == [modelType.rawValue] + orderingComponents,
              lengthPrefixedBytes == Self.encode(components) else {
            throw RuntimeGenerationControlError.malformed(field: "swiftdata_composite_ordering_key")
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.modelOrdinal != rhs.modelOrdinal { return lhs.modelOrdinal < rhs.modelOrdinal }
        return lhs.components.lexicographicallyPrecedes(rhs.components)
    }

    private static func encode(_ components: [String]) -> Data {
        var result = Data()
        for component in components {
            let bytes = Data(component.utf8)
            let count = UInt64(bytes.count)
            for shift in stride(from: 56, through: 0, by: -8) {
                result.append(UInt8((count >> UInt64(shift)) & 0xff))
            }
            result.append(bytes)
        }
        return result
    }
}

struct RuntimeLegacySwiftDataSourceIdentity: Codable, Sendable, Equatable, Hashable {
    let sourceSchemaVersion: String
    let modelType: RuntimeLegacySwiftDataSourceModelType
    let stableRecordID: String
    let orderingKey: RuntimeLegacySwiftDataCompositeOrderingKey
    let identityDigest: String

    static func make(
        sourceSchemaVersion: String,
        modelType: RuntimeLegacySwiftDataSourceModelType,
        orderingComponents: [String],
        stableRecordID: String
    ) throws -> Self {
        let orderingKey = try RuntimeLegacySwiftDataCompositeOrderingKey.make(
            modelType: modelType,
            orderingComponents: orderingComponents,
            stableRecordID: stableRecordID
        )
        let material = RuntimeLegacySwiftDataSourceIdentityDigestMaterial(
            sourceSchemaVersion: sourceSchemaVersion,
            modelType: modelType,
            stableRecordID: stableRecordID,
            orderingKey: orderingKey
        )
        let value = Self(
            sourceSchemaVersion: sourceSchemaVersion,
            modelType: modelType,
            stableRecordID: stableRecordID,
            orderingKey: orderingKey,
            identityDigest: try RuntimeGenerationControlCodec.digest(material)
        )
        try value.validate()
        return value
    }

    func validate() throws {
        try validate(orderingComponents: Array(orderingKey.components.dropFirst()))
    }

    func validate(orderingComponents: [String]) throws {
        try RuntimeLegacySwiftDataEnvelopeValidation.requireNonempty(sourceSchemaVersion, field: "source_schema_version")
        try RuntimeLegacySwiftDataEnvelopeValidation.requireNonempty(stableRecordID, field: "source_stable_record_id")
        try orderingKey.validate(
            modelType: modelType,
            orderingComponents: orderingComponents,
            stableRecordID: stableRecordID
        )
        try RuntimeLegacySwiftDataEnvelopeValidation.requireDigest(identityDigest, field: "source_identity_digest")
        let material = RuntimeLegacySwiftDataSourceIdentityDigestMaterial(
            sourceSchemaVersion: sourceSchemaVersion,
            modelType: modelType,
            stableRecordID: stableRecordID,
            orderingKey: orderingKey
        )
        guard identityDigest == (try RuntimeGenerationControlCodec.digest(material)) else {
            throw RuntimeGenerationControlError.malformed(field: "source_identity_digest")
        }
    }
}

private struct RuntimeLegacySwiftDataSourceIdentityDigestMaterial: Encodable {
    let sourceSchemaVersion: String
    let modelType: RuntimeLegacySwiftDataSourceModelType
    let stableRecordID: String
    let orderingKey: RuntimeLegacySwiftDataCompositeOrderingKey
}

enum RuntimeLegacySwiftDataRelationshipKind: String, Codable, Sendable, Equatable, Hashable {
    case parent = "parent"
    case child = "child"
    case orderedChild = "ordered_child"
    case dependency = "dependency"
    case reference = "reference"
    case source = "source"
    case receipt = "receipt"
    case replayTrace = "replay_trace"
    case supersedes = "supersedes"
    case attachedObject = "attached_object"
}

/// A relationship observed or decoded from source columns. It is evidence for
/// later review and does not establish referential validity or write order.
struct RuntimeLegacySwiftDataRelationshipClaim: Codable, Sendable, Equatable, Hashable {
    let sourceColumnName: String
    let kind: RuntimeLegacySwiftDataRelationshipKind
    let targetModelType: RuntimeLegacySwiftDataSourceModelType?
    let targetTypeName: String
    let targetStableID: String
    let isRequired: Bool
    let orderIndex: Int?
    let claimDigest: String

    static func make(
        sourceColumnName: String,
        kind: RuntimeLegacySwiftDataRelationshipKind,
        targetModelType: RuntimeLegacySwiftDataSourceModelType? = nil,
        targetTypeName: String,
        targetStableID: String,
        isRequired: Bool,
        orderIndex: Int? = nil
    ) throws -> Self {
        let material = RuntimeLegacySwiftDataRelationshipClaimDigestMaterial(
            sourceColumnName: sourceColumnName,
            kind: kind,
            targetModelType: targetModelType,
            targetTypeName: targetTypeName,
            targetStableID: targetStableID,
            isRequired: isRequired,
            orderIndex: orderIndex
        )
        let value = Self(
            sourceColumnName: sourceColumnName,
            kind: kind,
            targetModelType: targetModelType,
            targetTypeName: targetTypeName,
            targetStableID: targetStableID,
            isRequired: isRequired,
            orderIndex: orderIndex,
            claimDigest: try RuntimeGenerationControlCodec.digest(material)
        )
        try value.validate()
        return value
    }

    func validate() throws {
        try RuntimeLegacySwiftDataEnvelopeValidation.requireNonempty(sourceColumnName, field: "relationship_source_column")
        try RuntimeLegacySwiftDataEnvelopeValidation.requireNonempty(targetTypeName, field: "relationship_target_type")
        try RuntimeLegacySwiftDataEnvelopeValidation.requireNonempty(targetStableID, field: "relationship_target_id")
        if let orderIndex, orderIndex < 0 {
            throw RuntimeGenerationControlError.malformed(field: "relationship_order_index")
        }
        try RuntimeLegacySwiftDataEnvelopeValidation.requireDigest(claimDigest, field: "relationship_claim_digest")
        let material = RuntimeLegacySwiftDataRelationshipClaimDigestMaterial(
            sourceColumnName: sourceColumnName,
            kind: kind,
            targetModelType: targetModelType,
            targetTypeName: targetTypeName,
            targetStableID: targetStableID,
            isRequired: isRequired,
            orderIndex: orderIndex
        )
        guard claimDigest == (try RuntimeGenerationControlCodec.digest(material)) else {
            throw RuntimeGenerationControlError.malformed(field: "relationship_claim_digest")
        }
    }
}

private struct RuntimeLegacySwiftDataRelationshipClaimDigestMaterial: Encodable {
    let sourceColumnName: String
    let kind: RuntimeLegacySwiftDataRelationshipKind
    let targetModelType: RuntimeLegacySwiftDataSourceModelType?
    let targetTypeName: String
    let targetStableID: String
    let isRequired: Bool
    let orderIndex: Int?
}

// MARK: - Lossless source payloads

struct RuntimeLegacySwiftDataGoalPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let revision: Int
    let createdAt: String
    let updatedAt: String
    let stateRaw: String
    let title: String
    let summaryText: String?
    let modeRaw: String
    let relationshipKindRaw: String
    let actorDisplayName: String
    let actorOwnershipRaw: String
    let parentGoalID: String?
    let childGoalIDs: RuntimeLegacySwiftDataEncodedColumn
    let supportGoalIDs: RuntimeLegacySwiftDataEncodedColumn
    let tags: RuntimeLegacySwiftDataEncodedColumn
    let tempoRaw: String
    let timingTypeRaw: String
    let startsOn: String?
    let dueAt: String?
    let targetBy: String?
    let windowStart: String?
    let windowEnd: String?
    let suggestedNextAt: String?
    let repeatEveryDays: Int?
    let progressReviewCadenceDays: Int?
    let planningStrategy: RuntimeLegacySwiftDataEncodedColumn
    let progressStrategy: RuntimeLegacySwiftDataEncodedColumn
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataGoalDraftPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let title: String
    let modeRaw: String
    let resultKindRaw: String?
    let readinessRaw: String?
    let plannedGoalID: String?
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataGoalPlanPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let goalID: String
    let version: Int
    let generatedAt: String
    let summaryText: String?
    let strategy: RuntimeLegacySwiftDataEncodedColumn
    let assumptions: RuntimeLegacySwiftDataEncodedColumn
    let lint: RuntimeLegacySwiftDataEncodedColumn
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataPlanSectionPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let goalID: String
    let planID: String
    let title: String
    let summaryText: String?
    let kindRaw: String
    let orderIndex: Int
}

struct RuntimeLegacySwiftDataStepPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let goalID: String
    let planID: String
    let sectionID: String
    let orderIndex: Int
    let title: String
    let summaryText: String?
    let typeRaw: String
    let stateRaw: String
    let ownerDisplayName: String
    let ownerOwnershipRaw: String
    let tempoRaw: String
    let timingTypeRaw: String
    let startsOn: String?
    let dueAt: String?
    let targetBy: String?
    let windowStart: String?
    let windowEnd: String?
    let suggestedNextAt: String?
    let repeatEveryDays: Int?
    let progressReviewCadenceDays: Int?
    let dependencyStepIDs: RuntimeLegacySwiftDataEncodedColumn
    let successSignals: RuntimeLegacySwiftDataEncodedColumn
    let actionability: RuntimeLegacySwiftDataEncodedColumn
    let isOptional: Bool
    let isRepeatable: Bool
    let evidenceRequired: Bool
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataProgressEvidencePayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let goalID: String
    let stepID: String?
    let capturedAt: String
    let evidenceKindRaw: String
    let sourceRaw: String
    let progressDelta: Double?
    let confidenceDelta: Double?
    let minutesInvested: Int?
    let note: String?
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataFeedbackEventPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let goalID: String
    let stepID: String
    let occurredAt: String
    let kindRaw: String
    let note: String?
    let payload: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataCapturePayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let rawText: String
    let sourceTypeRaw: String?
    let statusRaw: String
    let linkedGoalID: String?
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataReminderPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let title: String
    let summaryText: String?
    let triggerAt: String?
    let kindRaw: String
    let stateRaw: String
    let receiptID: String?
    let replayTraceID: String?
    let sourceRecordID: String?
    let attachedObjectID: String?
    let deliveryPolicy: RuntimeLegacySwiftDataEncodedColumn
    let source: RuntimeLegacySwiftDataEncodedColumn
    let attachment: RuntimeLegacySwiftDataEncodedColumn?
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataTeachingSignalPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let goalID: String
    let kindRaw: String
    let sourceRaw: String
    let dispositionRaw: String
    let applicationKey: String
    let createdAt: String
    let updatedAt: String
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataEventLedgerPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let kindRaw: String
    let occurredAt: String
    let occurredAtDate: Date?
    let sourceRaw: String
    let goalID: String?
    let captureID: String?
    let planID: String?
    let planScope: String?
    let reviewID: String?
    let title: String
    let summaryText: String?
    let semanticState: String?
    let toneRaw: String
    let schemaVersion: String
    let privacyRaw: String
    let localOnly: Bool
    let createdAt: String
    let createdAtDate: Date?
    let updatedAt: String
    let updatedAtDate: Date?
    let evidenceReferences: RuntimeLegacySwiftDataEncodedColumn
    let metadata: RuntimeLegacySwiftDataEncodedColumn
    let payload: RuntimeLegacySwiftDataEncodedColumn
    let trust: RuntimeLegacySwiftDataEncodedColumn
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataCommandExecutionPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let commandID: String
    let commandKindRaw: String
    let commandSourceRaw: String
    let actorRaw: String
    let executionStatusRaw: String
    let resultStatusRaw: String
    let recordedAt: String
    let recordedAtDate: Date?
    let schemaVersion: String
    let localOnly: Bool
    let privacyRaw: String
    let command: RuntimeLegacySwiftDataEncodedColumn
    let result: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataSideEffectLedgerPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let effectKindRaw: String
    let statusRaw: String
    let boundaryRaw: String
    let actionKindRaw: String
    let sourceDomainRaw: String
    let commandID: String?
    let targetObjects: RuntimeLegacySwiftDataEncodedColumn
    let requiresConfirmation: Bool
    let externalEffect: Bool
    let reasons: RuntimeLegacySwiftDataEncodedColumn
    let blockedFacts: RuntimeLegacySwiftDataEncodedColumn
    let degradedFacts: RuntimeLegacySwiftDataEncodedColumn
    let receiptID: String?
    let schemaVersion: String
    let localOnly: Bool
    let occurredAt: String
    let occurredAtDate: Date?
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataEntityRevisionTombstonePayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let entityKindRaw: String
    let entityID: String
    let revisionMarker: String
    let reasonRaw: String
    let recordedAt: String
    let recordedAtDate: Date?
    let localOnly: Bool
    let lineageID: String
    let ancestryLineageIDs: RuntimeLegacySwiftDataEncodedColumn
    let lifecycleStateRaw: String
    let privacyClassRaw: String
    let sourceRecordID: String?
    let receiptID: String?
    let replayTraceID: String?
    let schemaVersion: String
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataAppStatePayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let preferredTabRaw: String
    let userDisplayName: String
    let appearancePreferenceRaw: String
    let accentFamilyRaw: String?
    let hasCompletedBootstrap: Bool
    let lastBootstrapSourceRaw: String?
    let lastBootstrapAt: String?
    let lastSeedVersion: String?
    let lastSeededAt: String?
    let lastOpenedGoalID: String?
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataActionReceiptPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let sourceDomainRaw: String
    let resultStateRaw: String
    let privacyLevelRaw: String
    let proofRelevanceRaw: String
    let undoAvailabilityRaw: String
    let requiresConfirmationBeforeBroaderUse: Bool
    let localOnly: Bool
    let createdAt: String
    let createdAtDate: Date?
    let occurredAt: String
    let occurredAtDate: Date?
    let receipt: RuntimeLegacySwiftDataEncodedColumn
    let proofFreshnessLineage: RuntimeLegacySwiftDataEncodedColumn
    let runtimeLineage: RuntimeLegacySwiftDataEncodedColumn?
}

struct RuntimeLegacySwiftDataRuntimeSnapshotPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let generatedAt: String
    let sourceRecordIDs: RuntimeLegacySwiftDataEncodedColumn
    let receiptIDs: RuntimeLegacySwiftDataEncodedColumn
    let replayTraceIDs: RuntimeLegacySwiftDataEncodedColumn
    let recommendationInputReferenceIDs: RuntimeLegacySwiftDataEncodedColumn
    let proofInputReferenceIDs: RuntimeLegacySwiftDataEncodedColumn
    let afep02LineageReferenceIDs: RuntimeLegacySwiftDataEncodedColumn
    let fieldRedactions: RuntimeLegacySwiftDataEncodedColumn
    let compatibilityStatusRaw: String
    let checksum: String
    let provenanceHash: String
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataLifeContextPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataGraphOperationalPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let surfaceRaw: String
    let sourceSnapshotID: String
    let ambitionID: String
    let generatedAt: String
    let localProjectionOnly: Bool
    let privacyClassRaw: String
    let sourceObjectIDs: RuntimeLegacySwiftDataEncodedColumn
    let receiptIDs: RuntimeLegacySwiftDataEncodedColumn
    let replayTraceIDs: RuntimeLegacySwiftDataEncodedColumn
    let sourceFields: RuntimeLegacySwiftDataEncodedColumn
    let projectionHash: String
    let checksum: String
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataGraphProofPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let proofID: String
    let version: Int
    let supersedesProofID: String?
    let sourceSnapshotID: String?
    let ambitionID: String
    let generatedAt: String
    let localProjectionOnly: Bool
    let privacyClassRaw: String
    let sourceObjectIDs: RuntimeLegacySwiftDataEncodedColumn
    let receiptIDs: RuntimeLegacySwiftDataEncodedColumn
    let replayTraceIDs: RuntimeLegacySwiftDataEncodedColumn
    let sourceFields: RuntimeLegacySwiftDataEncodedColumn
    let checksum: String
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

struct RuntimeLegacySwiftDataGraphProjectionPayload: Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let surfaceRaw: String
    let sourceSnapshotID: String
    let ambitionID: String
    let generatedAt: String
    let localProjectionOnly: Bool
    let privacyClassRaw: String
    let sourceObjectIDs: RuntimeLegacySwiftDataEncodedColumn
    let receiptIDs: RuntimeLegacySwiftDataEncodedColumn
    let replayTraceIDs: RuntimeLegacySwiftDataEncodedColumn
    let sourceFields: RuntimeLegacySwiftDataEncodedColumn
    let projectionHash: String
    let checksum: String
    let invalidationReasonRaw: String
    let snapshot: RuntimeLegacySwiftDataEncodedColumn
}

enum RuntimeLegacySwiftDataSourcePayload: Codable, Sendable, Equatable, Hashable {
    case goal(RuntimeLegacySwiftDataGoalPayload)
    case goalDraft(RuntimeLegacySwiftDataGoalDraftPayload)
    case goalPlan(RuntimeLegacySwiftDataGoalPlanPayload)
    case planSection(RuntimeLegacySwiftDataPlanSectionPayload)
    case step(RuntimeLegacySwiftDataStepPayload)
    case progressEvidence(RuntimeLegacySwiftDataProgressEvidencePayload)
    case feedbackEvent(RuntimeLegacySwiftDataFeedbackEventPayload)
    case capture(RuntimeLegacySwiftDataCapturePayload)
    case reminder(RuntimeLegacySwiftDataReminderPayload)
    case teachingSignal(RuntimeLegacySwiftDataTeachingSignalPayload)
    case eventLedger(RuntimeLegacySwiftDataEventLedgerPayload)
    case commandExecution(RuntimeLegacySwiftDataCommandExecutionPayload)
    case sideEffectLedger(RuntimeLegacySwiftDataSideEffectLedgerPayload)
    case entityRevisionTombstone(RuntimeLegacySwiftDataEntityRevisionTombstonePayload)
    case appState(RuntimeLegacySwiftDataAppStatePayload)
    case actionReceipt(RuntimeLegacySwiftDataActionReceiptPayload)
    case runtimeSnapshot(RuntimeLegacySwiftDataRuntimeSnapshotPayload)
    case lifeContext(RuntimeLegacySwiftDataLifeContextPayload)
    case graphOperational(RuntimeLegacySwiftDataGraphOperationalPayload)
    case graphProof(RuntimeLegacySwiftDataGraphProofPayload)
    case graphProjection(RuntimeLegacySwiftDataGraphProjectionPayload)

    var modelType: RuntimeLegacySwiftDataSourceModelType {
        switch self {
        case .goal: .goal
        case .goalDraft: .goalDraft
        case .goalPlan: .goalPlan
        case .planSection: .planSection
        case .step: .step
        case .progressEvidence: .progressEvidence
        case .feedbackEvent: .feedbackEvent
        case .capture: .capture
        case .reminder: .reminder
        case .teachingSignal: .teachingSignal
        case .eventLedger: .eventLedger
        case .commandExecution: .commandExecution
        case .sideEffectLedger: .sideEffectLedger
        case .entityRevisionTombstone: .entityRevisionTombstone
        case .appState: .appState
        case .actionReceipt: .actionReceipt
        case .runtimeSnapshot: .runtimeSnapshot
        case .lifeContext: .lifeContext
        case .graphOperational: .graphOperational
        case .graphProof: .graphProof
        case .graphProjection: .graphProjection
        }
    }

    var stableRecordID: String {
        switch self {
        case let .goal(value): value.id
        case let .goalDraft(value): value.id
        case let .goalPlan(value): value.id
        case let .planSection(value): value.id
        case let .step(value): value.id
        case let .progressEvidence(value): value.id
        case let .feedbackEvent(value): value.id
        case let .capture(value): value.id
        case let .reminder(value): value.id
        case let .teachingSignal(value): value.id
        case let .eventLedger(value): value.id
        case let .commandExecution(value): value.id
        case let .sideEffectLedger(value): value.id
        case let .entityRevisionTombstone(value): value.id
        case let .appState(value): value.id
        case let .actionReceipt(value): value.id
        case let .runtimeSnapshot(value): value.id
        case let .lifeContext(value): value.id
        case let .graphOperational(value): value.id
        case let .graphProof(value): value.id
        case let .graphProjection(value): value.id
        }
    }

    /// Model-owned ordering dimensions. The stable source ID is always the
    /// final tie-breaker; numeric dimensions use fixed-width decimal encoding.
    var orderingComponents: [String] {
        switch self {
        case let .goal(value):
            [value.updatedAt, Self.orderingNumber(value.revision), value.id]
        case let .goalDraft(value):
            [value.updatedAt, value.id]
        case let .goalPlan(value):
            [value.goalID, Self.orderingNumber(value.version), value.id]
        case let .planSection(value):
            [value.goalID, value.planID, Self.orderingNumber(value.orderIndex), value.id]
        case let .step(value):
            [
                value.goalID, value.planID, value.sectionID,
                Self.orderingNumber(value.orderIndex), value.id
            ]
        case let .progressEvidence(value):
            [
                value.capturedAt, value.goalID,
                value.stepID == nil ? "0" : "1", value.stepID ?? "", value.id
            ]
        case let .feedbackEvent(value):
            [value.occurredAt, value.goalID, value.stepID, value.id]
        case let .capture(value):
            [value.createdAt, value.id]
        case let .reminder(value):
            [
                value.triggerAt == nil ? "0" : "1", value.triggerAt ?? "",
                value.createdAt, value.id
            ]
        case let .teachingSignal(value):
            [value.createdAt, value.id]
        case let .eventLedger(value):
            [value.occurredAt, value.id]
        case let .commandExecution(value):
            [value.recordedAt, value.id]
        case let .sideEffectLedger(value):
            [value.occurredAt, value.id]
        case let .entityRevisionTombstone(value):
            [
                value.recordedAt, value.entityKindRaw, value.entityID,
                value.revisionMarker, value.id
            ]
        case let .appState(value):
            [value.id]
        case let .actionReceipt(value):
            [value.occurredAt, value.createdAt, value.id]
        case let .runtimeSnapshot(value):
            [value.generatedAt, value.id]
        case let .lifeContext(value):
            [value.updatedAt, value.id]
        case let .graphOperational(value):
            [value.generatedAt, value.ambitionID, value.id]
        case let .graphProof(value):
            [
                value.ambitionID, Self.orderingNumber(value.version),
                value.proofID, value.id
            ]
        case let .graphProjection(value):
            [value.generatedAt, value.ambitionID, value.id]
        }
    }

    private static func orderingNumber(_ value: Int) -> String {
        String(format: "%020lld", Int64(value))
    }

    var encodedColumns: [RuntimeLegacySwiftDataEncodedColumn] {
        switch self {
        case let .goal(value):
            [value.childGoalIDs, value.supportGoalIDs, value.tags, value.planningStrategy,
             value.progressStrategy, value.snapshot]
        case let .goalDraft(value):
            [value.snapshot]
        case let .goalPlan(value):
            [value.strategy, value.assumptions, value.lint, value.snapshot]
        case .planSection:
            []
        case let .step(value):
            [value.dependencyStepIDs, value.successSignals, value.actionability, value.snapshot]
        case let .progressEvidence(value):
            [value.snapshot]
        case let .feedbackEvent(value):
            [value.payload]
        case let .capture(value):
            [value.snapshot]
        case let .reminder(value):
            [value.deliveryPolicy, value.source] + [value.attachment].compactMap { $0 } + [value.snapshot]
        case let .teachingSignal(value):
            [value.snapshot]
        case let .eventLedger(value):
            [value.evidenceReferences, value.metadata, value.payload, value.trust, value.snapshot]
        case let .commandExecution(value):
            [value.command, value.result]
        case let .sideEffectLedger(value):
            [value.targetObjects, value.reasons, value.blockedFacts, value.degradedFacts, value.snapshot]
        case let .entityRevisionTombstone(value):
            [value.ancestryLineageIDs, value.snapshot]
        case let .appState(value):
            [value.snapshot]
        case let .actionReceipt(value):
            [value.receipt, value.proofFreshnessLineage] + [value.runtimeLineage].compactMap { $0 }
        case let .runtimeSnapshot(value):
            [value.sourceRecordIDs, value.receiptIDs, value.replayTraceIDs,
             value.recommendationInputReferenceIDs, value.proofInputReferenceIDs,
             value.afep02LineageReferenceIDs, value.fieldRedactions, value.snapshot]
        case let .lifeContext(value):
            [value.snapshot]
        case let .graphOperational(value):
            [value.sourceObjectIDs, value.receiptIDs, value.replayTraceIDs, value.sourceFields,
             value.snapshot]
        case let .graphProof(value):
            [value.sourceObjectIDs, value.receiptIDs, value.replayTraceIDs, value.sourceFields,
             value.snapshot]
        case let .graphProjection(value):
            [value.sourceObjectIDs, value.receiptIDs, value.replayTraceIDs, value.sourceFields,
             value.snapshot]
        }
    }

    func validate() throws {
        try RuntimeLegacySwiftDataEnvelopeValidation.requireNonempty(
            stableRecordID,
            field: "payload_stable_record_id"
        )
        let expected = Self.encodedColumnSpecifications[modelType] ?? []
        let expectedNames = Set(expected.map(\.columnName))
        let actualNames = encodedColumns.map(\.columnName)
        guard Set(actualNames).count == actualNames.count,
              Set(actualNames).isSubset(of: expectedNames) else {
            throw RuntimeGenerationControlError.malformed(field: "swiftdata_encoded_column_set")
        }
        for specification in expected where specification.isOptional == false {
            guard actualNames.contains(specification.columnName) else {
                throw RuntimeGenerationControlError.malformed(
                    field: "missing_swiftdata_encoded_column_\(specification.columnName)"
                )
            }
        }
        for column in encodedColumns {
            try column.validate()
            guard let specification = expected.first(where: { $0.columnName == column.columnName }),
                  specification.encodedTypeName == column.encodedTypeName,
                  specification.encoding == column.encoding else {
                throw RuntimeGenerationControlError.malformed(
                    field: "swiftdata_encoded_column_binding_\(column.columnName)"
                )
            }
            try Self.validateDecodedColumn(column)
        }
        try validateScalarAndSnapshotParity()
    }

    /// SwiftData duplicates queryable scalars beside encoded domain snapshots.
    /// Discovery accepts a row only when every duplicated value agrees exactly;
    /// otherwise review would be choosing between two unproven authorities.
    private func validateScalarAndSnapshotParity() throws {
        func reject() throws -> Never {
            throw RuntimeGenerationControlError.malformed(
                field: "swiftdata_scalar_snapshot_parity_\(modelType.rawValue)"
            )
        }
        func require(_ condition: @autoclosure () -> Bool) throws {
            guard condition() else { try reject() }
        }
        func requireDate(_ text: String, _ stored: Date?) throws {
            let parsed = PersistedTemporalValue.date(from: text)
            try require(parsed != nil && parsed == stored)
        }
        func requireNonnegative(_ values: Int?...) throws {
            try require(values.allSatisfy { $0.map { $0 >= 0 } ?? true })
        }

        switch self {
        case let .goal(value):
            let snapshot: Goal = try Self.decode(value.snapshot)
            let children: [String] = try Self.decode(value.childGoalIDs)
            let support: [String] = try Self.decode(value.supportGoalIDs)
            let tags: [String] = try Self.decode(value.tags)
            let planning: PlanningStrategy = try Self.decode(value.planningStrategy)
            let progress: ProgressStrategy = try Self.decode(value.progressStrategy)
            try requireNonnegative(value.revision, value.repeatEveryDays, value.progressReviewCadenceDays)
            try require(
                value.id == snapshot.id &&
                value.schemaVersion == snapshot.schemaVersion &&
                value.revision == snapshot.revision &&
                value.createdAt == snapshot.createdAt &&
                value.updatedAt == snapshot.updatedAt &&
                value.stateRaw == snapshot.state.rawValue &&
                value.title == snapshot.title &&
                value.summaryText == snapshot.summary &&
                value.modeRaw == snapshot.mode.rawValue &&
                value.relationshipKindRaw == snapshot.relationshipKind.rawValue &&
                value.actorDisplayName == snapshot.actor.displayName &&
                value.actorOwnershipRaw == snapshot.actor.ownership.rawValue &&
                value.parentGoalID == snapshot.parentGoalID &&
                children == snapshot.childGoalIDs &&
                support == snapshot.supportGoalIDs &&
                tags == snapshot.tags &&
                value.tempoRaw == snapshot.timing.tempo.rawValue &&
                value.timingTypeRaw == snapshot.timing.timingType.rawValue &&
                value.startsOn == snapshot.timing.startsOn &&
                value.dueAt == snapshot.timing.dueAt &&
                value.targetBy == snapshot.timing.targetBy &&
                value.windowStart == snapshot.timing.windowStart &&
                value.windowEnd == snapshot.timing.windowEnd &&
                value.suggestedNextAt == snapshot.timing.suggestedNextAt &&
                value.repeatEveryDays == snapshot.timing.repeatEveryDays &&
                value.progressReviewCadenceDays == snapshot.timing.progressReviewCadenceDays &&
                planning == snapshot.planningStrategy &&
                progress == snapshot.progressStrategy
            )

        case let .goalDraft(value):
            let snapshot: PersistedGoalDraft = try Self.decode(value.snapshot)
            try require(
                value.id == snapshot.id &&
                value.createdAt == snapshot.createdAt &&
                value.updatedAt == snapshot.updatedAt &&
                value.title == snapshot.draft.title &&
                value.modeRaw == snapshot.draft.mode.rawValue &&
                value.resultKindRaw == snapshot.latestResultKind?.rawValue &&
                value.readinessRaw == snapshot.clarification?.readiness.rawValue &&
                value.plannedGoalID == snapshot.plannedGoalID
            )

        case let .goalPlan(value):
            let snapshot: GoalPlan = try Self.decode(value.snapshot)
            let strategy: PlanningStrategy = try Self.decode(value.strategy)
            let assumptions: [PlanAssumption] = try Self.decode(value.assumptions)
            let lint: PlanLintResult = try Self.decode(value.lint)
            try requireNonnegative(value.version)
            try require(
                value.id == snapshot.id && value.goalID == snapshot.goalID &&
                value.version == snapshot.version && value.generatedAt == snapshot.generatedAt &&
                value.summaryText == snapshot.summary && strategy == snapshot.strategy &&
                assumptions == snapshot.assumptions && lint == snapshot.lint
            )

        case let .planSection(value):
            try requireNonnegative(value.orderIndex)
            try require(
                value.goalID.isEmpty == false && value.planID.isEmpty == false &&
                PlanSectionKind(rawValue: value.kindRaw) != nil
            )

        case let .step(value):
            let snapshot: Step = try Self.decode(value.snapshot)
            let dependencies: [String] = try Self.decode(value.dependencyStepIDs)
            let signals: [String] = try Self.decode(value.successSignals)
            let actionability: StepActionability = try Self.decode(value.actionability)
            try requireNonnegative(value.orderIndex, value.repeatEveryDays, value.progressReviewCadenceDays)
            try require(
                value.goalID.isEmpty == false && value.planID.isEmpty == false &&
                value.id == snapshot.id && value.sectionID == snapshot.sectionID &&
                value.title == snapshot.title && value.summaryText == snapshot.summary &&
                value.typeRaw == snapshot.type.rawValue && value.stateRaw == snapshot.state.rawValue &&
                value.ownerDisplayName == snapshot.owner.displayName &&
                value.ownerOwnershipRaw == snapshot.owner.ownership.rawValue &&
                value.tempoRaw == snapshot.timing.tempo.rawValue &&
                value.timingTypeRaw == snapshot.timing.timingType.rawValue &&
                value.startsOn == snapshot.timing.startsOn && value.dueAt == snapshot.timing.dueAt &&
                value.targetBy == snapshot.timing.targetBy &&
                value.windowStart == snapshot.timing.windowStart && value.windowEnd == snapshot.timing.windowEnd &&
                value.suggestedNextAt == snapshot.timing.suggestedNextAt &&
                value.repeatEveryDays == snapshot.timing.repeatEveryDays &&
                value.progressReviewCadenceDays == snapshot.timing.progressReviewCadenceDays &&
                dependencies == snapshot.dependencyStepIDs && signals == snapshot.successSignals &&
                actionability == snapshot.actionability && value.isOptional == snapshot.isOptional &&
                value.isRepeatable == snapshot.isRepeatable && value.evidenceRequired == snapshot.evidenceRequired
            )

        case let .progressEvidence(value):
            let snapshot: ProgressEvidence = try Self.decode(value.snapshot)
            try requireNonnegative(value.minutesInvested)
            try require(value.progressDelta?.isFinite ?? true)
            try require(value.confidenceDelta?.isFinite ?? true)
            try require(
                value.id == snapshot.id && value.goalID == snapshot.goalID && value.stepID == snapshot.stepID &&
                value.capturedAt == snapshot.capturedAt && value.evidenceKindRaw == snapshot.evidenceKind.rawValue &&
                value.sourceRaw == snapshot.source.rawValue && value.progressDelta == snapshot.progressDelta &&
                value.confidenceDelta == snapshot.confidenceDelta && value.minutesInvested == snapshot.minutesInvested &&
                value.note == snapshot.note
            )

        case let .feedbackEvent(value):
            let snapshot: StoredGoalFeedbackEvent = try Self.decode(value.payload)
            try require(
                value.id == snapshot.base.id && value.goalID.isEmpty == false &&
                value.stepID == snapshot.base.stepID && value.occurredAt == snapshot.base.occurredAt &&
                value.kindRaw == snapshot.kind.rawValue && value.note == snapshot.base.note
            )

        case let .capture(value):
            let snapshot: Capture = try Self.decode(value.snapshot)
            try require(
                value.id == snapshot.id && value.createdAt == snapshot.createdAt &&
                value.updatedAt == snapshot.updatedAt && value.rawText == snapshot.rawText &&
                value.sourceTypeRaw == snapshot.sourceType?.rawValue &&
                value.statusRaw == snapshot.status.rawValue && value.linkedGoalID == snapshot.linkedGoalID
            )

        case let .reminder(value):
            let snapshot: ReminderTrigger = try Self.decode(value.snapshot)
            let delivery: ReminderDeliveryPolicy = try Self.decode(value.deliveryPolicy)
            let source: ReminderSource = try Self.decode(value.source)
            let attachment: ReminderAttachment? = try value.attachment.map { try Self.decode($0) }
            try require(
                value.id == snapshot.id && value.schemaVersion == snapshot.schemaVersion &&
                value.createdAt == snapshot.createdAt && value.updatedAt == snapshot.updatedAt &&
                value.deletedAt == snapshot.deletedAt && value.title == snapshot.title &&
                value.summaryText == snapshot.summary && value.triggerAt == snapshot.triggerAt &&
                value.kindRaw == snapshot.kind.rawValue && value.stateRaw == snapshot.state.rawValue &&
                value.receiptID == snapshot.receiptID && value.replayTraceID == snapshot.replayTraceID &&
                value.sourceRecordID == snapshot.source.sourceRecordID &&
                value.attachedObjectID == snapshot.attachment?.attachedObjectID &&
                delivery == snapshot.deliveryPolicy && source == snapshot.source && attachment == snapshot.attachment
            )

        case let .teachingSignal(value):
            let snapshot: GoalTeachingSignal = try Self.decode(value.snapshot)
            try require(
                value.id == snapshot.id && value.goalID == snapshot.goalID &&
                value.kindRaw == snapshot.kind.rawValue && value.sourceRaw == snapshot.source.rawValue &&
                value.dispositionRaw == snapshot.disposition.rawValue &&
                value.applicationKey == snapshot.applicationKey && value.createdAt == snapshot.createdAt &&
                value.updatedAt == snapshot.updatedAt
            )

        case let .eventLedger(value):
            let snapshot: EventLedgerEntry = try Self.decode(value.snapshot)
            let evidence: [EventLedgerEvidenceReference] = try Self.decode(value.evidenceReferences)
            let metadata: [String: String] = try Self.decode(value.metadata)
            let payload: [String: String] = try Self.decode(value.payload)
            let trust: EventLedgerTrustMetadata = try Self.decode(value.trust)
            try requireDate(value.occurredAt, value.occurredAtDate)
            try requireDate(value.createdAt, value.createdAtDate)
            try requireDate(value.updatedAt, value.updatedAtDate)
            try require(
                value.id == snapshot.id && value.kindRaw == snapshot.kind.rawValue &&
                value.occurredAt == snapshot.occurredAt && value.sourceRaw == snapshot.source.rawValue &&
                value.goalID == snapshot.goalID && value.captureID == snapshot.captureID &&
                value.planID == snapshot.planID && value.planScope == snapshot.planScope &&
                value.reviewID == snapshot.reviewID && value.title == snapshot.title &&
                value.summaryText == snapshot.summary && value.semanticState == snapshot.semanticState &&
                value.toneRaw == snapshot.tone.rawValue && value.schemaVersion == snapshot.schemaVersion &&
                value.privacyRaw == snapshot.privacy.rawValue && value.localOnly == snapshot.localOnly &&
                value.createdAt == snapshot.createdAt && value.updatedAt == snapshot.updatedAt &&
                evidence == snapshot.evidenceReferences && metadata == snapshot.metadata &&
                payload == snapshot.payload && trust == snapshot.trust
            )

        case let .commandExecution(value):
            let command: AmbitionsCommand
            switch RuntimeCommandCodec().decode(value.command.bytes) {
            case let .supported(decoded, _): command = decoded
            case .unsupported, .corrupt: try reject()
            }
            let result: AmbitionsCommandExecutionResult = try Self.decode(value.result)
            try requireDate(value.recordedAt, value.recordedAtDate)
            try require(
                value.commandID == command.id && value.commandKindRaw == command.operation.rawValue &&
                value.commandSourceRaw == command.source.rawValue && value.actorRaw == command.actor.rawValue &&
                value.executionStatusRaw == command.executionStatus.rawValue &&
                value.resultStatusRaw == result.status.rawValue && value.localOnly == command.localOnly &&
                value.privacyRaw == command.privacy.rawValue && value.schemaVersion.isEmpty == false
            )

        case let .sideEffectLedger(value):
            let snapshot: SideEffectLedgerRecord = try Self.decode(value.snapshot)
            let targets: [LifeGraphObjectReference] = try Self.decode(value.targetObjects)
            let reasons: [SafeAutomationPolicyReason] = try Self.decode(value.reasons)
            let blocked: [String] = try Self.decode(value.blockedFacts)
            let degraded: [String] = try Self.decode(value.degradedFacts)
            try requireDate(value.occurredAt, value.occurredAtDate)
            try require(
                value.id == snapshot.id && value.effectKindRaw == snapshot.effectKind.rawValue &&
                value.statusRaw == snapshot.status.rawValue && value.boundaryRaw == snapshot.boundary.rawValue &&
                value.actionKindRaw == snapshot.actionKind.rawValue && value.sourceDomainRaw == snapshot.sourceDomain.rawValue &&
                value.commandID == snapshot.commandID && targets == snapshot.targetObjects &&
                value.requiresConfirmation == snapshot.requiresConfirmation && value.externalEffect == snapshot.externalEffect &&
                reasons == snapshot.reasons && blocked == snapshot.blockedFacts && degraded == snapshot.degradedFacts &&
                value.receiptID == snapshot.receiptID && value.schemaVersion == snapshot.schemaVersion &&
                value.localOnly == snapshot.localOnly && value.occurredAt == snapshot.occurredAt
            )

        case let .entityRevisionTombstone(value):
            let snapshot: EntityRevisionTombstone = try Self.decode(value.snapshot)
            let ancestry: [String] = try Self.decode(value.ancestryLineageIDs)
            try requireDate(value.recordedAt, value.recordedAtDate)
            try require(
                value.id == snapshot.id && value.entityKindRaw == snapshot.entityKind.rawValue &&
                value.entityID == snapshot.entityID && value.revisionMarker == snapshot.revisionMarker &&
                value.reasonRaw == snapshot.reason.rawValue && value.recordedAt == snapshot.recordedAt &&
                value.localOnly == snapshot.localOnly && value.lineageID == snapshot.lineageID &&
                ancestry == snapshot.ancestryLineageIDs && value.lifecycleStateRaw == snapshot.lifecycleState.rawValue &&
                value.privacyClassRaw == snapshot.privacyClass.rawValue && value.sourceRecordID == snapshot.sourceRecordID &&
                value.receiptID == snapshot.receiptID && value.replayTraceID == snapshot.replayTraceID &&
                value.schemaVersion == snapshot.schemaVersion
            )

        case let .appState(value):
            let snapshot: AppStateSnapshot = try Self.decode(value.snapshot)
            try require(
                value.id == snapshot.id && value.preferredTabRaw == snapshot.preferredTab.rawValue &&
                value.userDisplayName == snapshot.userDisplayName &&
                value.appearancePreferenceRaw == snapshot.appearancePreference.rawValue &&
                value.accentFamilyRaw == snapshot.accentFamily.rawValue &&
                value.hasCompletedBootstrap == snapshot.hasCompletedBootstrap &&
                value.lastBootstrapSourceRaw == snapshot.lastBootstrapSource?.rawValue &&
                value.lastBootstrapAt == snapshot.lastBootstrapAt && value.lastSeedVersion == snapshot.lastSeedVersion &&
                value.lastSeededAt == snapshot.lastSeededAt && value.lastOpenedGoalID == snapshot.lastOpenedGoalID
            )

        case let .actionReceipt(value):
            let receipt: ActionReceipt = try Self.decode(value.receipt)
            let proof: ActionReceiptProofFreshnessLineage = try Self.decode(value.proofFreshnessLineage)
            _ = try value.runtimeLineage.map { (column: RuntimeLegacySwiftDataEncodedColumn) -> RuntimeTrustLineage in
                try Self.decode(column)
            }
            try requireDate(value.createdAt, value.createdAtDate)
            try requireDate(value.occurredAt, value.occurredAtDate)
            try require(
                value.id == receipt.id && value.schemaVersion == receipt.schemaVersion &&
                value.sourceDomainRaw == receipt.sourceDomain.rawValue &&
                value.resultStateRaw == receipt.resultState.rawValue &&
                value.undoAvailabilityRaw == receipt.undoAvailability.rawValue &&
                value.createdAt == receipt.createdAt && value.occurredAt == receipt.occurredAt &&
                proof.receiptID == receipt.id &&
                ActionReceiptPrivacyLevel(rawValue: value.privacyLevelRaw) != nil &&
                ActionReceiptProofRelevance(rawValue: value.proofRelevanceRaw) != nil
            )

        case let .runtimeSnapshot(value):
            let snapshot: RuntimeSnapshotLedgerEnvelope = try Self.decode(value.snapshot)
            let source: [String] = try Self.decode(value.sourceRecordIDs)
            let receipts: [String] = try Self.decode(value.receiptIDs)
            let replay: [String] = try Self.decode(value.replayTraceIDs)
            let recommendations: [String] = try Self.decode(value.recommendationInputReferenceIDs)
            let proof: [String] = try Self.decode(value.proofInputReferenceIDs)
            let afep: [String] = try Self.decode(value.afep02LineageReferenceIDs)
            let redactions: [RuntimeSnapshotLedgerFieldRedaction] = try Self.decode(value.fieldRedactions)
            try require(
                value.id == snapshot.id && value.schemaVersion == snapshot.schemaVersion &&
                value.generatedAt == snapshot.generatedAt && source == snapshot.sourceRecordIDs &&
                receipts == snapshot.receiptIDs && replay == snapshot.replayTraceIDs &&
                recommendations == snapshot.recommendationInputReferenceIDs &&
                proof == snapshot.proofInputReferenceIDs && afep == snapshot.afep02LineageReferenceIDs &&
                redactions == snapshot.fieldRedactions &&
                value.compatibilityStatusRaw == snapshot.compatibilityStatus.rawValue &&
                value.checksum == snapshot.checksum && value.provenanceHash == snapshot.provenanceHash
            )

        case let .lifeContext(value):
            let snapshot: LifeContextBundle = try Self.decode(value.snapshot)
            try require(
                value.id == snapshot.id && value.schemaVersion.isEmpty == false &&
                value.createdAt == snapshot.createdAt && value.updatedAt == snapshot.updatedAt &&
                value.deletedAt == snapshot.deletedAt
            )

        case let .graphOperational(value):
            let snapshot: AmbitionGraphOperationalRecord = try Self.decode(value.snapshot)
            let sources: [String] = try Self.decode(value.sourceObjectIDs)
            let receipts: [String] = try Self.decode(value.receiptIDs)
            let replay: [String] = try Self.decode(value.replayTraceIDs)
            let fields: [String] = try Self.decode(value.sourceFields)
            try require(
                value.id == snapshot.id && value.schemaVersion == snapshot.schemaVersion &&
                value.surfaceRaw == snapshot.surface.rawValue && value.sourceSnapshotID == snapshot.sourceSnapshotID &&
                value.ambitionID == snapshot.ambitionID && value.generatedAt == snapshot.generatedAt &&
                value.localProjectionOnly == snapshot.localProjectionOnly &&
                value.privacyClassRaw == snapshot.privacyClass.rawValue && sources == snapshot.sourceObjectIDs &&
                receipts == snapshot.receiptIDs && replay == snapshot.replayTraceIDs && fields == snapshot.sourceFields &&
                value.projectionHash == snapshot.projectionHash && value.checksum == snapshot.checksum
            )

        case let .graphProof(value):
            let snapshot: AmbitionGraphProofRecord = try Self.decode(value.snapshot)
            let sources: [String] = try Self.decode(value.sourceObjectIDs)
            let receipts: [String] = try Self.decode(value.receiptIDs)
            let replay: [String] = try Self.decode(value.replayTraceIDs)
            let fields: [String] = try Self.decode(value.sourceFields)
            try requireNonnegative(value.version)
            try require(
                value.id == snapshot.id && value.schemaVersion == snapshot.schemaVersion &&
                value.proofID == snapshot.proofID && value.version == snapshot.version &&
                value.supersedesProofID == snapshot.supersedesProofID &&
                value.sourceSnapshotID == snapshot.sourceSnapshotID && value.ambitionID == snapshot.ambitionID &&
                value.generatedAt == snapshot.generatedAt && value.localProjectionOnly == snapshot.localProjectionOnly &&
                value.privacyClassRaw == snapshot.privacyClass.rawValue && sources == snapshot.sourceObjectIDs &&
                receipts == snapshot.receiptIDs && replay == snapshot.replayTraceIDs && fields == snapshot.sourceFields &&
                value.checksum == snapshot.checksum
            )

        case let .graphProjection(value):
            let snapshot: AmbitionGraphProjectionRecord = try Self.decode(value.snapshot)
            let sources: [String] = try Self.decode(value.sourceObjectIDs)
            let receipts: [String] = try Self.decode(value.receiptIDs)
            let replay: [String] = try Self.decode(value.replayTraceIDs)
            let fields: [String] = try Self.decode(value.sourceFields)
            try require(
                value.id == snapshot.id && value.schemaVersion == snapshot.schemaVersion &&
                value.surfaceRaw == snapshot.surface.rawValue && value.sourceSnapshotID == snapshot.sourceSnapshotID &&
                value.ambitionID == snapshot.ambitionID && value.generatedAt == snapshot.generatedAt &&
                value.localProjectionOnly == snapshot.localProjectionOnly &&
                value.privacyClassRaw == snapshot.privacyClass.rawValue && sources == snapshot.sourceObjectIDs &&
                receipts == snapshot.receiptIDs && replay == snapshot.replayTraceIDs && fields == snapshot.sourceFields &&
                value.projectionHash == snapshot.projectionHash && value.checksum == snapshot.checksum &&
                value.invalidationReasonRaw == snapshot.invalidationReason.rawValue
            )
        }
    }

    private static func decode<Value: Decodable>(
        _ column: RuntimeLegacySwiftDataEncodedColumn
    ) throws -> Value {
        do {
            return try JSONDecoder().decode(Value.self, from: column.bytes)
        } catch {
            throw RuntimeGenerationControlError.malformed(
                field: "swiftdata_encoded_column_decode_\(column.columnName)"
            )
        }
    }

    /// Relationship evidence is derived from the already validated payload;
    /// callers cannot omit, add, or relabel edges independently of source data.
    func derivedRelationshipClaims() throws -> [RuntimeLegacySwiftDataRelationshipClaim] {
        var claims: [RuntimeLegacySwiftDataRelationshipClaim]
        switch self {
        case let .goal(value):
            claims = try Self.optionalClaim(
                "parentGoalID", .parent, model: .goal, id: value.parentGoalID
            )
            claims += try Self.stringClaims(
                value.childGoalIDs, kind: .child, model: .goal
            )
            claims += try Self.stringClaims(
                value.supportGoalIDs, kind: .reference, model: .goal
            )
        case let .goalDraft(value):
            claims = try Self.optionalClaim(
                "plannedGoalID", .reference, model: .goal, id: value.plannedGoalID
            )
        case let .goalPlan(value):
            claims = [try Self.claim("goalID", .parent, model: .goal, id: value.goalID, required: true)]
        case let .planSection(value):
            claims = [
                try Self.claim("goalID", .parent, model: .goal, id: value.goalID, required: true),
                try Self.claim(
                    "planID", .parent, model: .goalPlan, id: value.planID,
                    required: true, order: value.orderIndex
                )
            ]
        case let .step(value):
            claims = [
                try Self.claim("goalID", .parent, model: .goal, id: value.goalID, required: true),
                try Self.claim("planID", .parent, model: .goalPlan, id: value.planID, required: true),
                try Self.claim(
                    "sectionID", .orderedChild, model: .planSection, id: value.sectionID,
                    required: true, order: value.orderIndex
                )
            ]
            claims += try Self.stringClaims(value.dependencyStepIDs, kind: .dependency, model: .step)
        case let .progressEvidence(value):
            claims = [try Self.claim("goalID", .parent, model: .goal, id: value.goalID, required: true)]
            claims += try Self.optionalClaim("stepID", .reference, model: .step, id: value.stepID)
        case let .feedbackEvent(value):
            claims = [
                try Self.claim("goalID", .parent, model: .goal, id: value.goalID, required: true),
                try Self.claim("stepID", .reference, model: .step, id: value.stepID, required: true)
            ]
        case let .capture(value):
            claims = try Self.optionalClaim("linkedGoalID", .reference, model: .goal, id: value.linkedGoalID)
        case let .reminder(value):
            claims = try Self.optionalClaim("receiptID", .receipt, model: .actionReceipt, id: value.receiptID)
            claims += try Self.optionalClaim("replayTraceID", .replayTrace, type: "RuntimeReplayTrace", id: value.replayTraceID)
            claims += try Self.optionalClaim("sourceRecordID", .source, type: "SourceRecord", id: value.sourceRecordID)
            claims += try Self.optionalClaim("attachedObjectID", .attachedObject, type: "CanonicalObject", id: value.attachedObjectID)
        case let .teachingSignal(value):
            claims = [try Self.claim("goalID", .parent, model: .goal, id: value.goalID, required: true)]
        case let .eventLedger(value):
            claims = try Self.optionalClaim("goalID", .reference, model: .goal, id: value.goalID)
            claims += try Self.optionalClaim("captureID", .reference, model: .capture, id: value.captureID)
            claims += try Self.optionalClaim("planID", .reference, model: .goalPlan, id: value.planID)
            claims += try Self.optionalClaim("reviewID", .reference, type: "Review", id: value.reviewID)
            let evidence: [EventLedgerEvidenceReference] = try Self.decode(value.evidenceReferences)
            claims += try evidence.enumerated().map { index, reference in
                let target: (RuntimeLegacySwiftDataSourceModelType?, String)
                switch reference.kind {
                case .goal: target = (.goal, RuntimeLegacySwiftDataSourceModelType.goal.rawValue)
                case .capture: target = (.capture, RuntimeLegacySwiftDataSourceModelType.capture.rawValue)
                case .plan: target = (.goalPlan, RuntimeLegacySwiftDataSourceModelType.goalPlan.rawValue)
                case .feedbackEvent: target = (.feedbackEvent, RuntimeLegacySwiftDataSourceModelType.feedbackEvent.rawValue)
                case .progressEvidence: target = (.progressEvidence, RuntimeLegacySwiftDataSourceModelType.progressEvidence.rawValue)
                case .teachingSignal: target = (.teachingSignal, RuntimeLegacySwiftDataSourceModelType.teachingSignal.rawValue)
                case .review: target = (nil, "Review")
                case .recommendation: target = (nil, "Recommendation")
                case .calendarContext: target = (nil, "CalendarContext")
                case .accessibilityAudit: target = (nil, "AccessibilityAudit")
                case .syncConflict: target = (nil, "SyncConflict")
                case .externalCommand: target = (nil, "AmbitionsCommand")
                }
                return try Self.claim(
                    "evidenceReferencesData", .reference, model: target.0,
                    type: target.1, id: reference.id, required: false, order: index
                )
            }
        case let .commandExecution(value):
            claims = [try Self.claim(
                "commandID", .reference, type: "AmbitionsCommand",
                id: value.commandID, required: true
            )]
        case let .sideEffectLedger(value):
            claims = try Self.optionalClaim("commandID", .reference, type: "AmbitionsCommand", id: value.commandID)
            claims += try Self.optionalClaim("receiptID", .receipt, model: .actionReceipt, id: value.receiptID)
            let targets: [LifeGraphObjectReference] = try Self.decode(value.targetObjects)
            claims += try targets.enumerated().map { index, reference in
                try Self.claim(
                    "targetObjectsData", .reference,
                    type: "LifeGraphObject.\(reference.kind.rawValue)",
                    id: reference.id, required: false, order: index
                )
            }
        case let .entityRevisionTombstone(value):
            claims = [
                try Self.claim(
                    "entityID", .reference, type: "CanonicalEntity.\(value.entityKindRaw)",
                    id: value.entityID, required: true
                ),
                try Self.claim("lineageID", .source, type: "EntityLineage", id: value.lineageID, required: true)
            ]
            claims += try Self.stringClaims(value.ancestryLineageIDs, kind: .source, type: "EntityLineage")
            claims += try Self.optionalClaim("sourceRecordID", .source, type: "SourceRecord", id: value.sourceRecordID)
            claims += try Self.optionalClaim("receiptID", .receipt, model: .actionReceipt, id: value.receiptID)
            claims += try Self.optionalClaim("replayTraceID", .replayTrace, type: "RuntimeReplayTrace", id: value.replayTraceID)
        case let .appState(value):
            claims = try Self.optionalClaim("lastOpenedGoalID", .reference, model: .goal, id: value.lastOpenedGoalID)
        case let .actionReceipt(value):
            let proof: ActionReceiptProofFreshnessLineage = try Self.decode(value.proofFreshnessLineage)
            claims = [try Self.claim(
                "proofFreshnessLineageData", .receipt, type: "ActionReceipt",
                id: proof.receiptID, required: true
            )]
            if let sourceObjectID = proof.sourceObjectID {
                claims.append(try Self.claim(
                    "proofFreshnessLineageData", .source,
                    type: proof.sourceObjectKind.map { "LifeGraphObject.\($0.rawValue)" } ?? "CanonicalObject",
                    id: sourceObjectID, required: false
                ))
            }
            claims += try proof.lineageObjectIDs.enumerated().map { index, id in
                try Self.claim(
                    "proofFreshnessLineageData", .source, type: "LineageObject",
                    id: id, required: false, order: index
                )
            }
            claims += try proof.proofReferenceIDs.enumerated().map { index, id in
                try Self.claim(
                    "proofFreshnessLineageData", .reference, type: "ProofReference",
                    id: id, required: false, order: index
                )
            }
            if let runtimeColumn = value.runtimeLineage {
                let runtime: RuntimeTrustLineage = try Self.decode(runtimeColumn)
                let direct: [(RuntimeLegacySwiftDataRelationshipKind, String, String)] = [
                    (.receipt, "RuntimeCommitReceipt", runtime.runtimeCommitReceiptID),
                    (.reference, "RuntimeTransaction", runtime.runtimeTransactionID),
                    (.reference, "RuntimeEvent", runtime.runtimeEventID),
                    (.receipt, "RuntimeReceipt", runtime.runtimeReceiptID),
                    (.reference, "RuntimeProofArtifact", runtime.runtimeProofArtifactID),
                    (.reference, "RuntimeRollbackPlan", runtime.runtimeRollbackPlanID),
                    (.replayTrace, "RuntimeReplayTrace", runtime.runtimeReplayTraceID),
                    (.reference, "AmbitionsCommand", runtime.runtimeCommandID)
                ]
                claims += try direct.map { kind, type, id in
                    try Self.claim("runtimeLineageData", kind, type: type, id: id, required: true)
                }
                claims += try runtime.affectedObjectIDs.enumerated().map { index, id in
                    try Self.claim(
                        "runtimeLineageData", .reference, type: "CanonicalObject",
                        id: id, required: false, order: index
                    )
                }
            }
        case let .runtimeSnapshot(value):
            claims = try Self.stringClaims(value.sourceRecordIDs, kind: .source, type: "SourceRecord")
            claims += try Self.stringClaims(value.receiptIDs, kind: .receipt, model: .actionReceipt)
            claims += try Self.stringClaims(value.replayTraceIDs, kind: .replayTrace, type: "RuntimeReplayTrace")
            claims += try Self.stringClaims(value.recommendationInputReferenceIDs, kind: .reference, type: "RecommendationInput")
            claims += try Self.stringClaims(value.proofInputReferenceIDs, kind: .reference, type: "ProofInput")
            claims += try Self.stringClaims(value.afep02LineageReferenceIDs, kind: .source, type: "AFEP02Lineage")
        case .lifeContext:
            claims = []
        case let .graphOperational(value):
            claims = try Self.graphClaims(
                sourceSnapshotID: value.sourceSnapshotID, ambitionID: value.ambitionID,
                sourceObjects: value.sourceObjectIDs, receipts: value.receiptIDs,
                replay: value.replayTraceIDs
            )
        case let .graphProof(value):
            claims = try Self.graphClaims(
                sourceSnapshotID: value.sourceSnapshotID, ambitionID: value.ambitionID,
                sourceObjects: value.sourceObjectIDs, receipts: value.receiptIDs,
                replay: value.replayTraceIDs
            )
            claims += try Self.optionalClaim(
                "supersedesProofID", .supersedes, model: .graphProof,
                id: value.supersedesProofID
            )
        case let .graphProjection(value):
            claims = try Self.graphClaims(
                sourceSnapshotID: value.sourceSnapshotID, ambitionID: value.ambitionID,
                sourceObjects: value.sourceObjectIDs, receipts: value.receiptIDs,
                replay: value.replayTraceIDs
            )
        }
        return RuntimeLegacySwiftDataEnvelopeValidation.sortedClaims(claims)
    }

    private static func claim(
        _ column: String,
        _ kind: RuntimeLegacySwiftDataRelationshipKind,
        model: RuntimeLegacySwiftDataSourceModelType? = nil,
        type: String? = nil,
        id: String,
        required: Bool,
        order: Int? = nil
    ) throws -> RuntimeLegacySwiftDataRelationshipClaim {
        try .make(
            sourceColumnName: column,
            kind: kind,
            targetModelType: model,
            targetTypeName: type ?? model?.rawValue ?? "",
            targetStableID: id,
            isRequired: required,
            orderIndex: order
        )
    }

    private static func optionalClaim(
        _ column: String,
        _ kind: RuntimeLegacySwiftDataRelationshipKind,
        model: RuntimeLegacySwiftDataSourceModelType? = nil,
        type: String? = nil,
        id: String?
    ) throws -> [RuntimeLegacySwiftDataRelationshipClaim] {
        guard let id else { return [] }
        return [try claim(column, kind, model: model, type: type, id: id, required: false)]
    }

    private static func stringClaims(
        _ column: RuntimeLegacySwiftDataEncodedColumn,
        kind: RuntimeLegacySwiftDataRelationshipKind,
        model: RuntimeLegacySwiftDataSourceModelType? = nil,
        type: String? = nil
    ) throws -> [RuntimeLegacySwiftDataRelationshipClaim] {
        let ids: [String] = try decode(column)
        return try ids.enumerated().map { index, id in
            try claim(
                column.columnName, kind, model: model, type: type,
                id: id, required: false, order: index
            )
        }
    }

    private static func graphClaims(
        sourceSnapshotID: String?,
        ambitionID: String,
        sourceObjects: RuntimeLegacySwiftDataEncodedColumn,
        receipts: RuntimeLegacySwiftDataEncodedColumn,
        replay: RuntimeLegacySwiftDataEncodedColumn
    ) throws -> [RuntimeLegacySwiftDataRelationshipClaim] {
        var claims = try optionalClaim(
            "sourceSnapshotID", .source, model: .runtimeSnapshot, id: sourceSnapshotID
        )
        claims.append(try claim(
            "ambitionID", .reference, model: .goal, id: ambitionID, required: true
        ))
        claims += try stringClaims(sourceObjects, kind: .source, type: "CanonicalObject")
        claims += try stringClaims(receipts, kind: .receipt, model: .actionReceipt)
        claims += try stringClaims(replay, kind: .replayTrace, type: "RuntimeReplayTrace")
        return claims
    }

    private static func validateDecodedColumn(
        _ column: RuntimeLegacySwiftDataEncodedColumn
    ) throws {
        do {
            if column.encoding == .runtimeCommandCodec {
                guard column.encodedTypeName == "AmbitionsCommand" else {
                    throw RuntimeGenerationControlError.malformed(
                        field: "swiftdata_runtime_command_type"
                    )
                }
                switch RuntimeCommandCodec().decode(column.bytes) {
                case .supported:
                    return
                case .unsupported, .corrupt:
                    throw RuntimeGenerationControlError.malformed(
                        field: "swiftdata_runtime_command_payload"
                    )
                }
            }

            let decoder = JSONDecoder()
            switch column.encodedTypeName {
            case "[String]":
                _ = try decoder.decode([String].self, from: column.bytes)
            case "PlanningStrategy":
                _ = try decoder.decode(PlanningStrategy.self, from: column.bytes)
            case "ProgressStrategy":
                _ = try decoder.decode(ProgressStrategy.self, from: column.bytes)
            case "Goal":
                _ = try decoder.decode(Goal.self, from: column.bytes)
            case "PersistedGoalDraft":
                _ = try decoder.decode(PersistedGoalDraft.self, from: column.bytes)
            case "[PlanAssumption]":
                _ = try decoder.decode([PlanAssumption].self, from: column.bytes)
            case "PlanLintResult":
                _ = try decoder.decode(PlanLintResult.self, from: column.bytes)
            case "GoalPlan":
                _ = try decoder.decode(GoalPlan.self, from: column.bytes)
            case "StepActionability":
                _ = try decoder.decode(StepActionability.self, from: column.bytes)
            case "Step":
                _ = try decoder.decode(Step.self, from: column.bytes)
            case "ProgressEvidence":
                _ = try decoder.decode(ProgressEvidence.self, from: column.bytes)
            case "StoredGoalFeedbackEvent":
                _ = try decoder.decode(StoredGoalFeedbackEvent.self, from: column.bytes)
            case "Capture":
                _ = try decoder.decode(Capture.self, from: column.bytes)
            case "ReminderDeliveryPolicy":
                _ = try decoder.decode(ReminderDeliveryPolicy.self, from: column.bytes)
            case "ReminderSource":
                _ = try decoder.decode(ReminderSource.self, from: column.bytes)
            case "ReminderAttachment":
                _ = try decoder.decode(ReminderAttachment.self, from: column.bytes)
            case "ReminderTrigger":
                _ = try decoder.decode(ReminderTrigger.self, from: column.bytes)
            case "GoalTeachingSignal":
                _ = try decoder.decode(GoalTeachingSignal.self, from: column.bytes)
            case "[EventLedgerEvidenceReference]":
                _ = try decoder.decode([EventLedgerEvidenceReference].self, from: column.bytes)
            case "[String: String]":
                _ = try decoder.decode([String: String].self, from: column.bytes)
            case "EventLedgerTrustMetadata":
                _ = try decoder.decode(EventLedgerTrustMetadata.self, from: column.bytes)
            case "EventLedgerEntry":
                _ = try decoder.decode(EventLedgerEntry.self, from: column.bytes)
            case "AmbitionsCommandExecutionResult":
                _ = try decoder.decode(AmbitionsCommandExecutionResult.self, from: column.bytes)
            case "[LifeGraphObjectReference]":
                _ = try decoder.decode([LifeGraphObjectReference].self, from: column.bytes)
            case "[SafeAutomationPolicyReason]":
                _ = try decoder.decode([SafeAutomationPolicyReason].self, from: column.bytes)
            case "SideEffectLedgerRecord":
                _ = try decoder.decode(SideEffectLedgerRecord.self, from: column.bytes)
            case "EntityRevisionTombstone":
                _ = try decoder.decode(EntityRevisionTombstone.self, from: column.bytes)
            case "AppStateSnapshot":
                _ = try decoder.decode(AppStateSnapshot.self, from: column.bytes)
            case "ActionReceipt":
                _ = try decoder.decode(ActionReceipt.self, from: column.bytes)
            case "ActionReceiptProofFreshnessLineage":
                _ = try decoder.decode(ActionReceiptProofFreshnessLineage.self, from: column.bytes)
            case "RuntimeTrustLineage":
                _ = try decoder.decode(RuntimeTrustLineage.self, from: column.bytes)
            case "[RuntimeSnapshotLedgerFieldRedaction]":
                _ = try decoder.decode([RuntimeSnapshotLedgerFieldRedaction].self, from: column.bytes)
            case "RuntimeSnapshotLedgerEnvelope":
                _ = try decoder.decode(RuntimeSnapshotLedgerEnvelope.self, from: column.bytes)
            case "LifeContextBundle":
                _ = try decoder.decode(LifeContextBundle.self, from: column.bytes)
            case "AmbitionGraphOperationalRecord":
                _ = try decoder.decode(AmbitionGraphOperationalRecord.self, from: column.bytes)
            case "AmbitionGraphProofRecord":
                _ = try decoder.decode(AmbitionGraphProofRecord.self, from: column.bytes)
            case "AmbitionGraphProjectionRecord":
                _ = try decoder.decode(AmbitionGraphProjectionRecord.self, from: column.bytes)
            default:
                throw RuntimeGenerationControlError.malformed(
                    field: "unsupported_swiftdata_encoded_type"
                )
            }
        } catch let error as RuntimeGenerationControlError {
            throw error
        } catch {
            throw RuntimeGenerationControlError.malformed(
                field: "swiftdata_encoded_column_decode_\(column.columnName)"
            )
        }
    }

    private static let encodedColumnSpecifications: [RuntimeLegacySwiftDataSourceModelType: [
        RuntimeLegacySwiftDataEncodedColumnSpecification
    ]] = [
        .goal: [
            .init("childGoalIDsData", "[String]"),
            .init("supportGoalIDsData", "[String]"),
            .init("tagsData", "[String]"),
            .init("planningStrategyData", "PlanningStrategy"),
            .init("progressStrategyData", "ProgressStrategy"),
            .init("snapshotData", "Goal")
        ],
        .goalDraft: [.init("snapshotData", "PersistedGoalDraft")],
        .goalPlan: [
            .init("strategyData", "PlanningStrategy"),
            .init("assumptionsData", "[PlanAssumption]"),
            .init("lintData", "PlanLintResult"),
            .init("snapshotData", "GoalPlan")
        ],
        .planSection: [],
        .step: [
            .init("dependencyStepIDsData", "[String]"),
            .init("successSignalsData", "[String]"),
            .init("actionabilityData", "StepActionability"),
            .init("snapshotData", "Step")
        ],
        .progressEvidence: [.init("snapshotData", "ProgressEvidence")],
        .feedbackEvent: [.init("payloadData", "StoredGoalFeedbackEvent")],
        .capture: [.init("snapshotData", "Capture")],
        .reminder: [
            .init("deliveryPolicyData", "ReminderDeliveryPolicy"),
            .init("sourceData", "ReminderSource"),
            .init("attachmentData", "ReminderAttachment", isOptional: true),
            .init("snapshotData", "ReminderTrigger")
        ],
        .teachingSignal: [.init("snapshotData", "GoalTeachingSignal")],
        .eventLedger: [
            .init("evidenceReferencesData", "[EventLedgerEvidenceReference]"),
            .init("metadataData", "[String: String]"),
            .init("payloadData", "[String: String]"),
            .init("trustData", "EventLedgerTrustMetadata"),
            .init("snapshotData", "EventLedgerEntry")
        ],
        .commandExecution: [
            .init("commandData", "AmbitionsCommand", encoding: .runtimeCommandCodec),
            .init("resultData", "AmbitionsCommandExecutionResult")
        ],
        .sideEffectLedger: [
            .init("targetObjectsData", "[LifeGraphObjectReference]"),
            .init("reasonsData", "[SafeAutomationPolicyReason]"),
            .init("blockedFactsData", "[String]"),
            .init("degradedFactsData", "[String]"),
            .init("snapshotData", "SideEffectLedgerRecord")
        ],
        .entityRevisionTombstone: [
            .init("ancestryLineageIDsData", "[String]"),
            .init("snapshotData", "EntityRevisionTombstone")
        ],
        .appState: [.init("snapshotData", "AppStateSnapshot")],
        .actionReceipt: [
            .init("receiptData", "ActionReceipt"),
            .init("proofFreshnessLineageData", "ActionReceiptProofFreshnessLineage"),
            .init("runtimeLineageData", "RuntimeTrustLineage", isOptional: true)
        ],
        .runtimeSnapshot: [
            .init("sourceRecordIDsData", "[String]"),
            .init("receiptIDsData", "[String]"),
            .init("replayTraceIDsData", "[String]"),
            .init("recommendationInputReferenceIDsData", "[String]"),
            .init("proofInputReferenceIDsData", "[String]"),
            .init("afep02LineageReferenceIDsData", "[String]"),
            .init("fieldRedactionsData", "[RuntimeSnapshotLedgerFieldRedaction]"),
            .init("snapshotData", "RuntimeSnapshotLedgerEnvelope")
        ],
        .lifeContext: [.init("snapshotData", "LifeContextBundle")],
        .graphOperational: [
            .init("sourceObjectIDsData", "[String]"),
            .init("receiptIDsData", "[String]"),
            .init("replayTraceIDsData", "[String]"),
            .init("sourceFieldsData", "[String]"),
            .init("snapshotData", "AmbitionGraphOperationalRecord")
        ],
        .graphProof: [
            .init("sourceObjectIDsData", "[String]"),
            .init("receiptIDsData", "[String]"),
            .init("replayTraceIDsData", "[String]"),
            .init("sourceFieldsData", "[String]"),
            .init("snapshotData", "AmbitionGraphProofRecord")
        ],
        .graphProjection: [
            .init("sourceObjectIDsData", "[String]"),
            .init("receiptIDsData", "[String]"),
            .init("replayTraceIDsData", "[String]"),
            .init("sourceFieldsData", "[String]"),
            .init("snapshotData", "AmbitionGraphProjectionRecord")
        ]
    ]
}

private struct RuntimeLegacySwiftDataEncodedColumnSpecification: Sendable, Equatable, Hashable {
    let columnName: String
    let encodedTypeName: String
    let encoding: RuntimeLegacySwiftDataEncodedColumnEncoding
    let isOptional: Bool

    init(
        _ columnName: String,
        _ encodedTypeName: String,
        encoding: RuntimeLegacySwiftDataEncodedColumnEncoding = .canonicalJSON,
        isOptional: Bool = false
    ) {
        self.columnName = columnName
        self.encodedTypeName = encodedTypeName
        self.encoding = encoding
        self.isOptional = isOptional
    }
}

// MARK: - Review-only envelope

struct RuntimeLegacySwiftDataSourceEnvelope: Codable, Sendable, Equatable, Hashable {
    let formatVersion: RuntimeLegacySwiftDataEnvelopeVersion
    /// Export-session binding used only to reject frame splicing. It is
    /// intentionally excluded from semantic record/import identity.
    let transportSessionDigest: String
    let sourceIdentity: RuntimeLegacySwiftDataSourceIdentity
    let sourceDisposition: RuntimeLegacySwiftDataSourceDisposition
    let requiresReview: Bool
    let materializationAuthorized: Bool
    let payload: RuntimeLegacySwiftDataSourcePayload
    let relationshipClaims: [RuntimeLegacySwiftDataRelationshipClaim]
    let payloadDigest: String
    let relationshipSetDigest: String
    let envelopeDigest: String

    static func make(
        sourceSchemaVersion: String,
        transportSessionDigest: String,
        payload: RuntimeLegacySwiftDataSourcePayload,
        relationshipClaims: [RuntimeLegacySwiftDataRelationshipClaim]
    ) throws -> Self {
        try payload.validate()
        let identity = try RuntimeLegacySwiftDataSourceIdentity.make(
            sourceSchemaVersion: sourceSchemaVersion,
            modelType: payload.modelType,
            orderingComponents: payload.orderingComponents,
            stableRecordID: payload.stableRecordID
        )
        let claims = RuntimeLegacySwiftDataEnvelopeValidation.sortedClaims(relationshipClaims)
        guard claims == (try payload.derivedRelationshipClaims()) else {
            throw RuntimeGenerationControlError.malformed(
                field: "swiftdata_relationship_claim_derivation"
            )
        }
        try RuntimeLegacySwiftDataEnvelopeValidation.validateClaims(
            claims,
            for: payload.modelType
        )
        let payloadDigest = try RuntimeGenerationControlCodec.digest(payload)
        let relationshipSetDigest = try RuntimeGenerationControlCodec.digest(claims)
        let material = RuntimeLegacySwiftDataSourceEnvelopeDigestMaterial(
            formatVersion: .v1,
            transportSessionDigest: transportSessionDigest,
            sourceIdentity: identity,
            sourceDisposition: payload.modelType.sourceDisposition,
            requiresReview: true,
            materializationAuthorized: false,
            payload: payload,
            relationshipClaims: claims,
            payloadDigest: payloadDigest,
            relationshipSetDigest: relationshipSetDigest
        )
        let value = Self(
            formatVersion: .v1,
            transportSessionDigest: transportSessionDigest,
            sourceIdentity: identity,
            sourceDisposition: payload.modelType.sourceDisposition,
            requiresReview: true,
            materializationAuthorized: false,
            payload: payload,
            relationshipClaims: claims,
            payloadDigest: payloadDigest,
            relationshipSetDigest: relationshipSetDigest,
            envelopeDigest: try RuntimeGenerationControlCodec.digest(material)
        )
        try value.validate()
        return value
    }

    func validate() throws {
        guard formatVersion == .v1,
              requiresReview,
              materializationAuthorized == false,
              sourceDisposition.isReviewableDiscovery,
              sourceDisposition.isMaterializable == false else {
            throw RuntimeGenerationControlError.malformed(field: "swiftdata_envelope_authority_boundary")
        }
        try RuntimeLegacySwiftDataEnvelopeValidation.requireDigest(
            transportSessionDigest,
            field: "transport_session_digest"
        )
        try payload.validate()
        try sourceIdentity.validate(orderingComponents: payload.orderingComponents)
        guard sourceIdentity.modelType == payload.modelType,
              sourceIdentity.stableRecordID == payload.stableRecordID,
              sourceDisposition == payload.modelType.sourceDisposition else {
            throw RuntimeGenerationControlError.malformed(field: "swiftdata_envelope_payload_binding")
        }
        let sortedClaims = RuntimeLegacySwiftDataEnvelopeValidation.sortedClaims(relationshipClaims)
        guard relationshipClaims == sortedClaims else {
            throw RuntimeGenerationControlError.malformed(field: "swiftdata_relationship_claim_order")
        }
        guard relationshipClaims == (try payload.derivedRelationshipClaims()) else {
            throw RuntimeGenerationControlError.malformed(
                field: "swiftdata_relationship_claim_derivation"
            )
        }
        try RuntimeLegacySwiftDataEnvelopeValidation.validateClaims(
            relationshipClaims,
            for: payload.modelType
        )
        try RuntimeLegacySwiftDataEnvelopeValidation.requireDigest(payloadDigest, field: "swiftdata_payload_digest")
        try RuntimeLegacySwiftDataEnvelopeValidation.requireDigest(
            relationshipSetDigest,
            field: "swiftdata_relationship_set_digest"
        )
        try RuntimeLegacySwiftDataEnvelopeValidation.requireDigest(envelopeDigest, field: "swiftdata_envelope_digest")
        guard payloadDigest == (try RuntimeGenerationControlCodec.digest(payload)),
              relationshipSetDigest == (try RuntimeGenerationControlCodec.digest(relationshipClaims)) else {
            throw RuntimeGenerationControlError.malformed(field: "swiftdata_envelope_content_digest")
        }
        let material = RuntimeLegacySwiftDataSourceEnvelopeDigestMaterial(
            formatVersion: formatVersion,
            transportSessionDigest: transportSessionDigest,
            sourceIdentity: sourceIdentity,
            sourceDisposition: sourceDisposition,
            requiresReview: requiresReview,
            materializationAuthorized: materializationAuthorized,
            payload: payload,
            relationshipClaims: relationshipClaims,
            payloadDigest: payloadDigest,
            relationshipSetDigest: relationshipSetDigest
        )
        guard envelopeDigest == (try RuntimeGenerationControlCodec.digest(material)) else {
            throw RuntimeGenerationControlError.malformed(field: "swiftdata_envelope_digest")
        }
    }
}

private struct RuntimeLegacySwiftDataSourceEnvelopeDigestMaterial: Encodable {
    let formatVersion: RuntimeLegacySwiftDataEnvelopeVersion
    let transportSessionDigest: String
    let sourceIdentity: RuntimeLegacySwiftDataSourceIdentity
    let sourceDisposition: RuntimeLegacySwiftDataSourceDisposition
    let requiresReview: Bool
    let materializationAuthorized: Bool
    let payload: RuntimeLegacySwiftDataSourcePayload
    let relationshipClaims: [RuntimeLegacySwiftDataRelationshipClaim]
    let payloadDigest: String
    let relationshipSetDigest: String
}

private enum RuntimeLegacySwiftDataEnvelopeValidation {
    static func requireNonempty(_ value: String, field: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false, trimmed == value else {
            throw RuntimeGenerationControlError.malformed(field: field)
        }
    }

    static func requireDigest(_ value: String, field: String) throws {
        guard value.count == 64,
              value.allSatisfy({ "0123456789abcdef".contains($0) }) else {
            throw RuntimeGenerationControlError.malformed(field: field)
        }
    }

    static func sortedClaims(
        _ claims: [RuntimeLegacySwiftDataRelationshipClaim]
    ) -> [RuntimeLegacySwiftDataRelationshipClaim] {
        claims.sorted {
            let left = [
                $0.sourceColumnName,
                $0.kind.rawValue,
                $0.targetModelType?.rawValue ?? "",
                $0.targetTypeName,
                $0.targetStableID,
                $0.orderIndex.map(String.init) ?? ""
            ]
            let right = [
                $1.sourceColumnName,
                $1.kind.rawValue,
                $1.targetModelType?.rawValue ?? "",
                $1.targetTypeName,
                $1.targetStableID,
                $1.orderIndex.map(String.init) ?? ""
            ]
            return left.lexicographicallyPrecedes(right)
        }
    }

    static func validateClaims(
        _ claims: [RuntimeLegacySwiftDataRelationshipClaim],
        for modelType: RuntimeLegacySwiftDataSourceModelType
    ) throws {
        let permittedColumns = relationshipSourceColumns[modelType] ?? []
        var digests = Set<String>()
        var identities = Set<RuntimeLegacySwiftDataRelationshipClaimIdentity>()
        for claim in claims {
            try claim.validate()
            let identity = RuntimeLegacySwiftDataRelationshipClaimIdentity(
                sourceColumnName: claim.sourceColumnName,
                kind: claim.kind,
                targetModelType: claim.targetModelType,
                targetTypeName: claim.targetTypeName,
                targetStableID: claim.targetStableID,
                orderIndex: claim.orderIndex
            )
            guard permittedColumns.contains(claim.sourceColumnName),
                  digests.insert(claim.claimDigest).inserted,
                  identities.insert(identity).inserted else {
                throw RuntimeGenerationControlError.malformed(field: "swiftdata_relationship_claim_set")
            }
            if let targetModelType = claim.targetModelType,
               claim.targetTypeName != targetModelType.rawValue {
                throw RuntimeGenerationControlError.malformed(field: "swiftdata_relationship_target_binding")
            }
        }
    }

    static func requireDiagnosticCode(_ value: String) throws {
        try requireNonempty(value, field: "rejected_diagnostic_code")
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789._-")
        guard value.count <= 128,
              value.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
            throw RuntimeGenerationControlError.malformed(field: "rejected_diagnostic_code")
        }
    }

    private static let relationshipSourceColumns: [RuntimeLegacySwiftDataSourceModelType: Set<String>] = [
        .goal: ["parentGoalID", "childGoalIDsData", "supportGoalIDsData"],
        .goalDraft: ["plannedGoalID"],
        .goalPlan: ["goalID"],
        .planSection: ["goalID", "planID"],
        .step: ["goalID", "planID", "sectionID", "dependencyStepIDsData"],
        .progressEvidence: ["goalID", "stepID"],
        .feedbackEvent: ["goalID", "stepID"],
        .capture: ["linkedGoalID"],
        .reminder: [
            "receiptID", "replayTraceID", "sourceRecordID", "attachedObjectID",
            "sourceData", "attachmentData"
        ],
        .teachingSignal: ["goalID"],
        .eventLedger: [
            "goalID", "captureID", "planID", "reviewID", "evidenceReferencesData"
        ],
        .commandExecution: ["commandID"],
        .sideEffectLedger: ["commandID", "targetObjectsData", "receiptID"],
        .entityRevisionTombstone: [
            "entityID", "lineageID", "ancestryLineageIDsData", "sourceRecordID",
            "receiptID", "replayTraceID"
        ],
        .appState: ["lastOpenedGoalID"],
        .actionReceipt: ["receiptData", "proofFreshnessLineageData", "runtimeLineageData"],
        .runtimeSnapshot: [
            "sourceRecordIDsData", "receiptIDsData", "replayTraceIDsData",
            "recommendationInputReferenceIDsData", "proofInputReferenceIDsData",
            "afep02LineageReferenceIDsData"
        ],
        .lifeContext: [],
        .graphOperational: [
            "sourceSnapshotID", "ambitionID", "sourceObjectIDsData", "receiptIDsData",
            "replayTraceIDsData"
        ],
        .graphProof: [
            "proofID", "supersedesProofID", "sourceSnapshotID", "ambitionID",
            "sourceObjectIDsData", "receiptIDsData", "replayTraceIDsData"
        ],
        .graphProjection: [
            "sourceSnapshotID", "ambitionID", "sourceObjectIDsData", "receiptIDsData",
            "replayTraceIDsData"
        ]
    ]
}

private struct RuntimeLegacySwiftDataRelationshipClaimIdentity: Hashable {
    let sourceColumnName: String
    let kind: RuntimeLegacySwiftDataRelationshipKind
    let targetModelType: RuntimeLegacySwiftDataSourceModelType?
    let targetTypeName: String
    let targetStableID: String
    let orderIndex: Int?
}
