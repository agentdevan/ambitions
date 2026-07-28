import Foundation

extension AmbitionsCommandExecutor {
    func executeTimeCommand(_ command: AmbitionsCommand) async -> AmbitionsCommandExecutionResult {
        if command.commandUndoIntent != nil {
            return await executeTimeUndo(command)
        }
        guard let interval = timeInterval(command) else {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Time change is missing a valid start and end.",
                target: command.target,
                metadata: ["blockedBy": "time_interval_missing"]
            )
        }
        let summary: String
        switch command.typedPayload {
        case let .schedule(schedule):
            switch schedule.action {
            case .placeStep: summary = "Step placed in Time."
            case .protectWindow: summary = "Time window protected."
            case .correctWindow, .undo: summary = "Time window corrected."
            default: summary = "Time changed."
            }
        default:
            summary = "Time changed."
        }
        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: summary,
            route: .time,
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "timeMaterialization": "pending_authority_commit",
                "start": DomainTimestamp.string(from: interval.start),
                "end": DomainTimestamp.string(from: interval.end),
                "projectionReloadRequired": "true",
            ]
        )
    }

    private func executeTimeUndo(_ command: AmbitionsCommand) async -> AmbitionsCommandExecutionResult {
        guard let undo = command.commandUndoIntent,
              let originalCommandID = Self.commandID(fromReceiptID: undo.originalReceiptID.rawValue),
              let sqliteStore = runtimeEvents as? EventStoreSQLite,
              let authorityReceipt = try? await sqliteStore.authorityReceipt(commandID: originalCommandID),
              authorityReceipt.receiptID == undo.originalReceiptID.rawValue else {
            return timeUndoRejection(command, type: "time_undo_receipt_not_found")
        }
        let events = (try? await runtimeEvents?.fetchEvents(matching: .kind(.domainMutation), limit: nil)) ?? []
        let alreadyUndone = events.contains { envelope in
            guard case let .domainMutation(record) = envelope.event.payload,
                  let event = try? record.decodedEvent(),
                  case let .mutationUndone(value) = event else { return false }
            return value.originalReceiptID == undo.originalReceiptID.rawValue
        }
        guard alreadyUndone == false else {
            return timeUndoRejection(command, type: "time_undo_already_applied")
        }
        guard let currentVersion = try? await projectionStore?.fetchRecord(id: .time)?.cursor.sequence,
              currentVersion == undo.expectedProjectionVersion else {
            return timeUndoRejection(command, type: "time_undo_stale_projection")
        }
        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Time change undone.",
            route: .time,
            target: command.target,
            metadata: [
                "undoOriginalReceiptID": undo.originalReceiptID.rawValue,
                "expectedProjectionVersion": String(undo.expectedProjectionVersion),
                "timeMaterialization": "pending_authority_commit",
                "projectionReloadRequired": "true",
            ]
        )
    }

    private func timeUndoRejection(
        _ command: AmbitionsCommand,
        type: String
    ) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Undo could not be applied because Time changed or this receipt was already undone.",
            route: .time,
            target: command.target,
            metadata: ["rejectionType": type, "typedRejectionReceipt": "true"]
        )
    }

    func materializeTime(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext,
        committedResult: AmbitionsCommandExecutionResult
    ) async -> AmbitionsCommandExecutionResult {
        guard let runtimeEvents else { return committedResult }
        do {
            let envelopes = try await runtimeEvents.fetchEvents(matching: .kind(.domainMutation), limit: nil)
            let undoneReceiptIDs = Set(envelopes.compactMap { envelope -> String? in
                guard case let .domainMutation(record) = envelope.event.payload,
                      let event = try? record.decodedEvent(),
                      case let .mutationUndone(value) = event else { return nil }
                return value.originalReceiptID
            })
            let blocksByID = envelopes.reduce(into: [String: TimeBlock]()) { blocks, envelope in
                if let commandID = envelope.event.commandID,
                   undoneReceiptIDs.contains("runtime.receipt.\(commandID)") {
                    return
                }
                if let block = Self.timeBlock(envelope) {
                    blocks[block.id] = block
                }
            }
            let blocks = blocksByID.values.sorted { $0.id < $1.id }
            let store = LifeCalendarStore(fileURL: scheduleStoreURL())
            _ = try await store.replace(with: blocks, occurredAt: context.now)
            return committedResult.mergingMetadata([
                "timeMaterialization": "saved_post_authority",
                "timeMaterializedBlockCount": String(blocks.count),
            ])
        } catch {
            return committedResult.mergingMetadata([
                "timeMaterialization": "needs_recovery",
                "timeMaterializationError": String(describing: error),
            ])
        }
    }

    private static func commandID(fromReceiptID receiptID: String) -> String? {
        let prefix = "runtime.receipt."
        guard receiptID.hasPrefix(prefix), receiptID.count > prefix.count else { return nil }
        return String(receiptID.dropFirst(prefix.count))
    }

    private func timeInterval(_ command: AmbitionsCommand) -> (start: Date, end: Date)? {
        let placement = command.timePlacementCommandIntent
        let correction = command.timeCorrectionCommandIntent
        guard let start = parseDate(from: placement?.start ?? correction?.start),
              let end = parseDate(from: placement?.end ?? correction?.end),
              end > start else { return nil }
        return (start, end)
    }

    private static func timeBlock(_ envelope: RuntimeEventEnvelope) -> TimeBlock? {
        guard case let .domainMutation(record) = envelope.event.payload,
              let event = try? record.decodedEvent() else { return nil }
        switch event {
        case let .stepPlaced(value):
            guard let start = DomainTimestamp.date(from: value.start),
                  let end = DomainTimestamp.date(from: value.end), end > start else { return nil }
            return TimeBlock(
                id: value.timeBlockID,
                title: value.title ?? "Scheduled Step",
                start: start,
                end: end,
                kind: .scheduledStep,
                source: .eventJournal,
                stepID: value.stepID,
                goalID: value.goalID,
                commandID: envelope.event.commandID,
                eventID: envelope.id
            )
        case let .timeWindowProtected(value):
            return windowBlock(value, envelope: envelope, kind: .protected)
        case let .timeWindowCorrected(value):
            guard let kind = correctedBlockKind(reason: value.reason) else { return nil }
            return windowBlock(
                value,
                envelope: envelope,
                kind: kind,
                title: correctedBlockTitle(reason: value.reason)
            )
        default:
            return nil
        }
    }

    private static func correctedBlockKind(reason: String) -> TimeBlockKind? {
        switch TimeMutationActionKind(rawValue: reason) {
        case .notUsable: .unavailable
        case .needsMoreTime: .needsMoreTime
        case .keepClear: .keepClear
        case .makeTodayLighter: .lighterPressure
        case .addBuffer: .buffer
        case .none, .placeStep, .protectWindow: nil
        }
    }

    private static func correctedBlockTitle(reason: String) -> String {
        switch TimeMutationActionKind(rawValue: reason) {
        case .notUsable: "Not usable"
        case .needsMoreTime: "Needs more time"
        case .keepClear: "Keep this clear"
        case .makeTodayLighter: "Today made lighter"
        case .addBuffer: "Buffer added"
        case .none, .placeStep, .protectWindow: "Time corrected"
        }
    }

    private static func windowBlock(
        _ value: TimeWindowDomainEvent,
        envelope: RuntimeEventEnvelope,
        kind: TimeBlockKind,
        title: String? = nil
    ) -> TimeBlock? {
        guard let start = DomainTimestamp.date(from: value.start),
              let end = DomainTimestamp.date(from: value.end), end > start else { return nil }
        return TimeBlock(
            id: value.windowID,
            title: title ?? value.reason,
            start: start,
            end: end,
            kind: kind,
            source: .eventJournal,
            commandID: envelope.event.commandID,
            eventID: envelope.id
        )
    }
}
