import Foundation

enum RuntimeCanonicalSearchTokenizer {
    static let maximumStoredTokenBytes = 128
    static let maximumTokensPerField = 64

    struct Result: Sendable, Equatable {
        let tokens: [String]
        let exceededMaximumCount: Bool
    }

    static func tokenize(
        _ value: String,
        maximumCount: Int = maximumTokensPerField
    ) -> Result {
        let components = value.precomposedStringWithCanonicalMapping.lowercased().split(whereSeparator: {
            $0.isLetter == false && $0.isNumber == false
        })
        let tokens = components.prefix(maximumCount).map { component in
            let token = String(component)
            if token.utf8.count <= maximumStoredTokenBytes { return token }
            return "~" + RuntimeTransactionDigest.digest([
                "runtime.search.long-token.v1", token,
            ])
        }
        return Result(
            tokens: tokens,
            exceededMaximumCount: components.count > maximumCount
        )
    }

    static func tokens(_ value: String, maximumCount: Int = maximumTokensPerField) -> [String] {
        tokenize(value, maximumCount: maximumCount).tokens
    }
}

struct RuntimeCanonicalSearchDocument: Codable, Sendable, Equatable, Hashable {
    let generationID: String
    let aggregate: RuntimeSemanticAggregate
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let title: String
    let body: String
    let sourceCursor: RuntimeCanonicalReplayCursor
    let digest: String

    var documentID: String { "\(aggregate.kind.rawValue).\(aggregate.id.rawValue)" }

    static func authorityDigest(
        generationID: String,
        aggregate: RuntimeSemanticAggregate,
        privacy: EventLedgerPrivacyClassification,
        localOnly: Bool,
        title: String,
        body: String,
        sourceCursor: RuntimeCanonicalReplayCursor
    ) -> String {
        RuntimeTransactionDigest.digest([
            "runtime.search.document.v2", generationID,
            aggregate.kind.rawValue, aggregate.id.rawValue,
            privacy.rawValue, String(localOnly), title, body,
            String(sourceCursor.sequence), sourceCursor.eventID, sourceCursor.eventHash,
        ])
    }
}

struct RuntimeCanonicalSearchQuery: Sendable, Equatable {
    static let maximumDeliveryCount = 50
    static let maximumQueryBytes = 2_048
    static let maximumCandidateCount = 512
    static let maximumPostingWork = 8_192

    let text: String
    let allowedPrivacy: Set<EventLedgerPrivacyClassification>
    let requiresLocalOnly: Bool
    let families: Set<RuntimeSemanticAggregateKind>
    let deliveryCount: Int

    init(
        text: String,
        allowedPrivacy: Set<EventLedgerPrivacyClassification>,
        requiresLocalOnly: Bool = true,
        families: Set<RuntimeSemanticAggregateKind> = [],
        deliveryCount: Int = 25
    ) {
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.allowedPrivacy = allowedPrivacy
        self.requiresLocalOnly = requiresLocalOnly
        self.families = families
        let delivery = min(max(1, deliveryCount), Self.maximumDeliveryCount)
        self.deliveryCount = delivery
    }

    var normalizedTokens: [String] {
        guard inputIsSupported else { return [] }
        return Array(Set(queryTokenization.tokens)).sorted()
    }

    var inputIsSupported: Bool {
        text.utf8.count <= Self.maximumQueryBytes && queryTokenization.exceededMaximumCount == false
    }

    private var queryTokenization: RuntimeCanonicalSearchTokenizer.Result {
        RuntimeCanonicalSearchTokenizer.tokenize(text, maximumCount: 16)
    }

    var queryDigest: String {
        RuntimeTransactionDigest.digest(["runtime.search.query.v2"] + normalizedTokens)
    }

    var accessPolicyDigest: String {
        RuntimeTransactionDigest.digest([
            "runtime.search.access-policy.v1",
            allowedPrivacy.map(\.rawValue).sorted().joined(separator: ","),
            String(requiresLocalOnly), families.map(\.rawValue).sorted().joined(separator: ","),
        ])
    }

    var filterDigest: String {
        RuntimeTransactionDigest.digest([
            accessPolicyDigest, String(deliveryCount),
        ])
    }
}

struct RuntimeCanonicalSearchCursor: Codable, Sendable, Equatable, Hashable {
    let generationID: String
    let queryDigest: String
    let filterDigest: String
    let aggregateKind: RuntimeSemanticAggregateKind
    let aggregateID: RuntimeAggregateID

    func isBound(to generationID: String, query: RuntimeCanonicalSearchQuery) -> Bool {
        self.generationID == generationID && queryDigest == query.queryDigest &&
            filterDigest == query.filterDigest
    }
}

struct RuntimeCanonicalSearchResult: Sendable, Equatable {
    let document: RuntimeCanonicalSearchDocument
}

struct RuntimeCanonicalSearchPage: Sendable, Equatable {
    let generationID: String
    let coverage: RuntimeCanonicalSearchCoverage
    let projectionCursor: RuntimeCanonicalReplayCursor
    let projectionDigest: String
    let results: [RuntimeCanonicalSearchResult]
    let nextCursor: RuntimeCanonicalSearchCursor?
    let truth: RuntimeCanonicalProjectionTruth
    let authorityFingerprint: String

    func actionToken(
        for result: RuntimeCanonicalSearchResult,
        query: RuntimeCanonicalSearchQuery,
        definition: RuntimeCanonicalProjectionDefinition
    ) throws -> RuntimeCanonicalSearchActionToken {
        guard results.contains(result), result.document.generationID == generationID,
              definition.id == .search else {
            throw RuntimeCanonicalSearchError.actionSourceChanged
        }
        return RuntimeCanonicalSearchActionToken(
            generationID: generationID,
            coverage: coverage,
            aggregate: result.document.aggregate,
            sourceCursor: result.document.sourceCursor,
            documentDigest: result.document.digest,
            definitionDigest: definition.authorityDigest,
            allowedPrivacy: query.allowedPrivacy,
            requiresLocalOnly: query.requiresLocalOnly,
            families: query.families,
            accessPolicyDigest: query.accessPolicyDigest,
            authorityFingerprint: authorityFingerprint
        )
    }
}

enum RuntimeCanonicalSearchError: Error, Sendable, Equatable {
    case cursorBindingMismatch
    case projectionNotAvailable(RuntimeCanonicalProjectionHealth)
    case corruptIndex
    case actionSourceChanged
    case unsupportedQuery
    case emptyPrivacyFilter
    case unauthorizedPrivacyFilter
    case temporarilyUnavailable
    case queryTooBroad
}

struct RuntimeCanonicalSearchActionToken: Sendable, Equatable, Hashable {
    let generationID: String
    let coverage: RuntimeCanonicalSearchCoverage
    let aggregate: RuntimeSemanticAggregate
    let sourceCursor: RuntimeCanonicalReplayCursor
    let documentDigest: String
    let definitionDigest: String
    let allowedPrivacy: Set<EventLedgerPrivacyClassification>
    let requiresLocalOnly: Bool
    let families: Set<RuntimeSemanticAggregateKind>
    let accessPolicyDigest: String
    let authorityFingerprint: String
}
