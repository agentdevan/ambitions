import Foundation

struct KnowledgeQuery: Codable, Sendable, Equatable, Hashable {
    let topic: String
    let subject: String
}

struct KnowledgeProviderResponse: Codable, Sendable, Equatable {
    let claimSet: KnowledgeClaimSet
    let providerInputs: [KnowledgeProviderClaimInput]
    let providerStatuses: [KnowledgeProviderStatus]

    init(
        claimSet: KnowledgeClaimSet,
        providerInputs: [KnowledgeProviderClaimInput] = [],
        providerStatuses: [KnowledgeProviderStatus]
    ) {
        self.claimSet = claimSet
        self.providerInputs = providerInputs
        self.providerStatuses = providerStatuses
    }
}

protocol KnowledgeProviding: Sendable {
    var descriptor: KnowledgeProviderDescriptor { get }
    func status(now: Date) async -> KnowledgeProviderStatus
    func fetch(query: KnowledgeQuery, now: Date) async throws -> KnowledgeProviderResponse
}

struct LocalOnlyKnowledgeProvider: KnowledgeProviding {
    let descriptor: KnowledgeProviderDescriptor

    init(
        descriptor: KnowledgeProviderDescriptor = KnowledgeProviderDescriptor(
            id: "local-only",
            type: .systemFallback,
            displayName: "Local-only fallback"
        )
    ) {
        self.descriptor = descriptor
    }

    func status(now: Date) async -> KnowledgeProviderStatus {
        _ = now
        return KnowledgeProviderStatus(
            provider: descriptor,
            availability: .localOnlyMode,
            detail: "Knowledge retrieval is unavailable while Ambitions remains in explicit local-only mode.",
            runtimeTrustPosture: .localOnly
        )
    }

    func fetch(query: KnowledgeQuery, now: Date) async throws -> KnowledgeProviderResponse {
        _ = query
        let currentStatus = await status(now: now)
        return KnowledgeProviderResponse(
            claimSet: KnowledgeClaimSet(
                claims: [],
                conflictState: .none,
                degradationSummary: currentStatus.detail
            ),
            providerStatuses: [currentStatus]
        )
    }
}

struct KnowledgeProviderRegistry: KnowledgeProviding {
    let providers: [any KnowledgeProviding]
    let ingestionService: any KnowledgeIngesting
    let boundaryHardener: KnowledgeClaimBoundaryHardener

    init(
        providers: [any KnowledgeProviding],
        ingestionService: any KnowledgeIngesting = DefaultKnowledgeIngestionService(),
        boundaryHardener: KnowledgeClaimBoundaryHardener = KnowledgeClaimBoundaryHardener()
    ) {
        self.providers = providers
        self.ingestionService = ingestionService
        self.boundaryHardener = boundaryHardener
    }

    var descriptor: KnowledgeProviderDescriptor {
        KnowledgeProviderDescriptor(
            id: "knowledge-provider-registry",
            type: .systemFallback,
            displayName: "Knowledge provider registry"
        )
    }

    func status(now: Date) async -> KnowledgeProviderStatus {
        let statuses = await providerStatuses(now: now)
        let availability: KnowledgeProviderAvailability
        if statuses.contains(where: { $0.availability == .available }) {
            availability = .available
        } else if statuses.contains(where: { $0.availability == .localOnlyMode }) {
            availability = .localOnlyMode
        } else if statuses.contains(where: { $0.availability == .providerUnavailable }) {
            availability = .providerUnavailable
        } else {
            availability = .unsupported
        }

        let detail = statuses.map(\.detail).filter { $0.isEmpty == false }.joined(separator: " ")
        return KnowledgeProviderStatus(
            provider: descriptor,
            availability: availability,
            detail: detail.isEmpty ? "Knowledge provider registry has no configured providers." : detail,
            runtimeTrustPosture: .localOnly
        )
    }

    func fetch(query: KnowledgeQuery, now: Date) async throws -> KnowledgeProviderResponse {
        var allStatuses: [KnowledgeProviderStatus] = []
        var allProviderInputs: [KnowledgeProviderClaimInput] = []
        var fallbackClaims: [KnowledgeClaim] = []
        var fallbackConflictState: KnowledgeConflictState = .none
        var fallbackDegradationFragments: [String] = []

        for provider in providers {
            let currentStatus = await provider.status(now: now)
            let response = try await provider.fetch(query: query, now: now)
            let responseStatuses = response.providerStatuses.isEmpty ? [currentStatus] : response.providerStatuses

            allProviderInputs.append(contentsOf: response.providerInputs)
            fallbackClaims.append(contentsOf: response.claimSet.claims)
            allStatuses.append(contentsOf: responseStatuses)
            if let degradationSummary = response.claimSet.degradationSummary, degradationSummary.isEmpty == false {
                fallbackDegradationFragments.append(degradationSummary)
            }
            if response.claimSet.conflictState == .conflictingUnresolved {
                fallbackConflictState = .conflictingUnresolved
            }
        }

        let normalized = ingestionService.ingest(
            response: KnowledgeProviderResponse(
                claimSet: KnowledgeClaimSet(
                    claims: fallbackClaims,
                    conflictState: fallbackConflictState == .conflictingUnresolved || hasUnresolvedConflicts(in: fallbackClaims)
                        ? .conflictingUnresolved
                        : .none,
                    degradationSummary: fallbackDegradationFragments.isEmpty ? nil : fallbackDegradationFragments.joined(separator: " ")
                ),
                providerInputs: allProviderInputs,
                providerStatuses: allStatuses
            ),
            fallbackStatuses: allStatuses
        )
        let boundaryReport = boundaryHardener.assess(
            claims: normalized.claimSet.claims,
            providerStatuses: normalized.providerStatuses,
            existingDegradationStates: normalized.degradationStates
        )

        return KnowledgeProviderResponse(
            claimSet: KnowledgeClaimSet(
                claims: normalized.claimSet.claims,
                conflictState: normalized.claimSet.conflictState,
                degradationSummary: boundaryReport.degradationSummary ?? normalized.claimSet.degradationSummary
            ),
            providerInputs: allProviderInputs,
            providerStatuses: normalized.providerStatuses
        )
    }

    private func providerStatuses(now: Date) async -> [KnowledgeProviderStatus] {
        var results: [KnowledgeProviderStatus] = []
        for provider in providers {
            results.append(await provider.status(now: now))
        }
        return results
    }

    private func hasUnresolvedConflicts(in claims: [KnowledgeClaim]) -> Bool {
        let grouped = Dictionary(grouping: claims, by: \.subject)
        for subjectClaims in grouped.values {
            let distinctSummaries = Set(subjectClaims.map(\.payload.summary))
            if distinctSummaries.count > 1 {
                return true
            }
            if subjectClaims.contains(where: { $0.uncertaintyFlags.contains(.conflicting) }) {
                return true
            }
        }
        return false
    }
}
