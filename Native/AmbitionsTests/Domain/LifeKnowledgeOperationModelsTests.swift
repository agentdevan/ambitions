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
            inspectionSummary: "You / What Ambitions knows can inspect this SourceRecord, Receipt, and ReplayTrace.",
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
        XCTAssertEqual(contextEntry.localInspectionSummary, "You / What Ambitions knows can inspect this SourceRecord, Receipt, and ReplayTrace.")
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
        XCTAssertEqual(replayTrace.decisionReceipt?.replayTraceLabel, "Replay trace stays inspectable")
        XCTAssertTrue(boundary.isInspectableBoundary)
        XCTAssertTrue(boundary.blocksRawActivityLogCopy)
    }

    func testLifeKnowledgeStoreDeletionRetainsStructuredExportShape() {
        let store = LifeKnowledgeOperationModels.Store(
            id: "store.life-knowledge.delete",
            inspectionSummary: "You / What Ambitions knows can inspect this SourceRecord, Receipt, and ReplayTrace.",
            createdAt: "2026-05-25T11:18:00Z",
            updatedAt: "2026-05-25T11:18:00Z"
        )
        let deleted = store.markedDeleted(at: "2026-05-25T11:19:00Z")

        XCTAssertTrue(deleted.isDeleted)
        XCTAssertFalse(deleted.canDelete)
        XCTAssertEqual(deleted.updatedAt, "2026-05-25T11:19:00Z")
        XCTAssertEqual(deleted.exportSnapshot.deletedAt, "2026-05-25T11:19:00Z")
        XCTAssertEqual(deleted.exportSnapshot.inspectionSummary, "You / What Ambitions knows can inspect this SourceRecord, Receipt, and ReplayTrace.")
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
            inspectionSummary: "You / What Ambitions knows can inspect this SourceRecord, Receipt, and ReplayTrace.",
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
        XCTAssertEqual(reset.exportSnapshot.sourceRecordIDs, [])
        XCTAssertEqual(reset.exportSnapshot.contextEntryIDs, [])
        XCTAssertEqual(reset.exportSnapshot.collectionIDs, [])
        XCTAssertEqual(reset.exportSnapshot.templateIDs, [])
        XCTAssertEqual(reset.exportSnapshot.decisionIDs, [])
        XCTAssertEqual(reset.exportSnapshot.resourceIDs, [])
        XCTAssertEqual(reset.exportSnapshot.personPlaceContextIDs, [])
        XCTAssertEqual(reset.exportSnapshot.reflectionIDs, [])
        XCTAssertNil(reset.exportSnapshot.deletedAt)
    }
}

private extension LifeKnowledgeOperationModelsTests {
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
