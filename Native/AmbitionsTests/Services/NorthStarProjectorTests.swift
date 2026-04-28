import XCTest
@testable import Ambitions

final class NorthStarProjectorTests: XCTestCase {
    func testProjectionGroupsNorthStarsUnderLifeAreasAndCountsPostures() {
        let projector = NorthStarProjector()
        let astronaut = makeNorthStar(
            id: "astronaut",
            title: "Become an Astronaut",
            area: .career,
            posture: .readyToShape,
            linkedGoalIDs: ["goal-career"],
            canBeShaped: true
        )
        let home = makeNorthStar(
            id: "home",
            title: "Build a calm home",
            area: .home,
            posture: .dormant
        )
        let activeGoal = makeGoal(id: "goal-career", title: "Build flight portfolio", domain: .career)

        let projection = projector.projection(from: .init(northStars: [home, astronaut], goals: [activeGoal]))

        XCTAssertEqual(projection.counts.total, 2)
        XCTAssertEqual(projection.counts.readyToShape, 1)
        XCTAssertEqual(projection.counts.dormant, 1)
        XCTAssertEqual(projection.areas.prefix(2).map(\.id), [LifeAreaID(domain: .career), LifeAreaID(domain: .home)])
        let career = tryUnwrap(projection.areas.first { $0.id == LifeAreaID(domain: .career) })
        XCTAssertEqual(career.northStars.map(\.title), ["Become an Astronaut"])
        XCTAssertEqual(career.northStars.first?.linkedActiveGoalCount, 1)
        XCTAssertEqual(career.northStars.first?.shapeIntoGoalLabel, "This can become a goal later")
    }

    func testProjectionOrderingIsDeterministicAndKeepsArchivedOutByDefault() {
        let projector = NorthStarProjector()
        let archived = makeNorthStar(id: "archived", title: "Archived direction", area: .career, posture: .archived)
        let dormantRecent = makeNorthStar(id: "recent", title: "Quiet recent", area: .career, posture: .dormant, lastReferencedAt: "2026-04-28T12:00:00Z")
        let dormantOld = makeNorthStar(id: "old", title: "Quiet old", area: .career, posture: .dormant, lastReferencedAt: "2026-04-20T12:00:00Z")
        let active = makeNorthStar(id: "active", title: "Active direction", area: .career, posture: .activeDirection)
        let ready = makeNorthStar(id: "ready", title: "Ready direction", area: .career, posture: .readyToShape)

        let projection = projector.projection(from: .init(northStars: [archived, dormantOld, ready, dormantRecent, active]))
        let career = tryUnwrap(projection.areas.first { $0.id == LifeAreaID(domain: .career) })

        XCTAssertEqual(career.northStars.map(\.id.rawValue), ["active", "ready", "recent", "old"])
        XCTAssertEqual(projection.counts.archived, 0)

        let withArchived = projector.projection(from: .init(northStars: [archived], includeArchived: true))
        XCTAssertEqual(withArchived.counts.archived, 1)
    }

    func testEmptyAndPrivacySafeProjectionAreExplicit() {
        let projector = NorthStarProjector()
        let privateDirection = makeNorthStar(
            id: "private",
            title: "Private direction",
            area: .relationships,
            posture: .needsReview,
            isSensitive: true
        )

        let empty = projector.projection(from: .init(northStars: []))
        XCTAssertEqual(empty.emptyTitle, "No North Stars here yet")
        XCTAssertEqual(empty.counts.total, 0)
        XCTAssertEqual(empty.areas.count, LifeDomainKey.allCases.count)

        let projection = projector.projection(from: .init(northStars: [privateDirection]))
        let relationships = tryUnwrap(projection.areas.first { $0.id == LifeAreaID(domain: .relationships) })
        XCTAssertEqual(relationships.northStars.first?.title, "Private North Star")
        XCTAssertEqual(relationships.northStars.first?.summary, "Detail hidden")
        XCTAssertEqual(projection.privacySafeCompact.privacyLevel, .redacted)
        XCTAssertEqual(projection.privacySafeCompact.areas.first { $0.id == LifeAreaID(domain: .relationships) }?.northStars.first?.title, "Private North Star")
    }
}

private extension NorthStarProjectorTests {
    func tryUnwrap<T>(_ value: T?, file: StaticString = #filePath, line: UInt = #line) -> T {
        guard let value else {
            XCTFail("Expected value", file: file, line: line)
            fatalError("Expected value")
        }
        return value
    }

    func makeNorthStar(
        id: String,
        title: String,
        area: LifeDomainKey,
        posture: NorthStarPosture,
        linkedGoalIDs: [String] = [],
        canBeShaped: Bool = false,
        lastReferencedAt: String? = nil,
        isSensitive: Bool = false
    ) -> NorthStar {
        NorthStar(
            id: NorthStarID(rawValue: id),
            title: title,
            primaryLifeAreaID: LifeAreaID(domain: area),
            posture: posture,
            linkedGoalIDs: linkedGoalIDs,
            activationReadiness: canBeShaped ? .readyToShape : .heldWithoutPressure,
            canBeShaped: canBeShaped,
            lastReferencedAt: lastReferencedAt,
            isSensitive: isSensitive
        )
    }

    func makeGoal(id: String, title: String, domain: LifeDomainKey) -> Goal {
        Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: "2026-04-28T12:00:00Z",
            updatedAt: "2026-04-28T12:00:00Z",
            state: .active,
            title: title,
            summary: "A grounded goal",
            mode: .project,
            relationshipKind: .independent,
            actor: .localOwner,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: GoalTiming(
                tempo: .untimed,
                timingType: .logWhenDone,
                startsOn: nil,
                dueAt: nil,
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: nil,
                repeatEveryDays: nil,
                progressReviewCadenceDays: 7
            ),
            planningStrategy: PlanningStrategy(
                strategyKind: .sequential,
                allowParallelSteps: false,
                maxActiveSteps: 3,
                preferredSectionOrder: [.overview, .activeSteps],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: false,
                preferShortSteps: true,
                revisitCadenceDays: 7
            ),
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion,
                rollupMethod: .ratio,
                targetStepCount: nil,
                targetEvidenceCount: nil,
                targetMinutes: nil,
                supportsUntimedProgress: true,
                countsChildGoals: false,
                countsSupportGoals: false
            ),
            plan: nil,
            lifeGraph: LifeGraphContext(domains: [LifeDomainAssignment(domain: domain)])
        )
    }
}
