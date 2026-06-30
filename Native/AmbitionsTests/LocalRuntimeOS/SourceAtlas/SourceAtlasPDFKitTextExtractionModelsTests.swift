import PDFKit
import XCTest
import UIKit
@testable import Ambitions

final class SourceAtlasPDFKitTextExtractionModelsTests: XCTestCase {
    func testEmbeddedTextExtractionProducesPageAwareLocatorsAndReviewRequiredCandidate() {
        let request = Self.request(
            importCandidate: Self.importCandidate(
                originalLocator: "https://example.com/handbook.pdf",
                title: "Handbook PDF"
            ),
            pdfData: Self.pdfData(pages: [
                "First page\nwith embedded text.",
                "Second page text stays embedded."
            ])
        )

        let candidate = SourceAtlasPDFKitTextExtractor().extractText(request)

        XCTAssertEqual(candidate.pageLocators.count, 2)
        XCTAssertEqual(candidate.pageLocators.first?.locator, "page:1")
        XCTAssertEqual(candidate.pageLocators.first?.text, "First page with embedded text.")
        XCTAssertEqual(candidate.pageLocators.last?.locator, "page:2")
        XCTAssertEqual(candidate.pageLocators.last?.text, "Second page text stays embedded.")
        XCTAssertEqual(candidate.extractionQuality, .normalizedTextBlocks)
        XCTAssertEqual(candidate.failure, .none)
        XCTAssertTrue(candidate.requiresReview)
        XCTAssertFalse(candidate.canMutateWithoutReview)
        XCTAssertFalse(candidate.canSupportOfficialCurrentClaim)
        XCTAssertEqual(candidate.reviewState, .needsPrivacyReview)
        XCTAssertEqual(candidate.container.kind, .pdf)
        XCTAssertEqual(candidate.container.reviewState, .needsPrivacyReview)
        XCTAssertEqual(candidate.container.canSupportOfficialCurrentClaim, false)
    }

    func testPartialNoTextAndFailedStatesStayConservative() {
        let partial = SourceAtlasPDFKitTextExtractor().extractText(
            Self.request(
                importCandidate: Self.importCandidate(
                    originalLocator: "/Users/devan/Documents/partial.pdf",
                    declaredSourceState: .locallyProven,
                    declaredFreshnessState: .stale
                ),
                pdfData: Self.pdfData(pages: [
                    "One page has text.",
                    nil
                ])
            )
        )
        let noText = SourceAtlasPDFKitTextExtractor().extractText(
            Self.request(
                importCandidate: Self.importCandidate(
                    originalLocator: "/Users/devan/Documents/notext.pdf",
                    declaredSourceState: .sourceNeeded,
                    declaredFreshnessState: .unknown
                ),
                pdfData: Self.pdfData(pages: [
                    nil
                ])
            )
        )
        let failed = SourceAtlasPDFKitTextExtractor().extractText(
            Self.request(
                importCandidate: Self.importCandidate(
                    originalLocator: "/Users/devan/Documents/failed.pdf",
                    declaredSourceState: .revoked,
                    declaredFreshnessState: .revoked
                ),
                pdfData: Data()
            )
        )

        XCTAssertEqual(partial.extractionQuality, .partial)
        XCTAssertEqual(partial.fallbackReason, .reviewRequired)
        XCTAssertEqual(partial.sourceState, .locallyProven)
        XCTAssertEqual(partial.freshnessState, .stale)
        XCTAssertEqual(partial.container.conservativeRequirementSourceState, .stale)
        XCTAssertEqual(partial.container.failureState, .extractionFailed)

        XCTAssertEqual(noText.extractionQuality, .noText)
        XCTAssertEqual(noText.fallbackReason, .sourceNeeded)
        XCTAssertEqual(noText.sourceState, .sourceNeeded)
        XCTAssertEqual(noText.container.failureState, .sourceMissing)

        XCTAssertEqual(failed.extractionQuality, .failed)
        XCTAssertEqual(failed.failure, .emptyData)
        XCTAssertEqual(failed.fallbackReason, .sourceNeeded)
        XCTAssertEqual(failed.sourceState, .revoked)
        XCTAssertEqual(failed.freshnessState, .revoked)
        XCTAssertEqual(failed.container.failureState, .revoked)

        XCTAssertTrue([partial, noText, failed].allSatisfy(\.requiresReview))
        XCTAssertTrue([partial, noText, failed].allSatisfy { $0.canMutateWithoutReview == false })
        XCTAssertTrue([partial, noText, failed].allSatisfy { $0.canSupportOfficialCurrentClaim == false })
    }

    func testDistinctSourceStatesRemainDistinctAcrossExtraction() {
        let states: [SourceAtlasRequirementSourceState] = [
            .unknown,
            .sourceNeeded,
            .stale,
            .contradicted,
            .revoked,
            .locallyProven
        ]

        for state in states {
            let candidate = SourceAtlasPDFKitTextExtractor().extractText(
                Self.request(
                    importCandidate: Self.importCandidate(
                        originalLocator: "https://example.com/\(state.rawValue).pdf",
                        declaredSourceState: state,
                        declaredFreshnessState: .unknown
                    ),
                    pdfData: Self.pdfData(pages: [
                        "Source-state preservation stays explicit."
                    ])
                )
            )

            XCTAssertEqual(candidate.sourceState, state)
            XCTAssertEqual(candidate.container.sourceState, state)
            XCTAssertTrue(candidate.requiresReview)
            XCTAssertFalse(candidate.canMutateWithoutReview)
        }
    }

    func testStableSourceHashIsDeterministic() {
        let request = Self.request(
            importCandidate: Self.importCandidate(
                originalLocator: "https://example.com/stable.pdf",
                title: "Stable PDF"
            ),
            pdfData: Self.pdfData(pages: [
                "Stable text for hashing."
            ])
        )

        let first = SourceAtlasPDFKitTextExtractor().extractText(request)
        let second = SourceAtlasPDFKitTextExtractor().extractText(request)

        XCTAssertEqual(first.sourceHash, second.sourceHash)
        XCTAssertTrue(first.sourceHash.hasPrefix("fnv1a64:"))
        XCTAssertEqual(first.pageLocators, second.pageLocators)
    }
}

private extension SourceAtlasPDFKitTextExtractionModelsTests {
    static func request(
        id: String = "pdfkit-text-extraction",
        importCandidate: SourceAtlasPDFImportCandidate,
        pdfData: Data,
        title: String? = nil,
        canonicalLocator: String? = nil
    ) -> SourceAtlasPDFKitTextExtractionRequest {
        SourceAtlasPDFKitTextExtractionRequest(
            id: id,
            importCandidate: importCandidate,
            originalLocator: importCandidate.originalLocator,
            canonicalLocator: canonicalLocator ?? importCandidate.canonicalLocator,
            title: title ?? importCandidate.title,
            pdfData: pdfData,
            createdAt: "2026-05-15T02:12:09Z",
            updatedAt: "2026-05-15T02:12:09Z"
        )
    }

    static func importCandidate(
        originalLocator: String,
        title: String? = "PDF needs review",
        declaredSourceState: SourceAtlasRequirementSourceState = .sourceNeeded,
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown
    ) -> SourceAtlasPDFImportCandidate {
        SourceAtlasPDFImportBoundary().importPDF(
            SourceAtlasPDFImportRequest(
                id: "pdf-import-\(originalLocator.hashValue)",
                originalLocator: originalLocator,
                title: title,
                declaredSourceState: declaredSourceState,
                declaredFreshnessState: declaredFreshnessState,
                createdAt: "2026-05-15T02:12:09Z",
                updatedAt: "2026-05-15T02:12:09Z"
            )
        )
    }

    static func pdfData(pages: [String?]) -> Data {
        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: 300, height: 400)
        )
        return renderer.pdfData { context in
            for pageText in pages {
                context.beginPage()
                guard let pageText else {
                    continue
                }
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.black
                ]
                pageText.draw(
                    in: CGRect(x: 24, y: 24, width: 252, height: 352),
                    withAttributes: attributes
                )
            }
        }
    }
}
