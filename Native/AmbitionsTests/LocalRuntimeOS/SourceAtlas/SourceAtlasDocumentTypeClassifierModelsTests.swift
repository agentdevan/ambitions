import XCTest
@testable import Ambitions

final class SourceAtlasDocumentTypeClassifierModelsTests: XCTestCase {
    func testClassifierMapsRequestedDocumentTypesConservatively() {
        let cases: [(SourceAtlasDocumentTypeClassifierInput, SourceAtlasDocumentType, SourceAtlasRiskClass)] = [
            (
                Self.input(
                    title: "League rulebook",
                    bodyText: "Official rules, scoring, eligibility, and equipment standards."
                ),
                .rulebook,
                .sportRules
            ),
            (
                Self.input(
                    title: "School program page",
                    bodyText: "Admissions, tuition, credits, residency, and accreditation notes."
                ),
                .schoolProgramPage,
                .educationEligibility
            ),
            (
                Self.input(
                    title: "Job posting",
                    bodyText: "Employer role, responsibilities, required skills, salary, and apply details."
                ),
                .jobPosting,
                .careerContext
            ),
            (
                Self.input(
                    title: "Certification handbook",
                    bodyText: "Issuing body, credential, exam, renewal, and continuing education rules."
                ),
                .certificationHandbook,
                .certificationEligibility
            ),
            (
                Self.input(
                    title: "Official page",
                    bodyText: "Official website for the department with revised guidance."
                ),
                .officialPage,
                .professionalBoundary
            ),
            (
                Self.input(
                    title: "Generic note",
                    bodyText: "A copied note that should remain conservative."
                ),
                .genericText,
                .lowRiskSkill
            ),
            (
                Self.input(
                    title: "Court and professional guidance",
                    bodyText: "Statute, court, jurisdiction, and professional code references."
                ),
                .legalCivicProfessionalSource,
                .legalCivic
            )
        ]

        let classifier = SourceAtlasDocumentTypeClassifier()

        for (input, expectedType, expectedRiskClass) in cases {
            let decision = classifier.classify(input)

            XCTAssertEqual(decision.documentType, expectedType)
            XCTAssertEqual(decision.riskClass, expectedRiskClass)
            XCTAssertEqual(decision.behavior, .valueModelOnly)
            XCTAssertFalse(decision.behavior.performsNetworkAccess)
            XCTAssertFalse(decision.behavior.persistsState)
            XCTAssertFalse(decision.behavior.mutatesState)
            XCTAssertFalse(decision.behavior.makesReleaseClaims)
        }
    }

    func testOfficialLookingPageDoesNotBecomeOfficialOrCurrentWithoutExplicitProof() {
        let classifier = SourceAtlasDocumentTypeClassifier()

        let decision = classifier.classify(
            Self.input(
                title: "Official looking page",
                bodyText: "Official website, published by the department, with revised guidance and authority language."
            )
        )

        XCTAssertEqual(decision.documentType, .officialPage)
        XCTAssertEqual(decision.requirementSourceState, .sourceNeeded)
        XCTAssertNotEqual(decision.freshnessState, .current)
        XCTAssertFalse(decision.claimBoundary.allowsOfficialLabel)
        XCTAssertFalse(decision.claimBoundary.allowsCurrentLabel)
        XCTAssertFalse(decision.claimBoundary.canSupportOfficialCurrentClaim)
        XCTAssertEqual(decision.reviewState, .needsSourceReview)

        let explicitProofDecision = classifier.classify(
            Self.input(
                title: "Official page with proof",
                bodyText: "Official website, revised guidance, current as of today.",
                hasOfficialSourceProof: true,
                declaredFreshnessState: .current
            )
        )

        XCTAssertEqual(explicitProofDecision.documentType, .officialPage)
        XCTAssertEqual(explicitProofDecision.requirementSourceState, .officialCurrent)
        XCTAssertEqual(explicitProofDecision.freshnessState, .current)
        XCTAssertTrue(explicitProofDecision.claimBoundary.allowsOfficialLabel)
        XCTAssertTrue(explicitProofDecision.claimBoundary.allowsCurrentLabel)
        XCTAssertTrue(explicitProofDecision.claimBoundary.canSupportOfficialCurrentClaim)
        XCTAssertEqual(explicitProofDecision.reviewState, .ready)
    }

    func testGenericTextStaysConservativeAndDoesNotEscalateToOfficialTruth() {
        let decision = SourceAtlasDocumentTypeClassifier().classify(
            Self.input(
                title: "Copied note",
                bodyText: "A plain copied note that does not identify an authority."
            )
        )

        XCTAssertEqual(decision.documentType, .genericText)
        XCTAssertEqual(decision.sourceKindRecommendation, .userProvided)
        XCTAssertEqual(decision.provenanceRecommendation, .copiedContent)
        XCTAssertEqual(decision.requirementSourceState, .unknown)
        XCTAssertEqual(decision.freshnessState, .unknown)
        XCTAssertEqual(decision.reviewState, .needsUserReview)
        XCTAssertFalse(decision.claimBoundary.allowsOfficialLabel)
        XCTAssertFalse(decision.claimBoundary.allowsCurrentLabel)
        XCTAssertFalse(decision.claimBoundary.requiresStrictReview)
        XCTAssertFalse(decision.claimBoundary.canSupportOfficialCurrentClaim)
    }

    func testHighRiskCategoriesRequireReviewAndKeepSourceNeededDefaults() {
        let classifier = SourceAtlasDocumentTypeClassifier()

        let decisions = [
            classifier.classify(
                Self.input(
                    title: "Rulebook",
                    bodyText: "Rules, scoring, equipment, and eligibility."
                )
            ),
            classifier.classify(
                Self.input(
                    title: "School program page",
                    bodyText: "Program admissions, tuition, credits, residency, and accreditation."
                )
            ),
            classifier.classify(
                Self.input(
                    title: "Job posting",
                    bodyText: "Employer role, responsibilities, required skills, and apply window."
                )
            ),
            classifier.classify(
                Self.input(
                    title: "Certification handbook",
                    bodyText: "Credential eligibility, exam, renewal, and continuing education."
                )
            ),
            classifier.classify(
                Self.input(
                    title: "Legal civic professional source",
                    bodyText: "Statute, court, jurisdiction, and professional code references."
                )
            )
        ]

        XCTAssertTrue(decisions.allSatisfy(\.reviewState.blocksAutomaticMutation))
        XCTAssertTrue(decisions.allSatisfy { $0.claimBoundary.requiresStrictReview })
        XCTAssertTrue(decisions.allSatisfy { $0.requirementSourceState == .sourceNeeded })
        XCTAssertTrue(decisions.contains { $0.documentType == .jobPosting && $0.claimBoundary.treatsAsExampleOnly })
    }

    func testDeclaredSourceStatesRemainDistinct() {
        let classifier = SourceAtlasDocumentTypeClassifier()
        let cases: [(SourceAtlasRequirementSourceState, Bool)] = [
            (.unknown, false),
            (.sourceNeeded, false),
            (.stale, false),
            (.contradicted, false),
            (.revoked, false),
            (.locallyProven, true)
        ]

        for (state, hasLocalProof) in cases {
            let decision = classifier.classify(
                Self.input(
                    title: "State preservation",
                    bodyText: "Conservative source state handling.",
                    hasLocalProof: hasLocalProof,
                    declaredSourceState: state
                )
            )

            XCTAssertEqual(decision.requirementSourceState, state)
        }
    }

    func testDeclaredFreshnessStatesRemainDistinct() {
        let classifier = SourceAtlasDocumentTypeClassifier()
        let cases: [SourceAtlasFreshnessState] = [
            .unknown,
            .needsReview,
            .stale,
            .staleCritical,
            .sourceChanged,
            .disputed,
            .revoked,
            .userProvided,
            .aging
        ]

        for state in cases {
            let decision = classifier.classify(
                Self.input(
                    title: "Freshness preservation",
                    bodyText: "Conservative freshness handling.",
                    declaredFreshnessState: state
                )
            )

            XCTAssertEqual(decision.freshnessState, state)
        }
    }

    func testClassifierIsDeterministicForTheSameInput() {
        let input = Self.input(
            title: "Official looking page",
            bodyText: "Official website, revised guidance, and current notes.",
            hasOfficialSourceProof: true,
            declaredFreshnessState: .current
        )

        let first = SourceAtlasDocumentTypeClassifier().classify(input)
        let second = SourceAtlasDocumentTypeClassifier().classify(input)

        XCTAssertEqual(first, second)
        XCTAssertTrue(first.behavior == .valueModelOnly)
    }
}

private extension SourceAtlasDocumentTypeClassifierModelsTests {
    static func input(
        title: String,
        bodyText: String,
        sourceLocator: String? = nil,
        hasOfficialSourceProof: Bool = false,
        hasLocalProof: Bool = false,
        declaredSourceState: SourceAtlasRequirementSourceState = .unknown,
        declaredFreshnessState: SourceAtlasFreshnessState = .unknown
    ) -> SourceAtlasDocumentTypeClassifierInput {
        SourceAtlasDocumentTypeClassifierInput(
            title: title,
            bodyText: bodyText,
            sourceLocator: sourceLocator,
            hasOfficialSourceProof: hasOfficialSourceProof,
            hasLocalProof: hasLocalProof,
            declaredSourceState: declaredSourceState,
            declaredFreshnessState: declaredFreshnessState
        )
    }
}
