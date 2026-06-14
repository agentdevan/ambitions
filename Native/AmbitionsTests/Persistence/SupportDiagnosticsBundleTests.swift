import XCTest
@testable import Ambitions

final class SupportDiagnosticsBundleTests: XCTestCase {
    private let builder = SupportDiagnosticsBundleBuilder()
    private let storageValidator = StoragePrivacySecurityBoundaryValidator()

    func testBuildsReviewedLocalOnlyRedactedSupportBundle() throws {
        let bundle = builder.makeBundle(
            diagnosticSnapshot: diagnosticSnapshot(),
            storageBoundaryReport: greenStorageBoundaryReport(),
            generatedAt: "2026-06-14T09:55:00Z",
            userReviewed: true
        )

        XCTAssertTrue(bundle.isGreen)
        XCTAssertTrue(bundle.canExportSupportAttachment)
        XCTAssertEqual(bundle.manifest.schemaVersion, supportDiagnosticsBundleSchemaVersion)
        XCTAssertTrue(bundle.manifest.localOnly)
        XCTAssertFalse(bundle.manifest.thirdPartyAnalyticsEnabled)
        XCTAssertEqual(bundle.manifest.redactedEntryCount, 1)
        XCTAssertEqual(bundle.storageBoundary.issueCount, 0)
        XCTAssertTrue(bundle.storageBoundary.hasRedactedPrivateSupportCoverage)

        let privateEntry = try XCTUnwrap(bundle.entries.first { $0.privacy == .privateUserText })
        XCTAssertEqual(privateEntry.title, "Private diagnostic")
        XCTAssertEqual(privateEntry.sourceRecordAnchor, "[redacted]")
        XCTAssertTrue(privateEntry.redactionApplied)
        XCTAssertEqual(privateEntry.metadataKeys, ["goalID", "kind", "source", "sourceConfirmed", "tone"])
        XCTAssertEqual(privateEntry.payloadKeys, ["rawNote"])

        let standardEntry = try XCTUnwrap(bundle.entries.first { $0.privacy == .standard })
        XCTAssertEqual(standardEntry.title, "EventLedger goal_created")
        XCTAssertEqual(standardEntry.sourceRecordAnchor, "ledger.goal.created")
        XCTAssertFalse(standardEntry.redactionApplied)
    }

    func testExportPayloadsAreDeterministicAndDoNotIncludePrivateText() throws {
        let bundle = builder.makeBundle(
            diagnosticSnapshot: diagnosticSnapshot(),
            storageBoundaryReport: greenStorageBoundaryReport(),
            formats: [.markdownSummary, .jsonLines, .json, .markdownSummary],
            destinations: [.supportAttachment, .localInspection, .supportAttachment],
            generatedAt: "2026-06-14T09:55:00Z",
            userReviewed: true
        )

        XCTAssertEqual(bundle.manifest.formats, [.json, .jsonLines, .markdownSummary])
        XCTAssertEqual(bundle.manifest.destinations, [.localInspection, .supportAttachment])

        let markdown = try bundle.exportPayload(format: .markdownSummary)
        XCTAssertEqual(markdown.format, .markdownSummary)
        XCTAssertFalse(markdown.containsPrivateDiagnosticText)
        XCTAssertFalse(markdown.content.contains("Called the therapist"))
        XCTAssertTrue(markdown.content.contains("Private diagnostic"))
        XCTAssertTrue(markdown.content.contains("Third-party analytics: disabled"))

        let jsonLines = try bundle.exportPayload(format: .jsonLines)
        XCTAssertEqual(jsonLines.content.split(separator: "\n").count, bundle.entries.count)
        XCTAssertFalse(jsonLines.content.contains("Called the therapist"))
        XCTAssertTrue(jsonLines.content.contains("\"metadataKeys\""))
        XCTAssertFalse(jsonLines.content.contains("\"rawNote\":\"Called the therapist\""))
    }

    func testBlocksThirdPartyAnalyticsMissingReviewAndUnsafeStorageBoundary() {
        let bundle = builder.makeBundle(
            diagnosticSnapshot: diagnosticSnapshot(),
            storageBoundaryReport: unsafeStorageBoundaryReport(),
            formats: [],
            destinations: [.localInspection, .thirdPartyAnalytics],
            generatedAt: "2026-06-14T09:55:00Z",
            userReviewed: false
        )
        let issues = Set(bundle.findings.map(\.issue))

        XCTAssertFalse(bundle.isGreen)
        XCTAssertFalse(bundle.canExportSupportAttachment)
        XCTAssertTrue(issues.contains(.exportFormatMissing))
        XCTAssertTrue(issues.contains(.thirdPartyAnalyticsDestination))
        XCTAssertTrue(issues.contains(.userReviewMissing))
        XCTAssertTrue(issues.contains(.storageBoundaryNotGreen))
        XCTAssertTrue(issues.contains(.supportBoundaryMissing))
        XCTAssertFalse(issues.contains(.supportBoundaryRedactionMissing))
    }
}

private extension SupportDiagnosticsBundleTests {
    func diagnosticSnapshot() -> DiagnosticLedgerSnapshot {
        DiagnosticLedgerSnapshot(
            eventLedger: [
                EventLedgerEntry(
                    id: "ledger.goal.created",
                    kind: .goalCreated,
                    occurredAt: "2026-06-14T09:40:00Z",
                    source: .goals,
                    goalID: "goal-1",
                    title: "Goal created",
                    summary: "Goal shell created locally."
                ),
                EventLedgerEntry(
                    id: "ledger.goal.updated.private",
                    kind: .goalUpdated,
                    occurredAt: "2026-06-14T09:41:00Z",
                    source: .goals,
                    goalID: "goal-1",
                    title: "Called the therapist",
                    summary: "Called the therapist about recovery details.",
                    trust: EventLedgerTrustMetadata(requiresReview: true),
                    metadata: ["privateContext": "therapy"],
                    payload: ["rawNote": "Called the therapist"],
                    privacy: .privateUserText
                )
            ],
            sideEffectLedger: [],
            privacyClassifications: [],
            generatedAt: "2026-06-14T09:45:00Z"
        )
    }

    func greenStorageBoundaryReport() -> StoragePrivacySecurityBoundaryReport {
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
        return storageValidator.validate(
            records: StoragePrivacyBoundaryCatalog.records(from: manifest, userReviewed: true),
            protectedMode: .enforcedReview
        )
    }

    func unsafeStorageBoundaryReport() -> StoragePrivacySecurityBoundaryReport {
        storageValidator.validate(
            records: [
                StoragePrivacyBoundaryRecord(
                    id: "unsafe-support",
                    title: "Unsafe support payload",
                    privacyClass: .privateSensitive,
                    indexingPolicy: .indexed,
                    exportPolicy: .safe,
                    destinations: [.supportBundle, .r2PublicSourcePack],
                    redactionSummary: "",
                    userReviewed: false
                )
            ],
            protectedMode: .notEnforced
        )
    }
}
