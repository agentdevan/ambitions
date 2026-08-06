import XCTest
@testable import Ambitions

final class CapabilityProposalPolicyTests: XCTestCase {
    func testApprovedEvidenceProducesDeterministicReviewOnlyProposal() {
        let policy = CapabilityProposalPolicy()
        let first = policy.evaluate(observations: [Self.observation()])
        let second = policy.evaluate(observations: [Self.observation()])

        XCTAssertEqual(first, second)
        guard case let .proposal(proposal) = first else {
            return XCTFail("Expected an eligible proposal.")
        }
        XCTAssertEqual(proposal.normalizedName, "swift concurrency")
        XCTAssertEqual(proposal.normalizedMeaning, "i practiced structured concurrency")
        XCTAssertEqual(proposal.status, .pending)
        XCTAssertEqual(proposal.relationshipKinds, [.practiced])
        XCTAssertFalse(proposal.id.isEmpty)
    }

    func testUnsupportedPrivacyAndSourceStatesRemainQuiet() {
        XCTAssertEqual(
            CapabilityProposalPolicy().evaluate(observations: [Self.observation(outputPrivacy: .protectedLocal)]),
            .quiet(.protectedContent)
        )
        XCTAssertEqual(
            CapabilityProposalPolicy().evaluate(observations: [Self.observation(availability: .trashed)]),
            .quiet(.sourceUnavailable)
        )
        XCTAssertEqual(
            CapabilityProposalPolicy().evaluate(observations: [Self.observation(contradictionState: .contradicted)]),
            .quiet(.contradictoryEvidence)
        )
    }

    func testMissingExplicitWordingOffersOnlyManualReflection() {
        XCTAssertEqual(
            CapabilityProposalPolicy().evaluate(observations: [Self.observation(explicitName: nil, explicitMeaning: nil)]),
            .neutralReflection
        )
    }

    func testNotThisFingerprintSuppressesUnchangedEvidence() {
        let policy = CapabilityProposalPolicy()
        guard case let .proposal(proposal) = policy.evaluate(observations: [Self.observation()]) else {
            return XCTFail("Expected an eligible proposal.")
        }

        XCTAssertEqual(
            policy.evaluate(
                observations: [Self.observation()],
                dismissedBasisFingerprints: [proposal.evidenceBasisFingerprint]
            ),
            .quiet(.duplicateBasis)
        )
    }

    private static func observation(
        availability: CapabilityEvidenceAvailability = .available,
        contradictionState: CapabilityEvidenceContradictionState = .none,
        outputPrivacy: CapabilityPrivacyClassification = .privateLocal,
        explicitName: String? = "Swift Concurrency",
        explicitMeaning: String? = "I practiced structured concurrency"
    ) -> CapabilityProposalObservation {
        CapabilityProposalObservation(
            source: CapabilityEvidenceSourceReference(
                kind: .goal,
                stableID: "goal-concurrency",
                revision: 4,
                fingerprint: "goal-concurrency-r4"
            ),
            event: .acceptedCompletion,
            relationKind: .practiced,
            isAccepted: true,
            availability: availability,
            contradictionState: contradictionState,
            outputPrivacy: outputPrivacy,
            contextPrivacy: .privateLocal,
            lifecycle: .active,
            futureUseState: .eligible,
            explicitName: explicitName,
            explicitMeaning: explicitMeaning,
            presentationHost: .goalReview
        )
    }
}
