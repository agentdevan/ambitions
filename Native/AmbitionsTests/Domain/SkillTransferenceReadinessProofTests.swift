import XCTest
@testable import Ambitions

final class SkillTransferenceReadinessProofTests: XCTestCase {
    private let adapter = SkillTransferenceFeasibilityAdapter()

    func testEligibleTransferProposalPreservesEvidenceContextsAndControls() throws {
        let proposal = try makeEligibleProposal()

        XCTAssertEqual(proposal.sourceContextID, ProofFixture.sourceContext.id)
        XCTAssertEqual(proposal.destinationContextID, ProofFixture.destinationContext.id)
        XCTAssertEqual(proposal.demonstratedStrategy, "Use a short weekly review before choosing the next bounded action.")
        XCTAssertEqual(proposal.evidence.map(\.id), [
            "evidence.transfer.difference",
            "evidence.transfer.similarity",
            "evidence.transfer.strategy"
        ])
        XCTAssertEqual(proposal.structuralSimilarities, [
            "Both contexts use a bounded review before action.",
            "Both contexts have an explicit next-action decision point."
        ])
        XCTAssertEqual(proposal.materialDifferences, [
            "The destination has a different available-work window."
        ])
        XCTAssertEqual(proposal.unknowns, [
            "Whether the destination context will preserve the same review cadence."
        ])
        XCTAssertEqual(proposal.nonTransferConditions, [
            "Do not transfer if the destination has no user-confirmed action boundary."
        ])
        XCTAssertEqual(proposal.intendedReceivingOwner, .goalPath)
        XCTAssertEqual(proposal.userControls, [.accept, .dismiss, .edit, .suppress])
        XCTAssertFalse(proposal.isDurable)
        XCTAssertFalse(proposal.canonicalMutationIssued)
        XCTAssertNil(proposal.mutationReceiptID)
        XCTAssertTrue(proposal.trace.isComplete)
        XCTAssertEqual(
            Set(proposal.trust.sectionKinds),
            Set(RecommendationTrustSeamSectionKind.allCases)
        )
        XCTAssertFalse(proposal.trust.hasVisibleCopyGuardrailViolation)
        XCTAssertTrue(proposal.destinationPrivacy.isGreen)
        XCTAssertTrue(proposal.destinationPrivacy.localProjectionOnly)
    }

    func testInsufficientEvidenceProducesQuietNoProposal() {
        let proposal = adapter.propose(
            SkillTransferProposalInput(
                source: ProofFixture.sourceContext,
                destination: ProofFixture.destinationContext,
                demonstratedStrategy: "Use a short weekly review before choosing the next bounded action.",
                evidence: [],
                structuralSimilarities: ["Unverified similarity"],
                materialDifferences: ["Unknown difference"],
                unknowns: ["Evidence is sparse."],
                nonTransferConditions: ["Do not transfer without evidence."],
                explanation: makeExplanation(
                    source: ProofFixture.sourceContext,
                    destination: ProofFixture.destinationContext,
                    evidence: []
                ),
                destinationPolicy: makeLocalPolicy(objectID: ProofFixture.destinationContext.id)
            )
        )

        XCTAssertNil(proposal)
    }

    func testSensitiveDestinationBlocksBeforeOwnerHandoffAndReturnsNoSensitiveResult() throws {
        let sensitivePolicy = AmbitionsOSPrivacySafetyPolicy(
            id: "policy.transfer.sensitive-destination",
            objectID: ProofFixture.destinationContext.id,
            surface: .goals,
            permissionState: .privateOnly,
            privacyClass: .sensitive,
            sensitiveAreas: [.careerSensitive],
            sourceState: .userConfirmed,
            freshnessState: .current,
            reviewState: .needsPrivacyReview,
            projectionPolicy: .hidden,
            toolIntent: .readLocalSummary,
            toolApprovalState: .reviewOnly,
            deterministicFallbackAvailable: true,
            redactionSummary: "Sensitive destination is not disclosed in this proof.",
            receipts: [
                AmbitionsOSPrivacyReceipt(
                    id: "receipt.transfer.sensitive-destination",
                    action: "inspect",
                    occurredAt: "2026-07-31T00:00:00Z"
                )
            ],
            runtimeBoundary: .valueModelOnly
        )
        let classification = AmbitionsOSPrivacySafetyValidator().classify(sensitivePolicy)

        let proposal = adapter.propose(
            SkillTransferProposalInput(
                source: ProofFixture.sourceContext,
                destination: ProofFixture.destinationContext,
                demonstratedStrategy: "Use a short weekly review before choosing the next bounded action.",
                evidence: ProofFixture.evidence,
                structuralSimilarities: ProofFixture.similarities,
                materialDifferences: ProofFixture.differences,
                unknowns: ProofFixture.unknowns,
                nonTransferConditions: ProofFixture.nonTransferConditions,
                explanation: makeExplanation(
                    source: ProofFixture.sourceContext,
                    destination: ProofFixture.destinationContext,
                    evidence: ProofFixture.evidence
                ),
                destinationPolicy: sensitivePolicy
            )
        )

        XCTAssertTrue(classification.requiresUserReview)
        XCTAssertEqual(classification.humanProgressPrivacyClass, .sensitive)
        XCTAssertNil(proposal)
    }

    func testUnknownsAndNonTransferConditionsRemainExplicit() throws {
        let proposal = try makeEligibleProposal()

        XCTAssertEqual(proposal.unknowns.count, 1)
        XCTAssertEqual(proposal.nonTransferConditions.count, 1)
        XCTAssertTrue(proposal.trace.uncertainty.summaries.contains("The destination context may not preserve the source review cadence."))
        XCTAssertTrue(proposal.explanation.assumptions.allSatisfy(\.isUserCorrectable))
    }

    func testTrustCompatibleInspectionExposesTheTransferFieldsWithoutBuildingAView() throws {
        let proposal = try makeEligibleProposal()
        let expectedFields: Set<String> = [
            "source_context",
            "destination_context",
            "demonstrated_strategy",
            "evidence",
            "structural_similarities",
            "material_differences",
            "unknowns",
            "non_transfer_conditions",
            "uncertainty",
            "intended_receiving_owner",
            "user_controls"
        ]

        XCTAssertEqual(Set(proposal.inspectableFieldKeys), expectedFields)
        XCTAssertEqual(
            Set(proposal.trust.sectionKinds),
            Set([
                .source,
                .reason,
                .fit,
                .uncertainty,
                .controls,
                .receiptBehavior
            ])
        )
        XCTAssertTrue(proposal.trust.visibleCopy.contains("Local-only"))
    }

    func testAcceptProducesOnlyAProposalInputForTheExistingGoalPathCandidate() throws {
        let proposal = try makeEligibleProposal()
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: GoalUnderstandingModelsTests().sampleUnderstandingForCompiler()
        )
        let candidate = try XCTUnwrap(compiled.candidates.first)
        let candidateBeforeAccept = candidate

        let ownerInput = adapter.accept(proposal, goalPathCandidate: candidate)

        XCTAssertEqual(ownerInput.owner, .goalPath)
        XCTAssertEqual(ownerInput.goalPathCandidateID, candidate.id)
        XCTAssertEqual(ownerInput.proposalID, proposal.id)
        XCTAssertTrue(ownerInput.isProposalOnly)
        XCTAssertFalse(ownerInput.createsGoal)
        XCTAssertFalse(ownerInput.mutatesGoalPath)
        XCTAssertFalse(ownerInput.mutatesTime)
        XCTAssertFalse(ownerInput.canonicalMutationIssued)
        XCTAssertNil(ownerInput.mutationReceiptID)
        XCTAssertFalse(ownerInput.isDurable)
        XCTAssertEqual(candidate, candidateBeforeAccept)
    }

    func testEditChangesOnlyTheEphemeralProposal() throws {
        let proposal = try makeEligibleProposal()

        let edited = adapter.edit(
            proposal,
            intendedReceivingOwner: .goalPath,
            intendedUse: "Use only as a Goal Path proposal input after user review."
        )

        XCTAssertNotEqual(edited, proposal)
        XCTAssertEqual(edited.sourceContextID, proposal.sourceContextID)
        XCTAssertEqual(edited.destinationContextID, proposal.destinationContextID)
        XCTAssertEqual(edited.demonstratedStrategy, proposal.demonstratedStrategy)
        XCTAssertEqual(edited.intendedUse, "Use only as a Goal Path proposal input after user review.")
        XCTAssertFalse(edited.isDurable)
        XCTAssertFalse(edited.canonicalMutationIssued)
        XCTAssertNil(edited.mutationReceiptID)
        XCTAssertEqual(proposal.intendedUse, "Goal Path may inspect this as a proposal input only.")
    }

    func testDismissRemovesOnlyTheEphemeralProposal() throws {
        let proposal = try makeEligibleProposal()

        XCTAssertNil(adapter.dismiss(proposal))
    }

    func testExistingCorrectionLearningCanSuppressWithoutSilentMutation() throws {
        let proposal = try makeEligibleProposal()
        let correction = CorrectionFoldRecord.recommendation(
            id: "correction.transfer.suppress",
            recommendationID: proposal.id,
            from: .stillUseful,
            to: .confirmedStillCounts,
            reason: "Do not reuse this proposed transfer without a fresh user decision.",
            occurredAt: "2026-07-31T00:00:00Z"
        )
        let influence = try XCTUnwrap(
            CorrectionFoldRecommendationLearningInfluence(correction: correction)
        )

        XCTAssertTrue(influence.isInspectableAndControllable)
        XCTAssertTrue(influence.resetDeleteCompatible)
        XCTAssertFalse(influence.permitsSilentMutation)
        XCTAssertTrue(influence.suppresses(candidateRecommendationID: proposal.id))
        XCTAssertNil(adapter.suppress(proposal, using: influence))
    }

    func testEquivalentEvidenceAndPolicyInputsProduceAnEquivalentProposal() throws {
        let first = try makeProposal(
            evidence: ProofFixture.evidence,
            similarities: ProofFixture.similarities,
            differences: ProofFixture.differences,
            unknowns: ProofFixture.unknowns,
            conditions: ProofFixture.nonTransferConditions
        )
        let second = try makeProposal(
            evidence: ProofFixture.evidence.reversed(),
            similarities: ProofFixture.similarities.reversed(),
            differences: ProofFixture.differences.reversed(),
            unknowns: ProofFixture.unknowns.reversed(),
            conditions: ProofFixture.nonTransferConditions.reversed()
        )

        XCTAssertEqual(first, second)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        XCTAssertEqual(try encoder.encode(first), try encoder.encode(second))
    }

    func testReadinessProofRemainsLocalOfflineAccountFreeAndNonDurable() throws {
        let proposal = try makeEligibleProposal()

        XCTAssertTrue(proposal.localOnly)
        XCTAssertTrue(proposal.explanation.localOnly)
        XCTAssertTrue(proposal.runtimeBoundary.isValueModelOnly)
        XCTAssertFalse(proposal.networkRequired)
        XCTAssertFalse(proposal.accountRequired)
        XCTAssertFalse(proposal.hostedModelUsed)
        XCTAssertFalse(proposal.externalEgressAllowed)
        XCTAssertFalse(proposal.isDurable)
    }

    func testCurrentPersonalRuntimeLearningSignalIsNotAGenericTransferRepresentation() {
        XCTAssertEqual(PersonalRuntimeLearningSignalType.allCases, [.momentumReflow])
        XCTAssertTrue(PersonalRuntimeLearningSignalConfidenceState.reset.excludesFutureRanking)
        XCTAssertTrue(PersonalRuntimeLearningSignalConfidenceState.deleted.excludesFutureRanking)
    }

    func testGoalPathBoundaryIsProposalOnlyAndNoExistingTransferConsumerIsAdded() throws {
        let proposal = try makeEligibleProposal()
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: GoalUnderstandingModelsTests().sampleUnderstandingForCompiler()
        )
        let candidate = try XCTUnwrap(compiled.candidates.first)
        let input = adapter.accept(proposal, goalPathCandidate: candidate)

        XCTAssertEqual(input.owner, .goalPath)
        XCTAssertTrue(input.isProposalOnly)
        XCTAssertFalse(input.canonicalMutationIssued)
        XCTAssertNil(input.mutationReceiptID)
        XCTAssertFalse(input.isDurable)
    }
}

// Test-only feasibility adapter. This is not a production object, owner
// contract, persistence model, or final architecture.
private struct SkillTransferProposalInput {
    let source: LifeKnowledgeOperationModels.ContextEntry
    let destination: LifeKnowledgeOperationModels.ContextEntry
    let demonstratedStrategy: String
    let evidence: [RecommendationExplanationEvidence]
    let structuralSimilarities: [String]
    let materialDifferences: [String]
    let unknowns: [String]
    let nonTransferConditions: [String]
    let explanation: RecommendationExplanation
    let destinationPolicy: AmbitionsOSPrivacySafetyPolicy
}

private struct SkillTransferenceFeasibilityAdapter {
    func propose(_ input: SkillTransferProposalInput) -> SkillTransferFeasibilityProposal? {
        let destinationClassification = AmbitionsOSPrivacySafetyValidator().classify(input.destinationPolicy)
        guard input.source.kind == .contextEntry,
              input.destination.kind == .contextEntry,
              input.source.id != input.destination.id,
              input.demonstratedStrategy.isEmpty == false,
              input.evidence.count >= 2,
              input.structuralSimilarities.isEmpty == false,
              input.materialDifferences.isEmpty == false,
              input.unknowns.isEmpty == false,
              input.nonTransferConditions.isEmpty == false,
              input.destinationPolicy.isSensitive == false,
              destinationClassification.classification == .local,
              destinationClassification.requiresUserReview == false,
              destinationClassification.localProjectionOnly,
              destinationClassification.externallyProjectable == false,
              input.explanation.localOnly
        else {
            return nil
        }

        let trace = RecommendationTrace(
            explanation: input.explanation,
            fitState: .fits,
            receiptBehavior: .required()
        )
        let trust = RecommendationTrustSeamState(trace: trace)

        return SkillTransferFeasibilityProposal(
            id: "skill-transfer:\(input.source.id):\(input.destination.id)",
            sourceContextID: input.source.id,
            destinationContextID: input.destination.id,
            demonstratedStrategy: input.demonstratedStrategy,
            evidence: input.evidence,
            structuralSimilarities: input.structuralSimilarities,
            materialDifferences: input.materialDifferences,
            unknowns: input.unknowns,
            nonTransferConditions: input.nonTransferConditions,
            uncertainty: input.explanation.uncertainty,
            intendedReceivingOwner: .goalPath,
            intendedUse: "Goal Path may inspect this as a proposal input only.",
            userControls: [.accept, .edit, .dismiss, .suppress],
            explanation: input.explanation,
            trace: trace,
            trust: trust,
            destinationPrivacy: destinationClassification,
            runtimeBoundary: .valueModelOnly
        )
    }

    func accept(
        _ proposal: SkillTransferFeasibilityProposal,
        goalPathCandidate: GoalCompiledPathCandidate
    ) -> GoalPathProposalInput {
        GoalPathProposalInput(
            proposalID: proposal.id,
            owner: proposal.intendedReceivingOwner,
            goalPathCandidateID: goalPathCandidate.id,
            isProposalOnly: true,
            createsGoal: false,
            mutatesGoalPath: false,
            mutatesTime: false,
            canonicalMutationIssued: false,
            mutationReceiptID: nil,
            isDurable: false
        )
    }

    func edit(
        _ proposal: SkillTransferFeasibilityProposal,
        intendedReceivingOwner: SkillTransferReceivingOwner,
        intendedUse: String
    ) -> SkillTransferFeasibilityProposal {
        proposal.replacing(
            intendedReceivingOwner: intendedReceivingOwner,
            intendedUse: intendedUse
        )
    }

    func dismiss(_ proposal: SkillTransferFeasibilityProposal) -> SkillTransferFeasibilityProposal? {
        nil
    }

    func suppress(
        _ proposal: SkillTransferFeasibilityProposal,
        using influence: CorrectionFoldRecommendationLearningInfluence
    ) -> SkillTransferFeasibilityProposal? {
        influence.suppresses(candidateRecommendationID: proposal.id) ? nil : proposal
    }
}

private struct SkillTransferFeasibilityProposal: Codable, Equatable, Hashable {
    let id: String
    let sourceContextID: String
    let destinationContextID: String
    let demonstratedStrategy: String
    let evidence: [RecommendationExplanationEvidence]
    let structuralSimilarities: [String]
    let materialDifferences: [String]
    let unknowns: [String]
    let nonTransferConditions: [String]
    let uncertainty: [RecommendationExplanationUncertainty]
    let intendedReceivingOwner: SkillTransferReceivingOwner
    let intendedUse: String
    let userControls: [SkillTransferUserControl]
    let explanation: RecommendationExplanation
    let trace: RecommendationTrace
    let trust: RecommendationTrustSeamState
    let destinationPrivacy: AmbitionsOSPrivacySafetyClassification
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let localOnly: Bool
    let networkRequired: Bool
    let accountRequired: Bool
    let hostedModelUsed: Bool
    let externalEgressAllowed: Bool
    let isDurable: Bool
    let canonicalMutationIssued: Bool
    let mutationReceiptID: String?

    init(
        id: String,
        sourceContextID: String,
        destinationContextID: String,
        demonstratedStrategy: String,
        evidence: [RecommendationExplanationEvidence],
        structuralSimilarities: [String],
        materialDifferences: [String],
        unknowns: [String],
        nonTransferConditions: [String],
        uncertainty: [RecommendationExplanationUncertainty],
        intendedReceivingOwner: SkillTransferReceivingOwner,
        intendedUse: String,
        userControls: [SkillTransferUserControl],
        explanation: RecommendationExplanation,
        trace: RecommendationTrace,
        trust: RecommendationTrustSeamState,
        destinationPrivacy: AmbitionsOSPrivacySafetyClassification,
        runtimeBoundary: SourceAtlasRuntimeBoundary,
        localOnly: Bool = true,
        networkRequired: Bool = false,
        accountRequired: Bool = false,
        hostedModelUsed: Bool = false,
        externalEgressAllowed: Bool = false,
        isDurable: Bool = false,
        canonicalMutationIssued: Bool = false,
        mutationReceiptID: String? = nil
    ) {
        self.id = id
        self.sourceContextID = sourceContextID
        self.destinationContextID = destinationContextID
        self.demonstratedStrategy = demonstratedStrategy
        self.evidence = evidence.sorted { $0.id < $1.id }
        self.structuralSimilarities = Self.orderedUnique(structuralSimilarities)
        self.materialDifferences = Self.orderedUnique(materialDifferences)
        self.unknowns = Self.orderedUnique(unknowns)
        self.nonTransferConditions = Self.orderedUnique(nonTransferConditions)
        self.uncertainty = uncertainty.sorted { $0.id < $1.id }
        self.intendedReceivingOwner = intendedReceivingOwner
        self.intendedUse = intendedUse
        self.userControls = Self.orderedUnique(userControls)
        self.explanation = explanation
        self.trace = trace
        self.trust = trust
        self.destinationPrivacy = destinationPrivacy
        self.runtimeBoundary = runtimeBoundary
        self.localOnly = localOnly
        self.networkRequired = networkRequired
        self.accountRequired = accountRequired
        self.hostedModelUsed = hostedModelUsed
        self.externalEgressAllowed = externalEgressAllowed
        self.isDurable = isDurable
        self.canonicalMutationIssued = canonicalMutationIssued
        self.mutationReceiptID = mutationReceiptID
    }

    var inspectableFieldKeys: [String] {
        [
            "source_context",
            "destination_context",
            "demonstrated_strategy",
            "evidence",
            "structural_similarities",
            "material_differences",
            "unknowns",
            "non_transfer_conditions",
            "uncertainty",
            "intended_receiving_owner",
            "user_controls"
        ]
    }

    func replacing(
        intendedReceivingOwner: SkillTransferReceivingOwner,
        intendedUse: String
    ) -> SkillTransferFeasibilityProposal {
        SkillTransferFeasibilityProposal(
            id: id,
            sourceContextID: sourceContextID,
            destinationContextID: destinationContextID,
            demonstratedStrategy: demonstratedStrategy,
            evidence: evidence,
            structuralSimilarities: structuralSimilarities,
            materialDifferences: materialDifferences,
            unknowns: unknowns,
            nonTransferConditions: nonTransferConditions,
            uncertainty: uncertainty,
            intendedReceivingOwner: intendedReceivingOwner,
            intendedUse: intendedUse,
            userControls: userControls,
            explanation: explanation,
            trace: trace,
            trust: trust,
            destinationPrivacy: destinationPrivacy,
            runtimeBoundary: runtimeBoundary,
            localOnly: localOnly,
            networkRequired: networkRequired,
            accountRequired: accountRequired,
            hostedModelUsed: hostedModelUsed,
            externalEgressAllowed: externalEgressAllowed,
            isDurable: isDurable,
            canonicalMutationIssued: canonicalMutationIssued,
            mutationReceiptID: mutationReceiptID
        )
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }

    private static func orderedUnique(_ values: [SkillTransferUserControl]) -> [SkillTransferUserControl] {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }
}

private struct GoalPathProposalInput: Equatable {
    let proposalID: String
    let owner: SkillTransferReceivingOwner
    let goalPathCandidateID: String
    let isProposalOnly: Bool
    let createsGoal: Bool
    let mutatesGoalPath: Bool
    let mutatesTime: Bool
    let canonicalMutationIssued: Bool
    let mutationReceiptID: String?
    let isDurable: Bool
}

private enum SkillTransferReceivingOwner: String, Codable, Equatable, Hashable, CaseIterable {
    case goalPath = "goal_path"
}

private enum SkillTransferUserControl: String, Codable, Equatable, Hashable, CaseIterable {
    case accept
    case edit
    case dismiss
    case suppress
}

private enum ProofFixture {
    // These IDs and titles are reused from the existing synthetic
    // LifeKnowledgeOperationModelsTests context-entry fixtures.
    static let sourceContext = LifeKnowledgeOperationModels.ContextEntry(
        id: "context-entry.life-knowledge.1",
        kind: .contextEntry,
        title: "Launch note",
        summary: "Store a structured note entry with source, receipt, and replay.",
        body: "The note can be collected, templated, and replayed locally.",
        createdAt: "2026-05-25T11:18:00Z",
        updatedAt: "2026-05-25T11:18:00Z"
    )

    static let destinationContext = LifeKnowledgeOperationModels.ContextEntry(
        id: "context-entry.life-knowledge.relations",
        kind: .contextEntry,
        title: "Launch notes with backlinks",
        summary: "Relate notes to life objects and keep the backlink review state local.",
        createdAt: "2026-05-25T11:30:00Z",
        updatedAt: "2026-05-25T11:35:00Z"
    )

    static let evidence: [RecommendationExplanationEvidence] = [
        RecommendationExplanationEvidence(
            id: "evidence.transfer.strategy",
            category: .memoryEvent,
            title: "Demonstrated weekly review method",
            summary: "The source context records a repeated bounded review before action.",
            sourceID: sourceContext.id,
            metadata: ["contextID": sourceContext.id]
        ),
        RecommendationExplanationEvidence(
            id: "evidence.transfer.similarity",
            category: .contextLens,
            title: "Shared review boundary",
            summary: "Both contexts expose a review-before-action boundary.",
            sourceID: sourceContext.id,
            metadata: ["destinationContextID": destinationContext.id]
        ),
        RecommendationExplanationEvidence(
            id: "evidence.transfer.difference",
            category: .assumption,
            title: "Destination work window differs",
            summary: "The destination has a different available-work window.",
            sourceID: destinationContext.id,
            metadata: ["requiresUserReview": "true"]
        )
    ]

    static let similarities = [
        "Both contexts use a bounded review before action.",
        "Both contexts have an explicit next-action decision point."
    ]

    static let differences = [
        "The destination has a different available-work window."
    ]

    static let unknowns = [
        "Whether the destination context will preserve the same review cadence."
    ]

    static let nonTransferConditions = [
        "Do not transfer if the destination has no user-confirmed action boundary."
    ]
}

private func makeEligibleProposal() throws -> SkillTransferFeasibilityProposal {
    try makeProposal(
        evidence: ProofFixture.evidence,
        similarities: ProofFixture.similarities,
        differences: ProofFixture.differences,
        unknowns: ProofFixture.unknowns,
        conditions: ProofFixture.nonTransferConditions
    )
}

private func makeProposal(
    evidence: [RecommendationExplanationEvidence],
    similarities: [String],
    differences: [String],
    unknowns: [String],
    conditions: [String]
) throws -> SkillTransferFeasibilityProposal {
    let adapter = SkillTransferenceFeasibilityAdapter()
    return try XCTUnwrap(
        adapter.propose(
            SkillTransferProposalInput(
                source: ProofFixture.sourceContext,
                destination: ProofFixture.destinationContext,
                demonstratedStrategy: "Use a short weekly review before choosing the next bounded action.",
                evidence: evidence,
                structuralSimilarities: similarities,
                materialDifferences: differences,
                unknowns: unknowns,
                nonTransferConditions: conditions,
                explanation: makeExplanation(
                    source: ProofFixture.sourceContext,
                    destination: ProofFixture.destinationContext,
                    evidence: evidence
                ),
                destinationPolicy: makeLocalPolicy(objectID: ProofFixture.destinationContext.id)
            )
        )
    )
}

private func makeExplanation(
    source: LifeKnowledgeOperationModels.ContextEntry,
    destination: LifeKnowledgeOperationModels.ContextEntry,
    evidence: [RecommendationExplanationEvidence]
) -> RecommendationExplanation {
    RecommendationExplanation(
        id: "explanation.skill-transfer.\(source.id).\(destination.id)",
        type: .whyContextLens,
        title: "Why this bounded transfer is proposed",
        summary: "A demonstrated review method may help another context, subject to visible differences and user control.",
        recommendationTitle: "Inspect the weekly review method in the destination context",
        recommendationSummary: "Proposal-only input for one existing Goal Path candidate.",
        confidence: .medium,
        evidence: evidence,
        assumptions: [
            RecommendationExplanationAssumption(
                id: "assumption.transfer.destination-fit",
                summary: "The destination can preserve a user-confirmed action boundary.",
                fieldKey: "destination_context"
            )
        ],
        uncertainty: [
            RecommendationExplanationUncertainty(
                id: "uncertainty.transfer.cadence",
                summary: "The destination context may not preserve the source review cadence."
            )
        ],
        userCorrectableFields: ["destination_context", "transfer_conditions"],
        correctionActions: [
            RecommendationExplanationCorrectionAction(
                id: "correction.transfer.destination",
                kind: .changeDomainContext,
                title: "Change the destination context",
                targetFieldKey: "destination_context"
            )
        ],
        lastUpdatedAt: "2026-07-31T00:00:00Z",
        source: .you,
        privacy: .standard,
        localOnly: true,
        metadata: [
            "sourceContextID": source.id,
            "destinationContextID": destination.id,
            "intendedUse": "Goal Path proposal input only"
        ]
    )
}

private func makeLocalPolicy(objectID: String) -> AmbitionsOSPrivacySafetyPolicy {
    AmbitionsOSPrivacySafetyPolicy(
        id: "policy.transfer.local.\(objectID)",
        objectID: objectID,
        surface: .goals,
        permissionState: .privateOnly,
        privacyClass: .privateLife,
        sourceState: .userConfirmed,
        freshnessState: .current,
        reviewState: .ready,
        projectionPolicy: .fullLocal,
        toolIntent: .readLocalSummary,
        toolApprovalState: .reviewOnly,
        deterministicFallbackAvailable: true,
        redactionSummary: "Synthetic local-only proof; no external projection.",
        receipts: [
            AmbitionsOSPrivacyReceipt(
                id: "receipt.transfer.local.\(objectID)",
                action: "inspect",
                occurredAt: "2026-07-31T00:00:00Z"
            )
        ],
        runtimeBoundary: .valueModelOnly
    )
}
