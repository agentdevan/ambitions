import XCTest
@testable import Ambitions

final class SourceAtlasPDFImportBoundaryModelsTests: XCTestCase {
    func testLocalPDFRouteDefaultsToUserProvidedSourceNeededAndPrivacyReviewRequired() {
        let candidate = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "/Users/devan/Documents/handbook.pdf",
                title: " Handbook PDF "
            )
        )

        XCTAssertEqual(candidate.route, .localFile)
        XCTAssertEqual(candidate.sourceKind, .userProvided)
        XCTAssertEqual(candidate.provenanceState, .localFile)
        XCTAssertEqual(candidate.sourceState, .sourceNeeded)
        XCTAssertEqual(candidate.freshnessState, .unknown)
        XCTAssertEqual(candidate.reviewState, .needsPrivacyReview)
        XCTAssertEqual(candidate.privacyClass, .sensitive)
        XCTAssertTrue(candidate.requiresReview)
        XCTAssertFalse(candidate.canMutateWithoutReview)
        XCTAssertFalse(candidate.canSupportOfficialCurrentClaim)
        XCTAssertEqual(candidate.container.kind, .pdf)
        XCTAssertEqual(candidate.container.provenanceState, .localFile)
        XCTAssertEqual(candidate.container.reviewState, .needsPrivacyReview)
        XCTAssertFalse(candidate.container.canSupportOfficialCurrentClaim)
    }

    func testPDFURLRouteClassificationPreservesLocatorAndPrivacyPosture() {
        let candidate = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: " https://example.com/guide.pdf ",
                canonicalLocator: "https://cdn.example.com/guide-final.pdf",
                title: "Guide PDF"
            )
        )

        XCTAssertEqual(candidate.route, .pdfURL)
        XCTAssertEqual(candidate.originalLocator, "https://example.com/guide.pdf")
        XCTAssertEqual(candidate.canonicalLocator, "https://cdn.example.com/guide-final.pdf")
        XCTAssertEqual(candidate.provenanceState, .sourceAttached)
        XCTAssertEqual(candidate.container.locator, "https://cdn.example.com/guide-final.pdf")
        XCTAssertEqual(candidate.container.kind, .pdf)
        XCTAssertEqual(candidate.container.provenanceState, .sourceAttached)
        XCTAssertEqual(candidate.container.privacyClass, .sensitive)
        XCTAssertTrue(candidate.requiresReview)
    }

    func testNormalizedLocatorAndGeneratedHashAreDeterministic() {
        let request = Self.request(
            originalLocator: " https://example.com/source.pdf ",
            title: " Source PDF ",
            declaredFailure: .none
        )

        let first = SourceAtlasPDFImportBoundary().importPDF(request)
        let second = SourceAtlasPDFImportBoundary().importPDF(request)

        XCTAssertEqual(first.sourceHash, second.sourceHash)
        XCTAssertTrue(first.sourceHash.hasPrefix("fnv1a64:"))
        XCTAssertEqual(first.route, .pdfURL)
        XCTAssertEqual(first.container.locator, "https://example.com/source.pdf")
    }

    func testLockedEncryptedCorruptHugePartialNoTextPrivateSensitiveAndUnsupportedFailuresStaySafe() {
        let locked = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "/Users/devan/Documents/locked.pdf",
                declaredFailure: .lockedOrEncrypted
            )
        )
        let corrupt = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "https://example.com/corrupt.pdf",
                declaredFailure: .corrupt
            )
        )
        let huge = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "/Users/devan/Documents/huge.pdf",
                declaredFailure: .huge
            )
        )
        let partial = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "https://example.com/partial.pdf",
                declaredFailure: .partial
            )
        )
        let noText = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "https://example.com/notext.pdf",
                declaredFailure: .noText
            )
        )
        let privateSensitive = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "https://example.com/private.pdf",
                declaredFreshnessState: .current,
                declaredFailure: .privateSensitive
            )
        )
        let unsupported = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(originalLocator: "ftp://example.com/source.pdf")
        )

        XCTAssertEqual(locked.failure, .lockedOrEncrypted)
        XCTAssertEqual(locked.container.failureState, .inaccessible)
        XCTAssertEqual(corrupt.failure, .corrupt)
        XCTAssertEqual(corrupt.container.failureState, .extractionFailed)
        XCTAssertEqual(huge.failure, .huge)
        XCTAssertEqual(huge.container.failureState, .inaccessible)
        XCTAssertEqual(partial.failure, .partial)
        XCTAssertEqual(partial.container.failureState, .extractionFailed)
        XCTAssertEqual(noText.failure, .noText)
        XCTAssertEqual(noText.container.failureState, .extractionFailed)
        XCTAssertEqual(privateSensitive.failure, .privateSensitive)
        XCTAssertEqual(privateSensitive.container.failureState, .privacyReviewRequired)
        XCTAssertEqual(privateSensitive.reviewState, .needsPrivacyReview)
        XCTAssertEqual(unsupported.failure, .unsupported)
        XCTAssertEqual(unsupported.container.failureState, .unsupportedFormat)
        XCTAssertTrue([locked, corrupt, huge, partial, noText, privateSensitive, unsupported].allSatisfy(\.requiresReview))
        XCTAssertTrue([locked, corrupt, huge, partial, noText, privateSensitive, unsupported].allSatisfy { $0.canMutateWithoutReview == false })
        XCTAssertTrue([locked, corrupt, huge, partial, noText, privateSensitive, unsupported].allSatisfy { $0.canSupportOfficialCurrentClaim == false })
    }

    func testNonPDFLocalAndURLLocatorsAreUnsupported() {
        let localTextFile = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(originalLocator: "/Users/devan/Documents/source.txt")
        )
        let webPage = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(originalLocator: "https://example.com/source.html")
        )

        XCTAssertNil(localTextFile.route)
        XCTAssertNil(webPage.route)
        XCTAssertEqual(localTextFile.failure, .unsupported)
        XCTAssertEqual(webPage.failure, .unsupported)
        XCTAssertEqual(localTextFile.container.failureState, .unsupportedFormat)
        XCTAssertEqual(webPage.container.failureState, .unsupportedFormat)
        XCTAssertFalse(localTextFile.canSupportOfficialCurrentClaim)
        XCTAssertFalse(webPage.canSupportOfficialCurrentClaim)
    }

    func testOfficialOrCurrentDeclaredStatesAreDowngradedToSourceNeeded() {
        let officialStates: [SourceAtlasRequirementSourceState] = [
            .official,
            .officialCurrent,
            .current
        ]

        for state in officialStates {
            let candidate = SourceAtlasPDFImportBoundary().importPDF(
                Self.request(
                    originalLocator: "https://example.com/\(state.rawValue).pdf",
                    declaredSourceState: state,
                    declaredFreshnessState: .current
                )
            )

            XCTAssertEqual(candidate.sourceState, .sourceNeeded)
            XCTAssertEqual(candidate.freshnessState, .needsReview)
            XCTAssertFalse(candidate.canSupportOfficialCurrentClaim)
            XCTAssertFalse(candidate.container.canSupportOfficialCurrentClaim)
        }
    }

    func testDistinctUnknownSourceNeededStaleContradictedRevokedAndLocalProofStatesArePreserved() {
        let states: [SourceAtlasRequirementSourceState] = [
            .unknown,
            .sourceNeeded,
            .stale,
            .contradicted,
            .revoked,
            .locallyProven
        ]

        for state in states {
            let candidate = SourceAtlasPDFImportBoundary().importPDF(
                Self.request(
                    originalLocator: "https://example.com/\(state.rawValue).pdf",
                    declaredSourceState: state
                )
            )

            XCTAssertEqual(candidate.sourceState, state)
            XCTAssertTrue(candidate.requiresReview)
            XCTAssertFalse(candidate.canMutateWithoutReview)
        }
    }

    func testCurrentFreshnessIsDowngradedWhileNonCurrentStatesStayDistinct() {
        let current = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "/Users/devan/Documents/current.pdf",
                declaredFreshnessState: .current
            )
        )
        let stale = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "/Users/devan/Documents/stale.pdf",
                declaredFreshnessState: .stale
            )
        )
        let unknown = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "/Users/devan/Documents/unknown.pdf",
                declaredFreshnessState: .unknown
            )
        )
        let revoked = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "/Users/devan/Documents/revoked.pdf",
                declaredFreshnessState: .revoked
            )
        )

        XCTAssertEqual(current.freshnessState, .needsReview)
        XCTAssertEqual(stale.freshnessState, .stale)
        XCTAssertEqual(unknown.freshnessState, .unknown)
        XCTAssertEqual(revoked.freshnessState, .revoked)
        XCTAssertTrue([current, stale, unknown, revoked].allSatisfy { $0.canSupportOfficialCurrentClaim == false })
    }

    func testLocallyProvenContainerKeepsLocalProofConservativeState() {
        let candidate = SourceAtlasPDFImportBoundary().importPDF(
            Self.request(
                originalLocator: "/Users/devan/Documents/local-proof.pdf",
                declaredSourceState: .locallyProven,
                declaredFreshnessState: .current
            )
        )

        XCTAssertEqual(candidate.sourceState, .locallyProven)
        XCTAssertEqual(candidate.container.sourceState, .locallyProven)
        XCTAssertEqual(candidate.container.conservativeRequirementSourceState, .locallyProven)
        XCTAssertFalse(candidate.container.canSupportOfficialCurrentClaim)
        XCTAssertFalse(candidate.container.canSupportLocalProofClaim)
    }
}

private extension SourceAtlasPDFImportBoundaryModelsTests {
    static func request(
        id: String = "pdf-import",
        originalLocator: String,
        canonicalLocator: String? = nil,
        title: String? = nil,
        suppliedSourceHash: String? = nil,
        declaredSourceState: SourceAtlasRequirementSourceState = .sourceNeeded,
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown,
        declaredFailure: SourceAtlasPDFImportFailure = .none
    ) -> SourceAtlasPDFImportRequest {
        SourceAtlasPDFImportRequest(
            id: id,
            originalLocator: originalLocator,
            canonicalLocator: canonicalLocator,
            title: title,
            suppliedSourceHash: suppliedSourceHash,
            declaredSourceState: declaredSourceState,
            declaredFreshnessState: declaredFreshnessState,
            declaredFailure: declaredFailure,
            createdAt: "2026-05-13T15:22:39Z",
            updatedAt: "2026-05-13T15:22:39Z"
        )
    }
}
