import Foundation
import XCTest
@testable import Ambitions

final class RuntimeMutationPreparationTests: XCTestCase {
    func testPureReducerIsDeterministicAndUsesSuppliedAuthorityFacts() throws {
        let command = quickCaptureCommand()
        let input = RuntimeFeatureReducerInput(
            command: command,
            commandID: try XCTUnwrap(RuntimeCommandID(rawValue: command.id)),
            snapshot: .empty(privacy: command.privacy),
            context: try preparationContext()
        )

        let first = CaptureMutationReducer().reduce(input)
        let second = CaptureMutationReducer().reduce(input)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.disposition, .apply)
        XCTAssertEqual(first.writeSet.transitions.map(\.objectID.rawValue), ["prepared-object-1"])
        XCTAssertEqual(first.writeSet.events.map(\.id.rawValue), ["prepared-event-1"])
        XCTAssertEqual(first.writeSet.receiptIntentID?.rawValue, "prepared-receipt-1")
        XCTAssertEqual(first.writeSet.rollbackIntentID?.rawValue, "prepared-rollback-1")
        XCTAssertEqual(first.writeSet.externalEffect, .none)
    }

    func testPreparationProducesReadyConfirmationBlockedAndUnsupportedTruth() async throws {
        let context = try preparationContext()
        let readyService = RuntimeMutationPreparationService(
            reader: SequencedPreparationReader([.empty(privacy: .privateUserText)])
        )
        guard case let .ready(ready) = await readyService.prepare(quickCaptureCommand(), context: context) else {
            return XCTFail("Expected ready preparation")
        }
        XCTAssertNil(ready.confirmationRequest)
        XCTAssertEqual(ready.authorization.state, .authorized)

        let destructive = destructiveCommand()
        let confirmationService = RuntimeMutationPreparationService(
            reader: SequencedPreparationReader([try destructiveSnapshot()])
        )
        guard case let .requiresConfirmation(prepared) = await confirmationService.prepare(destructive, context: context) else {
            return XCTFail("Expected bound confirmation request")
        }
        XCTAssertEqual(prepared.confirmationRequest?.scope, .destructiveMutation)
        XCTAssertEqual(prepared.confirmationRequest?.oneUse, true)

        let blockedService = RuntimeMutationPreparationService(
            reader: SequencedPreparationReader([RuntimePreparationSnapshot(
                observedRevision: .exact(4), objectRevisions: [:], cursors: [], privacy: .privateUserText
            )])
        )
        guard case let .blocked(blocked) = await blockedService.prepare(quickCaptureCommand(), context: context) else {
            return XCTFail("Expected revision block")
        }
        XCTAssertEqual(blocked.reason, .revisionMismatch)
        XCTAssertEqual(blocked.recovery.kind, .inspect)

        let privacyService = RuntimeMutationPreparationService(
            reader: SequencedPreparationReader([.empty(privacy: .standard)])
        )
        guard case let .blocked(privacy) = await privacyService.prepare(quickCaptureCommand(), context: context) else {
            return XCTFail("Expected privacy block")
        }
        XCTAssertEqual(privacy.reason, .privacyDenied)

        let missingHandlerService = RuntimeMutationPreparationService(
            reader: SequencedPreparationReader([.empty(privacy: .privateUserText)]),
            router: RuntimeFeatureMutationRouter(
                availability: RuntimeFeatureHandlerAvailability(features: [])
            )
        )
        guard case let .unsupported(missing) = await missingHandlerService.prepare(quickCaptureCommand(), context: context) else {
            return XCTFail("Expected missing-handler unsupported result")
        }
        XCTAssertEqual(missing.reason, .missingHandler)
    }

    func testEveryValidatorNeedsConfirmationOutcomeIsBoundOrBlockedNeverReady() async throws {
        let commands = [
            AmbitionsCommand(
                id: "needs-confirmation-goal",
                source: .goals,
                typedPayload: .goal(GoalCommand(
                    action: .create, target: AmbitionsCommandTarget(), content: RuntimeCommandContent()
                )),
                createdAt: "2026-07-24T12:00:00Z"
            ),
            AmbitionsCommand(
                id: "needs-confirmation-schedule",
                source: .time,
                typedPayload: .schedule(ScheduleCommand(
                    action: .createItem(nil), target: AmbitionsCommandTarget(), content: RuntimeCommandContent()
                )),
                createdAt: "2026-07-24T12:00:00Z"
            ),
            AmbitionsCommand(
                id: "needs-confirmation-reminder",
                source: .time,
                typedPayload: .reminder(ReminderCommand(
                    action: .create, target: AmbitionsCommandTarget(), content: RuntimeCommandContent()
                )),
                createdAt: "2026-07-24T12:00:00Z"
            ),
            try calendarCommand(),
            legacyCalendarCommand(explicitOperationID: nil),
        ]

        for command in commands {
            XCTAssertEqual(AmbitionsCommandValidator().validate(command), .needsConfirmation)
            let service = RuntimeMutationPreparationService(
                reader: SequencedPreparationReader([.empty(privacy: command.privacy)])
            )
            let outcome = await service.prepare(command, context: try preparationContext())
            switch outcome {
            case .ready:
                XCTFail("Validator needsConfirmation became ready for \(command.id)")
            case let .requiresConfirmation(preparation):
                XCTAssertNotNil(preparation.confirmationRequest)
                XCTAssertTrue(preparation.confirmationRequest?.oneUse == true)
            case let .blocked(failure):
                XCTAssertEqual(failure.reason, .invalidSemanticInput)
            case .unsupported:
                XCTFail("Known needs-confirmation command became unsupported")
            }
        }
    }

    func testLegacyCalendarUsesExplicitCompatibilityConfirmationWithoutFabricatingOutboxIdentity() async throws {
        for operationID in [nil, "historical-calendar-operation"] as [String?] {
            let command = legacyCalendarCommand(explicitOperationID: operationID)
            let context = try preparationContext()
            let service = RuntimeMutationPreparationService(
                reader: SequencedPreparationReader([.empty(privacy: command.privacy)])
            )
            guard case let .requiresConfirmation(preparation) = await service.prepare(
                command,
                context: context
            ), let request = preparation.confirmationRequest else {
                return XCTFail("Legacy calendar must require typed compatibility confirmation")
            }
            XCTAssertEqual(preparation.confirmationRequest?.scope, .legacyCalendarCompatibility)
            XCTAssertEqual(preparation.decision.writeSet.externalEffect, .none)
            XCTAssertEqual(preparation.authorization.sideEffectPolicy, .localOnly)
            guard case let .schedule(schedule) = preparation.command.typedPayload,
                  case let .calendarWrite(intent) = schedule.action else {
                return XCTFail("Expected retained legacy calendar intent")
            }
            XCTAssertEqual(intent.operationID?.rawValue, operationID)
            XCTAssertNotEqual(intent.operationID?.rawValue, "prepared-effect-1")

            let authority = StubRuntimeMutationAuthority(mode: .commit)
            let submitter = RuntimeMutationSubmissionService(
                reader: SequencedPreparationReader([.empty(privacy: command.privacy)]),
                authority: authority,
                clock: .deterministic(context.issuedAt.addingTimeInterval(30))
            )
            guard case .changed = await submitter.commit(
                preparation,
                confirmation: confirmation(for: request, decidedAt: context.issuedAt.addingTimeInterval(10))
            ) else { return XCTFail("Bound compatibility confirmation should reach the authority seam") }
        }
    }

    func testAuthorizerReconcilesEveryTargetRevisionAndReadIdentity() throws {
        let objectID = try XCTUnwrap(RuntimeDomainObjectID(rawValue: "capture-1"))
        let command = quickCaptureCommand(
            target: AmbitionsCommandTarget(captureID: objectID.rawValue),
            expectedRevision: .exact(7)
        )
        let snapshot = RuntimePreparationSnapshot(
            observedRevision: .exact(7),
            objectRevisions: [objectID: .exact(8)],
            cursors: [],
            privacy: command.privacy
        )
        let input = RuntimeFeatureReducerInput(
            command: command,
            commandID: try XCTUnwrap(RuntimeCommandID(rawValue: command.id)),
            snapshot: snapshot,
            context: try preparationContext()
        )
        let decision = CaptureMutationReducer().reduce(input)
        let authorization = RuntimePreparationAuthorizer().authorize(
            command: command,
            snapshot: snapshot,
            decision: decision,
            boundary: .localOnly
        )
        XCTAssertEqual(authorization.state, .denied)
        XCTAssertTrue(authorization.reasonCodes.contains(.revisionMismatch))

        let missingReadDecision = RuntimeReducerDecision(
            family: decision.family,
            action: decision.action,
            disposition: decision.disposition,
            readSet: RuntimeMutationReadSet(objects: [], cursors: [], privacy: command.privacy),
            writeSet: decision.writeSet,
            confirmationScope: decision.confirmationScope,
            reason: decision.reason,
            recovery: decision.recovery
        )
        let identityAuthorization = RuntimePreparationAuthorizer().authorize(
            command: command,
            snapshot: snapshot,
            decision: missingReadDecision,
            boundary: .localOnly
        )
        XCTAssertTrue(identityAuthorization.reasonCodes.contains(.identityMismatch))
    }

    func testUnknownBytesRemainLosslessAndProduceInspectWithoutRead() async throws {
        let bytes = Data(#"{"schemaVersion":999,"future":"opaque"}"#.utf8)
        let reader = SequencedPreparationReader([])
        let service = RuntimeMutationPreparationService(reader: reader)

        guard case let .unsupported(failure) = await service.prepare(bytes, context: try preparationContext()) else {
            return XCTFail("Expected unsupported future bytes")
        }
        XCTAssertEqual(failure.originalBytes, bytes)
        XCTAssertEqual(failure.recovery.kind, .inspect)
        let readCount = await reader.readCount()
        XCTAssertEqual(readCount, 0)
    }

    func testEveryTypedFamilyRoutesExhaustively() throws {
        let router = RuntimeFeatureMutationRouter()
        let commands = try familyCommands()
        XCTAssertEqual(commands.map { router.feature(for: $0.typedPayload) }, [
            .capture, .goalStep, .goalStep, .scheduleReminder, .scheduleReminder,
            .profile, .historyRepair, .historyRepair, .importDeletion, .externalOperation,
        ])
    }

    func testCalendarAndProtectedPlacementAreTypedProposalsWithoutImmediateEffect() throws {
        let context = try preparationContext()
        let calendar = try calendarCommand()
        let calendarDecision = ScheduleReminderMutationReducer().reduce(RuntimeFeatureReducerInput(
            command: calendar,
            commandID: try XCTUnwrap(RuntimeCommandID(rawValue: calendar.id)),
            snapshot: .empty(privacy: calendar.privacy),
            context: context
        ))
        XCTAssertEqual(calendarDecision.confirmationScope, .calendarOutbox)
        XCTAssertEqual(
            calendarDecision.writeSet.externalEffect,
            .outbox(operationID: try XCTUnwrap(RuntimeExternalOperationID(rawValue: "calendar-operation-1")), kind: .calendarEvent)
        )
        XCTAssertEqual(calendarDecision.writeSet.effectOrdering, .afterLocalAuthorityAcceptance)

        let protected = protectedPlacementCommand()
        let protectedDecision = ScheduleReminderMutationReducer().reduce(RuntimeFeatureReducerInput(
            command: protected,
            commandID: try XCTUnwrap(RuntimeCommandID(rawValue: protected.id)),
            snapshot: RuntimePreparationSnapshot(
                observedRevision: .exact(2),
                objectRevisions: [try XCTUnwrap(RuntimeDomainObjectID(rawValue: "time-1")): .exact(2)],
                cursors: [],
                privacy: protected.privacy
            ),
            context: context
        ))
        XCTAssertEqual(protectedDecision.confirmationScope, .protectedPlacement)
        XCTAssertEqual(protectedDecision.writeSet.externalEffect, .none)
    }

    func testConfirmationTamperingExpiryRejectionAndConsumptionNeverReachFalseSuccess() async throws {
        let now = Date(timeIntervalSince1970: 1_774_526_400)
        let context = try preparationContext(issuedAt: now, expiresAt: now.addingTimeInterval(300))
        let command = destructiveCommand()
        let preparationReader = SequencedPreparationReader([try destructiveSnapshot()])
        let service = RuntimeMutationPreparationService(reader: preparationReader)
        guard case let .requiresConfirmation(preparation) = await service.prepare(command, context: context),
              let request = preparation.confirmationRequest else {
            return XCTFail("Expected confirmation preparation")
        }

        let missingAuthority = StubRuntimeMutationAuthority(mode: .commit)
        let missingSubmitter = RuntimeMutationSubmissionService(
            reader: SequencedPreparationReader([try destructiveSnapshot()]),
            authority: missingAuthority,
            clock: .deterministic(now.addingTimeInterval(30))
        )
        guard case let .blocked(missingResult) = await missingSubmitter.commit(preparation, confirmation: nil) else {
            return XCTFail("Expected missing-confirmation block")
        }
        XCTAssertEqual(missingResult.reason, .confirmationRequired)
        let missingAcceptCount = await missingAuthority.acceptCount()
        XCTAssertEqual(missingAcceptCount, 0)

        let tamperedAuthority = StubRuntimeMutationAuthority(mode: .commit)
        let tamperedSubmitter = RuntimeMutationSubmissionService(
            reader: SequencedPreparationReader([try destructiveSnapshot()]),
            authority: tamperedAuthority,
            clock: .deterministic(now.addingTimeInterval(30))
        )
        var tampered = confirmation(for: request, decidedAt: now.addingTimeInterval(10))
        tampered = RuntimeMutationConfirmation(
            token: tampered.token,
            preparationID: tampered.preparationID,
            commandID: try XCTUnwrap(RuntimeCommandID(rawValue: "wrong-command")),
            commandFingerprint: tampered.commandFingerprint,
            actor: tampered.actor,
            scope: .export,
            target: tampered.target,
            decisionDigest: tampered.decisionDigest,
            decision: tampered.decision,
            decidedAt: tampered.decidedAt
        )
        guard case let .blocked(tamperedResult) = await tamperedSubmitter.commit(preparation, confirmation: tampered) else {
            return XCTFail("Expected tamper block")
        }
        XCTAssertEqual(tamperedResult.reason, .confirmationMismatch)
        let tamperedAcceptCount = await tamperedAuthority.acceptCount()
        XCTAssertEqual(tamperedAcceptCount, 0)

        let expiredAuthority = StubRuntimeMutationAuthority(mode: .commit)
        let expired = RuntimeMutationSubmissionService(
            reader: SequencedPreparationReader([try destructiveSnapshot()]),
            authority: expiredAuthority,
            clock: .deterministic(context.expiresAt.addingTimeInterval(1))
        )
        guard case let .blocked(expiredResult) = await expired.commit(
            preparation,
            confirmation: confirmation(for: request, decidedAt: now.addingTimeInterval(10))
        ) else { return XCTFail("Expected expiry block") }
        XCTAssertEqual(expiredResult.reason, .confirmationExpired)
        let expiredAcceptCount = await expiredAuthority.acceptCount()
        XCTAssertEqual(expiredAcceptCount, 0)

        let rejectedAuthority = StubRuntimeMutationAuthority(mode: .commit)
        let rejectedSubmitter = RuntimeMutationSubmissionService(
            reader: SequencedPreparationReader([try destructiveSnapshot()]),
            authority: rejectedAuthority,
            clock: .deterministic(now.addingTimeInterval(30))
        )
        var rejected = confirmation(for: request, decidedAt: now.addingTimeInterval(10))
        rejected = RuntimeMutationConfirmation(
            token: rejected.token, preparationID: rejected.preparationID, commandID: rejected.commandID,
            commandFingerprint: rejected.commandFingerprint, actor: rejected.actor, scope: rejected.scope,
            target: rejected.target, decisionDigest: rejected.decisionDigest, decision: .rejected,
            decidedAt: rejected.decidedAt
        )
        guard case let .blocked(rejectedResult) = await rejectedSubmitter.commit(preparation, confirmation: rejected) else {
            return XCTFail("Expected rejection block")
        }
        XCTAssertEqual(rejectedResult.reason, .confirmationRejected)
        let rejectedAcceptCount = await rejectedAuthority.acceptCount()
        XCTAssertEqual(rejectedAcceptCount, 0)

        let consumedAuthority = StubRuntimeMutationAuthority(mode: .consumed)
        let consumedSubmitter = RuntimeMutationSubmissionService(
            reader: SequencedPreparationReader([try destructiveSnapshot()]),
            authority: consumedAuthority,
            clock: .deterministic(now.addingTimeInterval(30))
        )
        guard case let .blocked(consumedResult) = await consumedSubmitter.commit(
            preparation,
            confirmation: confirmation(for: request, decidedAt: now.addingTimeInterval(10))
        ) else { return XCTFail("Expected authority replay block") }
        XCTAssertEqual(consumedResult.reason, .confirmationConsumed)
        let consumedAcceptCount = await consumedAuthority.acceptCount()
        XCTAssertEqual(consumedAcceptCount, 1)
    }

    func testSubmissionRechecksRevisionAndCommittedProjectionDegradationCannotRewriteAuthority() async throws {
        let now = Date(timeIntervalSince1970: 1_774_526_400)
        let objectID = try XCTUnwrap(RuntimeDomainObjectID(rawValue: "capture-1"))
        let command = quickCaptureCommand(
            target: AmbitionsCommandTarget(captureID: objectID.rawValue),
            expectedRevision: .exact(7)
        )
        let initial = RuntimePreparationSnapshot(
            observedRevision: .exact(7), objectRevisions: [objectID: .exact(7)], cursors: [], privacy: command.privacy
        )
        let service = RuntimeMutationPreparationService(reader: SequencedPreparationReader([initial]))
        guard case let .ready(preparation) = await service.prepare(
            command,
            context: try preparationContext(issuedAt: now, expiresAt: now.addingTimeInterval(300))
        ) else { return XCTFail("Expected exact-revision preparation") }

        let staleAuthority = StubRuntimeMutationAuthority(mode: .commit)
        let staleSubmitter = RuntimeMutationSubmissionService(
            reader: SequencedPreparationReader([RuntimePreparationSnapshot(
                observedRevision: .exact(8), objectRevisions: [objectID: .exact(8)], cursors: [], privacy: command.privacy
            )]),
            authority: staleAuthority,
            clock: .deterministic(now.addingTimeInterval(30))
        )
        guard case let .blocked(stale) = await staleSubmitter.commit(preparation, confirmation: nil) else {
            return XCTFail("Expected stale block")
        }
        XCTAssertEqual(stale.reason, .staleAfterPreparation)
        let staleAcceptCount = await staleAuthority.acceptCount()
        XCTAssertEqual(staleAcceptCount, 0)

        let commitAuthority = StubRuntimeMutationAuthority(mode: .commitWithProjectionDegradation)
        let commitSubmitter = RuntimeMutationSubmissionService(
            reader: SequencedPreparationReader([initial]),
            authority: commitAuthority,
            clock: .deterministic(now.addingTimeInterval(30))
        )
        guard case let .changed(committed) = await commitSubmitter.commit(preparation, confirmation: nil) else {
            return XCTFail("Committed authority must remain changed")
        }
        XCTAssertEqual(committed.projectionDegradation, ["projection.time"])
    }

    func testSubmissionExposesEveryTerminalStateWithTypedRecovery() async throws {
        let now = Date(timeIntervalSince1970: 1_774_526_400)
        let command = quickCaptureCommand()
        let service = RuntimeMutationPreparationService(
            reader: SequencedPreparationReader([.empty(privacy: command.privacy)])
        )
        guard case let .ready(preparation) = await service.prepare(
            command,
            context: try preparationContext(issuedAt: now, expiresAt: now.addingTimeInterval(300))
        ) else { return XCTFail("Expected ready preparation") }

        let cases: [(StubRuntimeMutationAuthority.Mode, RuntimeRecoveryReason)] = [
            (.unchanged, .noMutation),
            (.failed, .authorityFailed),
        ]
        for (mode, reason) in cases {
            let submitter = RuntimeMutationSubmissionService(
                reader: SequencedPreparationReader([.empty(privacy: command.privacy)]),
                authority: StubRuntimeMutationAuthority(mode: mode),
                clock: .deterministic(now.addingTimeInterval(30))
            )
            let outcome = await submitter.commit(preparation, confirmation: nil)
            switch (mode, outcome) {
            case let (.unchanged, .unchanged(result)), let (.failed, .failed(result)):
                XCTAssertEqual(result.reason, reason)
                XCTAssertNotEqual(result.recovery.kind, .none)
            default:
                XCTFail("Unexpected terminal outcome \(outcome)")
            }
        }

        let unavailable = RuntimeMutationSubmissionService(
            reader: SequencedPreparationReader([.empty(privacy: command.privacy)]),
            authority: UnavailableRuntimeMutationAuthority(),
            clock: .deterministic(now.addingTimeInterval(30))
        )
        guard case let .unsupported(result) = await unavailable.commit(preparation, confirmation: nil) else {
            return XCTFail("Unavailable future authority must remain unsupported")
        }
        XCTAssertEqual(result.reason, .authorityUnavailable)
        XCTAssertEqual(result.recovery.kind, .inspect)
    }

    func testConstructedInconsistentPreparationsNeverReachAuthority() async throws {
        let now = Date(timeIntervalSince1970: 1_774_526_400)
        let command = destructiveCommand()
        let service = RuntimeMutationPreparationService(
            reader: SequencedPreparationReader([try destructiveSnapshot()])
        )
        guard case let .requiresConfirmation(base) = await service.prepare(
            command,
            context: try preparationContext(issuedAt: now, expiresAt: now.addingTimeInterval(300))
        ), let request = base.confirmationRequest else {
            return XCTFail("Expected bound destructive preparation")
        }
        let deniedAuthorization = RuntimePreparationAuthorization(
            state: .denied,
            actor: base.authorization.actor,
            source: base.authorization.source,
            expectedRevision: base.authorization.expectedRevision,
            observedRevision: base.authorization.observedRevision,
            privacyBoundary: base.authorization.privacyBoundary,
            sideEffectPolicy: base.authorization.sideEffectPolicy,
            reasonCodes: [.authorityRejected]
        )
        let mismatchedAuthorization = RuntimePreparationAuthorization(
            state: .authorized,
            actor: .system,
            source: .system,
            expectedRevision: base.authorization.expectedRevision,
            observedRevision: base.authorization.observedRevision,
            privacyBoundary: base.authorization.privacyBoundary,
            sideEffectPolicy: base.authorization.sideEffectPolicy,
            reasonCodes: []
        )
        let tamperedDecision = RuntimeReducerDecision(
            family: base.decision.family,
            action: "\(base.decision.action).tampered",
            disposition: base.decision.disposition,
            readSet: base.decision.readSet,
            writeSet: base.decision.writeSet,
            confirmationScope: base.decision.confirmationScope,
            reason: base.decision.reason,
            recovery: base.decision.recovery
        )
        let reusableRequest = RuntimeConfirmationRequest(
            token: request.token,
            preparationID: request.preparationID,
            commandID: request.commandID,
            commandFingerprint: request.commandFingerprint,
            actor: request.actor,
            scope: request.scope,
            target: request.target,
            decisionDigest: request.decisionDigest,
            issuedAt: request.issuedAt,
            expiresAt: request.expiresAt,
            oneUse: false
        )
        let variants = [
            copy(base, schemaVersion: "runtime_preparation.future.v9"),
            copy(base, commandVersion: runtimeCommandSchemaVersion + 1),
            copy(base, commandID: try XCTUnwrap(RuntimeCommandID(rawValue: "wrong-command"))),
            copy(base, decision: tamperedDecision),
            copy(base, authorization: deniedAuthorization),
            copy(base, authorization: mismatchedAuthorization),
            copy(base, confirmationRequest: reusableRequest),
        ]
        for preparation in variants {
            let authority = StubRuntimeMutationAuthority(mode: .commit)
            let submitter = RuntimeMutationSubmissionService(
                reader: SequencedPreparationReader([try destructiveSnapshot()]),
                authority: authority,
                clock: .deterministic(now.addingTimeInterval(30))
            )
            let outcome = await submitter.commit(
                preparation,
                confirmation: confirmation(for: request, decidedAt: now.addingTimeInterval(10))
            )
            switch outcome {
            case .blocked, .unsupported:
                break
            case .changed, .unchanged, .failed:
                XCTFail("Inconsistent preparation escaped validation")
            }
            let acceptCount = await authority.acceptCount()
            XCTAssertEqual(acceptCount, 0)
        }
    }

    func testRecomputedDigestCannotAuthorizeMismatchedBoundReadRevision() async throws {
        let now = Date(timeIntervalSince1970: 1_774_526_400)
        let objectID = try XCTUnwrap(RuntimeDomainObjectID(rawValue: "capture-1"))
        let command = quickCaptureCommand(
            target: AmbitionsCommandTarget(captureID: objectID.rawValue),
            expectedRevision: .exact(7)
        )
        let preparedSnapshot = RuntimePreparationSnapshot(
            observedRevision: .exact(7),
            objectRevisions: [objectID: .exact(7)],
            cursors: [],
            privacy: command.privacy
        )
        let service = RuntimeMutationPreparationService(
            reader: SequencedPreparationReader([preparedSnapshot])
        )
        guard case let .ready(base) = await service.prepare(
            command,
            context: try preparationContext(issuedAt: now, expiresAt: now.addingTimeInterval(300))
        ) else { return XCTFail("Expected exact-revision ready preparation") }

        let tamperedDecision = RuntimeReducerDecision(
            family: base.decision.family,
            action: base.decision.action,
            disposition: base.decision.disposition,
            readSet: RuntimeMutationReadSet(
                objects: [RuntimeReadDependency(
                    objectID: objectID,
                    expectedRevision: .exact(7),
                    observedRevision: .exact(8)
                )],
                cursors: base.decision.readSet.cursors,
                privacy: base.decision.readSet.privacy
            ),
            writeSet: base.decision.writeSet,
            confirmationScope: base.decision.confirmationScope,
            reason: base.decision.reason,
            recovery: base.decision.recovery
        )
        let payloadDigest = try XCTUnwrap(RuntimePreparationDigest.value(command.typedPayload))
        let recomputedDecisionDigest = try XCTUnwrap(RuntimePreparationDigest.decision(
            commandPayloadDigest: payloadDigest,
            decision: tamperedDecision,
            preparationID: base.preparationID
        ))
        let tampered = copy(
            base,
            decision: tamperedDecision,
            decisionDigest: recomputedDecisionDigest
        )
        let currentSnapshot = RuntimePreparationSnapshot(
            observedRevision: .exact(7),
            objectRevisions: [objectID: .exact(8)],
            cursors: [],
            privacy: command.privacy
        )
        let authority = StubRuntimeMutationAuthority(mode: .commit)
        let submitter = RuntimeMutationSubmissionService(
            reader: SequencedPreparationReader([currentSnapshot]),
            authority: authority,
            clock: .deterministic(now.addingTimeInterval(30))
        )

        guard case let .blocked(result) = await submitter.commit(tampered, confirmation: nil) else {
            return XCTFail("Mismatched bound read revision must be rejected before authority")
        }
        XCTAssertEqual(result.reason, .identityMismatch)
        let acceptCount = await authority.acceptCount()
        XCTAssertEqual(acceptCount, 0)
    }

    func testTargetlessAggregateRevisionTamperNeverReachesAuthority() async throws {
        let now = Date(timeIntervalSince1970: 1_774_526_400)
        let command = quickCaptureCommand()
        let service = RuntimeMutationPreparationService(
            reader: SequencedPreparationReader([.empty(privacy: command.privacy)])
        )
        guard case let .ready(base) = await service.prepare(
            command,
            context: try preparationContext(issuedAt: now, expiresAt: now.addingTimeInterval(300))
        ) else { return XCTFail("Expected targetless absent-revision preparation") }
        XCTAssertTrue(base.decision.readSet.objects.isEmpty)

        let tamperedAuthorization = RuntimePreparationAuthorization(
            state: .authorized,
            actor: base.authorization.actor,
            source: base.authorization.source,
            expectedRevision: .absent,
            observedRevision: .exact(1),
            privacyBoundary: base.authorization.privacyBoundary,
            sideEffectPolicy: base.authorization.sideEffectPolicy,
            reasonCodes: []
        )
        let tampered = copy(base, authorization: tamperedAuthorization)
        let currentSnapshot = RuntimePreparationSnapshot(
            observedRevision: .exact(1),
            objectRevisions: [:],
            cursors: [],
            privacy: command.privacy
        )
        let authority = StubRuntimeMutationAuthority(mode: .commit)
        let submitter = RuntimeMutationSubmissionService(
            reader: SequencedPreparationReader([currentSnapshot]),
            authority: authority,
            clock: .deterministic(now.addingTimeInterval(30))
        )

        guard case let .blocked(result) = await submitter.commit(tampered, confirmation: nil) else {
            return XCTFail("Aggregate revision incompatible with command expectation must be rejected")
        }
        XCTAssertEqual(result.reason, .identityMismatch)
        let acceptCount = await authority.acceptCount()
        XCTAssertEqual(acceptCount, 0)
    }

    func testReducerSourceGuardRejectsImpureDependencies() throws {
        let source = try String(contentsOf: reducerSourceURL(), encoding: .utf8)
        for forbidden in [
            "FileManager", "URLSession", "SwiftData", "NotificationCenter", "Task.detached",
            "Date()", "UUID()", "@Sendable (", "Repository", "Store(",
        ] {
            XCTAssertFalse(source.contains(forbidden), "Pure reducer source contains \(forbidden)")
        }
    }

    private func quickCaptureCommand(
        target: AmbitionsCommandTarget = AmbitionsCommandTarget(),
        expectedRevision: RuntimeExpectedRevision = .absent
    ) -> AmbitionsCommand {
        AmbitionsCommand(
            id: "command-prepared-capture",
            source: .capture,
            typedPayload: .capture(CaptureCommand(
                action: .quickCapture(externalCreation: nil),
                target: target,
                content: RuntimeCommandContent(AmbitionsCommandPayload(rawText: "Private capture"))
            )),
            expectedRevision: expectedRevision,
            createdAt: "2026-07-24T12:00:00Z",
            privacy: .privateUserText
        )
    }

    private func destructiveCommand() -> AmbitionsCommand {
        AmbitionsCommand(
            id: "command-prepared-delete",
            source: .you,
            typedPayload: .importDeletion(ImportDeletionCommand(
                action: .deleteObject,
                target: AmbitionsCommandTarget(goalID: "goal-1", destination: .you),
                content: RuntimeCommandContent()
            )),
            expectedRevision: .exact(1),
            createdAt: "2026-07-24T12:00:00Z"
        )
    }

    private func destructiveSnapshot() throws -> RuntimePreparationSnapshot {
        let goalID = try XCTUnwrap(RuntimeDomainObjectID(rawValue: "goal-1"))
        return RuntimePreparationSnapshot(
            observedRevision: .exact(1),
            objectRevisions: [goalID: .exact(1)],
            cursors: [],
            privacy: .standard
        )
    }

    private func legacyCalendarCommand(explicitOperationID: String?) -> AmbitionsCommand {
        var metadata = [
            "calendarWriteIntent": "true",
            "userConfirmed": "true",
            "startAt": "2026-07-24T12:00:00Z",
            "endAt": "2026-07-24T12:30:00Z",
            "scheduleBlockID": "legacy-schedule-1",
        ]
        metadata["externalEffectOperationID"] = explicitOperationID
        return AmbitionsCommand(
            id: "legacy-calendar-\(explicitOperationID ?? "absent")",
            kind: .scheduleItem,
            source: .time,
            target: AmbitionsCommandTarget(timeID: "time-1", destination: .time),
            payload: AmbitionsCommandPayload(title: "Historical calendar", metadata: metadata),
            createdAt: "2025-01-02T03:04:05Z",
            actor: .system
        )
    }

    private func copy(
        _ base: RuntimePreparation,
        schemaVersion: String? = nil,
        commandVersion: Int? = nil,
        commandID: RuntimeCommandID? = nil,
        decision: RuntimeReducerDecision? = nil,
        decisionDigest: RuntimeCommandFingerprint? = nil,
        authorization: RuntimePreparationAuthorization? = nil,
        confirmationRequest: RuntimeConfirmationRequest? = nil
    ) -> RuntimePreparation {
        RuntimePreparation(
            preparationID: base.preparationID,
            command: base.command,
            commandID: commandID ?? base.commandID,
            commandFingerprint: base.commandFingerprint,
            commandVersion: commandVersion ?? base.commandVersion,
            decision: decision ?? base.decision,
            decisionDigest: decisionDigest ?? base.decisionDigest,
            authorization: authorization ?? base.authorization,
            confirmationRequest: confirmationRequest ?? base.confirmationRequest,
            issuedAt: base.issuedAt,
            expiresAt: base.expiresAt,
            schemaVersion: schemaVersion ?? base.schemaVersion
        )
    }

    private func protectedPlacementCommand() -> AmbitionsCommand {
        AmbitionsCommand(
            id: "command-protected-placement",
            source: .time,
            typedPayload: .schedule(ScheduleCommand(
                action: .protectWindow(TimePlacementCommandIntent(
                    start: "2026-07-24T12:00:00Z", end: "2026-07-24T12:30:00Z",
                    approvedDurationMinutes: 30, contextLens: .work, relatedGoalID: nil, relatedCaptureID: nil
                )),
                target: AmbitionsCommandTarget(timeID: "time-1", destination: .time),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Protected work"))
            )),
            expectedRevision: .exact(2),
            createdAt: "2026-07-24T12:00:00Z"
        )
    }

    private func calendarCommand() throws -> AmbitionsCommand {
        AmbitionsCommand(
            id: "command-calendar-proposal",
            source: .time,
            typedPayload: .schedule(ScheduleCommand(
                action: .calendarWrite(CalendarWriteCommandIntent(
                    operationID: try XCTUnwrap(RuntimeExternalOperationID(rawValue: "calendar-operation-1")),
                    userConfirmed: true,
                    placement: TimePlacementCommandIntent(
                        start: "2026-07-24T12:00:00Z", end: "2026-07-24T12:30:00Z",
                        approvedDurationMinutes: 30, contextLens: .work, relatedGoalID: nil, relatedCaptureID: nil
                    ),
                    destinationStepID: nil, destinationStepTitle: nil, originalBlockID: nil,
                    displacedDisposition: .notDisplaced, destinationStepPressure: nil, originStepPressure: nil,
                    lifeshapeImpact: .recalculatedBeforeCommit,
                    scheduleBlockID: try XCTUnwrap(RuntimeCommandObjectID(rawValue: "schedule-1"))
                )),
                target: AmbitionsCommandTarget(timeID: "time-1", destination: .time),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Calendar proposal"))
            )),
            expectedRevision: .absent,
            createdAt: "2026-07-24T12:00:00Z"
        )
    }

    private func familyCommands() throws -> [AmbitionsCommand] {
        let content = RuntimeCommandContent(AmbitionsCommandPayload(title: "Typed"))
        let target = AmbitionsCommandTarget(goalID: "goal-1", timeID: "time-1", stepID: "step-1", destination: .today)
        let recovery = RecoveryRecommendationCommand(
            goalID: try XCTUnwrap(RuntimeCommandObjectID(rawValue: "goal-1")), captureID: nil, timeID: nil,
            title: "Recover", explanationID: nil
        )
        return [
            quickCaptureCommand(),
            AmbitionsCommand(id: "family-goal", source: .goals, typedPayload: .goal(GoalCommand(action: .update, target: target, content: content)), createdAt: "2026-07-24T12:00:00Z"),
            AmbitionsCommand(id: "family-step", source: .today, typedPayload: .step(StepCommand(action: .complete, target: target, content: content)), createdAt: "2026-07-24T12:00:00Z"),
            protectedPlacementCommand(),
            AmbitionsCommand(id: "family-reminder", source: .time, typedPayload: .reminder(ReminderCommand(action: .create, target: target, content: content)), createdAt: "2026-07-24T12:00:00Z"),
            AmbitionsCommand(id: "family-profile", source: .you, typedPayload: .profile(ProfileCommand(action: .updatePreferences, target: AmbitionsCommandTarget(destination: .you), content: content)), createdAt: "2026-07-24T12:00:00Z"),
            AmbitionsCommand(id: "family-history", source: .today, typedPayload: .history(HistoryCommand(action: .openDestination, target: target, content: content)), createdAt: "2026-07-24T12:00:00Z"),
            AmbitionsCommand(id: "family-repair", source: .today, typedPayload: .repair(RepairCommand(action: .recover, recommendation: recovery, target: target, content: content)), createdAt: "2026-07-24T12:00:00Z"),
            AmbitionsCommand(id: "family-import", source: .you, typedPayload: .importDeletion(ImportDeletionCommand(action: .prepareExport, target: target, content: content)), createdAt: "2026-07-24T12:00:00Z"),
            AmbitionsCommand(id: "family-external", source: .system, typedPayload: .externalOperation(ExternalOperationCommand(operationID: try XCTUnwrap(RuntimeExternalOperationID(rawValue: "operation-1")), kind: .reminder, target: target, title: "External")), createdAt: "2026-07-24T12:00:00Z"),
        ]
    }

    private func preparationContext(
        issuedAt: Date = Date(timeIntervalSince1970: 1_774_526_400),
        expiresAt: Date = Date(timeIntervalSince1970: 1_774_526_700)
    ) throws -> RuntimePreparationContext {
        RuntimePreparationContext(
            preparationID: try XCTUnwrap(RuntimePreparationID(rawValue: "preparation-1")),
            confirmationToken: try XCTUnwrap(RuntimeConfirmationToken(rawValue: "confirmation-1")),
            proposedObjectID: try XCTUnwrap(RuntimeDomainObjectID(rawValue: "prepared-object-1")),
            eventID: try XCTUnwrap(RuntimeEventID(rawValue: "prepared-event-1")),
            receiptID: try XCTUnwrap(RuntimeReceiptID(rawValue: "prepared-receipt-1")),
            rollbackPlanID: try XCTUnwrap(RuntimeRollbackPlanID(rawValue: "prepared-rollback-1")),
            externalOperationID: try XCTUnwrap(RuntimeExternalOperationID(rawValue: "prepared-effect-1")),
            issuedAt: issuedAt,
            expiresAt: expiresAt,
            boundary: .localOnly
        )
    }

    private func confirmation(
        for request: RuntimeConfirmationRequest,
        decidedAt: Date
    ) -> RuntimeMutationConfirmation {
        RuntimeMutationConfirmation(
            token: request.token, preparationID: request.preparationID, commandID: request.commandID,
            commandFingerprint: request.commandFingerprint, actor: request.actor, scope: request.scope,
            target: request.target, decisionDigest: request.decisionDigest, decision: .approved,
            decidedAt: decidedAt
        )
    }

    private func reducerSourceURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Ambitions/Core/LocalRuntimeOS/Commands/RuntimeMutationReducers.swift")
    }
}

private actor SequencedPreparationReader: RuntimePreparationReading {
    private var snapshots: [RuntimePreparationSnapshot]
    private var count = 0

    init(_ snapshots: [RuntimePreparationSnapshot]) { self.snapshots = snapshots }

    func read(_ request: RuntimePreparationReadRequest) async throws -> RuntimePreparationSnapshot {
        count += 1
        guard snapshots.isEmpty == false else { throw RuntimeFoundationError.validation }
        return snapshots.removeFirst()
    }

    func readCount() -> Int { count }
}

private actor StubRuntimeMutationAuthority: RuntimeMutationAuthorityAccepting {
    enum Mode: Equatable { case commit, commitWithProjectionDegradation, consumed, unchanged, failed }
    private let mode: Mode
    private var count = 0

    init(mode: Mode) { self.mode = mode }

    func accept(
        _ preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?
    ) async -> RuntimeAuthorityAcceptance {
        count += 1
        switch mode {
        case .commit, .commitWithProjectionDegradation:
            return .committed(RuntimeCommittedMutation(
                preparationID: preparation.preparationID,
                commandID: preparation.commandID,
                authorityReceiptID: RuntimeReceiptID(rawValue: "authority-receipt-1")!,
                projectionDegradation: mode == .commitWithProjectionDegradation ? ["projection.time"] : []
            ))
        case .consumed:
            return .rejected(.inspect(.confirmationConsumed, target: preparation.command.target))
        case .unchanged:
            return .unchanged(RuntimeRecovery(
                kind: .reconcile, reason: .noMutation, target: preparation.command.target, redactedDetail: nil
            ))
        case .failed:
            return .failed(RuntimeRecovery(
                kind: .retry, reason: .authorityFailed, target: preparation.command.target, redactedDetail: nil
            ))
        }
    }

    func acceptCount() -> Int { count }
}
