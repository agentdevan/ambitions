import AmbitionsRuntimeCore
import Foundation

struct RuntimeSemanticEventLimits: Sendable, Equatable {
    static let canonical = RuntimeSemanticEventLimits(maximumEnvelopeBytes: 1_048_576, maximumPayloadBytes: 786_432)
    let maximumEnvelopeBytes: Int
    let maximumPayloadBytes: Int
    init(maximumEnvelopeBytes: Int, maximumPayloadBytes: Int) {
        self.maximumEnvelopeBytes = max(0, maximumEnvelopeBytes)
        self.maximumPayloadBytes = max(0, maximumPayloadBytes)
    }
}

enum RuntimeSemanticEventCodecError: Error, Sendable, Equatable, Hashable {
    case envelopeTooLarge
    case payloadTooLarge
    case malformedEnvelope
    case corruptEnvelope
    case truncatedEnvelope
    case futureEnvelopeVersion
    case unsupportedEnvelopeVersion
    case unknownType
    case futurePayloadVersion
    case unsupportedPayloadVersion
    case typeMismatch
    case invalidPayload
    case nonCanonicalBytes
    case encodingFailed
}

extension RuntimeSemanticEventCodecError: CustomStringConvertible, LocalizedError {
    var description: String {
        switch self {
        case .envelopeTooLarge: "The event envelope exceeds its safe size limit."
        case .payloadTooLarge: "The event payload exceeds its safe size limit."
        case .malformedEnvelope: "The event envelope is malformed."
        case .corruptEnvelope: "The event envelope is corrupt."
        case .truncatedEnvelope: "The event envelope is truncated."
        case .futureEnvelopeVersion: "The event envelope requires a newer app version."
        case .unsupportedEnvelopeVersion: "The event envelope version is unsupported."
        case .unknownType: "The event type is unknown."
        case .futurePayloadVersion: "The event payload requires a newer app version."
        case .unsupportedPayloadVersion: "The event payload version is unsupported."
        case .typeMismatch: "The event type does not match its payload."
        case .invalidPayload: "The event payload is invalid."
        case .nonCanonicalBytes: "The event bytes are not canonical."
        case .encodingFailed: "The event could not be encoded canonically."
        }
    }
    var errorDescription: String? { description }
}

struct RuntimeSemanticEventHeader: Sendable, Equatable {
    let envelopeVersion: Int
    let typeID: RuntimeSemanticEventTypeID
    let payloadVersion: Int
}

struct RuntimeDecodedSemanticEvent: Sendable, Equatable {
    let event: RuntimeSemanticEvent
    let sourceBytes: Data
    let sourcePayloadVersion: Int
    let wasUpcast: Bool
}

struct RuntimeSemanticEventWireEnvelope: Codable, Sendable, Equatable {
    let envelopeVersion: Int
    let typeID: String
    let payloadVersion: Int
    let payload: Data
    enum CodingKeys: String, CodingKey {
        case envelopeVersion = "envelope_version"
        case typeID = "type_id"
        case payloadVersion = "payload_version"
        case payload
    }
}

struct RuntimeCaptureCreatedLegacyV0Payload: Codable, Sendable, Equatable {
    let aggregateID: RuntimeAggregateID
    let resultingRevision: UInt64
    let captureID: RuntimeCommandObjectID
    let title: String
    enum CodingKeys: String, CodingKey {
        case aggregateID = "a"
        case captureID = "b"
        case resultingRevision = "r"
        case title = "t"
    }
}

private struct RuntimeSemanticPayloadDiscriminator: Decodable {
    let mutation: RuntimeSemanticMutation
}

struct RuntimeSemanticEventCodec: Sendable {
    static let currentEnvelopeVersion = 1
    let limits: RuntimeSemanticEventLimits
    private let encoder: CanonicalByteEncoder

    init(limits: RuntimeSemanticEventLimits = .canonical, encoder: CanonicalByteEncoder = CanonicalByteEncoder()) {
        self.limits = limits
        self.encoder = encoder
    }

    func encode(_ event: RuntimeSemanticEvent) throws -> Data {
        do { try event.validate() } catch { throw RuntimeSemanticEventCodecError.invalidPayload }
        let payloadBytes: Data
        do {
            payloadBytes = try encodedPayload(event)
        } catch let error as RuntimeSemanticEventCodecError {
            throw error
        } catch {
            throw RuntimeSemanticEventCodecError.encodingFailed
        }
        guard payloadBytes.count <= limits.maximumPayloadBytes else {
            throw RuntimeSemanticEventCodecError.payloadTooLarge
        }
        let envelope = RuntimeSemanticEventWireEnvelope(
            envelopeVersion: Self.currentEnvelopeVersion,
            typeID: event.typeID.rawValue,
            payloadVersion: event.mutation.aggregateTransitions.isEmpty ? 1 : event.typeID.latestPayloadVersion,
            payload: payloadBytes
        )
        let bytes: Data
        do { bytes = try encoder.encode(envelope) } catch { throw RuntimeSemanticEventCodecError.encodingFailed }
        guard bytes.count <= limits.maximumEnvelopeBytes else {
            throw RuntimeSemanticEventCodecError.envelopeTooLarge
        }
        return bytes
    }

    func inspectHeader(_ bytes: Data) throws -> RuntimeSemanticEventHeader {
        let envelope = try validatedEnvelope(bytes)
        let typeID = try validatedTypeAndVersion(envelope)
        return RuntimeSemanticEventHeader(
            envelopeVersion: envelope.envelopeVersion,
            typeID: typeID,
            payloadVersion: envelope.payloadVersion
        )
    }

    func decode(_ bytes: Data) throws -> RuntimeDecodedSemanticEvent {
        let envelope = try validatedEnvelope(bytes)
        let typeID = try validatedTypeAndVersion(envelope)
        let event: RuntimeSemanticEvent
        let wasUpcast: Bool
        if RuntimeSemanticEventRegistry.requiresUpcast(
            typeID: typeID,
            payloadVersion: envelope.payloadVersion
        ) {
            guard typeID == .captureCreated, envelope.payloadVersion == 0 else {
                throw RuntimeSemanticEventCodecError.unsupportedPayloadVersion
            }
            let legacy: RuntimeCaptureCreatedLegacyV0Payload = try decodeCanonicalPayload(envelope.payload)
            guard legacy.resultingRevision == 0 else {
                throw RuntimeSemanticEventCodecError.invalidPayload
            }
            let mutation = try RuntimeSemanticMutation(
                semanticType: .captureCreated,
                aggregateID: legacy.aggregateID,
                priorRevision: nil,
                resultingRevision: legacy.resultingRevision,
                changedObjectIDs: [try RuntimeDomainObjectID(validating: legacy.captureID.rawValue)]
            )
            let facts = CaptureCommand(
                action: .quickCapture(externalCreation: nil),
                target: AmbitionsCommandTarget(captureID: legacy.captureID.rawValue),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: legacy.title))
            )
            event = .capture(.created(try RuntimeCaptureMutationPayload(mutation: mutation, facts: facts)))
            wasUpcast = true
        } else {
            let discriminator: RuntimeSemanticPayloadDiscriminator
            do {
                discriminator = try decoder().decode(
                    RuntimeSemanticPayloadDiscriminator.self,
                    from: envelope.payload
                )
            } catch {
                throw RuntimeSemanticEventCodecError.invalidPayload
            }
            guard discriminator.mutation.semanticType == typeID else {
                throw RuntimeSemanticEventCodecError.typeMismatch
            }
            event = try decodeLatest(typeID: typeID, payload: envelope.payload)
            wasUpcast = false
        }
        if envelope.payloadVersion >= 2 {
            guard let primary = event.mutation.primaryAggregate,
                  event.mutation.aggregateTransitions.isEmpty == false,
                  event.mutation.aggregateTransitions.contains(where: { $0.aggregate == primary }) else {
                throw RuntimeSemanticEventCodecError.invalidPayload
            }
            for transition in event.mutation.aggregateTransitions {
                let decodedState: RuntimeCanonicalAggregateState
                do {
                    decodedState = try RuntimeCanonicalAggregateStateCodec().decode(transition.canonicalStateBytes)
                } catch {
                    throw RuntimeSemanticEventCodecError.invalidPayload
                }
                guard RuntimeStoreManifestCodec.isSHA256Hex(transition.canonicalStateDigest),
                      transition.canonicalStateDigest == transition.canonicalStateDigest.lowercased(),
                      transition.canonicalStateDigest == LocalRuntimeStorageChecksum.sha256Hex(
                          for: transition.canonicalStateBytes
                      ),
                      decodedState.aggregate == transition.aggregate,
                      decodedState.revision == transition.resultingRevision,
                      decodedState.lifecycle == transition.lifecycle,
                      decodedState.transition == transition.transition,
                      decodedState.commandPayload == event.commandPayload,
                      decodedState.changedObjectIDs == event.mutation.changedObjectIDs,
                      decodedState.privacy == transition.privacy,
                      decodedState.localOnly == transition.localOnly,
                      (transition.lifecycle == .tombstoned) == (transition.tombstone != nil),
                      (transition.tombstone.map({ authority in
                          RuntimeStoreManifestCodec.isSHA256Hex(authority.predecessorDigest) &&
                              authority.predecessorDigest == authority.predecessorDigest.lowercased()
                      }) ?? true) else {
                    throw RuntimeSemanticEventCodecError.invalidPayload
                }
            }
        } else if event.mutation.aggregateTransitions.isEmpty == false || event.mutation.primaryAggregate != nil {
            throw RuntimeSemanticEventCodecError.invalidPayload
        }
        if envelope.payloadVersion >= 3 {
            guard let privacy = event.mutation.privacy,
                  let localOnly = event.mutation.localOnly,
                  event.mutation.aggregateTransitions.allSatisfy({ transition in
                      transition.privacy == privacy && transition.localOnly == localOnly
                  }) else {
                throw RuntimeSemanticEventCodecError.invalidPayload
            }
        }
        return RuntimeDecodedSemanticEvent(
            event: event,
            sourceBytes: bytes,
            sourcePayloadVersion: envelope.payloadVersion,
            wasUpcast: wasUpcast
        )
    }

    private func validatedEnvelope(_ bytes: Data) throws -> RuntimeSemanticEventWireEnvelope {
        guard bytes.count <= limits.maximumEnvelopeBytes else { throw RuntimeSemanticEventCodecError.envelopeTooLarge }
        let envelope: RuntimeSemanticEventWireEnvelope
        do {
            envelope = try decoder().decode(RuntimeSemanticEventWireEnvelope.self, from: bytes)
        } catch {
            if bytes.first == 0x7B, bytes.last != 0x7D {
                throw RuntimeSemanticEventCodecError.truncatedEnvelope
            }
            throw RuntimeSemanticEventCodecError.corruptEnvelope
        }
        if envelope.envelopeVersion > Self.currentEnvelopeVersion { throw RuntimeSemanticEventCodecError.futureEnvelopeVersion }
        guard envelope.envelopeVersion == Self.currentEnvelopeVersion else { throw RuntimeSemanticEventCodecError.unsupportedEnvelopeVersion }
        guard envelope.payload.count <= limits.maximumPayloadBytes else { throw RuntimeSemanticEventCodecError.payloadTooLarge }
        let canonical: Data
        do { canonical = try encoder.encode(envelope) } catch { throw RuntimeSemanticEventCodecError.malformedEnvelope }
        guard canonical == bytes else { throw RuntimeSemanticEventCodecError.nonCanonicalBytes }
        return envelope
    }

    private func validatedTypeAndVersion(_ envelope: RuntimeSemanticEventWireEnvelope) throws -> RuntimeSemanticEventTypeID {
        guard let typeID = RuntimeSemanticEventTypeID(rawValue: envelope.typeID) else {
            throw RuntimeSemanticEventCodecError.unknownType
        }
        if envelope.payloadVersion > typeID.latestPayloadVersion { throw RuntimeSemanticEventCodecError.futurePayloadVersion }
        guard RuntimeSemanticEventRegistry.supports(typeID: typeID, payloadVersion: envelope.payloadVersion) else {
            throw RuntimeSemanticEventCodecError.unsupportedPayloadVersion
        }
        return typeID
    }

    private func encodedPayload(_ event: RuntimeSemanticEvent) throws -> Data {
        switch event {
        case let .capture(value): try encoder.encode(value.payload)
        case let .goal(value): try encoder.encode(value.payload)
        case let .step(value): try encoder.encode(value.payload)
        case let .schedule(value): try encoder.encode(value.payload)
        case let .reminder(value): try encoder.encode(value.payload)
        case let .profile(value): try encoder.encode(value.payload)
        case let .history(value): try encoder.encode(value.payload)
        case let .repair(value): try encoder.encode(value.payload)
        case let .importDeletion(value): try encoder.encode(value.payload)
        case let .externalOperation(value): try encoder.encode(value.payload)
        case let .attachment(value): try encoder.encode(value.payload)
        case let .compensation(value): try encoder.encode(value.payload)
        }
    }

    private func decodeLatest(typeID: RuntimeSemanticEventTypeID, payload: Data) throws -> RuntimeSemanticEvent {
        if Self.compensationTypeIDs.contains(typeID) {
            let value: RuntimeCompensationMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            guard value.mutation.semanticType == typeID else {
                throw RuntimeSemanticEventCodecError.typeMismatch
            }
            return .compensation(.applied(value))
        }
        switch typeID.aggregateKind {
        case .capture:
            let value: RuntimeCaptureMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            return try captureEvent(typeID, value)
        case .goal:
            let value: RuntimeGoalMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            return try goalEvent(typeID, value)
        case .step:
            let value: RuntimeStepMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            return try stepEvent(typeID, value)
        case .schedule:
            let value: RuntimeScheduleMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            return try scheduleEvent(typeID, value)
        case .reminder:
            let value: RuntimeReminderMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            return try reminderEvent(typeID, value)
        case .profile:
            let value: RuntimeProfileMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            guard typeID == .profilePreferencesUpdated else { throw RuntimeSemanticEventCodecError.typeMismatch }
            return .profile(.preferencesUpdated(value))
        case .history:
            let value: RuntimeHistoryMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            return try historyEvent(typeID, value)
        case .repair:
            let value: RuntimeRepairMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            guard typeID == .repairRecovered else { throw RuntimeSemanticEventCodecError.typeMismatch }
            return .repair(.recovered(value))
        case .importDeletion:
            let value: RuntimeImportDeletionMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            return try importDeletionEvent(typeID, value)
        case .externalOperation:
            let value: RuntimeExternalOperationMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            return try externalEvent(typeID, value)
        case .attachment:
            let value: RuntimeAttachmentMutationPayload = try decodeCanonicalPayload(payload)
            try value.validate()
            return try attachmentEvent(typeID, value)
        }
    }

    private static let compensationTypeIDs: Set<RuntimeSemanticEventTypeID> = [
        .captureCreatedCompensated, .goalCreatedCompensated,
        .scheduleCreatedCompensated, .reminderCreatedCompensated,
    ]

    private func decodeCanonicalPayload<Value: Codable>(_ bytes: Data) throws -> Value {
        guard bytes.count <= limits.maximumPayloadBytes else { throw RuntimeSemanticEventCodecError.payloadTooLarge }
        let value: Value
        do { value = try decoder().decode(Value.self, from: bytes) }
        catch { throw RuntimeSemanticEventCodecError.invalidPayload }
        let canonical: Data
        do { canonical = try encoder.encode(value) } catch { throw RuntimeSemanticEventCodecError.invalidPayload }
        guard canonical == bytes else { throw RuntimeSemanticEventCodecError.nonCanonicalBytes }
        return value
    }

    private func captureEvent(_ id: RuntimeSemanticEventTypeID, _ value: RuntimeCaptureMutationPayload) throws -> RuntimeSemanticEvent {
        guard value.mutation.semanticType == id else { throw RuntimeSemanticEventCodecError.typeMismatch }
        return switch id {
        case .captureCreated: .capture(.created(value))
        case .captureCommitmentRouted: .capture(.commitmentRouted(value))
        case .captureAttachedToGoal: .capture(.attachedToGoal(value))
        case .captureMarkedWaiting: .capture(.markedWaiting(value))
        case .captureArchived: .capture(.archived(value))
        default: throw RuntimeSemanticEventCodecError.typeMismatch
        }
    }
    private func goalEvent(_ id: RuntimeSemanticEventTypeID, _ value: RuntimeGoalMutationPayload) throws -> RuntimeSemanticEvent {
        guard value.mutation.semanticType == id else { throw RuntimeSemanticEventCodecError.typeMismatch }
        return switch id {
        case .goalCreated: .goal(.created(value))
        case .goalUpdated: .goal(.updated(value))
        case .goalPrioritySet: .goal(.prioritySet(value))
        case .goalUrgencySet: .goal(.urgencySet(value))
        case .goalDeadlineSet: .goal(.deadlineSet(value))
        case .goalContextLensSet: .goal(.contextLensSet(value))
        case .goalContextLensCleared: .goal(.contextLensCleared(value))
        case .goalDeliverableAdded: .goal(.deliverableAdded(value))
        case .goalDeliverableRemoved: .goal(.deliverableRemoved(value))
        case .goalScopeItemAdded: .goal(.scopeItemAdded(value))
        case .goalScopeItemRemoved: .goal(.scopeItemRemoved(value))
        default: throw RuntimeSemanticEventCodecError.typeMismatch
        }
    }
    private func stepEvent(_ id: RuntimeSemanticEventTypeID, _ value: RuntimeStepMutationPayload) throws -> RuntimeSemanticEvent {
        guard value.mutation.semanticType == id else { throw RuntimeSemanticEventCodecError.typeMismatch }
        return switch id {
        case .stepSessionStarted: .step(.sessionStarted(value))
        case .stepCompleted: .step(.completed(value))
        case .stepDelayed: .step(.delayed(value))
        case .stepSplit: .step(.split(value))
        case .stepRecovered: .step(.recovered(value))
        case .stepTodayActionApplied: .step(.todayActionApplied(value))
        default: throw RuntimeSemanticEventCodecError.typeMismatch
        }
    }
    private func scheduleEvent(_ id: RuntimeSemanticEventTypeID, _ value: RuntimeScheduleMutationPayload) throws -> RuntimeSemanticEvent {
        guard value.mutation.semanticType == id else { throw RuntimeSemanticEventCodecError.typeMismatch }
        return switch id {
        case .scheduleItemCreated: .schedule(.itemCreated(value))
        case .scheduleItemScheduled: .schedule(.itemScheduled(value))
        case .scheduleStepPlaced: .schedule(.stepPlaced(value))
        case .scheduleWindowProtected: .schedule(.windowProtected(value))
        case .scheduleWindowCorrected: .schedule(.windowCorrected(value))
        case .scheduleMutationUndone: .schedule(.mutationUndone(value))
        case .scheduleRitualApplied: .schedule(.ritualApplied(value))
        case .scheduleCalendarWriteCommitted: .schedule(.calendarWriteCommitted(value))
        default: throw RuntimeSemanticEventCodecError.typeMismatch
        }
    }
    private func reminderEvent(_ id: RuntimeSemanticEventTypeID, _ value: RuntimeReminderMutationPayload) throws -> RuntimeSemanticEvent {
        guard value.mutation.semanticType == id else { throw RuntimeSemanticEventCodecError.typeMismatch }
        return switch id {
        case .reminderCreated: .reminder(.created(value))
        case .reminderUpdated: .reminder(.updated(value))
        case .reminderDeleted: .reminder(.deleted(value))
        default: throw RuntimeSemanticEventCodecError.typeMismatch
        }
    }
    private func attachmentEvent(_ id: RuntimeSemanticEventTypeID, _ value: RuntimeAttachmentMutationPayload) throws -> RuntimeSemanticEvent {
        guard value.mutation.semanticType == id else { throw RuntimeSemanticEventCodecError.typeMismatch }
        return switch id {
        case .attachmentLinked: .attachment(.linked(value))
        case .attachmentUnlinked: .attachment(.unlinked(value))
        case .attachmentRevisionReplaced: .attachment(.revisionReplaced(value))
        case .attachmentDeletionAuthorized: .attachment(.deletionAuthorized(value))
        case .attachmentQuarantined: .attachment(.quarantined(value))
        default: throw RuntimeSemanticEventCodecError.typeMismatch
        }
    }
    private func historyEvent(_ id: RuntimeSemanticEventTypeID, _ value: RuntimeHistoryMutationPayload) throws -> RuntimeSemanticEvent {
        guard value.mutation.semanticType == id else { throw RuntimeSemanticEventCodecError.typeMismatch }
        return switch id {
        case .historyRecommendationDismissed: .history(.recommendationDismissed(value))
        case .historyTodayReceiptRecorded: .history(.todayReceiptRecorded(value))
        default: throw RuntimeSemanticEventCodecError.typeMismatch
        }
    }
    private func importDeletionEvent(_ id: RuntimeSemanticEventTypeID, _ value: RuntimeImportDeletionMutationPayload) throws -> RuntimeSemanticEvent {
        guard value.mutation.semanticType == id else { throw RuntimeSemanticEventCodecError.typeMismatch }
        return switch id {
        case .objectDeleted: .importDeletion(.objectDeleted(value))
        case .memoryForgotten: .importDeletion(.memoryForgotten(value))
        default: throw RuntimeSemanticEventCodecError.typeMismatch
        }
    }
    private func externalEvent(_ id: RuntimeSemanticEventTypeID, _ value: RuntimeExternalOperationMutationPayload) throws -> RuntimeSemanticEvent {
        guard value.mutation.semanticType == id else { throw RuntimeSemanticEventCodecError.typeMismatch }
        return switch id {
        case .externalReminderRequested: .externalOperation(.reminderRequested(value))
        case .externalCalendarEventRequested: .externalOperation(.calendarEventRequested(value))
        default: throw RuntimeSemanticEventCodecError.typeMismatch
        }
    }

    private func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        decoder.dataDecodingStrategy = .base64
        decoder.nonConformingFloatDecodingStrategy = .throw
        return decoder
    }
}
