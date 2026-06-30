@testable import Ambitions
import XCTest

final class SearchRecallTests: XCTestCase {
    func testSearchRecallOwnerFilesExistUnderCanonicalTreeAndOldRuntimeIndexIsRemoved() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/LocalSearchIndex.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/FTSIndex.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/SemanticLocalIndex.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/ResultRanker.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/FindActInspectContract.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/SearchActionValidator.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/SearchRebuildPipeline.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Runtime/SearchIndex.swift").path),
            "Local search index source must be owned by Core/LocalRuntimeOS/SearchRecall."
        )
    }

    func testLocalSearchIndexStillRanksMemoryLensRecordsAfterMove() {
        let step = LocalSearchRecord(
            id: "step-1",
            family: .step,
            title: "Send planning brief",
            context: "Recommended step",
            sourceArea: "Today",
            state: "Ready",
            primaryActionTitle: "Start now",
            inspectActionTitle: "Open step",
            destination: .tab(.today),
            updatedAt: "2026-06-30T08:00:00Z",
            searchableText: "planning brief focus",
            originBias: [.today]
        )
        let goal = LocalSearchRecord(
            id: "goal-1",
            family: .goal,
            title: "Planning system",
            context: "Goal",
            sourceArea: "Goals",
            state: "Active",
            primaryActionTitle: "Open goal",
            inspectActionTitle: nil,
            destination: .tab(.goals),
            updatedAt: "2026-06-30T07:00:00Z",
            searchableText: "architecture",
            originBias: [.goals]
        )

        let results = LocalSearchIndex(records: [goal, step]).search(
            query: "planning",
            origin: .today,
            familyPriority: [.step: 0, .goal: 10]
        )

        XCTAssertEqual(results.map(\.id), ["step-1", "goal-1"])
    }

    func testFTSIndexReturnsFindActInspectResultsWithPrivacyProvenanceAndValidatedActions() async throws {
        let eventStore = InMemoryRuntimeEventStore(deviceID: "search-recall-fts-test")
        _ = try await eventStore.append(commandEvent(
            id: "command-search-public",
            captureID: "capture-search-public",
            summary: "Captured public planning note",
            privacy: .standard
        ))
        _ = try await eventStore.append(commandEvent(
            id: "command-search-private",
            captureID: "capture-search-private",
            summary: "private medical note",
            privacy: .privateUserText
        ))
        let batch = try await ProjectionMaterializer(store: eventStore).materializeAll(
            materializedAt: "2026-06-30T08:10:00Z"
        )
        let ftsIndex = FTSIndex(store: SearchStoreFTS(databaseURL: try scratchDirectory().appendingPathComponent("search.sqlite")))
        let receipt = try await ftsIndex.rebuild(from: batch.search, updatedAt: "2026-06-30T08:11:00Z")

        let results = try await ftsIndex.search(
            SearchRecallQuery(rawText: "planning", allowedPrivacy: [.standard], limit: 10),
            searchedAt: "2026-06-30T08:12:00Z"
        )
        let result = try XCTUnwrap(results.first)
        let report = await ftsIndex.validationReport(
            for: result,
            query: SearchRecallQuery(rawText: "planning", allowedPrivacy: [.standard], limit: 10),
            validatedAt: "2026-06-30T08:12:30Z"
        )

        XCTAssertEqual(receipt.projectionID, .search)
        XCTAssertEqual(receipt.indexedRecordCount, batch.search.results.count)
        XCTAssertEqual(result.privacy, .standard)
        XCTAssertEqual(result.family, .capture)
        XCTAssertEqual(result.provenance.eventID, "runtime.event.1")
        XCTAssertTrue(result.localOnly)
        XCTAssertEqual(report.state, .allowed)
        XCTAssertFalse(results.contains { $0.privacy == .privateUserText })
        XCTAssertTrue(result.explanation.rankingSignals.contains { $0.contains("ranker-schema") })
    }

    func testSearchActionValidatorDeniesPrivateFamilyAndMissingTargetResults() {
        let validator = SearchActionValidator()
        let privateResult = findActInspectResult(
            id: "private-result",
            family: .capture,
            privacy: .privateUserText,
            target: AmbitionsCommandTarget(captureID: "capture-private", destination: .captureInbox),
            validationState: .valid
        )
        let privateReport = validator.validate(
            result: privateResult,
            query: SearchRecallQuery(rawText: "private", allowedPrivacy: [.standard]),
            validatedAt: "2026-06-30T08:20:00Z"
        )
        XCTAssertEqual(privateReport.state, .deniedPrivacy)

        let familyReport = validator.validate(
            result: privateResult,
            query: SearchRecallQuery(rawText: "private", allowedPrivacy: [.privateUserText], allowedFamilies: [.goal]),
            validatedAt: "2026-06-30T08:20:30Z"
        )
        XCTAssertEqual(familyReport.state, .deniedFamily)

        let missingTarget = findActInspectResult(
            id: "missing-target",
            family: .goal,
            privacy: .standard,
            target: AmbitionsCommandTarget(),
            validationState: .valid
        )
        let missingReport = validator.validate(
            result: missingTarget,
            query: SearchRecallQuery(rawText: "goal", allowedPrivacy: [.standard]),
            validatedAt: "2026-06-30T08:21:00Z"
        )
        XCTAssertEqual(missingReport.state, .deniedMissingTarget)
    }

    func testSemanticLocalIndexIsDeterministicLocalOnlyAndUsesNoExternalModel() {
        let result = findActInspectResult(
            id: "semantic-result",
            family: .step,
            privacy: .standard,
            title: "Review planning notes",
            body: "Plan the next local runtime slice",
            target: AmbitionsCommandTarget(stepID: "step-semantic", destination: .today),
            validationState: .valid
        )

        let matches = SemanticLocalIndex(results: [result]).search(
            SearchRecallQuery(rawText: "planned note", allowedPrivacy: [.standard])
        )

        let match = matches.first
        XCTAssertEqual(match?.result.id, "semantic-result")
        XCTAssertEqual(match?.externalModelUsed, false)
        XCTAssertEqual(match?.localOnly, true)
        XCTAssertEqual(matches, SemanticLocalIndex(results: [result]).search(
            SearchRecallQuery(rawText: "planned note", allowedPrivacy: [.standard])
        ))
    }

    func testSearchRebuildPipelineMaterializesSearchProjectionStoresCursorAndIndexesEvents() async throws {
        let eventStore = InMemoryRuntimeEventStore(deviceID: "search-rebuild-pipeline-test")
        _ = try await eventStore.append(commandEvent(
            id: "command-search-rebuild",
            captureID: "capture-search-rebuild",
            summary: "Captured rebuild proof",
            privacy: .standard
        ))
        let directory = try scratchDirectory()
        let projectionStore = ProjectionStoreSQLite(databaseURL: directory.appendingPathComponent("projections.sqlite"))
        let ftsIndex = FTSIndex(store: SearchStoreFTS(databaseURL: directory.appendingPathComponent("search.sqlite")))
        let pipeline = SearchRebuildPipeline(
            eventStore: eventStore,
            ftsIndex: ftsIndex,
            projectionStore: projectionStore
        )

        let receipt = try await pipeline.rebuild(
            materializedAt: "2026-06-30T08:30:00Z",
            updatedAt: "2026-06-30T08:31:00Z"
        )
        let storedCursor = try await projectionStore.fetchCursor(id: .search)
        let results = try await ftsIndex.search(
            SearchRecallQuery(rawText: "rebuild", allowedPrivacy: [.standard], limit: 10),
            searchedAt: "2026-06-30T08:32:00Z"
        )

        XCTAssertTrue(receipt.localOnly)
        XCTAssertTrue(receipt.projectionStored)
        XCTAssertEqual(receipt.indexReceipt.indexedEventIDs, ["runtime.event.1"])
        XCTAssertEqual(storedCursor, receipt.indexReceipt.cursor)
        XCTAssertEqual(results.first?.provenance.eventID, "runtime.event.1")
    }
}

private extension SearchRecallTests {
    func commandEvent(
        id: String,
        captureID: String,
        summary: String,
        privacy: EventLedgerPrivacyClassification
    ) -> RuntimeEvent {
        let command = AmbitionsCommand(
            id: id,
            kind: .quickCapture,
            source: .today,
            target: AmbitionsCommandTarget(captureID: captureID, destination: .captureInbox),
            payload: AmbitionsCommandPayload(rawText: summary),
            createdAt: "2026-06-30T08:00:00Z",
            privacy: privacy
        )
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: summary,
            route: .captureInbox,
            target: AmbitionsCommandTarget(captureID: captureID, destination: .captureInbox),
            eventLedgerEntryIDs: ["ledger.\(id)"],
            metadata: ["captureID": captureID]
        )
        return RuntimeEvent.commandExecution(
            command: command,
            result: result,
            recordedAt: "2026-06-30T08:00:00Z",
            commandRecordID: "command.execution.\(id)"
        )
    }

    func findActInspectResult(
        id: String,
        family: LocalSearchObjectFamily,
        privacy: EventLedgerPrivacyClassification,
        title: String = "Result",
        body: String = "Body",
        target: AmbitionsCommandTarget,
        validationState: AmbitionsCommandValidationState
    ) -> FindActInspectResult {
        FindActInspectResult(
            id: id,
            family: family,
            title: title,
            body: body,
            privacy: privacy,
            provenance: SearchRecallProvenance(
                eventID: "event-\(id)",
                objectIDs: ["object-\(id)"],
                sourceSummary: "Runtime event"
            ),
            primaryAction: SearchRecallAction(
                id: "\(id).open",
                kind: .open,
                title: "Open",
                commandKind: .openDestination,
                target: target,
                validationState: validationState
            ),
            inspectAction: SearchRecallAction(
                id: "\(id).inspect",
                kind: .inspect,
                title: "Inspect",
                commandKind: .askWhy,
                target: target,
                validationState: validationState
            ),
            explanation: SearchRecallExplanation(
                matchedTerms: [],
                rankingSignals: [],
                privacySummary: "local",
                actionSummary: "validated",
                localOnly: true
            ),
            updatedAt: "2026-06-30T08:00:00Z",
            baseScore: 10
        )
    }

    func repoRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
        while candidate.path != "/" {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }
        throw NSError(domain: "SearchRecallTests", code: 1)
    }

    func scratchDirectory() throws -> URL {
        let directory = URL(fileURLWithPath: "/tmp", isDirectory: true)
            .appendingPathComponent("ambitions-search-recall-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
