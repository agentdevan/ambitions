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
