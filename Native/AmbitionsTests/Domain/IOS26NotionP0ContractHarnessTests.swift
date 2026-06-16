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
                "surface": "Search Ambitions",
            ]
        )
        let youBoundary = NotionYouInspectionBoundary(
            surfaceTitle: "Search Ambitions",
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
        XCTAssertEqual(replayTrace.state, ReplayableDecisionTraceState.ready)
        XCTAssertTrue(replayTrace.isReplayable)
        XCTAssertTrue(replayTrace.isLocalOnly)
        XCTAssertEqual(replayTrace.recommendation?.receipt.proofReferenceIDs, [proofReference.id])
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordIDs, [receipt.id])
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordLabel, "Source record stays local")
        XCTAssertEqual(replayTrace.decisionReceipt?.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(replayTrace.decisionReceipt?.hasProofBridge ?? false)
        XCTAssertEqual(payload?.action, "open")
        XCTAssertEqual(payload?.values["sourceRecordID"], sourceRecord.id)
        XCTAssertEqual(payload?.values["surface"], "Search Ambitions")
        XCTAssertEqual(youBoundary.surfaceTitle, "Search Ambitions")
        XCTAssertEqual(youBoundary.inspectionLabel, "Search Ambitions")
        XCTAssertTrue(youBoundary.blocksRawActivityLogCopy)
        XCTAssertTrue(youBoundary.isInspectableBoundary)
    }

    func testNotionReplacementGauntletCoversFourHundredDeterministicScenarios() throws {
        let harness = NotionP0ReplacementGauntletHarness(makeReplayTrace: makeReplayTrace)
        let result = try harness.run()

        XCTAssertEqual(result.scenarioCount, 400)
        XCTAssertEqual(result.areaCounts[.notesReferences], 40)
        XCTAssertEqual(result.areaCounts[.resources], 40)
        XCTAssertEqual(result.areaCounts[.decisionsProof], 40)
        XCTAssertEqual(result.areaCounts[.collectionsTemplates], 40)
        XCTAssertEqual(result.areaCounts[.relationsBacklinks], 40)
        XCTAssertEqual(result.areaCounts[.search], 40)
        XCTAssertEqual(result.areaCounts[.conversion], 40)
        XCTAssertEqual(result.areaCounts[.sourceUsage], 40)
        XCTAssertEqual(result.areaCounts[.exportDeleteReset], 40)
        XCTAssertEqual(result.areaCounts[.replay], 40)
        XCTAssertTrue(result.failingScenarios.isEmpty, result.failureSummary)
        XCTAssertEqual(Set(result.blockedClaims), Set(NotionP0ContractHarnessFixture.forbiddenBroadClaims))
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
        surfaceTitle == "Search Ambitions" && allowsRawActivityLog == false
    }
}

private enum NotionP0ReplacementGauntletArea: String, CaseIterable, Sendable {
    case notesReferences = "notes-references"
    case resources
    case decisionsProof = "decisions-proof"
    case collectionsTemplates = "collections-templates"
    case relationsBacklinks = "relations-backlinks"
    case search
    case conversion
    case sourceUsage = "source-usage"
    case exportDeleteReset = "export-delete-reset"
    case replay
}

private struct NotionP0ReplacementGauntletScenario: Sendable, Hashable, Identifiable {
    let area: NotionP0ReplacementGauntletArea
    let variantIndex: Int

    var id: String {
        "\(area.rawValue).\(variantIndex)"
    }

    var label: String {
        "Notion P0 \(area.rawValue) / variant-\(variantIndex + 1)"
    }
}

private struct NotionP0ReplacementGauntletScenarioOutcome: Sendable, Hashable {
    let scenario: NotionP0ReplacementGauntletScenario
    let failures: [String]
}

private struct NotionP0ReplacementGauntletResult: Sendable {
    let scenarios: [NotionP0ReplacementGauntletScenarioOutcome]
    let blockedClaims: [String]

    var scenarioCount: Int {
        scenarios.count
    }

    var failingScenarios: [NotionP0ReplacementGauntletScenarioOutcome] {
        scenarios.filter { $0.failures.isEmpty == false }
    }

    var failureSummary: String {
        guard failingScenarios.isEmpty == false else {
            return "No failing scenarios."
        }
        return failingScenarios
            .map { "\($0.scenario.id): \($0.failures.joined(separator: " | "))" }
            .joined(separator: "\n")
    }

    var areaCounts: [NotionP0ReplacementGauntletArea: Int] {
        Dictionary(grouping: scenarios, by: { $0.scenario.area }).mapValues(\.count)
    }
}

private struct NotionP0ReplacementGauntletHarness {
    let makeReplayTrace: (String, String, String) -> ReplayTrace

    private let fixedTimestamp = "2026-05-25T11:18:00Z"

    func run() throws -> NotionP0ReplacementGauntletResult {
        let scenarios = makeScenarios()
        let outcomes = try scenarios.map(validate(_:))
        return NotionP0ReplacementGauntletResult(
            scenarios: outcomes,
            blockedClaims: NotionP0ContractHarnessFixture.forbiddenBroadClaims
        )
    }

    private func makeScenarios() -> [NotionP0ReplacementGauntletScenario] {
        NotionP0ReplacementGauntletArea.allCases.flatMap { area in
            (0..<40).map { variantIndex in
                NotionP0ReplacementGauntletScenario(area: area, variantIndex: variantIndex)
            }
        }
    }

    private func validate(_ scenario: NotionP0ReplacementGauntletScenario) throws -> NotionP0ReplacementGauntletScenarioOutcome {
        var failures: [String] = []

        func record(_ condition: @autoclosure () -> Bool, _ message: String) {
            if condition() == false {
                failures.append(message)
            }
        }

        let fixture = try makeFixture(for: scenario)

        record(scenario.label.contains("Notion P0"), "Scenario label must stay on the Notion gauntlet path.")
        record(fixture.store.inspectionLabel == "Search Ambitions", "Store inspection label must stay inspectable.")
        record(fixture.replayTrace.isLocalOnly, "Replay traces must stay local-only.")
        record(fixture.boundary.isInspectableBoundary, "You inspection boundaries must stay inspectable.")
        record(fixture.boundary.blocksRawActivityLogCopy, "You inspection boundaries must block raw activity copy.")
        record(fixture.store.canDelete, "The life knowledge store must stay deletable before reset.")
        record(fixture.store.isDeleted == false, "The initial life knowledge store must not be deleted.")

        switch scenario.area {
        case .notesReferences:
            validateNotesReferences(fixture, record: record)
        case .resources:
            validateResources(fixture, record: record)
        case .decisionsProof:
            validateDecisionsProof(fixture, record: record)
        case .collectionsTemplates:
            validateCollectionsTemplates(fixture, record: record)
        case .relationsBacklinks:
            validateRelationsBacklinks(fixture, record: record)
        case .search:
            validateSearch(fixture, record: record)
        case .conversion:
            validateConversion(fixture, record: record)
        case .sourceUsage:
            validateSourceUsage(fixture, record: record)
        case .exportDeleteReset:
            validateExportDeleteReset(fixture, record: record)
        case .replay:
            validateReplay(fixture, record: record)
        }

        return NotionP0ReplacementGauntletScenarioOutcome(
            scenario: scenario,
            failures: failures
        )
    }

    private func validateNotesReferences(
        _ fixture: NotionP0ReplacementGauntletFixture,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        record(fixture.sourceRecord.locator == "local://notion/p0/\(fixture.scenarioID)", "Source records must stay local and inspectable.")
        record(fixture.noteResource.kind == .note, "Notes must stay represented by local note resources.")
        record(fixture.noteResource.attachedObject.id == fixture.noteObject.id, "Notes must stay attached to note objects.")
        record(fixture.sourceObject.id == fixture.sourceRecord.id, "Source objects must stay source-tied.")
        record(fixture.store.exportSnapshot.sourceRecordIDs == [fixture.sourceRecord.id], "Store exports must include the source record.")
    }

    private func validateResources(
        _ fixture: NotionP0ReplacementGauntletFixture,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        record(fixture.collectionResource.kind == .projectArtifact, "Collections must still project as local project artifacts.")
        record(fixture.templateResource.kind == .checklistTemplate, "Templates must stay represented as local checklist templates.")
        record(fixture.resourceProjection.resources(attachedTo: fixture.noteObject).map(\.id) == [fixture.noteResource.id], "Note resources must remain attached.")
        record(fixture.resourceProjection.resources(attachedTo: fixture.collectionObject).map(\.id) == [fixture.collectionResource.id], "Collection resources must remain attached.")
        record(fixture.resourceProjection.resources(attachedTo: fixture.templateObject).map(\.id) == [fixture.templateResource.id], "Template resources must remain attached.")
    }

    private func validateDecisionsProof(
        _ fixture: NotionP0ReplacementGauntletFixture,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        record(fixture.receipt.sourceObject?.id == fixture.sourceRecord.id, "Receipts must preserve the source object bridge.")
        record(fixture.proofLedgerEntry.hasProofBridge, "Proof ledger entries must preserve the proof bridge.")
        record(fixture.proofReference.id == fixture.proofLedgerEntry.proofReference?.id, "Proof references must be stable.")
        record(fixture.proofProjection.relationshipProjection(for: fixture.convertedObject).relationships.map(\.kind) == [.proves], "Proof projections must stay local and inspectable.")
    }

    private func validateCollectionsTemplates(
        _ fixture: NotionP0ReplacementGauntletFixture,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        record(fixture.collection.entryIDs == [fixture.contextEntry.id], "Collections must keep context-entry links.")
        record(fixture.template.fieldKeys.contains("replayTrace"), "Templates must preserve replay trace fields.")
        record(fixture.template.fieldKeys.contains("sourceRecords"), "Templates must preserve source record fields.")
        record(fixture.decision.contextEntryID == fixture.contextEntry.id, "Decisions must stay anchored to the context entry.")
    }

    private func validateRelationsBacklinks(
        _ fixture: NotionP0ReplacementGauntletFixture,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        record(fixture.store.relationEdges(from: fixture.contextEntry.id).count == 6, "Relation edges must stay exported from the context entry.")
        record(fixture.store.backlinks(to: fixture.lifeAreaTarget).edgeIDs == [fixture.lifeAreaEdge.id], "Life area backlinks must stay stable.")
        record(fixture.store.backlinks(to: fixture.goalThreadTarget).weakEdgeIDs == [fixture.goalThreadEdge.id], "Goal thread backlinks must retain weak review state.")
        record(fixture.store.backlinks(to: fixture.commitmentTarget).reviewRequiredEdgeIDs == [fixture.commitmentEdge.id], "Commitment backlinks must retain review requirements.")
        record(fixture.store.backlinks(to: fixture.stepTarget).strongEdgeIDs == [fixture.stepEdge.id], "Step backlinks must retain strong edges.")
        record(fixture.store.backlinks(to: fixture.sourceTarget).hasBacklinks, "Source backlinks must stay inspectable.")
    }

    private func validateSearch(
        _ fixture: NotionP0ReplacementGauntletFixture,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        let search = fixture.store.search(
            query: LifeKnowledgeOperationModels.SearchQuery(
                searchText: "launch note",
                filters: LifeKnowledgeOperationModels.SearchFilters(
                    itemKinds: [.contextEntry],
                    sourceRecordIDs: [fixture.sourceRecord.id],
                    proofOnly: true,
                    sensitivity: .open,
                    reviewState: .ready
                ),
                performanceBudget: LifeKnowledgeOperationModels.SearchPerformanceBudget(
                    maximumCandidates: 20,
                    maximumResults: 10,
                    maximumTextTokens: 4
                )
            )
        )

        record(search.items.map(\.id) == [fixture.contextEntry.id], "Search must return the matching context entry.")
        record(search.hitPerformanceBudget == false, "Search budget must remain roomy for the gauntlet fixture.")
        record(search.items.first?.matchedTerms == ["launch", "note"], "Search terms must stay deterministic.")
        record(search.items.first?.hasProof == true, "Search results must preserve proof visibility.")
    }

    private func validateConversion(
        _ fixture: NotionP0ReplacementGauntletFixture,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        record(fixture.convertedObject.kind == .step, "Note-to-object conversion must still produce a step object.")
        record(fixture.receipt.affectedObjects.first?.id == fixture.convertedObject.id, "Converted step objects must stay receipt-backed.")
        record(fixture.proofProjection.relationshipProjection(for: fixture.convertedObject).relationships.count == 1, "Converted step objects must stay proof-linked.")
        record(fixture.contextEntry.localInspectionSummary.contains("Search Ambitions"), "Converted knowledge must remain inspectable in You.")
    }

    private func validateSourceUsage(
        _ fixture: NotionP0ReplacementGauntletFixture,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        record(fixture.boundary.sourceKnowledgeLabel == "Notion source knowledge", "The You boundary must keep the source-knowledge label.")
        record(fixture.proofLedgerEntry.sourceRecordLabel == "Source record is source-tied", "Source records must stay source-tied.")
        record(fixture.proofLedgerEntry.replayTraceLabel == "Replay trace stays local and inspectable", "Replay traces must stay inspectable.")
        record(fixture.proofLedgerEntry.hasProofBridge, "Source usage must retain a proof bridge.")
    }

    private func validateExportDeleteReset(
        _ fixture: NotionP0ReplacementGauntletFixture,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        let exported = fixture.store.exportSnapshot
        let deleted = fixture.store.markedDeleted(at: fixedTimestamp)
        let reset = fixture.store.reset(at: fixedTimestamp)

        record(exported.sourceRecordIDs == [fixture.sourceRecord.id], "Exported source records must stay local.")
        record(exported.contextEntryIDs == [fixture.contextEntry.id], "Exported context entries must stay local.")
        record(deleted.isDeleted, "Delete must mark the store as deleted.")
        record(deleted.exportSnapshot.deletedAt == fixedTimestamp, "Delete must preserve the deletion timestamp in export snapshots.")
        record(reset.sourceRecords.isEmpty, "Reset must clear source records.")
        record(reset.contextEntries.isEmpty, "Reset must clear context entries.")
        record(reset.exportSnapshot.deletedAt == nil, "Reset must clear the deleted state.")
    }

    private func validateReplay(
        _ fixture: NotionP0ReplacementGauntletFixture,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        record(fixture.replayTrace.state == .ready, "Replay traces must stay ready.")
        record(fixture.replayTrace.isLocalOnly, "Replay traces must stay local-only.")
        record(fixture.replayTrace.isReplayable, "Replay traces must stay replayable.")
        record(fixture.replayTrace.decisionReceipt?.sourceRecordIDs == [fixture.receipt.id], "Decision receipts must stay source-linked.")
        record(fixture.replayTrace.decisionReceipt?.hasProofBridge ?? false, "Decision receipts must preserve the proof bridge.")
        record(fixture.replayTrace.recommendation?.receipt.proofReferenceIDs == [fixture.proofReference.id], "Recommendation receipts must stay proof-linked.")
    }

    private func makeFixture(
        for scenario: NotionP0ReplacementGauntletScenario
    ) throws -> NotionP0ReplacementGauntletFixture {
        let scenarioID = scenario.id
        let sourceRecord = SourceRecord(
            id: "source.notion.\(scenarioID)",
            providerID: "provider.local",
            entityTitle: "Notion launch note \(scenario.variantIndex + 1)",
            publisher: "Ambitions",
            locator: "local://notion/p0/\(scenarioID)",
            provenanceKind: .official,
            isOfficial: true
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let noteObject = LifeGraphObjectReference(
            kind: .resource,
            id: "notion.note.\(scenarioID)",
            label: "Launch notes \(scenario.variantIndex + 1)",
            sourceDomain: .you
        )
        let collectionObject = LifeGraphObjectReference(
            kind: .resource,
            id: "notion.collection.\(scenarioID)",
            label: "Launch collection \(scenario.variantIndex + 1)",
            sourceDomain: .you
        )
        let templateObject = LifeGraphObjectReference(
            kind: .resource,
            id: "notion.template.\(scenarioID)",
            label: "Launch template \(scenario.variantIndex + 1)",
            sourceDomain: .you
        )
        let convertedObject = LifeGraphObjectReference(
            kind: .step,
            id: "notion.step.\(scenarioID)",
            label: "Launch checklist \(scenario.variantIndex + 1)",
            sourceDomain: .today
        )
        let noteResource = ResourceReference(
            id: "resource.notion.note.\(scenarioID)",
            kind: .note,
            title: "Launch notes \(scenario.variantIndex + 1)",
            locator: "local://notion/note/\(scenarioID)",
            summary: "The note stays local and searchable.",
            attachedObject: noteObject,
            sourceDomain: .you
        )
        let collectionResource = ResourceReference(
            id: "resource.notion.collection.\(scenarioID)",
            kind: .projectArtifact,
            title: "Launch collection \(scenario.variantIndex + 1)",
            locator: "local://notion/collection/\(scenarioID)",
            summary: "The collection stays local and backlinkable.",
            attachedObject: collectionObject,
            sourceDomain: .you
        )
        let templateResource = ResourceReference(
            id: "resource.notion.template.\(scenarioID)",
            kind: .checklistTemplate,
            title: "Launch template \(scenario.variantIndex + 1)",
            locator: "local://notion/template/\(scenarioID)",
            summary: "The template stays local and reusable.",
            attachedObject: templateObject,
            sourceDomain: .you
        )
        let resourceProjection = ProofResourceGraphProjection(
            resourceReferences: [noteResource, collectionResource, templateResource]
        )
        let receipt = ActionReceipt(
            id: "receipt.notion.\(scenarioID)",
            resultState: .completed,
            title: "Notion note converted locally",
            summary: "Notes, collections, templates, relations, search, export/delete, and replay stay local.",
            sourceDomain: .proof,
            occurredAt: fixedTimestamp,
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
        let replayTrace = makeReplayTrace(sourceRecord.id, receipt.id, proofReference.id)
        let reflection = Reflection(
            id: "reflection.notion.\(scenarioID)",
            ambitionID: "ambition.notion.\(scenarioID)",
            proofID: proofReference.id,
            closureEventID: nil,
            text: "Search Ambitions keeps the local source, receipt, and replay trail visible.",
            learnedSignal: "notion_local_knowledge_\(scenario.variantIndex)",
            createdAt: fixedTimestamp
        )
        let lifeAreaTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .lifeArea,
            id: "life-area.home.\(scenarioID)",
            label: "Home \(scenario.variantIndex + 1)"
        )
        let goalThreadTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .goalThread,
            id: "goal-thread.home-reset.\(scenarioID)",
            label: "Reset the apartment \(scenario.variantIndex + 1)"
        )
        let commitmentTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .commitment,
            id: "commitment.home-reset.\(scenarioID)",
            label: "Home reset commitment \(scenario.variantIndex + 1)",
            sourceDomain: .commitment
        )
        let stepTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .step,
            id: "step.home-reset.\(scenarioID)",
            label: "Pack kitchen \(scenario.variantIndex + 1)",
            sourceDomain: .goalEngine
        )
        let proofTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .proof,
            id: "proof.home-reset.\(scenarioID)",
            label: "Receipt-backed proof \(scenario.variantIndex + 1)",
            sourceDomain: .proof
        )
        let sourceTarget = LifeKnowledgeOperationModels.RelationTargetReference(
            kind: .source,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let lifeAreaEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: "context-entry.notion.\(scenarioID)",
            target: lifeAreaTarget,
            relationshipKind: .attachedTo,
            reviewState: .ready,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let goalThreadEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: "context-entry.notion.\(scenarioID)",
            target: goalThreadTarget,
            relationshipKind: .supports,
            reviewState: .weak,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let commitmentEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: "context-entry.notion.\(scenarioID)",
            target: commitmentTarget,
            relationshipKind: .dependsOn,
            reviewState: .needsReview,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let stepEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: "context-entry.notion.\(scenarioID)",
            target: stepTarget,
            relationshipKind: .contains,
            reviewState: .ready,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let proofEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: "context-entry.notion.\(scenarioID)",
            target: proofTarget,
            relationshipKind: .proves,
            reviewState: .ready,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let sourceEdge = LifeKnowledgeOperationModels.RelationEdge(
            sourceContextEntryID: "context-entry.notion.\(scenarioID)",
            target: sourceTarget,
            relationshipKind: .createdFrom,
            reviewState: .ready,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let contextEntry = LifeKnowledgeOperationModels.ContextEntry(
            id: "context-entry.notion.\(scenarioID)",
            kind: .contextEntry,
            title: "Launch notes \(scenario.variantIndex + 1)",
            summary: "Store a structured note entry with source, receipt, and replay.",
            body: "The note can be collected, templated, and replayed locally.",
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            templateID: "template.notion.\(scenarioID)",
            collectionIDs: ["collection.notion.\(scenarioID)"],
            resourceIDs: [noteResource.id],
            relationEdgeIDs: [
                lifeAreaEdge.id,
                goalThreadEdge.id,
                commitmentEdge.id,
                stepEdge.id,
                proofEdge.id,
                sourceEdge.id
            ],
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let collection = LifeKnowledgeOperationModels.Collection(
            id: "collection.notion.\(scenarioID)",
            title: "Launch collection \(scenario.variantIndex + 1)",
            summary: "Group the note and its related entries.",
            templateID: "template.notion.\(scenarioID)",
            entryIDs: [contextEntry.id],
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let template = LifeKnowledgeOperationModels.Template(
            id: "template.notion.\(scenarioID)",
            title: "Structured note template \(scenario.variantIndex + 1)",
            summary: "Capture structured note fields with local source proof.",
            entryKind: .contextEntry,
            fieldKeys: ["body", "receipt", "replayTrace", "sourceRecords", "summary", "title"],
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let decision = LifeKnowledgeOperationModels.Decision(
            id: "decision.notion.\(scenarioID)",
            title: "Use the structured note locally \(scenario.variantIndex + 1)",
            summary: "A decision can carry the local source record and replay evidence.",
            contextEntryID: contextEntry.id,
            sourceRecords: [sourceRecord],
            receipt: receipt,
            replayTrace: replayTrace,
            reflection: reflection,
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let resource = LifeKnowledgeOperationModels.Resource(
            id: "resource.notion.\(scenarioID)",
            reference: ResourceReference(
                id: "resource.notion.\(scenarioID)",
                kind: .note,
                title: "Launch notes \(scenario.variantIndex + 1)",
                locator: "local://notion/note/\(scenarioID)",
                summary: "A local note stays searchable.",
                attachedObject: noteObject,
                sourceDomain: .you
            ),
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let personPlace = LifeKnowledgeOperationModels.PersonPlaceContext(
            id: "person-place.notion.\(scenarioID)",
            kind: .person,
            label: "Alex \(scenario.variantIndex + 1)",
            summary: "Person context stays local and source-controlled.",
            sourceRecord: sourceRecord,
            resourceIDs: [resource.id],
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )
        let store = LifeKnowledgeOperationModels.Store(
            id: "store.notion.\(scenarioID)",
            inspectionSummary: "You / Search Ambitions can inspect this source, receipt, and reason.",
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
            relationEdges: [
                sourceEdge,
                proofEdge,
                stepEdge,
                commitmentEdge,
                goalThreadEdge,
                lifeAreaEdge
            ],
            createdAt: fixedTimestamp,
            updatedAt: fixedTimestamp
        )

        return NotionP0ReplacementGauntletFixture(
            scenarioID: scenarioID,
            sourceRecord: sourceRecord,
            sourceObject: sourceObject,
            noteObject: noteObject,
            collectionObject: collectionObject,
            templateObject: templateObject,
            convertedObject: convertedObject,
            noteResource: noteResource,
            collectionResource: collectionResource,
            templateResource: templateResource,
            resourceProjection: resourceProjection,
            proofLedgerEntry: proofLedgerEntry,
            proofReference: proofReference,
            proofProjection: proofProjection,
            receipt: receipt,
            replayTrace: replayTrace,
            contextEntry: contextEntry,
            collection: collection,
            template: template,
            decision: decision,
            resource: resource,
            personPlace: personPlace,
            lifeAreaTarget: lifeAreaTarget,
            goalThreadTarget: goalThreadTarget,
            commitmentTarget: commitmentTarget,
            stepTarget: stepTarget,
            proofTarget: proofTarget,
            sourceTarget: sourceTarget,
            lifeAreaEdge: lifeAreaEdge,
            goalThreadEdge: goalThreadEdge,
            commitmentEdge: commitmentEdge,
            stepEdge: stepEdge,
            proofEdge: proofEdge,
            sourceEdge: sourceEdge,
            store: store,
            boundary: NotionYouInspectionBoundary(
                surfaceTitle: LifeKnowledgeOperationModels.surfaceTitle,
                sourceKnowledgeLabel: "Notion source knowledge",
                allowsRawActivityLog: false
            )
        )
    }
}

private struct NotionP0ReplacementGauntletFixture {
    let scenarioID: String
    let sourceRecord: SourceRecord
    let sourceObject: LifeGraphObjectReference
    let noteObject: LifeGraphObjectReference
    let collectionObject: LifeGraphObjectReference
    let templateObject: LifeGraphObjectReference
    let convertedObject: LifeGraphObjectReference
    let noteResource: ResourceReference
    let collectionResource: ResourceReference
    let templateResource: ResourceReference
    let resourceProjection: ProofResourceGraphProjection
    let proofLedgerEntry: ActionReceiptProofLedgerEntry
    let proofReference: ProofReference
    let proofProjection: ProofResourceGraphProjection
    let receipt: ActionReceipt
    let replayTrace: ReplayTrace
    let contextEntry: LifeKnowledgeOperationModels.ContextEntry
    let collection: LifeKnowledgeOperationModels.Collection
    let template: LifeKnowledgeOperationModels.Template
    let decision: LifeKnowledgeOperationModels.Decision
    let resource: LifeKnowledgeOperationModels.Resource
    let personPlace: LifeKnowledgeOperationModels.PersonPlaceContext
    let lifeAreaTarget: LifeKnowledgeOperationModels.RelationTargetReference
    let goalThreadTarget: LifeKnowledgeOperationModels.RelationTargetReference
    let commitmentTarget: LifeKnowledgeOperationModels.RelationTargetReference
    let stepTarget: LifeKnowledgeOperationModels.RelationTargetReference
    let proofTarget: LifeKnowledgeOperationModels.RelationTargetReference
    let sourceTarget: LifeKnowledgeOperationModels.RelationTargetReference
    let lifeAreaEdge: LifeKnowledgeOperationModels.RelationEdge
    let goalThreadEdge: LifeKnowledgeOperationModels.RelationEdge
    let commitmentEdge: LifeKnowledgeOperationModels.RelationEdge
    let stepEdge: LifeKnowledgeOperationModels.RelationEdge
    let proofEdge: LifeKnowledgeOperationModels.RelationEdge
    let sourceEdge: LifeKnowledgeOperationModels.RelationEdge
    let store: LifeKnowledgeOperationModels.Store
    let boundary: NotionYouInspectionBoundary
}
