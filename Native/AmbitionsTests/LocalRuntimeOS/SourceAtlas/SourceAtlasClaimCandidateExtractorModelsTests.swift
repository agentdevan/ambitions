import XCTest
@testable import Ambitions

final class SourceAtlasClaimCandidateExtractorModelsTests: XCTestCase {
    func testExtractorPreservesLocatorHintsAndExtractsConservativeSignals() {
        let extraction = SourceAtlasClaimCandidateExtractor().extract(
            Self.input(
                title: "Training checklist",
                bodyText: """
                Bring a helmet before Friday.
                You must complete orientation before enrollment.
                Show proof of insurance and receipt.
                """,
                sourceLocator: "page 3 lines 12-18"
            )
        )

        XCTAssertEqual(extraction.sourceLocator, "page 3 lines 12-18")
        XCTAssertEqual(extraction.provenanceState, .sourceAttached)
        XCTAssertEqual(extraction.sourceState, .sourceNeeded)
        XCTAssertEqual(extraction.freshnessState, .unknown)
        XCTAssertEqual(extraction.reviewState, .needsSourceReview)
        XCTAssertTrue(extraction.reviewRequired)
        XCTAssertEqual(extraction.behavior, .valueModelOnly)
        XCTAssertFalse(extraction.behavior.performsNetworkAccess)
        XCTAssertFalse(extraction.behavior.persistsState)
        XCTAssertFalse(extraction.behavior.mutatesState)
        XCTAssertFalse(extraction.behavior.makesReleaseClaims)

        let kinds = Set(extraction.candidates.map(\.kind))
        XCTAssertTrue(kinds.contains(.equipment))
        XCTAssertTrue(kinds.contains(.deadline))
        XCTAssertTrue(kinds.contains(.prerequisite))
        XCTAssertTrue(kinds.contains(.requirement))
        XCTAssertTrue(kinds.contains(.proof))

        XCTAssertTrue(extraction.candidates.allSatisfy { $0.reviewRequired })
        XCTAssertTrue(extraction.candidates.allSatisfy { $0.reviewState == .needsSourceReview })
        XCTAssertTrue(extraction.candidates.allSatisfy { $0.locatorHint.sourceLocator == "page 3 lines 12-18" })
        XCTAssertTrue(extraction.candidates.allSatisfy { $0.locatorHint.pageNumber == 3 })
        XCTAssertTrue(extraction.candidates.allSatisfy { $0.locatorHint.lineNumber == 12 })
        XCTAssertTrue(extraction.candidates.allSatisfy { $0.locatorHint.pageLocator == "page:3" })
        XCTAssertTrue(extraction.candidates.allSatisfy { $0.locatorHint.lineLocator == "line:12" })
    }

    func testExtractorKeepsUnknownSourceNeededStaleContradictedRevokedAndLocallyProvenDistinct() {
        let extraction = SourceAtlasClaimCandidateExtractor().extract(
            Self.input(
                title: "Status note",
                bodyText: """
                Must submit the form.
                Archived notice.
                This conflicts with the current policy.
                The authorization was revoked.
                Maybe later.
                """,
                documentClassifierDecision: Self.localProofDecision()
            )
        )

        let requirement = extraction.candidates.first(where: { $0.kind == .requirement })
        let stale = extraction.candidates.first(where: { $0.sourceState == .stale })
        let contradicted = extraction.candidates.first(where: { $0.sourceState == .contradicted })
        let revoked = extraction.candidates.first(where: { $0.sourceState == .revoked })
        let unknown = extraction.candidates.first(where: { $0.kind == .unknown })

        XCTAssertNotNil(requirement)
        XCTAssertNotNil(stale)
        XCTAssertNotNil(contradicted)
        XCTAssertNotNil(revoked)
        XCTAssertNotNil(unknown)

        XCTAssertEqual(requirement?.sourceState, .sourceNeeded)
        XCTAssertEqual(requirement?.freshnessState, .needsReview)
        XCTAssertEqual(stale?.sourceState, .stale)
        XCTAssertEqual(stale?.freshnessState, .stale)
        XCTAssertEqual(contradicted?.sourceState, .contradicted)
        XCTAssertEqual(contradicted?.freshnessState, .disputed)
        XCTAssertEqual(revoked?.sourceState, .revoked)
        XCTAssertEqual(revoked?.freshnessState, .revoked)
        XCTAssertEqual(unknown?.sourceState, .unknown)
        XCTAssertEqual(unknown?.freshnessState, .unknown)
    }

    func testExplicitProofDecisionAllowsReadyProofCandidatesButNotWordingOnlyOverclaim() {
        let explicitProofExtraction = SourceAtlasClaimCandidateExtractor().extract(
            Self.input(
                title: "Official proof",
                bodyText: "Proof of current license is attached.",
                sourceLocator: "page 7",
                documentClassifierDecision: Self.localProofDecision()
            )
        )

        let proofCandidate = explicitProofExtraction.candidates.first(where: { $0.kind == .proof })

        XCTAssertNotNil(proofCandidate)
        XCTAssertEqual(proofCandidate?.sourceState, .locallyProven)
        XCTAssertEqual(proofCandidate?.freshnessState, .unknown)
        XCTAssertEqual(proofCandidate?.provenanceState, .localFile)
        XCTAssertEqual(proofCandidate?.sourceKind, .userProvided)
        XCTAssertEqual(proofCandidate?.reviewState, .ready)
        XCTAssertEqual(proofCandidate?.reviewRequired, false)
        XCTAssertFalse(explicitProofExtraction.reviewRequired)

        let wordingOnlyExtraction = SourceAtlasClaimCandidateExtractor().extract(
            Self.input(
                title: "Official proof",
                bodyText: "Official current proof is attached.",
                sourceLocator: "page 7"
            )
        )

        let wordingOnlyProofCandidate = wordingOnlyExtraction.candidates.first(where: { $0.kind == .proof })

        XCTAssertNotNil(wordingOnlyProofCandidate)
        XCTAssertNotEqual(wordingOnlyProofCandidate?.sourceState, .officialCurrent)
        XCTAssertNotEqual(wordingOnlyProofCandidate?.freshnessState, .current)
        XCTAssertTrue(wordingOnlyProofCandidate?.reviewRequired ?? false)
        XCTAssertEqual(wordingOnlyProofCandidate?.reviewState, .needsSourceReview)
    }

    func testExtractorIsDeterministicAndValueModelOnly() {
        let input = Self.input(
            title: "Training checklist",
            bodyText: """
            Bring a helmet before Friday.
            You must complete orientation before enrollment.
            Show proof of insurance and receipt.
            """
        )

        let first = SourceAtlasClaimCandidateExtractor().extract(input)
        let second = SourceAtlasClaimCandidateExtractor().extract(input)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.behavior, .valueModelOnly)
        XCTAssertTrue(first.candidates.allSatisfy { $0.schemaVersion == sourceAtlasClaimCandidateExtractorSchemaVersion })
    }
}

private extension SourceAtlasClaimCandidateExtractorModelsTests {
    static func input(
        title: String? = nil,
        bodyText: String,
        sourceLocator: String? = nil,
        documentClassifierDecision: SourceAtlasDocumentTypeClassifierDecision? = nil
    ) -> SourceAtlasClaimCandidateExtractionInput {
        SourceAtlasClaimCandidateExtractionInput(
            title: title,
            bodyText: bodyText,
            sourceLocator: sourceLocator,
            documentClassifierDecision: documentClassifierDecision
        )
    }

    static func localProofDecision() -> SourceAtlasDocumentTypeClassifierDecision {
        SourceAtlasDocumentTypeClassifier().classify(
            SourceAtlasDocumentTypeClassifierInput(
                title: "Local proof",
                bodyText: "Copied note with evidence attached.",
                hasLocalProof: true
            )
        )
    }
}
