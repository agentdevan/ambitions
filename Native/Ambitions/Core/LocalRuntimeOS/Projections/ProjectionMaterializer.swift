import Foundation

struct ProjectionEventRecord: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let cursor: RuntimeEventCursor
    let kind: RuntimeEventKind
    let commandID: String?
    let actor: AmbitionsCommandActor
    let source: AmbitionsCommandSource
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let target: AmbitionsCommandTarget
    let occurredAt: String
    let summary: String
    let resultStatus: AmbitionsCommandExecutionStatus?
    let route: AmbitionsCommandDestination?
    let objectIDs: [String]
    let provenanceIDs: [String]
    let metadata: [String: String]

    init(envelope: RuntimeEventEnvelope) {
        id = envelope.id
        cursor = envelope.cursor
        kind = envelope.event.kind
        commandID = envelope.event.commandID
        actor = envelope.event.actor
        source = envelope.event.source
        privacy = envelope.event.privacy
        localOnly = envelope.event.localOnly
        target = envelope.event.target
        occurredAt = envelope.event.occurredAt

        let payloadSummary = Self.summary(for: envelope.event.payload)
        summary = payloadSummary.summary
        resultStatus = payloadSummary.resultStatus
        route = payloadSummary.route
        objectIDs = Self.normalized(Self.targetObjectIDs(envelope.event.target) + payloadSummary.objectIDs)
        provenanceIDs = Self.normalized(payloadSummary.provenanceIDs)
        metadata = payloadSummary.metadata.merging([
            "localOnly": String(envelope.event.localOnly),
            "runtimeEventChecksum": envelope.checksum,
            "runtimeEventSequence": String(envelope.sequence)
        ], uniquingKeysWith: { _, new in new })
    }

    var isPrivacySafeForExternalSurface: Bool {
        switch privacy {
        case .standard, .calendarDerived, .syncMetadata:
            return true
        case .sensitive, .privateUserText:
            return false
        }
    }

    private static func targetObjectIDs(_ target: AmbitionsCommandTarget) -> [String] {
        [
            target.goalID,
            target.captureID,
            target.timeID,
            target.reviewID,
            target.stepID,
            target.deliverableID,
            target.scopeItemID,
            target.recommendationID,
            target.explanationID
        ].compactMap { $0 }
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }

    // swiftlint:disable:next large_tuple
    private static func summary(for payload: RuntimeEventPayload) -> (
        summary: String,
        resultStatus: AmbitionsCommandExecutionStatus?,
        route: AmbitionsCommandDestination?,
        objectIDs: [String],
        provenanceIDs: [String],
        metadata: [String: String]
    ) {
        switch payload {
        case let .commandExecution(command):
            return (
                command.resultSummary,
                command.resultStatus,
                command.resultRoute,
                [command.commandRecordID].compactMap { $0 },
                command.eventLedgerEntryIDs + command.recommendationExplanationIDs,
                command.resultMetadata.merging([
                    "commandKind": command.commandKind.rawValue,
                    "resultStatus": command.resultStatus.rawValue
                ], uniquingKeysWith: { _, new in new })
            )
        case let .closureRecorded(closure):
            return (
                closure.closureState,
                nil,
                nil,
                [closure.closureID, closure.objectID] + closure.receiptIDs,
                closure.receiptIDs,
                ["closureState": closure.closureState]
            )
        case let .correctionRecorded(correction):
            return (
                correction.correctionKind,
                nil,
                nil,
                [correction.correctionID, correction.objectID] + [correction.supersedesEventID].compactMap { $0 },
                [correction.supersedesEventID].compactMap { $0 },
                ["correctionKind": correction.correctionKind]
            )
        case let .captureRouteDecided(route):
            return (
                route.decisionSummary,
                nil,
                nil,
                [route.captureID],
                [],
                [
                    "captureRoute": route.route.rawValue,
                    "captureKind": route.kind.rawValue
                ]
            )
        case let .timePlacementProposed(placement):
            return (
                placement.placementSummary,
                nil,
                .time,
                [placement.proposalID] + [placement.stepID, placement.timeBlockID].compactMap { $0 },
                [],
                [
                    "proposalID": placement.proposalID,
                    "stepID": placement.stepID ?? "",
                    "timeBlockID": placement.timeBlockID ?? ""
                ].filter { $0.value.isEmpty == false }
            )
        case let .proofAttached(proof):
            return (
                "Proof attached",
                nil,
                nil,
                [proof.proofID, proof.objectID] + proof.sourceRecordIDs,
                proof.sourceRecordIDs,
                ["proofID": proof.proofID]
            )
        case let .tombstoneRecorded(tombstone):
            return (
                tombstone.reason,
                nil,
                nil,
                [tombstone.tombstoneID, tombstone.objectID] + [tombstone.lineageID, tombstone.supersededByObjectID].compactMap { $0 },
                [tombstone.lineageID, tombstone.supersededByObjectID].compactMap { $0 },
                [
                    "objectFamily": tombstone.objectFamily.rawValue,
                    "objectID": tombstone.objectID
                ]
            )
        case let .compactionSnapshot(snapshot):
            return (
                "Compacted \(snapshot.eventCount) runtime events",
                nil,
                nil,
                [snapshot.cursor.eventID],
                [snapshot.cursor.eventID],
                [
                    "eventCount": String(snapshot.eventCount),
                    "checksumHead": snapshot.checksumHead
                ]
            )
        case let .domainMutation(record):
            let decodedEvent = try? record.decodedEvent()
            return (
                record.typeID,
                nil,
                nil,
                decodedEvent.map(Self.objectIDs(for:)) ?? [],
                [],
                ["domainEventTypeID": record.typeID, "domainEventSchemaVersion": String(record.schemaVersion)]
            )
        }
    }

    private static func objectIDs(for event: RuntimeDomainEvent) -> [String] {
        switch event {
        case let .captureCreated(value): [value.captureID]
        case let .stepPlaced(value): [value.stepID, value.timeBlockID]
        case let .timeWindowProtected(value), let .timeWindowCorrected(value): [value.windowID]
        case let .mutationUndone(value): value.affectedObjectIDs
        case let .todayReceiptRecorded(value):
            value.receipt.affectedObjects.map(\.id)
        case let .todayGoalStepActionApplied(value):
            [value.goalID, value.stepID]
        case let .timeRitualActionApplied(value):
            [value.goalID, value.stepID]
        case let .captureGoalHandoffApplied(value):
            [value.captureID, value.goalID]
        }
    }
}

struct ProjectionBuildContext {
    let definition: ProjectionDefinition
    let records: [ProjectionEventRecord]
    let materializedAt: String
    let previousCursor: ProjectionCursor?

    func cursor(payloadFingerprint: String) throws -> ProjectionCursor {
        try ProjectionChecksum.cursor(
            projectionID: definition.id,
            definition: definition,
            materializedAt: materializedAt,
            records: records,
            payloadFingerprint: payloadFingerprint
        )
    }

    func invalidation(nextCursor: ProjectionCursor) -> ProjectionInvalidation {
        let latest = records.last
        let reason: ProjectionInvalidationReason = latest?.kind == .tombstoneRecorded ? .tombstoneObserved : .eventAppended
        return ProjectionInvalidation(
            projectionID: definition.id,
            reason: latest == nil ? .fullRebuildRequested : reason,
            eventID: latest?.id,
            eventKind: latest?.kind,
            previousCursor: previousCursor,
            nextCursor: nextCursor,
            occurredAt: latest?.occurredAt ?? materializedAt,
            explanation: latest == nil
                ? "Projection rebuilt with no matching runtime events."
                : "Projection materialized from runtime event \(latest?.id ?? "unknown")."
        )
    }

    func diff(nextCursor: ProjectionCursor) -> ProjectionDiff {
        let previousSequence = previousCursor?.sequence ?? 0
        return ProjectionDiff(
            projectionID: definition.id,
            previousCursor: previousCursor,
            nextCursor: nextCursor,
            addedEventIDs: records.filter { $0.cursor.sequence > previousSequence }.map(\.id)
        )
    }
}

struct ProjectionMaterializationBatch: Equatable {
    let today: TodayProjection
    let goals: GoalsProjection
    let time: TimeProjection
    let you: YouProjection
    let search: SearchProjection
    let widget: WidgetProjection
    let appIntent: AppIntentProjection
    let receipt: ReceiptProjection
    let privacy: PrivacyProjection
    let invalidations: [ProjectionInvalidation]
    let diffs: [ProjectionDiff]

    var cursors: [ProjectionID: ProjectionCursor] {
        [
            .today: today.cursor,
            .goals: goals.cursor,
            .time: time.cursor,
            .you: you.cursor,
            .search: search.cursor,
            .widget: widget.cursor,
            .appIntent: appIntent.cursor,
            .receipt: receipt.cursor,
            .privacy: privacy.cursor
        ]
    }
}

struct ProjectionMaterializer {
    let store: any RuntimeEventStore

    func materializeAll(
        previousCursors: [ProjectionID: ProjectionCursor] = [:],
        materializedAt: String
    ) async throws -> ProjectionMaterializationBatch {
        let definitions = Dictionary(uniqueKeysWithValues: ProjectionDefinition.allCanonical.map { ($0.id, $0) })
        let allEnvelopes = try await store.fetchEvents(matching: .all, limit: nil)
        let records = allEnvelopes.map(ProjectionEventRecord.init)

        func context(for id: ProjectionID) throws -> ProjectionBuildContext {
            guard let definition = definitions[id] else {
                throw ProjectionMaterializerError.missingDefinition(id)
            }
            let accepted = zip(allEnvelopes, records)
                .filter { envelope, _ in definition.accepts(envelope) }
                .map { _, record in record }
            return ProjectionBuildContext(
                definition: definition,
                records: accepted,
                materializedAt: materializedAt,
                previousCursor: previousCursors[id]
            )
        }

        let today = try TodayProjection(context: context(for: .today))
        let goals = try GoalsProjection(context: context(for: .goals))
        let time = try TimeProjection(context: context(for: .time))
        let you = try YouProjection(context: context(for: .you))
        let search = try SearchProjection(context: context(for: .search))
        let widget = try WidgetProjection(context: context(for: .widget))
        let appIntent = try AppIntentProjection(context: context(for: .appIntent))
        let receipt = try ReceiptProjection(context: context(for: .receipt))
        let privacy = try PrivacyProjection(context: context(for: .privacy))

        let contexts = [
            try context(for: .today),
            try context(for: .goals),
            try context(for: .time),
            try context(for: .you),
            try context(for: .search),
            try context(for: .widget),
            try context(for: .appIntent),
            try context(for: .receipt),
            try context(for: .privacy)
        ]
        let cursors = [
            today.cursor,
            goals.cursor,
            time.cursor,
            you.cursor,
            search.cursor,
            widget.cursor,
            appIntent.cursor,
            receipt.cursor,
            privacy.cursor
        ]

        return ProjectionMaterializationBatch(
            today: today,
            goals: goals,
            time: time,
            you: you,
            search: search,
            widget: widget,
            appIntent: appIntent,
            receipt: receipt,
            privacy: privacy,
            invalidations: zip(contexts, cursors).map { context, cursor in
                context.invalidation(nextCursor: cursor)
            },
            diffs: zip(contexts, cursors).map { context, cursor in
                context.diff(nextCursor: cursor)
            }
        )
    }
}

enum ProjectionMaterializerError: Error, Equatable {
    case missingDefinition(ProjectionID)
}
