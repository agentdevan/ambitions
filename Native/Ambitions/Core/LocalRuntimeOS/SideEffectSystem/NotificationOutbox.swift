import Foundation

enum NotificationOutboxOutcome: String, Sendable, Equatable, Hashable {
    case authorizationMissing
    case scheduled
    case cleared
    case refreshFailed

    var status: SideEffectLedgerStatus {
        switch self {
        case .scheduled, .cleared:
            return .recordedLocalOnly
        case .authorizationMissing:
            return .blocked
        case .refreshFailed:
            return .failedSafely
        }
    }

    var requiresConfirmation: Bool {
        self == .authorizationMissing
    }

    var blockedFacts: [String] {
        switch self {
        case .authorizationMissing:
            return ["Notification authorization is required to refresh local reminders."]
        default:
            return []
        }
    }

    var degradedFacts: [String] {
        switch self {
        case .refreshFailed:
            return ["Notification snapshot could not be loaded; no schedule refresh was applied."]
        default:
            return []
        }
    }

    func reasons(requestWasScheduled: Bool) -> [SafeAutomationPolicyReason] {
        guard self == .scheduled || self == .cleared else {
            return self == .authorizationMissing ? [] : [.noChangeNeeded]
        }
        return requestWasScheduled ? [] : [.noChangeNeeded]
    }
}

struct NotificationOutbox: Sendable {
    private let recorder: (any SideEffectOutboxing)?

    init(recorder: (any SideEffectOutboxing)?) {
        self.recorder = recorder
    }

    func recordRefresh(
        outcome: NotificationOutboxOutcome,
        now: Date,
        requestIdentifier: String?
    ) async {
        guard let recorder else { return }
        let requestWasScheduled = requestIdentifier?.isEmpty == false
        let request = SideEffectOutboxRequest(
            id: "notification.\(outcome.rawValue).\(Int(now.timeIntervalSince1970))",
            effectKind: .notification,
            actionKind: .noOp,
            sourceDomain: .system,
            requestedAt: now,
            externalEffect: false,
            requiresConfirmation: outcome.requiresConfirmation,
            commitRequirement: .committedProjection,
            requestedStatus: outcome.status,
            requestedBoundary: .localOnly,
            reasons: outcome.reasons(requestWasScheduled: requestWasScheduled),
            blockedFacts: outcome.blockedFacts,
            degradedFacts: outcome.degradedFacts,
            receiptID: requestIdentifier.map { "notification-receipt.\($0)" }
        )
        _ = try? await recorder.enqueue(request)
    }
}
