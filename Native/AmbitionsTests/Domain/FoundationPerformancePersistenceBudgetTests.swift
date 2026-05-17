import XCTest
@testable import Ambitions

final class FoundationPerformancePersistenceBudgetTests: XCTestCase {
    func testPhaseBFoundationSchemaVersionsSurviveCodableRoundTrips() throws {
        let goal = object(.goal, "goal-1", label: "Launch app", sourceDomain: .goals)
        let capture = object(.capture, "capture-1", label: "Release checklist", sourceDomain: .capture)
        let person = ManualPersonReference(id: "person-alex", displayName: "Alex")

        try assertCodableRoundTripPreservesSchemaVersion(
            LifeGraphRelationship(kind: .contains, source: goal, target: capture),
            expected: lifeGraphRelationshipSchemaVersion
        )
        try assertCodableRoundTripPreservesSchemaVersion(
            ProofReference(id: "proof-1", kind: .completedAction, title: "Build shipped", attachedObject: goal),
            expected: proofResourceGraphSchemaVersion
        )
        try assertCodableRoundTripPreservesSchemaVersion(
            ResourceReference(id: "resource-1", kind: .documentReference, title: "Launch notes", attachedObject: goal),
            expected: proofResourceGraphSchemaVersion
        )
        try assertCodableRoundTripPreservesSchemaVersion(person, expected: promiseLedgerSchemaVersion)
        try assertCodableRoundTripPreservesSchemaVersion(
            CommitmentReference(
                id: "commitment-1",
                title: "Send notes",
                kind: .promiseMade,
                direction: .userOwes,
                relatedPerson: person,
                attachedObject: goal
            ),
            expected: promiseLedgerSchemaVersion
        )
        try assertCodableRoundTripPreservesSchemaVersion(
            WaitingItemReference(
                id: "waiting-1",
                title: "Waiting on feedback",
                reason: .feedback,
                relatedPerson: person,
                attachedObject: goal
            ),
            expected: promiseLedgerSchemaVersion
        )
        try assertCodableRoundTripPreservesSchemaVersion(
            ActionReceipt(
                id: "receipt-1",
                resultState: .changed,
                title: "Capture changed",
                summary: "Capture changed locally.",
                sourceDomain: .capture,
                occurredAt: "2026-04-26T12:00:00Z",
                affectedObjects: [capture]
            ),
            expected: actionClosureReceiptSchemaVersion
        )
        try assertCodableRoundTripPreservesSchemaVersion(
            SafeAutomationProposedAction(kind: .archiveItem, sourceDomain: .capture, targetObjects: [capture]),
            expected: safeAutomationPolicySchemaVersion
        )
    }

    func testLifeGraphBreadcrumbTraversalIsBoundedAndCycleSafe() {
        let goal = object(.goal, "goal-1", label: "Goal", sourceDomain: .goals)
        let milestone = object(.milestone, "milestone-1", label: "Milestone", sourceDomain: .goalEngine)
        let action = object(.action, "action-1", label: "Action", sourceDomain: .goalEngine)
        let projection = LifeGraphRelationshipProjection(relationships: [
            LifeGraphRelationship(kind: .contains, source: goal, target: milestone),
            LifeGraphRelationship(kind: .contains, source: milestone, target: action),
            LifeGraphRelationship(kind: .contains, source: action, target: goal)
        ])

        XCTAssertEqual(projection.breadcrumb(to: action, maxDepth: 2).labels, ["Milestone", "Action"])
        XCTAssertEqual(projection.breadcrumb(to: action, maxDepth: 8).labels, ["Goal", "Milestone", "Action"])
        XCTAssertEqual(projection.breadcrumb(to: action, maxDepth: 0).labels, ["Action"])
    }

    func testFoundationProjectionsStayDeterministicAfterInputShuffleAndDuplicateRecords() {
        let goal = object(.goal, "goal-1", label: "Launch app", sourceDomain: .goals)
        let actionA = object(.action, "action-a", parent: goal.id, label: "Audit copy", sourceDomain: .goalEngine)
        let actionB = object(.action, "action-b", parent: goal.id, label: "Build importer", sourceDomain: .goalEngine)
        let person = ManualPersonReference(id: "person-alex", displayName: "Alex")

        let containsA = LifeGraphRelationship(kind: .contains, source: goal, target: actionA)
        let containsB = LifeGraphRelationship(kind: .contains, source: goal, target: actionB)
        XCTAssertEqual(
            LifeGraphRelationshipProjection(relationships: [containsB, containsA, containsA]).relationships.map(\.id),
            LifeGraphRelationshipProjection(relationships: [containsA, containsB]).relationships.map(\.id)
        )

        let proofA = ProofReference(id: "proof-a", kind: .completedAction, title: "A proof", attachedObject: actionA)
        let proofB = ProofReference(id: "proof-b", kind: .note, title: "B proof", attachedObject: actionB)
        let resourceA = ResourceReference(id: "resource-a", kind: .documentReference, title: "A resource", attachedObject: actionA)
        let resourceB = ResourceReference(id: "resource-b", kind: .calendarReference, title: "B resource", attachedObject: actionB)
        XCTAssertEqual(
            ProofResourceGraphProjection(
                proofReferences: [proofB, proofA, proofA],
                resourceReferences: [resourceB, resourceA, resourceA]
            ),
            ProofResourceGraphProjection(proofReferences: [proofA, proofB], resourceReferences: [resourceA, resourceB])
        )

        let commitmentA = CommitmentReference(
            id: "commitment-a",
            title: "Send A",
            kind: .promiseMade,
            direction: .userOwes,
            relatedPerson: person,
            attachedObject: actionA
        )
        let commitmentB = CommitmentReference(
            id: "commitment-b",
            title: "Send B",
            kind: .feedbackNeeded,
            direction: .userWaiting,
            relatedPerson: person,
            attachedObject: actionB
        )
        let waitingA = WaitingItemReference(id: "waiting-a", title: "Waiting A", reason: .feedback, relatedPerson: person, attachedObject: actionA)
        let waitingB = WaitingItemReference(id: "waiting-b", title: "Waiting B", reason: .resource, relatedPerson: person, attachedObject: actionB)
        XCTAssertEqual(
            PromiseLedgerProjection(
                personReferences: [person, person],
                commitments: [commitmentB, commitmentA, commitmentA],
                waitingItems: [waitingB, waitingA, waitingA]
            ),
            PromiseLedgerProjection(personReferences: [person], commitments: [commitmentA, commitmentB], waitingItems: [waitingA, waitingB])
        )

        let receiptA = receipt("receipt-a", occurredAt: "2026-04-26T12:00:00Z", affectedObjects: [actionA])
        let receiptB = receipt("receipt-b", occurredAt: "2026-04-26T13:00:00Z", affectedObjects: [actionB])
        XCTAssertEqual(
            ActionReceiptProjection(receipts: [receiptA, receiptB, receiptA]).displaySummaries(limit: 4).map(\.id),
            ["receipt-b", "receipt-a"]
        )
    }

    func testSafeAutomationExportSyncCalendarAndExternalBoundariesDoNotClaimExecution() {
        let action = object(.action, "action-1", label: "Plan block", sourceDomain: .time)
        let evaluator = SafeAutomationPolicyEvaluator()

        let prepareExport = evaluator.evaluate(
            SafeAutomationProposedAction(kind: .prepareExport, sourceDomain: .you, targetObjects: [action])
        )
        XCTAssertEqual(prepareExport.permissionLevel, .prepareDraft)
        XCTAssertEqual(prepareExport.receiptRecommendation.resultState, .exportedPrepared)
        XCTAssertEqual(prepareExport.degradedFacts, ["No export file is written by this policy."])

        let performExport = evaluator.evaluate(
            SafeAutomationProposedAction(kind: .performExport, sourceDomain: .you, targetObjects: [action])
        )
        XCTAssertEqual(performExport.permissionLevel, .requiresConfirmation)
        XCTAssertEqual(performExport.blockedFacts, ["No export was performed."])
        XCTAssertTrue(performExport.mustNeverBeSilent)

        let sync = evaluator.evaluate(
            SafeAutomationProposedAction(kind: .applySyncResolution, sourceDomain: .you, targetObjects: [action])
        )
        XCTAssertEqual(sync.permissionLevel, .notSupportedYet)
        XCTAssertEqual(sync.receiptRecommendation.safetyState, .safeFailure)
        XCTAssertEqual(sync.blockedFacts, ["No sync conflict resolution was applied."])

        let calendar = evaluator.evaluate(
            SafeAutomationProposedAction(kind: .writeCalendarBlock, sourceDomain: .time, targetObjects: [action])
        )
        XCTAssertEqual(calendar.confirmationRequirement, .requiredForExternalEffect)
        XCTAssertEqual(calendar.blockedFacts, ["No calendar data was changed."])

        let external = evaluator.evaluate(
            SafeAutomationProposedAction(
                kind: .archiveItem,
                sourceDomain: .externalSurface,
                targetObjects: [action],
                sourceAllowsLocalMutation: false
            )
        )
        XCTAssertEqual(external.permissionLevel, .requiresConfirmation)
        XCTAssertEqual(external.undoRule, .externalUndoUnavailable)
        XCTAssertEqual(external.blockedFacts, ["The source may not silently change local data."])
    }

    func testReceiptDisplaySummariesAndEventLedgerRecentQueriesAreExplicitlyBounded() async throws {
        let action = object(.action, "action-1", label: "Ship build", sourceDomain: .goalEngine)
        let projection = ActionReceiptProjection(receipts: [
            receipt("receipt-a", occurredAt: "2026-04-26T12:00:00Z", affectedObjects: [action]),
            receipt("receipt-b", occurredAt: "2026-04-26T13:00:00Z", affectedObjects: [action])
        ])

        XCTAssertEqual(projection.displaySummaries(limit: 1).map(\.id), ["receipt-b"])
        XCTAssertEqual(projection.displaySummaries(limit: 0), [])
        XCTAssertEqual(projection.displaySummaries(limit: -1), [])

        let ledger = InMemoryEventLedgerRepository()
        try await ledger.append(event("event-a", occurredAt: "2026-04-26T12:00:00Z"))
        try await ledger.append(event("event-b", occurredAt: "2026-04-26T13:00:00Z"))

        let oneRecentEvent = try await ledger.fetchRecent(limit: 1)
        let zeroRecentEvents = try await ledger.fetchRecent(limit: 0)
        let negativeRecentEvents = try await ledger.fetchRecent(limit: -1)

        XCTAssertEqual(oneRecentEvent.map(\.id), ["event-b"])
        XCTAssertEqual(zeroRecentEvents, [])
        XCTAssertEqual(negativeRecentEvents, [])
    }
}

private extension FoundationPerformancePersistenceBudgetTests {
    func assertCodableRoundTripPreservesSchemaVersion<Value>(
        _ value: Value,
        expected: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws where Value: Codable & Equatable & SchemaVersioned {
        let encoded = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(Value.self, from: encoded)

        XCTAssertEqual(decoded, value, file: file, line: line)
        XCTAssertEqual(decoded.schemaVersion, expected, file: file, line: line)
    }

    func object(
        _ kind: LifeGraphObjectKind,
        _ id: String,
        parent: String? = nil,
        label: String,
        sourceDomain: LifeGraphSourceDomain
    ) -> LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: kind,
            id: id,
            parentContextID: parent,
            label: label,
            sourceDomain: sourceDomain
        )
    }

    func receipt(
        _ id: String,
        occurredAt: String,
        affectedObjects: [LifeGraphObjectReference]
    ) -> ActionReceipt {
        ActionReceipt(
            id: id,
            resultState: .changed,
            title: "Local change",
            summary: "A local change was recorded.",
            sourceDomain: .system,
            occurredAt: occurredAt,
            affectedObjects: affectedObjects
        )
    }

    func event(_ id: String, occurredAt: String) -> EventLedgerEntry {
        EventLedgerEntry(
            id: id,
            kind: .recommendationShown,
            occurredAt: occurredAt,
            source: .system,
            title: id
        )
    }
}

private protocol SchemaVersioned {
    var schemaVersion: String { get }
}

extension LifeGraphRelationship: SchemaVersioned {}
extension ProofReference: SchemaVersioned {}
extension ResourceReference: SchemaVersioned {}
extension ManualPersonReference: SchemaVersioned {}
extension CommitmentReference: SchemaVersioned {}
extension WaitingItemReference: SchemaVersioned {}
extension ActionReceipt: SchemaVersioned {}
extension SafeAutomationProposedAction: SchemaVersioned {}
