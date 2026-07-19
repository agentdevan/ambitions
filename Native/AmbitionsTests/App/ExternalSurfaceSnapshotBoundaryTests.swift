import CryptoKit
import XCTest
@testable import Ambitions

final class ExternalSurfaceSnapshotBoundaryTests: XCTestCase {
    func testExternalSnapshotProjectionPayloadUsesOnlyApprovedJSONFields() async throws {
        let runtimeStore = InMemoryRuntimeEventStore()
        _ = try await runtimeStore.append(commandEvent(
            id: "command-safe-widget",
            source: .capture,
            summary: "Safe capture update",
            privacy: .standard
        ))
        _ = try await runtimeStore.append(commandEvent(
            id: "command-private-widget",
            source: .widget,
            summary: "Private Therapy Session",
            privacy: .privateUserText
        ))
        let batch = try await ProjectionMaterializer(store: runtimeStore).materializeAll(
            materializedAt: "2026-07-02T09:00:00Z"
        )
        let snapshot = ExternalSurfaceSnapshotBuilder().makeSnapshot(
            widget: batch.widget,
            privacy: batch.privacy,
            now: Date(timeIntervalSince1970: 1_714_000_000)
        )
        let data = try PersistenceCoding.encode(snapshot)
        let root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let keys = allJSONKeys(in: root)
        let unexpectedKeys = keys.subtracting(Self.allowedExternalSnapshotJSONKeys)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertTrue(unexpectedKeys.isEmpty, "Unexpected external snapshot keys: \(unexpectedKeys.sorted())")
        XCTAssertTrue(keys.isSuperset(of: Self.requiredProjectionSnapshotJSONKeys))
        XCTAssertFalse(json.contains("Private Therapy Session"))
        XCTAssertFalse(json.contains("command-private-widget"))
        XCTAssertFalse(json.contains("private_user_text"))
        XCTAssertFalse(json.contains("payloadData"))
        XCTAssertFalse(json.contains("containsPrivateRuntimeData"))
        XCTAssertFalse(json.contains("redactionRequiredEventIDs"))
        XCTAssertFalse(json.contains("localOnlyEventIDs"))
        XCTAssertFalse(json.contains("rows"))
        XCTAssertFalse(json.contains("cursor"))
    }

    func testSharedExternalSnapshotRecordRejectsPrivateOrCorruptRecordsBeforePayloadDecode() throws {
        let payload = Data(#"{"schemaVersion":"external_surface_snapshot.v1","generatedAt":"2026-07-02T09:00:00Z"}"#.utf8)
        let checksum = sha256Hex(for: payload)
        let privateRecord = SharedExternalSnapshotRecord(
            id: SharedExternalSnapshotStore.snapshotRecordID,
            snapshotKind: SharedExternalSnapshotStore.snapshotKind,
            createdAt: "2026-07-02T09:00:00Z",
            privacyClasses: [EventLedgerPrivacyClassification.privateUserText.rawValue],
            containsPrivateRuntimeData: false,
            payloadChecksum: checksum,
            payloadData: payload,
            schemaVersion: appGroupSnapshotStoreSchemaVersion
        )
        let corruptRecord = SharedExternalSnapshotRecord(
            id: SharedExternalSnapshotStore.snapshotRecordID,
            snapshotKind: SharedExternalSnapshotStore.snapshotKind,
            createdAt: "2026-07-02T09:00:00Z",
            privacyClasses: [EventLedgerPrivacyClassification.standard.rawValue],
            containsPrivateRuntimeData: false,
            payloadChecksum: "wrong-checksum",
            payloadData: payload,
            schemaVersion: appGroupSnapshotStoreSchemaVersion
        )

        XCTAssertThrowsError(try privateRecord.verifiedPayloadData())
        XCTAssertThrowsError(try corruptRecord.verifiedPayloadData())
    }
}

private extension ExternalSurfaceSnapshotBoundaryTests {
    static let requiredProjectionSnapshotJSONKeys: Set<String> = [
        "schemaVersion",
        "generatedAt",
        "nowState",
        "ambientState",
        "continuity",
        "privacy",
    ]

    static let allowedExternalSnapshotJSONKeys: Set<String> = [
        "action",
        "activeFocus",
        "ambientState",
        "backgroundMaintenanceMayMutateUserData",
        "bestNextStep",
        "blockedCount",
        "blockerSummary",
        "captureEntry",
        "context",
        "continuity",
        "currentStep",
        "defaultVisibility",
        "detail",
        "display",
        "focus",
        "freshnessLabel",
        "generatedAt",
        "goal",
        "goalID",
        "goalMode",
        "kind",
        "label",
        "lease",
        "lifecycle",
        "nextAction",
        "nowState",
        "openCaptureUrgency",
        "origin",
        "preservesCanonicalPayloadsOnRelaunch",
        "pressureLevel",
        "primaryReference",
        "privacy",
        "privacySummary",
        "prominence",
        "receipt",
        "recovery",
        "reference",
        "requiresGoalID",
        "requiresStepID",
        "ritualCue",
        "schemaVersion",
        "sensitiveDetailLabel",
        "sourceState",
        "sourceStateLabel",
        "staleActionLabel",
        "staleLabel",
        "state",
        "status",
        "stepID",
        "stepState",
        "supportedCommands",
        "surface",
        "syncHealth",
        "tab",
        "templateKey",
        "timeShape",
        "timing",
        "title",
        "today",
        "todayPosture",
        "todayPressure",
        "unavailableLabel",
        "urgency",
        "waitingCount",
        "protectedTime",
    ]

    func commandEvent(
        id: String,
        source: AmbitionsCommandSource,
        summary: String,
        privacy: EventLedgerPrivacyClassification
    ) -> RuntimeEvent {
        let command = AmbitionsCommand(
            id: id,
            kind: .quickCapture,
            source: source,
            target: AmbitionsCommandTarget(captureID: "capture-\(id)", destination: .captureInbox),
            payload: AmbitionsCommandPayload(rawText: summary),
            createdAt: "2026-07-02T09:00:00Z",
            privacy: privacy
        )
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: summary,
            route: .captureInbox,
            target: command.target,
            eventLedgerEntryIDs: ["ledger.\(id)"],
            metadata: ["objectID": "capture-\(id)"]
        )
        return RuntimeEvent.commandExecution(
            command: command,
            result: result,
            recordedAt: "2026-07-02T09:00:00Z",
            commandRecordID: "command.execution.\(id)"
        )
    }

    func allJSONKeys(in value: Any) -> Set<String> {
        if let dictionary = value as? [String: Any] {
            return dictionary.reduce(into: Set(dictionary.keys)) { keys, element in
                keys.formUnion(allJSONKeys(in: element.value))
            }
        }
        if let array = value as? [Any] {
            return array.reduce(into: Set<String>()) { keys, element in
                keys.formUnion(allJSONKeys(in: element))
            }
        }
        return []
    }

    func sha256Hex(for data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
