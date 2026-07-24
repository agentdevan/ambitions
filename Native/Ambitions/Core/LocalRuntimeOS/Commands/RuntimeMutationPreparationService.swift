import CryptoKit
import Foundation

struct RuntimeMutationPreparationService: RuntimeMutationPreparing, Sendable {
    let reader: any RuntimePreparationReading
    let router: RuntimeFeatureMutationRouter
    let validator: AmbitionsCommandValidator

    init(
        reader: any RuntimePreparationReading,
        router: RuntimeFeatureMutationRouter = RuntimeFeatureMutationRouter(),
        validator: AmbitionsCommandValidator = AmbitionsCommandValidator()
    ) {
        self.reader = reader
        self.router = router
        self.validator = validator
    }

    func prepare(_ command: AmbitionsCommand, context: RuntimePreparationContext) async -> RuntimePreparationOutcome {
        guard context.issuedAt < context.expiresAt,
              let commandID = RuntimeCommandID(rawValue: command.id),
              commandID.rawValue == command.id,
              let commandFingerprint = RuntimePreparationDigest.command(command),
              let decisionDigestSeed = RuntimePreparationDigest.value(command.typedPayload) else {
            return blocked(
                commandID: command.id,
                reason: .identityMismatch,
                target: command.target
            )
        }
        let validation = validator.validate(command)
        guard validation == .valid || validation == .needsConfirmation else {
            let reason: RuntimeRecoveryReason = validation == .unsupportedInThisBuild
                ? .unsupportedInput
                : .invalidSemanticInput
            return validation == .unsupportedInThisBuild
                ? unsupported(commandID: command.id, reason: reason, target: command.target)
                : blocked(commandID: command.id, reason: reason, target: command.target)
        }

        let request = RuntimePreparationReadRequest(
            commandID: commandID,
            targetIDs: command.target.runtimePreparationObjectIDs,
            expectedRevision: command.expectedRevision,
            privacy: command.privacy
        )
        let snapshot: RuntimePreparationSnapshot
        do {
            snapshot = try await reader.read(request)
        } catch {
            return blocked(commandID: command.id, reason: .snapshotReadFailed, target: command.target)
        }
        let input = RuntimeFeatureReducerInput(
            command: command,
            commandID: commandID,
            snapshot: snapshot,
            context: context
        )
        guard let decision = router.reduce(input) else {
            return unsupported(commandID: command.id, reason: .missingHandler, target: command.target)
        }
        guard decision.disposition != .unsupported else {
            return unsupported(commandID: command.id, reason: decision.reason ?? .unsupportedInput, target: command.target)
        }
        guard decision.disposition != .blocked else {
            return blocked(commandID: command.id, reason: decision.reason ?? .invalidSemanticInput, target: command.target)
        }
        if validation == .needsConfirmation, decision.confirmationScope == nil {
            return blocked(commandID: command.id, reason: .invalidSemanticInput, target: command.target)
        }

        let authorization = RuntimePreparationAuthorizer().authorize(
            command: command,
            snapshot: snapshot,
            decision: decision,
            boundary: context.boundary
        )
        guard authorization.isAuthorized else {
            let reason = authorization.reasonCodes.first ?? .authorityRejected
            return blocked(commandID: command.id, reason: reason, target: command.target)
        }
        guard let decisionDigest = RuntimePreparationDigest.decision(
            commandPayloadDigest: decisionDigestSeed,
            decision: decision,
            preparationID: context.preparationID
        ) else {
            return blocked(commandID: command.id, reason: .identityMismatch, target: command.target)
        }
        let confirmationRequest = decision.confirmationScope.map { scope in
            RuntimeConfirmationRequest(
                token: context.confirmationToken,
                preparationID: context.preparationID,
                commandID: commandID,
                commandFingerprint: commandFingerprint,
                actor: command.actor,
                scope: scope,
                target: command.target,
                decisionDigest: decisionDigest,
                issuedAt: context.issuedAt,
                expiresAt: context.expiresAt,
                oneUse: true
            )
        }
        let preparation = RuntimePreparation(
            preparationID: context.preparationID,
            command: command,
            commandID: commandID,
            commandFingerprint: commandFingerprint,
            commandVersion: runtimeCommandSchemaVersion,
            decision: decision,
            decisionDigest: decisionDigest,
            authorization: authorization,
            confirmationRequest: confirmationRequest,
            issuedAt: context.issuedAt,
            expiresAt: context.expiresAt,
            schemaVersion: runtimePreparationSchemaVersion
        )
        return confirmationRequest == nil ? .ready(preparation) : .requiresConfirmation(preparation)
    }

    func prepare(_ bytes: Data, context: RuntimePreparationContext) async -> RuntimePreparationOutcome {
        switch RuntimeCommandCodec().decode(bytes) {
        case let .supported(command, _):
            return await prepare(command, context: context)
        case let .unsupported(value), let .corrupt(value):
            return .unsupported(RuntimePreparationFailure(
                commandID: nil,
                reason: .unsupportedInput,
                recovery: .inspect(.unsupportedInput),
                originalBytes: value.originalBytes
            ))
        }
    }

    private func blocked(
        commandID: String?,
        reason: RuntimeRecoveryReason,
        target: AmbitionsCommandTarget
    ) -> RuntimePreparationOutcome {
        .blocked(RuntimePreparationFailure(
            commandID: commandID,
            reason: reason,
            recovery: .inspect(reason, target: target),
            originalBytes: nil
        ))
    }

    private func unsupported(
        commandID: String?,
        reason: RuntimeRecoveryReason,
        target: AmbitionsCommandTarget
    ) -> RuntimePreparationOutcome {
        .unsupported(RuntimePreparationFailure(
            commandID: commandID,
            reason: reason,
            recovery: .inspect(reason, target: target),
            originalBytes: nil
        ))
    }
}

struct RuntimePreparationAuthorizer: Sendable {
    func authorize(
        command: AmbitionsCommand,
        snapshot: RuntimePreparationSnapshot,
        decision: RuntimeReducerDecision,
        boundary: PrivateLifeRuntimeBoundary
    ) -> RuntimePreparationAuthorization {
        let privacyBoundary = PrivacyBoundary.forCommand(command, boundary: boundary)
        var reasons: [RuntimeRecoveryReason] = []
        if privacyBoundary.isSatisfied == false || snapshot.privacy != command.privacy {
            reasons.append(.privacyDenied)
        }
        if revisionMatches(expected: command.expectedRevision, observed: snapshot.observedRevision) == false {
            reasons.append(.revisionMismatch)
        }
        let targetIDs = command.target.runtimePreparationObjectIDs
        let readIDs = decision.readSet.objects.map(\.objectID)
        if readIDs != targetIDs {
            reasons.append(.identityMismatch)
        }
        for dependency in decision.readSet.objects {
            let snapshotRevision = snapshot.objectRevisions[dependency.objectID] ?? .absent
            if dependency.expectedRevision != command.expectedRevision ||
                dependency.observedRevision != snapshotRevision {
                reasons.append(.identityMismatch)
            }
            if revisionMatches(expected: command.expectedRevision, observed: dependency.observedRevision) == false {
                reasons.append(.revisionMismatch)
            }
        }
        if requiresExactRevision(command), case .absent = command.expectedRevision {
            reasons.append(.revisionMismatch)
        }
        if actorIsAllowed(command) == false { reasons.append(.actorDenied) }
        let sideEffectPolicy: CommandSideEffectPolicy
        switch decision.writeSet.externalEffect {
        case .none: sideEffectPolicy = .localOnly
        case .outbox: sideEffectPolicy = .outboxRequired
        }
        if case .outbox = decision.writeSet.externalEffect, decision.confirmationScope == nil {
            reasons.append(.confirmationRequired)
        }
        if decision.confirmationScope == .legacyCalendarCompatibility,
           RuntimeLegacyCalendarCompatibilityPolicy().allows(command: command, decision: decision) == false {
            reasons.append(.identityMismatch)
        }
        let ordered = Array(Set(reasons)).sorted { $0.rawValue < $1.rawValue }
        return RuntimePreparationAuthorization(
            state: ordered.isEmpty ? .authorized : .denied,
            actor: command.actor,
            source: command.source,
            expectedRevision: command.expectedRevision,
            observedRevision: snapshot.observedRevision,
            privacyBoundary: privacyBoundary,
            sideEffectPolicy: sideEffectPolicy,
            reasonCodes: ordered
        )
    }

    func revisionMatches(expected: RuntimeExpectedRevision, observed: RuntimeExpectedRevision) -> Bool {
        switch (expected, observed) {
        case (.absent, .absent): true
        case let (.exact(expected), .exact(observed)): expected == observed
        default: false
        }
    }

    private func actorIsAllowed(_ command: AmbitionsCommand) -> Bool {
        switch command.actor {
        case .user: return true
        case .system:
            if case let .importDeletion(value) = command.typedPayload {
                return value.action != .deleteObject && value.action != .forgetMemory && value.action != .performExport
            }
            return true
        case .externalSurface:
            if case let .capture(capture) = command.typedPayload,
               case .quickCapture = capture.action { return true }
            return false
        }
    }

    private func requiresExactRevision(_ command: AmbitionsCommand) -> Bool {
        guard case let .importDeletion(value) = command.typedPayload else { return false }
        return value.action == .deleteObject || value.action == .forgetMemory
    }
}

struct RuntimeLegacyCalendarCompatibilityPolicy: Sendable {
    func allows(command: AmbitionsCommand, decision: RuntimeReducerDecision) -> Bool {
        guard command.schemaVersion == ambitionsCommandSchemaVersion,
              command.localOnly,
              decision.confirmationScope == .legacyCalendarCompatibility,
              decision.writeSet.externalEffect == .none,
              case let .schedule(schedule) = command.typedPayload,
              case let .calendarWrite(intent) = schedule.action else { return false }
        switch intent.operationIdentityProvenance {
        case .currentRequired:
            return false
        case .legacyExplicit:
            return intent.operationID != nil
        case .legacyAbsent:
            return intent.operationID == nil
        }
    }
}

enum RuntimePreparationDigest {
    static func command(_ command: AmbitionsCommand) -> RuntimeCommandFingerprint? {
        guard let record = try? RuntimeJournalCommandRecord(command: command) else { return nil }
        return value(record)
    }

    static func value<Value: Encodable>(_ value: Value) -> RuntimeCommandFingerprint? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        guard let bytes = try? encoder.encode(value) else { return nil }
        let raw = SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
        return RuntimeCommandFingerprint(rawValue: raw)
    }

    static func decision(
        commandPayloadDigest: RuntimeCommandFingerprint,
        decision: RuntimeReducerDecision,
        preparationID: RuntimePreparationID
    ) -> RuntimeCommandFingerprint? {
        guard let reducerDigest = value(decision) else { return nil }
        return value([commandPayloadDigest.rawValue, reducerDigest.rawValue, preparationID.rawValue])
    }
}

struct RuntimeMutationSubmissionService: RuntimeMutationSubmitting, Sendable {
    let reader: any RuntimePreparationReading
    let authority: any RuntimeMutationAuthorityAccepting
    let clock: RuntimeClockClient

    func commit(
        _ preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?
    ) async -> RuntimeCommandOutcome {
        let now = clock.now
        if let inconsistency = preparationInconsistency(preparation) {
            return inconsistency == .unsupportedInput
                ? unsupported(preparation, reason: inconsistency)
                : blocked(preparation, reason: inconsistency)
        }
        guard now >= preparation.issuedAt else {
            return blocked(preparation, reason: .confirmationMismatch)
        }
        guard now <= preparation.expiresAt else {
            return blocked(preparation, reason: .confirmationExpired)
        }
        if let request = preparation.confirmationRequest {
            guard let confirmation else { return blocked(preparation, reason: .confirmationRequired) }
            guard confirmation.decision == .approved else {
                return blocked(preparation, reason: .confirmationRejected)
            }
            guard confirmation.token == request.token,
                  confirmation.preparationID == request.preparationID,
                  confirmation.commandID == request.commandID,
                  confirmation.commandFingerprint == request.commandFingerprint,
                  confirmation.actor == request.actor,
                  confirmation.scope == request.scope,
                  confirmation.target == request.target,
                  confirmation.decisionDigest == request.decisionDigest,
                  confirmation.decidedAt >= request.issuedAt,
                  confirmation.decidedAt <= request.expiresAt else {
                return blocked(preparation, reason: .confirmationMismatch)
            }
        } else if confirmation != nil {
            return blocked(preparation, reason: .confirmationMismatch)
        }
        if preparation.decision.disposition == .unchanged {
            return .unchanged(RuntimeTerminalResult(
                preparationID: preparation.preparationID,
                commandID: preparation.commandID.rawValue,
                reason: preparation.decision.reason ?? .noMutation,
                recovery: preparation.decision.recovery
            ))
        }
        let request = RuntimePreparationReadRequest(
            commandID: preparation.commandID,
            targetIDs: preparation.command.target.runtimePreparationObjectIDs,
            expectedRevision: preparation.command.expectedRevision,
            privacy: preparation.command.privacy
        )
        let snapshot: RuntimePreparationSnapshot
        do {
            snapshot = try await reader.read(request)
        } catch {
            return failed(preparation, reason: .snapshotReadFailed)
        }
        guard snapshot.privacy == preparation.decision.readSet.privacy else {
            return blocked(preparation, reason: .privacyDenied)
        }
        guard snapshot.observedRevision == preparation.authorization.observedRevision,
              revisionsRemainCurrent(
                  preparation.decision.readSet,
                  expectedRevision: preparation.command.expectedRevision,
                  snapshot: snapshot
              ) else {
            return blocked(preparation, reason: .staleAfterPreparation)
        }
        guard RuntimePreparationDigest.command(preparation.command) == preparation.commandFingerprint else {
            return blocked(preparation, reason: .identityMismatch)
        }

        switch await authority.accept(preparation, confirmation: confirmation) {
        case let .committed(committed):
            guard committed.preparationID == preparation.preparationID,
                  committed.commandID == preparation.commandID else {
                return failed(preparation, reason: .authorityFailed)
            }
            return .changed(committed)
        case let .unchanged(recovery):
            return .unchanged(terminal(preparation, recovery: recovery))
        case let .rejected(recovery):
            return .blocked(terminal(preparation, recovery: recovery))
        case let .failed(recovery):
            return .failed(terminal(preparation, recovery: recovery))
        case let .unsupported(recovery):
            return .unsupported(terminal(preparation, recovery: recovery))
        }
    }

    private func revisionsRemainCurrent(
        _ readSet: RuntimeMutationReadSet,
        expectedRevision: RuntimeExpectedRevision,
        snapshot: RuntimePreparationSnapshot
    ) -> Bool {
        readSet.objects.allSatisfy { dependency in
            dependency.expectedRevision == expectedRevision &&
                RuntimePreparationAuthorizer().revisionMatches(
                    expected: expectedRevision,
                    observed: dependency.observedRevision
                ) &&
                (snapshot.objectRevisions[dependency.objectID] ?? .absent) == dependency.observedRevision
        }
    }

    private func preparationInconsistency(_ preparation: RuntimePreparation) -> RuntimeRecoveryReason? {
        guard preparation.schemaVersion == runtimePreparationSchemaVersion,
              preparation.commandVersion == runtimeCommandSchemaVersion else {
            return .unsupportedInput
        }
        let command = preparation.command
        guard preparation.commandID.rawValue == command.id,
              RuntimePreparationDigest.command(command) == preparation.commandFingerprint,
              let payloadDigest = RuntimePreparationDigest.value(command.typedPayload),
              RuntimePreparationDigest.decision(
                commandPayloadDigest: payloadDigest,
                decision: preparation.decision,
                preparationID: preparation.preparationID
              ) == preparation.decisionDigest,
              preparation.issuedAt < preparation.expiresAt else {
            return .identityMismatch
        }
        let authorization = preparation.authorization
        guard authorization.state == .authorized,
              authorization.reasonCodes.isEmpty else { return .authorityRejected }
        guard authorization.actor == command.actor,
              authorization.source == command.source,
              authorization.expectedRevision == command.expectedRevision,
              authorization.privacyBoundary.privacy == command.privacy,
              authorization.privacyBoundary.localOnly,
              authorization.privacyBoundary.isSatisfied,
              command.localOnly,
              preparation.decision.readSet.privacy == command.privacy else {
            return .privacyDenied
        }
        guard RuntimePreparationAuthorizer().revisionMatches(
            expected: command.expectedRevision,
            observed: authorization.observedRevision
        ) else {
            return .identityMismatch
        }
        let feature = RuntimeFeatureMutationRouter().feature(for: command.typedPayload)
        guard preparation.decision.family == feature.rawValue,
              preparation.decision.action == command.typedPayload.diagnosticCase,
              preparation.decision.readSet.objects.map(\.objectID) == command.target.runtimePreparationObjectIDs,
              preparation.decision.readSet.objects.allSatisfy({ dependency in
                  dependency.expectedRevision == command.expectedRevision &&
                      RuntimePreparationAuthorizer().revisionMatches(
                          expected: command.expectedRevision,
                          observed: dependency.observedRevision
                      )
              }) else {
            return .identityMismatch
        }
        let expectedPolicy: CommandSideEffectPolicy = preparation.decision.writeSet.externalEffect == .none
            ? .localOnly
            : .outboxRequired
        guard authorization.sideEffectPolicy == expectedPolicy else { return .authorityRejected }
        switch preparation.decision.disposition {
        case .apply:
            guard preparation.decision.writeSet.events.isEmpty == false,
                  preparation.decision.writeSet.receiptIntentID != nil,
                  preparation.decision.writeSet.rollbackIntentID != nil else {
                return .identityMismatch
            }
        case .unchanged:
            guard preparation.decision.writeSet.transitions.isEmpty,
                  preparation.decision.writeSet.events.isEmpty,
                  preparation.decision.writeSet.externalEffect == .none else {
                return .identityMismatch
            }
        case .blocked:
            return .authorityRejected
        case .unsupported:
            return .unsupportedInput
        }
        switch (preparation.decision.confirmationScope, preparation.confirmationRequest) {
        case (nil, nil):
            break
        case let (.some(scope), .some(request)):
            guard request.oneUse,
                  request.token.rawValue.isEmpty == false,
                  request.preparationID == preparation.preparationID,
                  request.commandID == preparation.commandID,
                  request.commandFingerprint == preparation.commandFingerprint,
                  request.actor == command.actor,
                  request.scope == scope,
                  request.target == command.target,
                  request.decisionDigest == preparation.decisionDigest,
                  request.issuedAt == preparation.issuedAt,
                  request.expiresAt == preparation.expiresAt else {
                return .confirmationMismatch
            }
        default:
            return .confirmationMismatch
        }
        if preparation.decision.confirmationScope == .legacyCalendarCompatibility,
           RuntimeLegacyCalendarCompatibilityPolicy().allows(
               command: command,
               decision: preparation.decision
           ) == false {
            return .identityMismatch
        }
        return nil
    }

    private func terminal(
        _ preparation: RuntimePreparation,
        recovery: RuntimeRecovery
    ) -> RuntimeTerminalResult {
        RuntimeTerminalResult(
            preparationID: preparation.preparationID,
            commandID: preparation.commandID.rawValue,
            reason: recovery.reason,
            recovery: recovery
        )
    }

    private func blocked(_ preparation: RuntimePreparation, reason: RuntimeRecoveryReason) -> RuntimeCommandOutcome {
        .blocked(RuntimeTerminalResult(
            preparationID: preparation.preparationID,
            commandID: preparation.commandID.rawValue,
            reason: reason,
            recovery: .inspect(reason, target: preparation.command.target)
        ))
    }

    private func failed(_ preparation: RuntimePreparation, reason: RuntimeRecoveryReason) -> RuntimeCommandOutcome {
        .failed(RuntimeTerminalResult(
            preparationID: preparation.preparationID,
            commandID: preparation.commandID.rawValue,
            reason: reason,
            recovery: RuntimeRecovery(kind: .retry, reason: reason, target: preparation.command.target, redactedDetail: nil)
        ))
    }

    private func unsupported(_ preparation: RuntimePreparation, reason: RuntimeRecoveryReason) -> RuntimeCommandOutcome {
        .unsupported(RuntimeTerminalResult(
            preparationID: preparation.preparationID,
            commandID: preparation.commandID.rawValue,
            reason: reason,
            recovery: .inspect(reason, target: preparation.command.target)
        ))
    }
}

struct UnavailableRuntimeMutationAuthority: RuntimeMutationAuthorityAccepting, Sendable {
    func accept(
        _ preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?
    ) async -> RuntimeAuthorityAcceptance {
        .unsupported(.inspect(.authorityUnavailable, target: preparation.command.target))
    }
}
