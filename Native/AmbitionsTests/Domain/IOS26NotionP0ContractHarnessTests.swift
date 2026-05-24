import Foundation
import XCTest
@testable import Ambitions

final class IOS26NotionP0ContractHarnessTests: XCTestCase {
    func testHarnessBlocksBroadReplacementClaimsWhileNotionEvidenceIsMissing() {
        let harness = NotionP0ContractHarnessFixture(
            notesEvidence: false,
            collectionsEvidence: false,
            templatesEvidence: false,
            relationsBacklinksEvidence: false,
            localSearchEvidence: false,
            noteConversionEvidence: false,
            attachmentsLinksEvidence: false,
            exportDeleteEvidence: false,
            sourceRecordEvidence: false,
            receiptEvidence: false,
            replayTraceEvidence: false,
            youInspectionBoundaryEvidence: false,
            unsupportedClaims: NotionP0ContractHarnessFixture.forbiddenBroadClaims
        )

        XCTAssertEqual(
            harness.missingEvidence,
            [
                "notes",
                "collections",
                "templates",
                "relations/backlinks",
                "local search",
                "note-to-object conversion",
                "attachments/links",
                "export/delete",
                "source record",
                "receipt",
                "replay trace",
                "You inspection boundary",
            ]
        )
        XCTAssertTrue(harness.blocksBroadReplacementClaims)
        XCTAssertFalse(harness.allEvidencePresent)
        XCTAssertEqual(Set(harness.blockedClaims), Set(NotionP0ContractHarnessFixture.forbiddenBroadClaims))
    }

    func testNotionReplacementEvidenceStaysLocalAndInspectableThroughSourceReceiptReplayAndYouSeams() throws {
        let sourceRecord = KnowledgeSourceRecord(
            id: "source.notion.1",
            providerID: "provider.local",
            entityTitle: "Notion launch note contract",
            publisher: nil,
            locator: "local://notion/p0",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let noteObject = LifeGraphObjectReference(
            kind: .resource,
            id: "notion.note.1",
            label: "Launch notes",
            sourceDomain: .you
        )
        let collectionObject = LifeGraphObjectReference(
            kind: .resource,
            id: "notion.collection.1",
            label: "Launch collection",
            sourceDomain: .you
        )
        let templateObject = LifeGraphObjectReference(
            kind: .resource,
            id: "notion.template.1",
            label: "Launch template",
            sourceDomain: .you
        )
        let convertedObject = LifeGraphObjectReference(
            kind: .step,
            id: "notion.step.1",
            label: "Launch checklist",
            sourceDomain: .today
        )
        let noteResource = ResourceReference(
            id: "resource.notion.note.1",
            kind: .note,
            title: "Launch notes",
            locator: "local://notion/note/launch",
            summary: "The note stays local and searchable.",
            attachedObject: noteObject,
            sourceDomain: .you
        )
        let collectionResource = ResourceReference(
            id: "resource.notion.collection.1",
            kind: .projectArtifact,
            title: "Launch collection",
            locator: "local://notion/collection/launch",
            summary: "The collection stays local and backlinkable.",
            attachedObject: collectionObject,
            sourceDomain: .you
        )
        let templateResource = ResourceReference(
            id: "resource.notion.template.1",
            kind: .checklistTemplate,
            title: "Launch template",
            locator: "local://notion/template/launch",
            summary: "The template stays local and reusable.",
            attachedObject: templateObject,
            sourceDomain: .you
        )
        let resourceProjection = ProofResourceGraphProjection(
            resourceReferences: [noteResource, collectionResource, templateResource]
        )
        let searchResults = [noteResource, collectionResource, templateResource].filter {
            $0.title.localizedCaseInsensitiveContains("Launch")
        }
        let receipt = ActionReceipt(
            id: "receipt.notion.1",
            resultState: .completed,
            title: "Notion note converted locally",
            summary: "Notes, collections, templates, relations, search, export/delete, and replay stay local.",
            sourceDomain: .proof,
            occurredAt: "2026-05-24T12:15:00Z",
            affectedObjects: [convertedObject],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(
            receipt: receipt,
            proofRelevance: .countsAsProof
        )
        let proofReference = try XCTUnwrap(proofLedgerEntry.proofReference)
        let proofProjection = ProofResourceGraphProjection(
            proofReferences: [proofReference],
            resourceReferences: [noteResource, collectionResource, templateResource]
        )
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: proofReference.id
        )
        let parser = NotificationResponsePayloadParser()
        let payload = parser.payload(
            actionIdentifier: AppNotificationConstants.openActionID,
            userInfo: [
                "sourceRecordID": sourceRecord.id,
                "surface": "What Ambitions knows",
            ]
        )
        let youBoundary = NotionYouInspectionBoundary(
            surfaceTitle: "What Ambitions knows",
            sourceKnowledgeLabel: "Notion source knowledge",
            allowsRawActivityLog: false
        )

        XCTAssertEqual(sourceRecord.locator, "local://notion/p0")
        XCTAssertEqual(noteResource.kind, .note)
        XCTAssertEqual(collectionResource.kind, .projectArtifact)
        XCTAssertEqual(templateResource.kind, .checklistTemplate)
        XCTAssertEqual(searchResults.map(\.id), [
            noteResource.id,
            collectionResource.id,
            templateResource.id,
        ])
        XCTAssertEqual(resourceProjection.resources(attachedTo: noteObject).map(\.id), [noteResource.id])
        XCTAssertEqual(resourceProjection.resources(attachedTo: collectionObject).map(\.id), [collectionResource.id])
        XCTAssertEqual(resourceProjection.resources(attachedTo: templateObject).map(\.id), [templateResource.id])
        XCTAssertEqual(Set(resourceProjection.relationshipProjection(for: noteObject).relationships.map(\.kind)), [.attachedTo])
        XCTAssertEqual(Set(resourceProjection.relationshipProjection(for: collectionObject).relationships.map(\.kind)), [.attachedTo])
        XCTAssertEqual(Set(resourceProjection.relationshipProjection(for: templateObject).relationships.map(\.kind)), [.attachedTo])
        XCTAssertEqual(receipt.sourceObject?.id, sourceRecord.id)
        XCTAssertEqual(proofLedgerEntry.sourceObjectID, sourceRecord.id)
        XCTAssertEqual(proofLedgerEntry.sourceRecordLabel, "Source record is source-tied")
        XCTAssertEqual(proofLedgerEntry.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(proofLedgerEntry.hasProofBridge)
        XCTAssertEqual(proofReference.attachedObject.id, convertedObject.id)
        XCTAssertEqual(proofProjection.relationshipProjection(for: convertedObject).relationships.count, 1)
        XCTAssertEqual(Set(proofProjection.relationshipProjection(for: convertedObject).relationships.map(\.kind)), [.proves])
        XCTAssertEqual(replayTrace.state, .ready)
        XCTAssertTrue(replayTrace.isReplayable)
        XCTAssertTrue(replayTrace.isLocalOnly)
        XCTAssertEqual(replayTrace.recommendation?.receipt.proofReferenceIDs, [proofReference.id])
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordIDs, [receipt.id])
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordLabel, "Source record stays local")
        XCTAssertEqual(replayTrace.decisionReceipt?.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(replayTrace.decisionReceipt?.hasProofBridge ?? false)
        XCTAssertEqual(payload?.action, "open")
        XCTAssertEqual(payload?.values["sourceRecordID"], sourceRecord.id)
        XCTAssertEqual(payload?.values["surface"], "What Ambitions knows")
        XCTAssertEqual(youBoundary.surfaceTitle, "What Ambitions knows")
        XCTAssertEqual(youBoundary.inspectionLabel, "What Ambitions knows")
        XCTAssertTrue(youBoundary.blocksRawActivityLogCopy)
        XCTAssertTrue(youBoundary.isInspectableBoundary)
    }

    private func makeReplayTrace(
        sourceRecordID: String,
        receiptID: String,
        proofReferenceID: String
    ) -> ReplayableDecisionTrace {
        let runtimeContext = RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Notion replacement evidence remains local-only."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Notion evidence stays on device.",
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
            id: "trace.notion.1",
            recommendationID: "recommendation.notion.1",
            source: RecommendationTraceSource(
                citedSourceIDs: [sourceRecordID],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .memoryEvent],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.notion.1",
                summary: "Notion note, receipt, and replay stay local and inspectable.",
                evidenceCategoryIDs: ["memory_event", "source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.notion.1"],
                summaries: ["Notion source knowledge is reviewed in You."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct.notion"],
                controlActionIDs: ["open", "export", "delete"],
                correctableFieldKeys: ["receipt", "replayTrace", "sourceRecord"],
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
                decisionKey: "notion.p0.contract",
                goalText: "Capture a note, collection, template, and backlink locally",
                recommendationTrace: recommendationTrace
            )
        )
    }
}

private struct NotionP0ContractHarnessFixture: Sendable, Equatable {
    static let forbiddenBroadClaims = [
        "forbidden claim fixture: release-ready",
        "forbidden claim fixture: App Store-ready",
        "forbidden claim fixture: TestFlight-ready",
        "forbidden claim fixture: fully accessible",
        "forbidden claim fixture: performance validated",
        "forbidden claim fixture: privacy approved",
        "forbidden claim fixture: Notion replacement is complete",
        "forbidden claim fixture: Notion is fully replaced",
    ]

    let notesEvidence: Bool
    let collectionsEvidence: Bool
    let templatesEvidence: Bool
    let relationsBacklinksEvidence: Bool
    let localSearchEvidence: Bool
    let noteConversionEvidence: Bool
    let attachmentsLinksEvidence: Bool
    let exportDeleteEvidence: Bool
    let sourceRecordEvidence: Bool
    let receiptEvidence: Bool
    let replayTraceEvidence: Bool
    let youInspectionBoundaryEvidence: Bool
    let unsupportedClaims: [String]

    var missingEvidence: [String] {
        var items: [String] = []
        if notesEvidence == false { items.append("notes") }
        if collectionsEvidence == false { items.append("collections") }
        if templatesEvidence == false { items.append("templates") }
        if relationsBacklinksEvidence == false { items.append("relations/backlinks") }
        if localSearchEvidence == false { items.append("local search") }
        if noteConversionEvidence == false { items.append("note-to-object conversion") }
        if attachmentsLinksEvidence == false { items.append("attachments/links") }
        if exportDeleteEvidence == false { items.append("export/delete") }
        if sourceRecordEvidence == false { items.append("source record") }
        if receiptEvidence == false { items.append("receipt") }
        if replayTraceEvidence == false { items.append("replay trace") }
        if youInspectionBoundaryEvidence == false { items.append("You inspection boundary") }
        return items
    }

    var allEvidencePresent: Bool {
        missingEvidence.isEmpty
    }

    var blocksBroadReplacementClaims: Bool {
        allEvidencePresent == false || unsupportedClaims.isEmpty == false
    }

    var blockedClaims: [String] {
        Array(Set(unsupportedClaims)).sorted()
    }
}

private struct NotionYouInspectionBoundary: Sendable, Equatable {
    let surfaceTitle: String
    let sourceKnowledgeLabel: String
    let allowsRawActivityLog: Bool

    var inspectionLabel: String {
        surfaceTitle
    }

    var blocksRawActivityLogCopy: Bool {
        allowsRawActivityLog == false
    }

    var isInspectableBoundary: Bool {
        surfaceTitle == "What Ambitions knows" && allowsRawActivityLog == false
    }
}
