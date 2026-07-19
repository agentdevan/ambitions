import XCTest
@testable import Ambitions

final class OneStepGoalProjectorTests: XCTestCase {
    func testProjectionGroupsOneStepGoalsUnderLifeAreasAndStandaloneBucket() {
        let projector = OneStepGoalProjector()
        let careerTask = makeTask(
            id: "email-portfolio",
            title: "Email portfolio",
            area: .career,
            status: .today,
            linkedGoalIDs: ["goal-career"]
        )
        let standalone = makeTask(
            id: "buy-stamps",
            title: "Buy stamps",
            area: nil,
            status: .ready
        )
        let activeGoal = makeGoal(id: "goal-career", title: "Build design practice", domain: .career)

        let projection = projector.projection(from: .init(oneStepGoals: [standalone, careerTask], goals: [activeGoal]))

        XCTAssertEqual(projection.counts.total, 2)
        XCTAssertEqual(projection.counts.openCount, 2)
        XCTAssertEqual(projection.areas.prefix(2).map(\.id), ["career", "standalone"])
        let career = tryUnwrap(projection.areas.first { $0.lifeAreaID == LifeAreaID(domain: .career) })
        XCTAssertEqual(career.oneStepGoals.map(\.title), ["Email portfolio"])
        XCTAssertEqual(career.oneStepGoals.first?.linkedActiveGoalCount, 1)
        let standaloneArea = tryUnwrap(projection.areas.first { $0.lifeAreaID == nil })
        XCTAssertEqual(standaloneArea.displayName, "No Life Area")
        XCTAssertEqual(standaloneArea.oneStepGoals.map(\.title), ["Buy stamps"])
    }

    func testProjectionOrderingIsDeterministicAndKeepsArchivedOutByDefault() {
        let projector = OneStepGoalProjector()
        let archived = makeTask(id: "archived", title: "Archived task", area: .career, status: .archived)
        let parked = makeTask(id: "parked", title: "Parked task", area: .career, status: .parked)
        let waiting = makeTask(id: "waiting", title: "Waiting task", area: .career, status: .waiting)
        let dueSoon = makeTask(
            id: "due-soon",
            title: "Due soon",
            area: .career,
            status: .scheduled,
            timing: OneStepGoalTimingMetadata(dueAt: "2026-04-29T12:00:00Z")
        )
        let dueLater = makeTask(
            id: "due-later",
            title: "Due later",
            area: .career,
            status: .scheduled,
            timing: OneStepGoalTimingMetadata(dueAt: "2026-05-02T12:00:00Z")
        )

        let projection = projector.projection(from: .init(oneStepGoals: [archived, parked, dueLater, waiting, dueSoon]))
        let career = tryUnwrap(projection.areas.first { $0.lifeAreaID == LifeAreaID(domain: .career) })

        XCTAssertEqual(career.oneStepGoals.map(\.id.rawValue), ["due-soon", "due-later", "waiting", "parked"])
        XCTAssertEqual(projection.counts.archived, 0)

        let withArchived = projector.projection(from: .init(oneStepGoals: [archived], includeArchived: true))
        XCTAssertEqual(withArchived.counts.archived, 1)
    }

    func testProjectionBuildsLocalLabelsFiltersAndSavedViewsForTheReplacementFloor() {
        let projector = OneStepGoalProjector()
        let today = makeTask(
            id: "today",
            title: "Today task",
            area: .career,
            status: .today,
            source: .capture,
            proofReferenceIDs: ["proof-today"],
            reviewReferenceIDs: ["review-today"]
        )
        let upcoming = makeTask(
            id: "upcoming",
            title: "Upcoming task",
            area: .career,
            status: .scheduled,
            timing: OneStepGoalTimingMetadata(dueAt: "2026-06-01T12:00:00Z"),
            source: .command,
            proofReferenceIDs: ["proof-upcoming"],
            reviewReferenceIDs: ["review-upcoming"]
        )
        let open = makeTask(
            id: "open",
            title: "Open task",
            area: .career,
            status: .ready,
            source: .review,
            proofReferenceIDs: ["proof-open"],
            reviewReferenceIDs: ["review-open"]
        )
        let waiting = makeTask(
            id: "waiting",
            title: "Waiting task",
            area: .career,
            status: .waiting,
            linkedGoalIDs: ["goal-career"],
            source: .manual
        )
        let held = makeTask(
            id: "held",
            title: "Held task",
            area: .career,
            status: .parked,
            source: .demotedGoal,
            proofReferenceIDs: ["proof-held"],
            reviewReferenceIDs: ["review-held"]
        )
        let someday = makeTask(
            id: "someday",
            title: "Someday task",
            area: .career,
            status: .reviewLater,
            timing: OneStepGoalTimingMetadata(reviewAfter: "2026-07-01T12:00:00Z"),
            source: .manual
        )

        let projection = projector.projection(from: .init(oneStepGoals: [today, upcoming, open, waiting, held, someday]))

        XCTAssertEqual(projection.labels.first?.title, "Open")
        XCTAssertTrue(projection.labels.contains { $0.id == "proof_needed" && $0.count == 2 })
        XCTAssertTrue(projection.labels.contains { $0.id == "source_needed" && $0.count == 2 })
        XCTAssertTrue(projection.labels.contains { $0.id == "waiting" && $0.goalIDs == [OneStepGoalID(rawValue: "waiting")] })

        XCTAssertEqual(
            projection.filters.map(\.title),
            [
                "Labels/tags",
                "Today",
                "Upcoming",
                "Scheduled",
                "Open",
                "Waiting",
                "Blocked",
                "Held",
                "Someday/Future",
                "Proof Needed",
                "Needs Review",
                "Source Needed"
            ]
        )
        XCTAssertEqual(projection.savedViews.map(\.title), projection.filters.map(\.title))
        XCTAssertEqual(projection.savedViews.first?.count, projection.labels.count)
        XCTAssertEqual(projection.filters.first?.goalIDs.map(\.rawValue), ["today", "upcoming", "open", "waiting", "held", "someday"])
        XCTAssertEqual(projection.filters.first?.criteriaDescription, "Browse the local label index.")
        XCTAssertEqual(projection.filters.first { $0.id == OneStepGoalSavedViewKind.today.rawValue }?.goalIDs.map(\.rawValue), ["today"])
        XCTAssertEqual(projection.filters.first { $0.id == OneStepGoalSavedViewKind.upcoming.rawValue }?.goalIDs.map(\.rawValue), ["upcoming"])
        XCTAssertEqual(projection.filters.first { $0.id == OneStepGoalSavedViewKind.scheduled.rawValue }?.goalIDs.map(\.rawValue), ["upcoming"])
        XCTAssertEqual(projection.filters.first { $0.id == OneStepGoalSavedViewKind.open.rawValue }?.goalIDs.map(\.rawValue), ["today", "upcoming", "open", "waiting", "someday"])
        XCTAssertEqual(projection.filters.first { $0.id == OneStepGoalSavedViewKind.waiting.rawValue }?.goalIDs.map(\.rawValue), ["waiting"])
        XCTAssertEqual(projection.filters.first { $0.id == OneStepGoalSavedViewKind.blocked.rawValue }?.goalIDs.map(\.rawValue), ["waiting", "held"])
        XCTAssertEqual(projection.filters.first { $0.id == OneStepGoalSavedViewKind.held.rawValue }?.goalIDs.map(\.rawValue), ["held", "someday"])
        XCTAssertEqual(projection.filters.first { $0.id == OneStepGoalSavedViewKind.somedayFuture.rawValue }?.goalIDs.map(\.rawValue), ["someday"])
        XCTAssertEqual(projection.filters.first { $0.id == OneStepGoalSavedViewKind.proofNeeded.rawValue }?.goalIDs.map(\.rawValue), ["waiting", "someday"])
        XCTAssertEqual(projection.filters.first { $0.id == OneStepGoalSavedViewKind.needsReview.rawValue }?.goalIDs.map(\.rawValue), ["waiting", "someday"])
        XCTAssertEqual(projection.filters.first { $0.id == OneStepGoalSavedViewKind.sourceNeeded.rawValue }?.goalIDs.map(\.rawValue), ["waiting", "someday"])
    }

    func testEmptyAndPrivacySafeProjectionAreExplicit() {
        let projector = OneStepGoalProjector()
        let privateTask = makeTask(
            id: "private",
            title: "Private task",
            area: .relationships,
            status: .reviewLater,
            isSensitive: true
        )

        let empty = projector.projection(from: .init(oneStepGoals: []))
        XCTAssertEqual(empty.emptyTitle, "No One-Step Goals yet")
        XCTAssertEqual(empty.counts.total, 0)
        XCTAssertEqual(empty.areas.count, LifeDomainKey.allCases.count)

        let projection = projector.projection(from: .init(oneStepGoals: [privateTask]))
        let relationships = tryUnwrap(projection.areas.first { $0.lifeAreaID == LifeAreaID(domain: .relationships) })
        XCTAssertEqual(relationships.oneStepGoals.first?.title, "Private item")
        XCTAssertEqual(relationships.oneStepGoals.first?.note, "Detail hidden")
        XCTAssertEqual(projection.privacySafeCompact.privacyLevel, .redacted)
        XCTAssertEqual(projection.privacySafeCompact.areas.first { $0.lifeAreaID == LifeAreaID(domain: .relationships) }?.oneStepGoals.first?.title, "Private item")
    }

    func testProjectionKeepsHiddenAndSensitiveItemsOutOfLabelsAndSavedViews() {
        let projector = OneStepGoalProjector()
        let hidden = makeTask(
            id: "hidden",
            title: "Hidden task",
            area: .career,
            status: .waiting,
            source: .manual
        )
        let sensitive = makeTask(
            id: "sensitive",
            title: "Sensitive task",
            area: .relationships,
            status: .reviewLater,
            source: .manual,
            isSensitive: true
        )
        let visible = makeTask(
            id: "visible",
            title: "Visible task",
            area: .career,
            status: .today,
            source: .capture,
            proofReferenceIDs: ["proof-visible"],
            reviewReferenceIDs: ["review-visible"]
        )

        let projection = projector.projection(
            from: .init(
                oneStepGoals: [hidden, sensitive, visible],
                hiddenOneStepGoalIDs: [hidden.id],
                hiddenAreaIDs: [LifeAreaID(domain: .relationships)]
            )
        )

        XCTAssertEqual(projection.labels.flatMap(\.goalIDs).map(\.rawValue), ["visible", "visible", "visible"])
        XCTAssertEqual(projection.savedViews.first { $0.kind == .labelsTags }?.goalIDs.map(\.rawValue), ["visible"])
        XCTAssertEqual(projection.savedViews.first { $0.kind == .waiting }?.goalIDs, [])
        XCTAssertEqual(projection.savedViews.first { $0.kind == .sourceNeeded }?.goalIDs, [])

        let redactedProjection = projector.projection(
            from: .init(
                oneStepGoals: [visible],
                privacyLevel: .redacted
            )
        )

        XCTAssertEqual(redactedProjection.labels, [])
        XCTAssertEqual(redactedProjection.savedViews.first?.goalIDs, [])

        let privacySafeCompact = projection.privacySafeCompact
        XCTAssertEqual(privacySafeCompact.labels, [])
        XCTAssertTrue(privacySafeCompact.filters.allSatisfy { $0.count == 0 && $0.goalIDs.isEmpty })
        XCTAssertTrue(privacySafeCompact.savedViews.allSatisfy { $0.count == 0 && $0.goalIDs.isEmpty })
        XCTAssertTrue(privacySafeCompact.filters.allSatisfy(\.criteriaTags.isEmpty))
        XCTAssertTrue(privacySafeCompact.savedViews.allSatisfy(\.criteriaTags.isEmpty))
    }
}

private extension OneStepGoalProjectorTests {
    func tryUnwrap<T>(_ value: T?, file: StaticString = #filePath, line: UInt = #line) -> T {
        guard let value else {
            XCTFail("Expected value", file: file, line: line)
            fatalError("Expected value")
        }
        return value
    }

    func makeTask(
        id: String,
        title: String,
        area: LifeDomainKey?,
        status: OneStepGoalStatus,
        timing: OneStepGoalTimingMetadata? = nil,
        linkedGoalIDs: [String] = [],
        source: OneStepGoalSource = .manual,
        proofReferenceIDs: [String] = [],
        reviewReferenceIDs: [String] = [],
        sourceCaptureID: String? = nil,
        isSensitive: Bool = false
    ) -> OneStepGoal {
        OneStepGoal(
            id: OneStepGoalID(rawValue: id),
            title: title,
            lifeAreaID: area.map { LifeAreaID(domain: $0) },
            status: status,
            timing: timing,
            source: source,
            sourceCaptureID: sourceCaptureID,
            linkedGoalIDs: linkedGoalIDs,
            proofReferenceIDs: proofReferenceIDs,
            reviewReferenceIDs: reviewReferenceIDs,
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
