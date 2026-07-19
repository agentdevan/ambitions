import CryptoKit
@testable import Ambitions
import XCTest

final class PrivacySecurityTests: XCTestCase {
    private let classifier = PrivacyClassifier()

    func testPrivacySecurityCanonicalOwnerFilesExistAndOldStorageBoundaryOwnerIsRemoved() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyClassifier.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/RedactionEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/EgressFirewall.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/ExportPolicy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/LocalAuthGate.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/FileProtectionPolicy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/EncryptedBlobVault.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyManifestRuntimeMap.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/SensitiveSurfacePolicy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/StoragePrivacySecurityBoundary.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyExternalBoundaryGate.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing PrivacySecurity owner file: \(requiredPath)"
            )
        }

        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Persistence/StoragePrivacySecurityBoundary.swift").path)
        )
    }

    func testRedactionEngineHidesPrivateNotificationPayloadAndKeepsInspectionPath() {
        let object = privateObject()
        let result = RedactionEngine().redact(
            PrivacyRedactionRequest(
                object: object,
                surface: .notificationContent,
                title: "goal_text=Call therapist",
                summary: "schedule_assumption=Discuss recovery details",
                metadata: ["goalID": "goal-1", "tone": "sensitive"],
                payload: [
                    "rawNote": "private_life_graph=node proof_payload=photo receipt_payload=receipt behavior_history=night personalization_signal=protect"
                ],
                userReviewed: true
            )
        )

        XCTAssertTrue(result.redactionApplied)
        XCTAssertEqual(result.visibleTitle, "Private life item")
        XCTAssertEqual(result.visibleSummary, "Details hidden. Open Ambitions to inspect locally.")
        XCTAssertEqual(result.metadataKeys, ["goalID", "tone"])
        XCTAssertEqual(result.payloadKeys, ["rawNote"])
        XCTAssertFalse(result.egressRecord.inspectedValue.contains("goal_text"))
        XCTAssertFalse(result.egressRecord.inspectedValue.contains("schedule_assumption"))
        XCTAssertFalse(result.egressRecord.inspectedValue.contains("private_life_graph"))
        XCTAssertFalse(result.egressRecord.inspectedValue.contains("proof_payload"))
        XCTAssertFalse(result.egressRecord.inspectedValue.contains("receipt_payload"))
        XCTAssertFalse(result.egressRecord.inspectedValue.contains("behavior_history"))
        XCTAssertFalse(result.egressRecord.inspectedValue.contains("personalization_signal"))
        XCTAssertEqual(SourceAtlasNoPrivateGraphEgressAudit.validate([result.egressRecord]), [])
    }

    func testEgressFirewallBlocksPrivateR2AndPermitsPublicReferencePayload() {
        let firewall = EgressFirewall()
        let privateDecision = firewall.evaluate(
            PrivacyEgressAttempt(
                id: "private-r2",
                destination: .r2PublicReference,
                purpose: .publicReferenceFreshness,
                redactionRequest: PrivacyRedactionRequest(
                    object: privateObject(),
                    surface: .sourceAtlasPublicReference,
                    title: "goal_text=Private goal",
                    summary: "schedule_assumption=Private plan",
                    payload: ["rawNote": "capture_text=private receipt_payload=receipt proof_payload=proof personalization_factor=energy"],
                    userReviewed: true
                )
            )
        )

        XCTAssertFalse(privateDecision.permitted)
        XCTAssertFalse(privateDecision.receipt.permitted)
        XCTAssertTrue(privateDecision.receipt.issueCodes.contains(SensitiveSurfaceIssue.publicReferenceForbidden.rawValue))
        XCTAssertTrue(privateDecision.receipt.issueCodes.contains(NetworkEgressIssue.privateGraphPayloadForbidden.rawValue))
        XCTAssertFalse(privateDecision.redaction.egressRecord.inspectedValue.contains("goal_text"))
        XCTAssertFalse(privateDecision.redaction.egressRecord.inspectedValue.contains("schedule_assumption"))
        XCTAssertFalse(privateDecision.redaction.egressRecord.inspectedValue.contains("capture_text"))
        XCTAssertFalse(privateDecision.redaction.egressRecord.inspectedValue.contains("receipt_payload"))
        XCTAssertFalse(privateDecision.redaction.egressRecord.inspectedValue.contains("proof_payload"))
        XCTAssertFalse(privateDecision.redaction.egressRecord.inspectedValue.contains("personalization_factor"))
        XCTAssertEqual(SourceAtlasNoPrivateGraphEgressAudit.validate([privateDecision.redaction.egressRecord]), [])

        let publicObject = PrivacyClassifiedObject(
            id: "source-pack-rule",
            family: "source_atlas",
            title: "Public source pack rule",
            privacyClass: .publicMetadata,
            containsUserText: false
        )
        let publicDecision = firewall.evaluate(
            PrivacyEgressAttempt(
                id: "public-r2",
                destination: .r2PublicReference,
                purpose: .publicReferenceFreshness,
                redactionRequest: PrivacyRedactionRequest(
                    object: publicObject,
                    surface: .sourceAtlasPublicReference,
                    title: "Public source pack rule",
                    summary: "Public manifest metadata",
                    metadata: ["pack": "public"],
                    userReviewed: true
                )
            )
        )

        XCTAssertTrue(publicDecision.permitted)
        XCTAssertTrue(publicDecision.receipt.permitted)
        XCTAssertFalse(publicDecision.redaction.redactionApplied)
        XCTAssertEqual(publicDecision.networkDecision.issues, [])
    }

    func testExportPolicyRequiresUserReviewAndPermitsReviewedPortableManifest() {
        let manifest = PortableExportManifest.make(
            selection: .all,
            goals: [],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            teachingSignals: [],
            appState: .default
        )
        let records = StoragePrivacyBoundaryCatalog.records(from: manifest, userReviewed: true)
        let policy = ExportPolicy()

        let unreviewed = policy.evaluate(
            PrivacyExportRequest(
                id: "portable-unreviewed",
                destination: .portablePackage,
                records: records,
                userReviewed: false
            )
        )
        XCTAssertFalse(unreviewed.permitted)
        XCTAssertTrue(unreviewed.report.findings.map(\.issue).contains(.userReviewMissing))

        let reviewed = policy.evaluate(
            PrivacyExportRequest(
                id: "portable-reviewed",
                destination: .portablePackage,
                records: records,
                userReviewed: true
            )
        )
        XCTAssertTrue(reviewed.permitted)
        XCTAssertTrue(reviewed.receipt.permitted)
        XCTAssertFalse(reviewed.allowedProjectionIDs.isEmpty)
        XCTAssertTrue(reviewed.receipt.redactionApplied)
    }

    func testLocalAuthGateAndEncryptedBlobVaultProtectPrivatePayload() async throws {
        let object = privateObject()
        let gate = LocalAuthGate()

        let blocked = gate.evaluate(
            LocalAuthGateRequest(
                id: "private-inspection",
                object: object,
                surface: .localInspection,
                availability: .available,
                authenticationSatisfied: false
            )
        )
        XCTAssertTrue(blocked.required)
        XCTAssertFalse(blocked.permitted)
        XCTAssertTrue(blocked.issues.contains(.authenticationNotSatisfied))

        let allowed = gate.evaluate(
            LocalAuthGateRequest(
                id: "private-inspection",
                object: object,
                surface: .localInspection,
                availability: .available,
                authenticationSatisfied: true
            )
        )
        XCTAssertTrue(allowed.permitted)

        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("PrivacySecurityTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let blobStore = BlobStoreFileSystem(rootDirectory: root)
        let vault = EncryptedBlobVault(blobStore: blobStore)
        let key = SymmetricKey(size: .bits256)
        let plaintext = Data("private payload".utf8)
        let write = try await vault.sealAndWrite(
            id: "private-payload",
            object: object,
            plaintext: plaintext,
            contentType: "text/plain",
            key: key,
            keyID: "test-key",
            createdAt: "2026-06-30T10:30:00Z"
        )

        XCTAssertTrue(write.receipt.permitted)
        XCTAssertEqual(write.record.privacyClass, .privateUserText)
        XCTAssertEqual(write.record.blobRecord.protectionClass, .complete)

        let encryptedBytes = try await blobStore.read(id: write.record.blobRecord.id)
        XCTAssertNotEqual(encryptedBytes, plaintext)
        let opened = try await vault.open(write.record, key: key)
        XCTAssertEqual(opened, plaintext)
    }

    func testPrivacyManifestRuntimeMapPreservesLocalOnlyNoTrackingBoundary() {
        let decision = PrivacyManifestRuntimeMap().evaluate(
            PrivacyManifestRuntimeFacts(
                trackingEnabled: false,
                collectedDataTypeCount: 0,
                accessedAPITypeCount: PrivacyManifestDataAndAccessedAPIInventory.current.accessedAPITypes.count
            )
        )

        XCTAssertTrue(decision.isSatisfied)
        XCTAssertTrue(decision.localOnlyRuntime)
        XCTAssertFalse(decision.trackingEnabled)
        XCTAssertEqual(decision.collectedDataTypeCount, 0)
        XCTAssertEqual(decision.accessedAPITypeCount, 1)
    }

    func testPrivacyManifestInventoryCapturesFileTimestampReasonWithoutReleaseClaims() throws {
        let inventory = PrivacyManifestDataAndAccessedAPIInventory.current
        let entry = try XCTUnwrap(inventory.accessedAPITypes.first)

        XCTAssertEqual(inventory.manifestPath, PrivacyManifestRuntimeMap.expectedManifestPath)
        XCTAssertFalse(inventory.trackingEnabled)
        XCTAssertTrue(inventory.collectedDataTypes.isEmpty)
        XCTAssertFalse(inventory.legalApprovalClaimed)
        XCTAssertFalse(inventory.appStoreReadinessClaimed)
        XCTAssertEqual(entry.apiType, "NSPrivacyAccessedAPICategoryFileTimestamp")
        XCTAssertEqual(entry.reasonCodes, ["C617.1"])
        XCTAssertTrue(entry.sourceReferences.contains("Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataLegacyMigration.swift:66"))
        XCTAssertTrue(entry.localOnlyJustification.contains("no derived information is sent off-device"))
    }

    func testPrivacyExternalBoundaryGateEvaluatesEgressExportDiagnosticsAndFiles() {
        let gate = PrivacyExternalBoundaryGate()
        let publicObject = PrivacyClassifiedObject(
            id: "public-source-rule",
            family: "source_atlas",
            title: "Public source rule",
            privacyClass: .publicMetadata,
            containsUserText: false
        )
        let publicEgress = EgressFirewall().evaluate(
            PrivacyEgressAttempt(
                id: "public-egress",
                destination: .r2PublicReference,
                purpose: .publicReferenceFreshness,
                redactionRequest: PrivacyRedactionRequest(
                    object: publicObject,
                    surface: .sourceAtlasPublicReference,
                    title: "Public source rule",
                    summary: "Public reference metadata",
                    userReviewed: true
                )
            )
        )
        let publicEgressDecision = gate.evaluateEgress(publicEgress)
        XCTAssertTrue(publicEgressDecision.isPermitted)
        XCTAssertEqual(publicEgressDecision.receipt.action, .networkEgress)

        let privateEgress = EgressFirewall().evaluate(
            PrivacyEgressAttempt(
                id: "private-egress",
                destination: .r2PublicReference,
                purpose: .publicReferenceFreshness,
                redactionRequest: PrivacyRedactionRequest(
                    object: privateObject(),
                    surface: .sourceAtlasPublicReference,
                    title: "Private goal",
                    summary: "Private schedule",
                    userReviewed: true
                )
            )
        )
        let privateEgressDecision = gate.evaluateEgress(privateEgress)
        XCTAssertFalse(privateEgressDecision.isPermitted)
        XCTAssertTrue(privateEgressDecision.issueCodes.contains(PrivacyExternalBoundaryIssue.privateGraphTouched.rawValue))

        let manifest = PortableExportManifest.make(
            selection: .all,
            goals: [],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            teachingSignals: [],
            appState: .default
        )
        let records = StoragePrivacyBoundaryCatalog.records(from: manifest, userReviewed: true)
        let exportDecision = ExportPolicy().evaluate(
            PrivacyExportRequest(
                id: "portable-reviewed",
                destination: .portablePackage,
                records: records,
                userReviewed: true
            )
        )
        let externalExportDecision = gate.evaluateExport(exportDecision)
        XCTAssertTrue(externalExportDecision.isPermitted)
        XCTAssertEqual(externalExportDecision.receipt.action, .export)

        let diagnosticRedaction = RedactionEngine().redact(
            PrivacyRedactionRequest(
                object: privateObject(),
                surface: .diagnosticsExport,
                title: "Private detail",
                summary: "Diagnostic payload",
                userReviewed: true
            )
        )
        let diagnosticsDecision = gate.evaluateDiagnostics(diagnosticRedaction)
        XCTAssertTrue(diagnosticsDecision.isPermitted)
        XCTAssertEqual(diagnosticsDecision.receipt.action, .diagnosticsRedaction)

        let protectedFile = FileProtectionPolicy().decision(for: privateObject())
        XCTAssertTrue(gate.evaluateFileProtection(protectedFile).isPermitted)

        let sensitiveFile = FileProtectionPolicy().decision(for: PrivacyClassifiedObject(
            id: "calendar-derived-note",
            family: "time",
            title: "Calendar detail",
            privacyClass: .calendarDerived
        ))
        XCTAssertTrue(gate.evaluateFileProtection(sensitiveFile).isPermitted)

        let weakFile = FileProtectionDecision(
            objectID: "weak-private-file",
            privacyClass: .privateUserText,
            protectionLevel: .standard,
            requiresEncryptedBlobVault: false,
            reason: "fixture"
        )
        let weakFileDecision = gate.evaluateFileProtection(weakFile)
        XCTAssertFalse(weakFileDecision.isPermitted)
        XCTAssertTrue(weakFileDecision.issueCodes.contains(PrivacyExternalBoundaryIssue.fileProtectionInsufficient.rawValue))
    }

    func testPrivacyExternalBoundaryGateEvaluatesExternalSnapshotsAndBridgeHandoffs() async throws {
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
        let batch = try await ProjectionMaterializer(store: runtimeStore).materializeAll(materializedAt: "2026-06-30T09:00:00Z")
        let record = AppGroupSnapshotRecord(
            id: SharedExternalSnapshotStore.snapshotRecordID,
            snapshotKind: SharedExternalSnapshotStore.snapshotKind,
            createdAt: "2026-06-30T09:01:00Z",
            privacyClasses: [.standard],
            containsPrivateRuntimeData: false,
            payloadData: Data(#"{"safe":true}"#.utf8)
        )
        let gate = PrivacyExternalBoundaryGate()
        let snapshotDecision = gate.evaluateExternalSnapshot(record: record, widget: batch.widget, privacy: batch.privacy)
        XCTAssertTrue(snapshotDecision.isPermitted)
        XCTAssertEqual(snapshotDecision.receipt.action, .externalSnapshot)

        let mismatchedWidget = try widgetProjectionDroppingRedactions(batch.widget)
        let mismatchedSnapshotDecision = gate.evaluateExternalSnapshot(
            record: record,
            widget: mismatchedWidget,
            privacy: batch.privacy
        )
        XCTAssertFalse(mismatchedSnapshotDecision.isPermitted)
        XCTAssertTrue(mismatchedSnapshotDecision.issueCodes.contains(PrivacyExternalBoundaryIssue.externalSnapshotPrivacyProjectionMismatch.rawValue))

        let unsafeRecord = AppGroupSnapshotRecord(
            id: SharedExternalSnapshotStore.snapshotRecordID,
            snapshotKind: SharedExternalSnapshotStore.snapshotKind,
            createdAt: "2026-06-30T09:01:00Z",
            privacyClasses: [.privateUserText],
            containsPrivateRuntimeData: true,
            payloadData: Data(#"{"unsafe":true}"#.utf8)
        )
        let unsafeSnapshotDecision = gate.evaluateExternalSnapshot(record: unsafeRecord, widget: batch.widget, privacy: batch.privacy)
        XCTAssertFalse(unsafeSnapshotDecision.isPermitted)
        XCTAssertTrue(unsafeSnapshotDecision.issueCodes.contains(PrivacyExternalBoundaryIssue.rawPrivateRuntimeData.rawValue))

        let appIntentDecision = gate.evaluateExternalSurfaceBridge(
            PrivacyExternalSurfaceBridgeEvidence(
                id: "intent-safe",
                kind: .appIntentResponse,
                commitRequirement: .committedProjection,
                requestedBoundary: .localOnly,
                requestedStatus: .recordedLocalOnly,
                externalEffect: false,
                containsPrivateRuntimeData: false,
                receiptID: "app-intent-intake-receipt.intent-safe",
                summary: "App Intent response uses safe local review copy."
            )
        )
        XCTAssertTrue(appIntentDecision.isPermitted)
        XCTAssertEqual(appIntentDecision.receipt.action, .appIntentResponse)

        let shareDecision = gate.evaluateExternalSurfaceBridge(
            PrivacyExternalSurfaceBridgeEvidence(
                id: "share-safe",
                kind: .shareHandoff,
                commitRequirement: .committedProjection,
                requestedBoundary: .localOnly,
                requestedStatus: .recordedLocalOnly,
                externalEffect: false,
                containsPrivateRuntimeData: false,
                receiptID: "share-intake-receipt.share-safe",
                summary: "Share handoff uses safe local review copy."
            )
        )
        XCTAssertTrue(shareDecision.isPermitted)
        XCTAssertEqual(shareDecision.receipt.action, .shareHandoff)

        let unsafeBridgeDecision = gate.evaluateExternalSurfaceBridge(
            PrivacyExternalSurfaceBridgeEvidence(
                id: "intent-unsafe",
                kind: .appIntentResponse,
                commitRequirement: .noUserStateMutation,
                requestedBoundary: .externalEffect,
                requestedStatus: .queued,
                externalEffect: true,
                containsPrivateRuntimeData: true,
                receiptID: nil,
                summary: "fixture"
            )
        )
        XCTAssertFalse(unsafeBridgeDecision.isPermitted)
        XCTAssertTrue(unsafeBridgeDecision.issueCodes.contains(PrivacyExternalBoundaryIssue.externalSurfaceBridgeContainsPrivateRuntimeData.rawValue))
    }

    private func widgetProjectionDroppingRedactions(_ widget: WidgetProjection) throws -> WidgetProjection {
        let data = try LocalRuntimeStorageCoding.encode(widget)
        let corruptedData = try widgetPayloadDroppingRedactions(from: data)
        return try LocalRuntimeStorageCoding.decode(WidgetProjection.self, from: corruptedData)
    }

    private func widgetPayloadDroppingRedactions(from data: Data) throws -> Data {
        guard var root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw PrivacySecurityTestError.invalidWidgetProjectionPayload
        }
        root["redactedEventIDs"] = []
        return try JSONSerialization.data(withJSONObject: root, options: [.sortedKeys])
    }

    private func privateObject() -> PrivacyClassifiedObject {
        classifier.classifyEvent(
            id: "private-goal-note",
            family: "goal",
            title: "Private goal note",
            privacy: .privateUserText,
            sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity"
        )
    }

    private func commandEvent(
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
            createdAt: "2026-06-30T09:00:00Z",
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
            recordedAt: "2026-06-30T09:00:00Z",
            commandRecordID: "command.execution.\(id)"
        )
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

private enum PrivacySecurityTestError: Error {
    case invalidWidgetProjectionPayload
}
