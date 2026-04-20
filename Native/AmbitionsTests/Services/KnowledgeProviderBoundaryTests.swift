import XCTest
@testable import Ambitions

final class KnowledgeProviderBoundaryTests: XCTestCase {
    func testLocalOnlyKnowledgeProviderReportsExplicitDegradationWithoutRetrieval() async throws {
        let provider = LocalOnlyKnowledgeProvider(
            descriptor: KnowledgeProviderDescriptor(
                id: "local-only",
                type: .systemFallback,
                displayName: "Local-only fallback"
            )
        )

        let status = await provider.status(now: Date(timeIntervalSince1970: 1_776_600_000))
        let response = try await provider.fetch(
            query: KnowledgeQuery(
                topic: "college applications",
                subject: "application_window"
            ),
            now: Date(timeIntervalSince1970: 1_776_600_000)
        )

        XCTAssertEqual(status.availability, .localOnlyMode)
        XCTAssertEqual(status.runtimeTrustPosture, .localOnly)
        XCTAssertEqual(response.claimSet.claims, [])
        XCTAssertEqual(response.claimSet.conflictState, .none)
        XCTAssertTrue((response.claimSet.degradationSummary ?? "").localizedCaseInsensitiveContains("local-only"))
        XCTAssertEqual(response.providerStatuses, [status])
    }

    func testRegistryPreservesConflictAndUnavailableStates() async throws {
        let primary = StubKnowledgeProvider(
            descriptor: KnowledgeProviderDescriptor(id: "primary", type: .webIndex, displayName: "Primary"),
            statusValue: KnowledgeProviderStatus(
                provider: KnowledgeProviderDescriptor(id: "primary", type: .webIndex, displayName: "Primary"),
                availability: .available,
                detail: "Primary provider is available.",
                runtimeTrustPosture: .localOnly
            ),
            response: KnowledgeProviderResponse(
                claimSet: KnowledgeClaimSet(
                    claims: [],
                    conflictState: .none,
                    degradationSummary: nil
                ),
                providerInputs: [
                    sampleProviderInput(
                        providerClaimKey: "claim-1",
                        providerID: "primary",
                        summary: "Deadline is May 1"
                    )
                ],
                providerStatuses: []
            )
        )
        let unavailable = StubKnowledgeProvider(
            descriptor: KnowledgeProviderDescriptor(id: "secondary", type: .publicDataset, displayName: "Secondary"),
            statusValue: KnowledgeProviderStatus(
                provider: KnowledgeProviderDescriptor(id: "secondary", type: .publicDataset, displayName: "Secondary"),
                availability: .providerUnavailable,
                detail: "Secondary provider is unavailable.",
                runtimeTrustPosture: .localOnly
            ),
            response: KnowledgeProviderResponse(
                claimSet: KnowledgeClaimSet(
                    claims: [],
                    conflictState: .conflictingUnresolved,
                    degradationSummary: "Secondary provider is unavailable and conflicts remain unresolved."
                ),
                providerInputs: [
                    sampleProviderInput(
                        providerClaimKey: "claim-2",
                        providerID: "secondary",
                        summary: "Deadline is May 15",
                        trustLevel: .low,
                        uncertaintyFlags: [.providerUnavailable]
                    )
                ],
                providerStatuses: []
            )
        )
        let registry = KnowledgeProviderRegistry(providers: [primary, unavailable])

        let response = try await registry.fetch(
            query: KnowledgeQuery(topic: "college applications", subject: "deadline"),
            now: Date(timeIntervalSince1970: 1_776_600_000)
        )

        XCTAssertEqual(response.claimSet.claims.count, 2)
        XCTAssertEqual(response.claimSet.conflictState, .conflictingUnresolved)
        XCTAssertEqual(response.providerStatuses.map(\.availability), [.available, .providerUnavailable])
        XCTAssertTrue(response.claimSet.claims.contains(where: { $0.uncertaintyFlags.contains(.conflicting) }))
    }

    func testProviderResponsesRetainProvenanceFreshnessAndTrustMetadata() async throws {
        let provider = StubKnowledgeProvider(
            descriptor: KnowledgeProviderDescriptor(id: "provider-1", type: .officialAPI, displayName: "Official API"),
            statusValue: KnowledgeProviderStatus(
                provider: KnowledgeProviderDescriptor(id: "provider-1", type: .officialAPI, displayName: "Official API"),
                availability: .available,
                detail: "Provider is available.",
                runtimeTrustPosture: .localOnly
            ),
            response: KnowledgeProviderResponse(
                claimSet: KnowledgeClaimSet(
                    claims: [],
                    conflictState: .none,
                    degradationSummary: nil
                ),
                providerInputs: [sampleProviderInput(providerClaimKey: "claim-1", providerID: "provider-1", summary: "Tax filing deadline is April 15.", provenanceKind: .official, isOfficial: true)],
                providerStatuses: []
            )
        )
        let registry = KnowledgeProviderRegistry(providers: [provider])

        let response = try await registry.fetch(
            query: KnowledgeQuery(topic: "tax deadline", subject: "deadline"),
            now: Date(timeIntervalSince1970: 1_776_600_000)
        )
        let returned = try XCTUnwrap(response.claimSet.claims.first)

        XCTAssertEqual(returned.source.provenanceKind, .official)
        XCTAssertEqual(returned.freshness.state, .fresh)
        XCTAssertEqual(returned.trustLevel, .high)
        XCTAssertEqual(returned.confidence, .high)
    }

    func testProviderResponsesFallBackToLegacyClaimSetWhenProviderInputsAreEmpty() async throws {
        let claim = sampleClaim()
        let provider = StubKnowledgeProvider(
            descriptor: KnowledgeProviderDescriptor(id: "provider-1", type: .officialAPI, displayName: "Official API"),
            statusValue: KnowledgeProviderStatus(
                provider: KnowledgeProviderDescriptor(id: "provider-1", type: .officialAPI, displayName: "Official API"),
                availability: .available,
                detail: "Provider is available.",
                runtimeTrustPosture: .localOnly
            ),
            response: KnowledgeProviderResponse(
                claimSet: KnowledgeClaimSet(
                    claims: [claim],
                    conflictState: .none,
                    degradationSummary: "legacy_fallback"
                ),
                providerInputs: [],
                providerStatuses: []
            )
        )

        let response = try await provider.fetch(
            query: KnowledgeQuery(topic: "tax deadline", subject: "deadline"),
            now: Date(timeIntervalSince1970: 1_776_600_000)
        )

        XCTAssertEqual(response.claimSet.claims, [claim])
        XCTAssertEqual(response.providerInputs, [])
    }
}

private extension KnowledgeProviderBoundaryTests {
    func sampleClaim(
        id: String = "claim-1",
        providerID: String = "provider-1",
        summary: String = "Tax filing deadline is April 15.",
        uncertaintyFlags: Set<KnowledgeUncertaintyFlag> = []
    ) -> KnowledgeClaim {
        KnowledgeClaim(
            id: id,
            providerID: providerID,
            subject: "deadline",
            payload: KnowledgeClaimPayload(summary: summary, detail: nil),
            source: KnowledgeSourceRecord(
                id: "source-\(id)",
                providerID: providerID,
                entityTitle: "Tax calendar",
                publisher: "IRS",
                locator: "https://example.com/tax-calendar",
                provenanceKind: .official,
                isOfficial: true
            ),
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-19T12:00:00Z",
                publishedAt: "2026-04-18T12:00:00Z",
                staleAfter: "2026-04-26T12:00:00Z",
                expiresAt: "2026-05-01T12:00:00Z",
                state: .fresh
            ),
            trustLevel: .high,
            confidence: .high,
            uncertaintyFlags: uncertaintyFlags,
            explanation: KnowledgeExplanationMetadata(
                summary: "This came from an official calendar source.",
                supportingSourceIDs: ["source-\(id)"],
                notes: []
            )
        )
    }
}

private struct StubKnowledgeProvider: KnowledgeProviding {
    let descriptor: KnowledgeProviderDescriptor
    let statusValue: KnowledgeProviderStatus
    let response: KnowledgeProviderResponse

    func status(now: Date) async -> KnowledgeProviderStatus {
        _ = now
        return statusValue
    }

    func fetch(query: KnowledgeQuery, now: Date) async throws -> KnowledgeProviderResponse {
        _ = query
        _ = now
        return response
    }
}

private extension KnowledgeProviderBoundaryTests {
    func sampleProviderInput(
        providerClaimKey: String,
        providerID: String,
        summary: String,
        provenanceKind: KnowledgeProvenanceKind = .official,
        isOfficial: Bool = true,
        trustLevel: KnowledgeTrustLevel = .high,
        uncertaintyFlags: Set<KnowledgeUncertaintyFlag> = []
    ) -> KnowledgeProviderClaimInput {
        KnowledgeProviderClaimInput(
            providerClaimKey: providerClaimKey,
            providerID: providerID,
            subject: "deadline",
            summary: summary,
            detail: nil,
            source: KnowledgeProviderSourceInput(
                providerSourceKey: "source-\(providerClaimKey)",
                entityTitle: "Tax calendar",
                publisher: "IRS",
                locator: "https://example.com/tax-calendar",
                provenanceKind: provenanceKind,
                isOfficial: isOfficial
            ),
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-19T12:00:00Z",
                publishedAt: "2026-04-18T12:00:00Z",
                staleAfter: "2026-04-26T12:00:00Z",
                expiresAt: "2026-05-01T12:00:00Z",
                state: .fresh
            ),
            trustLevel: trustLevel,
            confidence: trustLevel == .low ? .low : .high,
            uncertaintyFlags: uncertaintyFlags
        )
    }
}
