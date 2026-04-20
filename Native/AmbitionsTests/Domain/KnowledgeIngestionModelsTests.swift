import XCTest
@testable import Ambitions

final class KnowledgeIngestionModelsTests: XCTestCase {
    func testKnowledgeIngestionTypesRoundTripThroughCodable() throws {
        let result = KnowledgeIngestionResult(
            claimSet: KnowledgeClaimSet(
                claims: [],
                conflictState: .none,
                degradationSummary: "local_only_mode"
            ),
            sources: [
                KnowledgeSourceRecord(
                    id: "source-1",
                    providerID: "provider-1",
                    entityTitle: "Official deadline page",
                    publisher: "Agency",
                    locator: "https://example.com/deadline",
                    provenanceKind: .official,
                    isOfficial: true
                )
            ],
            conflictGroups: [
                KnowledgeConflictGroup(
                    subject: "deadline",
                    claimIDs: ["claim-1", "claim-2"],
                    sourceIDs: ["source-1", "source-2"],
                    reason: "multiple_distinct_claim_values"
                )
            ],
            degradationStates: [.localOnlyMode, .conflictingClaims],
            providerStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider-1",
                        type: .officialAPI,
                        displayName: "Official API"
                    ),
                    availability: .available,
                    detail: "Available",
                    runtimeTrustPosture: .localOnly
                )
            ]
        )

        let encoded = try JSONEncoder().encode(result)
        let decoded = try JSONDecoder().decode(KnowledgeIngestionResult.self, from: encoded)

        XCTAssertEqual(decoded, result)
    }

    func testProviderClaimInputPreservesStructuralMetadata() {
        let input = KnowledgeProviderClaimInput(
            providerClaimKey: "claim-1",
            providerID: "provider-1",
            subject: "deadline",
            summary: "Deadline is May 1",
            detail: "Applies to standard applications.",
            source: KnowledgeProviderSourceInput(
                providerSourceKey: "source-1",
                entityTitle: "Application calendar",
                publisher: "Admissions office",
                locator: "https://example.com/calendar",
                provenanceKind: .official,
                isOfficial: true
            ),
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-19T12:00:00Z",
                publishedAt: "2026-04-18T12:00:00Z",
                staleAfter: "2026-04-26T12:00:00Z",
                expiresAt: "2026-05-10T12:00:00Z",
                state: .fresh
            ),
            trustLevel: .high,
            confidence: .high,
            uncertaintyFlags: [.inferred]
        )

        XCTAssertEqual(input.source.provenanceKind, .official)
        XCTAssertTrue(input.source.isOfficial)
        XCTAssertEqual(input.freshness.state, .fresh)
        XCTAssertEqual(input.trustLevel, .high)
        XCTAssertEqual(input.confidence, .high)
        XCTAssertEqual(input.uncertaintyFlags, [.inferred])
    }
}
