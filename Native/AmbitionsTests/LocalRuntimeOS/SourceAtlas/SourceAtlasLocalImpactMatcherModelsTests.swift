import XCTest
@testable import Ambitions

final class SourceAtlasLocalImpactMatcherModelsTests: XCTestCase {
    func testMatchesChangedPublicClaimIDsToLocalGoalBindingsOnly() {
        let response = SourceAtlasLocalImpactMatcher().match(
            changedClaims: SourceAtlasChangedPublicClaimSet(changedClaimIDs: ["claim-b", "claim-a", "claim-a"]),
            localBindings: [
                Self.binding(id: "binding-1", localGoalID: "goal-1", sourceClaimIDs: ["claim-a", "claim-c"]),
                Self.binding(id: "binding-2", localGoalID: "goal-2", sourceClaimIDs: ["claim-x"])
            ]
        )

        XCTAssertEqual(response.changedClaimIDs, ["claim-a", "claim-b"])
        XCTAssertEqual(response.matches.count, 1)
        XCTAssertEqual(response.matches.first?.affectedLocalGoalID, "goal-1")
        XCTAssertEqual(response.matches.first?.changedClaimIDs, ["claim-a"])
        XCTAssertTrue(response.runtimeBoundary.isValueModelOnly)
        XCTAssertFalse(response.runtimeBoundary.performsNetworkFetches)
        XCTAssertFalse(response.runtimeBoundary.writesPersistence)
        XCTAssertFalse(response.runtimeBoundary.mutatesPlans)
    }

    func testKeepsSourceNeededUnknownStaleContradictedRevokedAndLocalProofDistinct() {
        let states: [SourceAtlasRequirementSourceState] = [
            .unknown,
            .sourceNeeded,
            .stale,
            .contradicted,
            .revoked,
            .locallyProven
        ]
        let response = SourceAtlasLocalImpactMatcher().match(
            changedClaims: SourceAtlasChangedPublicClaimSet(changedClaimIDs: states.map { "claim-\($0.rawValue)" }),
            localBindings: states.map {
                Self.binding(
                    id: "binding-\($0.rawValue)",
                    localGoalID: "goal-\($0.rawValue)",
                    sourceClaimIDs: ["claim-\($0.rawValue)"],
                    sourceState: $0,
                    freshnessState: $0 == .stale || $0 == .revoked ? .stale : .current
                )
            }
        )

        let sourceStates = Set(response.matches.map { $0.sourceState })
        XCTAssertEqual(sourceStates, Set(states))
        XCTAssertEqual(response.matches.first(where: { $0.sourceState == .unknown })?.receiptPreview.claimBoundary, .sourceNeeded)
        XCTAssertEqual(response.matches.first(where: { $0.sourceState == .sourceNeeded })?.receiptPreview.claimBoundary, .sourceNeeded)
        XCTAssertEqual(response.matches.first(where: { $0.sourceState == .stale })?.receiptPreview.freshnessState, .stale)
        XCTAssertEqual(response.matches.first(where: { $0.sourceState == .contradicted })?.receiptPreview.sourceState, .contradicted)
        XCTAssertEqual(response.matches.first(where: { $0.sourceState == .revoked })?.receiptPreview.sourceState, .revoked)
        XCTAssertEqual(response.matches.first(where: { $0.sourceState == .locallyProven })?.receiptPreview.sourceState, .locallyProven)
    }

    func testReceiptPreviewIsConservativeAndLocalOnly() {
        let response = SourceAtlasLocalImpactMatcher().match(
            changedClaims: SourceAtlasChangedPublicClaimSet(changedClaimIDs: ["claim-deadline"]),
            localBindings: [
                Self.binding(
                    id: "binding-deadline",
                    localGoalID: "goal-certification",
                    sourceClaimIDs: ["claim-deadline"],
                    sourceRecordIDs: ["source-handbook"],
                    sourceState: .officialCurrent,
                    freshnessState: .current,
                    reviewState: .approved,
                    provenanceIDs: ["snapshot-1"]
                )
            ]
        )

        let receipt = response.receiptPreviews.first
        XCTAssertEqual(receipt?.affectedLocalGoalIDs, ["goal-certification"])
        XCTAssertEqual(receipt?.changedClaimIDs, ["claim-deadline"])
        XCTAssertEqual(receipt?.sourceRecordIDs, ["source-handbook"])
        XCTAssertEqual(receipt?.provenanceIDs, ["snapshot-1", "source-handbook"])
        XCTAssertEqual(receipt?.sourceState, .officialCurrent)
        XCTAssertEqual(receipt?.freshnessState, .current)
        XCTAssertEqual(receipt?.reviewRequired, true)
        XCTAssertEqual(receipt?.claimBoundary, .reviewRequired)
    }

    func testEncodedReceiptDoesNotExposePercentageLanguage() throws {
        let response = SourceAtlasLocalImpactMatcher().match(
            changedClaims: SourceAtlasChangedPublicClaimSet(changedClaimIDs: ["claim-a"]),
            localBindings: [
                Self.binding(id: "binding-1", localGoalID: "goal-1", sourceClaimIDs: ["claim-a"])
            ]
        )
        let encoded = String(data: try JSONEncoder().encode(response), encoding: .utf8) ?? ""

        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("mo" + "del"))
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("per" + "cent"))
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("con" + "fidence"))
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("official_validation"))
    }
}

private extension SourceAtlasLocalImpactMatcherModelsTests {
    static func binding(
        id: String,
        localGoalID: String,
        sourceClaimIDs: [String],
        sourceRecordIDs: [String] = [],
        sourceState: SourceAtlasRequirementSourceState = .stale,
        freshnessState: SourceAtlasRequirementFreshnessState = .stale,
        reviewState: SourceAtlasRequirementReviewState = .required,
        provenanceIDs: [String] = []
    ) -> SourceAtlasLocalGoalSourceBinding {
        SourceAtlasLocalGoalSourceBinding(
            id: id,
            localGoalID: localGoalID,
            sourceClaimIDs: sourceClaimIDs,
            sourceRecordIDs: sourceRecordIDs,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            provenanceIDs: provenanceIDs
        )
    }
}
