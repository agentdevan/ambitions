import Foundation

let ambitionsCommandExecutionRecordSchemaVersion = "ambitions_command_execution_record.native.v1"

enum AmbitionsCommandExecutionStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pending
    case succeeded
    case failed
    case noOp = "no_op"
    case queued
    case requiresConfirmation = "requires_confirmation"
    case unsupported
    case blocked
}

struct AmbitionsCommandExecutionResult: Codable, Sendable, Equatable, Hashable {
    let status: AmbitionsCommandExecutionStatus
    let summary: String
    let route: AmbitionsCommandDestination?
    let target: AmbitionsCommandTarget?
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let metadata: [String: String]

    init(
        status: AmbitionsCommandExecutionStatus,
        summary: String,
        route: AmbitionsCommandDestination? = nil,
        target: AmbitionsCommandTarget? = nil,
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = [],
        metadata: [String: String] = [:]
    ) {
        self.status = status
        self.summary = summary
        self.route = route
        self.target = target
        self.eventLedgerEntryIDs = Array(Set(eventLedgerEntryIDs.filter { $0.isEmpty == false })).sorted()
        self.recommendationExplanationIDs = Array(Set(recommendationExplanationIDs.filter { $0.isEmpty == false })).sorted()
        self.metadata = metadata.filter { $0.key.isEmpty == false && $0.value.isEmpty == false }
    }
}

extension AmbitionsCommandExecutionResult {
    func mergingMetadata(_ additionalMetadata: [String: String]) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: status,
            summary: summary,
            route: route,
            target: target,
            eventLedgerEntryIDs: eventLedgerEntryIDs,
            recommendationExplanationIDs: recommendationExplanationIDs,
            metadata: metadata.merging(additionalMetadata.filter { $0.key.isEmpty == false && $0.value.isEmpty == false }) { _, new in new }
        )
    }
}

struct AmbitionsCommandExecutionRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let command: AmbitionsCommand
    let result: AmbitionsCommandExecutionResult
    let recordedAt: String
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let schemaVersion: String

    init(
        id: String? = nil,
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        recordedAt: String,
        localOnly: Bool? = nil,
        privacy: EventLedgerPrivacyClassification? = nil,
        schemaVersion: String = ambitionsCommandExecutionRecordSchemaVersion
    ) {
        self.id = id ?? "command.execution.\(command.id)"
        self.command = command
        self.result = result
        self.recordedAt = recordedAt
        self.localOnly = localOnly ?? command.localOnly
        self.privacy = privacy ?? command.privacy
        self.schemaVersion = schemaVersion
    }

    var commandID: String {
        command.id
    }
}

/// A persistence-boundary result which never erases bytes that this build cannot interpret.
enum StoredCommandExecutionRecord: Sendable, Equatable {
    case supported(AmbitionsCommandExecutionRecord)
    case quarantined(QuarantinedCommandExecutionRecord)

    var command: AmbitionsCommand? {
        guard case let .supported(record) = self else { return nil }
        return record.command
    }

    var result: AmbitionsCommandExecutionResult? {
        guard case let .supported(record) = self else { return nil }
        return record.result
    }

    var commandID: String {
        switch self {
        case let .supported(record): record.commandID
        case let .quarantined(record): record.commandID
        }
    }

    var id: String {
        switch self {
        case let .supported(record): record.id
        case let .quarantined(record): record.id
        }
    }

    var recordedAt: String {
        switch self {
        case let .supported(record): record.recordedAt
        case let .quarantined(record): record.recordedAt
        }
    }

    var localOnly: Bool? {
        guard case let .supported(record) = self else { return nil }
        return record.localOnly
    }

    var privacy: EventLedgerPrivacyClassification? {
        guard case let .supported(record) = self else { return nil }
        return record.privacy
    }

    var schemaVersion: String? {
        guard case let .supported(record) = self else { return nil }
        return record.schemaVersion
    }
}

struct QuarantinedCommandExecutionRecord: Sendable, Equatable {
    let id: String
    let commandID: String
    let commandBytes: Data
    let resultBytes: Data
    let recordedAt: String
    let schemaVersion: String
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let issue: RuntimeUnsupportedCommand
}
