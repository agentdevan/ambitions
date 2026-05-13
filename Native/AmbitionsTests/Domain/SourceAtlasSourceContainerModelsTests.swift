import XCTest
@testable import Ambitions

final class SourceAtlasSourceContainerModelsTests: XCTestCase {
    func testOfficialPackCanSupportOfficialCurrentClaimOnlyWithApprovedProvenance() {
        let container = Self.container(
            kind: .officialPack,
            sourceKind: .official,
            provenanceState: .approvedOfficial,
            sourceState: .officialCurrent,
            freshnessState: .current,
            reviewState: .ready,
            sourceRecordIDs: ["source-official"]
        )

        XCTAssertTrue(container.isWellFormed)
        XCTAssertFalse(container.requiresReview)
        XCTAssertTrue(container.canSupportOfficialCurrentClaim)
        XCTAssertEqual(container.conservativeRequirementSourceState, .officialCurrent)
        XCTAssertFalse(container.blocksCurrentUse)
    }

    func testUserProvidedCopiedOcrAndMiniPackContentStayReviewRequired() {
        let containers = [
            Self.container(kind: .url, provenanceState: .userProvided, reviewState: .ready),
            Self.container(kind: .plainText, provenanceState: .copiedContent, extractionState: .copiedText, reviewState: .ready),
            Self.container(kind: .image, provenanceState: .ocrDerived, extractionState: .ocrDerived, reviewState: .ready),
            Self.container(kind: .userMiniPack, provenanceState: .userMiniPack, reviewState: .ready)
        ]

        XCTAssertTrue(containers.allSatisfy { $0.requiresReview })
        XCTAssertTrue(containers.allSatisfy { $0.reviewState == .needsSourceReview })
        XCTAssertTrue(containers.allSatisfy { $0.canSupportOfficialCurrentClaim == false })
        XCTAssertTrue(containers.allSatisfy(\.blocksCurrentUse))
    }

    func testRequiredSourceStatesRemainDistinct() {
        let states: [(SourceAtlasRequirementSourceState, SourceAtlasSourceContainerFailureState)] = [
            (.unknown, .none),
            (.sourceNeeded, .sourceMissing),
            (.stale, .stale),
            (.contradicted, .contradicted),
            (.revoked, .revoked),
            (.locallyProven, .none)
        ]

        for (sourceState, failureState) in states {
            let container = Self.container(
                provenanceState: sourceState == .locallyProven ? .sourceAttached : .unknown,
                sourceState: sourceState,
                reviewState: sourceState == .locallyProven ? .ready : .needsSourceReview,
                failureState: .none,
                sourceRecordIDs: sourceState == .locallyProven ? ["local-proof"] : []
            )

            XCTAssertEqual(container.sourceState, sourceState)
            XCTAssertEqual(container.failureState, failureState)
        }
    }

    func testLocalProofDoesNotBecomeOfficialCurrent() {
        let container = Self.container(
            kind: .localFile,
            sourceKind: .userProvided,
            provenanceState: .sourceAttached,
            sourceState: .locallyProven,
            freshnessState: .current,
            reviewState: .ready,
            sourceRecordIDs: ["local-proof"]
        )

        XCTAssertTrue(container.canSupportLocalProofClaim)
        XCTAssertFalse(container.canSupportOfficialCurrentClaim)
        XCTAssertEqual(container.conservativeRequirementSourceState, .locallyProven)
    }

    func testAllApprovedContainerKindsRoundTripThroughCodable() throws {
        let containers = [
            Self.container(kind: .url, locator: "https://example.com/source"),
            Self.container(kind: .pdf, locator: "file://source.pdf"),
            Self.container(kind: .image, locator: "file://source.png"),
            Self.container(kind: .plainText, locator: nil),
            Self.container(kind: .localFile, locator: "file://source.txt"),
            Self.container(kind: .officialPack, locator: "ambitions://source-atlas/official"),
            Self.container(kind: .userMiniPack, locator: "ambitions://source-atlas/user-mini", provenanceState: .userMiniPack)
        ]

        let data = try JSONEncoder().encode(containers)
        let decoded = try JSONDecoder().decode([SourceAtlasSourceContainer].self, from: data)

        XCTAssertEqual(decoded, containers)
        XCTAssertEqual(Set(decoded.map { $0.kind }), Set(SourceAtlasSourceContainerKind.allCases))
    }

    func testStaleContradictedAndRevokedFreshnessAreConservative() {
        let stale = Self.container(
            provenanceState: .approvedOfficial,
            sourceState: .officialCurrent,
            freshnessState: .stale,
            reviewState: .ready,
            sourceRecordIDs: ["source-official"]
        )
        let contradicted = Self.container(
            provenanceState: .approvedOfficial,
            sourceState: .officialCurrent,
            freshnessState: .disputed,
            reviewState: .ready,
            sourceRecordIDs: ["source-official"]
        )
        let revoked = Self.container(
            provenanceState: .approvedOfficial,
            sourceState: .officialCurrent,
            freshnessState: .revoked,
            reviewState: .ready,
            sourceRecordIDs: ["source-official"]
        )

        XCTAssertEqual(stale.conservativeRequirementSourceState, .stale)
        XCTAssertEqual(contradicted.conservativeRequirementSourceState, .contradicted)
        XCTAssertEqual(revoked.conservativeRequirementSourceState, .revoked)
        XCTAssertTrue([stale, contradicted, revoked].allSatisfy { $0.blocksCurrentUse })
    }
}

private extension SourceAtlasSourceContainerModelsTests {
    static func container(
        kind: SourceAtlasSourceContainerKind = .url,
        sourceKind: SourceAtlasSourceKind = .unknown,
        locator: String? = "ambitions://source",
        provenanceState: SourceAtlasSourceContainerProvenanceState = .unknown,
        extractionState: SourceAtlasSourceContainerExtractionState = .sourceLinked,
        sourceState: SourceAtlasRequirementSourceState = .unknown,
        freshnessState: SourceAtlasFreshnessState = .unknown,
        reviewState: HumanProgressReviewState = .needsSourceReview,
        failureState: SourceAtlasSourceContainerFailureState = .none,
        sourceRecordIDs: [String] = [],
        claimIDs: [String] = []
    ) -> SourceAtlasSourceContainer {
        SourceAtlasSourceContainer(
            id: "container-\(kind.rawValue)-\(sourceState.rawValue)",
            title: "Source container",
            kind: kind,
            sourceKind: sourceKind,
            locator: locator,
            provenanceState: provenanceState,
            extractionState: extractionState,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: .privateLife,
            failureState: failureState,
            sourceRecordIDs: sourceRecordIDs,
            claimIDs: claimIDs,
            createdAt: "2026-05-13T05:52:58Z",
            updatedAt: "2026-05-13T05:52:58Z"
        )
    }
}
