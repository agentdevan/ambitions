import Foundation

public protocol RuntimeProjection: Sendable {
    associatedtype Request: Codable & Sendable
    associatedtype Output: Codable & Sendable

    static var identifier: String { get }
}

public struct VersionedProjection<Output: Codable & Sendable>: Codable, Sendable {
    public let cursor: String
    public let canonicalRevision: Int64
    public let value: Output

    public init(cursor: String, canonicalRevision: Int64, value: Output) {
        self.cursor = cursor
        self.canonicalRevision = canonicalRevision
        self.value = value
    }
}

public protocol PrivateLifeRuntimeClient: Sendable {
    func execute(
        _ command: RuntimeCommand,
        context: RuntimeExecutionContext
    ) async -> RuntimeOutcome

    func projection<Projection: RuntimeProjection>(
        _ projection: Projection.Type,
        request: Projection.Request
    ) async throws -> VersionedProjection<Projection.Output>
}
