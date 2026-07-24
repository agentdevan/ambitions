import Foundation

public struct FaultToken: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// A generic deterministic fault helper for package and consumer tests.
public actor DeterministicFaultInjector {
    private let failureOccurrences: [FaultToken: Int]
    private var observationCounts: [FaultToken: Int] = [:]

    public init(failureOccurrences: [FaultToken: Int]) {
        self.failureOccurrences = failureOccurrences.filter { $0.value > 0 }
    }

    public func checkpoint(_ token: FaultToken) throws {
        let observationCount = observationCounts[token, default: 0] + 1
        observationCounts[token] = observationCount
        if failureOccurrences[token] == observationCount {
            throw FaultInjectionError(token: token)
        }
    }

    public func observationCount(for token: FaultToken) -> Int {
        observationCounts[token, default: 0]
    }
}

public struct FaultInjectionError: Error, Sendable, Equatable {
    public let token: FaultToken

    public init(token: FaultToken) {
        self.token = token
    }
}

extension FaultInjectionError: CustomStringConvertible, LocalizedError {
    public var description: String {
        "A deterministic test fault was injected."
    }

    public var errorDescription: String? {
        description
    }
}
