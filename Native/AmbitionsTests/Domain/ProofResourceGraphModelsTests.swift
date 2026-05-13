import XCTest
@testable import Ambitions

final class ProofResourceGraphModelsTests: XCTestCase {
    func testProofKindsCoverBatch78FoundationScope() {
        XCTAssertEqual(
            Set(ProofReferenceKind.allCases),
            [
                .completedAction,
                .stillCounts,
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

    func testPivotPreservationPreservesReviewableAndNonTransferableProofCapital() {
        let goal = object(.goal, "goal-1", label: "Launch app")
        let oldAction = object(.action, "action-old", parent: goal.id, label: "Ship release")
        let newAction = object(.action, "action-new", parent: goal.id, label: "Prepare rollout")

        let preservedProof = ProofReference(
            id: "preserved-proof",
            kind: .completedAction,
            title: "Release validated",
            attachedObject: oldAction,
            occurredAt: "2026-04-26T10:00:00Z",
            capitalProfile: ProofCapitalProfile(
                sourceKind: .actionReceipt,
                sourceState: .sourceBacked,
                freshnessState: .current,
                contradictionState: .none,
                evidence: .init(
                    anchorObjectIDs: [newAction.stableKey],
                    proofReferenceIDs: ["proof-input-1"],
                    sourceReceiptIDs: ["receipt-1"]
                )
            )
        )

        let reviewProof = ProofReference(
            id: "review-proof",
            kind: .completedAction,
            title: "Review-needed milestone",
            attachedObject: oldAction,
            occurredAt: "2026-04-26T11:00:00Z",
            capitalProfile: ProofCapitalProfile(
                sourceKind: .manual,
                sourceState: .userConfirmed,
                freshnessState: .stale,
                contradictionState: .none,
                evidence: .init(
                    anchorObjectIDs: [newAction.stableKey],
                    sourceReceiptIDs: ["receipt-stale"]
                )
            )
        )

        let contradictedProof = ProofReference(
            id: "contradicted-proof",
            kind: .decision,
            title: "Contradicted proof",
            attachedObject: oldAction,
            capitalProfile: ProofCapitalProfile(
                sourceKind: .correction,
                sourceState: .sourceBacked,
                freshnessState: .current,
                contradictionState: .confirmed,
                evidence: .init(
                    anchorObjectIDs: [newAction.stableKey],
                    proofReferenceIDs: ["proof-input-3"]
                )
            )
        )

        let noOverlapProof = ProofReference(
            id: "no-overlap-proof",
            kind: .decision,
            title: "No-overlap proof",
            attachedObject: oldAction,
            capitalProfile: ProofCapitalProfile(
                sourceKind: .manual,
                sourceState: .sourceBacked,
                freshnessState: .current,
                contradictionState: .none,
                evidence: .init(
                    anchorObjectIDs: [goal.stableKey],
                    sourceReceiptIDs: ["receipt-overlap"]
                )
            )
        )

        let missingEvidenceProof = ProofReference(
            id: "missing-evidence-proof",
            kind: .link,
            title: "Missing evidence proof",
            attachedObject: oldAction,
            capitalProfile: ProofCapitalProfile(
                sourceKind: .manual,
                sourceState: .sourceBacked,
                freshnessState: .current,
                contradictionState: .none,
                evidence: .init(
                    anchorObjectIDs: [newAction.stableKey]
                )
            )
        )

        let targetMismatchProof = ProofReference(
            id: "target-mismatch-proof",
            kind: .link,
            title: "Wrong target proof",
            attachedObject: object(.action, "other-action", parent: goal.id, label: "Ignored"),
            capitalProfile: ProofCapitalProfile(
                sourceKind: .manual,
                sourceState: .sourceBacked,
                freshnessState: .current,
                contradictionState: .none,
                evidence: .init(
                    anchorObjectIDs: [oldAction.stableKey, newAction.stableKey],
                    proofReferenceIDs: ["proof-input-4"],
                    sourceReceiptIDs: ["receipt-4"]
                )
            )
        )

        let projection = ProofResourceGraphProjection(
            proofReferences: [preservedProof, reviewProof, contradictedProof, noOverlapProof, missingEvidenceProof, targetMismatchProof]
        )

        let report = projection.evaluatePivotPreservation(from: oldAction, to: newAction)

        XCTAssertEqual(Set(report.preservedProofIDs), ["preserved-proof"])
        XCTAssertEqual(Set(report.reviewRequiredProofIDs), ["review-proof"])
        XCTAssertEqual(Set(report.nonTransferableProofIDs), ["contradicted-proof", "missing-evidence-proof", "no-overlap-proof"])
        XCTAssertEqual(report.transferRecords.count, 5)
        XCTAssertEqual(report.transferRecords.first(where: { $0.proofID == "no-overlap-proof" })?.issues.contains(.missingOverlap), true)
        XCTAssertEqual(report.transferRecords.first(where: { $0.proofID == "contradicted-proof" })?.issues.contains(.contradictionConfirmed), true)
        XCTAssertEqual(report.transferRecords.first(where: { $0.proofID == "missing-evidence-proof" })?.outcome, .nonTransferable)
    }

    func testPivotTransferRequiresOverlapAndTrustEvidence() {
        let goal = object(.goal, "goal-2", label: "Goal with pivot")
        let sourceAction = object(.action, "source-action", parent: goal.id, label: "Pivot source")
        let destinationAction = object(.action, "destination-action", parent: goal.id, label: "Pivot destination")

        let proof = ProofReference(
            id: "pivot-proof",
            kind: .completedAction,
            title: "Pivot evidence proof",
            attachedObject: sourceAction,
            capitalProfile: ProofCapitalProfile(
                sourceKind: .actionReceipt,
                sourceState: .sourceBacked,
                freshnessState: .current,
                contradictionState: .none,
                evidence: .init(
                    anchorObjectIDs: [destinationAction.stableKey],
                    proofReferenceIDs: ["proof-reference-1"],
                    sourceReceiptIDs: ["proof-receipt-1"]
                )
            )
        )

        let projection = ProofResourceGraphProjection(proofReferences: [proof])

        let report = projection.evaluatePivotPreservation(from: sourceAction, to: destinationAction)
        let record = report.transferRecords.first

        XCTAssertEqual(report.preservedProofIDs, ["pivot-proof"])
        XCTAssertNotNil(record)
        XCTAssertEqual(record?.issues.contains(ProofCapitalTransferIssue.missingOverlap), false)
        XCTAssertEqual(record?.issues.contains(ProofCapitalTransferIssue.missingTrustEvidence), false)
        XCTAssertEqual(record?.issues.contains(ProofCapitalTransferIssue.sourceNeedReview), false)
    }

    func testLegacyProofReferenceDecodesWithDefaultProofCapitalProfile() throws {
        let data = Data(
            """
            {
              "id": "legacy-proof",
              "kind": "completed_action",
              "title": "Legacy proof",
              "attachedObject": {
                "kind": "action",
                "id": "legacy-action",
                "parentContextID": "legacy-goal",
                "label": "Legacy action",
                "sourceDomain": "goals"
              },
              "schemaVersion": "proof_resource_graph.native.v1"
            }
            """.utf8
        )

        let proof = try JSONDecoder().decode(ProofReference.self, from: data)

        XCTAssertEqual(proof.id, "legacy-proof")
        XCTAssertEqual(proof.capitalProfile.sourceKind, .manual)
        XCTAssertEqual(proof.capitalProfile.sourceState, .userStated)
        XCTAssertEqual(proof.capitalProfile.freshnessState, .notApplicable)
        XCTAssertEqual(proof.capitalProfile.contradictionState, .none)
        XCTAssertEqual(proof.capitalProfile.evidence, ProofCapitalEvidence())
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
