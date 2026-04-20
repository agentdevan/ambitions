import XCTest
@testable import Ambitions

final class GoalDomainPackServiceTests: XCTestCase {
    func testServiceReturnsNoMatchesWhenNoPackApplies() {
        let service = DefaultGoalDomainPackService(packs: [CareerGoalDomainPack(), EducationGoalDomainPack()])

        let enriched = service.applyPacks(
            to: GoalCompiledPath.legacyFallback(from: sampleNonMatchingUnderstanding()),
            understanding: sampleNonMatchingUnderstanding()
        )

        XCTAssertTrue(enriched.candidates.allSatisfy { $0.appliedPacks.isEmpty })
        XCTAssertTrue(enriched.audit.packEntries.isEmpty)
    }

    func testServiceAppliesStablePackOrderingAndDeterministicArtifactOrdering() {
        let service = DefaultGoalDomainPackService(packs: [EducationGoalDomainPack(), CareerGoalDomainPack()])
        let understanding = sampleEducationUnderstanding()
        let compiled = GoalCompiledPath.legacyFallback(from: understanding)

        let first = service.applyPacks(to: compiled, understanding: understanding)
        let second = service.applyPacks(to: compiled, understanding: understanding)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.candidates.first?.appliedPacks.map(\.packID), ["education", "career"])
        XCTAssertEqual(
            first.candidates.first?.resourceHooks.map(\.id),
            first.candidates.first?.resourceHooks.map(\.id).sorted()
        )
    }

    func testServicePreservesCoreArtifactsWhileAddingPackContributions() throws {
        let service = DefaultGoalDomainPackService(packs: [EducationGoalDomainPack()])
        let understanding = sampleEducationUnderstanding()
        let core = GoalCompiledPath.legacyFallback(from: understanding)
        let enriched = service.applyPacks(to: core, understanding: understanding)

        let corePrimary = try XCTUnwrap(core.candidates.first(where: \.isPrimary))
        let enrichedPrimary = try XCTUnwrap(enriched.candidates.first(where: \.isPrimary))

        XCTAssertEqual(enrichedPrimary.stages, corePrimary.stages)
        XCTAssertTrue(enrichedPrimary.dependencies.count >= corePrimary.dependencies.count)
        XCTAssertTrue(enrichedPrimary.branches.count >= corePrimary.branches.count)
        XCTAssertEqual(enrichedPrimary.assumptions, corePrimary.assumptions)
        XCTAssertTrue(enrichedPrimary.resourceHooks.isEmpty == false)
        XCTAssertTrue(enriched.audit.packEntries.isEmpty == false)
    }

    func testResourceHooksStayPlaceholderOnly() throws {
        let service = DefaultGoalDomainPackService(packs: [EducationGoalDomainPack()])
        let enriched = service.applyPacks(
            to: GoalCompiledPath.legacyFallback(from: sampleEducationUnderstanding()),
            understanding: sampleEducationUnderstanding()
        )

        let primary = try XCTUnwrap(enriched.candidates.first(where: \.isPrimary))
        XCTAssertTrue(primary.resourceHooks.allSatisfy { $0.placeholderState == .resourceNeeded })
        XCTAssertTrue(primary.resourceHooks.allSatisfy { $0.summary.isEmpty == false })
        XCTAssertTrue(primary.resourceHooks.allSatisfy { $0.optionality == .required })
    }
}

private extension GoalDomainPackServiceTests {
    func sampleEducationUnderstanding() -> GoalUnderstanding {
        let base = GoalPathCompilerServiceTests().sampleStrongerUnderstanding()
        return GoalUnderstanding(
            schemaVersion: base.schemaVersion,
            subject: base.subject,
            primaryInterpretation: GoalUnderstandingInterpretation(
                id: base.primaryInterpretation.id,
                summary: base.primaryInterpretation.summary,
                modeHint: .learning,
                domainHints: [.career, .education],
                supportingSignals: base.primaryInterpretation.supportingSignals,
                source: base.primaryInterpretation.source
            ),
            alternateInterpretations: base.alternateInterpretations,
            domains: GoalUnderstandingDomainInterpretation(
                primary: .education,
                all: [
                    LifeDomainAssignment(domain: .education, priority: 1),
                    LifeDomainAssignment(domain: .career, priority: 0.8)
                ],
                isAmbiguous: false
            ),
            mode: GoalUnderstandingModeInterpretation(
                goalMode: .learning,
                planningStrategyID: .learningPath,
                progressStrategyID: .learning,
                remainsProvisional: false
            ),
            ownership: base.ownership,
            timeline: base.timeline,
            successDefinition: base.successDefinition,
            readiness: base.readiness,
            constraints: base.constraints,
            dependencies: base.dependencies,
            risks: base.risks,
            assumptions: base.assumptions,
            clarification: base.clarification,
            confidence: base.confidence,
            audit: base.audit
        )
    }

    func sampleNonMatchingUnderstanding() -> GoalUnderstanding {
        let base = GoalPathCompilerServiceTests().sampleStrongerUnderstanding()
        return GoalUnderstanding(
            schemaVersion: base.schemaVersion,
            subject: base.subject,
            primaryInterpretation: GoalUnderstandingInterpretation(
                id: base.primaryInterpretation.id,
                summary: base.primaryInterpretation.summary,
                modeHint: .project,
                domainHints: [.home],
                supportingSignals: base.primaryInterpretation.supportingSignals,
                source: base.primaryInterpretation.source
            ),
            alternateInterpretations: [],
            domains: GoalUnderstandingDomainInterpretation(
                primary: .home,
                all: [LifeDomainAssignment(domain: .home, priority: 1)],
                isAmbiguous: false
            ),
            mode: GoalUnderstandingModeInterpretation(
                goalMode: .project,
                planningStrategyID: .milestonePlan,
                progressStrategyID: .timedExecution,
                remainsProvisional: false
            ),
            ownership: base.ownership,
            timeline: base.timeline,
            successDefinition: base.successDefinition,
            readiness: base.readiness,
            constraints: base.constraints,
            dependencies: base.dependencies,
            risks: base.risks,
            assumptions: base.assumptions,
            clarification: base.clarification,
            confidence: base.confidence,
            audit: base.audit
        )
    }
}
