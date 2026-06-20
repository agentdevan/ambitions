import Foundation

enum ExecutionMode: String, Codable, Sendable {
    case sprint
    case standard
    case maintenance
    case recovery
}

enum NarrativeMomentum: String, Codable, Sendable {
    case stabilizing
    case building
    case recovering
    case waiting
    case accelerating
}

enum CauseOfDrift: String, Codable, Sendable {
    case avoidance
    case oversizedStep = "oversized_step"
    case timingPressure = "timing_pressure"
    case missingContext = "missing_context"
    case unclearAction = "unclear_action"
    case missingEvidence = "missing_evidence"
    case wrongPlanFit = "wrong_plan_fit"
    case externalDependency = "external_dependency"
    case notReady = "not_ready"
}

enum RecommendationConfidence: String, Codable, Sendable {
    case low
    case medium
    case high

    static func label(for confidence: Double) -> RecommendationConfidence {
        let bounded = min(max(confidence, 0), 1)
        switch bounded {
        case ..<0.4:
            return .low
        case ..<0.75:
            return .medium
        default:
            return .high
        }
    }
}

enum DomainIdentifier {
    static func prefixed(_ prefix: String, uuid: UUID = UUID()) -> String {
        "\(prefix)-\(uuid.uuidString.lowercased())"
    }
}

enum DomainTimestamp {
    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }

    static func date(from value: String) -> Date? {
        formatter.date(from: value) ?? fallbackFormatter.date(from: value)
    }

    private static var formatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }

    private static var fallbackFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }
}

protocol GoalRescheduling: Sendable {
    func decide(_ input: RescheduleEngineInput) -> RescheduleDecision
}

protocol GoalOrchestrating: Sendable {
    func compileGoal(_ rawInput: String, context: GoalEngineOrchestrationContext) -> GoalOrchestrationResult
}

enum SyncAvailability: String, Codable, Sendable {
    case localOnly = "local_only"
}

struct SyncState: Sendable, Equatable {
    let availability: SyncAvailability
    let lastSyncAt: String?

    static let localOnly = SyncState(availability: .localOnly, lastSyncAt: nil)
}

protocol SyncServicing: Sendable {
    func currentState() async -> SyncState
}

struct LocalOnlySyncService: SyncServicing {
    func currentState() async -> SyncState {
        .localOnly
    }
}
