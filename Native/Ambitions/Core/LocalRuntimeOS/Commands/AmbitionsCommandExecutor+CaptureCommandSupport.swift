import Foundation

extension CapturePriorityHints {
    init(commandHints: AmbitionsCommandPriorityHints) {
        self.init(
            importance: commandHints.importance,
            urgency: commandHints.urgency,
            consequence: commandHints.consequence,
            deadline: commandHints.deadline,
            effort: commandHints.effort,
            contextFit: commandHints.contextFit,
            goalSupporting: commandHints.goalRelationship != nil
        )
    }
}

extension EventLedgerEntry {
    static func commandCaptureCreated(
        command: AmbitionsCommand,
        capture: Capture,
        occurredAt: String
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: "ledger.command.\(command.id)",
            kind: .captureCreated,
            occurredAt: occurredAt,
            source: eventSource(for: command.source),
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

    static func eventSource(for source: AmbitionsCommandSource) -> EventLedgerSource {
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
