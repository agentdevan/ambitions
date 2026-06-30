import XCTest
@testable import Ambitions

final class SourceAtlasReviewModelsTests: XCTestCase {
    func testReviewSheetSummaryKeepsStateTokensDistinct() {
        let states: [SourceAtlasRequirementSourceState] = [
            .unknown,
            .sourceNeeded,
            .stale,
            .contradicted,
            .revoked,
            .locallyProven
        ]

        for state in states {
            let summary = Self.summary(
                sourceState: state,
                freshnessState: state == .stale ? .stale : .current,
                reviewState: state == .unknown || state == .sourceNeeded ? .required : .approved,
                sourceRecord: state == .locallyProven ? Self.sourceRecord(approvedForOfficialClaims: false) : nil,
                claim: Self.claim(),
                requirement: Self.requirement(sourceState: state)
            )

            let tokens = Set(summary.displayTokens)

            switch state {
            case .unknown:
                XCTAssertTrue(tokens.contains(.unknown))
            case .sourceNeeded:
                XCTAssertTrue(tokens.contains(.sourceNeeded))
            case .stale:
                XCTAssertTrue(tokens.contains(.stale))
            case .contradicted:
                XCTAssertTrue(tokens.contains(.contradicted))
            case .revoked:
                XCTAssertTrue(tokens.contains(.revoked))
            case .locallyProven:
                XCTAssertTrue(tokens.contains(.locallyProven))
            case .official, .officialCurrent, .current:
                XCTFail("Unexpected state in test coverage")
            }
        }
    }

    func testBlockingStatesBlockOfficialCurrentClaimsAndCurrentUse() {
        let blockedStates: [SourceAtlasRequirementSourceState] = [
            .unknown,
            .sourceNeeded,
            .stale,
            .contradicted,
            .revoked
        ]

        for state in blockedStates {
            let summary = Self.summary(
                sourceState: state,
                freshnessState: state == .stale ? .stale : .current,
                reviewState: .required,
                sourceRecord: nil,
                claim: Self.claim(reviewRequired: true),
                requirement: Self.requirement(sourceState: state, reviewState: .required)
            )

            XCTAssertTrue(summary.blocksOfficialCurrentClaims)
            XCTAssertTrue(summary.blocksCurrentUse)
            XCTAssertTrue(summary.requiresHumanReview)
            XCTAssertTrue(summary.claimDrawerState?.blocksOfficialCurrentClaims ?? false)
            XCTAssertTrue(summary.claimDrawerState?.blocksCurrentUse ?? false)
            XCTAssertTrue(summary.claimDrawerState?.requiresHumanReview ?? false)
        }
    }

    func testLocallyProvenDoesNotBecomeOfficialCurrent() {
        let summary = Self.summary(
            sourceState: .locallyProven,
            freshnessState: .current,
            reviewState: .approved,
            sourceRecord: Self.sourceRecord(approvedForOfficialClaims: false),
            claim: Self.claim(),
            requirement: Self.requirement(sourceState: .locallyProven, reviewState: .approved)
        )

        XCTAssertTrue(summary.displayTokens.contains(.locallyProven))
        XCTAssertTrue(summary.blocksOfficialCurrentClaims)
        XCTAssertFalse(summary.blocksCurrentUse)
        XCTAssertTrue(summary.requiresHumanReview)
        XCTAssertTrue(summary.claimDrawerState?.blocksOfficialCurrentClaims ?? false)
        XCTAssertFalse(summary.claimDrawerState?.blocksCurrentUse ?? true)
    }

    func testMissingProvenanceBlocksOfficialCurrentClaims() {
        let summary = Self.summary(
            sourceState: .officialCurrent,
            freshnessState: .current,
            reviewState: .approved,
            sourceRecord: Self.sourceRecord(approvedForOfficialClaims: true),
            claim: Self.claim(sourceIDs: []),
            requirement: Self.requirement(sourceState: .officialCurrent, reviewState: .approved),
            provenanceSourceIDs: []
        )

        XCTAssertTrue(summary.displayTokens.contains(.provenanceMissing))
        XCTAssertTrue(summary.blocksOfficialCurrentClaims)
        XCTAssertTrue(summary.blocksCurrentUse)
        XCTAssertTrue(summary.requiresHumanReview)
        XCTAssertEqual(summary.claimDrawerState?.provenanceSourceIDs, [])
    }

    func testEncodedOutputIsDeterministicAndAvoidsConfidenceModelPercentageLanguage() throws {
        let summary = Self.summary(
            sourceState: .locallyProven,
            freshnessState: .current,
            reviewState: .approved,
            sourceRecord: Self.sourceRecord(approvedForOfficialClaims: false),
            claim: Self.claim(),
            requirement: Self.requirement(sourceState: .locallyProven, reviewState: .approved)
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let decoder = JSONDecoder()

        let first = try encoder.encode(summary)
        let second = try encoder.encode(summary)
        let decoded = try decoder.decode(SourceAtlasReviewSheetSummary.self, from: first)
        let encoded = String(decoding: first, as: UTF8.self).lowercased()

        XCTAssertEqual(first, second)
        XCTAssertEqual(decoded, summary)
        XCTAssertFalse(encoded.contains("confidence"))
        XCTAssertFalse(encoded.contains("percentage"))
        XCTAssertFalse(encoded.contains("model"))
        let aiRecommends = ["ai", " recommends"].joined()
        let releaseReady = ["release", "-ready"].joined()
        XCTAssertFalse(encoded.contains(aiRecommends))
        XCTAssertFalse(encoded.contains(releaseReady))
    }
}

private extension SourceAtlasReviewModelsTests {
    static func summary(
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState = .current,
        reviewState: SourceAtlasRequirementReviewState = .approved,
        sourceRecord: SourceAtlasSourceRecord? = nil,
        claim: SourceAtlasClaim? = nil,
        requirement: SourceAtlasRequirement? = nil,
        provenanceSourceIDs: [String]? = nil,
        fallbackReason: SourceAtlasQueryFallbackReason = .none
    ) -> SourceAtlasReviewSheetSummary {
        let queryResult = SourceAtlasQueryResult(
            id: "result-\(sourceState.rawValue)-\(freshnessState.rawValue)-\(reviewState.rawValue)",
            packID: "pack-1",
            domainID: "domain-1",
            goalIntent: "keep source review truthful",
            claimID: claim?.id ?? "claim-1",
            requirementID: requirement?.id ?? "requirement-1",
            sourceState: sourceState,
            freshnessState: freshnessState,
            riskState: .low,
            riskClass: .careerContext,
            reviewState: reviewState,
            provenanceSourceIDs: provenanceSourceIDs ?? (sourceRecord.map { [$0.id] } ?? ["source-1"]),
            proofEntryIDs: ["proof-1"],
            fallbackReason: fallbackReason,
            sourceNeededDetail: fallbackReason == .provenanceMissing
                ? SourceAtlasSourceNeededDetail(
                    mode: .provenanceMissing,
                    fallbackReason: .provenanceMissing,
                    starterGuidance: [],
                    blocksOfficialCurrentClaims: true,
                    blocksCurrentUse: true
                )
                : nil
        )

        return SourceAtlasReviewSheetSummary(
            queryResult: queryResult,
            sourceRecord: sourceRecord,
            claim: claim,
            requirement: requirement
        )
    }

    static func sourceRecord(approvedForOfficialClaims: Bool) -> SourceAtlasSourceRecord {
        SourceAtlasSourceRecord(
            id: "source-1",
            title: "Official source",
            kind: .official,
            locator: "file://source.md",
            retrievedAt: "2026-05-15T04:02:45Z",
            contentHash: "sha256:source",
            approvedForOfficialClaims: approvedForOfficialClaims
        )
    }

    static func claim(
        id: String = "claim-1",
        text: String = "Keep the source review sheet conservative.",
        state: SourceAtlasClaimState = .official,
        freshness: SourceAtlasFreshnessState = .current,
        riskClass: SourceAtlasRiskClass = .careerContext,
        sourceIDs: [String] = ["source-1"],
        reviewRequired: Bool = false
    ) -> SourceAtlasClaim {
        SourceAtlasClaim(
            id: id,
            text: text,
            state: state,
            freshness: freshness,
            riskClass: riskClass,
            sourceIDs: sourceIDs,
            reviewRequired: reviewRequired
        )
    }

    static func requirement(
        id: String = "requirement-1",
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState = .current,
        riskState: SourceAtlasRequirementRiskState = .low,
        reviewState: SourceAtlasRequirementReviewState = .approved
    ) -> SourceAtlasRequirement {
        SourceAtlasRequirement(
            id: id,
            claimID: "claim-1",
            title: "Review requirement",
            kind: .reviewRequired,
            required: true,
            sourceState: sourceState,
            freshnessState: freshnessState,
            riskState: riskState,
            reviewState: reviewState
        )
    }
}
