import Foundation

enum RuntimeCommittedReceiptCodecError: Error, Sendable, Equatable {
    case corrupt
    case futureVersion
    case nonCanonical
    case digestMismatch
}

enum RuntimeCommittedReceiptCodec {
    static func makeCore(_ facts: RuntimeCommittedReceiptCoreFacts) throws -> RuntimeCommittedReceiptCore {
        guard facts.version == runtimeCommittedReceiptCoreVersion else {
            throw RuntimeCommittedReceiptCodecError.futureVersion
        }
        let normalized = try normalizedFacts(facts)
        let core = RuntimeCommittedReceiptCore(
            facts: normalized,
            receiptDigest: LocalRuntimeStorageChecksum.sha256Hex(for: try encode(normalized))
        )
        guard try encode(core).count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes else {
            throw RuntimeCommittedReceiptCodecError.corrupt
        }
        return core
    }

    static func encode<Value: Encodable>(_ value: Value) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(value)
    }

    static func decodeCore(_ bytes: Data, storedChecksum: String) throws -> RuntimeCommittedReceiptCore {
        guard bytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
              RuntimeStoreManifestCodec.isSHA256Hex(storedChecksum),
              storedChecksum == LocalRuntimeStorageChecksum.sha256Hex(for: bytes) else {
            throw RuntimeCommittedReceiptCodecError.digestMismatch
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let core: RuntimeCommittedReceiptCore
        do { core = try decoder.decode(RuntimeCommittedReceiptCore.self, from: bytes) }
        catch { throw RuntimeCommittedReceiptCodecError.corrupt }
        guard core.facts.version <= runtimeCommittedReceiptCoreVersion else {
            throw RuntimeCommittedReceiptCodecError.futureVersion
        }
        guard core.facts.version == runtimeCommittedReceiptCoreVersion,
              try encode(core) == bytes,
              core.receiptDigest == LocalRuntimeStorageChecksum.sha256Hex(for: try encode(core.facts)),
              try normalizedFacts(core.facts) == core.facts else {
            throw RuntimeCommittedReceiptCodecError.nonCanonical
        }
        return core
    }

    static func makePlan(
        planID: RuntimeRollbackPlanID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference,
        correlationID: RuntimeCorrelationID,
        action: RuntimeSemanticCompensationAction,
        targets: [RuntimeCompensationTargetExpectation],
        externalOperationIDs: [RuntimeExternalOperationID],
        privacy: RuntimeCommittedReceiptPrivacy,
        policyVersion: Int,
        expiresAt: Date,
        requiresConfirmation: Bool
    ) throws -> RuntimeCommittedCompensationPlan {
        struct DigestFacts: Codable {
            let version: Int
            let planID: RuntimeRollbackPlanID
            let receiptID: RuntimeReceiptID
            let lineage: RuntimeAuthorityLineageReference
            let correlationID: RuntimeCorrelationID
            let action: RuntimeSemanticCompensationAction
            let targets: [RuntimeCompensationTargetExpectation]
            let externalOperationIDs: [RuntimeExternalOperationID]
            let privacy: RuntimeCommittedReceiptPrivacy
            let policyVersion: Int
            let expiresAt: Date
            let requiresConfirmation: Bool
        }
        try Task.checkCancellation()
        guard targets.isEmpty == false,
              targets.count <= RuntimeCompensationLimits.maximumTargets,
              externalOperationIDs.count <= RuntimeCompensationLimits.maximumExternalOperations,
              Set(externalOperationIDs).count == externalOperationIDs.count else {
            throw RuntimeCommittedReceiptCodecError.corrupt
        }
        for target in targets {
            try Task.checkCancellation()
            guard target.aggregate.kind == action.aggregateKind,
                  target.sourcePriorRevision == nil,
                  target.sourceTransition == .create,
                  target.requiredLifecycle == .active,
                  target.requiredCurrentRevision == target.sourceRevision,
                  target.inverseTransition == action.transition,
                  RuntimeStoreManifestCodec.isSHA256Hex(target.sourceStateDigest) else {
                throw RuntimeCommittedReceiptCodecError.corrupt
            }
        }
        let orderedTargets = targets.sorted()
        let orderedOperations = externalOperationIDs.sorted { $0.rawValue < $1.rawValue }
        guard Set(orderedTargets.map {
                  "\($0.aggregate.kind.rawValue)\u{0}\($0.aggregate.id.rawValue)"
              }).count == orderedTargets.count,
              orderedTargets.allSatisfy({ target in
                  target.aggregate.kind == action.aggregateKind &&
                      target.sourcePriorRevision == nil &&
                      target.sourceTransition == .create &&
                      target.requiredLifecycle == .active &&
                      target.requiredCurrentRevision == target.sourceRevision &&
                      target.inverseTransition == action.transition &&
                      RuntimeStoreManifestCodec.isSHA256Hex(target.sourceStateDigest)
              }),
              orderedTargets.contains(where: {
                  $0.aggregate.kind == action.aggregateKind &&
                      $0.aggregate.id.rawValue == action.primaryObjectID.rawValue
              }) else {
            throw RuntimeCommittedReceiptCodecError.corrupt
        }
        let normalizedExpiry = normalizedDate(expiresAt)
        let facts = DigestFacts(
            version: runtimeCompensationPlanVersion, planID: planID, receiptID: receiptID,
            lineage: lineage, correlationID: correlationID, action: action, targets: orderedTargets,
            externalOperationIDs: orderedOperations, privacy: privacy,
            policyVersion: policyVersion, expiresAt: normalizedExpiry,
            requiresConfirmation: requiresConfirmation
        )
        return RuntimeCommittedCompensationPlan(
            version: runtimeCompensationPlanVersion, planID: planID,
            sourceReceiptID: receiptID, sourceLineage: lineage,
            sourceCorrelationID: correlationID, action: action,
            targets: orderedTargets, externalOperationIDs: orderedOperations,
            privacy: privacy, policyVersion: policyVersion, expiresAt: normalizedExpiry,
            requiresConfirmation: requiresConfirmation,
            digest: LocalRuntimeStorageChecksum.sha256Hex(for: try encode(facts))
        )
    }

    static func validatePlan(_ plan: RuntimeCommittedCompensationPlan) throws {
        let rebuilt = try makePlan(
            planID: plan.planID, receiptID: plan.sourceReceiptID, lineage: plan.sourceLineage,
            correlationID: plan.sourceCorrelationID,
            action: plan.action, targets: plan.targets,
            externalOperationIDs: plan.externalOperationIDs, privacy: plan.privacy,
            policyVersion: plan.policyVersion, expiresAt: plan.expiresAt,
            requiresConfirmation: plan.requiresConfirmation
        )
        guard rebuilt == plan else { throw RuntimeCommittedReceiptCodecError.digestMismatch }
    }

    static func decodePlan(
        _ bytes: Data,
        storedChecksum: String
    ) throws -> RuntimeCommittedCompensationPlan {
        guard bytes.count <= RuntimeCommittedReceiptReadBounds.maximumPersistedPayloadBytes,
              RuntimeStoreManifestCodec.isSHA256Hex(storedChecksum),
              storedChecksum == LocalRuntimeStorageChecksum.sha256Hex(for: bytes) else {
            throw RuntimeCommittedReceiptCodecError.digestMismatch
        }
        struct VersionProbe: Decodable { let version: Int }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let version: Int
        do { version = try decoder.decode(VersionProbe.self, from: bytes).version }
        catch { throw RuntimeCommittedReceiptCodecError.corrupt }
        guard version <= runtimeCompensationPlanVersion else {
            throw RuntimeCommittedReceiptCodecError.futureVersion
        }
        guard version == runtimeCompensationPlanVersion else {
            throw RuntimeCommittedReceiptCodecError.nonCanonical
        }
        let plan: RuntimeCommittedCompensationPlan
        do { plan = try decoder.decode(RuntimeCommittedCompensationPlan.self, from: bytes) }
        catch { throw RuntimeCommittedReceiptCodecError.corrupt }
        guard try encode(plan) == bytes else {
            throw RuntimeCommittedReceiptCodecError.nonCanonical
        }
        try validatePlan(plan)
        return plan
    }

    static func evidenceDigest(
        _ evidence: RuntimeIrreversibilityEvidence,
        sourceReceiptID: RuntimeReceiptID,
        sourceLineage: RuntimeAuthorityLineageReference
    ) throws -> String {
        let semanticReasons: Set<RuntimeIrreversibilityReason> = [
            .destructiveErasure, .compensationOfCompensation,
        ]
        guard evidence.version == 1,
              (evidence.permanence == .semantic) == semanticReasons.contains(evidence.reason),
              evidence.commandFamily.isEmpty == false,
              evidence.commandAction.isEmpty == false else {
            throw RuntimeCommittedReceiptCodecError.corrupt
        }
        struct SourceBoundEvidence: Codable {
            let evidence: RuntimeIrreversibilityEvidence
            let sourceReceiptID: RuntimeReceiptID
            let sourceLineage: RuntimeAuthorityLineageReference
        }
        return LocalRuntimeStorageChecksum.sha256Hex(for: try encode(SourceBoundEvidence(
            evidence: evidence,
            sourceReceiptID: sourceReceiptID,
            sourceLineage: sourceLineage
        )))
    }

    private static func normalizedFacts(
        _ facts: RuntimeCommittedReceiptCoreFacts
    ) throws -> RuntimeCommittedReceiptCoreFacts {
        let objects = facts.objects.sorted()
        let artifacts = facts.artifacts.sorted()
        let presentationFacts = Array(Set(facts.presentationFacts)).sorted()
        let retention = facts.retention.map {
            RuntimeReceiptRetentionReference(
                kind: $0.kind,
                stableID: $0.stableID,
                retainUntil: $0.retainUntil.map(normalizedDate)
            )
        }.sorted()
        guard objects.isEmpty == false,
              objects.count <= RuntimeCommittedReceiptLimits.maximumObjects,
              artifacts.count <= RuntimeCommittedReceiptLimits.maximumArtifacts,
              presentationFacts.count <= RuntimeCommittedReceiptLimits.maximumPresentationFacts,
              retention.count <= RuntimeCommittedReceiptLimits.maximumRetentionReferences,
              Set(objects.map { "\($0.aggregate.kind.rawValue)\u{0}\($0.aggregate.id.rawValue)" }).count == objects.count,
              Set(artifacts.map { "\($0.kind.rawValue)\u{0}\($0.stableID)" }).count == artifacts.count,
              Set(retention.map { "\($0.kind.rawValue)\u{0}\($0.stableID)" }).count == retention.count,
              objects.allSatisfy({ RuntimeStoreManifestCodec.isSHA256Hex($0.stateDigest) }),
              artifacts.allSatisfy({ $0.digest.map(RuntimeStoreManifestCodec.isSHA256Hex) ?? true }),
              facts.privacy.localOnly,
              (facts.confirmationToken == nil) == (facts.confirmationDecisionDigest == nil) else {
            throw RuntimeCommittedReceiptCodecError.corrupt
        }
        return RuntimeCommittedReceiptCoreFacts(
            version: facts.version, receiptID: facts.receiptID,
            preparationID: facts.preparationID, commandID: facts.commandID,
            lineage: facts.lineage, correlationID: facts.correlationID,
            outcome: facts.outcome, committedAt: normalizedDate(facts.committedAt),
            privacy: facts.privacy, objects: objects, artifacts: artifacts,
            presentationFacts: presentationFacts, compensation: facts.compensation,
            retention: retention, confirmationToken: facts.confirmationToken,
            confirmationDecisionDigest: facts.confirmationDecisionDigest
        )
    }

    private static func normalizedDate(_ value: Date) -> Date {
        Date(timeIntervalSince1970: floor(value.timeIntervalSince1970 * 1_000) / 1_000)
    }
}
