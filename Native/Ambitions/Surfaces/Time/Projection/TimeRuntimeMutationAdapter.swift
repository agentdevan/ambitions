import Foundation

/// The Time surface's narrow mutation boundary. It accepts only the Time
/// schedule actions that have an authority-owned semantic event and refuses
/// to render a success until the committed Time projection and the post-
/// authority calendar materialization agree with the receipt.
enum TimeRuntimeMutationAdapterError: Error, Equatable {
    case unsupportedCommand
    case placementIdentityMissing
    case placementReceiptMismatch
    case authorityRejected(String)
    case receiptEvidenceMissing
    case timeMaterializationNeedsRecovery
    case projectionMaterializationNeedsRecovery
    case projectionReceiptMismatch
    case preflightProjectionUnavailable
    case preflightProjectionMismatch
    case preflightExpectedRevisionMissing
}

struct TimeRuntimeMutationCommit: Sendable, Equatable {
    let result: AmbitionsCommandExecutionResult
    let receiptID: String
    let projection: RuntimeProjectionSnapshot
}

/// A non-mutating admission record for a proposed Time change. It binds the
/// proposal to an already-read Time projection, but is intentionally not a
/// commit token: durable acceptance still belongs to the runtime command
/// transaction.
struct TimeRuntimeMutationPreflight: Sendable, Equatable {
    let commandID: String
    let expectedProjectionID: String
    let expectedEventSequence: Int64
    let expectedCursorChecksum: String
    let expectedPayloadChecksum: String
    let affectedObjectIDs: [String]
}

/// This adapter has no persistence fallback. Its only writer is the injected
/// `RuntimeCommandClient`, which is already selected by the application
/// authority session. In generation-v8 mode the current composition returns a
/// blocked result until a v8 command bridge is supplied, so Time cannot fall
/// back to legacy Step or calendar writes.
struct TimeRuntimeMutationAdapter: Sendable {
    private let runtimeClient: RuntimeCommandClient

    init(runtimeClient: RuntimeCommandClient) {
        self.runtimeClient = runtimeClient
    }

    /// Verifies that a reviewed Time proposal still names the exact Time
    /// projection it was based on. Callers must pass the snapshot captured at
    /// review time; this method never fabricates a baseline from the latest
    /// projection. Current reflow presentation has no accepted-command path,
    /// so it can use this only for a non-mutating diff/preflight.
    func preflight(
        _ command: AmbitionsCommand,
        expectedTimeProjection: RuntimeProjectionSnapshot
    ) async throws -> TimeRuntimeMutationPreflight {
        try validate(command)
        guard command.expectedRevision != .absent else {
            throw TimeRuntimeMutationAdapterError.preflightExpectedRevisionMissing
        }
        guard expectedTimeProjection.projectionID == ProjectionID.time.rawValue else {
            throw TimeRuntimeMutationAdapterError.preflightProjectionMismatch
        }
        let observed: RuntimeProjectionSnapshot
        do {
            observed = try await runtimeClient.projection(.time)
        } catch {
            throw TimeRuntimeMutationAdapterError.preflightProjectionUnavailable
        }
        guard observed.projectionID == expectedTimeProjection.projectionID,
              observed.eventSequence == expectedTimeProjection.eventSequence,
              observed.cursorChecksum == expectedTimeProjection.cursorChecksum,
              observed.payloadChecksum == expectedTimeProjection.payloadChecksum else {
            throw TimeRuntimeMutationAdapterError.preflightProjectionMismatch
        }
        return TimeRuntimeMutationPreflight(
            commandID: command.id,
            expectedProjectionID: expectedTimeProjection.projectionID,
            expectedEventSequence: expectedTimeProjection.eventSequence,
            expectedCursorChecksum: expectedTimeProjection.cursorChecksum,
            expectedPayloadChecksum: expectedTimeProjection.payloadChecksum,
            affectedObjectIDs: Array(Set([
                command.target.goalID,
                command.target.stepID,
                command.target.timeID,
            ].compactMap { $0 })).sorted()
        )
    }

    func execute(
        _ command: AmbitionsCommand,
        now: Date
    ) async throws -> TimeRuntimeMutationCommit {
        try validate(command)
        guard case .exact = command.expectedRevision else {
            throw TimeRuntimeMutationAdapterError.preflightExpectedRevisionMissing
        }
        let result = await runtimeClient.execute(
            command,
            CommandExecutionContext(now: now, actor: .user, sourceSurface: "Time")
        )
        guard result.status == .succeeded else {
            throw TimeRuntimeMutationAdapterError.authorityRejected(
                result.metadata["rejectionType"] ?? result.metadata["blockedBy"] ?? result.summary
            )
        }
        guard RuntimeTransactionCommitPolicy.hasCommittedEvidence(result),
              let receiptID = result.metadata["runtimeReceiptID"],
              receiptID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              let disposition = result.metadata["runtimeTransactionDisposition"],
              RuntimeTransactionCommitDisposition(rawValue: disposition) != nil else {
            throw TimeRuntimeMutationAdapterError.receiptEvidenceMissing
        }
        try validateCommittedPlacement(command, result: result)
        guard result.metadata["runtimeProjectionStoreStatus"] == "saved" else {
            throw TimeRuntimeMutationAdapterError.projectionMaterializationNeedsRecovery
        }
        guard result.metadata["timeMaterialization"] == "saved_post_authority" else {
            throw TimeRuntimeMutationAdapterError.timeMaterializationNeedsRecovery
        }
        let projection: RuntimeProjectionSnapshot
        do {
            projection = try await runtimeClient.projection(.time)
        } catch {
            throw TimeRuntimeMutationAdapterError.projectionMaterializationNeedsRecovery
        }
        guard Self.projection(projection, matchesCommittedTimeCursorIn: result.metadata) else {
            throw TimeRuntimeMutationAdapterError.projectionReceiptMismatch
        }
        return TimeRuntimeMutationCommit(result: result, receiptID: receiptID, projection: projection)
    }

    private func validate(_ command: AmbitionsCommand) throws {
        guard case let .schedule(schedule) = command.typedPayload else {
            throw TimeRuntimeMutationAdapterError.unsupportedCommand
        }
        switch schedule.action {
        case .placeStep:
            // Step and schedule placement are one semantic transaction. Both
            // identities must be present before admission; neither a calendar
            // side effect nor a partial Step write is a valid substitute.
            guard let stepID = command.target.stepID,
                  stepID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
                  let timeID = command.target.timeID,
                  timeID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
                  command.timePlacementCommandIntent != nil else {
                throw TimeRuntimeMutationAdapterError.placementIdentityMissing
            }
        case .protectWindow, .correctWindow, .undo:
            break
        case .createItem, .schedule, .ritual, .calendarWrite:
            throw TimeRuntimeMutationAdapterError.unsupportedCommand
        }
    }

    private func validateCommittedPlacement(
        _ command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult
    ) throws {
        guard case let .schedule(schedule) = command.typedPayload,
              case .placeStep = schedule.action else { return }
        guard let expectedStepID = command.target.stepID,
              let expectedTimeID = command.target.timeID,
              result.target?.stepID == expectedStepID,
              result.target?.timeID == expectedTimeID else {
            throw TimeRuntimeMutationAdapterError.placementReceiptMismatch
        }
        let affected = Set(
            result.metadata["runtimeAffectedObjectIDs"]?
                .split(separator: ",")
                .map(String.init) ?? []
        )
        guard affected.contains(expectedStepID), affected.contains(expectedTimeID) else {
            throw TimeRuntimeMutationAdapterError.placementReceiptMismatch
        }
    }

    private static func projection(
        _ projection: RuntimeProjectionSnapshot,
        matchesCommittedTimeCursorIn metadata: [String: String]
    ) -> Bool {
        let ids = metadata["runtimeMaterializedProjectionCursorIDs"]?.split(separator: ",").map(String.init) ?? []
        let sequences = metadata["runtimeMaterializedProjectionCursorSequences"]?.split(separator: ",").compactMap { Int64($0) } ?? []
        let checksums = metadata["runtimeMaterializedProjectionCursorChecksums"]?.split(separator: ",").map(String.init) ?? []
        guard ids.count == sequences.count,
              ids.count == checksums.count,
              let timeIndex = ids.firstIndex(of: ProjectionID.time.rawValue) else {
            return false
        }
        return projection.projectionID == ProjectionID.time.rawValue &&
            projection.eventSequence == sequences[timeIndex] &&
            projection.cursorChecksum == checksums[timeIndex]
    }
}
