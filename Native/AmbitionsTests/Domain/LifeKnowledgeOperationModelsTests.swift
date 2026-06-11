import Foundation
import XCTest
@testable import Ambitions

final class LifeKnowledgeOperationModelsTests: XCTestCase {
    func testStructuredLifeKnowledgeRoundTripsSourceReceiptReplayAndInspectableSurfaceState() throws {
        let sourceRecord = SourceRecord(
            id: "source.life-knowledge.1",
            providerID: "provider.local",
            entityTitle: "Structured life knowledge capture",
            publisher: nil,
            locator: "local://life-knowledge/context-entry",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let receipt = ActionReceipt(
            id: "receipt.life-knowledge.1",
            resultState: .completed,
            title: "Life knowledge stored locally",
            summary: "Structured life knowledge stays local and inspectable.",
            sourceDomain: .you,
            occurredAt: "2026-05-25T11:18:00Z",
            affectedObjects: [
                LifeGraphObjectReference(
                    kind: .evidence,
                    id: sourceRecord.id,
                    label: sourceRecord.entityTitle,
                    sourceDomain: .you
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .evidence,
                id: sourceRecord.id,
                label: sourceRecord.entityTitle,
                sourceDomain: .you
            )
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(
            receipt: receipt,
            proofRelevance: .countsAsProof
        )
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        )
        let reflection = Reflection(
            id: "reflection.life-knowledge.1",
            ambitionID: "ambition.life-knowledge.1",
            proofID: proofLedgerEntry.proofReference?.id,
            closureEventID: nil,
            text: "What Ambitions knows keeps the local source, receipt, and replay trail visible.",
            learnedSignal: "structured_local_knowledge",
            createdAt: "2026-05-25T11:18:00Z"
        )
        let noteReference = ResourceReference(
            id: "resource.life-knowledge.note.1",
            kind: .note,
            title: "Launch note",
            locator: "local://life-knowledge/note/1",
            summary: "A local note stays searchable.",
            attachedObject: LifeGraphObjectReference(
                kind: .resource,
                id: "resource.life-knowledge.note.1",
                label: "Launch note",
                sourceDomain: .you
            ),
            sourceDomain: .you
        )
        let contextEntry = LifeKnowledgeOperationModels.ContextEntry(
            id: "context-entry.life-knowledge.1",
            kind: .contextEntry,
            title: "Launch note",
            summary: "Store a structured note entry with source, receipt, and replay.",
            body: "The note can be collected, templated, and replayed locally.",
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            templateID: "template.life-knowledge.1",
            collectionIDs: ["collection.life-knowledge.1"],
            resourceIDs: [noteReference.id],
            createdAt: "2026-05-25T11:18:00Z",
            updatedAt: "2026-05-25T11:18:00Z"
        )
        let collection = LifeKnowledgeOperationModels.Collection(
            id: "collection.life-knowledge.1",
            title: "Launch collection",
            summary: "Group the note and its related entries.",
            templateID: "template.life-knowledge.1",
            entryIDs: [contextEntry.id],
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            createdAt: "2026-05-25T11:18:00Z",
            updatedAt: "2026-05-25T11:18:00Z"
        )
        let template = LifeKnowledgeOperationModels.Template(
            id: "template.life-knowledge.1",
            title: "Structured note template",
            summary: "Capture structured note fields with local source proof.",
            entryKind: .contextEntry,
            fieldKeys: ["title", "summary", "body", "sourceRecords", "receipt", "replayTrace"],
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            createdAt: "2026-05-25T11:18:00Z",
            updatedAt: "2026-05-25T11:18:00Z"
        )
        let decision = LifeKnowledgeOperationModels.Decision(
            id: "decision.life-knowledge.1",
            title: "Use the structured note locally",
            summary: "A decision can carry the local source record and replay evidence.",
            contextEntryID: contextEntry.id,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            createdAt: "2026-05-25T11:18:00Z",
            updatedAt: "2026-05-25T11:18:00Z"
        )
        let resource = LifeKnowledgeOperationModels.Resource(
            id: "resource.life-knowledge.1",
            reference: noteReference,
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:18:00Z",
            updatedAt: "2026-05-25T11:18:00Z"
        )
        let personPlace = LifeKnowledgeOperationModels.PersonPlaceContext(
            id: "person-place.life-knowledge.1",
            kind: .person,
            label: "Alex",
            summary: "Person context stays local and source-controlled.",
            sourceRecord: sourceRecord,
            resourceIDs: [resource.id],
            createdAt: "2026-05-25T11:18:00Z",
            updatedAt: "2026-05-25T11:18:00Z"
        )
        let store = LifeKnowledgeOperationModels.Store(
            id: "store.life-knowledge.1",
            inspectionSummary: "You / What Ambitions knows can inspect this source, receipt, and reason.",
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            contextEntries: [contextEntry],
            collections: [collection],
            templates: [template],
            decisions: [decision],
            resources: [resource],
            personPlaceContexts: [personPlace],
            reflections: [reflection],
            createdAt: "2026-05-25T11:18:00Z",
            updatedAt: "2026-05-25T11:18:00Z"
        )
        let boundary = LifeKnowledgeOperationModels.InspectionBoundary(
            surfaceTitle: "What Ambitions knows",
            sourceKnowledgeLabel: "Life knowledge source records",
            allowsRawActivityLog: false
        )
        let snapshot = store.exportSnapshot()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let decoder = JSONDecoder()
        let encodedStore = try encoder.encode(store)
        let decodedStore = try decoder.decode(LifeKnowledgeOperationModels.Store.self, from: encodedStore)

        XCTAssertEqual(store.surfaceTitle, "What Ambitions knows")
        XCTAssertEqual(contextEntry.sourceSurfaceTitle, "What Ambitions knows")
        XCTAssertEqual(contextEntry.sourceRecordIDs, [sourceRecord.id])
        XCTAssertEqual(contextEntry.receiptID, receipt.id)
        XCTAssertEqual(contextEntry.replayTraceID, replayTrace.id)
        XCTAssertEqual(contextEntry.localInspectionSummary, "You / What Ambitions knows can inspect this source, receipt, and reason.")
        XCTAssertEqual(collection.entryIDs, [contextEntry.id])
        XCTAssertEqual(template.fieldKeys, ["body", "receipt", "replayTrace", "sourceRecords", "summary", "title"])
        XCTAssertEqual(decision.contextEntryID, contextEntry.id)
        XCTAssertEqual(resource.sourceRecord?.id, sourceRecord.id)
        XCTAssertEqual(personPlace.kind, .person)
        XCTAssertEqual(store.inspectionLabel, "What Ambitions knows")
        XCTAssertTrue(store.canDelete)
        XCTAssertFalse(store.isDeleted)
        XCTAssertEqual(snapshot.surfaceTitle, "What Ambitions knows")
        XCTAssertEqual(snapshot.sourceRecordIDs, [sourceRecord.id])
        XCTAssertEqual(snapshot.contextEntryIDs, [contextEntry.id])
        XCTAssertEqual(snapshot.collectionIDs, [collection.id])
        XCTAssertEqual(snapshot.templateIDs, [template.id])
        XCTAssertEqual(snapshot.decisionIDs, [decision.id])
        XCTAssertEqual(snapshot.resourceIDs, [resource.id])
        XCTAssertEqual(snapshot.personPlaceContextIDs, [personPlace.id])
        XCTAssertEqual(snapshot.reflectionIDs, [reflection.id])
        XCTAssertTrue(snapshot.isDeleted == false)
        XCTAssertEqual(decodedStore, store)
        XCTAssertEqual(replayTrace.state, .ready)
        XCTAssertTrue(replayTrace.isLocalOnly)
        XCTAssertTrue(replayTrace.isReplayable)
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordIDs, [receipt.id])
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordLabel, "Source record stays local")
        XCTAssertEqual(replayTrace.decisionReceipt?.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(boundary.isInspectableBoundary)
        XCTAssertTrue(boundary.blocksRawActivityLogCopy)
    }

    func testRelationBacklinksCoverLifeAreaGoalThreadCommitmentStepProofAndSourceTargets() throws {
        let sourceRecord = SourceRecord(
            id: "source.life-knowledge.relations",
            providerID: "provider.local",
            entityTitle: "Relations source note",
            publisher: nil,
            locator: "local://life-knowledge/relations",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let receipt = ActionReceipt(
            id: "receipt.life-knowledge.relations",
            resultState: .completed,
            title: "Relations stored locally",
            summary: "Notes, backlinks, and relation review state stay inspectable.",
            sourceDomain: .you,
            occurredAt: "2026-05-25T11:30:00Z",
            affectedObjects: [
                LifeGraphObjectReference(
                    kind: .resource,
                    id: sourceRecord.id,
                    label: sourceRecord.entityTitle,
                    sourceDomain: .you
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .evidence,
                id: sourceRecord.id,
                label: sourceRecord.entityTitle,
                sourceDomain: .you
            )
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(
            receipt: receipt,
            proofRelevance: .countsAsProof
        )
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        )
        let contextEntryID = "context-entry.life-knowledge.relations"
        let lifeAreaTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .lifeArea,
            id: "life-area.home",
            label: "Home"
        )
        let goalThreadTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .goalThread,
            id: "goal-thread.home-reset",
            label: "Reset the apartment"
        )
        let commitmentTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .commitment,
            id: "commitment.home-reset",
            label: "Home reset commitment",
            sourceDomain: .commitment
        )
        let stepTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .step,
            id: "step.home-reset",
            label: "Pack kitchen",
            sourceDomain: .goalEngine
        )
        let proofTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .proof,
            id: "proof.home-reset",
            label: "Receipt-backed proof",
            sourceDomain: .proof
        )
        let sourceTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .source,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let lifeAreaEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: contextEntryID,
            target: lifeAreaTarget,
            relationshipKind: .relatesTo,
            reviewState: .ready,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:30:00Z",
            updatedAt: "2026-05-25T11:30:00Z"
        )
        let goalThreadEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: contextEntryID,
            target: goalThreadTarget,
            relationshipKind: .supports,
            reviewState: .weak,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:31:00Z",
            updatedAt: "2026-05-25T11:31:00Z"
        )
        let commitmentEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: contextEntryID,
            target: commitmentTarget,
            relationshipKind: .dependsOn,
            reviewState: .needsReview,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:32:00Z",
            updatedAt: "2026-05-25T11:32:00Z"
        )
        let stepEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: contextEntryID,
            target: stepTarget,
            relationshipKind: .contains,
            reviewState: .ready,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:33:00Z",
            updatedAt: "2026-05-25T11:33:00Z"
        )
        let proofEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: contextEntryID,
            target: proofTarget,
            relationshipKind: .proves,
            reviewState: .ready,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:34:00Z",
            updatedAt: "2026-05-25T11:34:00Z"
        )
        let sourceEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: contextEntryID,
            target: sourceTarget,
            relationshipKind: .createdFrom,
            reviewState: .ready,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:35:00Z",
            updatedAt: "2026-05-25T11:35:00Z"
        )
        let contextEntry = LifeKnowledgeOperationModels.ContextEntry(
            id: contextEntryID,
            kind: .contextEntry,
            title: "Launch notes with backlinks",
            summary: "Relate notes to life objects and keep the backlink review state local.",
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            relationEdgeIDs: [
                lifeAreaEdge.id,
                goalThreadEdge.id,
                commitmentEdge.id,
                stepEdge.id,
                proofEdge.id,
                sourceEdge.id
            ],
            createdAt: "2026-05-25T11:30:00Z",
            updatedAt: "2026-05-25T11:35:00Z"
        )
        let store = LifeKnowledgeOperationModels.Store(
            id: "store.life-knowledge.relations",
            inspectionSummary: "You / What Ambitions knows can inspect this source, receipt, and reason.",
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            contextEntries: [contextEntry],
            relationEdges: [
                sourceEdge,
                proofEdge,
                stepEdge,
                commitmentEdge,
                goalThreadEdge,
                lifeAreaEdge
            ],
            createdAt: "2026-05-25T11:30:00Z",
            updatedAt: "2026-05-25T11:35:00Z"
        )
        let relationKinds = Set(LifeKnowledgeOperationModels.RelationTargetKind.allCases)

        XCTAssertEqual(
            relationKinds,
            [
                .lifeArea,
                .goalThread,
                .commitment,
                .step,
                .proof,
                .source
            ]
        )
        XCTAssertEqual(lifeAreaTarget.objectReference.kind, .lifeArea)
        XCTAssertEqual(goalThreadTarget.objectReference.kind, .goal)
        XCTAssertEqual(commitmentTarget.objectReference.kind, .commitment)
        XCTAssertEqual(stepTarget.objectReference.kind, .step)
        XCTAssertEqual(proofTarget.objectReference.kind, .proof)
        XCTAssertEqual(sourceTarget.objectReference.kind, .evidence)
        XCTAssertEqual(contextEntry.relationEdgeIDs.count, 6)
        XCTAssertEqual(Set(contextEntry.relationEdgeIDs), [
            lifeAreaEdge.id,
            goalThreadEdge.id,
            commitmentEdge.id,
            stepEdge.id,
            proofEdge.id,
            sourceEdge.id
        ])
        XCTAssertEqual(store.relationEdges(from: contextEntryID).map(\.id).count, 6)
        XCTAssertEqual(store.backlinks(to: lifeAreaTarget).edgeIDs, [lifeAreaEdge.id])
        XCTAssertEqual(store.backlinks(to: goalThreadTarget).weakEdgeIDs, [goalThreadEdge.id])
        XCTAssertEqual(store.backlinks(to: commitmentTarget).reviewRequiredEdgeIDs, [commitmentEdge.id])
        XCTAssertEqual(store.backlinks(to: stepTarget).strongEdgeIDs, [stepEdge.id])
        XCTAssertEqual(store.backlinks(to: proofTarget).edgeIDs, [proofEdge.id])
        XCTAssertEqual(store.backlinks(to: sourceTarget).edgeIDs, [sourceEdge.id])
        XCTAssertEqual(Set(store.exportSnapshot.relationEdgeIDs), [
            lifeAreaEdge.id,
            goalThreadEdge.id,
            commitmentEdge.id,
            stepEdge.id,
            proofEdge.id,
            sourceEdge.id
        ])
        XCTAssertTrue(store.backlinks(to: sourceTarget).hasBacklinks)
        XCTAssertTrue(store.reset(at: "2026-05-25T11:40:00Z").exportSnapshot.relationEdgeIDs.isEmpty)
    }

    func testLifeKnowledgeStoreDeletionRetainsStructuredExportShape() {
        let store = LifeKnowledgeOperationModels.Store(
            id: "store.life-knowledge.delete",
            inspectionSummary: "You / What Ambitions knows can inspect this source, receipt, and reason.",
            createdAt: "2026-05-25T11:18:00Z",
            updatedAt: "2026-05-25T11:18:00Z"
        )
        let deleted = store.markedDeleted(at: "2026-05-25T11:19:00Z")

        XCTAssertTrue(deleted.isDeleted)
        XCTAssertFalse(deleted.canDelete)
        XCTAssertEqual(deleted.updatedAt, "2026-05-25T11:19:00Z")
        XCTAssertEqual(deleted.exportSnapshot.deletedAt, "2026-05-25T11:19:00Z")
        XCTAssertEqual(deleted.exportSnapshot.inspectionSummary, "You / What Ambitions knows can inspect this source, receipt, and reason.")
    }

    func testLifeKnowledgeStoreResetClearsLocalPayloadWhilePreservingInspectableSurfaceIdentity() {
        let sourceRecord = SourceRecord(
            id: "source.life-knowledge.reset",
            providerID: "provider.local",
            entityTitle: "Resettable life knowledge",
            publisher: nil,
            locator: "local://life-knowledge/reset",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let store = LifeKnowledgeOperationModels.Store(
            id: "store.life-knowledge.reset",
            inspectionSummary: "You / What Ambitions knows can inspect this source, receipt, and reason.",
            sourceRecords: [sourceRecord],
            receipt: ActionReceipt(
                id: "receipt.life-knowledge.reset",
                resultState: .created,
                title: "Resettable life knowledge",
                summary: "Reset should clear local payload.",
                sourceDomain: .you,
                occurredAt: "2026-05-25T11:18:00Z",
                affectedObjects: [
                    LifeGraphObjectReference(
                        kind: .resource,
                        id: sourceRecord.id,
                        label: sourceRecord.entityTitle,
                        sourceDomain: .you
                    )
                ]
            ),
            replayTrace: makeReplayTrace(
                sourceRecordID: sourceRecord.id,
                receiptID: "receipt.life-knowledge.reset",
                proofReferenceID: "proof.life-knowledge.reset"
            ),
            contextEntries: [
                LifeKnowledgeOperationModels.ContextEntry(
                    id: "context-entry.life-knowledge.reset",
                    kind: .contextEntry,
                    title: "Resettable entry",
                    summary: "Will be cleared by reset.",
                    sourceRecords: [sourceRecord],
                    createdAt: "2026-05-25T11:18:00Z",
                    updatedAt: "2026-05-25T11:18:00Z"
                )
            ],
            collections: [
                LifeKnowledgeOperationModels.Collection(
                    id: "collection.life-knowledge.reset",
                    title: "Resettable collection",
                    summary: "Will be cleared by reset.",
                    entryIDs: ["context-entry.life-knowledge.reset"],
                    createdAt: "2026-05-25T11:18:00Z",
                    updatedAt: "2026-05-25T11:18:00Z"
                )
            ],
            templates: [
                LifeKnowledgeOperationModels.Template(
                    id: "template.life-knowledge.reset",
                    title: "Resettable template",
                    summary: "Will be cleared by reset.",
                    entryKind: .contextEntry,
                    createdAt: "2026-05-25T11:18:00Z",
                    updatedAt: "2026-05-25T11:18:00Z"
                )
            ],
            decisions: [
                LifeKnowledgeOperationModels.Decision(
                    id: "decision.life-knowledge.reset",
                    title: "Resettable decision",
                    summary: "Will be cleared by reset.",
                    contextEntryID: "context-entry.life-knowledge.reset",
                    createdAt: "2026-05-25T11:18:00Z",
                    updatedAt: "2026-05-25T11:18:00Z"
                )
            ],
            resources: [
                LifeKnowledgeOperationModels.Resource(
                    id: "resource.life-knowledge.reset",
                    reference: ResourceReference(
                        id: "resource.life-knowledge.reset",
                        kind: .note,
                        title: "Resettable resource",
                        locator: "local://life-knowledge/reset/resource",
                        summary: "Will be cleared by reset.",
                        attachedObject: LifeGraphObjectReference(
                            kind: .resource,
                            id: "resource.life-knowledge.reset",
                            label: "Resettable resource",
                            sourceDomain: .you
                        ),
                        sourceDomain: .you
                    ),
                    sourceRecord: sourceRecord,
                    createdAt: "2026-05-25T11:18:00Z",
                    updatedAt: "2026-05-25T11:18:00Z"
                )
            ],
            personPlaceContexts: [
                LifeKnowledgeOperationModels.PersonPlaceContext(
                    id: "person-place.life-knowledge.reset",
                    kind: .person,
                    label: "Alex",
                    summary: "Will be cleared by reset.",
                    sourceRecord: sourceRecord,
                    createdAt: "2026-05-25T11:18:00Z",
                    updatedAt: "2026-05-25T11:18:00Z"
                )
            ],
            reflections: [
                LifeKnowledgeOperationModels.Reflection(
                    id: "reflection.life-knowledge.reset",
                    ambitionID: "ambition.life-knowledge.reset",
                    proofID: nil,
                    closureEventID: nil,
                    text: "Will be cleared by reset.",
                    learnedSignal: "resettable_local_knowledge",
                    createdAt: "2026-05-25T11:18:00Z"
                )
            ],
            createdAt: "2026-05-25T11:18:00Z",
            updatedAt: "2026-05-25T11:18:00Z"
        )

        let reset = store.reset(at: "2026-05-25T11:20:00Z")

        XCTAssertFalse(reset.isDeleted)
        XCTAssertTrue(reset.canDelete)
        XCTAssertEqual(reset.updatedAt, "2026-05-25T11:20:00Z")
        XCTAssertEqual(reset.surfaceTitle, store.surfaceTitle)
        XCTAssertEqual(reset.inspectionSummary, store.inspectionSummary)
        XCTAssertTrue(reset.sourceRecords.isEmpty)
        XCTAssertNil(reset.receipt)
        XCTAssertNil(reset.replayTrace)
        XCTAssertTrue(reset.contextEntries.isEmpty)
        XCTAssertTrue(reset.collections.isEmpty)
        XCTAssertTrue(reset.templates.isEmpty)
        XCTAssertTrue(reset.decisions.isEmpty)
        XCTAssertTrue(reset.resources.isEmpty)
        XCTAssertTrue(reset.personPlaceContexts.isEmpty)
        XCTAssertTrue(reset.reflections.isEmpty)
        XCTAssertTrue(reset.relationEdges.isEmpty)
        XCTAssertEqual(reset.exportSnapshot.sourceRecordIDs, [])
        XCTAssertEqual(reset.exportSnapshot.contextEntryIDs, [])
        XCTAssertEqual(reset.exportSnapshot.collectionIDs, [])
        XCTAssertEqual(reset.exportSnapshot.templateIDs, [])
        XCTAssertEqual(reset.exportSnapshot.decisionIDs, [])
        XCTAssertEqual(reset.exportSnapshot.resourceIDs, [])
        XCTAssertEqual(reset.exportSnapshot.personPlaceContextIDs, [])
        XCTAssertEqual(reset.exportSnapshot.reflectionIDs, [])
        XCTAssertEqual(reset.exportSnapshot.relationEdgeIDs, [])
        XCTAssertNil(reset.exportSnapshot.deletedAt)
    }

    func testLifeKnowledgeStoreSearchFiltersByTypeSourceLifeAreaGoalThreadProofSensitivityReviewStateAndDate() throws {
        let store = try makeLifeKnowledgeSearchFilterStore()
        let search = store.search(
            query: LifeKnowledgeOperationModels.SearchQuery(
                searchText: "launch note",
                filters: LifeKnowledgeOperationModels.SearchFilters(
                    itemKinds: [.contextEntry],
                    lifeAreaIDs: ["life-area.home"],
                    goalThreadIDs: ["goal-thread.home-reset"],
                    sourceRecordIDs: ["source.life-knowledge.search.official"],
                    proofOnly: true,
                    sensitivity: .open,
                    reviewState: .ready,
                    dateFilter: LifeKnowledgeOperationModels.SearchDateFilter(
                        createdAfter: "2026-05-25T00:00:00Z",
                        createdBefore: "2026-05-25T23:59:59Z",
                        updatedAfter: "2026-05-25T00:00:00Z",
                        updatedBefore: "2026-05-25T23:59:59Z"
                    )
                ),
                performanceBudget: LifeKnowledgeOperationModels.SearchPerformanceBudget(
                    maximumCandidates: 6,
                    maximumResults: 3,
                    maximumTextTokens: 4
                )
            )
        )

        XCTAssertEqual(search.scannedCandidateCount, 6)
        XCTAssertEqual(search.matchedCandidateCount, 1)
        XCTAssertEqual(search.returnedItemCount, 1)
        XCTAssertTrue(search.hitPerformanceBudget)
        XCTAssertEqual(search.items.map(\.id), ["context-entry.life-knowledge.search.newer"])
        XCTAssertEqual(search.items.first?.kind, .contextEntry)
        XCTAssertEqual(search.items.first?.title, "Launch note")
        XCTAssertEqual(search.items.first?.matchedTerms, ["launch", "note"])
        XCTAssertEqual(search.items.first?.reviewState, .ready)
        XCTAssertEqual(search.items.first?.sensitivity, .open)
        XCTAssertEqual(
            search.performanceBudgetSummary,
            "Scanned 6 of 13 candidate items; matched 1; returned 1 within a 6-candidate / 3-result budget."
        )

        let sensitiveSearch = store.search(
            query: LifeKnowledgeOperationModels.SearchQuery(
                filters: LifeKnowledgeOperationModels.SearchFilters(
                    itemKinds: [.resource],
                    sensitivity: .sensitive
                ),
                performanceBudget: LifeKnowledgeOperationModels.SearchPerformanceBudget(
                    maximumCandidates: 20,
                    maximumResults: 5
                )
            )
        )

        XCTAssertEqual(sensitiveSearch.items.map(\.id), ["resource.life-knowledge.search.private"])
        XCTAssertEqual(sensitiveSearch.items.first?.sensitivity, .sensitive)

        let reviewRequiredSearch = store.search(
            query: LifeKnowledgeOperationModels.SearchQuery(
                filters: LifeKnowledgeOperationModels.SearchFilters(
                    itemKinds: [.placeContext],
                    sensitivity: .reviewRequired,
                    reviewState: .needsReview
                ),
                performanceBudget: LifeKnowledgeOperationModels.SearchPerformanceBudget(
                    maximumCandidates: 20,
                    maximumResults: 5
                )
            )
        )

        XCTAssertEqual(reviewRequiredSearch.items.map(\.id), ["place-context.life-knowledge.search.review-required"])
        XCTAssertEqual(reviewRequiredSearch.items.first?.reviewState, .needsReview)
        XCTAssertEqual(reviewRequiredSearch.items.first?.sensitivity, .reviewRequired)

        let weakRelationSearch = store.search(
            query: LifeKnowledgeOperationModels.SearchQuery(
                filters: LifeKnowledgeOperationModels.SearchFilters(
                    itemKinds: [.relationEdge],
                    reviewState: .weak
                ),
                performanceBudget: LifeKnowledgeOperationModels.SearchPerformanceBudget(
                    maximumCandidates: 20,
                    maximumResults: 5
                )
            )
        )

        XCTAssertEqual(weakRelationSearch.items.map(\.id), ["relation-edge.life-knowledge.search.weak"])
        XCTAssertEqual(weakRelationSearch.items.first?.reviewState, .weak)

        let proofOnlySearch = store.search(
            query: LifeKnowledgeOperationModels.SearchQuery(
                filters: LifeKnowledgeOperationModels.SearchFilters(
                    itemKinds: [.reflection],
                    proofOnly: true
                ),
                performanceBudget: LifeKnowledgeOperationModels.SearchPerformanceBudget(
                    maximumCandidates: 20,
                    maximumResults: 5
                )
            )
        )

        XCTAssertEqual(proofOnlySearch.items.map(\.id), ["reflection.life-knowledge.search.proof"])
        XCTAssertTrue(proofOnlySearch.items.first?.hasProof ?? false)

        let dateFilteredSearch = store.search(
            query: LifeKnowledgeOperationModels.SearchQuery(
                filters: LifeKnowledgeOperationModels.SearchFilters(
                    itemKinds: [.contextEntry],
                    dateFilter: LifeKnowledgeOperationModels.SearchDateFilter(
                        createdAfter: "2026-05-25T00:00:00Z"
                    )
                ),
                performanceBudget: LifeKnowledgeOperationModels.SearchPerformanceBudget(
                    maximumCandidates: 20,
                    maximumResults: 5
                )
            )
        )

        XCTAssertEqual(dateFilteredSearch.items.map(\.id), [
            "context-entry.life-knowledge.search.newer",
            "context-entry.life-knowledge.search.relation"
        ])
    }

    func testLifeKnowledgeStoreSearchRanksByRankingValueThenUpdatedAtThenTitleThenID() throws {
        let store = try makeLifeKnowledgeSearchRankingStore()
        let search = store.search(
            query: LifeKnowledgeOperationModels.SearchQuery(
                searchText: "launch",
                filters: LifeKnowledgeOperationModels.SearchFilters(
                    itemKinds: [.collection]
                ),
                performanceBudget: LifeKnowledgeOperationModels.SearchPerformanceBudget(
                    maximumCandidates: 10,
                    maximumResults: 10
                )
            )
        )

        XCTAssertEqual(search.items.map(\.id), [
            "collection.life-knowledge.search.alpha",
            "collection.life-knowledge.search.beta"
        ])
        XCTAssertEqual(search.items.first?.matchedTerms, ["launch"])
        XCTAssertGreaterThanOrEqual(search.items.first?.rankingValue ?? 0, search.items.dropFirst().first?.rankingValue ?? 0)
        XCTAssertEqual(search.returnedItemCount, 2)
        XCTAssertFalse(search.hitPerformanceBudget)
    }
}

private extension LifeKnowledgeOperationModelsTests {
    func makeLifeKnowledgeSearchFilterStore() throws -> LifeKnowledgeOperationModels.Store {
        let officialSourceRecord = SourceRecord(
            id: "source.life-knowledge.search.official",
            providerID: "provider.local",
            entityTitle: "Official launch note",
            publisher: "Ambitions",
            locator: "local://life-knowledge/search/official",
            provenanceKind: .official,
            isOfficial: true
        )
        let privateSourceRecord = SourceRecord(
            id: "source.life-knowledge.search.private",
            providerID: "provider.local",
            entityTitle: "Private launch note",
            publisher: nil,
            locator: "local://life-knowledge/search/private",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let receipt = ActionReceipt(
            id: "receipt.life-knowledge.search.1",
            resultState: .completed,
            title: "Launch note stored locally",
            summary: "Life knowledge remains inspectable and local.",
            sourceDomain: .you,
            occurredAt: "2026-05-25T11:33:00Z",
            affectedObjects: [
                LifeGraphObjectReference(
                    kind: .evidence,
                    id: officialSourceRecord.id,
                    label: officialSourceRecord.entityTitle,
                    sourceDomain: .you
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .evidence,
                id: officialSourceRecord.id,
                label: officialSourceRecord.entityTitle,
                sourceDomain: .you
            )
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(
            receipt: receipt,
            proofRelevance: .countsAsProof
        )
        let proofReferenceID = try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        let replayTrace = makeReplayTrace(
            sourceRecordID: officialSourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: proofReferenceID
        )
        let reflection = Reflection(
            id: "reflection.life-knowledge.search.proof",
            ambitionID: "ambition.life-knowledge.search",
            proofID: proofReferenceID,
            closureEventID: nil,
            text: "What Ambitions knows keeps the launch note visible.",
            learnedSignal: "launch_note_visible",
            createdAt: "2026-05-25T11:34:00Z"
        )
        let newerContextEntry = LifeKnowledgeOperationModels.ContextEntry(
            id: "context-entry.life-knowledge.search.newer",
            kind: .contextEntry,
            title: "Launch note",
            summary: "Track the launch note locally.",
            body: "The launch note is searchable by life area, goal thread, source, proof, review state, and date.",
            sourceRecords: [officialSourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            templateID: "template.life-knowledge.search.1",
            collectionIDs: ["collection.life-knowledge.search.1"],
            resourceIDs: ["resource.life-knowledge.search.private"],
            relationEdgeIDs: [
                "relation-edge.life-knowledge.search.ready.life-area",
                "relation-edge.life-knowledge.search.ready.goal-thread"
            ],
            createdAt: "2026-05-25T11:40:00Z",
            updatedAt: "2026-05-25T11:40:00Z"
        )
        let relationContextEntry = LifeKnowledgeOperationModels.ContextEntry(
            id: "context-entry.life-knowledge.search.relation",
            kind: .contextEntry,
            title: "Backlink review note",
            summary: "Review the local backlinks before publishing a note.",
            body: "This note keeps weak and review-required relation edges inspectable.",
            sourceRecords: [officialSourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            relationEdgeIDs: [
                "relation-edge.life-knowledge.search.weak",
                "relation-edge.life-knowledge.search.needs-review"
            ],
            createdAt: "2026-05-25T11:33:00Z",
            updatedAt: "2026-05-25T11:33:00Z"
        )
        let olderContextEntry = LifeKnowledgeOperationModels.ContextEntry(
            id: "context-entry.life-knowledge.search.older",
            kind: .contextEntry,
            title: "Archive note",
            summary: "Older note that should fall outside the date filter.",
            body: "This older note stays local and inspectable.",
            sourceRecords: [officialSourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-24T11:00:00Z",
            updatedAt: "2026-05-24T11:00:00Z"
        )
        let collection = LifeKnowledgeOperationModels.Collection(
            id: "collection.life-knowledge.search.1",
            title: "Launch collection",
            summary: "Group the launch note and related entries.",
            templateID: "template.life-knowledge.search.1",
            entryIDs: [newerContextEntry.id, olderContextEntry.id],
            sourceRecords: [officialSourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            createdAt: "2026-05-25T11:35:00Z",
            updatedAt: "2026-05-25T11:35:00Z"
        )
        let template = LifeKnowledgeOperationModels.Template(
            id: "template.life-knowledge.search.1",
            title: "Structured note template",
            summary: "Capture structured note fields locally.",
            entryKind: .contextEntry,
            fieldKeys: ["title", "summary", "body", "sourceRecords", "receipt", "replayTrace"],
            sourceRecords: [officialSourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            createdAt: "2026-05-25T11:36:00Z",
            updatedAt: "2026-05-25T11:36:00Z"
        )
        let decision = LifeKnowledgeOperationModels.Decision(
            id: "decision.life-knowledge.search.1",
            title: "Use the launch note locally",
            summary: "Keep the launch note inspectable.",
            contextEntryID: newerContextEntry.id,
            sourceRecords: [officialSourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            createdAt: "2026-05-25T11:37:00Z",
            updatedAt: "2026-05-25T11:37:00Z"
        )
        let resource = LifeKnowledgeOperationModels.Resource(
            id: "resource.life-knowledge.search.private",
            reference: ResourceReference(
                id: "resource.life-knowledge.search.private",
                kind: .note,
                title: "Private launch note",
                locator: "local://life-knowledge/search/private",
                summary: "Sensitive resource",
                attachedObject: LifeGraphObjectReference(
                    kind: .resource,
                    id: "resource.life-knowledge.search.private",
                    label: "Private launch note",
                    sourceDomain: .you
                ),
                sourceDomain: .you
            ),
            sourceRecord: privateSourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:38:00Z",
            updatedAt: "2026-05-25T11:38:00Z"
        )
        let placeContext = LifeKnowledgeOperationModels.PersonPlaceContext(
            id: "place-context.life-knowledge.search.review-required",
            kind: .place,
            label: "Archive desk",
            summary: "A local place context with no source record needs review.",
            sourceRecord: nil,
            resourceIDs: [resource.id],
            createdAt: "2026-05-25T11:39:00Z",
            updatedAt: "2026-05-25T11:39:00Z"
        )
        let readyLifeAreaEdge = LifeKnowledgeOperationModels.RelationEdge(
            id: "relation-edge.life-knowledge.search.ready.life-area",
            sourceContextEntryID: newerContextEntry.id,
            target: LifeKnowledgeOperationModels.RelationTargetReference(
                kind: .lifeArea,
                id: "life-area.home",
                label: "Home"
            ),
            relationshipKind: .relatesTo,
            reviewState: .ready,
            sourceRecords: [officialSourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:40:00Z",
            updatedAt: "2026-05-25T11:40:00Z"
        )
        let readyGoalThreadEdge = LifeKnowledgeOperationModels.RelationEdge(
            id: "relation-edge.life-knowledge.search.ready.goal-thread",
            sourceContextEntryID: newerContextEntry.id,
            target: LifeKnowledgeOperationModels.RelationTargetReference(
                kind: .goalThread,
                id: "goal-thread.home-reset",
                label: "Reset the apartment"
            ),
            relationshipKind: .supports,
            reviewState: .ready,
            sourceRecords: [officialSourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:40:30Z",
            updatedAt: "2026-05-25T11:40:30Z"
        )
        let weakRelationEdge = LifeKnowledgeOperationModels.RelationEdge(
            id: "relation-edge.life-knowledge.search.weak",
            sourceContextEntryID: relationContextEntry.id,
            target: LifeKnowledgeOperationModels.RelationTargetReference(
                kind: .step,
                id: "step.life-knowledge.search.weak",
                label: "Review the launch note"
            ),
            relationshipKind: .contains,
            reviewState: .weak,
            sourceRecords: [officialSourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:33:30Z",
            updatedAt: "2026-05-25T11:33:30Z"
        )
        let needsReviewRelationEdge = LifeKnowledgeOperationModels.RelationEdge(
            id: "relation-edge.life-knowledge.search.needs-review",
            sourceContextEntryID: relationContextEntry.id,
            target: LifeKnowledgeOperationModels.RelationTargetReference(
                kind: .commitment,
                id: "commitment.life-knowledge.search.review",
                label: "Keep the note local"
            ),
            relationshipKind: .dependsOn,
            reviewState: .needsReview,
            sourceRecords: [officialSourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: "2026-05-25T11:33:45Z",
            updatedAt: "2026-05-25T11:33:45Z"
        )

        return LifeKnowledgeOperationModels.Store(
            id: "store.life-knowledge.search",
            inspectionSummary: "You / What Ambitions knows can inspect this source, receipt, and reason.",
            sourceRecords: [officialSourceRecord, privateSourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            contextEntries: [newerContextEntry, relationContextEntry, olderContextEntry],
            collections: [collection],
            templates: [template],
            decisions: [decision],
            resources: [resource],
            personPlaceContexts: [placeContext],
            reflections: [reflection],
            relationEdges: [
                readyGoalThreadEdge,
                readyLifeAreaEdge,
                weakRelationEdge,
                needsReviewRelationEdge
            ],
            createdAt: "2026-05-25T11:40:00Z",
            updatedAt: "2026-05-25T11:40:30Z"
        )
    }

    func makeLifeKnowledgeSearchRankingStore() throws -> LifeKnowledgeOperationModels.Store {
        let officialSourceRecord = SourceRecord(
            id: "source.life-knowledge.search.ranking",
            providerID: "provider.local",
            entityTitle: "Ranking source note",
            publisher: "Ambitions",
            locator: "local://life-knowledge/search/ranking",
            provenanceKind: .official,
            isOfficial: true
        )
        return LifeKnowledgeOperationModels.Store(
            id: "store.life-knowledge.search.ranking",
            inspectionSummary: "You / What Ambitions knows can inspect this source, receipt, and reason.",
            sourceRecords: [officialSourceRecord],
            contextEntries: [
                LifeKnowledgeOperationModels.ContextEntry(
                    id: "context-entry.life-knowledge.search.ranking.alpha",
                    kind: .contextEntry,
                    title: "Launch Alpha",
                    summary: "Ranking alpha summary.",
                    sourceRecords: [officialSourceRecord],
                    createdAt: "2026-05-25T09:00:00Z",
                    updatedAt: "2026-05-25T12:00:00Z"
                ),
                LifeKnowledgeOperationModels.ContextEntry(
                    id: "context-entry.life-knowledge.search.ranking.beta",
                    kind: .contextEntry,
                    title: "Launch Beta",
                    summary: "Ranking beta summary.",
                    sourceRecords: [officialSourceRecord],
                    createdAt: "2026-05-25T09:00:00Z",
                    updatedAt: "2026-05-25T12:00:00Z"
                )
            ],
            collections: [
                LifeKnowledgeOperationModels.Collection(
                    id: "collection.life-knowledge.search.beta",
                    title: "Launch Beta",
                    summary: "Ranking beta summary.",
                    sourceRecords: [officialSourceRecord],
                    createdAt: "2026-05-25T09:00:00Z",
                    updatedAt: "2026-05-25T12:00:00Z"
                ),
                LifeKnowledgeOperationModels.Collection(
                    id: "collection.life-knowledge.search.alpha",
                    title: "Launch Alpha",
                    summary: "Ranking alpha summary.",
                    sourceRecords: [officialSourceRecord],
                    createdAt: "2026-05-25T09:00:00Z",
                    updatedAt: "2026-05-25T12:00:00Z"
                )
            ],
            createdAt: "2026-05-25T12:00:00Z",
            updatedAt: "2026-05-25T12:00:00Z"
        )
    }

    func makeReplayTrace(
        sourceRecordID: String,
        receiptID: String,
        proofReferenceID: String
    ) -> ReplayTrace {
        let runtimeContext = RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Life knowledge remains local-only."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Structured life knowledge stays on device.",
                    runtimeTrustPosture: .localOnly
                )
            ],
            memorySummary: RuntimeMemorySummary(
                memory: RuntimeMemorySnapshot(
                    goals: [],
                    drafts: [],
                    evidence: [],
                    feedback: [],
                    captures: [],
                    appState: .default
                )
            ),
            externalSurfaceSnapshot: nil
        )
        let traceContext = PrivateLifeRuntimeKernelTraceContext(runtimeContext: runtimeContext)
        let recommendationTrace = RecommendationTrace(
            id: "trace.life-knowledge.1",
            recommendationID: "recommendation.life-knowledge.1",
            source: RecommendationTraceSource(
                citedSourceIDs: [sourceRecordID],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .memoryEvent],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.life-knowledge.1",
                summary: "Structured life knowledge stays inspectable through source, receipt, and replay.",
                evidenceCategoryIDs: ["memory_event", "source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.life-knowledge.1"],
                summaries: ["Life knowledge requires user-controlled source use."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct.life-knowledge"],
                controlActionIDs: ["open", "collect", "delete"],
                correctableFieldKeys: ["sourceRecord", "receipt", "replayTrace"],
                hasRequiredControl: true
            ),
            receiptBehavior: RecommendationTraceReceiptBehavior.available(
                receiptIDs: [receiptID],
                actionReceiptIDs: [receiptID],
                proofReferenceIDs: [proofReferenceID]
            )
        )

        return PrivateLifeRuntimeKernel().makeReplayableDecisionTrace(
            PrivateLifeRuntimeKernelDecisionInput(
                traceContext: traceContext,
                decisionKey: "life-knowledge.store",
                goalText: "Store structured life knowledge locally.",
                recommendationTrace: recommendationTrace
            )
        )
    }
}
