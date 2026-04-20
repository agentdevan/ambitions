import XCTest
@testable import Ambitions

final class KnowledgeIngestionServiceTests: XCTestCase {
    func testNormalizationProducesDeterministicClaimsAndDedupedSources() {
        let service = DefaultKnowledgeIngestionService()
        let response = KnowledgeProviderResponse(
            claimSet: KnowledgeClaimSet(claims: [], conflictState: .none, degradationSummary: nil),
            providerInputs: [
                sampleInput(providerClaimKey: "claim-1", summary: "Deadline is May 1"),
                sampleInput(providerClaimKey: "claim-2", summary: "Deadline is May 1")
            ],
            providerStatuses: [availableStatus]
        )

        let first = service.ingest(response: response, fallbackStatuses: [])
        let second = service.ingest(response: response, fallbackStatuses: [])

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.claimSet.claims.count, 2)
        XCTAssertEqual(first.sources.count, 1)
        XCTAssertEqual(first.claimSet.conflictState, .none)
        XCTAssertEqual(first.degradationStates, [])
        XCTAssertEqual(first.claimSet.claims.map(\.source.id), [first.sources[0].id, first.sources[0].id])
    }

    func testNormalizationPreservesFreshnessAndProvenanceDistinctions() {
        let service = DefaultKnowledgeIngestionService()
        let response = KnowledgeProviderResponse(
            claimSet: KnowledgeClaimSet(claims: [], conflictState: .none, degradationSummary: nil),
            providerInputs: [
                sampleInput(
                    providerClaimKey: "official",
                    summary: "Deadline is May 1",
                    provenance: .official,
                    isOfficial: true,
                    freshnessState: .fresh
                ),
                sampleInput(
                    providerClaimKey: "inferred",
                    summary: "Deadline is probably May 3",
                    provenance: .inferred,
                    freshnessState: .unknown,
                    uncertaintyFlags: [.inferred]
                ),
                sampleInput(
                    providerClaimKey: "user",
                    summary: "I was told it closes May 5",
                    provenance: .userProvided,
                    freshnessState: .stale
                )
            ],
            providerStatuses: [availableStatus]
        )

        let result = service.ingest(response: response, fallbackStatuses: [])

        XCTAssertEqual(result.claimSet.claims.map(\.source.provenanceKind), [.official, .inferred, .userProvided])
        XCTAssertEqual(result.claimSet.claims.map(\.source.isOfficial), [true, false, false])
        XCTAssertEqual(result.claimSet.claims.map(\.freshness.state), [.fresh, .unknown, .stale])
        XCTAssertEqual(result.claimSet.conflictState, .conflictingUnresolved)
        XCTAssertEqual(Set(result.degradationStates), [.staleInformation, .conflictingClaims])
    }

    func testNormalizationBuildsConflictGroupsWithoutResolvingClaims() {
        let service = DefaultKnowledgeIngestionService()
        let response = KnowledgeProviderResponse(
            claimSet: KnowledgeClaimSet(claims: [], conflictState: .none, degradationSummary: nil),
            providerInputs: [
                sampleInput(providerClaimKey: "claim-1", summary: "Deadline is May 1"),
                sampleInput(providerClaimKey: "claim-2", summary: "Deadline is May 15")
            ],
            providerStatuses: [availableStatus]
        )

        let result = service.ingest(response: response, fallbackStatuses: [])

        XCTAssertEqual(result.claimSet.claims.count, 2)
        XCTAssertEqual(result.claimSet.conflictState, .conflictingUnresolved)
        XCTAssertEqual(result.conflictGroups.count, 1)
        XCTAssertEqual(result.conflictGroups[0].subject, "deadline")
        XCTAssertEqual(Set(result.degradationStates), [.conflictingClaims])
        XCTAssertTrue(result.claimSet.claims.allSatisfy { $0.uncertaintyFlags.contains(.conflicting) })
    }

    func testNormalizationPropagatesAvailabilityFreshnessAndLowTrustStates() {
        let service = DefaultKnowledgeIngestionService()
        let unavailable = KnowledgeProviderStatus(
            provider: KnowledgeProviderDescriptor(id: "provider-2", type: .publicDataset, displayName: "Dataset"),
            availability: .providerUnavailable,
            detail: "Unavailable",
            runtimeTrustPosture: .localOnly
        )
        let response = KnowledgeProviderResponse(
            claimSet: KnowledgeClaimSet(claims: [], conflictState: .none, degradationSummary: nil),
            providerInputs: [
                sampleInput(
                    providerClaimKey: "claim-1",
                    summary: "Processing time is 6 weeks",
                    freshnessState: .expired,
                    trustLevel: .low,
                    uncertaintyFlags: [.providerUnavailable]
                )
            ],
            providerStatuses: [unavailable]
        )

        let result = service.ingest(response: response, fallbackStatuses: [])

        XCTAssertEqual(
            Set(result.degradationStates),
            [.providerUnavailable, .staleInformation, .lowTrustInformation]
        )
        XCTAssertEqual(result.providerStatuses, [unavailable])
        XCTAssertEqual(result.claimSet.claims.first?.freshness.state, .expired)
        XCTAssertEqual(result.claimSet.claims.first?.trustLevel, .low)
    }

    func testLegacyClaimSetFallbackOnlyAppliesWhenProviderInputsAreEmpty() {
        let service = DefaultKnowledgeIngestionService()
        let fallbackClaim = KnowledgeClaim(
            id: "fallback-claim",
            providerID: "provider-1",
            subject: "deadline",
            payload: KnowledgeClaimPayload(summary: "Legacy deadline", detail: nil),
            source: KnowledgeSourceRecord(
                id: "fallback-source",
                providerID: "provider-1",
                entityTitle: "Legacy calendar",
                publisher: "Legacy",
                locator: "https://example.com/legacy",
                provenanceKind: .providerReported,
                isOfficial: false
            ),
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-19T12:00:00Z",
                publishedAt: nil,
                staleAfter: nil,
                expiresAt: nil,
                state: .unknown
            ),
            trustLevel: .medium,
            confidence: .medium,
            uncertaintyFlags: [],
            explanation: KnowledgeExplanationMetadata(summary: "", supportingSourceIDs: ["fallback-source"], notes: [])
        )

        let fallbackOnly = service.ingest(
            response: KnowledgeProviderResponse(
                claimSet: KnowledgeClaimSet(
                    claims: [fallbackClaim],
                    conflictState: .none,
                    degradationSummary: "legacy_fallback"
                ),
                providerInputs: [],
                providerStatuses: [availableStatus]
            ),
            fallbackStatuses: []
        )

        XCTAssertEqual(fallbackOnly.claimSet.claims, [fallbackClaim])
        XCTAssertEqual(fallbackOnly.sources, [fallbackClaim.source])

        let primaryPath = service.ingest(
            response: KnowledgeProviderResponse(
                claimSet: KnowledgeClaimSet(
                    claims: [fallbackClaim],
                    conflictState: .none,
                    degradationSummary: "legacy_fallback"
                ),
                providerInputs: [sampleInput(providerClaimKey: "claim-1", summary: "Primary path")],
                providerStatuses: [availableStatus]
            ),
            fallbackStatuses: []
        )

        XCTAssertEqual(primaryPath.claimSet.claims.count, 1)
        XCTAssertEqual(primaryPath.claimSet.claims.first?.payload.summary, "Primary path")
        XCTAssertNotEqual(primaryPath.claimSet.claims.first?.id, fallbackClaim.id)
    }
}

private extension KnowledgeIngestionServiceTests {
    var availableStatus: KnowledgeProviderStatus {
        KnowledgeProviderStatus(
            provider: KnowledgeProviderDescriptor(id: "provider-1", type: .officialAPI, displayName: "Official API"),
            availability: .available,
            detail: "Available",
            runtimeTrustPosture: .localOnly
        )
    }

    func sampleInput(
        providerClaimKey: String,
        summary: String,
        provenance: KnowledgeProvenanceKind = .providerReported,
        isOfficial: Bool = false,
        freshnessState: KnowledgeFreshnessState = .fresh,
        trustLevel: KnowledgeTrustLevel = .high,
        uncertaintyFlags: Set<KnowledgeUncertaintyFlag> = []
    ) -> KnowledgeProviderClaimInput {
        KnowledgeProviderClaimInput(
            providerClaimKey: providerClaimKey,
            providerID: "provider-1",
            subject: "deadline",
            summary: summary,
            detail: nil,
            source: KnowledgeProviderSourceInput(
                providerSourceKey: "calendar-source",
                entityTitle: "Application calendar",
                publisher: "Admissions office",
                locator: "https://example.com/calendar",
                provenanceKind: provenance,
                isOfficial: isOfficial
            ),
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-19T12:00:00Z",
                publishedAt: "2026-04-18T12:00:00Z",
                staleAfter: freshnessState == .fresh ? "2026-04-26T12:00:00Z" : "2026-04-19T12:00:00Z",
                expiresAt: freshnessState == .expired ? "2026-04-19T12:00:00Z" : nil,
                state: freshnessState
            ),
            trustLevel: trustLevel,
            confidence: trustLevel == .low ? .low : .high,
            uncertaintyFlags: uncertaintyFlags
        )
    }
}
