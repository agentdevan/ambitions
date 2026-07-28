import Foundation

extension TodayCommandActionHandler {
    func emitTodayCommandEvidence(
        for action: TodayInlineAction,
        command: AmbitionsCommand,
        now: Date,
        goalID: String?,
        beforeFeedback: [GoalFeedbackEvent],
        afterFeedback: [GoalFeedbackEvent],
        beforeEvidence: [ProgressEvidence],
        afterEvidence: [ProgressEvidence],
        beforeCaptures: [Capture],
        afterCaptures: [Capture]
    ) async -> [String] {
        let beforeFeedbackIDs = Set(beforeFeedback.map(\.base.id))
        let beforeEvidenceIDs = Set(beforeEvidence.map(\.id))
        let newFeedback = afterFeedback.filter { beforeFeedbackIDs.contains($0.base.id) == false }
        let newEvidence = afterEvidence.filter { beforeEvidenceIDs.contains($0.id) == false }
        let newCaptures = newCaptures(before: beforeCaptures, after: afterCaptures)

        guard !newFeedback.isEmpty || !newEvidence.isEmpty || !newCaptures.isEmpty else {
            return []
        }
        guard let goalID else { return [] }

        var eventLedgerEntryIDs: [String] = []

        for event in newFeedback {
            let entry = EventLedgerEntry.fromFeedbackEvent(event, goalID: goalID, source: .today)
            do {
                try await repositories.eventLedger.append(entry)
                eventLedgerEntryIDs.append(entry.id)
            } catch {
                // Keep command behavior alive even if ledger emission fails.
            }
        }

        for evidence in newEvidence {
            let entry = EventLedgerEntry.fromProgressEvidence(evidence, source: .today)
            do {
                try await repositories.eventLedger.append(entry)
                eventLedgerEntryIDs.append(entry.id)
            } catch {
                // Keep command behavior alive even if ledger emission fails.
            }
        }

        for capture in newCaptures where action.kind == .quickLog {
            let entry = commandCaptureCreatedEntry(
                capture: capture,
                command: command,
                occurredAt: Self.iso.string(from: now)
            )
            do {
                try await repositories.eventLedger.append(entry)
                eventLedgerEntryIDs.append(entry.id)
            } catch {
                // Keep command behavior alive even if ledger emission fails.
            }
        }

        return eventLedgerEntryIDs
    }

    private func commandCaptureCreatedEntry(
        capture: Capture,
        command: AmbitionsCommand,
        occurredAt: String
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: "ledger.command.\(command.id)",
            kind: .captureCreated,
            occurredAt: occurredAt,
            source: eventLedgerSource(for: command.source),
            goalID: command.target.goalID,
            captureID: capture.id,
            title: "Capture created",
            summary: nil,
            semanticState: command.operation.rawValue,
            tone: .neutral,
            trust: EventLedgerTrustMetadata(isUserConfirmed: command.actor == .user),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: command.id,
                    kind: .externalCommand,
                    occurredAt: command.requestedAt,
                    summary: command.operation.rawValue
                ),
                EventLedgerEvidenceReference(
                    id: capture.id,
                    kind: .capture,
                    occurredAt: capture.createdAt,
                    summary: "quick_capture"
                )
            ],
            metadata: [
                "commandOperation": command.operation.rawValue,
                "commandSource": command.source.rawValue,
                "sourceSurface": command.sourceSurface ?? ""
            ].filter { $0.value.isEmpty == false },
            payload: [
                "captureID": capture.id,
                "contextLens": command.content.contextLens?.rawValue ?? "",
                "commitmentKind": command.content.commitmentKind?.rawValue ?? ""
            ].filter { $0.value.isEmpty == false },
            privacy: .privateUserText
        )
    }

    private func eventLedgerSource(for source: AmbitionsCommandSource) -> EventLedgerSource {
        switch source {
        case .today:
            return .today
        case .goals, .goalDetail:
            return .goals
        case .capture:
            return .capture
        case .time:
            return .plan
        case .you:
            return .you
        case .reviews:
            return .you
        case .widget, .liveActivity, .appIntent, .notification, .deepLink, .system:
            return .system
        }
    }
}
