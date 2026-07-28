import Foundation

enum RuntimeCanonicalSearchField: String, Codable, Sendable, Equatable, Hashable, CaseIterable, Comparable {
    case aggregateKind = "aggregate_kind"

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

enum RuntimeCanonicalSearchCoverage: String, Codable, Sendable, Equatable, Hashable {
    /// Search remains limited to non-sensitive aggregate kind labels until the
    /// canonical reducer owns merged searchable content and field privacy.
    case aggregateKindOnly = "aggregate_kind_only"
}

enum RuntimeCanonicalProjectionOrderingField: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case aggregateKind = "aggregate_kind"
    case aggregateID = "aggregate_id"
}

struct RuntimeCanonicalProjectionDefinition: Codable, Sendable, Equatable, Hashable {
    let id: RuntimeCanonicalProjectionID
    let definitionVersion: Int
    let outputVersion: Int
    let inputEventTypes: [RuntimeSemanticEventTypeID]
    let stableOrdering: [RuntimeCanonicalProjectionOrderingField]
    let allowedSearchFields: [RuntimeCanonicalSearchField]
    let allowedPrivacyClasses: [EventLedgerPrivacyClassification]
    let requiresLocalOnlySource: Bool

    init(
        id: RuntimeCanonicalProjectionID,
        definitionVersion: Int = 1,
        outputVersion: Int = 1,
        inputEventTypes: [RuntimeSemanticEventTypeID],
        stableOrdering: [RuntimeCanonicalProjectionOrderingField] = [.aggregateKind, .aggregateID],
        allowedSearchFields: [RuntimeCanonicalSearchField] = [],
        allowedPrivacyClasses: [EventLedgerPrivacyClassification] = [
            .standard, .sensitive, .privateUserText, .calendarDerived, .syncMetadata,
        ],
        requiresLocalOnlySource: Bool = true
    ) {
        self.id = id
        self.definitionVersion = definitionVersion
        self.outputVersion = outputVersion
        self.inputEventTypes = Array(Set(inputEventTypes)).sorted { $0.rawValue < $1.rawValue }
        self.stableOrdering = stableOrdering
        self.allowedSearchFields = Array(Set(allowedSearchFields)).sorted()
        self.allowedPrivacyClasses = Array(Set(allowedPrivacyClasses)).sorted { $0.rawValue < $1.rawValue }
        self.requiresLocalOnlySource = requiresLocalOnlySource
    }

    var authorityDigest: String {
        RuntimeTransactionDigest.digest([
            id.rawValue, String(definitionVersion), String(outputVersion),
            inputEventTypes.map(\.rawValue).joined(separator: ","), stableOrdering.map(\.rawValue).joined(separator: ","),
            allowedSearchFields.map(\.rawValue).joined(separator: ","),
            allowedPrivacyClasses.map(\.rawValue).joined(separator: ","),
            String(requiresLocalOnlySource),
        ])
    }

}

enum RuntimeCanonicalProjectionDefinitionRegistryError: Error, Sendable, Equatable {
    case duplicateProjectionID(RuntimeCanonicalProjectionID)
    case incompleteEventOwnership
    case invalidDefinition(RuntimeCanonicalProjectionID)
}

struct RuntimeCanonicalProjectionDefinitionRegistry: Sendable {
    let definitions: [RuntimeCanonicalProjectionID: RuntimeCanonicalProjectionDefinition]

    init(definitions values: [RuntimeCanonicalProjectionDefinition]) throws {
        var indexed: [RuntimeCanonicalProjectionID: RuntimeCanonicalProjectionDefinition] = [:]
        for value in values {
            guard value.definitionVersion > 0, value.outputVersion > 0,
                  value.inputEventTypes.isEmpty == false,
                  value.stableOrdering == [.aggregateKind, .aggregateID],
                  value.allowedPrivacyClasses.isEmpty == false else {
                throw RuntimeCanonicalProjectionDefinitionRegistryError.invalidDefinition(value.id)
            }
            guard indexed.updateValue(value, forKey: value.id) == nil else {
                throw RuntimeCanonicalProjectionDefinitionRegistryError.duplicateProjectionID(value.id)
            }
        }
        guard Set(indexed.keys) == Set(RuntimeCanonicalProjectionID.allCases),
              RuntimeCanonicalProjectionRegistry.validateExhaustiveOwnership(),
              indexed.allSatisfy({ projectionID, definition in
                  Set(definition.inputEventTypes) == Set(RuntimeSemanticEventTypeID.allCases.filter {
                      RuntimeCanonicalProjectionRegistry.projectionIDs(for: $0).contains(projectionID)
                  })
              }) else {
            throw RuntimeCanonicalProjectionDefinitionRegistryError.incompleteEventOwnership
        }
        definitions = indexed
    }

    static func canonical() throws -> Self {
        let all = RuntimeSemanticEventTypeID.allCases
        return try Self(definitions: [
            .init(id: .aggregateState, inputEventTypes: all),
            .init(
                id: .search,
                definitionVersion: 2,
                outputVersion: 2,
                inputEventTypes: all,
                allowedSearchFields: RuntimeCanonicalSearchField.allCases
            ),
        ])
    }
}

enum RuntimeCanonicalProjectionHealth: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case available, stale, missing, rebuilding, blocked, unavailable, corrupt
}

struct RuntimeCanonicalProjectionEntry: Codable, Sendable, Equatable, Hashable {
    let aggregate: RuntimeSemanticAggregate
    let revision: UInt64
    let lifecycle: RuntimeAggregateLifecycle
    let canonicalStateBytes: Data
    let canonicalStateDigest: String
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let sourceCursor: RuntimeCanonicalReplayCursor
}

enum RuntimeCanonicalProjectionSourceError: Error, Sendable, Equatable {
    case blockedHistoricalPrivacy(eventID: String, payloadVersion: Int)
    case unsupportedSource
    case inconsistentSource
}

struct RuntimeCanonicalProjectionTruth: Sendable, Equatable {
    let state: RuntimeCanonicalProjectionHealth
    let authority: RuntimeCanonicalGenerationAuthority?
    let expectedDefinitionVersion: Int
    let sourceCursor: RuntimeCanonicalReplayCursor?
    let digest: String?
    let repairEligible: Bool
    let reasonCode: String?

    init(
        state: RuntimeCanonicalProjectionHealth,
        authority: RuntimeCanonicalGenerationAuthority?,
        expectedDefinitionVersion: Int,
        sourceCursor: RuntimeCanonicalReplayCursor?,
        digest: String?,
        repairEligible: Bool,
        reasonCode: String?
    ) {
        self.state = state
        self.authority = authority
        self.expectedDefinitionVersion = expectedDefinitionVersion
        self.sourceCursor = sourceCursor
        self.digest = digest
        self.repairEligible = repairEligible
        self.reasonCode = reasonCode
    }
}
