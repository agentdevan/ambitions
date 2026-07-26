import AmbitionsRuntimeSQLite
import Foundation

struct RuntimeReceiptDecodedByteBudget: Sendable, Equatable {
    private(set) var remainingBytes: Int

    init(maximumBytes: Int) {
        remainingBytes = max(0, maximumBytes)
    }

    mutating func query(
        _ sql: String,
        bindings: [SQLiteBinding] = [],
        database: isolated SQLiteDatabase
    ) throws -> [SQLiteRow] {
        guard remainingBytes > 0 else {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        }
        let rows = try database.query(
            sql,
            bindings: bindings,
            maximumDecodedBytes: remainingBytes
        )
        let decodedBytes = rows.reduce(0) { total, row in
            total + row.values.reduce(0) { subtotal, value in
                let valueBytes: Int = switch value {
                case .null: 1
                case .integer, .real: 8
                case let .text(value): value.utf8.count
                case let .blob(value): value.count
                }
                return subtotal + valueBytes
            }
        }
        guard decodedBytes <= remainingBytes else {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        }
        remainingBytes -= decodedBytes
        return rows
    }

}

extension RuntimeReceiptDecodedByteBudget: RuntimeExternalOperationReadBudget {}

struct RuntimeAuthenticatedReceiptGraph: Sendable, Equatable {
    let core: RuntimeCommittedReceiptCore
    let eventEvidence: RuntimeVerifiedExactSemanticEventEvidence
    let history: [RuntimeObjectHistoryEntry]
    let tombstones: [RuntimeCanonicalTombstoneDraft]
    let plan: RuntimeCommittedCompensationPlan?
    let irreversibilityEvidence: RuntimeIrreversibilityEvidence?
    let externalOperations: [RuntimeAuthenticatedExternalOperationSummary]
    /// Internal authenticated state used only by same-transaction authority
    /// decisions. Receipt/query presentation exposes `externalOperations`.
    let externalOperationStates: [RuntimeExternalOperationID: RuntimeCanonicalExternalOperation]
    let externalOperationSchemaVersion: Int
    let projectionInvalidationIDs: [String]
    let compensationReceiptID: RuntimeReceiptID?
    let currentTargetStates: [RuntimeSemanticAggregate: RuntimeCanonicalAggregateState]
    let finalizedIdempotency: RuntimeFinalizedIdempotencyReference?
    let confirmation: RuntimeCommittedReceiptConfirmationReference?
}

struct RuntimeCompensationConsumptionDraft: Sendable, Equatable {
    let planID: RuntimeRollbackPlanID
    let sourceReceiptID: RuntimeReceiptID
    let compensationReceiptID: RuntimeReceiptID
    let compensationCommandID: RuntimeCommandID
    let terminalEventSequence: UInt64
    let consumedAtMilliseconds: Int64
}

enum RuntimeCommittedReceiptAuthorityError: Error, Sendable, Equatable {
    case corruptAuthority
    case sourceBlocked(RuntimeReceiptSourceBlockedReason)
}

enum RuntimeCommittedReceiptAuthorityPhase: Sendable, Equatable {
    case coreInserted
    case historyPersisted
    case dispositionPersisted
    case compensationConsumed
    case graphAuthenticated
}

enum RuntimeCommittedReceiptAuthority {
    private struct HistoryIdentityFacts: Codable {
        let receiptID: RuntimeReceiptID
        let aggregate: RuntimeSemanticAggregate
        let resultingRevision: UInt64
        let terminalEventSequence: UInt64
        let stateDigest: String
    }

    private struct TombstoneIdentityFacts: Codable {
        let historyID: String
        let authority: RuntimeCanonicalTombstoneAuthority
    }

    private struct ExternalOperationArtifactAuthority {
        let summaries: [RuntimeAuthenticatedExternalOperationSummary]
        let states: [RuntimeExternalOperationID: RuntimeCanonicalExternalOperation]
        let artifacts: [RuntimeCommittedReceiptArtifactLink]
        let retention: [RuntimeReceiptRetentionReference]
        let schemaVersion: Int
    }

    struct HistoryDraft {
        let historyID: String
        let link: RuntimeCommittedReceiptObjectLink
        let payload: RuntimeObjectHistoryEntry
        let tombstoneID: String?
        let tombstone: RuntimeCanonicalTombstoneDraft?
    }

    static func persist(
        atomicReceipt: RuntimeAtomicCommitReceipt,
        eventRecord: CanonicalRuntimeSemanticEventRecord,
        correlationID: RuntimeCorrelationID,
        dispositionIntent: RuntimeCompensationDispositionIntent,
        externalOperationCreations: [RuntimeCanonicalExternalOperationCreation],
        compensationConsumption: RuntimeCompensationConsumptionDraft?,
        createdAtMilliseconds: Int64,
        phase: ((RuntimeCommittedReceiptAuthorityPhase) throws -> Void)? = nil,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCommittedReceiptCore {
        guard atomicReceipt.lineage.eventID == eventRecord.lineage.eventID,
              atomicReceipt.lineage.eventSequence == eventRecord.lineage.sequence,
              atomicReceipt.lineage.eventHash == eventRecord.lineage.eventHash.hexadecimal,
              eventRecord.lineage.correlationID == correlationID,
              eventRecord.lineage.commandID == atomicReceipt.commandID,
              eventRecord.event.mutation.aggregateTransitions.count == atomicReceipt.aggregateStates.count,
              atomicReceipt.aggregateStates.isEmpty == false,
              atomicReceipt.aggregateStates.count <= RuntimeCommittedReceiptLimits.maximumObjects,
              externalOperationCreations.count <= RuntimeExternalOperationLimits.maximumOperationsPerReceipt,
              atomicReceipt.unresolvedWork.filter {
                $0.kind == .projectionInvalidation
              }.count <= RuntimeCommittedReceiptLimits.maximumProjectionInvalidations else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }

        let privacy = RuntimeCommittedReceiptPrivacy(
            classification: try requiredReceiptPrivacy(eventRecord.event.mutation),
            localOnly: try requiredLocalOnly(eventRecord.event.mutation)
        )
        let history = try makeHistoryDrafts(
            receipt: atomicReceipt,
            eventRecord: eventRecord,
            privacy: privacy
        )
        let externalOperationIDs = externalOperationCreations.map(\.operationID).sorted()
        let expectedExternalTargets = try atomicReceipt.aggregateStates.map {
            RuntimeExternalOperationTarget(
                family: $0.aggregate.kind,
                objectID: try RuntimeDomainObjectID(validating: $0.aggregate.id.rawValue)
            )
        }.sorted()
        guard externalOperationIDs == externalOperationCreations.map(\.operationID),
              Set(externalOperationIDs).count == externalOperationIDs.count,
              externalOperationCreations.allSatisfy({ creation in
                  creation.receiptID == atomicReceipt.receiptID &&
                      creation.commandID == atomicReceipt.commandID &&
                      creation.lineage == atomicReceipt.lineage &&
                      creation.targets == expectedExternalTargets &&
                      creation.privacy == privacy.classification &&
                      creation.localOnly &&
                      creation.localOnly == privacy.localOnly &&
                      creation.createdAt == atomicReceipt.committedAt &&
                      creation.stableIdempotencyKey == .derive(
                          operationID: creation.operationID,
                          commandID: creation.commandID,
                          kind: creation.kind
                      )
              }) else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let committedDisposition: RuntimeCommittedCompensationDisposition
        let committedPlan: RuntimeCommittedCompensationPlan?
        let evidence: RuntimeIrreversibilityEvidence?
        switch dispositionIntent {
        case let .typedPlan(intent):
            let isProvableCreatePlan = history.isEmpty == false &&
                history.count <= RuntimeCompensationLimits.maximumTargets &&
                externalOperationIDs.count <= RuntimeCompensationLimits.maximumExternalOperations &&
                history.allSatisfy { draft in
                draft.link.aggregate.kind == intent.action.aggregateKind &&
                    draft.link.priorRevision == nil &&
                    draft.link.transition == .create &&
                    draft.link.lifecycle == .active
            }
            if isProvableCreatePlan {
                let targets = history.map { draft in
                    RuntimeCompensationTargetExpectation(
                        aggregate: draft.link.aggregate,
                        sourcePriorRevision: draft.link.priorRevision,
                        sourceRevision: draft.link.terminalRevision,
                        sourceTransition: draft.link.transition,
                        requiredCurrentRevision: draft.link.terminalRevision,
                        requiredLifecycle: draft.link.lifecycle,
                        sourceStateDigest: draft.link.stateDigest,
                        inverseTransition: intent.action.transition
                    )
                }
                let plan = try RuntimeCommittedReceiptCodec.makePlan(
                    planID: intent.planID,
                    receiptID: atomicReceipt.receiptID,
                    lineage: atomicReceipt.lineage,
                    correlationID: correlationID,
                    action: intent.action,
                    targets: targets,
                    externalOperationIDs: externalOperationIDs,
                    privacy: privacy,
                    policyVersion: intent.policyVersion,
                    expiresAt: intent.expiresAt,
                    requiresConfirmation: intent.requiresConfirmation
                )
                committedPlan = plan
                evidence = nil
                committedDisposition = .plan(
                    planID: plan.planID, digest: plan.digest,
                    expiresAt: plan.expiresAt,
                    requiresConfirmation: plan.requiresConfirmation
                )
            } else {
                let value = RuntimeIrreversibilityEvidence(
                    version: 1,
                    permanence: .currentRuntimeUnsupported,
                    reason: .unsupportedSemanticInverse,
                    commandFamily: eventRecord.event.mutation.semanticType.aggregateKind.rawValue,
                    commandAction: eventRecord.event.mutation.semanticType.rawValue
                )
                let digest = try RuntimeCommittedReceiptCodec.evidenceDigest(
                    value,
                    sourceReceiptID: atomicReceipt.receiptID,
                    sourceLineage: atomicReceipt.lineage
                )
                committedPlan = nil
                evidence = value
                committedDisposition = .noncompensable(evidenceDigest: digest, evidence: value)
            }
        case let .noncompensable(value):
            let digest = try RuntimeCommittedReceiptCodec.evidenceDigest(
                value,
                sourceReceiptID: atomicReceipt.receiptID,
                sourceLineage: atomicReceipt.lineage
            )
            committedPlan = nil
            evidence = value
            committedDisposition = .noncompensable(evidenceDigest: digest, evidence: value)
        }

        var artifacts: [RuntimeCommittedReceiptArtifactLink] = [
            RuntimeCommittedReceiptArtifactLink(
                kind: .terminalEvent,
                stableID: eventRecord.lineage.eventID.rawValue,
                digest: eventRecord.lineage.eventHash.hexadecimal
            ),
        ]
        artifacts += try atomicReceipt.unresolvedWork
            .filter { $0.kind == .projectionInvalidation }
            .map {
                RuntimeCommittedReceiptArtifactLink(
                    kind: .projectionInvalidation,
                    stableID: $0.stableID,
                    digest: LocalRuntimeStorageChecksum.sha256Hex(
                        for: try RuntimeCommittedReceiptCodec.encode($0.lineage)
                    )
                )
            }
        for draft in history {
            if let tombstoneID = draft.tombstoneID, let tombstone = draft.tombstone {
                artifacts.append(RuntimeCommittedReceiptArtifactLink(
                    kind: .tombstoneHistory,
                    stableID: tombstoneID,
                    digest: LocalRuntimeStorageChecksum.sha256Hex(
                        for: try RuntimeCommittedReceiptCodec.encode(tombstone)
                    )
                ))
            }
        }
        artifacts += try externalOperationCreations.map {
            RuntimeCommittedReceiptArtifactLink(
                kind: .externalOperation,
                stableID: $0.operationID.rawValue,
                digest: try RuntimeExternalOperationCodec.creationDigest($0)
            )
        }
        if let plan = committedPlan {
            artifacts.append(RuntimeCommittedReceiptArtifactLink(
                kind: .compensationPlan, stableID: plan.planID.rawValue, digest: plan.digest
            ))
        }
        if let evidence {
            artifacts.append(RuntimeCommittedReceiptArtifactLink(
                kind: .irreversibilityEvidence,
                stableID: atomicReceipt.receiptID.rawValue,
                digest: try RuntimeCommittedReceiptCodec.evidenceDigest(
                    evidence,
                    sourceReceiptID: atomicReceipt.receiptID,
                    sourceLineage: atomicReceipt.lineage
                )
            ))
        }

        var retention = history.map {
            RuntimeReceiptRetentionReference(kind: .objectHistory, stableID: $0.historyID, retainUntil: nil)
        }
        retention += history.compactMap { draft in
            draft.tombstoneID.map {
                RuntimeReceiptRetentionReference(kind: .tombstoneHistory, stableID: $0, retainUntil: nil)
            }
        }
        retention += externalOperationIDs.map {
            RuntimeReceiptRetentionReference(kind: .externalOperation, stableID: $0.rawValue, retainUntil: nil)
        }
        if let plan = committedPlan {
            retention.append(RuntimeReceiptRetentionReference(
                kind: .compensationSource,
                stableID: plan.planID.rawValue,
                retainUntil: plan.expiresAt
            ))
        }

        var presentation = history.map {
            RuntimeCommittedReceiptPresentationFact.objectChanged(
                family: $0.link.aggregate.kind,
                lifecycle: $0.link.lifecycle
            )
        }
        presentation += externalOperationCreations.map { .externalWorkPending(kind: $0.kind) }
        presentation.append(committedPlan == nil ? .compensationUnavailable : .compensationPlanRecorded)

        let core = try RuntimeCommittedReceiptCodec.makeCore(RuntimeCommittedReceiptCoreFacts(
            version: runtimeCommittedReceiptCoreVersion,
            receiptID: atomicReceipt.receiptID,
            preparationID: atomicReceipt.preparationID,
            commandID: atomicReceipt.commandID,
            lineage: atomicReceipt.lineage,
            correlationID: correlationID,
            outcome: .changed,
            committedAt: atomicReceipt.committedAt,
            privacy: privacy,
            objects: history.map(\.link),
            artifacts: artifacts,
            presentationFacts: presentation,
            compensation: committedDisposition,
            retention: retention,
            confirmationToken: atomicReceipt.confirmationToken,
            confirmationDecisionDigest: atomicReceipt.confirmationDecisionDigest
        ))

        try insertCore(core, createdAtMilliseconds: createdAtMilliseconds, database: database)
        try phase?(.coreInserted)
        try insertHistory(
            history, receiptID: atomicReceipt.receiptID,
            terminalEventSequence: atomicReceipt.lineage.eventSequence,
            privacy: privacy, createdAtMilliseconds: createdAtMilliseconds,
            database: database
        )
        try phase?(.historyPersisted)
        if let plan = committedPlan {
            try insertPlan(plan, createdAtMilliseconds: createdAtMilliseconds, database: database)
        } else if let evidence {
            try insertEvidence(
                evidence, receiptID: atomicReceipt.receiptID,
                sourceLineage: atomicReceipt.lineage,
                createdAtMilliseconds: createdAtMilliseconds, database: database
            )
        }
        try insertDisposition(
            committedDisposition, receiptID: atomicReceipt.receiptID,
            createdAtMilliseconds: createdAtMilliseconds, database: database
        )
        try phase?(.dispositionPersisted)
        try insertArtifactLinks(core, database: database)
        try insertRetention(core, database: database)
        if let compensationConsumption {
            try insertCompensationConsumption(
                compensationConsumption,
                receipt: atomicReceipt,
                database: database
            )
            try phase?(.compensationConsumed)
        }
        try authenticatePersistedCore(
            core, expectedHistory: history,
            expectedPlan: committedPlan, expectedEvidence: evidence,
            requireFinalization: false,
            constructionCompensation: compensationConsumption,
            database: database
        )
        try phase?(.graphAuthenticated)
        return core
    }

    private static func requiredReceiptPrivacy(
        _ mutation: RuntimeSemanticMutation
    ) throws -> EventLedgerPrivacyClassification {
        guard let privacy = mutation.privacy,
              mutation.aggregateTransitions.allSatisfy({ $0.privacy == privacy }) else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        return privacy
    }

    private static func requiredLocalOnly(_ mutation: RuntimeSemanticMutation) throws -> Bool {
        guard mutation.localOnly == true,
              mutation.aggregateTransitions.allSatisfy({ $0.localOnly == true }) else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        return true
    }

    private static func makeHistoryDrafts(
        receipt: RuntimeAtomicCommitReceipt,
        eventRecord: CanonicalRuntimeSemanticEventRecord,
        privacy: RuntimeCommittedReceiptPrivacy
    ) throws -> [HistoryDraft] {
        try receipt.aggregateStates.map { state in
            guard let transition = eventRecord.event.mutation.aggregateTransitions.first(where: {
                $0.aggregate == state.aggregate
            }), transition.resultingRevision == state.revision,
                  transition.lifecycle == state.lifecycle,
                  transition.transition == state.transition,
                  transition.canonicalStateDigest == LocalRuntimeStorageChecksum.sha256Hex(
                    for: transition.canonicalStateBytes
                  ),
                  try RuntimeCanonicalAggregateStateCodec().decode(
                    transition.canonicalStateBytes
                  ) == state else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            let link = RuntimeCommittedReceiptObjectLink(
                aggregate: state.aggregate,
                priorRevision: transition.priorRevision,
                terminalRevision: state.revision,
                lifecycle: state.lifecycle,
                transition: state.transition,
                stateDigest: transition.canonicalStateDigest
            )
            let identityBytes = try RuntimeCommittedReceiptCodec.encode(HistoryIdentityFacts(
                receiptID: receipt.receiptID,
                aggregate: state.aggregate,
                resultingRevision: state.revision,
                terminalEventSequence: receipt.lineage.eventSequence,
                stateDigest: transition.canonicalStateDigest
            ))
            let historyID = LocalRuntimeStorageChecksum.sha256Hex(for: identityBytes)
            let payload = RuntimeObjectHistoryEntry(
                historyID: historyID,
                receiptID: receipt.receiptID,
                lineage: receipt.lineage,
                object: link,
                privacy: privacy
            )
            let tombstoneID: String?
            let tombstone: RuntimeCanonicalTombstoneDraft?
            if let authority = transition.tombstone {
                let draft = RuntimeCanonicalTombstoneDraft(
                    objectID: try RuntimeDomainObjectID(validating: state.aggregate.id.rawValue),
                    family: state.aggregate.kind.rawValue,
                    terminalRevision: state.revision,
                    lineage: receipt.lineage,
                    authority: authority
                )
                tombstone = draft
                tombstoneID = LocalRuntimeStorageChecksum.sha256Hex(
                    for: try RuntimeCommittedReceiptCodec.encode(TombstoneIdentityFacts(
                        historyID: historyID, authority: authority
                    ))
                )
            } else {
                tombstone = nil
                tombstoneID = nil
            }
            return HistoryDraft(
                historyID: historyID, link: link, payload: payload,
                tombstoneID: tombstoneID, tombstone: tombstone
            )
        }.sorted { $0.link < $1.link }
    }

    private static func insertCore(
        _ core: RuntimeCommittedReceiptCore,
        createdAtMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        let bytes = try RuntimeCommittedReceiptCodec.encode(core)
        try database.execute(
            """
            INSERT INTO runtime_committed_receipt_cores(
                receipt_id, command_id, terminal_event_sequence, terminal_event_id,
                terminal_event_hash, correlation_id, privacy, local_only,
                core_version, core_digest, confirmation_token,
                confirmation_decision_digest, payload, payload_checksum, created_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(core.facts.receiptID.rawValue), .text(core.facts.commandID.rawValue),
                .integer(try int64(core.facts.lineage.eventSequence)),
                .text(core.facts.lineage.eventID.rawValue), .text(core.facts.lineage.eventHash),
                .text(core.facts.correlationID.rawValue), .text(core.facts.privacy.classification.rawValue),
                .integer(Int64(core.facts.version)), .text(core.receiptDigest),
                core.facts.confirmationToken.map { .text($0.rawValue) } ?? .null,
                core.facts.confirmationDecisionDigest.map { .text($0.rawValue) } ?? .null,
                .blob(bytes),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)),
                .integer(createdAtMilliseconds),
            ]
        )
    }

    private static func insertHistory(
        _ drafts: [HistoryDraft],
        receiptID: RuntimeReceiptID,
        terminalEventSequence: UInt64,
        privacy: RuntimeCommittedReceiptPrivacy,
        createdAtMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        for draft in drafts {
            let bytes = try RuntimeCommittedReceiptCodec.encode(draft.payload)
            try database.execute(
                """
                INSERT INTO runtime_object_history(
                    history_id, receipt_id, family, object_id, prior_revision,
                    resulting_revision, lifecycle, transition_kind,
                    terminal_event_sequence, state_digest, privacy, local_only,
                    history_version, payload, payload_checksum, created_at_ms
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, 1, ?, ?, ?)
                """,
                bindings: [
                    .text(draft.historyID), .text(receiptID.rawValue),
                    .text(draft.link.aggregate.kind.rawValue), .text(draft.link.aggregate.id.rawValue),
                    draft.link.priorRevision.map { .integer(Int64($0)) } ?? .null,
                    .integer(try int64(draft.link.terminalRevision)),
                    .text(draft.link.lifecycle.rawValue), .text(draft.link.transition.rawValue),
                    .integer(try int64(terminalEventSequence)), .text(draft.link.stateDigest),
                    .text(privacy.classification.rawValue), .blob(bytes),
                    .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)),
                    .integer(createdAtMilliseconds),
                ]
            )
            try database.execute(
                """
                INSERT INTO runtime_receipt_object_links(
                    receipt_id, history_id, family, object_id, terminal_revision, link_version
                ) VALUES (?, ?, ?, ?, ?, 1)
                """,
                bindings: [
                    .text(receiptID.rawValue), .text(draft.historyID),
                    .text(draft.link.aggregate.kind.rawValue), .text(draft.link.aggregate.id.rawValue),
                    .integer(try int64(draft.link.terminalRevision)),
                ]
            )
            if let tombstoneID = draft.tombstoneID, let tombstone = draft.tombstone {
                let tombstoneBytes = try RuntimeCommittedReceiptCodec.encode(tombstone)
                try database.execute(
                    """
                    INSERT INTO runtime_object_tombstone_history(
                        tombstone_history_id, history_id, receipt_id, family, object_id,
                        terminal_revision, terminal_event_sequence, reason, predecessor_digest,
                        tombstone_version, payload, payload_checksum, created_at_ms
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)
                    """,
                    bindings: [
                        .text(tombstoneID), .text(draft.historyID), .text(receiptID.rawValue),
                        .text(draft.link.aggregate.kind.rawValue), .text(draft.link.aggregate.id.rawValue),
                        .integer(try int64(draft.link.terminalRevision)),
                        .integer(try int64(terminalEventSequence)),
                        .text(tombstone.authority.reason.rawValue),
                        .text(tombstone.authority.predecessorDigest), .blob(tombstoneBytes),
                        .text(LocalRuntimeStorageChecksum.sha256Hex(for: tombstoneBytes)),
                        .integer(createdAtMilliseconds),
                    ]
                )
            }
        }
    }

    private static func insertPlan(
        _ plan: RuntimeCommittedCompensationPlan,
        createdAtMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        try RuntimeCommittedReceiptCodec.validatePlan(plan)
        let bytes = try RuntimeCommittedReceiptCodec.encode(plan)
        try database.execute(
            """
            INSERT INTO runtime_compensation_plans(
                plan_id, source_receipt_id, source_event_sequence, source_event_hash,
                plan_version, policy_version, expires_at_ms, requires_confirmation,
                privacy, plan_digest, payload, payload_checksum, created_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(plan.planID.rawValue), .text(plan.sourceReceiptID.rawValue),
                .integer(try int64(plan.sourceLineage.eventSequence)), .text(plan.sourceLineage.eventHash),
                .integer(Int64(plan.version)), .integer(Int64(plan.policyVersion)),
                .integer(try milliseconds(plan.expiresAt)), .integer(plan.requiresConfirmation ? 1 : 0),
                .text(plan.privacy.classification.rawValue), .text(plan.digest), .blob(bytes),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)), .integer(createdAtMilliseconds),
            ]
        )
        for target in plan.targets {
            try database.execute(
                """
                INSERT INTO runtime_compensation_plan_targets(
                    plan_id, family, object_id, source_prior_revision, source_revision,
                    source_transition_kind, required_current_revision,
                    required_lifecycle, source_state_digest, transition_kind, target_version
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
                """,
                bindings: [
                    .text(plan.planID.rawValue), .text(target.aggregate.kind.rawValue),
                    .text(target.aggregate.id.rawValue),
                    try target.sourcePriorRevision.map { .integer(try int64($0)) } ?? .null,
                    .integer(try int64(target.sourceRevision)),
                    .text(target.sourceTransition.rawValue),
                    .integer(try int64(target.requiredCurrentRevision)),
                    .text(target.requiredLifecycle.rawValue), .text(target.sourceStateDigest),
                    .text(target.inverseTransition.rawValue),
                ]
            )
        }
        for operationID in plan.externalOperationIDs {
            try database.execute(
                """
                INSERT INTO runtime_compensation_plan_external_operations(
                    plan_id, operation_id, operation_version
                ) VALUES (?, ?, 1)
                """,
                bindings: [.text(plan.planID.rawValue), .text(operationID.rawValue)]
            )
        }
    }

    private static func insertEvidence(
        _ evidence: RuntimeIrreversibilityEvidence,
        receiptID: RuntimeReceiptID,
        sourceLineage: RuntimeAuthorityLineageReference,
        createdAtMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        let digest = try RuntimeCommittedReceiptCodec.evidenceDigest(
            evidence,
            sourceReceiptID: receiptID,
            sourceLineage: sourceLineage
        )
        let bytes = try RuntimeCommittedReceiptCodec.encode(evidence)
        try database.execute(
            """
            INSERT INTO runtime_irreversibility_evidence(
                source_receipt_id, evidence_version, permanence, reason,
                evidence_digest, payload, payload_checksum, created_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(receiptID.rawValue), .integer(Int64(evidence.version)),
                .text(evidence.permanence.rawValue), .text(evidence.reason.rawValue),
                .text(digest), .blob(bytes),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)),
                .integer(createdAtMilliseconds),
            ]
        )
    }

    private static func insertDisposition(
        _ disposition: RuntimeCommittedCompensationDisposition,
        receiptID: RuntimeReceiptID,
        createdAtMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        let bytes = try RuntimeCommittedReceiptCodec.encode(disposition)
        let kind: String
        let planID: SQLiteValue
        let evidenceDigest: SQLiteValue
        switch disposition {
        case let .plan(id, _, _, _):
            kind = "plan"; planID = .text(id.rawValue); evidenceDigest = .null
        case let .noncompensable(digest, _):
            kind = "noncompensable"; planID = .null; evidenceDigest = .text(digest)
        }
        try database.execute(
            """
            INSERT INTO runtime_receipt_compensation_dispositions(
                source_receipt_id, disposition_kind, plan_id, evidence_digest,
                disposition_version, payload, payload_checksum, created_at_ms
            ) VALUES (?, ?, ?, ?, 1, ?, ?, ?)
            """,
            bindings: [
                .text(receiptID.rawValue), .text(kind), planID, evidenceDigest,
                .blob(bytes), .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)),
                .integer(createdAtMilliseconds),
            ]
        )
    }

    private static func insertArtifactLinks(
        _ core: RuntimeCommittedReceiptCore,
        database: isolated SQLiteDatabase
    ) throws {
        for artifact in core.facts.artifacts {
            try database.execute(
                """
                INSERT INTO runtime_receipt_artifact_links(
                    receipt_id, artifact_kind, artifact_id, artifact_digest, link_version
                ) VALUES (?, ?, ?, ?, 1)
                """,
                bindings: [
                    .text(core.facts.receiptID.rawValue), .text(artifact.kind.rawValue),
                    .text(artifact.stableID), artifact.digest.map(SQLiteValue.text) ?? .null,
                ]
            )
        }
    }

    private static func insertRetention(
        _ core: RuntimeCommittedReceiptCore,
        database: isolated SQLiteDatabase
    ) throws {
        for reference in core.facts.retention {
            try database.execute(
                """
                INSERT INTO runtime_receipt_retention_references(
                    receipt_id, reference_kind, reference_id, retain_until_ms, reference_version
                ) VALUES (?, ?, ?, ?, 1)
                """,
                bindings: [
                    .text(core.facts.receiptID.rawValue), .text(reference.kind.rawValue),
                    .text(reference.stableID),
                    try reference.retainUntil.map { .integer(try milliseconds($0)) } ?? .null,
                ]
            )
        }
    }

    private static func insertCompensationConsumption(
        _ draft: RuntimeCompensationConsumptionDraft,
        receipt: RuntimeAtomicCommitReceipt,
        database: isolated SQLiteDatabase
    ) throws {
        guard draft.compensationReceiptID == receipt.receiptID,
              draft.compensationCommandID == receipt.commandID,
              draft.terminalEventSequence == receipt.lineage.eventSequence,
              draft.consumedAtMilliseconds == (try milliseconds(receipt.committedAt)),
              draft.sourceReceiptID != draft.compensationReceiptID else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let result = try database.execute(
            """
            INSERT INTO runtime_compensation_consumptions(
                plan_id, source_receipt_id, compensation_receipt_id,
                compensation_command_id, terminal_event_sequence,
                consumed_at_ms, consumption_version
            ) VALUES (?, ?, ?, ?, ?, ?, 1)
            """,
            bindings: [
                .text(draft.planID.rawValue), .text(draft.sourceReceiptID.rawValue),
                .text(draft.compensationReceiptID.rawValue),
                .text(draft.compensationCommandID.rawValue),
                .integer(try int64(draft.terminalEventSequence)),
                .integer(draft.consumedAtMilliseconds),
            ]
        )
        guard result.changedRowCount == 1 else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
    }

    static func authenticatePersistedCore(
        _ expected: RuntimeCommittedReceiptCore,
        expectedHistory: [HistoryDraft]? = nil,
        expectedPlan: RuntimeCommittedCompensationPlan? = nil,
        expectedEvidence: RuntimeIrreversibilityEvidence? = nil,
        requireFinalization: Bool = true,
        constructionCompensation: RuntimeCompensationConsumptionDraft? = nil,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAuthenticatedReceiptGraph {
        var budget = RuntimeReceiptDecodedByteBudget(
            maximumBytes: RuntimeCommittedReceiptReadBounds.authenticatedGraphBudgetBytes(
                baseBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
            )
        )
        return try authenticatePersistedCore(
            expected,
            expectedHistory: expectedHistory,
            expectedPlan: expectedPlan,
            expectedEvidence: expectedEvidence,
            requireFinalization: requireFinalization,
            constructionCompensation: constructionCompensation,
            budget: &budget,
            database: database
        )
    }

    static func authenticatePersistedCore(
        _ expected: RuntimeCommittedReceiptCore,
        expectedHistory: [HistoryDraft]? = nil,
        expectedPlan: RuntimeCommittedCompensationPlan? = nil,
        expectedEvidence: RuntimeIrreversibilityEvidence? = nil,
        requireFinalization: Bool = true,
        coreRowAuthenticated: Bool = false,
        constructionCompensation: RuntimeCompensationConsumptionDraft? = nil,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAuthenticatedReceiptGraph {
        var traversal = ReceiptAuthenticationTraversal(
            allowedUnfinalizedCompensation: constructionCompensation.map {
                CompensationConsumptionReference(
                    planID: $0.planID,
                    sourceReceiptID: $0.sourceReceiptID,
                    compensationReceiptID: $0.compensationReceiptID,
                    compensationCommandID: $0.compensationCommandID,
                    terminalEventSequence: $0.terminalEventSequence,
                    consumedAtMilliseconds: $0.consumedAtMilliseconds
                )
            }
        )
        return try authenticatePersistedCoreTraversing(
            expected,
            expectedHistory: expectedHistory,
            expectedPlan: expectedPlan,
            expectedEvidence: expectedEvidence,
            requireFinalization: requireFinalization,
            coreRowAuthenticated: coreRowAuthenticated,
            budget: &budget,
            traversal: &traversal,
            database: database
        )
    }

    private static func authenticatePersistedCoreTraversing(
        _ expected: RuntimeCommittedReceiptCore,
        expectedHistory: [HistoryDraft]? = nil,
        expectedPlan: RuntimeCommittedCompensationPlan? = nil,
        expectedEvidence: RuntimeIrreversibilityEvidence? = nil,
        requireFinalization: Bool = true,
        coreRowAuthenticated: Bool = false,
        budget: inout RuntimeReceiptDecodedByteBudget,
        traversal: inout ReceiptAuthenticationTraversal,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAuthenticatedReceiptGraph {
        if coreRowAuthenticated == false {
            let rows = try budget.query(
                """
                SELECT c.command_id, c.terminal_event_sequence, c.terminal_event_id,
                       c.terminal_event_hash, c.correlation_id, c.privacy, c.local_only,
                       c.core_version, c.core_digest, c.confirmation_token,
                       c.confirmation_decision_digest, c.payload, c.payload_checksum,
                       c.created_at_ms AS core_created_at_ms,
                       r.receipt_id AS anchor_receipt_id,
                       r.preparation_id AS anchor_preparation_id,
                       r.command_id AS anchor_command_id,
                       r.terminal_event_sequence AS anchor_event_sequence,
                       r.receipt_version AS anchor_version,
                       r.created_at_ms AS anchor_created_at_ms
                FROM runtime_committed_receipt_cores AS c
                JOIN runtime_commit_receipts AS r ON r.receipt_id = c.receipt_id
                WHERE c.receipt_id = ? LIMIT 2
                """,
                bindings: [.text(expected.facts.receiptID.rawValue)],
                database: database
            )
            guard rows.count == 1, let row = rows.first,
                  case let .blob(bytes)? = row.value(named: "payload"),
                  bytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
                  case let .text(checksum)? = row.value(named: "payload_checksum"),
                  try RuntimeCommittedReceiptCodec.decodeCore(bytes, storedChecksum: checksum) == expected,
                  row.value(named: "command_id") == .text(expected.facts.commandID.rawValue),
                  row.value(named: "terminal_event_sequence") == .integer(try int64(expected.facts.lineage.eventSequence)),
                  row.value(named: "terminal_event_id") == .text(expected.facts.lineage.eventID.rawValue),
                  row.value(named: "terminal_event_hash") == .text(expected.facts.lineage.eventHash),
                  row.value(named: "correlation_id") == .text(expected.facts.correlationID.rawValue),
                  row.value(named: "privacy") == .text(expected.facts.privacy.classification.rawValue),
                  row.value(named: "local_only") == .integer(1),
                  row.value(named: "core_version") == .integer(Int64(expected.facts.version)),
                  row.value(named: "core_digest") == .text(expected.receiptDigest),
                  row.value(named: "confirmation_token") == (
                      expected.facts.confirmationToken.map { SQLiteValue.text($0.rawValue) } ?? .null
                  ),
                  row.value(named: "confirmation_decision_digest") == (
                      expected.facts.confirmationDecisionDigest.map {
                          SQLiteValue.text($0.rawValue)
                      } ?? .null
                  ),
                  row.value(named: "core_created_at_ms") == .integer(
                      try milliseconds(expected.facts.committedAt)
                  ),
                  row.value(named: "anchor_receipt_id") == .text(expected.facts.receiptID.rawValue),
                  row.value(named: "anchor_preparation_id") == .text(expected.facts.preparationID.rawValue),
                  row.value(named: "anchor_command_id") == .text(expected.facts.commandID.rawValue),
                  row.value(named: "anchor_event_sequence") == .integer(
                      try int64(expected.facts.lineage.eventSequence)
                  ),
                  row.value(named: "anchor_version") == .integer(Int64(runtimeCommitAnchorVersion)),
                  row.value(named: "anchor_created_at_ms") == .integer(
                      try milliseconds(expected.facts.committedAt)
                  ) else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
        }
        let eventEvidence = try authenticateTerminalEvent(
            expected,
            budget: &budget,
            database: database
        )
        try authenticateTerminalMutationParity(expected, eventEvidence: eventEvidence)
        let historyRows = try budget.query(
            """
            SELECT history_id, family, object_id, prior_revision, resulting_revision,
                   lifecycle, transition_kind, terminal_event_sequence, state_digest,
                   privacy, local_only, payload, payload_checksum
            FROM runtime_object_history WHERE receipt_id = ? ORDER BY family, object_id LIMIT ?
            """,
            bindings: [
                .text(expected.facts.receiptID.rawValue),
                .integer(Int64(expected.facts.objects.count + 1)),
            ],
            database: database
        )
        guard historyRows.count == expected.facts.objects.count else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        var authenticatedHistory: [RuntimeObjectHistoryEntry] = []
        authenticatedHistory.reserveCapacity(historyRows.count)
        for (historyRow, object) in zip(historyRows, expected.facts.objects) {
            try RuntimeReceiptCancellation.check(.graphTraversal)
            let priorRevisionBinding: SQLiteValue = try object.priorRevision.map {
                .integer(try int64($0))
            } ?? .null
            guard historyRow.value(named: "family") == .text(object.aggregate.kind.rawValue),
                  historyRow.value(named: "object_id") == .text(object.aggregate.id.rawValue),
                  historyRow.value(named: "prior_revision") == priorRevisionBinding,
                  historyRow.value(named: "resulting_revision") == .integer(try int64(object.terminalRevision)),
                  historyRow.value(named: "lifecycle") == .text(object.lifecycle.rawValue),
                  historyRow.value(named: "transition_kind") == .text(object.transition.rawValue),
                  historyRow.value(named: "terminal_event_sequence") == .integer(try int64(expected.facts.lineage.eventSequence)),
                  historyRow.value(named: "state_digest") == .text(object.stateDigest),
                  historyRow.value(named: "privacy") == .text(expected.facts.privacy.classification.rawValue),
                  historyRow.value(named: "local_only") == .integer(1),
                  case let .text(historyID)? = historyRow.value(named: "history_id"),
                  case let .blob(historyBytes)? = historyRow.value(named: "payload"),
                  historyBytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
                  case let .text(historyChecksum)? = historyRow.value(named: "payload_checksum"),
                  LocalRuntimeStorageChecksum.sha256Hex(for: historyBytes) == historyChecksum else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            let entry: RuntimeObjectHistoryEntry = try decodeCanonical(
                RuntimeObjectHistoryEntry.self,
                bytes: historyBytes
            )
            guard entry.historyID == historyID,
                  entry.receiptID == expected.facts.receiptID,
                  entry.lineage == expected.facts.lineage,
                  entry.object == object,
                  entry.privacy == expected.facts.privacy else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            authenticatedHistory.append(entry)
        }
        let linkRows = try budget.query(
            """
            SELECT l.history_id, l.family, l.object_id, l.terminal_revision
            FROM runtime_receipt_object_links AS l
            WHERE l.receipt_id = ? ORDER BY l.family, l.object_id LIMIT ?
            """,
            bindings: [
                .text(expected.facts.receiptID.rawValue),
                .integer(Int64(expected.facts.objects.count + 1)),
            ],
            database: database
        )
        guard linkRows.count == expected.facts.objects.count else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        for ((linkRow, historyRow), object) in zip(zip(linkRows, historyRows), expected.facts.objects) {
            try Task.checkCancellation()
            guard linkRow.value(named: "history_id") == historyRow.value(named: "history_id"),
                  linkRow.value(named: "family") == .text(object.aggregate.kind.rawValue),
                  linkRow.value(named: "object_id") == .text(object.aggregate.id.rawValue),
                  linkRow.value(named: "terminal_revision") == .integer(try int64(object.terminalRevision)) else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
        }
        if let expectedHistory {
            guard historyRows.count == expectedHistory.count else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            for (row, draft) in zip(historyRows, expectedHistory) {
                try Task.checkCancellation()
                guard row.value(named: "history_id") == .text(draft.historyID),
                      row.value(named: "family") == .text(draft.link.aggregate.kind.rawValue),
                      row.value(named: "object_id") == .text(draft.link.aggregate.id.rawValue),
                      row.value(named: "resulting_revision") == .integer(try int64(draft.link.terminalRevision)),
                      row.value(named: "state_digest") == .text(draft.link.stateDigest) else {
                    throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
                }
            }
        }
        let dispositions = try budget.query(
            """
            SELECT disposition_kind, plan_id, evidence_digest, payload, payload_checksum
            FROM runtime_receipt_compensation_dispositions
            WHERE source_receipt_id = ? LIMIT 2
            """,
            bindings: [.text(expected.facts.receiptID.rawValue)],
            database: database
        )
        guard dispositions.count == 1, let disposition = dispositions.first,
              case let .blob(dispositionBytes)? = disposition.value(named: "payload"),
              dispositionBytes.count <= RuntimeCommittedReceiptReadBounds.maximumDispositionPayloadBytes,
              case let .text(dispositionChecksum)? = disposition.value(named: "payload_checksum"),
              LocalRuntimeStorageChecksum.sha256Hex(for: dispositionBytes) == dispositionChecksum,
              try decodeCanonical(
                RuntimeCommittedCompensationDisposition.self,
                bytes: dispositionBytes
              ) == expected.facts.compensation else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let authenticatedPlan: RuntimeCommittedCompensationPlan?
        let authenticatedEvidence: RuntimeIrreversibilityEvidence?
        switch expected.facts.compensation {
        case let .plan(planID, digest, expiresAt, requiresConfirmation):
            guard disposition.value(named: "disposition_kind") == .text("plan"),
                  disposition.value(named: "plan_id") == .text(planID.rawValue),
                  disposition.value(named: "evidence_digest") == .null else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            let plan = try loadPlan(planID: planID, budget: &budget, database: database)
            guard plan.sourceReceiptID == expected.facts.receiptID,
                  plan.sourceLineage == expected.facts.lineage,
                  plan.sourceCorrelationID == expected.facts.correlationID,
                  plan.privacy == expected.facts.privacy,
                  plan.digest == digest,
                  plan.expiresAt == expiresAt,
                  plan.requiresConfirmation == requiresConfirmation else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            try authenticatePlanRelations(plan, budget: &budget, database: database)
            let opposite = try budget.query(
                "SELECT 1 AS present FROM runtime_irreversibility_evidence WHERE source_receipt_id = ? LIMIT 2",
                bindings: [.text(expected.facts.receiptID.rawValue)],
                database: database
            )
            guard opposite.isEmpty else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            authenticatedPlan = plan
            authenticatedEvidence = nil
        case let .noncompensable(evidenceDigest, evidence):
            guard disposition.value(named: "disposition_kind") == .text("noncompensable"),
                  disposition.value(named: "plan_id") == .null,
                  disposition.value(named: "evidence_digest") == .text(evidenceDigest),
                  try RuntimeCommittedReceiptCodec.evidenceDigest(
                    evidence,
                    sourceReceiptID: expected.facts.receiptID,
                    sourceLineage: expected.facts.lineage
                  ) == evidenceDigest else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            let evidenceRows = try budget.query(
                "SELECT payload, payload_checksum FROM runtime_irreversibility_evidence WHERE source_receipt_id = ? LIMIT 2",
                bindings: [.text(expected.facts.receiptID.rawValue)],
                database: database
            )
            guard evidenceRows.count == 1, let evidenceRow = evidenceRows.first,
                  case let .blob(evidenceBytes)? = evidenceRow.value(named: "payload"),
                  evidenceBytes.count <= RuntimeCommittedReceiptReadBounds.maximumEvidencePayloadBytes,
                  case let .text(evidenceChecksum)? = evidenceRow.value(named: "payload_checksum"),
                  LocalRuntimeStorageChecksum.sha256Hex(for: evidenceBytes) == evidenceChecksum,
                  try decodeCanonical(RuntimeIrreversibilityEvidence.self, bytes: evidenceBytes) == evidence else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            let opposite = try budget.query(
                "SELECT 1 AS present FROM runtime_compensation_plans WHERE source_receipt_id = ? LIMIT 2",
                bindings: [.text(expected.facts.receiptID.rawValue)],
                database: database
            )
            guard opposite.isEmpty else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            authenticatedPlan = nil
            authenticatedEvidence = evidence
        }
        let artifactRows = try budget.query(
            """
            SELECT artifact_kind, artifact_id, artifact_digest
            FROM runtime_receipt_artifact_links WHERE receipt_id = ?
            ORDER BY artifact_kind, artifact_id LIMIT ?
            """,
            bindings: [
                .text(expected.facts.receiptID.rawValue),
                .integer(Int64(expected.facts.artifacts.count + 1)),
            ],
            database: database
        )
        guard artifactRows.count == expected.facts.artifacts.count else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        for (artifactRow, artifact) in zip(artifactRows, expected.facts.artifacts) {
            try Task.checkCancellation()
            guard artifactRow.value(named: "artifact_kind") == .text(artifact.kind.rawValue),
                  artifactRow.value(named: "artifact_id") == .text(artifact.stableID),
                  artifactRow.value(named: "artifact_digest") == (artifact.digest.map(SQLiteValue.text) ?? .null) else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
        }
        let retentionRows = try budget.query(
            """
            SELECT reference_kind, reference_id, retain_until_ms
            FROM runtime_receipt_retention_references WHERE receipt_id = ?
            ORDER BY reference_kind, reference_id LIMIT ?
            """,
            bindings: [
                .text(expected.facts.receiptID.rawValue),
                .integer(Int64(expected.facts.retention.count + 1)),
            ],
            database: database
        )
        guard retentionRows.count == expected.facts.retention.count else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        for (retentionRow, reference) in zip(retentionRows, expected.facts.retention) {
            try Task.checkCancellation()
            guard retentionRow.value(named: "reference_kind") == .text(reference.kind.rawValue),
                  retentionRow.value(named: "reference_id") == .text(reference.stableID),
                  retentionRow.value(named: "retain_until_ms") == (try reference.retainUntil.map {
                    .integer(try milliseconds($0))
                  } ?? .null) else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
        }
        let tombstonedObjects = expected.facts.objects.filter { $0.lifecycle == .tombstoned }
        let tombstoneRows = try budget.query(
            """
            SELECT t.tombstone_history_id, t.history_id, t.family, t.object_id, t.terminal_revision,
                   t.terminal_event_sequence, t.reason, t.predecessor_digest,
                   t.payload, t.payload_checksum
            FROM runtime_object_tombstone_history AS t
            WHERE t.receipt_id = ? ORDER BY t.family, t.object_id LIMIT ?
            """,
            bindings: [
                .text(expected.facts.receiptID.rawValue),
                .integer(Int64(tombstonedObjects.count + 1)),
            ],
            database: database
        )
        guard tombstoneRows.count == tombstonedObjects.count else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        var authenticatedTombstones: [RuntimeCanonicalTombstoneDraft] = []
        authenticatedTombstones.reserveCapacity(tombstoneRows.count)
        for (tombstoneRow, object) in zip(tombstoneRows, tombstonedObjects) {
            try Task.checkCancellation()
            guard case let .text(tombstoneID)? = tombstoneRow.value(named: "tombstone_history_id"),
                  case let .text(historyID)? = tombstoneRow.value(named: "history_id"),
                  RuntimeStoreManifestCodec.isSHA256Hex(tombstoneID),
                  historyRows.contains(where: {
                    $0.value(named: "history_id") == .text(historyID) &&
                        $0.value(named: "family") == .text(object.aggregate.kind.rawValue) &&
                        $0.value(named: "object_id") == .text(object.aggregate.id.rawValue)
                  }),
                  tombstoneRow.value(named: "family") == .text(object.aggregate.kind.rawValue),
                  tombstoneRow.value(named: "object_id") == .text(object.aggregate.id.rawValue),
                  tombstoneRow.value(named: "terminal_revision") == .integer(try int64(object.terminalRevision)),
                  tombstoneRow.value(named: "terminal_event_sequence") == .integer(try int64(expected.facts.lineage.eventSequence)),
                  case let .blob(tombstoneBytes)? = tombstoneRow.value(named: "payload"),
                  tombstoneBytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
                  case let .text(tombstoneChecksum)? = tombstoneRow.value(named: "payload_checksum"),
                  LocalRuntimeStorageChecksum.sha256Hex(for: tombstoneBytes) == tombstoneChecksum else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            let draft: RuntimeCanonicalTombstoneDraft = try decodeCanonical(
                RuntimeCanonicalTombstoneDraft.self,
                bytes: tombstoneBytes
            )
            try authenticateTerminalTombstoneParity(
                object: object,
                draft: draft,
                eventEvidence: eventEvidence
            )
            guard draft.objectID.rawValue == object.aggregate.id.rawValue,
                  draft.family == object.aggregate.kind.rawValue,
                  draft.terminalRevision == object.terminalRevision,
                  draft.lineage == expected.facts.lineage,
                  LocalRuntimeStorageChecksum.sha256Hex(
                    for: try RuntimeCommittedReceiptCodec.encode(TombstoneIdentityFacts(
                        historyID: historyID,
                        authority: draft.authority
                    ))
                  ) == tombstoneID,
                  tombstoneRow.value(named: "reason") == .text(draft.authority.reason.rawValue),
                  tombstoneRow.value(named: "predecessor_digest") == .text(draft.authority.predecessorDigest) else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            authenticatedTombstones.append(draft)
        }
        let artifactAuthority = try authenticateArtifactAndRetentionAuthority(
            expected,
            historyRows: historyRows,
            tombstoneRows: tombstoneRows,
            plan: authenticatedPlan,
            evidence: authenticatedEvidence,
            budget: &budget,
            database: database
        )
        if let expectedPlan {
            guard authenticatedPlan == expectedPlan else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            let planRows = try budget.query(
                "SELECT payload, payload_checksum FROM runtime_compensation_plans WHERE plan_id = ? LIMIT 2",
                bindings: [.text(expectedPlan.planID.rawValue)],
                database: database
            )
            guard planRows.count == 1, let planRow = planRows.first,
                  case let .blob(planBytes)? = planRow.value(named: "payload"),
                  planBytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
                  case let .text(planChecksum)? = planRow.value(named: "payload_checksum"),
                  LocalRuntimeStorageChecksum.sha256Hex(for: planBytes) == planChecksum,
                  try decodeCanonical(RuntimeCommittedCompensationPlan.self, bytes: planBytes) == expectedPlan else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            try RuntimeCommittedReceiptCodec.validatePlan(expectedPlan)
        }
        if let expectedEvidence {
            guard authenticatedEvidence == expectedEvidence else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            let evidenceRows = try budget.query(
                "SELECT payload, payload_checksum FROM runtime_irreversibility_evidence WHERE source_receipt_id = ? LIMIT 2",
                bindings: [.text(expected.facts.receiptID.rawValue)],
                database: database
            )
            guard evidenceRows.count == 1, let evidenceRow = evidenceRows.first,
                  case let .blob(evidenceBytes)? = evidenceRow.value(named: "payload"),
                  evidenceBytes.count <= RuntimeCommittedReceiptReadBounds.maximumEvidencePayloadBytes,
                  case let .text(evidenceChecksum)? = evidenceRow.value(named: "payload_checksum"),
                  LocalRuntimeStorageChecksum.sha256Hex(for: evidenceBytes) == evidenceChecksum,
                  try decodeCanonical(RuntimeIrreversibilityEvidence.self, bytes: evidenceBytes) == expectedEvidence else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
        }
        let finalizedRows = try budget.query(
            """
            SELECT final_result_version, final_result_payload, final_result_checksum, finalized_at_ms
            FROM runtime_command_idempotency WHERE command_id = ? LIMIT 2
            """,
            bindings: [.text(expected.facts.commandID.rawValue)],
            database: database
        )
        guard finalizedRows.count == 1, let finalizedRow = finalizedRows.first else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let finalizedIdempotency: RuntimeFinalizedIdempotencyReference?
        if case let .integer(resultVersion)? = finalizedRow.value(named: "final_result_version"),
           resultVersion == Int64(canonicalIdempotencyFinalResultVersion),
           case let .blob(finalBytes)? = finalizedRow.value(named: "final_result_payload"),
           finalBytes.count <= RuntimeCommittedReceiptReadBounds.maximumFinalizedResultPayloadBytes,
           case let .text(finalChecksum)? = finalizedRow.value(named: "final_result_checksum"),
           case let .integer(finalizedAt)? = finalizedRow.value(named: "finalized_at_ms"),
           finalizedAt >= 0,
           LocalRuntimeStorageChecksum.sha256Hex(for: finalBytes) == finalChecksum {
            do {
                try RuntimeAtomicCommitCoding.requireFinalizedOutcome(
                    finalBytes,
                    storedChecksum: finalChecksum,
                    references: expected
                )
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            finalizedIdempotency = RuntimeFinalizedIdempotencyReference(
                resultVersion: Int(resultVersion),
                resultChecksum: finalChecksum,
                finalizedAt: Date(timeIntervalSince1970: Double(finalizedAt) / 1_000)
            )
        } else if requireFinalization ||
            finalizedRow.value(named: "final_result_version") != .null ||
            finalizedRow.value(named: "final_result_payload") != .null ||
            finalizedRow.value(named: "final_result_checksum") != .null ||
            finalizedRow.value(named: "finalized_at_ms") != .null {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        } else {
            finalizedIdempotency = nil
        }
        let confirmation = try authenticateConfirmation(
            expected,
            budget: &budget,
            database: database
        )
        let consumptionRows = try budget.query(
            """
            SELECT plan_id, source_receipt_id, compensation_receipt_id,
                   compensation_command_id, terminal_event_sequence, consumed_at_ms
            FROM runtime_compensation_consumptions
            WHERE source_receipt_id = ? LIMIT 2
            """,
            bindings: [.text(expected.facts.receiptID.rawValue)],
            database: database
        )
        guard consumptionRows.count <= 1 else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let reverseConsumptionRows = try budget.query(
            """
            SELECT plan_id, source_receipt_id, compensation_receipt_id,
                   compensation_command_id, terminal_event_sequence, consumed_at_ms
            FROM runtime_compensation_consumptions
            WHERE compensation_receipt_id = ? LIMIT 2
            """,
            bindings: [.text(expected.facts.receiptID.rawValue)],
            database: database
        )
        guard reverseConsumptionRows.count <= 1 else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let isCompensationReceipt: Bool
        if case .compensation(.applied(_)) = eventEvidence.terminal.event {
            isCompensationReceipt = true
        } else {
            isCompensationReceipt = false
        }
        let compensationReceiptID: RuntimeReceiptID?
        if isCompensationReceipt, requireFinalization == false, finalizedIdempotency == nil {
            guard consumptionRows.isEmpty,
                  reverseConsumptionRows.count == 1,
                  let reverseConsumption = reverseConsumptionRows.first,
                  let allowed = traversal.allowedUnfinalizedCompensation,
                  try compensationConsumptionReference(from: reverseConsumption) == allowed,
                  allowed.compensationReceiptID == expected.facts.receiptID else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            try authenticateIncomingCompensationConsumption(
                reverseConsumption,
                compensationCore: expected,
                compensationEventEvidence: eventEvidence,
                compensationEvidence: authenticatedEvidence,
                budget: &budget,
                traversal: &traversal,
                database: database
            )
            compensationReceiptID = nil
        } else if isCompensationReceipt {
            guard consumptionRows.isEmpty,
                  reverseConsumptionRows.count == 1,
                  let reverseConsumption = reverseConsumptionRows.first,
                  finalizedIdempotency != nil else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            try authenticateIncomingCompensationConsumption(
                reverseConsumption,
                compensationCore: expected,
                compensationEventEvidence: eventEvidence,
                compensationEvidence: authenticatedEvidence,
                budget: &budget,
                traversal: &traversal,
                database: database
            )
            compensationReceiptID = nil
        } else {
            guard reverseConsumptionRows.isEmpty else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            if let consumption = consumptionRows.first {
                compensationReceiptID = try authenticateOutgoingCompensationConsumption(
                    consumption,
                    sourceCore: expected,
                    sourcePlan: authenticatedPlan,
                    budget: &budget,
                    traversal: &traversal,
                    database: database
                )
            } else {
                compensationReceiptID = nil
            }
        }
        var currentTargetStates: [RuntimeSemanticAggregate: RuntimeCanonicalAggregateState] = [:]
        if let plan = authenticatedPlan {
            for target in plan.targets {
                try Task.checkCancellation()
                let targetRows = try budget.query(
                    """
                    SELECT revision, payload_version, payload, payload_checksum FROM runtime_aggregates
                    WHERE aggregate_kind = ? AND aggregate_id = ? LIMIT 2
                    """,
                    bindings: [
                        .text(target.aggregate.kind.rawValue),
                        .text(target.aggregate.id.rawValue),
                    ],
                    database: database
                )
                guard targetRows.count <= 1 else {
                    throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
                }
                guard let targetRow = targetRows.first else {
                    continue
                }
                guard case let .integer(revision)? = targetRow.value(named: "revision"), revision >= 0,
                      case .integer(1)? = targetRow.value(named: "payload_version"),
                      case let .blob(targetBytes)? = targetRow.value(named: "payload"),
                      targetBytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
                      case let .text(targetChecksum)? = targetRow.value(named: "payload_checksum"),
                      LocalRuntimeStorageChecksum.sha256Hex(for: targetBytes) == targetChecksum else {
                    throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
                }
                let state: RuntimeCanonicalAggregateState
                let canonicalBytes: Data
                do {
                    state = try RuntimeCanonicalAggregateStateCodec().decode(targetBytes)
                    canonicalBytes = try RuntimeCanonicalAggregateStateCodec().encode(state)
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
                }
                guard UInt64(revision) == state.revision,
                      state.aggregate == target.aggregate,
                      canonicalBytes == targetBytes else {
                    throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
                }
                if state.revision == target.requiredCurrentRevision,
                   targetChecksum != target.sourceStateDigest {
                    throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
                }
                currentTargetStates[target.aggregate] = state
            }
        }
        return RuntimeAuthenticatedReceiptGraph(
            core: expected,
            eventEvidence: eventEvidence,
            history: authenticatedHistory,
            tombstones: authenticatedTombstones,
            plan: authenticatedPlan,
            irreversibilityEvidence: authenticatedEvidence,
            externalOperations: artifactAuthority.externalOperations,
            externalOperationStates: artifactAuthority.states,
            externalOperationSchemaVersion: artifactAuthority.schemaVersion,
            projectionInvalidationIDs: artifactAuthority.projectionInvalidationIDs,
            compensationReceiptID: compensationReceiptID,
            currentTargetStates: currentTargetStates,
            finalizedIdempotency: finalizedIdempotency,
            confirmation: confirmation
        )
    }

    private static func authenticateConfirmation(
        _ core: RuntimeCommittedReceiptCore,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCommittedReceiptConfirmationReference? {
        let token = core.facts.confirmationToken
        let digest = core.facts.confirmationDecisionDigest
        guard (token == nil) == (digest == nil) else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        var sql = """
            SELECT receipt_id, preparation_id, command_id, token, decision_digest,
                   terminal_event_sequence, consumed_at_ms
            FROM runtime_confirmation_consumptions
            WHERE receipt_id = ? OR preparation_id = ? OR command_id = ?
               OR terminal_event_sequence = ?
            """
        var bindings: [SQLiteBinding] = [
            .text(core.facts.receiptID.rawValue),
            .text(core.facts.preparationID.rawValue),
            .text(core.facts.commandID.rawValue),
            .integer(try int64(core.facts.lineage.eventSequence)),
        ]
        if let token {
            sql += " OR token = ?"
            bindings.append(.text(token.rawValue))
        }
        sql += " LIMIT 2"
        let rows = try budget.query(sql, bindings: bindings, database: database)
        guard let token, let digest else {
            guard rows.isEmpty else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            return nil
        }
        guard rows.count == 1, let row = rows.first,
              row.value(named: "receipt_id") == .text(core.facts.receiptID.rawValue),
              row.value(named: "preparation_id") == .text(core.facts.preparationID.rawValue),
              row.value(named: "command_id") == .text(core.facts.commandID.rawValue),
              row.value(named: "token") == .text(token.rawValue),
              row.value(named: "decision_digest") == .text(digest.rawValue),
              row.value(named: "terminal_event_sequence") == .integer(
                  try int64(core.facts.lineage.eventSequence)
              ),
              case let .integer(consumedAtMilliseconds)? = row.value(named: "consumed_at_ms"),
              consumedAtMilliseconds == (try milliseconds(core.facts.committedAt)) else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        return RuntimeCommittedReceiptConfirmationReference(
            receiptID: core.facts.receiptID,
            preparationID: core.facts.preparationID,
            commandID: core.facts.commandID,
            token: token,
            decisionDigest: digest,
            terminalEventSequence: core.facts.lineage.eventSequence,
            consumedAt: core.facts.committedAt
        )
    }

    static func authenticateTerminalMutationParity(
        _ expected: RuntimeCommittedReceiptCore,
        eventEvidence: RuntimeVerifiedExactSemanticEventEvidence
    ) throws {
        let mutation = eventEvidence.terminal.event.mutation
        guard mutation.privacy == expected.facts.privacy.classification,
              mutation.localOnly == expected.facts.privacy.localOnly,
              expected.facts.privacy.localOnly,
              mutation.aggregateTransitions.count == expected.facts.objects.count else {
            throw RuntimeCommittedReceiptAuthorityError.sourceBlocked(.terminalEventIntegrityMismatch)
        }
        for (transition, object) in zip(mutation.aggregateTransitions, expected.facts.objects) {
            try Task.checkCancellation()
            let decodedState: RuntimeCanonicalAggregateState
            do {
                decodedState = try RuntimeCanonicalAggregateStateCodec().decode(
                    transition.canonicalStateBytes
                )
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                throw RuntimeCommittedReceiptAuthorityError.sourceBlocked(.terminalEventIntegrityMismatch)
            }
            guard transition.aggregate == object.aggregate,
                  transition.priorRevision == object.priorRevision,
                  transition.resultingRevision == object.terminalRevision,
                  transition.lifecycle == object.lifecycle,
                  transition.transition == object.transition,
                  transition.canonicalStateDigest == object.stateDigest,
                  transition.canonicalStateDigest == LocalRuntimeStorageChecksum.sha256Hex(
                      for: transition.canonicalStateBytes
                  ),
                  transition.privacy == expected.facts.privacy.classification,
                  transition.localOnly == true,
                  decodedState.aggregate == object.aggregate,
                  decodedState.revision == object.terminalRevision,
                  decodedState.lifecycle == object.lifecycle,
                  decodedState.transition == object.transition,
                  decodedState.privacy == expected.facts.privacy.classification,
                  decodedState.localOnly == true,
                  decodedState.changedObjectIDs == mutation.changedObjectIDs else {
                throw RuntimeCommittedReceiptAuthorityError.sourceBlocked(.terminalEventIntegrityMismatch)
            }
        }
    }

    private struct CompensationConsumptionReference: Hashable {
        let planID: RuntimeRollbackPlanID
        let sourceReceiptID: RuntimeReceiptID
        let compensationReceiptID: RuntimeReceiptID
        let compensationCommandID: RuntimeCommandID
        let terminalEventSequence: UInt64
        let consumedAtMilliseconds: Int64
    }

    private struct ReceiptAuthenticationTraversal {
        let allowedUnfinalizedCompensation: CompensationConsumptionReference?
        private var visitedCompensationEdges: Set<CompensationConsumptionReference> = []

        mutating func begin(_ reference: CompensationConsumptionReference) -> Bool {
            visitedCompensationEdges.insert(reference).inserted
        }
    }

    private static func compensationConsumptionReference(
        from row: SQLiteRow
    ) throws -> CompensationConsumptionReference {
        guard case let .text(rawPlanID)? = row.value(named: "plan_id"),
              let planID = RuntimeRollbackPlanID(rawValue: rawPlanID),
              case let .text(rawSourceReceiptID)? = row.value(named: "source_receipt_id"),
              let sourceReceiptID = RuntimeReceiptID(rawValue: rawSourceReceiptID),
              case let .text(rawCompensationReceiptID)? = row.value(named: "compensation_receipt_id"),
              let compensationReceiptID = RuntimeReceiptID(rawValue: rawCompensationReceiptID),
              case let .text(rawCompensationCommandID)? = row.value(named: "compensation_command_id"),
              let compensationCommandID = RuntimeCommandID(rawValue: rawCompensationCommandID),
              case let .integer(rawTerminalSequence)? = row.value(named: "terminal_event_sequence"),
              rawTerminalSequence > 0,
              case let .integer(consumedAt)? = row.value(named: "consumed_at_ms"),
              consumedAt >= 0 else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        return CompensationConsumptionReference(
            planID: planID,
            sourceReceiptID: sourceReceiptID,
            compensationReceiptID: compensationReceiptID,
            compensationCommandID: compensationCommandID,
            terminalEventSequence: UInt64(rawTerminalSequence),
            consumedAtMilliseconds: consumedAt
        )
    }

    private static func authenticateOutgoingCompensationConsumption(
        _ row: SQLiteRow,
        sourceCore: RuntimeCommittedReceiptCore,
        sourcePlan: RuntimeCommittedCompensationPlan?,
        budget: inout RuntimeReceiptDecodedByteBudget,
        traversal: inout ReceiptAuthenticationTraversal,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeReceiptID {
        try Task.checkCancellation()
        let reference = try compensationConsumptionReference(from: row)
        guard let sourcePlan,
              reference.sourceReceiptID == sourceCore.facts.receiptID,
              reference.sourceReceiptID == sourcePlan.sourceReceiptID,
              reference.planID == sourcePlan.planID,
              reference.sourceReceiptID != reference.compensationReceiptID else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let reverseRows = try budget.query(
            """
            SELECT plan_id, source_receipt_id, compensation_receipt_id,
                   compensation_command_id, terminal_event_sequence, consumed_at_ms
            FROM runtime_compensation_consumptions
            WHERE compensation_receipt_id = ? LIMIT 2
            """,
            bindings: [.text(reference.compensationReceiptID.rawValue)],
            database: database
        )
        guard reverseRows.count == 1,
              let reverseRow = reverseRows.first,
              try compensationConsumptionReference(from: reverseRow) == reference else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let recursiveRows = try budget.query(
            """
            SELECT 1 AS present FROM runtime_compensation_consumptions
            WHERE source_receipt_id = ? LIMIT 2
            """,
            bindings: [.text(reference.compensationReceiptID.rawValue)],
            database: database
        )
        guard recursiveRows.isEmpty else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let compensationCore = try loadCore(
            receiptID: reference.compensationReceiptID,
            budget: &budget,
            database: database
        )
        let eventEvidence: RuntimeVerifiedExactSemanticEventEvidence
        let evidence: RuntimeIrreversibilityEvidence?
        if traversal.begin(reference) {
            let graph = try authenticatePersistedCoreTraversing(
                compensationCore,
                budget: &budget,
                traversal: &traversal,
                database: database
            )
            eventEvidence = graph.eventEvidence
            evidence = graph.irreversibilityEvidence
        } else {
            eventEvidence = try authenticateTerminalEvent(
                compensationCore,
                budget: &budget,
                database: database
            )
            try authenticateTerminalMutationParity(compensationCore, eventEvidence: eventEvidence)
            evidence = try authenticateCompensationEndpointDisposition(
                compensationCore,
                budget: &budget,
                database: database
            )
            if traversal.allowedUnfinalizedCompensation == reference,
               reference.compensationReceiptID == compensationCore.facts.receiptID {
                try requireUnfinalizedConstructionEndpoint(
                    compensationCore,
                    budget: &budget,
                    database: database
                )
            } else {
                try requireFinalizedEndpoint(
                    compensationCore,
                    budget: &budget,
                    database: database
                )
            }
        }
        try authenticateCompensationSemantics(
            reference,
            sourceCore: sourceCore,
            sourcePlan: sourcePlan,
            compensationCore: compensationCore,
            compensationEventEvidence: eventEvidence,
            compensationEvidence: evidence
        )
        return reference.compensationReceiptID
    }

    private static func authenticateIncomingCompensationConsumption(
        _ row: SQLiteRow,
        compensationCore: RuntimeCommittedReceiptCore,
        compensationEventEvidence: RuntimeVerifiedExactSemanticEventEvidence,
        compensationEvidence: RuntimeIrreversibilityEvidence?,
        budget: inout RuntimeReceiptDecodedByteBudget,
        traversal: inout ReceiptAuthenticationTraversal,
        database: isolated SQLiteDatabase
    ) throws {
        try Task.checkCancellation()
        let reference = try compensationConsumptionReference(from: row)
        guard reference.compensationReceiptID == compensationCore.facts.receiptID,
              reference.compensationCommandID == compensationCore.facts.commandID,
              reference.terminalEventSequence == compensationCore.facts.lineage.eventSequence,
              reference.sourceReceiptID != reference.compensationReceiptID else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let sourceCore = try loadCore(
            receiptID: reference.sourceReceiptID,
            budget: &budget,
            database: database
        )
        let sourcePlan: RuntimeCommittedCompensationPlan
        if traversal.begin(reference) {
            let graph = try authenticatePersistedCoreTraversing(
                sourceCore,
                budget: &budget,
                traversal: &traversal,
                database: database
            )
            guard let plan = graph.plan, plan.planID == reference.planID else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            sourcePlan = plan
        } else {
            let sourceEventEvidence = try authenticateTerminalEvent(
                sourceCore,
                budget: &budget,
                database: database
            )
            try authenticateTerminalMutationParity(sourceCore, eventEvidence: sourceEventEvidence)
            sourcePlan = try authenticateSourceEndpointPlan(
                sourceCore,
                expectedPlanID: reference.planID,
                budget: &budget,
                database: database
            )
            try requireFinalizedEndpoint(sourceCore, budget: &budget, database: database)
        }
        try authenticateCompensationSemantics(
            reference,
            sourceCore: sourceCore,
            sourcePlan: sourcePlan,
            compensationCore: compensationCore,
            compensationEventEvidence: compensationEventEvidence,
            compensationEvidence: compensationEvidence
        )
    }

    private static func authenticateCompensationSemantics(
        _ reference: CompensationConsumptionReference,
        sourceCore: RuntimeCommittedReceiptCore,
        sourcePlan: RuntimeCommittedCompensationPlan,
        compensationCore: RuntimeCommittedReceiptCore,
        compensationEventEvidence: RuntimeVerifiedExactSemanticEventEvidence,
        compensationEvidence: RuntimeIrreversibilityEvidence?
    ) throws {
        guard reference.sourceReceiptID == sourceCore.facts.receiptID,
              reference.sourceReceiptID == sourcePlan.sourceReceiptID,
              reference.planID == sourcePlan.planID,
              reference.compensationReceiptID == compensationCore.facts.receiptID,
              reference.compensationCommandID == compensationCore.facts.commandID,
              reference.terminalEventSequence == compensationCore.facts.lineage.eventSequence,
              reference.consumedAtMilliseconds == try milliseconds(compensationCore.facts.committedAt),
              compensationCore.facts.correlationID == sourceCore.facts.correlationID,
              compensationEventEvidence.terminal.lineage.causationEventID == sourceCore.facts.lineage.eventID,
              compensationEventEvidence.terminal.lineage.correlationID == sourceCore.facts.correlationID,
              case let .compensation(.applied(payload)) = compensationEventEvidence.terminal.event else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let expectedCommand = RuntimeCompensationCommand(
            sourceReceiptID: sourcePlan.sourceReceiptID,
            planID: sourcePlan.planID,
            planDigest: sourcePlan.digest,
            sourceLineage: sourcePlan.sourceLineage,
            action: sourcePlan.action,
            targets: sourcePlan.targets,
            requiresConfirmation: sourcePlan.requiresConfirmation,
            target: sourcePlan.action.target,
            content: RuntimeCommandContent()
        )
        let expectedType: RuntimeSemanticEventTypeID = switch sourcePlan.action {
        case .discardCreatedCapture: .captureCreatedCompensated
        case .discardCreatedGoal: .goalCreatedCompensated
        case .discardCreatedSchedule: .scheduleCreatedCompensated
        case .discardCreatedReminder: .reminderCreatedCompensated
        }
        let expectedEvidence = RuntimeIrreversibilityEvidence(
            version: 1,
            permanence: .semantic,
            reason: .compensationOfCompensation,
            commandFamily: "compensation",
            commandAction: RuntimeCommandPayload.compensation(expectedCommand).diagnosticCase
        )
        guard payload.facts.command == expectedCommand,
              compensationEventEvidence.terminal.event.typeID == expectedType,
              compensationEventEvidence.terminal.event.commandPayload ==
                  .compensation(expectedCommand),
              payload.mutation.semanticType == expectedType,
              compensationEvidence == expectedEvidence,
              case let .noncompensable(_, coreEvidence) = compensationCore.facts.compensation,
              coreEvidence == expectedEvidence,
              payload.mutation.aggregateTransitions.count == sourcePlan.targets.count,
              compensationCore.facts.objects.count == sourcePlan.targets.count,
              sourcePlan.targets.count <= RuntimeCompensationLimits.maximumTargets else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        for ((target, transition), object) in zip(
            zip(sourcePlan.targets, payload.mutation.aggregateTransitions),
            compensationCore.facts.objects
        ) {
            try Task.checkCancellation()
            let (resultingRevision, overflow) = target.sourceRevision.addingReportingOverflow(1)
            guard overflow == false,
                  transition.aggregate == target.aggregate,
                  transition.priorRevision == target.sourceRevision,
                  transition.resultingRevision == resultingRevision,
                  transition.lifecycle == .tombstoned,
                  transition.transition == target.inverseTransition,
                  transition.privacy == sourcePlan.privacy.classification,
                  transition.localOnly == sourcePlan.privacy.localOnly,
                  object.aggregate == target.aggregate,
                  object.priorRevision == target.sourceRevision,
                  object.terminalRevision == resultingRevision,
                  object.lifecycle == .tombstoned,
                  object.transition == target.inverseTransition else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
        }
    }

    private static func authenticateSourceEndpointPlan(
        _ sourceCore: RuntimeCommittedReceiptCore,
        expectedPlanID: RuntimeRollbackPlanID,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCommittedCompensationPlan {
        guard case let .plan(planID, digest, expiresAt, requiresConfirmation) =
                sourceCore.facts.compensation,
              planID == expectedPlanID else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let plan = try loadPlan(planID: planID, budget: &budget, database: database)
        guard plan.sourceReceiptID == sourceCore.facts.receiptID,
              plan.sourceLineage == sourceCore.facts.lineage,
              plan.sourceCorrelationID == sourceCore.facts.correlationID,
              plan.privacy == sourceCore.facts.privacy,
              plan.digest == digest,
              plan.expiresAt == expiresAt,
              plan.requiresConfirmation == requiresConfirmation else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        try authenticatePlanRelations(plan, budget: &budget, database: database)
        let dispositionRows = try budget.query(
            """
            SELECT disposition_kind, plan_id, evidence_digest, payload, payload_checksum
            FROM runtime_receipt_compensation_dispositions
            WHERE source_receipt_id = ? LIMIT 2
            """,
            bindings: [.text(sourceCore.facts.receiptID.rawValue)],
            database: database
        )
        guard dispositionRows.count == 1, let row = dispositionRows.first,
              row.value(named: "disposition_kind") == .text("plan"),
              row.value(named: "plan_id") == .text(planID.rawValue),
              row.value(named: "evidence_digest") == .null,
              case let .blob(bytes)? = row.value(named: "payload"),
              bytes.count <= RuntimeCommittedReceiptReadBounds.maximumDispositionPayloadBytes,
              case let .text(checksum)? = row.value(named: "payload_checksum"),
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == checksum,
              try decodeCanonical(RuntimeCommittedCompensationDisposition.self, bytes: bytes) ==
                sourceCore.facts.compensation else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let oppositeRows = try budget.query(
            "SELECT 1 AS present FROM runtime_irreversibility_evidence WHERE source_receipt_id = ? LIMIT 2",
            bindings: [.text(sourceCore.facts.receiptID.rawValue)],
            database: database
        )
        guard oppositeRows.isEmpty else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        return plan
    }

    private static func authenticateCompensationEndpointDisposition(
        _ compensationCore: RuntimeCommittedReceiptCore,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeIrreversibilityEvidence {
        guard case let .noncompensable(evidenceDigest, expectedEvidence) =
                compensationCore.facts.compensation else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let dispositionRows = try budget.query(
            """
            SELECT disposition_kind, plan_id, evidence_digest, payload, payload_checksum
            FROM runtime_receipt_compensation_dispositions
            WHERE source_receipt_id = ? LIMIT 2
            """,
            bindings: [.text(compensationCore.facts.receiptID.rawValue)],
            database: database
        )
        let evidenceRows = try budget.query(
            """
            SELECT payload, payload_checksum FROM runtime_irreversibility_evidence
            WHERE source_receipt_id = ? LIMIT 2
            """,
            bindings: [.text(compensationCore.facts.receiptID.rawValue)],
            database: database
        )
        guard dispositionRows.count == 1, let disposition = dispositionRows.first,
              disposition.value(named: "disposition_kind") == .text("noncompensable"),
              disposition.value(named: "plan_id") == .null,
              disposition.value(named: "evidence_digest") == .text(evidenceDigest),
              case let .blob(dispositionBytes)? = disposition.value(named: "payload"),
              dispositionBytes.count <= RuntimeCommittedReceiptReadBounds.maximumDispositionPayloadBytes,
              case let .text(dispositionChecksum)? = disposition.value(named: "payload_checksum"),
              LocalRuntimeStorageChecksum.sha256Hex(for: dispositionBytes) == dispositionChecksum,
              try decodeCanonical(
                RuntimeCommittedCompensationDisposition.self,
                bytes: dispositionBytes
              ) == compensationCore.facts.compensation,
              evidenceRows.count == 1, let evidenceRow = evidenceRows.first,
              case let .blob(evidenceBytes)? = evidenceRow.value(named: "payload"),
              evidenceBytes.count <= RuntimeCommittedReceiptReadBounds.maximumEvidencePayloadBytes,
              case let .text(evidenceChecksum)? = evidenceRow.value(named: "payload_checksum"),
              LocalRuntimeStorageChecksum.sha256Hex(for: evidenceBytes) == evidenceChecksum,
              try decodeCanonical(RuntimeIrreversibilityEvidence.self, bytes: evidenceBytes) ==
                expectedEvidence,
              try RuntimeCommittedReceiptCodec.evidenceDigest(
                expectedEvidence,
                sourceReceiptID: compensationCore.facts.receiptID,
                sourceLineage: compensationCore.facts.lineage
              ) == evidenceDigest else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let oppositeRows = try budget.query(
            "SELECT 1 AS present FROM runtime_compensation_plans WHERE source_receipt_id = ? LIMIT 2",
            bindings: [.text(compensationCore.facts.receiptID.rawValue)],
            database: database
        )
        guard oppositeRows.isEmpty else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        return expectedEvidence
    }

    private static func requireFinalizedEndpoint(
        _ core: RuntimeCommittedReceiptCore,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws {
        let rows = try budget.query(
            """
            SELECT final_result_version, final_result_payload, final_result_checksum, finalized_at_ms
            FROM runtime_command_idempotency WHERE command_id = ? LIMIT 2
            """,
            bindings: [.text(core.facts.commandID.rawValue)],
            database: database
        )
        guard rows.count == 1, let row = rows.first,
              row.value(named: "final_result_version") == .integer(
                Int64(canonicalIdempotencyFinalResultVersion)
              ),
              case let .blob(bytes)? = row.value(named: "final_result_payload"),
              bytes.count <= RuntimeCommittedReceiptReadBounds.maximumFinalizedResultPayloadBytes,
              case let .text(checksum)? = row.value(named: "final_result_checksum"),
              case let .integer(finalizedAt)? = row.value(named: "finalized_at_ms"),
              finalizedAt >= 0,
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == checksum else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        do {
            try RuntimeAtomicCommitCoding.requireFinalizedOutcome(
                bytes,
                storedChecksum: checksum,
                references: core
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
    }

    private static func requireUnfinalizedConstructionEndpoint(
        _ core: RuntimeCommittedReceiptCore,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws {
        let rows = try budget.query(
            """
            SELECT final_result_version, final_result_payload,
                   final_result_checksum, finalized_at_ms
            FROM runtime_command_idempotency WHERE command_id = ? LIMIT 2
            """,
            bindings: [.text(core.facts.commandID.rawValue)],
            database: database
        )
        guard rows.count == 1, let row = rows.first,
              row.value(named: "final_result_version") == .null,
              row.value(named: "final_result_payload") == .null,
              row.value(named: "final_result_checksum") == .null,
              row.value(named: "finalized_at_ms") == .null else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
    }

    private static func authenticateTerminalEvent(
        _ core: RuntimeCommittedReceiptCore,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeVerifiedExactSemanticEventEvidence {
        try RuntimeReceiptCancellation.check(.terminalEventRead)
        do {
            let evidence = try CanonicalRuntimeSemanticEventStore.readVerifiedExactInTransaction(
                sequence: core.facts.lineage.eventSequence,
                budget: &budget,
                database: database
            )
            let event = evidence.terminal
            guard event.lineage.eventID == core.facts.lineage.eventID,
                  event.lineage.commandID == core.facts.commandID,
                  event.lineage.correlationID == core.facts.correlationID,
                  event.lineage.eventHash.hexadecimal == core.facts.lineage.eventHash else {
                throw RuntimeCommittedReceiptAuthorityError.sourceBlocked(.terminalEventIntegrityMismatch)
            }
            return evidence
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as RuntimeCommittedReceiptAuthorityError {
            throw error
        } catch let error as RuntimeCommittedReceiptQueryError {
            throw error
        } catch is SQLiteQueryBudgetExceeded {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        } catch CanonicalRuntimeSemanticEventStoreError.quarantinedSource {
            throw RuntimeCommittedReceiptAuthorityError.sourceBlocked(.terminalEventQuarantined)
        } catch CanonicalRuntimeSemanticEventStoreError.quarantinedDependency {
            throw RuntimeCommittedReceiptAuthorityError.sourceBlocked(.eventDependencyQuarantined)
        } catch {
            throw RuntimeCommittedReceiptAuthorityError.sourceBlocked(.terminalEventIntegrityMismatch)
        }
    }

    static func authenticateTerminalTombstoneParity(
        object: RuntimeCommittedReceiptObjectLink,
        draft: RuntimeCanonicalTombstoneDraft,
        eventEvidence: RuntimeVerifiedExactSemanticEventEvidence
    ) throws {
        guard eventEvidence.terminal.event.mutation.aggregateTransitions.first(where: {
            $0.aggregate == object.aggregate
        })?.tombstone == draft.authority else {
            throw RuntimeCommittedReceiptAuthorityError.sourceBlocked(.terminalEventIntegrityMismatch)
        }
    }

    private static func authenticateArtifactAndRetentionAuthority(
        _ expected: RuntimeCommittedReceiptCore,
        historyRows: [SQLiteRow],
        tombstoneRows: [SQLiteRow],
        plan: RuntimeCommittedCompensationPlan?,
        evidence: RuntimeIrreversibilityEvidence?,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> (
        externalOperations: [RuntimeAuthenticatedExternalOperationSummary],
        states: [RuntimeExternalOperationID: RuntimeCanonicalExternalOperation],
        schemaVersion: Int,
        projectionInvalidationIDs: [String]
    ) {
        var authoritativeArtifacts = [RuntimeCommittedReceiptArtifactLink(
            kind: .terminalEvent,
            stableID: expected.facts.lineage.eventID.rawValue,
            digest: expected.facts.lineage.eventHash
        )]
        var authoritativeRetention: [RuntimeReceiptRetentionReference] = try historyRows.map { row in
            guard case let .text(historyID)? = row.value(named: "history_id") else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            return RuntimeReceiptRetentionReference(
                kind: .objectHistory,
                stableID: historyID,
                retainUntil: nil
            )
        }

        for row in tombstoneRows {
            try Task.checkCancellation()
            guard case let .text(tombstoneID)? = row.value(named: "tombstone_history_id"),
                  case let .blob(bytes)? = row.value(named: "payload"),
                  bytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
                  case let .text(checksum)? = row.value(named: "payload_checksum"),
                  LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == checksum else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            authoritativeArtifacts.append(RuntimeCommittedReceiptArtifactLink(
                kind: .tombstoneHistory,
                stableID: tombstoneID,
                digest: checksum
            ))
            authoritativeRetention.append(RuntimeReceiptRetentionReference(
                kind: .tombstoneHistory,
                stableID: tombstoneID,
                retainUntil: nil
            ))
        }

        let invalidations = try budget.query(
            """
            SELECT invalidation_id, payload, payload_checksum
            FROM runtime_commit_projection_invalidations
            WHERE terminal_event_sequence = ? ORDER BY invalidation_id LIMIT ?
            """,
            bindings: [
                .integer(try int64(expected.facts.lineage.eventSequence)),
                .integer(Int64(RuntimeCommittedReceiptLimits.maximumProjectionInvalidations + 1)),
            ],
            database: database
        )
        guard invalidations.count <= RuntimeCommittedReceiptLimits.maximumProjectionInvalidations else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        var projectionInvalidationIDs: [String] = []
        projectionInvalidationIDs.reserveCapacity(invalidations.count)
        for row in invalidations {
            try Task.checkCancellation()
            guard case let .text(invalidationID)? = row.value(named: "invalidation_id"),
                  case let .blob(bytes)? = row.value(named: "payload"),
                  bytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
                  case let .text(checksum)? = row.value(named: "payload_checksum"),
                  LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == checksum,
                  try decodeCanonical(
                    RuntimeAuthorityLineageReference.self,
                    bytes: bytes
                  ) == expected.facts.lineage else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            authoritativeArtifacts.append(RuntimeCommittedReceiptArtifactLink(
                kind: .projectionInvalidation,
                stableID: invalidationID,
                digest: checksum
            ))
            projectionInvalidationIDs.append(invalidationID)
        }

        let versionRows = try budget.query("PRAGMA user_version", database: database)
        guard versionRows.count == 1,
              case let .integer(rawSchemaVersion)? = versionRows[0].values.first else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        let operationAuthority: ExternalOperationArtifactAuthority
        switch Int(rawSchemaVersion) {
        case 6:
            operationAuthority = try authenticateLegacyExternalOperations(
                expected, budget: &budget, database: database
            )
        case runtimeCanonicalExternalOperationSchemaVersion:
            operationAuthority = try authenticateCanonicalExternalOperations(
                expected, plan: plan, budget: &budget, database: database
            )
        default:
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        authoritativeArtifacts += operationAuthority.artifacts
        authoritativeRetention += operationAuthority.retention

        if let plan {
            authoritativeArtifacts.append(RuntimeCommittedReceiptArtifactLink(
                kind: .compensationPlan,
                stableID: plan.planID.rawValue,
                digest: plan.digest
            ))
            authoritativeRetention.append(RuntimeReceiptRetentionReference(
                kind: .compensationSource,
                stableID: plan.planID.rawValue,
                retainUntil: plan.expiresAt
            ))
        }
        if let evidence {
            authoritativeArtifacts.append(RuntimeCommittedReceiptArtifactLink(
                kind: .irreversibilityEvidence,
                stableID: expected.facts.receiptID.rawValue,
                digest: try RuntimeCommittedReceiptCodec.evidenceDigest(
                    evidence,
                    sourceReceiptID: expected.facts.receiptID,
                    sourceLineage: expected.facts.lineage
                )
            ))
        }
        guard authoritativeArtifacts.sorted() == expected.facts.artifacts,
              authoritativeRetention.sorted() == expected.facts.retention else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        return (
            operationAuthority.summaries,
            operationAuthority.states,
            operationAuthority.schemaVersion,
            projectionInvalidationIDs
        )
    }

    private static func authenticateLegacyExternalOperations(
        _ expected: RuntimeCommittedReceiptCore,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> ExternalOperationArtifactAuthority {
        let rows = try budget.query(
            """
            SELECT operation_id, command_id, terminal_event_sequence, status,
                   payload, payload_checksum
            FROM runtime_pending_external_operations
            WHERE receipt_id = ? ORDER BY operation_id LIMIT ?
            """,
            bindings: [
                .text(expected.facts.receiptID.rawValue),
                .integer(Int64(RuntimeCommittedReceiptLimits.maximumPendingExternalOperations + 1)),
            ],
            database: database
        )
        guard rows.count <= RuntimeCommittedReceiptLimits.maximumPendingExternalOperations else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        var summaries: [RuntimeAuthenticatedExternalOperationSummary] = []
        var artifacts: [RuntimeCommittedReceiptArtifactLink] = []
        var retention: [RuntimeReceiptRetentionReference] = []
        for row in rows {
            try Task.checkCancellation()
            guard case let .text(rawOperationID)? = row.value(named: "operation_id"),
                  let operationID = RuntimeExternalOperationID(rawValue: rawOperationID),
                  row.value(named: "command_id") == .text(expected.facts.commandID.rawValue),
                  row.value(named: "terminal_event_sequence") == .integer(
                    try int64(expected.facts.lineage.eventSequence)
                  ),
                  row.value(named: "status") == .text("pending"),
                  case let .blob(bytes)? = row.value(named: "payload"),
                  bytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
                  case let .text(checksum)? = row.value(named: "payload_checksum"),
                  LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == checksum else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            let operation: RuntimeCanonicalPendingExternalOperation
            do {
                operation = try decodeCanonical(
                    RuntimeCanonicalPendingExternalOperation.self, bytes: bytes
                )
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            guard operation.operationID == operationID,
                  operation.status == "pending",
                  operation.lineage == expected.facts.lineage else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            summaries.append(RuntimeAuthenticatedExternalOperationSummary(
                operationID: operationID,
                kind: operation.kind,
                workflowStatus: .pending,
                effectDisposition: .notAttempted,
                statusVersion: nil,
                attemptCount: nil
            ))
            artifacts.append(RuntimeCommittedReceiptArtifactLink(
                kind: .externalOperation, stableID: operationID.rawValue, digest: checksum
            ))
            retention.append(RuntimeReceiptRetentionReference(
                kind: .externalOperation, stableID: operationID.rawValue, retainUntil: nil
            ))
        }
        return ExternalOperationArtifactAuthority(
            summaries: summaries,
            states: [:],
            artifacts: artifacts,
            retention: retention,
            schemaVersion: 6
        )
    }

    private static func authenticateCanonicalExternalOperations(
        _ expected: RuntimeCommittedReceiptCore,
        plan: RuntimeCommittedCompensationPlan?,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> ExternalOperationArtifactAuthority {
        let graphs: [RuntimeExternalOperationAuthorityGraph]
        do {
            graphs = try RuntimeExternalOperationGraphAuthority.loadAuthenticatedForReceipt(
                receiptID: expected.facts.receiptID,
                budget: &budget,
                database: database
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch is RuntimeCanonicalExternalOperationError {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        } catch is RuntimeExternalOperationCodecError {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }

        let expectedTargets = try expected.facts.objects.map {
            RuntimeExternalOperationTarget(
                family: $0.aggregate.kind,
                objectID: try RuntimeDomainObjectID(validating: $0.aggregate.id.rawValue)
            )
        }.sorted()
        var summaries: [RuntimeAuthenticatedExternalOperationSummary] = []
        var states: [RuntimeExternalOperationID: RuntimeCanonicalExternalOperation] = [:]
        var artifacts: [RuntimeCommittedReceiptArtifactLink] = []
        var retention: [RuntimeReceiptRetentionReference] = []

        for graph in graphs {
            try Task.checkCancellation()
            let creation = graph.creation
            let current = graph.current
            guard creation.receiptID == expected.facts.receiptID,
                  creation.commandID == expected.facts.commandID,
                  creation.lineage == expected.facts.lineage,
                  creation.privacy == expected.facts.privacy.classification,
                  creation.localOnly,
                  creation.localOnly == expected.facts.privacy.localOnly,
                  creation.createdAt == expected.facts.committedAt,
                  creation.targets == expectedTargets,
                  creation.stableIdempotencyKey == .derive(
                    operationID: creation.operationID,
                    commandID: creation.commandID,
                    kind: creation.kind
                  ),
                  current.operationID == creation.operationID,
                  states.updateValue(current, forKey: creation.operationID) == nil else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            summaries.append(RuntimeAuthenticatedExternalOperationSummary(
                operationID: creation.operationID,
                kind: creation.kind,
                workflowStatus: current.workflowStatus,
                effectDisposition: current.effectDisposition,
                statusVersion: current.statusVersion,
                attemptCount: current.attemptCount
            ))
            artifacts.append(RuntimeCommittedReceiptArtifactLink(
                kind: .externalOperation,
                stableID: creation.operationID.rawValue,
                digest: current.creationDigest
            ))
            retention.append(RuntimeReceiptRetentionReference(
                kind: .externalOperation,
                stableID: creation.operationID.rawValue,
                retainUntil: nil
            ))
        }

        let operationIDs = summaries.map(\.operationID)
        guard operationIDs == operationIDs.sorted(),
              Set(operationIDs).count == operationIDs.count,
              plan.map({ $0.externalOperationIDs == operationIDs }) ?? true else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        return ExternalOperationArtifactAuthority(
            summaries: summaries,
            states: states,
            artifacts: artifacts,
            retention: retention,
            schemaVersion: runtimeCanonicalExternalOperationSchemaVersion
        )
    }

    private static func authenticatePlanRelations(
        _ plan: RuntimeCommittedCompensationPlan,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws {
        let targetRows = try budget.query(
            """
            SELECT family, object_id, source_prior_revision, source_revision,
                   source_transition_kind, required_current_revision,
                   required_lifecycle, source_state_digest, transition_kind
            FROM runtime_compensation_plan_targets
            WHERE plan_id = ? ORDER BY family, object_id LIMIT ?
            """,
            bindings: [
                .text(plan.planID.rawValue),
                .integer(Int64(RuntimeCompensationLimits.maximumTargets + 1)),
            ],
            database: database
        )
        guard targetRows.count == plan.targets.count else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        for (row, target) in zip(targetRows, plan.targets) {
            try Task.checkCancellation()
            guard row.value(named: "family") == .text(target.aggregate.kind.rawValue),
                  row.value(named: "object_id") == .text(target.aggregate.id.rawValue),
                  row.value(named: "source_prior_revision") == (try target.sourcePriorRevision.map {
                    .integer(try int64($0))
                  } ?? .null),
                  row.value(named: "source_revision") == .integer(try int64(target.sourceRevision)),
                  row.value(named: "source_transition_kind") == .text(target.sourceTransition.rawValue),
                  row.value(named: "required_current_revision") == .integer(try int64(target.requiredCurrentRevision)),
                  row.value(named: "required_lifecycle") == .text(target.requiredLifecycle.rawValue),
                  row.value(named: "source_state_digest") == .text(target.sourceStateDigest),
                  row.value(named: "transition_kind") == .text(target.inverseTransition.rawValue) else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
        }
        let operationRows = try budget.query(
            """
            SELECT operation_id FROM runtime_compensation_plan_external_operations
            WHERE plan_id = ? ORDER BY operation_id LIMIT ?
            """,
            bindings: [
                .text(plan.planID.rawValue),
                .integer(Int64(RuntimeCompensationLimits.maximumExternalOperations + 1)),
            ],
            database: database
        )
        guard operationRows.compactMap({ row in
            guard case let .text(value)? = row.value(named: "operation_id") else { return nil }
            return RuntimeExternalOperationID(rawValue: value)
        }) == plan.externalOperationIDs else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
    }

    static func loadCore(
        receiptID: RuntimeReceiptID,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCommittedReceiptCore {
        var budget = RuntimeReceiptDecodedByteBudget(
            maximumBytes: RuntimeCommittedReceiptReadBounds.maximumCoreRowBytes
        )
        return try loadCore(receiptID: receiptID, budget: &budget, database: database)
    }

    static func loadAuthenticatedGraph(
        receiptID: RuntimeReceiptID,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAuthenticatedReceiptGraph {
        let core = try loadCore(receiptID: receiptID, budget: &budget, database: database)
        return try authenticatePersistedCore(
            core,
            coreRowAuthenticated: true,
            budget: &budget,
            database: database
        )
    }

    enum CompensatingRemovalState {
        enum Authority: Equatable { case clear, unresolved, successorRequired }

        case missing
        case active
        case complete
        case failed

        var authority: Authority {
            switch self {
            case .complete: .clear
            case .active, .failed: .unresolved
            case .missing: .successorRequired
            }
        }

        var permitsSuccessorCreation: Bool { authority == .successorRequired }
        var requiresOperatorResolution: Bool { authority == .unresolved }
    }

    private static func classifyCompensatingRemoval(
        sourceOperationID: RuntimeExternalOperationID,
        sourceReference: RuntimeExternalProviderReference,
        sourceGraph: RuntimeAuthenticatedReceiptGraph,
        sourceState: RuntimeCanonicalExternalOperation,
        plan: RuntimeCommittedCompensationPlan,
        database: isolated SQLiteDatabase
    ) throws -> CompensatingRemovalState {
        let rows = try database.query(
            """
            SELECT operation_id FROM runtime_external_operation_creations
            WHERE source_operation_id = ? AND operation_action = 'compensate_removal'
            LIMIT 2
            """,
            bindings: [.text(sourceOperationID.rawValue)],
            maximumDecodedBytes: 4_096
        )
        guard rows.count <= 1 else { throw RuntimeCommittedReceiptAuthorityError.corruptAuthority }
        guard case let .text(rawID)? = rows.first?.value(named: "operation_id"),
              let operationID = RuntimeExternalOperationID(rawValue: rawID) else { return .missing }
        var budget = RuntimeExternalOperationDecodedByteBudget()
        guard let cancellation = try RuntimeExternalOperationGraphAuthority.loadAuthenticated(
            operationID: operationID, budget: &budget, database: database
        ), cancellation.creation.payload.action == .compensateRemoval,
        cancellation.creation.payload.sourceOperationID == sourceOperationID,
        cancellation.creation.payload.sourceProviderReference == sourceReference,
        cancellation.creation.payload.sourceReceiptID == sourceGraph.core.facts.receiptID,
        cancellation.creation.payload.compensationPlanID == plan.planID,
        cancellation.creation.payload.compensationPlanDigest == plan.digest,
        cancellation.creation.kind == sourceGraph.externalOperations.first(where: {
            $0.operationID == sourceOperationID
        })?.kind,
        cancellation.creation.providerID == sourceState.providerID,
        cancellation.creation.privacy == sourceGraph.core.facts.privacy.classification,
        cancellation.creation.localOnly else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        if cancellation.current.workflowStatus == .succeeded,
           cancellation.current.effectDisposition == .confirmedAbsent,
           let outcome = cancellation.attempts.last.flatMap({ cancellation.outcomes[$0.attemptID] }),
           outcome.kind == .confirmedCancellation || outcome.kind == .reconciledCancellationAbsent {
            return .complete
        }
        if cancellation.current.effectDisposition == .indeterminate ||
            [.pending, .claimed, .executing, .retryScheduled, .reconciliationRequired]
                .contains(cancellation.current.workflowStatus) {
            return .active
        }
        return .failed
    }

    static func externalCompensationAuthority(
        graph: RuntimeAuthenticatedReceiptGraph,
        plan: RuntimeCommittedCompensationPlan,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeExternalCompensationAuthority {
        try requireExternalOperationPlanParity(graph: graph, plan: plan)
        guard graph.externalOperationSchemaVersion ==
                runtimeCanonicalExternalOperationSchemaVersion else {
            return plan.externalOperationIDs.isEmpty
                ? .clear
                : .unresolved(operationIDs: plan.externalOperationIDs)
        }
        var unresolved: [RuntimeExternalOperationID] = []
        var requiresCompensation: [RuntimeExternalOperationID] = []
        for summary in graph.externalOperations {
            try Task.checkCancellation()
            guard let state = graph.externalOperationStates[summary.operationID],
                  state.workflowStatus == summary.workflowStatus,
                  state.effectDisposition == summary.effectDisposition,
                  summary.statusVersion == Optional(state.statusVersion),
                  summary.attemptCount == Optional(state.attemptCount),
                  RuntimeExternalOperationInvariant.valid(
                    status: summary.workflowStatus,
                    disposition: summary.effectDisposition
                  ) else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            if summary.effectDisposition == .indeterminate {
                unresolved.append(summary.operationID)
                continue
            }
            switch (summary.workflowStatus, summary.effectDisposition) {
            case (.succeeded, .confirmedPresent):
                guard let sourceReference = state.externalReference else {
                    throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
                }
                switch try classifyCompensatingRemoval(
                    sourceOperationID: summary.operationID,
                    sourceReference: sourceReference,
                    sourceGraph: graph,
                    sourceState: state,
                    plan: plan,
                    database: database
                ).authority {
                case .clear: break
                case .unresolved: unresolved.append(summary.operationID)
                case .successorRequired: requiresCompensation.append(summary.operationID)
                }
            case (.succeeded, .confirmedAbsent):
                requiresCompensation.append(summary.operationID)
            case (.permanentFailure, .notAttempted), (.permanentFailure, .confirmedAbsent),
                 (.cancelled, .notAttempted), (.cancelled, .confirmedAbsent),
                 (.pending, .notAttempted), (.retryScheduled, .confirmedAbsent),
                 (.retryScheduled, .notAttempted):
                break
            case (.claimed, .notAttempted), (.claimed, .confirmedAbsent),
                 (.executing, .notAttempted), (.executing, .confirmedAbsent):
                unresolved.append(summary.operationID)
            case (.operatorRequired, .indeterminate):
                unresolved.append(summary.operationID)
            default:
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
        }
        if unresolved.isEmpty == false { return .unresolved(operationIDs: unresolved) }
        if requiresCompensation.isEmpty == false {
            return .externalCompensationRequired(operationIDs: requiresCompensation)
        }
        return .clear
    }

    static func prepareExternalOperationsForCompensation(
        graph: RuntimeAuthenticatedReceiptGraph,
        plan: RuntimeCommittedCompensationPlan,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeExternalCompensationAuthority {
        try requireExternalOperationPlanParity(graph: graph, plan: plan)
        guard graph.externalOperationSchemaVersion ==
                runtimeCanonicalExternalOperationSchemaVersion else {
            return plan.externalOperationIDs.isEmpty
                ? .clear
                : .unresolved(operationIDs: plan.externalOperationIDs)
        }

        var cancellable: [RuntimeCanonicalExternalOperation] = []
        var unresolved: [RuntimeExternalOperationID] = []
        var requiresCompensation: [RuntimeExternalOperationID] = []
        for summary in graph.externalOperations {
            try Task.checkCancellation()
            guard let expected = graph.externalOperationStates[summary.operationID],
                  expected.workflowStatus == summary.workflowStatus,
                  expected.effectDisposition == summary.effectDisposition,
                  summary.statusVersion == Optional(expected.statusVersion),
                  summary.attemptCount == Optional(expected.attemptCount),
                  RuntimeExternalOperationInvariant.valid(
                    status: summary.workflowStatus,
                    disposition: summary.effectDisposition
                  ) else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            if summary.effectDisposition == .indeterminate {
                unresolved.append(summary.operationID)
                continue
            }
            switch (summary.workflowStatus, summary.effectDisposition) {
            case (.pending, .notAttempted), (.retryScheduled, .confirmedAbsent),
                 (.retryScheduled, .notAttempted):
                cancellable.append(expected)
            case (.succeeded, .confirmedPresent):
                guard let sourceReference = expected.externalReference else {
                    throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
                }
                switch try classifyCompensatingRemoval(
                    sourceOperationID: summary.operationID,
                    sourceReference: sourceReference,
                    sourceGraph: graph,
                    sourceState: expected,
                    plan: plan,
                    database: database
                ).authority {
                case .clear: break
                case .unresolved: unresolved.append(summary.operationID)
                case .successorRequired: requiresCompensation.append(summary.operationID)
                }
            case (.succeeded, .confirmedAbsent):
                requiresCompensation.append(summary.operationID)
            case (.permanentFailure, .notAttempted), (.permanentFailure, .confirmedAbsent),
                 (.cancelled, .notAttempted), (.cancelled, .confirmedAbsent):
                break
            case (.claimed, .notAttempted), (.claimed, .confirmedAbsent),
                 (.executing, .notAttempted), (.executing, .confirmedAbsent):
                unresolved.append(summary.operationID)
            default:
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
        }
        if unresolved.isEmpty == false { return .unresolved(operationIDs: unresolved) }
        if requiresCompensation.isEmpty == false {
            return .externalCompensationRequired(operationIDs: requiresCompensation)
        }

        for expected in cancellable {
            try Task.checkCancellation()
            let cancelled: RuntimeCanonicalExternalOperation
            do {
                cancelled = try CanonicalRuntimeExternalOperationStore.cancelForCompensation(
                    expected: expected,
                    at: now,
                    database: database
                )
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            guard cancelled.operationID == expected.operationID,
                  cancelled.workflowStatus == .cancelled,
                  cancelled.effectDisposition == expected.effectDisposition,
                  cancelled.statusVersion == expected.statusVersion + 1 else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
        }
        return .clear
    }

    private static func requireExternalOperationPlanParity(
        graph: RuntimeAuthenticatedReceiptGraph,
        plan: RuntimeCommittedCompensationPlan
    ) throws {
        let operationIDs = graph.externalOperations.map(\.operationID)
        guard graph.core.facts.receiptID == plan.sourceReceiptID,
              graph.plan == plan,
              operationIDs == plan.externalOperationIDs,
              operationIDs == operationIDs.sorted(),
              Set(operationIDs).count == operationIDs.count,
              (graph.externalOperationSchemaVersion == 6 ||
                graph.externalOperationStates.count == operationIDs.count) else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
    }

    static func loadCore(
        receiptID: RuntimeReceiptID,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCommittedReceiptCore {
        let rows = try budget.query(
            """
            SELECT c.command_id, c.terminal_event_sequence, c.terminal_event_id,
                   c.terminal_event_hash, c.correlation_id, c.privacy, c.local_only,
                   c.core_version, c.core_digest, c.confirmation_token,
                   c.confirmation_decision_digest, c.payload, c.payload_checksum,
                   c.created_at_ms AS core_created_at_ms,
                   r.receipt_id AS anchor_receipt_id,
                   r.preparation_id AS anchor_preparation_id,
                   r.command_id AS anchor_command_id,
                   r.terminal_event_sequence AS anchor_event_sequence,
                   r.receipt_version AS anchor_version,
                   r.created_at_ms AS anchor_created_at_ms
            FROM runtime_committed_receipt_cores AS c
            JOIN runtime_commit_receipts AS r ON r.receipt_id = c.receipt_id
            WHERE c.receipt_id = ? LIMIT 2
            """,
            bindings: [.text(receiptID.rawValue)],
            database: database
        )
        guard rows.count == 1, let row = rows.first,
              case let .blob(bytes)? = row.value(named: "payload"),
              bytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
              case let .text(checksum)? = row.value(named: "payload_checksum") else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        do {
            let core = try RuntimeCommittedReceiptCodec.decodeCore(bytes, storedChecksum: checksum)
            guard core.facts.receiptID == receiptID,
                  row.value(named: "command_id") == .text(core.facts.commandID.rawValue),
                  row.value(named: "terminal_event_sequence") == .integer(
                      try int64(core.facts.lineage.eventSequence)
                  ),
                  row.value(named: "terminal_event_id") == .text(core.facts.lineage.eventID.rawValue),
                  row.value(named: "terminal_event_hash") == .text(core.facts.lineage.eventHash),
                  row.value(named: "correlation_id") == .text(core.facts.correlationID.rawValue),
                  row.value(named: "privacy") == .text(core.facts.privacy.classification.rawValue),
                  row.value(named: "local_only") == .integer(core.facts.privacy.localOnly ? 1 : 0),
                  row.value(named: "core_version") == .integer(Int64(core.facts.version)),
                  row.value(named: "core_digest") == .text(core.receiptDigest),
                  row.value(named: "confirmation_token") == (
                      core.facts.confirmationToken.map { SQLiteValue.text($0.rawValue) } ?? .null
                  ),
                  row.value(named: "confirmation_decision_digest") == (
                      core.facts.confirmationDecisionDigest.map {
                          SQLiteValue.text($0.rawValue)
                      } ?? .null
                  ),
                  row.value(named: "core_created_at_ms") == .integer(
                      try milliseconds(core.facts.committedAt)
                  ),
                  row.value(named: "anchor_receipt_id") == .text(core.facts.receiptID.rawValue),
                  row.value(named: "anchor_preparation_id") == .text(core.facts.preparationID.rawValue),
                  row.value(named: "anchor_command_id") == .text(core.facts.commandID.rawValue),
                  row.value(named: "anchor_event_sequence") == .integer(
                      try int64(core.facts.lineage.eventSequence)
                  ),
                  row.value(named: "anchor_version") == .integer(Int64(runtimeCommitAnchorVersion)),
                  row.value(named: "anchor_created_at_ms") == .integer(
                      try milliseconds(core.facts.committedAt)
                  ) else {
                throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
            }
            return core
        } catch is CancellationError {
            throw CancellationError()
        } catch RuntimeCommittedReceiptCodecError.futureVersion {
            throw RuntimeCommittedReceiptAuthorityError.sourceBlocked(.futureReceiptVersion)
        } catch {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
    }

    static func loadPlan(
        planID: RuntimeRollbackPlanID,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCommittedCompensationPlan {
        var budget = RuntimeReceiptDecodedByteBudget(
            maximumBytes: RuntimeCommittedReceiptReadBounds.maximumPlanRowBytes
        )
        return try loadPlan(planID: planID, budget: &budget, database: database)
    }

    static func loadPlan(
        planID: RuntimeRollbackPlanID,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCommittedCompensationPlan {
        let rows = try budget.query(
            "SELECT payload, payload_checksum FROM runtime_compensation_plans WHERE plan_id = ? LIMIT 2",
            bindings: [.text(planID.rawValue)],
            database: database
        )
        guard rows.count == 1, let row = rows.first,
              case let .blob(bytes)? = row.value(named: "payload"),
              bytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
              case let .text(checksum)? = row.value(named: "payload_checksum"),
              RuntimeStoreManifestCodec.isSHA256Hex(checksum),
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == checksum else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        do {
            return try RuntimeCommittedReceiptCodec.decodePlan(bytes, storedChecksum: checksum)
        } catch is CancellationError {
            throw CancellationError()
        } catch RuntimeCommittedReceiptCodecError.futureVersion {
            throw RuntimeCommittedReceiptAuthorityError.sourceBlocked(.futureCompensationPlanVersion)
        } catch {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
    }

    private static func decodeCanonical<Value: Codable>(
        _ type: Value.Type,
        bytes: Data
    ) throws -> Value {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let value = try decoder.decode(type, from: bytes)
        guard try RuntimeCommittedReceiptCodec.encode(value) == bytes else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        return value
    }

    private static func milliseconds(_ value: Date) throws -> Int64 {
        let milliseconds = value.timeIntervalSince1970 * 1_000
        guard milliseconds.isFinite, milliseconds >= 0,
              milliseconds.rounded(.towardZero) == milliseconds,
              milliseconds < Double(Int64.max) else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        return Int64(milliseconds)
    }

    private static func int64(_ value: UInt64) throws -> Int64 {
        guard value <= UInt64(Int64.max) else {
            throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
        }
        return Int64(value)
    }
}
