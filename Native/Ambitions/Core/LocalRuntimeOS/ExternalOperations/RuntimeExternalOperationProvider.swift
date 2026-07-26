import Foundation

protocol RuntimeExternalOperationProvider: Sendable {
    var providerID: RuntimeExternalProviderID { get }
    var supportedKind: RuntimeExternalEffectKind { get }

    func execute(
        _ request: RuntimeExternalProviderExecutionRequest
    ) async -> RuntimeExternalProviderExecutionOutcome

    func cancel(
        _ request: RuntimeExternalProviderCancellationRequest
    ) async -> RuntimeExternalProviderCancellationOutcome

    func reconcile(
        _ request: RuntimeExternalProviderReconciliationRequest
    ) async -> RuntimeExternalProviderReconciliationOutcome

}

struct RuntimeExternalProviderRegistry: Sendable {
    private let providersByKind: [RuntimeExternalEffectKind: any RuntimeExternalOperationProvider]

    init(providers: [any RuntimeExternalOperationProvider]) throws {
        var byKind: [RuntimeExternalEffectKind: any RuntimeExternalOperationProvider] = [:]
        var providerIDs = Set<RuntimeExternalProviderID>()
        for provider in providers {
            guard byKind[provider.supportedKind] == nil,
                  providerIDs.insert(provider.providerID).inserted else {
                throw RuntimeCanonicalExternalOperationError.invalidCreation
            }
            byKind[provider.supportedKind] = provider
        }
        guard Set(byKind.keys) == Set([.reminder, .calendarEvent]) else {
            throw RuntimeCanonicalExternalOperationError.providerUnavailable
        }
        providersByKind = byKind
    }

    func provider(
        for kind: RuntimeExternalEffectKind,
        expectedID: RuntimeExternalProviderID
    ) throws -> any RuntimeExternalOperationProvider {
        guard let provider = providersByKind[kind], provider.providerID == expectedID else {
            throw RuntimeCanonicalExternalOperationError.providerUnavailable
        }
        return provider
    }
}

enum RuntimeExternalProviderRouting {
    static func providerID(for kind: RuntimeExternalEffectKind) -> RuntimeExternalProviderID {
        switch kind {
        case .reminder:
            RuntimeExternalProviderID(validated: "apple.eventkit.reminders.v1")
        case .calendarEvent:
            RuntimeExternalProviderID(validated: "apple.eventkit.calendar.v1")
        }
    }
}

private extension RuntimeExternalProviderID {
    init(validated value: String) {
        rawValue = value
    }
}

enum RuntimeExternalRetryDecision: Sendable, Equatable {
    case schedule(Date)
    case exhausted
    case invalidInput
}

struct RuntimeExternalRetryPolicy: Sendable, Equatable {
    let version: Int
    let maximumAttempts: Int
    let baseDelay: TimeInterval
    let maximumDelay: TimeInterval
    let jitterFraction: Double

    init(
        version: Int = 1,
        maximumAttempts: Int = RuntimeExternalOperationLimits.maximumExecutionAttempts,
        baseDelay: TimeInterval = 5,
        maximumDelay: TimeInterval = 15 * 60,
        jitterFraction: Double = 0.2
    ) throws {
        guard version > 0, maximumAttempts > 0,
              maximumAttempts <= RuntimeExternalOperationLimits.maximumExecutionAttempts,
              baseDelay.isFinite, maximumDelay.isFinite, jitterFraction.isFinite,
              baseDelay > 0, maximumDelay >= baseDelay,
              jitterFraction >= 0, jitterFraction <= 1 else {
            throw RuntimeCanonicalExternalOperationError.invalidCreation
        }
        self.version = version
        self.maximumAttempts = maximumAttempts
        self.baseDelay = baseDelay
        self.maximumDelay = maximumDelay
        self.jitterFraction = jitterFraction
    }

    func decision(
        afterAttempt attempt: Int,
        now: Date,
        deterministicUnitInterval: Double
    ) -> RuntimeExternalRetryDecision {
        guard attempt < maximumAttempts else { return .exhausted }
        guard attempt > 0, now.timeIntervalSince1970.isFinite,
              now.timeIntervalSince1970 >= 0,
              deterministicUnitInterval.isFinite,
              deterministicUnitInterval >= 0,
              deterministicUnitInterval <= 1 else { return .invalidInput }
        let exponent = max(0, attempt - 1)
        let uncapped = baseDelay * pow(2, Double(exponent))
        let capped = min(maximumDelay, uncapped)
        let multiplier = 1 + ((deterministicUnitInterval * 2) - 1) * jitterFraction
        let rawDelayMilliseconds = capped * multiplier * 1_000
        let rawNowMilliseconds = now.timeIntervalSince1970 * 1_000
        let conservativeIntegerBound = 9_000_000_000_000_000_000.0
        guard rawDelayMilliseconds.isFinite, rawDelayMilliseconds >= 1,
              rawDelayMilliseconds < conservativeIntegerBound,
              rawNowMilliseconds < conservativeIntegerBound else {
            return .invalidInput
        }
        let nowMilliseconds = Int64(rawNowMilliseconds.rounded())
        let delayMilliseconds = max(1, Int64(rawDelayMilliseconds.rounded()))
        let (dueMilliseconds, overflow) = nowMilliseconds.addingReportingOverflow(delayMilliseconds)
        guard overflow == false else { return .invalidInput }
        return .schedule(Date(timeIntervalSince1970: Double(dueMilliseconds) / 1_000))
    }
}

enum RuntimeExternalRetryPolicyAuthority {
    static let currentVersion = 1

    static func resolve(version: Int) throws -> RuntimeExternalRetryPolicy {
        switch version {
        case 1:
            return try RuntimeExternalRetryPolicy(
                version: 1,
                maximumAttempts: RuntimeExternalOperationLimits.maximumExecutionAttempts,
                baseDelay: 5,
                maximumDelay: 15 * 60,
                jitterFraction: 0.2
            )
        default:
            throw RuntimeCanonicalExternalOperationError.invalidCreation
        }
    }

    static func requireExact(
        _ candidate: RuntimeExternalRetryPolicy,
        persistedVersion: Int
    ) throws -> RuntimeExternalRetryPolicy {
        let resolved = try resolve(version: persistedVersion)
        guard candidate == resolved else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        return resolved
    }
}

struct RuntimeExternalTokenClient: Sendable {
    let nextLeaseToken: @Sendable (RuntimeExternalOperationID, UInt64) -> RuntimeExternalLeaseToken
    let nextAttemptID: @Sendable (RuntimeExternalOperationID, Int) -> RuntimeExternalAttemptID
}

struct RuntimeExternalJitterClient: Sendable {
    let unitInterval: @Sendable (RuntimeExternalOperationID, Int) -> Double
}
