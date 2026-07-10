import XCTest
@testable import Ambitions

final class RuntimeDomainEventReplayTests: XCTestCase {
    func testCodecRoundTripsCaptureAndTimeSemanticEvents() throws {
        let codec = RuntimeDomainEventCodec()
        let fixtures: [RuntimeDomainEvent] = [
            .captureCreated(CaptureCreatedDomainEvent(captureID: "capture-1", rawText: "Call Sam", route: .captureInbox, kind: .raw, createdAt: "2026-07-10T12:00:00Z", linkedGoalID: nil)),
            .stepPlaced(StepPlacedDomainEvent(stepID: "step-1", timeBlockID: "block-1", start: "2026-07-10T13:00:00Z", end: "2026-07-10T13:30:00Z")),
            .timeWindowProtected(TimeWindowDomainEvent(windowID: "window-1", start: "2026-07-10T14:00:00Z", end: "2026-07-10T15:00:00Z", reason: "Focus")),
        ]
        for fixture in fixtures {
            XCTAssertEqual(try codec.decode(codec.encode(fixture)), fixture)
        }
    }

    func testOldestV1FixtureUpcastsToCurrentSchema() throws {
        let fixedV1Wire = Data(#"{"typeID":"ambitions.capture.created","schemaVersion":1,"payload":"eyJjYXB0dXJlSUQiOiJjYXB0dXJlLXYxIiwiY3JlYXRlZEF0IjoiMjAyNi0wNy0xMFQxMjowMDowMFoiLCJyYXdUZXh0IjoiT2xkIGZpeHR1cmUiLCJyb3V0ZSI6ImNhcHR1cmVfaW5ib3gifQ=="}"#.utf8)
        let decoded = try RuntimeDomainEventCodec().decode(fixedV1Wire)
        XCTAssertEqual(decoded, .captureCreated(CaptureCreatedDomainEvent(
            captureID: "capture-v1", rawText: "Old fixture", route: .captureInbox,
            kind: .raw, createdAt: "2026-07-10T12:00:00Z", linkedGoalID: nil
        )))
        XCTAssertEqual(decoded.schemaVersion, runtimeDomainEventSchemaVersion)
    }

    func testFutureSchemaIsRejectedWithoutMutatingSourceBytes() throws {
        let payload = try JSONEncoder().encode(RuntimeDomainEvent.captureCreated(
            CaptureCreatedDomainEvent(captureID: "capture-1", rawText: "Keep me", route: .captureInbox, kind: .raw, createdAt: "2026-07-10T12:00:00Z", linkedGoalID: nil)
        ))
        struct FutureWire: Codable { let typeID: String; let schemaVersion: Int; let payload: Data }
        let bytes = try JSONEncoder().encode(FutureWire(typeID: "ambitions.capture.created", schemaVersion: 999, payload: payload))
        let original = bytes
        XCTAssertThrowsError(try RuntimeDomainEventCodec().decode(bytes)) { error in
            XCTAssertEqual(error as? RuntimeDomainEventCodecError, .futureSchema(typeID: "ambitions.capture.created", version: 999))
        }
        XCTAssertEqual(bytes, original)
    }


    func testFutureSchemaIsPersistedInQuarantineWithoutDeletingJournal() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("domain-quarantine-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = EventStoreSQLite(databaseURL: directory.appendingPathComponent("EventStore.sqlite"))
        let before = try await store.fetchEvents(matching: .all, limit: nil)
        let event = RuntimeDomainEvent.captureCreated(
            CaptureCreatedDomainEvent(captureID: "capture-future", rawText: "Future", route: .captureInbox, kind: .raw, createdAt: "2026-07-10T12:00:00Z", linkedGoalID: nil)
        )
        let bytes = try RuntimeDomainEventCodec().encode(event, schemaVersion: 999)

        let decoded = try await store.decodeDomainEventOrQuarantine(bytes, typeID: event.typeID, schemaVersion: 999, quarantinedAt: "2026-07-10T12:01:00Z")
        let after = try await store.fetchEvents(matching: .all, limit: nil)
        let quarantine = try await store.quarantineRecords()

        XCTAssertNil(decoded)
        XCTAssertEqual(after, before)
        XCTAssertEqual(quarantine.map(\.typeID), [event.typeID])
        XCTAssertEqual(quarantine.map(\.schemaVersion), [999])
    }

    func testCaptureReadModelReconstructsIdenticallyFromSemanticEvents() throws {
        let events: [RuntimeDomainEvent] = [
            .captureCreated(CaptureCreatedDomainEvent(captureID: "capture-1", rawText: "Call Sam", route: .captureInbox, kind: .raw, createdAt: "2026-07-10T12:00:00Z", linkedGoalID: nil)),
            .captureCreated(CaptureCreatedDomainEvent(captureID: "capture-2", rawText: "Book dentist", route: .timeSeed, kind: .deadlineTask, createdAt: "2026-07-10T12:01:00Z", linkedGoalID: nil)),
        ]
        let codec = RuntimeDomainEventCodec()
        let replayed = try events.map { try codec.decode(codec.encode($0)) }
        XCTAssertEqual(captureChecksum(events), captureChecksum(replayed))
    }


    func testEmptyDerivedStoresReconstructFromPersistedSemanticJournal() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("domain-reconstruction-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = EventStoreSQLite(databaseURL: directory.appendingPathComponent("EventStore.sqlite"), deviceID: "replay-test")
        let semanticEvents: [RuntimeDomainEvent] = [
            .captureCreated(CaptureCreatedDomainEvent(captureID: "capture-1", rawText: "Call Sam", route: .captureInbox, kind: .raw, createdAt: "2026-07-10T12:00:00Z", linkedGoalID: nil)),
            .stepPlaced(StepPlacedDomainEvent(stepID: "step-1", timeBlockID: "block-1", start: "2026-07-10T13:00:00Z", end: "2026-07-10T13:30:00Z")),
        ]
        for (index, semantic) in semanticEvents.enumerated() {
            _ = try await store.append(RuntimeEvent(
                commandID: "replay-\(index)", actor: .user, source: .system,
                occurredAt: "2026-07-10T12:0\(index):00Z",
                payload: .domainMutation(RuntimeDomainEventRecord(semantic))
            ))
        }
        let projectionURL = directory.appendingPathComponent("ProjectionStore.sqlite")
        let searchURL = directory.appendingPathComponent("SearchStore.sqlite")
        let baselineBatch = try await ProjectionMaterializer(store: store).materializeAll(materializedAt: "2026-07-10T12:10:00Z")
        let baselineProjectionStore = ProjectionStoreSQLite(databaseURL: projectionURL)
        try await baselineProjectionStore.save(batch: baselineBatch, updatedAt: "2026-07-10T12:10:00Z")
        let baselineSearch = FTSIndex(store: SearchStoreFTS(databaseURL: searchURL))
        _ = try await baselineSearch.rebuild(from: baselineBatch.search, updatedAt: "2026-07-10T12:10:00Z")
        let baselineRecords = try await baselineProjectionStore.fetchAllRecords()
        let baselineResults = try await baselineSearch.search(SearchQuery(rawText: "", limit: 100), searchedAt: "2026-07-10T12:10:01Z")

        for url in [projectionURL, searchURL] {
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
        }

        let reconstructed = try await RuntimeDomainEventReplay(store: store).reconstruct()
        let rebuiltBatch = try await ProjectionMaterializer(store: store).materializeAll(materializedAt: "2026-07-10T12:10:00Z")
        let rebuiltProjectionStore = ProjectionStoreSQLite(databaseURL: projectionURL)
        try await rebuiltProjectionStore.save(batch: rebuiltBatch, updatedAt: "2026-07-10T12:10:00Z")
        let rebuiltSearch = FTSIndex(store: SearchStoreFTS(databaseURL: searchURL))
        _ = try await rebuiltSearch.rebuild(from: rebuiltBatch.search, updatedAt: "2026-07-10T12:10:00Z")
        let rebuiltRecords = try await rebuiltProjectionStore.fetchAllRecords()
        let rebuiltResults = try await rebuiltSearch.search(SearchQuery(rawText: "", limit: 100), searchedAt: "2026-07-10T12:10:01Z")

        XCTAssertEqual(reconstructed.captures.map(\.captureID), ["capture-1"])
        XCTAssertEqual(reconstructed.timePlacements.map(\.stepID), ["step-1"])
        XCTAssertEqual(rebuiltRecords, baselineRecords)
        XCTAssertEqual(rebuiltResults, baselineResults)
        XCTAssertEqual(reconstructed.canonicalChecksum, RuntimeTransactionDigest.digest([
            "capture|capture-1|Call Sam|capture_inbox|raw|2026-07-10T12:00:00Z",
            "time|step-1|block-1|2026-07-10T13:00:00Z|2026-07-10T13:30:00Z",
        ]))
    }

    private func captureChecksum(_ events: [RuntimeDomainEvent]) -> String {
        let rows = events.compactMap { event -> String? in
            guard case let .captureCreated(value) = event else { return nil }
            return [value.captureID, value.rawText, value.route.rawValue, value.kind.rawValue, value.createdAt].joined(separator: "|")
        }.sorted()
        return RuntimeTransactionDigest.digest(rows)
    }
}
