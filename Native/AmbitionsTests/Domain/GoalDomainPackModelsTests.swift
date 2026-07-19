import XCTest
@testable import Ambitions

final class GoalDomainPackModelsTests: XCTestCase {
    func testPackMatchSortKeyPrefersHigherConfidenceThenPackID() {
        let lowerConfidence = GoalDomainPackMatch(
            packID: "career",
            confidenceScore: 0.7,
            matchedDomains: [.career],
            reasons: ["career domain present"],
            provisional: false
        )
        let higherConfidence = GoalDomainPackMatch(
            packID: "education",
            confidenceScore: 0.9,
            matchedDomains: [.education],
            reasons: ["education domain present"],
            provisional: false
        )
        let tiedLaterID = GoalDomainPackMatch(
            packID: "finance",
            confidenceScore: 0.9,
            matchedDomains: [.finance],
            reasons: ["finance domain present"],
            provisional: true
        )

        let sorted = [lowerConfidence, tiedLaterID, higherConfidence].sorted(by: GoalDomainPackMatch.stableOrdering)

        XCTAssertEqual(sorted.map(\.packID), ["education", "finance", "career"])
    }

    func testPackTargetArtifactIDIsStable() {
        let target = GoalDomainPackTarget(candidateID: "candidate-primary", stageID: "stage-primary-readiness")

        XCTAssertEqual(
            target.makeArtifactID(packID: "education", kind: "resource_hook", semanticKey: "entry_requirements"),
            "pack-education-candidate-primary-stage-primary-readiness-resource_hook-entry_requirements"
        )
    }

    func testContributionRoundTripsThroughCodable() throws {
        let contribution = GoalDomainPackContribution(
            requirementHints: [
                GoalCompiledPathRequirementHint(
                    id: "requirement-1",
                    summary: "Requirements may need confirmation.",
                    kind: .externalRequirement,
                    relatedField: .goalShape,
                    relatedStageID: "stage-primary-readiness",
                    blocking: false
                )
            ],
            dependencyHints: [],
            readinessCriteria: [
                GoalCompiledPathReadinessCriterion(
                    id: "criterion-1",
                    summary: "Entry requirements confirmed",
                    kind: .confirmation,
                    targetStageID: "stage-primary-readiness",
                    token: "entry_requirements_confirmed",
                    blocking: true
                )
            ],
            riskHints: [],
            resourceHooks: [
                GoalCompiledPathResourceHook(
                    id: "hook-1",
                    summary: "Requirements may still need a reference.",
                    kind: .requirementReference,
                    targetStageID: "stage-primary-readiness",
                    relatedDomains: [.education],
                    sourceClaimIDs: [],
                    sourceRecordIDs: [],
                    optionality: .required,
                    placeholderState: .resourceNeeded
                )
            ],
            branchAdditions: [],
            auditEntries: [
                GoalCompiledPathPackAuditEntry(
                    id: "pack-audit-1",
                    packID: "education",
                    contributionKind: .resourceHook,
                    artifactID: "hook-1",
                    targetCandidateID: "candidate-primary",
                    targetStageID: "stage-primary-readiness",
                    summary: "Education pack added a placeholder resource hook."
                )
            ]
        )

        let encoded = try JSONEncoder().encode(contribution)
        let decoded = try JSONDecoder().decode(GoalDomainPackContribution.self, from: encoded)

        XCTAssertEqual(decoded, contribution)
    }
}
