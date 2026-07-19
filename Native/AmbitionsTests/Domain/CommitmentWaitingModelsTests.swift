import XCTest
@testable import Ambitions

final class CommitmentWaitingModelsTests: XCTestCase {
    func testCommitmentKindsCoverBatch79FoundationScope() {
        XCTAssertEqual(
            Set(CommitmentKind.allCases),
            [
                .promiseMade,
                .promiseReceived,
                .followUp,
                .obligation,
                .checkIn,
                .decisionNeeded,
                .resourceNeeded,
                .feedbackNeeded
            ]
        )
        XCTAssertEqual(Set(CommitmentDirection.allCases), [.userOwes, .userWaiting, .mutual, .informational])
        XCTAssertEqual(Set(CommitmentState.allCases), [.open, .waiting, .dueSoon, .overdue, .done, .parked, .blocked])
        XCTAssertEqual(Set(CommitmentSensitivity.allCases), [.low, .normal, .sensitive])
    }

    func testWaitingKindsCoverBatch79FoundationScope() {
        XCTAssertEqual(
            Set(WaitingReason.allCases),
            [
                .personResponse,
                .feedback,
                .resource,
                .decision,
                .money,
                .timeWindow,
                .externalEvent,
                .calendarWindow,
                .unknown
            ]
        )
        XCTAssertEqual(Set(WaitingState.allCases), [.waiting, .followUpDue, .overdue, .resolved, .parked, .blocked])
    }

    func testProjectionRejectsMalformedRecordsAndKeepsManualPeopleLocal() {
        let malformedPerson = ManualPersonReference(id: " ", displayName: " ")
        let malformedCommitment = CommitmentReference(
            id: "commitment-1",
            title: " ",
            kind: .promiseMade,
            direction: .userOwes,
            relatedPerson: malformedPerson
        )
        let malformedWaitingItem = WaitingItemReference(
            id: "waiting-1",
            title: "Waiting on contract",
            reason: .decision,
            relatedPerson: malformedPerson
        )

        let projection = PromiseLedgerProjection(
            personReferences: [malformedPerson],
            commitments: [malformedCommitment],
            waitingItems: [malformedWaitingItem]
        )

        XCTAssertTrue(projection.personReferences.isEmpty)
        XCTAssertTrue(projection.commitments.isEmpty)
        XCTAssertTrue(projection.waitingItems.isEmpty)
        XCTAssertTrue(projection.lifeGraphProjection.relationships.isEmpty)
    }

    func testProjectionDedupesAndOrdersCommitmentsWaitingItemsAndPeopleDeterministically() {
        let alex = person("person-alex", "Alex")
        let goal = object(.goal, "goal-1", label: "Launch app")
        let commitmentB = commitment("commitment-b", title: "Send B", person: alex, attachedObject: goal, due: "2026-04-27T15:00:00Z")
        let commitmentA = commitment("commitment-a", title: "Send A", person: alex, attachedObject: goal, due: "2026-04-27T14:00:00Z")
        let duplicateCommitmentA = commitment("commitment-a", title: "Send A copy", person: alex, attachedObject: goal, due: "2026-04-28T14:00:00Z")
        let waitingB = waiting("waiting-b", title: "Waiting B", person: alex, attachedObject: goal, due: "2026-04-27T15:00:00Z")
        let waitingA = waiting("waiting-a", title: "Waiting A", person: alex, attachedObject: goal, due: "2026-04-27T14:00:00Z")
        let duplicateWaitingA = waiting("waiting-a", title: "Waiting A copy", person: alex, attachedObject: goal, due: "2026-04-28T14:00:00Z")

        let projection = PromiseLedgerProjection(
            personReferences: [alex, person("person-alex", "Alex duplicate")],
            commitments: [commitmentB, duplicateCommitmentA, commitmentA],
            waitingItems: [waitingB, duplicateWaitingA, waitingA]
        )

        XCTAssertEqual(projection.personReferences.map(\.id), ["person-alex"])
        XCTAssertEqual(projection.commitments.map(\.id), ["commitment-a", "commitment-b"])
        XCTAssertEqual(projection.waitingItems.map(\.id), ["waiting-a", "waiting-b"])
        XCTAssertEqual(projection.openCommitments.map(\.id), ["commitment-a", "commitment-b"])
        XCTAssertEqual(projection.activeWaitingItems.map(\.id), ["waiting-a", "waiting-b"])
    }

    func testProjectionListsCommitmentsAndWaitingItemsByPerson() {
        let alex = person("person-alex", "Alex")
        let jordan = person("person-jordan", "Jordan")
        let goal = object(.goal, "goal-1", label: "Launch app")
        let alexCommitment = commitment("commitment-alex", title: "Send notes", person: alex, attachedObject: goal)
        let jordanCommitment = commitment("commitment-jordan", title: "Review copy", person: jordan, attachedObject: goal)
        let alexWaiting = waiting("waiting-alex", title: "Waiting on edits", person: alex, attachedObject: goal)
        let jordanWaiting = waiting("waiting-jordan", title: "Waiting on quote", person: jordan, attachedObject: goal)

        let projection = PromiseLedgerProjection(
            commitments: [jordanCommitment, alexCommitment],
            waitingItems: [jordanWaiting, alexWaiting]
        )

        XCTAssertEqual(projection.commitments(for: alex).map(\.id), ["commitment-alex"])
        XCTAssertEqual(projection.commitments(for: jordan).map(\.id), ["commitment-jordan"])
        XCTAssertEqual(projection.waitingItems(for: alex).map(\.id), ["waiting-alex"])
        XCTAssertEqual(projection.waitingItems(for: jordan).map(\.id), ["waiting-jordan"])
    }

    func testSocialLoadSignalsStayQualitativeAndSubordinate() {
        let alex = person("person-alex", "Alex")
        let goal = object(.goal, "goal-1", label: "Launch app")
        let overduePromise = CommitmentReference(
            id: "overdue-promise",
            title: "Send launch notes",
            kind: .promiseMade,
            direction: .userOwes,
            state: .overdue,
            relatedPerson: alex,
            attachedObject: goal,
            sensitivity: .normal
        )
        let sensitiveFollowUp = CommitmentReference(
            id: "sensitive-follow-up",
            title: "Check in about feedback",
            kind: .followUp,
            direction: .mutual,
            state: .open,
            relatedPerson: alex,
            attachedObject: goal,
            sensitivity: .sensitive
        )
        let lowStakesFollowUp = CommitmentReference(
            id: "low-follow-up",
            title: "Nudge for optional notes",
            kind: .followUp,
            direction: .informational,
            state: .open,
            relatedPerson: alex,
            attachedObject: goal,
            sensitivity: .low
        )
        let waitingItem = waiting("waiting-alex", title: "Waiting on response", person: alex, attachedObject: goal)

        let projection = PromiseLedgerProjection(
            commitments: [overduePromise, sensitiveFollowUp, lowStakesFollowUp],
            waitingItems: [waitingItem]
        )

        XCTAssertEqual(
            Set(projection.socialLoadSignals.map(\.kind)),
            [.someoneWaitingOnYou, .overduePromise, .sensitiveFollowUp, .lowStakesFollowUp, .waitingOnSomeone]
        )
        XCTAssertTrue(projection.socialLoadSignals.allSatisfy { $0.relatedPerson?.id == alex.id })
    }

    func testCommitmentsAndWaitingItemsProjectIntoLifeGraphRelationships() {
        let alex = person("person-alex", "Alex")
        let goal = object(.goal, "goal-1", label: "Launch app")
        let action = object(.action, "action-1", parent: goal.id, label: "Ship build")
        let madePromise = commitment("commitment-1", title: "Send build", person: alex, attachedObject: action)
        let decisionNeeded = CommitmentReference(
            id: "commitment-decision",
            title: "Pick rollout path",
            kind: .decisionNeeded,
            direction: .mutual,
            state: .open,
            relatedPerson: alex,
            attachedObject: goal
        )
        let waitingItem = waiting("waiting-1", title: "Waiting on feedback", person: alex, attachedObject: action)
        let blockedWaitingItem = WaitingItemReference(
            id: "waiting-blocked",
            title: "Blocked on funds",
            reason: .money,
            state: .blocked,
            relatedPerson: alex,
            attachedObject: goal
        )

        let projection = PromiseLedgerProjection(
            commitments: [madePromise, decisionNeeded],
            waitingItems: [waitingItem, blockedWaitingItem]
        )

        XCTAssertEqual(projection.lifeGraphProjection.sourceObjects(to: action, kind: .supports).map(\.id), ["commitment-1"])
        XCTAssertEqual(projection.lifeGraphProjection.sourceObjects(to: goal, kind: .explains).map(\.id), ["commitment-decision"])
        XCTAssertEqual(projection.lifeGraphProjection.sourceObjects(to: action, kind: .waitsOn).map(\.id), ["waiting-1"])
        XCTAssertEqual(projection.lifeGraphProjection.sourceObjects(to: goal, kind: .blocks).map(\.id), ["waiting-blocked"])
        XCTAssertEqual(projection.lifeGraphProjection.sourceObjects(to: madePromise.lifeGraphObjectReference, kind: .relatesTo).map(\.id), ["person-alex"])
        XCTAssertEqual(Set(projection.relationshipProjection(for: action).relationships.map(\.missionControlLane)), [.now, .risk])
    }

    func testManualPersonCanAlignToResourceGraphPersonReferenceWithoutContactsData() {
        let alex = ManualPersonReference(
            id: "person-alex",
            displayName: "Alex",
            roleContextLabel: "Launch stakeholder",
            sourceDomain: .commitment
        )
        let goal = object(.goal, "goal-1", label: "Launch app")

        let resource = alex.resourceReference(attachedTo: goal)
        let projection = ProofResourceGraphProjection(resourceReferences: [resource])

        XCTAssertEqual(resource.kind, .personReference)
        XCTAssertEqual(resource.locator, "manual-person-reference:person-alex")
        XCTAssertEqual(resource.title, "Alex")
        XCTAssertEqual(projection.resourceReferences.map(\.id), ["person-resource-person-alex"])
        XCTAssertEqual(projection.lifeGraphProjection.sourceObjects(to: goal, kind: .attachedTo).map(\.id), ["person-resource-person-alex"])
    }
}

private extension CommitmentWaitingModelsTests {
    func person(_ id: String, _ displayName: String) -> ManualPersonReference {
        ManualPersonReference(id: id, displayName: displayName, roleContextLabel: "Stakeholder", sourceDomain: .commitment)
    }

    func object(
        _ kind: LifeGraphObjectKind,
        _ id: String,
        parent: String? = nil,
        label: String
    ) -> LifeGraphObjectReference {
        LifeGraphObjectReference(kind: kind, id: id, parentContextID: parent, label: label, sourceDomain: .goals)
    }

    func commitment(
        _ id: String,
        title: String,
        person: ManualPersonReference,
        attachedObject: LifeGraphObjectReference,
        due: String? = nil
    ) -> CommitmentReference {
        CommitmentReference(
            id: id,
            title: title,
            kind: .promiseMade,
            direction: .userOwes,
            state: .open,
            relatedPerson: person,
            attachedObject: attachedObject,
            dueOrFollowUpAt: due,
            sensitivity: .normal
        )
    }

    func waiting(
        _ id: String,
        title: String,
        person: ManualPersonReference,
        attachedObject: LifeGraphObjectReference,
        due: String? = nil
    ) -> WaitingItemReference {
        WaitingItemReference(
            id: id,
            title: title,
            reason: .personResponse,
            state: .waiting,
            relatedPerson: person,
            attachedObject: attachedObject,
            dueOrFollowUpAt: due
        )
    }
}
