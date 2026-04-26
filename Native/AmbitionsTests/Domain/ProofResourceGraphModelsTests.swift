import XCTest
@testable import Ambitions

final class ProofResourceGraphModelsTests: XCTestCase {
    func testProofKindsCoverBatch78FoundationScope() {
        XCTAssertEqual(
            Set(ProofReferenceKind.allCases),
            [
                .completedAction,
                .note,
                .link,
                .fileReference,
                .photoReference,
                .calendarBlockReference,
                .reflection,
                .externalArtifactReference,
                .decision,
                .milestoneEvidence,
                .feedbackReceived,
                .blockerResolved
            ]
        )
    }

    func testResourceKindsCoverManualFirstReferenceScope() {
        XCTAssertEqual(
            Set(ResourceReferenceKind.allCases),
            [
                .note,
                .link,
                .fileReference,
                .documentReference,
                .externalReference,
                .projectArtifact,
                .checklistTemplate,
                .personReference,
                .calendarReference
            ]
        )
    }

    func testProjectionRejectsMalformedReferencesWithoutRelationships() {
        let malformedGoal = LifeGraphObjectReference(kind: .goal, id: "   ", label: "Missing goal", sourceDomain: .goals)
        let proof = ProofReference(
            id: "proof-1",
            kind: .completedAction,
            title: "Action done",
            attachedObject: malformedGoal
        )
        let resource = ResourceReference(
            id: "resource-1",
            kind: .link,
            title: "Launch notes",
            locator: "https://example.com",
            attachedObject: malformedGoal
        )

        let projection = ProofResourceGraphProjection(proofReferences: [proof], resourceReferences: [resource])

        XCTAssertTrue(projection.proofReferences.isEmpty)
        XCTAssertTrue(projection.resourceReferences.isEmpty)
        XCTAssertTrue(projection.lifeGraphProjection.relationships.isEmpty)
    }

    func testProjectionDedupesAndOrdersProofAndResourcesDeterministically() {
        let goal = object(.goal, "goal-1", label: "Launch app")
        let actionA = object(.action, "action-a", parent: goal.id, label: "Build importer")
        let actionB = object(.action, "action-b", parent: goal.id, label: "Audit launch copy")
        let proofB = ProofReference(
            id: "proof-b",
            kind: .link,
            title: "B proof",
            attachedObject: actionB,
            occurredAt: "2026-04-26T14:00:00Z"
        )
        let proofA = ProofReference(
            id: "proof-a",
            kind: .completedAction,
            title: "A proof",
            attachedObject: actionA,
            occurredAt: "2026-04-26T13:00:00Z"
        )
        let duplicateProofA = ProofReference(
            id: "proof-a",
            kind: .completedAction,
            title: "A proof duplicate label",
            attachedObject: actionA,
            occurredAt: "2026-04-26T15:00:00Z"
        )
        let resourceB = ResourceReference(
            id: "resource-b",
            kind: .fileReference,
            title: "B file",
            locator: "manual-file-token",
            attachedObject: actionB
        )
        let resourceA = ResourceReference(
            id: "resource-a",
            kind: .checklistTemplate,
            title: "A checklist",
            attachedObject: actionA
        )
        let duplicateResourceA = ResourceReference(
            id: "resource-a",
            kind: .checklistTemplate,
            title: "A checklist copy",
            attachedObject: actionA
        )

        let projection = ProofResourceGraphProjection(
            proofReferences: [proofB, duplicateProofA, proofA],
            resourceReferences: [resourceB, duplicateResourceA, resourceA]
        )

        XCTAssertEqual(projection.proofReferences.map(\.id), ["proof-a", "proof-b"])
        XCTAssertEqual(projection.resourceReferences.map(\.id), ["resource-a", "resource-b"])
        XCTAssertEqual(projection.proof(attachedTo: actionA).map(\.id), ["proof-a"])
        XCTAssertEqual(projection.resources(attachedTo: actionA).map(\.id), ["resource-a"])
    }

    func testProofAndResourcesProjectIntoLifeGraphRelationships() {
        let goal = object(.goal, "goal-1", label: "Launch app")
        let action = object(.action, "action-1", parent: goal.id, label: "Ship build")
        let capture = object(.capture, "capture-1", label: "Release checklist", sourceDomain: .capture)
        let proof = ProofReference(
            id: "proof-1",
            kind: .completedAction,
            title: "Build uploaded",
            summary: "Manual artifact reference only.",
            sourceObject: capture,
            attachedObject: action,
            occurredAt: "2026-04-26T15:00:00Z",
            strength: .supporting
        )
        let decisionProof = ProofReference(
            id: "decision-proof-1",
            kind: .decision,
            title: "Use phased rollout",
            attachedObject: goal
        )
        let resource = ResourceReference(
            id: "resource-1",
            kind: .documentReference,
            title: "Launch notes",
            locator: "local-manual-reference",
            attachedObject: action
        )

        let projection = ProofResourceGraphProjection(
            proofReferences: [proof, decisionProof],
            resourceReferences: [resource]
        )
        let actionRelationships = projection.relationshipProjection(for: action)

        XCTAssertEqual(projection.lifeGraphProjection.sourceObjects(to: action, kind: .proves).map(\.id), ["proof-1"])
        XCTAssertEqual(projection.lifeGraphProjection.sourceObjects(to: goal, kind: .explains).map(\.id), ["decision-proof-1"])
        XCTAssertEqual(projection.lifeGraphProjection.sourceObjects(to: action, kind: .attachedTo).map(\.id), ["resource-1"])
        XCTAssertEqual(projection.lifeGraphProjection.relatedObjects(from: capture, kind: .produces).map(\.id), ["proof-1"])
        XCTAssertEqual(Set(actionRelationships.relationships.map(\.missionControlLane)), [.proof, .resources])
    }

    func testReferenceOnlyPlaceholdersStayLifeGraphObjectsWithoutProviderBehavior() {
        let milestone = object(.milestone, "milestone-1", label: "Beta ready")
        let blocker = object(.blocker, "blocker-1", label: "Certificate blocked")
        let photo = ProofReference(
            id: "photo-proof",
            kind: .photoReference,
            title: "Whiteboard snapshot",
            summary: "A manual photo reference placeholder.",
            attachedObject: milestone
        )
        let personResource = ResourceReference(
            id: "person-resource",
            kind: .personReference,
            title: "Alex",
            locator: "manual-person-token",
            summary: "A manual person reference placeholder.",
            attachedObject: blocker
        )

        let projection = ProofResourceGraphProjection(
            proofReferences: [photo],
            resourceReferences: [personResource]
        )

        XCTAssertEqual(photo.lifeGraphObjectReference.kind, .proof)
        XCTAssertEqual(personResource.lifeGraphObjectReference.kind, .resource)
        XCTAssertTrue(LifeGraphObjectKind.proof.isPlaceholderOnlyInV1)
        XCTAssertTrue(LifeGraphObjectKind.resource.isPlaceholderOnlyInV1)
        XCTAssertEqual(projection.lifeGraphProjection.sourceObjects(to: milestone, kind: .proves).map(\.id), ["photo-proof"])
        XCTAssertEqual(projection.lifeGraphProjection.sourceObjects(to: blocker, kind: .attachedTo).map(\.id), ["person-resource"])
    }
}

private extension ProofResourceGraphModelsTests {
    func object(
        _ kind: LifeGraphObjectKind,
        _ id: String,
        parent: String? = nil,
        label: String,
        sourceDomain: LifeGraphSourceDomain? = nil
    ) -> LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: kind,
            id: id,
            parentContextID: parent,
            label: label,
            sourceDomain: sourceDomain
        )
    }
}
