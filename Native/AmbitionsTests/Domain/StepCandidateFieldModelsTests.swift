import XCTest
@testable import Ambitions

final class StepCandidateFieldModelsTests: XCTestCase {
    func testStepCandidateFieldRoundTripsThroughCodableAndPreservesTraceData() throws {
        let candidate = makeCandidate(
            sourceStepID: "compiled-step-a",
            title: "Draft launch note",
            summary: "Write the draft launch note."
        )
        let field = StepCandidateField(
            goalID: "goal.launch",
            deadlineTargetDate: "2026-05-30T10:00:00Z",
            generatedAt: "2026-05-22T18:13:20Z",
            sourceProvenance: [.goalIntentCompiler, .privateLifeRuntime, .personalizationFactorLedger],
            candidates: [candidate],
            rankingTrace: CandidateRankingTrace(
                generatedAt: "2026-05-22T18:13:20Z",
                selectedCandidateID: candidate.id,
                rankedCandidateIDs: [candidate.id],
                rejectedCandidateIDs: [],
                duplicateRejectedCandidateIDs: [],
                sourceProvenance: [.goalIntentCompiler],
                factorEvidenceIDs: ["factor.goal_requirement"],
                replayReferenceID: "replay.trace.local",
                replayFingerprint: "fingerprint.local",
                semanticSummary: "Selected the factor-backed direct path.",
                factorlessRanking: false
            ),
            localOnly: true
        )

        let encoded = try JSONEncoder().encode(field)
        let decoded = try JSONDecoder().decode(StepCandidateField.self, from: encoded)

        XCTAssertEqual(decoded, field)
        XCTAssertEqual(decoded.selectedCandidate?.id, candidate.id)
        XCTAssertEqual(decoded.rejectedCandidates, [])
        XCTAssertEqual(decoded.rankingTrace.selectedCandidateID, candidate.id)
        XCTAssertEqual(decoded.rankingTrace.factorEvidenceIDs, ["factor.goal_requirement"])
        XCTAssertEqual(decoded.sourceProvenance, [.goalIntentCompiler, .personalizationFactorLedger, .privateLifeRuntime])
    }

    func testCandidateSemanticSignatureNormalizesCopyVariantsInsteadOfComparingTitlesOnly() {
        let first = makeCandidate(
            sourceStepID: "compiled-step-a",
            title: "Draft launch note",
            summary: "Write the draft launch note."
        )
        let second = makeCandidate(
            sourceStepID: "compiled-step-b",
            title: "Draft launch note now",
            summary: "Write the draft launch note."
        )

        XCTAssertEqual(first.normalizedSemanticSignature, second.normalizedSemanticSignature)
        XCTAssertNotEqual(first.id, second.id)
        XCTAssertEqual(first.score.total, second.score.total)
        XCTAssertEqual(first.validity, .preferred)
    }
}

private extension StepCandidateFieldModelsTests {
    func makeCandidate(
        sourceStepID: String,
        title: String,
        summary: String
    ) -> StepCandidate {
        StepCandidate(
            sourceStepID: sourceStepID,
            sourceCandidateID: "\(sourceStepID).source",
            source: .goalIntentCompiler,
            kind: .directBest,
            title: title,
            summary: summary,
            accessibilitySummary: "Direct best · \(title)",
            estimatedMinutes: 12,
            estimatedEnergyCost: 0.4,
            accessRequirements: ["local access"],
            equipmentRequirements: [],
            facilityRequirements: [],
            goalContribution: 1,
            deadlineContribution: 0.9,
            futurePressureImpact: 0.8,
            opportunityCost: 0.3,
            approvalRequired: false,
            validity: .preferred,
            tradeoffs: [
                CandidateTradeoff(
                    id: "\(sourceStepID).benefit",
                    label: "Benefit",
                    benefit: "Clear path",
                    cost: "Higher effort than a fallback"
                )
            ],
            rejectionRisk: CandidateRejectionRisk(
                id: "\(sourceStepID).risk",
                level: .low,
                summary: "Low rejection risk for a direct path.",
                factorIDs: ["factor.goal_requirement"],
                requiresReview: false
            ),
            evidenceFactorIDs: ["factor.goal_requirement"],
            semanticAnchor: summary
        )
    }
}
